# Combobox Component API

A searchable select component with autocomplete functionality.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-combobox = "0.7"
```

```rust
use shadcn_ui_leptos_combobox::Combobox;
```

---

## Import

```rust
use shadcn_ui_leptos_combobox::{
    Combobox,
    ComboboxTrigger,
    ComboboxContent,
    ComboboxInput,
    ComboboxItem,
    ComboboxEmpty
};
```

---

## Component API

### Combobox

Root component managing combobox state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<Option<String>>` | **Required** | Selected value |
| `on_change` | `Option<Callback<Option<String>>>` | `None` | Change handler |
| `options` | `Vec<String>` | **Required** | Available options |
| `filterable` | `Signal<bool>` | `true` | Enable search filtering |

---

## Usage Examples

### Basic Combobox

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_combobox::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (value, set_value) = signal(None);
    let options = vec![
        "Apple".to_string(),
        "Banana".to_string(),
        "Orange".to_string(),
    ];

    view! {
        <Combobox
            value=value.into()
            on_change=Some(Callback::new(move |v| set_value.set(v)))
            options=options
        >
            <ComboboxTrigger>
                <button>"Select fruit"</button>
            </ComboboxTrigger>
            <ComboboxContent>
                <ComboboxInput placeholder="Search..." />
                <ComboboxEmpty>"No results found"</ComboboxEmpty>
                // Items rendered automatically
            </ComboboxContent>
        </Combobox>
    }
}
```

---

## CSS Classes

```css
.combobox-content {
    z-50 min-w-[8rem] overflow-hidden rounded-md
    border bg-popover p-1 text-popover-foreground
    shadow-md
}

.combobox-item {
    relative flex cursor-pointer select-none items-center
    rounded-sm px-2 py-1.5 text-sm outline-none
    transition-colors hover:bg-accent hover:text-accent-foreground
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Type** | Filter options |
| **Arrow Keys** | Navigate options |
| **Enter** | Select option |
| **Escape** | Close dropdown |

---

## TypeScript API

```typescript
interface ComboboxProps {
  value: string | null;
  onChange?: (value: string | null) => void;
  options: string[];
  filterable?: boolean;
}

export const Combobox: React.FC<ComboboxProps>;
```

---

*Source: [packages/leptos/combobox/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/combobox/src/default.rs)*
