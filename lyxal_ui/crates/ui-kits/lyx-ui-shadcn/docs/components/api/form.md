# Form Component API

A form container with built-in validation and state management.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-form = "0.7"
```

```rust
use shadcn_ui_leptos_form::Form;
```

---

## Component API

### Form

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `on_submit` | `Option<Callback<FormEvent>>` | `None` | Submit handler |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Form

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_form::Form;
use shadcn_ui_leptos_input::Input;
use shadcn_ui_leptos_button::Button;

#[component]
pub fn MyForm() -> impl IntoView {
    let handle_submit = move |e: FormEvent| {
        e.prevent_default();
        // Handle form submission
    };

    view! {
        <Form on_submit=Some(handle_submit)>
            <div class="space-y-4">
                <Input name="email" input_type="email" placeholder="Email" />
                <Input name="password" input_type="password" placeholder="Password" />
                <Button variant=ButtonVariant::Primary>"Submit"</Button>
            </div>
        </Form>
    }
}
```

---

## CSS Classes

```css
.form {
    space-y-6
}
```

---

## Accessibility

- Native HTML form validation
- Proper label association
- Error announcements

---

## TypeScript API

```typescript
interface FormProps {
  onSubmit?: (event: FormEvent) => void;
  className?: string;
  children?: React.ReactNode;
}

export const Form: React.FC<FormProps>;
```

---

*Source: [packages/leptos/form/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/form/src/default.rs)*
