### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\nginx-mpmc\shared-lyx-platform-lyx_platform_server-1\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\nginx-mpmc\shared-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-1\src\main.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: #[tokio::main]
5: 3: async fn main() {
6: 4:     use axum::Router;
7: 5:     use axum::routing::post;
8: 6: 
9: 7:     tracing_subscriber::fmt()
10: 8:     .pretty()
11: 9:     .with_thread_names(true)
12: 10:     // enable everything
13: 11:     .with_max_level(tracing::Level::TRACE)
14: 12:     // sets this to be the default, global collector for this lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
15: 13:     .init();
16: 14: 
17: 15:     // In production you wouldn't want to use a hardcoded address like this.
18: 16:     let addr = "127.0.0.1:3002";
19: 17:     // build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
20: 18:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
21: 19:         .route("/api_shared/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
22: 20:         .layer(tower_http::trace::TraceLayer::new_for_http())
23: 21:         .layer(axum::Extension(shared_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::SharedServerState));
24: 22: 
25: 23:     let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
26: 24:     println!("shared lyx-platform-lyx_platform_lyx-platform-lyx_platform_server listening on http://{}", addr);
27: 25:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
28: 26:         .await
29: 27:         .unwrap();
30: 28: }
31: 29: 
32: 30: #[cfg(not(feature = "ssr"))]
33: 31: pub fn main() {
34: 32:     // no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
35: 33:     // our lyx-platform-lyx_platform_lyx-platform-lyx_platform_server is SSR only, we have no lyx-core-lyx_core_lyx-core-lyx_core_client pair.
36: 34:     // We'll only ever run this with cargo run --features ssr
37: 35: }
38: ```
```
