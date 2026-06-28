# Module 03 — Sarielle (agent conversationnel)

**Statut** : 🟡 Partiel  
**Spec** : SAR-01 à SAR-08 · [SPEC](../SPECIFICATION_FONCTIONNELLE.md#module-3b--sarielle-agent-conversationnel)  
**Recette** : R-P1-07 à R-P1-10 · [RECETTE](../RECETTE.md)

---

## Vision

**Sarielle** est l'agent conversationnel grand public d'AFROMIA. Première fonction : aide à la navigation du site. Accessible sur homepage et pages info, repliable, avec choix de modèle. Pour utilisateurs connectés : accompagnement personnalisé (si consentement IA).

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
| Backend proxy | ✅ | `chat.py` : status, sync/async, jobs, feedback |
| AFFINIORA agent | ✅ | `AFFINIORA/.../agents/sarielle.py` |
| Frontend | ✅ | `/sarielle`, `SarielleFloatingHub`, `useSarielleChat` |
| Runtime | 🟡 | **502/offline si AFFINIORA down** |
| Tests AFFINIORA | ✅ | 8+ tests Sarielle |

## Fichiers clés

- Backend : `SAFIRI/apps/backend/app/api/v1/chat.py`
- AFFINIORA : `AFFINIORA/services/ai-engine/app/agents/sarielle.py`
- Frontend : `SAFIRI/apps/frontend/src/app/sarielle/`, `hooks/useSarielleChat.ts`

## Actions prioritaires

1. Garantir AFFINIORA up dans dev (bloqueur B1)
2. Recette navigation assistée (R-P1-08)
3. UX offline claire (pas de réponses template trompeuses)
