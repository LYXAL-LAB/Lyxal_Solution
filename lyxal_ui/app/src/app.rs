use leptos::prelude::*;
use leptos_meta::{Html, Title, provide_meta_context};
use leptos_router::StaticSegment;
use leptos_router::components::{Route, Router, Routes};

use crate::components::hooks::use_theme_mode::ThemeMode;
use crate::components::layout::app_bottom_nav::AppBottomNav;
use crate::components::layout::app_wrapper::AppWrapper;
use crate::components::layout::header::Header;
use crate::domain::home::{HomePage, HomeRoutes};
use crate::domain::settings::{SettingsPage, SettingsRoutes};
use crate::domain::test::{TestPage, TestRoutes};

#[component]
pub fn App() -> impl IntoView {
    let theme_mode = ThemeMode::init();

    provide_meta_context();

    view! {
        <Title text="Rust/UI Starters — Cross-Platform Apps" />

        <Html {..} class=move || if theme_mode.is_dark() { "dark" } else { "" } />

        <Router>
            <AppWrapper>
                <Header />

                <main class="overflow-y-auto flex-1 overflow-x-clip">
                    <Routes fallback=|| view! { <NotFoundPage /> }>
                        <Route path=StaticSegment(HomeRoutes::base_url()) view=HomePage />
                        <Route path=StaticSegment(TestRoutes::base_segment()) view=TestPage />
                        <Route path=StaticSegment(SettingsRoutes::base_segment()) view=SettingsPage />
                    </Routes>
                </main>
            </AppWrapper>

            <AppBottomNav />
        </Router>
    }
}

/* ========================================================== */
/*                     ✨ FUNCTIONS ✨                        */
/* ========================================================== */

#[component]
fn NotFoundPage() -> impl IntoView {
    view! { <p>"Not Found."</p> }
}
