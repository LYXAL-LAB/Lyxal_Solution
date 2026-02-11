### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\middlewares\auth_n\no_auth.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\no_auth.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\no_auth.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\no_auth.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\no_auth.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\no_auth.rs
10: 8: ```rust
11: 9: use actix_web::{HttpRequest, HttpResponse, Scope, error};
12: 10: use futures_util::future::LocalBoxFuture;
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;
14: 12: 
15: 13: use crate::middlewares::auth_n::helpers::fetch_org_lyx-core-lyx_core_lyx-core-lyx_core_ids_from_db;
16: 14: 
17: 15: use super::authentication::{Authenticator, Login};
18: 16: 
19: 17: /// An Authenticator implementation that performs no authentication
20: 18: /// This is primarily for development and testing purposes
21: 19: /// In production, a proper Authenticator (like OIDCAuthenticator) should be used
22: 20: pub struct DisabledAuthenticator {
23: 21:     path_prefix: String,
24: 22: }
25: 23: 
26: 24: impl DisabledAuthenticator {
27: 25:     pub fn new(path_prefix: String) -> Self {
28: 26:         Self { path_prefix }
29: 27:     }
30: 28: }
31: 29: 
32: 30: impl Authenticator for DisabledAuthenticator {
33: 31:     fn get_path_prefix(&self) -> String {
34: 32:         self.path_prefix.clone()
35: 33:     }
36: 34: 
37: 35:     fn authenticate(
38: 36:         &self,
39: 37:         _: &HttpRequest,
40: 38:         _: &Login,
41: 39:     ) -> LocalBoxFuture<'static, Result<User, HttpResponse>> {
42: 40:         Box::pin(async { Ok(User::default()) })
43: 41:     }
44: 42: 
45: 43:     fn routes(&self) -> actix_web::Scope {
46: 44:         Scope::new("no_auth")
47: 45:     }
48: 46: 
49: 47:     fn get_organisations(&self, req: &actix_web::HttpRequest) -> HttpResponse {
50: 48:         match fetch_org_lyx-core-lyx_core_lyx-core-lyx_core_ids_from_db(req) {
51: 49:             Ok(resp) => HttpResponse::Ok().json(resp),
52: 50:             Err(resp) => error::ErrorInternalServerError(resp).into(),
53: 51:         }
54: 52:     }
55: 53: 
56: 54:     fn generate_org_user(
57: 55:         &self,
58: 56:         _: &HttpRequest,
59: 57:         _: &str,
60: 58:         _: &Login,
61: 59:     ) -> LocalBoxFuture<'_, Result<String, HttpResponse>> {
62: 60:         Box::pin(async { Ok("org_token".to_string()) })
63: 61:     }
64: 62: }
65: 63: ```
66: 64: ```
67: 65: ```
68: 66: ```
69: ```
```
