### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\main.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\main.rs
#[cfg(feature = "ssr")]
mod router {
use axum::{
Router,
http::{HeaderName, HeaderValue},
};
use clap::{Parser, Subcommand};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::{get_configuration, provide_context, use_context};
use lyx-core-axum::{ErrorHandler, LeptosRoutes, generate_route_list};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode::lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::{App, shell};

#[derive(Parser)]
pub struct Cli {
#[command(subcommand)]
mode: Mode,
}

#[derive(Subcommand)]
enum Mode {
Bare,
Fallback,
FallbackWithContext,
ErrorHandlerService,
ErrorHandlerServiceFallback,
RouteSitePkgNoFallback,
}

impl From<Cli> for Router {
fn from(cli: Cli) -> Self {
let conf = get_configuration(None).unwrap();
let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
let routes = generate_route_list(App);

match cli.mode {
Mode::Bare => Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
})
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
Mode::Fallback => Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
})
.fallback(lyx-core-axum::file_and_error_handler(shell))
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
Mode::FallbackWithContext => Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
})
.fallback(lyx-core-axum::file_and_error_handler_with_context(
move || {
let opts =
use_context::<lyx-core-axum::ResponseOptions>()
.unwrap_or_default();
opts.insert_header(
HeaderName::from_static(
"cross-origin-opener-policy",
),
HeaderValue::from_static("same-origin"),
);
opts.insert_header(
HeaderName::from_static(
"cross-origin-embedder-policy",
),
HeaderValue::from_static("require-corp"),
);
provide_context(opts);
},
shell,
))
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
Mode::ErrorHandlerService => Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
})
.fallback_service(ErrorHandler::new(
shell,
lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
))
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
Mode::ErrorHandlerServiceFallback => Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
})
.fallback_service(
lyx-core-axum::site_pkg_dir_service(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options)
.fallback(ErrorHandler::new(
shell,
lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
)),
)
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
Mode::RouteSitePkgNoFallback => Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
})
.route_service(
&lyx-core-axum::site_pkg_dir_service_route_path(
&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
),
lyx-core-axum::site_pkg_dir_service(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
)
.fallback_service(ErrorHandler::new(
shell,
lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
))
.with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
}
}
}
}

#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
use axum::Router;
use clap::Parser;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::get_configuration;

let lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::from(router::Cli::parse());
let conf = get_configuration(None).unwrap();
let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
// write out the port from the bounded local_addr to allow the caller to know how to connect.
println!("{}", listener.local_addr().unwrap().port());
axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
.await
.unwrap();
}

#[cfg(not(feature = "ssr"))]
pub fn main() {}
