### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_platform\src\api\experiments\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\handlers.rs
10: 8: ```rust
11: 9: use std::{
12: 10:     cmp::min,
13: 11:     collections::{HashMap, HashSet},
14: 12:     ops::Deref,
15: 13:     vec,
16: 14: };
17: 15: 
18: 16: use actix_http::header;
19: 17: use actix_web::{
20: 18:     Either, HttpRequest, HttpResponse, HttpResponseBuilder, Scope, get, patch, post,
21: 19:     routes,
22: 20:     web::{self, Data, Json, Path, Query},
23: 21: };
24: 22: use chrono::{DateTime, Utc};
25: 23: use diesel::{
26: 24:     BoolExpressionMethods, Connection, ExpressionMethods, PgConnection, QueryDsl,
27: 25:     RunQueryDsl, SelectableHelper, TextExpressionMethods,
28: 26:     r2d2::{ConnectionManager, PooledConnection},
29: 27: };
30: 28: use lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client::{
31: 29:     get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_buckets_from_group, get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_from_group_response,
32: 30: };
33: 31: use reqwest::{Method, StatusCode};
34: 32: use serde_json::{Map, Value};
35: 33: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
36: 34:     helpers::{
37: 35:         construct_request_headers, execute_webhook_call, fetch_dimensions_info_map,
38: 36:         generate_snowflake_id, request,
39: 37:     },
40: 38:     service::types::{
41: 39:         AppHeader, AppState, CustomHeaders, DbConnection, WorkspaceContext,
42: 40:     },
43: 41: };
44: 42: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
45: 43: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, unexpected_error};
46: 44: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
47: 45:     Cac, Condition, Contextual, DimensionInfo, Exp, ListResponse, Overrides,
48: 46:     PaginatedResponse, SortBy, User,
49: 47:     api::{
50: 48:         DimensionMatchStrategy,
51: 49:         context::{
52: 50:             ContextAction, ContextBulkResponse, Identifier, MoveRequest, PutRequest,
53: 51:             UpdateRequest,
54: 52:         },
55: 53:         default_config::DefaultConfigUpdateRequest,
56: 54:         experiment_groups::ExpGroupMemberRequest,
57: 55:         experiments::{
58: 56:             ApplicableVariantsQuery, ApplicableVariantsRequest,
59: 57:             ConcludeExperimentRequest, ExperimentCreateRequest, ExperimentListFilters,
60: 58:             ExperimentResponse, ExperimentSortOn, ExperimentStateChangeRequest,
61: 59:             OverrideKeysUpdateRequest, RampRequest,
62: 60:         },
63: 61:     },
64: 62:     custom_query::{
65: 63:         self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, CustomQuery, DimensionQuery, PaginationParams,
66: 64:         QueryMap,
67: 65:     },
68: 66:     database::{
69: 67:         models::{
70: 68:             ChangeReason,
71: 69:             experimentation::{
72: 70:                 Experiment, ExperimentGroup, ExperimentStatusType, ExperimentType,
73: 71:                 TrafficPercentage, Variant, VariantType, Variants,
74: 72:             },
75: 73:             others::WebhookEvent,
76: 74:         },
77: 75:         schema::{
78: 76:             event_log::dsl as event_log, experiment_groups::dsl as experiment_groups,
79: 77:             experiments::dsl as experiments,
80: 78:         },
81: 79:     },
82: 80:     logic::{evaluate_local_cohorts, evaluate_local_cohorts_skip_unresolved},
83: 81:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
84: 82: };
85: 83: 
86: 84: use crate::api::{
87: 85:     experiment_groups::helpers::{
88: 86:         add_members, create_system_generated_experiment_group,
89: 87:         detach_experiment_from_group, update_experiment_group_buckets,
90: 88:     },
91: 89:     experiments::{
92: 90:         helpers::{
93: 91:             fetch_and_validate_change_reason_with_function, fetch_webhook_by_event,
94: 92:             validate_control_overrides, validate_delete_experiment_variants,
95: 93:         },
96: 94:         types::StartedByChangeSet,
97: 95:     },
98: 96: };
99: 97: 
100: 98: use super::{
101: 99:     cac_api::{
102: 100:         construct_header_map, get_context_override,
103: 101:         process_cac_bulk_operation_http_response,
104: 102:     },
105: 103:     helpers::{
106: 104:         add_variant_dimension_to_ctx, check_variant_types,
107: 105:         check_variants_override_coverage, extract_override_keys, fetch_cac_config,
108: 106:         fetch_experiment, handle_experiment_group_membership, hash, validate_experiment,
109: 107:         validate_override_keys,
110: 108:     },
111: 109: };
112: 110: 
113: 111: pub fn endpoints(scope: Scope) -> Scope {
114: 112:     scope
115: 113:         .service(create_handler)
116: 114:         .service(conclude_handler)
117: 115:         .service(discard_handler)
118: 116:         .service(list_handler)
119: 117:         .service(get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_handler)
120: 118:         .service(get_handler)
121: 119:         .service(ramp_handler)
122: 120:         .service(update_handler)
123: 121:         .service(pause_handler)
124: 122:         .service(resume_handler)
125: 123: }
126: 124: 
127: 125: fn add_config_version_to_header(
128: 126:     config_version: &Option<String>,
129: 127:     resp_builder: &mut HttpResponseBuilder,
130: 128: ) {
131: 129:     if let Some(val) = config_version {
132: 130:         resp_builder.insert_header((AppHeader::XConfigVersion.to_string(), val.clone()));
133: 131:     }
134: 132: }
135: 133: 
136: 134: #[authorized]
137: 135: #[post("")]
138: 136: async fn create_handler(
139: 137:     workspace_context: WorkspaceContext,
140: 138:     state: Data<AppState>,
141: 139:     custom_headers: CustomHeaders,
142: 140:     req: Json<ExperimentCreateRequest>,
143: 141:     db_conn: DbConnection,
144: 142:     user: User,
145: 143: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
146: 144:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl::experiments;
147: 145:     let mut variants = req.variants.to_vec();
148: 146:     let DbConnection(mut conn) = db_conn;
149: 147:     let description = req.description.clone();
150: 148:     let change_reason = req.change_reason.clone();
151: 149: 
152: 150:     fetch_and_validate_change_reason_with_function(
153: 151:         &workspace_context,
154: 152:         &change_reason,
155: 153:         &state,
156: 154:     )
157: 155:     .await?;
158: 156: 
159: 157:     // Checking if experiment has exactly 1 control variant, and
160: 158:     // atleast 1 experimental variant
161: 159:     check_variant_types(&variants)?;
162: 160:     let unique_override_keys: Vec<String> =
163: 161:         extract_override_keys(&variants[0].overrides.clone().into_inner())
164: 162:             .into_iter()
165: 163:             .collect();
166: 164: 
167: 165:     let unique_lyx-core-lyx_core_lyx-core-lyx_core_ids_of_variants_from_req: HashSet<&str> =
168: 166:         HashSet::from_iter(variants.iter().map(|v| v.id.as_str()));
169: 167: 
170: 168:     if unique_lyx-core-lyx_core_lyx-core-lyx_core_ids_of_variants_from_req.len() != variants.len() {
171: 169:         return Err(bad_argument!(
172: 170:             "Variant lyx-core-lyx_core_lyx-core-lyx_core_ids are expected to be unique. Provide unqiue variant IDs"
173: 171:         ));
174: 172:     }
175: 173: 
176: 174:     // validating context
177: 175:     let exp_context = req.context.clone().into_inner();
178: 176:     let exp_context_id = hash(&Value::Object(exp_context.clone().into()));
179: 177: 
180: 178:     // Checking if all the variants are overriding the mentioned keys
181: 179:     let variant_overrides = variants
182: 180:         .iter()
183: 181:         .map(|variant| variant.overrides.clone().into_inner())
184: 182:         .collect::<Vec<Overrides>>();
185: 183: 
186: 184:     match req.experiment_type {
187: 185:         ExperimentType::Default => {
188: 186:             let are_valid_variants = check_variants_override_coverage(
189: 187:                 &variant_overrides,
190: 188:                 &unique_override_keys,
191: 189:             );
192: 190:             if !are_valid_variants {
193: 191:                 return Err(bad_argument!(
194: 192:                     "all variants should contain the keys mentioned in override_keys. Check if any of the following keys [{}] are missing from keys in your variants",
195: 193:                     unique_override_keys.join(",")
196: 194:                 ));
197: 195:             }
198: 196: 
199: 197:             // Validate control overrides against resolved config when auto-populate is enabled
200: 198:             if workspace_context.settings.auto_populate_control {
201: 199:                 let control_variant = variants
202: 200:                     .iter()
203: 201:                     .find(|v| v.variant_type == VariantType::CONTROL)
204: 202:                     .ok_or_else(|| {
205: 203:                         log::error!(
206: 204:                             "Control variant not found in existing experiment variants"
207: 205:                         );
208: 206:                         unexpected_error!(
209: 207:                             "Control variant not found in existing experiment variants"
210: 208:                         )
211: 209:                     })?;
212: 210: 
213: 211:                 validate_control_overrides(
214: 212:                     &control_variant.overrides,
215: 213:                     &exp_context,
216: 214:                     &workspace_context,
217: 215:                     &user,
218: 216:                     &state,
219: 217:                 )
220: 218:                 .await?;
221: 219:             }
222: 220: 
223: 221:             // validating experiment against other active experiments based on permission flags
224: 222:             let flags = &state.experimentation_flags;
225: 223:             let (valid, reason) = validate_experiment(
226: 224:                 &exp_context,
227: 225:                 &unique_override_keys,
228: 226:                 None,
229: 227:                 flags,
230: 228:                 &workspace_context.schema_name,
231: 229:                 &mut conn,
232: 230:             )?;
233: 231:             if !valid {
234: 232:                 return Err(bad_argument!(reason));
235: 233:             }
236: 234:         }
237: 235:         ExperimentType::DeleteOverrides => {
238: 236:             validate_delete_experiment_variants(
239: 237:                 &user,
240: 238:                 &state,
241: 239:                 &exp_context,
242: 240:                 &exp_context_id,
243: 241:                 &workspace_context,
244: 242:                 &variants,
245: 243:             )
246: 244:             .await?;
247: 245:         }
248: 246:     }
249: 247: 
250: 248:     // generating snowflake id for experiment
251: 249:     let experiment_id = generate_snowflake_id(&state)?;
252: 250: 
253: 251:     //create overrides in CAC, if successfull then create experiment in DB
254: 252:     let mut cac_operations: Vec<ContextAction> = Vec::new();
255: 253:     for variant in &mut variants {
256: 254:         let variant_id = experiment_id.to_string() + "-" + variant.id.as_ref();
257: 255: 
258: 256:         // updating variant.id to => experiment_id + variant.id
259: 257:         variant.id = variant_id.to_string();
260: 258: 
261: 259:         let updated_cacccontext =
262: 260:             add_variant_dimension_to_ctx(&exp_context, variant_id.to_string())?;
263: 261: 
264: 262:         let payload = PutRequest {
265: 263:             context: updated_cacccontext
266: 264:                 .as_object()
267: 265:                 .ok_or_else(|| unexpected_error!("Failed to convert context to object"))?
268: 266:                 .clone()
269: 267:                 .try_into()
270: 268:                 .map_err(|e: String| unexpected_error!(e))?,
271: 269:             r#override: variant.overrides.clone().into(),
272: 270:             description: Some(description.clone()),
273: 271:             change_reason: change_reason.clone(),
274: 272:         };
275: 273:         cac_operations.push(ContextAction::Put(payload));
276: 274:     }
277: 275: 
278: 276:     // creating variants' context in CAC
279: 277:     let http_lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
280: 278:     let url = state.cac_host.clone() + "/context/bulk-operations";
281: 279:     let user_str = serde_json::to_string(&user).map_err(|err| {
282: 280:         log::error!("Something went wrong, failed to stringify user data {err}");
283: 281:         unexpected_error!(
284: 282:             "Something went wrong, failed to stringify user data {}",
285: 283:             err
286: 284:         )
287: 285:     })?;
288: 286: 
289: 287:     let extra_headers = vec![
290: 288:         ("x-user", Some(user_str)),
291: 289:         ("x-config-tags", custom_headers.config_tags),
292: 290:     ]
293: 291:     .into_iter()
294: 292:     .filter_map(|(key, val)| val.map(|v| (key, v)))
295: 293:     .collect::<Vec<_>>();
296: 294: 
297: 295:     let headers_map = construct_header_map(
298: 296:         &workspace_context.workspace_id,
299: 297:         &workspace_context.organisation_id,
300: 298:         extra_headers,
301: 299:     )?;
302: 300: 
303: 301:     // Step 1: Perform the HTTP request and handle errors
304: 302:     let response = http_lyx-core-lyx_core_lyx-core-lyx_core_client
305: 303:         .put(&url)
306: 304:         .headers(headers_map.into())
307: 305:         .header(
308: 306:             header::AUTHORIZATION,
309: 307:             format!("Internal {}", state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token),
310: 308:         )
311: 309:         .json(&cac_operations)
312: 310:         .send()
313: 311:         .await;
314: 312: 
315: 313:     // directly return an error response if not a 200 response
316: 314:     let (resp_contexts, config_version_id) =
317: 315:         process_cac_bulk_operation_http_response(response).await?;
318: 316:     let created_contexts = resp_contexts
319: 317:         .into_iter()
320: 318:         .map(|item| match item {
321: 319:             ContextBulkResponse::Put(context) => Ok(context),
322: 320:             _ => Err(format!("Unexpected response item: {item:?}")),
323: 321:         })
324: 322:         .collect::<Result<Vec<_>, _>>()
325: 323:         .map_err(|err| {
326: 324:             log::error!(
327: 325:                 "Something went wrong, failed to parse bulk operations response {err}"
328: 326:             );
329: 327:             unexpected_error!("Something went wrong")
330: 328:         })?;
331: 329: 
332: 330:     for i in 0..created_contexts.len() {
333: 331:         let created_context = &created_contexts[i];
334: 332:         variants[i].context_id = Some(created_context.id.clone());
335: 333:         variants[i].override_id = Some(created_context.override_id.clone());
336: 334:     }
337: 335: 
338: 336:     let now = Utc::now();
339: 337:     // inserting experiment in db
340: 338:     let new_experiment = Experiment {
341: 339:         id: experiment_id,
342: 340:         created_by: user.get_email(),
343: 341:         created_at: now,
344: 342:         last_modified: now,
345: 343:         name: req.name.to_string(),
346: 344:         experiment_type: req.experiment_type,
347: 345:         override_keys: unique_override_keys.to_vec(),
348: 346:         traffic_percentage: TrafficPercentage::default(),
349: 347:         status: ExperimentStatusType::CREATED,
350: 348:         started_by: None,
351: 349:         started_at: None,
352: 350:         context: req.context.clone().into_inner(),
353: 351:         variants: Variants::new(variants),
354: 352:         last_modified_by: user.get_email(),
355: 353:         chosen_variant: None,
356: 354:         description,
357: 355:         change_reason,
358: 356:         metrics: req
359: 357:             .metrics
360: 358:             .clone()
361: 359:             .unwrap_or(workspace_context.settings.metrics.clone()),
362: 360:         experiment_group_id: req.experiment_group_id,
363: 361:     };
364: 362: 
365: 363:     let inserted_experiment: Experiment =
366: 364:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
367: 365:             let inserted_experiment = diesel::insert_into(experiments)
368: 366:                 .values(&new_experiment)
369: 367:                 .returning(Experiment::as_returning())
370: 368:                 .schema_name(&workspace_context.schema_name)
371: 369:                 .get_result(transaction_conn)?;
372: 370: 
373: 371:             if let Some(experiment_group_id) = &req.experiment_group_id {
374: 372:                 add_members(
375: 373:                     experiment_group_id,
376: 374:                     std::slice::from_ref(&inserted_experiment),
377: 375:                     ExpGroupMemberRequest {
378: 376:                         change_reason: ChangeReason::try_from(format!("Adding experiment {experiment_id} to the group, while creating the experiment.")).map_err(|e| unexpected_error!(e))?,
379: 377:                         member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: vec![experiment_id],
380: 378:                     },
381: 379:                     transaction_conn,
382: 380:                     &workspace_context.schema_name,
383: 381:                     &user,
384: 382:                 )?;
385: 383:             }
386: 384: 
387: 385:             Ok(inserted_experiment)
388: 386:         })?;
389: 387: 
390: 388:     let response = ExperimentResponse::from(inserted_experiment);
391: 389:     let webhook_status = if let Ok(webhook) = fetch_webhook_by_event(
392: 390:         &state,
393: 391:         &user,
394: 392:         &WebhookEvent::ExperimentCreated,
395: 393:         &workspace_context,
396: 394:     )
397: 395:     .await
398: 396:     {
399: 397:         execute_webhook_call(
400: 398:             &webhook,
401: 399:             &response,
402: 400:             &config_version_id,
403: 401:             &workspace_context,
404: 402:             WebhookEvent::ExperimentCreated,
405: 403:             &state,
406: 404:             &mut conn,
407: 405:         )
408: 406:         .await
409: 407:     } else {
410: 408:         true
411: 409:     };
412: 410: 
413: 411:     let mut http_resp = if webhook_status {
414: 412:         HttpResponse::Ok()
415: 413:     } else {
416: 414:         HttpResponse::build(
417: 415:             StatusCode::from_u16(512).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
418: 416:         )
419: 417:     };
420: 418:     add_config_version_to_header(&config_version_id, &mut http_resp);
421: 419:     Ok(http_resp.json(response))
422: 420: }
423: 421: 
424: 422: #[allow(clippy::too_many_arguments)]
425: 423: #[authorized]
426: 424: #[patch("/{experiment_id}/conclude")]
427: 425: async fn conclude_handler(
428: 426:     workspace_context: WorkspaceContext,
429: 427:     state: Data<AppState>,
430: 428:     path: web::Path<i64>,
431: 429:     custom_headers: CustomHeaders,
432: 430:     req: web::Json<ConcludeExperimentRequest>,
433: 431:     db_conn: DbConnection,
434: 432:     user: User,
435: 433: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
436: 434:     let DbConnection(mut conn) = db_conn;
437: 435: 
438: 436:     fetch_and_validate_change_reason_with_function(
439: 437:         &workspace_context,
440: 438:         &req.change_reason,
441: 439:         &state,
442: 440:     )
443: 441:     .await?;
444: 442: 
445: 443:     let (response, config_version_id) = conclude(
446: 444:         &state,
447: 445:         path.into_inner(),
448: 446:         custom_headers.config_tags,
449: 447:         req.into_inner(),
450: 448:         &mut conn,
451: 449:         &workspace_context,
452: 450:         &user,
453: 451:     )
454: 452:     .await?;
455: 453: 
456: 454:     let experiment_response = ExperimentResponse::from(response);
457: 455: 
458: 456:     let webhook_status = if let Ok(webhook) = fetch_webhook_by_event(
459: 457:         &state,
460: 458:         &user,
461: 459:         &WebhookEvent::ExperimentConcluded,
462: 460:         &workspace_context,
463: 461:     )
464: 462:     .await
465: 463:     {
466: 464:         execute_webhook_call(
467: 465:             &webhook,
468: 466:             &experiment_response,
469: 467:             &config_version_id,
470: 468:             &workspace_context,
471: 469:             WebhookEvent::ExperimentConcluded,
472: 470:             &state,
473: 471:             &mut conn,
474: 472:         )
475: 473:         .await
476: 474:     } else {
477: 475:         true
478: 476:     };
479: 477: 
480: 478:     let mut http_resp = if webhook_status {
481: 479:         HttpResponse::Ok()
482: 480:     } else {
483: 481:         HttpResponse::build(
484: 482:             StatusCode::from_u16(512).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
485: 483:         )
486: 484:     };
487: 485: 
488: 486:     add_config_version_to_header(&config_version_id, &mut http_resp);
489: 487:     Ok(http_resp.json(experiment_response))
490: 488: }
491: 489: 
492: 490: pub async fn conclude(
493: 491:     state: &Data<AppState>,
494: 492:     experiment_id: i64,
495: 493:     config_tags: Option<String>,
496: 494:     req: ConcludeExperimentRequest,
497: 495:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
498: 496:     workspace_context: &WorkspaceContext,
499: 497:     user: &User,
500: 498: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<(Experiment, Option<String>)> {
501: 499:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl;
502: 500: 
503: 501:     let change_reason = req.change_reason.clone();
504: 502: 
505: 503:     let winner_variant_id: String = req.chosen_variant.to_owned();
506: 504: 
507: 505:     let experiment: Experiment = dsl::experiments
508: 506:         .find(experiment_id)
509: 507:         .schema_name(&workspace_context.schema_name)
510: 508:         .get_result::<Experiment>(conn)?;
511: 509: 
512: 510:     let exp_context_id = hash(&Value::Object(experiment.context.clone().into()));
513: 511:     let description = match req.description.clone() {
514: 512:         Some(desc) => desc,
515: 513:         None => experiment.description.clone(),
516: 514:     };
517: 515:     if !experiment.status.concludable() {
518: 516:         return Err(bad_argument!(
519: 517:             "experiment with id {} is {}, and cannot be concluded",
520: 518:             experiment_id,
521: 519:             experiment.status
522: 520:         ));
523: 521:     }
524: 522: 
525: 523:     let mut operations: Vec<ContextAction> = vec![];
526: 524: 
527: 525:     let mut is_valid_winner_variant = false;
528: 526:     for variant in experiment.variants.clone().into_inner() {
529: 527:         let context_id = variant.context_id.ok_or_else(|| {
530: 528:             log::error!("context id not available for variant {:?}", variant.id);
531: 529:             unexpected_error!("Something went wrong, failed to conclude experiment")
532: 530:         })?;
533: 531: 
534: 532:         if variant.id != winner_variant_id {
535: 533:             operations.push(ContextAction::Delete(context_id));
536: 534:             continue;
537: 535:         }
538: 536: 
539: 537:         if !experiment.context.is_empty() {
540: 538:             match (experiment.experiment_type, variant.variant_type) {
541: 539:                 (ExperimentType::Default, _) => {
542: 540:                     let context_move_req = MoveRequest {
543: 541:                         context: experiment
544: 542:                             .context
545: 543:                             .clone()
546: 544:                             .try_into()
547: 545:                             .map_err(|e: String| unexpected_error!(e))?,
548: 546:                         description: Some(description.clone()),
549: 547:                         change_reason: change_reason.clone(),
550: 548:                     };
551: 549:                     operations.push(ContextAction::Move {
552: 550:                         id: context_id,
553: 551:                         request: context_move_req,
554: 552:                     });
555: 553:                 }
556: 554:                 (ExperimentType::DeleteOverrides, VariantType::CONTROL) => {
557: 555:                     operations.push(ContextAction::Delete(context_id));
558: 556:                 }
559: 557:                 (ExperimentType::DeleteOverrides, _) => {
560: 558:                     let current_context = get_context_override(
561: 559:                         user,
562: 560:                         state,
563: 561:                         workspace_context,
564: 562:                         exp_context_id.clone(),
565: 563:                     )
566: 564:                     .await?;
567: 565: 
568: 566:                     let mut context_override: Map<String, Value> =
569: 567:                         current_context.override_.into();
570: 568:                     for key in variant.overrides.into_inner().keys() {
571: 569:                         context_override.remove(key);
572: 570:                     }
573: 571: 
574: 572:                     if context_override.is_empty() {
575: 573:                         operations.push(ContextAction::Delete(exp_context_id.clone()));
576: 574:                     } else {
577: 575:                         let payload = UpdateRequest {
578: 576:                             context: Identifier::Id(exp_context_id.clone()),
579: 577:                             override_: Cac::<Overrides>::try_from(context_override).map_err(|err| {
580: 578:                                 log::error!("failed to convert variant overrides to cac override {err}");
581: 579:                                 bad_argument!("failed to convert variant overrides to cac override")
582: 580:                             })?,
583: 581:                             description: None,
584: 582:                             change_reason: change_reason.clone(),
585: 583:                         };
586: 584:                         operations.push(ContextAction::Replace(payload));
587: 585:                     }
588: 586:                     operations.push(ContextAction::Delete(context_id));
589: 587:                 }
590: 588:             }
591: 589:         } else {
592: 590:             let user_str = serde_json::to_string(&user).map_err(|err| {
593: 591:                 log::error!("Something went wrong, failed to stringify user data {err}");
594: 592:                 unexpected_error!(
595: 593:                     "Something went wrong, failed to stringify user data {}",
596: 594:                     err
597: 595:                 )
598: 596:             })?;
599: 597: 
600: 598:             for (key, val) in variant.overrides.into_inner() {
601: 599:                 let update_request = DefaultConfigUpdateRequest {
602: 600:                     value: Some(val),
603: 601:                     change_reason: change_reason.clone(),
604: 602:                     schema: None,
605: 603:                     value_validation_function_name: None,
606: 604:                     value_compute_function_name: None,
607: 605:                     description: None,
608: 606:                 };
609: 607: 
610: 608:                 let url = format!("{}/default-config/{}", state.cac_host, key);
611: 609: 
612: 610:                 let headers = construct_request_headers(&[
613: 611:                     ("x-tenant", &workspace_context.workspace_id),
614: 612:                     (
615: 613:                         "Authorization",
616: 614:                         &format!("Internal {}", state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token),
617: 615:                     ),
618: 616:                     ("x-user", user_str.as_str()),
619: 617:                     ("x-org-id", &workspace_context.organisation_id),
620: 618:                 ])
621: 619:                 .map_err(|err| unexpected_error!(err))?;
622: 620: 
623: 621:                 let _ =
624: 622:                     request::<_, Value>(url, Method::PUT, Some(update_request), headers)
625: 623:                         .await
626: 624:                         .map_err(|err| unexpected_error!(err))?;
627: 625:             }
628: 626:             operations.push(ContextAction::Delete(context_id));
629: 627:         }
630: 628: 
631: 629:         is_valid_winner_variant = true;
632: 630:     }
633: 631: 
634: 632:     if !is_valid_winner_variant {
635: 633:         return Err(bad_argument!(
636: 634:             "winner variant not found. A wrong variant id may have been sent, check and try again"
637: 635:         ));
638: 636:     }
639: 637: 
640: 638:     // calling CAC bulk api with operations as payload
641: 639:     let http_lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
642: 640:     let url = state.cac_host.clone() + "/context/bulk-operations";
643: 641:     let user_str = serde_json::to_string(&user).map_err(|err| {
644: 642:         log::error!("Something went wrong, failed to stringify user data {err}");
645: 643:         unexpected_error!(
646: 644:             "Something went wrong, failed to stringify user data {}",
647: 645:             err
648: 646:         )
649: 647:     })?;
650: 648:     let extra_headers = vec![("x-user", Some(user_str)), ("x-config-tags", config_tags)]
651: 649:         .into_iter()
652: 650:         .filter_map(|(key, val)| val.map(|v| (key, v)))
653: 651:         .collect::<Vec<_>>();
654: 652: 
655: 653:     let headers_map = construct_header_map(
656: 654:         &workspace_context.workspace_id,
657: 655:         &workspace_context.organisation_id,
658: 656:         extra_headers,
659: 657:     )?;
660: 658: 
661: 659:     let response = http_lyx-core-lyx_core_lyx-core-lyx_core_client
662: 660:         .put(&url)
663: 661:         .headers(headers_map.into())
664: 662:         .header(
665: 663:             header::AUTHORIZATION,
666: 664:             format!("Internal {}", state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token),
667: 665:         )
668: 666:         .json(&operations)
669: 667:         .send()
670: 668:         .await;
671: 669: 
672: 670:     let (_, config_version_id) =
673: 671:         process_cac_bulk_operation_http_response(response).await?;
674: 672: 
675: 673:     let updated_experiment =
676: 674:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
677: 675:             if let Some(experiment_group_id) = experiment.experiment_group_id {
678: 676:                 detach_experiment_from_group(
679: 677:                     &experiment,
680: 678:                     experiment_group_id,
681: 679:                     transaction_conn,
682: 680:                     workspace_context,
683: 681:                     user,
684: 682:                 )?;
685: 683:             }
686: 684: 
687: 685:             let updated_experiment = diesel::update(dsl::experiments)
688: 686:                 .filter(dsl::id.eq(experiment_id))
689: 687:                 .set((
690: 688:                     dsl::status.eq(ExperimentStatusType::CONCLUDED),
691: 689:                     dsl::last_modified.eq(Utc::now()),
692: 690:                     dsl::last_modified_by.eq(user.get_email()),
693: 691:                     dsl::chosen_variant.eq(Some(winner_variant_id)),
694: 692:                     dsl::change_reason.eq(req.change_reason),
695: 693:                     dsl::experiment_group_id.eq(None as Option<i64>),
696: 694:                 ))
697: 695:                 .returning(Experiment::as_returning())
698: 696:                 .schema_name(&workspace_context.schema_name)
699: 697:                 .get_result::<Experiment>(transaction_conn)?;
700: 698:             Ok(updated_experiment)
701: 699:         })?;
702: 700: 
703: 701:     Ok((updated_experiment, config_version_id))
704: 702: }
705: 703: 
706: 704: #[allow(clippy::too_many_arguments)]
707: 705: #[authorized]
708: 706: #[patch("/{experiment_id}/discard")]
709: 707: async fn discard_handler(
710: 708:     workspace_context: WorkspaceContext,
711: 709:     state: Data<AppState>,
712: 710:     path: Path<i64>,
713: 711:     custom_headers: CustomHeaders,
714: 712:     req: Json<ExperimentStateChangeRequest>,
715: 713:     db_conn: DbConnection,
716: 714:     user: User,
717: 715: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
718: 716:     let DbConnection(mut conn) = db_conn;
719: 717: 
720: 718:     fetch_and_validate_change_reason_with_function(
721: 719:         &workspace_context,
722: 720:         &req.change_reason,
723: 721:         &state,
724: 722:     )
725: 723:     .await?;
726: 724: 
727: 725:     let (response, config_version_id) = discard(
728: 726:         &state,
729: 727:         path.into_inner(),
730: 728:         custom_headers.config_tags,
731: 729:         req.into_inner(),
732: 730:         &mut conn,
733: 731:         &workspace_context,
734: 732:         &user,
735: 733:     )
736: 734:     .await?;
737: 735: 
738: 736:     let experiment_response = ExperimentResponse::from(response);
739: 737: 
740: 738:     let webhook_status = if let Ok(webhook) = fetch_webhook_by_event(
741: 739:         &state,
742: 740:         &user,
743: 741:         &WebhookEvent::ExperimentDiscarded,
744: 742:         &workspace_context,
745: 743:     )
746: 744:     .await
747: 745:     {
748: 746:         execute_webhook_call(
749: 747:             &webhook,
750: 748:             &experiment_response,
751: 749:             &config_version_id,
752: 750:             &workspace_context,
753: 751:             WebhookEvent::ExperimentDiscarded,
754: 752:             &state,
755: 753:             &mut conn,
756: 754:         )
757: 755:         .await
758: 756:     } else {
759: 757:         true
760: 758:     };
761: 759: 
762: 760:     let mut http_resp = if webhook_status {
763: 761:         HttpResponse::Ok()
764: 762:     } else {
765: 763:         HttpResponse::build(
766: 764:             StatusCode::from_u16(512).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
767: 765:         )
768: 766:     };
769: 767:     add_config_version_to_header(&config_version_id, &mut http_resp);
770: 768:     Ok(http_resp.json(experiment_response))
771: 769: }
772: 770: 
773: 771: pub async fn discard(
774: 772:     state: &Data<AppState>,
775: 773:     experiment_id: i64,
776: 774:     config_tags: Option<String>,
777: 775:     req: ExperimentStateChangeRequest,
778: 776:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
779: 777:     workspace_context: &WorkspaceContext,
780: 778:     user: &User,
781: 779: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<(Experiment, Option<String>)> {
782: 780:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl;
783: 781: 
784: 782:     let experiment: Experiment = dsl::experiments
785: 783:         .find(experiment_id)
786: 784:         .schema_name(&workspace_context.schema_name)
787: 785:         .get_result::<Experiment>(conn)?;
788: 786: 
789: 787:     if !experiment.status.discardable() {
790: 788:         return Err(bad_argument!(
791: 789:             "experiment with id {} cannot be discarded",
792: 790:             experiment_id
793: 791:         ));
794: 792:     }
795: 793: 
796: 794:     let operations: Vec<ContextAction> = experiment
797: 795:         .variants
798: 796:         .clone()
799: 797:         .into_inner()
800: 798:         .into_iter()
801: 799:         .map(|variant| {
802: 800:             variant
803: 801:                 .context_id
804: 802:                 .map(ContextAction::Delete)
805: 803:                 .ok_or_else(|| {
806: 804:                     log::error!("context id not available for variant {:?}", variant.id);
807: 805:                     unexpected_error!(
808: 806:                         "Something went wrong, failed to discard experiment"
809: 807:                     )
810: 808:                 })
811: 809:         })
812: 810:         .collect::<lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<ContextAction>>>()?;
813: 811: 
814: 812:     // calling CAC bulk api with operations as payload
815: 813:     let http_lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
816: 814:     let url = state.cac_host.clone() + "/context/bulk-operations";
817: 815:     let user_str = serde_json::to_string(&user).map_err(|err| {
818: 816:         log::error!("Something went wrong, failed to stringify user data {err}");
819: 817:         unexpected_error!(
820: 818:             "Something went wrong, failed to stringify user data {}",
821: 819:             err
822: 820:         )
823: 821:     })?;
824: 822: 
825: 823:     let extra_headers = vec![("x-user", Some(user_str)), ("x-config-tags", config_tags)]
826: 824:         .into_iter()
827: 825:         .filter_map(|(key, val)| val.map(|v| (key, v)))
828: 826:         .collect::<Vec<_>>();
829: 827: 
830: 828:     let headers_map = construct_header_map(
831: 829:         &workspace_context.workspace_id,
832: 830:         &workspace_context.organisation_id,
833: 831:         extra_headers,
834: 832:     )?;
835: 833: 
836: 834:     let response = http_lyx-core-lyx_core_lyx-core-lyx_core_client
837: 835:         .put(&url)
838: 836:         .headers(headers_map.into())
839: 837:         .header(
840: 838:             header::AUTHORIZATION,
841: 839:             format!("Internal {}", state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token),
842: 840:         )
843: 841:         .json(&operations)
844: 842:         .send()
845: 843:         .await;
846: 844: 
847: 845:     let (_, config_version_id) =
848: 846:         process_cac_bulk_operation_http_response(response).await?;
849: 847: 
850: 848:     let updated_experiment =
851: 849:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
852: 850:             if let Some(experiment_group_id) = experiment.experiment_group_id {
853: 851:                 detach_experiment_from_group(
854: 852:                     &experiment,
855: 853:                     experiment_group_id,
856: 854:                     transaction_conn,
857: 855:                     workspace_context,
858: 856:                     user,
859: 857:                 )?;
860: 858:             }
861: 859: 
862: 860:             // updating experiment status in db
863: 861:             let updated_experiment = diesel::update(dsl::experiments)
864: 862:                 .filter(dsl::id.eq(experiment_id))
865: 863:                 .set((
866: 864:                     req,
867: 865:                     dsl::status.eq(ExperimentStatusType::DISCARDED),
868: 866:                     dsl::last_modified.eq(Utc::now()),
869: 867:                     dsl::last_modified_by.eq(user.get_email()),
870: 868:                     dsl::chosen_variant.eq(None as Option<String>),
871: 869:                     dsl::experiment_group_id.eq(None as Option<i64>),
872: 870:                 ))
873: 871:                 .returning(Experiment::as_returning())
874: 872:                 .schema_name(&workspace_context.schema_name)
875: 873:                 .get_result::<Experiment>(transaction_conn)?;
876: 874: 
877: 875:             Ok(updated_experiment)
878: 876:         })?;
879: 877: 
880: 878:     Ok((updated_experiment, config_version_id))
881: 879: }
882: 880: 
883: 881: pub async fn get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_helper(
884: 882:     db_conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
885: 883:     context: Map<String, Value>,
886: 884:     dimensions_info: &HashMap<String, DimensionInfo>,
887: 885:     identifier: String,
888: 886:     workspace_context: &WorkspaceContext,
889: 887: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<(Vec<String>, HashMap<String, ExperimentResponse>)> {
890: 888:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl;
891: 889: 
892: 890:     let experiment_groups = experiment_groups::experiment_groups
893: 891:         .schema_name(&workspace_context.schema_name)
894: 892:         .load::<ExperimentGroup>(db_conn)?;
895: 893: 
896: 894:     let context = evaluate_local_cohorts(dimensions_info, &context);
897: 895: 
898: 896:     let buckets =
899: 897:         get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_buckets_from_group(&experiment_groups, &context, &identifier);
900: 898: 
901: 899:     let exp_lyx-core-lyx_core_lyx-core-lyx_core_ids = buckets
902: 900:         .iter()
903: 901:         .filter_map(|(_, bucket)| bucket.experiment_id.parse::<i64>().ok())
904: 902:         .collect::<HashSet<_>>();
905: 903: 
906: 904:     let exps = dsl::experiments
907: 905:         .filter(
908: 906:             dsl::id
909: 907:                 .eq_any(exp_lyx-core-lyx_core_lyx-core-lyx_core_ids)
910: 908:                 .and(dsl::status.eq(ExperimentStatusType::INPROGRESS)),
911: 909:         )
912: 910:         .schema_name(&workspace_context.schema_name)
913: 911:         .load::<Experiment>(db_conn)?
914: 912:         .into_iter()
915: 913:         .map(|exp| {
916: 914:             let exp_response = ExperimentResponse::from(exp);
917: 915:             let id = exp_response.id.clone();
918: 916:             (id, exp_response)
919: 917:         })
920: 918:         .collect::<HashMap<String, ExperimentResponse>>();
921: 919: 
922: 920:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants =
923: 921:         get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_from_group_response(&exps, &context, &buckets);
924: 922: 
925: 923:     Ok((lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants, exps))
926: 924: }
927: 925: 
928: 926: #[authorized]
929: 927: #[routes]
930: 928: #[get("/lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable-variants")]
931: 929: #[post("/lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable-variants")]
932: 930: async fn get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_handler(
933: 931:     workspace_context: WorkspaceContext,
934: 932:     req: HttpRequest,
935: 933:     db_conn: DbConnection,
936: 934:     req_body: Option<Json<ApplicableVariantsRequest>>,
937: 935:     query_data: Option<Query<ApplicableVariantsQuery>>,
938: 936:     dimension_params: Option<DimensionQuery<QueryMap>>,
939: 937: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Either<Json<Vec<Variant>>, Json<ListResponse<Variant>>>> {
940: 938:     let DbConnection(mut conn) = db_conn;
941: 939:     let (context, identifier) =
942: 940:         match (req.method().clone(), query_data, dimension_params, req_body) {
943: 941:             (
944: 942:                 actix_web::http::Method::GET,
945: 943:                 Some(query_data),
946: 944:                 Some(dimension_params),
947: 945:                 _,
948: 946:             ) => (
949: 947:                 dimension_params.into_inner().deref().clone(),
950: 948:                 query_data.into_inner().identifier,
951: 949:             ),
952: 950:             (actix_web::http::Method::POST, _, _, Some(req_body)) => {
953: 951:                 let req_body = req_body.into_inner();
954: 952:                 (req_body.context, req_body.identifier)
955: 953:             }
956: 954:             _ => {
957: 955:                 return Err(bad_argument!("Invalid input for the method"));
958: 956:             }
959: 957:         };
960: 958: 
961: 959:     let dimensions_info =
962: 960:         fetch_dimensions_info_map(&mut conn, &workspace_context.schema_name)?;
963: 961:     let (lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants, exps) = get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants_helper(
964: 962:         &mut conn,
965: 963:         context,
966: 964:         &dimensions_info,
967: 965:         identifier,
968: 966:         &workspace_context,
969: 967:     )
970: 968:     .await?;
971: 969: 
972: 970:     let variants = exps
973: 971:         .into_iter()
974: 972:         .filter_map(|(_, experiment)| {
975: 973:             experiment
976: 974:                 .variants
977: 975:                 .into_inner()
978: 976:                 .into_iter()
979: 977:                 .find(|variant| lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants.contains(&variant.id))
980: 978:         })
981: 979:         .collect::<Vec<_>>();
982: 980: 
983: 981:     match *req.method() {
984: 982:         actix_web::http::Method::POST => {
985: 983:             Ok(Either::Right(Json(ListResponse::new(variants))))
986: 984:         }
987: 985:         _ => Ok(Either::Left(Json(variants))),
988: 986:     }
989: 987: }
990: 988: 
991: 989: #[authorized]
992: 990: #[get("")]
993: 991: async fn list_handler(
994: 992:     workspace_context: WorkspaceContext,
995: 993:     req: HttpRequest,
996: 994:     pagination_params: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<PaginationParams>,
997: 995:     filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ExperimentListFilters>,
998: 996:     dimension_params: DimensionQuery<QueryMap>,
999: 997:     db_conn: DbConnection,
1000: 998: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
1001: 999:     let DbConnection(mut conn) = db_conn;
1002: 1000: 
1003: 1001:     let max_event_timestamp: Option<DateTime<Utc>> = event_log::event_log
1004: 1002:         .filter(event_log::table_name.eq("experiments"))
1005: 1003:         .select(diesel::dsl::max(event_log::timestamp))
1006: 1004:         .schema_name(&workspace_context.schema_name)
1007: 1005:         .first(&mut conn)?;
1008: 1006: 
1009: 1007:     let last_modified = req
1010: 1008:         .headers()
1011: 1009:         .get("If-Modified-Since")
1012: 1010:         .and_then(|header_val| header_val.to_str().ok())
1013: 1011:         .and_then(|header_str| {
1014: 1012:             DateTime::parse_from_rfc2822(header_str)
1015: 1013:                 .map(|datetime| datetime.with_timezone(&Utc))
1016: 1014:                 .ok()
1017: 1015:         });
1018: 1016: 
1019: 1017:     if max_event_timestamp.is_some() && max_event_timestamp < last_modified {
1020: 1018:         return Ok(HttpResponse::NotModified().finish());
1021: 1019:     };
1022: 1020: 
1023: 1021:     let dimension_params = dimension_params.into_inner();
1024: 1022: 
1025: 1023:     let query_builder = |filters: &ExperimentListFilters| {
1026: 1024:         let mut builder = experiments::experiments
1027: 1025:             .schema_name(&workspace_context.schema_name)
1028: 1026:             .into_boxed();
1029: 1027:         if let Some(ref states) = filters.status {
1030: 1028:             builder = builder.filter(experiments::status.eq_any(states.0.clone()));
1031: 1029:         }
1032: 1030:         if let Some(ref experiment_name) = filters.experiment_name {
1033: 1031:             builder =
1034: 1032:                 builder.filter(experiments::name.like(format!("%{}%", experiment_name)));
1035: 1033:         }
1036: 1034:         if let Some(ref created_by) = filters.created_by {
1037: 1035:             builder =
1038: 1036:                 builder.filter(experiments::created_by.eq_any(created_by.0.clone()));
1039: 1037:         }
1040: 1038:         if let Some(experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids) = filters.experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.clone() {
1041: 1039:             let experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: HashSet<i64> = experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids
1042: 1040:                 .0
1043: 1041:                 .iter()
1044: 1042:                 .filter_map(|i| i.parse::<i64>().ok())
1045: 1043:                 .collect();
1046: 1044:             builder = builder.filter(experiments::id.eq_any(experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids));
1047: 1045:         }
1048: 1046:         if let Some(experiment_group_lyx-core-lyx_core_lyx-core-lyx_core_ids) = filters.experiment_group_lyx-core-lyx_core_lyx-core-lyx_core_ids.clone() {
1049: 1047:             let experiment_group_lyx-core-lyx_core_lyx-core-lyx_core_ids: HashSet<i64> = experiment_group_lyx-core-lyx_core_lyx-core-lyx_core_ids
1050: 1048:                 .0
1051: 1049:                 .iter()
1052: 1050:                 .filter_map(|i| i.parse::<i64>().ok())
1053: 1051:                 .collect();
1054: 1052:             builder = builder
1055: 1053:                 .filter(experiments::experiment_group_id.eq_any(experiment_group_lyx-core-lyx_core_lyx-core-lyx_core_ids));
1056: 1054:         }
1057: 1055:         if let Some(from_data) = filters.from_date {
1058: 1056:             builder = builder.filter(experiments::last_modified.ge(from_data));
1059: 1057:         }
1060: 1058:         if let Some(to_date) = filters.to_date {
1061: 1059:             builder = builder.filter(experiments::last_modified.le(to_date));
1062: 1060:         }
1063: 1061: 
1064: 1062:         builder
1065: 1063:     };
1066: 1064: 
1067: 1065:     let filters = filters.into_inner();
1068: 1066:     let base_query = query_builder(&filters);
1069: 1067: 
1070: 1068:     let sort_by = filters.sort_by.unwrap_or(SortBy::Desc);
1071: 1069:     let sort_on = filters.sort_on.unwrap_or_default();
1072: 1070: 
1073: 1071:     #[rustfmt::skip]
1074: 1072:     let base_query = match (sort_on, sort_by) {
1075: 1073:         (ExperimentSortOn::LastModifiedAt, SortBy::Desc) => base_query.order(experiments::last_modified.desc()),
1076: 1074:         (ExperimentSortOn::LastModifiedAt, SortBy::Asc)  => base_query.order(experiments::last_modified.asc()),
1077: 1075:         (ExperimentSortOn::CreatedAt, SortBy::Desc)      => base_query.order(experiments::created_at.desc()),
1078: 1076:         (ExperimentSortOn::CreatedAt, SortBy::Asc)       => base_query.order(experiments::created_at.asc()),
1079: 1077:     };
1080: 1078: 
1081: 1079:     let pagination_params = pagination_params.into_inner();
1082: 1080:     let show_all = pagination_params.all.unwrap_or_default();
1083: 1081:     let limit = pagination_params.count.unwrap_or(10);
1084: 1082:     let offset = (pagination_params.page.unwrap_or(1) - 1) * limit;
1085: 1083: 
1086: 1084:     let perform_in_memory_filter = !dimension_params.is_empty()
1087: 1085:         || filters.global_experiments_only.unwrap_or_default();
1088: 1086: 
1089: 1087:     let paginated_response = if perform_in_memory_filter {
1090: 1088:         let all_experiments: Vec<Experiment> = base_query.load(&mut conn)?;
1091: 1089:         let filtered_experiments = if filters.global_experiments_only.unwrap_or_default()
1092: 1090:         {
1093: 1091:             all_experiments
1094: 1092:                 .into_iter()
1095: 1093:                 .filter(|experiment| experiment.context.is_empty())
1096: 1094:                 .collect()
1097: 1095:         } else {
1098: 1096:             let dimensions_info =
1099: 1097:                 fetch_dimensions_info_map(&mut conn, &workspace_context.schema_name)?;
1100: 1098:             let dimension_params = evaluate_local_cohorts_skip_unresolved(
1101: 1099:                 &dimensions_info,
1102: 1100:                 &dimension_params,
1103: 1101:             );
1104: 1102:             let dimension_keys = dimension_params.keys().cloned().collect::<Vec<_>>();
1105: 1103: 
1106: 1104:             let filter_fn = match filters.dimension_match_strategy.unwrap_or_default() {
1107: 1105:                 DimensionMatchStrategy::Exact => Experiment::filter_exact_match,
1108: 1106:                 DimensionMatchStrategy::Subset => Experiment::filter_by_eval,
1109: 1107:             };
1110: 1108: 
1111: 1109:             let dimension_filtered_experiments =
1112: 1110:                 filter_fn(all_experiments, &dimension_params);
1113: 1111: 
1114: 1112:             Experiment::filter_by_dimension(
1115: 1113:                 dimension_filtered_experiments,
1116: 1114:                 &dimension_keys,
1117: 1115:             )
1118: 1116:         };
1119: 1117: 
1120: 1118:         let experiments = filtered_experiments
1121: 1119:             .into_iter()
1122: 1120:             .map(ExperimentResponse::from)
1123: 1121:             .collect::<Vec<_>>();
1124: 1122: 
1125: 1123:         if show_all {
1126: 1124:             PaginatedResponse::all(experiments)
1127: 1125:         } else {
1128: 1126:             let total_items = experiments.len();
1129: 1127:             let start = offset as usize;
1130: 1128:             let end = min((offset + limit) as usize, total_items);
1131: 1129:             let data = experiments
1132: 1130:                 .get(start..end)
1133: 1131:                 .map(|slice| slice.to_vec())
1134: 1132:                 .unwrap_or_default();
1135: 1133: 
1136: 1134:             PaginatedResponse {
1137: 1135:                 total_pages: (total_items as f64 / limit as f64).ceil() as i64,
1138: 1136:                 total_items: total_items as i64,
1139: 1137:                 data,
1140: 1138:             }
1141: 1139:         }
1142: 1140:     } else if show_all {
1143: 1141:         let result = base_query.load::<Experiment>(&mut conn)?;
1144: 1142:         PaginatedResponse::all(result.into_iter().map(ExperimentResponse::from).collect())
1145: 1143:     } else {
1146: 1144:         let count_query = query_builder(&filters);
1147: 1145:         let number_of_experiments = count_query.count().get_result(&mut conn)?;
1148: 1146:         let query = base_query.limit(limit).offset(offset);
1149: 1147:         let experiment_list = query.load::<Experiment>(&mut conn)?;
1150: 1148: 
1151: 1149:         PaginatedResponse {
1152: 1150:             total_pages: (number_of_experiments as f64 / limit as f64).ceil() as i64,
1153: 1151:             total_items: number_of_experiments,
1154: 1152:             data: experiment_list
1155: 1153:                 .into_iter()
1156: 1154:                 .map(ExperimentResponse::from)
1157: 1155:                 .collect(),
1158: 1156:         }
1159: 1157:     };
1160: 1158: 
1161: 1159:     Ok(HttpResponse::Ok().json(paginated_response))
1162: 1160: }
1163: 1161: 
1164: 1162: #[authorized]
1165: 1163: #[get("/{id}")]
1166: 1164: async fn get_handler(
1167: 1165:     workspace_context: WorkspaceContext,
1168: 1166:     params: web::Path<i64>,
1169: 1167:     db_conn: DbConnection,
1170: 1168: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentResponse>> {
1171: 1169:     let DbConnection(mut conn) = db_conn;
1172: 1170:     let response = fetch_experiment(
1173: 1171:         &params.into_inner(),
1174: 1172:         &mut conn,
1175: 1173:         &workspace_context.schema_name,
1176: 1174:     )?;
1177: 1175:     Ok(Json(ExperimentResponse::from(response)))
1178: 1176: }
1179: 1177: 
1180: 1178: pub fn user_allowed_to_ramp(
1181: 1179:     experiment: &Experiment,
1182: 1180:     user: &User,
1183: 1181:     allow_experiment_self_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approval: bool,
1184: 1182: ) -> bool {
1185: 1183:     allow_experiment_self_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approval
1186: 1184:         || !(experiment.status == ExperimentStatusType::CREATED
1187: 1185:             && experiment.created_by == user.get_email())
1188: 1186: }
1189: 1187: 
1190: 1188: #[authorized]
1191: 1189: #[patch("/{id}/ramp")]
1192: 1190: async fn ramp_handler(
1193: 1191:     workspace_context: WorkspaceContext,
1194: 1192:     state: Data<AppState>,
1195: 1193:     params: web::Path<i64>,
1196: 1194:     req: web::Json<RampRequest>,
1197: 1195:     db_conn: DbConnection,
1198: 1196:     user: User,
1199: 1197: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
1200: 1198:     let DbConnection(mut conn) = db_conn;
1201: 1199:     let exp_id = params.into_inner();
1202: 1200:     let change_reason = req.change_reason.clone();
1203: 1201: 
1204: 1202:     fetch_and_validate_change_reason_with_function(
1205: 1203:         &workspace_context,
1206: 1204:         &change_reason,
1207: 1205:         &state,
1208: 1206:     )
1209: 1207:     .await?;
1210: 1208: 
1211: 1209:     let experiment: Experiment = experiments::experiments
1212: 1210:         .find(exp_id)
1213: 1211:         .schema_name(&workspace_context.schema_name)
1214: 1212:         .get_result::<Experiment>(&mut conn)?;
1215: 1213: 
1216: 1214:     if !experiment.status.active() {
1217: 1215:         return Err(bad_argument!(
1218: 1216:             "Experiment is not active, cannot ramp a concluded experiment"
1219: 1217:         ));
1220: 1218:     }
1221: 1219: 
1222: 1220:     if !user_allowed_to_ramp(
1223: 1221:         &experiment,
1224: 1222:         &user,
1225: 1223:         workspace_context.settings.allow_experiment_self_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approval,
1226: 1224:     ) {
1227: 1225:         return Err(bad_argument!(
1228: 1226:             "Experiment creator is not allowed to start experiment, if this is not intended, please change the workspace settings to allow self-lyx-platform-lyx_platform_lyx-platform-lyx_platform_approval"
1229: 1227:         ));
1230: 1228:     }
1231: 1229: 
1232: 1230:     let experiment_variants = experiment.variants.clone().into_inner();
1233: 1231: 
1234: 1232:     match experiment.experiment_type {
1235: 1233:         ExperimentType::Default => {
1236: 1234:             // Validate control overrides against resolved config when auto-populate is enabled and experiment is in CREATED state
1237: 1235:             if workspace_context.settings.auto_populate_control
1238: 1236:                 && experiment.status == ExperimentStatusType::CREATED
1239: 1237:             {
1240: 1238:                 let control_variant = experiment_variants
1241: 1239:                     .iter()
1242: 1240:                     .find(|v| v.variant_type == VariantType::CONTROL)
1243: 1241:                     .ok_or_else(|| {
1244: 1242:                         log::error!(
1245: 1243:                             "Error finding control variant in the experiment variants"
1246: 1244:                         );
1247: 1245:                         unexpected_error!(
1248: 1246:                             "Error finding control variant in the experiment variants"
1249: 1247:                         )
1250: 1248:                     })?;
1251: 1249: 
1252: 1250:                 validate_control_overrides(
1253: 1251:                     &control_variant.overrides,
1254: 1252:                     &experiment.context,
1255: 1253:                     &workspace_context,
1256: 1254:                     &user,
1257: 1255:                     &state,
1258: 1256:                 )
1259: 1257:                 .await?;
1260: 1258:             }
1261: 1259:         }
1262: 1260:         ExperimentType::DeleteOverrides => {
1263: 1261:             validate_delete_experiment_variants(
1264: 1262:                 &user,
1265: 1263:                 &state,
1266: 1264:                 &experiment.context,
1267: 1265:                 &hash(&Value::Object(experiment.context.clone().into())),
1268: 1266:                 &workspace_context,
1269: 1267:                 &experiment.variants,
1270: 1268:             )
1271: 1269:             .await?;
1272: 1270:         }
1273: 1271:     }
1274: 1272: 
1275: 1273:     let old_traffic_percentage = experiment.traffic_percentage;
1276: 1274:     let new_traffic_percentage = &req.traffic_percentage;
1277: 1275:     let variants_count = experiment.variants.clone().into_inner().len() as u8;
1278: 1276: 
1279: 1277:     new_traffic_percentage
1280: 1278:         .check_max_allowed(variants_count)
1281: 1279:         .map_err(|e| bad_argument!(e))?;
1282: 1280: 
1283: 1281:     new_traffic_percentage
1284: 1282:         .compare_old(&old_traffic_percentage)
1285: 1283:         .map_err(|e| bad_argument!(e))?;
1286: 1284: 
1287: 1285:     let now = Utc::now();
1288: 1286:     let started_by_request = match experiment.status {
1289: 1287:         ExperimentStatusType::CREATED => StartedByChangeSet {
1290: 1288:             started_by: Some(user.get_email()),
1291: 1289:             started_at: Some(now),
1292: 1290:         },
1293: 1291:         _ => StartedByChangeSet {
1294: 1292:             started_by: None,
1295: 1293:             started_at: None,
1296: 1294:         },
1297: 1295:     };
1298: 1296: 
1299: 1297:     let mut experiment_group_id = experiment.experiment_group_id;
1300: 1298: 
1301: 1299:     let updated_experiment =
1302: 1300:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
1303: 1301:             if experiment.status == ExperimentStatusType::CREATED
1304: 1302:                 && experiment_group_id.is_none()
1305: 1303:             {
1306: 1304:                 // make a system generated experiment group
1307: 1305:                 let experiment_group = create_system_generated_experiment_group(
1308: 1306:                     &experiment,
1309: 1307:                     new_traffic_percentage,
1310: 1308:                     &state,
1311: 1309:                     transaction_conn,
1312: 1310:                     &workspace_context.schema_name,
1313: 1311:                     &user,
1314: 1312:                 )?;
1315: 1313:                 experiment_group_id = Some(experiment_group.id);
1316: 1314:             } else if let Some(experiment_group_id) = experiment_group_id {
1317: 1315:                 update_experiment_group_buckets(
1318: 1316:                     &experiment,
1319: 1317:                     &experiment_group_id,
1320: 1318:                     new_traffic_percentage,
1321: 1319:                     transaction_conn,
1322: 1320:                     &workspace_context.schema_name,
1323: 1321:                     &user,
1324: 1322:                 )?;
1325: 1323:             }
1326: 1324: 
1327: 1325:             let updated_experiment: Experiment = diesel::update(experiments::experiments)
1328: 1326:                 .filter(experiments::id.eq(exp_id))
1329: 1327:                 .set((
1330: 1328:                     started_by_request,
1331: 1329:                     experiments::traffic_percentage.eq(new_traffic_percentage),
1332: 1330:                     experiments::last_modified.eq(now),
1333: 1331:                     experiments::last_modified_by.eq(user.get_email()),
1334: 1332:                     experiments::status.eq(ExperimentStatusType::INPROGRESS),
1335: 1333:                     experiments::change_reason.eq(change_reason),
1336: 1334:                     experiments::experiment_group_id.eq(experiment_group_id),
1337: 1335:                 ))
1338: 1336:                 .returning(Experiment::as_returning())
1339: 1337:                 .schema_name(&workspace_context.schema_name)
1340: 1338:                 .get_result(transaction_conn)?;
1341: 1339:             Ok(updated_experiment)
1342: 1340:         })?;
1343: 1341: 
1344: 1342:     let (_, config_version_id) = fetch_cac_config(&state, &workspace_context).await?;
1345: 1343:     let experiment_response = ExperimentResponse::from(updated_experiment);
1346: 1344: 
1347: 1345:     let webhook_event = if matches!(experiment.status, ExperimentStatusType::CREATED) {
1348: 1346:         WebhookEvent::ExperimentStarted
1349: 1347:     } else {
1350: 1348:         WebhookEvent::ExperimentInprogress
1351: 1349:     };
1352: 1350:     let webhook_status = if let Ok(webhook) =
1353: 1351:         fetch_webhook_by_event(&state, &user, &webhook_event, &workspace_context).await
1354: 1352:     {
1355: 1353:         execute_webhook_call(
1356: 1354:             &webhook,
1357: 1355:             &experiment_response,
1358: 1356:             &config_version_id,
1359: 1357:             &workspace_context,
1360: 1358:             webhook_event,
1361: 1359:             &state,
1362: 1360:             &mut conn,
1363: 1361:         )
1364: 1362:         .await
1365: 1363:     } else {
1366: 1364:         true
1367: 1365:     };
1368: 1366: 
1369: 1367:     let mut http_resp = if webhook_status {
1370: 1368:         HttpResponse::Ok()
1371: 1369:     } else {
1372: 1370:         HttpResponse::build(
1373: 1371:             StatusCode::from_u16(512).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
1374: 1372:         )
1375: 1373:     };
1376: 1374:     Ok(http_resp.json(experiment_response))
1377: 1375: }
1378: 1376: 
1379: 1377: #[allow(clippy::too_many_arguments)]
1380: 1378: #[authorized]
1381: 1379: #[routes]
1382: 1380: #[put("/{id}/overrides")]
1383: 1381: #[patch("/{id}/overrides")]
1384: 1382: async fn update_handler(
1385: 1383:     workspace_context: WorkspaceContext,
1386: 1384:     params: web::Path<i64>,
1387: 1385:     state: Data<AppState>,
1388: 1386:     custom_headers: CustomHeaders,
1389: 1387:     db_conn: DbConnection,
1390: 1388:     req: Json<OverrideKeysUpdateRequest>,
1391: 1389:     user: User,
1392: 1390: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
1393: 1391:     let DbConnection(mut conn) = db_conn;
1394: 1392:     let experiment_id = params.into_inner();
1395: 1393:     let experiment_group_id = req.experiment_group_id.clone();
1396: 1394:     let description = req.description.clone();
1397: 1395:     let change_reason = req.change_reason.clone();
1398: 1396: 
1399: 1397:     fetch_and_validate_change_reason_with_function(
1400: 1398:         &workspace_context,
1401: 1399:         &change_reason,
1402: 1400:         &state,
1403: 1401:     )
1404: 1402:     .await?;
1405: 1403: 
1406: 1404:     let payload = req.into_inner();
1407: 1405:     let variants = payload.variants;
1408: 1406: 
1409: 1407:     let first_variant = variants.first().ok_or(bad_argument!(
1410: 1408:         "Variant not found in request. Provide at least one entry in variant's list",
1411: 1409:     ))?;
1412: 1410:     let override_keys =
1413: 1411:         extract_override_keys(&first_variant.overrides.clone().into_inner())
1414: 1412:             .into_iter()
1415: 1413:             .collect();
1416: 1414: 
1417: 1415:     // fetch the current variants of the experiment
1418: 1416:     let experiment = experiments::experiments
1419: 1417:         .find(experiment_id)
1420: 1418:         .schema_name(&workspace_context.schema_name)
1421: 1419:         .first::<Experiment>(&mut conn)?;
1422: 1420: 
1423: 1421:     if experiment.status != ExperimentStatusType::CREATED {
1424: 1422:         return Err(bad_argument!(
1425: 1423:             "Only experiments in CREATED state can be updated"
1426: 1424:         ));
1427: 1425:     }
1428: 1426: 
1429: 1427:     let experiment_variants: Vec<Variant> = experiment.variants.clone().into_inner();
1430: 1428: 
1431: 1429:     let id_to_existing_variant: HashMap<String, &Variant> = HashMap::from_iter(
1432: 1430:         experiment_variants
1433: 1431:             .iter()
1434: 1432:             .map(|variant| (variant.id.to_string(), variant))
1435: 1433:             .collect::<Vec<(String, &Variant)>>(),
1436: 1434:     );
1437: 1435: 
1438: 1436:     // checking if variants passed with correct existing variant lyx-core-lyx_core_lyx-core-lyx_core_ids
1439: 1437:     if variants.len() != id_to_existing_variant.len() {
1440: 1438:         Err(bad_argument!(
1441: 1439:             "Number of variants passed in the request does not match with existing experiment variants"
1442: 1440:         ))?;
1443: 1441:     }
1444: 1442: 
1445: 1443:     /****************** Validating override_keys and variant overrides *********************/
1446: 1444: 
1447: 1445:     validate_override_keys(&override_keys)?;
1448: 1446: 
1449: 1447:     let variant_lyx-core-lyx_core_lyx-core-lyx_core_ids: HashSet<String> = HashSet::from_iter(
1450: 1448:         variants
1451: 1449:             .iter()
1452: 1450:             .map(|variant| variant.id.to_string())
1453: 1451:             .collect::<Vec<String>>(),
1454: 1452:     );
1455: 1453:     for existing_id in id_to_existing_variant.keys() {
1456: 1454:         if !variant_lyx-core-lyx_core_lyx-core-lyx_core_ids.contains(existing_id) {
1457: 1455:             Err(bad_argument!(
1458: 1456:                 "Some variant lyx-core-lyx_core_lyx-core-lyx_core_ids do not match with exisiting experiment variants. Provide all existing variants of the experiment"
1459: 1457:             ))?;
1460: 1458:         }
1461: 1459:     }
1462: 1460:     // Checking if all the variants are overriding the mentioned keys
1463: 1461:     let mut new_variants: Vec<Variant> = variants
1464: 1462:         .clone()
1465: 1463:         .into_iter()
1466: 1464:         .map(|variant| {
1467: 1465:             let existing_variant: &Variant =
1468: 1466:                 id_to_existing_variant.get(&variant.id).ok_or_else(|| {
1469: 1467:                     log::error!(
1470: 1468:                         "Variant with id {} not found in existing variants",
1471: 1469:                         variant.id
1472: 1470:                     );
1473: 1471:                     unexpected_error!("Something went wrong")
1474: 1472:                 })?;
1475: 1473:             Ok(Variant {
1476: 1474:                 overrides: variant.overrides,
1477: 1475:                 override_id: None,
1478: 1476:                 ..existing_variant.clone()
1479: 1477:             })
1480: 1478:         })
1481: 1479:         .collect::<lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<_>>()?;
1482: 1480: 
1483: 1481:     let variant_overrides = new_variants
1484: 1482:         .iter()
1485: 1483:         .map(|variant| variant.overrides.clone().into_inner())
1486: 1484:         .collect::<Vec<Overrides>>();
1487: 1485: 
1488: 1486:     let experiment_condition =
1489: 1487:         Exp::<Condition>::validate_db_data(experiment.context.clone().into())
1490: 1488:             .map_err(|err| {
1491: 1489:                 log::error!(
1492: 1490:                     "update_overrides : failed to decode condition from db with error {}",
1493: 1491:                     err
1494: 1492:                 );
1495: 1493:                 unexpected_error!(err)
1496: 1494:             })?
1497: 1495:             .into_inner();
1498: 1496:     let exp_context_id = hash(&Value::Object(experiment_condition.clone().into()));
1499: 1497:     match experiment.experiment_type {
1500: 1498:         ExperimentType::Default => {
1501: 1499:             let are_valid_variants =
1502: 1500:                 check_variants_override_coverage(&variant_overrides, &override_keys);
1503: 1501:             if !are_valid_variants {
1504: 1502:                 return Err(bad_argument!(
1505: 1503:                     "All variants should contain the keys mentioned in override_keys. Check if any of the following keys [{}] are missing from keys in your variants",
1506: 1504:                     override_keys.join(",")
1507: 1505:                 ))?;
1508: 1506:             }
1509: 1507: 
1510: 1508:             // Validate control overrides against resolved config when auto-populate is enabled
1511: 1509:             if workspace_context.settings.auto_populate_control {
1512: 1510:                 let control_variant_id = experiment
1513: 1511:                     .variants
1514: 1512:                     .iter()
1515: 1513:                     .find(|v| v.variant_type == VariantType::CONTROL)
1516: 1514:                     .map(|v| v.id.to_string())
1517: 1515:                     .ok_or_else(|| {
1518: 1516:                         log::error!(
1519: 1517:                             "Control variant not found in existing experiment variants"
1520: 1518:                         );
1521: 1519:                         unexpected_error!(
1522: 1520:                             "Control variant not found in existing experiment variants"
1523: 1521:                         )
1524: 1522:                     })?;
1525: 1523: 
1526: 1524:                 let req_control_variant = variants
1527: 1525:                     .iter()
1528: 1526:                     .find(|v| v.id == control_variant_id)
1529: 1527:                     .ok_or_else(|| {
1530: 1528:                         log::error!("Control variant missing from request variants");
1531: 1529:                         bad_argument!("Control variant missing from request variants")
1532: 1530:                     })?;
1533: 1531: 
1534: 1532:                 validate_control_overrides(
1535: 1533:                     &req_control_variant.overrides,
1536: 1534:                     &experiment.context,
1537: 1535:                     &workspace_context,
1538: 1536:                     &user,
1539: 1537:                     &state,
1540: 1538:                 )
1541: 1539:                 .await?;
1542: 1540:             }
1543: 1541: 
1544: 1542:             // validating experiment against other active experiments based on permission flags
1545: 1543:             let flags = &state.experimentation_flags;
1546: 1544:             let (valid, reason) = validate_experiment(
1547: 1545:                 &experiment_condition,
1548: 1546:                 &override_keys,
1549: 1547:                 Some(experiment_id),
1550: 1548:                 flags,
1551: 1549:                 &workspace_context.schema_name,
1552: 1550:                 &mut conn,
1553: 1551:             )?;
1554: 1552:             if !valid {
1555: 1553:                 return Err(bad_argument!(reason));
1556: 1554:             }
1557: 1555:         }
1558: 1556:         ExperimentType::DeleteOverrides => {
1559: 1557:             validate_delete_experiment_variants(
1560: 1558:                 &user,
1561: 1559:                 &state,
1562: 1560:                 &experiment_condition,
1563: 1561:                 &exp_context_id,
1564: 1562:                 &workspace_context,
1565: 1563:                 &new_variants,
1566: 1564:             )
1567: 1565:             .await?;
1568: 1566:         }
1569: 1567:     }
1570: 1568: 
1571: 1569:     /******************************* Updating contexts ************************************/
1572: 1570:     let mut cac_operations: Vec<ContextAction> = vec![];
1573: 1571: 
1574: 1572:     // adding operations to create new updated variant contexts
1575: 1573:     for variant in &new_variants {
1576: 1574:         let overrides: Map<String, Value> = variant.overrides.clone().into_inner().into();
1577: 1575:         let payload = UpdateRequest {
1578: 1576:             context: Identifier::Id(variant.context_id.clone().ok_or_else(|| {
1579: 1577:                 unexpected_error!("context id not available for variant {}", variant.id)
1580: 1578:             })?),
1581: 1579:             override_: Cac::<Overrides>::try_from(overrides).map_err(|err| {
1582: 1580:                 log::error!("failed to convert variant overrides to cac override {err}");
1583: 1581:                 bad_argument!("failed to convert variant overrides to cac override")
1584: 1582:             })?,
1585: 1583:             description: description.clone(),
1586: 1584:             change_reason: change_reason.clone(),
1587: 1585:         };
1588: 1586: 
1589: 1587:         cac_operations.push(ContextAction::Replace(payload));
1590: 1588:     }
1591: 1589: 
1592: 1590:     let http_lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
1593: 1591:     let url = state.cac_host.clone() + "/context/bulk-operations";
1594: 1592:     let user_str = serde_json::to_string(&user).map_err(|err| {
1595: 1593:         log::error!("Something went wrong, failed to stringify user data {err}");
1596: 1594:         unexpected_error!(
1597: 1595:             "Something went wrong, failed to stringify user data {}",
1598: 1596:             err
1599: 1597:         )
1600: 1598:     })?;
1601: 1599:     let extra_headers = vec![
1602: 1600:         ("x-user", Some(user_str)),
1603: 1601:         ("x-config-tags", custom_headers.config_tags),
1604: 1602:     ]
1605: 1603:     .into_iter()
1606: 1604:     .filter_map(|(key, val)| val.map(|v| (key, v)))
1607: 1605:     .collect::<Vec<_>>();
1608: 1606: 
1609: 1607:     let headers_map = construct_header_map(
1610: 1608:         &workspace_context.workspace_id,
1611: 1609:         &workspace_context.organisation_id,
1612: 1610:         extra_headers,
1613: 1611:     )?;
1614: 1612: 
1615: 1613:     let response = http_lyx-core-lyx_core_lyx-core-lyx_core_client
1616: 1614:         .put(&url)
1617: 1615:         .headers(headers_map.into())
1618: 1616:         .header(
1619: 1617:             header::AUTHORIZATION,
1620: 1618:             format!("Internal {}", state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token),
1621: 1619:         )
1622: 1620:         .json(&cac_operations)
1623: 1621:         .send()
1624: 1622:         .await;
1625: 1623: 
1626: 1624:     // directly return an error response if not a 200 response
1627: 1625:     let (resp_contexts, config_version_id) =
1628: 1626:         process_cac_bulk_operation_http_response(response).await?;
1629: 1627:     let created_contexts = resp_contexts
1630: 1628:         .into_iter()
1631: 1629:         .map(|item| match item {
1632: 1630:             ContextBulkResponse::Replace(context) => Ok(context),
1633: 1631:             _ => Err(format!("Unexpected response item: {item:?}")),
1634: 1632:         })
1635: 1633:         .collect::<Result<Vec<_>, _>>()
1636: 1634:         .map_err(|err| {
1637: 1635:             log::error!(
1638: 1636:                 "Something went wrong, failed to parse bulk operations response {err}"
1639: 1637:             );
1640: 1638:             unexpected_error!("Something went wrong")
1641: 1639:         })?;
1642: 1640: 
1643: 1641:     for i in 0..created_contexts.len() {
1644: 1642:         let created_context = &created_contexts[i];
1645: 1643:         if new_variants[i]
1646: 1644:             .context_id
1647: 1645:             .clone()
1648: 1646:             .map(|id| id != created_context.id)
1649: 1647:             .unwrap_or_default()
1650: 1648:         {
1651: 1649:             log::error!(
1652: 1650:                 "Context id changed from {} to {}",
1653: 1651:                 new_variants[i].context_id.clone().unwrap_or_default(),
1654: 1652:                 created_context.id
1655: 1653:             );
1656: 1654:             Err(unexpected_error!("Something went wrong"))?;
1657: 1655:         }
1658: 1656: 
1659: 1657:         new_variants[i].override_id = Some(created_context.override_id.clone());
1660: 1658:     }
1661: 1659: 
1662: 1660:     /*************************** Updating experiment in DB **************************/
1663: 1661:     let existing_metrics = &experiment.metrics.clone();
1664: 1662:     let updated_metrics = payload.metrics.as_ref().unwrap_or(existing_metrics);
1665: 1663: 
1666: 1664:     let updated_experiment =
1667: 1665:         conn.transaction::<_, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError, _>(|transaction_conn| {
1668: 1666:             let experiment_group_id_result = handle_experiment_group_membership(
1669: 1667:                 &experiment,
1670: 1668:                 &experiment_group_id,
1671: 1669:                 &experiment.experiment_group_id,
1672: 1670:                 &state,
1673: 1671:                 transaction_conn,
1674: 1672:                 &workspace_context.schema_name,
1675: 1673:                 &user,
1676: 1674:             )?;
1677: 1675: 
1678: 1676:             let updated_experiment =
1679: 1677:                 diesel::update(experiments::experiments.find(experiment_id))
1680: 1678:                     .set((
1681: 1679:                         experiments::variants.eq(Variants::new(new_variants)),
1682: 1680:                         experiments::override_keys.eq(override_keys),
1683: 1681:                         experiments::change_reason.eq(change_reason),
1684: 1682:                         experiments::description
1685: 1683:                             .eq(description.unwrap_or(experiment.description)),
1686: 1684:                         experiments::metrics.eq(updated_metrics),
1687: 1685:                         experiments::last_modified.eq(Utc::now()),
1688: 1686:                         experiments::last_modified_by.eq(user.get_email()),
1689: 1687:                         experiments::experiment_group_id.eq(experiment_group_id_result),
1690: 1688:                     ))
1691: 1689:                     .returning(Experiment::as_returning())
1692: 1690:                     .schema_name(&workspace_context.schema_name)
1693: 1691:                     .get_result::<Experiment>(transaction_conn)?;
1694: 1692: 
1695: 1693:             Ok(updated_experiment)
1696: 1694:         })?;
1697: 1695: 
1698: 1696:     let experiment_response = ExperimentResponse::from(updated_experiment);
1699: 1697: 
1700: 1698:     let webhook_status = if let Ok(webhook) = fetch_webhook_by_event(
1701: 1699:         &state,
1702: 1700:         &user,
1703: 1701:         &WebhookEvent::ExperimentUpdated,
1704: 1702:         &workspace_context,
1705: 1703:     )
1706: 1704:     .await
1707: 1705:     {
1708: 1706:         execute_webhook_call(
1709: 1707:             &webhook,
1710: 1708:             &experiment_response,
1711: 1709:             &config_version_id,
1712: 1710:             &workspace_context,
1713: 1711:             WebhookEvent::ExperimentUpdated,
1714: 1712:             &state,
1715: 1713:             &mut conn,
1716: 1714:         )
1717: 1715:         .await
1718: 1716:     } else {
1719: 1717:         true
1720: 1718:     };
1721: 1719: 
1722: 1720:     let mut http_resp = if webhook_status {
1723: 1721:         HttpResponse::Ok()
1724: 1722:     } else {
1725: 1723:         HttpResponse::build(
1726: 1724:             StatusCode::from_u16(512).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
1727: 1725:         )
1728: 1726:     };
1729: 1727:     add_config_version_to_header(&config_version_id, &mut http_resp);
1730: 1728:     Ok(http_resp.json(experiment_response))
1731: 1729: }
1732: 1730: 
1733: 1731: #[authorized]
1734: 1732: #[patch("/{experiment_id}/pause")]
1735: 1733: async fn pause_handler(
1736: 1734:     workspace_context: WorkspaceContext,
1737: 1735:     state: Data<AppState>,
1738: 1736:     path: Path<i64>,
1739: 1737:     req: Json<ExperimentStateChangeRequest>,
1740: 1738:     db_conn: DbConnection,
1741: 1739:     user: User,
1742: 1740: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
1743: 1741:     let DbConnection(mut conn) = db_conn;
1744: 1742: 
1745: 1743:     fetch_and_validate_change_reason_with_function(
1746: 1744:         &workspace_context,
1747: 1745:         &req.change_reason,
1748: 1746:         &state,
1749: 1747:     )
1750: 1748:     .await?;
1751: 1749: 
1752: 1750:     let response = pause(
1753: 1751:         path.into_inner(),
1754: 1752:         req.into_inner(),
1755: 1753:         &mut conn,
1756: 1754:         &workspace_context,
1757: 1755:         &user,
1758: 1756:     )
1759: 1757:     .await?;
1760: 1758: 
1761: 1759:     let experiment_response = ExperimentResponse::from(response);
1762: 1760: 
1763: 1761:     let webhook_status = if let Ok(webhook) = fetch_webhook_by_event(
1764: 1762:         &state,
1765: 1763:         &user,
1766: 1764:         &WebhookEvent::ExperimentPaused,
1767: 1765:         &workspace_context,
1768: 1766:     )
1769: 1767:     .await
1770: 1768:     {
1771: 1769:         execute_webhook_call(
1772: 1770:             &webhook,
1773: 1771:             &experiment_response,
1774: 1772:             &None,
1775: 1773:             &workspace_context,
1776: 1774:             WebhookEvent::ExperimentPaused,
1777: 1775:             &state,
1778: 1776:             &mut conn,
1779: 1777:         )
1780: 1778:         .await
1781: 1779:     } else {
1782: 1780:         true
1783: 1781:     };
1784: 1782: 
1785: 1783:     let mut http_resp = if webhook_status {
1786: 1784:         HttpResponse::Ok()
1787: 1785:     } else {
1788: 1786:         HttpResponse::build(
1789: 1787:             StatusCode::from_u16(512).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
1790: 1788:         )
1791: 1789:     };
1792: 1790:     Ok(http_resp.json(experiment_response))
1793: 1791: }
1794: 1792: 
1795: 1793: pub async fn pause(
1796: 1794:     experiment_id: i64,
1797: 1795:     req: ExperimentStateChangeRequest,
1798: 1796:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
1799: 1797:     workspace_context: &WorkspaceContext,
1800: 1798:     user: &User,
1801: 1799: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Experiment> {
1802: 1800:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl;
1803: 1801: 
1804: 1802:     let experiment: Experiment = dsl::experiments
1805: 1803:         .find(experiment_id)
1806: 1804:         .schema_name(&workspace_context.schema_name)
1807: 1805:         .get_result::<Experiment>(conn)?;
1808: 1806: 
1809: 1807:     if !experiment.status.pausable() {
1810: 1808:         return Err(bad_argument!(
1811: 1809:             "experiment with id {} cannot be paused",
1812: 1810:             experiment_id
1813: 1811:         ));
1814: 1812:     }
1815: 1813: 
1816: 1814:     // not removing buckets here, so that once resumed, the experiment can continue
1817: 1815:     let updated_experiment = diesel::update(dsl::experiments)
1818: 1816:         .filter(dsl::id.eq(experiment_id))
1819: 1817:         .set((
1820: 1818:             req,
1821: 1819:             dsl::status.eq(ExperimentStatusType::PAUSED),
1822: 1820:             dsl::last_modified.eq(Utc::now()),
1823: 1821:             dsl::last_modified_by.eq(user.get_email()),
1824: 1822:         ))
1825: 1823:         .returning(Experiment::as_returning())
1826: 1824:         .schema_name(&workspace_context.schema_name)
1827: 1825:         .get_result::<Experiment>(conn)?;
1828: 1826: 
1829: 1827:     Ok(updated_experiment)
1830: 1828: }
1831: 1829: 
1832: 1830: #[authorized]
1833: 1831: #[patch("/{experiment_id}/resume")]
1834: 1832: async fn resume_handler(
1835: 1833:     workspace_context: WorkspaceContext,
1836: 1834:     state: Data<AppState>,
1837: 1835:     path: Path<i64>,
1838: 1836:     req: Json<ExperimentStateChangeRequest>,
1839: 1837:     db_conn: DbConnection,
1840: 1838:     user: User,
1841: 1839: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
1842: 1840:     let DbConnection(mut conn) = db_conn;
1843: 1841: 
1844: 1842:     fetch_and_validate_change_reason_with_function(
1845: 1843:         &workspace_context,
1846: 1844:         &req.change_reason,
1847: 1845:         &state,
1848: 1846:     )
1849: 1847:     .await?;
1850: 1848: 
1851: 1849:     let response = resume(
1852: 1850:         path.into_inner(),
1853: 1851:         req.into_inner(),
1854: 1852:         &mut conn,
1855: 1853:         &workspace_context,
1856: 1854:         &user,
1857: 1855:     )
1858: 1856:     .await?;
1859: 1857: 
1860: 1858:     let experiment_response = ExperimentResponse::from(response);
1861: 1859: 
1862: 1860:     let webhook_status = if let Ok(webhook) = fetch_webhook_by_event(
1863: 1861:         &state,
1864: 1862:         &user,
1865: 1863:         &WebhookEvent::ExperimentInprogress,
1866: 1864:         &workspace_context,
1867: 1865:     )
1868: 1866:     .await
1869: 1867:     {
1870: 1868:         execute_webhook_call(
1871: 1869:             &webhook,
1872: 1870:             &experiment_response,
1873: 1871:             &None,
1874: 1872:             &workspace_context,
1875: 1873:             WebhookEvent::ExperimentInprogress,
1876: 1874:             &state,
1877: 1875:             &mut conn,
1878: 1876:         )
1879: 1877:         .await
1880: 1878:     } else {
1881: 1879:         true
1882: 1880:     };
1883: 1881: 
1884: 1882:     let mut http_resp = if webhook_status {
1885: 1883:         HttpResponse::Ok()
1886: 1884:     } else {
1887: 1885:         HttpResponse::build(
1888: 1886:             StatusCode::from_u16(512).unwrap_or(StatusCode::INTERNAL_SERVER_ERROR),
1889: 1887:         )
1890: 1888:     };
1891: 1889:     Ok(http_resp.json(experiment_response))
1892: 1890: }
1893: 1891: 
1894: 1892: pub async fn resume(
1895: 1893:     experiment_id: i64,
1896: 1894:     req: ExperimentStateChangeRequest,
1897: 1895:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
1898: 1896:     workspace_context: &WorkspaceContext,
1899: 1897:     user: &User,
1900: 1898: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Experiment> {
1901: 1899:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl;
1902: 1900: 
1903: 1901:     let experiment: Experiment = dsl::experiments
1904: 1902:         .find(experiment_id)
1905: 1903:         .schema_name(&workspace_context.schema_name)
1906: 1904:         .get_result::<Experiment>(conn)?;
1907: 1905: 
1908: 1906:     if !experiment.status.resumable() {
1909: 1907:         return Err(bad_argument!(
1910: 1908:             "experiment with id {} cannot be resumed",
1911: 1909:             experiment_id
1912: 1910:         ));
1913: 1911:     }
1914: 1912: 
1915: 1913:     let updated_experiment = diesel::update(dsl::experiments)
1916: 1914:         .filter(dsl::id.eq(experiment_id))
1917: 1915:         .set((
1918: 1916:             req,
1919: 1917:             dsl::status.eq(ExperimentStatusType::INPROGRESS),
1920: 1918:             dsl::last_modified.eq(Utc::now()),
1921: 1919:             dsl::last_modified_by.eq(user.get_email()),
1922: 1920:         ))
1923: 1921:         .returning(Experiment::as_returning())
1924: 1922:         .schema_name(&workspace_context.schema_name)
1925: 1923:         .get_result::<Experiment>(conn)?;
1926: 1924: 
1927: 1925:     Ok(updated_experiment)
1928: 1926: }
1929: 1927: ```
1930: 1928: ```
1931: 1929: ```
1932: 1930: ```
1933: ```
```
