### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\lib.rs
pub mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;

#[cfg(feature = "hydrate")]
#[wasm_bindgen::prelude::wasm_bindgen]
pub fn hydrate() {
use lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
console_error_panic_hook::set_once();
lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount::hydrate_body(App);
}
