### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\nginx-mpmc\shared-lyx-platform-lyx_platform_server-2\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\nginx-mpmc\shared-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-2\src\main.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: #[tokio::main]
5: 3: async fn main() {
6: 4:     use axum::Router;
7: 5:     use axum::routing::post;
8: 6:     // In production you wouldn't want to use a hardcoded address like this.
9: 7:     let addr = "127.0.0.1:3003";
10: 8:     // build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
11: 9:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
12: 10:         .route("/api_shared2/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
13: 11:         .layer(tower_http::trace::TraceLayer::new_for_http())
14: 12:         .layer(axum::Extension(shared_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_2::SharedServerState2));
15: 13: 
16: 14:     let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
17: 15:     println!("shared lyx-platform-lyx_platform_lyx-platform-lyx_platform_server listening on http://{}", addr);
18: 16:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
19: 17:         .await
20: 18:         .unwrap();
21: 19: }
22: 20: 
23: 21: #[cfg(not(feature = "ssr"))]
24: 22: pub fn main() {
25: 23:     // no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
26: 24:     // our lyx-platform-lyx_platform_lyx-platform-lyx_platform_server is SSR only, we have no lyx-core-lyx_core_lyx-core-lyx_core_client pair.
27: 25:     // We'll only ever run this with cargo run --features ssr
28: 26: }
29: ```
```
