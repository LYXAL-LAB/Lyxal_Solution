1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\helpers.rs
10: 8: ```rust
11: 9: use std::collections::{HashMap, HashSet};
12: 10: 
13: 11: use actix_web::{
14: 12:     http::header::{HeaderMap, HeaderName, HeaderValue},
15: 13:     web::Data,
16: 14: };
17: 15: use bigdecimal::{BigDecimal, Num};
18: 16: #[cfg(feature = "high-performance-mode")]
19: 17: use chrono::DateTime;
20: 18: use chrono::Utc;
21: 19: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
22: 20: #[cfg(feature = "high-performance-mode")]
23: 21: use fred::interfaces::KeysInterface;
24: 22: use jsonschema::{Draft, JSONSchema};
25: 23: use num_bigint::BigUint;
26: 24: use serde_json::{Map, Value, json};
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
28: 26:     helpers::{fetch_dimensions_info_map, generate_snowflake_id},
29: 27:     service::types::{AppState, EncryptionKey, SchemaName, WorkspaceContext},
30: 28: };
31: 29: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{db_error, unexpected_error, validation_error};
32: 30: #[cfg(feature = "high-performance-mode")]
33: 31: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::event_log::dsl as event_log;
34: 32: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
35: 33:     Cac, Condition, Config, Context, DBConnection, DimensionInfo, OverrideWithKeys,
36: 34:     Overrides,
37: 35:     api::functions::{
38: 36:         CHANGE_REASON_VALIDATION_FN_NAME, FunctionEnvironment, FunctionExecutionRequest,
39: 37:         FunctionExecutionResponse, KeyType,
40: 38:     },
41: 39:     database::{
42: 40:         models::{
43: 41:             ChangeReason, Description,
44: 42:             cac::{
45: 43:                 ConfigVersion, DependencyGraph, DimensionType, FunctionCode,
46: 44:                 FunctionRuntimeVersion, FunctionType,
47: 45:             },
48: 46:         },
49: 47:         schema::{
50: 48:             config_versions,
51: 49:             contexts::dsl::{self as ctxt},
52: 50:             default_configs::dsl as def_conf,
53: 51:         },
54: 52:     },
55: 53:     logic::dimensions_to_start_from,
56: 54:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
57: 55: };
58: 56: 
59: 57: #[cfg(feature = "high-performance-mode")]
60: 58: use uuid::Uuid;
61: 59: 
62: 60: use crate::{
63: 61:     api::{
64: 62:         context::helpers::validation_function_executor,
65: 63:         functions::{
66: 64:             helpers::{get_first_function_by_type, get_published_function_code},
67: 65:             types::FunctionInfo,
68: 66:         },
69: 67:     },
70: 68:     validation_functions::execute_fn,
71: 69: };
72: 70: 
73: 71: pub fn parse_headermap_safe(headermap: &HeaderMap) -> HashMap<String, String> {
74: 72:     let mut req_headers = HashMap::new();
75: 73:     let record_header = |(header_name, header_val): (&HeaderName, &HeaderValue)| {
76: 74:         let header_val = match header_val.to_str() {
77: 75:             Ok(s) => String::from(s),
78: 76:             Err(e) => {
79: 77:                 log::error!(
80: 78:                     "unable to parse value of header {}, error: {e}",
81: 79:                     header_name
82: 80:                 );
83: 81:                 String::from("Error: non ASCII header value")
84: 82:             }
85: 83:         };
86: 84:         req_headers.insert(header_name.to_string(), header_val);
87: 85:     };
88: 86:     headermap.iter().for_each(record_header);
89: 87:     req_headers
90: 88: }
91: 89: 
92: 90: pub fn get_meta_schema() -> JSONSchema {
93: 91:     let my_schema = json!({
94: 92:         "type": "object",
95: 93:         "properties": {
96: 94:             "type": {
97: 95:                 "enum": ["boolean", "number", "integer", "string", "array", "null"]
98: 96:             },
99: 97:         },
100: 98:         "required": ["type"],
101: 99:     });
102: 100: 
103: 101:     JSONSchema::options()
104: 102:         .with_draft(Draft::Draft7)
105: 103:         .compile(&my_schema)
106: 104:         .expect("Error encountered: Failed to compile 'context_dimension_schema_value'. Ensure it adheres to the correct format and data type.")
107: 105: }
108: 106: 
109: 107: fn calculate_weight_from_index(index: u32) -> Result<BigDecimal, String> {
110: 108:     let base = BigUint::from(2u32);
111: 109:     let result = base.pow(index);
112: 110:     let biguint_str = &result.to_str_radix(10);
113: 111:     BigDecimal::from_str_radix(biguint_str, 10).map_err(|err| {
114: 112:         log::error!("failed to parse bigdecimal with error: {}", err.to_string());
115: 113:         String::from("failed to parse bigdecimal with error")
116: 114:     })
117: 115: }
118: 116: 
119: 117: pub fn calculate_context_weight(
120: 118:     cond: &Value,
121: 119:     dimension_position_map: &HashMap<String, DimensionInfo>,
122: 120: ) -> Result<BigDecimal, String> {
123: 121:     let dimensions: HashSet<String> = cond
124: 122:         .as_object()
125: 123:         .map(|o| o.keys().cloned().collect())
126: 124:         .unwrap_or_default();
127: 125: 
128: 126:     let mut weight = BigDecimal::from(0);
129: 127:     for dimension in dimensions {
130: 128:         let position = dimension_position_map
131: 129:             .get(dimension.clone().as_str())
132: 130:             .map(|x| x.position)
133: 131:             .ok_or_else(|| {
134: 132:                 let msg =
135: 133:                     format!("Dimension:{} not found in Dimension schema map", dimension);
136: 134:                 log::error!("{}", msg);
137: 135:                 msg
138: 136:             })?;
139: 137:         weight += calculate_weight_from_index(position as u32)?;
140: 138:     }
141: 139:     Ok(weight)
142: 140: }
143: 141: pub fn generate_cac(
144: 142:     conn: &mut DBConnection,
145: 143:     schema_name: &SchemaName,
146: 144: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Config> {
147: 145:     let contexts_vec: Vec<(String, Condition, String, Overrides)> = ctxt::contexts
148: 146:         .select((ctxt::id, ctxt::value, ctxt::override_id, ctxt::override_))
149: 147:         .order_by((ctxt::weight.asc(), ctxt::created_at.asc()))
150: 148:         .schema_name(schema_name)
151: 149:         .load::<(String, Condition, String, Overrides)>(conn)
152: 150:         .map_err(|err| {
153: 151:             log::error!("failed to fetch contexts with error: {}", err);
154: 152:             db_error!(err)
155: 153:         })?;
156: 154:     let contexts_vec: Vec<(String, Condition, i32, String, Overrides)> = contexts_vec
157: 155:         .iter()
158: 156:         .enumerate()
159: 157:         .map(|(index, (id, value, override_id, override_))| {
160: 158:             (
161: 159:                 id.clone(),
162: 160:                 value.clone(),
163: 161:                 index as i32,
164: 162:                 override_id.clone(),
165: 163:                 override_.clone(),
166: 164:             )
167: 165:         })
168: 166:         .collect();
169: 167: 
170: 168:     let mut contexts = Vec::new();
171: 169:     let mut overrides: HashMap<String, Overrides> = HashMap::new();
172: 170: 
173: 171:     for (id, condition, weight, override_id, override_) in contexts_vec.iter() {
174: 172:         let condition = Cac::<Condition>::validate_db_data(condition.clone().into())
175: 173:             .map_err(|err| {
176: 174:                 log::error!("generate_cac : failed to decode context from db {}", err);
177: 175:                 unexpected_error!(err)
178: 176:             })?
179: 177:             .into_inner();
180: 178: 
181: 179:         let override_ = Cac::<Overrides>::validate_db_data(override_.clone().into())
182: 180:             .map_err(|err| {
183: 181:                 log::error!("generate_cac : failed to decode overrides from db {}", err);
184: 182:                 unexpected_error!(err)
185: 183:             })?
186: 184:             .into_inner();
187: 185:         let ctxt = Context {
188: 186:             id: id.to_owned(),
189: 187:             condition,
190: 188:             priority: weight.to_owned(),
191: 189:             weight: weight.to_owned(),
192: 190:             override_with_keys: OverrideWithKeys::new(override_id.to_owned()),
193: 191:         };
194: 192:         contexts.push(ctxt);
195: 193:         overrides.insert(override_id.to_owned(), override_);
196: 194:     }
197: 195: 
198: 196:     let default_config_vec = def_conf::default_configs
199: 197:         .select((def_conf::key, def_conf::value))
200: 198:         .schema_name(schema_name)
201: 199:         .load::<(String, Value)>(conn)
202: 200:         .map_err(|err| {
203: 201:             log::error!("failed to fetch default_configs with error: {}", err);
204: 202:             db_error!(err)
205: 203:         })?;
206: 204: 
207: 205:     let default_configs =
208: 206:         default_config_vec
209: 207:             .into_iter()
210: 208:             .fold(Map::new(), |mut acc, item| {
211: 209:                 acc.insert(item.0, item.1);
212: 210:                 acc
213: 211:             });
214: 212: 
215: 213:     let dimensions = fetch_dimensions_info_map(conn, schema_name)?;
216: 214: 
217: 215:     Ok(Config {
218: 216:         contexts,
219: 217:         overrides,
220: 218:         default_configs,
221: 219:         dimensions,
222: 220:     })
223: 221: }
224: 222: 
225: 223: pub fn add_config_version(
226: 224:     state: &Data<AppState>,
227: 225:     tags: Option<Vec<String>>,
228: 226:     description: Description,
229: 227:     db_conn: &mut DBConnection,
230: 228:     schema_name: &SchemaName,
231: 229: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<i64> {
232: 230:     use config_versions::dsl::config_versions;
233: 231:     let version_id = generate_snowflake_id(state)?;
234: 232:     let config = generate_cac(db_conn, schema_name)?;
235: 233:     let json_config = json!(config);
236: 234:     let config_hash = blake3::hash(json_config.to_string().as_bytes()).to_string();
237: 235:     let config_version = ConfigVersion {
238: 236:         id: version_id,
239: 237:         config: json_config,
240: 238:         config_hash,
241: 239:         tags,
242: 240:         created_at: Utc::now(),
243: 241:         description,
244: 242:     };
245: 243:     diesel::insert_into(config_versions)
246: 244:         .values(&config_version)
247: 245:         .returning(ConfigVersion::as_returning())
248: 246:         .schema_name(schema_name)
249: 247:         .execute(db_conn)?;
250: 248:     Ok(version_id)
251: 249: }
252: 250: 
253: 251: #[cfg(feature = "high-performance-mode")]
254: 252: pub async fn put_config_in_redis(
255: 253:     version_id: i64,
256: 254:     state: Data<AppState>,
257: 255:     schema_name: &SchemaName,
258: 256:     db_conn: &mut DBConnection,
259: 257: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
260: 258:     let raw_config = generate_cac(db_conn, schema_name)?;
261: 259:     let parsed_config = serde_json::to_string(&json!(raw_config)).map_err(|e| {
262: 260:         log::error!("failed to convert cac config to string: {}", e);
263: 261:         unexpected_error!("could not convert cac config to string")
264: 262:     })?;
265: 263:     let config_key = format!("{}::cac_config", **schema_name);
266: 264:     let last_modified_at_key = format!("{}::cac_config::last_modified_at", **schema_name);
267: 265:     let audit_id_key = format!("{}::cac_config::audit_id", **schema_name);
268: 266:     let config_version_key = format!("{}::cac_config::config_version", **schema_name);
269: 267:     let last_modified = DateTime::to_rfc2822(&Utc::now());
270: 268:     let _ = state
271: 269:         .redis
272: 270:         .set::<(), String, String>(config_key, parsed_config, None, None, false)
273: 271:         .await;
274: 272:     let _ = state
275: 273:         .redis
276: 274:         .set::<(), String, String>(last_modified_at_key, last_modified, None, None, false)
277: 275:         .await;
278: 276:     if let Ok(uuid) = event_log::event_log
279: 277:         .select(event_log::id)
280: 278:         .filter(event_log::table_name.eq("contexts"))
281: 279:         .order_by(event_log::timestamp.desc())
282: 280:         .first::<Uuid>(db_conn)
283: 281:     {
284: 282:         let _ = state
285: 283:             .redis
286: 284:             .set::<(), String, String>(audit_id_key, uuid.to_string(), None, None, false)
287: 285:             .await;
288: 286:     }
289: 287:     let _ = state
290: 288:         .redis
291: 289:         .set::<(), String, i64>(config_version_key, version_id, None, None, false)
292: 290:         .await;
293: 291:     Ok(())
294: 292: }
295: 293: 
296: 294: #[allow(clippy::too_many_arguments)]
297: 295: fn compute_value_with_function(
298: 296:     workspace_context: &WorkspaceContext,
299: 297:     fun_name: &str,
300: 298:     function: &FunctionCode,
301: 299:     key: &str,
302: 300:     context: Map<String, Value>,
303: 301:     overrides: Map<String, Value>,
304: 302:     runtime_version: FunctionRuntimeVersion,
305: 303:     conn: &mut DBConnection,
306: 304:     master_encryption_key: &Option<EncryptionKey>,
307: 305: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Value> {
308: 306:     match execute_fn(
309: 307:         workspace_context,
310: 308:         function,
311: 309:         &FunctionExecutionRequest::ValueComputeFunctionRequest {
312: 310:             name: key.to_string(),
313: 311:             prefix: String::new(),
314: 312:             r#type: KeyType::Dimension,
315: 313:             environment: FunctionEnvironment { context, overrides },
316: 314:         },
317: 315:         runtime_version,
318: 316:         conn,
319: 317:         master_encryption_key,
320: 318:     ) {
321: 319:         Err((err, stdout)) => {
322: 320:             let stdout = stdout.unwrap_or_default();
323: 321:             log::error!(
324: 322:                 "function {fun_name} computation failed for {key} with error: {err}"
325: 323:             );
326: 324:             Err(validation_error!(
327: 325:                 "Function {fun_name} computation failed for {} with error {}. {}",
328: 326:                 key,
329: 327:                 err,
330: 328:                 stdout
331: 329:             ))
332: 330:         }
333: 331:         Ok(FunctionExecutionResponse {
334: 332:             fn_output, stdout, ..
335: 333:         }) => {
336: 334:             log::debug!("Function execution returned: {:?}", fn_output);
337: 335:             match fn_output {
338: 336:                 Value::Array(arr) if arr.len() == 1 => Ok(arr[0].clone()),
339: 337:                 _ => {
340: 338:                     log::error!(
341: 339:                         "Computation function {fun_name} returned invalid output, logs are {stdout}"
342: 340:                     );
343: 341:                     Err(validation_error!(
344: 342:                         "Computation function {fun_name} returned invalid output, please check your inputs",
345: 343:                     ))
346: 344:                 }
347: 345:             }
348: 346:         }
349: 347:     }
350: 348: }
351: 349: 
352: 350: /// Evaluates dependencies of local cohort dimensions recursively using depth-first traversal
353: 351: fn evaluate_remote_cohorts_dependency(
354: 352:     dimension: &str,
355: 353:     dependency_graph: &DependencyGraph,
356: 354:     dimensions: &HashMap<String, DimensionInfo>,
357: 355:     modified_context: &mut Map<String, Value>,
358: 356:     conn: &mut DBConnection,
359: 357:     workspace_context: &WorkspaceContext,
360: 358:     master_encryption_key: &Option<EncryptionKey>,
361: 359: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
362: 360:     let mut stack = dependency_graph
363: 361:         .get(dimension)
364: 362:         .cloned()
365: 363:         .unwrap_or_default()
366: 364:         .into_iter()
367: 365:         .map(|d| (d, dimension.to_string()))
368: 366:         .collect::<Vec<_>>();
369: 367: 
370: 368:     // Depth-first traversal of dependencies
371: 369:     while let Some((ref cohort_dimension, ref based_on)) = stack.pop() {
372: 370:         if let Some(data) = dimensions.get(cohort_dimension) {
373: 371:             if matches!(data.dimension_type, DimensionType::LocalCohort(_)) {
374: 372:                 continue;
375: 373:             }
376: 374: 
377: 375:             let Some(ref value_compute_function_name_) = data.value_compute_function_name
378: 376:             else {
379: 377:                 return Err(validation_error!(
380: 378:                     "Value compute function not found for {cohort_dimension}",
381: 379:                 ));
382: 380:             };
383: 381: 
384: 382:             let FunctionInfo {
385: 383:                 published_code,
386: 384:                 published_runtime_version,
387: 385:                 ..
388: 386:             } = get_published_function_code(
389: 387:                 conn,
390: 388:                 value_compute_function_name_,
391: 389:                 FunctionType::ValueCompute,
392: 390:                 &workspace_context.schema_name,
393: 391:             )?;
394: 392: 
395: 393:             let fn_code = published_code.ok_or_else(|| {
396: 394:                 validation_error!(
397: 395:                     "Published code not found for function {}",
398: 396:                     value_compute_function_name_
399: 397:                 )
400: 398:             })?;
401: 399: 
402: 400:             let published_runtime_version =
403: 401:                 published_runtime_version.ok_or_else(|| {
404: 402:                     validation_error!(
405: 403:                         "Published runtime version not found for function {}",
406: 404:                         value_compute_function_name_
407: 405:                     )
408: 406:                 })?;
409: 407: 
410: 408:             let value = compute_value_with_function(
411: 409:                 workspace_context,
412: 410:                 value_compute_function_name_,
413: 411:                 &fn_code,
414: 412:                 based_on,
415: 413:                 modified_context.clone(),
416: 414:                 Map::new(),
417: 415:                 published_runtime_version,
418: 416:                 conn,
419: 417:                 master_encryption_key,
420: 418:             )?;
421: 419: 
422: 420:             modified_context.insert(cohort_dimension.clone(), value);
423: 421: 
424: 422:             stack.extend(
425: 423:                 dependency_graph
426: 424:                     .get(cohort_dimension)
427: 425:                     .cloned()
428: 426:                     .unwrap_or_default()
429: 427:                     .into_iter()
430: 428:                     .map(|d| (d, cohort_dimension.clone()))
431: 429:                     .collect::<Vec<_>>(),
432: 430:             );
433: 431:         }
434: 432:     }
435: 433:     Ok(())
436: 434: }
437: 435: 
438: 436: /// Evaluates all remote cohort dimensions based on the provided query data and dimension definitions
439: 437: /// First, all remote cohort dependents of regular and remote dimensions are evaluated, starting from
440: 438: /// the dimensions present in query_data such that for each tree in the dependency graph,
441: 439: /// the node closest to root from query_data is picked for each branch of the tree.
442: 440: /// Next, local cohort dimensions from query_data are inserted into the modified context.
443: 441: ///
444: 442: /// Values of regular and local cohort dimensions in query_data are not modified.
445: 443: /// Returned value, might have a different value for remote cohort dimensions based on its based on dimensions,
446: 444: /// if the value provided for the remote cohort was incorrect in the query data.
447: 445: pub fn evaluate_remote_cohorts(
448: 446:     dimensions: &HashMap<String, DimensionInfo>,
449: 447:     query_data: &Map<String, Value>,
450: 448:     conn: &mut DBConnection,
451: 449:     workspace_context: &WorkspaceContext,
452: 450:     master_encryption_key: &Option<EncryptionKey>,
453: 451: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Map<String, Value>> {
454: 452:     let mut modified_context = Map::new();
455: 453: 
456: 454:     // First, evaluate all remote cohort dimensions and their dependencies
457: 455:     for dimension_key in dimensions_to_start_from(dimensions, query_data) {
458: 456:         if let Some(value) = query_data.get(&dimension_key) {
459: 457:             if let Some(data) = dimensions.get(&dimension_key) {
460: 458:                 match data.dimension_type {
461: 459:                     DimensionType::LocalCohort(_) => continue,
462: 460:                     DimensionType::Regular {} | DimensionType::RemoteCohort(_) => {
463: 461:                         modified_context.insert(dimension_key.to_string(), value.clone());
464: 462:                         evaluate_remote_cohorts_dependency(
465: 463:                             &dimension_key,
466: 464:                             &data.dependency_graph,
467: 465:                             dimensions,
468: 466:                             &mut modified_context,
469: 467:                             conn,
470: 468:                             workspace_context,
471: 469:                             master_encryption_key,
472: 470:                         )?;
473: 471:                     }
474: 472:                 }
475: 473:             }
476: 474:         }
477: 475:     }
478: 476: 
479: 477:     // Next, insert local cohort dimensions from query_data into modified_context
480: 478:     for (dimension_key, value) in query_data {
481: 479:         if let Some(data) = dimensions.get(dimension_key) {
482: 480:             if matches!(data.dimension_type, DimensionType::LocalCohort(_)) {
483: 481:                 modified_context.insert(dimension_key.to_string(), value.clone());
484: 482:             }
485: 483:         }
486: 484:     }
487: 485: 
488: 486:     Ok(modified_context)
489: 487: }
490: 488: 
491: 489: pub fn validate_change_reason(
492: 490:     workspace_context: &WorkspaceContext,
493: 491:     change_reason: &ChangeReason,
494: 492:     conn: &mut DBConnection,
495: 493:     master_encryption_key: &Option<EncryptionKey>,
496: 494: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
497: 495:     if !workspace_context.settings.enable_change_reason_validation {
498: 496:         return Ok(());
499: 497:     }
500: 498: 
501: 499:     let change_reason_validation_function = get_first_function_by_type(
502: 500:         FunctionType::ChangeReasonValidation,
503: 501:         conn,
504: 502:         &workspace_context.schema_name,
505: 503:     )?;
506: 504:     if let (Some(function_code), Some(published_runtime_version)) = (
507: 505:         change_reason_validation_function.published_code,
508: 506:         change_reason_validation_function.published_runtime_version,
509: 507:     ) {
510: 508:         validation_function_executor(
511: 509:             workspace_context,
512: 510:             CHANGE_REASON_VALIDATION_FN_NAME,
513: 511:             &function_code,
514: 512:             &FunctionExecutionRequest::ChangeReasonValidationFunctionRequest {
515: 513:                 change_reason: change_reason.clone(),
516: 514:             },
517: 515:             published_runtime_version,
518: 516:             conn,
519: 517:             master_encryption_key,
520: 518:         )?;
521: 519:     }
522: 520:     Ok(())
523: 521: }
524: 522: 
525: 523: // ************ Tests *************
526: 524: 
527: 525: #[cfg(test)]
528: 526: mod tests {
529: 527:     use std::str::FromStr;
530: 528: 
531: 529:     use super::*;
532: 530: 
533: 531:     #[test]
534: 532:     fn test_calculate_weight_from_index() {
535: 533:         let number_2_100_str = "1267650600228229401496703205376";
536: 534:         // test 2^100
537: 535:         let big_decimal =
538: 536:             BigDecimal::from_str(number_2_100_str).expect("Invalid string format");
539: 537: 
540: 538:         let number_2_200_str =
541: 539:             "1606938044258990275541962092341162602522202993782792835301376";
542: 540:         // test 2^100
543: 541:         let big_decimal_200 =
544: 542:             BigDecimal::from_str(number_2_200_str).expect("Invalid string format");
545: 543: 
546: 544:         assert_eq!(Some(big_decimal), calculate_weight_from_index(100).ok());
547: 545:         assert_eq!(Some(big_decimal_200), calculate_weight_from_index(200).ok());
548: 546:     }
549: 547: }
550: 548: ```
551: 549: ```
552: 550: ```
553: 551: ```
554: ```
```

