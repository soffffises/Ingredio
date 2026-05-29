---
name: Culinary Intelligence
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e4e2e1'
  on-surface: '#1b1c1c'
  on-surface-variant: '#414844'
  inverse-surface: '#303030'
  inverse-on-surface: '#f3f0f0'
  outline: '#717973'
  outline-variant: '#c1c8c2'
  surface-tint: '#3f6653'
  primary: '#012d1d'
  on-primary: '#ffffff'
  primary-container: '#1b4332'
  on-primary-container: '#86af99'
  inverse-primary: '#a5d0b9'
  secondary: '#934b00'
  on-secondary: '#ffffff'
  secondary-container: '#fd8603'
  on-secondary-container: '#5f2f00'
  tertiary: '#262625'
  on-tertiary: '#ffffff'
  tertiary-container: '#3c3c3a'
  on-tertiary-container: '#a8a6a4'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c1ecd4'
  primary-fixed-dim: '#a5d0b9'
  on-primary-fixed: '#002114'
  on-primary-fixed-variant: '#274e3d'
  secondary-fixed: '#ffdcc4'
  secondary-fixed-dim: '#ffb781'
  on-secondary-fixed: '#301400'
  on-secondary-fixed-variant: '#703800'
  tertiary-fixed: '#e5e2df'
  tertiary-fixed-dim: '#c8c6c3'
  on-tertiary-fixed: '#1c1c1a'
  on-tertiary-fixed-variant: '#474745'
  background: '#fcf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e1'
typography:
  headline-xl:
    fontFamily: Source Serif 4
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Source Serif 4
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Source Serif 4
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: Source Serif 4
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 20px
  margin-desktop: 40px
  gutter: 16px
  stack-sm: 12px
  stack-md: 24px
  stack-lg: 48px
---

## Brand & Style
The design system is built on the "Foodie Modern" philosophy, targeting home cooks who value both health and culinary delight. The brand personality is that of a knowledgeable, fresh, and professional sous-chef—efficient but deeply passionate about ingredients.

The visual style blends **Minimalism** with **Tactile** warmth. It utilizes generous white space (represented by soft creams) to allow high-resolution food photography to take center stage. The emotional response should be one of "attainable aspiration"—making healthy, ingredient-based cooking feel organized, vibrant, and appetizing.

## Colors
This design system utilizes a palette rooted in natural, appetizing tones:

- **Primary (Forest Green):** Used for primary actions, success states, and healthy categorization. It conveys freshness and reliability.
- **Secondary (Warm Orange):** An accent color used sparingly for high-utility call-to-actions, cooking timers, and "appetite-triggering" highlights.
- **Surface (Cream):** The primary background color. It is softer and more organic than pure white, reducing eye strain and evoking a kitchen-counter feel.
- **Neutral (Charcoal):** Used for maximum legibility in body text and structural elements like borders.

## Typography
The typography strategy employs a high-contrast pairing to balance editorial elegance with functional clarity. 

**Source Serif 4** is used for headlines and recipe titles to provide an authoritative, cookbook-like feel. It brings a sense of tradition and "foodie" credibility. **Plus Jakarta Sans** is used for all functional UI elements, ingredient lists, and instructions. Its soft, rounded terminals complement the overall shape language of the design system, ensuring the interface feels approachable and modern.

## Layout & Spacing
The layout follows a **Fluid Grid** model focused on mobile-first consumption.

- **Mobile:** A 4-column grid with 20px side margins. Content cards (like recipes) typically span the full width or 2 columns.
- **Vertical Rhythm:** A strict 8px baseline grid is used. Spacing between related items (ingredient name and quantity) uses `stack-sm`, while spacing between distinct sections (Ingredients and Instructions) uses `stack-lg`.
- **Safe Areas:** Elements should never touch the edge of the viewport; use a minimum of 20px padding for all text containers to maintain a premium, "breathable" feel.

## Elevation & Depth
This design system uses **Tonal Layers** and **Ambient Shadows** to create a gentle sense of hierarchy. 

- **Level 0 (Base):** The Cream background (`#F8F5F2`).
- **Level 1 (Cards/Surface):** Pure white surfaces with a very soft, diffused shadow (15% opacity Forest Green tint) to make recipe cards appear "lifted" from the counter.
- **Level 2 (Active Elements):** Overlays and modals utilize a subtle Backdrop Blur (8px) to maintain the context of the kitchen environment while focusing the user's attention.
- **Interactions:** Avoid heavy inner shadows. Depth is communicated through slight color shifts rather than simulated physical distance.

## Shapes
The shape language is defined by **Soft Roundedness**, specifically targeting a 24px corner radius for major containers to evoke a friendly, organic feel.

- **Main Cards & Containers:** Use `rounded-xl` (1.5rem / 24px) to create a distinct, modern silhouette.
- **Buttons & Inputs:** Use `rounded-lg` (1rem / 16px) for a comfortable touch target that remains consistent with the card language.
- **Image Assets:** Food photography must always be masked with the system's rounded corners to avoid "harsh" edges that conflict with the soft brand personality.

## Components
- **Buttons:** Primary buttons use the Forest Green background with White text. Secondary buttons use a Forest Green outline with a 1px weight. The "Start Cooking" action is a fixed bottom-screen floating button.
- **Ingredient Chips:** Small, pill-shaped tags used to show available vs. missing ingredients. Missing ingredients use a soft tonal Forest Green background (10% opacity) with Forest Green text.
- **Input Fields:** Search bars and quantity selectors use a White background with a 1px Forest Green border at 20% opacity. On focus, the border becomes 100% Forest Green.
- **Recipe Cards:** The hero of the UI. Featured cards use a vertical stack: Image (top, 200px height), Title (Serif), and Metadata (Prep time, Calories).
- **Progressive Disclosure:** Use "Step-by-Step" cards for instructions, showing only one instruction at a time to reduce cognitive load while cooking.
- **Checkboxes:** Custom circular checkboxes for ingredient lists to mirror the rounded shape language of the brand.