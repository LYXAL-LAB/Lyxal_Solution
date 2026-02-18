//! Example demonstrating WASM loading state components
//!
//! This example shows how to use the WasmLoadingState component and related
//! loading UI components to provide feedback during WASM initialization and operations.

use leptos::prelude::*;
use leptos_lyx_ui_wasm::loading::{WasmLoadingState, WasmSpinner, WasmProgressBar, WasmLoadingText, WasmInlineLoader};
#[cfg(feature = "button")]
use crate::default::components::ui::button::Button;

/// Example showing basic WASM loading state usage
#[component]
pub fn WasmLoadingExample() -> impl IntoView {
view! {
<div class="space-y-8 p-8">
<div>
<h1 class="text-3xl font-bold mb-2">"WASM Loading State Examples"</h1>
<p class="text-muted-foreground">
"Examples showing how to use WASM loading state components"
</p>
</div>

// Individual component examples
<SpinnerExample />
<ProgressBarExample />
<LoadingTextExample />
<InlineLoaderExample />

// Full WASM loading state example (commented out for demo purposes)
// Uncomment to see the full loading state in action
// <FullWasmLoadingStateExample />
</div>
}
}

/// Example showing the WasmSpinner component
#[component]
fn SpinnerExample() -> impl IntoView {
view! {
<div class="space-y-4">
<h2 class="text-2xl font-semibold">"Spinner Component"</h2>

<div class="flex items-center gap-8">
<div class="flex flex-col items-center gap-2">
<WasmSpinner size="sm" />
<span class="text-sm text-muted-foreground">"Small"</span>
</div>
<div class="flex flex-col items-center gap-2">
<WasmSpinner size="md" />
<span class="text-sm text-muted-foreground">"Medium"</span>
</div>
<div class="flex flex-col items-center gap-2">
<WasmSpinner size="lg" />
<span class="text-sm text-muted-foreground">"Large"</span>
</div>
<div class="flex flex-col items-center gap-2">
<WasmSpinner size="xl" />
<span class="text-sm text-muted-foreground">"Extra Large"</span>
</div>
</div>
</div>
}
}

/// Example showing the WasmProgressBar component
#[component]
fn ProgressBarExample() -> impl IntoView {
let (progress1, set_progress1) = signal(0);
let (progress2, set_progress2) = signal(45);
let (progress3, set_progress3) = signal(75);

// Animate the first progress bar
let _ = Effect::new(move |_| {
let timer = gloo_timers::callback::Timeout::new(100, move || {
let current = progress1.get();
if current < 100 {
set_progress1.set(current + 1);
}
});
timer.forget();
});

view! {
<div class="space-y-4">
<h2 class="text-2xl font-semibold">"Progress Bar Component"</h2>

<div class="space-y-6">
<div class="space-y-2">
<label class="text-sm font-medium">"With label (animated):"</label>
<WasmProgressBar
progress=Signal::derive(move || progress1.get())
show_label=Signal::new(true)
label="Loading..."
/>
</div>

<div class="space-y-2">
<label class="text-sm font-medium">"Without label:"</label>
<WasmProgressBar
progress=Signal::derive(move || progress2.get())
/>
</div>

<div class="space-y-2">
<label class="text-sm font-medium">"Different label:"</label>
<WasmProgressBar
progress=Signal::derive(move || progress3.get())
show_label=Signal::new(true)
label=Signal::derive(move || {
if progress3.get() < 30 {
"Starting...".to_string()
} else if progress3.get() < 70 {
"In progress...".to_string()
} else {
"Almost done...".to_string()
}
})
/>
</div>
</div>
</div>
}
}

/// Example showing the WasmLoadingText component
#[component]
fn LoadingTextExample() -> impl IntoView {
let (loading_message, set_loading_message) = signal("Initializing...".to_string());

// Cycle through different loading messages
let messages = vec![
"Initializing...".to_string(),
"Loading components...".to_string(),
"Preparing application...".to_string(),
"Almost ready...".to_string(),
];

let _ = Effect::new(move |_| {
let timer = gloo_timers::callback::Timeout::new(2000, move || {
let current_idx = (loading_message.get().len() / 10) % messages.len();
set_loading_message.set(messages[current_idx].clone());
});
timer.forget();
});

view! {
<div class="space-y-4">
<h2 class="text-2xl font-semibold">"Loading Text Component"</h2>

<div class="space-y-4">
<WasmLoadingText
text=Signal::derive(move || loading_message.get())
show_spinner=Signal::new(true)
/>

<WasmLoadingText
text="Loading without spinner..."
show_spinner=Signal::new(false)
/>
</div>
</div>
}
}

/// Example showing the WasmInlineLoader component
#[component]
fn InlineLoaderExample() -> impl IntoView {
#[cfg(feature = "button")]
let (loading1, set_loading1) = signal(false);
#[cfg(feature = "button")]
let (loading2, set_loading2) = signal(false);
#[cfg(feature = "button")]
let (loading3, set_loading3) = signal(false);

view! {
<div class="space-y-4">
<h2 class="text-2xl font-semibold">"Inline Loader Component"</h2>

<p class="text-sm text-muted-foreground">
"Click the buttons to see the inline loader in action"
</p>

#[cfg(feature = "button")]
<div class="flex flex-wrap gap-4">
<Button
on:click=move |_| {
set_loading1.set(true);
let set_loading = set_loading1.clone();
gloo_timers::callback::Timeout::new(2000, move || {
set_loading.set(false);
}).forget();
}
disabled=Signal::derive(move || loading1.get())
>
<WasmInlineLoader
loading=Signal::derive(move || loading1.get())
size="sm".to_string()
/>
"Small Loader"
</Button>

<Button
on:click=move |_| {
set_loading2.set(true);
let set_loading = set_loading2.clone();
gloo_timers::callback::Timeout::new(2000, move || {
set_loading.set(false);
}).forget();
}
disabled=Signal::derive(move || loading2.get())
>
<WasmInlineLoader
loading=Signal::derive(move || loading2.get())
/>
"Medium Loader"
</Button>

<Button
on:click=move |_| {
set_loading3.set(true);
let set_loading = set_loading3.clone();
gloo_timers::callback::Timeout::new(2000, move || {
set_loading.set(false);
}).forget();
}
disabled=Signal::derive(move || loading3.get())
>
<WasmInlineLoader
loading=Signal::derive(move || loading3.get())
size="lg".to_string()
/>
"Large Loader"
</Button>
</div>

#[cfg(not(feature = "button"))]
<div class="text-sm text-muted-foreground">
"Enable the 'button' feature to see inline loader examples"
</div>
</div>
}
}

/// Example showing the full WasmLoadingState component
///
/// This demonstrates how to use the WasmLoadingState component to wrap
/// your entire application or specific sections that depend on WASM initialization.
#[component]
fn FullWasmLoadingStateExample() -> impl IntoView {
view! {
<div class="space-y-4">
<h2 class="text-2xl font-semibold">"Full WASM Loading State"</h2>

<p class="text-sm text-muted-foreground">
"This shows the complete WASM loading state with progress tracking"
</p>

<WasmLoadingState>
<div class="p-4 bg-muted rounded-lg">
<h3 class="text-lg font-semibold">"WASM is Ready!"</h3>
<p class="text-muted-foreground">
"Your WASM application has been initialized successfully."
</p>
</div>
</WasmLoadingState>
</div>
}
}
