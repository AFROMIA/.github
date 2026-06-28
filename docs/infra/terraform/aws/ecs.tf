locals {
  services = {
    safiri-backend = {
      port          = 8000
      cpu           = 1024
      memory        = 2048
      desired_count = 1
      target_group  = aws_lb_target_group.backend.arn
      image         = "safiri-backend"
      command       = null
    }
    safiri-frontend = {
      port          = 3000
      cpu           = 512
      memory        = 1024
      desired_count = 1
      target_group  = aws_lb_target_group.frontend.arn
      image         = "safiri-frontend"
      command       = null
    }
    safiri-celery-worker = {
      port          = 0
      cpu           = 1024
      memory        = 2048
      desired_count = 1
      target_group  = null
      image         = "safiri-backend"
      command       = ["celery", "-A", "app.workers.celery_app", "worker", "--loglevel=info"]
    }
    safiri-celery-beat = {
      port          = 0
      cpu           = 256
      memory        = 512
      desired_count = 1
      target_group  = null
      image         = "safiri-backend"
      command       = ["celery", "-A", "app.workers.celery_app", "beat", "--loglevel=info"]
    }
    affiniora-ai-engine = {
      port          = 8001
      cpu           = 2048
      memory        = 8192
      desired_count = 1
      target_group  = null
      image         = "affiniora-ai-engine"
      command       = null
    }
  }

  common_env = [
    { name = "ENVIRONMENT", value = var.environment },
    { name = "DATABASE_URL", value = "postgresql+asyncpg://afromia:${var.db_password}@${aws_db_instance.postgres.address}:5432/afromia" },
    { name = "DATABASE_URL_SYNC", value = "postgresql+psycopg://afromia:${var.db_password}@${aws_db_instance.postgres.address}:5432/afromia" },
    { name = "REDIS_URL", value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379/0" },
    { name = "CELERY_BROKER_URL", value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379/1" },
    { name = "CELERY_RESULT_BACKEND", value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379/2" },
    { name = "AFFINIORA_API_URL", value = "http://affiniora-ai-engine.${local.name}.local:8001" },
    { name = "S3_BUCKET_NAME", value = aws_s3_bucket.media.id },
    { name = "AWS_REGION", value = var.aws_region },
  ]
}

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${local.name}.local"
  vpc         = aws_vpc.main.id
  description = "Service discovery for ${local.name}"
}

resource "aws_cloudwatch_log_group" "ecs" {
  for_each          = local.services
  name              = "/ecs/${local.name}/${each.key}"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "services" {
  for_each = local.services

  family                   = each.key
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name      = each.key
    image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${each.value.image}:${var.environment == "production" ? "production" : "staging"}"
    essential = true
    command   = each.value.command

    portMappings = each.value.port > 0 ? [{
      containerPort = each.value.port
      protocol      = "tcp"
    }] : []

    environment = each.key == "affiniora-ai-engine" ? [
      { name = "ENVIRONMENT", value = var.environment },
      { name = "REDIS_URL", value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379/3" },
      { name = "MODEL_CACHE_DIR", value = "/models/cache" },
    ] : each.key == "safiri-frontend" ? [
      { name = "NODE_ENV", value = "production" },
      { name = "NEXT_PUBLIC_API_URL", value = "https://${aws_cloudfront_distribution.main.domain_name}/api" },
      { name = "NEXT_PUBLIC_WS_URL", value = "wss://${aws_cloudfront_distribution.main.domain_name}" },
    ] : local.common_env

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs[each.key].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "services" {
  for_each = local.services

  name            = each.key
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = each.value.target_group != null ? [1] : []
    content {
      target_group_arn = each.value.target_group
      container_name   = each.key
      container_port   = each.value.port
    }
  }

  service_registries {
    registry_arn = aws_service_discovery_service.services[each.key].arn
  }

  depends_on = [aws_lb_listener.http]
}

resource "aws_service_discovery_service" "services" {
  for_each = local.services

  name = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_appautoscaling_target" "ecs" {
  for_each = { for k, v in local.services : k => v if v.desired_count > 0 && k != "safiri-celery-beat" }

  max_capacity       = each.key == "affiniora-ai-engine" ? 2 : 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${each.key}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  for_each = aws_appautoscaling_target.ecs

  name               = "${each.key}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
