### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\authorization.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\authorization.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\authorization.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\authorization.rs
use futures_util::future::LocalBoxFuture;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;

use crate::service::types::{OrganisationId, Resource, SchemaName};

pub trait Authorizer: Sync + Send {
// fn grant_access_to_admin(
//     &self,
//     workspace_context: &(OrganisationId, SchemaName),
//     admin_email: &str,
// ) -> LocalBoxFuture<'_, Result<bool, String>>;

fn is_allowed(
&self,
workspace_context: &(OrganisationId, SchemaName),
user: &User,
resource: &Resource,
action: &str,
attributes: Option<&[&str]>,
) -> LocalBoxFuture<'_, Result<bool, String>>;

// async fn get_permitted_attributes(
//     &self,
//     workspace_context: &(OrganisationId, SchemaName),
//     user: &User,
//     resource: &ResourceContext,
//     action: &Action,
// ) -> Result<Vec<String>, String>;

// async fn enforce_with_context(
//     &self,
//     workspace_context: &(OrganisationId, SchemaName),
//     user: &User,
//     resource: &ResourceContext,
//     action: &Action,
//     context: HashMap<String, Value>,
// ) -> Result<bool>;
}
