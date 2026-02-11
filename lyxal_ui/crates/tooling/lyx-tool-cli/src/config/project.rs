### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\project.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-cli\src\config\project.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_cli\src\config\project.rs
38: 36: ```rust
39: 37: use crate::config::hash_file::HashFile;
40: 38: use crate::{
41: 39:     config::lib_package::LibPackage,
42: 40:     ext::{
43: 41:         anyhow::{bail, ensure, Result},
44: 42:         PackageExt, PathBufExt, PathExt,
45: 43:     },
46: 44:     logger::GRAY,
47: 45:     service::site::Site,
48: 46: };
49: 47: use camino::{Utf8Path, Utf8PathBuf};
50: 48: use cargo_metadata::{Metadata, Package};
51: 49: use serde::Deserialize;
52: 50: use std::{fmt::Debug, net::SocketAddr, sync::Arc};
53: 51: 
54: 52: use super::{
55: 53:     assets::AssetsConfig,
56: 54:     bin_package::BinPackage,
57: 55:     cli::Opts,
58: 56:     dotenvs::{load_dotenvs, overlay_env},
59: 57:     end2end::End2EndConfig,
60: 58:     style::StyleConfig,
61: 59: };
62: 60: 
63: 61: /// If the site root path starts with this marker, the marker should be replaced with the Cargo target directory
64: 62: const CARGO_TARGET_DIR_MARKER: &str = "CARGO_TARGET_DIR";
65: 63: /// If the site root path starts with this marker, the marker should be replaced with the Cargo target directory
66: 64: const CARGO_BUILD_TARGET_DIR_MARKER: &str = "CARGO_BUILD_TARGET_DIR";
67: 65: 
68: 66: pub struct Project {
69: 67:     /// absolute path to the working dir
70: 68:     pub working_dir: Utf8PathBuf,
71: 69:     pub name: String,
72: 70:     pub lib: LibPackage,
73: 71:     pub bin: BinPackage,
74: 72:     pub style: StyleConfig,
75: 73:     pub watch: bool,
76: 74:     pub release: bool,
77: 75:     pub precompress: bool,
78: 76:     pub hot_reload: bool,
79: 77:     pub wasm_debug: bool,
80: 78:     pub site: Arc<Site>,
81: 79:     pub end2end: Option<End2EndConfig>,
82: 80:     pub assets: Option<AssetsConfig>,
83: 81:     pub js_dir: Utf8PathBuf,
84: 82:     pub watch_additional_files: Vec<Utf8PathBuf>,
85: 83:     pub hash_file: HashFile,
86: 84:     pub hash_files: bool,
87: 85:     pub js_minify: bool,
88: 86: }
89: 87: 
90: 88: impl Debug for Project {
91: 89:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
92: 90:         f.debug_struct("Project")
93: 91:             .field("name", &self.name)
94: 92:             .field("lib", &self.lib)
95: 93:             .field("bin", &self.bin)
96: 94:             .field("style", &self.style)
97: 95:             .field("watch", &self.watch)
98: 96:             .field("release", &self.release)
99: 97:             .field("precompress", &self.precompress)
100: 98:             .field("js_minify", &self.js_minify)
101: 99:             .field("hot_reload", &self.hot_reload)
102: 100:             .field("site", &self.site)
103: 101:             .field("end2end", &self.end2end)
104: 102:             .field("assets", &self.assets)
105: 103:             .finish_non_exhaustive()
106: 104:     }
107: 105: }
108: 106: 
109: 107: impl Project {
110: 108:     pub fn resolve(
111: 109:         cli: &Opts,
112: 110:         cwd: &Utf8Path,
113: 111:         metadata: &Metadata,
114: 112:         watch: bool,
115: 113:         bin_args: Option<&[String]>,
116: 114:     ) -> Result<Vec<Arc<Project>>> {
117: 115:         let projects = ProjectDefinition::parse(metadata)?;
118: 116: 
119: 117:         let mut resolved = Vec::new();
120: 118:         for (project, mut config) in projects {
121: 119:             if config.output_name.is_empty() {
122: 120:                 config.output_name = project.name.to_string();
123: 121:             }
124: 122: 
125: 123:             let lib = LibPackage::resolve(cli, metadata, &project, &config)?;
126: 124: 
127: 125:             let js_dir = config
128: 126:                 .js_dir
129: 127:                 .clone()
130: 128:                 .unwrap_or_else(|| Utf8PathBuf::from("src"));
131: 129: 
132: 130:             let watch_additional_files = config.watch_additional_files.clone().unwrap_or_default();
133: 131: 
134: 132:             let bin = BinPackage::resolve(cli, metadata, &project, &config, bin_args)?;
135: 133: 
136: 134:             // If there's more than 1 workspace member, we're a workspace. Probably
137: 135:             let is_workspace = metadata.workspace_members.len() > 1;
138: 136:             log::debug!("Detected Workspace: {is_workspace}");
139: 137:             let hash_file = match is_workspace {
140: 138:                 true => HashFile::new(
141: 139:                     Some(&metadata.workspace_root),
142: 140:                     &bin,
143: 141:                     config.hash_file_name.as_ref(),
144: 142:                 ),
145: 143:                 false => HashFile::new(None, &bin, config.hash_file_name.as_ref()),
146: 144:             };
147: 145: 
148: 146:             let proj = Project {
149: 147:                 working_dir: metadata.workspace_root.clone(),
150: 148:                 name: project.name.clone(),
151: 149:                 lib,
152: 150:                 bin,
153: 151:                 style: StyleConfig::new(&config)?,
154: 152:                 watch,
155: 153:                 release: cli.release,
156: 154:                 precompress: cli.precompress,
157: 155:                 hot_reload: cli.hot_reload,
158: 156:                 wasm_debug: cli.wasm_debug,
159: 157:                 site: Arc::new(Site::new(&config)),
160: 158:                 end2end: End2EndConfig::resolve(&config),
161: 159:                 assets: AssetsConfig::resolve(&config),
162: 160:                 js_dir,
163: 161:                 watch_additional_files,
164: 162:                 hash_file,
165: 163:                 hash_files: config.hash_files,
166: 164:                 js_minify: cli.release && cli.js_minify && config.js_minify,
167: 165:             };
168: 166:             resolved.push(Arc::new(proj));
169: 167:         }
170: 168: 
171: 169:         let projects_in_cwd = resolved
172: 170:             .iter()
173: 171:             .filter(|p| p.bin.abs_dir.starts_with(cwd) || p.lib.abs_dir.starts_with(cwd))
174: 172:             .collect::<Vec<_>>();
175: 173: 
176: 174:         if projects_in_cwd.len() == 1 {
177: 175:             Ok(vec![projects_in_cwd[0].clone()])
178: 176:         } else {
179: 177:             Ok(resolved)
180: 178:         }
181: 179:     }
182: 180: 
183: 181:     /// env vars to use when running external command
184: 182:     pub fn to_envs(&self) -> Vec<(&'static str, String)> {
185: 183:         let mut vec = vec![
186: 184:             ("LEPTOS_OUTPUT_NAME", self.lib.output_name.to_string()),
187: 185:             ("LEPTOS_SITE_ROOT", self.site.root_dir.to_string()),
188: 186:             ("LEPTOS_SITE_PKG_DIR", self.site.pkg_dir.to_string()),
189: 187:             ("LEPTOS_SITE_ADDR", self.site.addr.to_string()),
190: 188:             ("LEPTOS_RELOAD_PORT", self.site.reload.port().to_string()),
191: 189:             ("LEPTOS_LIB_DIR", self.lib.rel_dir.to_string()),
192: 190:             ("LEPTOS_BIN_DIR", self.bin.rel_dir.to_string()),
193: 191:             ("LEPTOS_JS_MINIFY", self.js_minify.to_string()),
194: 192:             ("LEPTOS_HASH_FILES", self.hash_files.to_string()),
195: 193:         ];
196: 194:         if self.hash_files {
197: 195:             vec.push(("LEPTOS_HASH_FILE_NAME", self.hash_file.rel.to_string()));
198: 196:         }
199: 197:         if self.watch {
200: 198:             vec.push(("LEPTOS_WATCH", "true".to_string()))
201: 199:         }
202: 200:         vec
203: 201:     }
204: 202: }
205: 203: 
206: 204: #[derive(Deserialize, Debug)]
207: 205: #[serde(rename_all = "kebab-case")]
208: 206: pub struct ProjectConfig {
209: 207:     #[serde(default)]
210: 208:     pub output_name: String,
211: 209:     #[serde(default = "default_site_addr")]
212: 210:     pub site_addr: SocketAddr,
213: 211:     #[serde(default = "default_site_root")]
214: 212:     pub site_root: Utf8PathBuf,
215: 213:     #[serde(default = "default_pkg_dir")]
216: 214:     pub site_pkg_dir: Utf8PathBuf,
217: 215:     pub style_file: Option<Utf8PathBuf>,
218: 216:     /// text file where the hashes of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend files are stored
219: 217:     pub hash_file_name: Option<Utf8PathBuf>,
220: 218:     /// whether to hash the lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend files content and add them to the file names
221: 219:     #[serde(default = "default_hash_files")]
222: 220:     pub hash_files: bool,
223: 221:     pub tailwind_input_file: Option<Utf8PathBuf>,
224: 222:     pub tailwind_config_file: Option<Utf8PathBuf>,
225: 223:     /// assets dir. content will be copied to the target/site dir
226: 224:     pub assets_dir: Option<Utf8PathBuf>,
227: 225:     /// js dir. changes triggers rebuilds.
228: 226:     pub js_dir: Option<Utf8PathBuf>,
229: 227:     #[serde(default = "default_js_minify")]
230: 228:     pub js_minify: bool,
231: 229:     /// additional files to watch. changes triggers rebuilds.
232: 230:     pub watch_additional_files: Option<Vec<Utf8PathBuf>>,
233: 231:     #[serde(default = "default_reload_port")]
234: 232:     pub reload_port: u16,
235: 233:     /// command for launching end-2-end integration tests
236: 234:     pub end2end_cmd: Option<String>,
237: 235:     /// the dir used when launching end-2-end integration tests
238: 236:     pub end2end_dir: Option<Utf8PathBuf>,
239: 237:     #[serde(default = "default_browserquery")]
240: 238:     pub browserquery: String,
241: 239:     /// the bin target to use for building the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
242: 240:     #[serde(default)]
243: 241:     pub bin_target: String,
244: 242:     /// the bin output target triple to use for building the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
245: 243:     pub bin_target_triple: Option<String>,
246: 244:     /// the directory to put the generated lyx-platform-lyx_platform_lyx-platform-lyx_platform_server artifacts
247: 245:     pub bin_target_dir: Option<String>,
248: 246:     /// the command to run instead of "cargo" when building the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
249: 247:     pub bin_cargo_command: Option<String>,
250: 248:     /// cargo flags to pass to cargo when running the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server. Overriden by bin_cargo_command
251: 249:     pub bin_cargo_args: Option<Vec<String>>,
252: 250:     /// An optional override, if you've changed the name of your bin file in your project you'll need to set it here as well.
253: 251:     pub bin_exe_name: Option<String>,
254: 252:     #[serde(default)]
255: 253:     pub features: Vec<String>,
256: 254:     #[serde(default)]
257: 255:     pub lib_features: Vec<String>,
258: 256:     #[serde(default)]
259: 257:     pub lib_default_features: bool,
260: 258:     /// cargo flags to pass to cargo when building the WASM lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend
261: 259:     pub lib_cargo_args: Option<Vec<String>>,
262: 260:     #[serde(default)]
263: 261:     pub bin_features: Vec<String>,
264: 262:     #[serde(default)]
265: 263:     pub bin_default_features: bool,
266: 264: 
267: 265:     #[serde(skip)]
268: 266:     pub config_dir: Utf8PathBuf,
269: 267:     #[serde(skip)]
270: 268:     pub tmp_dir: Utf8PathBuf,
271: 269: 
272: 270:     /// Deprecated. Keeping this here to warn users to remove it in case they have it in their config.
273: 271:     #[deprecated = "This option is deprecated since cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos 0.2.3 (when it became unconditionally enabled). You may remove it from your config."]
274: 272:     pub separate_front_target_dir: Option<bool>,
275: 273: 
276: 274:     // Profiles
277: 275:     pub lib_profile_dev: Option<String>,
278: 276:     pub lib_profile_release: Option<String>,
279: 277:     pub bin_profile_dev: Option<String>,
280: 278:     pub bin_profile_release: Option<String>,
281: 279: }
282: 280: 
283: 281: impl ProjectConfig {
284: 282:     fn parse(
285: 283:         dir: &Utf8Path,
286: 284:         metadata: &serde_json::Value,
287: 285:         cargo_metadata: &Metadata,
288: 286:     ) -> Result<Self> {
289: 287:         let mut conf: ProjectConfig = serde_json::from_value(metadata.clone())?;
290: 288:         conf.config_dir = dir.to_path_buf();
291: 289:         conf.tmp_dir = cargo_metadata.target_directory.join("tmp");
292: 290:         let dotenvs = load_dotenvs(dir)?;
293: 291:         overlay_env(&mut conf, dotenvs)?;
294: 292:         if conf.site_root == "/"
295: 293:             || conf.site_root == "."
296: 294:             || conf.site_root == CARGO_TARGET_DIR_MARKER
297: 295:             || conf.site_root == CARGO_BUILD_TARGET_DIR_MARKER
298: 296:         {
299: 297:             bail!(
300: 298:                 "site-root cannot be '{}'. All the content is erased when building the site.",
301: 299:                 conf.site_root
302: 300:             );
303: 301:         }
304: 302:         if conf.site_root.starts_with(CARGO_TARGET_DIR_MARKER) {
305: 303:             conf.site_root = {
306: 304:                 let mut path = cargo_metadata.target_directory.clone();
307: 305:                 // unwrap() should be safe because we just checked
308: 306:                 let sub = conf
309: 307:                     .site_root
310: 308:                     .unbase(CARGO_TARGET_DIR_MARKER.into())
311: 309:                     .unwrap();
312: 310:                 path.push(sub);
313: 311:                 path
314: 312:             };
315: 313:         }
316: 314:         if conf.site_root.starts_with(CARGO_BUILD_TARGET_DIR_MARKER) {
317: 315:             conf.site_root = {
318: 316:                 let mut path = cargo_metadata.target_directory.clone();
319: 317:                 // unwrap() should be safe because we just checked
320: 318:                 let sub = conf
321: 319:                     .site_root
322: 320:                     .unbase(CARGO_BUILD_TARGET_DIR_MARKER.into())
323: 321:                     .unwrap();
324: 322:                 path.push(sub);
325: 323:                 path
326: 324:             };
327: 325:         }
328: 326:         if conf.site_addr.port() == conf.reload_port {
329: 327:             bail!(
330: 328:                 "The site-addr port and reload-port cannot be the same: {}",
331: 329:                 conf.reload_port
332: 330:             );
333: 331:         }
334: 332: 
335: 333:         #[allow(deprecated)]
336: 334:         if conf.separate_front_target_dir.is_some() {
337: 335:             log::warn!("Deprecated: the `separate-front-target-dir` option is deprecated since cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos 0.2.3");
338: 336:             log::warn!("It is now unconditionally enabled; you can remove it from your Cargo.toml")
339: 337:         }
340: 338: 
341: 339:         Ok(conf)
342: 340:     }
343: 341: }
344: 342: 
345: 343: #[derive(Debug, Deserialize)]
346: 344: #[serde(rename_all = "kebab-case")]
347: 345: pub struct ProjectDefinition {
348: 346:     name: String,
349: 347:     pub bin_package: String,
350: 348:     pub lib_package: String,
351: 349: }
352: 350: impl ProjectDefinition {
353: 351:     fn from_workspace(
354: 352:         metadata: &serde_json::Value,
355: 353:         dir: &Utf8Path,
356: 354:         cargo_metadata: &Metadata,
357: 355:     ) -> Result<Vec<(Self, ProjectConfig)>> {
358: 356:         let mut found = Vec::new();
359: 357:         if let Some(arr) = metadata.as_array() {
360: 358:             for section in arr {
361: 359:                 let conf = ProjectConfig::parse(dir, section, cargo_metadata)?;
362: 360:                 let def: Self = serde_json::from_value(section.clone())?;
363: 361:                 found.push((def, conf))
364: 362:             }
365: 363:         }
366: 364:         Ok(found)
367: 365:     }
368: 366: 
369: 367:     fn from_project(
370: 368:         package: &Package,
371: 369:         metadata: &serde_json::Value,
372: 370:         dir: &Utf8Path,
373: 371:         cargo_metadata: &Metadata,
374: 372:     ) -> Result<(Self, ProjectConfig)> {
375: 373:         let conf = ProjectConfig::parse(dir, metadata, cargo_metadata)?;
376: 374: 
377: 375:         ensure!(
378: 376:             package.cdylib_target().is_some(),
379: 377:             "Cargo.toml has lyx-core-lyx_core_lyx-core-lyx_core_leptos metadata but is missing a cdylib library target. {}",
380: 378:             GRAY.paint(package.manifest_path.as_str())
381: 379:         );
382: 380:         ensure!(
383: 381:             package.has_bin_target(),
384: 382:             "Cargo.toml has lyx-core-lyx_core_lyx-core-lyx_core_leptos metadata but is missing a bin target. {}",
385: 383:             GRAY.paint(package.manifest_path.as_str())
386: 384:         );
387: 385: 
388: 386:         Ok((
389: 387:             ProjectDefinition {
390: 388:                 name: package.name.to_string(),
391: 389:                 bin_package: package.name.to_string(),
392: 390:                 lib_package: package.name.to_string(),
393: 391:             },
394: 392:             conf,
395: 393:         ))
396: 394:     }
397: 395: 
398: 396:     fn parse(metadata: &Metadata) -> Result<Vec<(Self, ProjectConfig)>> {
399: 397:         let workspace_dir = &metadata.workspace_root;
400: 398:         let mut found: Vec<(Self, ProjectConfig)> =
401: 399:             if let Some(md) = lyx-core-lyx_core_lyx-core-metadata(&metadata.workspace_metadata) {
402: 400:                 Self::from_workspace(md, &Utf8PathBuf::default(), metadata)?
403: 401:             } else {
404: 402:                 Default::default()
405: 403:             };
406: 404: 
407: 405:         for package in metadata.workspace_packages() {
408: 406:             let dir = package.manifest_path.unbase(workspace_dir)?.without_last();
409: 407: 
410: 408:             if let Some(lyx-core-lyx_core_lyx-core-metadata) = lyx-core-lyx_core_lyx-core-metadata(&package.metadata) {
411: 409:                 found.push(Self::from_project(
412: 410:                     package,
413: 411:                     lyx-core-lyx_core_lyx-core-metadata,
414: 412:                     &dir,
415: 413:                     metadata,
416: 414:                 )?);
417: 415:             }
418: 416:         }
419: 417:         Ok(found)
420: 418:     }
421: 419: }
422: 420: 
423: 421: fn lyx-core-lyx_core_lyx-core-metadata(metadata: &serde_json::Value) -> Option<&serde_json::Value> {
424: 422:     metadata.as_object().and_then(|o| o.get("lyx-core-lyx_core_lyx-core-lyx_core_leptos"))
425: 423: }
426: 424: 
427: 425: fn default_site_addr() -> SocketAddr {
428: 426:     SocketAddr::new([127, 0, 0, 1].into(), 3000)
429: 427: }
430: 428: 
431: 429: fn default_pkg_dir() -> Utf8PathBuf {
432: 430:     Utf8PathBuf::from("pkg")
433: 431: }
434: 432: 
435: 433: fn default_site_root() -> Utf8PathBuf {
436: 434:     Utf8PathBuf::from(CARGO_TARGET_DIR_MARKER).join("site")
437: 435: }
438: 436: 
439: 437: fn default_reload_port() -> u16 {
440: 438:     3001
441: 439: }
442: 440: 
443: 441: fn default_browserquery() -> String {
444: 442:     "defaults".to_string()
445: 443: }
446: 444: 
447: 445: fn default_hash_files() -> bool {
448: 446:     false
449: 447: }
450: 448: 
451: 449: fn default_js_minify() -> bool {
452: 450:     true
453: 451: }
454: 452: ```
455: 453: ```
456: 454: ```
457: 455: ```
458: 456: ```
459: 457: ```
460: 458: ```
461: 459: ```
462: 460: ```
463: 461: ```
464: 462: ```
465: 463: ```
466: 464: ```
467: 465: ```
468: 466: ```
469: 467: ```
470: 468: ```
471: 469: ```
472: ```
```
