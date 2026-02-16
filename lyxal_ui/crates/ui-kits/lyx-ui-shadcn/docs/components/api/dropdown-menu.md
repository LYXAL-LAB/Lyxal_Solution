# Dropdown Menu Component API

A context menu triggered by a button or other element.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-dropdown-menu = "0.7"
```

```rust
use shadcn_ui_leptos_dropdown_menu::DropdownMenu;
```

---

## Import

```rust
use shadcn_ui_leptos_dropdown_menu::{
    DropdownMenu,
    DropdownMenuTrigger,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuLabel,
    DropdownMenuSeparator,
    DropdownMenuShortcut
};
```

---

## Component API

### DropdownMenu

Root component managing menu state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |

### DropdownMenuItem

Individual menu item.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `disabled` | `Signal<bool>` | `false` | Disable item |
| `on_click` | `Option<Callback<()>>` | `None` | Click handler |

---

## Usage Examples

### Basic Dropdown Menu

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_dropdown_menu::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <DropdownMenu
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <DropdownMenuTrigger>
                <button>"Open menu"</button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
                <DropdownMenuItem on_click=Some(Callback::new(move |_| println!("Profile")))>
                    "Profile"
                </DropdownMenuItem>
                <DropdownMenuItem on_click=Some(Callback::new(move |_| println!("Settings")))>
                    "Settings"
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem>"Logout"</DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    }
}
```

---

## CSS Classes

```css
.dropdown-menu-content {
    z-50 min-w-[8rem] overflow-hidden rounded-md
    border bg-popover p-1 text-popover-foreground
    shadow-md animate-in fade-in-0
}

.dropdown-menu-item {
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
| **Arrow Down** | Next item |
| **Arrow Up** | Previous item |
| **Enter** | Select item |
| **Escape** | Close menu |

---

## TypeScript API

```typescript
interface DropdownMenuProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
}

export const DropdownMenu: React.FC<DropdownMenuProps>;
export const DropdownMenuTrigger: React.FC<ComponentProps>;
export const DropdownMenuContent: React.FC<ComponentProps>;
export const DropdownMenuItem: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/dropdown-menu/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/dropdown-menu/src/default.rs)*
