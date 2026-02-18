use leptos::prelude::*;
use leptos_meta::{MetaTags, Stylesheet, Title};
use crate::app::App;

#[allow(non_snake_case)]
#[component]
pub fn Shell(options: LeptosOptions) -> impl IntoView {
    view! {
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <AutoReload options=options.clone() />
                <HydrationScripts options=options.clone() />
                <MetaTags />
                <Stylesheet id="leptos" href="/pkg/lyxal_web.css"/>
                <Title text="Goose UI"/>
            </head>
            <body>
                <App />
            </body>
        </html>
    }
}

#[cfg(feature = "ssr")]
pub fn shell(options: LeptosOptions) -> impl IntoView {
    view! {
        <Shell options=options />
    }
}
