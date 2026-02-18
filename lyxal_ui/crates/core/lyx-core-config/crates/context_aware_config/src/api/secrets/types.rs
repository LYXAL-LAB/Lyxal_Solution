### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\types.rs
use diesel::query_builder::AsChangeset;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::{
models::{ChangeReason, Description},
schema::secrets,
};

#[derive(Debug, Clone, AsChangeset)]
#[diesel(table_name = secrets)]
pub struct UpdateSecretChangeset {
pub encrypted_value: Option<String>,
pub description: Option<Description>,
pub change_reason: ChangeReason,
}
