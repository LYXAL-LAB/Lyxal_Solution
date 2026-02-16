# Resizable Component API

A container with resizable panels.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-resizable = "0.7"
```

```rust
use shadcn_ui_leptos_resizable::Resizable;
```

---

## Import

```rust
use shadcn_ui_leptos_resizable::{
    Resizable,
    ResizablePanel,
    ResizableHandle
};
```

---

## Component API

### Resizable

Root container for resizable layout.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `direction` | `MaybeProp<Direction>` | `Horizontal` | Resize direction |

### ResizablePanel

Individual resizable panel.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `String` | **Required** | Panel identifier |
| `min_size` | `MaybeProp<f64>` | `0` | Minimum size percentage |
| `default_size` | `MaybeProp<f64>` | `50` | Default size percentage |

---

## Usage Examples

### Basic Resizable

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_resizable::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Resizable>
            <ResizablePanel id="panel1" default_size=MaybeProp::Derived(50.into())>
                <div class="p-4">"Left panel"</div>
            </ResizablePanel>
            <ResizableHandle />
            <ResizablePanel id="panel2" default_size=MaybeProp::Derived(50.into())>
                <div class="p-4">"Right panel"</div>
            </ResizablePanel>
        </Resizable>
    }
}
```

---

## CSS Classes

```css
.resizable {
    flex
}

.resizable-panel {
    overflow-hidden
}

.resizable-handle {
    flex w-px bg-border hover:bg-primary/50 cursor-col-resize
}

.resizable-handle-vertical {
    h-px w-full cursor-row-resize
}
```

---

## Accessibility

- `aria-resizable` - Resizable indicator
- `aria-valuenow` - Current size
- Keyboard resize support (Shift+Arrow keys)

---

## TypeScript API

```typescript
interface ResizableProps {
  direction?: 'horizontal' | 'vertical';
  children?: React.ReactNode;
}

interface ResizablePanelProps {
  id: string;
  minSize?: number;
  defaultSize?: number;
}

export const Resizable: React.FC<ResizableProps>;
export const ResizablePanel: React.FC<ResizablePanelProps>;
export const ResizableHandle: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/resizable/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/resizable/src/default.rs)*
