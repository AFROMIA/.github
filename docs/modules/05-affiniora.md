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
| Microservice AFFINIORA | ✅ | Endpoints v1 + v2 (`/v1/analyze/profile-full`, Sarielle jobs) |
| Contrat v2 UserProfileIA | ✅ | `CONTRACT_V2.md`, adaptateur legacy `profile_data_to_ia()` |
| Intégration SAFIRI | ✅ | `profile_ia_aggregator`, `rag_service`, `ia_gating` |
| Routeur LLM cloud/local | ✅ | Premium → cloud ; free → Qwen local |
| Debug panel IA Lab | ✅ | Appels directs navigateur → AFFINIORA (CORS + admin key) |
| Fallback score 65 | 🟡 | Indicateur « IA indisponible » en cours de généralisation |
| Celery tasks | 🟡 | Inactif sans worker |
| Tests AFFINIORA | ✅ | profile adapter, profile analysis, Sarielle instant |

## Fichiers clés

- `AFFINIORA/services/ai-engine/app/engines/profile_analysis_engine.py`
- `AFFINIORA/services/ai-engine/app/agents/llm_router.py`
- `SAFIRI/apps/backend/app/application/profile_ia_aggregator.py`
- `SAFIRI/apps/backend/app/application/ia_gating.py`
- `SAFIRI/packages/shared-types/src/profile-ia.ts`
- Frontend : `IaLabTab`, `ProfileAnalysisClient`, `SwipeCardStack`

## Actions prioritaires

1. Recette bout-en-bout analyse profil + coaching premium
2. AFFINIORA + Celery obligatoires dans checklist dev (`make dev-split`)
3. Recette scores réels sur feed seed (R-P0-04)
