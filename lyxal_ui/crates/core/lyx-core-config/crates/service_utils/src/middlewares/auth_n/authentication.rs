### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\middlewares\auth_n\authentication.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\authentication.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\authentication.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\authentication.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\authentication.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\authentication.rs
10: 8: ```rust
11: 9: use std::fmt::Display;
12: 10: 
13: 11: use actix_web::{
14: 12:     HttpRequest, HttpResponse, Scope,
15: 13:     cookie::{Cookie, time::Duration},
16: 14:     http::header,
17: 15:     web::Path,
18: 16: };
19: 17: use futures_util::future::LocalBoxFuture;
20: 18: use serde::Deserialize;
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;
22: 20: 
23: 21: #[derive(Deserialize)]
24: 22: pub(super) struct SwitchOrgParams {
25: 23:     pub(super) organisation_id: String,
26: 24: }
27: 25: 
28: 26: #[derive(Debug, Clone)]
29: 27: pub enum Login {
30: 28:     None,
31: 29:     Global,
32: 30:     Org(String),
33: 31: }
34: 32: 
35: 33: impl Display for Login {
36: 34:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
37: 35:         match self {
38: 36:             Login::None => write!(f, "none"),
39: 37:             Login::Global => write!(f, "user"),
40: 38:             Login::Org(org_id) => write!(f, "org_{org_id}"),
41: 39:         }
42: 40:     }
43: 41: }
44: 42: 
45: 43: pub trait Authenticator: Sync + Send {
46: 44:     fn routes(&self) -> Scope;
47: 45: 
48: 46:     fn get_path_prefix(&self) -> String;
49: 47: 
50: 48:     fn get_cookie_path(&self) -> String {
51: 49:         let prefix = self.get_path_prefix();
52: 50:         if prefix.as_str() == "" {
53: 51:             String::from('/')
54: 52:         } else {
55: 53:             prefix
56: 54:         }
57: 55:     }
58: 56: 
59: 57:     fn authenticate(
60: 58:         &self,
61: 59:         request: &HttpRequest,
62: 60:         login_type: &Login,
63: 61:     ) -> LocalBoxFuture<'static, Result<User, HttpResponse>>;
64: 62: 
65: 63:     fn get_organisations(&self, req: &HttpRequest) -> HttpResponse;
66: 64: 
67: 65:     fn generate_org_user<'a>(
68: 66:         &'a self,
69: 67:         req: &HttpRequest,
70: 68:         org_id: &str,
71: 69:         login_type: &Login,
72: 70:     ) -> LocalBoxFuture<'a, Result<String, HttpResponse>>;
73: 71: 
74: 72:     fn switch_organisation<'a>(
75: 73:         &'a self,
76: 74:         req: &HttpRequest,
77: 75:         path: &Path<SwitchOrgParams>,
78: 76:     ) -> LocalBoxFuture<'a, HttpResponse> {
79: 77:         let login_type = Login::Org(path.organisation_id.clone());
80: 78:         let user_token_future =
81: 79:             self.generate_org_user(req, &path.organisation_id, &login_type);
82: 80: 
83: 81:         let prefix = self.get_path_prefix();
84: 82:         let cookie_path = self.get_cookie_path();
85: 83:         let org_id = path.organisation_id.clone();
86: 84: 
87: 85:         Box::pin(async move {
88: 86:             match user_token_future.await {
89: 87:                 Ok(token) => {
90: 88:                     let cookie = Cookie::build(login_type.to_string(), token)
91: 89:                         .path(cookie_path)
92: 90:                         .http_only(true)
93: 91:                         .secure(true)
94: 92:                         .max_age(Duration::days(1))
95: 93:                         .finish();
96: 94:                     HttpResponse::Found()
97: 95:                         .cookie(cookie)
98: 96:                         .insert_header((
99: 97:                             header::LOCATION,
100: 98:                             format!("{prefix}/admin/{org_id}/workspaces"),
101: 99:                         ))
102: 100:                         .finish()
103: 101:                 }
104: 102:                 Err(resp) => resp,
105: 103:             }
106: 104:         })
107: 105:     }
108: 106: }
109: 107: ```
110: 108: ```
111: 109: ```
112: 110: ```
113: ```
```
