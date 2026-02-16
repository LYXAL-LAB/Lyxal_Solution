# Hover Card Component API

A card that appears when hovering over a trigger element.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-hover-card = "0.7"
```

```rust
use shadcn_ui_leptos_hover_card::HoverCard;
```

---

## Import

```rust
use shadcn_ui_leptos_hover_card::{
    HoverCard,
    HoverCardTrigger,
    HoverCardContent
};
```

---

## Component API

### HoverCard

Root component managing hover state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |

### HoverCardContent

The floating card content.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Hover Card

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_hover_card::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <HoverCard
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <HoverCardTrigger>
                <a href="#">"@username"</a>
            </HoverCardTrigger>
            <HoverCardContent>
                <div class="space-y-2">
                    <h4 class="text-sm font-semibold">"User Name"</h4>
                    <p class="text-sm">"Bio and additional info"</p>
                </div>
            </HoverCardContent>
        </HoverCard>
    }
}
```

---

## CSS Classes

```css
.hover-card-content {
    z-50 w-64 rounded-md border bg-popover p-4
    text-popover-foreground shadow-md outline-none
    data-[state=open]:animate-in data-[state=closed]:animate-out
}
```

---

## Accessibility

- `role="tooltip"` - Tooltip role
- Hover delay to prevent accidental triggers

---

## TypeScript API

```typescript
interface HoverCardProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
}

export const HoverCard: React.FC<HoverCardProps>;
export const HoverCardTrigger: React.FC<ComponentProps>;
export const HoverCardContent: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/hover-card/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/hover-card/src/default.rs)*
