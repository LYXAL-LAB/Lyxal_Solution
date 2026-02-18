use leptos::prelude::*;

use crate::components::ui::button::Button;
use crate::components::ui::toast_custom::toast_wrapper::show_toast;

#[component]
pub fn DemoToast() -> impl IntoView {
let toast_me = move |_| {
show_toast().info("This is a toast!");
};

view! { <Button on:click=toast_me>"Toast me"</Button> }
}
