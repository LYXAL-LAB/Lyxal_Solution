### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro\build.rs
use rustc_version::{version_meta, Channel};

fn main() {
// Set cfg flags depending on release channel
if matches!(version_meta().unwrap().channel, Channel::Nightly) {
println!("cargo:rustc-cfg=rustc_nightly");
}
}
