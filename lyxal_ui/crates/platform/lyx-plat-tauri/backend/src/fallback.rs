### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\fallback.rs
use axum::{
body::Body,
extract::State,
http::{Request, Response, StatusCode, Uri},
response::{IntoResponse, Response as AxumResponse},
};
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{view, LeptosOptions};
use tower::ServiceExt;
use tower_http::services::ServeDir;

pub async fn file_and_error_handler(
uri: Uri,
State(options): State<LeptosOptions>,
req: Request<Body>,
) -> AxumResponse {
let root = options.site_root.clone();
let res = get_static_file(uri.clone(), &root).await.unwrap();

if res.status() == StatusCode::OK {
res.into_response()
} else {
let handler = lyx-core-axum::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream(options.to_owned(), move || view! { 404 });
handler(req).await.into_response()
}
}

async fn get_static_file(uri: Uri, root: &str) -> Result<Response<Body>, (StatusCode, String)> {
let req = Request::builder().uri(uri.clone()).body(Body::empty()).unwrap();
match ServeDir::new(root).oneshot(req).await {
Ok(res) => Ok(res.into_response()),
Err(err) => {
Err((StatusCode::INTERNAL_SERVER_ERROR, format!("Something went wrong: {err}")))
}
}
}
