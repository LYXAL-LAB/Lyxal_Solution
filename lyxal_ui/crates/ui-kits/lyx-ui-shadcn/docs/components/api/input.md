# Input Component API

A flexible text input component with built-in validation support and accessibility features.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-input = "0.7"
```

```rust
use shadcn_ui_leptos_input::Input;
```

---

## Import

```rust
// Default theme
use shadcn_ui_leptos_input::Input;

// New York theme
use shadcn_ui_leptos_input::InputNewYork;

// Validation utilities
use shadcn_ui_leptos_input::{
    ValidationRule,
    ValidationError,
    ValidationResult,
    InputValidator,
    ValidationContext,
    validation_builders
};

// Signal-managed variant
use shadcn_ui_leptos_input::{
    SignalManagedInput,
    SignalManagedInputState
};
```

---

## Component API

### Input

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `MaybeProp<String>` | `None` | Current input value |
| `on_change` | `Option<Callback<String>>` | `None` | Value change handler |
| `placeholder` | `MaybeProp<String>` | `None` | Placeholder text |
| `disabled` | `Signal<bool>` | `false` | Disable input |
| `input_type` | `MaybeProp<String>` | `"text"` | HTML input type |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `validator` | `Option<InputValidator>` | `None` | Validation function |
| `validation_error` | `MaybeProp<String>` | `None` | Manual error message |
| `show_validation` | `Signal<bool>` | `false` | Show validation UI |

---

## Validation API

### ValidationRule

```rust
pub struct ValidationRule {
    pub name: String,
    pub validator: Box<dyn Fn(&str) -> Result<(), ValidationError>>,
}
```

### ValidationError

```rust
pub struct ValidationError {
    pub code: String,
    pub message: String,
}
```

### ValidationResult

```rust
pub struct ValidationResult {
    pub is_valid: bool,
    pub errors: Vec<ValidationError>,
}

impl ValidationResult {
    pub fn new() -> Self;
    pub fn is_valid(&self) -> bool;
    pub fn has_errors(&self) -> bool;
}
```

### InputValidator

```rust
pub struct InputValidator {
    pub rules: Vec<ValidationRule>,
}

impl InputValidator {
    pub fn new() -> Self;
    pub fn add_rule(mut self, rule: ValidationRule) -> Self;
    pub fn validate(&self, value: &str) -> ValidationResult;
}
```

### Validation Builders

```rust
pub fn validation_builders() -> ValidationBuilders {
    ValidationBuilders
}

pub struct ValidationBuilders;

impl ValidationBuilders {
    pub fn required() -> ValidationRule;
    pub fn min_length(min: usize) -> ValidationRule;
    pub fn max_length(max: usize) -> ValidationRule;
    pub fn email() -> ValidationRule;
    pub fn pattern(regex: &str) -> ValidationRule;
}
```

---

## Usage Examples

### Basic Input

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_input::Input;

#[component]
pub fn MyForm() -> impl IntoView {
    let (name, set_name) = signal(String::new());

    view! {
        <Input
            value=MaybeProp::Derived(name.into())
            on_change=Callback::new(move |value| {
                set_name.set(value);
            })
            placeholder="Enter your name"
        />
    }
}
```

### With Label

```rust
view! {
    <div class="space-y-2">
        <label for="email">"Email"</label>
        <Input
            id="email"
            input_type="email"
            placeholder="user@example.com"
        />
    </div>
}
```

### Different Input Types

```rust
view! {
    <div class="space-y-4">
        <Input input_type="text" placeholder="Text input" />
        <Input input_type="email" placeholder="Email" />
        <Input input_type="password" placeholder="Password" />
        <Input input_type="number" placeholder="Number" />
        <Input input_type="tel" placeholder="Phone" />
        <Input input_type="url" placeholder="Website" />
    </div>
}
```

### With Validation

```rust
use shadcn_ui_leptos_input::validation_builders;

#[component]
pub fn EmailInput() -> impl IntoView {
    let (email, set_email) = signal(String::new());
    let (show_error, set_show_error) = signal(false);

    let validator = validation_builders()
        .required()
        .email();

    view! {
        <div class="space-y-2">
            <Input
                value=MaybeProp::Derived(email.into())
                on_change=Callback::new(move |value| {
                    set_email.set(value);
                    set_show_error.set(true);
                })
                validator=Some(validator)
                show_validation=Signal::derive(|| show_error.get())
                placeholder="Enter your email"
                id="email"
            />
        </div>
    }
}
```

### Custom Validation Rules

```rust
use shadcn_ui_leptos_input::{ValidationRule, ValidationError};

let custom_validator = InputValidator::new().add_rule(
    ValidationRule {
        name: "custom".to_string(),
        validator: Box::new(|value| {
            if value.len() < 3 {
                Err(ValidationError {
                    code: "too_short".to_string(),
                    message: "Must be at least 3 characters".to_string(),
                })
            } else {
                Ok(())
            }
        }),
    }
);
```

### Multiple Validation Rules

```rust
let password_validator = validation_builders()
    .required()
    .min_length(8)
    .max_length(128)
    .pattern(r"[A-Z]")  // Must contain uppercase
    .pattern(r"[0-9]"); // Must contain number
```

### Disabled State

```rust
view! {
    <Input
        disabled=Signal::derive(|| true)
        placeholder="Disabled input"
        value="Cannot change this"
    />
}
```

### Controlled Input

```rust
#[component]
pub fn SearchInput() -> impl IntoView {
    let (search_query, set_search_query) = signal(String::new());

    view! {
        <div class="relative">
            <Input
                value=MaybeProp::Derived(search_query.into())
                on_change=Callback::new(move |value| {
                    set_search_query.set(value.clone());
                    // Perform search...
                })
                placeholder="Search..."
                class="pl-10"
            />
        </div>
    }
}
```

### Manual Error Display

```rust
#[component]
pub fn UsernameInput() -> impl IntoView {
    let (username, set_username) = signal(String::new());
    let (error, set_error) = signal(String::new());

    let validate = move |value: String| {
        if value.contains(" ") {
            set_error.set("Username cannot contain spaces".to_string());
        } else {
            set_error.set(String::new());
        }
        set_username.set(value);
    };

    view! {
        <div class="space-y-2">
            <Input
                value=MaybeProp::Derived(username.into())
                on_change=Callback::new(validate)
                validation_error=MaybeProp::Derived(error.into())
                show_validation=Signal::derive(|| !error.get().is_empty())
                placeholder="Choose a username"
            />
        </div>
    }
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Tab** | Navigate to/from input |
| **Shift+Tab** | Navigate backwards |
| **Character keys** | Enter text |
| **Ctrl/Cmd+V** | Paste |

### ARIA Attributes

The component automatically manages:

- `aria-invalid` - Set to "true" when validation fails
- `aria-describedby` - References error message element

### Screen Reader Support

```rust
// Good: Label with proper association
<Label for="email">"Email"</Label>
<Input id="email" />

// Good: Descriptive placeholder
<Input placeholder="Enter your email address" />

// Good: aria-label for icon-only inputs
<Input aria_label="Search".to_string() />

// Avoid: Non-descriptive placeholders
<Input placeholder="..." />  // Screen reader says "dot dot dot"
```

---

## Signal-Managed Variant

```rust
use shadcn_ui_leptos_input::SignalManagedInput;

#[component]
pub fn FormInput() -> impl IntoView {
    let state = SignalManagedInputState::new();

    view! {
        <SignalManagedInput
            state=state
            placeholder="Type something..."
        />
    }
}
```

---

## CSS Classes

### Base Classes

```css
.shadcn-input {
    flex h-10 w-full rounded-md border border-input
    bg-background px-3 py-2 text-sm ring-offset-background
    file:border-0 file:bg-transparent file:text-sm file:font-medium
    placeholder:text-muted-foreground
    focus-visible:outline-none focus-visible:ring-2
    focus-visible:ring-ring focus-visible:ring-offset-2
    disabled:cursor-not-allowed disabled:opacity-50
}
```

### Error Classes

```css
.shadcn-input--error {
    border-destructive
    focus-visible:ring-destructive
}
```

### Error Message Classes

```css
.input-error-message {
    text-sm text-destructive
}
```

---

## TypeScript API

```typescript
interface InputProps {
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
  disabled?: boolean;
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url';
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  validator?: InputValidator;
  validationError?: string;
  showValidation?: boolean;
}

interface InputValidator {
  validate: (value: string) => ValidationResult;
}

interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
}

interface ValidationError {
  code: string;
  message: string;
}

export const Input: React.FC<InputProps>;
export const validationBuilders: {
  required: () => ValidationRule;
  minLength: (min: number) => ValidationRule;
  maxLength: (max: number) => ValidationRule;
  email: () => ValidationRule;
  pattern: (regex: string) => ValidationRule;
};
```

---

## Best Practices

1. **Always associate labels** - Use `id` and `<label for="...">`
2. **Provide clear placeholders** - Describe the expected format
3. **Validate appropriately** - Show errors after user interaction
4. **Use correct input types** - Enables browser-specific features
5. **Consider mobile** - Use appropriate input mode keyboards

---

## See Also

- [Button](./button.md) - Submit button
- [Label](./label.md) - Form label component
- [Form](./form.md) - Form container
- [Accessibility Guide](../ACCESSIBILITY_GUIDE.md)

---

*Source: [packages/leptos/input/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/input/src/default.rs)*
