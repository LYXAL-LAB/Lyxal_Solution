### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\middlewares\auth_n.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n.rs
10: 8: ```rust
11: 9: mod authentication;
12: 10: mod helpers;
13: 11: mod no_auth;
14: 12: mod oidc;
15: 13: 
16: 14: use std::{
17: 15:     collections::HashSet,
18: 16:     future::{Ready, ready},
19: 17:     rc::Rc,
20: 18:     sync::Arc,
21: 19: };
22: 20: 
23: 21: use actix_web::{
24: 22:     Error, HttpMessage, HttpRequest, HttpResponse, Scope,
25: 23:     body::{BoxBody, EitherBody},
26: 24:     dev::{Service, ServiceRequest, ServiceResponse, Transform, forward_ready},
27: 25:     get,
28: 26:     http::header,
29: 27:     web::{self, Data, Path},
30: 28: };
31: 29: use authentication::{Authenticator, Login, SwitchOrgParams};
32: 30: use aws_sdk_kms::Client;
33: 31: use futures_util::future::LocalBoxFuture;
34: 32: use no_auth::DisabledAuthenticator;
35: 33: use oidc::{SaasOIDCAuthenticator, SimpleOIDCAuthenticator};
36: 34: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{InternalUser, User};
37: 35: 
38: 36: use crate::{
39: 37:     db::utils::get_oidc_lyx-core-lyx_core_lyx-core-lyx_core_client_secret,
40: 38:     extensions::HttpRequestExt,
41: 39:     helpers::get_from_env_unsafe,
42: 40:     service::types::{AppEnv, AppState},
43: 41: };
44: 42: 
45: 43: pub struct AuthNMiddleware<S> {
46: 44:     service: Rc<S>,
47: 45:     auth_n_handler: AuthNHandler,
48: 46: }
49: 47: 
50: 48: impl<S> AuthNMiddleware<S> {
51: 49:     fn get_login_type(
52: 50:         &self,
53: 51:         request: &ServiceRequest,
54: 52:         exception: &HashSet<String>,
55: 53:     ) -> Login {
56: 54:         let path_prefix = self.auth_n_handler.0.get_path_prefix();
57: 55:         let request_pattern = request
58: 56:             .match_pattern()
59: 57:             .map(|a| a.replace(&path_prefix, ""))
60: 58:             .unwrap_or_else(|| request.uri().path().replace(&path_prefix, ""));
61: 59: 
62: 60:         let excep = exception.contains(&request_pattern);
63: 61:         let org_request = request.path().matches("/organisations").count() > 0;
64: 62: 
65: 63:         match (excep, org_request) {
66: 64:             (true, false) => Login::None,
67: 65:             (_, true) => Login::Global,
68: 66:             (false, false) => Login::Org(
69: 67:                 request
70: 68:                     .request()
71: 69:                     .get_organisation_id()
72: 70:                     .map(|o| o.0)
73: 71:                     .unwrap_or_default(),
74: 72:             ),
75: 73:         }
76: 74:     }
77: 75: }
78: 76: 
79: 77: impl<S, B> Service<ServiceRequest> for AuthNMiddleware<S>
80: 78: where
81: 79:     S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
82: 80:     S::Future: 'static,
83: 81: {
84: 82:     type Response = ServiceResponse<EitherBody<B, BoxBody>>;
85: 83:     type Error = Error;
86: 84:     type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;
87: 85: 
88: 86:     // Generate polling fn.
89: 87:     forward_ready!(service);
90: 88: 
91: 89:     fn call(&self, request: ServiceRequest) -> Self::Future {
92: 90:         let state = request.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data::<Data<AppState>>().unwrap();
93: 91: 
94: 92:         let result = request
95: 93:             .headers()
96: 94:             .get(header::AUTHORIZATION)
97: 95:             .and_then(|auth| auth.to_str().ok())
98: 96:             .and_then(|auth| {
99: 97:                 let mut token = auth.split(' ');
100: 98:                 match (token.next(), token.next()) {
101: 99:                     (Some("Internal"), Some(token))
102: 100:                         if token == state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token =>
103: 101:                     {
104: 102:                         request
105: 103:                             .headers()
106: 104:                             .get("x-user")
107: 105:                             .and_then(|auth| auth.to_str().ok())
108: 106:                             .and_then(|user_str| {
109: 107:                                 serde_json::from_str::<User>(user_str).ok()
110: 108:                             })
111: 109:                             .map(|user| {
112: 110:                                 request
113: 111:                                     .extensions_mut()
114: 112:                                     .insert::<InternalUser>(InternalUser);
115: 113:                                 Ok(user)
116: 114:                             })
117: 115:                     }
118: 116:                     (_, _) => None,
119: 117:                 }
120: 118:             })
121: 119:             .unwrap_or_else(|| {
122: 120:                 let login_type = self
123: 121:                     .get_login_type(&request, &state.tenant_middleware_exclusion_list);
124: 122: 
125: 123:                 Err(self
126: 124:                     .auth_n_handler
127: 125:                     .0
128: 126:                     .authenticate(request.request(), &login_type))
129: 127:             });
130: 128: 
131: 129:         match result {
132: 130:             Ok(user) => {
133: 131:                 request.extensions_mut().insert::<User>(user);
134: 132:                 let fut = self.service.call(request);
135: 133:                 Box::pin(async { fut.await.map(|sr| sr.map_into_left_body()) })
136: 134:             }
137: 135:             Err(fut) => {
138: 136:                 let srv = self.service.clone();
139: 137:                 Box::pin(async move {
140: 138:                     match fut.await {
141: 139:                         Ok(user) => {
142: 140:                             request.extensions_mut().insert::<User>(user);
143: 141:                             srv.call(request).await.map(|sr| sr.map_into_left_body())
144: 142:                         }
145: 143:                         Err(resp) => {
146: 144:                             Ok(request.into_response(resp.map_into_right_body()))
147: 145:                         }
148: 146:                     }
149: 147:                 })
150: 148:             }
151: 149:         }
152: 150:     }
153: 151: }
154: 152: 
155: 153: #[derive(Clone)]
156: 154: pub struct AuthNHandler(Arc<dyn Authenticator>);
157: 155: 
158: 156: impl AuthNHandler {
159: 157:     pub fn routes(&self) -> Scope {
160: 158:         self.0.routes()
161: 159:     }
162: 160: 
163: 161:     pub fn org_routes(&self) -> Scope {
164: 162:         routes(self.clone())
165: 163:     }
166: 164: 
167: 165:     pub async fn init(
168: 166:         kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
169: 167:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
170: 168:         path_prefix: String,
171: 169:     ) -> Self {
172: 170:         let auth_provider: String = get_from_env_unsafe("AUTH_PROVIDER").unwrap();
173: 171:         let mut auth = auth_provider.split('+');
174: 172: 
175: 173:         let ap: Arc<dyn Authenticator> = match auth.next() {
176: 174:             Some("DISABLED") => Arc::new(DisabledAuthenticator::new(path_prefix)),
177: 175:             Some("OIDC") => {
178: 176:                 let url = auth.next().unwrap().to_string();
179: 177:                 let base_url = get_from_env_unsafe("OIDC_REDIRECT_HOST").unwrap();
180: 178:                 let cid = get_from_env_unsafe("OIDC_CLIENT_ID").unwrap();
181: 179:                 let csecret = get_oidc_lyx-core-lyx_core_lyx-core-lyx_core_client_secret(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env).await;
182: 180:                 Arc::new(
183: 181:                     SimpleOIDCAuthenticator::new(
184: 182:                         url,
185: 183:                         base_url,
186: 184:                         path_prefix,
187: 185:                         cid,
188: 186:                         csecret,
189: 187:                     )
190: 188:                     .await
191: 189:                     .unwrap(),
192: 190:                 )
193: 191:             }
194: 192:             Some("OIDC_SAAS") => {
195: 193:                 let url = auth.next().unwrap().to_string();
196: 194:                 let base_url = get_from_env_unsafe("OIDC_REDIRECT_HOST").unwrap();
197: 195:                 let cid = get_from_env_unsafe("OIDC_CLIENT_ID").unwrap();
198: 196:                 let csecret = get_oidc_lyx-core-lyx_core_lyx-core-lyx_core_client_secret(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env).await;
199: 197:                 Arc::new(
200: 198:                     SaasOIDCAuthenticator::new(url, base_url, path_prefix, cid, csecret)
201: 199:                         .await
202: 200:                         .unwrap(),
203: 201:                 )
204: 202:             }
205: 203:             _ => panic!("Missing/Unknown authenticator."),
206: 204:         };
207: 205:         Self(ap)
208: 206:     }
209: 207: }
210: 208: 
211: 209: pub fn routes(auth: AuthNHandler) -> Scope {
212: 210:     web::scope("organisations")
213: 211:         .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Data::new(auth))
214: 212:         .service(get_organisations)
215: 213:         .service(switch_organisation)
216: 214: }
217: 215: 
218: 216: #[get("")]
219: 217: async fn get_organisations(data: Data<AuthNHandler>, req: HttpRequest) -> HttpResponse {
220: 218:     data.0.get_organisations(&req)
221: 219: }
222: 220: 
223: 221: #[get("/switch/{organisation_id}")]
224: 222: async fn switch_organisation(
225: 223:     data: Data<AuthNHandler>,
226: 224:     req: HttpRequest,
227: 225:     path: Path<SwitchOrgParams>,
228: 226: ) -> HttpResponse {
229: 227:     data.0.switch_organisation(&req, &path).await
230: 228: }
231: 229: 
232: 230: impl<S, B> Transform<S, ServiceRequest> for AuthNHandler
233: 231: where
234: 232:     S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
235: 233:     S::Future: 'static,
236: 234: {
237: 235:     type Response = ServiceResponse<EitherBody<B>>;
238: 236:     type Error = Error;
239: 237:     type Transform = AuthNMiddleware<S>;
240: 238:     type InitError = ();
241: 239:     type Future = Ready<Result<Self::Transform, Self::InitError>>;
242: 240: 
243: 241:     fn new_transform(&self, service: S) -> Self::Future {
244: 242:         ready(Ok(AuthNMiddleware {
245: 243:             service: Rc::new(service),
246: 244:             auth_n_handler: self.clone(),
247: 245:         }))
248: 246:     }
249: 247: }
250: 248: ```
251: 249: ```
252: 250: ```
253: 251: ```
254: ```
```
