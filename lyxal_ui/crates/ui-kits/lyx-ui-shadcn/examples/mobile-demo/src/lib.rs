// Mobile-First Design Examples for Leptos-lyx-ui-shadcn
// This file demonstrates mobile-first design patterns as documented in
// docs/design/mobile-guidelines.md

use leptos::prelude::*;
use lyx_ui_button::*;
use lyx_ui_card::*;
use lyx_ui_input::*;

/// Mobile-First Card Component Example
///
/// Demonstrates:
/// - Responsive grid layout (1 column mobile, 2 tablet, 3 desktop)
/// - Touch-friendly sizing (larger padding on mobile)
/// - Full-width buttons on mobile, auto width on desktop
#[component]
pub fn MobileCard(
    #[prop(into)] title: String,
    #[prop(into)] description: String,
    #[prop(into)] action_label: String,
) -> impl IntoView {
    view! {
        <div class="rounded-lg border bg-card p-4 sm:p-6 shadow-sm">
            <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                <div class="space-y-2 flex-1">
                    <h3 class="text-lg font-semibold leading-none tracking-tight">
                        {title}
                    </h3>
                    <p class="text-sm text-muted-foreground">
                        {description}
                    </p>
                </div>
                // Full width on mobile, auto on desktop
                // h-11 on mobile for better touch target (44px minimum)
                <button class="inline-flex items-center justify-center w-full sm:w-auto h-11 sm:h-10 rounded-md bg-primary px-8 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors focus-visible:outline-none focus-visible:ring-2">
                    {action_label}
                </button>
            </div>
        </div>
    }
}

/// Mobile-First Form Component Example
///
/// Demonstrates:
/// - Stacked labels on mobile, inline on desktop
/// - Larger input height on mobile (h-12 vs h-10) for touch
/// - Full-width inputs on mobile
/// - Stacked action buttons on mobile, side-by-side on desktop
#[component]
pub fn MobileFormExample() -> impl IntoView {
    view! {
        <form class="flex flex-col gap-6 px-4 py-6 sm:px-6 sm:py-8 lg:px-8 lg:py-12 max-w-2xl mx-auto">
            <div>
                <h2 class="text-2xl sm:text-3xl font-bold tracking-tight">
                    "Contact Form"
                </h2>
                <p class="text-muted-foreground mt-2">
                    "Send us a message and we'll get back to you."
                </p>
            </div>

            // Name field - label above on mobile, inline on desktop
            <div class="flex flex-col gap-2 sm:grid sm:grid-cols-[140px_1fr] sm:items-center sm:gap-4">
                <label for="name" class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 sm:text-right">
                    "Name"
                </label>
                <input
                    id="name"
                    type="text"
                    placeholder="Enter your name"
                    // h-12 on mobile for touch, h-10 on desktop
                    class="flex h-12 sm:h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                />
            </div>

            // Email field
            <div class="flex flex-col gap-2 sm:grid sm:grid-cols-[140px_1fr] sm:items-center sm:gap-4">
                <label for="email" class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 sm:text-right">
                    "Email"
                </label>
                <input
                    id="email"
                    type="email"
                    placeholder="Enter your email"
                    class="flex h-12 sm:h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                />
            </div>

            // Message field - full width always
            <div class="flex flex-col gap-2">
                <label for="message" class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                    "Message"
                </label>
                <textarea
                    id="message"
                    placeholder="Your message"
                    // Taller on mobile for easier typing
                    class="flex min-h-[120px] sm:min-h-[100px] w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 resize-none"
                ></textarea>
            </div>

            // Form actions - stacked on mobile, row on desktop
            <div class="flex flex-col gap-3 sm:flex-row sm:justify-end sm:pt-4">
                <button
                    type="button"
                    class="inline-flex items-center justify-center w-full sm:w-auto h-11 sm:h-10 rounded-md border border-input bg-background px-4 py-2 text-sm font-medium hover:bg-accent hover:text-accent-foreground transition-colors focus-visible:outline-none focus-visible:ring-2"
                >
                    "Cancel"
                </button>
                <button
                    type="submit"
                    class="inline-flex items-center justify-center w-full sm:w-auto h-11 sm:h-10 rounded-md bg-primary px-8 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors focus-visible:outline-none focus-visible:ring-2"
                >
                    "Submit"
                </button>
            </div>
        </form>
    }
}

/// Mobile-First Card Grid Example
///
/// Demonstrates:
/// - Responsive grid: 1 column mobile, 2 tablet, 3 desktop, 4 large desktop
/// - Consistent gap spacing
/// - Content truncation for longer text
#[component]
pub fn MobileCardGrid() -> impl IntoView {
    let cards = vec![
        ("Analytics", "View your site's analytics and performance metrics."),
        ("Settings", "Manage your account settings and preferences."),
        ("Projects", "View and manage all your active projects."),
        ("Team", "Invite and manage team members."),
        ("Documents", "Access and organize your documents."),
        ("Reports", "Generate and view detailed reports."),
    ];

    view! {
        <section class="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
            <h2 class="text-2xl sm:text-3xl font-bold tracking-tight mb-6">
                "Quick Actions"
            </h2>
            // Responsive grid: 1 -> 2 -> 3 -> 4 columns
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                {cards.into_iter().map(|(title, description)| {
                    view! {
                        <div class="rounded-lg border bg-card p-4 sm:p-6 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex flex-col gap-3">
                                <div class="h-10 w-10 rounded-md bg-primary/10 flex items-center justify-center">
                                    <span class="text-lg">"📊"</span>
                                </div>
                                <h3 class="font-semibold leading-none tracking-tight">
                                    {title}
                                </h3>
                                <p class="text-sm text-muted-foreground line-clamp-2 sm:line-clamp-3">
                                    {description}
                                </p>
                                // Full width on mobile, auto on desktop
                                <button class="inline-flex items-center justify-center w-full sm:w-auto h-10 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors mt-2">
                                    "Open"
                                </button>
                            </div>
                        </div>
                    }
                }).collect::<Vec<_>>()}
            </div>
        </section>
    }
}

/// Mobile-First Header Example
///
/// Demonstrates:
/// - Responsive header with mobile menu trigger
/// - Hamburger menu on mobile, full nav on desktop
/// - Sticky positioning
/// - Safe area handling for notched devices
#[component]
pub fn MobileHeader() -> impl IntoView {
    let mobile_menu_open = RwSignal::new(false);

    view! {
        <header class="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
            <div class="flex h-16 items-center justify-between px-4 sm:px-6">
                // Logo and brand
                <div class="flex items-center gap-2">
                    <div class="h-8 w-8 sm:h-9 sm:w-9 rounded-md bg-primary flex items-center justify-center">
                        <span class="text-primary-foreground font-bold text-sm">"L"</span>
                    </div>
                    <span class="font-bold text-lg sm:text-xl hidden xs:block">
                        "Leptos UI"
                    </span>
                </div>

                // Desktop navigation
                <nav class="hidden md:flex items-center gap-6">
                    <a href="#" class="text-sm font-medium hover:text-primary transition-colors">
                        "Home"
                    </a>
                    <a href="#" class="text-sm font-medium hover:text-primary transition-colors">
                        "Features"
                    </a>
                    <a href="#" class="text-sm font-medium hover:text-primary transition-colors">
                        "Pricing"
                    </a>
                    <a href="#" class="text-sm font-medium hover:text-primary transition-colors">
                        "About"
                    </a>
                </nav>

                // Actions (desktop) or menu trigger (mobile)
                <div class="flex items-center gap-2">
                    // Desktop buttons
                    <button class="hidden sm:inline-flex items-center justify-center h-10 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 transition-colors">
                        "Get Started"
                    </button>

                    // Mobile menu trigger
                    <button
                        class="sm:inline-flex md:hidden items-center justify-center h-10 w-10 rounded-md hover:bg-accent transition-colors"
                        on:click=move |_| mobile_menu_open.set(!mobile_menu_open.get())
                    >
                        <span class="sr-only">"Toggle menu"</span>
                        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>
                </div>
            </div>

            // Mobile menu (full screen on mobile)
            <div class=move || {
                if mobile_menu_open.get() {
                    "fixed inset-0 z-50 bg-background flex flex-col pt-20 px-4 pb-safe md:hidden"
                } else {
                    "hidden"
                }
            }>
                <nav class="flex flex-col gap-1">
                    <a href="#" class="flex items-center justify-between py-4 border-b text-lg font-medium">
                        "Home"
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </a>
                    <a href="#" class="flex items-center justify-between py-4 border-b text-lg font-medium">
                        "Features"
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </a>
                    <a href="#" class="flex items-center justify-between py-4 border-b text-lg font-medium">
                        "Pricing"
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </a>
                    <a href="#" class="flex items-center justify-between py-4 border-b text-lg font-medium">
                        "About"
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                        </svg>
                    </a>
                </nav>

                // Mobile CTA
                <div class="mt-auto pb-8">
                    <button class="inline-flex items-center justify-center w-full h-12 rounded-md bg-primary px-8 py-3 text-base font-medium text-primary-foreground hover:bg-primary/90 transition-colors">
                        "Get Started"
                    </button>
                </div>
            </div>
        </header>
    }
}

/// Mobile-First Button Examples
///
/// Demonstrates:
/// - Proper touch target sizes (minimum 44px)
/// - Full width on mobile for primary actions
/// - Button groups that stack on mobile
#[component]
pub fn MobileButtonExamples() -> impl IntoView {
    view! {
        <section class="w-full max-w-4xl mx-auto px-4 py-8 space-y-8">
            <div>
                <h2 class="text-2xl font-bold mb-4">"Button Sizing"</h2>
                <p class="text-muted-foreground mb-6">
                    "Buttons use h-11 (44px) on mobile for proper touch targets"
                </p>

                <div class="flex flex-wrap gap-4">
                    <button class="inline-flex items-center justify-center h-11 sm:h-10 px-4 py-2 rounded-md bg-primary text-primary-foreground text-sm font-medium hover:bg-primary/90">
                        "Default"
                    </button>
                    <button class="inline-flex items-center justify-center h-9 sm:h-8 px-3 py-2 rounded-md bg-primary text-primary-foreground text-sm font-medium hover:bg-primary/90">
                        "Small"
                    </button>
                    <button class="inline-flex items-center justify-center h-12 sm:h-11 px-8 py-3 rounded-md bg-primary text-primary-foreground text-base font-medium hover:bg-primary/90">
                        "Large"
                    </button>
                </div>
            </div>

            <div>
                <h2 class="text-2xl font-bold mb-4">"Full Width on Mobile"</h2>
                <p class="text-muted-foreground mb-6">
                    "Primary actions use full width on mobile, auto width on desktop"
                </p>

                <div class="flex flex-col sm:flex-row gap-3">
                    <button class="inline-flex items-center justify-center w-full sm:w-auto h-11 sm:h-10 px-8 py-2 rounded-md bg-primary text-primary-foreground text-sm font-medium hover:bg-primary/90">
                        "Primary Action"
                    </button>
                    <button class="inline-flex items-center justify-center w-full sm:w-auto h-11 sm:h-10 px-4 py-2 rounded-md border border-input bg-background text-sm font-medium hover:bg-accent">
                        "Secondary"
                    </button>
                </div>
            </div>

            <div>
                <h2 class="text-2xl font-bold mb-4">"Icon Buttons"</h2>
                <p class="text-muted-foreground mb-6">
                    "Icon buttons maintain minimum 44px touch target"
                </p>

                <div class="flex gap-2">
                    <button class="inline-flex items-center justify-center h-11 w-11 rounded-md hover:bg-accent transition-colors">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                        </svg>
                        <span class="sr-only">"Add"</span>
                    </button>
                    <button class="inline-flex items-center justify-center h-11 w-11 rounded-md hover:bg-accent transition-colors">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                        </svg>
                        <span class="sr-only">"Edit"</span>
                    </button>
                    <button class="inline-flex items-center justify-center h-11 w-11 rounded-md hover:bg-destructive/10 text-destructive transition-colors">
                        <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                        <span class="sr-only">"Delete"</span>
                    </button>
                </div>
            </div>
        </section>
    }
}

/// Mobile-First Stats Cards Example
///
/// Demonstrates:
/// - Responsive grid layout
/// - Proper spacing on mobile
/// - Text truncation for longer content
#[component]
pub fn MobileStatsCards() -> impl IntoView {
    let stats = vec![
        ("Total Revenue", "$45,231.89", "+20.1% from last month"),
        ("Subscriptions", "+2350", "+180.1% from last month"),
        ("Sales", "+12,234", "+19% from last month"),
        ("Active Now", "+573", "+201 since last hour"),
    ];

    view! {
        <section class="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <h2 class="text-2xl sm:text-3xl font-bold tracking-tight mb-6">
                "Dashboard"
            </h2>

            // Responsive grid: 1 -> 2 -> 4 columns
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {stats.into_iter().map(|(title, value, description)| {
                    view! {
                        <div class="rounded-xl border bg-card p-6 shadow-sm">
                            <div class="flex flex-row items-center justify-between space-y-0 pb-2">
                                <h3 class="text-sm font-medium tracking-tight">
                                    {title}
                                </h3>
                                <svg class="h-4 w-4 text-muted-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                                </svg>
                            </div>
                            <div class="text-2xl font-bold">
                                {value}
                            </div>
                            <p class="text-xs text-muted-foreground">
                                {description}
                            </p>
                        </div>
                    }
                }).collect::<Vec<_>>()}
            </div>
        </section>
    }
}

/// Complete mobile-first demo page
#[component]
pub fn MobileDemoPage() -> impl IntoView {
    view! {
        <div class="min-h-screen bg-background">
            <MobileHeader />

            <main class="pb-20 sm:pb-0">
                <section class="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
                    <h1 class="text-3xl sm:text-4xl lg:text-5xl font-bold tracking-tight mb-4">
                        "Mobile-First Design"
                    </h1>
                    <p class="text-lg text-muted-foreground max-w-2xl">
                        "This demo showcases mobile-first design patterns for Leptos-lyx-ui-shadcn components. Resize your browser or view on mobile to see the responsive behavior."
                    </p>
                </section>

                <MobileStatsCards />

                <section class="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 sm:py-12">
                    <h2 class="text-2xl sm:text-3xl font-bold tracking-tight mb-6">
                        "Quick Actions"
                    </h2>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                        <MobileCard
                            title="Analytics"
                            description="View detailed analytics and performance metrics for your applications."
                            action_label="View Analytics".to_string()
                        />
                        <MobileCard
                            title="Projects"
                            description="Manage and track all your active projects in one place."
                            action_label="Manage Projects".to_string()
                        />
                        <MobileCard
                            title="Settings"
                            description="Configure your application settings and preferences."
                            action_label="Open Settings".to_string()
                        />
                    </div>
                </section>

                <section class="w-full max-w-4xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
                    <MobileButtonExamples />
                </section>

                <section class="w-full max-w-4xl mx-auto px-4 sm:px-6 py-8 sm:py-12">
                    <MobileFormExample />
                </section>
            </main>

            // Mobile bottom navigation (only visible on mobile)
            <nav class="fixed bottom-0 left-0 right-0 z-50 h-16 border-t bg-background flex items-center justify-around pb-safe sm:hidden">
                <a href="#" class="flex flex-col items-center justify-center h-full w-full gap-1">
                    <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    <span class="text-xs font-medium">"Home"</span>
                </a>
                <a href="#" class="flex flex-col items-center justify-center h-full w-full gap-1">
                    <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                    </svg>
                    <span class="text-xs font-medium">"Analytics"</span>
                </a>
                <a href="#" class="flex flex-col items-center justify-center h-full w-full gap-1">
                    <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    <span class="text-xs font-medium">"Settings"</span>
                </a>
            </nav>
        </div>
    }
}

#[wasm_bindgen::prelude::wasm_bindgen]
pub fn hydrate() {
    console_error_panic_hook::set_once();
    leptos::mount::mount_to_body(MobileDemoPage);
}
