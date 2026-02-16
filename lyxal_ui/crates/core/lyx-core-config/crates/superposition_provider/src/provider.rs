1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\provider.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\provider.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\provider.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\provider.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_provider\src\provider.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: 
13: 11: use async_trait::async_trait;
14: 12: use log::{error, info};
15: 13: use open_feature::{
16: 14:     provider::FeatureProvider,
17: 15:     provider::{ProviderMetadata, ProviderStatus, ResolutionDetails},
18: 16:     EvaluationContext, EvaluationError, EvaluationErrorCode, EvaluationResult,
19: 17:     StructValue,
20: 18: };
21: 19: use serde_json::Value;
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::DimensionInfo;
23: 21: use tokio::sync::RwLock;
24: 22: 
25: 23: use crate::lyx-core-lyx_core_lyx-core-lyx_core_client::{CacConfig, ExperimentationConfig};
26: 24: use crate::types::*;
27: 25: use crate::utils::ConversionUtils;
28: 26: 
29: 27: #[derive(Debug)]
30: 28: pub struct SuperpositionProvider {
31: 29:     metadata: ProviderMetadata,
32: 30:     status: RwLock<ProviderStatus>,
33: 31:     cac_config: Option<CacConfig>,
34: 32:     exp_config: Option<ExperimentationConfig>,
35: 33: }
36: 34: impl SuperpositionProvider {
37: 35:     pub fn new(provider_options: SuperpositionProviderOptions) -> Self {
38: 36:         // Create CAC config
39: 37:         let lyx-core-lyx_core_lyx-core-lyx_core_superposition_options = SuperpositionOptions::new(
40: 38:             provider_options.endpoint,
41: 39:             provider_options.token,
42: 40:             provider_options.org_id,
43: 41:             provider_options.workspace_id,
44: 42:         );
45: 43:         let cac_options = ConfigurationOptions::new(
46: 44:             provider_options.refresh_strategy,
47: 45:             provider_options.evaluation_cache,
48: 46:             provider_options.fallback_config.clone(),
49: 47:         );
50: 48: 
51: 49:         let cac_config =
52: 50:             CacConfig::new(lyx-core-lyx_core_lyx-core-lyx_core_superposition_options.clone(), cac_options.clone());
53: 51: 
54: 52:         let exp_config =
55: 53:             provider_options
56: 54:                 .experimentation_options
57: 55:                 .as_ref()
58: 56:                 .map(|exp_opts| {
59: 57:                     ExperimentationConfig::new(
60: 58:                         lyx-core-lyx_core_lyx-core-lyx_core_superposition_options.clone(),
61: 59:                         exp_opts.clone(),
62: 60:                     )
63: 61:                 });
64: 62: 
65: 63:         Self {
66: 64:             metadata: ProviderMetadata {
67: 65:                 name: "SuperpositionProvider".to_string(),
68: 66:             },
69: 67:             status: RwLock::new(ProviderStatus::NotReady),
70: 68:             cac_config: Some(cac_config),
71: 69:             exp_config,
72: 70:         }
73: 71:     }
74: 72: 
75: 73:     fn get_context_from_evaluation_context(
76: 74:         &self,
77: 75:         evaluation_context: &EvaluationContext,
78: 76:     ) -> (serde_json::Map<String, Value>, Option<String>) {
79: 77:         let context = evaluation_context
80: 78:             .custom_fields
81: 79:             .iter()
82: 80:             .map(|(k, v)| {
83: 81:                 (
84: 82:                     k.clone(),
85: 83:                     ConversionUtils::convert_evaluation_context_value_to_serde_value(v),
86: 84:                 )
87: 85:             })
88: 86:             .collect();
89: 87: 
90: 88:         (context, evaluation_context.targeting_key.clone())
91: 89:     }
92: 90: 
93: 91:     async fn get_dimensions_info(&self) -> HashMap<String, DimensionInfo> {
94: 92:         match &self.cac_config {
95: 93:             Some(cac_config) => cac_config
96: 94:                 .get_cached_config()
97: 95:                 .await
98: 96:                 .map(|c| c.dimensions.clone())
99: 97:                 .unwrap_or_default(),
100: 98:             None => HashMap::new(),
101: 99:         }
102: 100:     }
103: 101: 
104: 102:     pub async fn init(&self) -> Result<()> {
105: 103:         // Initialize CAC config
106: 104:         if let Some(cac_config) = &self.cac_config {
107: 105:             match cac_config.create_config().await {
108: 106:                 Ok(_) => info!("CAC configuration initialized successfully"),
109: 107:                 Err(e) => {
110: 108:                     error!("Failed to initialize CAC configuration: {}", e);
111: 109:                     return Err(SuperpositionError::ConfigError(format!(
112: 110:                         "Failed to initialize CAC configuration: {}",
113: 111:                         e
114: 112:                     )));
115: 113:                 }
116: 114:             }
117: 115:         }
118: 116: 
119: 117:         // Initialize experimentation config if available
120: 118:         if let Some(exp_config) = &self.exp_config {
121: 119:             match exp_config.create_config().await {
122: 120:                 Ok(_) => info!("Experimentation configuration initialized successfully"),
123: 121:                 Err(e) => {
124: 122:                     error!("Failed to initialize experimentation configuration: {}", e);
125: 123:                     return Err(SuperpositionError::ConfigError(format!(
126: 124:                         "Failed to initialize experimentation configuration: {}",
127: 125:                         e
128: 126:                     )));
129: 127:                 }
130: 128:             }
131: 129:         };
132: 130:         Ok(())
133: 131:     }
134: 132: 
135: 133:     pub async fn resolve_full_config(
136: 134:         &self,
137: 135:         evaluation_context: &EvaluationContext,
138: 136:     ) -> Result<serde_json::Map<String, Value>> {
139: 137:         self.eval_config(evaluation_context).await
140: 138:     }
141: 139: 
142: 140:     async fn eval_config(
143: 141:         &self,
144: 142:         evaluation_context: &EvaluationContext,
145: 143:     ) -> Result<serde_json::Map<String, Value>> {
146: 144:         // Get cached config from CAC
147: 145:         let (mut context, targeting_key) =
148: 146:             self.get_context_from_evaluation_context(evaluation_context);
149: 147: 
150: 148:         let dimensions_info = self.get_dimensions_info().await;
151: 149:         let variant_lyx-core-lyx_core_lyx-core-lyx_core_ids = if let Some(exp_config) = &self.exp_config {
152: 150:             exp_config
153: 151:                 .get_lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable_variants(&dimensions_info, &context, targeting_key)
154: 152:                 .await?
155: 153:         } else {
156: 154:             vec![]
157: 155:         };
158: 156: 
159: 157:         context.insert(
160: 158:             "variantIds".to_string(),
161: 159:             Value::Array(variant_lyx-core-lyx_core_lyx-core-lyx_core_ids.into_iter().map(Value::String).collect()),
162: 160:         );
163: 161: 
164: 162:         match &self.cac_config {
165: 163:             Some(cac_config) => cac_config.evaluate_config(&context, None).await,
166: 164:             None => Err(SuperpositionError::ConfigError(
167: 165:                 "CAC config not initialized".into(),
168: 166:             )),
169: 167:         }
170: 168:     }
171: 169: }
172: 170: #[async_trait]
173: 171: impl FeatureProvider for SuperpositionProvider {
174: 172:     async fn initialize(&mut self, _context: &EvaluationContext) {
175: 173:         info!("Initializing SuperpositionProvider...");
176: 174:         {
177: 175:             let mut status = self.status.write().await;
178: 176:             *status = ProviderStatus::NotReady;
179: 177:         }
180: 178:         if (self.init().await).is_err() {
181: 179:             let mut status = self.status.write().await;
182: 180:             *status = ProviderStatus::Error;
183: 181:             return;
184: 182:         }
185: 183: 
186: 184:         let mut status = self.status.write().await;
187: 185:         *status = ProviderStatus::Ready;
188: 186: 
189: 187:         info!("SuperpositionProvider initialized successfully");
190: 188:     }
191: 189: 
192: 190:     async fn resolve_bool_value(
193: 191:         &self,
194: 192:         flag_key: &str,
195: 193:         evaluation_context: &EvaluationContext,
196: 194:     ) -> EvaluationResult<ResolutionDetails<bool>> {
197: 195:         match self.eval_config(evaluation_context).await {
198: 196:             Ok(config) => {
199: 197:                 if let Some(value) = config.get(flag_key) {
200: 198:                     if let Some(bool_val) = value.as_bool() {
201: 199:                         return Ok(ResolutionDetails::new(bool_val));
202: 200:                     }
203: 201:                 }
204: 202:                 Err(EvaluationError {
205: 203:                     code: EvaluationErrorCode::FlagNotFound,
206: 204:                     message: Some("Flag not found in configuration".to_string()),
207: 205:                 })
208: 206:             }
209: 207:             Err(e) => {
210: 208:                 error!("Error evaluating boolean flag {}: {}", flag_key, e);
211: 209:                 Err(EvaluationError {
212: 210:                     code: EvaluationErrorCode::FlagNotFound,
213: 211:                     message: Some("Flag not found in configuration".to_string()),
214: 212:                 })
215: 213:             }
216: 214:         }
217: 215:     }
218: 216: 
219: 217:     async fn resolve_string_value(
220: 218:         &self,
221: 219:         flag_key: &str,
222: 220:         evaluation_context: &EvaluationContext,
223: 221:     ) -> EvaluationResult<ResolutionDetails<String>> {
224: 222:         match self.eval_config(evaluation_context).await {
225: 223:             Ok(config) => {
226: 224:                 if let Some(value) = config.get(flag_key) {
227: 225:                     if let Some(str_val) = value.as_str() {
228: 226:                         return Ok(ResolutionDetails::new(str_val.to_owned()));
229: 227:                     }
230: 228:                 }
231: 229:                 Err(EvaluationError {
232: 230:                     code: EvaluationErrorCode::FlagNotFound,
233: 231:                     message: Some("Flag not found in configuration".to_string()),
234: 232:                 })
235: 233:             }
236: 234:             Err(e) => {
237: 235:                 error!("Error evaluating String flag {}: {}", flag_key, e);
238: 236:                 Err(EvaluationError {
239: 237:                     code: EvaluationErrorCode::FlagNotFound,
240: 238:                     message: Some("Flag not found in configuration".to_string()),
241: 239:                 })
242: 240:             }
243: 241:         }
244: 242:     }
245: 243: 
246: 244:     async fn resolve_int_value(
247: 245:         &self,
248: 246:         flag_key: &str,
249: 247:         evaluation_context: &EvaluationContext,
250: 248:     ) -> EvaluationResult<ResolutionDetails<i64>> {
251: 249:         match self.eval_config(evaluation_context).await {
252: 250:             Ok(config) => {
253: 251:                 if let Some(value) = config.get(flag_key) {
254: 252:                     if let Some(int_val) = value.as_i64() {
255: 253:                         return Ok(ResolutionDetails::new(int_val));
256: 254:                     }
257: 255:                 }
258: 256:                 Err(EvaluationError {
259: 257:                     code: EvaluationErrorCode::FlagNotFound,
260: 258:                     message: Some("Flag not found in configuration".to_string()),
261: 259:                 })
262: 260:             }
263: 261:             Err(e) => {
264: 262:                 error!("Error evaluating integer flag {}: {}", flag_key, e);
265: 263:                 Err(EvaluationError {
266: 264:                     code: EvaluationErrorCode::FlagNotFound,
267: 265:                     message: Some("Flag not found in configuration".to_string()),
268: 266:                 })
269: 267:             }
270: 268:         }
271: 269:     }
272: 270: 
273: 271:     async fn resolve_float_value(
274: 272:         &self,
275: 273:         flag_key: &str,
276: 274:         evaluation_context: &EvaluationContext,
277: 275:     ) -> EvaluationResult<ResolutionDetails<f64>> {
278: 276:         match self.eval_config(evaluation_context).await {
279: 277:             Ok(config) => {
280: 278:                 if let Some(value) = config.get(flag_key) {
281: 279:                     if let Some(int_val) = value.as_f64() {
282: 280:                         return Ok(ResolutionDetails::new(int_val));
283: 281:                     }
284: 282:                 }
285: 283:                 Err(EvaluationError {
286: 284:                     code: EvaluationErrorCode::FlagNotFound,
287: 285:                     message: Some("Flag not found in configuration".to_string()),
288: 286:                 })
289: 287:             }
290: 288:             Err(e) => {
291: 289:                 error!("Error evaluating float flag {}: {}", flag_key, e);
292: 290:                 Err(EvaluationError {
293: 291:                     code: EvaluationErrorCode::FlagNotFound,
294: 292:                     message: Some("Flag not found in configuration".to_string()),
295: 293:                 })
296: 294:             }
297: 295:         }
298: 296:     }
299: 297: 
300: 298:     async fn resolve_struct_value(
301: 299:         &self,
302: 300:         flag_key: &str,
303: 301:         evaluation_context: &EvaluationContext,
304: 302:     ) -> EvaluationResult<ResolutionDetails<StructValue>> {
305: 303:         match self.eval_config(evaluation_context).await {
306: 304:             Ok(config) => {
307: 305:                 if let Some(value) = config.get(flag_key) {
308: 306:                     // Use the conversion utility we added earlier
309: 307:                     match ConversionUtils::serde_value_to_struct_value(value) {
310: 308:                         Ok(struct_value) => {
311: 309:                             return Ok(ResolutionDetails::new(struct_value));
312: 310:                         }
313: 311:                         Err(e) => {
314: 312:                             error!("Error converting value to StructValue: {}", e);
315: 313:                             return Err(EvaluationError {
316: 314:                                 code: EvaluationErrorCode::ParseError,
317: 315:                                 message: Some(format!(
318: 316:                                     "Failed to parse struct value: {}",
319: 317:                                     e
320: 318:                                 )),
321: 319:                             });
322: 320:                         }
323: 321:                     }
324: 322:                 }
325: 323:                 Err(EvaluationError {
326: 324:                     code: EvaluationErrorCode::FlagNotFound,
327: 325:                     message: Some("Flag not found in configuration".to_string()),
328: 326:                 })
329: 327:             }
330: 328:             Err(e) => {
331: 329:                 error!("Error evaluating Object flag {}: {}", flag_key, e);
332: 330:                 Err(EvaluationError {
333: 331:                     code: EvaluationErrorCode::FlagNotFound,
334: 332:                     message: Some("Flag not found in configuration".to_string()),
335: 333:                 })
336: 334:             }
337: 335:         }
338: 336:     }
339: 337: 
340: 338:     fn metadata(&self) -> &ProviderMetadata {
341: 339:         &self.metadata
342: 340:     }
343: 341: 
344: 342:     fn status(&self) -> ProviderStatus {
345: 343:         // Since we can't await in a non-async function, we need to handle this differently
346: 344:         // We'll use try_read() which returns immediately
347: 345:         match self.status.try_read() {
348: 346:             Ok(status) => match *status {
349: 347:                 ProviderStatus::Ready => ProviderStatus::Ready,
350: 348:                 ProviderStatus::Error => ProviderStatus::Error,
351: 349:                 ProviderStatus::NotReady => ProviderStatus::NotReady,
352: 350:                 ProviderStatus::STALE => ProviderStatus::STALE,
353: 351:             },
354: 352:             Err(_) => ProviderStatus::NotReady, // Default if lock is held
355: 353:         }
356: 354:     }
357: 355: }
358: 356: ```
359: 357: ```
360: 358: ```
361: 359: ```
362: ```
```

