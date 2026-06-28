# Module 20 — Wallet Safir

**Statut** : 🟡 Partiel (API + UI ; paiements externes non configurés)  
**Dépôt** : [SAFIRI](https://github.com/AFROMIA/SAFIRI)

---

## Vision

Monnaie interne **Safir** : solde utilisateur, conversion devises, tips, rechargement via Campay (mobile money Afrique), intégration premium.

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Migration 013 `wallet_safir` | ✅ | Tables ledger |
| API wallet, currency, Campay | ✅ | Code complet |
| UI `/wallet`, `TipButton`, `SafirAmount` | ✅ | Affichage devise |
| Client Campay | 🟡 | Sandbox non configuré |
| Recette transactions | ❌ | Non validée |

## Solution proposée

1. Obtenir credentials Campay sandbox
2. Variables `.env` : `CAMPAY_*` documentées dans `.env.example`
3. Recette : crédit admin → tip → solde mis à jour
4. Tests idempotence webhooks Campay

## Compétences requises

- **Backend** : transactions ACID, ledger double-entrée, webhooks
- **Paiements** : mobile money Afrique (Campay, MTN/Orange APIs)
- **Frontend** : affichage multi-devise, UX confiance paiement
- **Compliance** : traçabilité, anti-fraude basique

## Fichiers clés (SAFIRI)

- `apps/backend/app/application/wallet_service.py`
- `apps/backend/app/api/v1/wallet.py`
- `apps/frontend/src/app/wallet/`
