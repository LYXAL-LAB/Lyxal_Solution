### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\lib.rs
pub mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;

#[cfg(feature = "ssr")]
pub mod db;
pub mod model;

#[cfg(feature = "hydrate")]
#[wasm_bindgen::prelude::wasm_bindgen]
pub fn hydrate() {
use crate::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
console_error_panic_hook::set_once();
lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount::hydrate_body(App);
}
