### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\lib.rs
2: ```rust
3: 1: pub mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;
4: 2: #[cfg(feature = "ssr")]
5: 3: pub mod fallback;
6: 4: 
7: 5: #[cfg(feature = "hydrate")]
8: 6: #[wasm_bindgen::prelude::wasm_bindgen]
9: 7: pub fn hydrate() {
10: 8:     console_error_panic_hook::set_once();
11: 9:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount::hydrate_body(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App);
12: 10: }
13: ```
```
