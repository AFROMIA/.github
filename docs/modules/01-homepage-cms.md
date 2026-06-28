# Module 01 — Homepage & CMS multilingue

**Statut** : 🟡 Partiel  
**Spec** : CMS-HP-01 à CMS-HP-12 · [SPEC](../SPECIFICATION_FONCTIONNELLE.md#module-0--homepage--cms-multilingue)  
**Recette** : R-P1-01 à R-P1-06 · [RECETTE](../RECETTE.md#42-homepage--cms-p1)

---

## Vision

Page d'accueil premium entièrement éditable depuis le backoffice, multilingue (FR/EN + 8 langues), avec fallback i18n. Sections : hero (« relation enrichissante »), cards cliquables, vidéo/galerie, newsletter et contact en onglets.

## Exigences clés (demandes utilisateur)

| ID | Exigence |
|----|----------|
| CMS-HP-01 | Refonte homepage responsive premium |
| CMS-HP-02 | CMS + traductions par locale, fallback sur contenu dynamique |
| CMS-HP-03 | Hero : « relation enrichissante » (pas « intelligente ») |
| CMS-HP-04 | Cards → pages dédiées |
| CMS-HP-05 | Section vidéo + galerie photos/vidéos |
| CMS-HP-06 | Newsletter + contact via onglets (page non surchargée) |
| CMS-HP-07 | Galerie admin : upload fichiers locaux + URLs |
| CMS-HP-08 | Formulaires fonctionnels |
| CMS-HP-09 | Ancres navigation **uniquement** sur `/` |
| CMS-HP-10 | Mise à jour contenu sans redémarrage serveur |
| CMS-HP-11 | Sarielle chatbot sur homepage (langue navigateur) |
| CMS-HP-12 | Naming : SAFIRI (app), AFFINIORA (IA), Sarielle (agent) |

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Backend CMS homepage | ✅ | `cms.py`, `homepage_cms_service.py`, migration `009` |
| Admin `HomepageCmsPanel` | ✅ | Édition blocs, traductions, galerie |
| Frontend SSR + revalidate | 🟡 | Tags `homepage-cms` ; nécessite publication staff |
| Contenu seed | 🔴 | Aucun bloc CMS au seed → fallback i18n seul |
| Formulaires | 🟡 | Endpoints présents ; validation bout-en-bout à confirmer |
| Cache instantané | 🟡 | Revalidation implémentée ; bugs signalés partiellement résolus |

## Fichiers clés

- Backend : `SAFIRI/apps/backend/app/api/v1/cms.py`, `app/services/homepage_cms_service.py`
- Frontend : `SAFIRI/apps/frontend/src/app/page.tsx`, `components/home/`, `components/admin/HomepageCmsPanel.tsx`
- API revalidate : `SAFIRI/apps/frontend/src/app/api/revalidate/route.ts`

## Tests

| Type | Couverture |
|------|------------|
| Auto | ❌ Aucun |
| Recette | R-P1-01 à R-P1-06 — ⬜ non exécutés |

## Actions prioritaires

1. Seed contenu CMS homepage (FR + EN) pour recette immédiate
2. Valider formulaires newsletter/contact bout-en-bout
3. E2E : édition admin → visible sur `/` sans restart
4. Vérifier ancres limitées à la homepage
