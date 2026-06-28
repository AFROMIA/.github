# Module 08 — Chat & messagerie

**Statut** : 🚧 En cours (bugs signalés)  
**Spec** : CHAT-01 à CHAT-12

---

## Vision

Messagerie temps réel : texte, emojis, GIF, images, suggestions IA, cadeaux, indicateur frappe, présence en ligne/hors ligne, services payants intégrables.

## Bugs signalés (utilisateur)

| Bug | Description |
|-----|-------------|
| CHAT-BUG-01 | Message envoyé n'apparaît pas immédiatement dans le thread |
| CHAT-BUG-02 | Message visible dans liste gauche mais pas dans conversation sans refresh |
| CHAT-BUG-03 | Indicateur en ligne/hors ligne à valider |

## État réel

| Composant | État |
|-----------|------|
| REST + WebSocket | ✅ |
| Typing indicator | ✅ |
| Optimistic UI | 🚧 (bugs) |
| Suggestions IA | 🟡 (AFFINIORA) |
| Cadeaux virtuels | 🟡 |

## Fichiers clés

- `chat.py`, `chat_ws.py`
- `ChatWindow`, `useChatWebSocket`

## Actions prioritaires

1. **P0** — Corriger affichage message instantané (CHAT-BUG-01/02)
2. pytest + E2E chat WS (R-P0-06)
3. Présence en ligne visible en chat
