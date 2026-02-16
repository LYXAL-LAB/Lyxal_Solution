1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_z\no_auth.rs
10: 8: ```rust
11: 9: use futures_util::future::LocalBoxFuture;
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;
13: 11: 
14: 12: use crate::service::types::{OrganisationId, Resource, SchemaName};
15: 13: 
16: 14: use super::authorization::Authorizer;
17: 15: 
18: 16: pub struct NoAuth;
19: 17: 
20: 18: impl Authorizer for NoAuth {
21: 19:     fn is_allowed(
22: 20:         &self,
23: 21:         _: &(OrganisationId, SchemaName),
24: 22:         _: &User,
25: 23:         _: &Resource,
26: 24:         _: &str,
27: 25:         _: Option<&[&str]>,
28: 26:     ) -> LocalBoxFuture<'_, Result<bool, String>> {
29: 27:         Box::pin(async { Ok(true) })
30: 28:     }
31: 29: }
32: 30: ```
33: 31: ```
34: 32: ```
35: 33: ```
36: ```
```

