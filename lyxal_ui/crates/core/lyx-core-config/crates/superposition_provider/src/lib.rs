### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lib.rs
10: 8: ```rust
11: 9: pub mod lyx-core-lyx_core_lyx-core-lyx_core_client;
12: 10: pub mod provider;
13: 11: pub mod types;
14: 12: pub mod utils;
15: 13: 
16: 14: pub use lyx-core-lyx_core_lyx-core-lyx_core_client::*;
17: 15: pub use provider::*;
18: 16: pub use types::*;
19: 17: 
20: 18: pub use open_feature::{
21: 19:     provider::{ProviderMetadata, ProviderStatus, ResolutionDetails},
22: 20:     EvaluationContext,
23: 21: };
24: 22: 
25: 23: #[cfg(test)]
26: 24: mod tests {
27: 25:     use super::*;
28: 26: 
29: 27:     #[tokio::test]
30: 28:     async fn test_cac_config_creation() {
31: 29:         let lyx-core-lyx_core_lyx-core-lyx_core_superposition_options = SuperpositionOptions::new(
32: 30:             "http://localhost:8080".to_string(),
33: 31:             "test-token".to_string(),
34: 32:             "test-org".to_string(),
35: 33:             "test-workspace".to_string(),
36: 34:         );
37: 35: 
38: 36:         let config_options = ConfigurationOptions::new(
39: 37:             RefreshStrategy::OnDemand(OnDemandStrategy::default()),
40: 38:             None,
41: 39:             None,
42: 40:         );
43: 41: 
44: 42:         let cac_config = CacConfig::new(lyx-core-lyx_core_lyx-core-lyx_core_superposition_options, config_options);
45: 43: 
46: 44:         assert!(cac_config.get_cached_config().await.is_none());
47: 45:     }
48: 46: 
49: 47:     #[tokio::test]
50: 48:     async fn test_experimentation_config_creation() {
51: 49:         let lyx-core-lyx_core_lyx-core-lyx_core_superposition_options = SuperpositionOptions::new(
52: 50:             "http://localhost:8080".to_string(),
53: 51:             "test-token".to_string(),
54: 52:             "test-org".to_string(),
55: 53:             "test-workspace".to_string(),
56: 54:         );
57: 55: 
58: 56:         let exp_options = ExperimentationOptions::new(RefreshStrategy::OnDemand(
59: 57:             OnDemandStrategy::default(),
60: 58:         ));
61: 59: 
62: 60:         let exp_config = ExperimentationConfig::new(lyx-core-lyx_core_lyx-core-lyx_core_superposition_options, exp_options);
63: 61: 
64: 62:         // Test that we can get None for cached experiments initially
65: 63:         assert!(exp_config.get_cached_experiments().await.is_none());
66: 64:     }
67: 65: }
68: 66: ```
69: 67: ```
70: 68: ```
71: 69: ```
72: ```
```
