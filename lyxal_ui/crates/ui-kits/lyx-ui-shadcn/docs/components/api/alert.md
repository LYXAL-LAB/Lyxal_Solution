# Alert Component API

A component for displaying alert messages with different severity levels.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-alert = "0.7"
```

```rust
use shadcn_ui_leptos_alert::Alert;
```

---

## Import

```rust
use shadcn_ui_leptos_alert::{
    Alert,
    AlertTitle,
    AlertDescription,
    AlertVariant
};
```

---

## Component API

### Alert

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `MaybeProp<AlertVariant>` | `Default` | Alert style variant |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Alert content |

### AlertVariant

```rust
pub enum AlertVariant {
    Default,     // Neutral styling
    Destructive, // Red for errors
    Warning,     // Yellow for warnings
    Info,        // Blue for information
    Success,     // Green for success
}
```

### AlertTitle

Title text for the alert.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Title text |

### AlertDescription

Detailed description text.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Description text |

---

## Usage Examples

### Basic Alert

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_alert::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Alert variant=AlertVariant::Default>
            <AlertTitle>"Heads up!"</AlertTitle>
            <AlertDescription>
                "You can add components to your app using the cli."
            </AlertDescription>
        </Alert>
    }
}
```

### Alert Variants

```rust
view! {
    <div class="space-y-4">
        <Alert variant=AlertVariant::Default>
            <AlertDescription>"Default alert"</AlertDescription>
        </Alert>

        <Alert variant=AlertVariant::Info>
            <AlertDescription>"Information message"</AlertDescription>
        </Alert>

        <Alert variant=AlertVariant::Success>
            <AlertDescription>"Success! Operation completed."</AlertDescription>
        </Alert>

        <Alert variant=AlertVariant::Warning>
            <AlertDescription>"Warning! Please review."</AlertDescription>
        </Alert>

        <Alert variant=AlertVariant::Destructive>
            <AlertDescription>"Error! Something went wrong."</AlertDescription>
        </Alert>
    </div>
}
```

---

## CSS Classes

```css
.alert {
    relative w-full rounded-lg border px-4 py-3 text-sm
}

.alert-default {
    border-border bg-background text-foreground
}

.alert-destructive {
    border-destructive/50 text-destructive
    bg-destructive/10
}

.alert-warning {
    border-warning/50 text-warning
    bg-warning/10
}

.alert-success {
    border-success/50 text-success
    bg-success/10
}

.alert-info {
    border-info/50 text-info
    bg-info/10
}

.alert-title {
    mb-1 font-medium leading-none tracking-tight
}

.alert-description {
    text-sm opacity-90
}
```

---

## Accessibility

### ARIA Attributes

- `role="alert"` - Alert role for screen readers
- Semantic heading for title
- Descriptive text for context

---

## TypeScript API

```typescript
interface AlertProps {
  variant?: 'default' | 'destructive' | 'warning' | 'info' | 'success';
  className?: string;
  children?: React.ReactNode;
}

export const Alert: React.FC<AlertProps>;
export const AlertTitle: React.FC<ComponentProps>;
export const AlertDescription: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/alert/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/alert/src/default.rs)*
