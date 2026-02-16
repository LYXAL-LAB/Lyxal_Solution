# Landscape Orientation Support

A comprehensive guide for implementing landscape orientation support in Leptos-Shadcn-UI components, specifically focused on tablet and foldable device experiences.

## Table of Contents

1. [Overview](#overview)
2. [Why Landscape Matters](#why-landscape-matters)
3. [Orientation Media Queries](#orientation-media-queries)
4. [Common Patterns](#common-patterns)
5. [Component-Specific Guidelines](#component-specific-guidelines)
6. [Tablet Considerations](#tablet-considerations)
7. [Foldable Devices](#foldable-devices)
8. [Testing](#testing)
9. [Best Practices](#best-practices)

---

## Overview

Landscape orientation presents unique challenges and opportunities for UI design:

- **Width advantage**: More horizontal space for side-by-side layouts
- **Height constraint**: Less vertical space for scrolling content
- **Touch ergonomics**: Different hand positions and thumb reach
- **Use cases**: Media consumption, split-screen apps, gaming, productivity

### Target Devices

| Device Type | Portrait | Landscape | Primary Use Case |
|-------------|----------|-----------|------------------|
| Phone | Primary | Secondary | Media, gaming |
| Tablet | Common | Very Common | Productivity, media |
| Foldable | Variable | Common | Multitasking |
| Desktop | N/A | Native | All uses |

---

## Why Landscape Matters

### User Behavior

- **Tablet users often prefer landscape** for:
  - Watching videos and movies
  - Reading documents/books
  - Using keyboard accessories
  - Split-screen multitasking

- **Common scenarios**:
  - Tablet on stand/dock (always landscape)
  - Tablet with keyboard cover (landscape only)
  - Two-handed gaming
  - Side-by-side app usage

### Design Implications

1. **Content density**: Can show more columns, side-by-side content
2. **Navigation**: Horizontal navigation becomes more viable
3. **Media**: Video players take full advantage
4. **Forms**: Can use inline labels instead of stacked
5. **Tables**: Wider tables fit without scrolling

---

## Orientation Media Queries

### Basic Orientation Queries

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

### Combining with Breakpoints

```css
/* Tablet landscape (768px+ in landscape) */
@media (min-width: 768px) and (orientation: landscape) {
  /* Tablet-specific landscape styles */
}

/* Mobile landscape (480px+ in landscape) */
@media (min-width: 480px) and (orientation: landscape) {
  /* Mobile landscape styles */
}

/* Large tablet/desktop landscape */
@media (min-width: 1024px) and (orientation: landscape) {
  /* Large screen landscape styles */
}
```

### Tailwind-like Utility Classes

```rust
// Use orientation utilities in your components
const ORIENTATION_CLASSES = &str =
    "flex flex-col landscape:flex-row portrait:flex-col";

const RESPONSIVE_GRID = &str =
    "grid grid-cols-1 landscape:grid-cols-2 landscape-md:grid-cols-3";

const NAVIGATION = &str =
    "flex-col portrait:flex-col landscape:flex-row";
```

---

## Common Patterns

### Pattern 1: Stack to Row

**Portrait**: Stacked vertically
**Landscape**: Side-by-side horizontally

```rust
const ORIENTATION_STACK_ROW = &str =
    "flex flex-col gap-4 landscape:flex-row landscape:gap-6";

// Usage
view! {
    <div class=ORIENTATION_STACK_ROW>
        <div class="flex-1">{ /* Left content */ }</div>
        <div class="flex-1">{ /* Right content */ }</div>
    </div>
}
```

### Pattern 2: Single to Multi Column

**Portrait**: Single column
**Landscape**: 2-3 columns

```rust
const ORIENTATION_COLS = &str =
    "grid grid-cols-1 gap-4 landscape:grid-cols-2 landscape-md:grid-cols-3";

// Usage
view! {
    <div class=ORIENTATION_COLS>
        <div>{ /* Card 1 */ }</div>
        <div>{ /* Card 2 */ }</div>
        <div>{ /* Card 3 */ }</div>
        <div>{ /* Card 4 */ }</div>
    </div>
}
```

### Pattern 3: Navigation Transformation

**Portrait**: Bottom nav or hamburger
**Landscape**: Horizontal top nav

```rust
const NAV_LANDSCAPE = &str =
    "flex flex-col portrait:flex-col landscape:flex-row \
     portrait:fixed portrait:bottom-0 portrait:left-0 portrait:right-0 \
     landscape:relative landscape:top-0 landscape:bottom-auto";

// Hide bottom nav in landscape, show in portrait
const BOTTOM_NAV = &str =
    "fixed bottom-0 left-0 right-0 landscape:hidden";

// Show horizontal nav in landscape
const TOP_NAV = &str =
    "hidden landscape:flex landscape:flex-row";
```

### Pattern 4: Form Layout

**Portrait**: Stacked labels above inputs
**Landscape**: Inline labels beside inputs

```rust
const FORM_FIELD = &str =
    "flex flex-col gap-2 portrait:flex-col \
     landscape:landscape-form-inline landscape:gap-4";

const FORM_LABEL = &str =
    "text-sm font-medium portrait:text-left landscape:text-right";

const FORM_INPUT = &str =
    "w-full portrait:w-full landscape:flex-1";
```

### Pattern 5: Card Layout

**Portrait**: Vertical cards with stacked content
**Landscape**: Horizontal cards with media side-by-side

```rust
const CARD = &str =
    "rounded-lg border bg-card p-4 \
     portrait:flex portrait:flex-col portrait:gap-4 \
     landscape:landscape-card-horizontal";

const CARD_MEDIA = &str =
    "w-full portrait:w-full portrait:h-48 \
     landscape:landscape-card-media";
```

### Pattern 6: Full Width to Constrained

**Portrait**: Full width content
**Landscape**: Centered, constrained width

```rust
const CONTAINER = &str =
    "w-full portrait:w-full mx-auto \
     landscape:max-w-2xl landscape:px-6";
```

---

## Component-Specific Guidelines

### Button

```rust
// Buttons remain consistent, but layout changes
const BUTTON_GROUP = &str =
    "flex flex-col gap-3 portrait:flex-col \
     landscape:flex-row landscape:justify-end";

// Icon buttons
const ICON_BUTTON = &str =
    "h-11 w-11 landscape:h-10 landscape:w-10";
```

### Input

```rust
// Full width in both, but form layout changes
const INPUT = &str =
    "w-full h-12 portrait:h-12 landscape:h-10";

// Search input - wider in landscape
const SEARCH_INPUT = &str =
    "w-full portrait:w-full landscape:w-96";
```

### Dialog/Modal

```rust
// Full screen in portrait, centered modal in landscape
const DIALOG_CONTENT = &str =
    "fixed inset-0 portrait:inset-0 \
     landscape:landscape-dialog landscape:landscape-dialog-centered";

const DIALOG_FULL_PORTRAIT = &str =
    "w-full h-full portrait:rounded-none landscape:rounded-lg";
```

### Table

```rust
// Tables benefit greatly from landscape
const TABLE_WRAPPER = &str =
    "w-full overflow-x-auto portrait:overflow-x-auto \
     landscape:landscape-table-wrapper";

// Card view in portrait, table in landscape
const RESPONSIVE_TABLE = &str =
    "flex flex-col portrait:flex-col gap-4 \
     landscape:block landscape:landscape-table";
```

### Navigation

```rust
// Bottom nav for portrait, horizontal for landscape
const RESPONSIVE_NAV = &str =
    "fixed bottom-0 left-0 right-0 z-50 \
     h-16 border-t bg-background \
     landscape:hidden";

const LANDSCAPE_NAV = &str =
    "hidden landscape:flex landscape:flex-row \
     landscape:items-center landscape:gap-6";
```

### Card Grid

```rust
// Progressively more columns in landscape
const CARD_GRID = &str =
    "grid grid-cols-1 gap-4 \
     portrait:grid-cols-1 \
     landscape:landscape-card-grid \
     landscape-md:tablet-landscape-2-col";
```

### Alert/Toast

```rust
// Full width at bottom in portrait, side toast in landscape
const ALERT = &str =
    "fixed left-4 right-4 bottom-4 z-50 \
     portrait:left-4 portrait:right-4 \
     landscape:left-auto landscape:right-4 landscape:w-96";
```

---

## Tablet Considerations

### iPad-Specific Considerations

**Screen sizes**:
- iPad: 1024×768 (landscape) / 768×1024 (portrait)
- iPad Air: 1180×820 (landscape) / 820×1180 (portrait)
- iPad Pro 11": 2388×1668 (landscape) / 1668×2388 (portrait)
- iPad Pro 12.9": 2732×2048 (landscape) / 2048×2732 (portrait)

```rust
// Tablet-specific landscape utilities
const TABLET_LANDSCAPE = &str =
    "landscape-md:tablet-landscape-2-col";

const TABLET_CONTAINER = &str =
    "w-full mx-auto px-4 \
     landscape-md:tablet-landscape-container";
```

### Tablet with Keyboard

When tablets are used with keyboard covers:
- Treat more like desktop
- Larger touch targets still needed
- Consider keyboard shortcuts

```rust
// Keyboard mode detection (optional)
const WITH_KEYBOARD = &str =
    "hover:bg-accent focus:ring-2"; // Add hover states
```

### Split-Screen Multitasking

Tablets often run apps side-by-side:
- Design for narrow widths (1/3 split = ~340px on iPad)
- Test with 50/50 and 33/67 splits
- Maintain usability at reduced width

```rust
// Ensure content works in narrow splits
const SPLIT_SCREEN_SAFE = &str =
    "min-w-[300px] landscape:min-w-[280px]";
```

---

## Foldable Devices

### Dual-Screen Layouts

```rust
// Use both screens when unfolded in landscape
const FOLDABLE_LANDSCAPE = &str =
    "foldable-landscape-two-panels";

const FOLDABLE_PANEL = &str =
    "flex-1 p-4 overflow-y-auto";
```

### Hinge Handling

```rust
// Content spanning hinge may need special handling
const AVOID_HINGE = &str =
    "max-w-[45vw]"; // Keep content away from center

const SPAN_HINGE = &str =
    "col-span-2"; // Allow content to span both panels
```

---

## Testing

### Device Testing Matrix

| Device | Portrait | Landscape | Notes |
|--------|----------|-----------|-------|
| iPhone SE | 375×667 | 667×375 | Test rotation |
| iPhone 14 Pro | 393×852 | 852×393 | Test notch handling |
| iPad | 768×1024 | 1024×768 | Primary target |
| iPad Pro 11" | 820×1180 | 1180×820 | Test larger screens |
| Surface Pro | 912×1368 | 1368×912 | Touch + keyboard |

### Manual Testing Checklist

- [ ] Rotate device from portrait to landscape
- [ ] Rotate device from landscape to portrait
- [ ] Test in landscape at various widths
- [ ] Test touch targets in landscape
- [ ] Test keyboard interactions in landscape
- [ ] Test with external keyboard (tablet)
- [ ] Test split-screen mode (if available)
- [ ] Test safe areas with notches
- [ ] Test media playback in landscape
- [ ] Test form input in landscape

### Automated Testing

```typescript
// E2E test for landscape orientation
test('Tablet landscape orientation', async ({ page }) => {
  // Set tablet landscape viewport
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.goto('/');

  // Verify no horizontal scroll
  const hasHorizontalScroll = await page.evaluate(() => {
    return document.body.scrollWidth > window.innerWidth;
  });
  expect(hasHorizontalScroll).toBeFalsy();

  // Verify layout adapted
  const main = page.locator('main').first();
  await expect(main).toBeVisible();
});

// Orientation change test
test('Portrait to landscape rotation', async ({ page }) => {
  await page.setViewportSize({ width: 768, height: 1024 });
  await page.goto('/');

  const portraitScreenshot = await page.screenshot();

  // Rotate to landscape
  await page.setViewportSize({ width: 1024, height: 768 });
  await page.waitForTimeout(200);

  const landscapeScreenshot = await page.screenshot();

  // Layout should adapt
  expect(portraitScreenshot).not.toEqual(landscapeScreenshot);
});
```

---

## Best Practices

### DO

1. **Test real devices**
   - Emulators don't always match real behavior
   - Test on actual iPads and tablets
   - Test rotation transitions

2. **Consider use cases**
   - Media consumption → full-width video
   - Productivity → side-by-side content
   - Gaming → landscape-first controls

3. **Maintain accessibility**
   - Touch targets still 44×44px minimum
   - Text remains readable
   - Keyboard navigation works

4. **Optimize for content**
   - Let content dictate layout
   - Don't force landscape for simple forms
   - Consider reading patterns

5. **Handle transitions smoothly**
   - Avoid jarring layout shifts
   - Use CSS transitions sparingly
   - Test animation performance

### DON'T

1. **Don't force landscape**
   - Never lock orientation without good reason
   - Always support portrait
   - Respect user preference

2. **Don't assume desktop behavior**
   - Tablets in landscape ≠ desktop
   - Touch still primary input
   - Keyboard may not be present

3. **Don't ignore safe areas**
   - Notches may be on sides in landscape
   - Use safe-area-inset-* properties
   - Test on notched devices

4. **Don't forget narrow widths**
   - Split-screen reduces width
   - Foldable phones vary
   - Test at 300px width in landscape

5. **Don't overlook performance**
   - More content visible = more rendering
   - Lazy load images
   - Virtualize long lists

---

## Quick Reference

### Common Orientation Classes

```rust
// Layout direction
"flex flex-col landscape:flex-row"
"grid grid-cols-1 landscape:grid-cols-2"

// Display control
"landscape:hidden"          // Hide in landscape
"landscape:block"           // Show as block in landscape
"landscape:flex"            // Show as flex in landscape

// Tablet landscape
"landscape-md:grid-cols-3"
"landscape-md:gap-6"
"landscape-md:tablet-landscape-2-col"

// Safe areas in landscape
"landscape:px-safe"         // Horizontal safe areas
"landscape:pl-safe"         // Left safe area
"landscape:pr-safe"         // Right safe area
```

### Breakpoint Reference

| Class | Width | Orientation | Use Case |
|-------|-------|-------------|----------|
| `landscape:` | Any | landscape | All landscape devices |
| `portrait:` | Any | portrait | All portrait devices |
| `landscape-sm:` | 480px+ | landscape | Small landscape (phones) |
| `landscape-md:` | 768px+ | landscape | Tablet landscape |
| `landscape-lg:` | 1024px+ | landscape | Large tablet/desktop |

### Component Template

```rust
#[component]
pub fn OrientationAwareComponent() -> impl IntoView {
    view! {
        <div class="
            // Base styles
            w-full rounded-lg border bg-card p-4

            // Portrait: stacked
            portrait:flex portrait:flex-col portrait:gap-4

            // Landscape: side-by-side
            landscape:flex landscape:flex-row landscape:gap-6

            // Tablet landscape: enhanced
            landscape-md:items-center landscape-md:justify-between
        ">
            <div class="flex-1">
                // Content
            </div>
            <div class="flex-1">
                // Content
            </div>
        </div>
    }
}
```

---

## Resources

- [MDN: @media (orientation)](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/orientation)
- [Web.dev: Responsive Design](https://web.dev/responsive-web-design-basics/)
- [Apple: Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [Android: Screen Compatibility](https://developer.android.com/guide/topics/large-screens/support-different-screen-sizes)
