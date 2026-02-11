### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-workers\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-workers\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\lib.rs
46: 44: ```rust
47: 45: //! Setup our Cloudflare worker (`feature == "ssr"`) and our lyx-core-lyx_core_lyx-core-lyx_core_leptos hydration function (`feature ==
48: 46: //! "hydrate"`)
49: 47: 
50: 48: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
51: 49: 
52: 50: #[cfg(feature = "ssr")]
53: 51: use worker::*;
54: 52: 
55: 53: use crate::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
56: 54: 
57: 55: mod api;
58: 56: mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;
59: 57: mod components;
60: 58: 
61: 59: #[cfg(feature = "ssr")]
62: 60: mod serve_static;
63: 61: 
64: 62: #[cfg(feature = "ssr")]
65: 63: async fn router(env: Env) -> axum::Router {
66: 64:     use std::sync::Arc;
67: 65: 
68: 66:     use axum::{routing::post, Extension};
69: 67:     use lyx-core-axum::{generate_route_list, LeptosRoutes};
70: 68: 
71: 69:     use crate::api::register_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_functions;
72: 70: 
73: 71:     // Match what's in Cargo.toml
74: 72:     // Doesn't seem to be able to do this automatically
75: 73:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = LeptosOptions {
76: 74:         output_name: "lyx-core-lyx_core_lyx-core-lyx_core_leptos_worker".into(),
77: 75:         site_root: "public".into(),
78: 76:         site_pkg_dir: "pkg".into(),
79: 77:         env: lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::Env::DEV,
80: 78:         site_addr: "127.0.0.1:8787".parse().unwrap(),
81: 79:         reload_port: 3001,
82: 80:         reload_external_port: None,
83: 81:         reload_ws_protocol: lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config::ReloadWSProtocol::WS,
84: 82:         not_found_path: "/404".into(),
85: 83:         hash_file: "hash.txt".into(),
86: 84:         hash_files: false,
87: 85:     };
88: 86:     let routes = generate_route_list(|| view! { <App /> });
89: 87: 
90: 88:     register_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_functions();
91: 89: 
92: 90:     // build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
93: 91:     axum::Router::new()
94: 92:         .route("/api/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
95: 93:         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, || view! { <App/> })
96: 94:         .fallback(serve_static::serve_static) // <- Serve Workers Sites static files (assets dir)
97: 95:         .with_state(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options)
98: 96:         .layer(Extension(Arc::new(env))) // <- Allow lyx-core-lyx_core_lyx-core-lyx_core_leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions to access Worker stuff
99: 97: }
100: 98: 
101: 99: #[cfg(feature = "ssr")]
102: 100: #[event(fetch)]
103: 101: async fn fetch(
104: 102:     req: HttpRequest,
105: 103:     env: Env,
106: 104:     _ctx: Context,
107: 105: ) -> Result<axum::http::Response<axum::body::Body>> {
108: 106:     use tower_service::Service;
109: 107: 
110: 108:     console_error_panic_hook::set_once();
111: 109: 
112: 110:     Ok(router(env).await.call(req).await?)
113: 111: }
114: 112: 
115: 113: #[cfg(feature = "hydrate")]
116: 114: #[wasm_bindgen::prelude::wasm_bindgen]
117: 115: pub fn hydrate() {
118: 116:     _ = console_log::init_with_level(log::Level::Debug);
119: 117:     console_error_panic_hook::set_once();
120: 118: 
121: 119:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount_to_body(|| view! { <App/> });
122: 120: }
123: 121: ```
124: 122: ```
125: 123: ```
126: 124: ```
127: 125: ```
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: 130: ```
133: 131: ```
134: 132: ```
135: 133: ```
136: 134: ```
137: 135: ```
138: 136: ```
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: ```
```
