### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_superposition\src\resolve\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\resolve\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     HttpRequest, HttpResponse, Scope, routes,
13: 11:     web::{Data, Header, Json},
14: 12: };
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config::api::config::helpers::{
16: 14:     add_audit_id_to_header, add_config_version_to_header, add_last_modified_to_header,
17: 15:     generate_config_from_version, get_config_version, get_max_created_at,
18: 16:     is_not_modified, resolve, setup_query_data,
19: 17: };
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform::api::experiments::handlers::get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_helper;
21: 19: use serde_json::{Map, Value};
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{AppState, DbConnection, WorkspaceContext};
23: 21: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
25: 23:     api::config::{ContextPayload, MergeStrategy, ResolveConfigQuery},
26: 24:     custom_query::{self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, CustomQuery, DimensionQuery, QueryMap},
27: 25:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
28: 26: };
29: 27: 
30: 28: use super::types::IdentifierQuery;
31: 29: 
32: 30: pub fn endpoints() -> Scope {
33: 31:     Scope::new("").service(resolve_with_exp_handler)
34: 32: }
35: 33: 
36: 34: #[allow(clippy::too_many_arguments)]
37: 35: #[authorized]
38: 36: #[routes]
39: 37: #[get("")]
40: 38: #[post("")]
41: 39: async fn resolve_with_exp_handler(
42: 40:     req: HttpRequest,
43: 41:     body: Option<Json<ContextPayload>>,
44: 42:     merge_strategy: Header<MergeStrategy>,
45: 43:     db_conn: DbConnection,
46: 44:     dimension_params: DimensionQuery<QueryMap>,
47: 45:     query_filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ResolveConfigQuery>,
48: 46:     identifier_query: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<IdentifierQuery>,
49: 47:     workspace_context: WorkspaceContext,
50: 48:     state: Data<AppState>,
51: 49: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
52: 50:     let DbConnection(mut conn) = db_conn;
53: 51:     let query_filters = query_filters.into_inner();
54: 52:     let identifier_query = identifier_query.into_inner();
55: 53:     let max_created_at = get_max_created_at(&mut conn, &workspace_context.schema_name)
56: 54:         .map_err(|e| log::error!("failed to fetch max timestamp from event_log : {e}"))
57: 55:         .ok();
58: 56: 
59: 57:     if identifier_query.identifier.is_none() && is_not_modified(max_created_at, &req) {
60: 58:         return Ok(HttpResponse::NotModified().finish());
61: 59:     }
62: 60: 
63: 61:     let (is_smithy, mut query_data) = setup_query_data(&req, &body, &dimension_params)?;
64: 62:     let mut config_version =
65: 63:         get_config_version(&query_filters.version, &workspace_context)?;
66: 64: 
67: 65:     // This is needed as `generate_config_from_version` updates config_version value
68: 66:     // in case nothing was found either from query params or workspace settings
69: 67:     // This value is separately needed, as in the following check the value before the modification is required
70: 68:     let config_ver = config_version.to_owned();
71: 69: 
72: 70:     let mut config = generate_config_from_version(
73: 71:         &mut config_version,
74: 72:         &mut conn,
75: 73:         &workspace_context.schema_name,
76: 74:     )?;
77: 75: 
78: 76:     if let (None, Some(identifier)) = (config_ver, identifier_query.identifier) {
79: 77:         let context_map: &Map<String, Value> = &query_data;
80: 78:         let (lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants, _) = get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_helper(
81: 79:             &mut conn,
82: 80:             context_map.clone(),
83: 81:             &config.dimensions,
84: 82:             identifier,
85: 83:             &workspace_context,
86: 84:         )
87: 85:         .await?;
88: 86:         query_data.insert("variantIds".to_string(), lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants.into());
89: 87:     }
90: 88: 
91: 89:     let resolved_config = resolve(
92: 90:         &mut config,
93: 91:         query_data,
94: 92:         merge_strategy,
95: 93:         &mut conn,
96: 94:         &query_filters,
97: 95:         &workspace_context,
98: 96:         &state.master_encryption_key,
99: 97:     )?;
100: 98: 
101: 99:     let mut resp = HttpResponse::Ok();
102: 100:     add_last_modified_to_header(max_created_at, is_smithy, &mut resp);
103: 101:     add_audit_id_to_header(&mut conn, &mut resp, &workspace_context.schema_name);
104: 102:     add_config_version_to_header(&config_version, &mut resp);
105: 103:     Ok(resp.json(resolved_config))
106: 104: }
107: 105: ```
108: 106: ```
109: 107: ```
110: 108: ```
111: ```
```
