1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\secrets\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     Scope, delete, get, patch, post,
13: 11:     web::{self, Data, Json, Query},
14: 12: };
15: 13: use diesel::{Connection, ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
16: 14: use secrecy::SecretString;
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
18: 16:     encryption::{
19: 17:         decrypt_workspace_key, encrypt_secret, rotate_workspace_encryption_key_helper,
20: 18:     },
21: 19:     service::types::{
22: 20:         AppState, DbConnection, EncryptionKey, OrganisationId, SchemaName,
23: 21:         WorkspaceContext, WorkspaceId,
24: 22:     },
25: 23: };
26: 24: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, unexpected_error};
28: 26: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
29: 27:     PaginatedResponse, SortBy, User,
30: 28:     api::secrets::{
31: 29:         CreateSecretRequest, MasterEncryptionKeyRotationResponse, SecretFilters,
32: 30:         SecretResponse, SortOn, UpdateSecretRequest,
33: 31:     },
34: 32:     custom_query::PaginationParams,
35: 33:     database::{
36: 34:         models::{Workspace, others::Secret},
37: 35:         schema::secrets,
38: 36:         lyx-core-lyx_core_lyx-core-lyx_core_superposition_schema::lyx-core-lyx_core_lyx-core-lyx_core_superposition::workspaces,
39: 37:     },
40: 38:     result::{self as lyx-core-lyx_core_lyx-core-lyx_core_superposition},
41: 39: };
42: 40: 
43: 41: use super::types::UpdateSecretChangeset;
44: 42: 
45: 43: pub fn endpoints() -> Scope {
46: 44:     web::scope("")
47: 45:         .service(list_handler)
48: 46:         .service(create_handler)
49: 47:         .service(get_handler)
50: 48:         .service(update_handler)
51: 49:         .service(delete_handler)
52: 50: }
53: 51: 
54: 52: pub fn master_key_endpoints() -> Scope {
55: 53:     web::scope("").service(rotate_master_key_handler)
56: 54: }
57: 55: 
58: 56: fn get_workspace_encryption_key(
59: 57:     workspace_context: &WorkspaceContext,
60: 58:     master_encryption_key: &Option<EncryptionKey>,
61: 59: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<SecretString> {
62: 60:     let workspace: &Workspace = &workspace_context.settings;
63: 61: 
64: 62:     let Some(master_encryption_key) = master_encryption_key else {
65: 63:         log::error!("Master encryption key not configured");
66: 64:         return Err(bad_argument!(
67: 65:             "Master encryption key not configured. Configure master encryption key to use secrets"
68: 66:         ));
69: 67:     };
70: 68: 
71: 69:     let decrypted_key =
72: 70:         decrypt_workspace_key(&workspace.encryption_key, master_encryption_key).map_err(
73: 71:             |e| {
74: 72:                 log::error!("Failed to decrypt workspace key: {}", e);
75: 73:                 unexpected_error!("Failed to decrypt workspace encryption key")
76: 74:             },
77: 75:         )?;
78: 76: 
79: 77:     Ok(decrypted_key)
80: 78: }
81: 79: 
82: 80: #[authorized]
83: 81: #[get("")]
84: 82: async fn list_handler(
85: 83:     workspace_context: WorkspaceContext,
86: 84:     db_conn: DbConnection,
87: 85:     pagination: Query<PaginationParams>,
88: 86:     filters: Query<SecretFilters>,
89: 87: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<SecretResponse>>> {
90: 88:     let DbConnection(mut conn) = db_conn;
91: 89: 
92: 90:     let filters_inner = filters.into_inner();
93: 91: 
94: 92:     let query_builder = |filters: &SecretFilters| {
95: 93:         let mut builder = secrets::table
96: 94:             .schema_name(&workspace_context.schema_name)
97: 95:             .into_boxed();
98: 96: 
99: 97:         if let Some(ref secret_names) = filters.name {
100: 98:             builder = builder.filter(secrets::name.eq_any(secret_names.0.clone()));
101: 99:         }
102: 100: 
103: 101:         if let Some(ref creators) = filters.created_by {
104: 102:             builder = builder.filter(secrets::created_by.eq_any(creators.0.clone()));
105: 103:         }
106: 104: 
107: 105:         if let Some(ref last_modifiers) = filters.last_modified_by {
108: 106:             builder = builder
109: 107:                 .filter(secrets::last_modified_by.eq_any(last_modifiers.0.clone()));
110: 108:         }
111: 109: 
112: 110:         builder
113: 111:     };
114: 112: 
115: 113:     if let Some(true) = pagination.all {
116: 114:         let result = query_builder(&filters_inner).get_results::<Secret>(&mut conn)?;
117: 115:         return Ok(Json(PaginatedResponse::all(
118: 116:             result.into_iter().map(SecretResponse::from).collect(),
119: 117:         )));
120: 118:     }
121: 119: 
122: 120:     let base_query = query_builder(&filters_inner);
123: 121:     let count_query = query_builder(&filters_inner);
124: 122: 
125: 123:     let n_secrets: i64 = count_query.count().get_result(&mut conn)?;
126: 124:     let limit = pagination.count.unwrap_or(10);
127: 125: 
128: 126:     let sort_on = filters_inner.sort_on.unwrap_or_default();
129: 127:     let sort_by_order = filters_inner.sort_by.unwrap_or_default();
130: 128: 
131: 129:     #[rustfmt::skip]
132: 130:     let base_query = match (sort_on, sort_by_order) {
133: 131:         (SortOn::Name,           SortBy::Asc)  => base_query.order(secrets::name.asc()),
134: 132:         (SortOn::Name,           SortBy::Desc) => base_query.order(secrets::name.desc()),
135: 133:         (SortOn::CreatedAt,      SortBy::Asc)  => base_query.order(secrets::created_at.asc()),
136: 134:         (SortOn::CreatedAt,      SortBy::Desc) => base_query.order(secrets::created_at.desc()),
137: 135:         (SortOn::LastModifiedAt, SortBy::Asc)  => base_query.order(secrets::last_modified_at.asc()),
138: 136:         (SortOn::LastModifiedAt, SortBy::Desc) => base_query.order(secrets::last_modified_at.desc()),
139: 137:     };
140: 138: 
141: 139:     let mut builder = base_query.limit(limit);
142: 140:     if let Some(page) = pagination.page {
143: 141:         let offset = (page - 1) * limit;
144: 142:         builder = builder.offset(offset);
145: 143:     }
146: 144:     let result = builder.load::<Secret>(&mut conn)?;
147: 145: 
148: 146:     let total_pages = (n_secrets as f64 / limit as f64).ceil() as i64;
149: 147:     Ok(Json(PaginatedResponse {
150: 148:         total_pages,
151: 149:         total_items: n_secrets,
152: 150:         data: result.into_iter().map(SecretResponse::from).collect(),
153: 151:     }))
154: 152: }
155: 153: 
156: 154: #[authorized]
157: 155: #[post("")]
158: 156: async fn create_handler(
159: 157:     req: web::Json<CreateSecretRequest>,
160: 158:     user: User,
161: 159:     db_conn: DbConnection,
162: 160:     workspace_context: WorkspaceContext,
163: 161:     state: Data<AppState>,
164: 162: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<SecretResponse>> {
165: 163:     let req = req.into_inner();
166: 164: 
167: 165:     let DbConnection(mut conn) = db_conn;
168: 166: 
169: 167:     let encryption_key =
170: 168:         get_workspace_encryption_key(&workspace_context, &state.master_encryption_key)?;
171: 169: 
172: 170:     let encrypted_secret_value = encrypt_secret(&req.value, &encryption_key)
173: 171:         .map_err(|e| bad_argument!("Encryption failed: {}", e))?;
174: 172: 
175: 173:     let now = chrono::Utc::now();
176: 174: 
177: 175:     let new_secret = Secret {
178: 176:         name: req.name,
179: 177:         encrypted_value: encrypted_secret_value,
180: 178:         description: req.description,
181: 179:         change_reason: req.change_reason.clone(),
182: 180:         created_at: now,
183: 181:         last_modified_at: now,
184: 182:         created_by: user.get_email(),
185: 183:         last_modified_by: user.get_email(),
186: 184:     };
187: 185: 
188: 186:     let created_secret = diesel::insert_into(secrets::table)
189: 187:         .values(&new_secret)
190: 188:         .returning(Secret::as_returning())
191: 189:         .schema_name(&workspace_context.schema_name)
192: 190:         .get_result(&mut conn)?;
193: 191: 
194: 192:     Ok(Json(SecretResponse::from(created_secret)))
195: 193: }
196: 194: 
197: 195: #[authorized]
198: 196: #[get("/{secret_name}")]
199: 197: async fn get_handler(
200: 198:     path: web::Path<String>,
201: 199:     db_conn: DbConnection,
202: 200:     workspace_context: WorkspaceContext,
203: 201: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<SecretResponse>> {
204: 202:     let DbConnection(mut conn) = db_conn;
205: 203: 
206: 204:     let secret_name = path.into_inner();
207: 205: 
208: 206:     let secret = secrets::table
209: 207:         .filter(secrets::name.eq(secret_name))
210: 208:         .schema_name(&workspace_context.schema_name)
211: 209:         .get_result::<Secret>(&mut conn)?;
212: 210: 
213: 211:     Ok(Json(SecretResponse::from(secret)))
214: 212: }
215: 213: 
216: 214: #[authorized]
217: 215: #[patch("/{secret_name}")]
218: 216: async fn update_handler(
219: 217:     path: web::Path<String>,
220: 218:     req: web::Json<UpdateSecretRequest>,
221: 219:     user: User,
222: 220:     db_conn: DbConnection,
223: 221:     workspace_context: WorkspaceContext,
224: 222:     state: Data<AppState>,
225: 223: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<SecretResponse>> {
226: 224:     let DbConnection(mut conn) = db_conn;
227: 225:     let secret_name = path.into_inner();
228: 226:     let req_inner = req.into_inner();
229: 227: 
230: 228:     let encrypted_value_opt = if let Some(ref plaintext_value) = req_inner.value {
231: 229:         let encryption_key = get_workspace_encryption_key(
232: 230:             &workspace_context,
233: 231:             &state.master_encryption_key,
234: 232:         )?;
235: 233:         Some(
236: 234:             encrypt_secret(plaintext_value, &encryption_key)
237: 235:                 .map_err(|e| bad_argument!("Encryption failed: {}", e))?,
238: 236:         )
239: 237:     } else {
240: 238:         None
241: 239:     };
242: 240: 
243: 241:     let changeset = UpdateSecretChangeset {
244: 242:         encrypted_value: encrypted_value_opt,
245: 243:         description: req_inner.description,
246: 244:         change_reason: req_inner.change_reason,
247: 245:     };
248: 246: 
249: 247:     let updated_secret = diesel::update(secrets::table)
250: 248:         .filter(secrets::name.eq(secret_name))
251: 249:         .set((
252: 250:             changeset,
253: 251:             secrets::last_modified_at.eq(chrono::Utc::now()),
254: 252:             secrets::last_modified_by.eq(user.get_email()),
255: 253:         ))
256: 254:         .schema_name(&workspace_context.schema_name)
257: 255:         .get_result::<Secret>(&mut conn)?;
258: 256: 
259: 257:     Ok(Json(SecretResponse::from(updated_secret)))
260: 258: }
261: 259: 
262: 260: #[authorized]
263: 261: #[delete("/{secret_name}")]
264: 262: async fn delete_handler(
265: 263:     path: web::Path<String>,
266: 264:     user: User,
267: 265:     db_conn: DbConnection,
268: 266:     workspace_context: WorkspaceContext,
269: 267: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<SecretResponse>> {
270: 268:     let DbConnection(mut conn) = db_conn;
271: 269:     let secret_name = path.into_inner();
272: 270: 
273: 271:     diesel::update(secrets::table)
274: 272:         .filter(secrets::name.eq(&secret_name))
275: 273:         .set((
276: 274:             secrets::last_modified_at.eq(chrono::Utc::now()),
277: 275:             secrets::last_modified_by.eq(user.get_email()),
278: 276:         ))
279: 277:         .schema_name(&workspace_context.schema_name)
280: 278:         .execute(&mut conn)?;
281: 279: 
282: 280:     let deleted_secret = diesel::delete(secrets::table)
283: 281:         .filter(secrets::name.eq(&secret_name))
284: 282:         .schema_name(&workspace_context.schema_name)
285: 283:         .get_result::<Secret>(&mut conn)?;
286: 284: 
287: 285:     Ok(Json(SecretResponse::from(deleted_secret)))
288: 286: }
289: 287: 
290: 288: // Note: Not to be used during mid migration - to avoid old replicas from failing
291: 289: #[authorized]
292: 290: #[post("/rotate")]
293: 291: pub async fn rotate_master_key_handler(
294: 292:     user: User,
295: 293:     db_conn: DbConnection,
296: 294:     state: Data<AppState>,
297: 295: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<MasterEncryptionKeyRotationResponse>> {
298: 296:     let DbConnection(mut conn) = db_conn;
299: 297: 
300: 298:     let Some(ref master_encryption_key) = state.master_encryption_key else {
301: 299:         log::error!("Master encryption key not configured");
302: 300:         return Err(bad_argument!(
303: 301:             "Master encryption key not configured. Configure master encryption key to rotate keys"
304: 302:         ));
305: 303:     };
306: 304: 
307: 305:     master_encryption_key.previous_key.as_ref().ok_or_else(|| {
308: 306:         bad_argument!(
309: 307:             "PREVIOUS_MASTER_ENCRYPTION_KEY must be set to rotate master encryption key"
310: 308:         )
311: 309:     })?;
312: 310: 
313: 311:     let all_workspaces: Vec<Workspace> = workspaces::table.load(&mut conn)?;
314: 312: 
315: 313:     let user_email = user.get_email();
316: 314: 
317: 315:     let (workspaces_rotated, total_secrets_re_encrypted) = conn
318: 316:         .transaction::<(i64, i64), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|conn| {
319: 317:             let mut workspaces_rotated = 0i64;
320: 318:             let mut total_secrets_re_encrypted = 0i64;
321: 319: 
322: 320:             for workspace in all_workspaces {
323: 321:                 let workspace_context = WorkspaceContext {
324: 322:                     workspace_id: WorkspaceId(workspace.workspace_name.clone()),
325: 323:                     organisation_id: OrganisationId(workspace.organisation_id.clone()),
326: 324:                     schema_name: SchemaName(workspace.workspace_schema_name.clone()),
327: 325:                     settings: workspace,
328: 326:                 };
329: 327:                 match rotate_workspace_encryption_key_helper(
330: 328:                     &workspace_context,
331: 329:                     conn,
332: 330:                     master_encryption_key,
333: 331:                     &user_email,
334: 332:                 ) {
335: 333:                     Ok(secrets_count) => {
336: 334:                         workspaces_rotated += 1;
337: 335:                         total_secrets_re_encrypted += secrets_count;
338: 336:                     }
339: 337:                     Err(e) => {
340: 338:                         log::error!(
341: 339:                             "Failed to rotate keys for workspace {}: {}",
342: 340:                             workspace_context.schema_name.0,
343: 341:                             e
344: 342:                         );
345: 343:                         return Err(e);
346: 344:                     }
347: 345:                 }
348: 346:             }
349: 347: 
350: 348:             Ok((workspaces_rotated, total_secrets_re_encrypted))
351: 349:         })?;
352: 350: 
353: 351:     log::info!(
354: 352:         "Successfully rotated master encryption key. Rotated {} workspaces, re-encrypted {} secrets.",
355: 353:         workspaces_rotated,
356: 354:         total_secrets_re_encrypted
357: 355:     );
358: 356: 
359: 357:     let result = MasterEncryptionKeyRotationResponse {
360: 358:         workspaces_rotated,
361: 359:         total_secrets_re_encrypted,
362: 360:     };
363: 361: 
364: 362:     Ok(Json(result))
365: 363: }
366: 364: ```
367: 365: ```
368: 366: ```
369: 367: ```
370: ```
```

