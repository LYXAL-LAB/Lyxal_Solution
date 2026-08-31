use leptos::prelude::*;
use leptos_ui::clx;

mod components {
    use super::*;
    clx! {SwitchLabel, span, "text-sm font-medium"}
}

pub use components::*;

#[component]
pub fn Switch(
    #[prop(optional, into)] id: String,
    #[prop(optional, default = false)] checked: bool,
    #[prop(into, optional, default = "Toggle switch".to_string())] aria_label: String,
) -> impl IntoView {
    // let input_ref = NodeRef::<html::Input>::new();

    // let handle_keydown = move |e: web_sys::KeyboardEvent| {
    //     if e.key() == " " || e.key() == "Enter" {
    //         e.prevent_default();
    //         if let Some(input) = input_ref.get() {
    //             input.click();
    //         }
    //     }
    // };

    let peer_class = if !id.is_empty() { format!("peer/{}", id) } else { "peer".to_string() };

    view! {
        <label
            class="inline-flex relative items-center cursor-pointer"
            // on:keydown=handle_keydown
            tabindex="0"
        >
            <input
                type="checkbox"
                value=""
                // sr-only
                class=format!("hidden {}", peer_class)
                id=id
                checked=checked
                aria-label=aria_label
            />

            <div
                data-name="Switch"
                class="w-11 h-6 bg-gray-200 rounded-full peer-focus:outline-hidden peer-focus:ring-ring/50 peer-focus:ring-[3px] peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:size-5 after:transition-all peer-checked:bg-primary"
            />
        </label>
    }
}