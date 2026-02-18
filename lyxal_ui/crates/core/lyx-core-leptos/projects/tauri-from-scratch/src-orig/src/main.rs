#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
use axum::{
body::Body,
extract::{Request, State},
response::IntoResponse,
routing::get,
Router,
};
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-axum::{generate_route_list, LeptosRoutes};
use lyx-core-lyx_core_lyx-core-src-orig::{
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::{shell, App},
fallback::file_and_error_handler,
};
use tower_http::cors::CorsLayer;

let conf = get_configuration(None).unwrap();
let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
// Generate the list of routes in your Leptos App
let routes = generate_route_list(App);

#[derive(Clone, Debug, axum_macros::FromRef)]
pub struct ServerState {
pub options: LeptosOptions,
pub routes: Vec<lyx-core-axum::AxumRouteListing>,
}

let state = ServerState {
options: lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
routes: routes.clone(),
};

pub async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler(
State(state): State<ServerState>,
request: Request<Body>,
) -> impl IntoResponse {
lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(
move || {
provide_context(state.clone());
},
request,
)
.await
.into_response()
}

let cors = CorsLayer::new()
.allow_methods([axum::http::Method::GET, axum::http::Method::POST])
.allow_origin(
"tauri://localhost"
.parse::<axum::http::HeaderValue>()
.unwrap(),
)
.allow_headers(vec![axum::http::header::CONTENT_TYPE]);

pub async fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler(
State(state): State<ServerState>,
req: Request<Body>,
) -> axum::response::Response {
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = state.options.clone();
let handler = lyx-core-axum::render_route_with_context(
state.routes.clone(),
move || {
provide_context("...");
},
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone()),
);
handler(axum::extract::State(state), req)
.await
.into_response()
}

let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
.route(
"/api/{*fn_name}",
get(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler).post(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler),
)
.layer(cors)
.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_handler(routes, get(lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler))
.fallback(file_and_error_handler)
.with_state(state);

// run our lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with hyper
// `axum::Server` is a re-export of `hyper::Server`
log!("listening on http://{}", &addr);
let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
.await
.unwrap();
}

#[cfg(feature = "csr")]
pub fn main() {
lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::lyx-core-lyx_core_lyx-core-lyx_core_client::set_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_url("http://127.0.0.1:3000");
lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount::mount_to_body(lyx-core-lyx_core_lyx-core-src-orig::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App);
}
