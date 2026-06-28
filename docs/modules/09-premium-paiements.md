# Module 09 — Premium & paiements

**Statut** : 🔴 Non opérationnel (config manquante)  
**Spec** : PREM-01 à PREM-08

---

## Vision

Monétisation via abonnements Stripe/PayPal : likes illimités, likes reçus, visiteurs profil, boost. Quota free avec reset quotidien.

## État réel

| Composant | État |
|-----------|------|
| API Stripe / PayPal | ✅ (code) |
| Clés API configurées | ❌ |
| Page `/premium` | 🟡 |
| Page `/premium/success` | ❌ (404) |
| Webhooks | 🟡 (non testés) |
| Quota likes free | 🟡 |

## Bloqueurs

- `STRIPE_SECRET_KEY`, `PAYPAL_*` vides dans `.env`
- Route success absente → parcours checkout incomplet

## Recette

- Scénario R-P2-01 (Stripe test mode) — voir [RECETTE.md](../RECETTE.md)
- Aucun test automatisé

## Actions prioritaires

1. Configurer Stripe staging (clés test)
2. Créer `/premium/success`
3. Valider webhook → statut premium actif
4. E2E checkout test mode
