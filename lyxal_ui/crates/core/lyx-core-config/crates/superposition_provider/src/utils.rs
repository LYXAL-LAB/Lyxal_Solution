1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\utils.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\utils.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\utils.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\utils.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\utils.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: 
13: 11: use aws_smithy_types::Document;
14: 12: use log::debug;
15: 13: use serde_json::{json, Map, Value};
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core::experiment::{ExperimentGroups, FfiExperimentGroup};
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core::{Experiments, FfiExperiment};
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::operation::list_experiment_groups::ListExperimentGroupsOutput;
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::{
20: 18:     ExperimentStatusType as SDKExperimentStatusType, GroupType as SdkGroupType,
21: 19: };
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::models::cac::{DependencyGraph, DimensionType};
23: 21: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::database::models::experimentation::{
24: 22:     Bucket, Buckets, ExperimentStatusType, GroupType, Variant, VariantType, Variants,
25: 23: };
26: 24: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
27: 25:     Cac, Condition, Config, Context, DimensionInfo, Exp, ExtendedMap, OverrideWithKeys,
28: 26:     Overrides,
29: 27: };
30: 28: 
31: 29: use crate::types::*;
32: 30: 
33: 31: pub struct ConversionUtils;
34: 32: 
35: 33: impl ConversionUtils {
36: 34:     pub fn convert_get_config_response(
37: 35:         response: &lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::operation::get_config::GetConfigOutput,
38: 36:     ) -> Result<Config> {
39: 37:         debug!("Converting get_config response to lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::Config");
40: 38: 
41: 39:         // Convert default configs - these are already Value types
42: 40:         let default_configs =
43: 41:             Self::convert_condition_document(response.default_configs())?;
44: 42: 
45: 43:         // Convert overrides - HashMap<String, HashMap<String, Document>>
46: 44:         let overrides = {
47: 45:             let mut result_map = HashMap::new();
48: 46:             for (override_key, inner_map) in response.overrides() {
49: 47:                 let override_values = Self::convert_condition_document(inner_map)?;
50: 48: 
51: 49:                 // Create Overrides directly from Map<String, Value>
52: 50:                 let overrides_obj = Cac::<Overrides>::try_from(override_values)
53: 51:                     .map_err(|e| SuperpositionError::SerializationError(e.to_string()))?;
54: 52: 
55: 53:                 result_map.insert(override_key.clone(), overrides_obj.into_inner());
56: 54:             }
57: 55:             result_map
58: 56:         };
59: 57: 
60: 58:         // Convert contexts - Vec<ContextPartial>
61: 59:         let contexts = response
62: 60:             .contexts()
63: 61:             .iter()
64: 62:             .map(|context_partial| {
65: 63:                 // Convert condition Document to Map<String, Value>
66: 64:                 let condition_map =
67: 65:                     Self::convert_condition_document(context_partial.condition())?;
68: 66: 
69: 67:                 // Create Condition directly from Map<String, Value>
70: 68:                 let condition =
71: 69:                     Cac::<Condition>::try_from(condition_map).map_err(|e| {
72: 70:                         SuperpositionError::SerializationError(format!(
73: 71:                             "Invalid condition: {}",
74: 72:                             e
75: 73:                         ))
76: 74:                     })?;
77: 75: 
78: 76:                 let override_with_keys = OverrideWithKeys::try_from(
79: 77:                     context_partial.override_with_keys().to_vec(),
80: 78:                 )
81: 79:                 .map_err(|e| {
82: 80:                     SuperpositionError::SerializationError(format!(
83: 81:                         "Invalid override_with_keys: {e}",
84: 82:                     ))
85: 83:                 })?;
86: 84: 
87: 85:                 Ok(Context {
88: 86:                     id: context_partial.id().to_string(),
89: 87:                     condition: condition.into_inner(),
90: 88:                     priority: context_partial.priority(),
91: 89:                     weight: context_partial.weight(),
92: 90:                     override_with_keys,
93: 91:                 })
94: 92:             })
95: 93:             .collect::<Result<Vec<Context>>>()?;
96: 94: 
97: 95:         let dimensions = response
98: 96:             .dimensions()
99: 97:             .iter()
100: 98:             .map(|(key, dimension_info)| {
101: 99:                 let schema = dimension_info
102: 100:                     .schema()
103: 101:                     .iter()
104: 102:                     .map(|(k, v)| Self::document_to_value(v).map(|val| (k.clone(), val)))
105: 103:                     .collect::<Result<Map<String, Value>>>()?;
106: 104:                 let dim_info = DimensionInfo {
107: 105:                     schema: ExtendedMap::from(schema),
108: 106:                     position: dimension_info.position(),
109: 107:                     dimension_type: Self::try_dimension_type(
110: 108:                         dimension_info.dimension_type(),
111: 109:                     )?,
112: 110:                     dependency_graph: DependencyGraph(
113: 111:                         dimension_info.dependency_graph().clone(),
114: 112:                     ),
115: 113:                     value_compute_function_name: dimension_info
116: 114:                         .value_compute_function_name()
117: 115:                         .map(String::from),
118: 116:                 };
119: 117:                 Ok((key.clone(), dim_info))
120: 118:             })
121: 119:             .collect::<Result<HashMap<String, DimensionInfo>>>()?;
122: 120: 
123: 121:         let config = Config {
124: 122:             contexts,
125: 123:             overrides,
126: 124:             default_configs,
127: 125:             dimensions,
128: 126:         };
129: 127: 
130: 128:         debug!("Successfully converted config with {} contexts, {} overrides, {} default configs", 
131: 129:                config.contexts.len(), config.overrides.len(), config.default_configs.len());
132: 130: 
133: 131:         Ok(config)
134: 132:     }
135: 133: 
136: 134:     fn try_dimension_type(
137: 135:         dim_type: &lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::DimensionType,
138: 136:     ) -> Result<DimensionType> {
139: 137:         match dim_type {
140: 138:             lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::DimensionType::RemoteCohort(cohort_based_on) => {
141: 139:                 Ok(DimensionType::RemoteCohort(cohort_based_on.clone()))
142: 140:             }
143: 141:             lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::DimensionType::LocalCohort(cohort_based_on) => {
144: 142:                 Ok(DimensionType::LocalCohort(cohort_based_on.clone()))
145: 143:             }
146: 144:             lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::DimensionType::Regular => {
147: 145:                 Ok(DimensionType::Regular {})
148: 146:             }
149: 147:             _ => Err(SuperpositionError::SerializationError(
150: 148:                 "Unknown dimension type".to_string(),
151: 149:             )),
152: 150:         }
153: 151:     }
154: 152: 
155: 153:     pub fn convert_value_to_config(map: &Map<String, Value>) -> Result<Config> {
156: 154:         // Extract contexts array
157: 155:         let contexts =
158: 156:             map.get("contexts")
159: 157:                 .and_then(|v| v.as_array())
160: 158:                 .ok_or_else(|| {
161: 159:                     SuperpositionError::ConfigError(
162: 160:                         "Missing or invalid 'contexts' field".to_string(),
163: 161:                     )
164: 162:                 })?;
165: 163: 
166: 164:         let parsed_contexts: Result<Vec<Context>> = contexts
167: 165:             .iter()
168: 166:             .map(|context_val| {
169: 167:                 let context_obj = context_val.as_object().ok_or_else(|| {
170: 168:                     SuperpositionError::ConfigError(
171: 169:                         "Context must be an object".to_string(),
172: 170:                     )
173: 171:                 })?;
174: 172: 
175: 173:                 // Extract required fields
176: 174:                 let id = context_obj
177: 175:                     .get("id")
178: 176:                     .and_then(|v| v.as_str())
179: 177:                     .ok_or_else(|| {
180: 178:                         SuperpositionError::ConfigError(
181: 179:                             "Missing or invalid 'id' field in context".to_string(),
182: 180:                         )
183: 181:                     })?
184: 182:                     .to_string();
185: 183: 
186: 184:                 let priority = context_obj
187: 185:                     .get("priority")
188: 186:                     .and_then(|v| v.as_i64())
189: 187:                     .ok_or_else(|| {
190: 188:                         SuperpositionError::ConfigError(
191: 189:                             "Missing or invalid 'priority' field in context".to_string(),
192: 190:                         )
193: 191:                     })? as i32;
194: 192: 
195: 193:                 let weight = context_obj
196: 194:                     .get("weight")
197: 195:                     .and_then(|v| v.as_i64())
198: 196:                     .ok_or_else(|| {
199: 197:                         SuperpositionError::ConfigError(
200: 198:                             "Missing or invalid 'weight' field in context".to_string(),
201: 199:                         )
202: 200:                     })? as i32;
203: 201: 
204: 202:                 let override_with_keys: Vec<String> = context_obj
205: 203:                     .get("override_with_keys")
206: 204:                     .and_then(|v| v.as_array())
207: 205:                     .ok_or_else(|| {
208: 206:                         SuperpositionError::ConfigError(
209: 207:                             "Missing or invalid 'override_with_keys' field in context"
210: 208:                                 .to_string(),
211: 209:                         )
212: 210:                     })?
213: 211:                     .iter()
214: 212:                     .filter_map(|v| v.as_str().map(String::from))
215: 213:                     .collect();
216: 214:                 let override_with_keys = OverrideWithKeys::try_from(override_with_keys)
217: 215:                     .map_err(|e| {
218: 216:                     SuperpositionError::ConfigError(format!(
219: 217:                         "Invalid override_with_keys: {e}",
220: 218:                     ))
221: 219:                 })?;
222: 220: 
223: 221:                 // Extract condition
224: 222:                 let condition_map = context_obj
225: 223:                     .get("condition")
226: 224:                     .and_then(|v| v.as_object())
227: 225:                     .ok_or_else(|| {
228: 226:                         SuperpositionError::ConfigError(
229: 227:                             "Missing or invalid 'condition' field in context".to_string(),
230: 228:                         )
231: 229:                     })?
232: 230:                     .clone();
233: 231: 
234: 232:                 let condition = Cac::<Condition>::try_from(condition_map)
235: 233:                     .map_err(|e| {
236: 234:                         SuperpositionError::SerializationError(format!(
237: 235:                             "Invalid condition: {}",
238: 236:                             e
239: 237:                         ))
240: 238:                     })?
241: 239:                     .into_inner();
242: 240: 
243: 241:                 Ok(Context {
244: 242:                     id,
245: 243:                     condition,
246: 244:                     priority,
247: 245:                     weight,
248: 246:                     override_with_keys,
249: 247:                 })
250: 248:             })
251: 249:             .collect();
252: 250: 
253: 251:         let contexts = parsed_contexts?;
254: 252: 
255: 253:         // Extract overrides object
256: 254:         let overrides_obj = map
257: 255:             .get("overrides")
258: 256:             .and_then(|v| v.as_object())
259: 257:             .ok_or_else(|| {
260: 258:                 SuperpositionError::ConfigError(
261: 259:                     "Missing or invalid 'overrides' field".to_string(),
262: 260:                 )
263: 261:             })?;
264: 262: 
265: 263:         let mut overrides: HashMap<String, Overrides> = HashMap::new();
266: 264:         for (key, value) in overrides_obj {
267: 265:             let override_map = value
268: 266:                 .as_object()
269: 267:                 .ok_or_else(|| {
270: 268:                     SuperpositionError::ConfigError(format!(
271: 269:                         "Override '{}' must be an object",
272: 270:                         key
273: 271:                     ))
274: 272:                 })?
275: 273:                 .clone();
276: 274: 
277: 275:             let override_obj = Cac::<Overrides>::try_from(override_map)
278: 276:                 .map_err(|e| {
279: 277:                     SuperpositionError::SerializationError(format!(
280: 278:                         "Invalid override '{}': {}",
281: 279:                         key, e
282: 280:                     ))
283: 281:                 })?
284: 282:                 .into_inner();
285: 283: 
286: 284:             overrides.insert(key.clone(), override_obj);
287: 285:         }
288: 286: 
289: 287:         // Extract default_configs object
290: 288:         let default_configs = map
291: 289:             .get("default_configs")
292: 290:             .and_then(|v| v.as_object())
293: 291:             .ok_or_else(|| {
294: 292:                 SuperpositionError::ConfigError(
295: 293:                     "Missing or invalid 'default_configs' field".to_string(),
296: 294:                 )
297: 295:             })?
298: 296:             .clone();
299: 297: 
300: 298:         let dimensions = map
301: 299:             .get("dimensions")
302: 300:             .and_then(|v| v.as_object())
303: 301:             .map(|dim| {
304: 302:                 dim.iter()
305: 303:                     .map(|(key, value)| {
306: 304:                         let dim_info: DimensionInfo =
307: 305:                             serde_json::from_value(value.clone()).map_err(|e| {
308: 306:                                 SuperpositionError::SerializationError(format!(
309: 307:                                     "Invalid dimension info for '{}': {}",
310: 308:                                     key, e
311: 309:                                 ))
312: 310:                             })?;
313: 311:                         Ok((key.clone(), dim_info))
314: 312:                     })
315: 313:                     .collect::<Result<HashMap<String, DimensionInfo>>>()
316: 314:             })
317: 315:             .unwrap_or_else(|| Ok(HashMap::new()))?;
318: 316: 
319: 317:         Ok(Config {
320: 318:             contexts,
321: 319:             overrides,
322: 320:             default_configs,
323: 321:             dimensions,
324: 322:         })
325: 323:     }
326: 324: 
327: 325:     fn convert_condition_document(
328: 326:         context: &HashMap<String, Document>,
329: 327:     ) -> Result<Map<String, Value>> {
330: 328:         let mut condition_map = Map::new();
331: 329:         for (key, doc) in context {
332: 330:             let value = Self::document_to_value(doc)?;
333: 331:             condition_map.insert(key.clone(), value);
334: 332:         }
335: 333:         Ok(condition_map)
336: 334:     }
337: 335: 
338: 336:     /// Convert list_experiment SDK response to structured experiment data
339: 337:     pub fn convert_experiments_response(
340: 338:         response: &lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::operation::list_experiment::ListExperimentOutput,
341: 339:     ) -> Result<Experiments> {
342: 340:         debug!("Converting experiments response");
343: 341: 
344: 342:         let exp_list = response.data();
345: 343:         let mut trimmed_exp_list: Experiments = Vec::new();
346: 344: 
347: 345:         for exp in exp_list {
348: 346:             // Convert experiment context (condition)
349: 347:             let condition_map = Self::convert_condition_document(exp.context())?;
350: 348: 
351: 349:             // Convert variants
352: 350:             let mut variants: Variants = Variants::new(vec![]);
353: 351:             for variant in exp.variants() {
354: 352:                 let variant_type = match variant.variant_type() {
355: 353:                     lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::VariantType::Control => {
356: 354:                         VariantType::CONTROL
357: 355:                     }
358: 356:                     lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::VariantType::Experimental => {
359: 357:                         VariantType::EXPERIMENTAL
360: 358:                     }
361: 359:                     _ => {
362: 360:                         return Err(SuperpositionError::SerializationError(
363: 361:                             "Unknown variant type".to_string(),
364: 362:                         ))
365: 363:                     }
366: 364:                 };
367: 365: 
368: 366:                 // Convert variant overrides - check if overrides exist
369: 367:                 let overrides_map = Self::hashmap_to_map(variant.overrides())?;
370: 368: 
371: 369:                 let override_ = Exp::<Overrides>::try_from(overrides_map)
372: 370:                     .map_err(|e| SuperpositionError::SerializationError(e.to_string()))?;
373: 371: 
374: 372:                 let variant_value = Variant {
375: 373:                     id: variant.id.clone(),
376: 374:                     variant_type,
377: 375:                     context_id: variant.context_id.clone(),
378: 376:                     override_id: variant.override_id.clone(),
379: 377:                     overrides: override_,
380: 378:                 };
381: 379:                 variants.push(variant_value);
382: 380:             }
383: 381:             let context = Exp::<Condition>::try_from(condition_map)
384: 382:                 .map_err(|e| {
385: 383:                     SuperpositionError::SerializationError(format!(
386: 384:                         "Invalid condition: {}",
387: 385:                         e
388: 386:                     ))
389: 387:                 })?
390: 388:                 .into_inner();
391: 389:             let status = match exp.status {
392: 390:                 SDKExperimentStatusType::Created => ExperimentStatusType::CREATED,
393: 391:                 SDKExperimentStatusType::Inprogress => ExperimentStatusType::INPROGRESS,
394: 392:                 SDKExperimentStatusType::Paused => ExperimentStatusType::PAUSED,
395: 393:                 SDKExperimentStatusType::Concluded => ExperimentStatusType::CONCLUDED,
396: 394:                 SDKExperimentStatusType::Discarded => ExperimentStatusType::DISCARDED,
397: 395:                 _ => {
398: 396:                     return Err(SuperpositionError::SerializationError(
399: 397:                         "Unknown experiment status".to_string(),
400: 398:                     ))
401: 399:                 }
402: 400:             };
403: 401:             let experiment = FfiExperiment {
404: 402:                 id: exp.id.clone(),
405: 403:                 context,
406: 404:                 variants,
407: 405:                 traffic_percentage: exp.traffic_percentage as u8,
408: 406:                 status,
409: 407:             };
410: 408: 
411: 409:             trimmed_exp_list.push(experiment);
412: 410:         }
413: 411: 
414: 412:         Ok(trimmed_exp_list)
415: 413:     }
416: 414: 
417: 415:     pub fn convert_experiment_groups_response(
418: 416:         response: &ListExperimentGroupsOutput,
419: 417:     ) -> Result<ExperimentGroups> {
420: 418:         debug!("Converting experiment groups response");
421: 419: 
422: 420:         let group_list = response.data();
423: 421:         let mut trimmed_group_list: ExperimentGroups = Vec::new();
424: 422: 
425: 423:         for exp_group in group_list {
426: 424:             // Convert experiment context (condition)
427: 425:             let condition_map = Self::convert_condition_document(exp_group.context())?;
428: 426: 
429: 427:             let context = Exp::<Condition>::try_from(condition_map)
430: 428:                 .map_err(|e| {
431: 429:                     SuperpositionError::SerializationError(format!(
432: 430:                         "Invalid condition: {}",
433: 431:                         e
434: 432:                     ))
435: 433:                 })?
436: 434:                 .into_inner();
437: 435:             let group_type = match exp_group.group_type {
438: 436:                 SdkGroupType::SystemGenerated => GroupType::SystemGenerated,
439: 437:                 SdkGroupType::UserCreated => GroupType::UserCreated,
440: 438:                 _ => {
441: 439:                     return Err(SuperpositionError::SerializationError(
442: 440:                         "Unknown group type".to_string(),
443: 441:                     ))
444: 442:                 }
445: 443:             };
446: 444: 
447: 445:             let experiment_group = FfiExperimentGroup {
448: 446:                 id: exp_group.id.clone(),
449: 447:                 context,
450: 448:                 traffic_percentage: exp_group.traffic_percentage as u8,
451: 449:                 member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: exp_group.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids().to_vec(),
452: 450:                 group_type,
453: 451:                 buckets: Buckets::try_from(
454: 452:                     exp_group
455: 453:                         .buckets
456: 454:                         .iter()
457: 455:                         .map(|b| {
458: 456:                             b.as_ref().map(|bucket| Bucket {
459: 457:                                 variant_id: bucket.variant_id.clone(),
460: 458:                                 experiment_id: bucket.experiment_id.clone(),
461: 459:                             })
462: 460:                         })
463: 461:                         .collect::<Vec<_>>(),
464: 462:                 )
465: 463:                 .map_err(SuperpositionError::SerializationError)?,
466: 464:             };
467: 465: 
468: 466:             trimmed_group_list.push(experiment_group);
469: 467:         }
470: 468: 
471: 469:         Ok(trimmed_group_list)
472: 470:     }
473: 471: 
474: 472:     /// Convert AWS Smithy Document to serde_json::Value
475: 473:     pub fn document_to_value(doc: &aws_smithy_types::Document) -> Result<Value> {
476: 474:         Self::document_to_value_recursive(doc)
477: 475:     }
478: 476: 
479: 477:     pub fn hashmap_to_map(
480: 478:         hashmap: &HashMap<String, aws_smithy_types::Document>,
481: 479:     ) -> Result<Map<String, Value>> {
482: 480:         hashmap
483: 481:             .iter()
484: 482:             .map(|(k, v)| {
485: 483:                 let value = Self::document_to_value(v)?;
486: 484:                 Ok((k.clone(), value))
487: 485:             })
488: 486:             .collect()
489: 487:     }
490: 488: 
491: 489:     /// Recursively convert AWS Smithy Document to serde_json::Value by properly matching variants
492: 490:     fn document_to_value_recursive(doc: &aws_smithy_types::Document) -> Result<Value> {
493: 491:         use aws_smithy_types::Document;
494: 492: 
495: 493:         match doc {
496: 494:             Document::Object(obj) => {
497: 495:                 let mut map = Map::new();
498: 496:                 for (key, value) in obj {
499: 497:                     let converted_value = Self::document_to_value_recursive(value)?;
500: 498:                     map.insert(key.clone(), converted_value);
501: 499:                 }
502: 500:                 Ok(Value::Object(map))
503: 501:             }
504: 502:             Document::Array(arr) => {
505: 503:                 let mut vec = Vec::new();
506: 504:                 for item in arr {
507: 505:                     let converted_item = Self::document_to_value_recursive(item)?;
508: 506:                     vec.push(converted_item);
509: 507:                 }
510: 508:                 Ok(Value::Array(vec))
511: 509:             }
512: 510:             Document::Number(num) => {
513: 511:                 use aws_smithy_types::Number;
514: 512:                 match num {
515: 513:                     Number::PosInt(val) => {
516: 514:                         Ok(Value::Number(serde_json::Number::from(*val)))
517: 515:                     }
518: 516:                     Number::NegInt(val) => {
519: 517:                         Ok(Value::Number(serde_json::Number::from(*val)))
520: 518:                     }
521: 519:                     Number::Float(val) => Ok(Value::Number(
522: 520:                         serde_json::Number::from_f64(*val).ok_or_else(|| {
523: 521:                             SuperpositionError::SerializationError(
524: 522:                                 "Invalid float value".into(),
525: 523:                             )
526: 524:                         })?,
527: 525:                     )),
528: 526:                 }
529: 527:             }
530: 528:             Document::String(s) => Ok(Value::String(s.clone())),
531: 529:             Document::Bool(b) => Ok(Value::Bool(*b)),
532: 530:             Document::Null => Ok(Value::Null),
533: 531:         }
534: 532:     }
535: 533: 
536: 534:     pub fn convert_evaluation_context_value_to_serde_value(
537: 535:         value: &open_feature::EvaluationContextFieldValue,
538: 536:     ) -> Value {
539: 537:         match value {
540: 538:             open_feature::EvaluationContextFieldValue::Bool(b) => Value::Bool(*b),
541: 539:             open_feature::EvaluationContextFieldValue::Int(i) => {
542: 540:                 Value::Number(serde_json::Number::from(*i))
543: 541:             }
544: 542:             open_feature::EvaluationContextFieldValue::Float(f) => json!(f),
545: 543:             open_feature::EvaluationContextFieldValue::String(s) => {
546: 544:                 Value::String(s.clone())
547: 545:             }
548: 546:             open_feature::EvaluationContextFieldValue::DateTime(dt) => {
549: 547:                 Value::String(dt.to_string())
550: 548:             }
551: 549:             open_feature::EvaluationContextFieldValue::Struct(s) => {
552: 550:                 // Convert struct to serde_json::Value
553: 551:                 let struct_map: Map<String, Value> = s
554: 552:                     .as_ref()
555: 553:                     .downcast_ref::<Map<String, Value>>()
556: 554:                     .cloned()
557: 555:                     .unwrap_or_default();
558: 556:                 Value::Object(struct_map)
559: 557:             }
560: 558:         }
561: 559:     }
562: 560:     /// Convert evaluation context to dimension data format expected by lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types
563: 561:     pub fn context_to_dimension_data(
564: 562:         context: &open_feature::EvaluationContext,
565: 563:     ) -> Map<String, Value> {
566: 564:         let mut dimension_data = Map::new();
567: 565: 
568: 566:         // Add targeting key if present
569: 567:         if let Some(targeting_key) = &context.targeting_key {
570: 568:             dimension_data.insert(
571: 569:                 "targeting_key".to_string(),
572: 570:                 Value::String(targeting_key.to_string()),
573: 571:             );
574: 572:         }
575: 573: 
576: 574:         // Add all other fields from the context
577: 575:         for (key, value) in &context.custom_fields {
578: 576:             let serde_value =
579: 577:                 Self::convert_evaluation_context_value_to_serde_value(value);
580: 578:             dimension_data.insert(key.clone(), serde_value);
581: 579:         }
582: 580: 
583: 581:         debug!(
584: 582:             "Converted evaluation context to dimension data with {} keys",
585: 583:             dimension_data.len()
586: 584:         );
587: 585:         dimension_data
588: 586:     }
589: 587: 
590: 588:     /// Convert Config back to the legacy format for compatibility with existing provider logic
591: 589:     pub fn config_to_legacy_format(config: &Config) -> HashMap<String, Value> {
592: 590:         let mut result = HashMap::new();
593: 591: 
594: 592:         // Convert default_configs
595: 593:         result.insert(
596: 594:             "default_configs".to_string(),
597: 595:             Value::Object(config.default_configs.clone()),
598: 596:         );
599: 597: 
600: 598:         // Convert overrides to the expected format
601: 599:         let mut overrides_map = Map::new();
602: 600:         for (key, overrides) in &config.overrides {
603: 601:             let override_value: Map<String, Value> = overrides.clone().into();
604: 602:             overrides_map.insert(key.clone(), Value::Object(override_value));
605: 603:         }
606: 604:         result.insert("overrides".to_string(), Value::Object(overrides_map));
607: 605: 
608: 606:         // Convert contexts
609: 607:         let contexts_array: Vec<Value> = config
610: 608:             .contexts
611: 609:             .iter()
612: 610:             .map(|context| {
613: 611:                 let condition_map: Map<String, Value> = context.condition.clone().into();
614: 612:                 serde_json::json!({
615: 613:                     "id": context.id,
616: 614:                     "priority": context.priority,
617: 615:                     "weight": context.weight,
618: 616:                     "override_with_keys": context.override_with_keys,
619: 617:                     "condition": condition_map
620: 618:                 })
621: 619:             })
622: 620:             .collect();
623: 621:         result.insert("contexts".to_string(), Value::Array(contexts_array));
624: 622: 
625: 623:         debug!(
626: 624:             "Converted Config to legacy format with {} sections",
627: 625:             result.len()
628: 626:         );
629: 627:         result
630: 628:     }
631: 629: 
632: 630:     /// Evaluate config using lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types logic and return resolved values
633: 631:     pub fn evaluate_config(
634: 632:         config: &Config,
635: 633:         dimension_data: &Map<String, Value>,
636: 634:         prefix_filter: Option<&[String]>,
637: 635:     ) -> Result<HashMap<String, Value>> {
638: 636:         debug!(
639: 637:             "Evaluating config with dimension data: {:?}",
640: 638:             dimension_data.keys().collect::<Vec<_>>()
641: 639:         );
642: 640: 
643: 641:         // Filter by dimensions first
644: 642:         let filtered_config = config.filter_by_dimensions(dimension_data);
645: 643:         debug!(
646: 644:             "Filtered config has {} contexts after dimension filtering",
647: 645:             filtered_config.contexts.len()
648: 646:         );
649: 647: 
650: 648:         // Apply prefix filtering if specified
651: 649:         let final_config = if let Some(prefixes) = prefix_filter {
652: 650:             let prefix_set: std::collections::HashSet<String> =
653: 651:                 prefixes.iter().cloned().collect();
654: 652:             filtered_config.filter_by_prefix(&prefix_set)
655: 653:         } else {
656: 654:             filtered_config
657: 655:         };
658: 656: 
659: 657:         debug!(
660: 658:             "Final config has {} contexts after prefix filtering",
661: 659:             final_config.contexts.len()
662: 660:         );
663: 661: 
664: 662:         // Start with default configs
665: 663:         let mut result = final_config.default_configs.clone();
666: 664: 
667: 665:         // Apply overrides based on context priority (higher priority wins)
668: 666:         let mut sorted_contexts = final_config.contexts.clone();
669: 667:         sorted_contexts.sort_by_key(|c| std::cmp::Reverse(c.priority)); // Sort by priority descending
670: 668: 
671: 669:         for context in sorted_contexts {
672: 670:             if let Some(override_key) = context.override_with_keys.first() {
673: 671:                 if let Some(overrides) = final_config.overrides.get(override_key) {
674: 672:                     let override_map: Map<String, Value> = overrides.clone().into();
675: 673:                     for (override_key, value) in override_map {
676: 674:                         result.insert(override_key, value);
677: 675:                         debug!("Applied override for key");
678: 676:                     }
679: 677:                 }
680: 678:             }
681: 679:         }
682: 680: 
683: 681:         debug!(
684: 682:             "Config evaluation completed with {} final keys",
685: 683:             result.len()
686: 684:         );
687: 685: 
688: 686:         // Convert Map<String, Value> to HashMap<String, Value>
689: 687:         let final_result: HashMap<String, Value> = result.into_iter().collect();
690: 688:         Ok(final_result)
691: 689:     }
692: 690: 
693: 691:     /// Convert serde_json Value to boolean for OpenFeature provider
694: 692:     pub fn serde_value_to_bool(value: &Value) -> Result<bool> {
695: 693:         match value {
696: 694:             Value::Bool(b) => Ok(*b),
697: 695:             Value::String(s) => s.parse::<bool>().map_err(|_| {
698: 696:                 SuperpositionError::ConfigError(format!(
699: 697:                     "Cannot convert string '{}' to boolean",
700: 698:                     s
701: 699:                 ))
702: 700:             }),
703: 701:             _ => Err(SuperpositionError::ConfigError(format!(
704: 702:                 "Cannot convert {:?} to boolean",
705: 703:                 value
706: 704:             ))),
707: 705:         }
708: 706:     }
709: 707: 
710: 708:     /// Convert serde_json Value to string for OpenFeature provider
711: 709:     pub fn serde_value_to_string(value: &Value) -> Result<String> {
712: 710:         match value {
713: 711:             Value::String(s) => Ok(s.clone()),
714: 712:             Value::Number(n) => Ok(n.to_string()),
715: 713:             Value::Bool(b) => Ok(b.to_string()),
716: 714:             _ => Err(SuperpositionError::ConfigError(format!(
717: 715:                 "Cannot convert {:?} to string",
718: 716:                 value
719: 717:             ))),
720: 718:         }
721: 719:     }
722: 720: 
723: 721:     /// Convert serde_json Value to integer for OpenFeature provider
724: 722:     pub fn serde_value_to_int(value: &Value) -> Result<i64> {
725: 723:         match value {
726: 724:             Value::Number(n) => n.as_i64().ok_or_else(|| {
727: 725:                 SuperpositionError::ConfigError(format!(
728: 726:                     "Cannot convert number {} to i64",
729: 727:                     n
730: 728:                 ))
731: 729:             }),
732: 730:             Value::String(s) => s.parse::<i64>().map_err(|_| {
733: 731:                 SuperpositionError::ConfigError(format!(
734: 732:                     "Cannot convert string '{}' to i64",
735: 733:                     s
736: 734:                 ))
737: 735:             }),
738: 736:             _ => Err(SuperpositionError::ConfigError(format!(
739: 737:                 "Cannot convert {:?} to i64",
740: 738:                 value
741: 739:             ))),
742: 740:         }
743: 741:     }
744: 742: 
745: 743:     /// Convert serde_json Value to float for OpenFeature provider
746: 744:     pub fn serde_value_to_float(value: &Value) -> Result<f64> {
747: 745:         match value {
748: 746:             Value::Number(n) => n.as_f64().ok_or_else(|| {
749: 747:                 SuperpositionError::ConfigError(format!(
750: 748:                     "Cannot convert number {} to f64",
751: 749:                     n
752: 750:                 ))
753: 751:             }),
754: 752:             Value::String(s) => s.parse::<f64>().map_err(|_| {
755: 753:                 SuperpositionError::ConfigError(format!(
756: 754:                     "Cannot convert string '{}' to f64",
757: 755:                     s
758: 756:                 ))
759: 757:             }),
760: 758:             _ => Err(SuperpositionError::ConfigError(format!(
761: 759:                 "Cannot convert {:?} to f64",
762: 760:                 value
763: 761:             ))),
764: 762:         }
765: 763:     }
766: 764: 
767: 765:     /// Convert serde_json Value to OpenFeature StructValue
768: 766:     pub fn serde_value_to_struct_value(
769: 767:         value: &Value,
770: 768:     ) -> Result<open_feature::StructValue> {
771: 769:         match value {
772: 770:             Value::Object(map) => {
773: 771:                 let mut fields = HashMap::new();
774: 772:                 for (k, v) in map {
775: 773:                     let open_feature_value = Self::serde_value_to_openfeature_value(v)?;
776: 774:                     fields.insert(k.clone(), open_feature_value);
777: 775:                 }
778: 776:                 // StructValue is just a struct with a fields HashMap, not a complex conversion
779: 777:                 Ok(open_feature::StructValue { fields })
780: 778:             }
781: 779:             Value::Array(list) => {
782: 780:                 let mut fields = HashMap::new();
783: 781:                 for (index, item) in list.iter().enumerate() {
784: 782:                     let open_feature_value =
785: 783:                         Self::serde_value_to_openfeature_value(item)?;
786: 784:                     fields.insert(index.to_string(), open_feature_value);
787: 785:                 }
788: 786:                 Ok(open_feature::StructValue { fields })
789: 787:             }
790: 788:             _ => Err(SuperpositionError::ConfigError(format!(
791: 789:                 "Cannot convert {:?} to StructValue - flag must be an object/array",
792: 790:                 value
793: 791:             ))),
794: 792:         }
795: 793:     }
796: 794: 
797: 795:     /// Convert serde_json Value to OpenFeature Value
798: 796:     pub fn serde_value_to_openfeature_value(
799: 797:         value: &Value,
800: 798:     ) -> Result<open_feature::Value> {
801: 799:         match value {
802: 800:             Value::Bool(b) => Ok(open_feature::Value::Bool(*b)),
803: 801:             Value::String(s) => Ok(open_feature::Value::String(s.clone())),
804: 802:             Value::Number(n) => {
805: 803:                 if let Some(i) = n.as_i64() {
806: 804:                     Ok(open_feature::Value::Int(i))
807: 805:                 } else if let Some(f) = n.as_f64() {
808: 806:                     Ok(open_feature::Value::Float(f))
809: 807:                 } else {
810: 808:                     Err(SuperpositionError::ConfigError(format!(
811: 809:                         "Cannot convert number {} to OpenFeature value",
812: 810:                         n
813: 811:                     )))
814: 812:                 }
815: 813:             }
816: 814:             Value::Array(arr) => {
817: 815:                 let mut list = Vec::new();
818: 816:                 for item in arr {
819: 817:                     list.push(Self::serde_value_to_openfeature_value(item)?);
820: 818:                 }
821: 819:                 // OpenFeature uses Array, not List
822: 820:                 Ok(open_feature::Value::Array(list))
823: 821:             }
824: 822:             Value::Object(map) => {
825: 823:                 let mut fields = HashMap::new();
826: 824:                 for (k, v) in map {
827: 825:                     let open_feature_value = Self::serde_value_to_openfeature_value(v)?;
828: 826:                     fields.insert(k.clone(), open_feature_value);
829: 827:                 }
830: 828:                 // Create StructValue directly with fields HashMap
831: 829:                 let struct_value = open_feature::StructValue { fields };
832: 830:                 Ok(open_feature::Value::Struct(struct_value))
833: 831:             }
834: 832:             Value::Null => Err(SuperpositionError::ConfigError(
835: 833:                 "Cannot convert null to OpenFeature value".to_string(),
836: 834:             )),
837: 835:         }
838: 836:     }
839: 837: }
840: 838: ```
841: 839: ```
842: 840: ```
843: 841: ```
844: ```
```

