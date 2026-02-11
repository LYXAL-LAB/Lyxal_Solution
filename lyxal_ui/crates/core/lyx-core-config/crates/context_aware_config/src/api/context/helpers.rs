### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\context\helpers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\helpers.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: use std::str;
13: 11: 
14: 12: use lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client::utils::json_to_sorted_string;
15: 13: use chrono::Utc;
16: 14: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
17: 15: use serde_json::{Map, Value};
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
19: 17:     helpers::fetch_dimensions_info_map,
20: 18:     service::types::{EncryptionKey, SchemaName, WorkspaceContext},
21: 19: };
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{unexpected_error, validation_error};
23: 21: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
24: 22:     Cac, Condition, DBConnection, DimensionInfo, Overrides, User,
25: 23:     api::{
26: 24:         context::PutRequest,
27: 25:         functions::{
28: 26:             CONTEXT_VALIDATION_FN_NAME, FunctionEnvironment, FunctionExecutionRequest,
29: 27:             FunctionExecutionResponse, KeyType,
30: 28:         },
31: 29:     },
32: 30:     database::{
33: 31:         models::{
34: 32:             Description,
35: 33:             cac::{Context, FunctionCode, FunctionRuntimeVersion, FunctionType},
36: 34:         },
37: 35:         schema::{contexts, default_configs::dsl, dimensions},
38: 36:     },
39: 37:     logic::dimensions_to_start_from,
40: 38:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
41: 39: };
42: 40: 
43: 41: use crate::api::functions::helpers::get_first_function_by_type;
44: 42: use crate::helpers::calculate_context_weight;
45: 43: use crate::{
46: 44:     api::functions::{helpers::get_published_functions_by_names, types::FunctionInfo},
47: 45:     validation_functions::execute_fn,
48: 46: };
49: 47: 
50: 48: use super::validations::{validate_dimensions, validate_override_with_default_configs};
51: 49: 
52: 50: pub fn hash(val: &Value) -> String {
53: 51:     let sorted_str: String = json_to_sorted_string(val);
54: 52:     blake3::hash(sorted_str.as_bytes()).to_string()
55: 53: }
56: 54: 
57: 55: pub fn validate_condition_with_mandatory_dimensions(
58: 56:     context_map: &Map<String, Value>,
59: 57:     mandatory_dimensions: &Vec<String>,
60: 58: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
61: 59:     let dimensions_list: Vec<String> = context_map.keys().cloned().collect();
62: 60:     let all_mandatory_present = mandatory_dimensions
63: 61:         .iter()
64: 62:         .all(|dimension| dimensions_list.contains(dimension));
65: 63:     if !all_mandatory_present {
66: 64:         return Err(validation_error!(
67: 65:             "The context should contain all the mandatory dimensions : {:?}.",
68: 66:             mandatory_dimensions,
69: 67:         ));
70: 68:     }
71: 69:     Ok(())
72: 70: }
73: 71: 
74: 72: /// Given a set of dimensions and a context map, validate that dependent dimensions,
75: 73: ///  of the given dimensions in context, are not present
76: 74: fn validate_condition_with_dependent_dimensions(
77: 75:     dimensions: &HashMap<String, DimensionInfo>,
78: 76:     context_map: &Map<String, Value>,
79: 77: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
80: 78:     let required_dimensions = dimensions_to_start_from(dimensions, context_map);
81: 79: 
82: 80:     let invalid_dimensions = context_map
83: 81:         .keys()
84: 82:         .filter(|dimension_key| !required_dimensions.contains(dimension_key))
85: 83:         .cloned()
86: 84:         .collect::<Vec<_>>();
87: 85: 
88: 86:     let mut error_messages = Vec::new();
89: 87:     for dim_key in required_dimensions {
90: 88:         if let Some(dependents) = dimensions
91: 89:             .get(&dim_key)
92: 90:             .map(|d| d.dependency_graph.keys().cloned().collect::<Vec<_>>())
93: 91:         {
94: 92:             for invalid_dimension in &invalid_dimensions {
95: 93:                 if dependents.contains(invalid_dimension) {
96: 94:                     error_messages.push(format!(
97: 95:                         "{} can be derived from {} dimension",
98: 96:                         invalid_dimension, dim_key
99: 97:                     ));
100: 98:                 }
101: 99:             }
102: 100:         }
103: 101:     }
104: 102: 
105: 103:     if !error_messages.is_empty() {
106: 104:         return Err(validation_error!(
107: 105:             "Cohort Dimension(s): [ {} ] using the cohort definitions. Hence, usage of this/these dimension(s) is not allowed.",
108: 106:             error_messages.join(", ")
109: 107:         ));
110: 108:     }
111: 109: 
112: 110:     Ok(())
113: 111: }
114: 112: 
115: 113: pub fn validate_condition_with_functions(
116: 114:     workspace_context: &WorkspaceContext,
117: 115:     conn: &mut DBConnection,
118: 116:     context_map: &Map<String, Value>,
119: 117:     override_: &Map<String, Value>,
120: 118:     is_context_validation_enabled: bool,
121: 119:     master_encryption_key: &Option<EncryptionKey>,
122: 120: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
123: 121:     use dimensions::dsl;
124: 122:     let dimensions_list: Vec<String> = context_map.keys().cloned().collect();
125: 123:     let keys_function_array: Vec<(String, Option<String>)> = dsl::dimensions
126: 124:         .filter(dsl::dimension.eq_any(dimensions_list))
127: 125:         .select((dsl::dimension, dsl::value_validation_function_name))
128: 126:         .schema_name(&workspace_context.schema_name)
129: 127:         .load(conn)?;
130: 128:     let new_keys_function_array: Vec<(String, String)> = keys_function_array
131: 129:         .into_iter()
132: 130:         .filter_map(|(key, f_name)| f_name.map(|func| (key, func)))
133: 131:         .collect();
134: 132: 
135: 133:     let context_validation_function = get_first_function_by_type(
136: 134:         FunctionType::ContextValidation,
137: 135:         conn,
138: 136:         &workspace_context.schema_name,
139: 137:     )?;
140: 138: 
141: 139:     let environment = FunctionEnvironment {
142: 140:         context: context_map.clone(),
143: 141:         overrides: override_.clone(),
144: 142:     };
145: 143: 
146: 144:     // workspace_setting check
147: 145:     if is_context_validation_enabled {
148: 146:         if let (Some(function_code), Some(published_runtime_version)) = (
149: 147:             context_validation_function.published_code,
150: 148:             context_validation_function.published_runtime_version,
151: 149:         ) {
152: 150:             validation_function_executor(
153: 151:                 workspace_context,
154: 152:                 CONTEXT_VALIDATION_FN_NAME,
155: 153:                 &function_code,
156: 154:                 &FunctionExecutionRequest::ContextValidationFunctionRequest {
157: 155:                     environment: environment.clone(),
158: 156:                 },
159: 157:                 published_runtime_version,
160: 158:                 conn,
161: 159:                 master_encryption_key,
162: 160:             )?;
163: 161:         }
164: 162:     }
165: 163: 
166: 164:     let dimension_functions_map = get_functions_map(
167: 165:         conn,
168: 166:         new_keys_function_array,
169: 167:         FunctionType::ValueValidation,
170: 168:         &workspace_context.schema_name,
171: 169:     )?;
172: 170:     for (key, value) in context_map.iter() {
173: 171:         if let Some(functions_map) = dimension_functions_map.get(key) {
174: 172:             if let (function_name, Some(function_code), Some(published_runtime_version)) = (
175: 173:                 functions_map.function_name.clone(),
176: 174:                 functions_map.published_code.clone(),
177: 175:                 functions_map.published_runtime_version,
178: 176:             ) {
179: 177:                 validation_function_executor(
180: 178:                     workspace_context,
181: 179:                     &function_name,
182: 180:                     &function_code,
183: 181:                     &FunctionExecutionRequest::ValueValidationFunctionRequest {
184: 182:                         key: key.clone(),
185: 183:                         value: value.to_owned(),
186: 184:                         r#type: KeyType::Dimension,
187: 185:                         environment: environment.clone(),
188: 186:                     },
189: 187:                     published_runtime_version,
190: 188:                     conn,
191: 189:                     master_encryption_key,
192: 190:                 )?;
193: 191:             }
194: 192:         }
195: 193:     }
196: 194:     Ok(())
197: 195: }
198: 196: 
199: 197: pub fn validate_override_with_functions(
200: 198:     workspace_context: &WorkspaceContext,
201: 199:     conn: &mut DBConnection,
202: 200:     override_: &Map<String, Value>,
203: 201:     context: &Map<String, Value>,
204: 202:     master_encryption_key: &Option<EncryptionKey>,
205: 203: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
206: 204:     let default_config_keys: Vec<String> = override_.keys().cloned().collect();
207: 205:     let keys_function_array: Vec<(String, Option<String>)> = dsl::default_configs
208: 206:         .filter(dsl::key.eq_any(default_config_keys))
209: 207:         .select((dsl::key, dsl::value_validation_function_name))
210: 208:         .schema_name(&workspace_context.schema_name)
211: 209:         .load(conn)?;
212: 210:     let new_keys_function_array: Vec<(String, String)> = keys_function_array
213: 211:         .into_iter()
214: 212:         .filter_map(|(key_, f_name)| f_name.map(|func| (key_, func)))
215: 213:         .collect();
216: 214: 
217: 215:     let default_config_functions_map = get_functions_map(
218: 216:         conn,
219: 217:         new_keys_function_array,
220: 218:         FunctionType::ValueValidation,
221: 219:         &workspace_context.schema_name,
222: 220:     )?;
223: 221:     for (key, value) in override_.iter() {
224: 222:         if let Some(functions_map) = default_config_functions_map.get(key) {
225: 223:             if let (function_name, Some(function_code), Some(published_runtime_version)) = (
226: 224:                 functions_map.function_name.clone(),
227: 225:                 functions_map.published_code.clone(),
228: 226:                 functions_map.published_runtime_version,
229: 227:             ) {
230: 228:                 validation_function_executor(
231: 229:                     workspace_context,
232: 230:                     &function_name,
233: 231:                     &function_code,
234: 232:                     &FunctionExecutionRequest::ValueValidationFunctionRequest {
235: 233:                         key: key.clone(),
236: 234:                         value: value.to_owned(),
237: 235:                         r#type: KeyType::ConfigKey,
238: 236:                         environment: FunctionEnvironment {
239: 237:                             context: context.clone(),
240: 238:                             overrides: override_.clone(),
241: 239:                         },
242: 240:                     },
243: 241:                     published_runtime_version,
244: 242:                     conn,
245: 243:                     master_encryption_key,
246: 244:                 )?;
247: 245:             }
248: 246:         }
249: 247:     }
250: 248:     Ok(())
251: 249: }
252: 250: 
253: 251: fn get_functions_map(
254: 252:     conn: &mut DBConnection,
255: 253:     keys_function_array: Vec<(String, String)>,
256: 254:     function_type: FunctionType,
257: 255:     schema_name: &SchemaName,
258: 256: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HashMap<String, FunctionInfo>> {
259: 257:     let functions_map: HashMap<String, FunctionInfo> = get_published_functions_by_names(
260: 258:         conn,
261: 259:         keys_function_array
262: 260:             .iter()
263: 261:             .map(|(_, f_name)| f_name.clone())
264: 262:             .collect(),
265: 263:         function_type,
266: 264:         schema_name,
267: 265:     )?
268: 266:     .into_iter()
269: 267:     .map(|functions_info| (functions_info.function_name.clone(), functions_info))
270: 268:     .collect();
271: 269: 
272: 270:     // primitives here either imply dimensions or default configs based on who is calling it
273: 271:     let function_to_primitives_map: HashMap<String, FunctionInfo> = keys_function_array
274: 272:         .into_iter()
275: 273:         .filter_map(|(key, function_name)| {
276: 274:             functions_map
277: 275:                 .get(&function_name)
278: 276:                 .cloned()
279: 277:                 .map(|func_info| (key, func_info))
280: 278:         })
281: 279:         .collect();
282: 280: 
283: 281:     Ok(function_to_primitives_map)
284: 282: }
285: 283: 
286: 284: pub fn validation_function_executor(
287: 285:     workspace_context: &WorkspaceContext,
288: 286:     fun_name: &str,
289: 287:     function: &FunctionCode,
290: 288:     args: &FunctionExecutionRequest,
291: 289:     runtime_version: FunctionRuntimeVersion,
292: 290:     conn: &mut DBConnection,
293: 291:     master_encryption_key: &Option<EncryptionKey>,
294: 292: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
295: 293:     match execute_fn(
296: 294:         workspace_context,
297: 295:         function,
298: 296:         args,
299: 297:         runtime_version,
300: 298:         conn,
301: 299:         master_encryption_key,
302: 300:     ) {
303: 301:         Err((err, stdout)) => {
304: 302:             let stdout = stdout.unwrap_or_default();
305: 303:             let key = args.function_identifier();
306: 304:             log::error!("function validation failed for {key} with error: {err}");
307: 305:             Err(validation_error!(
308: 306:                 "Function {fun_name} validation failed for {} with error {}. {}",
309: 307:                 key,
310: 308:                 err,
311: 309:                 stdout
312: 310:             ))
313: 311:         }
314: 312:         Ok(FunctionExecutionResponse {
315: 313:             fn_output, stdout, ..
316: 314:         }) => {
317: 315:             log::debug!("Function execution returned: {:?}", fn_output);
318: 316:             if fn_output.as_bool().unwrap_or_default() {
319: 317:                 Ok(())
320: 318:             } else {
321: 319:                 log::error!(
322: 320:                     "Validation function {fun_name} returned false, logs are {stdout}"
323: 321:                 );
324: 322:                 Err(validation_error!(
325: 323:                     "Validation function {fun_name} returned false, please check your inputs",
326: 324:                 ))
327: 325:             }
328: 326:         }
329: 327:     }
330: 328: }
331: 329: 
332: 330: pub fn query_description(
333: 331:     context: Value,
334: 332:     transaction_conn: &mut diesel::PgConnection,
335: 333:     schema_name: &SchemaName,
336: 334: ) -> Result<Description, lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
337: 335:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::schema::contexts::dsl::{
338: 336:         contexts as contexts_table, id as context_id,
339: 337:     };
340: 338: 
341: 339:     let context_id_value = hash(&context);
342: 340: 
343: 341:     let existing_context = contexts_table
344: 342:         .filter(context_id.eq(context_id_value))
345: 343:         .schema_name(schema_name)
346: 344:         .first::<Context>(transaction_conn)?;
347: 345: 
348: 346:     Ok(existing_context.description)
349: 347: }
350: 348: 
351: 349: pub fn create_ctx_from_put_req(
352: 350:     req: PutRequest,
353: 351:     req_description: Description,
354: 352:     conn: &mut DBConnection,
355: 353:     user: &User,
356: 354:     workspace_context: &WorkspaceContext,
357: 355:     master_encryption_key: &Option<EncryptionKey>,
358: 356: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Context> {
359: 357:     let ctx_condition = req.context.to_owned().into_inner();
360: 358:     let condition_val = Value::Object(ctx_condition.clone().into());
361: 359:     let r_override = req.r#override.clone().into_inner();
362: 360:     let ctx_override = Value::Object(r_override.clone().into());
363: 361: 
364: 362:     let dimension_data_map = validate_ctx(
365: 363:         conn,
366: 364:         workspace_context,
367: 365:         ctx_condition.clone(),
368: 366:         r_override.clone(),
369: 367:         master_encryption_key,
370: 368:     )?;
371: 369:     let change_reason = req.change_reason.clone();
372: 370: 
373: 371:     validate_override_with_default_configs(
374: 372:         conn,
375: 373:         &r_override,
376: 374:         &workspace_context.schema_name,
377: 375:     )?;
378: 376:     validate_override_with_functions(
379: 377:         workspace_context,
380: 378:         conn,
381: 379:         &r_override,
382: 380:         &ctx_condition.clone(),
383: 381:         master_encryption_key,
384: 382:     )?;
385: 383: 
386: 384:     let weight = calculate_context_weight(&condition_val, &dimension_data_map)
387: 385:         .map_err(|_| unexpected_error!("Something Went Wrong"))?;
388: 386: 
389: 387:     let context_id = hash(&condition_val);
390: 388:     let override_id = hash(&ctx_override);
391: 389:     Ok(Context {
392: 390:         id: context_id,
393: 391:         value: ctx_condition,
394: 392:         override_id,
395: 393:         override_: r_override,
396: 394:         created_at: Utc::now(),
397: 395:         created_by: user.get_email(),
398: 396:         last_modified_at: Utc::now(),
399: 397:         last_modified_by: user.get_email(),
400: 398:         weight,
401: 399:         description: req_description,
402: 400:         change_reason,
403: 401:     })
404: 402: }
405: 403: 
406: 404: fn db_update_override(
407: 405:     conn: &mut DBConnection,
408: 406:     ctx: Context,
409: 407:     user: &User,
410: 408:     schema_name: &SchemaName,
411: 409: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Context> {
412: 410:     use contexts::dsl;
413: 411:     let update_resp = diesel::update(dsl::contexts)
414: 412:         .filter(dsl::id.eq(ctx.id.clone()))
415: 413:         .set((
416: 414:             dsl::override_.eq(ctx.override_),
417: 415:             dsl::override_id.eq(ctx.override_id),
418: 416:             dsl::last_modified_at.eq(Utc::now()),
419: 417:             dsl::last_modified_by.eq(user.get_email()),
420: 418:             dsl::description.eq(ctx.description),
421: 419:             dsl::change_reason.eq(ctx.change_reason),
422: 420:         ))
423: 421:         .returning(Context::as_returning())
424: 422:         .schema_name(schema_name)
425: 423:         .get_result::<Context>(conn)?;
426: 424:     Ok(update_resp)
427: 425: }
428: 426: 
429: 427: pub fn replace_override_of_existing_ctx(
430: 428:     conn: &mut DBConnection,
431: 429:     ctx: Context,
432: 430:     user: &User,
433: 431:     schema_name: &SchemaName,
434: 432: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Context> {
435: 433:     let new_override = ctx.override_;
436: 434:     let new_override_id = hash(&Value::Object(new_override.clone().into()));
437: 435:     let new_ctx = Context {
438: 436:         override_: new_override,
439: 437:         override_id: new_override_id,
440: 438:         ..ctx
441: 439:     };
442: 440:     db_update_override(conn, new_ctx, user, schema_name)
443: 441: }
444: 442: 
445: 443: pub fn update_override_of_existing_ctx(
446: 444:     conn: &mut DBConnection,
447: 445:     ctx: Context,
448: 446:     user: &User,
449: 447:     schema_name: &SchemaName,
450: 448: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Context> {
451: 449:     use contexts::dsl;
452: 450:     let mut new_override: Value = dsl::contexts
453: 451:         .filter(dsl::id.eq(ctx.id.clone()))
454: 452:         .select(dsl::override_)
455: 453:         .schema_name(schema_name)
456: 454:         .first(conn)?;
457: 455:     lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client::merge(
458: 456:         &mut new_override,
459: 457:         &Value::Object(ctx.override_.clone().into()),
460: 458:     );
461: 459:     let new_override_id = hash(&new_override);
462: 460:     let new_ctx = Context {
463: 461:         override_: Cac::<Overrides>::validate_db_data(
464: 462:             new_override.as_object().cloned().unwrap_or(Map::new()),
465: 463:         )
466: 464:         .map_err(|err| {
467: 465:             log::error!(
468: 466:                 "update_override_of_existing_ctx : failed to decode context from db {}",
469: 467:                 err
470: 468:             );
471: 469:             unexpected_error!(err)
472: 470:         })?
473: 471:         .into_inner(),
474: 472:         override_id: new_override_id,
475: 473:         ..ctx
476: 474:     };
477: 475:     db_update_override(conn, new_ctx, user, schema_name)
478: 476: }
479: 477: 
480: 478: pub fn validate_ctx(
481: 479:     conn: &mut DBConnection,
482: 480:     workspace_context: &WorkspaceContext,
483: 481:     condition: Condition,
484: 482:     override_: Overrides,
485: 483:     master_encryption_key: &Option<EncryptionKey>,
486: 484: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HashMap<String, DimensionInfo>> {
487: 485:     validate_condition_with_mandatory_dimensions(
488: 486:         &condition,
489: 487:         workspace_context
490: 488:             .settings
491: 489:             .mandatory_dimensions
492: 490:             .as_ref()
493: 491:             .unwrap_or(&vec![]),
494: 492:     )?;
495: 493: 
496: 494:     let dimension_info_map =
497: 495:         fetch_dimensions_info_map(conn, &workspace_context.schema_name)?;
498: 496:     validate_condition_with_dependent_dimensions(&dimension_info_map, &condition)?;
499: 497:     validate_dimensions(&condition, &dimension_info_map)?;
500: 498:     validate_condition_with_functions(
501: 499:         workspace_context,
502: 500:         conn,
503: 501:         &condition,
504: 502:         &override_,
505: 503:         workspace_context.settings.enable_context_validation,
506: 504:         master_encryption_key,
507: 505:     )?;
508: 506:     Ok(dimension_info_map)
509: 507: }
510: 508: ```
511: 509: ```
512: 510: ```
513: 511: ```
514: ```
```
