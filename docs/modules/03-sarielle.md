# Module 03 — Sarielle (agent conversationnel)

**Statut** : 🟡 Partiel  
**Spec** : SAR-01 à SAR-08 · [SPEC](../SPECIFICATION_FONCTIONNELLE.md#module-3b--sarielle-agent-conversationnel)  
**Recette** : R-P1-07 à R-P1-10 · [RECETTE](../RECETTE.md)

---

## Vision

**Sarielle** est le **compagnon numérique personnel** d'AFROMIA — interface humaine d'AFFINIORA. Première fonction : aide à la navigation. Accessible sur homepage et pages info, repliable, avec choix de modèle. Pour utilisateurs connectés : accompagnement personnalisé (coach relationnel/pro, mémoire de vie avec consentement).

**Documents liés** : [Charte de fondation](../CHARTE_FONDATION.md) · [Constitution AFFINIORA](../CONSTITUTION_AFFINIORA.md) · [RECETTE](../RECETTE.md)

## Exigences clés

| ID | Exigence |
|----|----------|
| SAR-01 | Page `/sarielle` style prompt, choix modèle |
| SAR-02 | Aide navigation : liens directs, redirections |
| SAR-03 | Hub flottant repliable (homepage, pages info) |
| SAR-04 | Langue adaptée navigateur / préférences |
| SAR-05 | Wizard : choix rencontres directes ou Sarielle |
| SAR-06 | Utilisateurs existants : accès Sarielle depuis « Commencer » |
| SAR-07 | Persistance conversations |
| SAR-08 | Jobs async avec timeout et feedback |

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Backend proxy | ✅ | `chat.py` : status, sync/async, jobs, feedback, `conversation_context` v2.1 |
| AFFINIORA agent | ✅ | `conversation/` + `agents/sarielle.py` — multi-piliers écosystème |
| Frontend | ✅ | `/sarielle` (chips pilier), `SarielleFloatingHub`, `useSarielleChat` + page/connect_mode |
| KB écosystème | ✅ | `seed_ecosystem.py`, RAG pillar/entity, tests `test_ecosystem_qa.py` |
| Constitution v1.0 | ✅ | `seed_constitution.py`, `constitution_validator.py`, dernier rempart prompt + post-check |
| Actions Sarielle v1 | 🟡 | `SarielleAction` (navigate, suggest_register) — pas d'Action Gateway DB |
| Runtime | 🟡 | Staging : backend `affiniora: ok` ; badge UI après build frontend ; local via `make dev-affiniora` |
| Tests AFFINIORA | ✅ | `test_ecosystem_qa.py`, `test_constitution.py`, Sarielle, access policy |

## Intents Sarielle (juillet 2026)

| Intent | Usage |
|--------|-------|
| `ecosystem_info` | AFROMIA, vision, produits, charte |
| `pillar_guide` | Orientation par pilier (entreprendre, apprendre…) |
| `product_navigation` | Liens vers modules/produits |
| `conseil_profil`, `compatibilite`, … | SAFIRI Connect (rétrocompat) |

## Fichiers clés

- Backend : `SAFIRI/apps/backend/app/api/v1/chat.py`, `sarielle_enrichment.py`, `affiniora_helpers.py`
- AFFINIORA : `AFFINIORA/services/ai-engine/app/conversation/`
- Frontend : `SAFIRI/apps/frontend/src/app/sarielle/`, `hooks/useSarielleChat.ts`

## Actions prioritaires

1. **Bloqueur B1** : Affiniora up — local : [DEV_LOCAL_STACK](../../AFFINIORA/docs/DEV_LOCAL_STACK.md) ; staging : [ETAT_AVANCEMENT_AFFINIORA](../../AFFINIORA/docs/ETAT_AVANCEMENT_AFFINIORA.md)
2. Recette R-AFF-02 à 05 (badge via backend en staging)
3. Recette navigation assistée (R-P1-08)
4. UX offline claire (pas de réponses template trompeuses)
