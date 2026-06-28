# Module 13 — CMS & blog

**Statut** : 🟡 Partiel  
**Spec** : CMS-01 à CMS-14

---

## Vision

Homepage dynamique multilingue, blog, pages légales, galerie, newsletter/contact — le tout éditable depuis l'admin sans redémarrage serveur.

## État réel

| Composant | État |
|-----------|------|
| API CMS + revalidation Next.js | ✅ |
| Admin `HomepageCmsPanel` | ✅ |
| Refresh instantané | 🟡 (corrigé partiellement) |
| Contenu seed CMS | ❌ (fallback i18n seul) |
| `/blog` liste | ✅ |
| `/blog/[slug]` détail | ❌ (404) |
| `/legal/[slug]` | 🟡 |
| Newsletter / contact | 🟡 (à valider bout-en-bout) |

## Recette

- Scénarios R-P1-01 à R-P1-06 — voir [RECETTE.md](../RECETTE.md)
- Aucun test automatisé

## Actions prioritaires

1. **P1** — Créer page `/blog/[slug]`
2. Seed contenu CMS pour recette Sarielle
3. Valider newsletter + contact → notification admin
4. E2E édition CMS → affichage < 10 s
