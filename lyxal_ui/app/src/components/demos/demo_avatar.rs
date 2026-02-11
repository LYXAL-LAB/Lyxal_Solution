use leptos::prelude::*;

use crate::components::ui::avatar::{Avatar, AvatarFallback, AvatarImage};

// TODO. Fix overlapping with AvatarFallback and broken image when we refresh with broken image.

#[component]
pub fn DemoAvatar() -> impl IntoView {
    view! {
        <Avatar>
            <AvatarImage attr:src="/broken-image.png" attr:alt="@rustify.rs" />
            <AvatarFallback>RS</AvatarFallback>
        </Avatar>
    }
}