### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\service\types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\service\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\service\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\service\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\service\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\service\types.rs
10: 8: ```rust
11: 9: use std::sync::Mutex;
12: 10: use std::{
13: 11:     collections::HashSet,
14: 12:     future::{Ready, ready},
15: 13:     str::FromStr,
16: 14:     sync::Arc,
17: 15: };
18: 16: 
19: 17: use actix_web::{Error, FromRequest, HttpMessage, error, web::Data};
20: 18: use derive_more::{Deref, DerefMut};
21: 19: use diesel::r2d2::{ConnectionManager, PooledConnection};
22: 20: use diesel::{Connection, PgConnection};
23: 21: use jsonschema::JSONSchema;
24: 22: use secrecy::SecretString;
25: 23: use serde::{Deserialize, Serialize};
26: 24: use snowflake::SnowflakeIdGenerator;
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::models::Workspace;
28: 26: 
29: 27: use crate::db::PgSchemaConnectionPool;
30: 28: 
31: 29: pub struct ExperimentationFlags {
32: 30:     pub allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: bool,
33: 31:     pub allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: bool,
34: 32:     pub allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: bool,
35: 33: }
36: 34: 
37: 35: #[derive(Copy, Clone, Debug)]
38: 36: pub enum AppEnv {
39: 37:     PROD,
40: 38:     SANDBOX,
41: 39:     TEST,
42: 40:     DEV,
43: 41: }
44: 42: 
45: 43: #[derive(Copy, Clone, Debug, strum_macros::Display)]
46: 44: #[strum(serialize_all = "kebab-case")]
47: 45: pub enum AppHeader {
48: 46:     XConfigVersion,
49: 47:     XAuditId,
50: 48:     LastModified,
51: 49: }
52: 50: 
53: 51: pub struct EncryptionKey {
54: 52:     pub current_key: SecretString,
55: 53:     pub previous_key: Option<SecretString>,
56: 54: }
57: 55: 
58: 56: pub struct AppState {
59: 57:     pub cac_host: String,
60: 58:     pub lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: AppEnv,
61: 59:     pub cac_version: String,
62: 60:     pub db_pool: PgSchemaConnectionPool,
63: 61:     pub meta_schema: JSONSchema,
64: 62:     pub experimentation_flags: ExperimentationFlags,
65: 63:     pub snowflake_generator: Arc<Mutex<SnowflakeIdGenerator>>,
66: 64:     pub tenant_middleware_exclusion_list: HashSet<String>,
67: 65:     pub service_prefix: String,
68: 66:     pub lyx-core-lyx_core_lyx-core-lyx_core_superposition_token: String,
69: 67:     #[cfg(feature = "high-performance-mode")]
70: 68:     pub redis: fred::lyx-core-lyx_core_lyx-core-lyx_core_clients::RedisPool,
71: 69:     pub http_lyx-core-lyx_core_lyx-core-lyx_core_client: reqwest::Client,
72: 70:     pub master_encryption_key: Option<EncryptionKey>,
73: 71: }
74: 72: 
75: 73: impl FromStr for AppEnv {
76: 74:     type Err = String;
77: 75:     fn from_str(val: &str) -> Result<AppEnv, Self::Err> {
78: 76:         match val {
79: 77:             "PROD" => Ok(AppEnv::PROD),
80: 78:             "SANDBOX" => Ok(AppEnv::SANDBOX),
81: 79:             "DEV" => Ok(AppEnv::DEV),
82: 80:             "TEST" => Ok(AppEnv::TEST),
83: 81:             _ => Err("invalid lyx-platform-lyx_platform_lyx-platform-lyx_platform_app env!!".to_string()),
84: 82:         }
85: 83:     }
86: 84: }
87: 85: 
88: 86: #[derive(Copy, Clone, Debug, strum_macros::Display, Deserialize, Serialize)]
89: 87: #[strum(serialize_all = "snake_case")]
90: 88: #[serde(rename_all = "snake_case")]
91: 89: pub enum Resource {
92: 90:     DefaultConfig,
93: 91:     Dimension,
94: 92:     Context,
95: 93:     Function,
96: 94:     TypeTemplate,
97: 95:     Config,
98: 96:     Experiment,
99: 97:     ExperimentGroup,
100: 98:     Workspace,
101: 99:     Organisation,
102: 100:     Webhook,
103: 101:     AuditLog,
104: 102:     Auth,
105: 103:     Variable,
106: 104:     Secret,
107: 105:     MasterEncryptionKey,
108: 106: }
109: 107: 
110: 108: impl Resource {
111: 109:     pub fn workspace_for(&self, workspace_context: &WorkspaceContext) -> String {
112: 110:         matches!(self, Self::Workspace | Self::Auth)
113: 111:             .then_some(workspace_context.organisation_id.0.clone())
114: 112:             .unwrap_or_else(|| workspace_context.schema_name.0.clone())
115: 113:     }
116: 114: }
117: 115: 
118: 116: #[derive(Deref, DerefMut, Clone, Debug)]
119: 117: pub struct WorkspaceId(pub String);
120: 118: 
121: 119: impl FromRequest for WorkspaceId {
122: 120:     type Error = Error;
123: 121:     type Future = Ready<Result<Self, Self::Error>>;
124: 122: 
125: 123:     fn from_request(
126: 124:         req: &actix_web::HttpRequest,
127: 125:         _: &mut actix_web::dev::Payload,
128: 126:     ) -> Self::Future {
129: 127:         let result = req.extensions().get::<Self>().cloned().ok_or_else(|| {
130: 128:             log::error!("Workspace Id not found");
131: 129:             actix_web::error::ErrorInternalServerError("Workspace Id not found")
132: 130:         });
133: 131: 
134: 132:         ready(result)
135: 133:     }
136: 134: }
137: 135: 
138: 136: #[derive(Deref, DerefMut, Clone, Debug)]
139: 137: pub struct OrganisationId(pub String);
140: 138: 
141: 139: impl Default for OrganisationId {
142: 140:     fn default() -> Self {
143: 141:         Self(String::from("lyx-core-lyx_core_lyx-core-lyx_core_superposition"))
144: 142:     }
145: 143: }
146: 144: 
147: 145: impl FromRequest for OrganisationId {
148: 146:     type Error = Error;
149: 147:     type Future = Ready<Result<Self, Self::Error>>;
150: 148: 
151: 149:     fn from_request(
152: 150:         req: &actix_web::HttpRequest,
153: 151:         _: &mut actix_web::dev::Payload,
154: 152:     ) -> Self::Future {
155: 153:         let result = req.extensions().get::<Self>().cloned().ok_or_else(|| {
156: 154:             log::error!("Organisation Id not found");
157: 155:             actix_web::error::ErrorInternalServerError("Organisation Id not found")
158: 156:         });
159: 157: 
160: 158:         ready(result)
161: 159:     }
162: 160: }
163: 161: 
164: 162: #[derive(Deref, DerefMut, Clone, Debug)]
165: 163: pub struct SchemaName(pub String);
166: 164: 
167: 165: impl Default for SchemaName {
168: 166:     fn default() -> Self {
169: 167:         Self(String::from("lyx-core-lyx_core_lyx-core-lyx_core_superposition"))
170: 168:     }
171: 169: }
172: 170: 
173: 171: impl FromRequest for SchemaName {
174: 172:     type Error = Error;
175: 173:     type Future = Ready<Result<Self, Self::Error>>;
176: 174: 
177: 175:     fn from_request(
178: 176:         req: &actix_web::HttpRequest,
179: 177:         _: &mut actix_web::dev::Payload,
180: 178:     ) -> Self::Future {
181: 179:         let result = req.extensions().get::<Self>().cloned().ok_or_else(|| {
182: 180:             log::error!("Please check that the organisation id and workspace id are being properly sent");
183: 181:             actix_web::error::ErrorInternalServerError("Please check that the organisation id and workspace id are being properly sent")
184: 182:         });
185: 183: 
186: 184:         ready(result)
187: 185:     }
188: 186: }
189: 187: 
190: 188: #[derive(Clone)]
191: 189: pub struct WorkspaceContext {
192: 190:     pub workspace_id: WorkspaceId,
193: 191:     pub organisation_id: OrganisationId,
194: 192:     pub schema_name: SchemaName,
195: 193:     pub settings: Workspace,
196: 194: }
197: 195: 
198: 196: impl FromRequest for WorkspaceContext {
199: 197:     type Error = Error;
200: 198:     type Future = Ready<Result<Self, Self::Error>>;
201: 199: 
202: 200:     fn from_request(
203: 201:         req: &actix_web::HttpRequest,
204: 202:         _: &mut actix_web::dev::Payload,
205: 203:     ) -> Self::Future {
206: 204:         let result = req.extensions().get::<Self>().cloned().ok_or_else(|| {
207: 205:             log::error!("Please check that the organisation id and workspace id are being properly sent");
208: 206:             actix_web::error::ErrorInternalServerError("Please check that the organisation id and workspace id are being properly sent")
209: 207:         });
210: 208: 
211: 209:         ready(result)
212: 210:     }
213: 211: }
214: 212: 
215: 213: #[derive(Deref, DerefMut)]
216: 214: pub struct DbConnection(pub PooledConnection<ConnectionManager<PgConnection>>);
217: 215: impl FromRequest for DbConnection {
218: 216:     type Error = Error;
219: 217:     type Future = Ready<Result<DbConnection, Self::Error>>;
220: 218: 
221: 219:     fn from_request(
222: 220:         req: &actix_web::HttpRequest,
223: 221:         _: &mut actix_web::dev::Payload,
224: 222:     ) -> Self::Future {
225: 223:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = match req.lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data::<Data<AppState>>() {
226: 224:             Some(state) => state,
227: 225:             None => {
228: 226:                 log::info!(
229: 227:                     "DbConnection-FromRequest: Unable to get lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data from request"
230: 228:                 );
231: 229:                 return ready(Err(error::ErrorInternalServerError("")));
232: 230:             }
233: 231:         };
234: 232: 
235: 233:         let result = match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.db_pool.get() {
236: 234:             Ok(mut conn) => {
237: 235:                 conn.set_prepared_statement_cache_size(
238: 236:                     diesel::connection::CacheSize::Disabled,
239: 237:                 );
240: 238:                 Ok(DbConnection(conn))
241: 239:             }
242: 240:             Err(e) => {
243: 241:                 log::info!("Unable to get db connection from pool, error: {e}");
244: 242:                 Err(error::ErrorInternalServerError(""))
245: 243:             }
246: 244:         };
247: 245: 
248: 246:         ready(result)
249: 247:     }
250: 248: }
251: 249: 
252: 250: pub struct CustomHeaders {
253: 251:     pub config_tags: Option<String>,
254: 252: }
255: 253: impl FromRequest for CustomHeaders {
256: 254:     type Error = Error;
257: 255:     type Future = Ready<Result<Self, Self::Error>>;
258: 256: 
259: 257:     fn from_request(
260: 258:         req: &actix_web::HttpRequest,
261: 259:         _: &mut actix_web::dev::Payload,
262: 260:     ) -> Self::Future {
263: 261:         let header_val = req.headers();
264: 262:         let val = CustomHeaders {
265: 263:             config_tags: header_val.get("x-config-tags").and_then(|header_val| {
266: 264:                 header_val.to_str().map_or(None, |v| Some(v.to_string()))
267: 265:             }),
268: 266:         };
269: 267:         ready(Ok(val))
270: 268:     }
271: 269: }
272: 270: ```
273: 271: ```
274: 272: ```
275: 273: ```
276: ```
```
