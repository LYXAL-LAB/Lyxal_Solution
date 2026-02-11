### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\default_config\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\default_config\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\default_config\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\default_config\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\default_config\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\default_config\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     HttpResponse, Scope, delete, get, post, routes,
13: 11:     web::{Data, Json, Path, Query},
14: 12: };
15: 13: use chrono::Utc;
16: 14: use diesel::{
17: 15:     Connection, ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper,
18: 16:     TextExpressionMethods,
19: 17: };
20: 18: use jsonschema::{Draft, JSONSchema, ValidationError};
21: 19: use serde_json::Value;
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
23: 21:     helpers::{parse_config_tags, validation_err_to_str},
24: 22:     service::types::{
25: 23:         AppHeader, AppState, CustomHeaders, DbConnection, EncryptionKey, SchemaName,
26: 24:         WorkspaceContext,
27: 25:     },
28: 26: };
29: 27: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
30: 28: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{
31: 29:     bad_argument, db_error, not_found, unexpected_error, validation_error,
32: 30: };
33: 31: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
34: 32:     DBConnection, PaginatedResponse, User,
35: 33:     api::{
36: 34:         default_config::{
37: 35:             DefaultConfigCreateRequest, DefaultConfigFilters, DefaultConfigKey,
38: 36:             DefaultConfigUpdateRequest,
39: 37:         },
40: 38:         functions::{FunctionEnvironment, FunctionExecutionRequest, KeyType},
41: 39:     },
42: 40:     custom_query::PaginationParams,
43: 41:     database::{
44: 42:         models::{
45: 43:             Description,
46: 44:             cac::{self as models, Context, DefaultConfig, FunctionType},
47: 45:         },
48: 46:         schema::{self, contexts::dsl::contexts, default_configs::dsl},
49: 47:     },
50: 48:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
51: 49: };
52: 50: 
53: 51: #[cfg(feature = "high-performance-mode")]
54: 52: use crate::helpers::put_config_in_redis;
55: 53: use crate::{
56: 54:     api::{
57: 55:         context::helpers::validation_function_executor,
58: 56:         functions::{
59: 57:             helpers::{check_fn_published, get_published_function_code},
60: 58:             types::FunctionInfo,
61: 59:         },
62: 60:     },
63: 61:     helpers::{add_config_version, validate_change_reason},
64: 62: };
65: 63: 
66: 64: pub fn endpoints() -> Scope {
67: 65:     Scope::new("")
68: 66:         .service(create_handler)
69: 67:         .service(update_handler)
70: 68:         .service(get_handler)
71: 69:         .service(list_handler)
72: 70:         .service(delete_handler)
73: 71: }
74: 72: 
75: 73: #[authorized]
76: 74: #[post("")]
77: 75: async fn create_handler(
78: 76:     workspace_context: WorkspaceContext,
79: 77:     state: Data<AppState>,
80: 78:     custom_headers: CustomHeaders,
81: 79:     request: Json<DefaultConfigCreateRequest>,
82: 80:     db_conn: DbConnection,
83: 81:     user: User,
84: 82: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
85: 83:     let DbConnection(mut conn) = db_conn;
86: 84:     let req = request.into_inner();
87: 85:     let key = req.key;
88: 86:     let tags = parse_config_tags(custom_headers.config_tags)?;
89: 87: 
90: 88:     if req.schema.is_empty() {
91: 89:         return Err(bad_argument!("Schema cannot be empty."));
92: 90:     }
93: 91: 
94: 92:     validate_change_reason(
95: 93:         &workspace_context,
96: 94:         &req.change_reason,
97: 95:         &mut conn,
98: 96:         &state.master_encryption_key,
99: 97:     )?;
100: 98: 
101: 99:     let value = req.value;
102: 100: 
103: 101:     let default_config = DefaultConfig {
104: 102:         key: key.to_owned(),
105: 103:         value,
106: 104:         schema: req.schema,
107: 105:         value_validation_function_name: req.value_validation_function_name,
108: 106:         created_by: user.get_email(),
109: 107:         created_at: Utc::now(),
110: 108:         last_modified_at: Utc::now(),
111: 109:         last_modified_by: user.get_email(),
112: 110:         description: req.description,
113: 111:         change_reason: req.change_reason.clone(),
114: 112:         value_compute_function_name: req.value_compute_function_name,
115: 113:     };
116: 114: 
117: 115:     let schema = Value::from(&default_config.schema);
118: 116:     let schema_compile_result = JSONSchema::options()
119: 117:         .with_draft(Draft::Draft7)
120: 118:         .compile(&schema);
121: 119:     let jschema = match schema_compile_result {
122: 120:         Ok(jschema) => jschema,
123: 121:         Err(e) => {
124: 122:             log::info!("Failed to compile as a Draft-7 JSON schema: {e}");
125: 123:             return Err(bad_argument!("Invalid JSON schema (failed to compile)"));
126: 124:         }
127: 125:     };
128: 126: 
129: 127:     if let Err(e) = jschema.validate(&default_config.value) {
130: 128:         let verrors = e.collect::<Vec<ValidationError>>();
131: 129:         log::info!(
132: 130:             "Validation for value with given JSON schema failed: {:?}",
133: 131:             verrors
134: 132:         );
135: 133:         return Err(validation_error!(
136: 134:             "Schema validation failed: {}",
137: 135:             &validation_err_to_str(verrors)
138: 136:                 .first()
139: 137:                 .unwrap_or(&String::new())
140: 138:         ));
141: 139:     }
142: 140: 
143: 141:     validate_default_config_with_function(
144: 142:         &workspace_context,
145: 143:         &mut conn,
146: 144:         &default_config.value_validation_function_name,
147: 145:         &default_config.key,
148: 146:         &default_config.value,
149: 147:         &state.master_encryption_key,
150: 148:     )?;
151: 149: 
152: 150:     validate_fn_published(
153: 151:         &default_config.value_compute_function_name,
154: 152:         FunctionType::ValueCompute,
155: 153:         &mut conn,
156: 154:         &workspace_context.schema_name,
157: 155:     )?;
158: 156: 
159: 157:     let version_id =
160: 158:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
161: 159:             diesel::insert_into(dsl::default_configs)
162: 160:                 .values(&default_config)
163: 161:                 .returning(DefaultConfig::as_returning())
164: 162:                 .schema_name(&workspace_context.schema_name)
165: 163:                 .execute(transaction_conn)?;
166: 164: 
167: 165:             let version_id = add_config_version(
168: 166:                 &state,
169: 167:                 tags,
170: 168:                 req.change_reason.into(),
171: 169:                 transaction_conn,
172: 170:                 &workspace_context.schema_name,
173: 171:             )?;
174: 172:             Ok(version_id)
175: 173:         })?;
176: 174: 
177: 175:     #[cfg(feature = "high-performance-mode")]
178: 176:     put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
179: 177:         .await?;
180: 178:     let mut http_resp = HttpResponse::Ok();
181: 179: 
182: 180:     http_resp.insert_header((
183: 181:         AppHeader::XConfigVersion.to_string(),
184: 182:         version_id.to_string(),
185: 183:     ));
186: 184: 
187: 185:     Ok(http_resp.json(default_config))
188: 186: }
189: 187: 
190: 188: #[authorized]
191: 189: #[get("/{key}")]
192: 190: async fn get_handler(
193: 191:     workspace_context: WorkspaceContext,
194: 192:     key: Path<DefaultConfigKey>,
195: 193:     db_conn: DbConnection,
196: 194: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<DefaultConfig>> {
197: 195:     let DbConnection(mut conn) = db_conn;
198: 196:     let res = fetch_default_key(&key, &mut conn, &workspace_context.schema_name)?;
199: 197:     Ok(Json(res))
200: 198: }
201: 199: 
202: 200: #[allow(clippy::too_many_arguments)]
203: 201: #[authorized]
204: 202: #[routes]
205: 203: #[put("/{key}")]
206: 204: #[patch("/{key}")]
207: 205: async fn update_handler(
208: 206:     workspace_context: WorkspaceContext,
209: 207:     state: Data<AppState>,
210: 208:     key: Path<DefaultConfigKey>,
211: 209:     custom_headers: CustomHeaders,
212: 210:     request: Json<DefaultConfigUpdateRequest>,
213: 211:     db_conn: DbConnection,
214: 212:     user: User,
215: 213: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
216: 214:     let DbConnection(mut conn) = db_conn;
217: 215:     let req = request.into_inner();
218: 216:     let key_str = key.into_inner().into();
219: 217:     let tags = parse_config_tags(custom_headers.config_tags)?;
220: 218: 
221: 219:     let existing = fetch_default_key(&key_str, &mut conn, &workspace_context.schema_name)
222: 220:         .map_err(|e| match e {
223: 221:             lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::DbError(diesel::NotFound) => {
224: 222:                 bad_argument!(
225: 223:                     "No record found for {}. Use create endpoint instead.",
226: 224:                     key_str
227: 225:                 )
228: 226:             }
229: 227:             _ => {
230: 228:                 log::error!("Failed to fetch {key_str}: {e}");
231: 229:                 unexpected_error!("Something went wrong.")
232: 230:             }
233: 231:         })?;
234: 232: 
235: 233:     validate_change_reason(
236: 234:         &workspace_context,
237: 235:         &req.change_reason,
238: 236:         &mut conn,
239: 237:         &state.master_encryption_key,
240: 238:     )?;
241: 239: 
242: 240:     let value = req.value.clone().unwrap_or_else(|| existing.value.clone());
243: 241: 
244: 242:     if let Some(ref schema) = req.schema {
245: 243:         let schema = Value::from(schema);
246: 244: 
247: 245:         let jschema = JSONSchema::options()
248: 246:             .with_draft(Draft::Draft7)
249: 247:             .compile(&schema)
250: 248:             .map_err(|e| {
251: 249:                 log::info!("Failed to compile JSON schema: {e}");
252: 250:                 bad_argument!("Invalid JSON schema.")
253: 251:             })?;
254: 252: 
255: 253:         jschema.validate(&value).map_err(|e| {
256: 254:             let verrors = e.collect::<Vec<ValidationError>>();
257: 255:             validation_error!(
258: 256:                 "Schema validation failed: {}",
259: 257:                 validation_err_to_str(verrors)
260: 258:                     .first()
261: 259:                     .unwrap_or(&String::new())
262: 260:             )
263: 261:         })?;
264: 262:     }
265: 263: 
266: 264:     if let Some(ref validation_function_name) = req.value_validation_function_name {
267: 265:         let value = req.value.clone().unwrap_or_else(|| existing.value.clone());
268: 266: 
269: 267:         validate_default_config_with_function(
270: 268:             &workspace_context,
271: 269:             &mut conn,
272: 270:             validation_function_name,
273: 271:             &key_str,
274: 272:             &value,
275: 273:             &state.master_encryption_key,
276: 274:         )?
277: 275:     }
278: 276: 
279: 277:     if let Some(ref value_compute_function_name) = req.value_compute_function_name {
280: 278:         validate_fn_published(
281: 279:             value_compute_function_name,
282: 280:             FunctionType::ValueCompute,
283: 281:             &mut conn,
284: 282:             &workspace_context.schema_name,
285: 283:         )?;
286: 284:     }
287: 285: 
288: 286:     let (db_row, version_id) =
289: 287:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
290: 288:             let change_reason = req.change_reason.clone();
291: 289:             let val = diesel::update(dsl::default_configs)
292: 290:                 .filter(dsl::key.eq(key_str.clone()))
293: 291:                 .set((
294: 292:                     req,
295: 293:                     dsl::last_modified_at.eq(Utc::now()),
296: 294:                     dsl::last_modified_by.eq(user.get_email()),
297: 295:                 ))
298: 296:                 .schema_name(&workspace_context.schema_name)
299: 297:                 .get_result::<DefaultConfig>(transaction_conn)?;
300: 298: 
301: 299:             let version_id = add_config_version(
302: 300:                 &state,
303: 301:                 tags.clone(),
304: 302:                 change_reason.into(),
305: 303:                 transaction_conn,
306: 304:                 &workspace_context.schema_name,
307: 305:             )?;
308: 306: 
309: 307:             Ok((val, version_id))
310: 308:         })?;
311: 309: 
312: 310:     #[cfg(feature = "high-performance-mode")]
313: 311:     put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
314: 312:         .await?;
315: 313: 
316: 314:     let mut http_resp = HttpResponse::Ok();
317: 315:     http_resp.insert_header((
318: 316:         AppHeader::XConfigVersion.to_string(),
319: 317:         version_id.to_string(),
320: 318:     ));
321: 319:     Ok(http_resp.json(db_row))
322: 320: }
323: 321: 
324: 322: fn validate_fn_published(
325: 323:     function: &Option<String>,
326: 324:     f_type: FunctionType,
327: 325:     conn: &mut DBConnection,
328: 326:     schema_name: &SchemaName,
329: 327: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
330: 328:     let Some(func_name) = function else {
331: 329:         return Ok(());
332: 330:     };
333: 331:     check_fn_published(func_name, f_type, conn, schema_name)
334: 332: }
335: 333: 
336: 334: fn validate_default_config_with_function(
337: 335:     workspace_context: &WorkspaceContext,
338: 336:     conn: &mut DBConnection,
339: 337:     function_name: &Option<String>,
340: 338:     key: &str,
341: 339:     value: &Value,
342: 340:     master_encryption_key: &Option<EncryptionKey>,
343: 341: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
344: 342:     if let Some(f_name) = function_name {
345: 343:         let FunctionInfo {
346: 344:             published_code: function_code,
347: 345:             published_runtime_version: function_version,
348: 346:             ..
349: 347:         } = get_published_function_code(
350: 348:             conn,
351: 349:             f_name,
352: 350:             FunctionType::ValueValidation,
353: 351:             &workspace_context.schema_name,
354: 352:         )
355: 353:         .map_err(|_| {
356: 354:             bad_argument!("Function {}'s published code does not exist.", f_name)
357: 355:         })?;
358: 356:         if let (Some(f_code), Some(f_version)) = (function_code, function_version) {
359: 357:             validation_function_executor(
360: 358:                 workspace_context,
361: 359:                 f_name.as_str(),
362: 360:                 &f_code,
363: 361:                 &FunctionExecutionRequest::ValueValidationFunctionRequest {
364: 362:                     key: key.to_string(),
365: 363:                     value: value.clone(),
366: 364:                     r#type: KeyType::ConfigKey,
367: 365:                     environment: FunctionEnvironment::default(),
368: 366:                 },
369: 367:                 f_version,
370: 368:                 conn,
371: 369:                 master_encryption_key,
372: 370:             )?;
373: 371:         }
374: 372:     };
375: 373:     Ok(())
376: 374: }
377: 375: 
378: 376: fn fetch_default_key(
379: 377:     key: &String,
380: 378:     conn: &mut DBConnection,
381: 379:     schema_name: &SchemaName,
382: 380: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<models::DefaultConfig> {
383: 381:     let res = dsl::default_configs
384: 382:         .filter(schema::default_configs::key.eq(key))
385: 383:         .select(models::DefaultConfig::as_select())
386: 384:         .schema_name(schema_name)
387: 385:         .get_result(conn)?;
388: 386:     Ok(res)
389: 387: }
390: 388: 
391: 389: #[authorized]
392: 390: #[get("")]
393: 391: async fn list_handler(
394: 392:     workspace_context: WorkspaceContext,
395: 393:     db_conn: DbConnection,
396: 394:     pagination: Query<PaginationParams>,
397: 395:     filters: Query<DefaultConfigFilters>,
398: 396: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<DefaultConfig>>> {
399: 397:     let DbConnection(mut conn) = db_conn;
400: 398: 
401: 399:     let filters = filters.into_inner();
402: 400: 
403: 401:     let query_builder = |filters: &DefaultConfigFilters| {
404: 402:         let mut builder = dsl::default_configs
405: 403:             .schema_name(&workspace_context.schema_name)
406: 404:             .into_boxed();
407: 405:         if let Some(ref config_name) = filters.name {
408: 406:             builder = builder
409: 407:                 .filter(schema::default_configs::key.like(format!["%{}%", config_name]));
410: 408:         }
411: 409:         builder
412: 410:     };
413: 411: 
414: 412:     if let Some(true) = pagination.all {
415: 413:         let result: Vec<DefaultConfig> =
416: 414:             query_builder(&filters).get_results(&mut conn)?;
417: 415:         return Ok(Json(PaginatedResponse::all(result)));
418: 416:     }
419: 417: 
420: 418:     let base_query = query_builder(&filters);
421: 419:     let count_query = query_builder(&filters);
422: 420: 
423: 421:     let n_default_configs: i64 = count_query.count().get_result(&mut conn)?;
424: 422:     let limit = pagination.count.unwrap_or(10);
425: 423:     let mut builder = base_query.order(dsl::created_at.desc()).limit(limit);
426: 424:     if let Some(page) = pagination.page {
427: 425:         let offset = (page - 1) * limit;
428: 426:         builder = builder.offset(offset);
429: 427:     }
430: 428:     let result: Vec<DefaultConfig> = builder.load(&mut conn)?;
431: 429:     let total_pages = (n_default_configs as f64 / limit as f64).ceil() as i64;
432: 430:     Ok(Json(PaginatedResponse {
433: 431:         total_pages,
434: 432:         total_items: n_default_configs,
435: 433:         data: result,
436: 434:     }))
437: 435: }
438: 436: 
439: 437: pub fn get_key_usage_context_lyx-core-lyx_core_lyx-core-lyx_core_ids(
440: 438:     key: &str,
441: 439:     conn: &mut DBConnection,
442: 440:     schema_name: &SchemaName,
443: 441: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<String>> {
444: 442:     let result: Vec<Context> =
445: 443:         contexts
446: 444:             .schema_name(schema_name)
447: 445:             .load(conn)
448: 446:             .map_err(|err| {
449: 447:                 log::error!("failed to fetch contexts with error: {}", err);
450: 448:                 db_error!(err)
451: 449:             })?;
452: 450: 
453: 451:     let mut context_lyx-core-lyx_core_lyx-core-lyx_core_ids = vec![];
454: 452:     for context in result.iter() {
455: 453:         context
456: 454:             .override_
457: 455:             .get(key)
458: 456:             .map_or((), |_| context_lyx-core-lyx_core_lyx-core-lyx_core_ids.push(context.id.to_owned()))
459: 457:     }
460: 458:     Ok(context_lyx-core-lyx_core_lyx-core-lyx_core_ids)
461: 459: }
462: 460: 
463: 461: #[authorized]
464: 462: #[delete("/{key}")]
465: 463: async fn delete_handler(
466: 464:     workspace_context: WorkspaceContext,
467: 465:     state: Data<AppState>,
468: 466:     path: Path<DefaultConfigKey>,
469: 467:     custom_headers: CustomHeaders,
470: 468:     db_conn: DbConnection,
471: 469:     user: User,
472: 470: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
473: 471:     let DbConnection(mut conn) = db_conn;
474: 472:     let tags = parse_config_tags(custom_headers.config_tags)?;
475: 473: 
476: 474:     let key: String = path.into_inner().into();
477: 475:     let mut version_id = 0;
478: 476: 
479: 477:     let context_lyx-core-lyx_core_lyx-core-lyx_core_ids =
480: 478:         get_key_usage_context_lyx-core-lyx_core_lyx-core-lyx_core_ids(&key, &mut conn, &workspace_context.schema_name)
481: 479:             .map_err(|_| unexpected_error!("Something went wrong"))?;
482: 480:     if context_lyx-core-lyx_core_lyx-core-lyx_core_ids.is_empty() {
483: 481:         let resp: Result<HttpResponse, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> =
484: 482:             conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
485: 483:                 diesel::update(dsl::default_configs)
486: 484:                     .filter(dsl::key.eq(&key))
487: 485:                     .set((
488: 486:                         dsl::last_modified_at.eq(Utc::now()),
489: 487:                         dsl::last_modified_by.eq(user.get_email()),
490: 488:                     ))
491: 489:                     .schema_name(&workspace_context.schema_name)
492: 490:                     .execute(transaction_conn)?;
493: 491: 
494: 492:                 let deleted_row =
495: 493:                     diesel::delete(dsl::default_configs.filter(dsl::key.eq(&key)))
496: 494:                         .schema_name(&workspace_context.schema_name)
497: 495:                         .execute(transaction_conn);
498: 496:                 match deleted_row {
499: 497:                     Ok(0) => {
500: 498:                         Err(not_found!("default config key `{}` doesn't exists", key))
501: 499:                     }
502: 500:                     Ok(_) => {
503: 501:                         let config_version_desc = Description::try_from(format!(
504: 502:                             "Context Deleted by {}",
505: 503:                             user.get_email()
506: 504:                         ))
507: 505:                         .map_err(|e| unexpected_error!(e))?;
508: 506:                         version_id = add_config_version(
509: 507:                             &state,
510: 508:                             tags,
511: 509:                             config_version_desc,
512: 510:                             transaction_conn,
513: 511:                             &workspace_context.schema_name,
514: 512:                         )?;
515: 513:                         log::info!(
516: 514:                             "default config key: {key} deleted by {}",
517: 515:                             user.get_email()
518: 516:                         );
519: 517:                         Ok(HttpResponse::NoContent()
520: 518:                             .insert_header((
521: 519:                                 AppHeader::XConfigVersion.to_string(),
522: 520:                                 version_id.to_string(),
523: 521:                             ))
524: 522:                             .finish())
525: 523:                     }
526: 524:                     Err(e) => {
527: 525:                         log::error!("default config delete query failed with error: {e}");
528: 526:                         Err(unexpected_error!("Something went wrong."))
529: 527:                     }
530: 528:                 }
531: 529:             });
532: 530: 
533: 531:         if resp.is_ok() {
534: 532:             #[cfg(feature = "high-performance-mode")]
535: 533:             put_config_in_redis(
536: 534:                 version_id,
537: 535:                 state,
538: 536:                 &workspace_context.schema_name,
539: 537:                 &mut conn,
540: 538:             )
541: 539:             .await?;
542: 540:         }
543: 541:         resp
544: 542:     } else {
545: 543:         Err(bad_argument!(
546: 544:             "Given key already in use in contexts: {}",
547: 545:             context_lyx-core-lyx_core_lyx-core-lyx_core_ids.join(",")
548: 546:         ))
549: 547:     }
550: 548: }
551: 549: ```
552: 550: ```
553: 551: ```
554: 552: ```
555: ```
```
