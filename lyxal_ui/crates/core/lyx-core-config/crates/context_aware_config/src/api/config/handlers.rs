1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\config\handlers.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: 
13: 11: #[cfg(feature = "high-performance-mode")]
14: 12: use actix_http::StatusCode;
15: 13: #[cfg(feature = "high-performance-mode")]
16: 14: use actix_web::http::header::ContentType;
17: 15: use actix_web::{
18: 16:     HttpRequest, HttpResponse, Scope, get, put, routes,
19: 17:     web::{Data, Header, Json, Path, Query},
20: 18: };
21: 19: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
22: 20: #[cfg(feature = "high-performance-mode")]
23: 21: use fred::interfaces::KeysInterface;
24: 22: use itertools::Itertools;
25: 23: use serde_json::{Map, Value, json};
26: 24: #[cfg(feature = "high-performance-mode")]
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::AppHeader;
28: 26: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
29: 27:     helpers::fetch_dimensions_info_map,
30: 28:     service::types::{AppState, DbConnection, WorkspaceContext},
31: 29: };
32: 30: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
33: 31: #[cfg(feature = "high-performance-mode")]
34: 32: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::response_error;
35: 33: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, unexpected_error};
36: 34: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
37: 35:     Cac, Condition, Config, Context, DBConnection, DimensionInfo, OverrideWithKeys,
38: 36:     Overrides, PaginatedResponse, User,
39: 37:     api::{
40: 38:         config::{ConfigQuery, ContextPayload, MergeStrategy, ResolveConfigQuery},
41: 39:         context::PutRequest,
42: 40:     },
43: 41:     custom_query::{
44: 42:         self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, CustomQuery, DimensionQuery, PaginationParams,
45: 43:         QueryMap,
46: 44:     },
47: 45:     database::{
48: 46:         models::{
49: 47:             ChangeReason,
50: 48:             cac::{ConfigVersion, ConfigVersionListItem},
51: 49:         },
52: 50:         schema::config_versions::dsl as config_versions,
53: 51:     },
54: 52:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
55: 53: };
56: 54: 
57: 55: use crate::api::context::{self, helpers::query_description};
58: 56: use crate::{
59: 57:     api::config::helpers::{
60: 58:         add_audit_id_to_header, add_config_version_to_header,
61: 59:         add_last_modified_to_header, generate_config_from_version, get_config_version,
62: 60:         get_max_created_at, is_not_modified,
63: 61:     },
64: 62:     helpers::{calculate_context_weight, generate_cac},
65: 63: };
66: 64: 
67: 65: use super::helpers::{lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_prefix_filter_to_config, resolve, setup_query_data};
68: 66: 
69: 67: #[allow(clippy::let_and_return)]
70: 68: pub fn endpoints() -> Scope {
71: 69:     let scope = Scope::new("")
72: 70:         .service(get_handler)
73: 71:         .service(resolve_handler)
74: 72:         .service(reduce_handler)
75: 73:         .service(list_version_handler)
76: 74:         .service(get_version_handler);
77: 75:     #[cfg(feature = "high-performance-mode")]
78: 76:     let scope = scope.service(get_fast_handler);
79: 77:     scope
80: 78: }
81: 79: 
82: 80: fn generate_subsets(map: &Map<String, Value>) -> Vec<Map<String, Value>> {
83: 81:     let mut subsets = Vec::new();
84: 82:     let keys: Vec<String> = map.keys().cloned().collect_vec();
85: 83:     let all_subsets_keys = generate_subsets_keys(keys);
86: 84: 
87: 85:     for subset_keys in &all_subsets_keys {
88: 86:         let mut subset_map = Map::new();
89: 87: 
90: 88:         for key in subset_keys {
91: 89:             if let Some(value) = map.get(key) {
92: 90:                 subset_map.insert(key.to_string(), value.clone());
93: 91:             }
94: 92:         }
95: 93: 
96: 94:         subsets.push(subset_map);
97: 95:     }
98: 96: 
99: 97:     subsets
100: 98: }
101: 99: 
102: 100: fn generate_subsets_keys(keys: Vec<String>) -> Vec<Vec<String>> {
103: 101:     let mut res = vec![[].to_vec()];
104: 102:     for element in keys {
105: 103:         let len = res.len();
106: 104:         for ind in 0..len {
107: 105:             let mut sub = res[ind].clone();
108: 106:             sub.push(element.clone());
109: 107:             res.push(sub);
110: 108:         }
111: 109:     }
112: 110:     res
113: 111: }
114: 112: 
115: 113: fn reduce(
116: 114:     contexts_overrides_values: Vec<(Context, Map<String, Value>, Value, String)>,
117: 115:     default_config_val: &Value,
118: 116: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<Map<String, Value>>> {
119: 117:     let mut dimensions: Vec<Map<String, Value>> = Vec::new();
120: 118:     for (context, overrides, key_val, override_id) in contexts_overrides_values {
121: 119:         let mut ct_dimensions: Map<String, Value> = context.condition.clone().into();
122: 120: 
123: 121:         ct_dimensions.insert("key_val".to_string(), key_val);
124: 122:         let request_payload = json!({
125: 123:             "override": overrides,
126: 124:             "context": context.condition,
127: 125:             "id": context.id,
128: 126:             "to_be_deleted": overrides.is_empty(),
129: 127:             "override_id": override_id,
130: 128:         });
131: 129:         ct_dimensions.insert("req_payload".to_string(), request_payload);
132: 130:         dimensions.push(ct_dimensions);
133: 131:     }
134: 132: 
135: 133:     //adding default config value
136: 134:     let mut default_config_map = Map::new();
137: 135:     default_config_map.insert("key_val".to_string(), default_config_val.to_owned());
138: 136:     dimensions.push(default_config_map);
139: 137: 
140: 138:     /*
141: 139:     We now have dimensions array, which is a vector of elements representing each context present where each element is a type of Map<String,Value> which contains the following
142: 140:         1. all the dimensions and value of those dimensions in the context
143: 141:         2. key_val, which is the value of the override key for which we are trying to reduce
144: 142:         3. A req_payload which contains the details of the context like, context_id, override_id, the context_condition, new overrides (without containing the key that has to be reduced)
145: 143:         {
146: 144:             dimension1_in_context : value_of_dimension1_in_context,
147: 145:             dimension2_in_context : value_of_dimension2_in_context,
148: 146:             .
149: 147:             .
150: 148:             key_val: value of the override key that we are trying to reduce
151: 149:             req_payload : {
152: 150:                 override : new_overrides(without the key that is to be reduced)
153: 151:                 context : context_condition
154: 152:                 id : context_id
155: 153:                 to_be_deleted : if new_overrides is empty then delete this context
156: 154:             }
157: 155:         }
158: 156: 
159: 157:     We have also sorted this dimensions vector in descending order based on the weight of the dimensions in that context
160: 158:     and in this vector the default config will be at the end of the list as it has no dimensions and it's weight is the least
161: 159: 
162: 160:     Now we iterate from start and then pick an element and generate all subsets of that element keys excluding the req_payload and key_val
163: 161:     i.e we only generate different subsets of dimensions of that context along with the value of those dimensions in that context
164: 162: 
165: 163:     Next we check if in the vector we find any other element c2 whose dimensions is part of the subsets of the parent element c1
166: 164:     if dimensions_subsets_of_c1 contains dimensions_of_c2
167: 165: 
168: 166:         if the value of the override key is same in both c1 and c2 then we can reduce or remove that key in the override of c1
169: 167:         so we mark the can_be_reduce to be true, and then update the dimensions vector.
170: 168: 
171: 169:         but if we find any other element c3 whose dimensions is a subset of c1_dimensions but the value is not the same
172: 170:         then that means we can't reduce this key from c1, because in resolve if we remove it from c1 it will pick the value form c3 which is different.
173: 171:         So if we find this element c3 before any other element which is a subset of c1 with the same value, then we can't reduce this key for c1 so we break
174: 172:         and continue with the next element.
175: 173:         Here "before" means the element with higher weight comes first with a subset of c1 but differnt override value for the key
176: 174:      */
177: 175:     for (c1_index, dimensions_of_c1_with_payload) in dimensions.clone().iter().enumerate()
178: 176:     {
179: 177:         let mut dimensions_of_c1 = dimensions_of_c1_with_payload.clone();
180: 178:         dimensions_of_c1.remove("req_payload");
181: 179:         let override_val_of_key_in_c1 = dimensions_of_c1.remove("key_val");
182: 180:         let dimensions_subsets_of_c1 = generate_subsets(&dimensions_of_c1);
183: 181:         for (c2_index, dimensions_in_c2_with_payload) in dimensions.iter().enumerate() {
184: 182:             let mut dimensions_of_c2 = dimensions_in_c2_with_payload.clone();
185: 183:             dimensions_of_c2.remove("req_payload");
186: 184:             let override_val_of_key_in_c2 = dimensions_of_c2.remove("key_val");
187: 185:             if c2_index != c1_index
188: 186:                 && dimensions_subsets_of_c1.contains(&dimensions_of_c2)
189: 187:             {
190: 188:                 if override_val_of_key_in_c1 == override_val_of_key_in_c2 {
191: 189:                     let mut temp_c1 = dimensions_of_c1_with_payload.to_owned();
192: 190:                     temp_c1.insert("can_be_reduced".to_string(), Value::Bool(true));
193: 191:                     dimensions[c1_index] = temp_c1;
194: 192:                     break;
195: 193:                 } else if override_val_of_key_in_c2.is_some() {
196: 194:                     break;
197: 195:                 }
198: 196:             }
199: 197:         }
200: 198:     }
201: 199:     Ok(dimensions)
202: 200: }
203: 201: 
204: 202: #[allow(clippy::type_complexity)]
205: 203: fn get_contextlyx-core-lyx_core_lyx-core-lyx_core_ids_from_overrideid(
206: 204:     contexts: Vec<Context>,
207: 205:     overrides: Map<String, Value>,
208: 206:     key_val: Value,
209: 207:     override_id: &str,
210: 208: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<(Context, Map<String, Value>, Value, String)>> {
211: 209:     let mut res: Vec<(Context, Map<String, Value>, Value, String)> = Vec::new();
212: 210:     for ct in contexts {
213: 211:         if ct.condition.contains_key("variantIds") {
214: 212:             continue;
215: 213:         }
216: 214:         let override_keys = &ct.override_with_keys;
217: 215:         if override_keys.contains(&override_id.to_owned()) {
218: 216:             res.push((
219: 217:                 ct,
220: 218:                 overrides.clone(),
221: 219:                 key_val.clone(),
222: 220:                 override_id.to_string(),
223: 221:             ));
224: 222:         }
225: 223:     }
226: 224:     Ok(res)
227: 225: }
228: 226: 
229: 227: fn construct_new_payload(
230: 228:     req_payload: &Map<String, Value>,
231: 229: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<PutRequest> {
232: 230:     let mut res = req_payload.clone();
233: 231:     res.remove("to_be_deleted");
234: 232:     res.remove("override_id");
235: 233:     res.remove("id");
236: 234: 
237: 235:     let context = res
238: 236:         .get("context")
239: 237:         .and_then(|val| val.as_object())
240: 238:         .map_or_else(
241: 239:             || {
242: 240:                 log::error!("construct new payload: Context not present");
243: 241:                 Err(bad_argument!("Context not present"))
244: 242:             },
245: 243:             |val| {
246: 244:                 Cac::<Condition>::try_from(val.to_owned()).map_err(|err| {
247: 245:                     log::error!("failed to decode condition with error : {}", err);
248: 246:                     bad_argument!(err)
249: 247:                 })
250: 248:             },
251: 249:         )?;
252: 250: 
253: 251:     let override_ = res
254: 252:         .get("override")
255: 253:         .and_then(|val| val.as_object())
256: 254:         .map_or_else(
257: 255:             || {
258: 256:                 log::error!("construct new payload Override not present");
259: 257:                 Err(bad_argument!("Override not present"))
260: 258:             },
261: 259:             |val| {
262: 260:                 Cac::<Overrides>::try_from(val.to_owned()).map_err(|err| {
263: 261:                     log::error!("failed to decode override with error : {}", err);
264: 262:                     bad_argument!(err)
265: 263:                 })
266: 264:             },
267: 265:         )?;
268: 266: 
269: 267:     let change_reason =
270: 268:         ChangeReason::try_from("Context updated during reduce operation".to_string())
271: 269:             .map_err(|e| unexpected_error!(e))?;
272: 270: 
273: 271:     Ok(PutRequest {
274: 272:         context,
275: 273:         r#override: override_,
276: 274:         description: None,
277: 275:         change_reason,
278: 276:     })
279: 277: }
280: 278: 
281: 279: #[allow(clippy::too_many_arguments)]
282: 280: async fn reduce_config_key(
283: 281:     user: &User,
284: 282:     conn: &mut DBConnection,
285: 283:     mut og_contexts: Vec<Context>,
286: 284:     mut og_overrides: HashMap<String, Overrides>,
287: 285:     check_key: &str,
288: 286:     dimension_schema_map: &HashMap<String, DimensionInfo>,
289: 287:     default_config: Map<String, Value>,
290: 288:     is_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approve: bool,
291: 289:     workspace_context: &WorkspaceContext,
292: 290:     state: &AppState,
293: 291: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Config> {
294: 292:     let default_config_val =
295: 293:         default_config
296: 294:             .get(check_key)
297: 295:             .ok_or(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument(format!(
298: 296:                 "{} not found in default config",
299: 297:                 check_key
300: 298:             )))?;
301: 299:     let mut contexts_overrides_values = Vec::new();
302: 300: 
303: 301:     for (override_id, mut override_value) in og_overrides.clone() {
304: 302:         if let Some(value_of_check_key) = override_value.remove(check_key) {
305: 303:             let context_arr = get_contextlyx-core-lyx_core_lyx-core-lyx_core_ids_from_overrideid(
306: 304:                 og_contexts.clone(),
307: 305:                 override_value.into(),
308: 306:                 value_of_check_key.clone(),
309: 307:                 &override_id,
310: 308:             )?;
311: 309:             contexts_overrides_values.extend(context_arr);
312: 310:         }
313: 311:     }
314: 312: 
315: 313:     let mut weights = Vec::new();
316: 314: 
317: 315:     for (index, ctx) in contexts_overrides_values.iter().enumerate() {
318: 316:         let weight =
319: 317:             calculate_context_weight(&json!((ctx.0).condition), dimension_schema_map)
320: 318:                 .map_err(|err| bad_argument!(err))?;
321: 319:         weights.push((index, weight))
322: 320:     }
323: 321: 
324: 322:     // Sort the collected results based on weight
325: 323:     weights.sort_by(|a, b| b.1.cmp(&a.1));
326: 324: 
327: 325:     // Use the sorted indices to reorder the original vector
328: 326:     let sorted_weight_contexts = weights
329: 327:         .into_iter()
330: 328:         .map(|(index, _)| contexts_overrides_values[index].clone())
331: 329:         .collect();
332: 330: 
333: 331:     let resolved_dimensions = reduce(sorted_weight_contexts, default_config_val)?;
334: 332:     for rd in resolved_dimensions {
335: 333:         match (
336: 334:             rd.get("can_be_reduced"),
337: 335:             rd.get("req_payload"),
338: 336:             rd.get("req_payload").and_then(|v| v.get("id")),
339: 337:             rd.get("req_payload").and_then(|v| v.get("override_id")),
340: 338:             rd.get("req_payload").and_then(|v| v.get("to_be_deleted")),
341: 339:             rd.get("req_payload").and_then(|v| v.get("override")),
342: 340:         ) {
343: 341:             (
344: 342:                 Some(Value::Bool(true)),
345: 343:                 Some(Value::Object(request_payload)),
346: 344:                 Some(Value::String(cid)),
347: 345:                 Some(Value::String(oid)),
348: 346:                 Some(Value::Bool(to_be_deleted)),
349: 347:                 Some(Value::Object(override_val)),
350: 348:             ) => {
351: 349:                 if *to_be_deleted {
352: 350:                     if is_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approve {
353: 351:                         let _ = context::delete(
354: 352:                             cid.clone(),
355: 353:                             user,
356: 354:                             conn,
357: 355:                             &workspace_context.schema_name,
358: 356:                         );
359: 357:                     }
360: 358:                     og_contexts.retain(|x| x.id != *cid);
361: 359:                 } else {
362: 360:                     if is_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approve {
363: 361:                         let _ = context::delete(
364: 362:                             cid.clone(),
365: 363:                             user,
366: 364:                             conn,
367: 365:                             &workspace_context.schema_name,
368: 366:                         );
369: 367:                         if let Ok(put_req) = construct_new_payload(request_payload) {
370: 368:                             let description = match put_req.description.clone() {
371: 369:                                 Some(val) => val,
372: 370:                                 None => query_description(
373: 371:                                     Value::Object(
374: 372:                                         put_req.context.clone().into_inner().into(),
375: 373:                                     ),
376: 374:                                     conn,
377: 375:                                     &workspace_context.schema_name,
378: 376:                                 )?,
379: 377:                             };
380: 378: 
381: 379:                             let _ = context::upsert(
382: 380:                                 put_req,
383: 381:                                 description,
384: 382:                                 conn,
385: 383:                                 false,
386: 384:                                 user,
387: 385:                                 workspace_context,
388: 386:                                 false,
389: 387:                                 &state.master_encryption_key,
390: 388:                             );
391: 389:                         }
392: 390:                     }
393: 391: 
394: 392:                     let override_val = Cac::<Overrides>::validate_db_data(
395: 393:                         override_val.clone(),
396: 394:                     )
397: 395:                     .map_err(|err| {
398: 396:                         log::error!(
399: 397:                             "reduce_config_key: failed to decode overrides from db {err}"
400: 398:                         );
401: 399:                         unexpected_error!(err)
402: 400:                     })?
403: 401:                     .into_inner();
404: 402: 
405: 403:                     let new_id =
406: 404:                         context::hash(&Value::Object(override_val.clone().into()));
407: 405:                     og_overrides.insert(new_id.clone(), override_val);
408: 406: 
409: 407:                     let mut ctx_index = 0;
410: 408:                     let mut delete_old_oid = true;
411: 409: 
412: 410:                     for (ind, ctx) in og_contexts.iter().enumerate() {
413: 411:                         if ctx.id == *cid {
414: 412:                             ctx_index = ind;
415: 413:                         } else if ctx.override_with_keys.contains(oid) {
416: 414:                             delete_old_oid = false;
417: 415:                         }
418: 416:                     }
419: 417: 
420: 418:                     let mut elem = og_contexts[ctx_index].clone();
421: 419:                     elem.override_with_keys = OverrideWithKeys::new(new_id);
422: 420:                     og_contexts[ctx_index] = elem;
423: 421: 
424: 422:                     if delete_old_oid {
425: 423:                         og_overrides.remove(oid);
426: 424:                     }
427: 425:                 }
428: 426:             }
429: 427:             _ => continue,
430: 428:         }
431: 429:     }
432: 430: 
433: 431:     Ok(Config {
434: 432:         contexts: og_contexts,
435: 433:         overrides: og_overrides,
436: 434:         default_configs: default_config,
437: 435:         dimensions: dimension_schema_map.clone(),
438: 436:     })
439: 437: }
440: 438: 
441: 439: #[authorized]
442: 440: #[put("/reduce")]
443: 441: async fn reduce_handler(
444: 442:     workspace_context: WorkspaceContext,
445: 443:     req: HttpRequest,
446: 444:     user: User,
447: 445:     db_conn: DbConnection,
448: 446:     state: Data<AppState>,
449: 447: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
450: 448:     let DbConnection(mut conn) = db_conn;
451: 449:     let is_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approve = req
452: 450:         .headers()
453: 451:         .get("x-lyx-platform-lyx_platform_lyx-platform-lyx_platform_approve")
454: 452:         .and_then(|value| value.to_str().ok().and_then(|s| s.parse::<bool>().ok()))
455: 453:         .unwrap_or(false);
456: 454: 
457: 455:     let dimensions_info_map =
458: 456:         fetch_dimensions_info_map(&mut conn, &workspace_context.schema_name)?;
459: 457:     let mut config = generate_cac(&mut conn, &workspace_context.schema_name)?;
460: 458:     let default_config = (config.default_configs).clone();
461: 459:     for (key, _) in default_config {
462: 460:         let contexts = config.contexts;
463: 461:         let overrides = config.overrides;
464: 462:         let default_config = config.default_configs;
465: 463:         config = reduce_config_key(
466: 464:             &user,
467: 465:             &mut conn,
468: 466:             contexts.clone(),
469: 467:             overrides.clone(),
470: 468:             key.as_str(),
471: 469:             &dimensions_info_map,
472: 470:             default_config.clone(),
473: 471:             is_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approve,
474: 472:             &workspace_context,
475: 473:             &state,
476: 474:         )
477: 475:         .await?;
478: 476:         if is_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approve {
479: 477:             config = generate_cac(&mut conn, &workspace_context.schema_name)?;
480: 478:         }
481: 479:     }
482: 480: 
483: 481:     Ok(HttpResponse::Ok().json(config))
484: 482: }
485: 483: 
486: 484: #[cfg(feature = "high-performance-mode")]
487: 485: #[authorized]
488: 486: #[get("/fast")]
489: 487: async fn get_fast_handler(
490: 488:     workspace_context: WorkspaceContext,
491: 489:     state: Data<AppState>,
492: 490: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
493: 491:     use fred::interfaces::MetricsInterface;
494: 492: 
495: 493:     log::debug!("Started redis fetch");
496: 494:     let config_key = format!("{}::cac_config", *workspace_context.schema_name);
497: 495:     let last_modified_at_key = format!(
498: 496:         "{}::cac_config::last_modified_at",
499: 497:         *workspace_context.schema_name
500: 498:     );
501: 499:     let audit_id_key =
502: 500:         format!("{}::cac_config::audit_id", *workspace_context.schema_name);
503: 501:     let config_version_key = format!(
504: 502:         "{}::cac_config::config_version",
505: 503:         *workspace_context.schema_name
506: 504:     );
507: 505:     let lyx-core-lyx_core_lyx-core-lyx_core_client = state.redis.next_connected();
508: 506:     let config = lyx-core-lyx_core_lyx-core-lyx_core_client.get::<String, String>(config_key).await;
509: 507:     let metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_latency_metrics();
510: 508:     let network_metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_network_latency_metrics();
511: 509:     log::trace!(
512: 510:         "Network metrics for config fetch in milliseconds :: max: {}, min: {}, avg: {}; Latency metrics :: max: {}, min: {}, avg: {}",
513: 511:         network_metrics.max,
514: 512:         network_metrics.min,
515: 513:         network_metrics.avg,
516: 514:         metrics.max,
517: 515:         metrics.min,
518: 516:         metrics.avg
519: 517:     );
520: 518:     match config {
521: 519:         Ok(config) => {
522: 520:             let mut response = HttpResponse::Ok();
523: 521:             if let Ok(max_created_at) =
524: 522:                 lyx-core-lyx_core_lyx-core-lyx_core_client.get::<String, String>(last_modified_at_key).await
525: 523:             {
526: 524:                 let metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_latency_metrics();
527: 525:                 let network_metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_network_latency_metrics();
528: 526:                 log::trace!(
529: 527:                     "Network metrics max-created-by fetch in milliseconds :: max: {}, min: {}, avg: {}; Latency metrics :: max: {}, min: {}, avg: {}",
530: 528:                     network_metrics.max,
531: 529:                     network_metrics.min,
532: 530:                     network_metrics.avg,
533: 531:                     metrics.max,
534: 532:                     metrics.min,
535: 533:                     metrics.avg
536: 534:                 );
537: 535:                 response
538: 536:                     .insert_header((AppHeader::LastModified.to_string(), max_created_at));
539: 537:             }
540: 538:             if let Ok(audit_id) = lyx-core-lyx_core_lyx-core-lyx_core_client.get::<String, String>(audit_id_key).await {
541: 539:                 let metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_latency_metrics();
542: 540:                 let network_metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_network_latency_metrics();
543: 541:                 log::trace!(
544: 542:                     "Network metrics for audit ID in milliseconds :: max: {}, min: {}, avg: {}; Latency metrics :: max: {}, min: {}, avg: {}",
545: 543:                     network_metrics.max,
546: 544:                     network_metrics.min,
547: 545:                     network_metrics.avg,
548: 546:                     metrics.max,
549: 547:                     metrics.min,
550: 548:                     metrics.avg
551: 549:                 );
552: 550:                 response.insert_header((AppHeader::XAuditId.to_string(), audit_id));
553: 551:             }
554: 552:             if let Ok(config_version) =
555: 553:                 lyx-core-lyx_core_lyx-core-lyx_core_client.get::<Option<i64>, String>(config_version_key).await
556: 554:             {
557: 555:                 let metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_latency_metrics();
558: 556:                 let network_metrics = lyx-core-lyx_core_lyx-core-lyx_core_client.take_network_latency_metrics();
559: 557:                 log::trace!(
560: 558:                     "Network metrics for version ID in milliseconds :: max: {}, min: {}, avg: {}; Latency metrics :: max: {}, min: {}, avg: {}",
561: 559:                     network_metrics.max,
562: 560:                     network_metrics.min,
563: 561:                     network_metrics.avg,
564: 562:                     metrics.max,
565: 563:                     metrics.min,
566: 564:                     metrics.avg
567: 565:                 );
568: 566:                 add_config_version_to_header(&config_version, &mut response);
569: 567:             }
570: 568:             response.insert_header(ContentType::json());
571: 569:             Ok(response.body(config))
572: 570:         }
573: 571:         Err(err) => {
574: 572:             log::error!("Could not get config in redis due to {}", err);
575: 573:             Err(response_error!(
576: 574:                 StatusCode::INTERNAL_SERVER_ERROR,
577: 575:                 "could not fetch config, please try /config API"
578: 576:             ))
579: 577:         }
580: 578:     }
581: 579: }
582: 580: 
583: 581: #[authorized]
584: 582: #[routes]
585: 583: #[get("")]
586: 584: #[post("")]
587: 585: async fn get_handler(
588: 586:     req: HttpRequest,
589: 587:     body: Option<Json<ContextPayload>>,
590: 588:     db_conn: DbConnection,
591: 589:     dimension_params: DimensionQuery<QueryMap>,
592: 590:     query_filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ConfigQuery>,
593: 591:     workspace_context: WorkspaceContext,
594: 592: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
595: 593:     let DbConnection(mut conn) = db_conn;
596: 594: 
597: 595:     let max_created_at = get_max_created_at(&mut conn, &workspace_context.schema_name)
598: 596:         .map_err(|e| log::error!("failed to fetch max timestamp from event_log: {e}"))
599: 597:         .ok();
600: 598: 
601: 599:     log::info!("Max created at: {max_created_at:?}");
602: 600: 
603: 601:     let is_not_modified = is_not_modified(max_created_at, &req);
604: 602: 
605: 603:     if is_not_modified {
606: 604:         return Ok(HttpResponse::NotModified().finish());
607: 605:     }
608: 606: 
609: 607:     let query_filters = query_filters.into_inner();
610: 608:     let mut version = get_config_version(&query_filters.version, &workspace_context)?;
611: 609: 
612: 610:     let mut config = generate_config_from_version(
613: 611:         &mut version,
614: 612:         &mut conn,
615: 613:         &workspace_context.schema_name,
616: 614:     )?;
617: 615: 
618: 616:     config = lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_prefix_filter_to_config(&query_filters.prefix, config)?;
619: 617:     let is_smithy: bool;
620: 618:     let context = if req.method() == actix_web::http::Method::GET {
621: 619:         is_smithy = false;
622: 620:         dimension_params.into_inner()
623: 621:     } else {
624: 622:         // Assuming smithy.
625: 623:         is_smithy = true;
626: 624:         body.map_or_else(QueryMap::default, |body| body.into_inner().context.into())
627: 625:     };
628: 626:     if !context.is_empty() {
629: 627:         config = config.filter_by_dimensions(&context);
630: 628:     }
631: 629: 
632: 630:     let mut response = HttpResponse::Ok();
633: 631:     add_last_modified_to_header(max_created_at, is_smithy, &mut response);
634: 632:     add_audit_id_to_header(&mut conn, &mut response, &workspace_context.schema_name);
635: 633:     add_config_version_to_header(&version, &mut response);
636: 634:     Ok(response.json(config))
637: 635: }
638: 636: 
639: 637: #[allow(clippy::too_many_arguments)]
640: 638: #[authorized]
641: 639: #[routes]
642: 640: #[get("/resolve")]
643: 641: #[post("/resolve")]
644: 642: async fn resolve_handler(
645: 643:     req: HttpRequest,
646: 644:     body: Option<Json<ContextPayload>>,
647: 645:     merge_strategy: Header<MergeStrategy>,
648: 646:     db_conn: DbConnection,
649: 647:     dimension_params: DimensionQuery<QueryMap>,
650: 648:     query_filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ResolveConfigQuery>,
651: 649:     workspace_context: WorkspaceContext,
652: 650:     state: Data<AppState>,
653: 651: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
654: 652:     let DbConnection(mut conn) = db_conn;
655: 653:     let query_filters = query_filters.into_inner();
656: 654: 
657: 655:     let max_created_at = get_max_created_at(&mut conn, &workspace_context.schema_name)
658: 656:         .map_err(|e| log::error!("failed to fetch max timestamp from event_log : {e}"))
659: 657:         .ok();
660: 658: 
661: 659:     if is_not_modified(max_created_at, &req) {
662: 660:         return Ok(HttpResponse::NotModified().finish());
663: 661:     }
664: 662: 
665: 663:     let mut config_version =
666: 664:         get_config_version(&query_filters.version, &workspace_context)?;
667: 665:     let mut config = generate_config_from_version(
668: 666:         &mut config_version,
669: 667:         &mut conn,
670: 668:         &workspace_context.schema_name,
671: 669:     )?;
672: 670:     let (is_smithy, query_data) = setup_query_data(&req, &body, &dimension_params)?;
673: 671: 
674: 672:     let resolved_config = resolve(
675: 673:         &mut config,
676: 674:         query_data,
677: 675:         merge_strategy,
678: 676:         &mut conn,
679: 677:         &query_filters,
680: 678:         &workspace_context,
681: 679:         &state.master_encryption_key,
682: 680:     )?;
683: 681: 
684: 682:     let mut resp = HttpResponse::Ok();
685: 683:     add_last_modified_to_header(max_created_at, is_smithy, &mut resp);
686: 684:     add_audit_id_to_header(&mut conn, &mut resp, &workspace_context.schema_name);
687: 685:     add_config_version_to_header(&config_version, &mut resp);
688: 686:     Ok(resp.json(resolved_config))
689: 687: }
690: 688: 
691: 689: #[authorized]
692: 690: #[get("/versions")]
693: 691: async fn list_version_handler(
694: 692:     workspace_context: WorkspaceContext,
695: 693:     db_conn: DbConnection,
696: 694:     filters: Query<PaginationParams>,
697: 695: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<ConfigVersionListItem>>> {
698: 696:     let DbConnection(mut conn) = db_conn;
699: 697: 
700: 698:     let n_version: i64 = config_versions::config_versions
701: 699:         .count()
702: 700:         .schema_name(&workspace_context.schema_name)
703: 701:         .get_result(&mut conn)?;
704: 702: 
705: 703:     let limit = filters.count.unwrap_or(10);
706: 704:     let mut builder = config_versions::config_versions
707: 705:         .schema_name(&workspace_context.schema_name)
708: 706:         .into_boxed()
709: 707:         .order(config_versions::created_at.desc())
710: 708:         .limit(limit);
711: 709:     if let Some(page) = filters.page {
712: 710:         let offset = (page - 1) * limit;
713: 711:         builder = builder.offset(offset);
714: 712:     }
715: 713:     let config_versions = builder
716: 714:         .select(ConfigVersionListItem::as_select())
717: 715:         .load(&mut conn)?;
718: 716:     let total_pages = (n_version as f64 / limit as f64).ceil() as i64;
719: 717:     Ok(Json(PaginatedResponse {
720: 718:         total_pages,
721: 719:         total_items: n_version,
722: 720:         data: config_versions,
723: 721:     }))
724: 722: }
725: 723: 
726: 724: #[authorized]
727: 725: #[get("/version/{version}")]
728: 726: async fn get_version_handler(
729: 727:     workspace_context: WorkspaceContext,
730: 728:     db_conn: DbConnection,
731: 729:     version: Path<i64>,
732: 730: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ConfigVersion>> {
733: 731:     let DbConnection(mut conn) = db_conn;
734: 732: 
735: 733:     let config_version = config_versions::config_versions
736: 734:         .schema_name(&workspace_context.schema_name)
737: 735:         .find(version.into_inner())
738: 736:         .get_result::<ConfigVersion>(&mut conn)?;
739: 737: 
740: 738:     Ok(Json(config_version))
741: 739: }
742: 740: ```
743: 741: ```
744: 742: ```
745: 743: ```
746: ```
```

