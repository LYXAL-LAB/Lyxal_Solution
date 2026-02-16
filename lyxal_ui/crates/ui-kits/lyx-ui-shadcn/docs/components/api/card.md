# Card Component API

A versatile card component for organizing and displaying content with optional header, title, description, content, and footer sections.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-card = "0.7"
```

```rust
use shadcn_ui_leptos_card::Card;
```

---

## Import

```rust
// Default theme
use shadcn_ui_leptos_card::{
    Card,
    CardHeader,
    CardTitle,
    CardDescription,
    CardContent,
    CardFooter,
    CardVariant,
    InteractiveCard
};

// New York theme
use shadcn_ui_leptos_card::{
    Card as CardNewYork,
    CardHeader as CardHeaderNewYork,
    // ... other components
};

// Signal-managed variant
use shadcn_ui_leptos_card::{
    SignalManagedCard,
    SignalManagedCardState
};
```

---

## Component API

### Card

The main card container component.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `variant` | `MaybeProp<CardVariant>` | `Default` | Visual style variant |
| `interactive` | `Signal<bool>` | `false` | Enable hover/click effects |
| `children` | `Option<Children>` | `None` | Card content |

### CardHeader

Header section containing title and description.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `children` | `Option<Children>` | `None` | Header content |

### CardTitle

Title text within the card header.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `level` | `MaybeProp<u8>` | `2` | Heading level (h1-h6) |
| `children` | `Option<Children>` | `None` | Title text |

### CardDescription

Description text within the card header.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `children` | `Option<Children>` | `None` | Description text |

### CardContent

Main content area of the card.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `children` | `Option<Children>` | `None` | Content |

### CardFooter

Footer section for actions or metadata.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `children` | `Option<Children>` | `None` | Footer content |

---

## CardVariant

```rust
pub enum CardVariant {
    Default,     // Standard card styling
    Destructive, // Red border/background for errors
    Warning,     // Yellow border/background for warnings
    Success,     // Green border/background for success
}
```

---

## Usage Examples

### Basic Card

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_card::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Card>
            <CardContent>
                <p>"Basic card content"</p>
            </CardContent>
        </Card>
    }
}
```

### Complete Card Structure

```rust
view! {
    <Card>
        <CardHeader>
            <CardTitle>"Card Title"</CardTitle>
            <CardDescription>
                "A brief description of the card's content"
            </CardDescription>
        </CardHeader>
        <CardContent>
            <p>"Main content goes here."</p>
        </CardContent>
        <CardFooter>
            <button>"Action"</button>
        </CardFooter>
    </Card>
}
```

### Content Only Card

```rust
view! {
    <Card>
        <CardContent class="p-6">
            <h3 class="text-lg font-semibold">"Simple Card"</h3>
            <p class="mt-2">"Just content, no header or footer."</p>
        </CardContent>
    </Card>
}
```

### Interactive Card

```rust
#[component]
pub fn ClickableCard() -> impl IntoView {
    let (clicked, set_clicked) = signal(false);

    view! {
        <Card
            interactive=Signal::derive(|| true)
            on:click=move |_| set_clicked.update(|n| *n = !n)
            class="cursor-pointer"
        >
            <CardHeader>
                <CardTitle>"Click Me!"</CardTitle>
            </CardHeader>
            <CardContent>
                <p>{move || if clicked.get() { "Clicked!" } else { "Not clicked" }}</p>
            </CardContent>
        </Card>
    }
}
```

### Variant Cards

```rust
view! {
    <div class="grid gap-4">
        <Card variant=CardVariant::Default>
            <CardHeader>
                <CardTitle>"Default"</CardTitle>
            </CardHeader>
        </Card>

        <Card variant=CardVariant::Success>
            <CardHeader>
                <CardTitle>"Success"</CardTitle>
                <CardDescription>"Operation completed"</CardDescription>
            </CardHeader>
        </Card>

        <Card variant=CardVariant::Warning>
            <CardHeader>
                <CardTitle>"Warning"</CardTitle>
                <CardDescription>"Please review this"</CardDescription>
            </CardHeader>
        </Card>

        <Card variant=CardVariant::Destructive>
            <CardHeader>
                <CardTitle>"Error"</CardTitle>
                <CardDescription>"Something went wrong"</CardDescription>
            </CardHeader>
        </Card>
    </div>
}
```

### Profile Card

```rust
#[component]
pub fn ProfileCard() -> impl IntoView {
    view! {
        <Card class="max-w-sm">
            <CardHeader>
                <div class="flex items-center space-x-4">
                    <div class="h-12 w-12 rounded-full bg-primary" />
                    <div>
                        <CardTitle class="text-lg">"John Doe"</CardTitle>
                        <CardDescription>"Software Engineer"</CardDescription>
                    </div>
                </div>
            </CardHeader>
            <CardContent>
                <p class="text-sm">
                    "Passionate about building great user experiences \
                    and writing clean, maintainable code."
                </p>
            </CardContent>
            <CardFooter>
                <div class="flex space-x-2">
                    <button class="text-sm">"View Profile"</button>
                    <button class="text-sm">"Contact"</button>
                </div>
            </CardFooter>
        </Card>
    }
}
```

### Stats Card

```rust
#[component]
pub fn StatsCard() -> impl IntoView {
    view! {
        <Card>
            <CardHeader>
                <CardDescription>"Total Revenue"</CardDescription>
                <CardTitle class="text-3xl">"$45,231.89"</CardTitle>
            </CardHeader>
            <CardContent>
                <div class="text-xs text-muted-foreground">
                    "+20.1% from last month"
                </div>
            </CardContent>
        </Card>
    }
}
```

### Custom Styled Card

```rust
view! {
    <Card
        class="bg-gradient-to-br from-purple-500 to-pink-500 text-white border-0"
    >
        <CardContent class="p-8">
            <h2 class="text-2xl font-bold">"Featured Content"</h2>
            <p class="mt-2 opacity-90">
                "Cards can be completely customized with your own styles"
            </p>
        </CardContent>
    </Card>
}
```

### Grid of Cards

```rust
view! {
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {(0..6).map(|i| {
            view! {
                <Card>
                    <CardHeader>
                        <CardTitle>{format!("Card {}", i + 1)}</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <p>"Content for card"</p>
                    </CardContent>
                </Card>
            }
        }).collect::<Vec<_>>()}
    </div>
}
```

---

## Accessibility

### Semantic Structure

Cards use semantic HTML elements:
- `<article>` for the card container
- `<h2>` (default) for the card title
- Proper heading hierarchy

### Keyboard Navigation

For interactive cards:

| Key | Action |
|-----|--------|
| **Tab** | Focus card (when interactive) |
| **Enter** | Activate card (when interactive) |
| **Space** | Activate card (when interactive) |

### ARIA Attributes

```rust
// Good: Descriptive card title
<Card>
    <CardHeader>
        <CardTitle>"User Profile Settings"</CardTitle>
    </CardHeader>
</Card>

// Good: Interactive cards indicate clickability
<Card
    interactive=Signal::derive(|| true)
    role="button"
    aria_label="View details"
>
```

---

## CSS Classes

### Card Classes

```css
.shadcn-card {
    rounded-lg border bg-card text-card-foreground shadow-sm
}
```

### Variant Classes

| Variant | CSS Classes |
|---------|-------------|
| `Default` | Base classes only |
| `Destructive` | `border-destructive bg-destructive/5` |
| `Warning` | `border-warning bg-warning/5` |
| `Success` | `border-success bg-success/5` |

### Interactive Classes

```css
.shadcn-card--interactive {
    cursor-pointer hover:shadow-md transition-shadow
}
```

### Subcomponent Classes

| Component | Base Classes |
|-----------|-------------|
| `CardHeader` | `flex flex-col space-y-1.5 p-6` |
| `CardTitle` | `text-2xl font-semibold leading-none tracking-tight` |
| `CardDescription` | `text-sm text-muted-foreground` |
| `CardContent` | `p-6 pt-0` |
| `CardFooter` | `flex items-center p-6 pt-0` |

---

## TypeScript API

```typescript
interface CardProps {
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  variant?: 'default' | 'destructive' | 'warning' | 'success';
  interactive?: boolean;
  children?: React.ReactNode;
}

interface CardHeaderProps {
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}

interface CardTitleProps {
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  level?: 1 | 2 | 3 | 4 | 5 | 6;
  children?: React.ReactNode;
}

interface CardDescriptionProps {
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}

interface CardContentProps {
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}

interface CardFooterProps {
  className?: string;
  id?: string;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}

export const Card: React.FC<CardProps>;
export const CardHeader: React.FC<CardHeaderProps>;
export const CardTitle: React.FC<CardTitleProps>;
export const CardDescription: React.FC<CardDescriptionProps>;
export const CardContent: React.FC<CardContentProps>;
export const CardFooter: React.FC<CardFooterProps>;
```

---

## Best Practices

1. **Use consistent hierarchy** - Header → Content → Footer
2. **Provide clear titles** - Summarize card content
3. **Use descriptions sparingly** - Add context when needed
4. **Keep content focused** - One topic per card
5. **Consider mobile layouts** - Stack cards on small screens

---

## See Also

- [Separator](./separator.md) - Visual dividers
- [Button](./button.md) - Card action buttons
- [Badge](./badge.md) - Status indicators

---

*Source: [packages/leptos/card/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/card/src/default.rs)*
