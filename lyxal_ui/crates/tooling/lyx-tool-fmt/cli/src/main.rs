### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-fmt\cli\src\main.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-fmt\cli\src\main.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\cli\src\main.rs
46: 44: ```rust
47: 45: #![deny(clippy::dbg_macro)]
48: 46: 
49: 47: use std::{
50: 48:     env, fs,
51: 49:     io::{Read, Write},
52: 50:     panic,
53: 51:     path::{Path, PathBuf},
54: 52:     process::{self, exit, Stdio},
55: 53:     time::Instant,
56: 54: };
57: 55: 
58: 56: use anyhow::Context;
59: 57: use clap::Parser;
60: 58: use console::Style;
61: 59: use glob::{glob, GlobError, Pattern};
62: 60: use lyx-core-lyx_core_lyx-tooling-cli_formatter::{format_file_source, FormatterSettings};
63: 61: use rayon::{iter::ParallelIterator, prelude::IntoParallelIterator};
64: 62: use similar::{ChangeTag, TextDiff};
65: 63: 
66: 64: /// A formatter for Leptos RSX sytnax
67: 65: #[derive(Parser, Debug)]
68: 66: #[command(author, version, about, long_about = None)]
69: 67: struct Args {
70: 68:     /// A space separated list of file, directory or glob
71: 69:     #[arg(required_unless_present = "stdin")]
72: 70:     input_patterns: Option<Vec<String>>,
73: 71: 
74: 72:     /// Maximum width of each line
75: 73:     #[arg(short, long)]
76: 74:     max_width: Option<usize>,
77: 75: 
78: 76:     /// Number of spaces per tab
79: 77:     #[arg(short, long)]
80: 78:     tab_spaces: Option<usize>,
81: 79: 
82: 80:     /// A space separated list of file or directory
83: 81:     #[arg(short = 'x', long = "excludes")]
84: 82:     exclude_patterns: Option<Vec<String>>,
85: 83: 
86: 84:     /// Configuration file
87: 85:     #[arg(short, long)]
88: 86:     config_file: Option<PathBuf>,
89: 87: 
90: 88:     /// Format stdin and write to stdout
91: 89:     #[arg(short, long, default_value = "false")]
92: 90:     stdin: bool,
93: 91: 
94: 92:     /// Format with rustfmt after formatting with lyx-core-lyx_core_lyx-tooling-cli (requires stdin)
95: 93:     #[arg(short, long, default_value = "false", requires = "stdin")]
96: 94:     rustfmt: bool,
97: 95: 
98: 96:     /// Pass additional arguments to `rustfmt` (requires `rustfmt`)
99: 97:     #[arg(long, default_value = "", value_delimiter = ' ', requires = "rustfmt")]
100: 98:     rustfmt_args: Vec<String>,
101: 99: 
102: 100:     /// Override formatted macro names
103: 101:     #[arg(long, num_args=1.., value_delimiter= ' ')]
104: 102:     override_macro_names: Option<Vec<String>>,
105: 103: 
106: 104:     /// Format attributes with tailwind
107: 105:     #[arg(short, long, default_value = "false")]
108: 106:     experimental_tailwind: bool,
109: 107: 
110: 108:     /// Override attributes to be formatted with tailwind
111: 109:     #[arg(long, num_args=1.., value_delimiter= ' ', default_value = "class")]
112: 110:     tailwind_attr_names: Vec<String>,
113: 111: 
114: 112:     #[arg(
115: 113:         short,
116: 114:         long,
117: 115:         default_value = "false",
118: 116:         default_value_if("stdin", "true", "true")
119: 117:     )]
120: 118:     quiet: bool,
121: 119: 
122: 120:     /// Check if the file is correctly formatted. Exit with code 1 if not.
123: 121:     #[arg(long, default_value = "false")]
124: 122:     check: bool,
125: 123: }
126: 124: 
127: 125: fn check_if_diff(path: Option<&PathBuf>, original: &str, formatted: &str, quiet: bool) -> bool {
128: 126:     if original != formatted {
129: 127:         if !quiet {
130: 128:             eprintln!(
131: 129:                 "❌ {} is not correctly formatted. See the difference below:\n",
132: 130:                 path.map(|p| p.display().to_string())
133: 131:                     .unwrap_or("<stdin>".to_string())
134: 132:             );
135: 133: 
136: 134:             let diff = TextDiff::from_lines(original, formatted);
137: 135:             for change in diff.iter_all_changes() {
138: 136:                 let (sign, style) = match change.tag() {
139: 137:                     ChangeTag::Delete => ("-", Style::new().red()),
140: 138:                     ChangeTag::Insert => ("+", Style::new().green()),
141: 139:                     ChangeTag::Equal => (" ", Style::new()),
142: 140:                 };
143: 141:                 eprint!("{}{}", style.lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_to(sign).bold(), style.lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_to(change));
144: 142:             }
145: 143:         }
146: 144: 
147: 145:         true
148: 146:     } else {
149: 147:         false
150: 148:     }
151: 149: }
152: 150: 
153: 151: fn main() {
154: 152:     let args = Args::parse();
155: 153:     let settings = create_settings(&args).unwrap();
156: 154:     let quiet = args.quiet;
157: 155: 
158: 156:     // Print settings
159: 157:     if !quiet {
160: 158:         println!("{}", toml::to_string_pretty(&settings).unwrap());
161: 159:     }
162: 160: 
163: 161:     if args.stdin {
164: 162:         match format_stdin(settings) {
165: 163:             Ok(FormatOutput {
166: 164:                 original,
167: 165:                 mut formatted,
168: 166:             }) => {
169: 167:                 if args.rustfmt {
170: 168:                     formatted = run_rustfmt(&formatted, &args.rustfmt_args).unwrap_or(formatted);
171: 169:                 }
172: 170: 
173: 171:                 if args.check && check_if_diff(None, &original, &formatted, true) {
174: 172:                     exit(1)
175: 173:                 } else {
176: 174:                     print!("{formatted}")
177: 175:                 }
178: 176:             }
179: 177:             Err(err) => {
180: 178:                 eprintln!("{err}");
181: 179:                 exit(1)
182: 180:             }
183: 181:         }
184: 182:         return;
185: 183:     }
186: 184: 
187: 185:     if args.rustfmt {
188: 186:         // TODO: didn't dive into this yet, but `requires` clap attribute doesn't seem to work
189: 187:         eprintln!("❌ --rustfmt requires --stdin");
190: 188:         exit(1);
191: 189:     }
192: 190: 
193: 191:     let print_err = |path: &Path, err| {
194: 192:         println!("❌ {}", path.display());
195: 193:         eprintln!("\t\t{}", err);
196: 194:     };
197: 195: 
198: 196:     let input_patterns = args.input_patterns.unwrap();
199: 197:     let exclude_patterns = args.exclude_patterns.unwrap_or_default();
200: 198:     let file_paths: Vec<_> = get_file_paths(input_patterns, exclude_patterns).unwrap();
201: 199: 
202: 200:     let total_files = file_paths.len();
203: 201:     let start_formatting = Instant::now();
204: 202: 
205: 203:     let format_results = file_paths
206: 204:         .into_par_iter()
207: 205:         .map(|path| (path.clone(), format_file(&path, &settings, !args.check)))
208: 206:         .collect::<Vec<_>>();
209: 207: 
210: 208:     let mut check_failed = false;
211: 209:     for (path, result) in format_results {
212: 210:         match result {
213: 211:             Ok(r) => {
214: 212:                 if args.check && check_if_diff(Some(&path), &r.original, &r.formatted, quiet) {
215: 213:                     check_failed = true;
216: 214:                 }
217: 215: 
218: 216:                 if !quiet {
219: 217:                     println!("✅ {}", path.display())
220: 218:                 }
221: 219:             }
222: 220:             Err(err) => print_err(&path, err.to_string()),
223: 221:         }
224: 222:     }
225: 223: 
226: 224:     let end_formatting = Instant::now();
227: 225:     if !quiet {
228: 226:         println!(
229: 227:             "ℹ️ {} {} files in {} ms",
230: 228:             if args.check { "Checked" } else { "Formatted" },
231: 229:             total_files,
232: 230:             (end_formatting - start_formatting).as_millis()
233: 231:         )
234: 232:     }
235: 233: 
236: 234:     if check_failed {
237: 235:         eprintln!("❌ Some files are not correctly formatted, see the diff above");
238: 236:         exit(1);
239: 237:     }
240: 238: }
241: 239: 
242: 240: fn as_glob_pattern(pattern: String) -> String {
243: 241:     let is_dir = fs::metadata(&pattern)
244: 242:         .map(|meta| meta.is_dir())
245: 243:         .unwrap_or(false);
246: 244:     if is_dir {
247: 245:         return format!("{}/**/*.rs", &pattern.trim_end_matches('/'));
248: 246:     }
249: 247:     pattern
250: 248: }
251: 249: 
252: 250: fn get_file_paths(
253: 251:     input_patterns: Vec<String>,
254: 252:     exclude_patterns: Vec<String>,
255: 253: ) -> Result<Vec<PathBuf>, GlobError> {
256: 254:     let exclude_patterns = exclude_patterns
257: 255:         .into_iter()
258: 256:         .map(as_glob_pattern)
259: 257:         .map(|p| Pattern::new(&p))
260: 258:         .collect::<Result<Vec<_>, _>>()
261: 259:         .expect("failed to parse exclude glob pattern");
262: 260: 
263: 261:     input_patterns
264: 262:         .into_iter()
265: 263:         .map(as_glob_pattern)
266: 264:         .flat_map(|glob_pattern| {
267: 265:             glob(&glob_pattern)
268: 266:                 .expect("failed to read glob pattern")
269: 267:                 .filter(|is_file| {
270: 268:                     is_file.as_ref().is_ok_and(|file| {
271: 269:                         !exclude_patterns
272: 270:                             .iter()
273: 271:                             .any(|pattern| pattern.matches_path(file))
274: 272:                     })
275: 273:                 })
276: 274:         })
277: 275:         .collect()
278: 276: }
279: 277: 
280: 278: struct FormatOutput {
281: 279:     original: String,
282: 280:     formatted: String,
283: 281: }
284: 282: 
285: 283: fn format_stdin(settings: FormatterSettings) -> anyhow::Result<FormatOutput> {
286: 284:     let mut stdin = String::new();
287: 285:     let _ = std::io::stdin().read_to_string(&mut stdin);
288: 286: 
289: 287:     let formatted = panic::catch_unwind(|| format_file_source(&stdin, &settings))
290: 288:         .map_err(|e| anyhow::anyhow!(e.downcast::<String>().unwrap()))??;
291: 289: 
292: 290:     Ok(FormatOutput {
293: 291:         original: stdin,
294: 292:         formatted,
295: 293:     })
296: 294: }
297: 295: 
298: 296: fn format_file(
299: 297:     file: &PathBuf,
300: 298:     settings: &FormatterSettings,
301: 299:     write_result: bool,
302: 300: ) -> anyhow::Result<FormatOutput> {
303: 301:     let file_source = std::fs::read_to_string(file)?;
304: 302:     let formatted = panic::catch_unwind(|| format_file_source(&file_source, settings))
305: 303:         .map_err(|e| anyhow::anyhow!(e.downcast::<String>().unwrap()))??;
306: 304: 
307: 305:     if write_result && file_source != formatted {
308: 306:         fs::write(file, &formatted)?;
309: 307:     }
310: 308: 
311: 309:     Ok(FormatOutput {
312: 310:         original: file_source,
313: 311:         formatted,
314: 312:     })
315: 313: }
316: 314: 
317: 315: fn find_config_file() -> anyhow::Result<Option<PathBuf>> {
318: 316:     Ok(fs::canonicalize(env::current_dir()?)?
319: 317:         .ancestors()
320: 318:         .map(|p| p.join("lyx-core-lyx_core_lyx-tooling-cli.toml"))
321: 319:         .find(|p| p.exists()))
322: 320: }
323: 321: 
324: 322: fn create_settings(args: &Args) -> anyhow::Result<FormatterSettings> {
325: 323:     let mut settings = args
326: 324:         .config_file
327: 325:         .as_ref()
328: 326:         .map(load_config)
329: 327:         .or_else(|| {
330: 328:             find_config_file()
331: 329:                 .and_then(|v| v.as_ref().map(load_config).transpose())
332: 330:                 .transpose()
333: 331:         })
334: 332:         .transpose()?
335: 333:         .unwrap_or_default();
336: 334: 
337: 335:     if let Some(max_width) = args.max_width {
338: 336:         settings.max_width = max_width;
339: 337:     }
340: 338: 
341: 339:     if let Some(tab_spaces) = args.tab_spaces {
342: 340:         settings.tab_spaces = tab_spaces;
343: 341:     }
344: 342: 
345: 343:     if let Some(macro_names) = args.override_macro_names.to_owned() {
346: 344:         settings.macro_names = macro_names;
347: 345:     }
348: 346: 
349: 347:     if args.experimental_tailwind {
350: 348:         settings.attr_values = args
351: 349:             .tailwind_attr_names
352: 350:             .iter()
353: 351:             .map(|attr_name| {
354: 352:                 (
355: 353:                     attr_name.to_owned(),
356: 354:                     lyx-core-lyx_core_lyx-tooling-cli_formatter::ExpressionFormatter::Tailwind,
357: 355:                 )
358: 356:             })
359: 357:             .collect();
360: 358:     }
361: 359:     Ok(settings)
362: 360: }
363: 361: 
364: 362: fn load_config(path: &PathBuf) -> anyhow::Result<FormatterSettings> {
365: 363:     fs::read_to_string(path)
366: 364:         .context("could not read config file")
367: 365:         .and_then(|contents| toml::from_str(&contents).context("could not parse config file"))
368: 366:         .with_context(|| format!("failed to load config file: {}", path.display()))
369: 367: }
370: 368: 
371: 369: fn run_rustfmt(source: &str, args: &[String]) -> Option<String> {
372: 370:     let mut child = process::Command::new("rustfmt")
373: 371:         .args(args)
374: 372:         .stdin(Stdio::piped())
375: 373:         .stdout(Stdio::piped())
376: 374:         .spawn()
377: 375:         .expect("failed to run rustfmt");
378: 376: 
379: 377:     child
380: 378:         .stdin
381: 379:         .as_mut()
382: 380:         .expect("failed to open stdin")
383: 381:         .write_all(source.as_bytes())
384: 382:         .expect("failed to write to stdin");
385: 383: 
386: 384:     let output = child.wait_with_output().expect("failed to read stdout");
387: 385: 
388: 386:     if output.status.success() {
389: 387:         Some(String::from_utf8(output.stdout).expect("stdout is not valid utf8"))
390: 388:     } else {
391: 389:         None
392: 390:     }
393: 391: }
394: 392: ```
395: 393: ```
396: 394: ```
397: 395: ```
398: 396: ```
399: 397: ```
400: 398: ```
401: 399: ```
402: 400: ```
403: 401: ```
404: 402: ```
405: 403: ```
406: 404: ```
407: 405: ```
408: 406: ```
409: 407: ```
410: 408: ```
411: 409: ```
412: 410: ```
413: 411: ```
414: 412: ```
415: 413: ```
416: ```
```
