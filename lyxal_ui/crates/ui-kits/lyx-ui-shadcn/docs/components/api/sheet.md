# Sheet Component API

A side panel that slides in from the edge of the screen.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-sheet = "0.7"
```

```rust
use shadcn_ui_leptos_sheet::Sheet;
```

---

## Import

```rust
use shadcn_ui_leptos_sheet::{
    Sheet,
    SheetTrigger,
    SheetContent,
    SheetHeader,
    SheetTitle,
    SheetDescription,
    SheetFooter,
    SheetClose
};
```

---

## Component API

### Sheet

Root component managing sheet state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |

### SheetContent

The sliding panel container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `side` | `MaybeProp<Side>` | `Right` | Which side to slide from |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### Side

```rust
pub enum Side {
    Top,
    Right,
    Bottom,
    Left,
}
```

---

## Usage Examples

### Basic Sheet

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_sheet::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <Sheet
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <SheetTrigger>
                <button>"Open Sheet"</button>
            </SheetTrigger>
            <SheetContent>
                <SheetHeader>
                    <SheetTitle>"Sheet Title"</SheetTitle>
                </SheetHeader>
                <div class="py-4">
                    "Sheet content goes here"
                </div>
            </SheetContent>
        </Sheet>
    }
}
```

---

## CSS Classes

```css
.sheet-content {
    fixed z-50 gap-4 bg-background p-6 shadow-lg
    transition ease-in-out data-[state=open]:animate-in
    data-[state=closed]:animate-out
}

.sheet-content[data-side=right] {
    inset-y-0 right-0 h-full w-3/4 border-l
    data-[state=closed]:slide-out-to-right
    data-[state=open]:slide-in-from-right
    sm:max-w-sm
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Escape** | Close sheet |

---

## TypeScript API

```typescript
interface SheetProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
}

export const Sheet: React.FC<SheetProps>;
export const SheetTrigger: React.FC<ComponentProps>;
export const SheetContent: React.FC<{ side?: 'top' | 'right' | 'bottom' | 'left' }>;
```

---

*Source: [packages/leptos/sheet/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/sheet/src/default.rs)*
