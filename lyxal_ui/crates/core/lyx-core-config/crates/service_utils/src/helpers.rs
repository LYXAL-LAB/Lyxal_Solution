### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\helpers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\helpers.rs
10: 8: ```rust
11: 9: use std::{
12: 10:     collections::HashMap,
13: 11:     env::VarError,
14: 12:     fmt::{self, Display},
15: 13:     str::FromStr,
16: 14: };
17: 15: 
18: 16: use actix_web::{Error, error::ErrorInternalServerError, web::Data};
19: 17: use anyhow::anyhow;
20: 18: use chrono::Utc;
21: 19: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
22: 20: use jsonschema::{ValidationError, error::ValidationErrorKind};
23: 21: use log::info;
24: 22: use once_cell::sync::Lazy;
25: 23: use regex::Regex;
26: 24: use reqwest::{
27: 25:     StatusCode,
28: 26:     header::{HeaderMap, HeaderName, HeaderValue},
29: 27: };
30: 28: use secrecy::ExposeSecret;
31: 29: use serde::Serialize;
32: 30: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::unexpected_error;
33: 31: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
34: 32:     DBConnection, DimensionInfo,
35: 33:     api::webhook::{HeadersEnum, WebhookEventInfo, WebhookResponse},
36: 34:     database::{
37: 35:         models::{
38: 36:             Workspace,
39: 37:             others::{CustomHeaders, HttpMethod, Webhook, WebhookEvent},
40: 38:         },
41: 39:         schema::{
42: 40:             dimensions::{self, dimension},
43: 41:             secrets::dsl as secrets_dsl,
44: 42:             variables::dsl as variables_dsl,
45: 43:         },
46: 44:         lyx-core-lyx_core_lyx-core-lyx_core_superposition_schema::lyx-core-lyx_core_lyx-core-lyx_core_superposition::workspaces,
47: 45:     },
48: 46:     result::{self},
49: 47: };
50: 48: 
51: 49: use crate::encryption::{EncryptionError, decrypt_secret, decrypt_workspace_key};
52: 50: use crate::service::types::{AppState, SchemaName, WorkspaceContext};
53: 51: 
54: 52: // using named group to capture which type (secrets/variables) the regex was
55: 53: // because variables and secrets need to be handled differently inside webhook execution
56: 54: static CONFIG_REFERENCE_REGEX: Lazy<regex::Regex> = Lazy::new(|| {
57: 55:     regex::Regex::new(r"\{\{(?P<type>VARS|SECRETS)\.(?P<name>[A-Z0-9_]+)\}\}")
58: 56:         .expect("Invalid config pattern")
59: 57: });
60: 58: 
61: 59: const CONFIG_TAG_REGEX: &str = "^[a-zA-Z0-9_-]{1,64}$";
62: 60: 
63: 61: //WARN Do NOT use this fxn inside api requests, instead add the required
64: 62: //env to AppState and get value from there. As this panics, it should
65: 63: //only be used for envs needed during lyx-platform-lyx_platform_lyx-platform-lyx_platform_app start.
66: 64: pub fn get_from_env_unsafe<F>(name: &str) -> Result<F, VarError>
67: 65: where
68: 66:     F: FromStr,
69: 67:     <F as FromStr>::Err: std::fmt::Debug,
70: 68: {
71: 69:     std::env::var(name)
72: 70:         .map(|val| val.parse().unwrap())
73: 71:         .map_err(|e| {
74: 72:             log::info!("{name} env not found with error: {e}");
75: 73:             e
76: 74:         })
77: 75: }
78: 76: 
79: 77: pub fn get_from_env_or_default<F>(name: &str, default: F) -> F
80: 78: where
81: 79:     F: FromStr + Display,
82: 80:     <F as FromStr>::Err: std::fmt::Debug,
83: 81: {
84: 82:     match std::env::var(name) {
85: 83:         Ok(env) => env.parse().unwrap(),
86: 84:         Err(err) => {
87: 85:             info!(
88: 86:                 "{name} ENV failed to load due to {err}, using default value {default}"
89: 87:             );
90: 88:             default
91: 89:         }
92: 90:     }
93: 91: }
94: 92: 
95: 93: pub trait ToActixErr<T> {
96: 94:     fn map_err_to_internal_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server<B>(
97: 95:         self,
98: 96:         log_prefix: &str,
99: 97:         err_body: B,
100: 98:     ) -> Result<T, Error>
101: 99:     where
102: 100:         B: fmt::Debug + fmt::Display + 'static;
103: 101: }
104: 102: 
105: 103: impl<T, E> ToActixErr<T> for Result<T, E>
106: 104: where
107: 105:     E: fmt::Debug,
108: 106: {
109: 107:     fn map_err_to_internal_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server<B>(
110: 108:         self,
111: 109:         log_prefix: &str,
112: 110:         err_body: B,
113: 111:     ) -> Result<T, Error>
114: 112:     where
115: 113:         B: fmt::Debug + fmt::Display + 'static,
116: 114:     {
117: 115:         self.map_err(|e| {
118: 116:             log::info!("{log_prefix}, err: {e:?}");
119: 117:             ErrorInternalServerError(err_body)
120: 118:         })
121: 119:     }
122: 120: }
123: 121: 
124: 122: pub fn get_pod_info() -> (String, String) {
125: 123:     let hostname: String = get_from_env_unsafe("HOSTNAME").expect("HOSTNAME is not set");
126: 124:     let tokens = hostname
127: 125:         .split('-')
128: 126:         .map(str::to_string)
129: 127:         .collect::<Vec<String>>();
130: 128:     let mut tokens = tokens.iter().rev();
131: 129:     let (pod_id, _replica_set, deployment_id) = (
132: 130:         tokens.next().unwrap().to_owned(),
133: 131:         tokens.next().unwrap().to_owned(),
134: 132:         tokens.next().unwrap().to_owned(),
135: 133:     );
136: 134:     (pod_id, deployment_id)
137: 135: }
138: 136: 
139: 137: pub fn validation_err_to_str(errors: Vec<ValidationError>) -> Vec<String> {
140: 138:     errors.into_iter().map(|error| {
141: 139:         match error.kind {
142: 140:             ValidationErrorKind::AdditionalItems { limit } => {
143: 141:                 format!("input array contain more items than expected, limit is {limit}")
144: 142:             }
145: 143:             ValidationErrorKind::AdditionalProperties { unexpected } => {
146: 144:                 format!("unexpected properties `{}`", unexpected.join(", "))
147: 145:             }
148: 146:             ValidationErrorKind::AnyOf => {
149: 147:                 "not valid under any of the schemas listed in the 'anyOf' keyword".to_string()
150: 148:             }
151: 149:             ValidationErrorKind::BacktrackLimitExceeded { error: _ } => {
152: 150:                 "backtrack limit exceeded while matching regex".to_string()
153: 151:             }
154: 152:             ValidationErrorKind::Constant { expected_value } => {
155: 153:                 format!("value doesn't match expected constant `{expected_value}`")
156: 154:             }
157: 155:             ValidationErrorKind::Contains => {
158: 156:                 "array doesn't contain items conforming to the specified schema".to_string()
159: 157:             }
160: 158:             ValidationErrorKind::ContentEncoding { content_encoding } => {
161: 159:                 format!("value doesn't respect the defined contentEncoding `{content_encoding}`")
162: 160:             }
163: 161:             ValidationErrorKind::ContentMediaType { content_media_type } => {
164: 162:                 format!("value doesn't respect the defined contentMediaType `{content_media_type}`")
165: 163:             }
166: 164:             ValidationErrorKind::Enum { options } => {
167: 165:                 format!("value doesn't match any of specified options {}", options)
168: 166:             }
169: 167:             ValidationErrorKind::ExclusiveMaximum { limit } => {
170: 168:                 format!("value is too large, limit is {limit}")
171: 169:             }
172: 170:             ValidationErrorKind::ExclusiveMinimum { limit } => {
173: 171:                 format!("value is too small, limit is {limit}")
174: 172:             }
175: 173:             ValidationErrorKind::FalseSchema => {
176: 174:                 "everything is invalid for `false` schema".to_string()
177: 175:             }
178: 176:             ValidationErrorKind::FileNotFound { error: _ } => {
179: 177:                 "referenced file not found".to_string()
180: 178:             }
181: 179:             ValidationErrorKind::Format { format } => {
182: 180:                 format!("value doesn't match the specified format `{}`", format)
183: 181:             }
184: 182:             ValidationErrorKind::FromUtf8 { error: _ } => {
185: 183:                 "invalid UTF-8 data".to_string()
186: 184:             }
187: 185:             ValidationErrorKind::InvalidReference { reference } => {
188: 186:                 format!("`{}` is not a valid reference", reference)
189: 187:             }
190: 188:             ValidationErrorKind::InvalidURL { error } => {
191: 189:                 format!("invalid URL: {}", error)
192: 190:             }
193: 191:             ValidationErrorKind::JSONParse { error } => {
194: 192:                 format!("error parsing JSON: {}", error)
195: 193:             }
196: 194:             ValidationErrorKind::MaxItems { limit } => {
197: 195:                 format!("too many items in array, limit is {}", limit)
198: 196:             }
199: 197:             ValidationErrorKind::Maximum { limit } => {
200: 198:                 format!("value is too large, maximum is {}", limit)
201: 199:             }
202: 200:             ValidationErrorKind::MaxLength { limit } => {
203: 201:                 format!("string is too long, maximum length is {}", limit)
204: 202:             }
205: 203:             ValidationErrorKind::MaxProperties { limit } => {
206: 204:                 format!("too many properties in object, limit is {}", limit)
207: 205:             }
208: 206:             ValidationErrorKind::MinItems { limit } => {
209: 207:                 format!("not enough items in array, minimum is {}", limit)
210: 208:             }
211: 209:             ValidationErrorKind::Minimum { limit } => {
212: 210:                 format!("value is too small, minimum is {}", limit)
213: 211:             }
214: 212:             ValidationErrorKind::MinLength { limit } => {
215: 213:                 format!("string is too short, minimum length is {}", limit)
216: 214:             }
217: 215:             ValidationErrorKind::MinProperties { limit } => {
218: 216:                 format!("not enough properties in object, minimum is {}", limit)
219: 217:             }
220: 218:             ValidationErrorKind::MultipleOf { multiple_of } => {
221: 219:                 format!("value is not a multiple of {}", multiple_of)
222: 220:             }
223: 221:             ValidationErrorKind::Not { schema } => {
224: 222:                 format!("negated schema `{}` failed validation", schema)
225: 223:             }
226: 224:             ValidationErrorKind::OneOfMultipleValid => {
227: 225:                 "value is valid under more than one schema listed in the 'oneOf' keyword".to_string()
228: 226:             }
229: 227:             ValidationErrorKind::OneOfNotValid => {
230: 228:                 "value is not valid under any of the schemas listed in the 'oneOf' keyword".to_string()
231: 229:             }
232: 230:             ValidationErrorKind::Pattern { pattern } => {
233: 231:                 format!("value doesn't match the pattern `{}`", pattern)
234: 232:             }
235: 233:             ValidationErrorKind::PropertyNames { error } => {
236: 234:                 format!("object property names are invalid: {}", error)
237: 235:             }
238: 236:             ValidationErrorKind::Required { property } => {
239: 237:                 format!("required property `{}` is missing", property)
240: 238:             }
241: 239:             ValidationErrorKind::Resolver { url, error } => {
242: 240:                 format!("error resolving reference `{}`: {}", url, error)
243: 241:             }
244: 242:             ValidationErrorKind::Schema => {
245: 243:                 "resolved schema failed to compile".to_string()
246: 244:             }
247: 245:             ValidationErrorKind::Type { kind } => {
248: 246:                 format!("value doesn't match the required type(s) `{:?}`", kind)
249: 247:             }
250: 248:             ValidationErrorKind::UnevaluatedProperties { unexpected } => {
251: 249:                 format!("unevaluated properties `{}`", unexpected.join(", "))
252: 250:             }
253: 251:             ValidationErrorKind::UniqueItems => {
254: 252:                 "array contains non-unique elements".to_string()
255: 253:             }
256: 254:             ValidationErrorKind::UnknownReferenceScheme { scheme } => {
257: 255:                 format!("unknown reference scheme `{}`", scheme)
258: 256:             }
259: 257:             ValidationErrorKind::Utf8 { error } => {
260: 258:                 format!("invalid UTF-8 string: {}", error)
261: 259:             }
262: 260:         }
263: 261:     }).collect()
264: 262: }
265: 263: 
266: 264: static HTTP_CLIENT: Lazy<reqwest::Client> = Lazy::new(reqwest::Client::new);
267: 265: 
268: 266: pub fn construct_request_headers(entries: &[(&str, &str)]) -> Result<HeaderMap, String> {
269: 267:     entries
270: 268:         .iter()
271: 269:         .map(|(name, value)| {
272: 270:             let h_name = HeaderName::from_str(name);
273: 271:             let h_value = HeaderValue::from_str(value);
274: 272: 
275: 273:             match (h_name, h_value) {
276: 274:                 (Ok(n), Ok(v)) => Some((n, v)),
277: 275:                 _ => None,
278: 276:             }
279: 277:         })
280: 278:         .collect::<Option<Vec<(HeaderName, HeaderValue)>>>()
281: 279:         .map(HeaderMap::from_iter)
282: 280:         .ok_or(String::from("failed to parse headers"))
283: 281: }
284: 282: 
285: 283: pub async fn request<T, R>(
286: 284:     url: String,
287: 285:     method: reqwest::Method,
288: 286:     body: Option<T>,
289: 287:     headers: HeaderMap,
290: 288: ) -> Result<R, reqwest::Error>
291: 289: where
292: 290:     T: serde::Serialize,
293: 291:     R: serde::de::DeserializeOwned,
294: 292: {
295: 293:     let mut request_builder = HTTP_CLIENT.request(method.clone(), url).headers(headers);
296: 294:     request_builder = match (method, body) {
297: 295:         (reqwest::Method::GET | reqwest::Method::DELETE, _) => request_builder,
298: 296:         (_, Some(data)) => request_builder.json(&data),
299: 297:         _ => request_builder,
300: 298:     };
301: 299: 
302: 300:     let response = request_builder.send().await?;
303: 301: 
304: 302:     response.json::<R>().await
305: 303: }
306: 304: pub fn generate_snowflake_id(state: &Data<AppState>) -> result::Result<i64> {
307: 305:     let mut snowflake_generator = state.snowflake_generator.lock().map_err(|e| {
308: 306:         log::error!("snowflake_id generation failed {}", e);
309: 307:         result::AppError::UnexpectedError(anyhow!("snowflake_id generation failed {}", e))
310: 308:     })?;
311: 309:     let id = snowflake_generator.real_time_generate();
312: 310:     // explicitly dropping snowflake_generator so that lock is released and it can be acquired in bulk-operations handler
313: 311:     drop(snowflake_generator);
314: 312:     Ok(id)
315: 313: }
316: 314: 
317: 315: pub fn parse_config_tags(
318: 316:     config_tags: Option<String>,
319: 317: ) -> result::Result<Option<Vec<String>>> {
320: 318:     let regex = Regex::new(CONFIG_TAG_REGEX).map_err(|err| {
321: 319:         log::error!("regex match failed for tags {}", err);
322: 320:         result::AppError::UnexpectedError(anyhow!("Something went wrong"))
323: 321:     })?;
324: 322:     match config_tags {
325: 323:         None => Ok(None),
326: 324:         Some(val) => {
327: 325:             let tags = val
328: 326:                 .split(',')
329: 327:                 .map(|s| {
330: 328:                     if !regex.is_match(s) {
331: 329:                         Err(result::AppError::BadArgument(
332: 330:                             "Invalid config_tags value".to_string(),
333: 331:                         ))
334: 332:                     } else {
335: 333:                         Ok(s.to_owned())
336: 334:                     }
337: 335:                 })
338: 336:                 .collect::<result::Result<Vec<String>>>()?;
339: 337:             Ok(Some(tags))
340: 338:         }
341: 339:     }
342: 340: }
343: 341: 
344: 342: pub fn get_workspace(
345: 343:     workspace_schema_name: &SchemaName,
346: 344:     db_conn: &mut DBConnection,
347: 345: ) -> result::Result<Workspace> {
348: 346:     let workspace = workspaces::dsl::workspaces
349: 347:         .filter(workspaces::workspace_schema_name.eq(workspace_schema_name.to_string()))
350: 348:         .get_result::<Workspace>(db_conn)?;
351: 349:     Ok(workspace)
352: 350: }
353: 351: 
354: 352: fn has_pattern_in_headers(headers: &CustomHeaders) -> (bool, bool) {
355: 353:     let mut has_vars = false;
356: 354:     let mut has_secrets = false;
357: 355:     for value in headers.values() {
358: 356:         let ref_type = value
359: 357:             .as_str()
360: 358:             .and_then(|s| CONFIG_REFERENCE_REGEX.captures(s))
361: 359:             .and_then(|caps| caps.name("type"))
362: 360:             .map(|m| m.as_str());
363: 361: 
364: 362:         match ref_type {
365: 363:             Some("VARS") => has_vars = true,
366: 364:             Some("SECRETS") => has_secrets = true,
367: 365:             _ => (),
368: 366:         }
369: 367:     }
370: 368:     (has_vars, has_secrets)
371: 369: }
372: 370: 
373: 371: fn substitute_templates(
374: 372:     template: &str,
375: 373:     variables: &HashMap<String, String>,
376: 374:     secrets: &HashMap<String, String>,
377: 375: ) -> String {
378: 376:     CONFIG_REFERENCE_REGEX
379: 377:         .replace(template, |caps: &regex::Captures| {
380: 378:             let ref_type = caps.name("type").map(|m| m.as_str());
381: 379:             let ref_name = caps.name("name").map(|m| m.as_str());
382: 380: 
383: 381:             match (ref_type, ref_name) {
384: 382:                 (Some("VARS"), Some(name)) => variables.get(name).cloned(),
385: 383:                 (Some("SECRETS"), Some(name)) => secrets.get(name).cloned(),
386: 384:                 _ => None,
387: 385:             }
388: 386:             .unwrap_or(template.to_string())
389: 387:         })
390: 388:         .into_owned()
391: 389: }
392: 390: 
393: 391: fn fetch_variables(
394: 392:     workspace_context: &WorkspaceContext,
395: 393:     conn: &mut DBConnection,
396: 394: ) -> result::Result<HashMap<String, String>> {
397: 395:     let variables_map = variables_dsl::variables
398: 396:         .select((variables_dsl::name, variables_dsl::value))
399: 397:         .schema_name(&workspace_context.schema_name)
400: 398:         .load(conn)?
401: 399:         .into_iter()
402: 400:         .collect();
403: 401: 
404: 402:     Ok(variables_map)
405: 403: }
406: 404: 
407: 405: fn fetch_secrets(
408: 406:     workspace_context: &WorkspaceContext,
409: 407:     state: &Data<AppState>,
410: 408:     conn: &mut DBConnection,
411: 409: ) -> result::Result<HashMap<String, String>> {
412: 410:     let encryption_key = workspace_context.settings.encryption_key.as_str();
413: 411: 
414: 412:     let master_encryption_key = match state.master_encryption_key {
415: 413:         Some(ref key) => key,
416: 414:         None => {
417: 415:             log::warn!("Master encryption key not configured, skipping secrets");
418: 416:             return Ok(HashMap::new());
419: 417:         }
420: 418:     };
421: 419: 
422: 420:     let workspace_key = match decrypt_workspace_key(encryption_key, master_encryption_key)
423: 421:     {
424: 422:         Ok(key) => key,
425: 423:         Err(e) => {
426: 424:             log::error!("Failed to decrypt workspace key: {}", e);
427: 425:             return Err(unexpected_error!("Failed to decrypt workspace key"));
428: 426:         }
429: 427:     };
430: 428: 
431: 429:     let db_secrets: Vec<(String, String)> = secrets_dsl::secrets
432: 430:         .schema_name(&workspace_context.schema_name)
433: 431:         .select((secrets_dsl::name, secrets_dsl::encrypted_value))
434: 432:         .load(conn)
435: 433:         .map_err(|e| {
436: 434:             log::error!("Failed to load secrets: {}", e);
437: 435:             unexpected_error!("Failed to load secrets")
438: 436:         })?;
439: 437: 
440: 438:     let result: Result<HashMap<String, String>, EncryptionError> = db_secrets
441: 439:         .into_iter()
442: 440:         .map(|(name, encrypted_value)| {
443: 441:             decrypt_secret(&encrypted_value, &workspace_key)
444: 442:                 .map(|decrypted| (name, decrypted.expose_secret().to_string()))
445: 443:         })
446: 444:         .collect();
447: 445: 
448: 446:     result.map_err(|e| {
449: 447:         log::error!("Failed to decrypt secrets: {}", e);
450: 448:         unexpected_error!("Failed to decrypt secrets")
451: 449:     })
452: 450: }
453: 451: 
454: 452: pub async fn execute_webhook_call<T>(
455: 453:     webhook: &Webhook,
456: 454:     payload: &T,
457: 455:     config_version_opt: &Option<String>,
458: 456:     workspace_context: &WorkspaceContext,
459: 457:     event: WebhookEvent,
460: 458:     state: &Data<AppState>,
461: 459:     conn: &mut DBConnection,
462: 460: ) -> bool
463: 461: where
464: 462:     T: Serialize,
465: 463: {
466: 464:     if !webhook.enabled {
467: 465:         log::info!("Webhook is disabled, skipping call");
468: 466:         return true;
469: 467:     }
470: 468: 
471: 469:     let (has_vars, has_secrets) = has_pattern_in_headers(&webhook.custom_headers);
472: 470: 
473: 471:     let variables = if has_vars {
474: 472:         match fetch_variables(workspace_context, conn) {
475: 473:             Ok(vars_map) => vars_map,
476: 474:             Err(e) => {
477: 475:                 log::error!("Failed to fetch variables for webhook: {}", e);
478: 476:                 return false;
479: 477:             }
480: 478:         }
481: 479:     } else {
482: 480:         HashMap::new()
483: 481:     };
484: 482: 
485: 483:     let secrets = if has_secrets {
486: 484:         match fetch_secrets(workspace_context, state, conn) {
487: 485:             Ok(secrets_map) => secrets_map,
488: 486:             Err(e) => {
489: 487:                 log::error!("Failed to fetch secrets for webhook: {}", e);
490: 488:                 return false;
491: 489:             }
492: 490:         }
493: 491:     } else {
494: 492:         HashMap::new()
495: 493:     };
496: 494: 
497: 495:     let mut headers = HeaderMap::new();
498: 496: 
499: 497:     let insert_header = |headers: &mut HeaderMap, name: &str, value: &str| {
500: 498:         if let (Ok(k), Ok(v)) = (HeaderName::from_str(name), HeaderValue::from_str(value))
501: 499:         {
502: 500:             headers.insert(k, v);
503: 501:         }
504: 502:     };
505: 503: 
506: 504:     insert_header(
507: 505:         &mut headers,
508: 506:         &HeadersEnum::ConfigVersion.to_string(),
509: 507:         &config_version_opt.clone().unwrap_or_default(),
510: 508:     );
511: 509:     insert_header(
512: 510:         &mut headers,
513: 511:         &HeadersEnum::WorkspaceId.to_string(),
514: 512:         &workspace_context.workspace_id,
515: 513:     );
516: 514: 
517: 515:     for (key, value) in webhook.custom_headers.iter() {
518: 516:         let value_str = value
519: 517:             .as_str()
520: 518:             .map(String::from)
521: 519:             .unwrap_or_else(|| value.to_string());
522: 520:         let rendered = substitute_templates(&value_str, &variables, &secrets);
523: 521:         insert_header(&mut headers, key, &rendered);
524: 522:     }
525: 523: 
526: 524:     let request_builder = match webhook.method {
527: 525:         HttpMethod::Post => state.http_lyx-core-lyx_core_lyx-core-lyx_core_client.post(&*webhook.url),
528: 526:         HttpMethod::Get => state.http_lyx-core-lyx_core_lyx-core-lyx_core_client.get(&*webhook.url),
529: 527:         HttpMethod::Put => state.http_lyx-core-lyx_core_lyx-core-lyx_core_client.put(&*webhook.url),
530: 528:         HttpMethod::Delete => state.http_lyx-core-lyx_core_lyx-core-lyx_core_client.delete(&*webhook.url),
531: 529:         HttpMethod::Patch => state.http_lyx-core-lyx_core_lyx-core-lyx_core_client.patch(&*webhook.url),
532: 530:         HttpMethod::Head => state.http_lyx-core-lyx_core_lyx-core-lyx_core_client.head(&*webhook.url),
533: 531:     };
534: 532: 
535: 533:     let response = request_builder
536: 534:         .headers(headers)
537: 535:         .json(&WebhookResponse {
538: 536:             event_info: WebhookEventInfo {
539: 537:                 webhook_event: event,
540: 538:                 time: Utc::now().to_string(),
541: 539:                 workspace_id: workspace_context.workspace_id.to_string(),
542: 540:                 organisation_id: workspace_context.organisation_id.to_string(),
543: 541:                 config_version: config_version_opt.clone(),
544: 542:             },
545: 543:             payload,
546: 544:         })
547: 545:         .send()
548: 546:         .await;
549: 547: 
550: 548:     match response {
551: 549:         Ok(res) if res.status() == StatusCode::OK => {
552: 550:             log::info!("webhook call succeeded: {:?}", res.status());
553: 551:             true
554: 552:         }
555: 553:         Ok(res) => {
556: 554:             log::error!("Webhook failed: {:?} - {:?}", res.status(), res.headers());
557: 555:             false
558: 556:         }
559: 557:         Err(err) => {
560: 558:             log::error!("Webhook call failed: {:?}", err);
561: 559:             false
562: 560:         }
563: 561:     }
564: 562: }
565: 563: 
566: 564: pub fn fetch_dimensions_info_map(
567: 565:     conn: &mut DBConnection,
568: 566:     schema_name: &SchemaName,
569: 567: ) -> result::Result<HashMap<String, DimensionInfo>> {
570: 568:     let dimensions_map = dimensions::table
571: 569:         .select((dimension, DimensionInfo::as_select()))
572: 570:         .schema_name(schema_name)
573: 571:         .load::<(String, DimensionInfo)>(conn)?
574: 572:         .into_iter()
575: 573:         .collect();
576: 574: 
577: 575:     Ok(dimensions_map)
578: 576: }
579: 577: ```
580: 578: ```
581: 579: ```
582: 580: ```
583: ```
```
