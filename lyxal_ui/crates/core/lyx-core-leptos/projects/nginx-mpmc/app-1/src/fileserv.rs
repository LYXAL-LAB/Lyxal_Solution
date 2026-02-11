### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_app-1\src\fileserv.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\nginx-mpmc\lyx-core-lyx-platform-lyx_platform_lyx-core-lyx-platform-lyx_platform_app-1\src\fileserv.rs
2: ```rust
3: 1: use axum::{
4: 2:     body::Body,
5: 3:     extract::State,
6: 4:     response::IntoResponse,
7: 5:     http::{Request, Response, StatusCode, Uri},
8: 6: };
9: 7: use axum::response::Response as AxumResponse;
10: 8: use tower::ServiceExt;
11: 9: use tower_http::services::ServeDir;
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
13: 11: use crate::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App;
14: 12: 
15: 13: pub async fn file_and_error_handler(uri: Uri, State(options): State<LeptosOptions>, req: Request<Body>) -> AxumResponse {
16: 14:     let root = options.site_root.clone();
17: 15:     tracing::debug!("APP 1");
18: 16:     let res = get_static_file(uri.clone(), &root).await.unwrap();
19: 17: 
20: 18:     if res.status() == StatusCode::OK {
21: 19:         res.into_response()
22: 20:     } else {
23: 21:         let handler = lyx-core-axum::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream(options.to_owned(), App);
24: 22:         handler(req).await.into_response()
25: 23:     }
26: 24: }
27: 25: 
28: 26: async fn get_static_file(
29: 27:     uri: Uri,
30: 28:     root: &str,
31: 29: ) -> Result<Response<Body>, (StatusCode, String)> {
32: 30:     let req = Request::builder()
33: 31:         .uri(uri.clone())
34: 32:         .body(Body::empty())
35: 33:         .unwrap();
36: 34:     // `ServeDir` implements `tower::Service` so we can call it with `tower::ServiceExt::oneshot`
37: 35:     // This path is relative to the cargo root
38: 36:     match ServeDir::new(root).oneshot(req).await {
39: 37:         Ok(res) => Ok(res.into_response()),
40: 38:         Err(err) => Err((
41: 39:             StatusCode::INTERNAL_SERVER_ERROR,
42: 40:             format!("Something went wrong: {err}"),
43: 41:         )),
44: 42:     }
45: 43: }
46: ```
```
