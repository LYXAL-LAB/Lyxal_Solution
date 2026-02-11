### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_sso_auth_axum\src\sign_in_sign_up.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum\src\sign_in_sign_up.rs
2: ```rust
3: 1: use super::*;
4: 2: 
5: 3: #[cfg(feature = "ssr")]
6: 4: pub mod ssr_imports {
7: 5:     pub use crate::{
8: 6:         auth::{ssr_imports::SqlCsrfToken, User},
9: 7:         state::AppState,
10: 8:     };
11: 9:     pub use oauth2::{
12: 10:         reqwest::async_http_lyx-core-lyx_core_lyx-core-lyx_core_client, AuthorizationCode, CsrfToken, Scope,
13: 11:         TokenResponse,
14: 12:     };
15: 13:     pub use serde_json::Value;
16: 14: }
17: 15: 
18: 16: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
19: 17: pub async fn google_sso() -> Result<String, ServerFnError> {
20: 18:     use crate::ssr_imports::*;
21: 19:     use ssr_imports::*;
22: 20: 
23: 21:     let oauth_lyx-core-lyx_core_lyx-core-lyx_core_client = expect_context::<AppState>().lyx-core-lyx_core_lyx-core-lyx_core_client;
24: 22:     let pool = pool()?;
25: 23: 
26: 24:     // We get the authorization URL and CSRF_TOKEN
27: 25:     let (authorize_url, csrf_token) = oauth_lyx-core-lyx_core_lyx-core-lyx_core_client
28: 26:         .authorize_url(CsrfToken::new_random)
29: 27:         .add_scope(Scope::new("openid".to_string()))
30: 28:         .add_scope(Scope::new("email".to_string()))
31: 29:         // required for google auth refresh token to be part of the response.
32: 30:         .add_extra_param("access_type", "offline")
33: 31:         .add_extra_param("prompt", "consent")
34: 32:         .url();
35: 33:     let url = authorize_url.to_string();
36: 34:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log!("{url:?}");
37: 35:     // Store the CSRF_TOKEN in our sqlite db.
38: 36:     sqlx::query("INSERT INTO csrf_tokens (csrf_token) VALUES (?)")
39: 37:         .bind(csrf_token.secret())
40: 38:         .execute(&pool)
41: 39:         .await
42: 40:         .map(|_| ())?;
43: 41: 
44: 42:     // Send the url to the lyx-core-lyx_core_lyx-core-lyx_core_client.
45: 43:     Ok(url)
46: 44: }
47: 45: 
48: 46: #[component]
49: 47: pub fn SignIn() -> impl IntoView {
50: 48:     let g_auth = Action::<GoogleSso, _>::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server();
51: 49: 
52: 50:     create_effect(move |_| {
53: 51:         if let Some(Ok(redirect)) = g_auth.value().get() {
54: 52:             window().location().set_href(&redirect).unwrap();
55: 53:         }
56: 54:     });
57: 55: 
58: 56:     view! {
59: 57:       <div style="
60: 58:       display:flex;
61: 59:       flex-direction: column;
62: 60:       justify-content: center;
63: 61:       align-items: center;
64: 62:       ">
65: 63:         <div> {"Sign Up Sign In"} </div>
66: 64:         <button style="display:flex;"  on:click=move|_| g_auth.dispatch(GoogleSso{})>
67: 65:         <svg style="width:2rem;" version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" xmlns:xlink="http://www.w3.org/1999/xlink" style="display: block;">
68: 66:           <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"></path>
69: 67:           <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"></path>
70: 68:           <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"></path>
71: 69:           <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"></path>
72: 70:           <path fill="none" d="M0 0h48v48H0z"></path>
73: 71:         </svg>
74: 72:         <span style="margin-left:0.5rem;">"Sign in with Google"</span>
75: 73:         </button>
76: 74:         </div>
77: 75:     }
78: 76: }
79: 77: 
80: 78: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
81: 79: pub async fn handle_g_auth_redirect(
82: 80:     provided_csrf: String,
83: 81:     code: String,
84: 82: ) -> Result<(String, u64), ServerFnError> {
85: 83:     use crate::ssr_imports::*;
86: 84:     use ssr_imports::*;
87: 85: 
88: 86:     let oauth_lyx-core-lyx_core_lyx-core-lyx_core_client = expect_context::<AppState>().lyx-core-lyx_core_lyx-core-lyx_core_client;
89: 87:     let pool = pool()?;
90: 88:     let auth_session = auth()?;
91: 89:     // If there's no match we'll return an error.
92: 90:     let _ = sqlx::query_as::<_, SqlCsrfToken>(
93: 91:         "SELECT csrf_token FROM csrf_tokens WHERE csrf_token = ?",
94: 92:     )
95: 93:     .bind(provided_csrf)
96: 94:     .fetch_one(&pool)
97: 95:     .await
98: 96:     .map_err(|err| ServerFnError::new(format!("CSRF_TOKEN error : {err:?}")))?;
99: 97: 
100: 98:     let token_response = oauth_lyx-core-lyx_core_lyx-core-lyx_core_client
101: 99:         .exchange_code(AuthorizationCode::new(code.clone()))
102: 100:         .request_async(async_http_lyx-core-lyx_core_lyx-core-lyx_core_client)
103: 101:         .await?;
104: 102:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log!("{:?}", &token_response);
105: 103:     let access_token = token_response.access_token().secret();
106: 104:     let expires_in = token_response.expires_in().unwrap().as_secs();
107: 105:     let refresh_secret = token_response.refresh_token().unwrap().secret();
108: 106:     let user_info_url = "https://www.googleapis.com/oauth2/v3/userinfo";
109: 107:     let lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
110: 108:     let response = lyx-core-lyx_core_lyx-core-lyx_core_client
111: 109:         .get(user_info_url)
112: 110:         .bearer_auth(access_token)
113: 111:         .send()
114: 112:         .await?;
115: 113: 
116: 114:     let email = if response.status().is_success() {
117: 115:         let response_json: Value = response.json().await?;
118: 116:         lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log!("{response_json:?}");
119: 117:         response_json["email"]
120: 118:             .as_str()
121: 119:             .expect("email to parse to string")
122: 120:             .to_string()
123: 121:     } else {
124: 122:         return Err(ServerFnError::new(format!(
125: 123:             "Response from google has status of {}",
126: 124:             response.status()
127: 125:         )));
128: 126:     };
129: 127: 
130: 128:     let user = if let Some(user) = User::get_from_email(&email, &pool).await {
131: 129:         user
132: 130:     } else {
133: 131:         sqlx::query("INSERT INTO users (email) VALUES (?)")
134: 132:             .bind(&email)
135: 133:             .execute(&pool)
136: 134:             .await?;
137: 135:         User::get_from_email(&email, &pool).await.unwrap()
138: 136:     };
139: 137: 
140: 138:     auth_session.login_user(user.id);
141: 139: 
142: 140:     sqlx::query("DELETE FROM google_tokens WHERE user_id == ?")
143: 141:         .bind(user.id)
144: 142:         .execute(&pool)
145: 143:         .await?;
146: 144: 
147: 145:     sqlx::query(
148: 146:         "INSERT INTO google_tokens (user_id,access_secret,refresh_secret) \
149: 147:          VALUES (?,?,?)",
150: 148:     )
151: 149:     .bind(user.id)
152: 150:     .bind(access_token)
153: 151:     .bind(refresh_secret)
154: 152:     .execute(&pool)
155: 153:     .await?;
156: 154: 
157: 155:     Ok((user.email, expires_in as u64))
158: 156: }
159: 157: 
160: 158: #[derive(Params, Debug, PartialEq, Clone)]
161: 159: pub struct OAuthParams {
162: 160:     pub code: Option<String>,
163: 161:     pub state: Option<String>,
164: 162: }
165: 163: 
166: 164: #[component]
167: 165: pub fn HandleGAuth() -> impl IntoView {
168: 166:     let handle_g_auth_redirect = Action::<HandleGAuthRedirect, _>::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server();
169: 167: 
170: 168:     let query = use_query::<OAuthParams>();
171: 169:     let navigate = lyx-core-lyx_core_lyx-core-router::use_navigate();
172: 170:     let rw_email = expect_context::<Email>().0;
173: 171:     let rw_expires_in = expect_context::<ExpiresIn>().0;
174: 172:     create_effect(move |_| {
175: 173:         if let Some(Ok((email, expires_in))) =
176: 174:             handle_g_auth_redirect.value().get()
177: 175:         {
178: 176:             rw_email.set(Some(email));
179: 177:             rw_expires_in.set(expires_in);
180: 178:             navigate("/", NavigateOptions::default());
181: 179:         }
182: 180:     });
183: 181: 
184: 182:     create_effect(move |_| {
185: 183:         if let Ok(OAuthParams { code, state }) = query.get_untracked() {
186: 184:             handle_g_auth_redirect.dispatch(HandleGAuthRedirect {
187: 185:                 provided_csrf: state.unwrap(),
188: 186:                 code: code.unwrap(),
189: 187:             });
190: 188:         } else {
191: 189:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log!("error parsing oauth params");
192: 190:         }
193: 191:     });
194: 192:     view! {}
195: 193: }
196: 194: 
197: 195: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
198: 196: pub async fn logout() -> Result<(), ServerFnError> {
199: 197:     use crate::ssr_imports::*;
200: 198: 
201: 199:     let auth = auth()?;
202: 200:     auth.logout_user();
203: 201:     lyx-core-axum::redirect("/");
204: 202:     Ok(())
205: 203: }
206: 204: 
207: 205: #[component]
208: 206: pub fn LogOut() -> impl IntoView {
209: 207:     let log_out = create_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action::<Logout>();
210: 208:     view! {
211: 209:         <button on:click=move|_|log_out.dispatch(Logout{})>{"log out"}</button>
212: 210:     }
213: 211: }
214: ```
```
