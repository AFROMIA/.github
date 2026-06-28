# Module 12 — Appels vidéo WebRTC

**Statut** : 🟡 Partiel  
**Spec** : CALL-01 à CALL-04

---

## Vision

Appels vidéo P2P entre matchs : signaling WebSocket, STUN/TURN (coturn), UI modal (caméra, micro, mute, raccrocher).

## État réel

| Composant | État |
|-----------|------|
| Signaling `WS /ws/calls/{conv}` | ✅ |
| Sessions `video_call_sessions` | ✅ |
| UI modal appel | 🟡 |
| coturn (TURN) | 🟡 (docker-compose présent, peu testé) |

## Bloqueurs

- coturn non lancé par défaut dans `make dev`
- Recette 2 navigateurs jamais validée

## Recette

- Appel entre 2 navigateurs localhost — voir [RECETTE.md](../RECETTE.md)
- Aucun test automatisé

## Actions prioritaires

1. Documenter lancement coturn en local
2. Recette signaling → connexion P2P
3. Valider mute / raccrocher UI
