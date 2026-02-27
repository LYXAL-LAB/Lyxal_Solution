use crate::i18n::*;
use leptos::prelude::*;
use leptos::IntoView;
use leptos_i18n::t;

/// Renders the home page of your application.
#[component]
pub fn SubmitProject() -> impl IntoView {
    // Creates a reactive value to update the button
    let i18n = use_i18n();

    let l = move || i18n.get_locale().as_str();

    view! {
        <div class="m-2">
            <h1 class="text-2xl">{l()}</h1>
            <h1 class="text-2xl">{{t!(i18n, submit_project.submit_project_title)}}</h1>
        </div>
    }
}
