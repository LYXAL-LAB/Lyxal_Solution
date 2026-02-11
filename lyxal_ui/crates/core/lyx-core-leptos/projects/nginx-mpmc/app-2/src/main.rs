### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_app-2\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_lyx-core-lyx-platform-lyx_platform_app-2\src\main.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: #[tokio::main]
5: 3: async fn main() {
6: 4:     use axum::{
7: 5:         Router,
8: 6:         routing::get,
9: 7:     };
10: 8:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
11: 9:     use lyx-core-axum::{generate_route_list, LeptosRoutes};
12: 10:     use lyx_core_lyx-platform-lyx_platform_lyx_core_lyx-platform-lyx_platform_app_2::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
13: 11:     use lyx_core_lyx-platform-lyx_platform_lyx_core_lyx-platform-lyx_platform_app_2::fileserv::file_and_error_handler;
14: 12: 
15: 13:     // Setting get_configuration(None) means we'll be using cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos's env values
16: 14:     // For deployment these variables are:
17: 15:     // <https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-specialized-lyx-specialized-start-axum#executing-a-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-on-a-remote-machine-without-the-toolchain>
18: 16:     // Alternately a file can be specified such as Some("Cargo.toml")
19: 17:     // The file would need to be included with the executable when moved to deployment
20: 18:     let conf = get_configuration(Some("Cargo.toml")).unwrap();
21: 19:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
22: 20:     let addr = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
23: 21:     let routes = generate_route_list(App);
24: 22: 
25: 23: 
26: 24:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
27: 25:         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, App)
28: 26:         .fallback(file_and_error_handler)
29: 27:         .layer(tower_http::trace::TraceLayer::new_for_http())
30: 28:         .with_state(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options);
31: 29:     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
32: 30:     logging::log!("listening on http://{}", &addr);
33: 31:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
34: 32:         .await
35: 33:         .unwrap();
36: 34: }
37: 35: 
38: 36: #[cfg(not(feature = "ssr"))]
39: 37: pub fn main() {
40: 38:     // no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
41: 39:     // unless we want this to work with e.g., Trunk for a purely lyx-core-lyx_core_lyx-core-lyx_core_client-side lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
42: 40:     // see lib.rs for hydration function instead
43: 41: }
44: ```
```
