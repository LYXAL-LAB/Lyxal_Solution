### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_superposition\src\workspace\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\workspace\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\workspace\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\workspace\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\workspace\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\workspace\handlers.rs
10: 8: ```rust
11: 9: use std::fs;
12: 10: 
13: 11: use actix_web::{
14: 12:     Scope, get, post, routes,
15: 13:     web::{self, Data, Json, Path, Query},
16: 14: };
17: 15: use chrono::Utc;
18: 16: use diesel::{
19: 17:     Connection, ExpressionMethods, PgConnection, QueryDsl, RunQueryDsl,
20: 18:     TextExpressionMethods,
21: 19:     connection::SimpleConnection,
22: 20:     r2d2::{ConnectionManager, PooledConnection},
23: 21: };
24: 22: use regex::Regex;
25: 23: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
26: 24:     encryption::{
27: 25:         encrypt_workspace_key, generate_encryption_key,
28: 26:         rotate_workspace_encryption_key_helper,
29: 27:     },
30: 28:     helpers::get_workspace,
31: 29:     service::types::{
32: 30:         AppState, DbConnection, OrganisationId, SchemaName, WorkspaceContext, WorkspaceId,
33: 31:     },
34: 32: };
35: 33: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
36: 34: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, db_error, unexpected_error, validation_error};
37: 35: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
38: 36:     PaginatedResponse, User,
39: 37:     api::{
40: 38:         I64Update,
41: 39:         workspace::{
42: 40:             CreateWorkspaceRequest, KeyRotationResponse, UpdateWorkspaceRequest,
43: 41:             WorkspaceListFilters, WorkspaceResponse,
44: 42:         },
45: 43:     },
46: 44:     custom_query::PaginationParams,
47: 45:     database::{
48: 46:         models::{Organisation, Workspace, WorkspaceStatus},
49: 47:         schema::config_versions::dsl as config_versions,
50: 48:         lyx-core-lyx_core_lyx-core-lyx_core_superposition_schema::lyx-core-lyx_core_lyx-core-lyx_core_superposition::{organisations, workspaces},
51: 49:     },
52: 50:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
53: 51: };
54: 52: 
55: 53: const WORKSPACE_TEMPLATE_PATH: &str = "workspace_template.sql";
56: 54: 
57: 55: fn setup_workspace_schema(
58: 56:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
59: 57:     workspace_schema_name: &str,
60: 58: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
61: 59:     let workspace_template =
62: 60:         fs::read_to_string(WORKSPACE_TEMPLATE_PATH).map_err(|err| {
63: 61:             log::error!("Could not load the workspace template due to {}", err);
64: 62:             unexpected_error!(
65: 63:                 "Could not load the workspace template, please contact an admin"
66: 64:             )
67: 65:         })?;
68: 66:     let workspace_template =
69: 67:         workspace_template.replace("{replaceme}", workspace_schema_name);
70: 68:     conn.batch_execute(&workspace_template).map_err(|err| {
71: 69:         log::error!(
72: 70:             "Could not create workspace {} due to {}",
73: 71:             workspace_schema_name,
74: 72:             err
75: 73:         );
76: 74:         db_error!(err)
77: 75:     })?;
78: 76:     Ok(())
79: 77: }
80: 78: 
81: 79: pub fn endpoints(scope: Scope) -> Scope {
82: 80:     scope
83: 81:         .service(create_handler)
84: 82:         .service(update_handler)
85: 83:         .service(list_handler)
86: 84:         .service(get_handler)
87: 85:         .service(migrate_schema_handler)
88: 86:         .service(rotate_encryption_key_handler)
89: 87: }
90: 88: 
91: 89: #[authorized]
92: 90: #[get("/{workspace_name}")]
93: 91: async fn get_handler(
94: 92:     workspace_name: Path<String>,
95: 93:     db_conn: DbConnection,
96: 94:     org_id: OrganisationId,
97: 95: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<WorkspaceResponse>> {
98: 96:     let DbConnection(mut conn) = db_conn;
99: 97:     let workspace_name = workspace_name.into_inner();
100: 98:     let workspace: Workspace = workspaces::dsl::workspaces
101: 99:         .filter(workspaces::organisation_id.eq(&org_id.0))
102: 100:         .filter(workspaces::workspace_name.eq(workspace_name))
103: 101:         .get_result(&mut conn)?;
104: 102:     let response = WorkspaceResponse::from(workspace);
105: 103:     Ok(Json(response))
106: 104: }
107: 105: 
108: 106: #[authorized]
109: 107: #[post("")]
110: 108: async fn create_handler(
111: 109:     request: Json<CreateWorkspaceRequest>,
112: 110:     db_conn: DbConnection,
113: 111:     org_id: OrganisationId,
114: 112:     user: User,
115: 113:     state: web::Data<AppState>,
116: 114: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<WorkspaceResponse>> {
117: 115:     let DbConnection(mut conn) = db_conn;
118: 116:     let org_info: Organisation = organisations::dsl::organisations
119: 117:         .filter(organisations::id.eq(&org_id.0))
120: 118:         .get_result::<Organisation>(&mut conn)?;
121: 119:     let timestamp = Utc::now();
122: 120:     let request = request.into_inner();
123: 121:     let email = user.get_email();
124: 122:     validate_workspace_name(&request.workspace_name)?;
125: 123:     let workspace_schema_name = format!("{}_{}", &org_info.id, &request.workspace_name);
126: 124: 
127: 125:     let encryption_key = match state.master_encryption_key {
128: 126:         Some(ref master_encryption_key) => {
129: 127:             let encryption_key = generate_encryption_key();
130: 128:             encrypt_workspace_key(&encryption_key, &master_encryption_key.current_key)
131: 129:                 .map_err(|e| {
132: 130:                     log::error!("Failed to encrypt workspace key: {}", e);
133: 131:                     unexpected_error!("Failed to encrypt workspace key")
134: 132:                 })?
135: 133:         }
136: 134:         None => {
137: 135:             log::warn!(
138: 136:                 "Master encryption key not configured, workspace will be created without encryption"
139: 137:             );
140: 138:             String::new()
141: 139:         }
142: 140:     };
143: 141: 
144: 142:     let workspace = Workspace {
145: 143:         organisation_id: org_info.id,
146: 144:         organisation_name: org_info.name,
147: 145:         workspace_name: request.workspace_name,
148: 146:         workspace_schema_name: workspace_schema_name.clone(),
149: 147:         workspace_status: WorkspaceStatus::ENABLED,
150: 148:         workspace_admin_email: request.workspace_admin_email,
151: 149:         config_version: None,
152: 150:         created_by: email.clone(),
153: 151:         last_modified_by: email,
154: 152:         last_modified_at: timestamp,
155: 153:         created_at: timestamp,
156: 154:         mandatory_dimensions: None,
157: 155:         metrics: request.metrics.unwrap_or_default(),
158: 156:         allow_experiment_self_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approval: request.allow_experiment_self_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approval,
159: 157:         auto_populate_control: request.auto_populate_control,
160: 158:         enable_context_validation: request.enable_context_validation,
161: 159:         enable_change_reason_validation: request.enable_change_reason_validation,
162: 160:         encryption_key,
163: 161:         key_rotated_at: None,
164: 162:     };
165: 163: 
166: 164:     let created_workspace =
167: 165:         conn.transaction::<Workspace, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
168: 166:             let mut inserted_workspace: Vec<Workspace> =
169: 167:                 diesel::insert_into(workspaces::dsl::workspaces)
170: 168:                     .values(workspace)
171: 169:                     .get_results(transaction_conn)?;
172: 170: 
173: 171:             setup_workspace_schema(transaction_conn, &workspace_schema_name)?;
174: 172:             Ok(inserted_workspace.remove(0))
175: 173:         })?;
176: 174:     let response = WorkspaceResponse::from(created_workspace);
177: 175:     Ok(Json(response))
178: 176: }
179: 177: 
180: 178: #[authorized]
181: 179: #[routes]
182: 180: #[put("/{workspace_name}")]
183: 181: #[patch("/{workspace_name}")]
184: 182: async fn update_handler(
185: 183:     workspace_name: web::Path<String>,
186: 184:     request: Json<UpdateWorkspaceRequest>,
187: 185:     db_conn: DbConnection,
188: 186:     org_id: OrganisationId,
189: 187:     user: User,
190: 188: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<WorkspaceResponse>> {
191: 189:     let request = request.into_inner();
192: 190:     let workspace_name = workspace_name.into_inner();
193: 191:     let timestamp = Utc::now();
194: 192:     let schema_name = SchemaName(format!("{}_{}", *org_id, workspace_name));
195: 193:     // TODO: mandatory dimensions updation needs to be validated
196: 194:     // for the existance of the dimensions in the workspace
197: 195:     let DbConnection(mut conn) = db_conn;
198: 196:     if let Some(I64Update::Add(version)) = request.config_version {
199: 197:         let _ = config_versions::config_versions
200: 198:             .select(config_versions::id)
201: 199:             .filter(config_versions::id.eq(version))
202: 200:             .schema_name(&schema_name)
203: 201:             .first::<i64>(&mut conn)?;
204: 202:     }
205: 203: 
206: 204:     let updated_workspace =
207: 205:         conn.transaction::<Workspace, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
208: 206:             let updated_workspace = diesel::update(workspaces::table)
209: 207:                 .filter(workspaces::organisation_id.eq(&org_id.0))
210: 208:                 .filter(workspaces::workspace_name.eq(workspace_name))
211: 209:                 .set((
212: 210:                     request,
213: 211:                     workspaces::last_modified_by.eq(user.email),
214: 212:                     workspaces::last_modified_at.eq(timestamp),
215: 213:                 ))
216: 214:                 .get_result::<Workspace>(transaction_conn)
217: 215:                 .map_err(|err| {
218: 216:                     log::error!("failed to update workspace with error: {}", err);
219: 217:                     err
220: 218:                 })?;
221: 219: 
222: 220:             Ok(updated_workspace)
223: 221:         })?;
224: 222:     let response = WorkspaceResponse::from(updated_workspace);
225: 223:     Ok(Json(response))
226: 224: }
227: 225: 
228: 226: #[authorized]
229: 227: #[get("")]
230: 228: async fn list_handler(
231: 229:     db_conn: DbConnection,
232: 230:     pagination_filters: Query<PaginationParams>,
233: 231:     filters: Query<WorkspaceListFilters>,
234: 232:     org_id: OrganisationId,
235: 233: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<WorkspaceResponse>>> {
236: 234:     let DbConnection(mut conn) = db_conn;
237: 235:     if let Some(true) = pagination_filters.all {
238: 236:         let result: Vec<WorkspaceResponse> = workspaces::dsl::workspaces
239: 237:             .filter(workspaces::organisation_id.eq(&org_id.0))
240: 238:             .get_results::<Workspace>(&mut conn)?
241: 239:             .into_iter()
242: 240:             .map(WorkspaceResponse::from)
243: 241:             .collect();
244: 242:         return Ok(Json(PaginatedResponse::all(result)));
245: 243:     };
246: 244: 
247: 245:     let filters = filters.into_inner();
248: 246:     let query_builder = |filters: &WorkspaceListFilters| {
249: 247:         let mut builder = workspaces::dsl::workspaces
250: 248:             .filter(workspaces::organisation_id.eq(&org_id.0))
251: 249:             .into_boxed();
252: 250:         if let Some(ref workspace_name) = filters.workspace_name {
253: 251:             builder = builder.filter(
254: 252:                 workspaces::dsl::workspace_name.like(format!("%{}%", workspace_name)),
255: 253:             );
256: 254:         }
257: 255:         builder
258: 256:     };
259: 257: 
260: 258:     let count_query = query_builder(&filters);
261: 259:     let base_query = query_builder(&filters);
262: 260: 
263: 261:     let n_types: i64 = count_query.count().get_result(&mut conn)?;
264: 262:     let limit = pagination_filters.count.unwrap_or(10);
265: 263:     let mut builder = base_query
266: 264:         .order(workspaces::dsl::created_at.desc())
267: 265:         .limit(limit);
268: 266:     if let Some(page) = pagination_filters.page {
269: 267:         let offset = (page - 1) * limit;
270: 268:         builder = builder.offset(offset);
271: 269:     }
272: 270:     let workspaces: Vec<WorkspaceResponse> = builder
273: 271:         .load::<Workspace>(&mut conn)?
274: 272:         .into_iter()
275: 273:         .map(WorkspaceResponse::from)
276: 274:         .collect();
277: 275:     let total_pages = (n_types as f64 / limit as f64).ceil() as i64;
278: 276:     Ok(Json(PaginatedResponse {
279: 277:         total_pages,
280: 278:         total_items: n_types,
281: 279:         data: workspaces,
282: 280:     }))
283: 281: }
284: 282: 
285: 283: const WORKSPACE_NAME_REGEX: &str = "^[a-zA-Z0-9]+$";
286: 284: 
287: 285: fn validate_workspace_name(workspace_name: &String) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
288: 286:     let regex = Regex::new(WORKSPACE_NAME_REGEX).map_err(|err| {
289: 287:         log::error!("Could not process the regex for validating workspace names {err}");
290: 288:         unexpected_error!("Could not process the regex for validating workspace names")
291: 289:     })?;
292: 290:     match workspace_name {
293: 291:         w_name if w_name.len() > 25 => {
294: 292:             log::error!(
295: 293:                 "the workspace name {} was larger than 25 bytes/characters, the actual length was {}",
296: 294:                 w_name,
297: 295:                 w_name.len()
298: 296:             );
299: 297:             Err(validation_error!(
300: 298:                 "the workspace name cannot be larger than 25 characters"
301: 299:             ))
302: 300:         }
303: 301:         w_name if !regex.is_match(w_name) => {
304: 302:             log::error!(
305: 303:                 "the workspace name {} did not match the regex {}",
306: 304:                 w_name,
307: 305:                 WORKSPACE_NAME_REGEX
308: 306:             );
309: 307:             Err(validation_error!(
310: 308:                 "the workspace name can only contain letters and numbers"
311: 309:             ))
312: 310:         }
313: 311:         _ => Ok(()),
314: 312:     }
315: 313: }
316: 314: 
317: 315: #[authorized]
318: 316: #[post("/{workspace_name}/db/migrate")]
319: 317: async fn migrate_schema_handler(
320: 318:     workspace_name: Path<String>,
321: 319:     db_conn: DbConnection,
322: 320:     org_id: OrganisationId,
323: 321:     state: Data<AppState>,
324: 322:     user: User,
325: 323: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<WorkspaceResponse>> {
326: 324:     let workspace_name = workspace_name.into_inner();
327: 325:     let DbConnection(mut conn) = db_conn;
328: 326:     let schema_name = SchemaName(format!("{}_{}", *org_id, &workspace_name));
329: 327:     let workspace = get_workspace(&schema_name, &mut conn)?;
330: 328: 
331: 329:     conn.transaction::<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
332: 330:         setup_workspace_schema(transaction_conn, &workspace.workspace_schema_name)?;
333: 331:         if workspace.encryption_key.is_empty() {
334: 332:             match state.master_encryption_key {
335: 333:                 Some(ref master_encryption_key) => {
336: 334:                     let new_key = generate_encryption_key();
337: 335:                     let encrypted_key =
338: 336:                         encrypt_workspace_key(&new_key, &master_encryption_key.current_key).map_err(|e| {
339: 337:                             log::error!("Failed to encrypt workspace key: {}", e);
340: 338:                             unexpected_error!("Failed to encrypt workspace key")
341: 339:                         })?;
342: 340: 
343: 341:                     diesel::update(workspaces::table)
344: 342:                         .filter(workspaces::organisation_id.eq(&org_id.0))
345: 343:                         .filter(workspaces::workspace_name.eq(&workspace_name))
346: 344:                         .set((
347: 345:                             workspaces::encryption_key.eq(encrypted_key),
348: 346:                             workspaces::last_modified_by.eq(user.get_username()),
349: 347:                             workspaces::last_modified_at.eq(Utc::now())
350: 348:                         ))
351: 349:                         .execute(transaction_conn)?;
352: 350:                 }
353: 351:                 None => {
354: 352:                     log::warn!(
355: 353:                         "Master encryption key not configured, skipping encryption setup for workspace '{}'. \
356: 354:                         Secrets will not be available for this workspace.",
357: 355:                         workspace_name
358: 356:                     );
359: 357:                 }
360: 358:             }
361: 359:         }
362: 360:         Ok(())
363: 361:     })?;
364: 362: 
365: 363:     let response = WorkspaceResponse::from(workspace);
366: 364:     Ok(Json(response))
367: 365: }
368: 366: 
369: 367: #[authorized]
370: 368: #[post("/{workspace_name}/rotate-encryption-key")]
371: 369: pub async fn rotate_encryption_key_handler(
372: 370:     workspace_name: Path<String>,
373: 371:     user: User,
374: 372:     db_conn: DbConnection,
375: 373:     org_id: OrganisationId,
376: 374:     state: Data<AppState>,
377: 375: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<KeyRotationResponse>> {
378: 376:     let DbConnection(mut conn) = db_conn;
379: 377: 
380: 378:     let Some(ref master_encryption_key) = state.master_encryption_key else {
381: 379:         log::error!("Master encryption key not configured");
382: 380:         return Err(bad_argument!(
383: 381:             "Master encryption key not configured. Configure master encryption key to rotate keys"
384: 382:         ));
385: 383:     };
386: 384: 
387: 385:     let schema_name = SchemaName(format!("{}_{}", *org_id, workspace_name.into_inner()));
388: 386:     let workspace = get_workspace(&schema_name, &mut conn)?;
389: 387:     let workspace_context = WorkspaceContext {
390: 388:         schema_name,
391: 389:         organisation_id: org_id,
392: 390:         workspace_id: WorkspaceId(workspace.workspace_name.clone()),
393: 391:         settings: workspace,
394: 392:     };
395: 393: 
396: 394:     let total_secrets_re_encrypted = conn
397: 395:         .transaction::<i64, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|conn| {
398: 396:             rotate_workspace_encryption_key_helper(
399: 397:                 &workspace_context,
400: 398:                 conn,
401: 399:                 master_encryption_key,
402: 400:                 &user.get_username(),
403: 401:             )
404: 402:         })?;
405: 403: 
406: 404:     Ok(Json(KeyRotationResponse {
407: 405:         total_secrets_re_encrypted,
408: 406:     }))
409: 407: }
410: 408: ```
411: 409: ```
412: 410: ```
413: 411: ```
414: ```
```
