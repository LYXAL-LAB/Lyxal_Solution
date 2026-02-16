# Toggle Component API

A two-state button that can be on or off.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-toggle = "0.7"
```

```rust
use shadcn_ui_leptos_toggle::Toggle;
```

---

## Component API

### Toggle

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `pressed` | `Signal<bool>` | **Required** | Toggle state |
| `on_change` | `Option<Callback<bool>>` | `None` | Change handler |
| `disabled` | `Signal<bool>` | `false` | Disable toggle |
| `variant` | `MaybeProp<ToggleVariant>` | `Default` | Visual style |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### ToggleVariant

```rust
pub enum ToggleVariant {
    Default,
    Outline,
}
```

---

## Usage Examples

### Basic Toggle

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_toggle::Toggle;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (pressed, set_pressed) = signal(false);

    view! {
        <Toggle
            pressed=pressed.into()
            on_change=Some(Callback::new(move |v| set_pressed.set(v)))
        >
            "Toggle me"
        </Toggle>
    }
}
```

---

## CSS Classes

```css
.toggle {
    inline-flex items-center justify-center rounded-md
    text-sm font-medium transition-colors
    hover:bg-muted hover:text-muted-foreground
    focus-visible:outline-none focus-visible:ring-2
    focus-visible:ring-ring disabled:pointer-events-none
    disabled:opacity-50
}

.toggle[data-state=on] {
    bg-accent text-accent-foreground
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Enter** | Toggle state |
| **Space** | Toggle state |

---

## TypeScript API

```typescript
interface ToggleProps {
  pressed: boolean;
  onChange?: (pressed: boolean) => void;
  disabled?: boolean;
  variant?: 'default' | 'outline';
  className?: string;
}

export const Toggle: React.FC<ToggleProps>;
```

---

*Source: [packages/leptos/toggle/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/toggle/src/default.rs)*
