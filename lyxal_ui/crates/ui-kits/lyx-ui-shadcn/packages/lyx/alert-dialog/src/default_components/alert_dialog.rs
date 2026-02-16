//! Main AlertDialog component
//! 
//! This module contains the main AlertDialog component that provides context
//! and handles keyboard events for the alert dialog system.

use leptos::prelude::*;
use web_sys::KeyboardEvent;
use wasm_bindgen::JsCast;

#[component]
pub fn AlertDialog(
    #[prop(into)] open: RwSignal<bool>,
    #[prop(into, optional)] on_open_change: Option<Callback<bool>>,
    #[prop(optional)] children: Option<Children>,
) -> impl IntoView {
    provide_context(open);
    provide_context(on_open_change);

    // Render children once (Children is FnOnce in Leptos 0.8)
    let rendered_children = children.map(|c| c());

    view! {
        <div style:display=move || if open.get() { "block" } else { "none" }>
            {rendered_children}
        </div>
    }
}


