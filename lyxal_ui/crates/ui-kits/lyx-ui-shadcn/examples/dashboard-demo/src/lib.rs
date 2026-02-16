use leptos::prelude::*;
use leptos_meta::*;
use leptos_router::components::Router;

// Import all the ShadCN components we'll need
use lyx_ui_button::*;
use lyx_ui_card::*;
use lyx_ui_input::*;
use lyx_ui_badge::*;
use lyx_ui_avatar::*;
use lyx_ui_dropdown_menu::*;
use lyx_ui_separator::*;
use lyx_ui_progress::*;
use lyx_ui_tabs::*;
use lyx_ui_dialog::*;
use lyx_ui_sheet::*;
use lyx_ui_scroll_area::*;
use lyx_ui_collapsible::*;
use lyx_ui_command::*;
use lyx_ui_popover::*;
use lyx_ui_select::*;
use lyx_ui_switch::*;
use lyx_ui_toast::*;
use lyx_ui_tooltip::*;

#[component]
pub fn App() -> impl IntoView {
    provide_meta_context();

    view! {
        <Html />
        <Title text="Leptos ShadCN Dashboard Demo" />
        <Meta charset="utf-8" />
        <Meta name="viewport" content="width=device-width, initial-scale=1" />
        <Link rel="stylesheet" href="https://cdn.tailwindcss.com" />
        
        <Router>
            <DashboardLayout />
        </Router>
    }
}

#[component]
pub fn DashboardLayout() -> impl IntoView {
    let sidebar_open = RwSignal::new(false); // Closed by default on mobile
    let theme = RwSignal::new("light".to_string());

    view! {
        <div class="min-h-screen bg-background">
            <div class="flex flex-col md:flex-row">
                // Mobile overlay when sidebar is open
                <div class=move || {
                    if sidebar_open.get() {
                        "fixed inset-0 z-40 bg-black/50 md:hidden"
                    } else {
                        "hidden"
                    }
                }
                on:click=move |_| sidebar_open.set(false)
                ></div>

                // Sidebar - fixed mobile, relative desktop
                <div class=move || {
                    let base_classes = if sidebar_open.get() {
                        "fixed inset-y-0 left-0 z-50 w-64 bg-card border-r border-border transition-transform duration-300 md:relative md:translate-x-0"
                    } else {
                        "fixed inset-y-0 left-0 z-50 w-64 bg-card border-r border-border transition-transform duration-300 -translate-x-full md:relative md:translate-x-0"
                    };
                    base_classes
                }>
                    <Sidebar close_sidebar=move || sidebar_open.set(false) />
                </div>

                // Main content
                <div class="flex-1 flex flex-col min-w-0">
                    // Header
                    <Header sidebar_open=sidebar_open theme=theme />

                    // Dashboard content - responsive padding
                    <main class="flex-1 p-4 sm:p-6 lg:p-8">
                        <DashboardContent />
                    </main>
                </div>
            </div>
        </div>
    }
}

#[component]
pub fn Sidebar(close_sidebar: impl Fn() + 'static) -> impl IntoView {
    view! {
        <div class="flex flex-col h-full p-4 sm:p-6">
            <div class="flex items-center gap-2 mb-6 sm:mb-8">
                <div class="h-10 w-10 sm:h-8 sm:w-8 bg-primary rounded-md flex items-center justify-center flex-shrink-0">
                    <span class="text-primary-foreground font-bold text-sm sm:text-base">L</span>
                </div>
                <div class="min-w-0">
                    <h1 class="text-base sm:text-lg font-semibold truncate">Leptos Dashboard</h1>
                    <p class="text-xs sm:text-sm text-muted-foreground truncate">Rust/WASM Demo</p>
                </div>
            </div>

            <nav class="flex-1 space-y-1 sm:space-y-2 overflow-y-auto">
                <NavItem icon="🏠" label="Dashboard" active=true />
                <NavItem icon="📊" label="Analytics" active=false />
                <NavItem icon="📁" label="Projects" active=false />
                <NavItem icon="👥" label="Team" active=false />
                <NavItem icon="📄" label="Documents" active=false />
                <NavItem icon="⚙️" label="Settings" active=false />
            </nav>

            // Close button on mobile only
            <button
                class="md:hidden mt-4 w-full inline-flex items-center justify-center h-11 rounded-md border border-input bg-background px-4 text-sm font-medium hover:bg-accent"
                on:click=move |_| close_sidebar()
            >
                "Close Menu"
            </button>
        </div>
    }
}

#[component]
pub fn NavItem(
    #[prop(into)] icon: String,
    #[prop(into)] label: String,
    #[prop(into)] active: bool,
) -> impl IntoView {
    view! {
        <a
            href="#"
            class=move || {
                if active {
                    // Larger touch target on mobile (h-11), normal on desktop (h-10)
                    "flex items-center gap-3 px-3 py-2.5 sm:py-2 rounded-md bg-accent text-accent-foreground min-h-[44px] sm:min-h-0"
                } else {
                    "flex items-center gap-3 px-3 py-2.5 sm:py-2 rounded-md hover:bg-accent hover:text-accent-foreground transition-colors min-h-[44px] sm:min-h-0"
                }
            }
        >
            <span class="text-lg sm:text-base">{icon}</span>
            <span class="font-medium text-sm sm:text-base">{label}</span>
        </a>
    }
}

#[component]
pub fn Header(
    sidebar_open: RwSignal<bool>,
    theme: RwSignal<String>,
) -> impl IntoView {
    view! {
        <header class="sticky top-0 z-30 w-full border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
            <div class="flex h-16 items-center justify-between px-4 sm:px-6">
                <div class="flex items-center gap-3 sm:gap-4">
                    // Menu button - larger touch target on mobile
                    <button
                        class="inline-flex items-center justify-center h-11 w-11 sm:h-10 sm:w-10 rounded-md hover:bg-accent transition-colors"
                        on:click=move |_| sidebar_open.set(!sidebar_open.get())
                    >
                        <span class="sr-only">"Toggle sidebar"</span>
                        <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>

                    <div class="flex items-center gap-2 min-w-0">
                        <h2 class="text-lg sm:text-xl font-semibold truncate">"Dashboard"</h2>
                        <Badge variant=BadgeVariant::Secondary>"Rust/WASM"</Badge>
                    </div>
                </div>

                <div class="flex items-center gap-2 sm:gap-4">
                    <button
                        class="inline-flex items-center justify-center h-11 w-11 sm:h-10 sm:w-10 rounded-md hover:bg-accent transition-colors"
                        on:click=move |_| theme.set(if theme.get() == "light" { "dark".to_string() } else { "light".to_string() })
                    >
                        <span class="sr-only">"Toggle theme"</span>
                        <svg class="h-5 w-5 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
                        </svg>
                    </button>

                    <button class="inline-flex items-center justify-center h-11 w-11 sm:h-10 sm:w-10 rounded-md hover:bg-accent transition-colors">
                        <Avatar>
                            <AvatarImage src="https://github.com/shadcn.png" />
                            <AvatarFallback>"CN"</AvatarFallback>
                        </Avatar>
                    </button>
                </div>
            </div>
        </header>
    }
}

#[component]
pub fn DashboardContent() -> impl IntoView {
    view! {
        <div class="space-y-6 sm:space-y-8">
            // Welcome section - stack on mobile
            <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                <div class="min-w-0">
                    <h1 class="text-2xl sm:text-3xl font-bold tracking-tight">"Welcome back!"</h1>
                    <p class="text-sm sm:text-base text-muted-foreground">"Here's what's happening with your projects today."</p>
                </div>
                // Full width on mobile, auto on desktop
                <button class="inline-flex items-center justify-center w-full sm:w-auto h-11 sm:h-10 rounded-md bg-primary px-4 sm:px-8 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90">
                    <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    "New Project"
                </button>
            </div>

            // Stats cards - responsive grid
            <div class="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
                <StatCard 
                    title="Total Revenue" 
                    value="$1,250.00" 
                    change="+12.5%" 
                    change_type="positive"
                    description="Trending up this month"
                />
                <StatCard 
                    title="New Customers" 
                    value="1,234" 
                    change="-20%" 
                    change_type="negative"
                    description="Down 20% this period"
                />
                <StatCard 
                    title="Active Accounts" 
                    value="45,678" 
                    change="+12.5%" 
                    change_type="positive"
                    description="Strong user retention"
                />
                <StatCard 
                    title="Growth Rate" 
                    value="4.5%" 
                    change="+4.5%" 
                    change_type="positive"
                    description="Steady performance increase"
                />
            </div>
            
            // Charts and tables section
            <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-7">
                <div class="col-span-4">
                    <Card>
                        <CardHeader>
                            <CardTitle>"Visitors for the last 6 months"</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div class="h-[300px] flex items-center justify-center bg-muted/50 rounded-md">
                                <div class="text-center">
                                    <div class="text-4xl mb-2">"📊"</div>
                                    <p class="text-muted-foreground">"Chart would go here"</p>
                                    <p class="text-sm text-muted-foreground">"Built with Rust/WASM"</p>
                                </div>
                            </div>
                        </CardContent>
                    </Card>
                </div>
                
                <div class="col-span-3">
                    <Card>
                        <CardHeader>
                            <CardTitle>"Recent Activity"</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div class="space-y-4">
                                <ActivityItem 
                                    user="Eddie Lake" 
                                    action="completed" 
                                    item="Cover page" 
                                    time="2 hours ago"
                                />
                                <ActivityItem 
                                    user="Jamik Tashpulatov" 
                                    action="updated" 
                                    item="Technical approach" 
                                    time="4 hours ago"
                                />
                                <ActivityItem 
                                    user="Sarah Wilson" 
                                    action="created" 
                                    item="New project" 
                                    time="6 hours ago"
                                />
                            </div>
                        </CardContent>
                    </Card>
                </div>
            </div>
            
            // Data table - horizontally scrollable on mobile
            <Card>
                <CardHeader class="px-4 sm:px-6">
                    <CardTitle class="text-lg sm:text-xl">"Project Documents"</CardTitle>
                    <CardDescription class="text-sm sm:text-base">"Manage your project documents and track progress"</CardDescription>
                </CardHeader>
                <CardContent class="px-4 sm:px-6">
                    <div class="rounded-md border">
                        // Horizontal scroll wrapper for mobile
                        <div class="-mx-4 overflow-x-auto px-4 sm:mx-0 sm:overflow-visible sm:px-0">
                            <table class="w-full min-w-[600px]">
                                <thead class="bg-muted/50">
                                    <tr>
                                        <th class="px-4 py-3 text-left text-xs sm:text-sm font-medium">"Document"</th>
                                        <th class="px-4 py-3 text-left text-xs sm:text-sm font-medium">"Type"</th>
                                        <th class="px-4 py-3 text-left text-xs sm:text-sm font-medium">"Status"</th>
                                        <th class="px-4 py-3 text-left text-xs sm:text-sm font-medium">"Assignee"</th>
                                        <th class="px-4 py-3 text-left text-xs sm:text-sm font-medium">"Actions"</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-border">
                                    <tr>
                                        <td class="px-4 py-3 text-sm font-medium">"Cover page"</td>
                                        <td class="px-4 py-3 text-sm">"Cover page"</td>
                                        <td class="px-4 py-3">
                                            <Badge variant=BadgeVariant::Secondary>"In Process"</Badge>
                                        </td>
                                        <td class="px-4 py-3 text-sm">"Eddie Lake"</td>
                                        <td class="px-4 py-3">
                                            <button class="inline-flex items-center justify-center h-9 px-3 rounded-md hover:bg-accent text-sm">
                                                "Open menu"
                                            </button>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="px-4 py-3 text-sm font-medium">"Table of contents"</td>
                                        <td class="px-4 py-3 text-sm">"Table of contents"</td>
                                        <td class="px-4 py-3">
                                            <Badge variant=BadgeVariant::Default>"Done"</Badge>
                                        </td>
                                        <td class="px-4 py-3 text-sm">"Eddie Lake"</td>
                                        <td class="px-4 py-3">
                                            <button class="inline-flex items-center justify-center h-9 px-3 rounded-md hover:bg-accent text-sm">
                                                "Open menu"
                                            </button>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="px-4 py-3 text-sm font-medium">"Executive summary"</td>
                                        <td class="px-4 py-3 text-sm">"Narrative"</td>
                                        <td class="px-4 py-3">
                                            <Badge variant=BadgeVariant::Default>"Done"</Badge>
                                        </td>
                                        <td class="px-4 py-3 text-sm">"Eddie Lake"</td>
                                        <td class="px-4 py-3">
                                            <button class="inline-flex items-center justify-center h-9 px-3 rounded-md hover:bg-accent text-sm">
                                                "Open menu"
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    }
}

#[component]
pub fn StatCard(
    #[prop(into)] title: String,
    #[prop(into)] value: String,
    #[prop(into)] change: String,
    #[prop(into)] change_type: String,
    #[prop(into)] description: String,
) -> impl IntoView {
    view! {
        <Card>
            <CardHeader class="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle class="text-sm font-medium">{title}</CardTitle>
                <svg class="h-4 w-4 text-muted-foreground" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                </svg>
            </CardHeader>
            <CardContent>
                <div class="text-2xl font-bold">{value}</div>
                <p class=move || {
                    if change_type == "positive" {
                        "text-xs text-green-600"
                    } else {
                        "text-xs text-red-600"
                    }
                }>
                    {change}
                </p>
                <p class="text-xs text-muted-foreground">{description}</p>
            </CardContent>
        </Card>
    }
}

#[component]
pub fn ActivityItem(
    #[prop(into)] user: String,
    #[prop(into)] action: String,
    #[prop(into)] item: String,
    #[prop(into)] time: String,
) -> impl IntoView {
    let user_initials = user.chars().take(2).collect::<String>();
    let user_display = user.clone();
    
    view! {
        <div class="flex items-center space-x-4">
            <Avatar class="h-8 w-8">
                <AvatarImage src="https://github.com/shadcn.png" />
                <AvatarFallback>{user_initials}</AvatarFallback>
            </Avatar>
            <div class="flex-1 space-y-1">
                <p class="text-sm font-medium leading-none">
                    {user_display} " " {action} " " {item}
                </p>
                <p class="text-xs text-muted-foreground">{time}</p>
            </div>
        </div>
    }
}

#[wasm_bindgen::prelude::wasm_bindgen]
pub fn hydrate() {
    console_error_panic_hook::set_once();
    leptos::mount::mount_to_body(App);
}
