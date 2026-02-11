### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\build.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\build.rs
2: ```rust
3: 1: use rustc_version::{version_meta, Channel};
4: 2: 
5: 3: fn main() {
6: 4:     // Set cfg flags depending on release channel
7: 5:     if matches!(version_meta().unwrap().channel, Channel::Nightly) {
8: 6:         println!("cargo:rustc-cfg=rustc_nightly");
9: 7:     }
10: 8: }
11: ```
```
