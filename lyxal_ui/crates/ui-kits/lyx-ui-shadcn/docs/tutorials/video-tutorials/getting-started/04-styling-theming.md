# Tutorial 4: Styling & Theming

**Video Length**: ~18 minutes | **Difficulty**: Beginner | **Series**: Getting Started

## Overview

Learn how to customize the appearance of shadcn-ui components to match your brand. This tutorial covers CSS variables, theme variants, dark mode, and creating custom component styles.

## What You'll Learn

- Understanding the CSS variable system
- Customizing colors and spacing
- Implementing dark mode
- Creating custom themes
- Using component variants
- Responsive design patterns

## Prerequisites

- Completed [Tutorial 3: Basic Form Patterns](03-basic-forms.md)
- Basic understanding of CSS

## Video Outline

**[0:00]** Introduction to theming
**[1:45]** CSS variable system overview
**[4:00]** Customizing colors
**[7:00]** Dark mode implementation
**[9:30]** Custom theme creation
**[12:00]** Component variants
**[14:30]** Responsive design
**[16:00]** Best practices and tips
**[17:00]** Summary and next steps

## Step-by-Step Guide

### Understanding the CSS Variable System

shadcn-ui uses CSS custom properties (variables) for theming. This allows for:

1. **Runtime theme switching** without page reload
2. **Type-safe theming** through CSS variables
3. **Per-component theming** using scoped variables
4. **Dark mode support** through class-based switching

The base variable structure:

```css
:root {
  /* Base colors */
  --background: 0 0% 100%;           /* HSL values */
  --foreground: 222.2 84% 4.9%;

  /* Component colors */
  --card: 0 0% 100%;
  --card-foreground: 222.2 84% 4.9%;
  --primary: 222.2 47.4% 11.2%;
  --primary-foreground: 210 40% 98%;

  /* Semantic colors */
  --muted: 210 40% 96.1%;
  --muted-foreground: 215.4 16.3% 46.9%;
  --accent: 210 40% 96.1%;
  --destructive: 0 84.2% 60.2%;

  /* Borders and inputs */
  --border: 214.3 31.8% 91.4%;
  --input: 214.3 31.8% 91.4%;
  --ring: 222.2 84% 4.9%;

  /* Layout */
  --radius: 0.5rem;
}
```

### Creating a Custom Theme

Create a `brand-theme.css` file:

```css
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

@layer base {
  :root {
    /* Custom brand colors (purple theme) */
    --background: 0 0% 100%;
    --foreground: 270 15% 10%;

    --card: 0 0% 100%;
    --card-foreground: 270 15% 10%;

    --popover: 0 0% 100%;
    --popover-foreground: 270 15% 10%;

    /* Primary - Purple */
    --primary: 270 91% 65%;
    --primary-foreground: 0 0% 100%;

    /* Secondary - Pink */
    --secondary: 330 81% 70%;
    --secondary-foreground: 0 0% 100%;

    /* Muted tones */
    --muted: 270 20% 96%;
    --muted-foreground: 270 10% 40%;

    /* Accent */
    --accent: 270 20% 96%;
    --accent-foreground: 270 15% 10%;

    /* Destructive */
    --destructive: 0 84% 60%;
    --destructive-foreground: 0 0% 100%;

    /* Borders */
    --border: 270 20% 90%;
    --input: 270 20% 90%;
    --ring: 270 91% 65%;

    /* Radius */
    --radius: 0.75rem;
  }

  .dark {
    --background: 270 20% 8%;
    --foreground: 0 0% 100%;

    --card: 270 20% 10%;
    --card-foreground: 0 0% 100%;

    --popover: 270 20% 10%;
    --popover-foreground: 0 0% 100%;

    --primary: 270 91% 65%;
    --primary-foreground: 270 15% 10%;

    --secondary: 330 81% 70%;
    --secondary-foreground: 270 15% 10%;

    --muted: 270 20% 20%;
    --muted-foreground: 270 10% 60%;

    --accent: 270 20% 20%;
    --accent-foreground: 0 0% 100%;

    --destructive: 0 62% 30%;
    --destructive-foreground: 0 0% 100%;

    --border: 270 20% 20%;
    --input: 270 20% 20%;
    --ring: 270 91% 65%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
    font-feature-settings: "rlig" 1, "calt" 1;
  }
}
```

### Implementing Dark Mode

Add dark mode toggle to your app:

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;

#[component]
pub fn ThemeToggle() -> impl IntoView {
    let (is_dark, set_is_dark) = create_signal(false);

    // Toggle dark mode class on body
    let toggle_theme = move |_| {
        set_is_dark.update(|dark| *dark = !*dark);
        if is_dark.get() {
            leptos_dom::document()
                .body()
                .class_list()
                .remove_1("dark")
                .unwrap();
        } else {
            leptos_dom::document()
                .body()
                .class_list()
                .add_1("dark")
                .unwrap();
        }
    };

    // Check system preference on mount
    leptos::create_effect(move |_| {
        let prefers_dark = window()
            .match_media("(prefers-color-scheme: dark)")
            .unwrap()
            .unwrap()
            .matches();

        if prefers_dark {
            set_is_dark.set(true);
            leptos_dom::document()
                .body()
                .class_list()
                .add_1("dark")
                .unwrap();
        }
    });

    view! {
        <Button
            variant="ghost"
            size="icon"
            on_click=toggle_theme
            aria_label="Toggle theme"
        >
            {move || {
                if is_dark.get() {
                    "🌙" // Moon icon
                } else {
                    "☀️" // Sun icon
                }
            }}
        </Button>
    }
}
```

### Using Component Variants

Many components support variant props:

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;

#[component]
pub fn ButtonVariants() -> impl IntoView {
    view! {
        <div class="flex flex-wrap gap-4">
            // Default button
            <Button variant="default">
                "Default"
            </Button>

            // Secondary button
            <Button variant="secondary">
                "Secondary"
            </Button>

            // Destructive button
            <Button variant="destructive">
                "Delete"
            </Button>

            // Outline button
            <Button variant="outline">
                "Outline"
            </Button>

            // Ghost button
            <Button variant="ghost">
                "Ghost"
            </Button>

            // Link button
            <Button variant="link">
                "Learn More"
            </Button>
        </div>

        // Button sizes
        <div class="flex flex-wrap gap-4 items-center">
            <Button size="sm">"Small"</Button>
            <Button size="default">"Default"</Button>
            <Button size="lg">"Large"</Button>
            <Button size="icon">"🔍"</Button>
        </div>
    }
}
```

### Creating Custom Card Styles

Customize cards with inline styles and variants:

```rust
use leptos::*;
use lyx_ui_shadcn_card::Card;
use lyx_ui_shadcn_button::Button;

#[component]
pub fn CustomCard() -> impl IntoView {
    view! {
        // Gradient card
        <Card class="relative overflow-hidden bg-gradient-to-br from-purple-500 to-pink-500 text-white border-0">
            <div class="relative z-10 p-6">
                <h3 class="text-2xl font-bold mb-2">"Featured"</h3>
                <p class="opacity-90 mb-4">
                    "This card uses a gradient background with custom styling."
                </p>
                <Button variant="secondary" size="sm">
                    "Learn More"
                </Button>
            </div>
        </Card>

        // Glass morphism card
        <Card class="backdrop-blur-sm bg-white/10 border-white/20 shadow-xl">
            <div class="p-6">
                <h3 class="text-lg font-semibold mb-2">"Glass Effect"</h3>
                <p class="text-sm text-muted-foreground">
                    "Frosted glass effect with transparency"
                </p>
            </div>
        </Card>

        // Bordered card with accent
        <Card class="border-l-4 border-l-purple-500 shadow-md hover:shadow-lg transition-shadow">
            <div class="p-6">
                <h3 class="text-lg font-semibold mb-2">"Accent Border"</h3>
                <p class="text-sm text-muted-foreground">
                    "Card with left accent border"
                </p>
            </div>
        </Card>
    }
}
```

### Responsive Design Patterns

Use Tailwind's responsive utilities:

```rust
#[component]
pub fn ResponsiveLayout() -> impl IntoView {
    view! {
        // Container that adjusts padding
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
            // Grid that adjusts columns
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                {move || {
                    (0..8).map(|i| {
                        view! {
                            <Card class="p-4">
                                <h3 class="font-semibold">"Item "{i}</h3>
                            </Card>
                        }
                    }).collect_view()
                }}
            </div>

            // Stack that changes direction
            <div class="flex flex-col md:flex-row gap-4 items-start">
                <div class="flex-1">"Sidebar content"</div>
                <div class="flex-[2]">"Main content"</div>
            </div>

            // Text that adjusts size
            <h1 class="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold">
                "Responsive Heading"
            </h1>
        </div>
    }
}
```

### Theme Switcher Component

Create a component to switch between multiple themes:

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;

#[derive(Clone, Copy, PartialEq)]
pub enum Theme {
    Light,
    Dark,
    Blue,
    Purple,
    Green,
}

impl Theme {
    pub fn name(&self) -> &'static str {
        match self {
            Theme::Light => "Light",
            Theme::Dark => "Dark",
            Theme::Blue => "Ocean",
            Theme::Purple => "Grape",
            Theme::Green => "Forest",
        }
    }

    pub fn class(&self) -> &'static str {
        match self {
            Theme::Light => "",
            Theme::Dark => "dark",
            Theme::Blue => "theme-blue",
            Theme::Purple => "theme-purple",
            Theme::Green => "theme-green",
        }
    }
}

#[component]
pub fn ThemeSwitcher() -> impl IntoView {
    let (current_theme, set_current_theme) = create_signal(Theme::Light);

    let apply_theme = move |theme: Theme| {
        // Remove all theme classes
        let body = leptos_dom::document().body();
        body.class_list()
            .remove_1("dark").ok();
        body.class_list()
            .remove_1("theme-blue").ok();
        body.class_list()
            .remove_1("theme-purple").ok();
        body.class_list()
            .remove_1("theme-green").ok();

        // Add new theme class
        if !theme.class().is_empty() {
            body.class_list().add_1(theme.class()).ok();
        }

        set_current_theme.set(theme);
    };

    view! {
        <div class="space-y-4">
            <h3 class="text-lg font-semibold">"Theme"</h3>
            <div class="flex flex-wrap gap-2">
                {move || {
                    [Theme::Light, Theme::Dark, Theme::Blue, Theme::Purple, Theme::Green]
                        .into_iter()
                        .map(|theme| {
                            let is_active = current_theme.get() == theme;
                            view! {
                                <Button
                                    variant=if is_active { "default" } else { "outline" }
                                    size="sm"
                                    on_click=move |_| apply_theme(theme)
                                >
                                    {theme.name()}
                                </Button>
                            }
                        })
                        .collect_view()
                }}
            </div>
        </div>
    }
}
```

Supporting CSS for custom themes:

```css
/* Ocean theme */
.theme-blue {
    --primary: 210 100% 50%;
    --primary-foreground: 0 0% 100%;
}

/* Grape theme */
.theme-purple {
    --primary: 270 91% 65%;
    --primary-foreground: 0 0% 100%;
}

/* Forest theme */
.theme-green {
    --primary: 140 60% 40%;
    --primary-foreground: 0 0% 100%;
}
```

### Animated Theme Transitions

Add smooth transitions when switching themes:

```css
* {
    transition-property: color, background-color, border-color;
    transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
    transition-duration: 150ms;
}
```

## Styling Best Practices

### 1. Use Utility Classes First
```rust
// Good
<div class="flex items-center gap-4 p-4 bg-white rounded-lg shadow">

// Avoid
<div style="display: flex; align-items: center; padding: 1rem;">
```

### 2. Create Reusable Component Classes
```rust
// Define a common card variant
const CARD_VARIANT: &str = "rounded-lg border bg-card text-card-foreground shadow-sm";

view! {
    <div class={CARD_VARIANT}>
        // Content
    </div>
}
```

### 3. Use Semantic Color Variables
```rust
// Good - uses semantic variable
<div class="bg-primary text-primary-foreground">

// Avoid - hardcoded colors
<div class="bg-blue-500 text-white">
```

### 4. Maintain Spacing Consistency
```rust
// Use consistent spacing scale
<div class="p-4">    // 1rem
<div class="p-6">    // 1.5rem
<div class="p-8">    // 2rem

// Avoid arbitrary values
<div class="p-[13px]">
```

## Complete Example: Themed Dashboard

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;
use lyx_ui_shadcn_card::Card;

#[component]
pub fn ThemedDashboard() -> impl IntoView {
    let (is_dark, set_is_dark) = create_signal(false);

    view! {
        <div class="min-h-screen bg-background text-foreground transition-colors">
            // Header with theme toggle
            <header class="border-b bg-card">
                <div class="container mx-auto px-4 py-4 flex justify-between items-center">
                    <h1 class="text-2xl font-bold">"Dashboard"</h1>
                    <ThemeToggle/>
                </div>
            </header>

            // Main content
            <main class="container mx-auto px-4 py-8">
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    // Stats cards
                    <Card class="p-6 bg-gradient-to-br from-primary/10 to-primary/5">
                        <div class="text-sm text-muted-foreground">"Total Users"</div>
                        <div class="text-3xl font-bold mt-2">"2,543"</div>
                        <div class="text-sm text-green-600 mt-2">"+12.5%"</div>
                    </Card>

                    <Card class="p-6 bg-gradient-to-br from-blue-500/10 to-blue-500/5">
                        <div class="text-sm text-muted-foreground">"Revenue"</div>
                        <div class="text-3xl font-bold mt-2">"$45,231"</div>
                        <div class="text-sm text-green-600 mt-2">"+8.2%"</div>
                    </Card>

                    <Card class="p-6 bg-gradient-to-br from-purple-500/10 to-purple-500/5">
                        <div class="text-sm text-muted-foreground">"Active Sessions"</div>
                        <div class="text-3xl font-bold mt-2">"1,234"</div>
                        <div class="text-sm text-red-600 mt-2">"-3.1%"</div>
                    </Card>
                </div>

                // Content section
                <Card class="mt-6 p-6">
                    <h2 class="text-xl font-semibold mb-4">"Recent Activity"</h2>
                    <div class="space-y-4">
                        {(0..5).map(|i| {
                            view! {
                                <div class="flex items-center justify-between py-3 border-b last:border-0">
                                    <div>
                                        <div class="font-medium">"Activity "{i}</div>
                                        <div class="text-sm text-muted-foreground">
                                            "Description of activity"
                                        </div>
                                    </div>
                                    <div class="text-sm text-muted-foreground">
                                        "2 hours ago"
                                    </div>
                                </div>
                            }
                        }).collect_view()}
                    </div>
                </Card>
            </main>
        </div>
    }
}
```

## Exercise

1. Create a custom theme with your brand colors
2. Implement a theme switcher with at least 3 themes
3. Add smooth transitions for theme changes
4. Create a responsive card layout
5. Add hover effects to your components

## What's Next?

- [Component Series: Form Components](../components/01-form-components.md) - Deep dive into form components
- [Theming Reference](../../components/theming.md) - Complete theming guide
- [Dark Mode Guide](../../architecture/dark-mode.md) - Advanced dark mode patterns

---

**Previous**: [Basic Form Patterns](03-basic-forms.md) | **Next**: [Form Components](../components/01-form-components.md)
