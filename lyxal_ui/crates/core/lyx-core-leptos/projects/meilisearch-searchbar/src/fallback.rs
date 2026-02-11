### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-meilisearch-searchbar\src\fallback.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx-core-meilisearch-searchbar\src\fallback.rs
2: ```rust
3: 1: use axum::{
4: 2:     body::Body,
5: 3:     extract::State,
6: 4:     http::{Request, Response, StatusCode, Uri},
7: 5:     response::{IntoResponse, Response as AxumResponse},
8: 6: };
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{view, LeptosOptions};
10: 8: use tower::ServiceExt;
11: 9: use tower_http::services::ServeDir;
12: 10: 
13: 11: pub async fn file_and_error_handler(
14: 12:     uri: Uri,
15: 13:     State(options): State<LeptosOptions>,
16: 14:     req: Request<Body>,
17: 15: ) -> AxumResponse {
18: 16:     let root = options.site_root.clone();
19: 17:     log::debug!("uri = {uri:?} root = {root} ");
20: 18:     let res = get_static_file(uri.clone(), &root).await.unwrap();
21: 19: 
22: 20:     if res.status() == StatusCode::OK {
23: 21:         res.into_response()
24: 22:     } else {
25: 23:         let handler = lyx-core-axum::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream(
26: 24:             options.to_owned(),
27: 25:             || view! {"Error! Error! Error!"},
28: 26:         );
29: 27:         handler(req).await.into_response()
30: 28:     }
31: 29: }
32: 30: 
33: 31: async fn get_static_file(uri: Uri, root: &str) -> Result<Response<Body>, (StatusCode, String)> {
34: 32:     let req = Request::builder()
35: 33:         .uri(uri.clone())
36: 34:         .body(Body::empty())
37: 35:         .unwrap();
38: 36:     // `ServeDir` implements `tower::Service` so we can call it with `tower::ServiceExt::oneshot`
39: 37:     // This path is relative to the cargo root
40: 38:     match ServeDir::new(root).oneshot(req).await {
41: 39:         Ok(res) => Ok(res.into_response()),
42: 40:         Err(err) => Err((
43: 41:             StatusCode::INTERNAL_SERVER_ERROR,
44: 42:             format!("Something went wrong: {}", err),
45: 43:         )),
46: 44:     }
47: 45: }
48: ```
```
