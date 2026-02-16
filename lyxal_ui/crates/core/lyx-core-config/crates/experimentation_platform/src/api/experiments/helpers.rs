1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiments\helpers.rs
10: 8: ```rust
11: 9: use std::collections::HashSet;
12: 10: 
13: 11: use actix_http::header;
14: 12: use actix_web::web::Data;
15: 13: use lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client::utils::json_to_sorted_string;
16: 14: use chrono::Utc;
17: 15: use diesel::{
18: 16:     BoolExpressionMethods, ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper,
19: 17:     pg::PgConnection,
20: 18:     r2d2::{ConnectionManager, PooledConnection},
21: 19: };
22: 20: use serde_json::{Map, Value};
23: 21: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{
24: 22:     AppState, ExperimentationFlags, SchemaName, WorkspaceContext,
25: 23: };
26: 24: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, unexpected_error};
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
28: 26:     Condition, Config, DBConnection, Exp, Overrides, User,
29: 27:     api::{
30: 28:         I64Update,
31: 29:         config::{ConfigQuery, ResolveConfigQuery},
32: 30:         experiment_groups::ExpGroupMemberRequest,
33: 31:         functions::{
34: 32:             CHANGE_REASON_VALIDATION_FN_NAME, FunctionExecutionRequest,
35: 33:             FunctionExecutionResponse, Stage,
36: 34:         },
37: 35:     },
38: 36:     custom_query::{DimensionQuery, QueryParam},
39: 37:     database::{
40: 38:         models::{
41: 39:             ChangeReason,
42: 40:             experimentation::{
43: 41:                 Experiment, ExperimentStatusType, GroupType, Variant, VariantType,
44: 42:             },
45: 43:             others::{Webhook, WebhookEvent},
46: 44:         },
47: 45:         schema::experiments::dsl as experiments,
48: 46:     },
49: 47:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
50: 48: };
51: 49: 
52: 50: use crate::api::experiment_groups::helpers::{
53: 51:     add_members, create_system_generated_experiment_group, fetch_experiment_group,
54: 52:     remove_members,
55: 53: };
56: 54: 
57: 55: use super::cac_api::{
58: 56:     construct_header_map, get_context_override, get_partial_resolve_config,
59: 57:     get_resolved_config,
60: 58: };
61: 59: 
62: 60: pub fn check_variant_types(variants: &Vec<Variant>) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
63: 61:     let mut experimental_variant_cnt = 0;
64: 62:     let mut control_variant_cnt = 0;
65: 63: 
66: 64:     for variant in variants {
67: 65:         match variant.variant_type {
68: 66:             VariantType::CONTROL => {
69: 67:                 control_variant_cnt += 1;
70: 68:             }
71: 69:             VariantType::EXPERIMENTAL => {
72: 70:                 experimental_variant_cnt += 1;
73: 71:             }
74: 72:         }
75: 73:     }
76: 74: 
77: 75:     if control_variant_cnt > 1 || control_variant_cnt == 0 {
78: 76:         return Err(bad_argument!(
79: 77:             "Experiment should have exactly 1 control variant. Ensure only one control variant is present"
80: 78:         ));
81: 79:     } else if experimental_variant_cnt < 1 {
82: 80:         return Err(bad_argument!(
83: 81:             "Experiment should have at least 1 experimental variant. Ensure only one control variant is present"
84: 82:         ));
85: 83:     }
86: 84: 
87: 85:     Ok(())
88: 86: }
89: 87: 
90: 88: pub fn validate_override_keys(override_keys: &Vec<String>) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
91: 89:     let mut key_set: HashSet<&str> = HashSet::new();
92: 90:     for key in override_keys {
93: 91:         if !key_set.insert(key) {
94: 92:             return Err(bad_argument!(
95: 93:                 "override_keys are not unique. Remove duplicate entries in override_keys"
96: 94:             ));
97: 95:         }
98: 96:     }
99: 97: 
100: 98:     Ok(())
101: 99: }
102: 100: 
103: 101: pub fn hash(val: &Value) -> String {
104: 102:     let sorted_str: String = json_to_sorted_string(val);
105: 103:     blake3::hash(sorted_str.as_bytes()).to_string()
106: 104: }
107: 105: 
108: 106: pub fn are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(
109: 107:     context_a: &Condition,
110: 108:     context_b: &Condition,
111: 109: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<bool> {
112: 110:     let dim_a_keys = context_a.keys();
113: 111:     let dim_b_keys = context_b.keys();
114: 112: 
115: 113:     let ref_keys = if dim_a_keys.len() > dim_b_keys.len() {
116: 114:         dim_b_keys
117: 115:     } else {
118: 116:         dim_a_keys
119: 117:     };
120: 118: 
121: 119:     let mut is_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping = true;
122: 120:     for key in ref_keys {
123: 121:         let test = (context_a.contains_key(key) && context_b.contains_key(key))
124: 122:             && (context_a[key] == context_b[key]);
125: 123:         is_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping = is_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping && test;
126: 124: 
127: 125:         if !test {
128: 126:             break;
129: 127:         }
130: 128:     }
131: 129: 
132: 130:     Ok(is_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping)
133: 131: }
134: 132: 
135: 133: pub fn check_variant_override_coverage(
136: 134:     variant_override: &Overrides,
137: 135:     override_keys: &Vec<String>,
138: 136: ) -> bool {
139: 137:     if variant_override.keys().len() != override_keys.len() {
140: 138:         return false;
141: 139:     }
142: 140: 
143: 141:     for override_key in override_keys {
144: 142:         if variant_override.get(override_key).is_none() {
145: 143:             return false;
146: 144:         }
147: 145:     }
148: 146:     true
149: 147: }
150: 148: 
151: 149: pub fn check_variants_override_coverage(
152: 150:     variant_overrides: &Vec<Overrides>,
153: 151:     override_keys: &Vec<String>,
154: 152: ) -> bool {
155: 153:     for variant_override in variant_overrides {
156: 154:         if !check_variant_override_coverage(variant_override, override_keys) {
157: 155:             return false;
158: 156:         }
159: 157:     }
160: 158: 
161: 159:     true
162: 160: }
163: 161: 
164: 162: fn validate_variants_delete_keys(
165: 163:     control_variant_overrides: &Overrides,
166: 164:     variant_delete_overrides: &[Overrides],
167: 165:     override_keys: &[String],
168: 166: ) -> bool {
169: 167:     let mut delete_keys = HashSet::new();
170: 168: 
171: 169:     for delete_variant in variant_delete_overrides.iter() {
172: 170:         for key in delete_variant.keys() {
173: 171:             if !override_keys.contains(key) {
174: 172:                 return false;
175: 173:             }
176: 174:             if !control_variant_overrides.contains_key(key) {
177: 175:                 return false;
178: 176:             }
179: 177: 
180: 178:             delete_keys.insert(key);
181: 179:         }
182: 180:     }
183: 181:     if delete_keys.len() != control_variant_overrides.len() {
184: 182:         return false;
185: 183:     }
186: 184:     true
187: 185: }
188: 186: 
189: 187: fn validate_keys_from_source(
190: 188:     variant_override: &Overrides,
191: 189:     source: &Map<String, Value>,
192: 190: ) -> bool {
193: 191:     for (override_key, value) in variant_override.iter() {
194: 192:         if let Some(val) = source.get(override_key) {
195: 193:             if val != value {
196: 194:                 return false;
197: 195:             }
198: 196:         } else {
199: 197:             return false;
200: 198:         }
201: 199:     }
202: 200:     true
203: 201: }
204: 202: 
205: 203: fn validate_variants_delete_override_value(
206: 204:     delete_variant_overrides: &Vec<Overrides>,
207: 205:     resolved_config: &Map<String, Value>,
208: 206: ) -> bool {
209: 207:     for override_ in delete_variant_overrides {
210: 208:         if !validate_keys_from_source(override_, resolved_config) {
211: 209:             return false;
212: 210:         }
213: 211:     }
214: 212:     true
215: 213: }
216: 214: 
217: 215: fn validate_variants_control_override_value(
218: 216:     control_variant_overrides: &Overrides,
219: 217:     current_context_overrides: &Map<String, Value>,
220: 218: ) -> bool {
221: 219:     validate_keys_from_source(control_variant_overrides, current_context_overrides)
222: 220: }
223: 221: 
224: 222: pub async fn validate_delete_experiment_variants(
225: 223:     user: &User,
226: 224:     state: &Data<AppState>,
227: 225:     exp_context: &Condition,
228: 226:     context_id: &str,
229: 227:     workspace_context: &WorkspaceContext,
230: 228:     variants: &[Variant],
231: 229: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
232: 230:     let current_context =
233: 231:         get_context_override(user, state, workspace_context, context_id.to_owned())
234: 232:             .await?;
235: 233: 
236: 234:     let partial_resolved_config = get_partial_resolve_config(
237: 235:         user,
238: 236:         state,
239: 237:         exp_context,
240: 238:         context_id,
241: 239:         workspace_context,
242: 240:     )
243: 241:     .await?;
244: 242: 
245: 243:     let control_variant_override = variants
246: 244:         .iter()
247: 245:         .find(|variant| variant.variant_type == VariantType::CONTROL)
248: 246:         .map(|variant| variant.overrides.clone().into_inner())
249: 247:         .ok_or_else(|| {
250: 248:             log::error!("validate_delete_experiment : No control variant found");
251: 249:             bad_argument!("No control variant found")
252: 250:         })?;
253: 251: 
254: 252:     let other_variants_overrides = variants
255: 253:         .iter()
256: 254:         .filter(|variant| variant.variant_type != VariantType::CONTROL)
257: 255:         .map(|variant| variant.overrides.clone().into_inner())
258: 256:         .collect::<Vec<_>>();
259: 257: 
260: 258:     let are_valid_variants = validate_variants_delete_keys(
261: 259:         &control_variant_override,
262: 260:         &other_variants_overrides,
263: 261:         &current_context
264: 262:             .override_
265: 263:             .keys()
266: 264:             .cloned()
267: 265:             .collect::<Vec<String>>(),
268: 266:     );
269: 267:     if !are_valid_variants {
270: 268:         log::error!("validate_delete_experiment : Variant delete keys are not valid");
271: 269:         return Err(bad_argument!(
272: 270:             "Variant delete keys are not valid. Ensure the keys are present in the context"
273: 271:         ));
274: 272:     }
275: 273: 
276: 274:     if !(validate_variants_delete_override_value(
277: 275:         &other_variants_overrides,
278: 276:         &partial_resolved_config,
279: 277:     )) {
280: 278:         log::error!(
281: 279:             "validate_delete_experiment: Inconsistent value for variant's overrides delete keys"
282: 280:         );
283: 281:         return Err(bad_argument!(
284: 282:             "Inconsistent value for variant's overrides delete keys"
285: 283:         ));
286: 284:     }
287: 285: 
288: 286:     if !(validate_variants_control_override_value(
289: 287:         &control_variant_override,
290: 288:         &current_context.override_,
291: 289:     )) {
292: 290:         log::error!(
293: 291:             "validate_delete_experiment: Inconsistent value for variant's overrides keys"
294: 292:         );
295: 293:         return Err(bad_argument!(
296: 294:             "Inconsistent value for variant's overrides keys"
297: 295:         ));
298: 296:     }
299: 297:     Ok(())
300: 298: }
301: 299: pub fn is_valid_experiment(
302: 300:     context: &Condition,
303: 301:     override_keys: &[String],
304: 302:     flags: &ExperimentationFlags,
305: 303:     active_experiments: &[Experiment],
306: 304: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<(bool, String)> {
307: 305:     let mut valid_experiment = true;
308: 306:     let mut invalid_reason = String::new();
309: 307:     if !flags.allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx
310: 308:         || !flags.allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx
311: 309:         || !flags.allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx
312: 310:     {
313: 311:         let override_keys_set = HashSet::<&String>::from_iter(override_keys);
314: 312:         for active_experiment in active_experiments {
315: 313:             let active_exp_context = Exp::<Condition>::validate_db_data(
316: 314:                 active_experiment.context.clone().into()
317: 315:             )
318: 316:             .map_err(|err| {
319: 317:                 log::error!("is_valid_experiment : failed to decode overrides from db with error {}", err);
320: 318:                 unexpected_error!(err)
321: 319:             })?
322: 320:             .into_inner();
323: 321:             let are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping =
324: 322:                 are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(context, &active_exp_context)
325: 323:                     .map_err(|e| {
326: 324:                         log::info!("experiment validation failed with error: {e}");
327: 325:                         bad_argument!(
328: 326:                             "Context overlap validation failed, given context overlaps with a running experiment's context. Overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping contexts are not allowed currently as per your configuration"
329: 327:                         )
330: 328:                     })?;
331: 329: 
332: 330:             let have_intersecting_key_set = active_experiment
333: 331:                 .override_keys
334: 332:                 .iter()
335: 333:                 .any(|key| override_keys_set.contains(key));
336: 334: 
337: 335:             let same_key_set = active_experiment
338: 336:                 .override_keys
339: 337:                 .iter()
340: 338:                 .all(|key| override_keys_set.contains(key));
341: 339: 
342: 340:             if !flags.allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx {
343: 341:                 valid_experiment = valid_experiment && (!are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping || same_key_set);
344: 342:             }
345: 343:             if !flags.allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx {
346: 344:                 valid_experiment =
347: 345:                     valid_experiment && !(are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping && have_intersecting_key_set);
348: 346:             }
349: 347:             if !flags.allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx {
350: 348:                 valid_experiment =
351: 349:                     valid_experiment && (are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping || !have_intersecting_key_set);
352: 350:             }
353: 351: 
354: 352:             if !valid_experiment {
355: 353:                 invalid_reason.push_str("This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping");
356: 354:                 break;
357: 355:             }
358: 356:         }
359: 357:     }
360: 358: 
361: 359:     Ok((valid_experiment, invalid_reason))
362: 360: }
363: 361: 
364: 362: pub fn validate_experiment(
365: 363:     context: &Condition,
366: 364:     override_keys: &[String],
367: 365:     experiment_id: Option<i64>,
368: 366:     flags: &ExperimentationFlags,
369: 367:     schema_name: &SchemaName,
370: 368:     conn: &mut PgConnection,
371: 369: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<(bool, String)> {
372: 370:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl as experiments_dsl;
373: 371: 
374: 372:     let active_experiments: Vec<Experiment> = experiments_dsl::experiments
375: 373:         .filter(
376: 374:             diesel::dsl::not(experiments_dsl::id.eq(experiment_id.unwrap_or_default()))
377: 375:                 .and(
378: 376:                     experiments_dsl::status
379: 377:                         .eq(ExperimentStatusType::CREATED)
380: 378:                         .or(experiments_dsl::status.eq(ExperimentStatusType::INPROGRESS)),
381: 379:                 ),
382: 380:         )
383: 381:         .schema_name(schema_name)
384: 382:         .load(conn)?;
385: 383: 
386: 384:     is_valid_experiment(context, override_keys, flags, &active_experiments)
387: 385: }
388: 386: 
389: 387: pub fn add_variant_dimension_to_ctx(
390: 388:     context: &Condition,
391: 389:     variant: String,
392: 390: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Value> {
393: 391:     let mut context_map: Map<String, Value> = context.clone().into();
394: 392:     context_map.insert("variantIds".to_string(), Value::String(variant));
395: 393:     Ok(Value::Object(context_map))
396: 394: }
397: 395: 
398: 396: pub fn extract_override_keys(overrides: &Map<String, Value>) -> HashSet<String> {
399: 397:     overrides.keys().map(String::from).collect()
400: 398: }
401: 399: 
402: 400: pub async fn fetch_cac_config(
403: 401:     state: &Data<AppState>,
404: 402:     workspace_context: &WorkspaceContext,
405: 403: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<(Config, Option<String>)> {
406: 404:     let http_lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
407: 405:     let query_params = ConfigQuery {
408: 406:         // Forced latest version to ensure we get the most recent config from CAC.
409: 407:         // Without this, CAC falls back to the workspace's default version setting, which may cause issue.
410: 408:         version: Some("latest".to_string()),
411: 409:         prefix: None,
412: 410:     };
413: 411:     let url = format!(
414: 412:         "{}/config?{}",
415: 413:         state.cac_host,
416: 414:         query_params.to_query_param(),
417: 415:     );
418: 416:     let headers_map = construct_header_map(
419: 417:         &workspace_context.workspace_id,
420: 418:         &workspace_context.organisation_id,
421: 419:         vec![],
422: 420:     )?;
423: 421: 
424: 422:     let response = http_lyx-core-lyx_core_lyx-core-lyx_core_client
425: 423:         .get(&url)
426: 424:         .headers(headers_map.into())
427: 425:         .header(
428: 426:             header::AUTHORIZATION,
429: 427:             format!("Internal {}", state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token),
430: 428:         )
431: 429:         .send()
432: 430:         .await;
433: 431: 
434: 432:     match response {
435: 433:         Ok(res) => {
436: 434:             let config_version = res
437: 435:                 .headers()
438: 436:                 .get("x-config-version")
439: 437:                 .and_then(|val| val.to_str().ok().map(String::from));
440: 438:             let config = res.json::<Config>().await.map_err(|err| {
441: 439:                 log::error!("failed to parse cac config response with error: {}", err);
442: 440:                 unexpected_error!("Failed to parse cac config.")
443: 441:             })?;
444: 442:             Ok((config, config_version))
445: 443:         }
446: 444:         Err(error) => {
447: 445:             log::error!("Failed to fetch cac config with error: {:?}", error);
448: 446:             Err(unexpected_error!(error))
449: 447:         }
450: 448:     }
451: 449: }
452: 450: 
453: 451: pub async fn fetch_webhook_by_event(
454: 452:     state: &Data<AppState>,
455: 453:     user: &User,
456: 454:     event: &WebhookEvent,
457: 455:     workspace_context: &WorkspaceContext,
458: 456: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Webhook> {
459: 457:     let http_lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
460: 458:     let url = format!("{}/webhook/event/{event}", state.cac_host);
461: 459:     let user_str = serde_json::to_string(user).map_err(|err| {
462: 460:         log::error!("Something went wrong, failed to stringify user data {err}");
463: 461:         unexpected_error!(
464: 462:             "Something went wrong, failed to stringify user data {}",
465: 463:             err
466: 464:         )
467: 465:     })?;
468: 466: 
469: 467:     let headers_map = construct_header_map(
470: 468:         &workspace_context.workspace_id,
471: 469:         &workspace_context.organisation_id,
472: 470:         vec![("x-user", user_str)],
473: 471:     )?;
474: 472: 
475: 473:     let response = http_lyx-core-lyx_core_lyx-core-lyx_core_client
476: 474:         .get(&url)
477: 475:         .headers(headers_map.into())
478: 476:         .header(
479: 477:             header::AUTHORIZATION,
480: 478:             format!("Internal {}", state.lyx-core-lyx_core_lyx-core-lyx_core_superposition_token),
481: 479:         )
482: 480:         .send()
483: 481:         .await;
484: 482: 
485: 483:     match response {
486: 484:         Ok(res) => {
487: 485:             if res.status() == 404 {
488: 486:                 log::info!("No Webhook found for event: {}", event);
489: 487:                 return Ok(Webhook::default());
490: 488:             }
491: 489:             let webhook = res.json::<Webhook>().await.map_err(|err| {
492: 490:                 log::error!("failed to parse Webhook response with error: {}", err);
493: 491:                 unexpected_error!("Failed to parse Webhook.")
494: 492:             })?;
495: 493:             Ok(webhook)
496: 494:         }
497: 495:         Err(error) => {
498: 496:             log::error!("Failed to fetch Webhook with error: {:?}", error);
499: 497:             Err(unexpected_error!(error))
500: 498:         }
501: 499:     }
502: 500: }
503: 501: 
504: 502: pub fn handle_experiment_group_membership(
505: 503:     experiment: &Experiment,
506: 504:     new_group_id: &Option<I64Update>,
507: 505:     current_group_id: &Option<i64>,
508: 506:     state: &Data<AppState>,
509: 507:     transaction_conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
510: 508:     schema_name: &SchemaName,
511: 509:     user: &User,
512: 510: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<I64Update> {
513: 511:     let experiment_id = experiment.id;
514: 512: 
515: 513:     fn create_member_request(
516: 514:         action: &str,
517: 515:         experiment_id: i64,
518: 516:     ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<ExpGroupMemberRequest> {
519: 517:         Ok(ExpGroupMemberRequest {
520: 518:             change_reason: ChangeReason::try_from(format!(
521: 519:                 "{} experiment {} to/from the group, while updating the experiment.",
522: 520:                 action, experiment_id
523: 521:             ))
524: 522:             .map_err(|e| unexpected_error!(e))?,
525: 523:             member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: vec![experiment_id],
526: 524:         })
527: 525:     }
528: 526: 
529: 527:     match (new_group_id, current_group_id) {
530: 528:         // Case 1: Adding to a new group (group specified and experiment not currently in any group)
531: 529:         (Some(I64Update::Add(experiment_group_id)), None) => {
532: 530:             add_members(
533: 531:                 experiment_group_id,
534: 532:                 std::slice::from_ref(experiment),
535: 533:                 create_member_request("Adding", experiment_id)?,
536: 534:                 transaction_conn,
537: 535:                 schema_name,
538: 536:                 user,
539: 537:             )?;
540: 538:             Ok(I64Update::Add(*experiment_group_id))
541: 539:         }
542: 540: 
543: 541:         // Case 2: Moving to a different group
544: 542:         (Some(I64Update::Add(experiment_group_id)), Some(current_group_id))
545: 543:             if experiment_group_id != current_group_id =>
546: 544:         {
547: 545:             // Remove from current group
548: 546:             remove_members(
549: 547:                 current_group_id,
550: 548:                 create_member_request("Removing", experiment_id)?,
551: 549:                 transaction_conn,
552: 550:                 schema_name,
553: 551:                 user,
554: 552:             )?;
555: 553: 
556: 554:             // Add to new group
557: 555:             add_members(
558: 556:                 experiment_group_id,
559: 557:                 std::slice::from_ref(experiment),
560: 558:                 create_member_request("Adding", experiment_id)?,
561: 559:                 transaction_conn,
562: 560:                 schema_name,
563: 561:                 user,
564: 562:             )?;
565: 563:             Ok(I64Update::Add(*experiment_group_id))
566: 564:         }
567: 565: 
568: 566:         // Case 3: Removing from group (explicitly set to None)
569: 567:         (Some(I64Update::Remove), Some(current_group_id)) => {
570: 568:             remove_members(
571: 569:                 current_group_id,
572: 570:                 create_member_request("Removing", experiment_id)?,
573: 571:                 transaction_conn,
574: 572:                 schema_name,
575: 573:                 user,
576: 574:             )?;
577: 575: 
578: 576:             // Make a new group if Inprogress or Paused
579: 577:             if experiment.status == ExperimentStatusType::INPROGRESS
580: 578:                 || experiment.status == ExperimentStatusType::PAUSED
581: 579:             {
582: 580:                 let new_experiment_group = create_system_generated_experiment_group(
583: 581:                     experiment,
584: 582:                     &experiment.traffic_percentage,
585: 583:                     state,
586: 584:                     transaction_conn,
587: 585:                     schema_name,
588: 586:                     user,
589: 587:                 )?;
590: 588:                 Ok(I64Update::Add(new_experiment_group.id))
591: 589:             } else {
592: 590:                 Ok(I64Update::Remove)
593: 591:             }
594: 592:         }
595: 593:         // Case 4: All other cases (no change needed)
596: 594:         _ => Ok(current_group_id
597: 595:             .map(I64Update::Add)
598: 596:             .unwrap_or(I64Update::Remove)),
599: 597:     }
600: 598: }
601: 599: 
602: 600: pub fn validate_and_add_experiment_group_id(
603: 601:     member_experiments: &[Experiment],
604: 602:     new_experiment_group_id: &i64,
605: 603:     schema_name: &SchemaName,
606: 604:     transaction_conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
607: 605:     user: &User,
608: 606: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
609: 607:     let now = Utc::now();
610: 608: 
611: 609:     for experiment in member_experiments {
612: 610:         let experiment_id = experiment.id;
613: 611: 
614: 612:         if let Some(existing_group_id) = experiment.experiment_group_id {
615: 613:             if existing_group_id != *new_experiment_group_id {
616: 614:                 return Err(bad_argument!(
617: 615:                     "Experiment {} is already a part of a different experiment group {}",
618: 616:                     experiment_id,
619: 617:                     existing_group_id
620: 618:                 ));
621: 619:             }
622: 620:         }
623: 621: 
624: 622:         let change_reason = ChangeReason::try_from(format!(
625: 623:             "Adding experiment {} to group {}",
626: 624:             experiment_id, new_experiment_group_id
627: 625:         ))
628: 626:         .map_err(|e| unexpected_error!(e))?;
629: 627: 
630: 628:         // Update experiment
631: 629:         diesel::update(experiments::experiments.find(experiment_id))
632: 630:             .set((
633: 631:                 experiments::experiment_group_id
634: 632:                     .eq(I64Update::Add(*new_experiment_group_id)),
635: 633:                 experiments::last_modified_by.eq(&user.get_email()),
636: 634:                 experiments::last_modified.eq(now),
637: 635:                 experiments::change_reason.eq(change_reason),
638: 636:             ))
639: 637:             .returning(Experiment::as_returning())
640: 638:             .schema_name(schema_name)
641: 639:             .execute(transaction_conn)?;
642: 640:     }
643: 641: 
644: 642:     Ok(())
645: 643: }
646: 644: 
647: 645: pub fn validate_and_remove_experiment_group_id(
648: 646:     member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: &[i64],
649: 647:     experiment_group_id: &i64,
650: 648:     schema_name: &SchemaName,
651: 649:     state: &Data<AppState>,
652: 650:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
653: 651:     user: &User,
654: 652: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
655: 653:     let experiment_group =
656: 654:         fetch_experiment_group(experiment_group_id, conn, schema_name)?;
657: 655: 
658: 656:     if experiment_group.group_type == GroupType::SystemGenerated {
659: 657:         return Err(bad_argument!(
660: 658:             "Cannot remove experiments from a system-generated experiment group"
661: 659:         ));
662: 660:     }
663: 661: 
664: 662:     let member_experiments: Vec<Experiment> = experiments::experiments
665: 663:         .filter(experiments::id.eq_any(member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids))
666: 664:         .schema_name(schema_name)
667: 665:         .get_results::<Experiment>(conn)?;
668: 666: 
669: 667:     ensure_experiments_exist(
670: 668:         &HashSet::from_iter(member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.to_owned()),
671: 669:         &member_experiments,
672: 670:         "The following experiment IDs are not present in the database",
673: 671:     )?;
674: 672:     let now = Utc::now();
675: 673: 
676: 674:     for experiment in member_experiments {
677: 675:         let new_experiment_group_id = match experiment.experiment_group_id {
678: 676:             None => {
679: 677:                 return Err(bad_argument!(
680: 678:                     "Experiment with id {} is not part of any experiment group",
681: 679:                     experiment.id
682: 680:                 ));
683: 681:             }
684: 682:             Some(existing_group_id) if existing_group_id != *experiment_group_id => {
685: 683:                 return Err(bad_argument!(
686: 684:                     "Experiment with id {} is part of a different experiment group: {}. Cannot remove from group {}",
687: 685:                     experiment.id,
688: 686:                     existing_group_id,
689: 687:                     experiment_group_id
690: 688:                 ));
691: 689:             }
692: 690:             _ => {
693: 691:                 // Make a new group if Inprogress or Paused
694: 692:                 if experiment.status == ExperimentStatusType::INPROGRESS
695: 693:                     || experiment.status == ExperimentStatusType::PAUSED
696: 694:                 {
697: 695:                     let new_experiment_group = create_system_generated_experiment_group(
698: 696:                         &experiment,
699: 697:                         &experiment.traffic_percentage,
700: 698:                         state,
701: 699:                         conn,
702: 700:                         schema_name,
703: 701:                         user,
704: 702:                     )?;
705: 703:                     I64Update::Add(new_experiment_group.id)
706: 704:                 } else {
707: 705:                     I64Update::Remove
708: 706:                 }
709: 707:             }
710: 708:         };
711: 709: 
712: 710:         let change_reason = ChangeReason::try_from(format!(
713: 711:             "Removing experiment {} from group {}",
714: 712:             experiment.id, experiment_group_id
715: 713:         ))
716: 714:         .map_err(|e| unexpected_error!(e))?;
717: 715: 
718: 716:         diesel::update(experiments::experiments.find(experiment.id))
719: 717:             .set((
720: 718:                 experiments::experiment_group_id.eq(new_experiment_group_id),
721: 719:                 experiments::last_modified_by.eq(&user.get_email()),
722: 720:                 experiments::last_modified.eq(now),
723: 721:                 experiments::change_reason.eq(change_reason),
724: 722:             ))
725: 723:             .returning(Experiment::as_returning())
726: 724:             .schema_name(schema_name)
727: 725:             .execute(conn)?;
728: 726:     }
729: 727: 
730: 728:     Ok(())
731: 729: }
732: 730: 
733: 731: pub fn ensure_experiments_exist(
734: 732:     requested_lyx-core-lyx_core_lyx-core-lyx_core_ids: &HashSet<i64>,
735: 733:     found_experiments: &[Experiment],
736: 734:     error_message: &str,
737: 735: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
738: 736:     let found_lyx-core-lyx_core_lyx-core-lyx_core_ids: HashSet<i64> = found_experiments.iter().map(|e| e.id).collect();
739: 737:     let requested_lyx-core-lyx_core_lyx-core-lyx_core_ids: HashSet<i64> = requested_lyx-core-lyx_core_lyx-core-lyx_core_ids.iter().copied().collect();
740: 738: 
741: 739:     let missing_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: Vec<i64> =
742: 740:         requested_lyx-core-lyx_core_lyx-core-lyx_core_ids.difference(&found_lyx-core-lyx_core_lyx-core-lyx_core_ids).copied().collect();
743: 741:     if !missing_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.is_empty() {
744: 742:         return Err(bad_argument!(
745: 743:             "{}: {}",
746: 744:             error_message,
747: 745:             missing_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids
748: 746:                 .iter()
749: 747:                 .map(|id| id.to_string())
750: 748:                 .collect::<Vec<_>>()
751: 749:                 .join(", ")
752: 750:         ));
753: 751:     }
754: 752:     Ok(())
755: 753: }
756: 754: 
757: 755: pub fn fetch_experiment(
758: 756:     experiment_id: &i64,
759: 757:     conn: &mut DBConnection,
760: 758:     schema_name: &SchemaName,
761: 759: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Experiment> {
762: 760:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::experiments::dsl::*;
763: 761:     let result: Experiment = experiments
764: 762:         .find(experiment_id)
765: 763:         .schema_name(schema_name)
766: 764:         .get_result::<Experiment>(conn)?;
767: 765: 
768: 766:     Ok(result)
769: 767: }
770: 768: 
771: 769: pub async fn validate_control_overrides(
772: 770:     control_overrides: &Exp<Overrides>,
773: 771:     exp_context: &Condition,
774: 772:     workspace_context: &WorkspaceContext,
775: 773:     user: &User,
776: 774:     state: &Data<AppState>,
777: 775: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
778: 776:     let context: &Map<String, Value> = exp_context;
779: 777: 
780: 778:     let resolved_config = get_resolved_config(
781: 779:         user,
782: 780:         state,
783: 781:         &DimensionQuery::from(context.clone()),
784: 782:         ResolveConfigQuery::default(),
785: 783:         workspace_context,
786: 784:     )
787: 785:     .await?;
788: 786:     let control_variant_overrides = control_overrides.clone().into_inner();
789: 787:     let mismatched_overrides: Map<_, _> = control_variant_overrides
790: 788:         .into_iter()
791: 789:         .filter_map(|(key, value)| match resolved_config.get(&key) {
792: 790:             Some(resolved_value) if *resolved_value == value => None,
793: 791:             Some(resolved_value) => Some(Ok((key, resolved_value.clone()))),
794: 792:             None => Some(Err(bad_argument!(
795: 793:                 "Control variant overrides do not match resolved config for key: {key}"
796: 794:             ))),
797: 795:         })
798: 796:         .collect::<lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<_>>()?;
799: 797: 
800: 798:     if !mismatched_overrides.is_empty() {
801: 799:         return Err(bad_argument!(
802: 800:             "Outdated control variant overrides. Please update the control variant's overrides with: {}.",
803: 801:             serde_json::to_string(&mismatched_overrides).unwrap_or_default()
804: 802:         ));
805: 803:     }
806: 804: 
807: 805:     Ok(())
808: 806: }
809: 807: 
810: 808: pub async fn fetch_and_validate_change_reason_with_function(
811: 809:     workspace_context: &WorkspaceContext,
812: 810:     change_reason: &ChangeReason,
813: 811:     state: &Data<AppState>,
814: 812: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
815: 813:     if !workspace_context.settings.enable_change_reason_validation {
816: 814:         return Ok(());
817: 815:     }
818: 816: 
819: 817:     let http_lyx-core-lyx_core_lyx-core-lyx_core_client = reqwest::Client::new();
820: 818:     let url = format!(
821: 819:         "{}/function/{}/{}/test",
822: 820:         state.cac_host,
823: 821:         CHANGE_REASON_VALIDATION_FN_NAME,
824: 822:         Stage::Published
825: 823:     );
826: 824: 
827: 825:     let payload = FunctionExecutionRequest::ChangeReasonValidationFunctionRequest {
828: 826:         change_reason: change_reason.clone(),
829: 827:     };
830: 828: 
831: 829:     let headers_map = construct_header_map(
832: 830:         &workspace_context.workspace_id,
833: 831:         &workspace_context.organisation_id,
834: 832:         vec![],
835: 833:     )?;
836: 834: 
837: 835:     let response = http_lyx-core-lyx_core_lyx-core-lyx_core_client
838: 836:         .post(&url)
839: 837:         .headers(headers_map.into())
840: 838:         .json(&payload)
841: 839:         .send()
842: 840:         .await;
843: 841: 
844: 842:     match response {
845: 843:         Ok(res) => match res.json::<FunctionExecutionResponse>().await {
846: 844:             Ok(response) => {
847: 845:                 log::info!("Change reason validation function response: {:?}", response);
848: 846:                 Ok(())
849: 847:             }
850: 848:             Err(err) => {
851: 849:                 log::error!(
852: 850:                     "Change reason validation function returned false for change reason: {:?} with error: {:?}",
853: 851:                     change_reason,
854: 852:                     err
855: 853:                 );
856: 854:                 Err(bad_argument!("Change reason validation failed."))
857: 855:             }
858: 856:         },
859: 857:         Err(error) => {
860: 858:             log::error!(
861: 859:                 "Failed to fetch change reason function response with error: {:?}",
862: 860:                 error
863: 861:             );
864: 862:             Err(unexpected_error!(error))
865: 863:         }
866: 864:     }
867: 865: }
868: 866: ```
869: 867: ```
870: 868: ```
871: 869: ```
872: ```
```

