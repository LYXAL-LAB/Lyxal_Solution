### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
// Note: this is original axum template code. Nothing has changed.

#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
use axum::Router;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-axum::{generate_route_list, LeptosRoutes};
use lyx-core-sample-crumbs::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;

let conf = get_configuration(None).unwrap();
let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
// Generate the list of routes in your Leptos App
let routes = generate_route_list(App);

let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
})
.fallback(lyx-core-axum::file_and_error_handler(shell))
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options);

// run our lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with hyper
// `axum::Server` is a re-export of `hyper::Server`
log!("listening on http://{}", &addr);
let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
.await
.unwrap();
}

#[cfg(not(feature = "ssr"))]
pub fn main() {
// no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
// unless we want this to work with e.g., Trunk for pure lyx-core-lyx_core_lyx-core-lyx_core_client-side testing
// see lib.rs for hydration function instead
}
