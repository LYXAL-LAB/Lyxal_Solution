# Textarea Component API

A multi-line text input component for longer content.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-textarea = "0.7"
```

```rust
use shadcn_ui_leptos_textarea::Textarea;
```

---

## Component API

### Textarea

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `MaybeProp<String>` | `None` | Current value |
| `on_change` | `Option<Callback<String>>` | `None` | Change handler |
| `placeholder` | `MaybeProp<String>` | `None` | Placeholder text |
| `disabled` | `Signal<bool>` | `false` | Disable textarea |
| `rows` | `MaybeProp<usize>` | `3` | Number of rows |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |

---

## Usage Examples

### Basic Textarea

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_textarea::Textarea;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (text, set_text) = signal(String::new());

    view! {
        <Textarea
            value=MaybeProp::Derived(text.into())
            on_change=Some(Callback::new(move |value| {
                set_text.set(value);
            }))
            placeholder="Enter your message"
            rows=MaybeProp::Derived(5.into())
        />
    }
}
```

---

## CSS Classes

```css
.shadcn-textarea {
    flex min-h-[80px] w-full rounded-md border border-input
    bg-background px-3 py-2 text-sm ring-offset-background
    placeholder:text-muted-foreground focus-visible:outline-none
    focus-visible:ring-2 focus-visible:ring-ring
    focus-visible:ring-offset-2 disabled:cursor-not-allowed
    disabled:opacity-50
}
```

---

## Accessibility

### ARIA Attributes

- `aria-label` - Accessible label
- `aria-describedby` - Description reference
- `aria-invalid` - Validation state

---

## TypeScript API

```typescript
interface TextareaProps {
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  disabled?: boolean;
  rows?: number;
  className?: string;
  id?: string;
}

export const Textarea: React.FC<TextareaProps>;
```

---

*Source: [packages/leptos/textarea/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/textarea/src/default.rs)*
