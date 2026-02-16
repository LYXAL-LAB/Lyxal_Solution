# Drawer Component API

A slide-out panel from any edge of the screen, similar to Sheet but with different styling.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-drawer = "0.7"
```

```rust
use shadcn_ui_leptos_drawer::Drawer;
```

---

## Import

```rust
use shadcn_ui_leptos_drawer::{
    Drawer,
    DrawerTrigger,
    DrawerContent,
    DrawerHeader,
    DrawerTitle,
    DrawerDescription,
    DrawerFooter,
    DrawerClose
};
```

---

## Component API

### Drawer

Root component managing drawer state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |
| `direction` | `MaybeProp<Direction>` | `Right` | Slide direction |

### Direction

```rust
pub enum Direction {
    Top,
    Right,
    Bottom,
    Left,
}
```

---

## Usage Examples

### Basic Drawer

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_drawer::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <Drawer
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <DrawerTrigger>
                <button>"Open Drawer"</button>
            </DrawerTrigger>
            <DrawerContent>
                <DrawerHeader>
                    <DrawerTitle>"Drawer Title"</DrawerTitle>
                </DrawerHeader>
                <div class="p-4">
                    "Drawer content"
                </div>
            </DrawerContent>
        </Drawer>
    }
}
```

---

## CSS Classes

```css
.drawer-content {
    fixed z-50 gap-4 bg-background p-6 shadow-lg
    transition ease-in-out
}

.drawer-content[data-direction=right] {
    inset-y-0 right-0 h-full w-3/4 border-l
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Escape** | Close drawer |

---

## TypeScript API

```typescript
interface DrawerProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  direction?: 'top' | 'right' | 'bottom' | 'left';
}

export const Drawer: React.FC<DrawerProps>;
export const DrawerTrigger: React.FC<ComponentProps>;
export const DrawerContent: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/drawer/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/drawer/src/default.rs)*
