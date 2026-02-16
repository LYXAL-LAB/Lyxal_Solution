1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-image\src\optimizer.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\optimizer.rs
46: 44: ```rust
47: 45: use serde::{Deserialize, Serialize};
48: 46: 
49: 47: /// ImageOptimizer enables image optimization and caching.
50: 48: #[cfg(feature = "ssr")]
51: 49: #[derive(Debug, Clone)]
52: 50: pub struct ImageOptimizer {
53: 51:     pub(crate) api_handler_path: String,
54: 52:     pub(crate) root_file_path: String,
55: 53:     pub(crate) semaphore: std::sync::Arc<tokio::sync::Semaphore>,
56: 54:     pub(crate) cache: std::sync::Arc<dashmap::DashMap<CachedImage, String>>,
57: 55: }
58: 56: 
59: 57: #[cfg(feature = "ssr")]
60: 58: impl ImageOptimizer {
61: 59:     /// Creates a new ImageOptimizer.
62: 60:     /// api_handler_path is the path where the image handler is located in the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server router.
63: 61:     /// Parallelism denotes the number of images that can be created at once.
64: 62:     /// Useful to limit to prevent overloading the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
65: 63:     pub fn new(
66: 64:         api_handler_path: impl Into<String>,
67: 65:         root_file_path: impl Into<String>,
68: 66:         parallelism: usize,
69: 67:     ) -> Self {
70: 68:         let semaphore = tokio::sync::Semaphore::new(parallelism);
71: 69:         let semaphore = std::sync::Arc::new(semaphore);
72: 70:         Self {
73: 71:             api_handler_path: api_handler_path.into(),
74: 72:             root_file_path: root_file_path.into(),
75: 73:             semaphore,
76: 74:             cache: std::sync::Arc::new(dashmap::DashMap::new()),
77: 75:         }
78: 76:     }
79: 77: 
80: 78:     /// Creates a context function to provide the optimizer.
81: 79:     ///
82: 80:     /// ```
83: 81:     /// use lyx-core-lyx_core_lyx-spec-image::*;
84: 82:     /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
85: 83:     /// use axum::*;
86: 84:     /// use axum::routing::post;
87: 85:     /// use lyx-core-axum::{generate_route_list, handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns, LeptosRoutes};
88: 86:     ///
89: 87:     /// #[cfg(feature = "ssr")]
90: 88:     /// async fn your_main_function() {
91: 89:     ///
92: 90:     ///   let options = get_configuration(None).await.unwrap().lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
93: 91:     ///   let optimizer = ImageOptimizer::new("/__cache/image", options.site_root.clone(), 1);
94: 92:     ///   let state = AppState {lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: options, optimizer: optimizer.clone() };
95: 93:     ///   let routes = generate_route_list(App);
96: 94:     ///
97: 95:     ///   let router: Router<()> = Router::new()
98: 96:     ///    .route("/api/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
99: 97:     ///    .image_cache_route(&state)
100: 98:     ///    // Use provide_context()
101: 99:     ///    .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context(&state, routes, optimizer.provide_context(), App)
102: 100:     ///    .with_state(state);
103: 101:     ///
104: 102:     ///   // Rest of your function ...
105: 103:     /// }
106: 104:     ///
107: 105:     /// // Composite App State with the optimizer and lyx-core-lyx_core_lyx-core-lyx_core_leptos options.
108: 106:     /// #[derive(Clone, axum::extract::FromRef)]
109: 107:     /// struct AppState {
110: 108:     ///   lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions,
111: 109:     ///   optimizer: lyx-core-lyx_core_lyx-spec-image::ImageOptimizer,
112: 110:     /// }
113: 111:     ///
114: 112:     /// #[component]
115: 113:     /// fn App() -> impl IntoView {
116: 114:     ///   ()
117: 115:     /// }
118: 116:     /// ```
119: 117:     pub fn provide_context(&self) -> impl Fn() + 'static + Clone + Send {
120: 118:         let optimizer = self.clone();
121: 119:         move || {
122: 120:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::provide_context(optimizer.clone());
123: 121:         }
124: 122:     }
125: 123: 
126: 124:     pub(crate) async fn create_image(
127: 125:         &self,
128: 126:         cache_image: &CachedImage,
129: 127:     ) -> Result<bool, CreateImageError> {
130: 128:         let root = self.root_file_path.as_str();
131: 129:         {
132: 130:             let option = if let CachedImageOption::Resize(_) = cache_image.option {
133: 131:                 "Resize"
134: 132:             } else {
135: 133:                 "Blur"
136: 134:             };
137: 135:             tracing::debug!("Creating {option} image for {}", &cache_image.src);
138: 136:         }
139: 137: 
140: 138:         let relative_path_created = self.get_file_path(&cache_image);
141: 139: 
142: 140:         let save_path = path_from_segments(vec![root, &relative_path_created]);
143: 141:         let absolute_src_path = path_from_segments(vec![root, &cache_image.src]);
144: 142: 
145: 143:         if file_exists(&save_path).await {
146: 144:             Ok(false)
147: 145:         } else {
148: 146:             let _ = self
149: 147:                 .semaphore
150: 148:                 .acquire()
151: 149:                 .await
152: 150:                 .expect("Failed to acquire semaphore");
153: 151:             let task = tokio::task::spawn_blocking({
154: 152:                 let option = cache_image.option.clone();
155: 153:                 move || create_optimized_image(option, absolute_src_path, save_path)
156: 154:             });
157: 155: 
158: 156:             match task.await {
159: 157:                 Err(join_error) => Err(CreateImageError::JoinError(join_error)),
160: 158:                 Ok(Err(err)) => Err(err),
161: 159:                 Ok(Ok(_)) => Ok(true),
162: 160:             }
163: 161:         }
164: 162:     }
165: 163: 
166: 164:     #[cfg(feature = "ssr")]
167: 165:     pub(crate) fn get_file_path_from_root(&self, cache_image: &CachedImage) -> String {
168: 166:         let path = path_from_segments(vec![
169: 167:             self.root_file_path.as_ref(),
170: 168:             &self.get_file_path(cache_image),
171: 169:         ]);
172: 170:         path.as_path().to_string_lossy().to_string()
173: 171:     }
174: 172: 
175: 173:     pub(crate) fn get_file_path(&self, cache_image: &CachedImage) -> String {
176: 174:         use base64::{engine::general_purpose, Engine as _};
177: 175:         // I'm worried this name will become too long.
178: 176:         // names are limited to 255 bytes on most filesystems.
179: 177: 
180: 178:         let encode = serde_qs::to_string(&cache_image).unwrap();
181: 179:         let encode = general_purpose::STANDARD.encode(encode);
182: 180: 
183: 181:         let mut path = path_from_segments(vec!["cache/image", &encode, &cache_image.src]);
184: 182: 
185: 183:         if let CachedImageOption::Resize { .. } = cache_image.option {
186: 184:             path.set_extension("webp");
187: 185:         } else {
188: 186:             path.set_extension("svg");
189: 187:         };
190: 188: 
191: 189:         path.as_path().to_string_lossy().to_string()
192: 190:     }
193: 191: }
194: 192: 
195: 193: #[cfg(feature = "ssr")]
196: 194: fn create_optimized_image<P>(
197: 195:     config: CachedImageOption,
198: 196:     source_path: P,
199: 197:     save_path: P,
200: 198: ) -> Result<(), CreateImageError>
201: 199: where
202: 200:     P: AsRef<std::path::Path> + AsRef<std::ffi::OsStr>,
203: 201: {
204: 202:     use webp::*;
205: 203: 
206: 204:     match config {
207: 205:         CachedImageOption::Resize(Resize {
208: 206:             width,
209: 207:             height,
210: 208:             quality,
211: 209:         }) => {
212: 210:             let img = image::open(source_path)?;
213: 211:             let new_img = img.resize(
214: 212:                 width,
215: 213:                 height,
216: 214:                 // Cubic Filter.
217: 215:                 image::imageops::FilterType::CatmullRom,
218: 216:             );
219: 217:             // Create the WebP encoder for the above image
220: 218:             let encoder: Encoder = Encoder::from_image(&new_img).unwrap();
221: 219:             // Encode the image at a specified quality 0-100
222: 220:             let webp: WebPMemory = encoder.encode(quality as f32);
223: 221:             create_nested_if_needed(&save_path)?;
224: 222:             std::fs::write(save_path, &*webp)?;
225: 223: 
226: 224:             Ok(())
227: 225:         }
228: 226:         CachedImageOption::Blur(blur) => {
229: 227:             let svg = create_image_blur(source_path, blur)?;
230: 228:             create_nested_if_needed(&save_path)?;
231: 229:             std::fs::write(save_path, &*svg)?;
232: 230:             Ok(())
233: 231:         }
234: 232:     }
235: 233: }
236: 234: 
237: 235: #[cfg(feature = "ssr")]
238: 236: fn create_image_blur<P>(source_path: P, blur: Blur) -> Result<String, CreateImageError>
239: 237: where
240: 238:     P: AsRef<std::path::Path> + AsRef<std::ffi::OsStr>,
241: 239: {
242: 240:     use webp::*;
243: 241: 
244: 242:     let img = image::open(source_path).map_err(|e| CreateImageError::ImageError(e))?;
245: 243: 
246: 244:     let Blur {
247: 245:         width,
248: 246:         height,
249: 247:         svg_height,
250: 248:         svg_width,
251: 249:         sigma,
252: 250:     } = blur;
253: 251: 
254: 252:     let img = img.resize(width, height, image::imageops::FilterType::Nearest);
255: 253: 
256: 254:     // Create the WebP encoder for the above image
257: 255:     let encoder: Encoder = Encoder::from_image(&img).unwrap();
258: 256:     // Encode the image at a specified quality 0-100
259: 257:     let webp: WebPMemory = encoder.encode(80.0);
260: 258: 
261: 259:     // Encode the image to base64
262: 260:     use base64::{engine::general_purpose, Engine as _};
263: 261:     let encoded = general_purpose::STANDARD.encode(&*webp);
264: 262: 
265: 263:     let uri = format!("data:image/webp;base64,{}", encoded);
266: 264: 
267: 265:     let svg = format!(
268: 266:         r#"
269: 267: <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 {svg_width} {svg_height}" preserveAspectRatio="none">
270: 268:     <filter id="a" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB"> 
271: 269:         <feGaussianBlur stdDeviation="{sigma}" edgeMode="duplicate"/> 
272: 270:         <feComponentTransfer>
273: 271:             <feFuncA type="discrete" tableValues="1 1"/> 
274: 272:         </feComponentTransfer> 
275: 273:     </filter> 
276: 274:     <image filter="url(#a)" x="0" y="0" height="100%" width="100%" href="{uri}"/>
277: 275: </svg>
278: 276: "#,
279: 277:     );
280: 278: 
281: 279:     Ok(svg)
282: 280: }
283: 281: 
284: 282: #[derive(Clone, Debug, Deserialize, PartialEq, Eq, Serialize, Hash)]
285: 283: pub struct CachedImage {
286: 284:     pub(crate) src: String,
287: 285:     pub(crate) option: CachedImageOption,
288: 286: }
289: 287: 
290: 288: impl std::fmt::Display for CachedImage {
291: 289:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
292: 290:         match &self.option {
293: 291:             CachedImageOption::Resize(resize) => write!(
294: 292:                 f,
295: 293:                 "ImageResize {} ({}x{} @ {}% quality)",
296: 294:                 self.src, resize.width, resize.height, resize.quality,
297: 295:             ),
298: 296:             CachedImageOption::Blur(_) => write!(f, "ImageBlur {}", self.src),
299: 297:         }
300: 298:     }
301: 299: }
302: 300: 
303: 301: #[derive(Clone, Debug, Deserialize, PartialEq, Eq, Serialize, Hash)]
304: 302: pub(crate) enum CachedImageOption {
305: 303:     #[serde(rename = "r")]
306: 304:     Resize(Resize),
307: 305:     #[serde(rename = "b")]
308: 306:     Blur(Blur),
309: 307: }
310: 308: 
311: 309: #[derive(Clone, Debug, Deserialize, PartialEq, Eq, Serialize, Hash)]
312: 310: #[serde(rename = "r")]
313: 311: pub(crate) struct Resize {
314: 312:     #[serde(rename = "w")]
315: 313:     pub width: u32,
316: 314:     #[serde(rename = "h")]
317: 315:     pub height: u32,
318: 316:     #[serde(rename = "q")]
319: 317:     pub quality: u8,
320: 318: }
321: 319: 
322: 320: #[derive(Clone, Debug, Deserialize, PartialEq, Eq, Serialize, Hash)]
323: 321: #[serde(rename = "b")]
324: 322: pub(crate) struct Blur {
325: 323:     #[serde(rename = "w")]
326: 324:     pub width: u32,
327: 325:     #[serde(rename = "h")]
328: 326:     pub height: u32,
329: 327:     #[serde(rename = "sw")]
330: 328:     pub svg_width: u32,
331: 329:     #[serde(rename = "sh")]
332: 330:     pub svg_height: u32,
333: 331:     #[serde(rename = "s")]
334: 332:     pub sigma: u8,
335: 333: }
336: 334: 
337: 335: #[cfg(feature = "ssr")]
338: 336: #[derive(Debug, thiserror::Error)]
339: 337: pub enum CreateImageError {
340: 338:     // Unexpected(String),
341: 339:     #[error("Image Error: {0}")]
342: 340:     ImageError(#[from] image::ImageError),
343: 341:     #[error("Join Error: {0}")]
344: 342:     JoinError(#[from] tokio::task::JoinError),
345: 343:     #[error("IO Error: {0}")]
346: 344:     IOError(#[from] std::io::Error),
347: 345: }
348: 346: 
349: 347: impl CachedImage {
350: 348:     pub(crate) fn get_url_encoded(&self, handler_path: impl AsRef<str>) -> String {
351: 349:         let params = serde_qs::to_string(&self).unwrap();
352: 350:         format!("{}?{}", handler_path.as_ref(), params)
353: 351:     }
354: 352: 
355: 353:     #[cfg(feature = "ssr")]
356: 354:     pub(crate) fn get_file_path(&self) -> String {
357: 355:         use base64::{engine::general_purpose, Engine as _};
358: 356:         // I'm worried this name will become too long.
359: 357:         // names are limited to 255 bytes on most filesystems.
360: 358: 
361: 359:         let encode = serde_qs::to_string(&self).unwrap();
362: 360:         let encode = general_purpose::STANDARD.encode(encode);
363: 361: 
364: 362:         let mut path = path_from_segments(vec!["cache/image", &encode, &self.src]);
365: 363: 
366: 364:         if let CachedImageOption::Resize { .. } = self.option {
367: 365:             path.set_extension("webp");
368: 366:         } else {
369: 367:             path.set_extension("svg");
370: 368:         };
371: 369: 
372: 370:         path.as_path().to_string_lossy().to_string()
373: 371:     }
374: 372: 
375: 373:     #[allow(dead_code)]
376: 374:     #[cfg(feature = "ssr")]
377: 375:     // TODO: Fix this. Super Yuck.
378: 376:     pub(crate) fn from_file_path(path: &str) -> Option<Self> {
379: 377:         use base64::{engine::general_purpose, Engine as _};
380: 378:         path.split('/')
381: 379:             .filter_map(|s| {
382: 380:                 general_purpose::STANDARD
383: 381:                     .decode(s)
384: 382:                     .ok()
385: 383:                     .and_then(|s| String::from_utf8(s).ok())
386: 384:             })
387: 385:             .find_map(|encoded| serde_qs::from_str(&encoded).ok())
388: 386:     }
389: 387: 
390: 388:     #[cfg(feature = "ssr")]
391: 389:     pub(crate) fn from_url_encoded(url: &str) -> Result<CachedImage, serde_qs::Error> {
392: 390:         let url = url.split('?').filter(|s| *s != "?").last().unwrap_or(url);
393: 391:         let result: Result<CachedImage, serde_qs::Error> = serde_qs::from_str(url);
394: 392:         result
395: 393:     }
396: 394: }
397: 395: 
398: 396: #[cfg(feature = "ssr")]
399: 397: fn path_from_segments(segments: Vec<&str>) -> std::path::PathBuf {
400: 398:     segments
401: 399:         .into_iter()
402: 400:         .map(|s| s.trim_start_matches('/'))
403: 401:         .map(|s| s.trim_end_matches('/'))
404: 402:         .filter(|s| !s.is_empty())
405: 403:         .collect()
406: 404: }
407: 405: 
408: 406: #[cfg(feature = "ssr")]
409: 407: async fn file_exists<P>(path: P) -> bool
410: 408: where
411: 409:     P: AsRef<std::path::Path>,
412: 410: {
413: 411:     tokio::fs::metadata(path).await.is_ok()
414: 412: }
415: 413: 
416: 414: #[cfg(feature = "ssr")]
417: 415: fn create_nested_if_needed<P>(path: P) -> std::io::Result<()>
418: 416: where
419: 417:     P: AsRef<std::ffi::OsStr>,
420: 418: {
421: 419:     match std::path::Path::new(&path).parent() {
422: 420:         Some(p) if (!(p).exists()) => std::fs::create_dir_all(p),
423: 421:         Some(_) => Result::Ok(()),
424: 422:         None => Result::Ok(()),
425: 423:     }
426: 424: }
427: 425: 
428: 426: // Test module
429: 427: #[cfg(test)]
430: 428: mod optimizer_tests {
431: 429:     use super::*;
432: 430: 
433: 431:     #[test]
434: 432:     fn url_encode() {
435: 433:         let img = CachedImage {
436: 434:             src: "test.jpg".to_string(),
437: 435:             option: CachedImageOption::Resize(Resize {
438: 436:                 quality: 75,
439: 437:                 width: 100,
440: 438:                 height: 100,
441: 439:             }),
442: 440:         };
443: 441: 
444: 442:         let encoded = img.get_url_encoded("/cache/image/test");
445: 443:         let decoded: CachedImage = CachedImage::from_url_encoded(&encoded).unwrap();
446: 444: 
447: 445:         dbg!(encoded);
448: 446:         assert!(img == decoded);
449: 447:     }
450: 448: 
451: 449:     const TEST_IMAGE: &str = "./lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example/lyx-specialized-lyx-specialized-start-axum/public/cute_ferris.png";
452: 450: 
453: 451:     #[test]
454: 452:     fn file_path() {
455: 453:         let spec = CachedImage {
456: 454:             src: TEST_IMAGE.to_string(),
457: 455:             option: CachedImageOption::Blur(Blur {
458: 456:                 width: 25,
459: 457:                 height: 25,
460: 458:                 svg_height: 100,
461: 459:                 svg_width: 100,
462: 460:                 sigma: 20,
463: 461:             }),
464: 462:         };
465: 463: 
466: 464:         let file_path = spec.get_file_path();
467: 465: 
468: 466:         dbg!(spec.get_file_path());
469: 467: 
470: 468:         let result = CachedImage::from_file_path(&file_path).unwrap();
471: 469: 
472: 470:         assert_eq!(spec, result);
473: 471:     }
474: 472: 
475: 473:     #[test]
476: 474:     fn create_blur() {
477: 475:         let result = create_image_blur(
478: 476:             TEST_IMAGE.to_string(),
479: 477:             Blur {
480: 478:                 width: 25,
481: 479:                 height: 25,
482: 480:                 svg_height: 100,
483: 481:                 svg_width: 100,
484: 482:                 sigma: 20,
485: 483:             },
486: 484:         );
487: 485:         assert!(result.is_ok());
488: 486:         println!("{}", result.unwrap());
489: 487:     }
490: 488: 
491: 489:     #[test]
492: 490:     fn create_and_save_blur() {
493: 491:         let spec = CachedImage {
494: 492:             src: TEST_IMAGE.to_string(),
495: 493:             option: CachedImageOption::Blur(Blur {
496: 494:                 width: 25,
497: 495:                 height: 25,
498: 496:                 svg_height: 100,
499: 497:                 svg_width: 100,
500: 498:                 sigma: 20,
501: 499:             }),
502: 500:         };
503: 501: 
504: 502:         let file_path = spec.get_file_path();
505: 503: 
506: 504:         let result = create_optimized_image(spec.option, TEST_IMAGE.to_string(), file_path.clone());
507: 505: 
508: 506:         assert!(result.is_ok());
509: 507: 
510: 508:         println!("Saved SVG at {file_path}");
511: 509:     }
512: 510: 
513: 511:     #[test]
514: 512:     fn create_opt_image() {
515: 513:         let spec = CachedImage {
516: 514:             src: TEST_IMAGE.to_string(),
517: 515:             option: CachedImageOption::Resize(Resize {
518: 516:                 quality: 75,
519: 517:                 width: 100,
520: 518:                 height: 100,
521: 519:             }),
522: 520:         };
523: 521: 
524: 522:         let file_path = spec.get_file_path();
525: 523: 
526: 524:         let result = create_optimized_image(spec.option, TEST_IMAGE.to_string(), file_path.clone());
527: 525: 
528: 526:         assert!(result.is_ok());
529: 527: 
530: 528:         println!("Saved WebP at {file_path}");
531: 529:     }
532: 530: }
533: 531: ```
534: 532: ```
535: 533: ```
536: 534: ```
537: 535: ```
538: 536: ```
539: 537: ```
540: 538: ```
541: 539: ```
542: 540: ```
543: 541: ```
544: 542: ```
545: 543: ```
546: 544: ```
547: 545: ```
548: 546: ```
549: 547: ```
550: 548: ```
551: 549: ```
552: 550: ```
553: 551: ```
554: 552: ```
555: ```
```

