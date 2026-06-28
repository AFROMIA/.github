# Module 11 — Boutique cadeaux

**Statut** : 🟡 Partiel  
**Spec** : SHOP-01 à SHOP-05

---

## Vision

Catalogue cadeaux virtuels (chat, Discover hub) et physiques (livraison). Onglet shop intégré au hub flottant Discover.

## État réel

| Composant | État |
|-----------|------|
| Catalogue API | ✅ |
| `GiftShopTab` (hub Discover) | ✅ |
| Envoi cadeau virtuel → message chat | 🟡 |
| Commande physique + adresse | 🟡 |
| Creator shop | 🟡 |
| Paiement Stripe | ❌ (clés absentes) |

## Recette

- Achat + envoi cadeau virtuel — voir [RECETTE.md](../RECETTE.md)
- Aucun test automatisé

## Actions prioritaires

1. Valider cadeau virtuel visible dans thread chat (type `gift`)
2. Stripe test pour commande physique
3. E2E hub Discover → shop → envoi
