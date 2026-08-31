pub mod admin;
pub mod auth;
pub mod availability;
pub mod bookings;
pub mod calendars;
pub mod compatibility_redirects;
pub mod event_types;
pub mod integrations;
pub mod oauth;
pub mod platform_admin;
pub mod resources;
pub mod settings;
pub mod teams;
pub mod users;

use axum::Router;
use crate::web::state::AppState;

pub fn router() -> Router<AppState> {
    Router::new()
        .nest("/settings", settings::router())
        .nest("/auth", auth::router())
        .nest("/resources", resources::router())
        .nest("/users", users::router())
        .nest("/event-types", event_types::router())
        .nest("/teams", teams::router())
        .nest("/calendars", calendars::router())
        .nest("/availability", availability::router())
        .nest("/bookings", bookings::router())
        .nest("/oauth", oauth::router())
        .nest("/integrations", integrations::router())
        .nest("/public", bookings::public_router())
        .nest("/admin", admin::router())
        .nest("/platform-admin", platform_admin::router())
        .merge(compatibility_redirects::compatibility_router())
}

