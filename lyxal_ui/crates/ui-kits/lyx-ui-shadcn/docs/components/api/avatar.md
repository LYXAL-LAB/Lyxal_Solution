# Avatar Component API

A user profile image component with fallback support.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-avatar = "0.7"
```

```rust
use shadcn_ui_leptos_avatar::Avatar;
```

---

## Import

```rust
use shadcn_ui_leptos_avatar::{
    Avatar,
    AvatarImage,
    AvatarFallback
};
```

---

## Component API

### Avatar

Root container for avatar components.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### AvatarImage

The image to display.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `src` | `MaybeProp<String>` | **Required** | Image URL |
| `alt` | `MaybeProp<String>` | `None` | Alt text |

### AvatarFallback

Fallback content when image fails to load.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Fallback content |

---

## Usage Examples

### Basic Avatar

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_avatar::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Avatar>
            <AvatarImage src="https://github.com/user.png" alt="User" />
            <AvatarFallback>"JD"</AvatarFallback>
        </Avatar>
    }
}
```

### Avatar with Initials

```rust
view! {
    <Avatar>
        <AvatarImage src=MaybeProp::Derived(None.into()) />
        <AvatarFallback class="bg-primary text-primary-foreground">
            "AB"
        </AvatarFallback>
    </Avatar>
}
```

---

## CSS Classes

```css
.avatar {
    relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full
}

.avatar-image {
    aspect-square h-full w-full
}

.avatar-fallback {
    flex h-full w-full items-center justify-center
    rounded-full bg-muted
}
```

---

## Accessibility

### ARIA Attributes

- `alt` - Image description
- Semantic fallback text

---

## TypeScript API

```typescript
interface AvatarProps {
  className?: string;
  children?: React.ReactNode;
}

interface AvatarImageProps {
  src: string;
  alt?: string;
}

interface AvatarFallbackProps {
  className?: string;
  children: React.ReactNode;
}

export const Avatar: React.FC<AvatarProps>;
export const AvatarImage: React.FC<AvatarImageProps>;
export const AvatarFallback: React.FC<AvatarFallbackProps>;
```

---

*Source: [packages/leptos/avatar/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/avatar/src/default.rs)*
