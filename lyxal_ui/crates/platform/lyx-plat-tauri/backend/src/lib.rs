### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend\src\lib.rs
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;

#[cfg(feature = "ssr")]
pub mod fallback;

#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "hello_world")]
pub async fn hello_world_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server() -> Result<String, ServerFnError> {
Ok("Hey.".to_string())
}
