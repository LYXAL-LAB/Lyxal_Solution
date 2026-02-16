1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\tests\experimentation_tests.rs
10: 8: ```rust
11: 9: use chrono::Utc;
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform::api::experiments::helpers;
13: 11: use serde_json::{Map, Value, json};
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::ExperimentationFlags;
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
16: 14:     Condition, Exp, Overrides,
17: 15:     database::models::{
18: 16:         ChangeReason, Description, Metrics,
19: 17:         experimentation::{
20: 18:             Experiment, ExperimentStatusType, ExperimentType, TrafficPercentage, Variant,
21: 19:             Variants,
22: 20:         },
23: 21:     },
24: 22:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
25: 23: };
26: 24: 
27: 25: enum Dimensions {
28: 26:     Os(String),
29: 27:     Client(String),
30: 28:     #[allow(dead_code)]
31: 29:     VariantIds(String),
32: 30: }
33: 31: 
34: 32: fn multiple_dimension_ctx_gen(values: Vec<Dimensions>) -> Map<String, Value> {
35: 33:     values
36: 34:         .into_iter()
37: 35:         .map(|val| {
38: 36:             let (key, value) = match val {
39: 37:                 Dimensions::Os(os) => ("os".to_string(), json!(os)),
40: 38:                 Dimensions::Client(lyx-core-lyx_core_lyx-core-lyx_core_client_id) => {
41: 39:                     ("lyx-core-lyx_core_lyx-core-lyx_core_clientId".to_string(), json!(lyx-core-lyx_core_lyx-core-lyx_core_client_id))
42: 40:                 }
43: 41:                 Dimensions::VariantIds(id) => ("variantIds".to_string(), json!(id)),
44: 42:             };
45: 43:             (key, value)
46: 44:         })
47: 45:         .collect::<Map<String, Value>>()
48: 46: }
49: 47: 
50: 48: fn experiment_gen(
51: 49:     override_keys: &[String],
52: 50:     context: &Condition,
53: 51:     status: ExperimentStatusType,
54: 52:     variants: &[Variant],
55: 53: ) -> Experiment {
56: 54:     Experiment {
57: 55:         id: 123456789,
58: 56:         created_at: Utc::now(),
59: 57:         created_by: "test".to_string(),
60: 58:         last_modified: Utc::now(),
61: 59:         last_modified_by: "test".to_string(),
62: 60:         name: "experiment-test".to_string(),
63: 61:         experiment_type: ExperimentType::Default,
64: 62:         traffic_percentage: TrafficPercentage::default(),
65: 63:         started_at: None,
66: 64:         started_by: None,
67: 65: 
68: 66:         override_keys: override_keys.to_vec(),
69: 67:         status,
70: 68:         context: context.clone(),
71: 69:         variants: Variants::new(variants.to_owned()),
72: 70:         chosen_variant: None,
73: 71:         description: Description::try_from(String::from("test")).unwrap(),
74: 72:         change_reason: ChangeReason::try_from(String::from("test")).unwrap(),
75: 73:         metrics: Metrics::default(),
76: 74:         experiment_group_id: None,
77: 75:     }
78: 76: }
79: 77: 
80: 78: #[test]
81: 79: fn test_duplicate_override_key_entries() {
82: 80:     let override_keys = vec!["key1".to_string(), "key2".to_string(), "key1".to_string()];
83: 81:     assert!(matches!(
84: 82:         helpers::validate_override_keys(&override_keys),
85: 83:         Err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument(_))
86: 84:     ));
87: 85: }
88: 86: 
89: 87: #[test]
90: 88: fn test_unique_override_key_entries() {
91: 89:     let override_keys = vec!["key1".to_string(), "key2".to_string()];
92: 90:     assert!(matches!(
93: 91:         helpers::validate_override_keys(&override_keys),
94: 92:         Ok(())
95: 93:     ));
96: 94: }
97: 95: 
98: 96: #[test]
99: 97: fn test_are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts() -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
100: 98:     let context_a = multiple_dimension_ctx_gen(vec![
101: 99:         Dimensions::Os("os1".to_string()),
102: 100:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
103: 101:     ]);
104: 102:     let context_a = Exp::<Condition>::try_from(context_a.clone())
105: 103:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
106: 104:         .into_inner();
107: 105: 
108: 106:     let context_b = multiple_dimension_ctx_gen(vec![
109: 107:         Dimensions::Os("os1".to_string()),
110: 108:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
111: 109:     ]);
112: 110:     let context_b = Exp::<Condition>::try_from(context_b.clone())
113: 111:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
114: 112:         .into_inner();
115: 113: 
116: 114:     let context_c = multiple_dimension_ctx_gen(vec![Dimensions::Os("os1".to_string())]);
117: 115:     let context_d = multiple_dimension_ctx_gen(vec![Dimensions::Os("os2".to_string())]);
118: 116:     let context_c = Exp::<Condition>::try_from(context_c.clone())
119: 117:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
120: 118:         .into_inner();
121: 119:     let context_d = Exp::<Condition>::try_from(context_d.clone())
122: 120:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
123: 121:         .into_inner();
124: 122: 
125: 123:     // both contexts with same dimensions
126: 124:     assert!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_a)?);
127: 125:     // contexts with one different dimension
128: 126:     assert!(!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_b)?));
129: 127:     // one context dimensions are subset of other
130: 128:     assert!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_c)?);
131: 129:     // one context dimensions not a subset of other but have less dimensions that other
132: 130:     assert!(!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_a, &context_d)?));
133: 131:     // disjoint contexts
134: 132:     assert!(!(helpers::are_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_contexts(&context_c, &context_d)?));
135: 133:     Ok(())
136: 134: }
137: 135: 
138: 136: #[test]
139: 137: fn test_check_variants_override_coverage() -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
140: 138:     let override_keys = vec!["key1".to_string(), "key2".to_string()];
141: 139:     let overrides = [
142: 140:         Exp::<Overrides>::try_from(Map::from_iter(vec![
143: 141:             ("key1".to_string(), json!("value1")),
144: 142:             ("key2".to_string(), json!("value2")),
145: 143:         ])),
146: 144:         // has one override key missing
147: 145:         Exp::<Overrides>::try_from(Map::from_iter(vec![(
148: 146:             "key1".to_string(),
149: 147:             json!("value1"),
150: 148:         )])),
151: 149:         // has an unknown override key
152: 150:         Exp::<Overrides>::try_from(Map::from_iter(vec![(
153: 151:             "key3".to_string(),
154: 152:             json!("value3"),
155: 153:         )])),
156: 154:         // has an extra unknown override key
157: 155:         Exp::<Overrides>::try_from(Map::from_iter(vec![
158: 156:             ("key1".to_string(), json!("value1")),
159: 157:             ("key2".to_string(), json!("value2")),
160: 158:             ("key3".to_string(), json!("value3")),
161: 159:         ])),
162: 160:     ]
163: 161:     .into_iter()
164: 162:     .map(|a| a.map(|b| b.into_inner()))
165: 163:     .collect::<Result<Vec<Overrides>, String>>()
166: 164:     .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?;
167: 165: 
168: 166:     assert!(helpers::check_variant_override_coverage(
169: 167:         &overrides[0],
170: 168:         &override_keys
171: 169:     ));
172: 170:     assert!(!helpers::check_variant_override_coverage(
173: 171:         &overrides[1],
174: 172:         &override_keys
175: 173:     ));
176: 174:     assert!(!helpers::check_variant_override_coverage(
177: 175:         &overrides[2],
178: 176:         &override_keys
179: 177:     ));
180: 178:     assert!(!helpers::check_variant_override_coverage(
181: 179:         &overrides[3],
182: 180:         &override_keys
183: 181:     ));
184: 182:     Ok(())
185: 183: }
186: 184: 
187: 185: /************************* No Restrictions *****************************************/
188: 186: 
189: 187: #[test]
190: 188: fn test_is_valid_experiment_no_restrictions_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment()
191: 189: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
192: 190:     let experiment_context = multiple_dimension_ctx_gen(vec![
193: 191:         Dimensions::Os("os1".to_string()),
194: 192:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
195: 193:     ]);
196: 194:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
197: 195:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
198: 196:         .into_inner();
199: 197:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
200: 198:     let flags = ExperimentationFlags {
201: 199:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
202: 200:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
203: 201:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
204: 202:     };
205: 203: 
206: 204:     let active_experiments = vec![experiment_gen(
207: 205:         &["key1".to_string(), "key2".to_string()],
208: 206:         &experiment_context,
209: 207:         ExperimentStatusType::CREATED,
210: 208:         &[],
211: 209:     )];
212: 210: 
213: 211:     assert_eq!(
214: 212:         helpers::is_valid_experiment(
215: 213:             &experiment_context,
216: 214:             &experiment_override_keys,
217: 215:             &flags,
218: 216:             &active_experiments
219: 217:         )?,
220: 218:         (true, "".to_string())
221: 219:     );
222: 220: 
223: 221:     Ok(())
224: 222: }
225: 223: 
226: 224: #[test]
227: 225: fn test_is_valid_experiment_no_restrictions_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment()
228: 226: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
229: 227:     let experiment_context = multiple_dimension_ctx_gen(vec![
230: 228:         Dimensions::Os("os1".to_string()),
231: 229:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
232: 230:     ]);
233: 231:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
234: 232:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
235: 233:         .into_inner();
236: 234:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
237: 235:     let flags = ExperimentationFlags {
238: 236:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
239: 237:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
240: 238:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
241: 239:     };
242: 240: 
243: 241:     let active_experiments = vec![experiment_gen(
244: 242:         &["key1".to_string(), "key2".to_string()],
245: 243:         &Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
246: 244:             Dimensions::Os("os2".to_string()),
247: 245:             Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
248: 246:         ]))
249: 247:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
250: 248:         .into_inner(),
251: 249:         ExperimentStatusType::CREATED,
252: 250:         &[],
253: 251:     )];
254: 252: 
255: 253:     assert_eq!(
256: 254:         helpers::is_valid_experiment(
257: 255:             &experiment_context,
258: 256:             &experiment_override_keys,
259: 257:             &flags,
260: 258:             &active_experiments
261: 259:         )?,
262: 260:         (true, "".to_string())
263: 261:     );
264: 262: 
265: 263:     Ok(())
266: 264: }
267: 265: 
268: 266: /************************* Restrict Same Keys Overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping Context *****************************************/
269: 267: 
270: 268: #[test]
271: 269: fn test_is_valid_experiment_restrict_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_same_keys()
272: 270: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
273: 271:     let experiment_context = multiple_dimension_ctx_gen(vec![
274: 272:         Dimensions::Os("os1".to_string()),
275: 273:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
276: 274:     ]);
277: 275:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
278: 276:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
279: 277:         .into_inner();
280: 278:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
281: 279:     let flags = ExperimentationFlags {
282: 280:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
283: 281:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
284: 282:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
285: 283:     };
286: 284: 
287: 285:     let active_experiments = vec![experiment_gen(
288: 286:         &experiment_override_keys,
289: 287:         &experiment_context,
290: 288:         ExperimentStatusType::CREATED,
291: 289:         &[],
292: 290:     )];
293: 291: 
294: 292:     assert_eq!(
295: 293:         helpers::is_valid_experiment(
296: 294:             &experiment_context,
297: 295:             &experiment_override_keys,
298: 296:             &flags,
299: 297:             &active_experiments
300: 298:         )?,
301: 299:         (false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
302: 300:     );
303: 301: 
304: 302:     Ok(())
305: 303: }
306: 304: 
307: 305: #[test]
308: 306: fn test_is_valid_experiment_restrict_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_one_same_key()
309: 307: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
310: 308:     let experiment_context = multiple_dimension_ctx_gen(vec![
311: 309:         Dimensions::Os("os1".to_string()),
312: 310:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
313: 311:     ]);
314: 312:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
315: 313:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
316: 314:         .into_inner();
317: 315:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
318: 316:     let flags = ExperimentationFlags {
319: 317:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
320: 318:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
321: 319:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
322: 320:     };
323: 321: 
324: 322:     let active_experiments = vec![experiment_gen(
325: 323:         &["key1".to_string(), "key3".to_string()],
326: 324:         &experiment_context,
327: 325:         ExperimentStatusType::CREATED,
328: 326:         &[],
329: 327:     )];
330: 328: 
331: 329:     assert_eq!(
332: 330:         helpers::is_valid_experiment(
333: 331:             &experiment_context,
334: 332:             &experiment_override_keys,
335: 333:             &flags,
336: 334:             &active_experiments
337: 335:         )?,
338: 336:         (false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
339: 337:     );
340: 338: 
341: 339:     Ok(())
342: 340: }
343: 341: 
344: 342: #[test]
345: 343: fn test_is_valid_experiment_restrict_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_diff_keys()
346: 344: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
347: 345:     let experiment_context = multiple_dimension_ctx_gen(vec![
348: 346:         Dimensions::Os("os1".to_string()),
349: 347:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
350: 348:     ]);
351: 349:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
352: 350:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
353: 351:         .into_inner();
354: 352:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
355: 353:     let flags = ExperimentationFlags {
356: 354:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
357: 355:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
358: 356:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
359: 357:     };
360: 358: 
361: 359:     let active_experiments = vec![experiment_gen(
362: 360:         &["key3".to_string(), "key4".to_string()],
363: 361:         &experiment_context,
364: 362:         ExperimentStatusType::CREATED,
365: 363:         &[],
366: 364:     )];
367: 365: 
368: 366:     assert_eq!(
369: 367:         helpers::is_valid_experiment(
370: 368:             &experiment_context,
371: 369:             &experiment_override_keys,
372: 370:             &flags,
373: 371:             &active_experiments
374: 372:         )?,
375: 373:         (true, "".to_string())
376: 374:     );
377: 375: 
378: 376:     Ok(())
379: 377: }
380: 378: 
381: 379: /************************* Restrict Different Keys Overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping Context *****************************************/
382: 380: 
383: 381: #[test]
384: 382: fn test_is_valid_experiment_restrict_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_same_keys()
385: 383: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
386: 384:     let experiment_context = multiple_dimension_ctx_gen(vec![
387: 385:         Dimensions::Os("os1".to_string()),
388: 386:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
389: 387:     ]);
390: 388:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
391: 389:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
392: 390:         .into_inner();
393: 391:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
394: 392:     let flags = ExperimentationFlags {
395: 393:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
396: 394:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
397: 395:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
398: 396:     };
399: 397: 
400: 398:     let active_experiments = vec![experiment_gen(
401: 399:         &experiment_override_keys,
402: 400:         &experiment_context,
403: 401:         ExperimentStatusType::CREATED,
404: 402:         &[],
405: 403:     )];
406: 404: 
407: 405:     assert_eq!(
408: 406:         helpers::is_valid_experiment(
409: 407:             &experiment_context,
410: 408:             &experiment_override_keys,
411: 409:             &flags,
412: 410:             &active_experiments
413: 411:         )?,
414: 412:         (true, "".to_string())
415: 413:     );
416: 414: 
417: 415:     Ok(())
418: 416: }
419: 417: 
420: 418: #[test]
421: 419: fn test_is_valid_experiment_restrict_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_one_diff_key()
422: 420: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
423: 421:     let experiment_context = multiple_dimension_ctx_gen(vec![
424: 422:         Dimensions::Os("os1".to_string()),
425: 423:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
426: 424:     ]);
427: 425:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
428: 426:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
429: 427:         .into_inner();
430: 428:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
431: 429:     let flags = ExperimentationFlags {
432: 430:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
433: 431:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
434: 432:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
435: 433:     };
436: 434: 
437: 435:     let active_experiments = vec![experiment_gen(
438: 436:         &["key1".to_string(), "key3".to_string()],
439: 437:         &experiment_context,
440: 438:         ExperimentStatusType::CREATED,
441: 439:         &[],
442: 440:     )];
443: 441: 
444: 442:     assert_eq!(
445: 443:         helpers::is_valid_experiment(
446: 444:             &experiment_context,
447: 445:             &experiment_override_keys,
448: 446:             &flags,
449: 447:             &active_experiments
450: 448:         )?,
451: 449:         (false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
452: 450:     );
453: 451: 
454: 452:     Ok(())
455: 453: }
456: 454: 
457: 455: #[test]
458: 456: fn test_is_valid_experiment_restrict_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_diff_keys()
459: 457: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
460: 458:     let experiment_context = multiple_dimension_ctx_gen(vec![
461: 459:         Dimensions::Os("os1".to_string()),
462: 460:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
463: 461:     ]);
464: 462:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
465: 463:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
466: 464:         .into_inner();
467: 465:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
468: 466:     let flags = ExperimentationFlags {
469: 467:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
470: 468:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
471: 469:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
472: 470:     };
473: 471: 
474: 472:     let active_experiments = vec![experiment_gen(
475: 473:         &["key3".to_string(), "key4".to_string()],
476: 474:         &experiment_context,
477: 475:         ExperimentStatusType::CREATED,
478: 476:         &[],
479: 477:     )];
480: 478: 
481: 479:     assert_eq!(
482: 480:         helpers::is_valid_experiment(
483: 481:             &experiment_context,
484: 482:             &experiment_override_keys,
485: 483:             &flags,
486: 484:             &active_experiments
487: 485:         )?,
488: 486:         (false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
489: 487:     );
490: 488: 
491: 489:     Ok(())
492: 490: }
493: 491: 
494: 492: /************************* Restrict Same Keys Non Overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping Context *****************************************/
495: 493: 
496: 494: #[test]
497: 495: fn test_is_valid_experiment_restrict_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_same_keys()
498: 496: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
499: 497:     let experiment_context = multiple_dimension_ctx_gen(vec![
500: 498:         Dimensions::Os("os1".to_string()),
501: 499:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
502: 500:     ]);
503: 501:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
504: 502:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
505: 503:         .into_inner();
506: 504:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
507: 505:     let flags = ExperimentationFlags {
508: 506:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
509: 507:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
510: 508:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
511: 509:     };
512: 510: 
513: 511:     let active_experiments = vec![experiment_gen(
514: 512:         &experiment_override_keys,
515: 513:         &Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
516: 514:             Dimensions::Os("os2".to_string()),
517: 515:             Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
518: 516:         ]))
519: 517:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
520: 518:         .into_inner(),
521: 519:         ExperimentStatusType::CREATED,
522: 520:         &[],
523: 521:     )];
524: 522: 
525: 523:     assert_eq!(
526: 524:         helpers::is_valid_experiment(
527: 525:             &experiment_context,
528: 526:             &experiment_override_keys,
529: 527:             &flags,
530: 528:             &active_experiments
531: 529:         )?,
532: 530:         (false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
533: 531:     );
534: 532: 
535: 533:     Ok(())
536: 534: }
537: 535: 
538: 536: #[test]
539: 537: fn test_is_valid_experiment_restrict_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_one_diff_key()
540: 538: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
541: 539:     let experiment_context = multiple_dimension_ctx_gen(vec![
542: 540:         Dimensions::Os("os1".to_string()),
543: 541:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
544: 542:     ]);
545: 543:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
546: 544:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
547: 545:         .into_inner();
548: 546:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
549: 547:     let flags = ExperimentationFlags {
550: 548:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
551: 549:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
552: 550:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
553: 551:     };
554: 552: 
555: 553:     let active_experiments = vec![experiment_gen(
556: 554:         &["key1".to_string(), "key3".to_string()],
557: 555:         &Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
558: 556:             Dimensions::Os("os2".to_string()),
559: 557:             Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
560: 558:         ]))
561: 559:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
562: 560:         .into_inner(),
563: 561:         ExperimentStatusType::CREATED,
564: 562:         &[],
565: 563:     )];
566: 564: 
567: 565:     assert_eq!(
568: 566:         helpers::is_valid_experiment(
569: 567:             &experiment_context,
570: 568:             &experiment_override_keys,
571: 569:             &flags,
572: 570:             &active_experiments
573: 571:         )?,
574: 572:         (false, "This current context overlaps with an existing experiment or the keys in the context are overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping".to_string())
575: 573:     );
576: 574: 
577: 575:     Ok(())
578: 576: }
579: 577: 
580: 578: #[test]
581: 579: fn test_is_valid_experiment_restrict_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_experiment_diff_keys()
582: 580: -> Result<(), lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError> {
583: 581:     let experiment_context = multiple_dimension_ctx_gen(vec![
584: 582:         Dimensions::Os("os1".to_string()),
585: 583:         Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client1".to_string()),
586: 584:     ]);
587: 585:     let experiment_context = Exp::<Condition>::try_from(experiment_context.clone())
588: 586:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
589: 587:         .into_inner();
590: 588:     let experiment_override_keys = vec!["key1".to_string(), "key2".to_string()];
591: 589:     let flags = ExperimentationFlags {
592: 590:         allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
593: 591:         allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: false,
594: 592:         allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: true,
595: 593:     };
596: 594: 
597: 595:     let active_experiments = vec![experiment_gen(
598: 596:         &["key3".to_string(), "key4".to_string()],
599: 597:         &Exp::<Condition>::try_from(multiple_dimension_ctx_gen(vec![
600: 598:             Dimensions::Os("os2".to_string()),
601: 599:             Dimensions::Client("testlyx-core-lyx_core_lyx-core-lyx_core_client2".to_string()),
602: 600:         ]))
603: 601:         .map_err(lyx-core-lyx_core_lyx-core-lyx_core_superposition::AppError::BadArgument)?
604: 602:         .into_inner(),
605: 603:         ExperimentStatusType::CREATED,
606: 604:         &[],
607: 605:     )];
608: 606: 
609: 607:     assert_eq!(
610: 608:         helpers::is_valid_experiment(
611: 609:             &experiment_context,
612: 610:             &experiment_override_keys,
613: 611:             &flags,
614: 612:             &active_experiments
615: 613:         )?,
616: 614:         (true, "".to_string())
617: 615:     );
618: 616: 
619: 617:     Ok(())
620: 618: }
621: 619: ```
622: 620: ```
623: 621: ```
624: 622: ```
625: ```
```

