# Mobile Design Guidelines

A comprehensive guide for implementing mobile-first design patterns in Leptos-Shadcn-UI components.

## Table of Contents

1. [Principles](#principles)
2. [Responsive Breakpoints](#responsive-breakpoints)
3. [Orientation Support](#orientation-support)
4. [Layout Patterns](#layout-patterns)
5. [Component Guidelines](#component-guidelines)
6. [Touch Targets](#touch-targets)
7. [Typography](#typography)
8. [Spacing](#spacing)
9. [Navigation](#navigation)
10. [Forms](#forms)
11. [Performance](#performance)

---

## Principles

### Mobile-First Approach

Mobile-first means designing for the smallest screen first, then progressively enhancing for larger screens. This approach:

- **Forces prioritization** - Focus on core content and features
- **Improves performance** - Base styles are lightweight
- **Enhances maintainability** - Less complex CSS overrides
- **Better UX** - Mobile users get optimized experience, not an afterthought

### Core Principles

1. **Content First**: Design around content hierarchy, not layout
2. **Progressive Enhancement**: Start simple, add complexity for larger screens
3. **Touch-Friendly**: Ensure interactive elements work well on touch devices
4. **Performance Optimized**: Minimize resource usage on mobile devices
5. **Accessibility**: Mobile design should enhance, not reduce, accessibility

---

## Responsive Breakpoints

### Standard Breakpoints

Based on Tailwind CSS default breakpoints:

```css
/* Mobile First - No breakpoint for base styles */

/* Small devices (640px and up) */
@media (min-width: 640px) { /* sm: */ }

/* Medium devices (768px and up) */
@media (min-width: 768px) { /* md: */ }

/* Large devices (1024px and up) */
@media (min-width: 1024px) { /* lg: */ }

/* Extra large devices (1280px and up) */
@media (min-width: 1280px) { /* xl: */ }

/* 2X Large devices (1536px and up) */
@media (min-width: 1536px) { /* 2xl: */ }
```

### Tailwind Class Usage

```rust
// Mobile first: Base styles apply to all screens
const CLASS_BASE = "w-full px-4";

// Add enhancements for larger screens
const CLASS_RESPONSIVE = "w-full px-4 sm:px-6 md:px-8 lg:w-3/4 lg:px-0";
```

### Breakpoint Strategy

- **Default**: Assume mobile (320px-639px)
- **sm**: Small tablets, large phones (640px+)
- **md**: Tablets (768px+)
- **lg**: Small laptops, desktops (1024px+)
- **xl**: Standard desktops (1280px+)
- **2xl**: Large desktops (1536px+)

---

## Orientation Support

### Why Orientation Matters

Modern devices support both portrait and landscape orientations, each presenting unique design opportunities:

- **Portrait**: Traditional mobile view, optimal for single-handed use
- **Landscape**: Wider viewport, better for tablets, media consumption, and productivity

**Important**: Always test your components in both orientations!

### Orientation Media Queries

```css
/* Landscape (width > height) */
@media (orientation: landscape) {
  /* Styles for landscape mode */
}

/* Portrait (height > width) */
@media (orientation: portrait) {
  /* Styles for portrait mode */
}
```

### Orientation + Breakpoint Combinations

```css
/* Tablet landscape (768px+ in landscape) */
@media (min-width: 768px) and (orientation: landscape) {
  /* Tablet-specific landscape styles */
}

/* Mobile landscape (phones in landscape) */
@media (min-width: 480px) and (orientation: landscape) {
  /* Mobile landscape styles */
}
```

### Common Orientation Patterns

```rust
// Stack in portrait, row in landscape
const ORIENTATION_AWARE = &str =
    "flex flex-col portrait:flex-col landscape:flex-row";

// Single column portrait, two column landscape
const ORIENTATION_GRID = &str =
    "grid grid-cols-1 portrait:grid-cols-1 landscape:grid-cols-2";

// Hide bottom nav in landscape, show in portrait
const BOTTOM_NAV = &str =
    "fixed bottom-0 left-0 right-0 landscape:hidden portrait:block";
```

### Landscape-Specific Utilities

Include the orientation CSS file for additional utilities:

```html
<link rel="stylesheet" href="/style/orientation.css">
```

Available classes:
- `landscape:flex-row` - Row direction in landscape
- `landscape:grid-cols-2` - 2 columns in landscape
- `landscape:gap-6` - Larger gap in landscape
- `landscape:hidden` - Hide in landscape
- `landscape-md:grid-cols-3` - Tablet landscape: 3 columns

### Tablet Landscape Best Practices

Tablets in landscape mode are a primary use case:
- Use horizontal space for side-by-side content
- Implement horizontal navigation when appropriate
- Consider split-screen multitasking scenarios
- Maintain touch-friendly sizing (44×44px minimum)

**See Also**: [Landscape Orientation Guide](./landscape-orientation.md) for comprehensive landscape support guidelines.

---

## Layout Patterns

### Container Pattern

Containers provide max-width and centering for content.

```rust
// Mobile-first container
const CONTAINER_CLASS = &str =
    "w-full mx-auto px-4 sm:px-6 lg:px-8";

// With max-width
const CONTAINER_CONSTRAINED = &str =
    "w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8";
```

### Grid Pattern

Responsive grids that stack on mobile, expand on desktop.

```rust
// Single column on mobile, multi on desktop
const GRID_RESPONSIVE = &str =
    "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4";

// Auto-fit with min-width
const GRID_AUTO = &str =
    "grid grid-cols-[minmax(280px,1fr)] gap-4";
```

### Stack Pattern

Vertical stacking on mobile, horizontal on desktop.

```rust
// Stack on mobile, row on desktop
const FLEX_STACK = &str =
    "flex flex-col md:flex-row gap-4";

// Centered stack, distributed on desktop
const FLEX_DISTRIBUTED = &str =
    "flex flex-col md:flex-row md:items-center md:justify-between gap-4";
```

### Card Grid Pattern

```rust
const CARD_GRID = &str =
    "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4";

const CARD_GRID_DENSE = &str =
    "grid grid-cols-1 auto-rows-fr sm:grid-cols-2 lg:grid-cols-3 gap-4";
```

---

## Component Guidelines

### Button

Buttons must meet minimum touch target size (44px min).

```rust
// Base button - mobile friendly size
const BUTTON_CLASS = &str =
    "inline-flex items-center justify-center \
     rounded-md text-sm font-medium \
     h-10 px-4 py-2 \
     transition-colors \
     focus-visible:outline-none focus-visible:ring-2";

// Sizes
const BUTTON_SM = &str = "h-9 px-3"; // Minimum 36px
const BUTTON_MD = &str = "h-10 px-4"; // Minimum 40px
const BUTTON_LG = &str = "h-11 px-8"; // Minimum 44px

// Full width on mobile for primary actions
const BUTTON_FULL_MOBILE = &str =
    "w-full sm:w-auto";
```

### Input

Inputs should be full-width on mobile for usability.

```rust
const INPUT_BASE = &str =
    "flex h-10 w-full rounded-md border \
     px-3 py-2 text-sm \
     focus-visible:outline-none focus-visible:ring-2";

// With label above on mobile
const INPUT_GROUP = &str =
    "flex flex-col gap-2 sm:flex-row sm:items-center sm:gap-4";
```

### Card

Cards stack vertically on mobile.

```rust
const CARD_CLASS = &str =
    "rounded-lg border bg-card text-card-foreground \
     p-4 shadow-sm";

// Responsive card grid
const CARD_CONTAINER = &str =
    "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4";
```

### Dialog/Modal

Modals should be full-screen on mobile, centered modal on desktop.

```rust
const DIALOG_OVERLAY = &str =
    "fixed inset-0 z-50 bg-black/80";

const DIALOG_CONTENT = &str =
    "fixed left-[50%] top-[50%] z-50 \
     translate-x-[-50%] translate-y-[-50%] \
     w-full max-w-lg \
     p-6 \
     sm:rounded-lg";

// Mobile full-screen alternative
const DIALOG_MOBILE = &str =
    "fixed inset-y-0 left-0 right-0 z-50 \
     sm:left-[50%] sm:top-[50%] sm:translate-x-[-50%] sm:translate-y-[-50%] \
     w-full sm:max-w-lg \
     bg-background \
     sm:rounded-lg";
```

### Navigation

Navigation patterns for different screen sizes.

```rust
// Mobile bottom nav
const BOTTOM_NAV = &str =
    "fixed bottom-0 left-0 right-0 z-50 \
     flex h-16 items-center justify-around \
     border-t bg-background \
     sm:hidden";

// Desktop horizontal nav
const TOP_NAV_DESKTOP = &str =
    "hidden sm:flex sm:flex-row sm:items-center sm:gap-6";

// Hamburger menu trigger (mobile only)
const MENU_TRIGGER = &str =
    "flex sm:hidden";
```

### Table

Tables are challenging on mobile. Use card view or horizontal scroll.

```rust
// Option 1: Horizontal scroll
const TABLE_CONTAINER = &str =
    "w-full overflow-x-auto";

// Option 2: Card view on mobile
const TABLE_MOBILE_CARD = &str =
    "block sm:table-row";
```

---

## Touch Targets

### Minimum Sizes

Interactive elements must meet these minimum sizes:

- **Buttons**: 44px × 44px minimum
- **Links**: 44px × 44px (use padding to expand hit area)
- **Form controls**: 44px height minimum
- **Checkboxes/Radios**: 44px × 44px hit area

### Implementation

```rust
// Expand small icon hit areas
const ICON_BUTTON = &str =
    "flex h-10 w-10 items-center justify-center \
     rounded-md hover:bg-accent";

// For small icons, add invisible padding
const SMALL_ICON = &str =
    "p-2 -m-2"; // Adds 8px padding on all sides
```

### Touch Spacing

Place interactive elements with adequate spacing:

```rust
const SPACING_TOUCH = &str = "gap-2 sm:gap-4"; // 8px mobile, 16px desktop
const BUTTON_GROUP = &str = "flex flex-col gap-3 sm:flex-row sm:gap-2";
```

---

## Typography

### Responsive Font Sizes

```rust
// Base font size
const TEXT_BASE = &str = "text-base"; // 16px

// Responsive headings
const H1 = &str = "text-3xl sm:text-4xl lg:text-5xl font-bold";
const H2 = &str = "text-2xl sm:text-3xl lg:text-4xl font-semibold";
const H3 = &str = "text-xl sm:text-2xl lg:text-3xl font-semibold";

// Body text
const TEXT_BODY = &str = "text-sm sm:text-base";
const TEXT_SMALL = &str = "text-xs sm:text-sm";
```

### Line Length

Optimal line length for readability:

```rust
const CONTENT_WIDTH = &str =
    "max-w-prose"; // ~65 characters (Tailwind utility)

const CONTENT_MAX_WIDTH = &str =
    "max-w-2xl";   // ~42rem for constrained content
```

### Text Truncation

```rust
const TRUNCATE_SINGLE = &str =
    "truncate";

const TRUNCATE_MULTI = &str =
    "line-clamp-2"; // Show 2 lines, truncate rest
```

---

## Spacing

### Mobile Spacing Scale

Use smaller spacing on mobile, increase on desktop:

```rust
// Padding
const PADDING_MOBILE = "p-4 sm:p-6 lg:p-8";
const PADDING_COMPACT = "p-2 sm:p-3 lg:p-4";

// Margins
const MARGIN_SECTION = "my-8 sm:my-12 lg:my-16";

// Gaps
const GAP_DEFAULT = "gap-2 sm:gap-4 lg:gap-6";
const GAP_COMPACT = "gap-1 sm:gap-2 lg:gap-3";
```

### Content Padding

Ensure content doesn't touch edges on mobile:

```rust
const SECTION_PADDING = &str =
    "px-4 py-6 sm:px-6 sm:py-8 lg:px-8 lg:py-12";

const CONTAINER_PADDING = &str =
    "px-4 sm:px-6 lg:px-8";
```

---

## Navigation

### Mobile Navigation Patterns

#### 1. Bottom Navigation Bar

Best for: 3-5 top-level destinations

```rust
const BOTTOM_NAV = &str =
    "fixed bottom-0 left-0 right-0 z-50 \
     h-16 border-t bg-background \
     flex items-center justify-around \
     pb-safe"; // iOS safe area
```

#### 2. Hamburger Menu

Best for: Many navigation items or nested navigation

```rust
const MOBILE_MENU = &str =
    "fixed inset-0 z-50 bg-background \
     flex flex-col \
     pt-20 px-4";

const MENU_ITEM = &str =
    "flex items-center justify-between \
     py-4 border-b";
```

#### 3. Tab Bar

Best for: Switching between views within a section

```rust
const TAB_BAR = &str =
    "flex overflow-x-auto \
     border-b bg-background \
     -webkit-overflow-scrolling"; // iOS momentum scroll
```

### Safe Area Handling

Respect device notches and safe areas:

```css
/* Add to your CSS */
@supports (padding: max(0px)) {
  .pb-safe {
    padding-bottom: max(1rem, env(safe-area-inset-bottom));
  }

  .pt-safe {
    padding-top: max(1rem, env(safe-area-inset-top));
  }
}
```

---

## Forms

### Form Layout

```rust
// Stack labels above inputs on mobile
const FORM_FIELD = &str =
    "flex flex-col gap-2 sm:grid sm:grid-cols-[auto_1fr] sm:items-center sm:gap-4";

const FORM_SECTION = &str =
    "flex flex-col gap-6";
```

### Input Sizing

```rust
// Full-width inputs on mobile
const INPUT_FULL = &str =
    "w-full h-12 sm:h-10"; // Larger on mobile for touch

// Textarea
const TEXTAREA = &str =
    "w-full min-h-[120px] sm:min-h-[100px] resize-none";
```

### Form Actions

```rust
// Stack buttons on mobile, side-by-side on desktop
const FORM_ACTIONS = &str =
    "flex flex-col gap-3 sm:flex-row sm:justify-end";
```

### Error Messages

```rust
const ERROR_MESSAGE = &str =
    "text-sm text-destructive mt-1 sm:mt-2";
```

---

## Performance

### Image Optimization

```rust
// Responsive images
const IMG_RESPONSIVE = &str =
    "w-full h-auto object-cover";

// Lazy loading attribute
const IMG_LAZY = &str =
    "loading=\"lazy\"";

// Art direction with srcset
const SRCSET_MOBILE = &str = "image-320w.jpg 320w";
const SRCSET_DESKTOP = &str = "image-1024w.jpg 1024w";
```

### Critical CSS

```css
/* Inline critical above-the-fold styles */
/* Load rest asynchronously */
```

### Reduce JavaScript

```rust
// Prefer CSS for animations
const HOVER_TRANSITION = &str =
    "transition-colors duration-200";

// Use CSS instead of JS for hover states
const HOVER_STATE = &str =
    "hover:bg-accent active:bg-accent/80";
```

### Optimize Touch Events

```css
/* Prevent 300ms delay on tap */
* {
  touch-action: manipulation;
}

/* Prevent double-tap zoom on buttons */
button,
a {
  touch-action: manipulation;
}
```

---

## Testing

### Test on Real Devices

- Test on actual phones, not just browser DevTools
- Test on both iOS and Android
- Test different screen sizes (small to large phones)

### Common Testing Sizes

- **Small phone**: 320px × 568px (iPhone 5)
- **Medium phone**: 375px × 667px (iPhone 8)
- **Large phone**: 414px × 896px (iPhone 11 Pro Max)
- **Tablet**: 768px × 1024px (iPad)
- **Desktop**: 1024px × 768px (laptop)

### Check Touch Targets

Use browser DevTools to verify:
1. Minimum 44px × 44px touch targets
2. Adequate spacing between interactive elements
3. No elements too close together

---

## Component Checklist

When creating or updating components, verify:

- [ ] Mobile-first approach (no max-width media queries)
- [ ] Touch targets are at least 44px × 44px
- [ ] Text is readable without zooming
- [ ] Horizontal content is scrollable on mobile
- [ ] Full-width elements on mobile where appropriate
- [ ] Padding prevents content from touching edges
- [ ] Safe areas respected for notched devices
- [ ] Navigation works well on touch
- [ ] Form inputs are easily tappable
- [ ] Images are responsive and optimized
- [ ] Performance is acceptable on 3G connections

---

## Resources

- [Tailwind CSS Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [Apple Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Material Design - Layout](https://m3.material.io/foundations/layout)
- [Web.dev Mobile Fundamentals](https://web.dev/fundamentals/designing-UX/)
- [MDN Responsive Design](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)
