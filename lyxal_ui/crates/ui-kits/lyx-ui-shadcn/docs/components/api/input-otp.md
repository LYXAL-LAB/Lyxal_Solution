# Input OTP Component API

A one-time password input with individual digit fields.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-input-otp = "0.7"
```

```rust
use shadcn_ui_leptos_input_otp::InputOtp;
```

---

## Component API

### InputOtp

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<String>` | **Required** | Current OTP value |
| `on_change` | `Option<Callback<String>>` | `None` | Change handler |
| `length` | `MaybeProp<usize>` | `6` | Number of digits |
| `disabled` | `Signal<bool>` | `false` | Disable input |

---

## Usage Examples

### Basic OTP Input

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_input_otp::InputOtp;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (otp, set_otp) = signal(String::new());

    view! {
        <div class="space-y-4">
            <InputOtp
                value=otp.into()
                on_change=Some(Callback::new(move |v| set_otp.set(v)))
                length=MaybeProp::Derived(6.into())
            />
            <p>{format!("Entered: {}", otp.get())}</p>
        </div>
    }
}
```

---

## CSS Classes

```css
.input-otp {
    flex gap-2
}

.input-otp-slot {
    flex h-10 w-10 items-center justify-center
    rounded-md border border-input bg-background
    text-center text-sm ring-offset-background
    transition-all focus:outline-none focus:ring-2
    focus:ring-ring focus:ring-offset-2
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Digit** | Enter digit, move to next |
| **Backspace** | Delete, move to previous |
| **Arrow Keys** | Navigate slots |
| **Paste** | Fill all slots |

---

## TypeScript API

```typescript
interface InputOtpProps {
  value: string;
  onChange?: (value: string) => void;
  length?: number;
  disabled?: boolean;
}

export const InputOtp: React.FC<InputOtpProps>;
```

---

*Source: [packages/leptos/input-otp/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/input-otp/src/default.rs)*
