1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\helper.rs
10: 8: ```rust
11: 9: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::bad_argument;
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
13: 11:     database::models::others::{Webhook, WebhookEvent},
14: 12:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
15: 13: };
16: 14: 
17: 15: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
18: 16: use diesel::{
19: 17:     PgConnection,
20: 18:     r2d2::{ConnectionManager, PooledConnection},
21: 19: };
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::webhooks::{self, dsl};
23: 21: 
24: 22: pub fn validate_events(
25: 23:     events: &[WebhookEvent],
26: 24:     exclude_webhook: Option<&String>,
27: 25:     schema_name: &String,
28: 26:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
29: 27: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
30: 28:     let result: Vec<Webhook> =
31: 29:         dsl::webhooks.schema_name(schema_name).get_results(conn)?;
32: 30:     for webhook in result {
33: 31:         if exclude_webhook == Some(&webhook.name) {
34: 32:             continue;
35: 33:         }
36: 34:         if let Some(duplicate_event) =
37: 35:             webhook.events.iter().find(|event| events.contains(event))
38: 36:         {
39: 37:             return Err(bad_argument!("Duplicate event found: {}", duplicate_event));
40: 38:         }
41: 39:     }
42: 40:     Ok(())
43: 41: }
44: 42: 
45: 43: pub fn fetch_webhook(
46: 44:     w_name: &String,
47: 45:     schema_name: &String,
48: 46:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
49: 47: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Webhook> {
50: 48:     Ok(dsl::webhooks
51: 49:         .filter(webhooks::name.eq(w_name))
52: 50:         .schema_name(schema_name)
53: 51:         .get_result::<Webhook>(conn)?)
54: 52: }
55: 53: ```
56: 54: ```
57: 55: ```
58: 56: ```
59: ```
```

