1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
10: 8: ```rust
11: 9: use chrono::{DateTime, Utc};
12: 10: use diesel::prelude::AsChangeset;
13: 11: use serde::Serialize;
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
15: 13:     Overrides,
16: 14:     database::{
17: 15:         models::{ChangeReason, Description},
18: 16:         schema::contexts,
19: 17:     },
20: 18: };
21: 19: 
22: 20: #[derive(Serialize, AsChangeset)]
23: 21: #[diesel(table_name = contexts)]
24: 22: pub(crate) struct UpdateContextOverridesChangeset {
25: 23:     pub override_id: String,
26: 24:     #[serde(rename = "override")]
27: 25:     pub override_: Overrides,
28: 26:     pub last_modified_at: DateTime<Utc>,
29: 27:     pub last_modified_by: String,
30: 28:     pub description: Option<Description>,
31: 29:     pub change_reason: ChangeReason,
32: 30: }
33: 31: ```
34: 32: ```
35: 33: ```
36: 34: ```
37: ```
```

