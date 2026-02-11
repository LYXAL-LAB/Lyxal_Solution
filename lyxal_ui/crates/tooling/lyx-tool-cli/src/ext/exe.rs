### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\exe.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\ext\exe.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\ext\exe.rs
38: 36: ```rust
39: 37: use crate::{
40: 38:     ext::anyhow::{bail, Context, Result},
41: 39:     logger::GRAY,
42: 40: };
43: 41: use bytes::Bytes;
44: 42: use std::{
45: 43:     fs::{self, File},
46: 44:     io::{Cursor, Write},
47: 45:     path::{Path, PathBuf},
48: 46:     sync::Once,
49: 47: };
50: 48: 
51: 49: use std::env;
52: 50: 
53: 51: use zip::ZipArchive;
54: 52: 
55: 53: use super::util::{is_linux_musl_env, os_arch};
56: 54: 
57: 55: use reqwest::ClientBuilder;
58: 56: #[cfg(target_family = "unix")]
59: 57: use std::os::unix::prelude::PermissionsExt;
60: 58: use std::time::{Duration, SystemTime};
61: 59: 
62: 60: use semver::Version;
63: 61: 
64: 62: #[derive(Debug)]
65: 63: pub struct ExeMeta {
66: 64:     name: &'static str,
67: 65:     version: String,
68: 66:     url: String,
69: 67:     exe: String,
70: 68:     manual: String,
71: 69: }
72: 70: 
73: 71: lazy_static::lazy_static! {
74: 72:     static ref ON_STARTUP_DEBUG_ONCE: Once = Once::new();
75: 73: }
76: 74: 
77: 75: pub const ENV_VAR_LEPTOS_CARGO_GENERATE_VERSION: &str = "LEPTOS_CARGO_GENERATE_VERSION";
78: 76: pub const ENV_VAR_LEPTOS_TAILWIND_VERSION: &str = "LEPTOS_TAILWIND_VERSION";
79: 77: pub const ENV_VAR_LEPTOS_SASS_VERSION: &str = "LEPTOS_SASS_VERSION";
80: 78: pub const ENV_VAR_LEPTOS_WASM_OPT_VERSION: &str = "LEPTOS_WASM_OPT_VERSION";
81: 79: 
82: 80: impl ExeMeta {
83: 81:     #[allow(clippy::wrong_self_convention)]
84: 82:     fn from_global_path(&self) -> Option<PathBuf> {
85: 83:         which::which(self.name).ok()
86: 84:     }
87: 85: 
88: 86:     fn get_name(&self) -> String {
89: 87:         format!("{}-{}", &self.name, &self.version)
90: 88:     }
91: 89: 
92: 90:     async fn cached(&self) -> Result<PathBuf> {
93: 91:         let cache_dir = get_cache_dir()?.join(self.get_name());
94: 92:         self._with_cache_dir(&cache_dir).await
95: 93:     }
96: 94: 
97: 95:     async fn _with_cache_dir(&self, cache_dir: &Path) -> Result<PathBuf> {
98: 96:         let exe_dir = cache_dir.join(self.get_name());
99: 97:         let c = ExeCache {
100: 98:             meta: self,
101: 99:             exe_dir,
102: 100:         };
103: 101:         c.get().await
104: 102:     }
105: 103: 
106: 104:     #[cfg(test)]
107: 105:     pub async fn with_cache_dir(&self, cache_dir: &Path) -> Result<PathBuf> {
108: 106:         self._with_cache_dir(cache_dir).await
109: 107:     }
110: 108: }
111: 109: 
112: 110: pub struct ExeCache<'a> {
113: 111:     exe_dir: PathBuf,
114: 112:     meta: &'a ExeMeta,
115: 113: }
116: 114: 
117: 115: impl<'a> ExeCache<'a> {
118: 116:     fn exe_in_cache(&self) -> Result<PathBuf> {
119: 117:         let exe_path = self.exe_dir.join(PathBuf::from(&self.meta.exe));
120: 118: 
121: 119:         if !exe_path.exists() {
122: 120:             bail!("The path {exe_path:?} doesn't exist");
123: 121:         }
124: 122: 
125: 123:         Ok(exe_path)
126: 124:     }
127: 125: 
128: 126:     async fn fetch_archive(&self) -> Result<Bytes> {
129: 127:         log::debug!(
130: 128:             "Install downloading {} {}",
131: 129:             self.meta.name,
132: 130:             GRAY.paint(&self.meta.url)
133: 131:         );
134: 132: 
135: 133:         let response = reqwest::get(&self.meta.url).await?;
136: 134: 
137: 135:         match response.status().is_success() {
138: 136:             true => Ok(response.bytes().await?),
139: 137:             false => bail!("Could not download from {}", self.meta.url),
140: 138:         }
141: 139:     }
142: 140: 
143: 141:     fn extract_downloaded(&self, data: &Bytes) -> Result<()> {
144: 142:         if self.meta.url.ends_with(".zip") {
145: 143:             extract_zip(data, &self.exe_dir)?;
146: 144:         } else if self.meta.url.ends_with(".tar.gz") {
147: 145:             extract_tar(data, &self.exe_dir)?;
148: 146:         } else {
149: 147:             self.write_binary(data)
150: 148:                 .context(format!("Could not write binary {}", self.meta.get_name()))?;
151: 149:         }
152: 150: 
153: 151:         log::debug!(
154: 152:             "Install decompressing {} {}",
155: 153:             self.meta.name,
156: 154:             GRAY.paint(self.exe_dir.to_string_lossy())
157: 155:         );
158: 156: 
159: 157:         Ok(())
160: 158:     }
161: 159: 
162: 160:     fn write_binary(&self, data: &Bytes) -> Result<()> {
163: 161:         fs::create_dir_all(&self.exe_dir).unwrap();
164: 162:         let path = self.exe_dir.join(Path::new(&self.meta.exe));
165: 163:         let mut file = File::create(&path).unwrap();
166: 164:         file.write_all(data)
167: 165:             .context(format!("Error writing binary file: {:?}", path))?;
168: 166: 
169: 167:         #[cfg(target_family = "unix")]
170: 168:         {
171: 169:             let mut perm = fs::metadata(&path)?.permissions();
172: 170:             // https://chmod-calculator.com
173: 171:             // read and execute for owner and group
174: 172:             perm.set_mode(0o550);
175: 173:             fs::set_permissions(&path, perm)?;
176: 174:         }
177: 175:         Ok(())
178: 176:     }
179: 177: 
180: 178:     async fn download(&self) -> Result<PathBuf> {
181: 179:         log::info!("Command installing {} ...", self.meta.get_name());
182: 180: 
183: 181:         let data = self
184: 182:             .fetch_archive()
185: 183:             .await
186: 184:             .context(format!("Could not download {}", self.meta.get_name()))?;
187: 185: 
188: 186:         self.extract_downloaded(&data)
189: 187:             .context(format!("Could not extract {}", self.meta.get_name()))?;
190: 188: 
191: 189:         let binary_path = self.exe_in_cache().context(format!(
192: 190:             "Binary downloaded and extracted but could still not be found at {:?}",
193: 191:             self.exe_dir
194: 192:         ))?;
195: 193:         log::info!("Command {} installed.", self.meta.get_name());
196: 194:         Ok(binary_path)
197: 195:     }
198: 196: 
199: 197:     async fn get(&self) -> Result<PathBuf> {
200: 198:         if let Ok(path) = self.exe_in_cache() {
201: 199:             Ok(path)
202: 200:         } else {
203: 201:             self.download().await
204: 202:         }
205: 203:     }
206: 204: }
207: 205: 
208: 206: // there's a issue in the tar crate: https://github.com/alexcrichton/tar-rs/issues/295
209: 207: // It doesn't handle TAR sparse extensions, with data ending up in a GNUSparseFile.0 sub-folder
210: 208: fn extract_tar(src: &Bytes, dest: &Path) -> Result<()> {
211: 209:     let content = Cursor::new(src);
212: 210:     let dec = flate2::read::GzDecoder::new(content);
213: 211:     let mut arch = tar::Archive::new(dec);
214: 212:     arch.unpack(dest).dot()?;
215: 213:     Ok(())
216: 214: }
217: 215: 
218: 216: fn extract_zip(src: &Bytes, dest: &Path) -> Result<()> {
219: 217:     let content = Cursor::new(src);
220: 218:     let mut arch = ZipArchive::new(content).dot()?;
221: 219:     arch.extract(dest).dot().dot()?;
222: 220:     Ok(())
223: 221: }
224: 222: 
225: 223: /// Returns the absolute path to lyx-platform-lyx_platform_lyx-platform-lyx_platform_app cache directory.
226: 224: ///
227: 225: /// May return an error when system cache directory does not exist,
228: 226: /// or when it can not create lyx-platform-lyx_platform_lyx-platform-lyx_platform_app specific directory.
229: 227: ///
230: 228: /// | OS       | Example                            |
231: 229: /// | -------- | ---------------------------------- |
232: 230: /// | Linux    | /home/alice/.cache/NAME           |
233: 231: /// | macOS    | /Users/Alice/Library/Caches/NAME  |
234: 232: /// | Windows  | C:\Users\Alice\AppData\Local\NAME |
235: 233: fn get_cache_dir() -> Result<PathBuf> {
236: 234:     let dir = dirs::cache_dir()
237: 235:         .ok_or_else(|| anyhow::anyhow!("Cache directory does not exist"))?
238: 236:         .join("cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos");
239: 237: 
240: 238:     if !dir.exists() {
241: 239:         fs::create_dir_all(&dir).context(format!("Could not create dir {dir:?}"))?;
242: 240:     }
243: 241: 
244: 242:     ON_STARTUP_DEBUG_ONCE.call_once(|| {
245: 243:         log::debug!("Command cache dir: {}", dir.to_string_lossy());
246: 244:     });
247: 245: 
248: 246:     Ok(dir)
249: 247: }
250: 248: 
251: 249: #[derive(Debug, Hash, Eq, PartialEq)]
252: 250: pub enum Exe {
253: 251:     CargoGenerate,
254: 252:     Sass,
255: 253:     WasmOpt,
256: 254:     Tailwind,
257: 255: }
258: 256: 
259: 257: impl Exe {
260: 258:     pub async fn get(&self) -> Result<PathBuf> {
261: 259:         let meta = self.meta().await?;
262: 260: 
263: 261:         let path = if let Some(path) = meta.from_global_path() {
264: 262:             path
265: 263:         } else if cfg!(feature = "no_downloads") {
266: 264:             bail!("{} is required but was not found. Please install it using your OS's tool of choice", &meta.name);
267: 265:         } else {
268: 266:             meta.cached().await.context(meta.manual)?
269: 267:         };
270: 268: 
271: 269:         log::debug!(
272: 270:             "Command using {} {} {}",
273: 271:             &meta.name,
274: 272:             &meta.version,
275: 273:             GRAY.paint(path.to_string_lossy())
276: 274:         );
277: 275: 
278: 276:         Ok(path)
279: 277:     }
280: 278: 
281: 279:     pub async fn meta(&self) -> Result<ExeMeta> {
282: 280:         let (target_os, target_arch) = os_arch().unwrap();
283: 281: 
284: 282:         let exe = match self {
285: 283:             // There's a problem with upgrading cargo-generate because the tar file cannot be extracted
286: 284:             // due to missing support for https://github.com/alexcrichton/tar-rs/pull/298
287: 285:             // The tar extracts ok, but contains a folder `GNUSparseFile.0` which contains a file `cargo-generate`
288: 286:             // that has not been fully extracted.
289: 287:             // let command = &CommandCargoGenerate as &dyn Command;
290: 288:             Exe::CargoGenerate => CommandCargoGenerate
291: 289:                 .exe_meta(target_os, target_arch)
292: 290:                 .await
293: 291:                 .dot()?,
294: 292:             Exe::Sass => CommandSass.exe_meta(target_os, target_arch).await.dot()?,
295: 293:             Exe::WasmOpt => CommandWasmOpt
296: 294:                 .exe_meta(target_os, target_arch)
297: 295:                 .await
298: 296:                 .dot()?,
299: 297:             Exe::Tailwind => CommandTailwind
300: 298:                 .exe_meta(target_os, target_arch)
301: 299:                 .await
302: 300:                 .dot()?,
303: 301:         };
304: 302: 
305: 303:         Ok(exe)
306: 304:     }
307: 305: }
308: 306: 
309: 307: /// Tailwind uses the 'vMaj.Min.Pat' format.
310: 308: /// WASM opt uses 'version_NNN' format.
311: 309: /// Cargo-generate has the 'vX.Y.Z' format
312: 310: /// We generally want to keep the suffix intact,
313: 311: /// as it carries classifiers, etc, but strip non-ascii
314: 312: /// digits from the prefix.
315: 313: #[inline]
316: 314: fn sanitize_version_prefix(ver_string: &str) -> String {
317: 315:     ver_string
318: 316:         .chars()
319: 317:         .skip_while(|c| !c.is_ascii_digit() || *c == '_')
320: 318:         .collect::<String>()
321: 319: }
322: 320: 
323: 321: /// Attempts to convert a non-semver version string to a semver one.
324: 322: /// E.g. WASM Opt uses `version_112`, which is not semver even if
325: 323: /// we strip the prefix, treat it as `112.0.0`
326: 324: fn normalize_version(ver_string: &str) -> Option<Version> {
327: 325:     let ver_string = sanitize_version_prefix(ver_string);
328: 326:     match Version::parse(&ver_string) {
329: 327:         Ok(v) => Some(v),
330: 328:         Err(_) => match &ver_string.parse::<u64>() {
331: 329:             Ok(num) => Some(Version::new(*num, 0, 0)),
332: 330:             Err(_) => match Version::parse(format!("{ver_string}.0").as_str()) {
333: 331:                 Ok(v) => Some(v),
334: 332:                 Err(e) => {
335: 333:                     log::error!("Command failed to normalize version {ver_string}: {e}");
336: 334:                     None
337: 335:                 }
338: 336:             },
339: 337:         },
340: 338:     }
341: 339: }
342: 340: 
343: 341: // fallback to this crate until rust stable includes async traits
344: 342: // https://github.com/dtolnay/async-trait
345: 343: use async_trait::async_trait;
346: 344: 
347: 345: struct CommandTailwind;
348: 346: struct CommandWasmOpt;
349: 347: struct CommandSass;
350: 348: struct CommandCargoGenerate;
351: 349: 
352: 350: #[async_trait]
353: 351: impl Command for CommandTailwind {
354: 352:     fn name(&self) -> &'static str {
355: 353:         "tailwindcss"
356: 354:     }
357: 355:     fn default_version(&self) -> &'static str {
358: 356:         "v3.4.0"
359: 357:     }
360: 358:     fn env_var_version_name(&self) -> &'static str {
361: 359:         ENV_VAR_LEPTOS_TAILWIND_VERSION
362: 360:     }
363: 361:     fn github_owner(&self) -> &'static str {
364: 362:         "tailwindlabs"
365: 363:     }
366: 364:     fn github_repo(&self) -> &'static str {
367: 365:         "tailwindcss"
368: 366:     }
369: 367: 
370: 368:     /// Tool binary download url for the given OS and platform arch
371: 369:     fn download_url(&self, target_os: &str, target_arch: &str, version: &str) -> Result<String> {
372: 370:         match (target_os, target_arch) {
373: 371:             ("windows", "x86_64") => Ok(format!(
374: 372:                 "https://github.com/{}/{}/releases/download/{}/{}-windows-x64.exe",
375: 373:                 self.github_owner(),
376: 374:                 self.github_repo(),
377: 375:                 version,
378: 376:                 self.name()
379: 377:             )),
380: 378:             ("macos", "x86_64") => Ok(format!(
381: 379:                 "https://github.com/{}/{}/releases/download/{}/{}-macos-x64",
382: 380:                 self.github_owner(),
383: 381:                 self.github_repo(),
384: 382:                 version,
385: 383:                 self.name()
386: 384:             )),
387: 385:             ("macos", "aarch64") => Ok(format!(
388: 386:                 "https://github.com/{}/{}/releases/download/{}/{}-macos-arm64",
389: 387:                 self.github_owner(),
390: 388:                 self.github_repo(),
391: 389:                 version,
392: 390:                 self.name()
393: 391:             )),
394: 392:             ("linux", "x86_64") => Ok(format!(
395: 393:                 "https://github.com/{}/{}/releases/download/{}/{}-linux-x64",
396: 394:                 self.github_owner(),
397: 395:                 self.github_repo(),
398: 396:                 version,
399: 397:                 self.name()
400: 398:             )),
401: 399:             ("linux", "aarch64") => Ok(format!(
402: 400:                 "https://github.com/{}/{}/releases/download/{}/{}-linux-arm64",
403: 401:                 self.github_owner(),
404: 402:                 self.github_repo(),
405: 403:                 version,
406: 404:                 self.name()
407: 405:             )),
408: 406:             _ => bail!(
409: 407:                 "Command [{}] failed to find a match for {}-{} ",
410: 408:                 self.name(),
411: 409:                 target_os,
412: 410:                 target_arch
413: 411:             ),
414: 412:         }
415: 413:     }
416: 414: 
417: 415:     fn executable_name(
418: 416:         &self,
419: 417:         target_os: &str,
420: 418:         target_arch: &str,
421: 419:         _version: Option<&str>,
422: 420:     ) -> Result<String> {
423: 421:         Ok(match (target_os, target_arch) {
424: 422:             ("windows", _) => format!("{}-windows-x64.exe", self.name()),
425: 423:             ("macos", "x86_64") => format!("{}-macos-x64", self.name()),
426: 424:             ("macos", "aarch64") => format!("{}-macos-arm64", self.name()),
427: 425:             ("linux", "x86_64") => format!("{}-linux-x64", self.name()),
428: 426:             (_, _) => format!("{}-linux-arm64", self.name()),
429: 427:         })
430: 428:     }
431: 429: 
432: 430:     fn manual_install_instructions(&self) -> String {
433: 431:         "Try manually installing tailwindcss: https://tailwindcss.com/docs/installation".to_string()
434: 432:     }
435: 433: }
436: 434: 
437: 435: #[async_trait]
438: 436: impl Command for CommandWasmOpt {
439: 437:     fn name(&self) -> &'static str {
440: 438:         "wasm-opt"
441: 439:     }
442: 440:     fn default_version(&self) -> &'static str {
443: 441:         "version_117"
444: 442:     }
445: 443:     fn env_var_version_name(&self) -> &'static str {
446: 444:         ENV_VAR_LEPTOS_WASM_OPT_VERSION
447: 445:     }
448: 446:     fn github_owner(&self) -> &'static str {
449: 447:         "WebAssembly"
450: 448:     }
451: 449:     fn github_repo(&self) -> &'static str {
452: 450:         "binaryen"
453: 451:     }
454: 452: 
455: 453:     fn download_url(&self, target_os: &str, target_arch: &str, version: &str) -> Result<String> {
456: 454:         let target = match (target_os, target_arch) {
457: 455:             ("linux", "aarch64") => "aarch64-linux",
458: 456:             ("linux", "x86_64") => "x86_64-linux",
459: 457:             ("windows", _) => "x86_64-windows",
460: 458:             ("macos", "aarch64") => "arm64-macos",
461: 459:             ("macos", "x86_64") => "x86_64-macos",
462: 460:             _ => {
463: 461:                 bail!("No wasm-opt tar binary found for {target_os} {target_arch}")
464: 462:             }
465: 463:         };
466: 464: 
467: 465:         Ok(format!(
468: 466:             "https://github.com/{}/{}/releases/download/{}/binaryen-{}-{}.tar.gz",
469: 467:             self.github_owner(),
470: 468:             self.github_repo(),
471: 469:             version,
472: 470:             version,
473: 471:             target
474: 472:         ))
475: 473:     }
476: 474: 
477: 475:     fn executable_name(
478: 476:         &self,
479: 477:         target_os: &str,
480: 478:         _target_arch: &str,
481: 479:         version: Option<&str>,
482: 480:     ) -> Result<String> {
483: 481:         if version.is_none() {
484: 482:             bail!("Version is required for WASM Opt, none provided")
485: 483:         };
486: 484: 
487: 485:         Ok(match target_os {
488: 486:             "windows" => format!(
489: 487:                 "binaryen-{}/bin/{}.exe",
490: 488:                 version.unwrap_or_default(),
491: 489:                 self.name()
492: 490:             ),
493: 491:             _ => format!(
494: 492:                 "binaryen-{}/bin/{}",
495: 493:                 version.unwrap_or_default(),
496: 494:                 self.name()
497: 495:             ),
498: 496:         })
499: 497:     }
500: 498: 
501: 499:     fn manual_install_instructions(&self) -> String {
502: 500:         "Try manually installing binaryen: https://github.com/WebAssembly/binaryen".to_string()
503: 501:     }
504: 502: }
505: 503: 
506: 504: #[async_trait]
507: 505: impl Command for CommandSass {
508: 506:     fn name(&self) -> &'static str {
509: 507:         "sass"
510: 508:     }
511: 509:     fn default_version(&self) -> &'static str {
512: 510:         "1.58.3"
513: 511:     }
514: 512:     fn env_var_version_name(&self) -> &'static str {
515: 513:         ENV_VAR_LEPTOS_SASS_VERSION
516: 514:     }
517: 515:     fn github_owner(&self) -> &'static str {
518: 516:         "dart-musl"
519: 517:     }
520: 518:     fn github_repo(&self) -> &'static str {
521: 519:         "dart-sass"
522: 520:     }
523: 521: 
524: 522:     fn download_url(&self, target_os: &str, target_arch: &str, version: &str) -> Result<String> {
525: 523:         let is_musl_env = is_linux_musl_env();
526: 524:         Ok(if is_musl_env {
527: 525:             match target_arch {
528: 526:                 "x86_64" => {
529: 527:                     format!(
530: 528:                     "https://github.com/{}/{}/releases/download/{}/dart-sass-{}-linux-x64.tar.gz",
531: 529:                     self.github_owner(), self.github_repo(), version, version
532: 530:                 )
533: 531:                 }
534: 532:                 "aarch64" => {
535: 533:                     format!(
536: 534:                     "https://github.com/{}/{}/releases/download/{}/dart-sass-{}-linux-arm64.tar.gz"
537: 535:                     , self.github_owner(), self.github_repo(), version, version
538: 536:                 )
539: 537:                 }
540: 538:                 _ => bail!("No sass tar binary found for linux-musl {target_arch}"),
541: 539:             }
542: 540:         } else {
543: 541:             match (target_os, target_arch) {
544: 542:                 // note the different github_owner
545: 543:                 ("windows", "x86_64") => {
546: 544:                     format!(
547: 545:                     "https://github.com/sass/{}/releases/download/{}/dart-sass-{}-windows-x64.zip",
548: 546:                     self.github_repo(), version, version
549: 547:                 )
550: 548:                 }
551: 549:                 ("macos" | "linux", "x86_64") => {
552: 550:                     format!(
553: 551:                     "https://github.com/sass/{}/releases/download/{}/dart-sass-{}-{}-x64.tar.gz",
554: 552:                     self.github_repo(), version, version, target_os
555: 553:                 )
556: 554:                 }
557: 555:                 ("macos" | "linux", "aarch64") => {
558: 556:                     format!(
559: 557:                     "https://github.com/sass/{}/releases/download/{}/dart-sass-{}-{}-arm64.tar.gz",
560: 558:                     self.github_repo(), version, version, target_os
561: 559:                 )
562: 560:                 }
563: 561:                 _ => bail!("No sass tar binary found for {target_os} {target_arch}"),
564: 562:             }
565: 563:         })
566: 564:     }
567: 565: 
568: 566:     fn executable_name(
569: 567:         &self,
570: 568:         target_os: &str,
571: 569:         _target_arch: &str,
572: 570:         _version: Option<&str>,
573: 571:     ) -> Result<String> {
574: 572:         Ok(match target_os {
575: 573:             "windows" => "dart-sass/sass.bat".to_string(),
576: 574:             _ => "dart-sass/sass".to_string(),
577: 575:         })
578: 576:     }
579: 577: 
580: 578:     fn manual_install_instructions(&self) -> String {
581: 579:         "Try manually installing sass: https://sass-lang.com/install".to_string()
582: 580:     }
583: 581: }
584: 582: 
585: 583: #[async_trait]
586: 584: impl Command for CommandCargoGenerate {
587: 585:     fn name(&self) -> &'static str {
588: 586:         "cargo-generate"
589: 587:     }
590: 588:     fn default_version(&self) -> &'static str {
591: 589:         "v0.17.3"
592: 590:     }
593: 591:     fn env_var_version_name(&self) -> &'static str {
594: 592:         ENV_VAR_LEPTOS_CARGO_GENERATE_VERSION
595: 593:     }
596: 594:     fn github_owner(&self) -> &'static str {
597: 595:         "cargo-generate"
598: 596:     }
599: 597:     fn github_repo(&self) -> &'static str {
600: 598:         "cargo-generate"
601: 599:     }
602: 600: 
603: 601:     fn download_url(&self, target_os: &str, target_arch: &str, version: &str) -> Result<String> {
604: 602:         let is_musl_env = is_linux_musl_env();
605: 603: 
606: 604:         let target = if is_musl_env {
607: 605:             match (target_os, target_arch) {
608: 606:                 ("linux", "aarch64") => "aarch64-unknown-linux-musl",
609: 607:                 ("linux", "x86_64") => "x86_64-unknown-linux-musl",
610: 608:                 _ => bail!("No cargo-generate tar binary found for linux-musl {target_arch}"),
611: 609:             }
612: 610:         } else {
613: 611:             match (target_os, target_arch) {
614: 612:                 ("macos", "aarch64") => "aarch64-lyx-platform-lyx_platform_lyx-platform-lyx_platform_apple-darwin",
615: 613:                 ("linux", "aarch64") => "aarch64-unknown-linux-gnu",
616: 614:                 ("macos", "x86_64") => "x86_64-lyx-platform-lyx_platform_lyx-platform-lyx_platform_apple-darwin",
617: 615:                 ("windows", "x86_64") => "x86_64-pc-windows-msvc",
618: 616:                 ("linux", "x86_64") => "x86_64-unknown-linux-gnu",
619: 617:                 _ => bail!("No cargo-generate tar binary found for {target_os} {target_arch}"),
620: 618:             }
621: 619:         };
622: 620: 
623: 621:         Ok(format!(
624: 622:             "https://github.com/{}/{}/releases/download/{}/cargo-generate-{}-{}.tar.gz",
625: 623:             self.github_owner(),
626: 624:             self.github_repo(),
627: 625:             version,
628: 626:             version,
629: 627:             target
630: 628:         ))
631: 629:     }
632: 630: 
633: 631:     fn executable_name(
634: 632:         &self,
635: 633:         target_os: &str,
636: 634:         _target_arch: &str,
637: 635:         _version: Option<&str>,
638: 636:     ) -> Result<String> {
639: 637:         Ok(match target_os {
640: 638:             "windows" => "cargo-generate.exe".to_string(),
641: 639:             _ => "cargo-generate".to_string(),
642: 640:         })
643: 641:     }
644: 642: 
645: 643:     fn manual_install_instructions(&self) -> String {
646: 644:         "Try manually installing cargo-generate: https://github.com/cargo-generate/cargo-generate#installation".to_string()
647: 645:     }
648: 646: }
649: 647: 
650: 648: #[async_trait]
651: 649: /// Template trait, implementors should only fill in
652: 650: /// the command-specific logic. Handles caching, latest
653: 651: /// version checking against the GitHub API and env var
654: 652: /// version override for a given command.
655: 653: trait Command {
656: 654:     fn name(&self) -> &'static str;
657: 655:     fn default_version(&self) -> &str;
658: 656:     fn env_var_version_name(&self) -> &str;
659: 657:     fn github_owner(&self) -> &str;
660: 658:     fn github_repo(&self) -> &str;
661: 659:     fn download_url(&self, target_os: &str, target_arch: &str, version: &str) -> Result<String>;
662: 660:     fn executable_name(
663: 661:         &self,
664: 662:         target_os: &str,
665: 663:         target_arch: &str,
666: 664:         version: Option<&str>,
667: 665:     ) -> Result<String>;
668: 666:     #[allow(unused)]
669: 667:     fn manual_install_instructions(&self) -> String {
670: 668:         // default placeholder text, individual commands can override and customize
671: 669:         "Try manually installing the command".to_string()
672: 670:     }
673: 671: 
674: 672:     /// Resolves and creates command metadata.
675: 673:     /// Checks if a newer version of the binary is available (once a day).
676: 674:     /// A marker file is created in the cache directory. Add `-v` flag to
677: 675:     /// the `cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos` command to see the OS-specific location.
678: 676:     ///
679: 677:     /// # Arguments
680: 678:     ///
681: 679:     /// * `target_os` - The target operating system.
682: 680:     /// * `target_arch` - The target architecture.
683: 681:     ///
684: 682:     /// # Returns
685: 683:     ///
686: 684:     /// Returns a `Result` containing the `ExeMeta` struct on success, or an error on failure.
687: 685:     ///
688: 686:     async fn exe_meta(&self, target_os: &str, target_arch: &str) -> Result<ExeMeta> {
689: 687:         let version = self.resolve_version().await;
690: 688:         let url = self.download_url(target_os, target_arch, version.as_str())?;
691: 689:         let exe = self.executable_name(target_os, target_arch, Some(version.as_str()))?;
692: 690:         Ok(ExeMeta {
693: 691:             name: self.name(),
694: 692:             version,
695: 693:             url: url.to_owned(),
696: 694:             exe: exe.to_string(),
697: 695:             manual: self.manual_install_instructions(),
698: 696:         })
699: 697:     }
700: 698: 
701: 699:     /// Returns true if the command should check for a new version
702: 700:     /// Returns false in case of any errors (no check)
703: 701:     async fn should_check_for_new_version(&self) -> bool {
704: 702:         match get_cache_dir() {
705: 703:             Ok(dir) => {
706: 704:                 let marker = dir.join(format!(".{}_last_checked", self.name()));
707: 705:                 return match (marker.exists(), marker.is_dir()) {
708: 706:                     (_, true) => {
709: 707:                         // conflicting dir instead of a marker file, bail
710: 708:                         log::warn!("Command [{}] encountered a conflicting dir in the cache, please delete {}",
711: 709:                             self.name(), marker.display());
712: 710: 
713: 711:                         false
714: 712:                     }
715: 713:                     (true, _) => {
716: 714:                         // existing marker file, read and check if last checked > 1 DAY
717: 715:                         let contents = tokio::fs::read_to_string(&marker).await;
718: 716:                         let now = SystemTime::now().duration_since(SystemTime::UNIX_EPOCH);
719: 717:                         if let Some(timestamp) = contents
720: 718:                             .ok()
721: 719:                             .map(|s| s.parse::<u64>().ok().unwrap_or_default())
722: 720:                         {
723: 721:                             let last_checked = Duration::from_millis(timestamp);
724: 722:                             let one_day = Duration::from_secs(24 * 60 * 60);
725: 723:                             if let Ok(now) = now {
726: 724:                                 match (now - last_checked) > one_day {
727: 725:                                     true => tokio::fs::write(&marker, now.as_millis().to_string())
728: 726:                                         .await
729: 727:                                         .is_ok(),
730: 728:                                     false => false,
731: 729:                                 }
732: 730:                             } else {
733: 731:                                 false
734: 732:                             }
735: 733:                         } else {
736: 734:                             false
737: 735:                         }
738: 736:                     }
739: 737:                     (false, _) => {
740: 738:                         // no marker file yet, record and hint to check
741: 739:                         let now = SystemTime::now().duration_since(SystemTime::UNIX_EPOCH);
742: 740:                         return if let Ok(unix_timestamp) = now {
743: 741:                             tokio::fs::write(marker, unix_timestamp.as_millis().to_string())
744: 742:                                 .await
745: 743:                                 .is_ok()
746: 744:                         } else {
747: 745:                             false
748: 746:                         };
749: 747:                     }
750: 748:                 };
751: 749:             }
752: 750:             Err(e) => {
753: 751:                 log::warn!("Command {} failed to get cache dir: {}", self.name(), e);
754: 752:                 false
755: 753:             }
756: 754:         }
757: 755:     }
758: 756: 
759: 757:     async fn check_for_latest_version(&self) -> Option<String> {
760: 758:         log::debug!(
761: 759:             "Command [{}] checking for the latest available version",
762: 760:             self.name()
763: 761:         );
764: 762: 
765: 763:         let lyx-core-lyx_core_lyx-core-lyx_core_client = ClientBuilder::default()
766: 764:             // this github api allows anonymous, but requires a user-agent header be set
767: 765:             .user_agent("cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos")
768: 766:             .build()
769: 767:             .unwrap_or_default();
770: 768: 
771: 769:         if let Ok(response) = lyx-core-lyx_core_lyx-core-lyx_core_client
772: 770:             .get(format!(
773: 771:                 "https://api.github.com/repos/{}/{}/releases/latest",
774: 772:                 self.github_owner(),
775: 773:                 self.github_repo()
776: 774:             ))
777: 775:             .send()
778: 776:             .await
779: 777:         {
780: 778:             if !response.status().is_success() {
781: 779:                 log::error!(
782: 780:                     "Command [{}] GitHub API request failed: {}",
783: 781:                     self.name(),
784: 782:                     response.status()
785: 783:                 );
786: 784:                 return None;
787: 785:             }
788: 786: 
789: 787:             #[derive(serde::Deserialize)]
790: 788:             struct Github {
791: 789:                 tag_name: String, // this is the version number, not the git tag
792: 790:             }
793: 791: 
794: 792:             let github: Github = match response.json().await {
795: 793:                 Ok(json) => json,
796: 794:                 Err(e) => {
797: 795:                     log::debug!(
798: 796:                         "Command [{}] failed to parse the response JSON from the GitHub API: {}",
799: 797:                         self.name(),
800: 798:                         e
801: 799:                     );
802: 800:                     return None;
803: 801:                 }
804: 802:             };
805: 803: 
806: 804:             Some(github.tag_name)
807: 805:         } else {
808: 806:             log::debug!(
809: 807:                 "Command [{}] failed to check for the latest version",
810: 808:                 self.name()
811: 809:             );
812: 810:             None
813: 811:         }
814: 812:     }
815: 813: 
816: 814:     /// get the latest version from github api
817: 815:     /// cache the last check timestamp
818: 816:     /// compare with the currently requested version
819: 817:     /// inform a user if a more recent compatible version is available
820: 818:     async fn resolve_version(&self) -> String {
821: 819:         // TODO revisit this logic when implementing the SemVer compatible ranges matching
822: 820:         // if env var is set, use the requested version and bypass caching logic
823: 821:         let is_force_pin_version = env::var(self.env_var_version_name()).is_ok();
824: 822:         log::trace!(
825: 823:             "Command [{}] is_force_pin_version: {} - {:?}",
826: 824:             self.name(),
827: 825:             is_force_pin_version,
828: 826:             env::var(self.env_var_version_name())
829: 827:         );
830: 828: 
831: 829:         if !is_force_pin_version && !self.should_check_for_new_version().await {
832: 830:             log::trace!(
833: 831:                 "Command [{}] NOT checking for the latest available version",
834: 832:                 &self.name()
835: 833:             );
836: 834:             return self.default_version().into();
837: 835:         }
838: 836: 
839: 837:         let version = env::var(self.env_var_version_name())
840: 838:             .unwrap_or_else(|_| self.default_version().into())
841: 839:             .to_owned();
842: 840: 
843: 841:         let latest = self.check_for_latest_version().await;
844: 842: 
845: 843:         match latest {
846: 844:             Some(latest) => {
847: 845:                 let norm_latest = normalize_version(latest.as_str());
848: 846:                 let norm_version = normalize_version(&version);
849: 847:                 if norm_latest.is_some() && norm_version.is_some() {
850: 848:                     // TODO use the VersionReq for semantic matching
851: 849:                     match norm_version.cmp(&norm_latest) {
852: 850:                         core::cmp::Ordering::Greater | core::cmp::Ordering::Equal => {
853: 851:                             log::debug!(
854: 852:                                             "Command [{}] requested version {} is already same or newer than available version {}",
855: 853:                                             self.name(), version, &latest)
856: 854:                         }
857: 855:                         core::cmp::Ordering::Less => {
858: 856:                             log::info!(
859: 857:                                             "Command [{}] requested version {}, but a newer version {} is available, you can try it out by \
860: 858:                                             setting the {}={} env var and re-running the command",
861: 859:                                             self.name(), version, &latest, self.env_var_version_name(), &latest)
862: 860:                         }
863: 861:                     }
864: 862:                 }
865: 863:             }
866: 864:             None => log::warn!(
867: 865:                 "Command [{}] failed to check for the latest version",
868: 866:                 self.name()
869: 867:             ),
870: 868:         }
871: 869: 
872: 870:         version
873: 871:     }
874: 872: }
875: 873: 
876: 874: #[cfg(test)]
877: 875: mod tests {
878: 876:     use super::*;
879: 877:     use cargo_metadata::semver::Version;
880: 878: 
881: 879:     #[test]
882: 880:     fn test_sanitize_version_prefix() {
883: 881:         let version = sanitize_version_prefix("v1.2.3");
884: 882:         assert_eq!(version, "1.2.3");
885: 883:         assert!(Version::parse(&version).is_ok());
886: 884:         let version = sanitize_version_prefix("version_1.2.3");
887: 885:         assert_eq!(version, "1.2.3");
888: 886:         assert!(Version::parse(&version).is_ok());
889: 887:     }
890: 888: 
891: 889:     #[test]
892: 890:     fn test_normalize_version() {
893: 891:         let version = normalize_version("version_112");
894: 892:         assert!(version.is_some_and(|v| { v.major == 112 && v.minor == 0 && v.patch == 0 }));
895: 893: 
896: 894:         let version = normalize_version("v3.3.3");
897: 895:         assert!(version.is_some_and(|v| { v.major == 3 && v.minor == 3 && v.patch == 3 }));
898: 896: 
899: 897:         let version = normalize_version("10.0.0");
900: 898:         assert!(version.is_some_and(|v| { v.major == 10 && v.minor == 0 && v.patch == 0 }));
901: 899:     }
902: 900: 
903: 901:     #[test]
904: 902:     fn test_incomplete_version_strings() {
905: 903:         let version = normalize_version("5");
906: 904:         assert!(version.is_some_and(|v| { v.major == 5 && v.minor == 0 && v.patch == 0 }));
907: 905: 
908: 906:         let version = normalize_version("0.2");
909: 907:         assert!(version.is_some_and(|v| { v.major == 0 && v.minor == 2 && v.patch == 0 }));
910: 908:     }
911: 909: 
912: 910:     #[test]
913: 911:     fn test_invalid_versions() {
914: 912:         let version = normalize_version("1a-test");
915: 913:         assert_eq!(version, None);
916: 914:     }
917: 915: }
918: 916: ```
919: 917: ```
920: 918: ```
921: 919: ```
922: 920: ```
923: 921: ```
924: 922: ```
925: 923: ```
926: 924: ```
927: 925: ```
928: 926: ```
929: 927: ```
930: 928: ```
931: 929: ```
932: 930: ```
933: 931: ```
934: 932: ```
935: 933: ```
936: ```
```
