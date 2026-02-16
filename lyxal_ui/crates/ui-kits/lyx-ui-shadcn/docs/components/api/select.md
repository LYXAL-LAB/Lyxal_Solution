# Select Component API

A dropdown select component for choosing from a list of options.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-select = "0.7"
```

```rust
use shadcn_ui_leptos_select::Select;
```

---

## Import

```rust
use shadcn_ui_leptos_select::{
    Select,
    SelectTrigger,
    SelectContent,
    SelectItem,
    SelectValue,
    SelectLabel,
    SelectGroup,
    SelectSeparator
};
```

---

## Component API

### Select

Root component for the select dropdown.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<String>` | **Required** | Selected value |
| `on_change` | `Option<Callback<String>>` | `None` | Change handler |
| `disabled` | `Signal<bool>` | `false` | Disable select |
| `placeholder` | `MaybeProp<String>` | `"Select..."` | Placeholder text |
| `children` | `Option<Children>` | `None` | Select content |

### SelectTrigger

Button that opens the dropdown.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `disabled` | `Signal<bool>` | `false` | Disable trigger |

### SelectContent

Dropdown content container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `position` | `MaybeProp<SelectPosition>` | `Bottom` | Dropdown position |

### SelectItem

Individual selectable option.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String` | **Required** | Option value |
| `disabled` | `Signal<bool>` | `false` | Disable option |

### SelectValue

Display area for selected value.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `placeholder` | `MaybeProp<String>` | `None` | Placeholder text |

---

## Usage Examples

### Basic Select

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_select::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (selected, set_selected) = signal("apple".to_string());

    view! {
        <Select
            value=selected.into()
            on_change=Some(Callback::new(move |value| {
                set_selected.set(value);
            }))
        >
            <SelectTrigger>
                <SelectValue placeholder="Choose a fruit" />
            </SelectTrigger>
            <SelectContent>
                <SelectItem value="apple">"Apple"</SelectItem>
                <SelectItem value="banana">"Banana"</SelectItem>
                <SelectItem value="orange">"Orange"</SelectItem>
            </SelectContent>
        </Select>
    }
}
```

---

## CSS Classes

```css
.select-trigger {
    flex h-10 w-full items-center justify-between
    rounded-md border border-input bg-background px-3 py-2
    text-sm ring-offset-background placeholder:text-muted-foreground
    focus:outline-none focus:ring-2 focus:ring-ring
    focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50
}

.select-content {
    relative z-50 min-w-[8rem] overflow-hidden rounded-md
    border bg-popover text-popover-foreground shadow-md
}

.select-item {
    relative flex w-full cursor-pointer select-none
    items-center rounded-sm py-1.5 pl-8 pr-2 text-sm
    outline-none focus:bg-accent focus:text-accent-foreground
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Arrow Down** | Next option |
| **Arrow Up** | Previous option |
| **Enter** | Select option |
| **Escape** | Close dropdown |

---

## TypeScript API

```typescript
interface SelectProps {
  value: string;
  onChange?: (value: string) => void;
  disabled?: boolean;
  placeholder?: string;
  children?: React.ReactNode;
}

export const Select: React.FC<SelectProps>;
export const SelectTrigger: React.FC<ComponentProps>;
export const SelectContent: React.FC<ComponentProps>;
export const SelectItem: React.FC<{ value: string; disabled?: boolean; children: React.ReactNode }>;
export const SelectValue: React.FC<{ placeholder?: string }>;
```

---

*Source: [packages/leptos/select/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/select/src/default.rs)*
