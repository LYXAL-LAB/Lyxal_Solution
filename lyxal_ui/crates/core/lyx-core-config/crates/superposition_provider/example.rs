### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
use std::{collections::HashMap, hash::Hash};

use open_feature::OpenFeature;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider::{
ConfigurationOptions, ExperimentationOptions, PollingStrategy, RefreshStrategy,
SuperpositionOptions, SuperpositionProvider, SuperpositionProviderOptions,
};
use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() {
env_logger::init();

let mut api = OpenFeature::singleton_mut().await;
let options = SuperpositionProviderOptions {
endpoint: "http://localhost:8080/".to_string(),
token: "your_token_here".to_string(),
org_id: "localorg".to_string(),
workspace_id: "test".to_string(),
fallback_config: None,
evaluation_cache: None,
refresh_strategy: RefreshStrategy::Polling(PollingStrategy {
interval: 1,
timeout: None,
}),
experimentation_options: Some(ExperimentationOptions {
refresh_strategy: RefreshStrategy::Polling(PollingStrategy {
interval: 1,
timeout: None,
}),
evaluation_cache: None,
default_toss: None,
}),
};
api.set_provider(SuperpositionProvider::new(options)).await;
let lyx-core-lyx_core_lyx-core-lyx_core_client = api.create_lyx-core-lyx_core_lyx-core-lyx_core_client();
sleep(Duration::from_secs(3)).await;
let context = open_feature::EvaluationContext {
custom_fields: HashMap::from([(
"d1".to_string(),
open_feature::EvaluationContextFieldValue::String("d1".to_string()),
)]),
targeting_key: Some("15".to_string()),
};
let val = lyx-core-lyx_core_lyx-core-lyx_core_client
.get_string_value("string", Some(&context), None)
.await
.unwrap();
println!("Value: {}", val);

println!("Hello, world!");
}
