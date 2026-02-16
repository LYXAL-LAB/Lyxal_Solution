# Lazy Loading Component API

A component that defers loading of its children until needed.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-lazy-loading = "0.7"
```

```rust
use shadcn_ui_leptos_lazy_loading::LazyLoading;
```

---

## Component API

### LazyLoading

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `fallback` | `Option<Children>` | `None` | Loading placeholder |
| `threshold` | `MaybeProp<f64>` | `0.1` | Intersection threshold |
| `children` | `Option<Children>` | `None` | Content to load |

---

## Usage Examples

### Basic Lazy Loading

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_lazy_loading::LazyLoading;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <LazyLoading
            fallback=Some(view! {
                <div class="animate-pulse">"Loading..."</div>
            })
        >
            <div class="p-4">
                "This content loads when visible"
            </div>
        </LazyLoading>
    }
}
```

---

## CSS Classes

```css
.lazy-loading {
    min-h-[100px]
}
```

---

## TypeScript API

```typescript
interface LazyLoadingProps {
  fallback?: React.ReactNode;
  threshold?: number;
  children?: React.ReactNode;
}

export const LazyLoading: React.FC<LazyLoadingProps>;
```

---

*Source: [packages/leptos/lazy-loading/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/lazy-loading/src/default.rs)*
