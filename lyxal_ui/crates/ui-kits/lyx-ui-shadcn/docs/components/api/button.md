# Button Component API

A versatile button component with multiple variants, sizes, and states for all interactive needs.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-button = "0.7"
```

```rust
use shadcn_ui_leptos_button::Button;
```

---

## Import

```rust
// Default theme
use shadcn_ui_leptos_button::{
    Button,
    ButtonVariant,
    ButtonSize,
    ButtonChildProps
};

// New York theme
use shadcn_ui_leptos_button::{
    ButtonNewYork,
    ButtonVariantNewYork,
    ButtonSizeNewYork
};

// Signal-managed variant
use shadcn_ui_leptos_button::{
    SignalManagedButton,
    SignalManagedButtonState
};
```

---

## Component API

### Button

#### Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `MaybeProp<ButtonVariant>` | `Default` | Visual style variant |
| `size` | `MaybeProp<ButtonSize>` | `Default` | Button size |
| `on_click` | `Option<Callback<()>>` | `None` | Click event handler |
| `disabled` | `Signal<bool>` | `false` | Disable button interaction |
| `loading` | `Signal<bool>` | `false` | Show loading spinner |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `aria_label` | `MaybeProp<String>` | `None` | Accessible name |
| `aria_describedby` | `MaybeProp<String>` | `None` | Description reference |
| `as_child` | `Option<Callback<ButtonChildProps, AnyView>>` | `None` | Render as custom element |
| `children` | `Option<Children>` | `None` | Button content |

#### ButtonVariant

```rust
pub enum ButtonVariant {
    Default,      // Primary brand color
    Destructive,  // Red, destructive actions
    Outline,      // Bordered outline
    Secondary,    // Secondary color
    Ghost,        // No background, hover effect
    Link,         // Text link style
}
```

#### ButtonSize

```rust
pub enum ButtonSize {
    Default,  // Standard size (h-10 px-4 py-2)
    Sm,       // Small (h-9 rounded-md px-3)
    Lg,       // Large (h-11 rounded-md px-8)
    Icon,     // Square icon (h-10 w-10)
}
```

#### ButtonChildProps

When using `as_child`, these props are passed to your custom component:

```rust
pub struct ButtonChildProps {
    pub class: String,                    // CSS classes
    pub id: String,                       // Element ID
    pub style: String,                    // Inline styles
    pub disabled: bool,                   // Disabled state
    pub r#type: String,                   // HTML type (button)
    pub onclick: Option<Callback<()>>,     // Click handler
}
```

---

## Usage Examples

### Basic Button

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_button::Button;

#[component]
pub fn MyApp() -> impl IntoView {
    view! {
        <Button on_click=move || println!("Clicked!")>
            "Click me"
        </Button>
    }
}
```

### Variants

```rust
view! {
    <div class="flex gap-2">
        <Button variant=ButtonVariant::Default>"Default"</Button>
        <Button variant=ButtonVariant::Destructive>"Destructive"</Button>
        <Button variant=ButtonVariant::Outline>"Outline"</Button>
        <Button variant=ButtonVariant::Secondary>"Secondary"</Button>
        <Button variant=ButtonVariant::Ghost>"Ghost"</Button>
        <Button variant=ButtonVariant::Link>"Link"</Button>
    </div>
}
```

### Sizes

```rust
view! {
    <div class="flex items-center gap-2">
        <Button size=ButtonSize::Sm>"Small"</Button>
        <Button size=ButtonSize::Default>"Default"</Button>
        <Button size=ButtonSize::Lg>"Large"</Button>
        <Button size=ButtonSize::Icon>
            <span>"+"</span>
        </Button>
    </div>
}
```

### With Loading State

```rust
#[component]
pub fn SaveButton() -> impl IntoView {
    let (loading, set_loading) = signal(false);

    let handle_save = move |_| {
        set_loading.set(true);
        // Simulate async operation
        setTimeout(move || {
            set_loading.set(false);
        }, 2000);
    };

    view! {
        <Button
            on_click=handle_save
            loading=loading.into()
        >
            "Save"
        </Button>
    }
}
```

### Disabled State

```rust
view! {
    <Button disabled=Signal::derive(|| true)>
        "Disabled"
    </Button>
}
```

### Custom Styling

```rust
view! {
    <Button
        variant=ButtonVariant::Primary
        class="w-full shadow-lg"
        id="submit-button"
        style=Style::new("margin-top: 1rem")
    >
        "Submit"
    </Button>
}
```

### With Icon

```rust
view! {
    <Button variant=ButtonVariant::Outline size=ButtonSize::Sm>
        <span class="mr-2">"+"</span>
        "Add New"
    </Button>
}
```

### As Child (Custom Element)

```rust
view! {
    <Button
        as_child=Callback::new(|props| {
            view! {
                <a
                    class=props.class
                    id=props.id
                    style=props.style
                    href="https://example.com"
                >
                    "Link Button"
                </a>
            }.into_any()
        })
    />
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Enter** | Activates button |
| **Space** | Activates button |
| **Tab** | Focuses next button |

### ARIA Attributes

The component automatically manages ARIA attributes:

- `aria-label` - Custom accessible label
- `aria-describedby` - References description element
- `aria-busy` - Set to "true" when loading
- `disabled` - HTML disabled attribute

### Screen Reader Support

```rust
// Good: Provide accessible label
<Button aria_label="Close dialog".to_string()>
    <span>"X"</span>
</Button>

// Good: Use descriptive text
<Button>"Delete Account"</Button>

// Avoid: Non-descriptive icons without labels
<Button>
    <span>X</span>  // Screen reader won't understand
</Button>
```

---

## Signal-Managed Variant

The `SignalManagedButton` provides built-in state management:

```rust
use shadcn_ui_leptos_button::SignalManagedButton;

#[component]
pub fn MyForm() -> impl IntoView {
    let state = SignalManagedButtonState::new();

    view! {
        <SignalManagedButton
            state=state
            on_click=move || println!("Clicked!")
        >
            "Submit"
        </SignalManagedButton>
    }
}
```

---

## CSS Classes

### Base Classes

```css
.shadcn-button {
    inline-flex items-center justify-center
    whitespace-nowrap rounded-md text-sm font-medium
    ring-offset-background transition-colors
    focus-visible:outline-none focus-visible:ring-2
    focus-visible:ring-ring focus-visible:ring-offset-2
    disabled:pointer-events-none disabled:opacity-50
}
```

### Variant Classes

| Variant | CSS Classes |
|---------|-------------|
| `Default` | `bg-primary text-primary-foreground hover:bg-primary/90` |
| `Destructive` | `bg-destructive text-destructive-foreground hover:bg-destructive/90` |
| `Outline` | `border border-input bg-background hover:bg-accent hover:text-accent-foreground` |
| `Secondary` | `bg-secondary text-secondary-foreground hover:bg-secondary/80` |
| `Ghost` | `hover:bg-accent hover:text-accent-foreground` |
| `Link` | `text-primary underline-offset-4 hover:underline` |

### Size Classes

| Size | CSS Classes |
|------|-------------|
| `Default` | `h-10 px-4 py-2` |
| `Sm` | `h-9 rounded-md px-3` |
| `Lg` | `h-11 rounded-md px-8` |
| `Icon` | `h-10 w-10` |

---

## TypeScript API

```typescript
interface ButtonProps {
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
  size?: 'default' | 'sm' | 'lg' | 'icon';
  onClick?: () => void;
  disabled?: boolean;
  loading?: boolean;
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  ariaLabel?: string;
  ariaDescribedby?: string;
  asChild?: boolean;
  children?: React.ReactNode;
}

export const Button: React.FC<ButtonProps>;
```

---

## Best Practices

1. **Use clear, descriptive labels** - "Submit" is better than "OK"
2. **Match variant to action** - Use `Destructive` for irreversible actions
3. **Provide loading feedback** - Use the `loading` prop for async actions
4. **Maintain consistent sizing** - Keep buttons within a section the same size
5. **Consider touch targets** - Minimum 44x44 pixels for mobile

---

## See Also

- [Input](./input.md) - Form input component
- [Dialog](./dialog.md) - Modal dialog component
- [Accessibility Guide](../ACCESSIBILITY_GUIDE.md)

---

*Source: [packages/leptos/button/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/button/src/default.rs)*
