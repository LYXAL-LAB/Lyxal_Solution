use leptos::prelude::*;

use crate::components::ui::button::Button;

#[component]
pub fn TestPage() -> impl IntoView {
    view! {
        <div class="flex flex-col gap-4 p-2">
            <h1 class="text-2xl font-bold">"Test"</h1>
            <p class="text-muted-foreground">"This is the test page."</p>

            <Button>"Test"</Button>
        </div>
    }
}
