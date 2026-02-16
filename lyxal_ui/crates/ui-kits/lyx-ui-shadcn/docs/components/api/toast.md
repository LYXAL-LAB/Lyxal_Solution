# Toast Component API

A temporary notification component for displaying brief messages.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-toast = "0.7"
```

```rust
use shadcn_ui_leptos_toast::Toast;
```

---

## Import

```rust
use shadcn_ui_leptos_toast::{
    Toast,
    ToastProvider,
    ToastTitle,
    ToastDescription,
    ToastAction,
    ToastClose,
    ToastVariant
};
```

---

## Component API

### ToastProvider

Context provider for toast notifications.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `children` | `Option<Children>` | `None` | App content |

### Toast

Individual toast notification.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `MaybeProp<ToastVariant>` | `Default` | Toast style |
| `title` | `MaybeProp<String>` | `None` | Toast title |
| `description` | `MaybeProp<String>` | `None` | Toast description |
| `duration` | `MaybeProp<u64>` | `5000` | Auto-close duration (ms) |
| `on_close` | `Option<Callback<()>>` | `None` | Close callback |

### ToastVariant

```rust
pub enum ToastVariant {
    Default,     // Neutral styling
    Destructive, // Red for errors
    Success,     // Green for success
}
```

---

## Usage Examples

### Basic Toast

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_toast::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <ToastProvider>
            <div>
                <button on:click=move |_| {
                    // Show toast
                }>"Show Toast"</button>
            </div>
        </ToastProvider>
    }
}
```

---

## CSS Classes

```css
.toast {
    group pointer-events-auto relative flex w-full
    items-center justify-between space-x-4 overflow-hidden
    rounded-md border p-6 pr-8 shadow-lg transition-all
}

.toast-default {
    border bg-background text-foreground
}

.toast-destructive {
    border-destructive bg-destructive text-destructive-foreground
}

.toast-success {
    border-success bg-success text-success-foreground
}
```

---

## Accessibility

### ARIA Attributes

- `role="status"` - Status role
- `aria-live="polite"` - Polite announcements
- `aria-atomic="true"` - Complete content reading

---

## TypeScript API

```typescript
interface ToastProps {
  variant?: 'default' | 'destructive' | 'success';
  title?: string;
  description?: string;
  duration?: number;
  onClose?: () => void;
}

export const Toast: React.FC<ToastProps>;
export const ToastProvider: React.FC<{ children: React.ReactNode }>;
export const ToastTitle: React.FC<ComponentProps>;
export const ToastDescription: React.FC<ComponentProps>;
export const ToastAction: React.FC<ButtonProps>;
export const ToastClose: React.FC<ButtonProps>;
```

---

*Source: [packages/leptos/toast/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/toast/src/default.rs)*
