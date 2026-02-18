pub mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;
#[cfg(feature = "ssr")]
pub mod fallback;

#[cfg(feature = "hydrate")]
#[wasm_bindgen::prelude::wasm_bindgen]
pub fn hydrate() {
console_error_panic_hook::set_once();
lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount::hydrate_body(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App);
}
