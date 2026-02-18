mod comprehensive_demo;
mod component_browser;

use leptos::prelude::*;
use leptos_meta::*;

// For production: use leptos-lyx-ui-shadcn-wasm for proper WASM initialization
#[cfg(feature = "wasm")]
use leptos_lyx_ui_wasm::init::provide_wasm_init;

fn main() {
// Mount the app to the body
mount_to_body(|| view! { <App /> })
}

#[component]
pub fn App() -> impl IntoView {
// Provides context that manages stylesheets, titles, meta tags, etc.
provide_meta_context();

// Initialize WASM with proper state management
#[cfg(feature = "wasm")]
provide_wasm_init();

view! {
<Title text="Leptos ShadCN UI Demo"/>
<Meta charset="utf-8"/>
<Meta name="viewport" content="width=device-width, initial-scale=1"/>
<Meta name="description" content="Interactive demo of Leptos ShadCN UI components"/>

<Link rel="preconnect" href="https://fonts.googleapis.com"/>
<Link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous"/>
<Link href="https://fonts.googleapis.com/css2?family=Inter:wght@100..900&display=swap" rel="stylesheet"/>

<comprehensive_demo::ComprehensiveDemo />
}
}
