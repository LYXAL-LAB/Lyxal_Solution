# Breadcrumb Component API

A navigation component showing the user's location in a hierarchy.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-breadcrumb = "0.7"
```

```rust
use shadcn_ui_leptos_breadcrumb::Breadcrumb;
```

---

## Import

```rust
use shadcn_ui_leptos_breadcrumb::{
    Breadcrumb,
    BreadcrumbList,
    BreadcrumbItem,
    BreadcrumbLink,
    BreadcrumbPage,
    BreadcrumbSeparator,
    BreadcrumbEllipsis
};
```

---

## Component API

### Breadcrumb

Root container for breadcrumb navigation.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### BreadcrumbList

Unordered list container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### BreadcrumbItem

Individual breadcrumb item.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### BreadcrumbLink

Clickable breadcrumb link.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `href` | `MaybeProp<String>` | **Required** | Link URL |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### BreadcrumbPage

Current page (non-link).

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### BreadcrumbSeparator

Visual separator between items.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Breadcrumb

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_breadcrumb::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Breadcrumb>
            <BreadcrumbList>
                <BreadcrumbItem>
                    <BreadcrumbLink href="/">"Home"</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                    <BreadcrumbLink href="/components">"Components"</BreadcrumbLink>
                </BreadcrumbItem>
                <BreadcrumbSeparator />
                <BreadcrumbItem>
                    <BreadcrumbPage>"Breadcrumb"</BreadcrumbPage>
                </BreadcrumbItem>
            </BreadcrumbList>
        </Breadcrumb>
    }
}
```

---

## CSS Classes

```css
.breadcrumb-list {
    flex items-center flex-wrap text-sm
}

.breadcrumb-item {
    inline-flex items-center gap-1.5
}

.breadcrumb-link {
    transition-colors hover:text-foreground
}

.breadcrumb-page {
    font-normal text-foreground
}

.breadcrumb-separator {
    opacity-50
}
```

---

## Accessibility

### ARIA Attributes

- `aria-label="breadcrumb"` - Breadcrumb navigation label
- `aria-current="page"` - Current page indicator

---

## TypeScript API

```typescript
interface BreadcrumbProps {
  className?: string;
  children?: React.ReactNode;
}

export const Breadcrumb: React.FC<BreadcrumbProps>;
export const BreadcrumbList: React.FC<ComponentProps>;
export const BreadcrumbItem: React.FC<ComponentProps>;
export const BreadcrumbLink: React.FC<{ href: string }>;
export const BreadcrumbPage: React.FC<ComponentProps>;
export const BreadcrumbSeparator: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/breadcrumb/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/breadcrumb/src/default.rs)*
