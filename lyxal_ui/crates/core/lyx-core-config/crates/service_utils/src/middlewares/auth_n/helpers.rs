### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\helpers.rs
use actix_web::{HttpRequest, web::Data};
use diesel::{
Connection, ExpressionMethods, RunQueryDsl,
query_dsl::methods::{OrderDsl, SelectDsl},
};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::lyx-core-lyx_core_lyx-core-lyx_core_superposition_schema::lyx-core-lyx_core_lyx-core-lyx_core_superposition::organisations;

use crate::service::types::AppState;

pub(super) fn fetch_org_lyx-core-lyx_core_lyx-core-lyx_core_ids_from_db(
req: &HttpRequest,
) -> Result<Vec<String>, &'static str> {
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = match req.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data::<Data<AppState>>() {
Some(state) => state,
None => {
log::info!("DbConnection-FromRequest: Unable to get lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data from request");
return Err("Unable to get lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data from request");
}
};

match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.db_pool.get() {
Ok(mut conn) => {
conn.set_prepared_statement_cache_size(
diesel::connection::CacheSize::Disabled,
);
let orgs = organisations::table
.order(organisations::created_at.desc())
.select(organisations::id)
.get_results::<String>(&mut conn);

match orgs {
Ok(orgs) => Ok(orgs),
Err(e) => {
log::error!("Failed to fetch organisations: {:?}", e);
Err("Failed to fetch organisations")
}
}
}
Err(e) => {
log::info!("Unable to get db connection from pool, error: {e}");
Err("Unable to get db connection from pool")
}
}
}
