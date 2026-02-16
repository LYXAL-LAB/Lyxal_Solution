# Menubar Component API

A persistent application menu bar at the top of the screen.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-menubar = "0.7"
```

```rust
use shadcn_ui_leptos_menubar::Menubar;
```

---

## Import

```rust
use shadcn_ui_leptos_menubar::{
    Menubar,
    MenubarMenu,
    MenubarTrigger,
    MenubarContent,
    MenubarItem,
    MenubarLabel,
    MenubarSeparator,
    MenubarShortcut
};
```

---

## Component API

### Menubar

Root menu bar container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### MenubarMenu

Individual menu in the bar.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String` | **Required** | Menu identifier |

### MenubarTrigger

Clickable menu trigger.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Menubar

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_menubar::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Menubar>
            <MenubarMenu value="file">
                <MenubarTrigger>"File"</MenubarTrigger>
                <MenubarContent>
                    <MenubarItem>"New Tab"</MenubarItem>
                    <MenubarItem>"New Window"</MenubarItem>
                    <MenubarSeparator />
                    <MenubarItem>"Quit"</MenubarItem>
                </MenubarContent>
            </MenubarMenu>
            <MenubarMenu value="edit">
                <MenubarTrigger>"Edit"</MenubarTrigger>
                <MenubarContent>
                    <MenubarItem>"Undo"</MenubarItem>
                    <MenubarItem>"Redo"</MenubarItem>
                </MenubarContent>
            </MenubarMenu>
        </Menubar>
    }
}
```

---

## CSS Classes

```css
.menubar {
    flex h-10 items-center space-x-1 rounded-md
    border bg-background p-1
}

.menubar-trigger {
    inline-flex items-center justify-center rounded-md
    px-3 py-1.5 text-sm font-medium transition-colors
    hover:bg-accent hover:text-accent-foreground
    focus:bg-accent focus:text-accent-foreground
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Arrow Keys** | Navigate menus |
| **Enter/Space** | Open menu |
| **Escape** | Close menu |

---

## TypeScript API

```typescript
interface MenubarProps {
  className?: string;
  children?: React.ReactNode;
}

export const Menubar: React.FC<MenubarProps>;
export const MenubarMenu: React.FC<{ value: string }>;
export const MenubarTrigger: React.FC<ComponentProps>;
export const MenubarContent: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/menubar/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/menubar/src/default.rs)*
