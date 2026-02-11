### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_sso_auth_axum\src\auth.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum\src\auth.rs
2: ```rust
3: 1: use serde::{Deserialize, Serialize};
4: 2: use std::collections::HashSet;
5: 3: 
6: 4: #[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
7: 5: pub struct User {
8: 6:     pub id: i64,
9: 7:     pub email: String,
10: 8:     pub permissions: HashSet<String>,
11: 9: }
12: 10: 
13: 11: impl Default for User {
14: 12:     fn default() -> Self {
15: 13:         let permissions = HashSet::new();
16: 14: 
17: 15:         Self {
18: 16:             id: -1,
19: 17:             email: "lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example@lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.com".into(),
20: 18:             permissions,
21: 19:         }
22: 20:     }
23: 21: }
24: 22: 
25: 23: #[cfg(feature = "ssr")]
26: 24: pub mod ssr_imports {
27: 25:     use super::User;
28: 26:     pub use axum_session_auth::{
29: 27:         Authentication, HasPermission, SessionSqlitePool,
30: 28:     };
31: 29:     pub use sqlx::SqlitePool;
32: 30:     use std::collections::HashSet;
33: 31:     pub type AuthSession = axum_session_auth::AuthSession<
34: 32:         User,
35: 33:         i64,
36: 34:         SessionSqlitePool,
37: 35:         SqlitePool,
38: 36:     >;
39: 37: 
40: 38:     use async_trait::async_trait;
41: 39: 
42: 40:     impl User {
43: 41:         pub async fn get(id: i64, pool: &SqlitePool) -> Option<Self> {
44: 42:             let sqluser = sqlx::query_as::<_, SqlUser>(
45: 43:                 "SELECT * FROM users WHERE id = ?",
46: 44:             )
47: 45:             .bind(id)
48: 46:             .fetch_one(pool)
49: 47:             .await
50: 48:             .ok()?;
51: 49: 
52: 50:             //lets just get all the tokens the user can use, we will only use the full permissions if modifying them.
53: 51:             let sql_user_perms = sqlx::query_as::<_, SqlPermissionTokens>(
54: 52:                 "SELECT token FROM user_permissions WHERE user_id = ?;",
55: 53:             )
56: 54:             .bind(id)
57: 55:             .fetch_all(pool)
58: 56:             .await
59: 57:             .ok()?;
60: 58: 
61: 59:             Some(sqluser.into_user(Some(sql_user_perms)))
62: 60:         }
63: 61: 
64: 62:         pub async fn get_from_email(
65: 63:             email: &str,
66: 64:             pool: &SqlitePool,
67: 65:         ) -> Option<Self> {
68: 66:             let sqluser = sqlx::query_as::<_, SqlUser>(
69: 67:                 "SELECT * FROM users WHERE email = ?",
70: 68:             )
71: 69:             .bind(email)
72: 70:             .fetch_one(pool)
73: 71:             .await
74: 72:             .ok()?;
75: 73: 
76: 74:             //lets just get all the tokens the user can use, we will only use the full permissions if modifying them.
77: 75:             let sql_user_perms = sqlx::query_as::<_, SqlPermissionTokens>(
78: 76:                 "SELECT token FROM user_permissions WHERE user_id = ?;",
79: 77:             )
80: 78:             .bind(sqluser.id)
81: 79:             .fetch_all(pool)
82: 80:             .await
83: 81:             .ok()?;
84: 82: 
85: 83:             Some(sqluser.into_user(Some(sql_user_perms)))
86: 84:         }
87: 85:     }
88: 86: 
89: 87:     #[derive(sqlx::FromRow, Clone)]
90: 88:     pub struct SqlPermissionTokens {
91: 89:         pub token: String,
92: 90:     }
93: 91: 
94: 92:     #[derive(sqlx::FromRow, Clone)]
95: 93:     pub struct SqlCsrfToken {
96: 94:         pub csrf_token: String,
97: 95:     }
98: 96: 
99: 97:     #[async_trait]
100: 98:     impl Authentication<User, i64, SqlitePool> for User {
101: 99:         async fn load_user(
102: 100:             userid: i64,
103: 101:             pool: Option<&SqlitePool>,
104: 102:         ) -> Result<User, anyhow::Error> {
105: 103:             let pool = pool.unwrap();
106: 104: 
107: 105:             User::get(userid, pool)
108: 106:                 .await
109: 107:                 .ok_or_else(|| anyhow::anyhow!("Cannot get user"))
110: 108:         }
111: 109: 
112: 110:         fn is_authenticated(&self) -> bool {
113: 111:             true
114: 112:         }
115: 113: 
116: 114:         fn is_active(&self) -> bool {
117: 115:             true
118: 116:         }
119: 117: 
120: 118:         fn is_anonymous(&self) -> bool {
121: 119:             false
122: 120:         }
123: 121:     }
124: 122: 
125: 123:     #[async_trait]
126: 124:     impl HasPermission<SqlitePool> for User {
127: 125:         async fn has(&self, perm: &str, _pool: &Option<&SqlitePool>) -> bool {
128: 126:             self.permissions.contains(perm)
129: 127:         }
130: 128:     }
131: 129: 
132: 130:     #[derive(sqlx::FromRow, Clone)]
133: 131:     pub struct SqlUser {
134: 132:         pub id: i64,
135: 133:         pub email: String,
136: 134:     }
137: 135: 
138: 136:     #[derive(sqlx::FromRow, Clone)]
139: 137:     pub struct SqlRefreshToken {
140: 138:         pub secret: String,
141: 139:     }
142: 140: 
143: 141:     impl SqlUser {
144: 142:         pub fn into_user(
145: 143:             self,
146: 144:             sql_user_perms: Option<Vec<SqlPermissionTokens>>,
147: 145:         ) -> User {
148: 146:             User {
149: 147:                 id: self.id,
150: 148:                 email: self.email,
151: 149:                 permissions: if let Some(user_perms) = sql_user_perms {
152: 150:                     user_perms
153: 151:                         .into_iter()
154: 152:                         .map(|x| x.token)
155: 153:                         .collect::<HashSet<String>>()
156: 154:                 } else {
157: 155:                     HashSet::<String>::new()
158: 156:                 },
159: 157:             }
160: 158:         }
161: 159:     }
162: 160: }
163: ```
```
