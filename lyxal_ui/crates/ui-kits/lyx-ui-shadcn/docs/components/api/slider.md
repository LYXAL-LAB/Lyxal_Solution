# Slider Component API

A slider control for selecting values within a range.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-slider = "0.7"
```

```rust
use shadcn_ui_leptos_slider::Slider;
```

---

## Component API

### Slider

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<Vec<f64>>` | **Required** | Current value(s) |
| `on_change` | `Option<Callback<Vec<f64>>>` | `None` | Change handler |
| `min` | `MaybeProp<f64>` | `0` | Minimum value |
| `max` | `MaybeProp<f64>` | `100` | Maximum value |
| `step` | `MaybeProp<f64>` | `1` | Step increment |
| `disabled` | `Signal<bool>` | `false` | Disable slider |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Slider

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_slider::Slider;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (value, set_value) = signal(vec![50.0]);

    view! {
        <div class="space-y-4">
            <Slider
                value=value.into()
                on_change=Some(Callback::new(move |v| set_value.set(v)))
            />
            <p>{format!("Value: {}", value.get()[0])}</p>
        </div>
    }
}
```

---

## CSS Classes

```css
.slider-root {
    relative flex w-full touch-none
    select-none items-center
}

.slider-track {
    relative h-2 w-full grow overflow-hidden
    rounded-full bg-secondary
}

.slider-fill {
    absolute h-full bg-primary
}

.slider-thumb {
    block h-5 w-5 rounded-full border-2
    border-primary bg-background ring-offset-background
    transition-colors focus-visible:outline-none
    focus-visible:ring-2 focus-visible:ring-ring
    focus-visible:ring-offset-2 disabled:pointer-events-none
    disabled:opacity-50
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Arrow Right** | Increase value |
| **Arrow Left** | Decrease value |
| **Home** | Minimum value |
| **End** | Maximum value |

---

## TypeScript API

```typescript
interface SliderProps {
  value: number[];
  onChange?: (value: number[]) => void;
  min?: number;
  max?: number;
  step?: number;
  disabled?: boolean;
  className?: string;
}

export const Slider: React.FC<SliderProps>;
```

---

*Source: [packages/leptos/slider/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/slider/src/default.rs)*
