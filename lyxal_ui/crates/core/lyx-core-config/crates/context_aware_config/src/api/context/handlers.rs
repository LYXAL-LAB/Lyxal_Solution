### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\context\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\handlers.rs
10: 8: ```rust
11: 9: use std::{cmp::min, collections::HashSet};
12: 10: 
13: 11: use actix_web::{
14: 12:     Either, HttpResponse, Scope, delete, get, post, put, routes,
15: 13:     web::{Data, Json, Path},
16: 14: };
17: 15: use bigdecimal::BigDecimal;
18: 16: use chrono::Utc;
19: 17: use diesel::{
20: 18:     Connection, ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper, delete,
21: 19:     dsl::sql,
22: 20:     sql_types::{Bool, Text},
23: 21: };
24: 22: use serde_json::{Map, Value};
25: 23: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
26: 24:     helpers::{fetch_dimensions_info_map, parse_config_tags},
27: 25:     service::types::{
28: 26:         AppHeader, AppState, CustomHeaders, DbConnection, WorkspaceContext,
29: 27:     },
30: 28: };
31: 29: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
32: 30: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, db_error, unexpected_error};
33: 31: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
34: 32:     Contextual, ListResponse, Overridden, Overrides, PaginatedResponse, SortBy, User,
35: 33:     api::{
36: 34:         DimensionMatchStrategy,
37: 35:         context::{
38: 36:             BulkOperation, BulkOperationResponse, ContextAction, ContextBulkResponse,
39: 37:             ContextListFilters, ContextValidationRequest, MoveRequest, PutRequest,
40: 38:             SortOn, UpdateRequest, WeightRecomputeResponse,
41: 39:         },
42: 40:     },
43: 41:     custom_query::{
44: 42:         self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, CustomQuery, DimensionQuery, PaginationParams,
45: 43:         QueryMap,
46: 44:     },
47: 45:     database::{
48: 46:         models::{ChangeReason, Description, cac::Context},
49: 47:         schema::contexts::{self, id},
50: 48:     },
51: 49:     logic::evaluate_local_cohorts_skip_unresolved,
52: 50:     result::{self as lyx-core-lyx_core_lyx-core-lyx_core_superposition, AppError},
53: 51: };
54: 52: 
55: 53: #[cfg(feature = "high-performance-mode")]
56: 54: use crate::helpers::put_config_in_redis;
57: 55: use crate::helpers::{add_config_version, calculate_context_weight};
58: 56: use crate::{
59: 57:     api::context::{
60: 58:         hash,
61: 59:         helpers::{query_description, validate_ctx},
62: 60:         operations,
63: 61:     },
64: 62:     helpers::validate_change_reason,
65: 63: };
66: 64: 
67: 65: pub fn endpoints() -> Scope {
68: 66:     Scope::new("")
69: 67:         .service(create_handler)
70: 68:         .service(update_handler)
71: 69:         .service(move_handler)
72: 70:         .service(delete_handler)
73: 71:         .service(bulk_operations_handler)
74: 72:         .service(list_handler)
75: 73:         .service(get_from_condition_handler)
76: 74:         .service(get_handler)
77: 75:         .service(weight_recompute_handler)
78: 76:         .service(validate_handler)
79: 77: }
80: 78: 
81: 79: #[authorized]
82: 80: #[put("")]
83: 81: async fn create_handler(
84: 82:     workspace_context: WorkspaceContext,
85: 83:     state: Data<AppState>,
86: 84:     custom_headers: CustomHeaders,
87: 85:     req: Json<PutRequest>,
88: 86:     mut db_conn: DbConnection,
89: 87:     user: User,
90: 88: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
91: 89:     let tags = parse_config_tags(custom_headers.config_tags)?;
92: 90:     let description = match req.description.clone() {
93: 91:         Some(val) => val,
94: 92:         None => {
95: 93:             // TODO: get rid of `query_description` function altogether
96: 94:             let resp = query_description(
97: 95:                 Value::Object(req.context.clone().into_inner().into()),
98: 96:                 &mut db_conn,
99: 97:                 &workspace_context.schema_name,
100: 98:             );
101: 99:             match resp {
102: 100:                 Err(AppError::DbError(diesel::result::Error::NotFound)) => {
103: 101:                     return Err(bad_argument!(
104: 102:                         "Description is required when context does not exist"
105: 103:                     ));
106: 104:                 }
107: 105:                 Ok(desc) => desc,
108: 106:                 Err(e) => return Err(e),
109: 107:             }
110: 108:         }
111: 109:     };
112: 110:     let req_change_reason = req.change_reason.clone();
113: 111: 
114: 112:     validate_change_reason(
115: 113:         &workspace_context,
116: 114:         &req_change_reason,
117: 115:         &mut db_conn,
118: 116:         &state.master_encryption_key,
119: 117:     )?;
120: 118: 
121: 119:     let (put_response, version_id) = db_conn
122: 120:         .transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
123: 121:             let put_response = operations::upsert(
124: 122:                 req.into_inner(),
125: 123:                 description,
126: 124:                 transaction_conn,
127: 125:                 true,
128: 126:                 &user,
129: 127:                 &workspace_context,
130: 128:                 false,
131: 129:                 &state.master_encryption_key,
132: 130:             )
133: 131:             .map_err(|err: lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError| {
134: 132:                 log::error!("context put failed with error: {:?}", err);
135: 133:                 err
136: 134:             })?;
137: 135: 
138: 136:             let version_id = add_config_version(
139: 137:                 &state,
140: 138:                 tags,
141: 139:                 req_change_reason.into(),
142: 140:                 transaction_conn,
143: 141:                 &workspace_context.schema_name,
144: 142:             )?;
145: 143:             Ok((put_response, version_id))
146: 144:         })?;
147: 145: 
148: 146:     let mut http_resp = HttpResponse::Ok();
149: 147: 
150: 148:     http_resp.insert_header((
151: 149:         AppHeader::XConfigVersion.to_string(),
152: 150:         version_id.to_string(),
153: 151:     ));
154: 152: 
155: 153:     #[cfg(feature = "high-performance-mode")]
156: 154:     {
157: 155:         let DbConnection(mut conn) = db_conn;
158: 156:         put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
159: 157:             .await?;
160: 158:     }
161: 159: 
162: 160:     Ok(http_resp.json(put_response))
163: 161: }
164: 162: 
165: 163: #[authorized]
166: 164: #[routes]
167: 165: #[put("/overrides")]
168: 166: #[patch("/overrides")]
169: 167: async fn update_handler(
170: 168:     workspace_context: WorkspaceContext,
171: 169:     state: Data<AppState>,
172: 170:     custom_headers: CustomHeaders,
173: 171:     req: Json<UpdateRequest>,
174: 172:     mut db_conn: DbConnection,
175: 173:     user: User,
176: 174: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
177: 175:     let tags = parse_config_tags(custom_headers.config_tags)?;
178: 176:     let req_change_reason = req.change_reason.clone();
179: 177: 
180: 178:     validate_change_reason(
181: 179:         &workspace_context,
182: 180:         &req_change_reason,
183: 181:         &mut db_conn,
184: 182:         &state.master_encryption_key,
185: 183:     )?;
186: 184: 
187: 185:     let (override_resp, version_id) = db_conn
188: 186:         .transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
189: 187:             let override_resp = operations::update(
190: 188:                 &workspace_context,
191: 189:                 req.into_inner(),
192: 190:                 transaction_conn,
193: 191:                 &user,
194: 192:                 &state.master_encryption_key,
195: 193:             )
196: 194:             .map_err(|err: lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError| {
197: 195:                 log::error!("context update failed with error: {:?}", err);
198: 196:                 err
199: 197:             })?;
200: 198: 
201: 199:             let version_id = add_config_version(
202: 200:                 &state,
203: 201:                 tags,
204: 202:                 req_change_reason.into(),
205: 203:                 transaction_conn,
206: 204:                 &workspace_context.schema_name,
207: 205:             )?;
208: 206:             Ok((override_resp, version_id))
209: 207:         })?;
210: 208:     let mut http_resp = HttpResponse::Ok();
211: 209: 
212: 210:     http_resp.insert_header((
213: 211:         AppHeader::XConfigVersion.to_string(),
214: 212:         version_id.to_string(),
215: 213:     ));
216: 214: 
217: 215:     #[cfg(feature = "high-performance-mode")]
218: 216:     {
219: 217:         let DbConnection(mut conn) = db_conn;
220: 218:         put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
221: 219:             .await?;
222: 220:     }
223: 221: 
224: 222:     Ok(http_resp.json(override_resp))
225: 223: }
226: 224: 
227: 225: #[allow(clippy::too_many_arguments)]
228: 226: #[authorized]
229: 227: #[put("/move/{ctx_id}")]
230: 228: async fn move_handler(
231: 229:     workspace_context: WorkspaceContext,
232: 230:     state: Data<AppState>,
233: 231:     path: Path<String>,
234: 232:     custom_headers: CustomHeaders,
235: 233:     req: Json<MoveRequest>,
236: 234:     mut db_conn: DbConnection,
237: 235:     user: User,
238: 236: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
239: 237:     let tags = parse_config_tags(custom_headers.config_tags)?;
240: 238: 
241: 239:     let description = match req.description.clone() {
242: 240:         Some(val) => val,
243: 241:         None => {
244: 242:             // TODO: get rid of `query_description` function altogether
245: 243:             let resp = query_description(
246: 244:                 Value::Object(req.context.clone().into_inner().into()),
247: 245:                 &mut db_conn,
248: 246:                 &workspace_context.schema_name,
249: 247:             );
250: 248:             match resp {
251: 249:                 Err(AppError::DbError(diesel::result::Error::NotFound)) => {
252: 250:                     return Err(bad_argument!(
253: 251:                         "Description is required when context does not exist"
254: 252:                     ));
255: 253:                 }
256: 254:                 Ok(desc) => desc,
257: 255:                 Err(e) => return Err(e),
258: 256:             }
259: 257:         }
260: 258:     };
261: 259: 
262: 260:     validate_change_reason(
263: 261:         &workspace_context,
264: 262:         &req.change_reason,
265: 263:         &mut db_conn,
266: 264:         &state.master_encryption_key,
267: 265:     )?;
268: 266: 
269: 267:     let (move_response, version_id) = db_conn
270: 268:         .transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
271: 269:             let move_response = operations::r#move(
272: 270:                 &workspace_context,
273: 271:                 path.into_inner(),
274: 272:                 req,
275: 273:                 description,
276: 274:                 transaction_conn,
277: 275:                 true,
278: 276:                 &user,
279: 277:                 &state.master_encryption_key,
280: 278:             )
281: 279:             .map_err(|err| {
282: 280:                 log::error!("move api failed with error: {:?}", err);
283: 281:                 err
284: 282:             })?;
285: 283:             let version_id = add_config_version(
286: 284:                 &state,
287: 285:                 tags,
288: 286:                 move_response.change_reason.clone().into(),
289: 287:                 transaction_conn,
290: 288:                 &workspace_context.schema_name,
291: 289:             )?;
292: 290: 
293: 291:             Ok((move_response, version_id))
294: 292:         })?;
295: 293:     let mut http_resp = HttpResponse::Ok();
296: 294: 
297: 295:     http_resp.insert_header((
298: 296:         AppHeader::XConfigVersion.to_string(),
299: 297:         version_id.to_string(),
300: 298:     ));
301: 299: 
302: 300:     #[cfg(feature = "high-performance-mode")]
303: 301:     {
304: 302:         let DbConnection(mut conn) = db_conn;
305: 303:         put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
306: 304:             .await?;
307: 305:     }
308: 306: 
309: 307:     Ok(http_resp.json(move_response))
310: 308: }
311: 309: 
312: 310: #[authorized]
313: 311: #[post("/get")]
314: 312: async fn get_from_condition_handler(
315: 313:     workspace_context: WorkspaceContext,
316: 314:     db_conn: DbConnection,
317: 315:     req: Json<Map<String, Value>>,
318: 316: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Context>> {
319: 317:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::contexts::dsl::*;
320: 318: 
321: 319:     let context_id = hash(&Value::Object(req.into_inner()));
322: 320:     let DbConnection(mut conn) = db_conn;
323: 321: 
324: 322:     let ctx: Context = contexts
325: 323:         .filter(id.eq(context_id))
326: 324:         .schema_name(&workspace_context.schema_name)
327: 325:         .get_result::<Context>(&mut conn)?;
328: 326: 
329: 327:     Ok(Json(ctx))
330: 328: }
331: 329: 
332: 330: #[authorized]
333: 331: #[get("/{ctx_id}")]
334: 332: async fn get_handler(
335: 333:     workspace_context: WorkspaceContext,
336: 334:     path: Path<String>,
337: 335:     db_conn: DbConnection,
338: 336: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Context>> {
339: 337:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::contexts::dsl::*;
340: 338: 
341: 339:     let ctx_id = path.into_inner();
342: 340:     let DbConnection(mut conn) = db_conn;
343: 341: 
344: 342:     let ctx: Context = contexts
345: 343:         .filter(id.eq(ctx_id))
346: 344:         .schema_name(&workspace_context.schema_name)
347: 345:         .get_result::<Context>(&mut conn)?;
348: 346: 
349: 347:     Ok(Json(ctx))
350: 348: }
351: 349: 
352: 350: #[authorized]
353: 351: #[routes]
354: 352: #[get("/list")]
355: 353: #[get("")]
356: 354: async fn list_handler(
357: 355:     workspace_context: WorkspaceContext,
358: 356:     filter_params: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ContextListFilters>,
359: 357:     pagination_params: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<PaginationParams>,
360: 358:     dimension_params: DimensionQuery<QueryMap>,
361: 359:     db_conn: DbConnection,
362: 360: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<Context>>> {
363: 361:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::contexts::dsl::*;
364: 362:     let DbConnection(mut conn) = db_conn;
365: 363: 
366: 364:     let filter_params = filter_params.into_inner();
367: 365:     let pagination_params = pagination_params.into_inner();
368: 366: 
369: 367:     let page = pagination_params.page.unwrap_or(1);
370: 368:     let count = pagination_params.count.unwrap_or(10);
371: 369:     let show_all = pagination_params.all.unwrap_or_default();
372: 370:     let offset = count * (page - 1);
373: 371: 
374: 372:     let dimension_params = dimension_params.into_inner();
375: 373: 
376: 374:     let get_base_query = || {
377: 375:         let mut builder = contexts
378: 376:             .schema_name(&workspace_context.schema_name)
379: 377:             .into_boxed();
380: 378:         if let Some(creators) = filter_params.created_by.clone() {
381: 379:             builder = builder.filter(created_by.eq_any(creators.0))
382: 380:         }
383: 381: 
384: 382:         if let Some(last_modifiers) = filter_params.last_modified_by.clone() {
385: 383:             builder = builder.filter(last_modified_by.eq_any(last_modifiers.0))
386: 384:         }
387: 385: 
388: 386:         if let Some(plaintext) = filter_params.plaintext.clone() {
389: 387:             builder = builder.filter(
390: 388:                 sql::<Bool>("override::text ILIKE ")
391: 389:                     .bind::<Text, _>(format!("%{plaintext}%")),
392: 390:             )
393: 391:         }
394: 392: 
395: 393:         builder
396: 394:     };
397: 395: 
398: 396:     let base_query = get_base_query();
399: 397: 
400: 398:     let base_query = match (
401: 399:         filter_params.sort_on.unwrap_or_default(),
402: 400:         filter_params.sort_by.unwrap_or_default(),
403: 401:     ) {
404: 402:         (SortOn::Weight, SortBy::Asc) => {
405: 403:             base_query.order((weight.asc(), created_at.asc()))
406: 404:         }
407: 405:         (SortOn::Weight, SortBy::Desc) => {
408: 406:             base_query.order((weight.desc(), created_at.desc()))
409: 407:         }
410: 408:         (SortOn::CreatedAt, SortBy::Asc) => {
411: 409:             base_query.order((created_at.asc(), weight.asc()))
412: 410:         }
413: 411:         (SortOn::CreatedAt, SortBy::Desc) => {
414: 412:             base_query.order((created_at.desc(), weight.desc()))
415: 413:         }
416: 414:         (SortOn::LastModifiedAt, SortBy::Asc) => {
417: 415:             base_query.order((last_modified_at.asc(), weight.asc()))
418: 416:         }
419: 417:         (SortOn::LastModifiedAt, SortBy::Desc) => {
420: 418:             base_query.order((last_modified_at.desc(), weight.desc()))
421: 419:         }
422: 420:     };
423: 421: 
424: 422:     let perform_in_memory_filter =
425: 423:         !dimension_params.is_empty() || filter_params.prefix.is_some();
426: 424: 
427: 425:     let paginated_response = if perform_in_memory_filter {
428: 426:         let mut all_contexts: Vec<Context> = base_query.load(&mut conn)?;
429: 427:         if let Some(prefix) = filter_params.prefix {
430: 428:             let prefix_list = HashSet::from_iter(prefix.0);
431: 429:             all_contexts = all_contexts
432: 430:                 .into_iter()
433: 431:                 .filter_map(|mut context| {
434: 432:                     Context::filter_keys_by_prefix(&context, &prefix_list)
435: 433:                         .map(|filtered_overrides_map| {
436: 434:                             context.override_ = filtered_overrides_map.into_inner();
437: 435:                             context
438: 436:                         })
439: 437:                         .ok()
440: 438:                 })
441: 439:                 .collect()
442: 440:         }
443: 441:         let dimensions_info =
444: 442:             fetch_dimensions_info_map(&mut conn, &workspace_context.schema_name)?;
445: 443:         let dimension_params =
446: 444:             evaluate_local_cohorts_skip_unresolved(&dimensions_info, &dimension_params);
447: 445:         let dimension_keys = dimension_params.keys().cloned().collect::<Vec<_>>();
448: 446: 
449: 447:         let filter_fn = match filter_params.dimension_match_strategy.unwrap_or_default() {
450: 448:             DimensionMatchStrategy::Exact => Context::filter_exact_match,
451: 449:             DimensionMatchStrategy::Subset => Context::filter_by_eval,
452: 450:         };
453: 451: 
454: 452:         let eval_filter_contexts = filter_fn(all_contexts, &dimension_params);
455: 453: 
456: 454:         let eval_filter_contexts =
457: 455:             Context::filter_by_dimension(eval_filter_contexts, &dimension_keys);
458: 456: 
459: 457:         if show_all {
460: 458:             PaginatedResponse::all(eval_filter_contexts)
461: 459:         } else {
462: 460:             let total_items = eval_filter_contexts.len();
463: 461:             let start = offset as usize;
464: 462:             let end = min((offset + count) as usize, total_items);
465: 463:             let data = eval_filter_contexts
466: 464:                 .get(start..end)
467: 465:                 .map(|slice| slice.to_vec())
468: 466:                 .unwrap_or_default();
469: 467: 
470: 468:             PaginatedResponse {
471: 469:                 total_pages: (total_items as f64 / count as f64).ceil() as i64,
472: 470:                 total_items: total_items as i64,
473: 471:                 data,
474: 472:             }
475: 473:         }
476: 474:     } else if show_all {
477: 475:         let data = base_query.load::<Context>(&mut conn)?;
478: 476:         PaginatedResponse::all(data)
479: 477:     } else {
480: 478:         let total_items = get_base_query().count().get_result(&mut conn)?;
481: 479: 
482: 480:         let data = base_query
483: 481:             .limit(count)
484: 482:             .offset(offset)
485: 483:             .load::<Context>(&mut conn)?;
486: 484: 
487: 485:         PaginatedResponse {
488: 486:             total_pages: (total_items as f64 / count as f64).ceil() as i64,
489: 487:             total_items,
490: 488:             data,
491: 489:         }
492: 490:     };
493: 491: 
494: 492:     Ok(Json(paginated_response))
495: 493: }
496: 494: 
497: 495: #[authorized]
498: 496: #[delete("/{ctx_id}")]
499: 497: async fn delete_handler(
500: 498:     workspace_context: WorkspaceContext,
501: 499:     state: Data<AppState>,
502: 500:     path: Path<String>,
503: 501:     custom_headers: CustomHeaders,
504: 502:     user: User,
505: 503:     mut db_conn: DbConnection,
506: 504: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
507: 505:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::contexts::dsl::{
508: 506:         contexts as contexts_table, id as context_id,
509: 507:     };
510: 508:     let ctx_id = path.into_inner();
511: 509:     let tags = parse_config_tags(custom_headers.config_tags)?;
512: 510:     let version_id =
513: 511:         db_conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
514: 512:             contexts_table
515: 513:                 .filter(context_id.eq(ctx_id.clone()))
516: 514:                 .schema_name(&workspace_context.schema_name)
517: 515:                 .first::<Context>(transaction_conn)?;
518: 516:             operations::delete(
519: 517:                 ctx_id.clone(),
520: 518:                 &user,
521: 519:                 transaction_conn,
522: 520:                 &workspace_context.schema_name,
523: 521:             )?;
524: 522:             let config_version_desc =
525: 523:                 Description::try_from(format!("Deleted context by {}", user.username))
526: 524:                     .map_err(|e| unexpected_error!(e))?;
527: 525:             let version_id = add_config_version(
528: 526:                 &state,
529: 527:                 tags,
530: 528:                 config_version_desc,
531: 529:                 transaction_conn,
532: 530:                 &workspace_context.schema_name,
533: 531:             )?;
534: 532:             Ok(version_id)
535: 533:         })?;
536: 534: 
537: 535:     #[cfg(feature = "high-performance-mode")]
538: 536:     {
539: 537:         let DbConnection(mut conn) = db_conn;
540: 538:         put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
541: 539:             .await?;
542: 540:     }
543: 541: 
544: 542:     Ok(HttpResponse::NoContent()
545: 543:         .insert_header((
546: 544:             AppHeader::XConfigVersion.to_string().as_str(),
547: 545:             version_id.to_string().as_str(),
548: 546:         ))
549: 547:         .finish())
550: 548: }
551: 549: 
552: 550: #[authorized]
553: 551: #[put("/bulk-operations")]
554: 552: async fn bulk_operations_handler(
555: 553:     workspace_context: WorkspaceContext,
556: 554:     state: Data<AppState>,
557: 555:     custom_headers: CustomHeaders,
558: 556:     req: Either<Json<Vec<ContextAction>>, Json<BulkOperation>>,
559: 557:     db_conn: DbConnection,
560: 558:     user: User,
561: 559: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
562: 560:     use contexts::dsl::contexts;
563: 561: 
564: 562:     let DbConnection(mut conn) = db_conn;
565: 563:     let mut is_v2 = false;
566: 564:     let ops = match req {
567: 565:         Either::Left(o) => o.into_inner(),
568: 566:         Either::Right(bo) => {
569: 567:             is_v2 = true;
570: 568:             bo.into_inner().operations
571: 569:         }
572: 570:     };
573: 571:     // Marking immutable.
574: 572:     let is_v2 = is_v2;
575: 573:     let mut all_descriptions = Vec::new();
576: 574:     let mut all_change_reasons = Vec::new();
577: 575: 
578: 576:     let tags = parse_config_tags(custom_headers.config_tags)?;
579: 577:     let (response, version_id) =
580: 578:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
581: 579:             let mut response = Vec::<ContextBulkResponse>::new();
582: 580:             for action in ops.into_iter() {
583: 581:                 match action {
584: 582:                     ContextAction::Put(put_req) => {
585: 583:                         let ctx_condition = put_req.context.to_owned().into_inner();
586: 584:                         let ctx_condition_value =
587: 585:                             Value::Object(ctx_condition.clone().into());
588: 586: 
589: 587:                         validate_change_reason(
590: 588:                             &workspace_context,
591: 589:                             &put_req.change_reason,
592: 590:                             transaction_conn,
593: 591:                             &state.master_encryption_key,
594: 592:                         )?;
595: 593: 
596: 594:                         let description = if put_req.description.is_none() {
597: 595:                             query_description(
598: 596:                                 ctx_condition_value,
599: 597:                                 transaction_conn,
600: 598:                                 &workspace_context.schema_name,
601: 599:                             )?
602: 600:                         } else {
603: 601:                             put_req
604: 602:                                 .description
605: 603:                                 .clone()
606: 604:                                 .expect("Description should not be empty")
607: 605:                         };
608: 606: 
609: 607:                         let put_resp = operations::upsert(
610: 608:                             put_req.clone(),
611: 609:                             description.clone(),
612: 610:                             transaction_conn,
613: 611:                             true,
614: 612:                             &user,
615: 613:                             &workspace_context,
616: 614:                             false,
617: 615:                             &state.master_encryption_key,
618: 616:                         )
619: 617:                         .map_err(|err| {
620: 618:                             log::error!(
621: 619:                                 "Failed at insert into contexts due to {:?}",
622: 620:                                 err
623: 621:                             );
624: 622:                             err
625: 623:                         })?;
626: 624: 
627: 625:                         all_descriptions.push(description);
628: 626:                         all_change_reasons.push(put_req.change_reason.clone());
629: 627:                         response.push(ContextBulkResponse::Put(put_resp));
630: 628:                     }
631: 629:                     ContextAction::Replace(update_request) => {
632: 630:                         all_change_reasons.push(update_request.change_reason.clone());
633: 631:                         let update_resp = operations::update(
634: 632:                             &workspace_context,
635: 633:                             update_request,
636: 634:                             transaction_conn,
637: 635:                             &user,
638: 636:                             &state.master_encryption_key,
639: 637:                         )
640: 638:                         .map_err(|err| {
641: 639:                             log::error!(
642: 640:                                 "Failed at update into contexts due to {:?}",
643: 641:                                 err
644: 642:                             );
645: 643:                             err
646: 644:                         })?;
647: 645: 
648: 646:                         response.push(ContextBulkResponse::Replace(update_resp));
649: 647:                     }
650: 648:                     ContextAction::Delete(ctx_id) => {
651: 649:                         let context: Context = contexts
652: 650:                             .filter(id.eq(&ctx_id))
653: 651:                             .schema_name(&workspace_context.schema_name)
654: 652:                             .first::<Context>(transaction_conn)?;
655: 653: 
656: 654:                         let deleted_row = delete(contexts)
657: 655:                             .filter(id.eq(&ctx_id))
658: 656:                             .schema_name(&workspace_context.schema_name)
659: 657:                             .execute(transaction_conn);
660: 658: 
661: 659:                         let description = context.description;
662: 660: 
663: 661:                         let email: String = user.clone().get_email();
664: 662:                         let change_reason = ChangeReason::try_from(format!(
665: 663:                             "Context deleted by {}",
666: 664:                             email.clone()
667: 665:                         ))
668: 666:                         .map_err(|e| unexpected_error!(e))?;
669: 667:                         all_descriptions.push(description.clone());
670: 668:                         all_change_reasons.push(change_reason);
671: 669: 
672: 670:                         match deleted_row {
673: 671:                             // Any kind of error would rollback the tranction but explicitly returning rollback tranction allows you to rollback from any point in transaction.
674: 672:                             Ok(0) => {
675: 673:                                 return Err(bad_argument!(
676: 674:                                     "context with id {} not found",
677: 675:                                     ctx_id
678: 676:                                 ));
679: 677:                             }
680: 678:                             Ok(_) => {
681: 679:                                 log::info!("{ctx_id} context deleted by {email}");
682: 680:                                 response.push(ContextBulkResponse::Delete(format!(
683: 681:                                     "{ctx_id} deleted succesfully"
684: 682:                                 )))
685: 683:                             }
686: 684:                             Err(e) => {
687: 685:                                 log::error!("Delete context failed due to {:?}", e);
688: 686:                                 return Err(db_error!(e));
689: 687:                             }
690: 688:                         };
691: 689:                     }
692: 690:                     ContextAction::Move {
693: 691:                         id: old_ctx_id,
694: 692:                         request: move_req,
695: 693:                     } => {
696: 694:                         let description = match move_req.description.clone() {
697: 695:                             Some(val) => val,
698: 696:                             None => query_description(
699: 697:                                 Value::Object(
700: 698:                                     move_req.context.clone().into_inner().into(),
701: 699:                                 ),
702: 700:                                 transaction_conn,
703: 701:                                 &workspace_context.schema_name,
704: 702:                             )?,
705: 703:                         };
706: 704: 
707: 705:                         let move_context_resp = operations::r#move(
708: 706:                             &workspace_context,
709: 707:                             old_ctx_id,
710: 708:                             Json(move_req),
711: 709:                             description,
712: 710:                             transaction_conn,
713: 711:                             true,
714: 712:                             &user,
715: 713:                             &state.master_encryption_key,
716: 714:                         )
717: 715:                         .map_err(|err| {
718: 716:                             log::error!(
719: 717:                                 "Failed at moving context reponse due to {:?}",
720: 718:                                 err
721: 719:                             );
722: 720:                             err
723: 721:                         })?;
724: 722:                         all_descriptions.push(move_context_resp.description.clone());
725: 723:                         all_change_reasons.push(move_context_resp.change_reason.clone());
726: 724:                         response.push(ContextBulkResponse::Move(move_context_resp));
727: 725:                     }
728: 726:                 }
729: 727:             }
730: 728: 
731: 729:             let version_id = add_config_version(
732: 730:                 &state,
733: 731:                 tags,
734: 732:                 Description::try_from_change_reasons(all_change_reasons)
735: 733:                     .unwrap_or_default(),
736: 734:                 transaction_conn,
737: 735:                 &workspace_context.schema_name,
738: 736:             )?;
739: 737:             Ok((response, version_id))
740: 738:         })?;
741: 739:     let mut resp_builder = HttpResponse::Ok();
742: 740:     resp_builder.insert_header((
743: 741:         AppHeader::XConfigVersion.to_string(),
744: 742:         version_id.to_string(),
745: 743:     ));
746: 744: 
747: 745:     // Commit the transaction
748: 746:     #[cfg(feature = "high-performance-mode")]
749: 747:     put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
750: 748:         .await?;
751: 749: 
752: 750:     let http_resp = if is_v2 {
753: 751:         resp_builder.json(BulkOperationResponse { output: response })
754: 752:     } else {
755: 753:         resp_builder.json(response)
756: 754:     };
757: 755:     Ok(http_resp)
758: 756: }
759: 757: 
760: 758: #[authorized]
761: 759: #[put("/weight/recompute")]
762: 760: async fn weight_recompute_handler(
763: 761:     workspace_context: WorkspaceContext,
764: 762:     state: Data<AppState>,
765: 763:     custom_headers: CustomHeaders,
766: 764:     db_conn: DbConnection,
767: 765:     user: User,
768: 766: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
769: 767:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::contexts::dsl::{
770: 768:         contexts, last_modified_at, last_modified_by, weight,
771: 769:     };
772: 770: 
773: 771:     let DbConnection(mut conn) = db_conn;
774: 772: 
775: 773:     let result: Vec<Context> = contexts
776: 774:         .schema_name(&workspace_context.schema_name)
777: 775:         .load(&mut conn)
778: 776:         .map_err(|err| {
779: 777:             log::error!("failed to fetch contexts with error: {}", err);
780: 778:             unexpected_error!("Something went wrong")
781: 779:         })?;
782: 780: 
783: 781:     let dimension_info_map =
784: 782:         fetch_dimensions_info_map(&mut conn, &workspace_context.schema_name)?;
785: 783:     let mut response: Vec<WeightRecomputeResponse> = vec![];
786: 784:     let tags = parse_config_tags(custom_headers.config_tags)?;
787: 785: 
788: 786:     let contexts_new_weight = result
789: 787:         .clone()
790: 788:         .into_iter()
791: 789:         .map(|context| {
792: 790:             let new_weight = calculate_context_weight(
793: 791:                 &Value::Object(context.value.clone().into()),
794: 792:                 &dimension_info_map,
795: 793:             );
796: 794: 
797: 795:             match new_weight {
798: 796:                 Ok(val) => {
799: 797:                     response.push(WeightRecomputeResponse {
800: 798:                         id: context.id.clone(),
801: 799:                         condition: context.value.clone(),
802: 800:                         old_weight: context.weight.clone(),
803: 801:                         new_weight: val.clone(),
804: 802:                     });
805: 803:                     Ok((val, context.id.clone()))
806: 804:                 }
807: 805:                 Err(e) => {
808: 806:                     log::error!("failed to calculate context weight: {}", e);
809: 807:                     Err(unexpected_error!("Something went wrong"))
810: 808:                 }
811: 809:             }
812: 810:         })
813: 811:         .collect::<lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<(BigDecimal, String)>>>()?;
814: 812: 
815: 813:     // Update database and add config version
816: 814:     let last_modified_time = Utc::now();
817: 815:     let config_version_id =
818: 816:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
819: 817:             for (context_weight, context_id) in contexts_new_weight.clone() {
820: 818:                 diesel::update(contexts.filter(id.eq(context_id)))
821: 819:                     .set((
822: 820:                         weight.eq(context_weight),
823: 821:                         last_modified_at.eq(last_modified_time),
824: 822:                         last_modified_by.eq(user.get_email())
825: 823:                     ))
826: 824:                     .schema_name(&workspace_context.schema_name)
827: 825:                     .returning(Context::as_returning())
828: 826:                     .execute(transaction_conn).map_err(|err| {
829: 827:                         log::error!(
830: 828:                             "Failed to execute query while recomputing weight, error: {err}"
831: 829:                         );
832: 830:                         db_error!(err)
833: 831:                     })?;
834: 832:             }
835: 833:             let config_version_desc = Description::try_from("Recomputed weight".to_string()).map_err(|e| unexpected_error!(e))?;
836: 834:             let version_id = add_config_version(&state, tags, config_version_desc, transaction_conn, &workspace_context.schema_name)?;
837: 835:             Ok(version_id)
838: 836:         })?;
839: 837:     #[cfg(feature = "high-performance-mode")]
840: 838:     put_config_in_redis(
841: 839:         config_version_id,
842: 840:         state,
843: 841:         &workspace_context.schema_name,
844: 842:         &mut conn,
845: 843:     )
846: 844:     .await?;
847: 845: 
848: 846:     let mut http_resp = HttpResponse::Ok();
849: 847:     http_resp.insert_header((
850: 848:         AppHeader::XConfigVersion.to_string(),
851: 849:         config_version_id.to_string(),
852: 850:     ));
853: 851:     Ok(http_resp.json(ListResponse::new(response)))
854: 852: }
855: 853: 
856: 854: #[authorized]
857: 855: #[post("/validate")]
858: 856: async fn validate_handler(
859: 857:     workspace_context: WorkspaceContext,
860: 858:     db_conn: DbConnection,
861: 859:     request: Json<ContextValidationRequest>,
862: 860:     state: Data<AppState>,
863: 861: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
864: 862:     let DbConnection(mut conn) = db_conn;
865: 863:     let ctx_condition = request.context.to_owned().into_inner();
866: 864:     log::debug!("Context {:?} is being checked for validity", ctx_condition);
867: 865: 
868: 866:     validate_ctx(
869: 867:         &mut conn,
870: 868:         &workspace_context,
871: 869:         ctx_condition.clone(),
872: 870:         Overrides::default(),
873: 871:         &state.master_encryption_key,
874: 872:     )?;
875: 873:     log::debug!("Context {:?} is valid", ctx_condition);
876: 874:     Ok(HttpResponse::Ok().finish())
877: 875: }
878: 876: ```
879: 877: ```
880: 878: ```
881: 879: ```
882: ```
```
