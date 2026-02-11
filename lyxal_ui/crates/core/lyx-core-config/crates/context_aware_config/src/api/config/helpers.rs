### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\config\helpers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\helpers.rs
10: 8: ```rust
11: 9: use actix_http::header::HeaderValue;
12: 10: use actix_web::{
13: 11:     HttpRequest, HttpResponseBuilder,
14: 12:     web::{Header, Json},
15: 13: };
16: 14: use lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client::{eval_cac, eval_cac_with_reasoning};
17: 15: use chrono::{DateTime, Timelike, Utc};
18: 16: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, dsl::max};
19: 17: use serde_json::{Map, Value};
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{
21: 19:     AppHeader, EncryptionKey, SchemaName, WorkspaceContext,
22: 20: };
23: 21: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, db_error, unexpected_error};
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
25: 23:     Config, DBConnection,
26: 24:     api::config::{ContextPayload, MergeStrategy, ResolveConfigQuery},
27: 25:     custom_query::{CommaSeparatedStringQParams, DimensionQuery, QueryMap},
28: 26:     database::schema::{
29: 27:         config_versions::dsl as config_versions, event_log::dsl as event_log,
30: 28:     },
31: 29:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
32: 30: };
33: 31: use uuid::Uuid;
34: 32: 
35: 33: use crate::helpers::{evaluate_remote_cohorts, generate_cac};
36: 34: 
37: 35: pub fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_prefix_filter_to_config(
38: 36:     prefix: &Option<CommaSeparatedStringQParams>,
39: 37:     mut config: Config,
40: 38: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Config> {
41: 39:     if let Some(prefix) = prefix {
42: 40:         config = config.filter_by_prefix(&prefix.iter().map(Clone::clone).collect());
43: 41:     }
44: 42: 
45: 43:     Ok(config)
46: 44: }
47: 45: 
48: 46: pub fn get_config_version(
49: 47:     version: &Option<String>,
50: 48:     workspace_context: &WorkspaceContext,
51: 49: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Option<i64>> {
52: 50:     version.as_ref().map_or_else(
53: 51:         || Ok(workspace_context.settings.config_version),
54: 52:         |version| {
55: 53:             if *version == *"latest" {
56: 54:                 log::trace!("latest config request");
57: 55:                 return Ok(None);
58: 56:             }
59: 57:             version.parse::<i64>().map_or_else(
60: 58:                 |e| {
61: 59:                     log::error!(
62: 60:                         "failed to decode version as integer: {version}, error: {e}"
63: 61:                     );
64: 62:                     Err(bad_argument!("version is not of type integer"))
65: 63:                 },
66: 64:                 |v| Ok(Some(v)),
67: 65:             )
68: 66:         },
69: 67:     )
70: 68: }
71: 69: 
72: 70: pub fn add_audit_id_to_header(
73: 71:     conn: &mut DBConnection,
74: 72:     resp_builder: &mut HttpResponseBuilder,
75: 73:     schema_name: &SchemaName,
76: 74: ) {
77: 75:     if let Ok(uuid) = event_log::event_log
78: 76:         .select(event_log::id)
79: 77:         .filter(event_log::table_name.eq("contexts"))
80: 78:         .order_by(event_log::timestamp.desc())
81: 79:         .schema_name(schema_name)
82: 80:         .first::<Uuid>(conn)
83: 81:     {
84: 82:         resp_builder.insert_header((AppHeader::XAuditId.to_string(), uuid.to_string()));
85: 83:     } else {
86: 84:         log::error!("Failed to fetch contexts from event_log");
87: 85:     }
88: 86: }
89: 87: 
90: 88: pub fn add_last_modified_to_header(
91: 89:     max_created_at: Option<DateTime<Utc>>,
92: 90:     is_smithy: bool,
93: 91:     resp_builder: &mut HttpResponseBuilder,
94: 92: ) {
95: 93:     if let Some(date) = max_created_at {
96: 94:         let value = if is_smithy {
97: 95:             // Smithy needs to be in this format otherwise they can't
98: 96:             // deserialize it.
99: 97:             HeaderValue::from_str(date.to_rfc3339().as_str())
100: 98:         } else {
101: 99:             HeaderValue::from_str(date.to_rfc2822().as_str())
102: 100:         };
103: 101:         if let Ok(header_value) = value {
104: 102:             resp_builder
105: 103:                 .insert_header((AppHeader::LastModified.to_string(), header_value));
106: 104:         } else {
107: 105:             log::error!("failed parsing datetime_utc {:?}", value);
108: 106:         }
109: 107:     }
110: 108: }
111: 109: 
112: 110: pub fn add_config_version_to_header(
113: 111:     config_version: &Option<i64>,
114: 112:     resp_builder: &mut HttpResponseBuilder,
115: 113: ) {
116: 114:     if let Some(val) = config_version {
117: 115:         resp_builder.insert_header((
118: 116:             AppHeader::XConfigVersion.to_string(),
119: 117:             val.clone().to_string(),
120: 118:         ));
121: 119:     }
122: 120: }
123: 121: 
124: 122: pub fn get_max_created_at(
125: 123:     conn: &mut DBConnection,
126: 124:     schema_name: &SchemaName,
127: 125: ) -> Result<DateTime<Utc>, diesel::result::Error> {
128: 126:     config_versions::config_versions
129: 127:         .select(max(config_versions::created_at))
130: 128:         .schema_name(schema_name)
131: 129:         .first::<Option<DateTime<Utc>>>(conn)
132: 130:         .and_then(|res| res.ok_or(diesel::result::Error::NotFound))
133: 131: }
134: 132: 
135: 133: pub fn is_not_modified(max_created_at: Option<DateTime<Utc>>, req: &HttpRequest) -> bool {
136: 134:     let nanosecond_erasure = |t: DateTime<Utc>| t.with_nanosecond(0);
137: 135:     let last_modified = req
138: 136:         .headers()
139: 137:         .get("If-Modified-Since")
140: 138:         .and_then(|header_val| {
141: 139:             let header_str = header_val.to_str().ok()?;
142: 140:             DateTime::parse_from_rfc2822(header_str)
143: 141:                 .map(|datetime| datetime.with_timezone(&Utc))
144: 142:                 .ok()
145: 143:         })
146: 144:         .and_then(nanosecond_erasure);
147: 145:     log::info!("last modified {last_modified:?}");
148: 146:     let parsed_max: Option<DateTime<Utc>> = max_created_at.and_then(nanosecond_erasure);
149: 147:     max_created_at.is_some() && parsed_max <= last_modified
150: 148: }
151: 149: 
152: 150: pub fn generate_config_from_version(
153: 151:     version: &mut Option<i64>,
154: 152:     conn: &mut DBConnection,
155: 153:     schema_name: &SchemaName,
156: 154: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Config> {
157: 155:     if let Some(val) = version {
158: 156:         let config = config_versions::config_versions
159: 157:             .select(config_versions::config)
160: 158:             .filter(config_versions::id.eq(*val))
161: 159:             .schema_name(schema_name)
162: 160:             .get_result::<Value>(conn)
163: 161:             .map_err(|err| {
164: 162:                 log::error!("failed to fetch config with error: {}", err);
165: 163:                 db_error!(err)
166: 164:             })?;
167: 165:         serde_json::from_value::<Config>(config).map_err(|err| {
168: 166:             log::error!("failed to decode config: {}", err);
169: 167:             unexpected_error!("failed to decode config")
170: 168:         })
171: 169:     } else {
172: 170:         match config_versions::config_versions
173: 171:             .select((config_versions::id, config_versions::config))
174: 172:             .order(config_versions::created_at.desc())
175: 173:             .schema_name(schema_name)
176: 174:             .first::<(i64, Value)>(conn)
177: 175:         {
178: 176:             Ok((latest_version, config)) => {
179: 177:                 *version = Some(latest_version);
180: 178:                 serde_json::from_value::<Config>(config).or_else(|err| {
181: 179:                     log::error!("failed to decode config: {}", err);
182: 180:                     generate_cac(conn, schema_name)
183: 181:                 })
184: 182:             }
185: 183:             Err(err) => {
186: 184:                 log::error!("failed to find latest config: {err}");
187: 185:                 generate_cac(conn, schema_name)
188: 186:             }
189: 187:         }
190: 188:     }
191: 189: }
192: 190: 
193: 191: pub fn setup_query_data(
194: 192:     req: &HttpRequest,
195: 193:     body: &Option<Json<ContextPayload>>,
196: 194:     dimension_params: &DimensionQuery<QueryMap>,
197: 195: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<(bool, QueryMap)> {
198: 196:     let is_smithy: bool;
199: 197:     let query_data = if req.method() == actix_web::http::Method::GET {
200: 198:         is_smithy = false;
201: 199:         (**dimension_params).clone()
202: 200:     } else {
203: 201:         is_smithy = true;
204: 202:         body.as_ref()
205: 203:             .ok_or(bad_argument!(
206: 204:                 "When using POST, context needs to be provided in the body."
207: 205:             ))?
208: 206:             .context
209: 207:             .clone()
210: 208:             .into()
211: 209:     };
212: 210:     Ok((is_smithy, query_data))
213: 211: }
214: 212: 
215: 213: pub fn resolve(
216: 214:     config: &mut Config,
217: 215:     mut query_data: QueryMap,
218: 216:     merge_strategy: Header<MergeStrategy>,
219: 217:     conn: &mut DBConnection,
220: 218:     query_filters: &ResolveConfigQuery,
221: 219:     workspace_context: &WorkspaceContext,
222: 220:     master_encryption_key: &Option<EncryptionKey>,
223: 221: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Map<String, Value>> {
224: 222:     *config = lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_prefix_filter_to_config(&query_filters.prefix, config.clone())?;
225: 223: 
226: 224:     if let Some(context_id) = &query_filters.context_id {
227: 225:         config.contexts = if let Some(index) = config
228: 226:             .contexts
229: 227:             .iter()
230: 228:             .position(|ctx| ctx.id == context_id.clone())
231: 229:         {
232: 230:             config.contexts[..index].to_vec()
233: 231:         } else {
234: 232:             return Err(bad_argument!(
235: 233:                 "context with id {} not found in CAC",
236: 234:                 context_id
237: 235:             ));
238: 236:         };
239: 237:     }
240: 238: 
241: 239:     if query_filters.resolve_remote.unwrap_or_default() {
242: 240:         query_data = QueryMap::from(evaluate_remote_cohorts(
243: 241:             &config.dimensions,
244: 242:             &query_data,
245: 243:             conn,
246: 244:             workspace_context,
247: 245:             master_encryption_key,
248: 246:         )?);
249: 247:     }
250: 248: 
251: 249:     let merge_strategy = merge_strategy.into_inner();
252: 250:     let show_reason = query_filters.show_reasoning.unwrap_or_default();
253: 251:     let response = if show_reason {
254: 252:         eval_cac_with_reasoning(config, &query_data, merge_strategy).map_err(|err| {
255: 253:             log::error!("failed to eval cac with err: {}", err);
256: 254:             unexpected_error!("cac eval failed")
257: 255:         })
258: 256:     } else {
259: 257:         eval_cac(config, &query_data, merge_strategy).map_err(|err| {
260: 258:             log::error!("failed to eval cac with err: {}", err);
261: 259:             unexpected_error!("cac eval failed")
262: 260:         })
263: 261:     }?;
264: 262: 
265: 263:     Ok(response)
266: 264: }
267: 265: ```
268: 266: ```
269: 267: ```
270: 268: ```
271: ```
```
