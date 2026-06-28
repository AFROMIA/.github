# Module 09 — Premium & paiements

**Statut** : 🟡 Partiel (checkout codé, clés staging absentes)  
**Spec** : PREM-01 à PREM-08

---

## Vision

Monétisation via abonnements Stripe, wallet Safir et Campay (mobile money) : likes illimités, coaching IA premium, boost, offerings channels.

## État réel (juin 2026)

| Composant | État |
|-----------|------|
| API Stripe / webhooks | ✅ |
| Client Campay | ✅ (code) |
| Page `/premium` | ✅ |
| Page `/premium/checkout` | ✅ (nouveau) |
| Page `/premium/success` | 🟡 |
| Clés API configurées | ❌ |
| Quota likes free | 🟡 |

## Solution proposée

1. Configurer Stripe test mode (`STRIPE_SECRET_KEY`, webhook secret)
2. Campay sandbox pour rechargement Safir ([module 20](./20-wallet-safir.md))
3. E2E : checkout → webhook → rôle premium actif
4. Page success avec redirection profil

## Compétences requises

- Stripe Checkout / webhooks, idempotence
- Campay API (mobile money Afrique)
- FastAPI middleware sécurité webhooks
- Next.js pages paiement, gestion erreurs UX

## Recette

- Scénario R-P2-01 — voir [RECETTE.md](../RECETTE.md)
- Tests manuels checkout staging requis

## Actions prioritaires

1. Clés Stripe staging dans `.env`
2. Valider webhook → `user.is_premium`
3. Lier premium → `ia_gating` (cloud LLM Sarielle)
