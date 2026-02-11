### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_service_mode\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\main.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\main.rs
4: 2: ```rust
5: 3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\main.rs
6: 4: 2: ```rust
7: 5: 3: 1: #[cfg(feature = "ssr")]
8: 6: 4: 2: mod router {
9: 7: 5: 3:     use axum::{
10: 8: 6: 4:         Router,
11: 9: 7: 5:         http::{HeaderName, HeaderValue},
12: 10: 8: 6:     };
13: 11: 9: 7:     use clap::{Parser, Subcommand};
14: 12: 10: 8:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::{get_configuration, provide_context, use_context};
15: 13: 11: 9:     use lyx-core-axum::{ErrorHandler, LeptosRoutes, generate_route_list};
16: 14: 12: 10:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode::lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::{App, shell};
17: 15: 13: 11: 
18: 16: 14: 12:     #[derive(Parser)]
19: 17: 15: 13:     pub struct Cli {
20: 18: 16: 14:         #[command(subcommand)]
21: 19: 17: 15:         mode: Mode,
22: 20: 18: 16:     }
23: 21: 19: 17: 
24: 22: 20: 18:     #[derive(Subcommand)]
25: 23: 21: 19:     enum Mode {
26: 24: 22: 20:         Bare,
27: 25: 23: 21:         Fallback,
28: 26: 24: 22:         FallbackWithContext,
29: 27: 25: 23:         ErrorHandlerService,
30: 28: 26: 24:         ErrorHandlerServiceFallback,
31: 29: 27: 25:         RouteSitePkgNoFallback,
32: 30: 28: 26:     }
33: 31: 29: 27: 
34: 32: 30: 28:     impl From<Cli> for Router {
35: 33: 31: 29:         fn from(cli: Cli) -> Self {
36: 34: 32: 30:             let conf = get_configuration(None).unwrap();
37: 35: 33: 31:             let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
38: 36: 34: 32:             let routes = generate_route_list(App);
39: 37: 35: 33: 
40: 38: 36: 34:             match cli.mode {
41: 39: 37: 35:                 Mode::Bare => Router::new()
42: 40: 38: 36:                     .lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
43: 41: 39: 37:                         let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
44: 42: 40: 38:                         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
45: 43: 41: 39:                     })
46: 44: 42: 40:                     .with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
47: 45: 43: 41:                 Mode::Fallback => Router::new()
48: 46: 44: 42:                     .lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
49: 47: 45: 43:                         let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
50: 48: 46: 44:                         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
51: 49: 47: 45:                     })
52: 50: 48: 46:                     .fallback(lyx-core-axum::file_and_error_handler(shell))
53: 51: 49: 47:                     .with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
54: 52: 50: 48:                 Mode::FallbackWithContext => Router::new()
55: 53: 51: 49:                     .lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
56: 54: 52: 50:                         let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
57: 55: 53: 51:                         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
58: 56: 54: 52:                     })
59: 57: 55: 53:                     .fallback(lyx-core-axum::file_and_error_handler_with_context(
60: 58: 56: 54:                         move || {
61: 59: 57: 55:                             let opts =
62: 60: 58: 56:                                 use_context::<lyx-core-axum::ResponseOptions>()
63: 61: 59: 57:                                     .unwrap_or_default();
64: 62: 60: 58:                             opts.insert_header(
65: 63: 61: 59:                                 HeaderName::from_static(
66: 64: 62: 60:                                     "cross-origin-opener-policy",
67: 65: 63: 61:                                 ),
68: 66: 64: 62:                                 HeaderValue::from_static("same-origin"),
69: 67: 65: 63:                             );
70: 68: 66: 64:                             opts.insert_header(
71: 69: 67: 65:                                 HeaderName::from_static(
72: 70: 68: 66:                                     "cross-origin-embedder-policy",
73: 71: 69: 67:                                 ),
74: 72: 70: 68:                                 HeaderValue::from_static("require-corp"),
75: 73: 71: 69:                             );
76: 74: 72: 70:                             provide_context(opts);
77: 75: 73: 71:                         },
78: 76: 74: 72:                         shell,
79: 77: 75: 73:                     ))
80: 78: 76: 74:                     .with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
81: 79: 77: 75:                 Mode::ErrorHandlerService => Router::new()
82: 80: 78: 76:                     .lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
83: 81: 79: 77:                         let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
84: 82: 80: 78:                         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
85: 83: 81: 79:                     })
86: 84: 82: 80:                     .fallback_service(ErrorHandler::new(
87: 85: 83: 81:                         shell,
88: 86: 84: 82:                         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
89: 87: 85: 83:                     ))
90: 88: 86: 84:                     .with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
91: 89: 87: 85:                 Mode::ErrorHandlerServiceFallback => Router::new()
92: 90: 88: 86:                     .lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
93: 91: 89: 87:                         let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
94: 92: 90: 88:                         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
95: 93: 91: 89:                     })
96: 94: 92: 90:                     .fallback_service(
97: 95: 93: 91:                         lyx-core-axum::site_pkg_dir_service(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options)
98: 96: 94: 92:                             .fallback(ErrorHandler::new(
99: 97: 95: 93:                                 shell,
100: 98: 96: 94:                                 lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
101: 99: 97: 95:                             )),
102: 100: 98: 96:                     )
103: 101: 99: 97:                     .with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
104: 102: 100: 98:                 Mode::RouteSitePkgNoFallback => Router::new()
105: 103: 101: 99:                     .lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
106: 104: 102: 100:                         let lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
107: 105: 103: 101:                         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
108: 106: 104: 102:                     })
109: 107: 105: 103:                     .route_service(
110: 108: 106: 104:                         &lyx-core-axum::site_pkg_dir_service_route_path(
111: 109: 107: 105:                             &lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
112: 110: 108: 106:                         ),
113: 111: 109: 107:                         lyx-core-axum::site_pkg_dir_service(&lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
114: 112: 110: 108:                     )
115: 113: 111: 109:                     .fallback_service(ErrorHandler::new(
116: 114: 112: 110:                         shell,
117: 115: 113: 111:                         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone(),
118: 116: 114: 112:                     ))
119: 117: 115: 113:                     .with_state(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
120: 118: 116: 114:             }
121: 119: 117: 115:         }
122: 120: 118: 116:     }
123: 121: 119: 117: }
124: 122: 120: 118: 
125: 123: 121: 119: #[cfg(feature = "ssr")]
126: 124: 122: 120: #[tokio::main]
127: 125: 123: 121: async fn main() {
128: 126: 124: 122:     use axum::Router;
129: 127: 125: 123:     use clap::Parser;
130: 128: 126: 124:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::get_configuration;
131: 129: 127: 125: 
132: 130: 128: 126:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::from(router::Cli::parse());
133: 131: 129: 127:     let conf = get_configuration(None).unwrap();
134: 132: 130: 128:     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
135: 133: 131: 129:     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
136: 134: 132: 130:     // write out the port from the bounded local_addr to allow the caller to know how to connect.
137: 135: 133: 131:     println!("{}", listener.local_addr().unwrap().port());
138: 136: 134: 132:     axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
139: 137: 135: 133:         .await
140: 138: 136: 134:         .unwrap();
141: 139: 137: 135: }
142: 140: 138: 136: 
143: 141: 139: 137: #[cfg(not(feature = "ssr"))]
144: 142: 140: 138: pub fn main() {}
145: 143: 141: ```
146: 144: ```
147: ```
```
