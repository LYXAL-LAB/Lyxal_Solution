# Theme Differences: Default vs New York

This document provides a comprehensive comparison between the **Default** and **New York** theme implementations across all components in the leptos-shadcn-ui library.

## Overview

The leptos-shadcn-ui library supports multiple design system themes. Currently, two primary themes are implemented:

- **Default Theme**: The original shadcn/ui design system
- **New York Theme**: A simplified variant following the New York design system pattern

### Architecture

Each component in the library follows a consistent structure:

```
packages/leptos/{component}/src/
├── lib.rs              # Public API re-exports
├── default.rs          # Default theme implementation
├── new_york.rs         # New York theme implementation
├── signal_managed.rs   # Signal/reactive implementation
└── tests/              # Component tests
```

## Component-by-Component Differences

### Components with Identical Implementations

The following components have **identical** implementations between default and New York themes. The `new_york.rs` file in these components is effectively a duplicate or re-export of the `default.rs` implementation:

| Component | Status | Notes |
|-----------|--------|-------|
| **Accordion** | Identical | Same classes and behavior |
| **Alert** | Identical | Same variant handling |
| **Alert Dialog** | Identical | Same dialog structure |
| **Aspect Ratio** | Identical | Same aspect ratio utilities |
| **Avatar** | Identical | Same avatar styling |
| **Badge** | Identical | Same badge variants |
| **Breadcrumb** | Identical | Same navigation structure |
| **Calendar** | Identical | Same calendar layout |
| **Carousel** | Identical | Same carousel behavior |
| **Checkbox** | Identical | Same checkbox styling |
| **Collapsible** | Identical | Same collapse animation |
| **Combobox** | Identical | Same combobox behavior |
| **Command** | Identical | Same command palette |
| **Context Menu** | Identical | Same menu structure |
| **Data Table** | Identical | Same table layout |
| **Date Picker** | Identical | Same date selection |
| **Dialog** | Identical | Same modal structure (see note below) |
| **Drawer** | Identical | Same drawer behavior |
| **Dropdown Menu** | Identical | Same dropdown structure |
| **Form** | Identical | Same form handling |
| **Hover Card** | Identical | Same hover behavior |
| **Label** | Identical | Same label styling |
| **Menubar** | Identical | Same menu bar |
| **Navigation Menu** | Identical | Same navigation |
| **Pagination** | Identical | Same pagination controls |
| **Popover** | Identical | Same popover behavior |
| **Progress** | Identical | Same progress indicators |
| **Radio Group** | Identical | Same radio selection |
| **Resizable** | Identical | Same resize handles |
| **Scroll Area** | Identical | Same scroll styling |
| **Select** | Identical | Same select dropdown |
| **Separator** | Identical | Same separator visual |
| **Sheet** | Identical | Same sheet behavior |
| **Skeleton** | Identical | Same loading skeleton |
| **Slider** | Identical | Same slider controls |
| **Switch** | Identical | Same toggle behavior |
| **Table** | Identical | Same table structure |
| **Tabs** | Identical | Same tab navigation |
| **Textarea** | Identical | Same text area |
| **Toast** | Identical | Same toast notifications |
| **Toggle** | Identical | Same toggle button |
| **Toggle Group** | Identical | Same toggle group |
| **Tooltip** | Identical | Same tooltip display |

> **Note**: While Dialog shows minor implementation differences (escape key handling in default), the visual output is identical.

---

## Components with Meaningful Differences

### 1. Button

**Location**: `packages/leptos/button/src/default.rs` vs `new_york.rs`

#### Default Theme

```rust
pub const BUTTON_CLASS: &str = "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50";
```

**Key features**:
- Includes `loading` prop with spinner animation
- Includes keyboard event handling (Enter/Space keys)
- Includes accessibility attributes (`aria-label`, `aria-describedby`, `aria-busy`)
- More comprehensive event handling

#### New York Theme

```rust
const BUTTON_CLASS: &str = "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50";
```

**Key differences**:
- No `loading` state support
- No keyboard event handling
- No accessibility attributes (beyond basic button attributes)
- Simpler, more minimal implementation

**Summary**: Default theme provides more comprehensive features including loading states and enhanced accessibility. New York theme is more minimal.

---

### 2. Card

**Location**: `packages/leptos/card/src/default.rs` vs `new_york.rs`

#### Default Theme

```rust
const CARD_CLASS: &str = "rounded-lg border bg-card text-card-foreground shadow-sm";
```

**Features**:
- Basic card structure
- Uses `<div>` element
- No variant support
- No interactive features

#### New York Theme

```rust
pub const CARD_CLASS: &str = "rounded-lg border bg-card text-card-foreground shadow-sm";
```

**Additional features**:
- **CardVariant enum**: Default, Destructive, Warning, Success
- **Variant-based styling**: Different border and background colors per variant
- **Interactive prop**: Adds cursor-pointer and hover effects
- **InteractiveCard component**: Full interactive card with click handling
- **Enhanced accessibility**: Uses `<article>` with `role` and `tabindex`
- **Keyboard navigation**: Enter/Space key support
- **Semantic HTML**: `<h2>` instead of `<h3>` for CardTitle

**Summary**: New York theme provides significantly more features including variants, interactivity, and enhanced accessibility.

---

### 3. Input

**Location**: `packages/leptos/input/src/default.rs` vs `new_york.rs`

#### Default Theme

```rust
pub const INPUT_CLASS: &str = "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50";
```

**Additional features**:
- **Validation support**: Built-in `InputValidator` integration
- **Error states**: `INPUT_ERROR_CLASS` for destructive styling
- **Validation feedback**: Automatic error message display
- **Accessibility attributes**: `aria-invalid`, `aria-describedby`
- **Wrapped in div**: Includes space for error messages
- **Real-time validation**: Validates on input change

#### New York Theme

```rust
const INPUT_CLASS: &str = "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50";
```

**Features**:
- Simple, minimal implementation
- No validation support
- No error handling
- Bare input element

**Summary**: Default theme provides comprehensive form validation features. New York theme is a minimal implementation.

---

## Utilities Module

**Location**: `packages/leptos/utils/src/default.rs` vs `new_york.rs`

### Default Theme (`default.rs`)

Provides utility functions for Tailwind CSS class management:

```rust
pub fn cn(classes: &[&str]) -> String {
    tw_merge!(classes.join(" "))
}

pub fn cn_flexible<T: AsRef<str>>(classes: &[T]) -> String {
    let class_strings: Vec<&str> = classes.iter().map(|c| c.as_ref()).collect();
    tw_merge!(class_strings.join(" "))
}
```

### New York Theme (`new_york.rs`)

```rust
pub use super::default::*;
```

**Summary**: The New York theme utilities simply re-export all functions from the default theme. There are no differences in utility functionality.

---

## Summary of Differences

### Key Takeaways

1. **Most components are identical**: 90%+ of components have identical implementations between themes
2. **New York is NOT always simpler**: The Card component actually has MORE features in New York
3. **Default has more form features**: Input component in Default theme includes validation
4. **Default has more interactive features**: Button component includes loading states
5. **Utilities are shared**: New York re-exports Default utilities

### When to Use Each Theme

#### Use Default Theme when:
- You need form validation features
- You need loading states on buttons
- You want more comprehensive accessibility features
- You prefer the original shadcn/ui design

#### Use New York Theme when:
- You want variant support on cards (Destructive, Warning, Success)
- You need interactive card components with click handling
- You prefer minimal form inputs (can add validation separately)
- You want the New York design aesthetic

### Visual Differences

Currently, there are **minimal visual differences** between the two themes:

- Both use the same border radius (`rounded-md`, `rounded-lg`)
- Both use the same color system from CSS variables
- Both use the same spacing and sizing
- Both use the same animation classes

The primary differences are in **feature completeness**, not visual styling.

---

## Future Development

As the library evolves, theme differences may become more pronounced. Potential areas for differentiation:

1. **Border radius**: New York may adopt more rounded corners
2. **Color palettes**: Different default color schemes
3. **Shadows**: Different shadow depths
4. **Animations**: Different animation timings and curves
5. **Component variants**: More variation in component styles

To see the latest theme differences, always refer to the source code in:
- `packages/leptos/{component}/src/default.rs`
- `packages/leptos/{component}/src/new_york.rs`

---

## References

- **Component library structure**: `/packages/leptos/`
- **Utilities**: `/packages/leptos/utils/src/`
- **Theme system**: `/packages/tailwind-rs-core/src/themes.rs`
- **CSS variables**: `/examples/leptos/index.html`

For more information on theming, see:
- [Getting Started Guide](../getting-started/README.md)
- [Component Distribution Guide](../components/DISTRIBUTION_GUIDE.md)
- [Design Documentation](./README.md)
