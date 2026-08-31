use leptos::prelude::*;
use leptos_router::components::{Route, Router, Routes, ParentRoute};
use leptos_router::path;

use crate::goose::layout::AppLayout;
use crate::goose::chat::GooseChat;
use crate::goose::home::HomeView;
use crate::goose::extensions::ExtensionsView;
use crate::goose::settings::SettingsPage;
use crate::goose::recipes::RecipesView;
use crate::goose::apps::AppsView;
use crate::goose::scheduler::SchedulerView;
use crate::goose::sessions::SessionsView;

#[component]
pub fn App() -> impl IntoView {
    view! {
        <Router>
            <Routes fallback=|| view! { "404 Not Found" }>
                <ParentRoute path=path!("/") view=AppLayout>
                    <Route path=path!("") view=GooseChat />
                    <Route path=path!("home") view=HomeView />
                    <Route path=path!("extensions") view=ExtensionsView />
                    <Route path=path!("settings") view=SettingsPage />
                    <Route path=path!("recipes") view=RecipesView />
                    <Route path=path!("apps") view=AppsView />
                    <Route path=path!("schedules") view=SchedulerView />
                    <Route path=path!("sessions") view=SessionsView />
                </ParentRoute>
            </Routes>
        </Router>
    }
}
