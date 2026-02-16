// Landscape Orientation Demo Component
//
// This component demonstrates landscape orientation support for tablets
// showcasing various responsive patterns that adapt to device orientation.

use leptos::*;

/// Orientation Demo Component
///
/// Demonstrates various landscape orientation patterns:
/// - Side-by-side layouts in landscape
/// - Navigation transformation
/// - Form layout adaptation
/// - Card grid reorganization
#[component]
pub fn OrientationDemo() -> impl IntoView {
    view! {
        <div class="w-full min-h-screen bg-background">
            // Header that adapts to orientation
            <header class="
                sticky top-0 z-40 w-full border-b bg-background
                px-4 py-3 sm:px-6
                landscape-md:px-8 landscape-md:py-4
            ">
                <div class="
                    flex items-center justify-between gap-4
                    portrait:flex-col portrait:items-start portrait:gap-2
                    landscape:flex-row landscape:items-center landscape:justify-between
                ">
                    <div>
                        <h1 class="text-xl font-bold landscape:text-2xl">
                            "Landscape Orientation Demo"
                        </h1>
                        <p class="text-sm text-muted-foreground">
                            "Rotate your device to see the layout adapt"
                        </p>
                    </div>
                    <div class="
                        flex gap-2
                        portrait:flex-row portrait:w-full
                        landscape:flex-row landscape:w-auto
                    ">
                        <button class="
                            inline-flex items-center justify-center
                            h-10 px-4 py-2
                            rounded-md bg-primary text-primary-foreground
                            text-sm font-medium
                            portrait:flex-1
                            landscape:w-auto
                        ">
                            "Primary Action"
                        </button>
                        <button class="
                            inline-flex items-center justify-center
                            h-10 px-4 py-2
                            rounded-md border border-input bg-background
                            text-sm font-medium
                            portrait:flex-1
                            landscape:w-auto
                        ">
                            "Secondary"
                        </button>
                    </div>
                </div>
            </header>

            // Main content area
            <main class="
                w-full max-w-7xl mx-auto
                px-4 py-6 sm:px-6 sm:py-8
                landscape-md:px-8 landscape-md:py-12
            ">
                // Orientation indicator
                <OrientationIndicator />

                // Demo sections
                <div class="flex flex-col gap-8 sm:gap-12">
                    // Section 1: Side-by-side content
                    <SideBySideSection />

                    // Section 2: Adaptive form
                    <AdaptiveFormSection />

                    // Section 3: Card grid
                    <CardGridSection />

                    // Section 4: Navigation patterns
                    <NavigationPatternsSection />

                    // Section 5: Media layout
                    <MediaLayoutSection />
                </div>
            </main>

            // Footer
            <footer class="
                w-full border-t bg-muted/50
                px-4 py-6 mt-12
                landscape-md:px-8 landscape-md:py-8
            ">
                <div class="
                    max-w-7xl mx-auto
                    text-center text-sm text-muted-foreground
                ">
                    <p class="portrait:text-base landscape:text-sm">
                        "This demo showcases landscape orientation support for tablets. "
                        "Try rotating your device to see how the layout adapts."
                    </p>
                </div>
            </footer>
        </div>
    }
}

/// Shows current device orientation
#[component]
fn OrientationIndicator() -> impl IntoView {
    let (is_landscape, set_is_landscape) = create_signal(false);

    // Check orientation on mount and window resize
    Effect::new(move |_| {
        if let Some(window) = web_sys::window() {
            let check_orientation = Closure::wrap(Box::new(move || {
                if let Ok(media_query) = window.match_media("(orientation: landscape)") {
                    set_is_landscape.set(media_query.matches());
                }
            }) as Box<dyn FnMut()>);

            // Initial check
            check_orientation.as_ref()();

            // Listen for resize events
            if let Ok(Some(listener)) = window
                .add_event_listener_with_callback("resize", check_orientation.as_ref().unchecked_ref())
            {
                // Store listener for cleanup (leaked for demo)
                let _ = listener.forget();
            }

            // Prevent closure from being dropped
            check_orientation.forget();
        }
    });

    view! {
        <div class="
            mb-6 p-4 rounded-lg border bg-muted/50
            flex items-center justify-between
            portrait:flex-col portrait:gap-2 portrait:text-center
            landscape:flex-row landscape:gap-4
        ">
            <div>
                <h2 class="text-lg font-semibold">
                    "Current Orientation"
                </h2>
                <p class="text-sm text-muted-foreground">
                    "Your device orientation affects the layout"
                </p>
            </div>
            <div class="
                px-4 py-2 rounded-md
                font-mico font-bold
                portrait:bg-primary/10 portrait:text-primary
                landscape:bg-accent landscape:text-accent-foreground
            ">
                {move || if is_landscape.get() { "🌅 Landscape" } else { "📱 Portrait" }}
            </div>
        </div>
    }
}

/// Demonstrates side-by-side content in landscape
#[component]
fn SideBySideSection() -> impl IntoView {
    view! {
        <section class="space-y-4">
            <h2 class="text-2xl font-bold">
                "Side-by-Side Content"
            </h2>
            <p class="text-muted-foreground">
                "Content stacks vertically in portrait, displays side-by-side in landscape."
            </p>

            <div class="
                rounded-lg border bg-card p-4
                flex flex-col gap-4
                portrait:flex-col
                landscape:flex-row landscape:gap-6 landscape:landscape-md:gap-8
            ">
                <div class="flex-1 space-y-2">
                    <h3 class="text-lg font-semibold">
                        "Left Panel"
                    </h3>
                    <p class="text-sm text-muted-foreground">
                        "This panel takes up full width in portrait mode, "
                        "but shares horizontal space in landscape mode."
                    </p>
                    <ul class="list-disc list-inside space-y-1 text-sm">
                        <li>"Portrait: Stacked vertically"</li>
                        <li>"Landscape: Side by side"</li>
                        <li>"Responsive gaps between panels"</li>
                    </ul>
                </div>

                <div class="
                    flex-1 space-y-2
                    portrait:border-t portrait:pt-4
                    landscape:border-l landscape:pl-6
                ">
                    <h3 class="text-lg font-semibold">
                        "Right Panel"
                    </h3>
                    <p class="text-sm text-muted-foreground">
                        "In landscape mode, both panels share the available width, "
                        "making better use of horizontal space."
                    </p>
                    <div class="
                        flex flex-wrap gap-2
                        portrait:flex-col
                        landscape:flex-row
                    ">
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full bg-primary/10 text-primary text-xs font-semibold">
                            "Tag 1"
                        </span>
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full bg-secondary text-secondary-foreground text-xs font-semibold">
                            "Tag 2"
                        </span>
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full bg-accent text-accent-foreground text-xs font-semibold">
                            "Tag 3"
                        </span>
                    </div>
                </div>
            </div>
        </section>
    }
}

/// Demonstrates adaptive form layout
#[component]
fn AdaptiveFormSection() -> impl IntoView {
    view! {
        <section class="space-y-4">
            <h2 class="text-2xl font-bold">
                "Adaptive Form Layout"
            </h2>
            <p class="text-muted-foreground">
                "Forms stack labels above inputs in portrait, use inline labels in landscape."
            </p>

            <form class="
                rounded-lg border bg-card p-4 sm:p-6
                space-y-4
                landscape:space-y-6
            " on:submit=|e| { e.prevent_default(); }>
                // Name field - stacked in portrait, inline in landscape
                <div class="
                    flex flex-col gap-2
                    portrait:flex-col portrait:gap-2
                    landscape:landscape-form-inline landscape:gap-4
                ">
                    <label class="
                        text-sm font-medium
                        portrait:text-left
                        landscape:text-right landscape:min-w-[120px]
                    ">
                        "Full Name"
                    </label>
                    <input
                        type="text"
                        placeholder="Enter your name"
                        class="
                            flex h-10 w-full rounded-md border px-3 py-2 text-sm
                            focus-visible:outline-none focus-visible:ring-2
                            portrait:w-full
                            landscape:flex-1
                        "
                    />
                </div>

                // Email field
                <div class="
                    flex flex-col gap-2
                    portrait:flex-col portrait:gap-2
                    landscape:landscape-form-inline landscape:gap-4
                ">
                    <label class="
                        text-sm font-medium
                        portrait:text-left
                        landscape:text-right landscape:min-w-[120px]
                    ">
                        "Email"
                    </label>
                    <input
                        type="email"
                        placeholder="your.email@example.com"
                        class="
                            flex h-10 w-full rounded-md border px-3 py-2 text-sm
                            focus-visible:outline-none focus-visible:ring-2
                            portrait:w-full
                            landscape:flex-1
                        "
                    />
                </div>

                // Message field
                <div class="
                    flex flex-col gap-2
                    portrait:flex-col
                    landscape:flex-row landscape:items-start landscape:gap-4
                ">
                    <label class="
                        text-sm font-medium
                        portrait:text-left
                        landscape:text-right landscape:min-w-[120px] landscape:pt-2
                    ">
                        "Message"
                    </label>
                    <textarea
                        placeholder="Type your message..."
                        rows="4"
                        class="
                            flex min-h-[120px] w-full rounded-md border px-3 py-2 text-sm resize-none
                            focus-visible:outline-none focus-visible:ring-2
                            portrait:w-full
                            landscape:flex-1
                        "
                    ></textarea>
                </div>

                // Form actions - stacked in portrait, inline in landscape
                <div class="
                    flex gap-3
                    portrait:flex-col
                    landscape:landscape-form-actions landscape:pt-2
                ">
                    <button
                        type="button"
                        class="
                            inline-flex items-center justify-center
                            h-10 px-4 py-2
                            rounded-md border bg-background
                            text-sm font-medium
                            portrait:w-full
                            landscape:w-auto
                        "
                    >
                        "Cancel"
                    </button>
                    <button
                        type="submit"
                        class="
                            inline-flex items-center justify-center
                            h-10 px-6 py-2
                            rounded-md bg-primary text-primary-foreground
                            text-sm font-medium
                            portrait:w-full
                            landscape:w-auto
                        "
                    >
                        "Submit"
                    </button>
                </div>
            </form>
        </section>
    }
}

/// Demonstrates adaptive card grid
#[component]
fn CardGridSection() -> impl IntoView {
    view! {
        <section class="space-y-4">
            <h2 class="text-2xl font-bold">
                "Adaptive Card Grid"
            </h2>
            <p class="text-muted-foreground">
                "Card grid adapts from single column in portrait to multiple columns in landscape."
            </p>

            <div class="
                grid gap-4
                grid-cols-1 portrait:grid-cols-1
                landscape:grid-cols-2
                landscape-md:grid-cols-3
            ">
                {(1..=6).map(|i| view! {
                    <CardComponent
                        title=format!("Card {}", i)
                        description=format!(
                            "This card adapts its layout based on orientation. \
                            In portrait, cards stack vertically. In landscape, \
                            they arrange in a grid."
                        )
                        index=i
                    />
                }).collect_view()}
            </div>
        </section>
    }
}

/// Individual card component
#[component]
fn CardComponent(title: String, description: String, index: usize) -> impl IntoView {
    let colors = vec![
        "bg-blue-100 text-blue-800",
        "bg-green-100 text-green-800",
        "bg-purple-100 text-purple-800",
        "bg-orange-100 text-orange-800",
        "bg-pink-100 text-pink-800",
        "bg-cyan-100 text-cyan-800",
    ];
    let color = colors[index % colors.len()];

    view! {
        <div class="
            rounded-lg border bg-card p-4 shadow-sm
            flex flex-col gap-3
            portrait:flex-col
            landscape:flex-row landscape:items-center
        ">
            <div class="
                rounded-md p-3
                portrait:w-full portrait:text-center
                landscape:w-16 landscape:h-16 landscape:flex-shrink-0 landscape:flex landscape:items-center landscape:justify-center
            ">
                <span class={format!("text-2xl {}", color)}>
                    {match index {
                        1 => "📱",
                        2 => "💻",
                        3 => "🎨",
                        4 => "🚀",
                        5 => "⚡",
                        _ => "✨",
                    }}
                </span>
            </div>
            <div class="flex-1 space-y-1">
                <h3 class="font-semibold text-sm">
                    {title}
                </h3>
                <p class="text-xs text-muted-foreground">
                    {description}
                </p>
            </div>
        </div>
    }
}

/// Demonstrates navigation patterns
#[component]
fn NavigationPatternsSection() -> impl IntoView {
    view! {
        <section class="space-y-4">
            <h2 class="text-2xl font-bold">
                "Navigation Patterns"
            </h2>
            <p class="text-muted-foreground">
                "Navigation adapts based on orientation - bottom nav in portrait, horizontal in landscape."
            </p>

            // Bottom nav (shown in portrait)
            <nav class="
                fixed bottom-0 left-0 right-0 z-50
                h-16 border-t bg-background
                flex items-center justify-around
                portrait:flex
                landscape:hidden
                pb-safe
            ">
                <NavItem icon="🏠" label="Home" active=true />
                <NavItem icon="📊" label="Dashboard" active=false />
                <NavItem icon="⚙️" label="Settings" active=false />
                <NavItem icon="👤" label="Profile" active=false />
            </nav>

            // Horizontal nav (shown in landscape)
            <nav class="
                hidden landscape:flex landscape:flex-row
                rounded-lg border bg-muted/50 p-2
                gap-2
            ">
                <NavItemHorizontal icon="🏠" label="Home" active=true />
                <NavItemHorizontal icon="📊" label="Dashboard" active=false />
                <NavItemHorizontal icon="⚙️" label="Settings" active=false />
                <NavItemHorizontal icon="👤" label="Profile" active=false />
            </nav>

            // Spacer for bottom nav in portrait
            <div class="h-16 landscape:hidden"></div>
        </section>
    }
}

/// Bottom nav item (portrait)
#[component]
fn NavItem(icon: &'static str, label: &'static str, active: bool) -> impl IntoView {
    let classes = if active {
        "flex flex-col items-center justify-center gap-1 text-primary"
    } else {
        "flex flex-col items-center justify-center gap-1 text-muted-foreground"
    };

    view! {
        <button class={classes}>
            <span class="text-xl">{icon}</span>
            <span class="text-xs font-medium">{label}</span>
        </button>
    }
}

/// Horizontal nav item (landscape)
#[component]
fn NavItemHorizontal(icon: &'static str, label: &'static str, active: bool) -> impl IntoView {
    let base_classes = "inline-flex items-center gap-2 px-4 py-2 rounded-md text-sm font-medium transition-colors";
    let active_classes = if active {
        "bg-background text-foreground shadow-sm"
    } else {
        "text-muted-foreground hover:bg-background/50"
    };

    view! {
        <button class={format!("{} {}", base_classes, active_classes)}>
            <span>{icon}</span>
            <span>{label}</span>
        </button>
    }
}

/// Demonstrates media layout in landscape
#[component]
fn MediaLayoutSection() -> impl IntoView {
    view! {
        <section class="space-y-4">
            <h2 class="text-2xl font-bold">
                "Media Layout"
            </h2>
            <p class="text-muted-foreground">
                "Media content takes full advantage of landscape orientation's wider aspect ratio."
            </p>

            <div class="
                rounded-lg border bg-card overflow-hidden
                portrait:flex-col
                landscape:flex landscape:landscape-card-horizontal
            ">
                // Media area
                <div class="
                    bg-gradient-to-br from-blue-500 to-purple-600
                    portrait:w-full portrait:h-48
                    landscape:w-64 landscape:h-48 landscape:min-w-[250px]
                    flex items-center justify-center
                ">
                    <div class="text-white text-center p-4">
                        <div class="text-4xl mb-2">🖼️</div>
                        <p class="text-sm font-medium">
                            portrait: 16:9
                            <br />
                            landscape: 4:3
                        </p>
                    </div>
                </div>

                // Content area
                <div class="p-4 landscape:p-6 flex-1">
                    <h3 class="text-lg font-semibold mb-2">
                        "Media in Landscape"
                    </h3>
                    <p class="text-sm text-muted-foreground mb-4">
                        "In landscape mode, media can be displayed alongside content, \
                        making better use of the available horizontal space. \
                        This is particularly useful for:"
                    </p>
                    <ul class="space-y-2 text-sm">
                        <li class="flex items-start gap-2">
                            <span class="text-primary">✓</span>
                            <span>"Video players and thumbnails"</span>
                        </li>
                        <li class="flex items-start gap-2">
                            <span class="text-primary">✓</span>
                            <span>"Image galleries and carousels"</span>
                        </li>
                        <li class="flex items-start gap-2">
                            <span class="text-primary">✓</span>
                            <span>"Product showcases"</span>
                        </li>
                        <li class="flex items-start gap-2">
                            <span class="text-primary">✓</span>
                            <span>"Article featured images"</span>
                        </li>
                    </ul>
                </div>
            </div>
        </section>
    }
}
