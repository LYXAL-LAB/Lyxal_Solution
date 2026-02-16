# Popover Component API

A floating content container positioned relative to a trigger element.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-popover = "0.7"
```

```rust
use shadcn_ui_leptos_popover::Popover;
```

---

## Import

```rust
use shadcn_ui_leptos_popover::{
    Popover,
    PopoverTrigger,
    PopoverContent
};
```

---

## Component API

### Popover

Root component managing popover state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |

### PopoverTrigger

Element that triggers the popover.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `as_child` | `Option<Callback<...>>` | `None` | Render as custom element |

### PopoverContent

The floating popover container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `align` | `MaybeProp<Alignment>` | `Center` | Horizontal alignment |
| `side` | `MaybeProp<Side>` | `Bottom` | Placement side |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Popover

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_popover::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <Popover
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <PopoverTrigger>
                <button>"Open popover"</button>
            </PopoverTrigger>
            <PopoverContent>
                <p>"Popover content"</p>
            </PopoverContent>
        </Popover>
    }
}
```

---

## CSS Classes

```css
.popover-content {
    z-50 w-72 rounded-md border bg-popover
    p-4 text-popover-foreground shadow-md
    outline-none data-[state=open]:animate-in
    data-[state=closed]:animate-out
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Escape** | Close popover |
| **Tab** | Focus within popover |

---

## TypeScript API

```typescript
interface PopoverProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
}

export const Popover: React.FC<PopoverProps>;
export const PopoverTrigger: React.FC<ComponentProps>;
export const PopoverContent: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/popover/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/popover/src/default.rs)*
