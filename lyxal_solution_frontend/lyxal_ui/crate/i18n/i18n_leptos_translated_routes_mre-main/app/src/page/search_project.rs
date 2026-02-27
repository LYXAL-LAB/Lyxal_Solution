use crate::i18n::*;
use leptos::prelude::*;
use leptos::IntoView;
use leptos_i18n::t;
use leptos_router::components::A;

/// Renders the home page of your application.
#[component]
pub fn SearchProject() -> impl IntoView {
    // Creates a reactive value to update the button
    let i18n = use_i18n();

    let l = move || i18n.get_locale().as_str();

    view! {
        <div class="m-2">
            <h1 class="text-2xl">{l()}</h1>
            <h1 class="text-2xl">{t!(i18n,search_project.search_project_title)}</h1>
            <For
              each = Locale::get_all
              key = |locale| **locale
              let:locale
            >
                <A href=format!("/{}/{}", locale, td_string!(*locale, common.menu.search_project_path)) {..} class="-mx-3 block rounded-lg px-3 py-2.5 text-base/7 font-semibold text-gray-900 hover:bg-gray-50">{locale.as_str()}</A>
            </For>
        </div>
    }
}
