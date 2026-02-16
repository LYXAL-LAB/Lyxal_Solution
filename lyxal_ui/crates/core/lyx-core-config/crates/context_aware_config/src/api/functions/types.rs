1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
10: 8: ```rust
11: 9: use diesel::{Selectable, prelude::Queryable};
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::{
13: 11:     models::cac::{FunctionCode, FunctionRuntimeVersion, FunctionType},
14: 12:     schema::functions,
15: 13: };
16: 14: 
17: 15: #[derive(Clone, Selectable, Queryable)]
18: 16: #[diesel(table_name = functions)]
19: 17: pub struct FunctionInfo {
20: 18:     pub function_name: String,
21: 19:     pub function_type: FunctionType,
22: 20:     pub published_code: Option<FunctionCode>,
23: 21:     pub published_runtime_version: Option<FunctionRuntimeVersion>,
24: 22: }
25: 23: ```
26: 24: ```
27: 25: ```
28: 26: ```
29: ```
```

