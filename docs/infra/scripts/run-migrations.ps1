#Requires -Version 5.1
<#
.SYNOPSIS
    Execute Alembic migrations via ECS run-task (one-shot).
.EXAMPLE
    .\run-migrations.ps1 -Profile afromia-dev -Environment staging
#>
param(
    [string]$Profile = "afromia-dev",
    [string]$Region = "eu-west-1",
    [string]$Environment = "staging"
)

$ErrorActionPreference = "Stop"
$Cluster = "afromia-$Environment"
$TaskFamily = "safiri-backend"

Write-Host "Recuperation de la task definition $TaskFamily..." -ForegroundColor Yellow
$taskDef = aws ecs describe-task-definition --task-definition $TaskFamily --profile $Profile --region $Region --output json | ConvertFrom-Json
$taskDefArn = $taskDef.taskDefinition.taskDefinitionArn

$network = aws ec2 describe-subnets --filters "Name=tag:Name,Values=afromia-$Environment-public-*" --profile $Profile --region $Region --output json | ConvertFrom-Json
$subnetIds = ($network.Subnets | Select-Object -First 2).SubnetId -join ","

$sg = aws ec2 describe-security-groups --filters "Name=group-name,Values=afromia-$Environment-ecs" --profile $Profile --region $Region --query "SecurityGroups[0].GroupId" --output text

$overrides = @{
    containerOverrides = @(
        @{
            name    = "safiri-backend"
            command = @("alembic", "upgrade", "head")
        }
    )
} | ConvertTo-Json -Depth 5 -Compress

Write-Host "Lancement migration ECS..." -ForegroundColor Yellow
$result = aws ecs run-task `
    --cluster $Cluster `
    --task-definition $taskDefArn `
    --launch-type FARGATE `
    --network-configuration "awsvpcConfiguration={subnets=[$subnetIds],securityGroups=[$sg],assignPublicIp=ENABLED}" `
    --overrides $overrides `
    --profile $Profile `
    --region $Region `
    --output json | ConvertFrom-Json

$taskArn = $result.tasks[0].taskArn
Write-Host "Task: $taskArn" -ForegroundColor Cyan
Write-Host "Suivi: aws ecs describe-tasks --cluster $Cluster --tasks $taskArn --profile $Profile" -ForegroundColor Gray
