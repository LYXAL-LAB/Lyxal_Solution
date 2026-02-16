# Tutorial 2: Your First Interactive Component

**Video Length**: ~15 minutes | **Difficulty**: Beginner | **Series**: Getting Started

## Overview

Learn how to build your first interactive component using Leptos reactive signals and shadcn-ui building blocks. We'll create a counter component that demonstrates state management, event handling, and component composition.

## What You'll Learn

- Understanding reactive signals in Leptos
- Building components with state
- Handling user events
- Composing multiple shadcn-ui components
- Component props and children

## Prerequisites

- Completed [Tutorial 1: Installation](01-installation.md)
- Basic understanding of Rust ownership (helpful but not required)

## Video Outline

**[0:00]** Introduction to reactive programming
**[1:30]** Understanding signals in Leptos
**[3:00]** Creating a simple counter component
**[5:30]** Adding event handlers
**[7:00]** Styling with shadcn classes
**[9:00]** Composing multiple components
**[11:00]** Using Button variants
**[13:00]** Adding icons and labels
**[14:00]** Summary and next steps

## Step-by-Step Guide

### Understanding Reactive Signals

Leptos uses **signals** for reactive state management. A signal is a piece of state that automatically updates the UI when changed.

```rust
use leptos::*;

// Create a read-write signal
let (count, set_count) = create_signal(0);

// Read the signal
let current_value = count.get();

// Update the signal
set_count.update(|n| *n += 1);
```

### Creating Your Counter Component

Let's build an interactive counter:

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;
use lyx_ui_shadcn_card::Card;

#[component]
pub fn Counter() -> impl IntoView {
    // Create reactive state
    let (count, set_count) = create_signal(0);

    view! {
        <Card class="w-full max-w-md mx-auto p-6">
            <div class="text-center space-y-4">
                <h2 class="text-2xl font-bold">"Counter"</h2>

                // Display current count (reactive)
                <div class="text-6xl font-bold text-primary">
                    {count}
                </div>

                // Control buttons
                <div class="flex gap-2 justify-center">
                    <Button
                        variant="outline"
                        on_click=move |_| {
                            set_count.update(|n| *n -= 1);
                        }
                    >
                        "-"
                    </Button>

                    <Button
                        variant="default"
                        on_click=move |_| {
                            set_count.update(|n| *n += 1);
                        }
                    >
                        "+"
                    </Button>

                    <Button
                        variant="destructive"
                        on_click=move |_| {
                            set_count.set(0);
                        }
                    >
                        "Reset"
                    </Button>
                </div>

                // Show message based on count
                <div class="text-sm text-muted-foreground">
                    {move || {
                        if count.get() == 0 {
                            "Start counting!".to_string()
                        } else if count.get() < 10 {
                            "Keep going!".to_string()
                        } else if count.get() < 20 {
                            "Almost there!".to_string()
                        } else {
                            "You're a counting champion!".to_string()
                        }
                    }}
                </div>
            </div>
        </Card>
    }
}
```

### Adding Component Props

Make your component reusable with props:

```rust
#[component]
pub fn Counter(
    /// Initial count value
    #[prop(default = 0)]
    initial: i32,
    /// Step size for increment/decrement
    #[prop(default = 1)]
    step: i32,
    /// Show reset button
    #[prop(default = true)]
    show_reset: bool,
) -> impl IntoView {
    let (count, set_count) = create_signal(initial);

    view! {
        <Card class="w-full max-w-md mx-auto p-6">
            // ... component content
            <Button
                variant="outline"
                on_click=move |_| {
                    set_count.update(|n| *n -= step);
                }
            >
                "-"
            </Button>
            // ... rest of component
        </Card>
    }
}

// Usage
view! {
    <Counter initial=5 step=2 show_reset=true/>
}
```

### Composing Multiple Components

Build a stats dashboard with multiple counters:

```rust
#[component]
pub fn StatsDashboard() -> impl IntoView {
    let (total_clicks, set_total_clicks) = create_signal(0);
    let (streak, set_streak) = create_signal(0);

    view! {
        <div class="container mx-auto p-8 space-y-6">
            <h1 class="text-3xl font-bold">"Stats Dashboard"</h1>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Counter
                    initial=0
                    step=1
                    on_change=move |new_value| {
                        set_total_clicks.update(|n| *n += 1);
                        if new_value > 10 {
                            set_streak.update(|n| *n += 1);
                        }
                    }
                />

                <Counter
                    initial=10
                    step=5
                    show_reset=true
                />
            </div>

            <Card class="p-4">
                <div class="text-center">
                    <div class="text-4xl font-bold">{total_clicks}</div>
                    <div class="text-sm text-muted-foreground">"Total Actions"</div>
                </div>
            </Card>
        </div>
    }
}
```

### Using Derived Signals

Create computed values based on other signals:

```rust
#[component]
pub fn SmartCounter() -> impl IntoView {
    let (count, set_count) = create_signal(0);

    // Derived signal - automatically updates when count changes
    let is_even = move || count.get() % 2 == 0;
    let double_count = move || count.get() * 2;
    let count_status = move || {
        match count.get() {
            n if n < 0 => "Negative".to_string(),
            0 => "Zero".to_string(),
            n if n % 2 == 0 => format!("Even: {}", n),
            _ => format!("Odd: {}", n),
        }
    };

    view! {
        <Card class="p-6">
            <div class="space-y-4">
                <div class="text-4xl font-bold">{count}</div>
                <div class="text-sm text-muted-foreground">{count_status}</div>
                <div class="grid grid-cols-2 gap-4 text-sm">
                    <div>
                        <span class="font-semibold">"Double: "</span>
                        {double_count}
                    </div>
                    <div>
                        <span class="font-semibold">"Is Even: "</span>
                        {is_even}
                    </div>
                </div>
                <Button on_click=move |_| set_count.update(|n| *n += 1)>
                    "Increment"
                </Button>
            </div>
        </Card>
    }
}
```

## Complete Example: Interactive Counter App

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;
use lyx_ui_shadcn_card::Card;

#[component]
pub fn App() -> impl IntoView {
    view! {
        <div class="min-h-screen bg-background">
            <div class="container mx-auto p-8">
                <header class="mb-8">
                    <h1 class="text-4xl font-bold">"Interactive Counters"</h1>
                    <p class="text-muted-foreground">"Your first reactive components!"</p>
                </header>

                <main class="space-y-6">
                    // Simple counter
                    <Counter title="Simple Counter" initial=0/>

                    // Stepped counter
                    <Counter title="By Fives" initial=0 step=5/>

                    // Smart counter with derived state
                    <SmartCounter/>
                </main>
            </div>
        </div>
    }
}

#[component]
fn Counter(
    #[prop(default = "Counter".to_string())]
    title: String,
    #[prop(default = 0)]
    initial: i32,
    #[prop(default = 1)]
    step: i32,
) -> impl IntoView {
    let (count, set_count) = create_signal(initial);

    view! {
        <Card class="p-6">
            <h3 class="text-lg font-semibold mb-4">{title}</h3>
            <div class="text-center space-y-4">
                <div class="text-5xl font-bold">{count}</div>
                <div class="flex gap-2 justify-center">
                    <Button
                        variant="outline"
                        on_click=move |_| set_count.update(|n| *n -= step)
                    >
                        "-"
                    </Button>
                    <Button
                        variant="default"
                        on_click=move |_| set_count.update(|n| *n += step)
                    >
                        "+"
                    </Button>
                    <Button
                        variant="ghost"
                        on_click=move |_| set_count.set(initial)
                    >
                        "Reset"
                    </Button>
                </div>
            </div>
        </Card>
    }
}
```

## Key Concepts Summary

| Concept | Description | Example |
|---------|-------------|---------|
| **Signal** | Reactive state container | `create_signal(0)` |
| **Getter** | Function to read signal value | `count.get()` |
| **Setter** | Function to update signal | `set_count.set(5)` |
| **Updater** | Modify current value | `set_count.update(\|n\| *n += 1)` |
| **Derived Signal** | Computed from other signals | `move \|| count.get() * 2` |
| **Event Handler** | Closure responding to events | `on_click=move \|\| {...}` |

## Common Patterns

### Pattern 1: Toggle State
```rust
let (is_open, set_is_open) = create_signal(false);

view! {
    <Button on_click=move |_| set_is_open.update(|b| *b = !*b)>
        {move || if is_open.get() { "Close" } else { "Open" }}
    </Button>
}
```

### Pattern 2: State Reset
```rust
let initial_value = 10;
let (value, set_value) = create_signal(initial_value);

view! {
    <Button on_click=move |_| set_value.set(initial_value)>
        "Reset to Default"
    </Button>
}
```

### Pattern 3: Conditional Rendering
```rust
let (show_details, set_show_details) = create_signal(false);

view! {
    <div>
        <Button on_click=move |_| set_show_details.update(|b| *b = !*b)>
            "Toggle Details"
        </Button>
        {move || show_details.get().then(|| {
            view! { <div>"Hidden content!"</div> }
        })}
    </div>
}
```

## Exercise

1. Create a counter that counts down from 60 to 0
2. Add a "step" selector with buttons: 1, 5, 10
3. Display the counter in different formats: decimal, hexadecimal, binary
4. Add a visual indicator (color change) when count reaches certain thresholds

## What's Next?

- [Tutorial 3: Basic Form Patterns](03-basic-forms.md) - Build input forms
- [Component API Reference](../../components/README.md) - Explore all components
- [State Management Guide](../../architecture/state-management.md) - Deep dive on reactivity

---

**Previous**: [Installation](01-installation.md) | **Next**: [Basic Form Patterns](03-basic-forms.md)
