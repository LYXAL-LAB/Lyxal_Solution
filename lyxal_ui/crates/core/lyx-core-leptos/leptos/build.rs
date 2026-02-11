### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\build.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\build.rs
2: ```rust
3: 1: use rustc_version::{version_meta, Channel};
4: 2: 
5: 3: fn main() {
6: 4:     let target = std::env::var("TARGET").unwrap_or_default();
7: 5: 
8: 6:     // Set cfg flags depending on release channel
9: 7:     if matches!(version_meta().unwrap().channel, Channel::Nightly) {
10: 8:         println!("cargo:rustc-cfg=rustc_nightly");
11: 9:     }
12: 10:     // Set cfg flag for getrandom wasm_js
13: 11:     if target == "wasm32-unknown-unknown" {
14: 12:         // Set a custom cfg flag for wasm builds
15: 13:         println!("cargo:rustc-cfg=getrandom_lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend=\"wasm_js\"");
16: 14:     }
17: 15: }
18: ```
```
