use leptos::prelude::*;
use lyx_logic_use::docs::lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo_or_body;
use lyx_logic_use{{#if module}}::{{ module }}{{/if}}::{{ function_name }};

#[component]
fn Demo() -> impl IntoView {

{{ function_name }}();

view! {  }
}

fn main() {
_ = console_log::init_with_level(log::Level::Debug);
console_error_panic_hook::set_once();

let unmount = mount_to(lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo_or_body(), || {
view! { <Demo /> }
});
unmount.forget();
}
