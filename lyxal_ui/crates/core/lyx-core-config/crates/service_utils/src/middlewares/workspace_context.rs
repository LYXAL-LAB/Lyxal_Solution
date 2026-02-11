### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\middlewares\workspace_context.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\workspace_context.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\workspace_context.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\workspace_context.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\workspace_context.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\workspace_context.rs
10: 8: ```rust
11: 9: use std::future::{Ready, ready};
12: 10: use std::rc::Rc;
13: 11: 
14: 12: use actix_web::{
15: 13:     Error, HttpMessage,
16: 14:     body::EitherBody,
17: 15:     dev::{Service, ServiceRequest, ServiceResponse, Transform, forward_ready},
18: 16:     error,
19: 17:     web::Data,
20: 18: };
21: 19: use futures_util::future::LocalBoxFuture;
22: 20: use regex::Regex;
23: 21: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, unexpected_error};
24: 22: 
25: 23: use crate::helpers::get_workspace;
26: 24: use crate::{
27: 25:     extensions::HttpRequestExt,
28: 26:     service::types::{AppState, OrganisationId, SchemaName, WorkspaceContext},
29: 27: };
30: 28: 
31: 29: pub struct OrgWorkspaceMiddlewareFactory {
32: 30:     enable_org_id: bool,
33: 31:     enable_workspace_id: bool,
34: 32: }
35: 33: 
36: 34: impl OrgWorkspaceMiddlewareFactory {
37: 35:     pub fn new(enable_org_id: bool, enable_workspace_id: bool) -> Self {
38: 36:         Self {
39: 37:             enable_org_id,
40: 38:             enable_workspace_id,
41: 39:         }
42: 40:     }
43: 41: }
44: 42: 
45: 43: impl<S, B> Transform<S, ServiceRequest> for OrgWorkspaceMiddlewareFactory
46: 44: where
47: 45:     S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
48: 46:     S::Future: 'static,
49: 47:     B: 'static,
50: 48: {
51: 49:     type Response = ServiceResponse<EitherBody<B>>;
52: 50:     type Error = Error;
53: 51:     type InitError = ();
54: 52:     type Transform = OrgWorkspaceMiddleware<S>;
55: 53:     type Future = Ready<Result<Self::Transform, Self::InitError>>;
56: 54: 
57: 55:     fn new_transform(&self, service: S) -> Self::Future {
58: 56:         ready(Ok(OrgWorkspaceMiddleware {
59: 57:             service: Rc::new(service),
60: 58:             enable_org_id: self.enable_org_id,
61: 59:             enable_workspace_id: self.enable_workspace_id,
62: 60:         }))
63: 61:     }
64: 62: }
65: 63: 
66: 64: pub struct OrgWorkspaceMiddleware<S> {
67: 65:     service: Rc<S>,
68: 66:     enable_org_id: bool,
69: 67:     enable_workspace_id: bool,
70: 68: }
71: 69: 
72: 70: impl<S, B> Service<ServiceRequest> for OrgWorkspaceMiddleware<S>
73: 71: where
74: 72:     S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
75: 73:     S::Future: 'static,
76: 74:     B: 'static,
77: 75: {
78: 76:     type Response = ServiceResponse<EitherBody<B>>;
79: 77:     type Error = Error;
80: 78:     type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;
81: 79: 
82: 80:     forward_ready!(service);
83: 81: 
84: 82:     fn call(&self, req: ServiceRequest) -> Self::Future {
85: 83:         let srv = self.service.clone();
86: 84:         let enable_org_id = self.enable_org_id;
87: 85:         let enable_workspace_id = self.enable_workspace_id;
88: 86: 
89: 87:         Box::pin(async move {
90: 88:             let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = match req.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data::<Data<AppState>>() {
91: 89:                 Some(val) => val,
92: 90:                 None => {
93: 91:                     log::error!("lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state not set");
94: 92:                     return Err(error::ErrorInternalServerError(""));
95: 93:                 }
96: 94:             };
97: 95: 
98: 96:             let base = match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.service_prefix.as_str() {
99: 97:                 "" | "/" => "".to_owned(),
100: 98:                 prefix => "/".to_owned() + prefix,
101: 99:             };
102: 100: 
103: 101:             let request_path = req.uri().path().replace(&base, "");
104: 102:             let request_pattern = req
105: 103:                 .match_pattern()
106: 104:                 .map(|a| a.replace(&base, ""))
107: 105:                 .unwrap_or_else(|| request_path.clone());
108: 106:             let pkg_regex = Regex::new(".*/pkg/.+")
109: 107:                 .map_err(|err| error::ErrorInternalServerError(err.to_string()))?;
110: 108:             let assets_regex = Regex::new(".*/assets/.+")
111: 109:                 .map_err(|err| error::ErrorInternalServerError(err.to_string()))?;
112: 110:             let is_excluded: bool = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state
113: 111:                 .tenant_middleware_exclusion_list
114: 112:                 .contains(&request_pattern)
115: 113:                 || pkg_regex.is_match(&request_path)
116: 114:                 || assets_regex.is_match(&request_path);
117: 115: 
118: 116:             if !is_excluded {
119: 117:                 let organisation = match (
120: 118:                     enable_org_id,
121: 119:                     req.request().get_organisation_id(),
122: 120:                 ) {
123: 121:                     (true, None) => {
124: 122:                         let error: Error = bad_argument!(
125: 123:                             "The parameter org id is required, and must be passed through headers/url params/query params."
126: 124:                         ).into();
127: 125:                         return Ok(req.into_response(
128: 126:                             error.error_response().map_into_right_body(),
129: 127:                         ));
130: 128:                     }
131: 129:                     (true, Some(org_id)) => org_id,
132: 130:                     (false, _) => OrganisationId::default(),
133: 131:                 };
134: 132:                 req.extensions_mut().insert(organisation.clone());
135: 133: 
136: 134:                 let workspace = req.request().get_workspace_id();
137: 135: 
138: 136:                 let schema_name = match (enable_workspace_id, workspace) {
139: 137:                     (true, None) => {
140: 138:                         let error: Error = bad_argument!(
141: 139:                             "The parameter workspace id is required, and must be passed through headers/url params/query params."
142: 140:                         ).into();
143: 141:                         return Ok(req.into_response(
144: 142:                             error.error_response().map_into_right_body(),
145: 143:                         ));
146: 144:                     }
147: 145:                     (true, Some(workspace_id)) => {
148: 146:                         let schema = format!("{}_{}", *organisation, *workspace_id);
149: 147:                         let schema_name = SchemaName(schema);
150: 148:                         let workspace_settings = {
151: 149:                             let mut db_conn = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state
152: 150:                                 .db_pool
153: 151:                                 .get()
154: 152:                                 .map_err(|err| unexpected_error!("{}", err))?;
155: 153: 
156: 154:                             get_workspace(&schema_name, &mut db_conn)?
157: 155:                         };
158: 156: 
159: 157:                         req.extensions_mut().insert(workspace_id.clone());
160: 158:                         req.extensions_mut().insert(WorkspaceContext {
161: 159:                             organisation_id: organisation,
162: 160:                             workspace_id,
163: 161:                             schema_name: schema_name.clone(),
164: 162:                             settings: workspace_settings,
165: 163:                         });
166: 164: 
167: 165:                         schema_name
168: 166:                     }
169: 167:                     (false, _) => SchemaName::default(),
170: 168:                 };
171: 169: 
172: 170:                 req.extensions_mut().insert(schema_name);
173: 171:             }
174: 172: 
175: 173:             let res = srv.call(req).await?.map_into_left_body();
176: 174: 
177: 175:             Ok(res)
178: 176:         })
179: 177:     }
180: 178: }
181: 179: ```
182: 180: ```
183: 181: ```
184: 182: ```
185: ```
```
