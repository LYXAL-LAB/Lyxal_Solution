### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\main.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: #[tokio::main]
5: 3: async fn main() {
6: 4:     use axum::Router;
7: 5:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log;
8: 6:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
9: 7:     use lyx-core-axum::{generate_route_list, LeptosRoutes};
10: 8:     use lyx-core-lyx_core_lyx_core_hexagonal_architecture::{
11: 9:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*,
12: 10:         config::config,
13: 11:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types::{HandlerStructAlias, ServerState},
14: 12:     };
15: 13: 
16: 14:     let conf = get_configuration(None).unwrap();
17: 15:     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
18: 16:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
19: 17:     let routes = generate_route_list(App);
20: 18:     let handler = config();
21: 19:     let handler_c = handler.clone();
22: 20:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_state = ServerState {
23: 21:         handler,
24: 22:         lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
25: 23:     };
26: 24:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
27: 25:         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context(
28: 26:             &lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_state,
29: 27:             routes,
30: 28:             move || provide_context(handler_c.clone()),
31: 29:             {
32: 30:                 let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
33: 31:                 move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
34: 32:             },
35: 33:         )
36: 34:         .fallback(lyx-core-axum::file_and_error_handler::<
37: 35:             ServerState<HandlerStructAlias>,
38: 36:             _,
39: 37:         >(shell))
40: 38:         .with_state(lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_state);
41: 39: 
42: 40:     log!("listening on http://{}", &addr);
43: 41:     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
44: 42:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
45: 43:         .await
46: 44:         .unwrap();
47: 45: }
48: 46: 
49: 47: #[cfg(not(feature = "ssr"))]
50: 48: pub fn main() {
51: 49:     // no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
52: 50:     // unless we want this to work with e.g., Trunk for pure lyx-core-lyx_core_lyx-core-lyx_core_client-side testing
53: 51:     // see lib.rs for hydration function instead
54: 52: }
55: ```
```
