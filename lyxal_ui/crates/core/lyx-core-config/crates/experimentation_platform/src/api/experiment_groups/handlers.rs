### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     Scope, delete, get, patch, post,
13: 11:     web::{self, Data, Json},
14: 12: };
15: 13: use chrono::Utc;
16: 14: use diesel::{
17: 15:     Connection, ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper,
18: 16:     TextExpressionMethods,
19: 17: };
20: 18: use serde_json::Value;
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
22: 20:     helpers::{generate_snowflake_id, get_from_env_or_default},
23: 21:     service::types::{AppState, DbConnection, WorkspaceContext},
24: 22: };
25: 23: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
26: 24: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, unexpected_error};
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
28: 26:     PaginatedResponse, SortBy, User,
29: 27:     api::experiment_groups::{
30: 28:         ExpGroupCreateRequest, ExpGroupFilters, ExpGroupMemberRequest,
31: 29:         ExpGroupUpdateRequest, SortOn,
32: 30:     },
33: 31:     custom_query::{self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, CustomQuery, PaginationParams},
34: 32:     database::{
35: 33:         models::{
36: 34:             ChangeReason,
37: 35:             experimentation::{
38: 36:                 Buckets, Experiment, ExperimentGroup, ExperimentGroups,
39: 37:                 ExperimentStatusType, GroupType,
40: 38:             },
41: 39:         },
42: 40:         schema::{
43: 41:             experiment_groups::dsl as experiment_groups, experiments::dsl as experiments,
44: 42:         },
45: 43:     },
46: 44:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
47: 45: };
48: 46: 
49: 47: use crate::api::{
50: 48:     experiment_groups::helpers::{
51: 49:         add_members, create_system_generated_experiment_group,
52: 50:         fetch_and_validate_members, fetch_experiment_group, remove_members,
53: 51:         validate_experiment_group_constraints,
54: 52:     },
55: 53:     experiments::{
56: 54:         cac_api::validate_context,
57: 55:         helpers::{
58: 56:             fetch_and_validate_change_reason_with_function, hash,
59: 57:             validate_and_add_experiment_group_id,
60: 58:             validate_and_remove_experiment_group_id,
61: 59:         },
62: 60:     },
63: 61: };
64: 62: 
65: 63: pub fn endpoints(scope: Scope) -> Scope {
66: 64:     scope
67: 65:         .service(create_handler)
68: 66:         .service(update_handler)
69: 67:         .service(list_handler)
70: 68:         .service(get_handler)
71: 69:         .service(delete_handler)
72: 70:         .service(add_members_handler)
73: 71:         .service(remove_members_handler)
74: 72:         .service(backfill_handler)
75: 73: }
76: 74: 
77: 75: #[authorized]
78: 76: #[post("")]
79: 77: async fn create_handler(
80: 78:     workspace_context: WorkspaceContext,
81: 79:     state: Data<AppState>,
82: 80:     req: Json<ExpGroupCreateRequest>,
83: 81:     db_conn: DbConnection,
84: 82:     user: User,
85: 83: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
86: 84:     let DbConnection(mut conn) = db_conn;
87: 85:     let req = req.into_inner();
88: 86:     log::trace!("Creating experiment group with request: {:?}", req);
89: 87: 
90: 88:     let exp_context = req.context.into_inner();
91: 89:     let member_experiments = if let Some(members) = req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids {
92: 90:         fetch_and_validate_members(
93: 91:             &members,
94: 92:             &[],
95: 93:             &mut conn,
96: 94:             &workspace_context.schema_name,
97: 95:         )?
98: 96:     } else {
99: 97:         Vec::new()
100: 98:     };
101: 99: 
102: 100:     fetch_and_validate_change_reason_with_function(
103: 101:         &workspace_context,
104: 102:         &req.change_reason,
105: 103:         &state,
106: 104:     )
107: 105:     .await?;
108: 106: 
109: 107:     validate_context(&state, &exp_context, &workspace_context, &user).await?;
110: 108:     validate_experiment_group_constraints(&member_experiments, &[], &exp_context)?;
111: 109: 
112: 110:     let members = member_experiments
113: 111:         .iter()
114: 112:         .map(|exp| exp.id)
115: 113:         .collect::<Vec<_>>();
116: 114:     let id = generate_snowflake_id(&state)?;
117: 115:     let context_hash = hash(&Value::Object(exp_context.clone().into()));
118: 116:     let now = chrono::Utc::now();
119: 117:     let new_experiment_group = ExperimentGroup {
120: 118:         id,
121: 119:         context_hash,
122: 120:         name: req.name,
123: 121:         description: req.description,
124: 122:         change_reason: req.change_reason,
125: 123:         created_by: user.email.clone(),
126: 124:         last_modified_by: user.email.clone(),
127: 125:         created_at: now,
128: 126:         last_modified_at: now,
129: 127:         context: exp_context,
130: 128:         traffic_percentage: req.traffic_percentage,
131: 129:         member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: members.clone(),
132: 130:         buckets: Buckets::default(),
133: 131:         group_type: GroupType::UserCreated,
134: 132:     };
135: 133: 
136: 134:     let new_experiment_group =
137: 135:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
138: 136:             validate_and_add_experiment_group_id(
139: 137:                 &member_experiments,
140: 138:                 &id,
141: 139:                 &workspace_context.schema_name,
142: 140:                 transaction_conn,
143: 141:                 &user,
144: 142:             )?;
145: 143:             let new_experiment_group =
146: 144:                 diesel::insert_into(experiment_groups::experiment_groups)
147: 145:                     .values(&new_experiment_group)
148: 146:                     .returning(ExperimentGroup::as_returning())
149: 147:                     .schema_name(&workspace_context.schema_name)
150: 148:                     .get_result::<ExperimentGroup>(transaction_conn)?;
151: 149:             Ok(new_experiment_group)
152: 150:         })?;
153: 151:     Ok(Json(new_experiment_group))
154: 152: }
155: 153: 
156: 154: #[authorized]
157: 155: #[patch("/{exp_group_id}")]
158: 156: async fn update_handler(
159: 157:     workspace_context: WorkspaceContext,
160: 158:     exp_group_id: web::Path<i64>,
161: 159:     req: Json<ExpGroupUpdateRequest>,
162: 160:     db_conn: DbConnection,
163: 161:     user: User,
164: 162:     state: Data<AppState>,
165: 163: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
166: 164:     let DbConnection(mut conn) = db_conn;
167: 165:     let id = exp_group_id.into_inner();
168: 166: 
169: 167:     let experiment_group =
170: 168:         fetch_experiment_group(&id, &mut conn, &workspace_context.schema_name)?;
171: 169:     if experiment_group.group_type == GroupType::SystemGenerated {
172: 170:         return Err(bad_argument!(
173: 171:             "Cannot update system generated experiment group with id {}",
174: 172:             id
175: 173:         ));
176: 174:     }
177: 175: 
178: 176:     let req = req.into_inner();
179: 177: 
180: 178:     fetch_and_validate_change_reason_with_function(
181: 179:         &workspace_context,
182: 180:         &req.change_reason,
183: 181:         &state,
184: 182:     )
185: 183:     .await?;
186: 184: 
187: 185:     let updated_group = diesel::update(experiment_groups::experiment_groups)
188: 186:         .filter(experiment_groups::id.eq(&id))
189: 187:         .set((
190: 188:             req,
191: 189:             experiment_groups::last_modified_by.eq(user.email),
192: 190:             experiment_groups::last_modified_at.eq(chrono::Utc::now()),
193: 191:         ))
194: 192:         .returning(ExperimentGroup::as_returning())
195: 193:         .schema_name(&workspace_context.schema_name)
196: 194:         .get_result(&mut conn)?;
197: 195:     Ok(Json(updated_group))
198: 196: }
199: 197: 
200: 198: #[authorized]
201: 199: #[patch("/{exp_group_id}/add-members")]
202: 200: async fn add_members_handler(
203: 201:     workspace_context: WorkspaceContext,
204: 202:     exp_group_id: web::Path<i64>,
205: 203:     req: Json<ExpGroupMemberRequest>,
206: 204:     db_conn: DbConnection,
207: 205:     user: User,
208: 206:     state: Data<AppState>,
209: 207: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
210: 208:     let req = req.into_inner();
211: 209:     let DbConnection(mut conn) = db_conn;
212: 210: 
213: 211:     fetch_and_validate_change_reason_with_function(
214: 212:         &workspace_context,
215: 213:         &req.change_reason,
216: 214:         &state,
217: 215:     )
218: 216:     .await?;
219: 217: 
220: 218:     let id = exp_group_id.into_inner();
221: 219:     let member_experiments = fetch_and_validate_members(
222: 220:         &req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids,
223: 221:         &[],
224: 222:         &mut conn,
225: 223:         &workspace_context.schema_name,
226: 224:     )?;
227: 225: 
228: 226:     let experiment_group =
229: 227:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
230: 228:             validate_and_add_experiment_group_id(
231: 229:                 &member_experiments,
232: 230:                 &id,
233: 231:                 &workspace_context.schema_name,
234: 232:                 transaction_conn,
235: 233:                 &user,
236: 234:             )?;
237: 235:             add_members(
238: 236:                 &id,
239: 237:                 &member_experiments,
240: 238:                 req,
241: 239:                 transaction_conn,
242: 240:                 &workspace_context.schema_name,
243: 241:                 &user,
244: 242:             )
245: 243:         })?;
246: 244:     Ok(experiment_group)
247: 245: }
248: 246: 
249: 247: #[authorized]
250: 248: #[patch("/{exp_group_id}/remove-members")]
251: 249: async fn remove_members_handler(
252: 250:     workspace_context: WorkspaceContext,
253: 251:     exp_group_id: web::Path<i64>,
254: 252:     req: Json<ExpGroupMemberRequest>,
255: 253:     state: Data<AppState>,
256: 254:     db_conn: DbConnection,
257: 255:     user: User,
258: 256: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
259: 257:     let req = req.into_inner();
260: 258:     let DbConnection(mut conn) = db_conn;
261: 259:     let id = exp_group_id.into_inner();
262: 260: 
263: 261:     fetch_and_validate_change_reason_with_function(
264: 262:         &workspace_context,
265: 263:         &req.change_reason,
266: 264:         &state,
267: 265:     )
268: 266:     .await?;
269: 267: 
270: 268:     let experiment_group =
271: 269:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
272: 270:             validate_and_remove_experiment_group_id(
273: 271:                 &req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids,
274: 272:                 &id,
275: 273:                 &workspace_context.schema_name,
276: 274:                 &state,
277: 275:                 transaction_conn,
278: 276:                 &user,
279: 277:             )?;
280: 278:             remove_members(
281: 279:                 &id,
282: 280:                 req,
283: 281:                 transaction_conn,
284: 282:                 &workspace_context.schema_name,
285: 283:                 &user,
286: 284:             )
287: 285:         })?;
288: 286:     Ok(experiment_group)
289: 287: }
290: 288: 
291: 289: #[authorized]
292: 290: #[get("")]
293: 291: async fn list_handler(
294: 292:     workspace_context: WorkspaceContext,
295: 293:     pagination_params: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<PaginationParams>,
296: 294:     filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ExpGroupFilters>,
297: 295:     db_conn: DbConnection,
298: 296: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<ExperimentGroup>>> {
299: 297:     let DbConnection(mut conn) = db_conn;
300: 298:     let query_builder = |filters: &ExpGroupFilters| {
301: 299:         let mut builder = experiment_groups::experiment_groups
302: 300:             .schema_name(&workspace_context.schema_name)
303: 301:             .into_boxed();
304: 302:         if let Some(name) = &filters.name {
305: 303:             builder = builder.filter(experiment_groups::name.like(format!("%{}%", name)));
306: 304:         }
307: 305:         if let Some(created_by) = &filters.created_by {
308: 306:             builder =
309: 307:                 builder.filter(experiment_groups::created_by.eq(created_by.clone()));
310: 308:         }
311: 309:         if let Some(last_modified_by) = &filters.last_modified_by {
312: 310:             builder = builder
313: 311:                 .filter(experiment_groups::last_modified_by.eq(last_modified_by.clone()));
314: 312:         }
315: 313:         if let Some(group_type) = &filters.group_type {
316: 314:             builder = builder
317: 315:                 .filter(experiment_groups::group_type.eq_any(group_type.0.clone()));
318: 316:         }
319: 317:         builder
320: 318:     };
321: 319:     let filters = filters.into_inner();
322: 320:     let base_query = query_builder(&filters);
323: 321:     let count_query = query_builder(&filters);
324: 322:     let sort_by = filters.sort_by.unwrap_or(SortBy::Desc);
325: 323:     let sort_on = filters.sort_on.unwrap_or_default();
326: 324:     #[rustfmt::skip]
327: 325:     let base_query = match (sort_on, sort_by) {
328: 326:         (SortOn::LastModifiedAt, SortBy::Desc) => base_query.order(experiment_groups::last_modified_at.desc()),
329: 327:         (SortOn::LastModifiedAt, SortBy::Asc)  => base_query.order(experiment_groups::last_modified_at.asc()),
330: 328:         (SortOn::CreatedAt, SortBy::Desc)      => base_query.order(experiment_groups::created_at.desc()),
331: 329:         (SortOn::CreatedAt, SortBy::Asc)       => base_query.order(experiment_groups::created_at.asc()),
332: 330:         (SortOn::Name, SortBy::Desc)           => base_query.order(experiment_groups::name.desc()),
333: 331:         (SortOn::Name, SortBy::Asc)            => base_query.order(experiment_groups::name.asc()),
334: 332:     };
335: 333:     if let Some(true) = pagination_params.all {
336: 334:         let result: ExperimentGroups =
337: 335:             base_query.get_results::<ExperimentGroup>(&mut conn)?;
338: 336:         return Ok(Json(PaginatedResponse::all(result)));
339: 337:     }
340: 338:     let total_items = count_query.count().get_result(&mut conn)?;
341: 339:     let limit = pagination_params.count.unwrap_or(10);
342: 340:     let offset = (pagination_params.page.unwrap_or(1) - 1) * limit;
343: 341: 
344: 342:     let query = base_query.limit(limit).offset(offset);
345: 343:     let data = query.load::<ExperimentGroup>(&mut conn)?;
346: 344:     let total_pages = (total_items as f64 / limit as f64).ceil() as i64;
347: 345:     Ok(Json(PaginatedResponse {
348: 346:         total_pages,
349: 347:         total_items,
350: 348:         data,
351: 349:     }))
352: 350: }
353: 351: 
354: 352: #[authorized]
355: 353: #[get("/{exp_group_id}")]
356: 354: async fn get_handler(
357: 355:     workspace_context: WorkspaceContext,
358: 356:     exp_group_id: web::Path<i64>,
359: 357:     db_conn: DbConnection,
360: 358: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
361: 359:     let id = exp_group_id.into_inner();
362: 360:     let DbConnection(mut conn) = db_conn;
363: 361:     let result = experiment_groups::experiment_groups
364: 362:         .schema_name(&workspace_context.schema_name)
365: 363:         .filter(experiment_groups::id.eq(id))
366: 364:         .first::<ExperimentGroup>(&mut conn)?;
367: 365:     Ok(Json(result))
368: 366: }
369: 367: 
370: 368: #[authorized]
371: 369: #[delete("/{exp_group_id}")]
372: 370: async fn delete_handler(
373: 371:     workspace_context: WorkspaceContext,
374: 372:     exp_group_id: web::Path<i64>,
375: 373:     mut db_conn: DbConnection,
376: 374:     user: User,
377: 375: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
378: 376:     let id = exp_group_id.into_inner();
379: 377:     db_conn.transaction::<Json<ExperimentGroup>, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|conn| {
380: 378:         let marked_group = diesel::update(experiment_groups::experiment_groups)
381: 379:             .filter(experiment_groups::id.eq(&id))
382: 380:             .set((
383: 381:                 experiment_groups::last_modified_by.eq(user.email),
384: 382:                 experiment_groups::last_modified_at.eq(chrono::Utc::now()),
385: 383:             ))
386: 384:             .returning(ExperimentGroup::as_returning())
387: 385:             .schema_name(&workspace_context.schema_name)
388: 386:             .get_result(conn)?;
389: 387:         if !marked_group.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.is_empty() {
390: 388:             return Err(bad_argument!(
391: 389:                 "Cannot delete experiment group {} since it has members",
392: 390:                 marked_group.name
393: 391:             ));
394: 392:         }
395: 393:         diesel::delete(experiment_groups::experiment_groups)
396: 394:             .filter(experiment_groups::id.eq(&id))
397: 395:             .schema_name(&workspace_context.schema_name)
398: 396:             .execute(conn)?;
399: 397:         Ok(Json(marked_group))
400: 398:     })
401: 399: }
402: 400: 
403: 401: // Remove this after backfilling experiment groups
404: 402: #[authorized]
405: 403: #[post("/backfill")]
406: 404: async fn backfill_handler(
407: 405:     workspace_context: WorkspaceContext,
408: 406:     state: Data<AppState>,
409: 407:     db_conn: DbConnection,
410: 408: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Vec<ExperimentGroup>>> {
411: 409:     log::info!("Backfilling experiment groups");
412: 410:     let DbConnection(mut conn) = db_conn;
413: 411:     let user = User {
414: 412:         email: "system@lyx-core-lyx_core_lyx-core-lyx_core_superposition.io".into(),
415: 413:         username: "lyx-core-lyx_core_lyx-core-lyx_core_superposition".into(),
416: 414:     };
417: 415:     let delay = get_from_env_or_default("BACKFILL_DELAY", 100);
418: 416: 
419: 417:     let experiment_groups =
420: 418:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
421: 419:             let mut results = vec![];
422: 420: 
423: 421:             let experiments: Vec<Experiment> = experiments::experiments
424: 422:                 .filter(experiments::status.eq_any(&[
425: 423:                     ExperimentStatusType::INPROGRESS,
426: 424:                     ExperimentStatusType::PAUSED,
427: 425:                 ]))
428: 426:                 .filter(experiments::experiment_group_id.is_null())
429: 427:                 .schema_name(&workspace_context.schema_name)
430: 428:                 .load::<Experiment>(transaction_conn)?;
431: 429: 
432: 430:             for experiment in experiments {
433: 431:                 let experiment_group = create_system_generated_experiment_group(
434: 432:                     &experiment,
435: 433:                     &experiment.traffic_percentage,
436: 434:                     &state,
437: 435:                     transaction_conn,
438: 436:                     &workspace_context.schema_name,
439: 437:                     &user,
440: 438:                 )?;
441: 439: 
442: 440:                 diesel::update(experiments::experiments.find(experiment.id))
443: 441:                     .set((
444: 442:                         experiments::change_reason.eq(ChangeReason::try_from(format!(
445: 443:                             "Experiment {} backfilled to group {}",
446: 444:                             experiment.name, experiment_group.id
447: 445:                         ))
448: 446:                         .map_err(|e| unexpected_error!(e))?),
449: 447:                         experiments::last_modified.eq(Utc::now()),
450: 448:                         experiments::last_modified_by.eq(user.get_email()),
451: 449:                         experiments::experiment_group_id.eq(experiment_group.id),
452: 450:                     ))
453: 451:                     .returning(Experiment::as_returning())
454: 452:                     .schema_name(&workspace_context.schema_name)
455: 453:                     .execute(transaction_conn)?;
456: 454: 
457: 455:                 results.push(experiment_group);
458: 456: 
459: 457:                 std::thread::sleep(std::time::Duration::from_millis(delay));
460: 458:             }
461: 459:             Ok(results)
462: 460:         })?;
463: 461: 
464: 462:     Ok(Json(experiment_groups))
465: 463: }
466: 464: ```
467: 465: ```
468: 466: ```
469: 467: ```
470: ```
```
