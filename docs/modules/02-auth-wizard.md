# Module 02 — Auth & wizard Getting Started

**Statut** : 🟡 Partiel  
**Spec** : AUTH-01 à AUTH-10 · [SPEC](../SPECIFICATION_FONCTIONNELLE.md#module-1--authentification--compte)  
**Recette** : R-P0-01, R-P0-02 · [RECETTE](../RECETTE.md)

---

## Vision

Inscription fluide via wizard « Getting Started » (traduit), auto-save par champ, consentement IA opt-in, gate email vérifié avant Discover.

## Exigences clés

| ID | Exigence |
|----|----------|
| AUTH-01 | Inscription email/mot de passe |
| AUTH-04 | Vérification email obligatoire |
| AUTH-06 | OAuth (Google, Apple, etc.) si configuré |
| AUTH-09 | Wizard Getting Started multilingue |
| AUTH-10 | Consentement entraînement IA **désactivé par défaut** |
| AUTH-11 | Bloquer Discover sans email vérifié (pas seulement bandeau) |
| AUTH-12 | Pas de connexion prématurée pendant wizard |

## État réel

| Composant | État | Détail |
|-----------|------|--------|
| Routes auth backend | ✅ | register, login, refresh, OAuth, register-draft |
| Wizard `/getting-started` | 🟡 | 7 étapes ; bug redirect Sarielle signalé |
| `EmailVerificationGate` | ✅ | Bloque AppShell si email non vérifié |
| SMTP | 🔴 | Vide → emails loggés en dev uniquement |
| OAuth | 🔴 | Clés vides dans `.env.example` |
| Double parcours | 🟡 | `/onboarding` ET `/getting-started` coexistent |

## Fichiers clés

- `SAFIRI/apps/backend/app/api/v1/auth.py`
- `SAFIRI/apps/frontend/src/app/getting-started/`
- `SAFIRI/apps/frontend/src/components/auth/EmailVerificationGate.tsx`

## Tests

| Type | Couverture |
|------|------------|
| Auto | ✅ ~13 tests auth + 5 OAuth |
| Recette | R-P0-01, R-P0-02 — ⬜ |

## Actions prioritaires

1. **P0** — Corriger wizard : pas de login/redirect avant fin étapes
2. Documenter bypass recette (comptes staff seed ou lien email dev)
3. Unifier `/onboarding` vs `/getting-started`
4. E2E parcours wizard complet
