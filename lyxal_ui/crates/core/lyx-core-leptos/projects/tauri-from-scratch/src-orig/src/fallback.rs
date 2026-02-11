### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\fallback.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\fallback.rs
2: ```rust
3: 1: use axum::{
4: 2:     body::Body,
5: 3:     extract::State,
6: 4:     http::{Request, Response, StatusCode, Uri},
7: 5:     response::{IntoResponse, Response as AxumResponse},
8: 6: };
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{prelude::LeptosOptions, view};
10: 8: use tower::ServiceExt;
11: 9: use tower_http::services::ServeDir;
12: 10: 
13: 11: pub async fn file_and_error_handler(
14: 12:     uri: Uri,
15: 13:     State(options): State<LeptosOptions>,
16: 14:     req: Request<Body>,
17: 15: ) -> AxumResponse {
18: 16:     let root = options.site_root.clone();
19: 17:     let res = get_static_file(uri.clone(), &root).await.unwrap();
20: 18: 
21: 19:     if res.status() == StatusCode::OK {
22: 20:         res.into_response()
23: 21:     } else {
24: 22:         let handler = lyx-core-axum::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream(move || view! {404});
25: 23:         handler(req).await.into_response()
26: 24:     }
27: 25: }
28: 26: 
29: 27: async fn get_static_file(
30: 28:     uri: Uri,
31: 29:     root: &str,
32: 30: ) -> Result<Response<Body>, (StatusCode, String)> {
33: 31:     let req = Request::builder()
34: 32:         .uri(uri.clone())
35: 33:         .body(Body::empty())
36: 34:         .unwrap();
37: 35:     match ServeDir::new(root).oneshot(req).await {
38: 36:         Ok(res) => Ok(res.into_response()),
39: 37:         Err(err) => Err((
40: 38:             StatusCode::INTERNAL_SERVER_ERROR,
41: 39:             format!("Something went wrong: {err}"),
42: 40:         )),
43: 41:     }
44: 42: }
45: ```
```
