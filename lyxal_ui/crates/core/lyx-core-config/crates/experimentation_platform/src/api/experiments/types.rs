### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_platform\src\api\experiments\types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\types.rs
10: 8: ```rust
11: 9: use chrono::{DateTime, Utc};
12: 10: use diesel::prelude::AsChangeset;
13: 11: use serde::Serialize;
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments;
15: 13: 
16: 14: #[derive(Serialize, AsChangeset)]
17: 15: #[diesel(table_name = experiments)]
18: 16: pub struct StartedByChangeSet {
19: 17:     pub started_by: Option<String>,
20: 18:     pub started_at: Option<DateTime<Utc>>,
21: 19: }
22: 20: ```
23: 21: ```
24: 22: ```
25: 23: ```
26: ```
```
