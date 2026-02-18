### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\types.rs
use chrono::{DateTime, Utc};
use diesel::prelude::AsChangeset;
use serde::Serialize;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
Overrides,
database::{
models::{ChangeReason, Description},
schema::contexts,
},
};

#[derive(Serialize, AsChangeset)]
#[diesel(table_name = contexts)]
pub(crate) struct UpdateContextOverridesChangeset {
pub override_id: String,
#[serde(rename = "override")]
pub override_: Overrides,
pub last_modified_at: DateTime<Utc>,
pub last_modified_by: String,
pub description: Option<Description>,
pub change_reason: ChangeReason,
}
