# Badge Component API

A small status indicator component for displaying labels and counts.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-badge = "0.7"
```

```rust
use shadcn_ui_leptos_badge::Badge;
```

---

## Import

```rust
use shadcn_ui_leptos_badge::{
    Badge,
    BadgeVariant
};
```

---

## Component API

### Badge

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `MaybeProp<BadgeVariant>` | `Default` | Badge style |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Badge content |

### BadgeVariant

```rust
pub enum BadgeVariant {
    Default,     // Neutral gray
    Primary,     // Brand primary color
    Secondary,   // Secondary color
    Destructive, // Red for errors
    Outline,     // Bordered outline
    Success,     // Green for success
}
```

---

## Usage Examples

### Basic Badge

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_badge::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Badge variant=BadgeVariant::Default>
            "New"
        </Badge>
    }
}
```

### Badge Variants

```rust
view! {
    <div class="flex gap-2">
        <Badge variant=BadgeVariant::Default>"Default"</Badge>
        <Badge variant=BadgeVariant::Primary>"Primary"</Badge>
        <Badge variant=BadgeVariant::Secondary>"Secondary"</Badge>
        <Badge variant=BadgeVariant::Destructive>"Error"</Badge>
        <Badge variant=BadgeVariant::Outline>"Outline"</Badge>
        <Badge variant=BadgeVariant::Success>"Success"</Badge>
    </div>
}
```

### Count Badge

```rust
view! {
    <div class="relative">
        <button>"Notifications"</button>
        <Badge class="absolute -top-2 -right-2 px-2 py-0.5">
            "3"
        </Badge>
    </div>
}
```

---

## CSS Classes

```css
.badge {
    inline-flex items-center rounded-full border
    px-2.5 py-0.5 text-xs font-semibold
    transition-colors focus:outline-none focus:ring-2
    focus:ring-ring focus:ring-offset-2
}

.badge-default {
    border-transparent bg-primary text-primary-foreground
    hover:bg-primary/80
}

.badge-secondary {
    border-transparent bg-secondary
    text-secondary-foreground hover:bg-secondary/80
}

.badge-destructive {
    border-transparent bg-destructive
    text-destructive-foreground hover:bg-destructive/80
}

.badge-outline {
    text-foreground
}

.badge-success {
    border-transparent bg-green-500 text-white
    hover:bg-green-600
}
```

---

## Accessibility

### ARIA Attributes

- `aria-label` - For status badges
- Semantic color usage for meaning

---

## TypeScript API

```typescript
interface BadgeProps {
  variant?: 'default' | 'primary' | 'secondary' | 'destructive' | 'outline' | 'success';
  className?: string;
  children?: React.ReactNode;
}

export const Badge: React.FC<BadgeProps>;
```

---

*Source: [packages/leptos/badge/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/badge/src/default.rs)*
