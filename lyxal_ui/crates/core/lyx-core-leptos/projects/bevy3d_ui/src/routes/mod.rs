pub mod lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1;
use lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1::Demo1;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-lyx_core_lyx-core-meta::Meta;
use lyx-core-lyx_core_lyx-core-meta::Title;
use lyx-core-lyx_core_lyx-core-meta::{provide_meta_context, MetaTags, Stylesheet};
use lyx-core-lyx_core_lyx-core-router::components::*;
use lyx-core-lyx_core_lyx-core-router::StaticSegment;
#[component]
pub fn RootPage() -> impl IntoView {
provide_meta_context();

view! {
<Meta name="charset" content="UTF-8"/>
<Meta name="description" content="Leptonic CSR template"/>
<Meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<Meta name="theme-color" content="#e66956"/>
<Title text="Leptos Bevy3D Example"/>
<Stylesheet href="https://fonts.googleapis.com/css?family=Roboto&display=swap"/>
<MetaTags/>
<Router>
<Routes fallback=move || "Not found.">
<Route path=StaticSegment("") view=Demo1 />
</Routes>
</Router>
}
}
