//! Enhanced lazy loading component with realistic simulation and favorites
//!
//! This example demonstrates code-splitting with Leptos's `#[lazy]` macro.
//! Each component below is compiled into a separate WASM chunk that is loaded
//! on-demand when first accessed. You can verify this by:
//! 1. Building the example with `cargo leptos build --split`
//! 2. Checking the browser's Network tab when clicking "Load" buttons
//! 3. Observing separate `.wasm` chunk files being loaded on-demand

use leptos::*;
use leptos::prelude::*;
use leptos::task::spawn_local;
use lyx_ui_lazy_loading::{
lazy_button_component, lazy_card_component, lazy_input_component,
lazy_alert_component, lazy_form_component,
};

/// Component metadata for enhanced lazy loading
#[derive(Clone)]
struct ComponentInfo {
name: String,
category: String,
estimated_size: String,
dependencies: Vec<String>,
description: String,
}

/// Lazy code-split component wrapper
/// This component demonstrates code-splitting using Leptos's #[lazy] macro
/// Each component is loaded from a separate WASM chunk on-demand
#[component]
pub fn LazyCodeSplitComponent(
#[prop(into)] name: String,
component_type: String,
) -> impl IntoView {
let (is_loaded, set_is_loaded) = signal(false);
let (is_loading, set_is_loading) = signal(false);
let (load_progress, set_load_progress) = signal(0.0);
let (component_view, set_component_view) = signal(None::<View<()>>);
let (error, set_error) = signal(None::<String>);

// Clone values for use in closures
let component_type_clone = component_type.clone();
let name_clone = name.clone();

let load_component = move |_| {
let component_type = component_type_clone.clone();
let name = name_clone.clone();
let set_is_loading = set_is_loading.clone();
let set_is_loaded = set_is_loaded.clone();
let set_component_view = set_component_view.clone();
let set_error = set_error.clone();
let set_load_progress = set_load_progress.clone();
let (is_mounted, set_is_mounted) = signal(true);

set_is_loading.set(true);
set_load_progress.set(0.0);

// Track if component is still mounted for interval cleanup
let is_mounted_interval = is_mounted.clone();
let set_is_loading_interval = set_is_loading.clone();
let set_is_loaded_interval = set_is_loaded.clone();
let set_load_progress_interval = set_load_progress.clone();

// Simulate loading progress
let progress_interval = set_interval_with_handle(
move || {
if is_mounted_interval.get() {
set_load_progress_interval.update(|p| {
if *p < 100.0 {
*p += 10.0;
}
});
}
},
std::time::Duration::from_millis(50),
).unwrap();

// Spawn async task to load the lazy component
spawn_local(async move {
// Load the appropriate lazy component based on type
let result = match component_type.as_str() {
"button" => lazy_button_component().await,
"card" => lazy_card_component().await,
"input" => lazy_input_component().await,
"alert" => lazy_alert_component().await,
"form" => lazy_form_component().await,
_ => Err(format!("Unknown component type: {}", component_type)),
};

// Clear the progress interval
let _ = progress_interval.clear();

// Only update if component is still mounted
if is_mounted.get() {
set_is_loading.set(false);
set_load_progress.set(100.0);

match result {
Ok(view) => {
set_component_view.set(Some(view));
set_is_loaded.set(true);
}
Err(err) => {
set_error.set(Some(err));
}
}
}
});

// Set up cleanup for interval when component unmounts
let progress_interval_for_cleanup = progress_interval;
on_cleanup(move || {
set_is_mounted.set(false);
progress_interval_for_cleanup.clear();
});
};

view! {
<div class="lazy-code-split-component">
<div class="component-header">
<h4>{name_clone}</h4>
<span class="component-type-badge">{component_type_clone}</span>
</div>

<div class="component-content">
<div class="lazy-component-loaded" class:hidden={move || !is_loaded.get()}>
<div class="component-success">
<div class="success-icon">"âœ…"</div>
<p class="success-text">
"Code-split component loaded from separate WASM chunk!"
</p>
<div class="component-demo">
{move || component_view.get()}
</div>
<div class="chunk-info">
<p class="chunk-text">
"Check browser Network tab to see the chunk file that was loaded"
</p>
</div>
</div>
</div>

<div class="component-loading" class:hidden={move || !is_loading.get()}>
<div class="loading-content">
<div class="loading-spinner"></div>
<p>"Loading {name_clone} from WASM chunk..."</p>
<div class="progress-bar">
<div class="progress-fill" style={move || format!("width: {}%", load_progress.get())}></div>
</div>
<span class="progress-text">{move || format!("{}%", load_progress.get() as i32)}</span>
</div>
</div>

<div class="component-error" class:hidden={move || error.get().is_none()}>
<div class="error-content">
<div class="error-icon">"âŒ"</div>
<p class="error-text">
{move || error.get().unwrap_or_else(|| "Unknown error".to_string())}
</p>
</div>
</div>

<div class="component-placeholder" class:hidden={move || is_loaded.get() || is_loading.get()}>
<div class="placeholder-content">
<p class="placeholder-text">
"This component will be loaded from a separate WASM chunk on-demand."
</p>
<div class="placeholder-info">
<p>"Click the button below to trigger code-splitting"</p>
<ul class="chunk-list">
<li>"Separate .wasm chunk file"</li>
<li>"Loaded only when needed"</li>
<li>"Reduces initial bundle size"</li>
</ul>
</div>
<button on:click={load_component} class="load-btn">
"Load {name_clone}"
</button>
</div>
</div>
</div>
</div>
}
}

/// Component metadata for enhanced lazy loading
#[derive(Clone)]
struct ComponentInfo {
name: String,
category: String,
estimated_size: String,
dependencies: Vec<String>,
description: String,
}

/// Enhanced lazy component wrapper with realistic simulation and favorites
#[component]
pub fn LazyComponentWrapper(
#[prop(into)] name: String,
) -> impl IntoView {
let (is_loaded, set_is_loaded) = signal(false);
let (is_loading, set_is_loading) = signal(false);
let (load_progress, set_load_progress) = signal(0.0);
let (is_favorite, set_is_favorite) = signal(false);

// Clone name for use in closures
let name_clone = name.clone();

// Component metadata based on name
let component_info = move || {
match name_clone.as_str() {
"Alert" => ComponentInfo {
name: "Alert".to_string(),
category: "Form & Input".to_string(),
estimated_size: "12KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Displays important messages to users".to_string(),
},
"Badge" => ComponentInfo {
name: "Badge".to_string(),
category: "Form & Input".to_string(),
estimated_size: "8KB".to_string(),
dependencies: vec![],
description: "Small status indicators and labels".to_string(),
},
"Checkbox" => ComponentInfo {
name: "Checkbox".to_string(),
category: "Form & Input".to_string(),
estimated_size: "15KB".to_string(),
dependencies: vec![],
description: "Interactive checkbox input component".to_string(),
},
"Combobox" => ComponentInfo {
name: "Combobox".to_string(),
category: "Form & Input".to_string(),
estimated_size: "25KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Searchable dropdown with custom options".to_string(),
},
"Form" => ComponentInfo {
name: "Form".to_string(),
category: "Form & Input".to_string(),
estimated_size: "35KB".to_string(),
dependencies: vec!["leptos-hook-form".to_string()],
description: "Complete form handling with validation".to_string(),
},
"Input OTP" => ComponentInfo {
name: "Input OTP".to_string(),
category: "Form & Input".to_string(),
estimated_size: "18KB".to_string(),
dependencies: vec![],
description: "One-time password input fields".to_string(),
},
"Radio Group" => ComponentInfo {
name: "Radio Group".to_string(),
category: "Form & Input".to_string(),
estimated_size: "20KB".to_string(),
dependencies: vec![],
description: "Radio button group selection".to_string(),
},
"Select" => ComponentInfo {
name: "Select".to_string(),
category: "Form & Input".to_string(),
estimated_size: "22KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Dropdown selection component".to_string(),
},
"Slider" => ComponentInfo {
name: "Slider".to_string(),
category: "Form & Input".to_string(),
estimated_size: "16KB".to_string(),
dependencies: vec![],
description: "Range slider input component".to_string(),
},
"Switch" => ComponentInfo {
name: "Switch".to_string(),
category: "Form & Input".to_string(),
estimated_size: "14KB".to_string(),
dependencies: vec![],
description: "Toggle switch component".to_string(),
},
"Textarea" => ComponentInfo {
name: "Textarea".to_string(),
category: "Form & Input".to_string(),
estimated_size: "10KB".to_string(),
dependencies: vec![],
description: "Multi-line text input".to_string(),
},
"Toggle" => ComponentInfo {
name: "Toggle".to_string(),
category: "Form & Input".to_string(),
estimated_size: "12KB".to_string(),
dependencies: vec![],
description: "Button toggle component".to_string(),
},
"Accordion" => ComponentInfo {
name: "Accordion".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "28KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Collapsible content sections".to_string(),
},
"Breadcrumb" => ComponentInfo {
name: "Breadcrumb".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "18KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Navigation breadcrumb trail".to_string(),
},
"Collapsible" => ComponentInfo {
name: "Collapsible".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "20KB".to_string(),
dependencies: vec![],
description: "Expandable content container".to_string(),
},
"Command" => ComponentInfo {
name: "Command".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "32KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Command palette interface".to_string(),
},
"Navigation Menu" => ComponentInfo {
name: "Navigation Menu".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "40KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Complex navigation menu system".to_string(),
},
"Pagination" => ComponentInfo {
name: "Pagination".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "25KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Page navigation controls".to_string(),
},
"Scroll Area" => ComponentInfo {
name: "Scroll Area".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "15KB".to_string(),
dependencies: vec![],
description: "Custom scrollable container".to_string(),
},
"Skeleton" => ComponentInfo {
name: "Skeleton".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "12KB".to_string(),
dependencies: vec![],
description: "Loading placeholder components".to_string(),
},
"Tabs" => ComponentInfo {
name: "Tabs".to_string(),
category: "Layout & Navigation".to_string(),
estimated_size: "30KB".to_string(),
dependencies: vec![],
description: "Tabbed content interface".to_string(),
},
"Alert Dialog" => ComponentInfo {
name: "Alert Dialog".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "35KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Modal dialog with actions".to_string(),
},
"Dialog" => ComponentInfo {
name: "Dialog".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "30KB".to_string(),
dependencies: vec![],
description: "Modal dialog component".to_string(),
},
"Drawer" => ComponentInfo {
name: "Drawer".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "38KB".to_string(),
dependencies: vec![],
description: "Slide-out drawer panel".to_string(),
},
"Dropdown Menu" => ComponentInfo {
name: "Dropdown Menu".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "28KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Contextual dropdown menu".to_string(),
},
"Hover Card" => ComponentInfo {
name: "Hover Card".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "22KB".to_string(),
dependencies: vec![],
description: "Hover-triggered information card".to_string(),
},
"Menubar" => ComponentInfo {
name: "Menubar".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "45KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Horizontal menu bar".to_string(),
},
"Popover" => ComponentInfo {
name: "Popover".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "20KB".to_string(),
dependencies: vec![],
description: "Positioned popup content".to_string(),
},
"Sheet" => ComponentInfo {
name: "Sheet".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "32KB".to_string(),
dependencies: vec![],
description: "Slide-up sheet panel".to_string(),
},
"Toast" => ComponentInfo {
name: "Toast".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "25KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Notification toast messages".to_string(),
},
"Tooltip" => ComponentInfo {
name: "Tooltip".to_string(),
category: "Overlay & Feedback".to_string(),
estimated_size: "18KB".to_string(),
dependencies: vec![],
description: "Hover tooltip component".to_string(),
},
"Aspect Ratio" => ComponentInfo {
name: "Aspect Ratio".to_string(),
category: "Data & Media".to_string(),
estimated_size: "8KB".to_string(),
dependencies: vec![],
description: "Maintains aspect ratio container".to_string(),
},
"Calendar" => ComponentInfo {
name: "Calendar".to_string(),
category: "Data & Media".to_string(),
estimated_size: "50KB".to_string(),
dependencies: vec!["chrono".to_string()],
description: "Interactive calendar component".to_string(),
},
"Carousel" => ComponentInfo {
name: "Carousel".to_string(),
category: "Data & Media".to_string(),
estimated_size: "35KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Image/content carousel".to_string(),
},
"Context Menu" => ComponentInfo {
name: "Context Menu".to_string(),
category: "Data & Media".to_string(),
estimated_size: "30KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Right-click context menu".to_string(),
},
"Date Picker" => ComponentInfo {
name: "Date Picker".to_string(),
category: "Data & Media".to_string(),
estimated_size: "45KB".to_string(),
dependencies: vec!["chrono".to_string()],
description: "Date selection component".to_string(),
},
"Progress" => ComponentInfo {
name: "Progress".to_string(),
category: "Data & Media".to_string(),
estimated_size: "12KB".to_string(),
dependencies: vec![],
description: "Progress bar component".to_string(),
},
"Table" => ComponentInfo {
name: "Table".to_string(),
category: "Data & Media".to_string(),
estimated_size: "40KB".to_string(),
dependencies: vec!["inline-svg".to_string()],
description: "Data table with sorting".to_string(),
},
_ => ComponentInfo {
name: name_clone.clone(),
category: "Unknown".to_string(),
estimated_size: "20KB".to_string(),
dependencies: vec![],
description: "Component description not available".to_string(),
},
}
};

let load_component = move |_| {
set_is_loading.set(true);
set_load_progress.set(0.0);

// Track if component is still mounted for interval cleanup
let (is_mounted, set_is_mounted) = signal(true);
let set_is_loading_interval = set_is_loading.clone();
let set_is_loaded_interval = set_is_loaded.clone();
let set_load_progress_interval = set_load_progress.clone();
let is_mounted_interval = is_mounted.clone();

// Simulate loading progress
let progress_interval = set_interval_with_handle(
move || {
// Only update if component is still mounted
if is_mounted_interval.get() {
set_load_progress_interval.update(|p| {
if *p < 100.0 {
*p += 10.0;
} else {
set_is_loading_interval.set(false);
set_is_loaded_interval.set(true);
}
});
}
},
std::time::Duration::from_millis(100),
).unwrap();

// Set up cleanup for interval when component unmounts
let progress_interval_for_cleanup = progress_interval.clone();
on_cleanup(move || {
set_is_mounted.set(false);
progress_interval_for_cleanup.clear();
});
};

let toggle_favorite = move |_| {
set_is_favorite.update(|f| *f = !*f);
};

view! {
<div class="lazy-component-wrapper" class:favorite={is_favorite}>
<div class="component-header">
<div class="component-title-section">
<h4>{name.clone()}</h4>
<button
on:click={toggle_favorite}
class="favorite-toggle"
class:active={move || is_favorite.get()}
>
{move || if is_favorite.get() { "â˜…" } else { "â˜†" }}
</button>
</div>
<div class="component-meta">
<span class="component-category">{component_info().category}</span>
<span class="component-size">{component_info().estimated_size}</span>
</div>
</div>

<div class="component-content">
<div class="lazy-component-loaded" class:hidden={move || !is_loaded.get()}>
<div class="component-success">
<div class="success-icon">"âœ…"</div>
<p class="success-text">"Component loaded successfully!"</p>
<div class="component-demo">
<span>"ðŸŽ‰ {name} is now available"</span>
</div>
<div class="component-details">
<p class="component-description">{component_info().description}</p>
<div class="component-dependencies">
<strong>"Dependencies:"</strong>
{if component_info().dependencies.is_empty() {
"None".to_string()
} else {
component_info().dependencies.join(", ")
}}
</div>
</div>
</div>
</div>

<div class="component-loading" class:hidden={move || !is_loading.get()}>
<div class="loading-content">
<div class="loading-spinner"></div>
<p>"Loading {name}..."</p>
<div class="progress-bar">
<div class="progress-fill" style={move || format!("width: {}%", load_progress.get())}></div>
</div>
<span class="progress-text">{move || format!("{}%", load_progress.get() as i32)}</span>
</div>
</div>

<div class="component-placeholder" class:hidden={move || is_loaded.get() || is_loading.get()}>
<div class="placeholder-content">
<p class="placeholder-text">"This component is not yet loaded. Click to load it on demand."</p>
<div class="component-preview">
<p class="preview-description">{component_info().description}</p>
<div class="preview-meta">
<span class="preview-size">"Size: {component_info().estimated_size}"</span>
<span class="preview-category">"Category: {component_info().category}"</span>
</div>
</div>
<button on:click={load_component} class="load-btn">
"Load {name}"
</button>
</div>
</div>
</div>
</div>
}
}

/// Simple lazy loading provider with code-splitting demonstration
#[component]
pub fn LazyLoadingProvider(
#[prop(into)] children: Children,
) -> impl IntoView {
view! {
<div class="lazy-loading-provider">
// Code-Splitting Demo Section
<div class="code-splitting-demo">
<div class="demo-header">
<h2>"Code-Splitting Demo"</h2>
<p class="demo-description">
"This section demonstrates component-level code splitting using Leptos's #[lazy] macro. "
"Each component below is compiled into a separate WASM chunk that is loaded on-demand."
</p>
<div class="demo-instructions">
<h3>"How to Verify Code Splitting:"</h3>
<ol>
<li>"Open your browser's Developer Tools (F12)"</li>
<li>"Go to the Network tab"</li>
<li>"Filter by '.wasm' files"</li>
<li>"Click the 'Load' button on any component below"</li>
<li>"Observe a new .wasm chunk file being loaded"</li>
</ol>
</div>
</div>

<div class="demo-components">
<div class="demo-section">
<h3>"Code-Split Components"</h3>
<div class="component-grid">
<LazyCodeSplitComponent
name="Button Component"
component_type="button".to_string()
/>
<LazyCodeSplitComponent
name="Card Component"
component_type="card".to_string()
/>
<LazyCodeSplitComponent
name="Input Component"
component_type="input".to_string()
/>
<LazyCodeSplitComponent
name="Alert Component"
component_type="alert".to_string()
/>
<LazyCodeSplitComponent
name="Form Component"
component_type="form".to_string()
/>
</div>
</div>
</div>
</div>

// Original children
{children()}
</div>
}
}
