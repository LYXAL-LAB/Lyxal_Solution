# Mobile Utility Classes

Quick reference for responsive utility class patterns in Leptos-Shadcn-UI.

## Layout Utilities

### Width

```rust
// Full width mobile, constrained on desktop
"w-full"                    // Full width always
"w-full sm:w-auto"          // Full width mobile, auto desktop
"w-full md:w-2/3 lg:w-1/2"  // Progressive constraint
"w-full max-w-md"           // Full width, max constraint
```

### Container

```rust
// Responsive container
"w-full mx-auto px-4 sm:px-6 lg:px-8"           // Standard
"w-full max-w-7xl mx-auto px-4 sm:px-6"         // Constrained
"w-full max-w-screen-xl mx-auto px-4"           // Large max
```

### Display

```rust
// Show/hide by breakpoint
"block sm:hidden"        // Mobile only
"hidden sm:block"        // Desktop only (sm+)
"hidden md:block"        // Tablet+ only
"block lg:hidden"        // Below lg only
```

### Flex Direction

```rust
// Stack on mobile, row on desktop
"flex flex-col sm:flex-row"                    // Basic
"flex flex-col md:flex-row lg:flex-row"        // Multiple breakpoints
"flex flex-col gap-4 sm:flex-row sm:gap-6"     // With gap
```

### Grid

```rust
// Responsive grids
"grid grid-cols-1"                             // Single column
"grid grid-cols-1 sm:grid-cols-2"              // 1 -> 2 columns
"grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"  // Progressive
"grid grid-cols-[minmax(280px,1fr)]"           // Auto-fit with min
```

---

## Spacing Utilities

### Padding

```rust
// Responsive padding
"p-4"                     // All sides, constant
"p-4 sm:p-6 lg:p-8"       // Progressive increase
"px-4 py-6 sm:px-6 sm:py-8"  // Different x/y
"px-4 py-6 sm:py-8 lg:py-12"  // Selective
```

### Margin

```rust
// Responsive margins
"mx-4 sm:mx-6"            // Horizontal
"my-4 sm:my-6 lg:my-8"    // Vertical
"m-4 sm:m-6"              // All sides
```

### Gap

```rust
// Responsive gap for flex/grid
"gap-2"                   // Constant
"gap-2 sm:gap-4 lg:gap-6" // Progressive
"gap-x-4 gap-y-2 sm:gap-x-6 sm:gap-y-3"  // X and Y separate
```

---

## Typography Utilities

### Font Size

```rust
// Responsive text
"text-base"               // Constant (16px)
"text-sm sm:text-base"    // Small -> base
"text-lg sm:text-xl lg:text-2xl"  // Progressive headings
"text-xs sm:text-sm md:text-base"  // Body text
```

### Text Alignment

```rust
// Center on mobile, left on desktop
"text-center sm:text-left"
"text-center md:text-left"
```

### Text Wrapping

```rust
// Truncation
"truncate"                // Single line, ellipsis
"line-clamp-2"            // 2 lines max, ellipsis
"line-clamp-3 sm:line-clamp-none"  // Conditional clamp
```

---

## Sizing Utilities

### Height

```rust
// Responsive height
"h-10"                    // Constant
"h-12 sm:h-10"            // Larger on mobile (touch)
"h-8 sm:h-10 md:h-12"     // Progressive
"min-h-screen sm:min-h-0" // Conditional min-height
```

### Min/Max Width

```rust
// Responsive constraints
"min-w-0 sm:min-w-[200px]"     // Allow shrink mobile
"max-w-full sm:max-w-md"        // Constrain desktop
"w-full max-w-none sm:max-w-2xl"  // Combo
```

---

## Position Utilities

### Sticky

```rust
// Responsive sticky
"sticky top-0"                        // Always
"relative sm:sticky sm:top-0"        // Desktop only sticky
"sticky top-4 sm:top-0"              // Different offset
```

### Fixed Positioning

```rust
// Mobile overlay, desktop modal
"fixed inset-0 z-50"                 // Full screen
"fixed inset-x-0 bottom-0 sm:inset-0 sm:left-1/2 sm:top-1/2"  // Conditional
```

---

## Border & Radius

### Border Width

```rust
// Responsive borders
"border"                   // All sides, constant
"border-x sm:border"       // Sides only mobile
"border-b-2 sm:border-b"   // Thicker bottom mobile
```

### Border Radius

```rust
// Responsive radius
"rounded-md"               // Constant
"rounded-lg sm:rounded-md" // Less round on desktop
"rounded-none sm:rounded"  // Square mobile, round desktop
```

---

## Color & Background

### Background Color

```rust
// Conditional backgrounds
"bg-muted/50 sm:bg-muted"  // Lighter mobile
"hover:bg-accent"          // Desktop hover
"hover:bg-accent active:bg-accent/80"  // Include touch active
```

### Text Color

```rust
// Responsive text color
"text-muted-foreground"    // Constant
"text-foreground sm:text-muted-foreground"  // Emphasize mobile
```

---

## Flexbox Utilities

### Justify Content

```rust
// Responsive justify
"justify-center sm:justify-start"     // Center -> left
"justify-between"                     // Constant
"justify-center sm:justify-between lg:justify-around"  // Progressive
```

### Align Items

```rust
// Responsive align
"items-start sm:items-center"         // Top -> center
"items-center"                        // Constant
```

### Flex Wrap

```rust
// Responsive wrapping
"flex-wrap sm:flex-nowrap"            // Wrap mobile, single desktop
"flex-nowrap sm:flex-wrap"            // Opposite
```

---

## Grid Utilities

### Template Columns

```rust
// Responsive columns
"grid-cols-1"                         // Single
"grid-cols-1 sm:grid-cols-2"          // 1 -> 2
"grid-cols-2 sm:grid-cols-3 lg:grid-cols-4"  // Progressive
"grid-cols-[minmax(200px,1fr)]"       // Auto with min
```

### Template Rows

```rust
// Responsive rows
"grid-rows-1 sm:grid-rows-2"          // Conditional
"auto-rows-fr"                        // Fill available space
```

---

## Overflow Utilities

```rust
// Responsive overflow
"overflow-hidden"                     // Always hide
"overflow-x-auto"                     // Horizontal scroll
"overflow-hidden sm:overflow-visible"  // Hide mobile, show desktop
"-mx-4 overflow-x-auto px-4"          // Full-width scroll with padding
```

---

## Opacity Utilities

```rust
// Responsive opacity
"opacity-50"                          // Constant
"opacity-100 sm:opacity-75"           // Fade on desktop
"hover:opacity-80 active:opacity-60"  // Include touch
```

---

## Transition Utilities

```rust
// Touch-friendly transitions
"transition-colors"                   // Smooth color
"transition-colors duration-200"      // Faster mobile
"transition-transform active:scale-95" // Touch feedback
```

---

## Common Patterns

### Container with Padding

```rust
const CONTAINER = &str =
    "w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8";
```

### Section Spacing

```rust
const SECTION = &str =
    "py-12 sm:py-16 lg:py-20 px-4 sm:px-6";
```

### Responsive Button

```rust
const BUTTON_RESPONSIVE = &str =
    "w-full sm:w-auto h-11 sm:h-10 px-8";
```

### Card Grid

```rust
const CARD_GRID = &str =
    "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4";
```

### Stack to Row

```rust
const STACK_ROW = &str =
    "flex flex-col gap-4 sm:flex-row sm:gap-6";
```

### Hide/Show

```rust
const MOBILE_ONLY = &str =
    "block sm:hidden";

const DESKTOP_ONLY = &str =
    "hidden sm:block";
```

### Text Clamp

```rust
const TEXT_CLAMP_MOBILE = &str =
    "line-clamp-3 sm:line-clamp-none";
```

### Touch Target Expansion

```rust
const TOUCH_TARGET = &str =
    "p-2 -m-2";  // Add invisible padding
```

---

## Breakpoint Reference

| Prefix | Min Width | Devices |
|--------|-----------|---------|
| (none) | 0px | All devices (mobile first) |
| sm: | 640px | Small tablets, large phones |
| md: | 768px | Tablets portrait |
| lg: | 1024px | Tablets landscape, small laptops |
| xl: | 1280px | Desktops |
| 2xl: | 1536px | Large desktops |

---

## Mobile-First Best Practices

### 1. Start with base styles

```rust
// ✅ GOOD: Mobile first
"flex flex-col gap-4 sm:flex-row"

// ❌ BAD: Desktop first
"flex flex-row gap-4 max-sm:flex-col"
```

### 2. Use min-width queries

```rust
// ✅ GOOD: Add enhancements for larger screens
"w-full sm:w-auto"

// ❌ BAD: Override for smaller screens
"w-auto max-sm:w-full"
```

### 3. Combine related utilities

```rust
// ✅ GOOD: Group related responsive classes
"w-full px-4 sm:px-6 lg:px-8"

// ❌ BAD: Scatter breakpoints
"w-full sm:w-full lg:w-full px-4 sm:px-6 lg:px-8"
```

### 4. Use meaningful breakpoints

```rust
// ✅ GOOD: Break when layout needs to change
"flex-col sm:flex-row"  // Changes at 640px

// ❌ BAD: Arbitrary breakpoints
"flex-col md:flex-row xl:flex-row"  // Redundant
```

### 5. Test at actual breakpoints

```rust
// Verify these sizes:
// - 375px (iPhone SE)
// - 640px (small tablet)
// - 768px (tablet)
// - 1024px (laptop)
// - 1280px (desktop)
```

---

## Performance Tips

### Minimize responsive classes

```rust
// ✅ GOOD: Only use what you need
"w-full sm:w-auto"

// ❌ BAD: Redundant classes
"w-full w-full sm:w-auto"
```

### Use logical order

```rust
// ✅ GOOD: Logical progression
"p-4 sm:p-6 lg:p-8"

// ❌ BAD: Out of order
"lg:p-8 p-4 sm:p-6"
```

### Prefer responsive variants over conditionals

```rust
// ✅ GOOD: Use Tailwind responsive classes
"hidden sm:block"

// ❌ BAD: Use CSS conditionals
"@[<640px]:hidden"
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                    MOBILE UTILITIES QUICK REF               │
├─────────────────────────────────────────────────────────────┤
│ Layout:   flex-col sm:flex-row                              │
│           grid-cols-1 sm:grid-cols-2                        │
│           w-full sm:w-auto                                  │
│                                                             │
│ Spacing:  p-4 sm:p-6 lg:p-8                                 │
│           gap-2 sm:gap-4                                    │
│           my-4 sm:my-6                                      │
│                                                             │
│ Display:  block sm:hidden (mobile only)                     │
│           hidden sm:block (desktop only)                    │
│                                                             │
│ Text:     text-sm sm:text-base                              │
│           line-clamp-3 sm:line-clamp-none                   │
│           text-center sm:text-left                          │
│                                                             │
│ Height:   h-12 sm:h-10 (larger touch target on mobile)      │
│                                                             │
│ Touch:    min-h-[44px] min-w-[44px] (minimum touch target)  │
└─────────────────────────────────────────────────────────────┘
```
