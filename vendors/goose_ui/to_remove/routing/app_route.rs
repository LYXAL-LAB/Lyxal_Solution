use icons::{House, Settings, TestTubeDiagonal};
use leptos::prelude::*;
use leptos_router::StaticSegment;
use strum::IntoStaticStr;

#[derive(Debug, Clone, Copy, PartialEq, Eq, IntoStaticStr, Default)]
pub enum AppRoute {
    #[default]
    Home,
    Test,
    Settings,
}

impl AppRoute {
    pub fn path(self) -> &'static str {
        match self {
            AppRoute::Home => "/",
            AppRoute::Test => "/test",
            AppRoute::Settings => "/settings",
        }
    }

    pub fn segment(self) -> StaticSegment<&'static str> {
        StaticSegment(self.path())
    }

    pub fn label(self) -> &'static str {
        self.into()
    }

    pub fn bottom_nav_routes() -> &'static [AppRoute] {
        &[AppRoute::Home, AppRoute::Test, AppRoute::Settings]
    }

    pub fn icon(self) -> impl IntoView {
        match self {
            AppRoute::Home => view! { <House /> }.into_any(),
            AppRoute::Test => view! { <TestTubeDiagonal /> }.into_any(),
            AppRoute::Settings => view! { <Settings /> }.into_any(),
        }
    }
}
