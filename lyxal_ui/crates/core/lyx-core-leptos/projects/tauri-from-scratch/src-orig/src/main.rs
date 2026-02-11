### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\main.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: #[tokio::main]
5: 3: async fn main() {
6: 4:     use axum::{
7: 5:         body::Body,
8: 6:         extract::{Request, State},
9: 7:         response::IntoResponse,
10: 8:         routing::get,
11: 9:         Router,
12: 10:     };
13: 11:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log;
14: 12:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
15: 13:     use lyx-core-axum::{generate_route_list, LeptosRoutes};
16: 14:     use lyx-core-lyx_core_lyx-core-src-orig::{
17: 15:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::{shell, App},
18: 16:         fallback::file_and_error_handler,
19: 17:     };
20: 18:     use tower_http::cors::CorsLayer;
21: 19: 
22: 20:     let conf = get_configuration(None).unwrap();
23: 21:     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
24: 22:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
25: 23:     // Generate the list of routes in your Leptos App
26: 24:     let routes = generate_route_list(App);
27: 25: 
28: 26:     #[derive(Clone, Debug, axum_macros::FromRef)]
29: 27:     pub struct ServerState {
30: 28:         pub options: LeptosOptions,
31: 29:         pub routes: Vec<lyx-core-axum::AxumRouteListing>,
32: 30:     }
33: 31: 
34: 32:     let state = ServerState {
35: 33:         options: lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
36: 34:         routes: routes.clone(),
37: 35:     };
38: 36: 
39: 37:     pub async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler(
40: 38:         State(state): State<ServerState>,
41: 39:         request: Request<Body>,
42: 40:     ) -> impl IntoResponse {
43: 41:         lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(
44: 42:             move || {
45: 43:                 provide_context(state.clone());
46: 44:             },
47: 45:             request,
48: 46:         )
49: 47:         .await
50: 48:         .into_response()
51: 49:     }
52: 50: 
53: 51:     let cors = CorsLayer::new()
54: 52:         .allow_methods([axum::http::Method::GET, axum::http::Method::POST])
55: 53:         .allow_origin(
56: 54:             "tauri://localhost"
57: 55:                 .parse::<axum::http::HeaderValue>()
58: 56:                 .unwrap(),
59: 57:         )
60: 58:         .allow_headers(vec![axum::http::header::CONTENT_TYPE]);
61: 59: 
62: 60:     pub async fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler(
63: 61:         State(state): State<ServerState>,
64: 62:         req: Request<Body>,
65: 63:     ) -> axum::response::Response {
66: 64:         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = state.options.clone();
67: 65:         let handler = lyx-core-axum::render_route_with_context(
68: 66:             state.routes.clone(),
69: 67:             move || {
70: 68:                 provide_context("...");
71: 69:             },
72: 70:             move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone()),
73: 71:         );
74: 72:         handler(axum::extract::State(state), req)
75: 73:             .await
76: 74:             .into_response()
77: 75:     }
78: 76: 
79: 77:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
80: 78:         .route(
81: 79:             "/api/{*fn_name}",
82: 80:             get(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler).post(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler),
83: 81:         )
84: 82:         .layer(cors)
85: 83:         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_handler(routes, get(lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler))
86: 84:         .fallback(file_and_error_handler)
87: 85:         .with_state(state);
88: 86: 
89: 87:     // run our lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with hyper
90: 88:     // `axum::Server` is a re-export of `hyper::Server`
91: 89:     log!("listening on http://{}", &addr);
92: 90:     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
93: 91:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
94: 92:         .await
95: 93:         .unwrap();
96: 94: }
97: 95: 
98: 96: #[cfg(feature = "csr")]
99: 97: pub fn main() {
100: 98:     lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::lyx-core-lyx_core_lyx-core-lyx_core_client::set_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_url("http://127.0.0.1:3000");
101: 99:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount::mount_to_body(lyx-core-lyx_core_lyx-core-src-orig::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App);
102: 100: }
103: ```
```
