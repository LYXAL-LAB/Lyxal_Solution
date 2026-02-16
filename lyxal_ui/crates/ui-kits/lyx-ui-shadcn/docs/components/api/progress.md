# Progress Component API

A progress indicator component for showing completion status.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-progress = "0.7"
```

```rust
use shadcn_ui_leptos_progress::Progress;
```

---

## Component API

### Progress

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<f64>` | **Required** | Progress value (0-100) |
| `max` | `MaybeProp<f64>` | `100` | Maximum value |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |

---

## Usage Examples

### Basic Progress

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_progress::Progress;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (progress, set_progress) = signal(66.0);

    view! {
        <div class="space-y-2">
            <Progress value=progress.into() />
            <p>{format!("{}% complete", progress.get())}</p>
        </div>
    }
}
```

### Indeterminate Progress

```rust
view! {
    <Progress value=Signal::derive(|| 0.0) class="animate-pulse" />
}
```

---

## CSS Classes

```css
.progress-root {
    relative h-4 w-full overflow-hidden rounded-full
    bg-secondary
}

.progress-indicator {
    h-full w-full flex-1 bg-primary
    transition-all
}
```

---

## Accessibility

### ARIA Attributes

- `role="progressbar"` - Progress bar role
- `aria-valuenow` - Current value
- `aria-valuemin` - Minimum value (0)
- `aria-valuemax` - Maximum value
- `aria-label` - Accessible label

---

## TypeScript API

```typescript
interface ProgressProps {
  value: number;
  max?: number;
  className?: string;
  id?: string;
}

export const Progress: React.FC<ProgressProps>;
```

---

*Source: [packages/leptos/progress/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/progress/src/default.rs)*
