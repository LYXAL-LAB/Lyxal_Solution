1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.rs
10: 8: ```rust
11: 9: use std::{collections::HashMap, hash::Hash};
12: 10: 
13: 11: use open_feature::OpenFeature;
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider::{
15: 13:     ConfigurationOptions, ExperimentationOptions, PollingStrategy, RefreshStrategy,
16: 14:     SuperpositionOptions, SuperpositionProvider, SuperpositionProviderOptions,
17: 15: };
18: 16: use tokio::time::{sleep, Duration};
19: 17: 
20: 18: #[tokio::main]
21: 19: async fn main() {
22: 20:     env_logger::init();
23: 21: 
24: 22:     let mut api = OpenFeature::singleton_mut().await;
25: 23:     let options = SuperpositionProviderOptions {
26: 24:         endpoint: "http://localhost:8080/".to_string(),
27: 25:         token: "your_token_here".to_string(),
28: 26:         org_id: "localorg".to_string(),
29: 27:         workspace_id: "test".to_string(),
30: 28:         fallback_config: None,
31: 29:         evaluation_cache: None,
32: 30:         refresh_strategy: RefreshStrategy::Polling(PollingStrategy {
33: 31:             interval: 1,
34: 32:             timeout: None,
35: 33:         }),
36: 34:         experimentation_options: Some(ExperimentationOptions {
37: 35:             refresh_strategy: RefreshStrategy::Polling(PollingStrategy {
38: 36:                 interval: 1,
39: 37:                 timeout: None,
40: 38:             }),
41: 39:             evaluation_cache: None,
42: 40:             default_toss: None,
43: 41:         }),
44: 42:     };
45: 43:     api.set_provider(SuperpositionProvider::new(options)).await;
46: 44:     let lyx-core-lyx_core_lyx-core-lyx_core_client = api.create_lyx-core-lyx_core_lyx-core-lyx_core_client();
47: 45:     sleep(Duration::from_secs(3)).await;
48: 46:     let context = open_feature::EvaluationContext {
49: 47:         custom_fields: HashMap::from([(
50: 48:             "d1".to_string(),
51: 49:             open_feature::EvaluationContextFieldValue::String("d1".to_string()),
52: 50:         )]),
53: 51:         targeting_key: Some("15".to_string()),
54: 52:     };
55: 53:     let val = lyx-core-lyx_core_lyx-core-lyx_core_client
56: 54:         .get_string_value("string", Some(&context), None)
57: 55:         .await
58: 56:         .unwrap();
59: 57:     println!("Value: {}", val);
60: 58: 
61: 59:     println!("Hello, world!");
62: 60: }
63: 61: ```
64: 62: ```
65: 63: ```
66: 64: ```
67: ```
```

