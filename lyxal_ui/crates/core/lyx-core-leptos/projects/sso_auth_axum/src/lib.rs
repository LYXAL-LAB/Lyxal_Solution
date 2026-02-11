### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_sso_auth_axum\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum\src\lib.rs
2: ```rust
3: 1: pub mod auth;
4: 2: pub mod error_template;
5: 3: #[cfg(feature = "ssr")]
6: 4: pub mod fallback;
7: 5: pub mod sign_in_sign_up;
8: 6: #[cfg(feature = "ssr")]
9: 7: pub mod state;
10: 8: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::TimeoutHandle, *};
11: 9: use lyx-core-lyx_core_lyx-core-meta::*;
12: 10: use lyx-core-lyx_core_lyx-core-router::*;
13: 11: use sign_in_sign_up::*;
14: 12: 
15: 13: #[cfg(feature = "ssr")]
16: 14: mod ssr_imports {
17: 15:     pub use crate::auth::ssr_imports::{AuthSession, SqlRefreshToken};
18: 16:     pub use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{use_context, ServerFnError};
19: 17:     pub use oauth2::{reqwest::async_http_lyx-core-lyx_core_lyx-core-lyx_core_client, TokenResponse};
20: 18:     pub use sqlx::SqlitePool;
21: 19: 
22: 20:     pub fn pool() -> Result<SqlitePool, ServerFnError> {
23: 21:         use_context::<SqlitePool>()
24: 22:             .ok_or_else(|| ServerFnError::new("Pool missing."))
25: 23:     }
26: 24: 
27: 25:     pub fn auth() -> Result<AuthSession, ServerFnError> {
28: 26:         use_context::<AuthSession>()
29: 27:             .ok_or_else(|| ServerFnError::new("Auth session missing."))
30: 28:     }
31: 29: }
32: 30: 
33: 31: #[derive(Clone, Debug)]
34: 32: pub struct Email(RwSignal<Option<String>>);
35: 33: #[derive(Clone, Debug)]
36: 34: pub struct ExpiresIn(RwSignal<u64>);
37: 35: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
38: 36: pub async fn refresh_token(email: String) -> Result<u64, ServerFnError> {
39: 37:     use crate::{auth::User, state::AppState};
40: 38:     use ssr_imports::*;
41: 39: 
42: 40:     let pool = pool()?;
43: 41:     let oauth_lyx-core-lyx_core_lyx-core-lyx_core_client = expect_context::<AppState>().lyx-core-lyx_core_lyx-core-lyx_core_client;
44: 42:     let user = User::get_from_email(&email, &pool)
45: 43:         .await
46: 44:         .ok_or(ServerFnError::new("User not found"))?;
47: 45: 
48: 46:     let refresh_secret = sqlx::query_as::<_, SqlRefreshToken>(
49: 47:         "SELECT secret FROM google_refresh_tokens WHERE user_id = ?",
50: 48:     )
51: 49:     .bind(user.id)
52: 50:     .fetch_one(&pool)
53: 51:     .await?
54: 52:     .secret;
55: 53: 
56: 54:     let token_response = oauth_lyx-core-lyx_core_lyx-core-lyx_core_client
57: 55:         .exchange_refresh_token(&oauth2::RefreshToken::new(refresh_secret))
58: 56:         .request_async(async_http_lyx-core-lyx_core_lyx-core-lyx_core_client)
59: 57:         .await?;
60: 58: 
61: 59:     let access_token = token_response.access_token().secret();
62: 60:     let expires_in = token_response.expires_in().unwrap().as_secs();
63: 61:     let refresh_secret = token_response.refresh_token().unwrap().secret();
64: 62:     sqlx::query("DELETE FROM google_tokens WHERE user_id == ?")
65: 63:         .bind(user.id)
66: 64:         .execute(&pool)
67: 65:         .await?;
68: 66:     sqlx::query(
69: 67:         "INSERT OR REPLACE INTO google_tokens (user_id,access_secret,refresh_secret) \
70: 68:          VALUES (?,?,?)",
71: 69:     )
72: 70:     .bind(user.id)
73: 71:     .bind(access_token)
74: 72:     .bind(refresh_secret)
75: 73:     .execute(&pool)
76: 74:     .await?;
77: 75:     Ok(expires_in)
78: 76: }
79: 77: 
80: 78: #[component]
81: 79: pub fn App() -> impl IntoView {
82: 80:     provide_meta_context();
83: 81:     let email = RwSignal::new(None::<String>);
84: 82:     let rw_expires_in = RwSignal::new(0);
85: 83:     provide_context(Email(email));
86: 84:     provide_context(ExpiresIn(rw_expires_in));
87: 85: 
88: 86:     let display_email =
89: 87:         move || email.get().unwrap_or(String::from("No email to display"));
90: 88:     let refresh_token = create_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action::<RefreshToken>();
91: 89: 
92: 90:     create_effect(move |handle: Option<Option<TimeoutHandle>>| {
93: 91:         // If this effect is called, try to cancel the previous handle.
94: 92:         if let Some(prev_handle) = handle.flatten() {
95: 93:             prev_handle.clear();
96: 94:         };
97: 95:         // if expires_in isn't 0, then set a timeout that rerfresh a minute short of the refresh.
98: 96:         let expires_in = rw_expires_in.get();
99: 97:         if expires_in != 0 && email.get_untracked().is_some() {
100: 98:             let handle = set_timeout_with_handle(
101: 99:                 move || {
102: 100:                     refresh_token.dispatch(RefreshToken {
103: 101:                         email: email.get_untracked().unwrap(),
104: 102:                     })
105: 103:                 },
106: 104:                 std::time::Duration::from_secs(
107: 105:                     // Google tokens last 3599 seconds, so we'll get a refresh token every 14 seconds.
108: 106:                     expires_in.checked_sub(3545).unwrap_or_default(),
109: 107:                 ),
110: 108:             )
111: 109:             .unwrap();
112: 110:             Some(handle)
113: 111:         } else {
114: 112:             None
115: 113:         }
116: 114:     });
117: 115: 
118: 116:     create_effect(move |_| {
119: 117:         if let Some(Ok(expires_in)) = refresh_token.value().get() {
120: 118:             rw_expires_in.set(expires_in);
121: 119:         }
122: 120:     });
123: 121: 
124: 122:     view! {
125: 123:         <Stylesheet id="lyx-core-lyx_core_lyx-core-lyx_core_leptos" href="/pkg/lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum.css"/>
126: 124:         <Link rel="shortcut icon" type_="image/ico" href="/favicon.ico"/>
127: 125:         <Title text="SSO Auth Axum"/>
128: 126:         <Router>
129: 127:             <main>
130: 128:                 <Routes>
131: 129:                     <Route path="" view=move || {
132: 130:                         view!{
133: 131:                             {display_email}
134: 132:                             <Show when=move || email.get().is_some() fallback=||view!{<SignIn/>}>
135: 133:                                 <LogOut/>
136: 134:                             </Show>
137: 135:                             }
138: 136:                         }/>
139: 137:                     <Route path="g_auth" view=||view!{<HandleGAuth/>}/>
140: 138:                 </Routes>
141: 139:             </main>
142: 140:         </Router>
143: 141:     }
144: 142: }
145: 143: 
146: 144: #[cfg(feature = "hydrate")]
147: 145: #[wasm_bindgen::prelude::wasm_bindgen]
148: 146: pub fn hydrate() {
149: 147:     _ = console_log::init_with_level(log::Level::Debug);
150: 148:     console_error_panic_hook::set_once();
151: 149: 
152: 150:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount_to_body(App);
153: 151: }
154: ```
```
