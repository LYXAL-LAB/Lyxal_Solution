1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc.rs
10: 8: ```rust
11: 9: mod saas_authenticator;
12: 10: mod simple_authenticator;
13: 11: mod types;
14: 12: mod utils;
15: 13: 
16: 14: use actix_web::{
17: 15:     HttpRequest, HttpResponse,
18: 16:     cookie::{Cookie, time::Duration},
19: 17:     error::ErrorInternalServerError,
20: 18:     http::header,
21: 19:     web::{Data, Query},
22: 20: };
23: 21: use base64::{Engine, engine::general_purpose};
24: 22: use openidconnect::{
25: 23:     self as oidcrs, AuthenticationFlow, CsrfToken, Nonce, TokenResponse,
26: 24:     core::{CoreClient, CoreResponseType},
27: 25: };
28: 26: pub use saas_authenticator::SaasOIDCAuthenticator;
29: 27: pub use simple_authenticator::SimpleOIDCAuthenticator;
30: 28: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;
31: 29: 
32: 30: use crate::middlewares::auth_n::{
33: 31:     authentication::{Authenticator, Login},
34: 32:     oidc::types::{LoginParams, ProtectionCookie, RedirectionState},
35: 33: };
36: 34: 
37: 35: /// Trait defining OIDC specific authenticator methods
38: 36: /// This is to be implemented by any OIDC based authenticator - SimpleOIDCAuthenticator, SaasOIDCAuthenticator etc.
39: 37: trait OIDCAuthenticator: Authenticator {
40: 38:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client(&self) -> &CoreClient;
41: 39: 
42: 40:     fn get_global_user(
43: 41:         &self,
44: 42:         request: &HttpRequest,
45: 43:         path: String,
46: 44:     ) -> Result<User, HttpResponse>;
47: 45: 
48: 46:     fn new_redirect(&self, cookie_type: &Login, path: String) -> HttpResponse {
49: 47:         let state = RedirectionState {
50: 48:             csrf: CsrfToken::new_random(),
51: 49:             redirect_uri: path,
52: 50:         };
53: 51: 
54: 52:         let encoded_state = general_purpose::STANDARD
55: 53:             .encode(serde_json::to_string(&state).unwrap_or_default());
56: 54: 
57: 55:         let (auth_url, csrf_token, nonce) = self
58: 56:             .get_lyx-core-lyx_core_lyx-core-lyx_core_client()
59: 57:             .authorize_url(
60: 58:                 AuthenticationFlow::<CoreResponseType>::AuthorizationCode,
61: 59:                 || CsrfToken::new(encoded_state),
62: 60:                 Nonce::new_random,
63: 61:             )
64: 62:             .add_scope(oidcrs::Scope::new("email".to_string()))
65: 63:             .add_scope(oidcrs::Scope::new("profile".to_string()))
66: 64:             .url();
67: 65: 
68: 66:         let protection = ProtectionCookie {
69: 67:             csrf: csrf_token,
70: 68:             nonce,
71: 69:         };
72: 70: 
73: 71:         let cookie_result = serde_json::to_string(&protection)
74: 72:             .map_err(|e| {
75: 73:                 log::error!("Unable to stringify data: {e}");
76: 74:                 ErrorInternalServerError("Unable to stringify data".to_string())
77: 75:             })
78: 76:             .map(|cookie| {
79: 77:                 Cookie::build("protection", cookie)
80: 78:                     .max_age(Duration::days(7))
81: 79:                     .secure(true)
82: 80:                     // .http_only(true)
83: 81:                     // .same_site(SameSite::Strict) -- TODO: figure out why this does not work for our case
84: 82:                     .path(self.get_cookie_path())
85: 83:                     .finish()
86: 84:             });
87: 85: 
88: 86:         match cookie_result {
89: 87:             Ok(p_cookie) => HttpResponse::Found()
90: 88:                 .insert_header((header::LOCATION, auth_url.to_string()))
91: 89:                 .cookie(p_cookie)
92: 90:                 // Deletes the cookie.
93: 91:                 .cookie(
94: 92:                     Cookie::build(cookie_type.to_string(), "")
95: 93:                         .max_age(Duration::seconds(0))
96: 94:                         .secure(true)
97: 95:                         .finish(),
98: 96:                 )
99: 97:                 .finish(),
100: 98:             Err(_) => HttpResponse::InternalServerError().finish(),
101: 99:         }
102: 100:     }
103: 101: 
104: 102:     async fn login(
105: 103:         data: Data<Self>,
106: 104:         req: HttpRequest,
107: 105:         params: Query<LoginParams>,
108: 106:     ) -> actix_web::Result<HttpResponse> {
109: 107:         let login_type = Login::Global;
110: 108: 
111: 109:         let p_cookie = match ProtectionCookie::from_req(&req) {
112: 110:             Ok(p_cookie) => p_cookie,
113: 111:             Err(e) => {
114: 112:                 log::error!("OIDC: Missing/Bad protection-cookie, redirecting... {e}");
115: 113:                 return Ok(data.new_redirect(
116: 114:                     &login_type,
117: 115:                     format!("{}/admin/organisations", data.get_path_prefix()),
118: 116:                 ));
119: 117:             }
120: 118:         };
121: 119: 
122: 120:         if *params.state.csrf.secret() != *p_cookie.csrf.secret() {
123: 121:             log::error!("OIDC: Bad csrf");
124: 122:             return Ok(data.new_redirect(
125: 123:                 &login_type,
126: 124:                 format!("{}/admin/organisations", data.get_path_prefix()),
127: 125:             ));
128: 126:         }
129: 127: 
130: 128:         // Exchange the code with a token.
131: 129:         let token_response = data
132: 130:             .get_lyx-core-lyx_core_lyx-core-lyx_core_client()
133: 131:             .exchange_code(params.code.clone())
134: 132:             .request_async(oidcrs::reqwest::async_http_lyx-core-lyx_core_lyx-core-lyx_core_client)
135: 133:             .await
136: 134:             .map_err(|e| {
137: 135:                 log::error!("Failed to exchange auth-code for token: {e}");
138: 136:                 ErrorInternalServerError(
139: 137:                     "Failed to exchange auth-code for token".to_string(),
140: 138:                 )
141: 139:             })?;
142: 140: 
143: 141:         let response = token_response
144: 142:             .id_token()
145: 143:             .ok_or_else(|| log::error!("No identity-token!"))
146: 144:             .and_then(|t| {
147: 145:                 t.claims(&data.get_lyx-core-lyx_core_lyx-core-lyx_core_client().id_token_verifier(), &p_cookie.nonce)
148: 146:                     .map_err(|e| log::error!("Couldn't verify claims: {e}"))
149: 147:             })
150: 148:             .map(|_| token_response.clone());
151: 149: 
152: 150:         match response {
153: 151:             Ok(r) => {
154: 152:                 let token = serde_json::to_string(&r).map_err(|e| {
155: 153:                     log::error!("Unable to stringify data: {e}");
156: 154:                     ErrorInternalServerError("Unable to stringify data".to_string())
157: 155:                 })?;
158: 156:                 let cookie = Cookie::build(login_type.to_string(), token)
159: 157:                     .path(data.get_cookie_path())
160: 158:                     .http_only(true)
161: 159:                     .secure(true)
162: 160:                     .max_age(Duration::days(1))
163: 161:                     .finish();
164: 162:                 Ok(HttpResponse::Found()
165: 163:                     .cookie(cookie)
166: 164:                     .insert_header((header::LOCATION, params.state.redirect_uri.clone()))
167: 165:                     .finish())
168: 166:             }
169: 167:             Err(()) => Ok(data.new_redirect(
170: 168:                 &login_type,
171: 169:                 format!("{}/admin/organisations", data.get_path_prefix()),
172: 170:             )),
173: 171:         }
174: 172:     }
175: 173: }
176: 174: ```
177: 175: ```
178: 176: ```
179: 177: ```
180: ```
```

