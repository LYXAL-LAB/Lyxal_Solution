### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
cfg_if::cfg_if! {
if #[cfg(feature = "hydrate")] {
use lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App;
use wasm_bindgen::prelude::wasm_bindgen;

#[wasm_bindgen]
pub fn hydrate() {
_ = console_log::init_with_level(log::Level::Debug);
#[cfg(debug_assertions)]
console_error_panic_hook::set_once();
lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount_to_body(App);
}
}
}
