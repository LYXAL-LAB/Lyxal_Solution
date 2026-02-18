### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\types.rs
use diesel::{Selectable, prelude::Queryable};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::{
models::cac::{FunctionCode, FunctionRuntimeVersion, FunctionType},
schema::functions,
};

#[derive(Clone, Selectable, Queryable)]
#[diesel(table_name = functions)]
pub struct FunctionInfo {
pub function_name: String,
pub function_type: FunctionType,
pub published_code: Option<FunctionCode>,
pub published_runtime_version: Option<FunctionRuntimeVersion>,
}
