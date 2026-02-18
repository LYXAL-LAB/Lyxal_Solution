### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
pub mod lyx-core-lyx_core_lyx-core-lyx_core_client;
pub mod provider;
pub mod types;
pub mod utils;

pub use lyx-core-lyx_core_lyx-core-lyx_core_client::*;
pub use provider::*;
pub use types::*;

pub use open_feature::{
provider::{ProviderMetadata, ProviderStatus, ResolutionDetails},
EvaluationContext,
};

#[cfg(test)]
mod tests {
use super::*;

#[tokio::test]
async fn test_cac_config_creation() {
let lyx-core-lyx_core_lyx-core-lyx_core_superposition_options = SuperpositionOptions::new(
"http://localhost:8080".to_string(),
"test-token".to_string(),
"test-org".to_string(),
"test-workspace".to_string(),
);

let config_options = ConfigurationOptions::new(
RefreshStrategy::OnDemand(OnDemandStrategy::default()),
None,
None,
);

let cac_config = CacConfig::new(lyx-core-lyx_core_lyx-core-lyx_core_superposition_options, config_options);

assert!(cac_config.get_cached_config().await.is_none());
}

#[tokio::test]
async fn test_experimentation_config_creation() {
let lyx-core-lyx_core_lyx-core-lyx_core_superposition_options = SuperpositionOptions::new(
"http://localhost:8080".to_string(),
"test-token".to_string(),
"test-org".to_string(),
"test-workspace".to_string(),
);

let exp_options = ExperimentationOptions::new(RefreshStrategy::OnDemand(
OnDemandStrategy::default(),
));

let exp_config = ExperimentationConfig::new(lyx-core-lyx_core_lyx-core-lyx_core_superposition_options, exp_options);

// Test that we can get None for cached experiments initially
assert!(exp_config.get_cached_experiments().await.is_none());
}
}
