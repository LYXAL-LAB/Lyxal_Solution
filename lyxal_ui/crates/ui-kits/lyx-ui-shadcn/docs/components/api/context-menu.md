# Context Menu Component API

A right-click context menu for performing actions on elements.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-context-menu = "0.7"
```

```rust
use shadcn_ui_leptos_context_menu::ContextMenu;
```

---

## Import

```rust
use shadcn_ui_leptos_context_menu::{
    ContextMenu,
    ContextMenuTrigger,
    ContextMenuContent,
    ContextMenuItem,
    ContextMenuLabel,
    ContextMenuSeparator
};
```

---

## Component API

### ContextMenu

Root component managing menu state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |

### ContextMenuTrigger

Element that triggers the context menu on right-click.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### ContextMenuItem

Individual menu item.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `on_click` | `Option<Callback<()>>` | `None` | Click handler |

---

## Usage Examples

### Basic Context Menu

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_context_menu::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <ContextMenu
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <ContextMenuTrigger>
                <div class="p-4 border">"Right-click me"</div>
            </ContextMenuTrigger>
            <ContextMenuContent>
                <ContextMenuItem on_click=Some(Callback::new(move |_| println!("Copy")))>
                    "Copy"
                </ContextMenuItem>
                <ContextMenuItem on_click=Some(Callback::new(move |_| println!("Paste")))>
                    "Paste"
                </ContextMenuItem>
                <ContextMenuSeparator />
                <ContextMenuItem>"Delete"</ContextMenuItem>
            </ContextMenuContent>
        </ContextMenu>
    }
}
```

---

## CSS Classes

```css
.context-menu-content {
    z-50 min-w-[8rem] overflow-hidden rounded-md
    border bg-popover p-1 text-popover-foreground
    shadow-md
}

.context-menu-item {
    relative flex cursor-pointer select-none items-center
    rounded-sm px-2 py-1.5 text-sm outline-none
    transition-colors hover:bg-accent hover:text-accent-foreground
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Arrow Keys** | Navigate items |
| **Enter** | Select item |
| **Escape** | Close menu |

---

## TypeScript API

```typescript
interface ContextMenuProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
}

export const ContextMenu: React.FC<ContextMenuProps>;
export const ContextMenuTrigger: React.FC<ComponentProps>;
export const ContextMenuContent: React.FC<ComponentProps>;
export const ContextMenuItem: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/context-menu/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/context-menu/src/default.rs)*
