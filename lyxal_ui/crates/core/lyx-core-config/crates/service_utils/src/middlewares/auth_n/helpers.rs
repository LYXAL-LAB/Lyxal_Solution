### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
10: 8: ```rust
11: 9: use actix_web::{HttpRequest, web::Data};
12: 10: use diesel::{
13: 11:     Connection, ExpressionMethods, RunQueryDsl,
14: 12:     query_dsl::methods::{OrderDsl, SelectDsl},
15: 13: };
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::lyx-core-lyx_core_lyx-core-lyx_core_superposition_schema::lyx-core-lyx_core_lyx-core-lyx_core_superposition::organisations;
17: 15: 
18: 16: use crate::service::types::AppState;
19: 17: 
20: 18: pub(super) fn fetch_org_lyx-core-lyx_core_lyx-core-lyx_core_ids_from_db(
21: 19:     req: &HttpRequest,
22: 20: ) -> Result<Vec<String>, &'static str> {
23: 21:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = match req.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data::<Data<AppState>>() {
24: 22:         Some(state) => state,
25: 23:         None => {
26: 24:             log::info!("DbConnection-FromRequest: Unable to get lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data from request");
27: 25:             return Err("Unable to get lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data from request");
28: 26:         }
29: 27:     };
30: 28: 
31: 29:     match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.db_pool.get() {
32: 30:         Ok(mut conn) => {
33: 31:             conn.set_prepared_statement_cache_size(
34: 32:                 diesel::connection::CacheSize::Disabled,
35: 33:             );
36: 34:             let orgs = organisations::table
37: 35:                 .order(organisations::created_at.desc())
38: 36:                 .select(organisations::id)
39: 37:                 .get_results::<String>(&mut conn);
40: 38: 
41: 39:             match orgs {
42: 40:                 Ok(orgs) => Ok(orgs),
43: 41:                 Err(e) => {
44: 42:                     log::error!("Failed to fetch organisations: {:?}", e);
45: 43:                     Err("Failed to fetch organisations")
46: 44:                 }
47: 45:             }
48: 46:         }
49: 47:         Err(e) => {
50: 48:             log::info!("Unable to get db connection from pool, error: {e}");
51: 49:             Err("Unable to get db connection from pool")
52: 50:         }
53: 51:     }
54: 52: }
55: 53: ```
56: 54: ```
57: 55: ```
58: 56: ```
59: ```
```
