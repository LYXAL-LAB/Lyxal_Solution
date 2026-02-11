### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lyx-core-lyx_core_client.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lyx-core-lyx_core_lyx-core-lyx_core_client.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lyx-core-lyx_core_lyx-core-lyx_core_client.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lyx-core-lyx_core_lyx-core-lyx_core_client.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lyx-core-lyx_core_lyx-core-lyx_core_client.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\lyx-core-lyx_core_lyx-core-lyx_core_client.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: use std::sync::Arc;
13: 11: 
14: 12: use log::{debug, error, info, warn};
15: 13: use serde_json::Value;
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core::experiment::ExperimentGroups;
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core::{
18: 16:     eval_config, get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants, Experiments, MergeStrategy,
19: 17: };
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{Config, DimensionInfo};
21: 19: use tokio::join;
22: 20: use tokio::sync::RwLock;
23: 21: use tokio::task::JoinHandle;
24: 22: use tokio::time::{sleep, Duration};
25: 23: 
26: 24: use crate::types::*;
27: 25: use crate::utils::ConversionUtils;
28: 26: 
29: 27: pub use open_feature::{
30: 28:     provider::{ProviderMetadata, ProviderStatus, ResolutionDetails},
31: 29:     EvaluationContext,
32: 30: };
33: 31: 
34: 32: #[derive(Debug)]
35: 33: pub struct CacConfig {
36: 34:     lyx-core-lyx_core_lyx-core-lyx_core_superposition_options: SuperpositionOptions,
37: 35:     options: ConfigurationOptions,
38: 36:     fallback_config: Option<serde_json::Map<String, Value>>,
39: 37:     cached_config: Arc<RwLock<Option<Config>>>,
40: 38:     last_updated: Arc<RwLock<Option<chrono::DateTime<chrono::Utc>>>>,
41: 39:     evaluation_cache: RwLock<HashMap<String, HashMap<String, Value>>>,
42: 40:     polling_task: RwLock<Option<JoinHandle<()>>>,
43: 41: }
44: 42: 
45: 43: impl CacConfig {
46: 44:     pub fn new(
47: 45:         lyx-core-lyx_core_lyx-core-lyx_core_superposition_options: SuperpositionOptions,
48: 46:         options: ConfigurationOptions,
49: 47:     ) -> Self {
50: 48:         Self {
51: 49:             lyx-core-lyx_core_lyx-core-lyx_core_superposition_options,
52: 50:             fallback_config: options.fallback_config.clone(),
53: 51:             options,
54: 52:             cached_config: Arc::new(RwLock::new(None)),
55: 53:             last_updated: Arc::new(RwLock::new(None)),
56: 54:             evaluation_cache: RwLock::new(HashMap::new()),
57: 55:             polling_task: RwLock::new(None),
58: 56:         }
59: 57:     }
60: 58: 
61: 59:     pub async fn create_config(&self) -> Result<()> {
62: 60:         info!("Creating CAC configuration...");
63: 61: 
64: 62:         // Fetch initial config
65: 63:         let latest_config = self.get_config(&self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options).await;
66: 64:         match latest_config {
67: 65:             Ok(config) => {
68: 66:                 let mut cached_config = self.cached_config.write().await;
69: 67:                 *cached_config = Some(config);
70: 68:                 let mut last_updated = self.last_updated.write().await;
71: 69:                 *last_updated = Some(chrono::Utc::now());
72: 70:                 info!("CAC config fetched successfully");
73: 71:             }
74: 72:             Err(e) => {
75: 73:                 let mut cached_config = self.cached_config.write().await;
76: 74:                 if cached_config.is_none() {
77: 75:                     // If no cached config, use fallback if available
78: 76:                     if let Some(fallback) = &self.fallback_config {
79: 77:                         *cached_config =
80: 78:                             Some(ConversionUtils::convert_value_to_config(fallback)?);
81: 79:                         info!("Using fallback config due to initial fetch failure");
82: 80:                     }
83: 81:                 } else {
84: 82:                     error!("Failed to fetch initial config: {}", e);
85: 83:                     return Err(e);
86: 84:                 }
87: 85:             }
88: 86:         }
89: 87: 
90: 88:         // Start refresh strategy
91: 89:         match &self.options.refresh_strategy {
92: 90:             RefreshStrategy::Polling(polling_strategy) => {
93: 91:                 info!(
94: 92:                     "Using PollingStrategy: interval={}s, timeout={}s",
95: 93:                     polling_strategy.interval,
96: 94:                     polling_strategy.timeout.unwrap_or(30)
97: 95:                 );
98: 96:                 let task = self.start_polling(polling_strategy.interval).await;
99: 97:                 let mut polling_task = self.polling_task.write().await;
100: 98:                 *polling_task = Some(task);
101: 99:             }
102: 100:             RefreshStrategy::OnDemand(on_demand_strategy) => {
103: 101:                 info!(
104: 102:                     "Using OnDemandStrategy: ttl={}s, use_stale_on_error={}, timeout={}s",
105: 103:                     on_demand_strategy.ttl,
106: 104:                     on_demand_strategy.use_stale_on_error.unwrap_or(false),
107: 105:                     on_demand_strategy.timeout.unwrap_or(30)
108: 106:                 );
109: 107:             }
110: 108:         }
111: 109: 
112: 110:         Ok(())
113: 111:     }
114: 112: 
115: 113:     async fn start_polling(&self, interval: u64) -> JoinHandle<()> {
116: 114:         let lyx-core-lyx_core_lyx-core-lyx_core_superposition_options = self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options.clone();
117: 115:         let cached_config = self.cached_config.clone();
118: 116:         let last_updated = self.last_updated.clone();
119: 117: 
120: 118:         tokio::spawn(async move {
121: 119:             loop {
122: 120:                 match Self::get_config_static(&lyx-core-lyx_core_lyx-core-lyx_core_superposition_options).await {
123: 121:                     Ok(config) => {
124: 122:                         let mut cached = cached_config.write().await;
125: 123:                         *cached = Some(config);
126: 124:                         let mut updated = last_updated.write().await;
127: 125:                         *updated = Some(chrono::Utc::now());
128: 126:                         debug!("CAC config updated via polling");
129: 127:                     }
130: 128:                     Err(e) => {
131: 129:                         error!("Polling error: {}", e);
132: 130:                     }
133: 131:                 }
134: 132:                 sleep(Duration::from_secs(interval)).await;
135: 133:             }
136: 134:         })
137: 135:     }
138: 136: 
139: 137:     pub async fn on_demand_config(&self, ttl: u64, use_stale: bool) -> Result<Config> {
140: 138:         let now = chrono::Utc::now();
141: 139:         let last_updated;
142: 140:         {
143: 141:             last_updated = self.last_updated.read().await;
144: 142:         }
145: 143:         let should_refresh = match *last_updated {
146: 144:             Some(last) => (now - last).num_seconds() > ttl as i64,
147: 145:             None => true,
148: 146:         };
149: 147: 
150: 148:         if should_refresh {
151: 149:             debug!("TTL expired. Fetching config on-demand");
152: 150:             match self.get_config(&self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options).await {
153: 151:                 Ok(config) => {
154: 152:                     let mut cached_config = self.cached_config.write().await;
155: 153:                     *cached_config = Some(config.clone());
156: 154:                     let mut last_updated_mut = self.last_updated.write().await;
157: 155:                     *last_updated_mut = Some(chrono::Utc::now());
158: 156:                     info!("Config fetched successfully on-demand");
159: 157:                     return Ok(config);
160: 158:                 }
161: 159:                 Err(e) => {
162: 160:                     warn!("On-demand fetch failed: {}", e);
163: 161:                     if !use_stale {
164: 162:                         return Err(e);
165: 163:                     }
166: 164:                     info!("Using stale config due to error");
167: 165:                 }
168: 166:             }
169: 167:         }
170: 168: 
171: 169:         // Return cached config
172: 170:         let cached_config = self.cached_config.read().await;
173: 171:         match cached_config.as_ref() {
174: 172:             Some(config) => Ok(config.clone()),
175: 173:             None => Err(SuperpositionError::ConfigError(
176: 174:                 "No cached config available".into(),
177: 175:             )),
178: 176:         }
179: 177:     }
180: 178: 
181: 179:     async fn get_config(&self, options: &SuperpositionOptions) -> Result<Config> {
182: 180:         Self::get_config_static(options).await
183: 181:     }
184: 182: 
185: 183:     async fn get_config_static(options: &SuperpositionOptions) -> Result<Config> {
186: 184:         use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::{Client, Config as SdkConfig};
187: 185: 
188: 186:         info!("Fetching config from Superposition service using SDK");
189: 187: 
190: 188:         // Create SDK config
191: 189:         let sdk_config = SdkConfig::builder()
192: 190:             .endpoint_url(&options.endpoint)
193: 191:             .bearer_token(options.token.clone().into())
194: 192:             .behavior_version_latest()
195: 193:             .build();
196: 194: 
197: 195:         // Create Superposition lyx-core-lyx_core_lyx-core-lyx_core_client
198: 196:         let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::from_conf(sdk_config);
199: 197: 
200: 198:         // Call the get_config API
201: 199:         let response = lyx-core-lyx_core_lyx-core-lyx_core_client
202: 200:             .get_config()
203: 201:             .workspace_id(&options.workspace_id)
204: 202:             .org_id(&options.org_id)
205: 203:             .send()
206: 204:             .await
207: 205:             .map_err(|e| {
208: 206:                 let error = format!("Failed to get config: {}", e);
209: 207:                 SuperpositionError::NetworkError(error)
210: 208:             })?;
211: 209: 
212: 210:         // Use ConversionUtils to convert to proper Config type
213: 211:         let config = ConversionUtils::convert_get_config_response(&response)?;
214: 212: 
215: 213:         info!("Successfully fetched and converted config with {} contexts, {} overrides, {} default configs",
216: 214:               config.contexts.len(), config.overrides.len(), config.default_configs.len());
217: 215: 
218: 216:         Ok(config)
219: 217:     }
220: 218: 
221: 219:     pub async fn get_cached_config(&self) -> Option<Config> {
222: 220:         let cached_config = self.cached_config.read().await;
223: 221:         cached_config.clone()
224: 222:     }
225: 223: 
226: 224:     /// Evaluate configuration for given context and return resolved values
227: 225:     pub async fn evaluate_config(
228: 226:         &self,
229: 227:         query_data: &serde_json::Map<String, Value>,
230: 228:         prefix_filter: Option<&[String]>,
231: 229:     ) -> Result<serde_json::Map<String, Value>> {
232: 230:         let cached_config = self.cached_config.read().await;
233: 231:         match cached_config.as_ref() {
234: 232:             Some(cached_config) => {
235: 233:                 // Use ConversionUtils to evaluate config
236: 234:                 eval_config(
237: 235:                     cached_config.default_configs.clone(),
238: 236:                     &cached_config.contexts,
239: 237:                     &cached_config.overrides,
240: 238:                     &cached_config.dimensions,
241: 239:                     query_data,
242: 240:                     MergeStrategy::MERGE,
243: 241:                     prefix_filter.map(|p| p.to_vec()),
244: 242:                 )
245: 243:                 .map_err(|e| {
246: 244:                     SuperpositionError::ConfigError(format!(
247: 245:                         "Failed to evaluate config: {}",
248: 246:                         e
249: 247:                     ))
250: 248:                 })
251: 249:             }
252: 250:             None => Err(SuperpositionError::ConfigError(
253: 251:                 "No cached config available".into(),
254: 252:             )),
255: 253:         }
256: 254:     }
257: 255: 
258: 256:     pub async fn close(&self) -> Result<()> {
259: 257:         // Stop polling task
260: 258:         let mut polling_task = self.polling_task.write().await;
261: 259:         if let Some(task) = polling_task.take() {
262: 260:             task.abort();
263: 261:         }
264: 262: 
265: 263:         // Clear caches
266: 264:         let mut cached_config = self.cached_config.write().await;
267: 265:         *cached_config = None;
268: 266:         let mut evaluation_cache = self.evaluation_cache.write().await;
269: 267:         evaluation_cache.clear();
270: 268: 
271: 269:         Ok(())
272: 270:     }
273: 271: }
274: 272: 
275: 273: /// Experimentation Configuration lyx-core-lyx_core_lyx-core-lyx_core_client
276: 274: #[derive(Debug)]
277: 275: pub struct ExperimentationConfig {
278: 276:     lyx-core-lyx_core_lyx-core-lyx_core_superposition_options: SuperpositionOptions,
279: 277:     options: ExperimentationOptions,
280: 278:     cached_experiments: Arc<RwLock<Option<Experiments>>>,
281: 279:     cached_experiment_groups: Arc<RwLock<Option<ExperimentGroups>>>,
282: 280:     last_updated: Arc<RwLock<Option<chrono::DateTime<chrono::Utc>>>>,
283: 281:     evaluation_cache: RwLock<HashMap<String, HashMap<String, Value>>>,
284: 282:     polling_task: RwLock<Option<JoinHandle<()>>>,
285: 283: }
286: 284: 
287: 285: impl ExperimentationConfig {
288: 286:     pub fn new(
289: 287:         lyx-core-lyx_core_lyx-core-lyx_core_superposition_options: SuperpositionOptions,
290: 288:         options: ExperimentationOptions,
291: 289:     ) -> Self {
292: 290:         Self {
293: 291:             lyx-core-lyx_core_lyx-core-lyx_core_superposition_options,
294: 292:             options,
295: 293:             cached_experiments: Arc::new(RwLock::new(None)),
296: 294:             cached_experiment_groups: Arc::new(RwLock::new(None)),
297: 295:             last_updated: Arc::new(RwLock::new(None)),
298: 296:             evaluation_cache: RwLock::new(HashMap::new()),
299: 297:             polling_task: RwLock::new(None),
300: 298:         }
301: 299:     }
302: 300: 
303: 301:     pub async fn create_config(&self) -> Result<()> {
304: 302:         info!("Creating Experimentation configuration...");
305: 303: 
306: 304:         // Fetch initial experiments and experiment groups
307: 305:         let (latest_experiments, latest_experiment_groups) = join!(
308: 306:             self.get_experiments(&self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options),
309: 307:             self.get_experiment_groups(&self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options)
310: 308:         );
311: 309:         match (latest_experiments, latest_experiment_groups) {
312: 310:             (Ok(Some(experiments)), Ok(Some(experiment_groups))) => {
313: 311:                 let mut cached_experiments = self.cached_experiments.write().await;
314: 312:                 *cached_experiments = Some(experiments);
315: 313:                 let mut cached_experiment_groups =
316: 314:                     self.cached_experiment_groups.write().await;
317: 315:                 *cached_experiment_groups = Some(experiment_groups);
318: 316:                 let mut last_updated = self.last_updated.write().await;
319: 317:                 *last_updated = Some(chrono::Utc::now());
320: 318:                 info!("Experiments fetched successfully");
321: 319:             }
322: 320:             (Ok(None), Ok(None)) => {
323: 321:                 warn!("No experiments or experiment groups returned from initial fetch");
324: 322:             }
325: 323:             (Err(e), _) | (_, Err(e)) => {
326: 324:                 error!(
327: 325:                     "Failed to fetch initial experiments or experiment groups: {}",
328: 326:                     e
329: 327:                 );
330: 328:                 return Err(e);
331: 329:             }
332: 330:             (_, _) => {
333: 331:                 error!("Failed to fetch either experiments or experiment groups");
334: 332:                 return Err(SuperpositionError::ConfigError(
335: 333:                     "Failed to fetch either experiments or experiment groups".into(),
336: 334:                 ));
337: 335:             }
338: 336:         }
339: 337: 
340: 338:         // Start refresh strategy
341: 339:         match &self.options.refresh_strategy {
342: 340:             RefreshStrategy::Polling(polling_strategy) => {
343: 341:                 info!(
344: 342:                     "Using PollingStrategy for experiments: interval={}s",
345: 343:                     polling_strategy.interval
346: 344:                 );
347: 345:                 let task = self.start_polling(polling_strategy.interval).await;
348: 346:                 let mut polling_task = self.polling_task.write().await;
349: 347:                 *polling_task = Some(task);
350: 348:             }
351: 349:             RefreshStrategy::OnDemand(on_demand_strategy) => {
352: 350:                 info!(
353: 351:                     "Using OnDemandStrategy for experiments: ttl={}s",
354: 352:                     on_demand_strategy.ttl
355: 353:                 );
356: 354:             }
357: 355:         }
358: 356: 
359: 357:         Ok(())
360: 358:     }
361: 359: 
362: 360:     async fn start_polling(&self, interval: u64) -> JoinHandle<()> {
363: 361:         let lyx-core-lyx_core_lyx-core-lyx_core_superposition_options = self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options.clone();
364: 362:         let cached_experiments = self.cached_experiments.clone();
365: 363:         let cached_experiment_groups = self.cached_experiment_groups.clone();
366: 364:         let last_updated = self.last_updated.clone();
367: 365: 
368: 366:         tokio::spawn(async move {
369: 367:             loop {
370: 368:                 let (experiments_result, groups_result) = join!(
371: 369:                     Self::get_experiments_static(&lyx-core-lyx_core_lyx-core-lyx_core_superposition_options),
372: 370:                     Self::get_experiment_groups_static(&lyx-core-lyx_core_lyx-core-lyx_core_superposition_options)
373: 371:                 );
374: 372:                 match (experiments_result, groups_result) {
375: 373:                     (Ok(Some(experiments)), Ok(Some(experiment_groups))) => {
376: 374:                         let mut cached = cached_experiments.write().await;
377: 375:                         *cached = Some(experiments);
378: 376:                         let mut cached_groups = cached_experiment_groups.write().await;
379: 377:                         *cached_groups = Some(experiment_groups);
380: 378:                         let mut updated = last_updated.write().await;
381: 379:                         *updated = Some(chrono::Utc::now());
382: 380:                         debug!("Experiments and Experiment Groups updated via polling");
383: 381:                     }
384: 382:                     (Ok(None), Ok(None)) => {
385: 383:                         warn!(
386: 384:                             "No experiments or experiment groups returned from polling"
387: 385:                         );
388: 386:                     }
389: 387:                     (Err(e), _) | (_, Err(e)) => {
390: 388:                         error!("Polling error: {}", e);
391: 389:                     }
392: 390:                     _ => {}
393: 391:                 }
394: 392:                 sleep(Duration::from_secs(interval)).await;
395: 393:             }
396: 394:         })
397: 395:     }
398: 396: 
399: 397:     pub async fn on_demand_config(
400: 398:         &self,
401: 399:         ttl: u64,
402: 400:         use_stale: bool,
403: 401:     ) -> Result<Experiments> {
404: 402:         let now = chrono::Utc::now();
405: 403:         let last_updated = self.last_updated.read().await;
406: 404: 
407: 405:         let should_refresh = match *last_updated {
408: 406:             Some(last) => (now - last).num_seconds() > ttl as i64,
409: 407:             None => true,
410: 408:         };
411: 409: 
412: 410:         if should_refresh {
413: 411:             debug!("TTL expired. Fetching experiments and experiment groups on-demand");
414: 412:             let (experiments_result, groups_result) = join!(
415: 413:                 self.get_experiments(&self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options),
416: 414:                 self.get_experiment_groups(&self.lyx-core-lyx_core_lyx-core-lyx_core_superposition_options)
417: 415:             );
418: 416:             match (experiments_result, groups_result) {
419: 417:                 (Ok(Some(experiments)), Ok(Some(experiment_groups))) => {
420: 418:                     let mut cached_experiments = self.cached_experiments.write().await;
421: 419:                     *cached_experiments = Some(experiments.clone());
422: 420:                     let mut cached_experiment_groups =
423: 421:                         self.cached_experiment_groups.write().await;
424: 422:                     *cached_experiment_groups = Some(experiment_groups);
425: 423:                     let mut last_updated_mut = self.last_updated.write().await;
426: 424:                     *last_updated_mut = Some(chrono::Utc::now());
427: 425:                     info!("Experiments and Experiment Groups fetched successfully on-demand");
428: 426:                     return Ok(experiments);
429: 427:                 }
430: 428:                 (Err(e), _) | (_, Err(e)) => {
431: 429:                     warn!(
432: 430:                         "On-demand experiments and experiment groups fetch failed: {}",
433: 431:                         e
434: 432:                     );
435: 433:                     if !use_stale {
436: 434:                         return Err(e);
437: 435:                     }
438: 436:                     info!("Using stale experiments and experiment groups due to error");
439: 437:                 }
440: 438:                 _ => {}
441: 439:             }
442: 440:         }
443: 441: 
444: 442:         // Return cached experiments
445: 443:         let cached_experiments = self.cached_experiments.read().await;
446: 444:         match cached_experiments.as_ref() {
447: 445:             Some(experiments) => Ok(experiments.clone()),
448: 446:             None => Ok(vec![]), // Return empty if no experiments cached
449: 447:         }
450: 448:     }
451: 449: 
452: 450:     async fn get_experiments(
453: 451:         &self,
454: 452:         options: &SuperpositionOptions,
455: 453:     ) -> Result<Option<Experiments>> {
456: 454:         Self::get_experiments_static(options).await
457: 455:     }
458: 456: 
459: 457:     async fn get_experiment_groups(
460: 458:         &self,
461: 459:         options: &SuperpositionOptions,
462: 460:     ) -> Result<Option<ExperimentGroups>> {
463: 461:         Self::get_experiment_groups_static(options).await
464: 462:     }
465: 463: 
466: 464:     async fn get_experiments_static(
467: 465:         options: &SuperpositionOptions,
468: 466:     ) -> Result<Option<Experiments>> {
469: 467:         use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::{
470: 468:             types::ExperimentStatusType, Client, Config as SdkConfig,
471: 469:         };
472: 470: 
473: 471:         info!("Fetching experiments from Superposition service using SDK");
474: 472: 
475: 473:         // Create SDK config
476: 474:         let sdk_config = SdkConfig::builder()
477: 475:             .endpoint_url(&options.endpoint)
478: 476:             .bearer_token(options.token.clone().into())
479: 477:             .behavior_version_latest()
480: 478:             .build();
481: 479: 
482: 480:         // Create Superposition lyx-core-lyx_core_lyx-core-lyx_core_client
483: 481:         let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::from_conf(sdk_config);
484: 482: 
485: 483:         let response = lyx-core-lyx_core_lyx-core-lyx_core_client
486: 484:             .list_experiment()
487: 485:             .workspace_id(&options.workspace_id)
488: 486:             .org_id(&options.org_id)
489: 487:             .all(true)
490: 488:             .status(ExperimentStatusType::Created)
491: 489:             .status(ExperimentStatusType::Inprogress)
492: 490:             .send()
493: 491:             .await
494: 492:             .map_err(|e| {
495: 493:                 SuperpositionError::NetworkError(format!(
496: 494:                     "Failed to list experiments: {}",
497: 495:                     e
498: 496:                 ))
499: 497:             })?;
500: 498: 
501: 499:         let experiments = ConversionUtils::convert_experiments_response(&response)?;
502: 500: 
503: 501:         info!(
504: 502:             "Successfully fetched and converted {} experiments",
505: 503:             experiments.len()
506: 504:         );
507: 505:         Ok(Some(experiments))
508: 506:     }
509: 507: 
510: 508:     async fn get_experiment_groups_static(
511: 509:         options: &SuperpositionOptions,
512: 510:     ) -> Result<Option<ExperimentGroups>> {
513: 511:         use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_sdk::{Client, Config as SdkConfig};
514: 512: 
515: 513:         info!("Fetching experiment groups from Superposition service using SDK");
516: 514: 
517: 515:         // Create SDK config
518: 516:         let sdk_config = SdkConfig::builder()
519: 517:             .endpoint_url(&options.endpoint)
520: 518:             .bearer_token(options.token.clone().into())
521: 519:             .behavior_version_latest()
522: 520:             .build();
523: 521: 
524: 522:         // Create Superposition lyx-core-lyx_core_lyx-core-lyx_core_client
525: 523:         let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::from_conf(sdk_config);
526: 524: 
527: 525:         let response = lyx-core-lyx_core_lyx-core-lyx_core_client
528: 526:             .list_experiment_groups()
529: 527:             .workspace_id(&options.workspace_id)
530: 528:             .org_id(&options.org_id)
531: 529:             .all(true)
532: 530:             .send()
533: 531:             .await
534: 532:             .map_err(|e| {
535: 533:                 SuperpositionError::NetworkError(format!(
536: 534:                     "Failed to list experiment groups: {}",
537: 535:                     e
538: 536:                 ))
539: 537:             })?;
540: 538: 
541: 539:         let experiment_groups =
542: 540:             ConversionUtils::convert_experiment_groups_response(&response)?;
543: 541: 
544: 542:         info!(
545: 543:             "Successfully fetched and converted {} experiment groups",
546: 544:             experiment_groups.len()
547: 545:         );
548: 546:         Ok(Some(experiment_groups))
549: 547:     }
550: 548: 
551: 549:     pub async fn get_cached_experiments(&self) -> Option<Experiments> {
552: 550:         let cached_experiments = self.cached_experiments.read().await;
553: 551:         cached_experiments.clone()
554: 552:     }
555: 553: 
556: 554:     pub async fn get_cached_experiment_groups(&self) -> Option<ExperimentGroups> {
557: 555:         let cached_experiment_groups = self.cached_experiment_groups.read().await;
558: 556:         cached_experiment_groups.clone()
559: 557:     }
560: 558: 
561: 559:     pub async fn close(&self) -> Result<()> {
562: 560:         // Stop polling task
563: 561:         let mut polling_task = self.polling_task.write().await;
564: 562:         if let Some(task) = polling_task.take() {
565: 563:             task.abort();
566: 564:         }
567: 565: 
568: 566:         // Clear caches
569: 567:         let mut cached_experiments = self.cached_experiments.write().await;
570: 568:         *cached_experiments = None;
571: 569:         let mut evaluation_cache = self.evaluation_cache.write().await;
572: 570:         evaluation_cache.clear();
573: 571: 
574: 572:         Ok(())
575: 573:     }
576: 574: 
577: 575:     pub async fn get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants(
578: 576:         &self,
579: 577:         dimensions_info: &HashMap<String, DimensionInfo>,
580: 578:         contexts: &serde_json::Map<String, Value>,
581: 579:         identifier: Option<String>,
582: 580:     ) -> Result<Vec<String>> {
583: 581:         let cached_experiments = self.cached_experiments.read().await;
584: 582:         let cached_experiment_groups = self.cached_experiment_groups.read().await;
585: 583: 
586: 584:         match (
587: 585:             cached_experiments.as_ref(),
588: 586:             cached_experiment_groups.as_ref(),
589: 587:         ) {
590: 588:             (Some(experiments), Some(experiment_groups)) => {
591: 589:                 // Use get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants from lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_core
592: 590:                 get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants(
593: 591:                     dimensions_info,
594: 592:                     experiments.clone(),
595: 593:                     experiment_groups,
596: 594:                     contexts,
597: 595:                     &identifier.unwrap_or_default(),
598: 596:                     None,
599: 597:                 )
600: 598:                 .map_err(|e| {
601: 599:                     SuperpositionError::ConfigError(format!(
602: 600:                         "Failed to get lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable variants: {}",
603: 601:                         e
604: 602:                     ))
605: 603:                 })
606: 604:             }
607: 605:             _ => Err(SuperpositionError::ConfigError(
608: 606:                 "No cached experiments or experiment groups available".into(),
609: 607:             )),
610: 608:         }
611: 609:     }
612: 610: }
613: 611: ```
614: 612: ```
615: 613: ```
616: 614: ```
617: ```
```
