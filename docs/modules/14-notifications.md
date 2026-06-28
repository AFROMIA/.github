# Module 14 — Notifications

**Statut** : 🔴 Non opérationnel  
**Spec** : NOTIF-01 à NOTIF-08

---

## Vision

Push PWA (VAPID), notifications in-app (bell + WS), alertes admin (connexions, inscriptions, lives, clients premium).

## État réel

| Composant | État |
|-----------|------|
| API push subscribe | ✅ |
| `NotificationBell` + WS | ✅ |
| Celery `send_push_notification` | 🟡 |
| `pywebpush` installé | ❌ |
| VAPID keys configurées | ❌ |
| Notifications admin (REQ-56) | 🟡 (code présent, peu testé) |

## Bloqueurs

- B2 : Celery absent du dev standard
- B4 : `VAPID_*` vides
- Dépendance `pywebpush` manquante

## Recette

- Push subscribe + réception — voir [RECETTE.md](../RECETTE.md)
- Aucun test automatisé

## Actions prioritaires

1. Installer `pywebpush` + générer clés VAPID dev
2. Lancer Celery worker
3. Valider notification admin à chaque inscription
4. Valider push match / nouveau message
