# Module 05 — AFFINIORA (moteur IA)

**Statut** : 🟡 Partiel  
**Spec** : AI-01 à INT-07 · [SPEC](../SPECIFICATION_FONCTIONNELLE.md#module-3--intelligence-affiniora)

---

## Vision

Moteur IA propriétaire self-hosted : scoring compatibilité, personnalité, anti-fake, suggestions chat. **Aucun faux pourcentage** — scores réels visibles partout.

## Exigences clés (demandes utilisateur)

| ID | Exigence |
|----|----------|
| AI-01 | Vrais scores compatibilité (pas hash 65–95 %) |
| AI-02 | Quiz → personnalité sous 60 s |
| INT-05 | Discover : score réel ou indicateur « IA indisponible » |
| INT-06 | Onglet Affiniora dans hub Discover |
| AI-07 | Pas de fallback silencieux à 65 % |

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Microservice AFFINIORA | ✅ | Endpoints v1 + v2, admin `reindex-ecosystem`, `reindex-constitution` |
| Constitution & garde-fous | ✅ | `constitution_validator.py`, KB `category: constitution`, logs refus |
| Architecture cognition/conversation | ✅ | `cognition/`, `conversation/`, `domain_router` |
| Contrat v2.1 ConversationContext | ✅ | `pillar`, `page`, `connect_mode` cross-repo |
| KB écosystème | ✅ | 25+ chunks charte, indexeur markdown |
| Contrat v2 UserProfileIA | ✅ | `CONTRACT_V2.md`, adaptateur legacy |
| Intégration SAFIRI | ✅ | `profile_ia_aggregator`, `rag_service`, `ia_gating` |
| Routeur LLM cloud/local | ✅ | Premium → cloud ; free → Qwen local |
| Tests AFFINIORA | ✅ | `test_ecosystem_qa.py`, `test_constitution.py`, Sarielle, access policy |
| **Staging ECS** | 🟡 | Reachable via backend après SG + env (11/07) ; redeploy frontend SAFIRI pour badge UI |
| **Local testable** | ✅ | Stack `make dev-split` — [DEV_LOCAL_STACK](../../AFFINIORA/docs/DEV_LOCAL_STACK.md) |

## Fichiers clés

- `AFFINIORA/services/ai-engine/app/cognition/`
- `AFFINIORA/services/ai-engine/app/conversation/`
- `AFFINIORA/services/ai-engine/app/knowledge/seed_ecosystem.py`
- `AFFINIORA/services/ai-engine/app/knowledge/seed_constitution.py`
- `AFFINIORA/services/ai-engine/app/cognition/constitution_validator.py`
- `SAFIRI/apps/backend/app/application/profile_ia_aggregator.py`
- `SAFIRI/apps/backend/app/application/ia_gating.py`
- `SAFIRI/packages/shared-types/src/profile-ia.ts`

## Actions prioritaires

1. Remettre Affiniora en ligne staging (SG ECS, env OOM, health via backend) — [ETAT_AVANCEMENT_AFFINIORA](../../AFFINIORA/docs/ETAT_AVANCEMENT_AFFINIORA.md)
2. Recette R-AFF-01 à 05 (local puis staging)
3. Recette bout-en-bout analyse profil + coaching premium
4. AFFINIORA + Celery obligatoires dans checklist dev (`make dev-split`)
