### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::bad_argument;
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
database::models::others::{Webhook, WebhookEvent},
result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
};

use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
use diesel::{
PgConnection,
r2d2::{ConnectionManager, PooledConnection},
};
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::webhooks::{self, dsl};

pub fn validate_events(
events: &[WebhookEvent],
exclude_webhook: Option<&String>,
schema_name: &String,
conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
let result: Vec<Webhook> =
dsl::webhooks.schema_name(schema_name).get_results(conn)?;
for webhook in result {
if exclude_webhook == Some(&webhook.name) {
continue;
}
if let Some(duplicate_event) =
webhook.events.iter().find(|event| events.contains(event))
{
return Err(bad_argument!("Duplicate event found: {}", duplicate_event));
}
}
Ok(())
}

pub fn fetch_webhook(
w_name: &String,
schema_name: &String,
conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Webhook> {
Ok(dsl::webhooks
.filter(webhooks::name.eq(w_name))
.schema_name(schema_name)
.get_result::<Webhook>(conn)?)
}
