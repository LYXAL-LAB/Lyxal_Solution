# Radio Group Component API

A set of radio buttons for single selection from multiple options.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-radio-group = "0.7"
```

```rust
use shadcn_ui_leptos_radio_group::RadioGroup;
```

---

## Import

```rust
use shadcn_ui_leptos_radio_group::{
    RadioGroup,
    RadioGroupItem
};
```

---

## Component API

### RadioGroup

Root container managing radio state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<String>` | **Required** | Selected value |
| `on_change` | `Option<Callback<String>>` | `None` | Change handler |
| `disabled` | `Signal<bool>` | `false` | Disable group |
| `name` | `MaybeProp<String>` | `None` | Form field name |

### RadioGroupItem

Individual radio option.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String` | **Required** | Option value |
| `disabled` | `Signal<bool>` | `false` | Disable option |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |

---

## Usage Examples

### Basic Radio Group

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_radio_group::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (selected, set_selected) = signal("default".to_string());

    view! {
        <RadioGroup
            value=selected.into()
            on_change=Some(Callback::new(move |v| set_selected.set(v)))
            name="notification"
        >
            <div class="flex items-center space-x-2">
                <RadioGroupItem value="default" id="r1" />
                <label for="r1">"Default"</label>
            </div>
            <div class="flex items-center space-x-2">
                <RadioGroupItem value="compact" id="r2" />
                <label for="r2">"Compact"</label>
            </div>
        </RadioGroup>
    }
}
```

---

## CSS Classes

```css
.radio-group-item {
    aspect-square h-4 w-4 rounded-full border
    border-primary text-primary ring-offset-background
    focus:outline-none focus:ring-2 focus:ring-ring
    focus:ring-offset-2 disabled:cursor-not-allowed
    disabled:opacity-50
}

.radio-group-item[data-state=checked] {
    border-primary text-primary
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Arrow Keys** | Navigate options |
| **Space** | Select option |

---

## TypeScript API

```typescript
interface RadioGroupProps {
  value: string;
  onChange?: (value: string) => void;
  disabled?: boolean;
  name?: string;
  children?: React.ReactNode;
}

interface RadioGroupItemProps {
  value: string;
  disabled?: boolean;
  id?: string;
}

export const RadioGroup: React.FC<RadioGroupProps>;
export const RadioGroupItem: React.FC<RadioGroupItemProps>;
```

---

*Source: [packages/leptos/radio-group/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/radio-group/src/default.rs)*
