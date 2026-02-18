//! Component browser with favorites filtering
//! Provides an interactive interface to browse, search, and filter components by favorites

use leptos::*;
use leptos::prelude::*;
use lyx_ui_button::{Button, ButtonVariant, ButtonSize};
use lyx_ui_card::{Card, CardHeader, CardTitle, CardDescription, CardContent};
use lyx_ui_input::Input;

/// Component metadata for the browser
#[derive(Clone, Debug)]
pub struct ComponentMetadata {
pub id: String,
pub name: String,
pub category: String,
pub description: String,
pub status: ComponentStatus,
}

/// Component implementation status
#[derive(Clone, Copy, Debug, PartialEq)]
pub enum ComponentStatus {
Complete,
Partial,
Planned,
}

impl ComponentStatus {
pub fn as_str(&self) -> &'static str {
match self {
ComponentStatus::Complete => "Complete",
ComponentStatus::Partial => "Partial",
ComponentStatus::Planned => "Planned",
}
}

pub fn badge_class(&self) -> &'static str {
match self {
ComponentStatus::Complete => "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200",
ComponentStatus::Partial => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200",
ComponentStatus::Planned => "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200",
}
}
}

/// Get all components with metadata
fn get_all_components() -> Vec<ComponentMetadata> {
vec![
// Form & Input Components
ComponentMetadata {
id: "button".to_string(),
name: "Button".to_string(),
category: "Form & Input".to_string(),
description: "Displays a button with multiple variants and sizes".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "input".to_string(),
name: "Input".to_string(),
category: "Form & Input".to_string(),
description: "Form input field with various types".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "checkbox".to_string(),
name: "Checkbox".to_string(),
category: "Form & Input".to_string(),
description: "Toggle checkbox with indeterminate state".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "radio-group".to_string(),
name: "Radio Group".to_string(),
category: "Form & Input".to_string(),
description: "Radio button group for single selection".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "select".to_string(),
name: "Select".to_string(),
category: "Form & Input".to_string(),
description: "Dropdown selection component".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "combobox".to_string(),
name: "Combobox".to_string(),
category: "Form & Input".to_string(),
description: "Autocomplete input with suggestions".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "form".to_string(),
name: "Form".to_string(),
category: "Form & Input".to_string(),
description: "Form building blocks with validation".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "label".to_string(),
name: "Label".to_string(),
category: "Form & Input".to_string(),
description: "Accessible label for form controls".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "textarea".to_string(),
name: "Textarea".to_string(),
category: "Form & Input".to_string(),
description: "Multi-line text input".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "slider".to_string(),
name: "Slider".to_string(),
category: "Form & Input".to_string(),
description: "Range slider input".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "switch".to_string(),
name: "Switch".to_string(),
category: "Form & Input".to_string(),
description: "Toggle switch component".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "toggle".to_string(),
name: "Toggle".to_string(),
category: "Form & Input".to_string(),
description: "Two-state button".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "toggle-group".to_string(),
name: "Toggle Group".to_string(),
category: "Form & Input".to_string(),
description: "Set of two-state buttons".to_string(),
status: ComponentStatus::Complete,
},
// Navigation Components
ComponentMetadata {
id: "navigation-menu".to_string(),
name: "Navigation Menu".to_string(),
category: "Navigation".to_string(),
description: "Hierarchical menu with dropdowns".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "menubar".to_string(),
name: "Menubar".to_string(),
category: "Navigation".to_string(),
description: "Horizontal menu bar for desktop apps".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "tabs".to_string(),
name: "Tabs".to_string(),
category: "Navigation".to_string(),
description: "Tabbed content interface".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "breadcrumb".to_string(),
name: "Breadcrumb".to_string(),
category: "Navigation".to_string(),
description: "Navigation breadcrumb trail".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "pagination".to_string(),
name: "Pagination".to_string(),
category: "Navigation".to_string(),
description: "Page navigation controls".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "command".to_string(),
name: "Command".to_string(),
category: "Navigation".to_string(),
description: "Fast command menu palette".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "context-menu".to_string(),
name: "Context Menu".to_string(),
category: "Navigation".to_string(),
description: "Right-click context menu".to_string(),
status: ComponentStatus::Complete,
},
// Overlay Components
ComponentMetadata {
id: "dialog".to_string(),
name: "Dialog".to_string(),
category: "Overlay".to_string(),
description: "Modal dialog component".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "alert-dialog".to_string(),
name: "Alert Dialog".to_string(),
category: "Overlay".to_string(),
description: "Modal dialog for critical alerts".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "sheet".to_string(),
name: "Sheet".to_string(),
category: "Overlay".to_string(),
description: "Slide-in panel from edges".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "drawer".to_string(),
name: "Drawer".to_string(),
category: "Overlay".to_string(),
description: "Slide-out panel for mobile".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "dropdown-menu".to_string(),
name: "Dropdown Menu".to_string(),
category: "Overlay".to_string(),
description: "Contextual dropdown menu".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "popover".to_string(),
name: "Popover".to_string(),
category: "Overlay".to_string(),
description: "Positioned popup content".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "tooltip".to_string(),
name: "Tooltip".to_string(),
category: "Overlay".to_string(),
description: "Hover tooltip component".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "toast".to_string(),
name: "Toast".to_string(),
category: "Overlay".to_string(),
description: "Notification toast messages".to_string(),
status: ComponentStatus::Complete,
},
// Layout Components
ComponentMetadata {
id: "accordion".to_string(),
name: "Accordion".to_string(),
category: "Layout".to_string(),
description: "Collapsible content sections".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "collapsible".to_string(),
name: "Collapsible".to_string(),
category: "Layout".to_string(),
description: "Expandable content container".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "resizable".to_string(),
name: "Resizable".to_string(),
category: "Layout".to_string(),
description: "Resizable panel groups".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "scroll-area".to_string(),
name: "Scroll Area".to_string(),
category: "Layout".to_string(),
description: "Custom scrollable container".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "separator".to_string(),
name: "Separator".to_string(),
category: "Layout".to_string(),
description: "Visual content separator".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "sidebar".to_string(),
name: "Sidebar".to_string(),
category: "Layout".to_string(),
description: "Multi-level sidebar navigation".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "aspect-ratio".to_string(),
name: "Aspect Ratio".to_string(),
category: "Layout".to_string(),
description: "Maintains aspect ratio container".to_string(),
status: ComponentStatus::Complete,
},
// Display Components
ComponentMetadata {
id: "alert".to_string(),
name: "Alert".to_string(),
category: "Display".to_string(),
description: "Callout for user attention".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "avatar".to_string(),
name: "Avatar".to_string(),
category: "Display".to_string(),
description: "User image with fallback".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "badge".to_string(),
name: "Badge".to_string(),
category: "Display".to_string(),
description: "Status indicator and labels".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "card".to_string(),
name: "Card".to_string(),
category: "Display".to_string(),
description: "Container with header and footer".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "calendar".to_string(),
name: "Calendar".to_string(),
category: "Display".to_string(),
description: "Interactive calendar component".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "progress".to_string(),
name: "Progress".to_string(),
category: "Display".to_string(),
description: "Progress bar indicator".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "skeleton".to_string(),
name: "Skeleton".to_string(),
category: "Display".to_string(),
description: "Loading placeholder component".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "table".to_string(),
name: "Table".to_string(),
category: "Display".to_string(),
description: "Responsive data table".to_string(),
status: ComponentStatus::Complete,
},
// Advanced Components
ComponentMetadata {
id: "carousel".to_string(),
name: "Carousel".to_string(),
category: "Advanced".to_string(),
description: "Image/content carousel with swipe".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "date-picker".to_string(),
name: "Date Picker".to_string(),
category: "Advanced".to_string(),
description: "Date selection component".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "hover-card".to_string(),
name: "Hover Card".to_string(),
category: "Advanced".to_string(),
description: "Hover-triggered information card".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "input-otp".to_string(),
name: "Input OTP".to_string(),
category: "Advanced".to_string(),
description: "One-time password input".to_string(),
status: ComponentStatus::Complete,
},
ComponentMetadata {
id: "utils".to_string(),
name: "Utils".to_string(),
category: "Advanced".to_string(),
description: "Utility functions and helpers".to_string(),
status: ComponentStatus::Complete,
},
// Planned Components
ComponentMetadata {
id: "chart".to_string(),
name: "Chart".to_string(),
category: "Advanced".to_string(),
description: "Data visualization charts".to_string(),
status: ComponentStatus::Planned,
},
ComponentMetadata {
id: "data-table".to_string(),
name: "Data Table".to_string(),
category: "Advanced".to_string(),
description: "Advanced table with sorting/filtering".to_string(),
status: ComponentStatus::Planned,
},
ComponentMetadata {
id: "sonner".to_string(),
name: "Sonner".to_string(),
category: "Advanced".to_string(),
description: "Animated toast notifications".to_string(),
status: ComponentStatus::Planned,
},
ComponentMetadata {
id: "typography".to_string(),
name: "Typography".to_string(),
category: "Advanced".to_string(),
description: "Typography styles and components".to_string(),
status: ComponentStatus::Planned,
},
]
}

/// Get unique categories from components
fn get_categories(components: &[ComponentMetadata]) -> Vec<String> {
let mut categories: Vec<_> = components.iter().map(|c| c.category.clone()).collect();
categories.sort();
categories.dedup();
categories
}

/// LocalStorage key for favorites
const FAVORITES_KEY: &str = "component_favorites";

/// Load favorites from localStorage
fn load_favorites() -> Vec<String> {
// Try to get from window.localStorage
if let Some(window) = web_sys::window() {
if let Ok(Some(storage)) = window.local_storage() {
if let Ok(Some(favorites_str)) = storage.get(FAVORITES_KEY) {
if let Ok(favorites) = serde_json::from_str::<Vec<String>>(&favorites_str) {
return favorites;
}
}
}
}
Vec::new()
}

/// Save favorites to localStorage
fn save_favorites(favorites: &[String]) {
if let Some(window) = web_sys::window() {
if let Ok(Some(storage)) = window.local_storage() {
if let Ok(favorites_str) = serde_json::to_string(favorites) {
let _ = storage.set(FAVORITES_KEY, &favorites_str);
}
}
}
}

/// Main component browser with favorites filtering
#[component]
pub fn ComponentBrowser() -> impl IntoView {
let all_components = get_all_components();

// Load favorites from localStorage on init
let initial_favorites = load_favorites();
let (favorites, set_favorites) = signal(initial_favorites);

// Save favorites to localStorage whenever they change
let favorites_for_effect = favorites.clone();
create_effect(move |_| {
let favs = favorites_for_effect.get();
save_favorites(&favs);
});

// Filter state
let (search_value, set_search_value) = signal(String::new());
let (selected_category, set_selected_category) = signal::<Option<String>>(None);
let (show_favorites_only, set_show_favorites_only) = signal(false);

// Get categories for dropdown
let categories = get_categories(&all_components);

// Toggle favorite handler
let toggle_favorite = move |component_id: String| {
set_favorites.update(|favs| {
if favs.contains(&component_id) {
favs.retain(|id| id != &component_id);
} else {
favs.push(component_id);
}
});
};

// Compute filtered components
let filtered_components = move || {
let search = search_value.get().to_lowercase();
let category = selected_category.get();
let favorites_only = show_favorites_only.get();
let current_favorites = favorites.get();

all_components
.iter()
.filter(|component| {
// Search filter
let matches_search = search.is_empty()
|| component.name.to_lowercase().contains(&search)
|| component.description.to_lowercase().contains(&search)
|| component.category.to_lowercase().contains(&search);

// Category filter
let matches_category = category.as_ref().map_or(true, |cat| cat == &component.category);

// Favorites filter
let matches_favorites = !favorites_only || current_favorites.contains(&component.id);

matches_search && matches_category && matches_favorites
})
.cloned()
.collect::<Vec<_>>()
};

view! {
<div class="min-h-screen bg-background text-foreground">
<div class="container mx-auto px-4 py-8">
// Header
<div class="text-center mb-8">
<h1 class="text-4xl font-bold mb-4">"Component Browser"</h1>
<p class="text-lg text-muted-foreground">
"Browse and explore all Leptos ShadCN UI components. Mark your favorites for quick access."
</p>
</div>

// Filter bar
<Card class="mb-6">
<CardContent class="pt-6">
<div class="flex flex-col md:flex-row gap-4">
// Search input
<div class="flex-1">
<Input
placeholder="Search components..."
value=search_value
on_change=Callback::new(move |value| set_search_value.set(value))
class="w-full"
/>
</div>

// Category dropdown
<div class="md:w-64">
<select
class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
on:change=move |ev| {
let value = event_target_value(&ev);
set_selected_category.set(if value.is_empty() { None } else { Some(value) });
}
>
<option value="" selected=move || selected_category.get().is_none()>
"All Categories"
</option>
{categories.iter().map(|category| {
let cat = category.clone();
let is_selected = move || selected_category.get().as_ref() == Some(&cat);
view! {
<option value=cat.clone() selected=is_selected()>
{cat}
</option>
}
}).collect::<Vec<_>>()}
</select>
</div>

// Favorites toggle
<div class="flex items-center gap-2">
<Button
variant=move || if show_favorites_only.get() { ButtonVariant::Default } else { ButtonVariant::Outline }
size=ButtonSize::Default
on_click=move |_| set_show_favorites_only.update(|f| *f = !*f)
class="relative"
>
<span class="mr-2">"â˜…"</span>
"Favorites"
{move || {
let count = favorites.get().len();
if count > 0 {
view! {
<span class="ml-2 bg-primary-foreground text-primary text-xs px-2 py-0.5 rounded-full">
{count}
</span>
}
} else {
view! { <div></div> }
}
}}
</Button>
</div>
</div>
</CardContent>
</Card>

// Results count
<div class="mb-4 text-sm text-muted-foreground">
{move || {
let count = filtered_components().len();
let total = all_components.len();
format!("Showing {} of {} components", count, total)
}}
</div>

// Component grid
{move || {
let components = filtered_components();
if components.is_empty() {
view! {
<Card class="text-center py-12">
<CardContent>
<p class="text-muted-foreground text-lg">
"No components match your filters. Try adjusting your search or filters."
</p>
</CardContent>
</Card>
}
} else {
view! {
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
{components.into_iter().map(|component| {
let component_id = component.id.clone();
let component_name = component.name.clone();

// Check if this component is a favorite
let is_favorite = move || {
let favs = favorites.get();
favs.contains(&component_id)
};

// Create toggle handler for this specific component
let toggle_this_favorite = toggle_favorite.clone();
let component_id_for_toggle = component_id.clone();

view! {
<Card class="hover:shadow-md transition-shadow">
<CardHeader>
<div class="flex items-start justify-between">
<div class="flex-1">
<CardTitle class="text-lg">{component_name}</CardTitle>
<CardDescription class="mt-1">{component.description}</CardDescription>
</div>
<button
class="ml-2 text-2xl hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 rounded"
class:text-yellow-500=move || is_favorite()
class:text-gray-300=move || !is_favorite()
on:click=move |_| toggle_this_favorite(component_id_for_toggle.clone())
aria-label=format!("Toggle favorite for {}", component_name)
>
{move || if is_favorite() { "â˜…" } else { "â˜†" }}
</button>
</div>
</CardHeader>
<CardContent>
<div class="flex items-center justify-between">
<span class="text-sm text-muted-foreground">{component.category}</span>
<span class=format!("text-xs px-2 py-1 rounded-full {}", component.status.badge_class())>
{component.status.as_str()}
</span>
</div>
</CardContent>
</Card>
}
}).collect::<Vec<_>>()}
</div>
}
}
}}

// Footer
<div class="mt-12 text-center text-sm text-muted-foreground">
<p>
{move || {
let count = favorites.get().len();
format!("{} favorite{}", count, if count == 1 { "" } else { "s" })
}}
</p>
<p class="mt-2">
"Favorites are saved in your browser's local storage"
</p>
</div>
</div>
</div>
}
}
