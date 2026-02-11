### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_sso_auth_axum\src\fallback.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum\src\fallback.rs
2: ```rust
3: 1: use crate::error_template::error_template;
4: 2: use axum::{
5: 3:     body::Body,
6: 4:     extract::State,
7: 5:     http::{Request, Response, StatusCode, Uri},
8: 6:     response::{IntoResponse, Response as AxumResponse},
9: 7: };
10: 8: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
11: 9: use tower::ServiceExt;
12: 10: use tower_http::services::ServeDir;
13: 11: 
14: 12: pub async fn file_and_error_handler(
15: 13:     uri: Uri,
16: 14:     State(options): State<LeptosOptions>,
17: 15:     req: Request<Body>,
18: 16: ) -> AxumResponse {
19: 17:     let root = options.site_root.clone();
20: 18:     let res = get_static_file(uri.clone(), &root).await.unwrap();
21: 19: 
22: 20:     if res.status() == StatusCode::OK {
23: 21:         res.into_response()
24: 22:     } else {
25: 23:         lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log!("{:?}:{}", res.status(), uri);
26: 24:         let handler =
27: 25:             lyx-core-axum::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream(options.to_owned(), || {
28: 26:                 error_template(RwSignal::new(lyx-core-lyx_core_lyx-core-lyx_core_leptos::Errors::default()))
29: 27:             });
30: 28:         handler(req).await.into_response()
31: 29:     }
32: 30: }
33: 31: 
34: 32: async fn get_static_file(
35: 33:     uri: Uri,
36: 34:     root: &str,
37: 35: ) -> Result<Response<Body>, (StatusCode, String)> {
38: 36:     let req = Request::builder()
39: 37:         .uri(uri.clone())
40: 38:         .body(Body::empty())
41: 39:         .unwrap();
42: 40:     // `ServeDir` implements `tower::Service` so we can call it with `tower::ServiceExt::oneshot`
43: 41:     // This path is relative to the cargo root
44: 42:     match ServeDir::new(root).oneshot(req).await {
45: 43:         Ok(res) => Ok(res.into_response()),
46: 44:         Err(err) => Err((
47: 45:             StatusCode::INTERNAL_SERVER_ERROR,
48: 46:             format!("Something went wrong: {}", err),
49: 47:         )),
50: 48:     }
51: 49: }
52: ```
```
