# Module 22 — Speed dating live

**Statut** : 🚧 En cours  
**Dépôt** : [SAFIRI](https://github.com/AFROMIA/SAFIRI)

---

## Vision

Sessions speed dating orchestrées : compte à rebours, salles LiveKit, WebSocket pour synchronisation, liées aux offerings channels.

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| API `speed_dating.py` | ✅ | CRUD sessions |
| `speed_dating_orchestrator` | ✅ | Machine à états |
| WebSocket `speed_dating_ws` | ✅ | Événements temps réel |
| `livekit_helpers` | ✅ | Tokens room |
| UI `SpeedDatingRoom`, countdown | 🟡 | Basique |
| Recette 2 utilisateurs | ❌ | LiveKit local requis |

## Solution proposée

1. Documenter LiveKit dans [start.md](../../start.md) (ws://localhost:7880)
2. Seed offering speed-dating + 2 comptes test
3. Test manuel : join → countdown → room → leave
4. Gestion timeout / no-show

## Compétences requises

- **Temps réel** : WebSocket, orchestration états
- **WebRTC** : LiveKit SDK, tokens JWT
- **Frontend** : UX session live, gestion erreurs réseau
- **Produit** : règles speed dating (durée, rotation)

## Fichiers clés (SAFIRI)

- `apps/backend/app/application/speed_dating_orchestrator.py`
- `apps/frontend/src/app/speed-dating/`
- `apps/frontend/src/components/speed-dating/`
