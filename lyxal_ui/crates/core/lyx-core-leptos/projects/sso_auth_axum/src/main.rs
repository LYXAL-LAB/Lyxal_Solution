### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_sso_auth_axum\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum\src\main.rs
2: ```rust
3: 1: use crate::ssr_imports::*;
4: 2: use axum::{
5: 3:     body::Body as AxumBody,
6: 4:     extract::{Path, State},
7: 5:     http::Request,
8: 6:     response::IntoResponse,
9: 7:     routing::get,
10: 8:     Router,
11: 9: };
12: 10: use axum_session::{Key, SessionConfig, SessionLayer, SessionStore};
13: 11: use axum_session_auth::{AuthConfig, AuthSessionLayer};
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{get_configuration, logging::log, provide_context, view};
15: 13: use lyx-core-axum::{
16: 14:     generate_route_list, handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context, LeptosRoutes,
17: 15: };
18: 16: use sqlx::sqlite::SqlitePoolOptions;
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum::{
20: 18:     auth::*, fallback::file_and_error_handler, state::AppState,
21: 19: };
22: 20: 
23: 21: async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler(
24: 22:     State(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state): State<AppState>,
25: 23:     auth_session: AuthSession,
26: 24:     path: Path<String>,
27: 25:     request: Request<AxumBody>,
28: 26: ) -> impl IntoResponse {
29: 27:     log!("{:?}", path);
30: 28: 
31: 29:     handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(
32: 30:         move || {
33: 31:             provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.clone());
34: 32:             provide_context(auth_session.clone());
35: 33:             provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.pool.clone());
36: 34:         },
37: 35:         request,
38: 36:     )
39: 37:     .await
40: 38: }
41: 39: 
42: 40: pub async fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler(
43: 41:     auth_session: AuthSession,
44: 42:     State(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state): State<AppState>,
45: 43:     axum::extract::State(option): axum::extract::State<lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions>,
46: 44:     request: Request<AxumBody>,
47: 45: ) -> axum::response::Response {
48: 46:     let handler = lyx-core-axum::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async_with_context(
49: 47:         option.clone(),
50: 48:         move || {
51: 49:             provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.clone());
52: 50:             provide_context(auth_session.clone());
53: 51:             provide_context(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.pool.clone());
54: 52:         },
55: 53:         move || view! {  <lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum::App/> },
56: 54:     );
57: 55: 
58: 56:     handler(request).await.into_response()
59: 57: }
60: 58: 
61: 59: #[tokio::main]
62: 60: async fn main() {
63: 61:     simple_logger::init_with_level(log::Level::Info)
64: 62:         .expect("couldn't initialize logging");
65: 63: 
66: 64:     let pool = SqlitePoolOptions::new()
67: 65:         .connect("sqlite:sso.db")
68: 66:         .await
69: 67:         .expect("Could not make pool.");
70: 68: 
71: 69:     // Auth section
72: 70:     let session_config = SessionConfig::default()
73: 71:         .with_table_name("sessions_table")
74: 72:         .with_key(Key::generate())
75: 73:         .with_database_key(Key::generate());
76: 74:     // .with_security_mode(SecurityMode::PerSession); // FIXME did this dislyx-platform-lyx_platform_lyx-platform-lyx_platform_appear?
77: 75: 
78: 76:     let auth_config = AuthConfig::<i64>::default();
79: 77:     let session_store = SessionStore::<SessionSqlitePool>::new(
80: 78:         Some(pool.clone().into()),
81: 79:         session_config,
82: 80:     )
83: 81:     .await
84: 82:     .unwrap();
85: 83: 
86: 84:     sqlx::migrate!()
87: 85:         .run(&pool)
88: 86:         .await
89: 87:         .expect("could not run SQLx migrations");
90: 88: 
91: 89:     // Setting this to None means we'll be using cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos and its env vars
92: 90:     let conf = get_configuration(None).unwrap();
93: 91:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
94: 92:     let addr = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
95: 93:     let routes = generate_route_list(lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum::App);
96: 94: 
97: 95:     // We create our lyx-core-lyx_core_lyx-core-lyx_core_client using provided environment variables.
98: 96:     let lyx-core-lyx_core_lyx-core-lyx_core_client = oauth2::lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic::BasicClient::new(
99: 97:         oauth2::ClientId::new(
100: 98:             std::env::var("G_AUTH_CLIENT_ID")
101: 99:                 .expect("G_AUTH_CLIENT_ID Env var to be set."),
102: 100:         ),
103: 101:         Some(oauth2::ClientSecret::new(
104: 102:             std::env::var("G_AUTH_SECRET")
105: 103:                 .expect("G_AUTH_SECRET Env var to be set"),
106: 104:         )),
107: 105:         oauth2::AuthUrl::new(
108: 106:             "https://accounts.google.com/o/oauth2/v2/auth".to_string(),
109: 107:         )
110: 108:         .unwrap(),
111: 109:         Some(
112: 110:             oauth2::TokenUrl::new(
113: 111:                 "https://oauth2.googleapis.com/token".to_string(),
114: 112:             )
115: 113:             .unwrap(),
116: 114:         ),
117: 115:     )
118: 116:     .set_redirect_uri(
119: 117:         oauth2::RedirectUrl::new(
120: 118:             std::env::var("REDIRECT_URL")
121: 119:                 .expect("REDIRECT_URL Env var to be set"),
122: 120:         )
123: 121:         .unwrap(),
124: 122:     );
125: 123: 
126: 124:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = AppState {
127: 125:         lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
128: 126:         pool: pool.clone(),
129: 127:         lyx-core-lyx_core_lyx-core-lyx_core_client,
130: 128:     };
131: 129: 
132: 130:     // build our lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with a route
133: 131:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
134: 132:         .route(
135: 133:             "/api/*fn_name",
136: 134:             get(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler).post(lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_handler),
137: 135:         )
138: 136:         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_handler(routes, get(lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_handler))
139: 137:         .fallback(file_and_error_handler)
140: 138:         .layer(
141: 139:             AuthSessionLayer::<User, i64, SessionSqlitePool, SqlitePool>::new(
142: 140:                 Some(pool.clone()),
143: 141:             )
144: 142:             .with_config(auth_config),
145: 143:         )
146: 144:         .layer(SessionLayer::new(session_store))
147: 145:         .with_state(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state);
148: 146: 
149: 147:     // run our lyx-platform-lyx_platform_lyx-platform-lyx_platform_app with hyper
150: 148:     // `axum::Server` is a re-export of `hyper::Server`
151: 149:     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
152: 150:     log!("listening on http://{}", &addr);
153: 151:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
154: 152:         .await
155: 153:         .unwrap();
156: 154: }
157: ```
```
