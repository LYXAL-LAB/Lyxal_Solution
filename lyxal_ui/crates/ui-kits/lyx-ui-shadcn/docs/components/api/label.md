# Label Component API

A form label component for associating text with form controls.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-label = "0.7"
```

```rust
use shadcn_ui_leptos_label::Label;
```

---

## Component API

### Label

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `for` | `MaybeProp<String>` | `None` | ID of associated element |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `children` | `Option<Children>` | `None` | Label text |

---

## Usage Examples

### Basic Label

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_label::Label;
use shadcn_ui_leptos_input::Input;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <div class="space-y-2">
            <Label for="email">"Email"</Label>
            <Input id="email" input_type="email" />
        </div>
    }
}
```

---

## CSS Classes

```css
.shadcn-label {
    text-sm font-medium leading-none
    peer-disabled:cursor-not-allowed peer-disabled:opacity-70
}
```

---

## Accessibility

Labels must be associated with form controls using the `for` attribute matching the input's `id`.

---

## TypeScript API

```typescript
interface LabelProps {
  htmlFor?: string;
  className?: string;
  id?: string;
  children?: React.ReactNode;
}

export const Label: React.FC<LabelProps>;
```

---

*Source: [packages/leptos/label/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/label/src/default.rs)*
