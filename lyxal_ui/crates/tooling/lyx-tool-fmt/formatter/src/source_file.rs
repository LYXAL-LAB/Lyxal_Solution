### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-fmt\formatter\src\source_file.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx-tool-fmt\formatter\src\source_file.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\source_file.rs
46: 44: ```rust
47: 45: use std::{
48: 46:     io::{self},
49: 47:     ops::Range,
50: 48: };
51: 49: 
52: 50: use crop::Rope;
53: 51: 
54: 52: use syn::spanned::Spanned;
55: 53: use thiserror::Error;
56: 54: 
57: 55: use crate::{
58: 56:     collect::collect_macros_in_file,
59: 57:     formatter::{format_macro, FormatterSettings},
60: 58:     line_column_to_byte, ViewMacro,
61: 59: };
62: 60: 
63: 61: #[derive(Error, Debug)]
64: 62: pub enum FormatError {
65: 63:     #[error("could not read file")]
66: 64:     IoError(#[from] io::Error),
67: 65:     #[error("could not parse file")]
68: 66:     ParseError(#[from] syn::Error),
69: 67: }
70: 68: 
71: 69: #[derive(Debug)]
72: 70: struct TextEdit {
73: 71:     range: Range<usize>,
74: 72:     new_text: String,
75: 73: }
76: 74: 
77: 75: pub fn format_file_source(
78: 76:     source: &str,
79: 77:     settings: &FormatterSettings,
80: 78: ) -> Result<String, FormatError> {
81: 79:     let ast = syn::parse_file(source)?;
82: 80:     let rope = Rope::from(source);
83: 81:     let (mut rope, macros) = collect_macros_in_file(&ast, rope, &settings.macro_names);
84: 82:     format_source(&mut rope, macros, settings)
85: 83: }
86: 84: 
87: 85: fn format_source(
88: 86:     source: &mut Rope,
89: 87:     macros: Vec<ViewMacro<'_>>,
90: 88:     settings: &FormatterSettings,
91: 89: ) -> Result<String, FormatError> {
92: 90:     let mut edits = Vec::new();
93: 91: 
94: 92:     for view_mac in macros {
95: 93:         let mac = view_mac.inner();
96: 94:         let start = mac.path.span().start();
97: 95:         let end = mac.delimiter.span().close().end();
98: 96:         let start_byte = line_column_to_byte(source, start);
99: 97:         let end_byte = line_column_to_byte(source, end);
100: 98:         let new_text = format_macro(&view_mac, settings, Some(source));
101: 99: 
102: 100:         edits.push(TextEdit {
103: 101:             range: start_byte..end_byte,
104: 102:             new_text,
105: 103:         });
106: 104:     }
107: 105: 
108: 106:     let mut last_offset: isize = 0;
109: 107:     for edit in edits {
110: 108:         let start = edit.range.start;
111: 109:         let end = edit.range.end;
112: 110:         let new_text = edit.new_text;
113: 111: 
114: 112:         source.replace(
115: 113:             (start as isize + last_offset) as usize..(end as isize + last_offset) as usize,
116: 114:             &new_text,
117: 115:         );
118: 116:         last_offset += new_text.len() as isize - (end as isize - start as isize);
119: 117:     }
120: 118: 
121: 119:     Ok(source.to_string())
122: 120: }
123: 121: 
124: 122: #[cfg(test)]
125: 123: mod tests {
126: 124:     use indoc::indoc;
127: 125: 
128: 126:     use crate::{ExpressionFormatter, IndentationStyle};
129: 127: 
130: 128:     use super::*;
131: 129: 
132: 130:     #[test]
133: 131:     fn rustfmt_lyx-core-lyx_core_lyx-tooling-cli_indent_difference() {
134: 132:         let source = indoc! {r#"
135: 133:         // Valid Rust formatted code
136: 134:         #[component]
137: 135:         pub(crate) fn Error(cx: Scope, message: Option<String>) -> impl IntoView {
138: 136:             view! {
139: 137:               <div>
140: 138:                 Example
141: 139:               </div>
142: 140:             }
143: 141:         }
144: 142:         "#};
145: 143: 
146: 144:         let result = format_file_source(
147: 145:             source,
148: 146:             &FormatterSettings {
149: 147:                 tab_spaces: 2,
150: 148:                 ..Default::default()
151: 149:             },
152: 150:         )
153: 151:         .unwrap();
154: 152:         insta::assert_snapshot!(result, @r###"
155: 153:         // Valid Rust formatted code
156: 154:         #[component]
157: 155:         pub(crate) fn Error(cx: Scope, message: Option<String>) -> impl IntoView {
158: 156:             view! { <div>Example</div> }
159: 157:         }
160: 158:         "###);
161: 159:     }
162: 160: 
163: 161:     #[test]
164: 162:     fn it_works() {
165: 163:         let source = indoc! {r#"
166: 164:             fn main() {
167: 165:                 view! {  <div>  <span>"hello"</span></div>  };
168: 166:             }
169: 167:         "#};
170: 168: 
171: 169:         let result = format_file_source(source, &Default::default()).unwrap();
172: 170:         insta::assert_snapshot!(result, @r#"
173: 171:         fn main() {
174: 172:             view! {
175: 173:                 <div>
176: 174:                     <span>"hello"</span>
177: 175:                 </div>
178: 176:             };
179: 177:         }
180: 178: 
181: 179:         "#);
182: 180:     }
183: 181: 
184: 182:     #[test]
185: 183:     fn fully_qualified_macro_path() {
186: 184:         let source = indoc! {r#"
187: 185:             fn main() {
188: 186:                 lyx-core-lyx_core_lyx-core-lyx_core_leptos::view! {    <div>  <span>"hello"</span></div>  };
189: 187:             }
190: 188:         "#};
191: 189: 
192: 190:         let result = format_file_source(source, &Default::default()).unwrap();
193: 191:         insta::assert_snapshot!(result, @r#"
194: 192:         fn main() {
195: 193:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::view! {
196: 194:                 <div>
197: 195:                     <span>"hello"</span>
198: 196:                 </div>
199: 197:             };
200: 198:         }
201: 199: 
202: 200:         "#);
203: 201:     }
204: 202: 
205: 203:     #[test]
206: 204:     fn ignore_other_macros() {
207: 205:         let source = indoc! {r#"
208: 206:             fn main() {
209: 207:                 lyx-core-lyx_core_lyx-core-lyx_core_leptos::view! {    <div class=format!("classy")>  <span>"hello"</span></div>  };
210: 208:             }
211: 209:         "#};
212: 210: 
213: 211:         let result = format_file_source(source, &Default::default()).unwrap();
214: 212:         insta::assert_snapshot!(result, @r#"
215: 213:         fn main() {
216: 214:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::view! {
217: 215:                 <div class=format!("classy")>
218: 216:                     <span>"hello"</span>
219: 217:                 </div>
220: 218:             };
221: 219:         }
222: 220: 
223: 221:         "#);
224: 222:     }
225: 223: 
226: 224:     #[test]
227: 225:     fn preserve_formatting_unknown_macros() {
228: 226:         let source = indoc! {r#"
229: 227:         #[component]
230: 228:         pub fn HeaderField() -> impl IntoView {
231: 229:             view! {
232: 230:                 <div class="HeaderField start">
233: 231:                     <h1>Hello Kanna</h1>
234: 232:                 </div>
235: 233: 
236: 234:                 {
237: 235:                     style! {
238: 236:                         h1 {
239: 237:                             background-color: red;
240: 238:                             color: white;
241: 239:                         }
242: 240: 
243: 241:                         @media (orientation: portrait) {
244: 242:                             h1 {
245: 243:                               background-color: green;
246: 244:                             }
247: 245:                         }
248: 246:                     }
249: 247:                 }
250: 248:             }
251: 249:         }"#};
252: 250: 
253: 251:         let result = format_file_source(source, &Default::default()).unwrap();
254: 252:         insta::assert_snapshot!(result, @r###"
255: 253:         #[component]
256: 254:         pub fn HeaderField() -> impl IntoView {
257: 255:             view! {
258: 256:                 <div class="HeaderField start">
259: 257:                     <h1>Hello Kanna</h1>
260: 258:                 </div>
261: 259: 
262: 260:                 {
263: 261:                     style! {
264: 262:                         h1 {
265: 263:                             background-color: red;
266: 264:                             color: white;
267: 265:                         }
268: 266: 
269: 267:                         @media (orientation: portrait) {
270: 268:                             h1 {
271: 269:                               background-color: green;
272: 270:                             }
273: 271:                         }
274: 272:                     }
275: 273:                 }
276: 274:             }
277: 275:         }
278: 276:         "###);
279: 277:     }
280: 278: 
281: 279:     #[test]
282: 280:     fn fully_qualified_macro_path_overridden() {
283: 281:         let source = indoc! {r#"
284: 282:             fn main() {
285: 283:                 foo::bar::some_view! {    <div>  <span>"hello"</span></div>  };
286: 284:             }
287: 285:         "#};
288: 286: 
289: 287:         let result = format_file_source(
290: 288:             source,
291: 289:             &FormatterSettings {
292: 290:                 macro_names: vec!["foo::bar::some_view".to_string()],
293: 291:                 ..Default::default()
294: 292:             },
295: 293:         )
296: 294:         .unwrap();
297: 295:         insta::assert_snapshot!(result, @r#"
298: 296:         fn main() {
299: 297:             foo::bar::some_view! {
300: 298:                 <div>
301: 299:                     <span>"hello"</span>
302: 300:                 </div>
303: 301:             };
304: 302:         }
305: 303: 
306: 304:         "#);
307: 305:     }
308: 306: 
309: 307:     #[test]
310: 308:     fn fully_qualified_macro_path_with_indent() {
311: 309:         let source = indoc! {r#"
312: 310:             fn main() {
313: 311:                 foo::bar::some_view! {    <div>  <span>{
314: 312:                         let a = 12;
315: 313: 
316: 314: 
317: 315:                         foo::bar::some_view! {
318: 316: 
319: 317:                                          <span>{a}</span>
320: 318:                         }
321: 319:                 }</span></div>  };
322: 320:             }
323: 321:         "#};
324: 322: 
325: 323:         let result = format_file_source(
326: 324:             source,
327: 325:             &FormatterSettings {
328: 326:                 macro_names: vec!["foo::bar::some_view".to_string()],
329: 327:                 ..Default::default()
330: 328:             },
331: 329:         )
332: 330:         .unwrap();
333: 331:         insta::assert_snapshot!(result, @r#"
334: 332:         fn main() {
335: 333:             foo::bar::some_view! {
336: 334:                 <div>
337: 335:                     <span>
338: 336:                         {
339: 337:                             let a = 12;
340: 338: 
341: 339:                             foo::bar::some_view! { <span>{a}</span> }
342: 340:                         }
343: 341:                     </span>
344: 342:                 </div>
345: 343:             };
346: 344:         }
347: 345: 
348: 346:         "#);
349: 347:     }
350: 348: 
351: 349:     #[test]
352: 350:     fn override_macro_names() {
353: 351:         let source = indoc! {r#"
354: 352:             fn main() {
355: 353:                 html! {    <div>  <span>{
356: 354:                         let a = 12;
357: 355: 
358: 356: 
359: 357:                         html! {
360: 358: 
361: 359:                                          <span>{a}</span>
362: 360:                         }
363: 361:                 }</span></div>  };
364: 362:             }
365: 363:         "#};
366: 364: 
367: 365:         let result = format_file_source(
368: 366:             source,
369: 367:             &FormatterSettings {
370: 368:                 macro_names: vec!["html".to_string()],
371: 369:                 ..Default::default()
372: 370:             },
373: 371:         )
374: 372:         .unwrap();
375: 373:         insta::assert_snapshot!(result, @r#"
376: 374:         fn main() {
377: 375:             html! {
378: 376:                 <div>
379: 377:                     <span>
380: 378:                         {
381: 379:                             let a = 12;
382: 380: 
383: 381:                             html! { <span>{a}</span> }
384: 382:                         }
385: 383:                     </span>
386: 384:                 </div>
387: 385:             };
388: 386:         }
389: 387: 
390: 388:         "#);
391: 389:     }
392: 390: 
393: 391:     #[test]
394: 392:     fn with_comments() {
395: 393:         let source = indoc! {r#"
396: 394:             // comment outside view macro
397: 395:             fn main() {
398: 396:                 view! {
399: 397:                     // Top level comment
400: 398:                     <div>
401: 399:                         // This is one beautiful message
402: 400:                     <span>"hello"</span> // at the end of the line 1
403: 401:                     <div>// at the end of the line 2
404: 402:              // double
405: 403:              // comments
406: 404:                     <span>"hello"</span> </div>
407: 405:                      <For
408: 406:             // a function that returns the items we're iterating over; a signal is fine
409: 407:             each= move || {errors.clone().into_iter().enumerate()}
410: 408:             // a unique key for each item as a reference
411: 409:              key=|(index, _error)| *index // yeah
412: 410:              />
413: 411:              <div> // same line comment
414: 412:              // with comment on the next line
415: 413:              </div>
416: 414:              // comments with url: https://lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.com
417: 415:              <h1>"hi"</h1>
418: 416:              // comments with empty lines inbetween
419: 417: 
420: 418:              // and some more
421: 419:              // on the next line
422: 420:                     </div>
423: 421:                    // trailing comment
424: 422:                     };
425: 423:             }
426: 424: 
427: 425:             // comment after view macro
428: 426:         "#};
429: 427: 
430: 428:         let result = format_file_source(source, &Default::default()).unwrap();
431: 429:         insta::assert_snapshot!(result, @r###"
432: 430:         // comment outside view macro
433: 431:         fn main() {
434: 432:             view! {
435: 433:                 // Top level comment
436: 434:                 <div>
437: 435:                     // This is one beautiful message
438: 436:                     // at the end of the line 1
439: 437:                     <span>"hello"</span>
440: 438:                     // at the end of the line 2
441: 439:                     <div>
442: 440:                         // double
443: 441:                         // comments
444: 442:                         <span>"hello"</span>
445: 443:                     </div>
446: 444:                     <For
447: 445:                         // a function that returns the items we're iterating over; a signal is fine
448: 446:                         each=move || { errors.clone().into_iter().enumerate() }
449: 447:                         // a unique key for each item as a reference
450: 448:                         // yeah
451: 449:                         key=|(index, _error)| *index
452: 450:                     />
453: 451:                     // same line comment
454: 452:                     <div>// with comment on the next line
455: 453:                     </div>
456: 454:                     // comments with url: https://lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.com
457: 455:                     <h1>"hi"</h1>
458: 456:                 // comments with empty lines inbetween
459: 457: 
460: 458:                 // and some more
461: 459:                 // on the next line
462: 460:                 </div>
463: 461:                 // trailing comment
464: 462:             };
465: 463:         }
466: 464: 
467: 465:         // comment after view macro
468: 466:         "###);
469: 467:     }
470: 468: 
471: 469:     #[test]
472: 470:     fn nested() {
473: 471:         let source = indoc! {r#"
474: 472:             fn main() {
475: 473:                 view! {    <div>  <span>{
476: 474:                         let a = 12;
477: 475: 
478: 476: 
479: 477:                         view! {
480: 478: 
481: 479:                                          <span>{a}</span>
482: 480:                         }
483: 481:                 }</span></div>  };
484: 482:             }
485: 483:         "#};
486: 484: 
487: 485:         let result = format_file_source(source, &Default::default()).unwrap();
488: 486:         insta::assert_snapshot!(result, @r###"
489: 487:         fn main() {
490: 488:             view! {
491: 489:                 <div>
492: 490:                     <span>
493: 491:                         {
494: 492:                             let a = 12;
495: 493: 
496: 494:                             view! { <span>{a}</span> }
497: 495:                         }
498: 496:                     </span>
499: 497:                 </div>
500: 498:             };
501: 499:         }
502: 500:         "###);
503: 501:     }
504: 502: 
505: 503:     #[test]
506: 504:     fn nested_with_comments() {
507: 505:         let source = indoc! {r#"
508: 506:             fn main() {
509: 507:                 view! {
510: 508: 
511: 509:                     // parent div
512: 510:                     <div>
513: 511: 
514: 512:                     // parent span
515: 513:                     <span>{ //ok
516: 514:                         let a = 12;
517: 515: 
518: 516:                         view! {
519: 517:                             // wow, a span
520: 518:                             <span>{a}</span>
521: 519:                         }
522: 520:                 }</span></div>  };
523: 521:             }
524: 522:         "#};
525: 523: 
526: 524:         let result = format_file_source(source, &Default::default()).unwrap();
527: 525:         insta::assert_snapshot!(result, @r###"
528: 526:         fn main() {
529: 527:             view! {
530: 528:                 // parent div
531: 529:                 <div>
532: 530: 
533: 531:                     // parent span
534: 532:                     // ok
535: 533:                     <span>
536: 534:                         {
537: 535:                             let a = 12;
538: 536: 
539: 537:                             view! {
540: 538:                                 // wow, a span
541: 539:                                 <span>{a}</span>
542: 540:                             }
543: 541:                         }
544: 542:                     </span>
545: 543:                 </div>
546: 544:             };
547: 545:         }
548: 546:         "###);
549: 547:     }
550: 548: 
551: 549:     #[test]
552: 550:     fn nested_comments_in_consecutive_view_macro() {
553: 551:         let source = indoc! {r#"
554: 552:             use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
555: 553: 
556: 554:             fn main() {
557: 555:                 mount_to_body(|| {
558: 556:                     view! {
559: 557:                         {move || {
560: 558:                             if true {
561: 559:                                 view! {
562: 560:                                     // comment in if condition.
563: 561:                                     <div>dummy text</div>
564: 562:                                 }
565: 563:                                     .into_view()
566: 564:                             } else {
567: 565:                                 view! {
568: 566:                                     // comment in else condition.
569: 567:                                     <div>dummy text</div>
570: 568:                                 }
571: 569:                                     .into_view()
572: 570:                             }
573: 571:                         }}
574: 572:                     }
575: 573:                 })
576: 574:             }
577: 575:         "#};
578: 576: 
579: 577:         let result = format_file_source(source, &Default::default()).unwrap();
580: 578:         insta::assert_snapshot!(result, @r###"
581: 579:         use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
582: 580: 
583: 581:         fn main() {
584: 582:             mount_to_body(|| {
585: 583:                 view! {
586: 584:                     {move || {
587: 585:                         if true {
588: 586:                             view! {
589: 587:                                 // comment in if condition.
590: 588:                                 <div>dummy text</div>
591: 589:                             }
592: 590:                                 .into_view()
593: 591:                         } else {
594: 592:                             view! {
595: 593:                                 // comment in else condition.
596: 594:                                 <div>dummy text</div>
597: 595:                             }
598: 596:                                 .into_view()
599: 597:                         }
600: 598:                     }}
601: 599:                 }
602: 600:             })
603: 601:         }
604: 602:         "###);
605: 603:     }
606: 604: 
607: 605:     #[test]
608: 606:     fn multiple() {
609: 607:         let source = indoc! {r#"
610: 608:             fn main() {
611: 609:                 view! {   <div>  <span>"hello"</span></div>  };
612: 610:                 view! {     <div>  <span>"hello"</span></div>  };
613: 611:             }
614: 612:         "#};
615: 613: 
616: 614:         let result = format_file_source(source, &Default::default()).unwrap();
617: 615:         insta::assert_snapshot!(result, @r#"
618: 616:         fn main() {
619: 617:             view! {
620: 618:                 <div>
621: 619:                     <span>"hello"</span>
622: 620:                 </div>
623: 621:             };
624: 622:             view! {
625: 623:                 <div>
626: 624:                     <span>"hello"</span>
627: 625:                 </div>
628: 626:             };
629: 627:         }
630: 628:         "#);
631: 629:     }
632: 630: 
633: 631:     #[test]
634: 632:     fn with_special_characters() {
635: 633:         let source = indoc! {r#"
636: 634:             fn main() {
637: 635:                 view! {    <div>  <span>"hello²💣"</span></div>  };
638: 636:             }
639: 637:         "#};
640: 638: 
641: 639:         let result = format_file_source(source, &Default::default()).unwrap();
642: 640:         insta::assert_snapshot!(result, @r#"
643: 641:         fn main() {
644: 642:             view! {
645: 643:                 <div>
646: 644:                     <span>"hello²💣"</span>
647: 645:                 </div>
648: 646:             };
649: 647:         }
650: 648:         "#);
651: 649:     }
652: 650: 
653: 651:     #[test]
654: 652:     fn multiline_view_with_variable_binding() {
655: 653:         let source = indoc! {r#"
656: 654:         #[component]
657: 655:         fn test2(cx: Scope) -> impl IntoView {
658: 656:             let x = view! { <div><span>Hello</span></div> };
659: 657:         }
660: 658:         "#};
661: 659: 
662: 660:         let result = format_file_source(source, &Default::default()).unwrap();
663: 661:         insta::assert_snapshot!(result, @r###"
664: 662:         #[component]
665: 663:         fn test2(cx: Scope) -> impl IntoView {
666: 664:             let x = view! {
667: 665:                 <div>
668: 666:                     <span>Hello</span>
669: 667:                 </div>
670: 668:             };
671: 669:         }
672: 670:         "###);
673: 671:     }
674: 672: 
675: 673:     #[test]
676: 674:     fn inside_match_case() {
677: 675:         let source = indoc! {r#"
678: 676:             use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
679: 677: 
680: 678:             enum ExampleEnum {
681: 679:                 ValueOneWithAReallyLongName,
682: 680:                 ValueTwoWithAReallyLongName,
683: 681:             }
684: 682: 
685: 683:             #[component]
686: 684:             fn Component(cx: Scope, val: ExampleEnum) -> impl IntoView {
687: 685:                 match val {
688: 686:                     ExampleEnum::ValueOneWithAReallyLongName =>
689: 687:                         view! {
690: 688:                                                                     <div>
691: 689:                                                                         <div>"Value One"</div>
692: 690:                                                                     </div>
693: 691:                                                                 }.into_view(cx),
694: 692:                     ExampleEnum::ValueTwoWithAReallyLongName =>  view! {
695: 693:                                                                     <div>
696: 694:                                                                         <div>"Value Two"</div>
697: 695:                                                                     </div>
698: 696:                                                                 }.into_view(cx),
699: 697:                 };
700: 698:             }
701: 699:         "#};
702: 700: 
703: 701:         let result = format_file_source(source, &Default::default()).unwrap();
704: 702:         insta::assert_snapshot!(result, @r#"
705: 703:         use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
706: 704: 
707: 705:         enum ExampleEnum {
708: 706:             ValueOneWithAReallyLongName,
709: 707:             ValueTwoWithAReallyLongName,
710: 708:         }
711: 709: 
712: 710:         #[component]
713: 711:         fn Component(cx: Scope, val: ExampleEnum) -> impl IntoView {
714: 712:             match val {
715: 713:                 ExampleEnum::ValueOneWithAReallyLongName =>
716: 714:                     view! {
717: 715:                         <div>
718: 716:                             <div>"Value One"</div>
719: 717:                         </div>
720: 718:                     }.into_view(cx),
721: 719:                 ExampleEnum::ValueTwoWithAReallyLongName =>  view! {
722: 720:                     <div>
723: 721:                         <div>"Value Two"</div>
724: 722:                     </div>
725: 723:                 }.into_view(cx),
726: 724:             };
727: 725:         }
728: 726:         "#);
729: 727:     }
730: 728: 
731: 729:     #[test]
732: 730:     fn with_unquoted_text_and_multibyte_chars() {
733: 731:         let source = indoc! { r#"
734: 732:             #[component]
735: 733:             pub fn History() -> impl IntoView {
736: 734:                 // ½½½½
737: 735: 
738: 736:                 view! {
739: 737:                     <button>"First"</button>
740: 738:                     <button>First</button>
741: 739:                 }
742: 740:             }
743: 741:         "#};
744: 742: 
745: 743:         let result = format_file_source(source, &Default::default()).unwrap();
746: 744:         insta::assert_snapshot!(result, @r#"
747: 745:         #[component]
748: 746:         pub fn History() -> impl IntoView {
749: 747:             // ½½½½
750: 748: 
751: 749:             view! {
752: 750:                 <button>"First"</button>
753: 751:                 <button>First</button>
754: 752:             }
755: 753:         }
756: 754:         "#);
757: 755:     }
758: 756: 
759: 757:     #[test]
760: 758:     fn indent_with_tabs() {
761: 759:         let source = indoc! {"
762: 760:         fn main() {
763: 761:         \tview! {
764: 762:               <div>
765: 763:                 <div>Example</div>
766: 764:               </div>
767: 765:             }
768: 766:         }
769: 767:         "};
770: 768: 
771: 769:         let result = format_file_source(
772: 770:             source,
773: 771:             &FormatterSettings {
774: 772:                 tab_spaces: 4,
775: 773:                 indentation_style: IndentationStyle::Tabs,
776: 774:                 ..Default::default()
777: 775:             },
778: 776:         )
779: 777:         .unwrap();
780: 778: 
781: 779:         let expected = indoc! {"
782: 780:         fn main() {
783: 781:         \tview! {
784: 782:         \t\t<div>
785: 783:         \t\t\t<div>Example</div>
786: 784:         \t\t</div>
787: 785:         \t}
788: 786:         }
789: 787:         "};
790: 788: 
791: 789:         assert_eq!(result, expected);
792: 790:     }
793: 791: 
794: 792:     #[test]
795: 793:     fn indent_with_tabs_including_code_blocks() {
796: 794:         let source = indoc! {"
797: 795:         fn main() {
798: 796:         \tview! {
799: 797:               <div>
800: 798:                 <button onclick={|_| {
801: 799:                  let x = 1;
802: 800:                  do_something(x);
803: 801:                 }}>Example</button>
804: 802:               </div>
805: 803:             }
806: 804:         }
807: 805:         "};
808: 806: 
809: 807:         let result = format_file_source(
810: 808:             source,
811: 809:             &FormatterSettings {
812: 810:                 tab_spaces: 4,
813: 811:                 indentation_style: IndentationStyle::Tabs,
814: 812:                 ..Default::default()
815: 813:             },
816: 814:         )
817: 815:         .unwrap();
818: 816: 
819: 817:         let expected = indoc! {"
820: 818:         fn main() {
821: 819:         \tview! {
822: 820:         \t\t<div>
823: 821:         \t\t\t<button onclick=|_| {
824: 822:         \t\t\t\tlet x = 1;
825: 823:         \t\t\t\tdo_something(x);
826: 824:         \t\t\t}>Example</button>
827: 825:         \t\t</div>
828: 826:         \t}
829: 827:         }
830: 828:         "};
831: 829: 
832: 830:         assert_eq!(result, expected);
833: 831:     }
834: 832: 
835: 833:     #[test]
836: 834:     fn auto_detect_tabs() {
837: 835:         let source = indoc! {"
838: 836:         fn main() {
839: 837:         \tview! {
840: 838:               <div>
841: 839:                 <div>Example</div>
842: 840:               </div>
843: 841:             }
844: 842:         }
845: 843:         "};
846: 844: 
847: 845:         let result = format_file_source(
848: 846:             source,
849: 847:             &FormatterSettings {
850: 848:                 indentation_style: IndentationStyle::Auto,
851: 849:                 ..Default::default()
852: 850:             },
853: 851:         )
854: 852:         .unwrap();
855: 853: 
856: 854:         let expected = indoc! {"
857: 855:         fn main() {
858: 856:         \tview! {
859: 857:         \t\t<div>
860: 858:         \t\t\t<div>Example</div>
861: 859:         \t\t</div>
862: 860:         \t}
863: 861:         }
864: 862:         "};
865: 863: 
866: 864:         assert_eq!(result, expected);
867: 865:     }
868: 866: 
869: 867:     #[test]
870: 868:     fn auto_detect_spaces() {
871: 869:         let source = indoc! {"
872: 870:         fn main() {
873: 871:         \u{0020}view! {
874: 872:               <div>
875: 873:                 <div>Example</div>
876: 874:               </div>
877: 875:             }
878: 876:         }
879: 877:         "};
880: 878: 
881: 879:         let result = format_file_source(
882: 880:             source,
883: 881:             &FormatterSettings {
884: 882:                 tab_spaces: 1,
885: 883:                 indentation_style: IndentationStyle::Auto,
886: 884:                 ..Default::default()
887: 885:             },
888: 886:         )
889: 887:         .unwrap();
890: 888: 
891: 889:         let expected = indoc! {"
892: 890:         fn main() {
893: 891:         \u{0020}view! {
894: 892:         \u{0020}\u{0020}<div>
895: 893:         \u{0020}\u{0020}\u{0020}<div>Example</div>
896: 894:         \u{0020}\u{0020}</div>
897: 895:         \u{0020}}
898: 896:         }
899: 897:         "};
900: 898: 
901: 899:         assert_eq!(result, expected);
902: 900:     }
903: 901: 
904: 902:     #[test]
905: 903:     fn tailwind() {
906: 904:         let source = indoc! {r#"
907: 905:             view! {
908: 906:                 <button class="text-white px-4 sm:px-8 py-2 sm:py-3 bg-sky-700 hover:bg-sky-800">Test</button>
909: 907:                 <button class="some non tailwind classes">Test</button>
910: 908:                 <button class="some mixed classes non tailwind classes text-white px-4 sm:px-8 py-2 sm:py-3">Test</button>
911: 909:             }"#};
912: 910: 
913: 911:         let result = format_file_source(
914: 912:             source,
915: 913:             &FormatterSettings {
916: 914:                 attr_values: [("class".to_string(), ExpressionFormatter::Tailwind)]
917: 915:                     .into_iter()
918: 916:                     .collect(),
919: 917:                 ..Default::default()
920: 918:             },
921: 919:         )
922: 920:         .unwrap();
923: 921:         insta::assert_snapshot!(result, @r###"
924: 922:         view! {
925: 923:             <button class="py-2 px-4 text-white sm:py-3 sm:px-8 bg-sky-700 hover:bg-sky-800">Test</button>
926: 924:             <button class="some non tailwind classes">Test</button>
927: 925:             <button class="py-2 px-4 text-white sm:py-3 sm:px-8 some mixed classes non tailwind classes">
928: 926:                 Test
929: 927:             </button>
930: 928:         }
931: 929:         "###);
932: 930:     }
933: 931: 
934: 932:     #[test]
935: 933:     fn indent_issue_140() {
936: 934:         let source = indoc! {r#"
937: 935:             #[component]
938: 936:             pub fn QrScanner() -> impl IntoView {
939: 937:                 view! {
940: 938:                     <script src="js/qr-scanner.umd.min.js"></script>
941: 939:                     <script src="js/qr_scanner_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper.js"></script>
942: 940:                     <div id="qr-video-container">
943: 941:                     <video id="qr-video"></video>
944: 942:                     </div>
945: 943:                     <button on:click=move |_| {
946: 944:                         wasm_bindgen_futures::spawn_local(async {
947: 945:                             let video_element = web_sys::window()
948: 946:                                 .unwrap()
949: 947:                                 .document()
950: 948:                                 .unwrap()
951: 949:                                 .get_element_by_id("qr-video")
952: 950:                                 .unwrap()
953: 951:                                 .dyn_into::<HtmlVideoElement>()
954: 952:                                 .unwrap();
955: 953:                             start_qr_scanner(video_element);
956: 954:                         });
957: 955:                     }>Start QR Scanner</button>
958: 956:                 }
959: 957:             }"#};
960: 958: 
961: 959:         let result = format_file_source(
962: 960:             source,
963: 961:             &FormatterSettings {
964: 962:                 indentation_style: IndentationStyle::Spaces,
965: 963:                 tab_spaces: 2,
966: 964:                 max_width: 80,
967: 965:                 ..Default::default()
968: 966:             },
969: 967:         )
970: 968:         .unwrap();
971: 969: 
972: 970:         insta::assert_snapshot!(result, @r###"
973: 971:         #[component]
974: 972:         pub fn QrScanner() -> impl IntoView {
975: 973:             view! {
976: 974:               <script src="js/qr-scanner.umd.min.js"></script>
977: 975:               <script src="js/qr_scanner_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper.js"></script>
978: 976:               <div id="qr-video-container">
979: 977:                 <video id="qr-video"></video>
980: 978:               </div>
981: 979:               <button on:click=move |_| {
982: 980:                 wasm_bindgen_futures::spawn_local(async {
983: 981:                   let video_element = web_sys::window()
984: 982:                     .unwrap()
985: 983:                     .document()
986: 984:                     .unwrap()
987: 985:                     .get_element_by_id("qr-video")
988: 986:                     .unwrap()
989: 987:                     .dyn_into::<HtmlVideoElement>()
990: 988:                     .unwrap();
991: 989:                   start_qr_scanner(video_element);
992: 990:                 });
993: 991:               }>Start QR Scanner</button>
994: 992:             }
995: 993:         }
996: 994:         "###);
997: 995:     }
998: 996: }
999: 997: ```
1000: 998: ```
1001: 999: ```
1002: 1000: ```
1003: 1001: ```
1004: 1002: ```
1005: 1003: ```
1006: 1004: ```
1007: 1005: ```
1008: 1006: ```
1009: 1007: ```
1010: 1008: ```
1011: 1009: ```
1012: 1010: ```
1013: 1011: ```
1014: 1012: ```
1015: 1013: ```
1016: 1014: ```
1017: 1015: ```
1018: 1016: ```
1019: 1017: ```
1020: 1018: ```
1021: ```
```
