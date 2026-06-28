# Module 10 — Live streaming

**Statut** : 🟡 Partiel  
**Spec** : LIVE-01 à LIVE-06

---

## Vision

Sessions live hébergées (LiveKit) : création, commentaires temps réel, cadeaux/pourboires, feed des lives actifs.

## État réel

| Composant | État |
|-----------|------|
| API sessions live | ✅ |
| Token LiveKit | 🟡 (clés requises, secret ≥ 32 car.) |
| WebSocket commentaires | ✅ |
| Cadeaux live (Stripe) | 🟡 |
| Page `/live` | 🟡 |

## Bloqueurs

- `LIVEKIT_*` non configuré en local standard
- Stripe requis pour pourboires

## Recette

- Scénario live session — voir [RECETTE.md](../RECETTE.md) § 4.5
- Aucun test automatisé

## Actions prioritaires

1. Configurer LiveKit dev
2. Recette host → viewer → commentaire
3. Notification admin live en cours (module 14)
