pub mod api;
pub mod avatars;
pub mod captcha;
pub mod company;
pub mod csp;
pub mod error;
pub mod errors;
pub use error::WebError;
pub mod meeting;
pub mod middleware;
pub mod state;
pub mod templates;

pub use errors::*;
pub use middleware::csrf::{
    csrf_cookie_middleware, csrf_cookie_value, csrf_cookie_value_for, csrf_token_from_headers,
    generate_csrf_token, verify_csrf_token, CSRF_COOKIE_NAME,
};
pub use middleware::rate_limit::{client_ip_for_rate_limit, RateLimiter};
pub use state::AppState;

use axum::routing::get;
use axum::Router;
use tower_http::set_header::SetResponseHeaderLayer;
use tower_http::trace::TraceLayer;

pub async fn create_router(state: AppState) -> anyhow::Result<Router> {
    let router = Router::new()
        .nest("/api/v1", api::v1::router())
        .merge(api::v1::compatibility_redirects::compatibility_router())
        .merge(crate::auth::auth_router())
        .route("/avatar/{user_id}", get(avatars::serve_avatar))
        .route("/team-avatar/{team_id}", get(avatars::serve_team_avatar))
        .route("/logo", get(avatars::serve_logo))
        .route("/accent.css", get(avatars::serve_accent_css))
        .route("/brand-logo", get(avatars::serve_brand_logo))
        .route("/embed.js", get(templates::serve_embed_js))
        .route(
            "/fonts/inter-latin.woff2",
            get(templates::serve_font_inter_latin),
        )
        .route(
            "/fonts/inter-latin-ext.woff2",
            get(templates::serve_font_inter_latin_ext),
        )
        .layer(TraceLayer::new_for_http())
        .layer(axum::middleware::from_fn(csrf_cookie_middleware))
        .layer(SetResponseHeaderLayer::if_not_present(
            axum::http::header::X_FRAME_OPTIONS,
            axum::http::HeaderValue::from_static("SAMEORIGIN"),
        ))
        .layer(SetResponseHeaderLayer::if_not_present(
            axum::http::header::X_CONTENT_TYPE_OPTIONS,
            axum::http::HeaderValue::from_static("nosniff"),
        ))
        .layer(SetResponseHeaderLayer::if_not_present(
            axum::http::header::REFERRER_POLICY,
            axum::http::HeaderValue::from_static("strict-origin-when-cross-origin"),
        ))
        .layer(SetResponseHeaderLayer::if_not_present(
            axum::http::HeaderName::from_static("permissions-policy"),
            axum::http::HeaderValue::from_static(
                "geolocation=(), microphone=(), camera=(), payment=(), usb=()",
            ),
        ))
        .layer(axum::middleware::from_fn_with_state(
            state.clone(),
            csp::csp_middleware,
        ))
        .with_state(state);

    Ok(router)
}
