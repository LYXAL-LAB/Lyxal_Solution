### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
//! Setup our Cloudflare worker (`feature == "ssr"`) and our lyx-core-lyx_core_lyx-core-lyx_core_leptos hydration function (`feature ==
//! "hydrate"`)

use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;

#[cfg(feature = "ssr")]
use worker::*;

use crate::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;

mod api;
mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;
mod components;

#[cfg(feature = "ssr")]
mod serve_static;

#[cfg(feature = "ssr")]
async fn router(env: Env) -> axum::Router {
use std::sync::Arc;

use axum::{routing::post, Extension};
use lyx-core-axum::{generate_route_list, LeptosRoutes};

use crate::api::register_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_functions;

// Match what's in Cargo.toml
// Doesn't seem to be able to do this automatically
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = LeptosOptions {
output_name: "lyx-core-lyx_core_lyx-core-lyx_core_leptos_worker".into(),
site_root: "public".into(),
site_pkg_dir: "pkg".into(),
env: lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::Env::DEV,
site_addr: "127.0.0.1:8787".parse().unwrap(),
reload_port: 3001,
reload_external_port: None,
reload_ws_protocol: lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::ReloadWSProtocol::WS,
not_found_path: "/404".into(),
hash_file: "hash.txt".into(),
hash_files: false,
};
let routes = generate_route_list(|| view! { <App /> });

register_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_functions();

// build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
axum::Router::new()
.route("/api/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, || view! { <App/> })
.fallback(serve_static::serve_static) // <- Serve Workers Sites static files (assets dir)
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options)
.layer(Extension(Arc::new(env))) // <- Allow lyx-core-lyx_core_lyx-core-lyx_core_leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions to access Worker stuff
}

#[cfg(feature = "ssr")]
#[event(fetch)]
async fn fetch(
req: HttpRequest,
env: Env,
_ctx: Context,
) -> Result<axum::http::Response<axum::body::Body>> {
use tower_service::Service;

console_error_panic_hook::set_once();

Ok(router(env).await.call(req).await?)
}

#[cfg(feature = "hydrate")]
#[wasm_bindgen::prelude::wasm_bindgen]
pub fn hydrate() {
_ = console_log::init_with_level(log::Level::Debug);
console_error_panic_hook::set_once();

lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount_to_body(|| view! { <App/> });
}
