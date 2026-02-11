### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_app-1\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_lyx-core-lyx-platform-lyx_platform_app-1\src\main.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: #[tokio::main]
5: 3: async fn main() {
6: 4:     use axum::Router;
7: 5:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
8: 6:     use lyx-core-axum::{generate_route_list, LeptosRoutes};
9: 7:     use lyx_core_lyx-platform-lyx_platform_lyx_core_lyx-platform-lyx_platform_app_1::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
10: 8:     use lyx_core_lyx-platform-lyx_platform_lyx_core_lyx-platform-lyx_platform_app_1::fileserv::file_and_error_handler;
11: 9:     use axum::routing::post;
12: 10:     
13: 11:     tracing_subscriber::fmt()
14: 12:     .pretty()
15: 13:     .with_thread_names(true)
16: 14:     // enable everything
17: 15:     .with_max_level(tracing::Level::TRACE)
18: 16:     // sets this to be the default, global collector for this lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
19: 17:     .init();
20: 18: 
21: 19:     // Setting get_configuration(None) means we'll be using cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos's env values
22: 20:     // For deployment these variables are:
23: 21:     // <https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum#executing-a-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-on-a-remote-machine-without-the-toolchain>
24: 22:     // Alternately a file can be specified such as Some("Cargo.toml")
25: 23:     // The file would need to be included with the executable when moved to deployment
26: 24:     let conf = get_configuration(Some("Cargo.toml")).unwrap();
27: 25:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
28: 26:     let addr = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
29: 27:     let routes = generate_route_list(App);
30: 28: 
31: 29:     // build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
32: 30:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
33: 31:         .route("/api_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app1/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
34: 32:         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, App)
35: 33:         .fallback(file_and_error_handler)
36: 34:         .layer(tower_http::trace::TraceLayer::new_for_http())
37: 35:         .with_state(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options);
38: 36: 
39: 37:     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
40: 38:     logging::log!("listening on http://{}", &addr);
41: 39:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
42: 40:         .await
43: 41:         .unwrap();
44: 42: }
45: 43: 
46: 44: #[cfg(not(feature = "ssr"))]
47: 45: pub fn main() {
48: 46:     // no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
49: 47:     // unless we want this to work with e.g., Trunk for a purely lyx-core-lyx_core_lyx-core-lyx_core_client-side lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
50: 48:     // see lib.rs for hydration function instead
51: 49: }
52: ```
```
