1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\tests\integration_test.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\tests\integration_test.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\tests\integration_test.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\tests\integration_test.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\tests\integration_test.rs
10: 8: ```rust
11: 9: use open_feature::{EvaluationContext, OpenFeature};
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider::{
13: 11:     ExperimentationOptions, OnDemandStrategy, RefreshStrategy, SuperpositionProvider,
14: 12:     SuperpositionProviderOptions,
15: 13: };
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::{
17: 15:     types::{ContextPut, DimensionType, Variant, WorkspaceStatus},
18: 16:     Client, Config,
19: 17: };
20: 18: 
21: 19: const WORKSPACE_ID: &str = "rustprovidertest";
22: 20: const ENDPOINT: &str = "http://localhost:8080";
23: 21: const TOKEN: &str = "12131";
24: 22: 
25: 23: /// Helper to create SDK lyx-core-lyx_core_lyx-core-lyx_core_client with bearer token auth
26: 24: fn create_sdk_lyx-core-lyx_core_lyx-core-lyx_core_client() -> Client {
27: 25:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::config::Token;
28: 26: 
29: 27:     let config = Config::builder()
30: 28:         .endpoint_url(ENDPOINT)
31: 29:         .bearer_token(Token::new(TOKEN, None))
32: 30:         .behavior_version_latest()
33: 31:         .build();
34: 32: 
35: 33:     Client::from_conf(config)
36: 34: }
37: 35: 
38: 36: /// Setup functions - mirrors Kotlin/JS/Python implementations
39: 37: async fn create_organisation(lyx-core-lyx_core_lyx-core-lyx_core_client: &Client) -> String {
40: 38:     let output = lyx-core-lyx_core_lyx-core-lyx_core_client
41: 39:         .create_organisation()
42: 40:         .name("rusttestorg")
43: 41:         .admin_email("admin@rusttestorg.com")
44: 42:         .send()
45: 43:         .await
46: 44:         .expect("Failed to create organisation");
47: 45: 
48: 46:     println!(
49: 47:         "Organisation created: {} with ID: {}",
50: 48:         output.name, output.id
51: 49:     );
52: 50:     output.id
53: 51: }
54: 52: 
55: 53: async fn create_workspace(lyx-core-lyx_core_lyx-core-lyx_core_client: &Client, org_id: &str, workspace_name: &str) {
56: 54:     lyx-core-lyx_core_lyx-core-lyx_core_client
57: 55:         .create_workspace()
58: 56:         .org_id(org_id)
59: 57:         .workspace_name(workspace_name)
60: 58:         .workspace_admin_email("test@tests.com")
61: 59:         .workspace_status(WorkspaceStatus::Enabled)
62: 60:         .allow_experiment_self_lyx-platform-lyx_platform_lyx-platform-lyx_platform_approval(true)
63: 61:         .auto_populate_control(false) // disable auto populate control for testing experiment
64: 62:         .enable_context_validation(true)
65: 63:         .enable_change_reason_validation(true)
66: 64:         .send()
67: 65:         .await
68: 66:         .expect("Failed to create workspace");
69: 67: 
70: 68:     println!("Workspace created: {}", workspace_name);
71: 69: }
72: 70: 
73: 71: async fn create_dimensions(lyx-core-lyx_core_lyx-core-lyx_core_client: &Client, org_id: &str, workspace_id: &str) {
74: 72:     println!("Creating dimensions:");
75: 73: 
76: 74:     use aws_smithy_types::Document;
77: 75: 
78: 76:     // Dimension 1: name (string)
79: 77:     lyx-core-lyx_core_lyx-core-lyx_core_client
80: 78:         .create_dimension()
81: 79:         .workspace_id(workspace_id)
82: 80:         .org_id(org_id)
83: 81:         .dimension("name")
84: 82:         .position(1)
85: 83:         .schema("type", Document::from("string"))
86: 84:         .description("customer name dimension")
87: 85:         .change_reason("adding name dimension")
88: 86:         .dimension_type(DimensionType::Regular)
89: 87:         .send()
90: 88:         .await
91: 89:         .expect("Failed to create name dimension");
92: 90:     println!("  - Created dimension: name");
93: 91: 
94: 92:     // Dimension 2: city (string)
95: 93:     lyx-core-lyx_core_lyx-core-lyx_core_client
96: 94:         .create_dimension()
97: 95:         .workspace_id(workspace_id)
98: 96:         .org_id(org_id)
99: 97:         .dimension("city")
100: 98:         .position(2)
101: 99:         .schema("type", Document::from("string"))
102: 100:         .description("city dimension")
103: 101:         .change_reason("adding city dimension")
104: 102:         .dimension_type(DimensionType::Regular)
105: 103:         .send()
106: 104:         .await
107: 105:         .expect("Failed to create city dimension");
108: 106:     println!("  - Created dimension: city");
109: 107: 
110: 108:     // Dimension 3: customers (LOCAL_COHORT with platinum/gold/otherwise)
111: 109:     // Build enum array
112: 110:     let enum_array = Document::Array(vec![
113: 111:         Document::from("platinum"),
114: 112:         Document::from("gold"),
115: 113:         Document::from("otherwise"),
116: 114:     ]);
117: 115: 
118: 116:     // Build platinum definition
119: 117:     let platinum_def = Document::Object(
120: 118:         [(
121: 119:             "in".to_string(),
122: 120:             Document::Array(vec![
123: 121:                 Document::Object(
124: 122:                     [("var".to_string(), Document::from("name"))]
125: 123:                         .into_iter()
126: 124:                         .collect(),
127: 125:                 ),
128: 126:                 Document::Array(vec![Document::from("Agush"), Document::from("Sauyav")]),
129: 127:             ]),
130: 128:         )]
131: 129:         .into_iter()
132: 130:         .collect(),
133: 131:     );
134: 132: 
135: 133:     // Build gold definition
136: 134:     let gold_def = Document::Object(
137: 135:         [(
138: 136:             "in".to_string(),
139: 137:             Document::Array(vec![
140: 138:                 Document::Object(
141: 139:                     [("var".to_string(), Document::from("name"))]
142: 140:                         .into_iter()
143: 141:                         .collect(),
144: 142:                 ),
145: 143:                 Document::Array(vec![Document::from("Angit"), Document::from("Bhrey")]),
146: 144:             ]),
147: 145:         )]
148: 146:         .into_iter()
149: 147:         .collect(),
150: 148:     );
151: 149: 
152: 150:     // Build definitions object
153: 151:     let definitions = Document::Object(
154: 152:         [
155: 153:             ("platinum".to_string(), platinum_def),
156: 154:             ("gold".to_string(), gold_def),
157: 155:         ]
158: 156:         .into_iter()
159: 157:         .collect(),
160: 158:     );
161: 159: 
162: 160:     lyx-core-lyx_core_lyx-core-lyx_core_client
163: 161:         .create_dimension()
164: 162:         .workspace_id(workspace_id)
165: 163:         .org_id(org_id)
166: 164:         .dimension("customers")
167: 165:         .position(1)
168: 166:         .schema("type", Document::from("string"))
169: 167:         .schema("enum", enum_array)
170: 168:         .schema("definitions", definitions)
171: 169:         .description("customers dimension")
172: 170:         .change_reason("adding customers dimension")
173: 171:         .dimension_type(DimensionType::LocalCohort("name".to_string()))
174: 172:         .send()
175: 173:         .await
176: 174:         .expect("Failed to create customers dimension");
177: 175:     println!("  - Created dimension: customers");
178: 176: }
179: 177: 
180: 178: async fn create_default_configs(lyx-core-lyx_core_lyx-core-lyx_core_client: &Client, org_id: &str, workspace_id: &str) {
181: 179:     println!("Creating default configs:");
182: 180: 
183: 181:     use aws_smithy_types::Document;
184: 182: 
185: 183:     // Config 1: price (number, minimum 0)
186: 184:     lyx-core-lyx_core_lyx-core-lyx_core_client
187: 185:         .create_default_config()
188: 186:         .key("price")
189: 187:         .value(Document::from(10000))
190: 188:         .schema("type", Document::from("number"))
191: 189:         .schema("minimum", Document::from(0))
192: 190:         .description("price as a positive number")
193: 191:         .change_reason("adding price config")
194: 192:         .workspace_id(workspace_id)
195: 193:         .org_id(org_id)
196: 194:         .send()
197: 195:         .await
198: 196:         .expect("Failed to create price config");
199: 197:     println!("  - Created config: price");
200: 198: 
201: 199:     // Config 2: currency (enum: Rupee/Dollar/Euro)
202: 200:     let currency_enum = Document::Array(vec![
203: 201:         Document::from("Rupee"),
204: 202:         Document::from("Dollar"),
205: 203:         Document::from("Euro"),
206: 204:     ]);
207: 205: 
208: 206:     lyx-core-lyx_core_lyx-core-lyx_core_client
209: 207:         .create_default_config()
210: 208:         .key("currency")
211: 209:         .value(Document::from("Rupee"))
212: 210:         .schema("type", Document::from("string"))
213: 211:         .schema("enum", currency_enum)
214: 212:         .description("currency as an enum")
215: 213:         .change_reason("adding currency config")
216: 214:         .workspace_id(workspace_id)
217: 215:         .org_id(org_id)
218: 216:         .send()
219: 217:         .await
220: 218:         .expect("Failed to create currency config");
221: 219:     println!("  - Created config: currency");
222: 220: }
223: 221: 
224: 222: async fn create_overrides(lyx-core-lyx_core_lyx-core-lyx_core_client: &Client, org_id: &str, workspace_id: &str) {
225: 223:     println!("Creating overrides:");
226: 224: 
227: 225:     use aws_smithy_types::Document;
228: 226: 
229: 227:     // Override 1: Boston -> Dollar
230: 228:     lyx-core-lyx_core_lyx-core-lyx_core_client
231: 229:         .create_context()
232: 230:         .workspace_id(workspace_id)
233: 231:         .org_id(org_id)
234: 232:         .request(
235: 233:             ContextPut::builder()
236: 234:                 .context("city", Document::from("Boston"))
237: 235:                 .r#override("currency", Document::from("Dollar"))
238: 236:                 .description("Bostonian")
239: 237:                 .change_reason("testing")
240: 238:                 .build()
241: 239:                 .expect("Failed to create ContextPut"),
242: 240:         )
243: 241:         .send()
244: 242:         .await
245: 243:         .expect("Failed to create Boston override");
246: 244:     println!("  - Created override: Boston -> Dollar");
247: 245: 
248: 246:     // Override 2: Berlin -> Euro
249: 247:     lyx-core-lyx_core_lyx-core-lyx_core_client
250: 248:         .create_context()
251: 249:         .workspace_id(workspace_id)
252: 250:         .org_id(org_id)
253: 251:         .request(
254: 252:             ContextPut::builder()
255: 253:                 .context("city", Document::from("Berlin"))
256: 254:                 .r#override("currency", Document::from("Euro"))
257: 255:                 .description("Berlin")
258: 256:                 .change_reason("testing")
259: 257:                 .build()
260: 258:                 .expect("Failed to create ContextPut"),
261: 259:         )
262: 260:         .send()
263: 261:         .await
264: 262:         .expect("Failed to create Berlin override");
265: 263:     println!("  - Created override: Berlin -> Euro");
266: 264: 
267: 265:     // Override 3: platinum -> price 5000
268: 266:     lyx-core-lyx_core_lyx-core-lyx_core_client
269: 267:         .create_context()
270: 268:         .workspace_id(workspace_id)
271: 269:         .org_id(org_id)
272: 270:         .request(
273: 271:             ContextPut::builder()
274: 272:                 .context("customers", Document::from("platinum"))
275: 273:                 .r#override("price", Document::from(5000))
276: 274:                 .description("platinum customer")
277: 275:                 .change_reason("testing")
278: 276:                 .build()
279: 277:                 .expect("Failed to create ContextPut"),
280: 278:         )
281: 279:         .send()
282: 280:         .await
283: 281:         .expect("Failed to create platinum override");
284: 282:     println!("  - Created override: platinum -> price 5000");
285: 283: 
286: 284:     // Override 4: gold -> price 8000
287: 285:     lyx-core-lyx_core_lyx-core-lyx_core_client
288: 286:         .create_context()
289: 287:         .workspace_id(workspace_id)
290: 288:         .org_id(org_id)
291: 289:         .request(
292: 290:             ContextPut::builder()
293: 291:                 .context("customers", Document::from("gold"))
294: 292:                 .r#override("price", Document::from(8000))
295: 293:                 .description("gold customers")
296: 294:                 .change_reason("testing")
297: 295:                 .build()
298: 296:                 .expect("Failed to create ContextPut"),
299: 297:         )
300: 298:         .send()
301: 299:         .await
302: 300:         .expect("Failed to create gold override");
303: 301:     println!("  - Created override: gold -> price 8000");
304: 302: 
305: 303:     // Override 5: karbik (otherwise) -> price 1
306: 304:     lyx-core-lyx_core_lyx-core-lyx_core_client
307: 305:         .create_context()
308: 306:         .workspace_id(workspace_id)
309: 307:         .org_id(org_id)
310: 308:         .request(
311: 309:             ContextPut::builder()
312: 310:                 .context("name", Document::from("karbik"))
313: 311:                 .r#override("price", Document::from(1))
314: 312:                 .description("edge case customer karbik")
315: 313:                 .change_reason("testing")
316: 314:                 .build()
317: 315:                 .expect("Failed to create ContextPut"),
318: 316:         )
319: 317:         .send()
320: 318:         .await
321: 319:         .expect("Failed to create karbik override");
322: 320:     println!("  - Created override: karbik -> price 1");
323: 321: }
324: 322: 
325: 323: async fn create_experiments(lyx-core-lyx_core_lyx-core-lyx_core_client: &Client, org_id: &str, workspace_id: &str) {
326: 324:     println!("Creating experiment:");
327: 325: 
328: 326:     use aws_smithy_types::Document;
329: 327: 
330: 328:     let response = lyx-core-lyx_core_lyx-core-lyx_core_client
331: 329:         .create_experiment()
332: 330:         .workspace_id(workspace_id)
333: 331:         .org_id(org_id)
334: 332:         .name("Kolkata Pricing Experiment")
335: 333:         .context("city", Document::from("Kolkata"))
336: 334:         .variants(
337: 335:             Variant::builder()
338: 336:                 .id("control".to_string())
339: 337:                 .variant_type(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::VariantType::Control)
340: 338:                 .overrides("price", Document::from(8000)) // # Note: Using a different price to distinguish from default
341: 339:                 .build()
342: 340:                 .expect("Failed to build control variant"),
343: 341:         )
344: 342:         .variants(
345: 343:             Variant::builder()
346: 344:                 .id("Experimental".to_string())
347: 345:                 .variant_type(lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::types::VariantType::Experimental)
348: 346:                 .overrides("price", Document::from(7000))
349: 347:                 .build()
350: 348:                 .expect("Failed to build Experimental variant"),
351: 349:         )
352: 350:         .description("A test experiment")
353: 351:         .change_reason("adding test experiment")
354: 352:         .send()
355: 353:         .await
356: 354:         .expect("Failed to create experiment");
357: 355: 
358: 356:     println!("  - Created experiment: Kolkata Pricing Experiment");
359: 357: 
360: 358:     lyx-core-lyx_core_lyx-core-lyx_core_client
361: 359:         .ramp_experiment()
362: 360:         .workspace_id(workspace_id)
363: 361:         .org_id(org_id)
364: 362:         .id(response.id)
365: 363:         .traffic_percentage(50)
366: 364:         .change_reason("ramping up experiment")
367: 365:         .send()
368: 366:         .await
369: 367:         .expect("Failed to ramp experiment");
370: 368: }
371: 369: 
372: 370: async fn setup_with_sdk(org_id: &str, workspace_id: &str) {
373: 371:     println!("\n=== Setting up test environment ===\n");
374: 372: 
375: 373:     let lyx-core-lyx_core_lyx-core-lyx_core_client = create_sdk_lyx-core-lyx_core_lyx-core-lyx_core_client();
376: 374: 
377: 375:     create_workspace(&lyx-core-lyx_core_lyx-core-lyx_core_client, org_id, workspace_id).await;
378: 376:     create_dimensions(&lyx-core-lyx_core_lyx-core-lyx_core_client, org_id, workspace_id).await;
379: 377:     create_default_configs(&lyx-core-lyx_core_lyx-core-lyx_core_client, org_id, workspace_id).await;
380: 378:     create_overrides(&lyx-core-lyx_core_lyx-core-lyx_core_client, org_id, workspace_id).await;
381: 379:     create_experiments(&lyx-core-lyx_core_lyx-core-lyx_core_client, org_id, workspace_id).await;
382: 380: 
383: 381:     println!("\n=== Setup complete ===\n");
384: 382: }
385: 383: 
386: 384: async fn run_provider_tests(org_id: &str, workspace_id: &str) {
387: 385:     println!("\n=== Starting OpenFeature provider tests ===\n");
388: 386: 
389: 387:     // Create provider with on-demand refresh strategy
390: 388:     let provider_options = SuperpositionProviderOptions {
391: 389:         endpoint: ENDPOINT.to_string(),
392: 390:         token: TOKEN.to_string(),
393: 391:         org_id: org_id.to_string(),
394: 392:         workspace_id: workspace_id.to_string(),
395: 393:         refresh_strategy: RefreshStrategy::OnDemand(OnDemandStrategy::default()),
396: 394:         evaluation_cache: None,
397: 395:         fallback_config: None,
398: 396:         experimentation_options: Some(ExperimentationOptions {
399: 397:             refresh_strategy: RefreshStrategy::OnDemand(OnDemandStrategy::default()),
400: 398:             evaluation_cache: None,
401: 399:             default_toss: None,
402: 400:         }),
403: 401:     };
404: 402: 
405: 403:     let provider = SuperpositionProvider::new(provider_options);
406: 404: 
407: 405:     // Set provider as the global provider
408: 406:     let mut api = OpenFeature::singleton_mut().await;
409: 407:     api.set_provider(provider).await;
410: 408: 
411: 409:     let lyx-core-lyx_core_lyx-core-lyx_core_client = api.create_lyx-core-lyx_core_lyx-core-lyx_core_client();
412: 410: 
413: 411:     // Test 1: Default values (no context)
414: 412:     println!("Test 1: Default values (no context)");
415: 413:     {
416: 414:         let ctx = EvaluationContext::default();
417: 415:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
418: 416:             .get_float_value("price", Some(&ctx), None)
419: 417:             .await
420: 418:             .unwrap();
421: 419:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
422: 420:             .get_string_value("currency", Some(&ctx), None)
423: 421:             .await
424: 422:             .unwrap();
425: 423: 
426: 424:         assert_eq!(price, 10000.0, "Default price should be 10000");
427: 425:         assert_eq!(currency, "Rupee", "Default currency should be Rupee");
428: 426:         println!("  ✓ Test passed\n");
429: 427:     }
430: 428: 
431: 429:     // Test 2: Platinum customer - Agush, no city
432: 430:     println!("Test 2: Platinum customer - Agush (no city)");
433: 431:     {
434: 432:         let ctx = EvaluationContext::default().with_custom_field("name", "Agush");
435: 433:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
436: 434:             .get_float_value("price", Some(&ctx), None)
437: 435:             .await
438: 436:             .unwrap();
439: 437:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
440: 438:             .get_string_value("currency", Some(&ctx), None)
441: 439:             .await
442: 440:             .unwrap();
443: 441: 
444: 442:         assert_eq!(price, 5000.0, "Price should be 5000 for platinum customer");
445: 443:         assert_eq!(currency, "Rupee", "Currency should be default Rupee");
446: 444:         println!("  ✓ Test passed\n");
447: 445:     }
448: 446: 
449: 447:     // Test 3: Platinum customer - Sauyav, with city Boston
450: 448:     println!("Test 3: Platinum customer - Sauyav with city Boston");
451: 449:     {
452: 450:         let ctx = EvaluationContext::default()
453: 451:             .with_custom_field("name", "Sauyav")
454: 452:             .with_custom_field("city", "Boston");
455: 453:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
456: 454:             .get_float_value("price", Some(&ctx), None)
457: 455:             .await
458: 456:             .unwrap();
459: 457:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
460: 458:             .get_string_value("currency", Some(&ctx), None)
461: 459:             .await
462: 460:             .unwrap();
463: 461: 
464: 462:         assert_eq!(price, 5000.0, "Price should be 5000");
465: 463:         assert_eq!(currency, "Dollar", "Currency should be Dollar");
466: 464:         println!("  ✓ Test passed\n");
467: 465:     }
468: 466: 
469: 467:     // Test 4: Regular customer - John (no city)
470: 468:     println!("Test 4: Regular customer - John (no city)");
471: 469:     {
472: 470:         let ctx = EvaluationContext::default().with_custom_field("name", "John");
473: 471:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
474: 472:             .get_float_value("price", Some(&ctx), None)
475: 473:             .await
476: 474:             .unwrap();
477: 475:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
478: 476:             .get_string_value("currency", Some(&ctx), None)
479: 477:             .await
480: 478:             .unwrap();
481: 479: 
482: 480:         assert_eq!(price, 10000.0, "Price should be default 10000");
483: 481:         assert_eq!(currency, "Rupee", "Currency should be default Rupee");
484: 482:         println!("  ✓ Test passed\n");
485: 483:     }
486: 484: 
487: 485:     // Test 5: Platinum customer - Sauyav with city Berlin
488: 486:     println!("Test 5: Platinum customer - Sauyav with city Berlin");
489: 487:     {
490: 488:         let ctx = EvaluationContext::default()
491: 489:             .with_custom_field("name", "Sauyav")
492: 490:             .with_custom_field("city", "Berlin");
493: 491:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
494: 492:             .get_float_value("price", Some(&ctx), None)
495: 493:             .await
496: 494:             .unwrap();
497: 495:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
498: 496:             .get_string_value("currency", Some(&ctx), None)
499: 497:             .await
500: 498:             .unwrap();
501: 499: 
502: 500:         assert_eq!(price, 5000.0, "Price should be 5000");
503: 501:         assert_eq!(currency, "Euro", "Currency should be Euro in Berlin");
504: 502:         println!("  ✓ Test passed\n");
505: 503:     }
506: 504: 
507: 505:     // Test 6: Regular customer - John with city Boston
508: 506:     println!("Test 6: Regular customer - John with city Boston");
509: 507:     {
510: 508:         let ctx = EvaluationContext::default()
511: 509:             .with_custom_field("name", "John")
512: 510:             .with_custom_field("city", "Boston");
513: 511:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
514: 512:             .get_float_value("price", Some(&ctx), None)
515: 513:             .await
516: 514:             .unwrap();
517: 515:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
518: 516:             .get_string_value("currency", Some(&ctx), None)
519: 517:             .await
520: 518:             .unwrap();
521: 519: 
522: 520:         assert_eq!(price, 10000.0, "Price should be default 10000");
523: 521:         assert_eq!(currency, "Dollar", "Currency should be Dollar in Boston");
524: 522:         println!("  ✓ Test passed\n");
525: 523:     }
526: 524: 
527: 525:     // Test 7: Edge case customer - karbik (specific override)
528: 526:     println!("Test 7: Edge case customer - karbik (specific override)");
529: 527:     {
530: 528:         let ctx = EvaluationContext::default().with_custom_field("name", "karbik");
531: 529:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
532: 530:             .get_float_value("price", Some(&ctx), None)
533: 531:             .await
534: 532:             .unwrap();
535: 533:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
536: 534:             .get_string_value("currency", Some(&ctx), None)
537: 535:             .await
538: 536:             .unwrap();
539: 537: 
540: 538:         assert_eq!(price, 1.0, "Price should be 1 for karbik");
541: 539:         assert_eq!(currency, "Rupee", "Currency should be default Rupee");
542: 540:         println!("  ✓ Test passed\n");
543: 541:     }
544: 542: 
545: 543:     // Test 8: Edge case customer - karbik with city Boston
546: 544:     println!("Test 8: Edge case customer - karbik with city Boston");
547: 545:     {
548: 546:         let ctx = EvaluationContext::default()
549: 547:             .with_custom_field("name", "karbik")
550: 548:             .with_custom_field("city", "Boston");
551: 549:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
552: 550:             .get_float_value("price", Some(&ctx), None)
553: 551:             .await
554: 552:             .unwrap();
555: 553:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
556: 554:             .get_string_value("currency", Some(&ctx), None)
557: 555:             .await
558: 556:             .unwrap();
559: 557: 
560: 558:         assert_eq!(price, 1.0, "Price should be 1 for karbik");
561: 559:         assert_eq!(currency, "Dollar", "Currency should be Dollar in Boston");
562: 560:         println!("  ✓ Test passed\n");
563: 561:     }
564: 562: 
565: 563:     // Test 9: Experiment case - Kolkata pricing
566: 564:     println!("Test 9: Experiment case: Kolkata pricing");
567: 565:     {
568: 566:         let ctx = EvaluationContext::default()
569: 567:             .with_custom_field("city", "Kolkata")
570: 568:             .with_targeting_key("test");
571: 569:         let price = lyx-core-lyx_core_lyx-core-lyx_core_client
572: 570:             .get_float_value("price", Some(&ctx), None)
573: 571:             .await
574: 572:             .unwrap();
575: 573:         let currency = lyx-core-lyx_core_lyx-core-lyx_core_client
576: 574:             .get_string_value("currency", Some(&ctx), None)
577: 575:             .await
578: 576:             .unwrap();
579: 577:         println!("  Retrieved price: {}, currency: {}", price, currency);
580: 578: 
581: 579:         assert!(
582: 580:             price == 8000.0 || price == 7000.0,
583: 581:             "Price should be either 8000 (control) or 7000 (experiment) "
584: 582:         );
585: 583:         assert_eq!(currency, "Rupee", "Currency should be default Rupee");
586: 584:         println!("  ✓ Experiment test passed ");
587: 585:     }
588: 586: 
589: 587:     println!("\n=== All tests passed! ===\n");
590: 588: }
591: 589: 
592: 590: #[tokio::test]
593: 591: #[ignore]
594: 592: async fn test_rust_provider_integration() {
595: 593:     // Create organisation
596: 594:     let lyx-core-lyx_core_lyx-core-lyx_core_client = create_sdk_lyx-core-lyx_core_lyx-core-lyx_core_client();
597: 595:     let org_id = create_organisation(&lyx-core-lyx_core_lyx-core-lyx_core_client).await;
598: 596: 
599: 597:     // Setup test environment using SDK
600: 598:     setup_with_sdk(&org_id, WORKSPACE_ID).await;
601: 599: 
602: 600:     // Run provider tests
603: 601:     run_provider_tests(&org_id, WORKSPACE_ID).await;
604: 602: }
605: 603: ```
606: 604: ```
607: 605: ```
608: 606: ```
609: ```
```

