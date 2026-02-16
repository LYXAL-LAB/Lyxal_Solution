1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\simple_authenticator.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\simple_authenticator.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\simple_authenticator.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\simple_authenticator.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\simple_authenticator.rs
10: 8: ```rust
11: 9: use std::sync::Arc;
12: 10: 
13: 11: use actix_web::{
14: 12:     HttpRequest, HttpResponse,
15: 13:     error::{ErrorBadRequest, ErrorInternalServerError},
16: 14:     web::{self, Data, get, resource},
17: 15: };
18: 16: use derive_more::{Deref, DerefMut};
19: 17: use futures_util::future::LocalBoxFuture;
20: 18: use openidconnect::{
21: 19:     self as oidcrs, ClientId, ClientSecret, IssuerUrl, RedirectUrl, TokenResponse,
22: 20:     core::{CoreClient, CoreIdTokenClaims, CoreProviderMetadata, CoreTokenResponse},
23: 21: };
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;
25: 23: 
26: 24: use crate::middlewares::auth_n::{
27: 25:     authentication::{Authenticator, Login},
28: 26:     helpers::fetch_org_lyx-core-lyx_core_lyx-core-lyx_core_ids_from_db,
29: 27:     oidc::{
30: 28:         OIDCAuthenticator,
31: 29:         utils::{try_user_from, verify_presence},
32: 30:     },
33: 31: };
34: 32: 
35: 33: #[derive(Clone)]
36: 34: pub struct AuthenticatorInner {
37: 35:     lyx-core-lyx_core_lyx-core-lyx_core_client: CoreClient,
38: 36:     path_prefix: String,
39: 37: }
40: 38: 
41: 39: /// A simple OIDC Authenticator implementation that uses a single
42: 40: /// OpenID Provider for authentication, no org specific issuers
43: 41: ///
44: 42: /// Env(s) needed for Simple OIDC Authenticator:
45: 43: /// OIDC_CLIENT_ID, OIDC_CLIENT_SECRET, OIDC_REDIRECT_HOST
46: 44: #[derive(Deref, DerefMut, Clone)]
47: 45: pub struct SimpleOIDCAuthenticator(Arc<AuthenticatorInner>);
48: 46: 
49: 47: impl SimpleOIDCAuthenticator {
50: 48:     pub async fn new(
51: 49:         idp_url: String,
52: 50:         base_url: String,
53: 51:         path_prefix: String,
54: 52:         lyx-core-lyx_core_lyx-core-lyx_core_client_id: String,
55: 53:         lyx-core-lyx_core_lyx-core-lyx_core_client_secret: String,
56: 54:     ) -> Result<Self, Box<dyn std::error::Error>> {
57: 55:         let issuer_url = IssuerUrl::new(idp_url)
58: 56:             .map_err(|e| format!("Unable to create issuer url: {}", e))
59: 57:             .unwrap();
60: 58: 
61: 59:         // Discover OpenID Provider metadata
62: 60:         let provider_metadata = CoreProviderMetadata::discover_async(
63: 61:             issuer_url,
64: 62:             oidcrs::reqwest::async_http_lyx-core-lyx_core_lyx-core-lyx_core_client,
65: 63:         )
66: 64:         .await?;
67: 65: 
68: 66:         // Create lyx-core-lyx_core_lyx-core-lyx_core_client
69: 67:         let lyx-core-lyx_core_lyx-core-lyx_core_client = CoreClient::from_provider_metadata(
70: 68:             provider_metadata.clone(),
71: 69:             ClientId::new(lyx-core-lyx_core_lyx-core-lyx_core_client_id.clone()),
72: 70:             Some(ClientSecret::new(lyx-core-lyx_core_lyx-core-lyx_core_client_secret.clone())),
73: 71:         )
74: 72:         .set_redirect_uri(RedirectUrl::new(format!(
75: 73:             "{base_url}{path_prefix}/oidc/login"
76: 74:         ))?);
77: 75: 
78: 76:         Ok(Self(Arc::new(AuthenticatorInner {
79: 77:             lyx-core-lyx_core_lyx-core-lyx_core_client,
80: 78:             path_prefix,
81: 79:         })))
82: 80:     }
83: 81: 
84: 82:     fn decode_global_token(&self, cookie: &str) -> Result<CoreIdTokenClaims, String> {
85: 83:         let ctr = serde_json::from_str::<CoreTokenResponse>(cookie)
86: 84:             .map_err(|e| format!("Error while decoding token: {e}"))?;
87: 85:         ctr.id_token()
88: 86:             .ok_or(String::from("Id Token not found"))?
89: 87:             .claims(&self.lyx-core-lyx_core_lyx-core-lyx_core_client.id_token_verifier(), verify_presence)
90: 88:             .map_err(|e| format!("Error in claims verification: {e}"))
91: 89:             .cloned()
92: 90:     }
93: 91: }
94: 92: 
95: 93: impl OIDCAuthenticator for SimpleOIDCAuthenticator {
96: 94:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client(&self) -> &CoreClient {
97: 95:         &self.lyx-core-lyx_core_lyx-core-lyx_core_client
98: 96:     }
99: 97: 
100: 98:     fn get_global_user(
101: 99:         &self,
102: 100:         request: &HttpRequest,
103: 101:         path: String,
104: 102:     ) -> Result<User, HttpResponse> {
105: 103:         let token = request.cookie(&Login::Global.to_string()).and_then(|c| {
106: 104:             self.decode_global_token(c.value())
107: 105:                 .map_err(|e| log::error!("Error in decoding user : {e}"))
108: 106:                 .ok()
109: 107:         });
110: 108:         if let Some(token_response) = token {
111: 109:             Ok(try_user_from(&token_response).map_err(|e| {
112: 110:                 log::error!("Unable to get user: {e}");
113: 111:                 ErrorBadRequest(String::from("Unable to get user"))
114: 112:             })?)
115: 113:         } else {
116: 114:             log::error!("Error user not found in cookies");
117: 115:             Err(self.new_redirect(&Login::Global, path))
118: 116:         }
119: 117:     }
120: 118: }
121: 119: 
122: 120: impl Authenticator for SimpleOIDCAuthenticator {
123: 121:     fn get_path_prefix(&self) -> String {
124: 122:         self.path_prefix.clone()
125: 123:     }
126: 124: 
127: 125:     fn authenticate(
128: 126:         &self,
129: 127:         request: &HttpRequest,
130: 128:         login_type: &Login,
131: 129:     ) -> LocalBoxFuture<'static, Result<User, HttpResponse>> {
132: 130:         let auth_n = self.clone();
133: 131:         match login_type {
134: 132:             Login::None => Box::pin(async { Ok(User::default()) }),
135: 133:             Login::Global => {
136: 134:                 let resp = auth_n.get_global_user(
137: 135:                     request,
138: 136:                     format!("{}/admin/organisations", self.path_prefix),
139: 137:                 );
140: 138:                 Box::pin(async { resp })
141: 139:             }
142: 140:             Login::Org(_) => {
143: 141:                 let resp = auth_n.get_global_user(request, request.path().to_string());
144: 142:                 Box::pin(async { resp })
145: 143:             }
146: 144:         }
147: 145:     }
148: 146: 
149: 147:     fn routes(&self) -> actix_web::Scope {
150: 148:         web::scope("oidc")
151: 149:             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Data::new(self.to_owned()))
152: 150:             .service(resource("login").route(get().to(Self::login)))
153: 151:     }
154: 152: 
155: 153:     fn get_organisations(&self, req: &actix_web::HttpRequest) -> HttpResponse {
156: 154:         match fetch_org_lyx-core-lyx_core_lyx-core-lyx_core_ids_from_db(req) {
157: 155:             Ok(resp) => HttpResponse::Ok().json(resp),
158: 156:             Err(resp) => ErrorInternalServerError(resp).into(),
159: 157:         }
160: 158:     }
161: 159: 
162: 160:     fn generate_org_user(
163: 161:         &self,
164: 162:         req: &HttpRequest,
165: 163:         _: &str,
166: 164:         login_type: &Login,
167: 165:     ) -> LocalBoxFuture<'_, Result<String, HttpResponse>> {
168: 166:         let user = req
169: 167:             .cookie(&Login::Global.to_string())
170: 168:             .and_then(|user_cookie| {
171: 169:                 self.decode_global_token(user_cookie.value())
172: 170:                     .map_err(|e| log::error!("Error in decoding user : {e}"))
173: 171:                     .map(|_| user_cookie.value().to_string())
174: 172:                     .ok()
175: 173:             });
176: 174: 
177: 175:         match user {
178: 176:             Some(u) => Box::pin(async { Ok(u) }),
179: 177:             None => {
180: 178:                 let redirect = self.new_redirect(
181: 179:                     login_type,
182: 180:                     format!("{}/admin/organisations", self.path_prefix),
183: 181:                 );
184: 182:                 Box::pin(async { Err(redirect) })
185: 183:             }
186: 184:         }
187: 185:     }
188: 186: }
189: 187: ```
190: 188: ```
191: 189: ```
192: 190: ```
193: ```
```

