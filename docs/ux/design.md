# AFROMIA / SAFIRI — DESIGN SYSTEM & CREATIVE DIRECTION

# BRAND IDENTITY

## Company

AFROMIA

## Product

SAFIRI

## Positioning

Premium African futuristic lifestyle and AI-powered matchmaking platform.

The platform must feel:

* modern,
* emotionally intelligent,
* luxurious,
* warm,
* elegant,
* welcoming,
* international,
* premium African,
* vibrant without being aggressive.

Avoid:

* overly dark cyberpunk interfaces,
* cheap neon effects,
* generic dating-app visuals,
* excessive black backgrounds,
* old-fashioned African stereotypes,
* heavy orange/red-only palettes.

The UI must compete visually with:

* Apple,
* Airbnb,
* Stripe,
* Linear,
* Notion,
* Tinder,
* Bumble,
* Revolut,
* modern luxury African brands.

The design language must communicate:

* trust,
* aspiration,
* warmth,
* modern African excellence,
* emotional sophistication.

---

# GLOBAL DESIGN PHILOSOPHY

The interface must create the feeling of:

"A premium intelligent relationship ecosystem connecting the world to modern Africa."

The visual identity should blend:

* luxury tech startup,
* modern African elegance,
* emotional warmth,
* AI sophistication,
* travel and discovery inspiration.

The experience should feel:

* smooth,
* light,
* breathable,
* colorful,
* modern,
* immersive.

---

# PRIMARY COLOR SYSTEM

## CORE BRAND COLORS

### 1. SAFIRI GOLD

Primary luxury color.

HEX:
#D4A94D

Usage:

* CTA buttons
* highlights
* premium badges
* active indicators
* compatibility scores

---

### 2. EMERALD AFRICA

Secondary premium color.

HEX:
#0E9F6E

Usage:

* success states
* positive compatibility
* onboarding accents
* trust indicators

---

### 3. SUNSET COPPER

Warm African accent.

HEX:
#C76B3C

Usage:

* gradients
* hover states
* profile highlights
* illustrations

---

### 4. DEEP SAFARI BLUE

Main structural color.

HEX:
#1F3A5F

Usage:

* navbar
* sidebar
* footer
* premium sections

---

### 5. IVORY SAND

Primary background.

HEX:
#F7F4EE

Usage:

* main background
* cards
* sections

This prevents the UI from feeling too dark.

---

### 6. SOFT CHARCOAL

Main text color.

HEX:
#2A2A2A

Usage:

* text
* icons
* labels

---

# GRADIENTS

## Main Hero Gradient

linear-gradient(
135deg,
#1F3A5F 0%,
#0E9F6E 50%,
#D4A94D 100%
)

---

## Warm Luxury Gradient

linear-gradient(
135deg,
#C76B3C 0%,
#D4A94D 100%
)

---

## Discovery Gradient

linear-gradient(
135deg,
#0E9F6E 0%,
#56CCF2 100%
)

---

# UI STYLE RULES

## Cards

* rounded-xl or rounded-2xl
* soft shadows
* glassmorphism very subtle
* airy spacing
* elegant hover animation

Avoid:

* hard borders everywhere
* excessive opacity
* noisy shadows

---

# TYPOGRAPHY

## Recommended Fonts

### Primary

Inter

### Secondary

Plus Jakarta Sans

### Accent

Sora

---

# BUTTON STYLE

## Primary CTA

* warm gradient
* subtle hover glow
* rounded-xl
* smooth transitions

Example:
background:
linear-gradient(
135deg,
#D4A94D,
#C76B3C
)

---

# ANIMATION STYLE

Use:

* Framer Motion
* smooth transitions
* soft scaling
* floating gradients
* elegant swipe motion
* parallax hero effects

Avoid:

* excessive bouncing
* gamer effects
* flashy neon animations

---

# NAVIGATION DESIGN

# TOP NAVBAR

The navbar must feel:

* premium,
* floating,
* glassy,
* modern.

## Structure

LEFT:

* AFROMIA logo
* SAFIRI branding

CENTER:

* Discover
* Matches
* Messages
* Explore Africa
* AI Compatibility

RIGHT:

* notifications
* profile avatar
* premium badge
* settings dropdown

## Navbar Behavior

* sticky
* slightly transparent
* blur backdrop
* subtle border bottom
* animated on scroll

---

# SIDEBAR DESIGN

## Sidebar Requirements

* retractable/collapsible
* smooth animation
* icon-first navigation
* elegant hover effects
* responsive mobile drawer

## Sidebar Sections

### Main

* Home
* Discover
* Matches
* Messages
* Explore
* AI Insights

### Social

* Communities
* Events
* Travel

### Premium

* Upgrade
* Boost
* Compatibility+

### User

* Profile
* Settings
* Logout

---

# SWIPE EXPERIENCE

The swipe system must feel world-class.

Inspired by:

* Tinder
* Bumble
* Apple animations

## Requirements

* card stack animations
* realistic gestures
* subtle card tilt
* profile preview transitions
* compatibility score overlay
* AI insights animation
* animated match celebration

---

# MATCH SCREEN

When users match:

* cinematic animation
* glowing compatibility percentage
* smooth confetti particles
* African-inspired luxury motion graphics

Example:
"92% compatibility detected by AFFINIORA AI"

---

# AI VISUAL LANGUAGE

AFFINIORA AI must feel:

* intelligent,
* human,
* emotionally aware,
* premium.

Avoid robotic AI styling.

Use:

* smooth gradients
* flowing particles
* elegant neural visuals
* warm AI assistant interactions

---

# LANDING PAGE DESIGN

# HERO SECTION

Must immediately impress investors.

Include:

* cinematic gradient background
* premium African imagery
* animated floating UI cards
* live compatibility preview
* AI compatibility visualization
* swipe demo animation

Headline example:
"Discover meaningful connections powered by African AI innovation."

Subheadline:
"SAFIRI connects the world to Africa through intelligent relationships and cultural discovery."

CTA:

* Start Exploring
* Discover Africa
* Find Your Match

---

# MOBILE EXPERIENCE

The app must feel mobile-native.

Requirements:

* thumb-friendly UI
* smooth gestures
* native-like transitions
* responsive swipe interactions
* floating action buttons
* bottom navigation

---

# DARK MODE

Dark mode should NOT be pure black.

Use:

* deep navy
* dark emerald
* warm charcoal
* bronze highlights

The UI must remain colorful and premium.

---

# DESIGN REFERENCES

Combine inspiration from:

* Apple
* Airbnb
* Tinder
* Stripe
* Revolut
* Linear
* Notion
* modern African luxury brands

---

# FINAL DESIGN OBJECTIVE

The final experience must make users feel:

"This is not just another dating app."

It must feel like:

* the future of African digital lifestyle,
* emotionally intelligent technology,
* premium modern Africa,
* luxury social discovery,
* investor-grade startup quality.

The UI must be visually stunning from the very first screen.

---

# ROMANTIC UX COMPONENTS (2026)

## RomanticLoader

- Logo AFROMIA centré, anneaux dorés animés (Framer Motion)
- Proverbe africain aléatoire (`src/data/african-proverbs.json`)
- Variantes : `sm` | `md` | `full`

## PageTransition

- Fade + slide léger sur changement de route (`PageTransition` dans `AppShell`)

## DiscoverFloatingHub

- Bouton flottant repositionnable (4 coins, persisté localStorage)
- Onglets : **Filtres** | **Affiniora IA** | **Boutique**
- Redimensionnable (collapsed 320px / expanded 480px)
- Mobile : bottom sheet plein écran

## Match celebration

- Confettis `canvas-confetti` + particules Framer Motion
- Phase 1 : « Affiniora calcule… » + RomanticLoader
- Phase 2 : polling score Celery réel (jamais de faux %)
- Palette : or, émeraude, cuivre, safari
