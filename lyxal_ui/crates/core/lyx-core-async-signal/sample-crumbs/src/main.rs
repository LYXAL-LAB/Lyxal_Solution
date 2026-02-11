### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-async-signal\sample-crumbs\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-async-signal\sample-crumbs\src\main.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\main.rs
26: 24: ```rust
27: 25: // Note: this is original axum template code. Nothing has changed.
28: 26: 
29: 27: #[cfg(feature = "ssr")]
30: 28: #[tokio::main]
31: 29: async fn main() {
32: 30:     use axum::Router;
33: 31:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log;
34: 32:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
35: 33:     use lyx-core-axum::{generate_route_list, LeptosRoutes};
36: 34:     use lyx-core-sample-crumbs::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
37: 35: 
38: 36:     let conf = get_configuration(None).unwrap();
39: 37:     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
40: 38:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
41: 39:     // Generate the list of routes in your Leptos App
42: 40:     let routes = generate_route_list(App);
43: 41: 
44: 42:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
45: 43:         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
46: 44:             let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
47: 45:             move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
48: 46:         })
49: 47:         .fallback(lyx-core-axum::file_and_error_handler(shell))
50: 48:         .with_state(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options);
51: 49: 
52: 50:     // run our lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with hyper
53: 51:     // `axum::Server` is a re-export of `hyper::Server`
54: 52:     log!("listening on http://{}", &addr);
55: 53:     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
56: 54:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
57: 55:         .await
58: 56:         .unwrap();
59: 57: }
60: 58: 
61: 59: #[cfg(not(feature = "ssr"))]
62: 60: pub fn main() {
63: 61:     // no lyx-core-lyx_core_lyx-core-lyx_core_client-side main function
64: 62:     // unless we want this to work with e.g., Trunk for pure lyx-core-lyx_core_lyx-core-lyx_core_client-side testing
65: 63:     // see lib.rs for hydration function instead
66: 64: }
67: 65: ```
68: 66: ```
69: 67: ```
70: 68: ```
71: 69: ```
72: 70: ```
73: 71: ```
74: 72: ```
75: 73: ```
76: 74: ```
77: 75: ```
78: 76: ```
79: ```
```
