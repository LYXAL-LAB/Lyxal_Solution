### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\audit_log\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\audit_log\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\audit_log\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\audit_log\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\audit_log\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\audit_log\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{Scope, get, web::Json};
12: 10: use chrono::{Duration, Utc};
13: 11: use diesel::{BoolExpressionMethods, ExpressionMethods, QueryDsl, RunQueryDsl};
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{DbConnection, WorkspaceContext};
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
17: 15:     PaginatedResponse, SortBy,
18: 16:     api::audit_log::AuditQueryFilters,
19: 17:     custom_query::{self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, PaginationParams},
20: 18:     database::{models::cac::EventLog, schema::event_log::dsl as event_log},
21: 19:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
22: 20: };
23: 21: 
24: 22: pub fn endpoints() -> Scope {
25: 23:     Scope::new("").service(list_handler)
26: 24: }
27: 25: 
28: 26: #[authorized]
29: 27: #[get("")]
30: 28: async fn list_handler(
31: 29:     workspace_context: WorkspaceContext,
32: 30:     filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<AuditQueryFilters>,
33: 31:     pagination_params: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<PaginationParams>,
34: 32:     db_conn: DbConnection,
35: 33: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<EventLog>>> {
36: 34:     let now = Utc::now();
37: 35:     let from_date = filters.from_date.unwrap_or(now - Duration::days(7));
38: 36:     let to_date = filters.to_date.unwrap_or(now);
39: 37: 
40: 38:     if from_date > to_date {
41: 39:         return Ok(Json(PaginatedResponse::default()));
42: 40:     }
43: 41: 
44: 42:     let DbConnection(mut conn) = db_conn;
45: 43: 
46: 44:     let query_builder = |filters: &AuditQueryFilters| {
47: 45:         let mut builder = event_log::event_log
48: 46:             .schema_name(&workspace_context.schema_name)
49: 47:             .into_boxed();
50: 48:         if let Some(tables) = filters.table.clone() {
51: 49:             builder = builder.filter(event_log::table_name.eq_any(tables.0));
52: 50:         }
53: 51:         if let Some(actions) = filters.action.clone() {
54: 52:             builder = builder.filter(event_log::action.eq_any(actions.0));
55: 53:         }
56: 54:         if let Some(username) = filters.username.clone() {
57: 55:             builder = builder.filter(event_log::user_name.eq(username));
58: 56:         }
59: 57:         builder.filter(
60: 58:             event_log::timestamp
61: 59:                 .ge(from_date)
62: 60:                 .and(event_log::timestamp.le(to_date)),
63: 61:         )
64: 62:     };
65: 63: 
66: 64:     let sort_by = filters.sort_by.unwrap_or(SortBy::Desc);
67: 65:     let base_query = query_builder(&filters);
68: 66:     let count_query = query_builder(&filters);
69: 67: 
70: 68:     let base_query = match sort_by {
71: 69:         SortBy::Desc => base_query.order(event_log::timestamp.desc()),
72: 70:         SortBy::Asc => base_query.order(event_log::timestamp.asc()),
73: 71:     };
74: 72: 
75: 73:     let limit = pagination_params.count.unwrap_or(10);
76: 74:     let offset = (pagination_params.page.unwrap_or(1) - 1) * limit;
77: 75:     let logs = base_query.limit(limit).offset(offset).load(&mut conn)?;
78: 76: 
79: 77:     let log_count: i64 = count_query.count().get_result(&mut conn)?;
80: 78: 
81: 79:     let total_pages = (log_count as f64 / limit as f64).ceil() as i64;
82: 80: 
83: 81:     Ok(Json(PaginatedResponse {
84: 82:         total_items: log_count,
85: 83:         total_pages,
86: 84:         data: logs,
87: 85:     }))
88: 86: }
89: 87: ```
90: 88: ```
91: 89: ```
92: 90: ```
93: ```
```
