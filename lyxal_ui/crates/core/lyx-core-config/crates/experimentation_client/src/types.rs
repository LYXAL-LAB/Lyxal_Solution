### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_client\src\types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\types.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: 
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
14: 12:     api::experiments::ExperimentResponse,
15: 13:     database::models::experimentation::ExperimentGroup,
16: 14: };
17: 15: 
18: 16: #[derive(Clone, Debug)]
19: 17: pub struct Config {
20: 18:     pub tenant: String,
21: 19:     pub hostname: String,
22: 20:     pub poll_frequency: u64,
23: 21: }
24: 22: 
25: 23: pub type Experiments = Vec<ExperimentResponse>;
26: 24: 
27: 25: pub(crate) type ExperimentStore = HashMap<String, ExperimentResponse>;
28: 26: 
29: 27: pub(crate) type ExperimentGroupStore = HashMap<String, ExperimentGroup>;
30: 28: ```
31: 29: ```
32: 30: ```
33: 31: ```
34: ```
```
