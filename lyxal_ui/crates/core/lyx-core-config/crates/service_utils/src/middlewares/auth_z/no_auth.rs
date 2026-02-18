### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
use futures_util::future::LocalBoxFuture;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;

use crate::service::types::{OrganisationId, Resource, SchemaName};

use super::authorization::Authorizer;

pub struct NoAuth;

impl Authorizer for NoAuth {
fn is_allowed(
&self,
_: &(OrganisationId, SchemaName),
_: &User,
_: &Resource,
_: &str,
_: Option<&[&str]>,
) -> LocalBoxFuture<'_, Result<bool, String>> {
Box::pin(async { Ok(true) })
}
}
