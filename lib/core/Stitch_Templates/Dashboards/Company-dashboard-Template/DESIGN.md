---
name: Institutional ESG Excellence
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#44474d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#75777e'
  outline-variant: '#c5c6cd'
  surface-tint: '#515f78'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#0d1c32'
  on-primary-container: '#76849f'
  inverse-primary: '#b9c7e4'
  secondary: '#006875'
  on-secondary: '#ffffff'
  secondary-container: '#00e3fd'
  on-secondary-container: '#00616d'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#002204'
  on-tertiary-container: '#469446'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#b9c7e4'
  on-primary-fixed: '#0d1c32'
  on-primary-fixed-variant: '#39475f'
  secondary-fixed: '#9cf0ff'
  secondary-fixed-dim: '#00daf3'
  on-secondary-fixed: '#001f24'
  on-secondary-fixed-variant: '#004f58'
  tertiary-fixed: '#a3f69c'
  tertiary-fixed-dim: '#88d982'
  on-tertiary-fixed: '#002204'
  on-tertiary-fixed-variant: '#005312'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 20px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

This design system is engineered for the intersection of high-finance reliability and environmental consciousness. The brand personality is **Institutional, Trustworthy, and Visionary**. It balances the weight of a traditional financial institution with the agility and transparency of a modern sustainable tech startup.

The visual style merges **Minimalism** with sophisticated **Glassmorphism**. High-density information is presented through a "less-is-more" lens, utilizing expansive whitespace to reduce cognitive load. The aesthetic emphasizes clarity and precision, ensuring users feel a sense of calm and control over their impact-driven investments.

## Colors

The palette is anchored by **Deep Navy (#0A192F)**, providing the institutional foundation and high-contrast legibility against a crisp **White** base. 

- **Primary Blue (#2563EB):** Used for primary actions and brand-led interactive elements to instill confidence.
- **Vibrant Cyan (#00E5FF):** Reserved for highlights, data visualization, and "forward-looking" ESG metrics.
- **Mint Green (#A7F3D0):** Employed for positive environmental status, sustainability indicators, and subtle progress fills.
- **Backgrounds:** Utilize a cool-toned neutral gray (#F8FAFC) to differentiate surfaces from the pure white cards.

## Typography

This design system utilizes a dual-font strategy to balance character with utility. **Manrope** is used for headlines to provide a modern, geometric, and premium feel. **Inter** is utilized for all body copy and UI labels to ensure maximum readability at small sizes, crucial for complex financial data.

Maintain a strict vertical rhythm. Large display text should always use tighter letter spacing for a more "locked-in" professional appearance, while small labels use increased letter spacing for clarity on mobile displays.

## Layout & Spacing

The system follows a **Mobile-First Fluid Grid**. On mobile devices, a 4-column structure is used with 20px side margins to provide breathing room. On larger screens, this expands to a 12-column grid.

Spacing follows a strict 4px/8px base unit system to maintain mathematical harmony. Components should favor "Stack" layouts, where vertical spacing is used to group related information clusters (e.g., ESG scores grouped with their respective category icons).

## Elevation & Depth

Depth is articulated through **Glassmorphism** and **Tonal Layering** rather than traditional heavy shadows.

- **Surface 1 (Base):** Light gray (#F8FAFC) background.
- **Surface 2 (Cards):** Pure white with a very subtle, diffused 4% opacity navy shadow.
- **Surface 3 (Overlays):** 70% opacity white with a 20px backdrop blur and a thin 1px white border (0.1 opacity) to simulate frosted glass.
- **Interaction:** Upon press, elements should slightly scale down (98%) rather than increasing shadow depth, mimicking a physical tactile response.

## Shapes

The shape language is defined by generous, organic curves that soften the "institutional" feel. Standard cards and containers use a **16px (1rem)** corner radius. Small interactive components like buttons and input fields use **8px (0.5rem)**, while status chips use a fully rounded **Pill** shape for distinct visual categorization.

## Components

- **Buttons:** Primary buttons use the Deep Navy base with white text. Secondary buttons utilize a glass effect (white with blur). All buttons feature 16px horizontal padding and 12px vertical padding.
- **Cards:** Must have a 1px border (#E2E8F0) and 16px+ corner radius. Use glassmorphism for internal card sections (e.g., a "Current Impact" sub-section).
- **Status Chips:** Small, pill-shaped elements. Environmental "Positive" chips use a light mint background with dark green text. Financial "Neutral" chips use a light blue background.
- **Progress Bars:** Thin (4px - 6px) tracks. The progress fill should use a gradient from Primary Blue to Vibrant Cyan to represent "growth" and "energy."
- **Icons:** Use 24px thin-line icons (1.5px stroke width). Avoid filled icons unless used as a toggle state.
- **Inputs:** Clean, bottom-border-only or light-gray filled fields with 8px radius. Focus states must use the Vibrant Cyan for the border color.
- **Impact Meters:** Semi-circular gauges or vertical bar charts with rounded caps to visualize ESG scores.