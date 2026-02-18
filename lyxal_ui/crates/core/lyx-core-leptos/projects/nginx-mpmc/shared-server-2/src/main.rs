#[cfg(feature = "ssr")]
#[tokio::main]
async fn main() {
use axum::Router;
use axum::routing::post;
// In production you wouldn't want to use a hardcoded address like this.
let addr = "127.0.0.1:3003";
// build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
.route("/api_shared2/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
.layer(tower_http::trace::TraceLayer::new_for_http())
.layer(axum::Extension(shared_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_2::SharedServerState2));

let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
println!("shared lyx-platform-lyx_platform_lyx-platform-lyx_platform_server listening on http://{}", addr);
axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
.await
.unwrap();
}

#[cfg(not(feature = "ssr"))]
pub fn main() {
// no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
// our lyx-platform-lyx_platform_lyx-platform-lyx_platform_server is SSR only, we have no lyx-core-lyx_core_lyx-core-lyx_core_client pair.
// We'll only ever run this with cargo run --features ssr
}
