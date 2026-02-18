use leptos::prelude::*;

use crate::components::ui::badge::Badge;

#[component]
pub fn DemoBadge() -> impl IntoView {
view! { <Badge>"Default"</Badge> }
}
