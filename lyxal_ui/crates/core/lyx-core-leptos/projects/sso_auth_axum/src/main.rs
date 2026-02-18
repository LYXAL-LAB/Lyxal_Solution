use crate::ssr_imports::*;
use axum::{
body::Body as AxumBody,
extract::{Path, State},
http::Request,
response::IntoResponse,
routing::get,
Router,
};
use axum_session::{Key, SessionConfig, SessionLayer, SessionStore};
use axum_session_auth::{AuthConfig, AuthSessionLayer};
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{get_configuration, logging::log, provide_context, view};
use lyx-core-axum::{
generate_route_list, handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context, LeptosRoutes,
};
use sqlx::sqlite::SqlitePoolOptions;
use lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum::{
auth::*, fallback::file_and_error_handler, state::AppState,
};

async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler(
State(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state): State<AppState>,
auth_session: AuthSession,
path: Path<String>,
request: Request<AxumBody>,
) -> impl IntoResponse {
log!("{:?}", path);

handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(
move || {
provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.clone());
provide_context(auth_session.clone());
provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.pool.clone());
},
request,
)
.await
}

pub async fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler(
auth_session: AuthSession,
State(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state): State<AppState>,
axum::extract::State(option): axum::extract::State<lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions>,
request: Request<AxumBody>,
) -> axum::response::Response {
let handler = lyx-core-axum::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async_with_context(
option.clone(),
move || {
provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.clone());
provide_context(auth_session.clone());
provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.pool.clone());
},
move || view! {  <lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum::App/> },
);

handler(request).await.into_response()
}

#[tokio::main]
async fn main() {
simple_logger::init_with_level(log::Level::Info)
.expect("couldn't initialize logging");

let pool = SqlitePoolOptions::new()
.connect("sqlite:sso.db")
.await
.expect("Could not make pool.");

// Auth section
let session_config = SessionConfig::default()
.with_table_name("sessions_table")
.with_key(Key::generate())
.with_database_key(Key::generate());
// .with_security_mode(SecurityMode::PerSession); // FIXME did this dislyx-platform-lyx_platform_lyx-platform-lyx_platform_appear?

let auth_config = AuthConfig::<i64>::default();
let session_store = SessionStore::<SessionSqlitePool>::new(
Some(pool.clone().into()),
session_config,
)
.await
.unwrap();

sqlx::migrate!()
.run(&pool)
.await
.expect("could not run SQLx migrations");

// Setting this to None means we'll be using cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos and its env vars
let conf = get_configuration(None).unwrap();
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
let addr = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
let routes = generate_route_list(lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum::App);

// We create our lyx-core-lyx_core_lyx-core-lyx_core_client using provided environment variables.
let lyx-core-lyx_core_lyx-core-lyx_core_client = oauth2::lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic::BasicClient::new(
oauth2::ClientId::new(
std::env::var("G_AUTH_CLIENT_ID")
.expect("G_AUTH_CLIENT_ID Env var to be set."),
),
Some(oauth2::ClientSecret::new(
std::env::var("G_AUTH_SECRET")
.expect("G_AUTH_SECRET Env var to be set"),
)),
oauth2::AuthUrl::new(
"https://accounts.google.com/o/oauth2/v2/auth".to_string(),
)
.unwrap(),
Some(
oauth2::TokenUrl::new(
"https://oauth2.googleapis.com/token".to_string(),
)
.unwrap(),
),
)
.set_redirect_uri(
oauth2::RedirectUrl::new(
std::env::var("REDIRECT_URL")
.expect("REDIRECT_URL Env var to be set"),
)
.unwrap(),
);

let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = AppState {
lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
pool: pool.clone(),
lyx-core-lyx_core_lyx-core-lyx_core_client,
};

// build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
.route(
"/api/*fn_name",
get(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler).post(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler),
)
.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_handler(routes, get(lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler))
.fallback(file_and_error_handler)
.layer(
AuthSessionLayer::<User, i64, SessionSqlitePool, SqlitePool>::new(
Some(pool.clone()),
)
.with_config(auth_config),
)
.layer(SessionLayer::new(session_store))
.with_state(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state);

// run our lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with hyper
// `axum::Server` is a re-export of `hyper::Server`
let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
log!("listening on http://{}", &addr);
axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
.await
.unwrap();
}
