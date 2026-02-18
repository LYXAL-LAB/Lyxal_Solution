#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
use axum::{
Router,
routing::get,
};
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
use lyx-core-axum::{generate_route_list, LeptosRoutes};
use lyx_core_lyx-platform-lyx_platform_lyx_core_lyx-platform-lyx_platform_app_2::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
use lyx_core_lyx-platform-lyx_platform_lyx_core_lyx-platform-lyx_platform_app_2::fileserv::file_and_error_handler;

// Setting get_configuration(None) means we'll be using cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos's env values
// For deployment these variables are:
// <https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum#executing-a-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-on-a-remote-machine-without-the-toolchain>
// Alternately a file can be specified such as Some("Cargo.toml")
// The file would need to be included with the executable when moved to deployment
let conf = get_configuration(Some("Cargo.toml")).unwrap();
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
let addr = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
let routes = generate_route_list(App);


let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, App)
.fallback(file_and_error_handler)
.layer(tower_http::trace::TraceLayer::new_for_http())
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options);
let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
logging::log!("listening on http://{}", &addr);
axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
.await
.unwrap();
}

#[cfg(not(feature = "ssr"))]
pub fn main() {
// no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
// unless we want this to work with e.g., Trunk for a purely lyx-core-lyx_core_lyx-core-lyx_core_client-side lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
// see lib.rs for hydration function instead
}
