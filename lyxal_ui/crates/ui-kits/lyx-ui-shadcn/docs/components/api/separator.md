# Separator Component API

A visual separator/divider component for organizing content.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-separator = "0.7"
```

```rust
use shadcn_ui_leptos_separator::Separator;
```

---

## Component API

### Separator

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `orientation` | `MaybeProp<Orientation>` | `Horizontal` | Line direction |
| `decorative` | `Signal<bool>` | `true` | Decorative (no label) |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### Orientation

```rust
pub enum Orientation {
    Horizontal,
    Vertical,
}
```

---

## Usage Examples

### Horizontal Separator

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_separator::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <div>
            <p>"Content above"</p>
            <Separator />
            <p>"Content below"</p>
        </div>
    }
}
```

### Vertical Separator

```rust
view! {
    <div class="flex items-center gap-4">
        <span>"Item 1"</span>
        <Separator orientation=Orientation::Vertical class="h-8" />
        <span>"Item 2"</span>
    </div>
}
```

---

## CSS Classes

```css
.separator {
    shrink-0 bg-border
}

.separator-horizontal {
    h-px w-full
}

.separator-vertical {
    h-full w-px
}
```

---

## Accessibility

### ARIA Attributes

- `role="separator"` - Separator role
- `aria-orientation` - Orientation (when decorative=false)

---

## TypeScript API

```typescript
interface SeparatorProps {
  orientation?: 'horizontal' | 'vertical';
  decorative?: boolean;
  className?: string;
}

export const Separator: React.FC<SeparatorProps>;
```

---

*Source: [packages/leptos/separator/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/separator/src/default.rs)*
