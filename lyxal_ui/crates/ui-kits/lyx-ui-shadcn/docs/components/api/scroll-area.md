# Scroll Area Component API

A container with custom styled scrollbars.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-scroll-area = "0.7"
```

```rust
use shadcn_ui_leptos_scroll_area::ScrollArea;
```

---

## Component API

### ScrollArea

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Scrollable content |

---

## Usage Examples

### Basic Scroll Area

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_scroll_area::ScrollArea;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <ScrollArea class="h-72 w-48 rounded-md border">
            <div class="p-4">
                <p>"Long content that scrolls..."</p>
            </div>
        </ScrollArea>
    }
}
```

---

## CSS Classes

```css
.scroll-area {
    overflow-auto
}

.scroll-area::-webkit-scrollbar {
    width: 8px
}

.scroll-area::-webkit-scrollbar-track {
    background: transparent
}

.scroll-area::-webkit-scrollbar-thumb {
    background-color: hsl(var(--muted))
    border-radius: 4px
}
```

---

## Accessibility

- Standard scrolling behavior maintained
- Keyboard navigation supported

---

## TypeScript API

```typescript
interface ScrollAreaProps {
  className?: string;
  children?: React.ReactNode;
}

export const ScrollArea: React.FC<ScrollAreaProps>;
```

---

*Source: [packages/leptos/scroll-area/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/scroll-area/src/default.rs)*
