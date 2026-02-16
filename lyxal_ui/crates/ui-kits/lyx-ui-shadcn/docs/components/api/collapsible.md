# Collapsible Component API

A component that can show/hide content with animation.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-collapsible = "0.7"
```

```rust
use shadcn_ui_leptos_collapsible::Collapsible;
```

---

## Import

```rust
use shadcn_ui_leptos_collapsible::{
    Collapsible,
    CollapsibleTrigger,
    CollapsibleContent
};
```

---

## Component API

### Collapsible

Root component managing collapsible state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |
| `disabled` | `Signal<bool>` | `false` | Disable collapsible |

### CollapsibleTrigger

Element that toggles the collapsible.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### CollapsibleContent

Collapsible content container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Collapsible

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_collapsible::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <Collapsible
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <CollapsibleTrigger>
                <button>"Toggle"</button>
            </CollapsibleTrigger>
            <CollapsibleContent>
                <div class="p-4">
                    "Hidden content that can be shown/hidden"
                </div>
            </CollapsibleContent>
        </Collapsible>
    }
}
```

---

## CSS Classes

```css
.collapsible-content {
    overflow-hidden transition-all
}

.collapsible-content[data-state=open] {
    animate-collapsible-down
}

.collapsible-content[data-state=closed] {
    animate-collapsible-up
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Enter/Space** | Toggle collapsible |

---

## TypeScript API

```typescript
interface CollapsibleProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  disabled?: boolean;
  children?: React.ReactNode;
}

export const Collapsible: React.FC<CollapsibleProps>;
export const CollapsibleTrigger: React.FC<ComponentProps>;
export const CollapsibleContent: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/collapsible/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/collapsible/src/default.rs)*
