### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\tests\memo.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\tests\memo.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
4: 2:     computed::{ArcMemo, Memo},
5: 3:     owner::Owner,
6: 4:     prelude::*,
7: 5:     signal::RwSignal,
8: 6:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal,
9: 7: };
10: 8: use std::{
11: 9:     rc::Rc,
12: 10:     sync::{Arc, RwLock},
13: 11: };
14: 12: 
15: 13: #[cfg(feature = "effects")]
16: 14: pub mod imports {
17: 15:     pub use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
18: 16:     pub use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
19: 17:         computed::{ArcMemo, Memo},
20: 18:         effect::{Effect, RenderEffect},
21: 19:         prelude::*,
22: 20:         signal::RwSignal,
23: 21:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal,
24: 22:     };
25: 23:     pub use std::{
26: 24:         mem,
27: 25:         rc::Rc,
28: 26:         sync::{Arc, RwLock},
29: 27:     };
30: 28:     pub use tokio::task;
31: 29: }
32: 30: 
33: 31: #[test]
34: 32: fn memo_calculates_value() {
35: 33:     let owner = Owner::new();
36: 34:     owner.set();
37: 35: 
38: 36:     let a = RwSignal::new(1);
39: 37:     let b = RwSignal::new(2);
40: 38:     let c = RwSignal::new(3);
41: 39: 
42: 40:     let d = Memo::new(move |_| a.get() + b.get() + c.get());
43: 41:     assert_eq!(d.read(), 6);
44: 42:     assert_eq!(d.with_untracked(|n| *n), 6);
45: 43:     assert_eq!(d.with(|n| *n), 6);
46: 44:     assert_eq!(d.get_untracked(), 6);
47: 45: }
48: 46: 
49: 47: #[test]
50: 48: fn arc_memo_readable() {
51: 49:     let owner = Owner::new();
52: 50:     owner.set();
53: 51: 
54: 52:     let a = RwSignal::new(1);
55: 53:     let b = RwSignal::new(2);
56: 54:     let c = RwSignal::new(3);
57: 55: 
58: 56:     let d = ArcMemo::new(move |_| a.get() + b.get() + c.get());
59: 57:     assert_eq!(d.read(), 6);
60: 58: }
61: 59: 
62: 60: #[test]
63: 61: fn memo_doesnt_repeat_calculation_per_get() {
64: 62:     let owner = Owner::new();
65: 63:     owner.set();
66: 64: 
67: 65:     let calculations = Arc::new(RwLock::new(0));
68: 66: 
69: 67:     let a = RwSignal::new(1);
70: 68:     let b = RwSignal::new(2);
71: 69:     let c = RwSignal::new(3);
72: 70: 
73: 71:     let d = Memo::new({
74: 72:         let calculations = Arc::clone(&calculations);
75: 73:         move |_| {
76: 74:             *calculations.write().unwrap() += 1;
77: 75:             a.get() + b.get() + c.get()
78: 76:         }
79: 77:     });
80: 78:     assert_eq!(d.get_untracked(), 6);
81: 79:     assert_eq!(d.get_untracked(), 6);
82: 80:     assert_eq!(d.get_untracked(), 6);
83: 81:     assert_eq!(*calculations.read().unwrap(), 1);
84: 82: 
85: 83:     println!("\n\n**setting to 0**");
86: 84:     a.set(0);
87: 85:     assert_eq!(d.get_untracked(), 5);
88: 86:     assert_eq!(*calculations.read().unwrap(), 2);
89: 87: }
90: 88: 
91: 89: #[test]
92: 90: fn nested_memos() {
93: 91:     let owner = Owner::new();
94: 92:     owner.set();
95: 93: 
96: 94:     let a = RwSignal::new(0); // 1
97: 95:     let b = RwSignal::new(0); // 2
98: 96:     let c = Memo::new(move |_| {
99: 97:         println!("calculating C");
100: 98:         a.get() + b.get()
101: 99:     }); // 3
102: 100:     let d = Memo::new(move |_| {
103: 101:         println!("calculating D");
104: 102:         c.get() * 2
105: 103:     }); // 4
106: 104:     let e = Memo::new(move |_| {
107: 105:         println!("calculating E");
108: 106:         d.get() + 1
109: 107:     }); // 5
110: 108:     assert_eq!(e.get_untracked(), 1);
111: 109:     assert_eq!(d.get_untracked(), 0);
112: 110:     assert_eq!(c.get_untracked(), 0);
113: 111: 
114: 112:     println!("\n\nFirst Set\n\n");
115: 113:     a.set(5);
116: 114:     assert_eq!(c.get_untracked(), 5);
117: 115:     assert_eq!(d.get_untracked(), 10);
118: 116:     assert_eq!(e.get_untracked(), 11);
119: 117: 
120: 118:     println!("\n\nSecond Set\n\n");
121: 119:     b.set(1);
122: 120:     assert_eq!(e.get_untracked(), 13);
123: 121:     assert_eq!(d.get_untracked(), 12);
124: 122:     assert_eq!(c.get_untracked(), 6);
125: 123: }
126: 124: 
127: 125: #[test]
128: 126: fn memo_runs_only_when_inputs_change() {
129: 127:     let owner = Owner::new();
130: 128:     owner.set();
131: 129: 
132: 130:     let call_count = Arc::new(RwLock::new(0));
133: 131:     let a = RwSignal::new(0);
134: 132:     let b = RwSignal::new(0);
135: 133:     let c = RwSignal::new(0);
136: 134: 
137: 135:     // pretend that this is some kind of expensive computation and we need to access its its value often
138: 136:     // we could do this with a derived signal, but that would re-run the computation
139: 137:     // memos should only run when their inputs actually change: this is the only point
140: 138:     let c = Memo::new({
141: 139:         let call_count = call_count.clone();
142: 140:         move |_| {
143: 141:             let mut call_count = call_count.write().unwrap();
144: 142:             *call_count += 1;
145: 143: 
146: 144:             a.get() + b.get() + c.get()
147: 145:         }
148: 146:     });
149: 147: 
150: 148:     // initially the memo has not been called at all, because it's lazy
151: 149:     assert_eq!(*call_count.read().unwrap(), 0);
152: 150: 
153: 151:     // here we access the value a bunch of times
154: 152:     assert_eq!(c.get_untracked(), 0);
155: 153:     assert_eq!(c.get_untracked(), 0);
156: 154:     assert_eq!(c.get_untracked(), 0);
157: 155:     assert_eq!(c.get_untracked(), 0);
158: 156:     assert_eq!(c.get_untracked(), 0);
159: 157: 
160: 158:     // we've still only called the memo calculation once
161: 159:     assert_eq!(*call_count.read().unwrap(), 1);
162: 160: 
163: 161:     // and we only call it again when an input changes
164: 162:     a.set(1);
165: 163:     assert_eq!(c.get_untracked(), 1);
166: 164:     assert_eq!(*call_count.read().unwrap(), 2);
167: 165: }
168: 166: 
169: 167: #[test]
170: 168: fn diamond_problem() {
171: 169:     let owner = Owner::new();
172: 170:     owner.set();
173: 171: 
174: 172:     let name = RwSignal::new("Greg Johnston".to_string());
175: 173:     let first = Memo::new(move |_| {
176: 174:         println!("calculating first");
177: 175:         name.get().split_whitespace().next().unwrap().to_string()
178: 176:     });
179: 177:     let last = Memo::new(move |_| {
180: 178:         println!("calculating last");
181: 179:         name.get().split_whitespace().nth(1).unwrap().to_string()
182: 180:     });
183: 181: 
184: 182:     let combined_count = Arc::new(RwLock::new(0));
185: 183:     let combined = Memo::new({
186: 184:         let combined_count = Arc::clone(&combined_count);
187: 185:         move |_| {
188: 186:             println!("calculating combined");
189: 187:             let mut combined_count = combined_count.write().unwrap();
190: 188:             *combined_count += 1;
191: 189: 
192: 190:             format!("{} {}", first.get(), last.get())
193: 191:         }
194: 192:     });
195: 193: 
196: 194:     assert_eq!(first.get_untracked(), "Greg");
197: 195:     assert_eq!(last.get_untracked(), "Johnston");
198: 196: 
199: 197:     name.set("Will Smith".to_string());
200: 198:     assert_eq!(first.get_untracked(), "Will");
201: 199:     assert_eq!(last.get_untracked(), "Smith");
202: 200:     assert_eq!(combined.get_untracked(), "Will Smith");
203: 201:     // should not have run the memo logic twice, even
204: 202:     // though both paths have been updated
205: 203:     assert_eq!(*combined_count.read().unwrap(), 1);
206: 204: }
207: 205: 
208: 206: #[cfg(feature = "effects")]
209: 207: #[tokio::test]
210: 208: async fn dynamic_dependencies() {
211: 209:     let owner = Owner::new();
212: 210:     owner.set();
213: 211: 
214: 212:     use imports::*;
215: 213: 
216: 214:     _ = Executor::init_tokio();
217: 215:     let owner = Owner::new();
218: 216:     owner.set();
219: 217: 
220: 218:     let first = RwSignal::new("Greg");
221: 219:     let last = RwSignal::new("Johnston");
222: 220:     let use_last = RwSignal::new(true);
223: 221:     let name = Memo::new(move |_| {
224: 222:         if use_last.get() {
225: 223:             format!("{} {}", first.get(), last.get())
226: 224:         } else {
227: 225:             first.get().to_string()
228: 226:         }
229: 227:     });
230: 228: 
231: 229:     let combined_count = Arc::new(RwLock::new(0));
232: 230: 
233: 231:     // we forget it so it continues running
234: 232:     // if it's dropped, it will stop listening
235: 233:     println!("[Initial]");
236: 234:     Effect::new_sync({
237: 235:         let combined_count = Arc::clone(&combined_count);
238: 236:         move |_| {
239: 237:             println!("Effect running.");
240: 238:             _ = name.get();
241: 239:             *combined_count.write().unwrap() += 1;
242: 240:         }
243: 241:     });
244: 242:     Executor::tick().await;
245: 243:     println!("[After 1 tick]");
246: 244: 
247: 245:     assert_eq!(*combined_count.read().unwrap(), 1);
248: 246: 
249: 247:     println!("[Set 'Bob']");
250: 248:     first.set("Bob");
251: 249:     Executor::tick().await;
252: 250: 
253: 251:     assert_eq!(name.get_untracked(), "Bob Johnston");
254: 252: 
255: 253:     assert_eq!(*combined_count.read().unwrap(), 2);
256: 254: 
257: 255:     println!("[Set 'Thompson']");
258: 256:     last.set("Thompson");
259: 257:     Executor::tick().await;
260: 258: 
261: 259:     assert_eq!(*combined_count.read().unwrap(), 3);
262: 260: 
263: 261:     use_last.set(false);
264: 262:     Executor::tick().await;
265: 263: 
266: 264:     assert_eq!(name.get_untracked(), "Bob");
267: 265:     assert_eq!(*combined_count.read().unwrap(), 4);
268: 266: 
269: 267:     assert_eq!(*combined_count.read().unwrap(), 4);
270: 268:     last.set("Jones");
271: 269:     Executor::tick().await;
272: 270: 
273: 271:     assert_eq!(*combined_count.read().unwrap(), 4);
274: 272:     last.set("Smith");
275: 273:     Executor::tick().await;
276: 274: 
277: 275:     assert_eq!(*combined_count.read().unwrap(), 4);
278: 276:     last.set("Stevens");
279: 277:     Executor::tick().await;
280: 278: 
281: 279:     assert_eq!(*combined_count.read().unwrap(), 4);
282: 280: 
283: 281:     use_last.set(true);
284: 282:     Executor::tick().await;
285: 283:     assert_eq!(name.get_untracked(), "Bob Stevens");
286: 284: 
287: 285:     assert_eq!(*combined_count.read().unwrap(), 5);
288: 286: }
289: 287: 
290: 288: #[cfg(feature = "effects")]
291: 289: #[tokio::test]
292: 290: async fn render_effect_doesnt_rerun_if_memo_didnt_change() {
293: 291:     let owner = Owner::new();
294: 292:     owner.set();
295: 293: 
296: 294:     use imports::*;
297: 295: 
298: 296:     _ = Executor::init_tokio();
299: 297:     let owner = Owner::new();
300: 298:     owner.set();
301: 299: 
302: 300:     task::LocalSet::new()
303: 301:         .run_until(async {
304: 302:             let count = RwSignal::new(1);
305: 303:             let even = Memo::new(move |_| *count.read() % 2 == 0);
306: 304: 
307: 305:             let combined_count = Arc::new(RwLock::new(0));
308: 306: 
309: 307:             println!("[Initial]");
310: 308:             mem::forget(RenderEffect::new({
311: 309:                 let combined_count = Arc::clone(&combined_count);
312: 310:                 move |_| {
313: 311:                     println!("INSIDE RENDEREFFECT");
314: 312:                     *combined_count.write().unwrap() += 1;
315: 313:                     println!("even = {}", even.get());
316: 314:                 }
317: 315:             }));
318: 316: 
319: 317:             Executor::tick().await;
320: 318:             assert_eq!(*combined_count.read().unwrap(), 1);
321: 319:             println!("[done]\n");
322: 320: 
323: 321:             println!("\n[Set Signal to 2]");
324: 322:             count.set(2);
325: 323:             Executor::tick().await;
326: 324:             assert_eq!(*combined_count.read().unwrap(), 2);
327: 325:             println!("[done]\n");
328: 326: 
329: 327:             println!("\n[Set Signal to 4]");
330: 328:             count.set(4);
331: 329:             Executor::tick().await;
332: 330:             assert_eq!(*combined_count.read().unwrap(), 2);
333: 331:             println!("[done]\n");
334: 332:         })
335: 333:         .await
336: 334: }
337: 335: 
338: 336: #[cfg(feature = "effects")]
339: 337: #[tokio::test]
340: 338: async fn effect_doesnt_rerun_if_memo_didnt_change() {
341: 339:     let owner = Owner::new();
342: 340:     owner.set();
343: 341: 
344: 342:     use imports::*;
345: 343: 
346: 344:     _ = Executor::init_tokio();
347: 345:     let owner = Owner::new();
348: 346:     owner.set();
349: 347: 
350: 348:     task::LocalSet::new()
351: 349:         .run_until(async {
352: 350:             let count = RwSignal::new(1);
353: 351:             let even = Memo::new(move |_| *count.read() % 2 == 0);
354: 352: 
355: 353:             let combined_count = Arc::new(RwLock::new(0));
356: 354: 
357: 355:             Effect::new({
358: 356:                 let combined_count = Arc::clone(&combined_count);
359: 357:                 move |_| {
360: 358:                     *combined_count.write().unwrap() += 1;
361: 359:                     println!("even = {}", even.get());
362: 360:                 }
363: 361:             });
364: 362: 
365: 363:             Executor::tick().await;
366: 364:             assert_eq!(*combined_count.read().unwrap(), 1);
367: 365: 
368: 366:             count.set(2);
369: 367:             Executor::tick().await;
370: 368:             assert_eq!(*combined_count.read().unwrap(), 2);
371: 369: 
372: 370:             count.set(4);
373: 371:             Executor::tick().await;
374: 372:             assert_eq!(*combined_count.read().unwrap(), 2);
375: 373:         })
376: 374:         .await
377: 375: }
378: 376: 
379: 377: #[cfg(feature = "effects")]
380: 378: #[tokio::test]
381: 379: async fn effect_depending_on_signal_and_memo_doesnt_rerun_unnecessarily() {
382: 380:     let owner = Owner::new();
383: 381:     owner.set();
384: 382: 
385: 383:     use imports::*;
386: 384: 
387: 385:     _ = Executor::init_tokio();
388: 386:     let owner = Owner::new();
389: 387:     owner.set();
390: 388: 
391: 389:     task::LocalSet::new()
392: 390:         .run_until(async {
393: 391:             let other_signal = RwSignal::new(false);
394: 392:             let count = RwSignal::new(1);
395: 393:             let even = Memo::new(move |_| *count.read() % 2 == 0);
396: 394: 
397: 395:             let combined_count = Arc::new(RwLock::new(0));
398: 396: 
399: 397:             Effect::new({
400: 398:                 let combined_count = Arc::clone(&combined_count);
401: 399:                 move |_| {
402: 400:                     *combined_count.write().unwrap() += 1;
403: 401:                     println!(
404: 402:                         "even = {}\nother_signal = {}",
405: 403:                         even.get(),
406: 404:                         other_signal.get()
407: 405:                     );
408: 406:                 }
409: 407:             });
410: 408: 
411: 409:             Executor::tick().await;
412: 410:             assert_eq!(*combined_count.read().unwrap(), 1);
413: 411: 
414: 412:             count.set(2);
415: 413:             Executor::tick().await;
416: 414:             assert_eq!(*combined_count.read().unwrap(), 2);
417: 415: 
418: 416:             count.set(4);
419: 417:             Executor::tick().await;
420: 418:             assert_eq!(*combined_count.read().unwrap(), 2);
421: 419:         })
422: 420:         .await
423: 421: }
424: 422: 
425: 423: #[test]
426: 424: fn unsync_derived_signal_and_memo() {
427: 425:     let owner = Owner::new();
428: 426:     owner.set();
429: 427: 
430: 428:     let a = RwSignal::new_local(Rc::new(1));
431: 429:     let b = RwSignal::new(2);
432: 430:     let c = RwSignal::new(3);
433: 431:     let d = Memo::new(move |_| *a.get() + b.get() + c.get());
434: 432: 
435: 433:     let e = Rc::new(0);
436: 434:     let f = Signal::derive_local(move || d.get() + *e);
437: 435: 
438: 436:     assert_eq!(d.read(), 6);
439: 437:     assert_eq!(d.with_untracked(|n| *n), 6);
440: 438:     assert_eq!(d.with(|n| *n), 6);
441: 439:     assert_eq!(d.get_untracked(), 6);
442: 440: 
443: 441:     // derived signal also works
444: 442:     assert_eq!(f.with_untracked(|n| *n), 6);
445: 443:     assert_eq!(f.with(|n| *n), 6);
446: 444:     assert_eq!(f.get_untracked(), 6);
447: 445: }
448: 446: 
449: 447: #[cfg(feature = "effects")]
450: 448: #[tokio::test]
451: 449: async fn test_memo_multiple_read_guards() {
452: 450:     // regression test for https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/3158
453: 451:     let owner = Owner::new();
454: 452:     owner.set();
455: 453:     use imports::*;
456: 454: 
457: 455:     _ = Executor::init_tokio();
458: 456:     let owner = Owner::new();
459: 457:     owner.set();
460: 458:     task::LocalSet::new()
461: 459:         .run_until(async {
462: 460:             let memo = Memo::<i32>::new_with_compare(|_| 42, |_, _| true);
463: 461: 
464: 462:             Effect::new(move |_| {
465: 463:                 let guard_a = memo.read();
466: 464:                 let guard_b = memo.read();
467: 465:                 assert_eq!(guard_a, 42);
468: 466:                 assert_eq!(guard_b, 42);
469: 467:             });
470: 468:             Executor::tick().await;
471: 469:         })
472: 470:         .await
473: 471: }
474: 472: 
475: 473: #[cfg(feature = "effects")]
476: 474: #[tokio::test]
477: 475: async fn test_memo_read_guard_held() {
478: 476:     // regression test for https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/3252
479: 477:     let owner = Owner::new();
480: 478:     owner.set();
481: 479:     use imports::*;
482: 480: 
483: 481:     _ = Executor::init_tokio();
484: 482:     let owner = Owner::new();
485: 483:     owner.set();
486: 484:     task::LocalSet::new()
487: 485:         .run_until(async {
488: 486:             let source = RwSignal::new(0);
489: 487: 
490: 488:             let directly_derived =
491: 489:                 Memo::new_with_compare(move |_| source.get(), |_, _| true);
492: 490:             let indirect = Memo::new_with_compare(
493: 491:                 move |_| directly_derived.get(),
494: 492:                 |_, _| true,
495: 493:             );
496: 494: 
497: 495:             Effect::new(move |_| {
498: 496:                 let direct_value = directly_derived.read();
499: 497:                 let indirect_value = indirect.get();
500: 498:                 assert_eq!(direct_value, indirect_value);
501: 499:             });
502: 500: 
503: 501:             Executor::tick().await;
504: 502:             source.set(1);
505: 503:             Executor::tick().await;
506: 504:             source.set(2);
507: 505:             Executor::tick().await;
508: 506:         })
509: 507:         .await
510: 508: }
511: 509: 
512: 510: #[test]
513: 511: fn memo_updates_even_if_not_read_until_later() {
514: 512:     #![allow(clippy::bool_assert_comparison)]
515: 513: 
516: 514:     let owner = Owner::new();
517: 515:     owner.set();
518: 516: 
519: 517:     // regression test for https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/3339
520: 518: 
521: 519:     let input = RwSignal::new(0);
522: 520:     let first_memo = Memo::new(move |_| input.get() == 1);
523: 521:     let second_memo = Memo::new(move |_| first_memo.get());
524: 522: 
525: 523:     assert_eq!(input.get(), 0);
526: 524:     assert_eq!(first_memo.get(), false);
527: 525: 
528: 526:     println!("update to 1");
529: 527:     input.set(1);
530: 528:     assert_eq!(input.get(), 1);
531: 529:     println!("read memo 1");
532: 530:     assert_eq!(first_memo.get(), true);
533: 531:     println!("read memo 2");
534: 532:     assert_eq!(second_memo.get(), true);
535: 533: 
536: 534:     // this time, we don't read the memo
537: 535:     println!("\nupdate to 2");
538: 536:     input.set(2);
539: 537:     assert_eq!(input.get(), 2);
540: 538:     println!("read memo 1");
541: 539:     assert_eq!(first_memo.get(), false);
542: 540: 
543: 541:     println!("\nupdate to 3");
544: 542:     input.set(3);
545: 543:     assert_eq!(input.get(), 3);
546: 544:     println!("read memo 1");
547: 545:     assert_eq!(first_memo.get(), false);
548: 546:     println!("read memo 2");
549: 547:     assert_eq!(second_memo.get(), false);
550: 548: }
551: ```
```
