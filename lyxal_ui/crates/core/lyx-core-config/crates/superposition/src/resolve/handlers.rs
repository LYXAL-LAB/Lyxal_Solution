### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
use actix_web::{
HttpRequest, HttpResponse, Scope, routes,
web::{Data, Header, Json},
};
use lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config::api::config::helpers::{
add_audit_id_to_header, add_config_version_to_header, add_last_modified_to_header,
generate_config_from_version, get_config_version, get_max_created_at,
is_not_modified, resolve, setup_query_data,
};
use lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform::api::experiments::handlers::get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_helper;
use serde_json::{Map, Value};
use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{AppState, DbConnection, WorkspaceContext};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
api::config::{ContextPayload, MergeStrategy, ResolveConfigQuery},
custom_query::{self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, CustomQuery, DimensionQuery, QueryMap},
result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
};

use super::types::IdentifierQuery;

pub fn endpoints() -> Scope {
Scope::new("").service(resolve_with_exp_handler)
}

#[allow(clippy::too_many_arguments)]
#[authorized]
#[routes]
#[get("")]
#[post("")]
async fn resolve_with_exp_handler(
req: HttpRequest,
body: Option<Json<ContextPayload>>,
merge_strategy: Header<MergeStrategy>,
db_conn: DbConnection,
dimension_params: DimensionQuery<QueryMap>,
query_filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ResolveConfigQuery>,
identifier_query: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<IdentifierQuery>,
workspace_context: WorkspaceContext,
state: Data<AppState>,
) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
let DbConnection(mut conn) = db_conn;
let query_filters = query_filters.into_inner();
let identifier_query = identifier_query.into_inner();
let max_created_at = get_max_created_at(&mut conn, &workspace_context.schema_name)
.map_err(|e| log::error!("failed to fetch max timestamp from event_log : {e}"))
.ok();

if identifier_query.identifier.is_none() && is_not_modified(max_created_at, &req) {
return Ok(HttpResponse::NotModified().finish());
}

let (is_smithy, mut query_data) = setup_query_data(&req, &body, &dimension_params)?;
let mut config_version =
get_config_version(&query_filters.version, &workspace_context)?;

// This is needed as `generate_config_from_version` updates config_version value
// in case nothing was found either from query params or workspace settings
// This value is separately needed, as in the following check the value before the modification is required
let config_ver = config_version.to_owned();

let mut config = generate_config_from_version(
&mut config_version,
&mut conn,
&workspace_context.schema_name,
)?;

if let (None, Some(identifier)) = (config_ver, identifier_query.identifier) {
let context_map: &Map<String, Value> = &query_data;
let (lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants, _) = get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_helper(
&mut conn,
context_map.clone(),
&config.dimensions,
identifier,
&workspace_context,
)
.await?;
query_data.insert("variantIds".to_string(), lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants.into());
}

let resolved_config = resolve(
&mut config,
query_data,
merge_strategy,
&mut conn,
&query_filters,
&workspace_context,
&state.master_encryption_key,
)?;

let mut resp = HttpResponse::Ok();
add_last_modified_to_header(max_created_at, is_smithy, &mut resp);
add_audit_id_to_header(&mut conn, &mut resp, &workspace_context.schema_name);
add_config_version_to_header(&config_version, &mut resp);
Ok(resp.json(resolved_config))
}
