### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core\src\lib.rs
uniffi::setup_scaffolding!("lyx-core-lyx_core_lyx-core-lyx_core_superposition_lyx-core-lyx_core_lyx-core-lyx_core_client");

pub mod config;
pub mod experiment;
pub mod ffi;
pub mod ffi_legacy;

pub use config::{eval_config, eval_config_with_reasoning, merge, MergeStrategy};
pub use experiment::{
get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants, get_satisfied_experiments, Experiments, FfiExperiment,
};
pub use ffi_legacy::{
core_free_string, core_get_resolved_config, core_get_resolved_config_with_reasoning,
};

pub const VERSION: &str = env!("CARGO_PKG_VERSION");
