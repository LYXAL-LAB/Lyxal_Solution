#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
use axum::Router;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-axum::{generate_route_list, LeptosRoutes};
use lyx-core-lyx_core_lyx_core_hexagonal_architecture::{
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*,
config::config,
lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types::{HandlerStructAlias, ServerState},
};

let conf = get_configuration(None).unwrap();
let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
let routes = generate_route_list(App);
let handler = config();
let handler_c = handler.clone();
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_state = ServerState {
handler,
lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
};
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context(
&lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_state,
routes,
move || provide_context(handler_c.clone()),
{
let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
},
)
.fallback(lyx-core-axum::file_and_error_handler::<
ServerState<HandlerStructAlias>,
_,
>(shell))
.with_state(lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_state);

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
