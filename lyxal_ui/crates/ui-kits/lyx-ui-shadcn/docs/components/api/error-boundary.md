# Error Boundary Component API

A component that catches JavaScript errors in its child component tree.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-error-boundary = "0.7"
```

```rust
use shadcn_ui_leptos_error_boundary::ErrorBoundary;
```

---

## Component API

### ErrorBoundary

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `fallback` | `Option<Callback<Error, View>>` | **Required** | Error fallback UI |
| `children` | `Option<Children>` | `None` | Child components |

---

## Usage Examples

### Basic Error Boundary

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_error_boundary::ErrorBoundary;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <ErrorBoundary
            fallback=Callback::new(|_error| {
                view! {
                    <div class="p-4 bg-destructive/10 rounded-md">
                        <h2 class="text-lg font-semibold">"Something went wrong"</h2>
                        <p class="text-sm">"Please refresh the page"</p>
                    </div>
                }
            })
        >
            <p>"Child content that might error"</p>
        </ErrorBoundary>
    }
}
```

---

## CSS Classes

```css
.error-boundary {
    p-4 border border-destructive rounded-md
}
```

---

## TypeScript API

```typescript
interface ErrorBoundaryProps {
  fallback: (error: Error) => React.ReactNode;
  children?: React.ReactNode;
}

export const ErrorBoundary: React.FC<ErrorBoundaryProps>;
```

---

*Source: [packages/leptos/error-boundary/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/error-boundary/src/default.rs)*
