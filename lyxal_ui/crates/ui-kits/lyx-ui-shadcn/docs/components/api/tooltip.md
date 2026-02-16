# Tooltip Component API

A floating label that displays information when hovering over an element.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-tooltip = "0.7"
```

```rust
use shadcn_ui_leptos_tooltip::Tooltip;
```

---

## Import

```rust
use shadcn_ui_leptos_tooltip::{
    Tooltip,
    TooltipTrigger,
    TooltipContent
};
```

---

## Component API

### Tooltip

Root component managing tooltip state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `delay_duration` | `MaybeProp<u64>` | `400` | Show delay (ms) |

### TooltipTrigger

Element that triggers the tooltip on hover.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `as_child` | `Option<Callback<...>>` | `None` | Render as custom element |

### TooltipContent

The floating tooltip container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `side` | `MaybeProp<Side>` | `Top` | Placement side |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Tooltip

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_tooltip::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <Tooltip open=open.into()>
            <TooltipTrigger>
                <button>"Hover me"</button>
            </TooltipTrigger>
            <TooltipContent>
                <p>"Tooltip content"</p>
            </TooltipContent>
        </Tooltip>
    }
}
```

---

## CSS Classes

```css
.tooltip-content {
    z-50 overflow-hidden rounded-md bg-primary
    px-3 py-1.5 text-xs text-primary-foreground
    animate-in fade-in-0 zoom-in-95
}
```

---

## Accessibility

### ARIA Attributes

- `role="tooltip"` - Tooltip role
- `aria-describedby` - References tooltip content

---

## TypeScript API

```typescript
interface TooltipProps {
  open: boolean;
  delayDuration?: number;
  children?: React.ReactNode;
}

export const Tooltip: React.FC<TooltipProps>;
export const TooltipTrigger: React.FC<ComponentProps>;
export const TooltipContent: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/tooltip/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/tooltip/src/default.rs)*
