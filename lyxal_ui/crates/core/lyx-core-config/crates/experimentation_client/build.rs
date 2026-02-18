### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\build.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\build.rs
fn main() {
let crate_dir = std::env!("CARGO_MANIFEST_DIR");
let mut config: cbindgen::Config = Default::default();
config.language = cbindgen::Language::C;
cbindgen::generate_with_config(crate_dir, config)
.expect("Failed to generate bindings")
.write_to_file("../../headers/liblyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client.h");
}
