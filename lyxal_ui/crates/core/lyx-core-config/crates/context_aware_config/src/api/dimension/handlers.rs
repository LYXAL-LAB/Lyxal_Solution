1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     HttpResponse, Scope, delete, get, post, routes,
13: 11:     web::{self, Data, Json, Path, Query},
14: 12: };
15: 13: use chrono::Utc;
16: 14: use diesel::{Connection, ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
17: 15: use serde_json::Value;
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
19: 17:     helpers::parse_config_tags,
20: 18:     service::types::{
21: 19:         AppHeader, AppState, CustomHeaders, DbConnection, WorkspaceContext,
22: 20:     },
23: 21: };
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
25: 23: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, db_error, not_found, unexpected_error};
26: 24: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
27: 25:     PaginatedResponse, User,
28: 26:     api::dimension::{
29: 27:         CreateRequest, DeleteRequest, DimensionName, DimensionResponse, UpdateRequest,
30: 28:     },
31: 29:     custom_query::PaginationParams,
32: 30:     database::{
33: 31:         models::{
34: 32:             Description,
35: 33:             cac::{DependencyGraph, Dimension, DimensionType},
36: 34:         },
37: 35:         schema::dimensions::{self, dsl::*},
38: 36:     },
39: 37:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
40: 38: };
41: 39: 
42: 40: use crate::api::dimension::validations::allow_primitive_types;
43: 41: #[cfg(feature = "high-performance-mode")]
44: 42: use crate::helpers::put_config_in_redis;
45: 43: use crate::{
46: 44:     api::dimension::{
47: 45:         utils::{
48: 46:             create_connections_with_dependents, get_dimension_usage_context_lyx-core-lyx_core_lyx-core-lyx_core_ids,
49: 47:             remove_connections_with_dependents,
50: 48:         },
51: 49:         validations::{
52: 50:             does_dimension_exist_for_cohorting, validate_cohort_position,
53: 51:             validate_cohort_schema, validate_dimension_position, validate_jsonschema,
54: 52:             validate_position_wrt_dependency, validate_validation_function,
55: 53:             validate_value_compute_function,
56: 54:         },
57: 55:     },
58: 56:     helpers::{add_config_version, validate_change_reason},
59: 57: };
60: 58: 
61: 59: pub fn endpoints() -> Scope {
62: 60:     Scope::new("")
63: 61:         .service(create_handler)
64: 62:         .service(update_handler)
65: 63:         .service(get_handler)
66: 64:         .service(list_handler)
67: 65:         .service(delete_handler)
68: 66: }
69: 67: 
70: 68: #[authorized]
71: 69: #[post("")]
72: 70: async fn create_handler(
73: 71:     workspace_context: WorkspaceContext,
74: 72:     state: Data<AppState>,
75: 73:     req: web::Json<CreateRequest>,
76: 74:     user: User,
77: 75:     custom_headers: CustomHeaders,
78: 76:     db_conn: DbConnection,
79: 77: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
80: 78:     let DbConnection(mut conn) = db_conn;
81: 79:     let create_req = req.into_inner();
82: 80:     let schema_value = Value::from(&create_req.schema);
83: 81:     let tags = parse_config_tags(custom_headers.config_tags)?;
84: 82: 
85: 83:     validate_change_reason(
86: 84:         &workspace_context,
87: 85:         &create_req.change_reason,
88: 86:         &mut conn,
89: 87:         &state.master_encryption_key,
90: 88:     )?;
91: 89: 
92: 90:     let num_rows = dimensions
93: 91:         .count()
94: 92:         .schema_name(&workspace_context.schema_name)
95: 93:         .get_result::<i64>(&mut conn)
96: 94:         .map_err(|err| {
97: 95:             log::error!("failed to fetch number of dimension with error: {}", err);
98: 96:             db_error!(err)
99: 97:         })?;
100: 98: 
101: 99:     validate_dimension_position(
102: 100:         create_req.dimension.clone(),
103: 101:         create_req.position,
104: 102:         num_rows,
105: 103:     )?;
106: 104: 
107: 105:     match create_req.dimension_type {
108: 106:         DimensionType::Regular {} => {
109: 107:             allow_primitive_types(&create_req.schema)?;
110: 108:             validate_jsonschema(&state.meta_schema, &schema_value)?;
111: 109:         }
112: 110:         DimensionType::RemoteCohort(ref cohort_based_on) => {
113: 111:             allow_primitive_types(&create_req.schema)?;
114: 112:             validate_jsonschema(&state.meta_schema, &schema_value)?;
115: 113:             let based_on_dimension = does_dimension_exist_for_cohorting(
116: 114:                 cohort_based_on,
117: 115:                 &workspace_context.schema_name,
118: 116:                 &mut conn,
119: 117:             )?;
120: 118:             validate_cohort_position(&create_req.position, &based_on_dimension, true)?;
121: 119:         }
122: 120:         DimensionType::LocalCohort(ref cohort_based_on) => {
123: 121:             let based_on_dimension = validate_cohort_schema(
124: 122:                 &schema_value,
125: 123:                 cohort_based_on,
126: 124:                 &workspace_context.schema_name,
127: 125:                 &mut conn,
128: 126:             )?;
129: 127:             validate_cohort_position(&create_req.position, &based_on_dimension, true)?;
130: 128:         }
131: 129:     }
132: 130: 
133: 131:     validate_validation_function(
134: 132:         &create_req.value_validation_function_name,
135: 133:         &mut conn,
136: 134:         &workspace_context.schema_name,
137: 135:     )?;
138: 136: 
139: 137:     validate_value_compute_function(
140: 138:         &create_req.dimension_type,
141: 139:         &create_req.value_compute_function_name,
142: 140:         &mut conn,
143: 141:         &workspace_context.schema_name,
144: 142:     )?;
145: 143: 
146: 144:     let dimension_data = Dimension {
147: 145:         dimension: create_req.dimension.into(),
148: 146:         position: create_req.position,
149: 147:         schema: create_req.schema,
150: 148:         created_by: user.get_email(),
151: 149:         created_at: Utc::now(),
152: 150:         value_validation_function_name: create_req.value_validation_function_name.clone(),
153: 151:         last_modified_at: Utc::now(),
154: 152:         last_modified_by: user.get_email(),
155: 153:         description: create_req.description,
156: 154:         change_reason: create_req.change_reason,
157: 155:         dependency_graph: DependencyGraph::default(),
158: 156:         value_compute_function_name: create_req.value_compute_function_name,
159: 157:         dimension_type: create_req.dimension_type,
160: 158:     };
161: 159: 
162: 160:     let (inserted_dimension, is_mandatory, version_id) = conn
163: 161:         .transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
164: 162:             diesel::update(dimensions::table)
165: 163:                 .filter(dimensions::position.ge(dimension_data.position))
166: 164:                 .set((
167: 165:                     last_modified_at.eq(Utc::now()),
168: 166:                     last_modified_by.eq(user.get_email()),
169: 167:                     dimensions::position.eq(dimensions::position + 1),
170: 168:                 ))
171: 169:                 .returning(Dimension::as_returning())
172: 170:                 .schema_name(&workspace_context.schema_name)
173: 171:                 .execute(transaction_conn)?;
174: 172: 
175: 173:             match dimension_data.dimension_type {
176: 174:                 DimensionType::LocalCohort(ref cohort_based_on)
177: 175:                 | DimensionType::RemoteCohort(ref cohort_based_on) => {
178: 176:                     // Update dependency graphs of all dimensions that
179: 177:                     // depend on the cohort_based_on dimension as well as
180: 178:                     // the cohorted dimension itself
181: 179:                     create_connections_with_dependents(
182: 180:                         cohort_based_on,
183: 181:                         &dimension_data.dimension,
184: 182:                         &user.get_email(),
185: 183:                         &workspace_context.schema_name,
186: 184:                         transaction_conn,
187: 185:                     )?
188: 186:                 }
189: 187:                 DimensionType::Regular {} => (),
190: 188:             }
191: 189: 
192: 190:             let insert_resp = diesel::insert_into(dimensions::table)
193: 191:                 .values(&dimension_data)
194: 192:                 .returning(Dimension::as_returning())
195: 193:                 .schema_name(&workspace_context.schema_name)
196: 194:                 .get_result(transaction_conn);
197: 195: 
198: 196:             match insert_resp {
199: 197:                 Ok(inserted_dimension) => {
200: 198:                     let is_mandatory = workspace_context
201: 199:                         .settings
202: 200:                         .mandatory_dimensions
203: 201:                         .unwrap_or_default()
204: 202:                         .contains(&inserted_dimension.dimension);
205: 203: 
206: 204:                     let version_id = add_config_version(
207: 205:                         &state,
208: 206:                         tags,
209: 207:                         dimension_data.change_reason.into(),
210: 208:                         transaction_conn,
211: 209:                         &workspace_context.schema_name,
212: 210:                     )?;
213: 211:                     Ok((inserted_dimension, is_mandatory, version_id))
214: 212:                 }
215: 213:                 Err(diesel::result::Error::DatabaseError(
216: 214:                     diesel::result::DatabaseErrorKind::ForeignKeyViolation,
217: 215:                     e,
218: 216:                 )) => {
219: 217:                     let fun_name = create_req.value_validation_function_name.clone();
220: 218:                     log::error!("{fun_name:?} function not found with error: {e:?}");
221: 219:                     Err(bad_argument!(
222: 220:                         "Function {} doesn't exists",
223: 221:                         Into::<Option<String>>::into(
224: 222:                             create_req.value_validation_function_name.clone()
225: 223:                         )
226: 224:                         .unwrap_or_default()
227: 225:                     ))
228: 226:                 }
229: 227:                 Err(e) => {
230: 228:                     log::error!("Dimension create failed with error: {e}");
231: 229:                     Err(db_error!(e))
232: 230:                 }
233: 231:             }
234: 232:         })?;
235: 233: 
236: 234:     #[cfg(feature = "high-performance-mode")]
237: 235:     put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
238: 236:         .await?;
239: 237: 
240: 238:     let mut http_resp = HttpResponse::Created();
241: 239:     http_resp.insert_header((
242: 240:         AppHeader::XConfigVersion.to_string(),
243: 241:         version_id.to_string(),
244: 242:     ));
245: 243:     Ok(http_resp.json(DimensionResponse::new(inserted_dimension, is_mandatory)))
246: 244: }
247: 245: 
248: 246: #[authorized]
249: 247: #[get("/{name}")]
250: 248: async fn get_handler(
251: 249:     workspace_context: WorkspaceContext,
252: 250:     db_conn: DbConnection,
253: 251:     req: Path<String>,
254: 252: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<DimensionResponse>> {
255: 253:     let DbConnection(mut conn) = db_conn;
256: 254: 
257: 255:     let result: Dimension = dimensions::dsl::dimensions
258: 256:         .filter(dimensions::dimension.eq(req.into_inner()))
259: 257:         .schema_name(&workspace_context.schema_name)
260: 258:         .get_result::<Dimension>(&mut conn)?;
261: 259: 
262: 260:     let is_mandatory = workspace_context
263: 261:         .settings
264: 262:         .mandatory_dimensions
265: 263:         .unwrap_or_default()
266: 264:         .contains(&result.dimension);
267: 265: 
268: 266:     Ok(Json(DimensionResponse::new(result, is_mandatory)))
269: 267: }
270: 268: 
271: 269: #[allow(clippy::too_many_arguments)]
272: 270: #[authorized]
273: 271: #[routes]
274: 272: #[put("/{name}")]
275: 273: #[patch("/{name}")]
276: 274: async fn update_handler(
277: 275:     workspace_context: WorkspaceContext,
278: 276:     path: Path<DimensionName>,
279: 277:     state: Data<AppState>,
280: 278:     req: web::Json<UpdateRequest>,
281: 279:     user: User,
282: 280:     custom_headers: CustomHeaders,
283: 281:     db_conn: DbConnection,
284: 282: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
285: 283:     let name: String = path.clone().into();
286: 284:     use dimensions::dsl;
287: 285:     let DbConnection(mut conn) = db_conn;
288: 286:     let tags = parse_config_tags(custom_headers.config_tags)?;
289: 287:     let update_req = req.into_inner();
290: 288: 
291: 289:     validate_change_reason(
292: 290:         &workspace_context,
293: 291:         &update_req.change_reason,
294: 292:         &mut conn,
295: 293:         &state.master_encryption_key,
296: 294:     )?;
297: 295: 
298: 296:     let dimension_data: Dimension = dimensions::dsl::dimensions
299: 297:         .filter(dimensions::dimension.eq(name.clone()))
300: 298:         .schema_name(&workspace_context.schema_name)
301: 299:         .get_result::<Dimension>(&mut conn)?;
302: 300: 
303: 301:     let num_rows = dimensions
304: 302:         .count()
305: 303:         .schema_name(&workspace_context.schema_name)
306: 304:         .get_result::<i64>(&mut conn)
307: 305:         .map_err(|err| {
308: 306:             log::error!("failed to fetch number of dimension with error: {}", err);
309: 307:             db_error!(err)
310: 308:         })?;
311: 309: 
312: 310:     if let Some(ref new_schema) = update_req.schema {
313: 311:         let schema_value = Value::from(new_schema);
314: 312:         match dimension_data.dimension_type {
315: 313:             DimensionType::Regular {} | DimensionType::RemoteCohort(_) => {
316: 314:                 allow_primitive_types(new_schema)?;
317: 315:                 validate_jsonschema(&state.meta_schema, &schema_value)?;
318: 316:             }
319: 317:             DimensionType::LocalCohort(ref cohort_based_on) => {
320: 318:                 validate_cohort_schema(
321: 319:                     &schema_value,
322: 320:                     cohort_based_on,
323: 321:                     &workspace_context.schema_name,
324: 322:                     &mut conn,
325: 323:                 )?;
326: 324:             }
327: 325:         }
328: 326:     }
329: 327: 
330: 328:     if let Some(ref new_position) = update_req.position {
331: 329:         match dimension_data.dimension_type {
332: 330:             DimensionType::Regular {} => (),
333: 331:             DimensionType::RemoteCohort(ref cohort_based_on)
334: 332:             | DimensionType::LocalCohort(ref cohort_based_on) => {
335: 333:                 let based_on_dimension = does_dimension_exist_for_cohorting(
336: 334:                     cohort_based_on,
337: 335:                     &workspace_context.schema_name,
338: 336:                     &mut conn,
339: 337:                 )?;
340: 338:                 validate_cohort_position(new_position, &based_on_dimension, false)?;
341: 339:             }
342: 340:         }
343: 341:     }
344: 342: 
345: 343:     if let Some(ref fn_name) = update_req.value_validation_function_name {
346: 344:         validate_validation_function(fn_name, &mut conn, &workspace_context.schema_name)?;
347: 345:     }
348: 346: 
349: 347:     if let Some(ref value_compute_function_name_) = update_req.value_compute_function_name
350: 348:     {
351: 349:         validate_value_compute_function(
352: 350:             &dimension_data.dimension_type,
353: 351:             value_compute_function_name_,
354: 352:             &mut conn,
355: 353:             &workspace_context.schema_name,
356: 354:         )?;
357: 355:     }
358: 356: 
359: 357:     let (result, is_mandatory, version_id) = conn
360: 358:         .transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
361: 359:             if let Some(position_val) = update_req.position {
362: 360:                 let new_position = position_val;
363: 361:                 validate_dimension_position(
364: 362:                     path.into_inner(),
365: 363:                     position_val,
366: 364:                     num_rows - 1,
367: 365:                 )?;
368: 366:                 validate_position_wrt_dependency(
369: 367:                     &name,
370: 368:                     &position_val,
371: 369:                     transaction_conn,
372: 370:                     &workspace_context.schema_name,
373: 371:                 )?;
374: 372:                 let previous_position = dimension_data.position;
375: 373: 
376: 374:                 diesel::update(dimensions)
377: 375:                     .filter(dsl::dimension.eq(&name))
378: 376:                     .set((
379: 377:                         dsl::last_modified_at.eq(Utc::now()),
380: 378:                         dsl::last_modified_by.eq(user.get_email()),
381: 379:                         dimensions::position.eq((num_rows + 100) as i32),
382: 380:                     ))
383: 381:                     .returning(Dimension::as_returning())
384: 382:                     .schema_name(&workspace_context.schema_name)
385: 383:                     .get_result::<Dimension>(transaction_conn)?;
386: 384: 
387: 385:                 if previous_position < new_position {
388: 386:                     diesel::update(dsl::dimensions)
389: 387:                         .filter(dimensions::position.gt(previous_position))
390: 388:                         .filter(dimensions::position.le(&new_position))
391: 389:                         .set((
392: 390:                             dsl::last_modified_at.eq(Utc::now()),
393: 391:                             dsl::last_modified_by.eq(user.get_email()),
394: 392:                             dimensions::position.eq(dimensions::position - 1),
395: 393:                         ))
396: 394:                         .returning(Dimension::as_returning())
397: 395:                         .schema_name(&workspace_context.schema_name)
398: 396:                         .execute(transaction_conn)?
399: 397:                 } else {
400: 398:                     diesel::update(dsl::dimensions)
401: 399:                         .filter(dimensions::position.lt(previous_position))
402: 400:                         .filter(dimensions::position.ge(&new_position))
403: 401:                         .set((
404: 402:                             dsl::last_modified_at.eq(Utc::now()),
405: 403:                             dsl::last_modified_by.eq(user.get_email()),
406: 404:                             dimensions::position.eq(dimensions::position + 1),
407: 405:                         ))
408: 406:                         .returning(Dimension::as_returning())
409: 407:                         .schema_name(&workspace_context.schema_name)
410: 408:                         .execute(transaction_conn)?
411: 409:                 };
412: 410:             }
413: 411: 
414: 412:             let result = diesel::update(dimensions)
415: 413:                 .filter(dsl::dimension.eq(name))
416: 414:                 .set((
417: 415:                     update_req,
418: 416:                     dimensions::last_modified_at.eq(Utc::now()),
419: 417:                     dimensions::last_modified_by.eq(user.get_email()),
420: 418:                 ))
421: 419:                 .returning(Dimension::as_returning())
422: 420:                 .schema_name(&workspace_context.schema_name)
423: 421:                 .get_result::<Dimension>(transaction_conn)
424: 422:                 .map_err(|err| db_error!(err))?;
425: 423: 
426: 424:             let is_mandatory = workspace_context
427: 425:                 .settings
428: 426:                 .mandatory_dimensions
429: 427:                 .unwrap_or_default()
430: 428:                 .contains(&result.dimension);
431: 429: 
432: 430:             let version_id = add_config_version(
433: 431:                 &state,
434: 432:                 tags,
435: 433:                 dimension_data.change_reason.into(),
436: 434:                 transaction_conn,
437: 435:                 &workspace_context.schema_name,
438: 436:             )?;
439: 437: 
440: 438:             Ok((result, is_mandatory, version_id))
441: 439:         })?;
442: 440: 
443: 441:     #[cfg(feature = "high-performance-mode")]
444: 442:     put_config_in_redis(version_id, state, &workspace_context.schema_name, &mut conn)
445: 443:         .await?;
446: 444: 
447: 445:     let mut http_resp = HttpResponse::Ok();
448: 446:     http_resp.insert_header((
449: 447:         AppHeader::XConfigVersion.to_string(),
450: 448:         version_id.to_string(),
451: 449:     ));
452: 450:     Ok(http_resp.json(DimensionResponse::new(result, is_mandatory)))
453: 451: }
454: 452: 
455: 453: #[authorized]
456: 454: #[get("")]
457: 455: async fn list_handler(
458: 456:     workspace_context: WorkspaceContext,
459: 457:     db_conn: DbConnection,
460: 458:     filters: Query<PaginationParams>,
461: 459: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<DimensionResponse>>> {
462: 460:     let DbConnection(mut conn) = db_conn;
463: 461: 
464: 462:     let (total_pages, total_items, result) = match filters.all {
465: 463:         Some(true) => {
466: 464:             let result: Vec<Dimension> = dimensions
467: 465:                 .schema_name(&workspace_context.schema_name)
468: 466:                 .get_results(&mut conn)?;
469: 467:             (1, result.len() as i64, result)
470: 468:         }
471: 469:         _ => {
472: 470:             let n_dimensions: i64 = dimensions
473: 471:                 .count()
474: 472:                 .schema_name(&workspace_context.schema_name)
475: 473:                 .get_result(&mut conn)?;
476: 474:             let limit = filters.count.unwrap_or(10);
477: 475:             let mut builder = dimensions
478: 476:                 .schema_name(&workspace_context.schema_name)
479: 477:                 .order(created_at.desc())
480: 478:                 .limit(limit)
481: 479:                 .into_boxed();
482: 480:             if let Some(page) = filters.page {
483: 481:                 let offset = (page - 1) * limit;
484: 482:                 builder = builder.offset(offset);
485: 483:             }
486: 484:             let result: Vec<Dimension> = builder.load(&mut conn)?;
487: 485:             let total_pages = (n_dimensions as f64 / limit as f64).ceil() as i64;
488: 486:             (total_pages, n_dimensions, result)
489: 487:         }
490: 488:     };
491: 489: 
492: 490:     let mandatory_dimensions = workspace_context
493: 491:         .settings
494: 492:         .mandatory_dimensions
495: 493:         .unwrap_or_default();
496: 494: 
497: 495:     let dimensions_with_mandatory: Vec<DimensionResponse> = result
498: 496:         .into_iter()
499: 497:         .map(|ele| {
500: 498:             let is_mandatory = mandatory_dimensions.contains(&ele.dimension);
501: 499:             DimensionResponse::new(ele, is_mandatory)
502: 500:         })
503: 501:         .collect();
504: 502: 
505: 503:     Ok(Json(PaginatedResponse {
506: 504:         total_pages,
507: 505:         total_items,
508: 506:         data: dimensions_with_mandatory,
509: 507:     }))
510: 508: }
511: 509: 
512: 510: #[authorized]
513: 511: #[delete("/{name}")]
514: 512: async fn delete_handler(
515: 513:     workspace_context: WorkspaceContext,
516: 514:     state: Data<AppState>,
517: 515:     path: Path<DeleteRequest>,
518: 516:     user: User,
519: 517:     custom_headers: CustomHeaders,
520: 518:     db_conn: DbConnection,
521: 519: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
522: 520:     let name: String = path.into_inner().into();
523: 521:     let DbConnection(mut conn) = db_conn;
524: 522:     let tags = parse_config_tags(custom_headers.config_tags)?;
525: 523: 
526: 524:     let dimension_data: Dimension = dimensions::dsl::dimensions
527: 525:         .filter(dimensions::dimension.eq(&name))
528: 526:         .select(Dimension::as_select())
529: 527:         .schema_name(&workspace_context.schema_name)
530: 528:         .get_result(&mut conn)?;
531: 529: 
532: 530:     let context_lyx-core-lyx_core_lyx-core-lyx_core_ids = get_dimension_usage_context_lyx-core-lyx_core_lyx-core-lyx_core_ids(
533: 531:         &name,
534: 532:         &mut conn,
535: 533:         &workspace_context.schema_name,
536: 534:     )?;
537: 535: 
538: 536:     if context_lyx-core-lyx_core_lyx-core-lyx_core_ids.is_empty() {
539: 537:         let (resp, _version_id) = conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
540: 538:             use dimensions::dsl;
541: 539: 
542: 540:             if !dimension_data.dependency_graph.is_empty() {
543: 541:                 return Err(bad_argument!("The dimension {} currently has other dimensions that are using it in their cohort definitions. To delete this dimension, you need to delete these cohorts", &dimension_data.dimension))
544: 542:             }
545: 543: 
546: 544:             match dimension_data.dimension_type {
547: 545:                 DimensionType::LocalCohort(ref cohort_based_on)
548: 546:                 | DimensionType::RemoteCohort(ref cohort_based_on) => {
549: 547:                     // Remove dependency graphs of all dimensions that
550: 548:                     // depend on the cohort_based_on dimension as well as
551: 549:                     // the cohorted dimension itself
552: 550:                     remove_connections_with_dependents(
553: 551:                         &dimension_data.dimension,
554: 552:                         cohort_based_on,
555: 553:                         &user.get_email(),
556: 554:                         &workspace_context.schema_name,
557: 555:                         transaction_conn,
558: 556:                     )?
559: 557:                 }
560: 558:                 DimensionType::Regular{} => (),
561: 559:             }
562: 560:             diesel::update(dsl::dimensions)
563: 561:                 .filter(dsl::dimension.eq(&name))
564: 562:                 .set((
565: 563:                     dsl::last_modified_at.eq(Utc::now()),
566: 564:                     dsl::last_modified_by.eq(user.get_email()),
567: 565:                 ))
568: 566:                 .returning(Dimension::as_returning())
569: 567:                 .schema_name(&workspace_context.schema_name)
570: 568:                 .execute(transaction_conn)?;
571: 569: 
572: 570:             let deleted_row = diesel::delete(dsl::dimensions.filter(dsl::dimension.eq(&name)))
573: 571:                 .schema_name(&workspace_context.schema_name)
574: 572:                 .execute(transaction_conn);
575: 573: 
576: 574:             diesel::update(dimensions::dsl::dimensions)
577: 575:                 .filter(dimensions::position.gt(dimension_data.position))
578: 576:                 .set(dimensions::position.eq(dimensions::position - 1))
579: 577:                 .returning(Dimension::as_returning())
580: 578:                 .schema_name(&workspace_context.schema_name)
581: 579:                 .execute(transaction_conn)?;
582: 580: 
583: 581:             match deleted_row {
584: 582:                 Ok(0) => Err(not_found!("Dimension `{}` doesn't exists", name)),
585: 583:                 Ok(_) => {
586: 584:                     let config_version_desc = Description::try_from(format!(
587: 585:                         "Dimension Deleted by {}",
588: 586:                         user.get_email()
589: 587:                     ))
590: 588:                     .map_err(|e| unexpected_error!(e))?;
591: 589:                     let version_id = add_config_version(
592: 590:                         &state,
593: 591:                         tags,
594: 592:                         config_version_desc,
595: 593:                         transaction_conn,
596: 594:                         &workspace_context.schema_name,
597: 595:                     )?;
598: 596:                     log::info!(
599: 597:                         "Dimension: {name} deleted by {}",
600: 598:                         user.get_email()
601: 599:                     );
602: 600:                     Ok((HttpResponse::NoContent()
603: 601:                         .insert_header((
604: 602:                             AppHeader::XConfigVersion.to_string(),
605: 603:                             version_id.to_string(),
606: 604:                         ))
607: 605:                         .finish(), version_id))
608: 606:                     },
609: 607:                 Err(e) => {
610: 608:                     log::error!("dimension delete query failed with error: {e}");
611: 609:                     Err(unexpected_error!("Something went wrong."))
612: 610:                 }
613: 611:             }
614: 612:         })?;
615: 613: 
616: 614:         #[cfg(feature = "high-performance-mode")]
617: 615:         put_config_in_redis(
618: 616:             _version_id,
619: 617:             state,
620: 618:             &workspace_context.schema_name,
621: 619:             &mut conn,
622: 620:         )
623: 621:         .await?;
624: 622:         Ok(resp)
625: 623:     } else {
626: 624:         Err(bad_argument!(
627: 625:             "Given key already in use in contexts: {}",
628: 626:             context_lyx-core-lyx_core_lyx-core-lyx_core_ids.join(",")
629: 627:         ))
630: 628:     }
631: 629: }
632: 630: ```
633: 631: ```
634: 632: ```
635: 633: ```
636: ```
```

