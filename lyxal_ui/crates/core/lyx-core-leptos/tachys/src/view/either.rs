### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\either.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\either.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     add_attr::AddAnyAttr, MarkBranch, Mountable, Position, PositionState,
21: 19:     Render, RenderHtml,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::{
25: 23:         any_attribute::AnyAttribute, Attribute, NamedAttributeKey,
26: 24:         NextAttribute,
27: 25:     },
28: 26:     hydration::Cursor,
29: 27:     ssr::StreamBuilder,
30: 28: };
31: 29: use lyx-core-lyx_core_lyx-core-lyx_core_either_of::*;
32: 30: use futures::future::join;
33: 31: 
34: 32: impl<A, B> Render for Either<A, B>
35: 33: where
36: 34:     A: Render,
37: 35:     B: Render,
38: 36: {
39: 37:     type State = Either<A::State, B::State>;
40: 38: 
41: 39:     fn build(self) -> Self::State {
42: 40:         match self {
43: 41:             Either::Left(left) => Either::Left(left.build()),
44: 42:             Either::Right(right) => Either::Right(right.build()),
45: 43:         }
46: 44:     }
47: 45: 
48: 46:     fn rebuild(self, state: &mut Self::State) {
49: 47:         match (self, &mut *state) {
50: 48:             (Either::Left(new), Either::Left(old)) => {
51: 49:                 new.rebuild(old);
52: 50:             }
53: 51:             (Either::Right(new), Either::Right(old)) => {
54: 52:                 new.rebuild(old);
55: 53:             }
56: 54:             (Either::Right(new), Either::Left(old)) => {
57: 55:                 let mut new_state = new.build();
58: 56:                 old.insert_before_this(&mut new_state);
59: 57:                 old.unmount();
60: 58:                 *state = Either::Right(new_state);
61: 59:             }
62: 60:             (Either::Left(new), Either::Right(old)) => {
63: 61:                 let mut new_state = new.build();
64: 62:                 old.insert_before_this(&mut new_state);
65: 63:                 old.unmount();
66: 64:                 *state = Either::Left(new_state);
67: 65:             }
68: 66:         }
69: 67:     }
70: 68: }
71: 69: 
72: 70: impl<A, B> Mountable for Either<A, B>
73: 71: where
74: 72:     A: Mountable,
75: 73:     B: Mountable,
76: 74: {
77: 75:     fn unmount(&mut self) {
78: 76:         match self {
79: 77:             Either::Left(left) => left.unmount(),
80: 78:             Either::Right(right) => right.unmount(),
81: 79:         }
82: 80:     }
83: 81: 
84: 82:     fn mount(
85: 83:         &mut self,
86: 84:         parent: &crate::renderer::types::Element,
87: 85:         marker: Option<&crate::renderer::types::Node>,
88: 86:     ) {
89: 87:         match self {
90: 88:             Either::Left(left) => left.mount(parent, marker),
91: 89:             Either::Right(right) => right.mount(parent, marker),
92: 90:         }
93: 91:     }
94: 92: 
95: 93:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
96: 94:         match &self {
97: 95:             Either::Left(left) => left.insert_before_this(child),
98: 96:             Either::Right(right) => right.insert_before_this(child),
99: 97:         }
100: 98:     }
101: 99: 
102: 100:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
103: 101:         match &self {
104: 102:             Either::Left(left) => left.elements(),
105: 103:             Either::Right(right) => right.elements(),
106: 104:         }
107: 105:     }
108: 106: }
109: 107: 
110: 108: impl<A, B> AddAnyAttr for Either<A, B>
111: 109: where
112: 110:     A: RenderHtml,
113: 111:     B: RenderHtml,
114: 112: {
115: 113:     type Output<SomeNewAttr: Attribute> = Either<
116: 114:         <A as AddAnyAttr>::Output<SomeNewAttr>,
117: 115:         <B as AddAnyAttr>::Output<SomeNewAttr>,
118: 116:     >;
119: 117: 
120: 118:     fn add_any_attr<NewAttr: Attribute>(
121: 119:         self,
122: 120:         attr: NewAttr,
123: 121:     ) -> Self::Output<NewAttr>
124: 122:     where
125: 123:         Self::Output<NewAttr>: RenderHtml,
126: 124:     {
127: 125:         match self {
128: 126:             Either::Left(i) => Either::Left(i.add_any_attr(attr)),
129: 127:             Either::Right(i) => Either::Right(i.add_any_attr(attr)),
130: 128:         }
131: 129:     }
132: 130: }
133: 131: 
134: 132: const fn max_usize(vals: &[usize]) -> usize {
135: 133:     let mut max = 0;
136: 134:     let len = vals.len();
137: 135:     let mut i = 0;
138: 136:     while i < len {
139: 137:         if vals[i] > max {
140: 138:             max = vals[i];
141: 139:         }
142: 140:         i += 1;
143: 141:     }
144: 142:     max
145: 143: }
146: 144: 
147: 145: #[cfg(not(erase_components))]
148: 146: impl<A, B> NextAttribute for Either<A, B>
149: 147: where
150: 148:     B: NextAttribute,
151: 149:     A: NextAttribute,
152: 150: {
153: 151:     type Output<NewAttr: Attribute> = Either<
154: 152:         <A as NextAttribute>::Output<NewAttr>,
155: 153:         <B as NextAttribute>::Output<NewAttr>,
156: 154:     >;
157: 155: 
158: 156:     fn add_any_attr<NewAttr: Attribute>(
159: 157:         self,
160: 158:         new_attr: NewAttr,
161: 159:     ) -> Self::Output<NewAttr> {
162: 160:         match self {
163: 161:             Either::Left(left) => Either::Left(left.add_any_attr(new_attr)),
164: 162:             Either::Right(right) => Either::Right(right.add_any_attr(new_attr)),
165: 163:         }
166: 164:     }
167: 165: }
168: 166: 
169: 167: #[cfg(erase_components)]
170: 168: impl<A, B> NextAttribute for Either<A, B>
171: 169: where
172: 170:     B: crate::html::attribute::any_attribute::IntoAnyAttribute,
173: 171:     A: crate::html::attribute::any_attribute::IntoAnyAttribute,
174: 172: {
175: 173:     type Output<NewAttr: Attribute> = Vec<AnyAttribute>;
176: 174: 
177: 175:     fn add_any_attr<NewAttr: Attribute>(
178: 176:         self,
179: 177:         new_attr: NewAttr,
180: 178:     ) -> Self::Output<NewAttr> {
181: 179:         use crate::html::attribute::any_attribute::IntoAnyAttribute;
182: 180: 
183: 181:         vec![
184: 182:             match self {
185: 183:                 Either::Left(left) => left.into_any_attr(),
186: 184:                 Either::Right(right) => right.into_any_attr(),
187: 185:             },
188: 186:             new_attr.into_any_attr(),
189: 187:         ]
190: 188:     }
191: 189: }
192: 190: 
193: 191: impl<A, B> Attribute for Either<A, B>
194: 192: where
195: 193:     B: Attribute,
196: 194:     A: Attribute,
197: 195: {
198: 196:     const MIN_LENGTH: usize = max_usize(&[A::MIN_LENGTH, B::MIN_LENGTH]);
199: 197: 
200: 198:     type AsyncOutput = Either<A::AsyncOutput, B::AsyncOutput>;
201: 199:     type State = Either<A::State, B::State>;
202: 200:     type Cloneable = Either<A::Cloneable, B::Cloneable>;
203: 201:     type CloneableOwned = Either<A::CloneableOwned, B::CloneableOwned>;
204: 202: 
205: 203:     fn html_len(&self) -> usize {
206: 204:         match self {
207: 205:             Either::Left(left) => left.html_len(),
208: 206:             Either::Right(right) => right.html_len(),
209: 207:         }
210: 208:     }
211: 209: 
212: 210:     fn to_html(
213: 211:         self,
214: 212:         buf: &mut String,
215: 213:         class: &mut String,
216: 214:         style: &mut String,
217: 215:         inner_html: &mut String,
218: 216:     ) {
219: 217:         match self {
220: 218:             Either::Left(left) => left.to_html(buf, class, style, inner_html),
221: 219:             Either::Right(right) => {
222: 220:                 right.to_html(buf, class, style, inner_html)
223: 221:             }
224: 222:         }
225: 223:     }
226: 224: 
227: 225:     fn hydrate<const FROM_SERVER: bool>(
228: 226:         self,
229: 227:         el: &crate::renderer::types::Element,
230: 228:     ) -> Self::State {
231: 229:         match self {
232: 230:             Either::Left(left) => Either::Left(left.hydrate::<FROM_SERVER>(el)),
233: 231:             Either::Right(right) => {
234: 232:                 Either::Right(right.hydrate::<FROM_SERVER>(el))
235: 233:             }
236: 234:         }
237: 235:     }
238: 236: 
239: 237:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
240: 238:         match self {
241: 239:             Either::Left(left) => Either::Left(left.build(el)),
242: 240:             Either::Right(right) => Either::Right(right.build(el)),
243: 241:         }
244: 242:     }
245: 243: 
246: 244:     fn rebuild(self, state: &mut Self::State) {
247: 245:         match self {
248: 246:             Either::Left(left) => {
249: 247:                 if let Some(state) = state.as_left_mut() {
250: 248:                     left.rebuild(state)
251: 249:                 }
252: 250:             }
253: 251:             Either::Right(right) => {
254: 252:                 if let Some(state) = state.as_right_mut() {
255: 253:                     right.rebuild(state)
256: 254:                 }
257: 255:             }
258: 256:         }
259: 257:     }
260: 258: 
261: 259:     fn into_cloneable(self) -> Self::Cloneable {
262: 260:         match self {
263: 261:             Either::Left(left) => Either::Left(left.into_cloneable()),
264: 262:             Either::Right(right) => Either::Right(right.into_cloneable()),
265: 263:         }
266: 264:     }
267: 265: 
268: 266:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
269: 267:         match self {
270: 268:             Either::Left(left) => Either::Left(left.into_cloneable_owned()),
271: 269:             Either::Right(right) => Either::Right(right.into_cloneable_owned()),
272: 270:         }
273: 271:     }
274: 272: 
275: 273:     fn dry_resolve(&mut self) {
276: 274:         match self {
277: 275:             Either::Left(left) => left.dry_resolve(),
278: 276:             Either::Right(right) => right.dry_resolve(),
279: 277:         }
280: 278:     }
281: 279: 
282: 280:     async fn resolve(self) -> Self::AsyncOutput {
283: 281:         match self {
284: 282:             Either::Left(left) => Either::Left(left.resolve().await),
285: 283:             Either::Right(right) => Either::Right(right.resolve().await),
286: 284:         }
287: 285:     }
288: 286: 
289: 287:     fn keys(&self) -> Vec<NamedAttributeKey> {
290: 288:         match self {
291: 289:             Either::Left(left) => left.keys(),
292: 290:             Either::Right(right) => right.keys(),
293: 291:         }
294: 292:     }
295: 293: }
296: 294: 
297: 295: impl<A, B> RenderHtml for Either<A, B>
298: 296: where
299: 297:     A: RenderHtml,
300: 298:     B: RenderHtml,
301: 299: {
302: 300:     type AsyncOutput = Either<A::AsyncOutput, B::AsyncOutput>;
303: 301:     type Owned = Either<A::Owned, B::Owned>;
304: 302: 
305: 303:     fn dry_resolve(&mut self) {
306: 304:         match self {
307: 305:             Either::Left(left) => left.dry_resolve(),
308: 306:             Either::Right(right) => right.dry_resolve(),
309: 307:         }
310: 308:     }
311: 309: 
312: 310:     async fn resolve(self) -> Self::AsyncOutput {
313: 311:         match self {
314: 312:             Either::Left(left) => Either::Left(left.resolve().await),
315: 313:             Either::Right(right) => Either::Right(right.resolve().await),
316: 314:         }
317: 315:     }
318: 316: 
319: 317:     const MIN_LENGTH: usize = max_usize(&[A::MIN_LENGTH, B::MIN_LENGTH]);
320: 318: 
321: 319:     #[inline(always)]
322: 320:     fn html_len(&self) -> usize {
323: 321:         match self {
324: 322:             Either::Left(i) => i.html_len(),
325: 323:             Either::Right(i) => i.html_len(),
326: 324:         }
327: 325:     }
328: 326: 
329: 327:     fn to_html_with_buf(
330: 328:         self,
331: 329:         buf: &mut String,
332: 330:         position: &mut Position,
333: 331:         escape: bool,
334: 332:         mark_branches: bool,
335: 333:         extra_attrs: Vec<AnyAttribute>,
336: 334:     ) {
337: 335:         match self {
338: 336:             Either::Left(left) => {
339: 337:                 if mark_branches && escape {
340: 338:                     buf.open_branch("0");
341: 339:                 }
342: 340:                 left.to_html_with_buf(
343: 341:                     buf,
344: 342:                     position,
345: 343:                     escape,
346: 344:                     mark_branches,
347: 345:                     extra_attrs,
348: 346:                 );
349: 347:                 if mark_branches && escape {
350: 348:                     buf.close_branch("0");
351: 349:                     if *position == Position::NextChildAfterText {
352: 350:                         *position = Position::NextChild;
353: 351:                     }
354: 352:                 }
355: 353:             }
356: 354:             Either::Right(right) => {
357: 355:                 if mark_branches && escape {
358: 356:                     buf.open_branch("1");
359: 357:                 }
360: 358:                 right.to_html_with_buf(
361: 359:                     buf,
362: 360:                     position,
363: 361:                     escape,
364: 362:                     mark_branches,
365: 363:                     extra_attrs,
366: 364:                 );
367: 365:                 if mark_branches && escape {
368: 366:                     buf.close_branch("1");
369: 367:                     if *position == Position::NextChildAfterText {
370: 368:                         *position = Position::NextChild;
371: 369:                     }
372: 370:                 }
373: 371:             }
374: 372:         }
375: 373:     }
376: 374: 
377: 375:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
378: 376:         self,
379: 377:         buf: &mut StreamBuilder,
380: 378:         position: &mut Position,
381: 379:         escape: bool,
382: 380:         mark_branches: bool,
383: 381:         extra_attrs: Vec<AnyAttribute>,
384: 382:     ) where
385: 383:         Self: Sized,
386: 384:     {
387: 385:         match self {
388: 386:             Either::Left(left) => {
389: 387:                 if mark_branches && escape {
390: 388:                     buf.open_branch("0");
391: 389:                 }
392: 390:                 left.to_html_async_with_buf::<OUT_OF_ORDER>(
393: 391:                     buf,
394: 392:                     position,
395: 393:                     escape,
396: 394:                     mark_branches,
397: 395:                     extra_attrs,
398: 396:                 );
399: 397:                 if mark_branches && escape {
400: 398:                     buf.close_branch("0");
401: 399:                     if *position == Position::NextChildAfterText {
402: 400:                         *position = Position::NextChild;
403: 401:                     }
404: 402:                 }
405: 403:             }
406: 404:             Either::Right(right) => {
407: 405:                 if mark_branches && escape {
408: 406:                     buf.open_branch("1");
409: 407:                 }
410: 408:                 right.to_html_async_with_buf::<OUT_OF_ORDER>(
411: 409:                     buf,
412: 410:                     position,
413: 411:                     escape,
414: 412:                     mark_branches,
415: 413:                     extra_attrs,
416: 414:                 );
417: 415:                 if mark_branches && escape {
418: 416:                     buf.close_branch("1");
419: 417:                     if *position == Position::NextChildAfterText {
420: 418:                         *position = Position::NextChild;
421: 419:                     }
422: 420:                 }
423: 421:             }
424: 422:         }
425: 423:     }
426: 424: 
427: 425:     fn hydrate<const FROM_SERVER: bool>(
428: 426:         self,
429: 427:         cursor: &Cursor,
430: 428:         position: &PositionState,
431: 429:     ) -> Self::State {
432: 430:         match self {
433: 431:             Either::Left(left) => {
434: 432:                 Either::Left(left.hydrate::<FROM_SERVER>(cursor, position))
435: 433:             }
436: 434:             Either::Right(right) => {
437: 435:                 Either::Right(right.hydrate::<FROM_SERVER>(cursor, position))
438: 436:             }
439: 437:         }
440: 438:     }
441: 439: 
442: 440:     async fn hydrate_async(
443: 441:         self,
444: 442:         cursor: &Cursor,
445: 443:         position: &PositionState,
446: 444:     ) -> Self::State {
447: 445:         match self {
448: 446:             Either::Left(left) => {
449: 447:                 Either::Left(left.hydrate_async(cursor, position).await)
450: 448:             }
451: 449:             Either::Right(right) => {
452: 450:                 Either::Right(right.hydrate_async(cursor, position).await)
453: 451:             }
454: 452:         }
455: 453:     }
456: 454: 
457: 455:     fn into_owned(self) -> Self::Owned {
458: 456:         match self {
459: 457:             Either::Left(left) => Either::Left(left.into_owned()),
460: 458:             Either::Right(right) => Either::Right(right.into_owned()),
461: 459:         }
462: 460:     }
463: 461: }
464: 462: 
465: 463: /// Stores each value in the view state, overwriting it only if `Some(_)` is provided.
466: 464: pub struct EitherKeepAlive<A, B> {
467: 465:     /// The first possibility.
468: 466:     pub a: Option<A>,
469: 467:     /// The second possibility.
470: 468:     pub b: Option<B>,
471: 469:     /// If `true`, then `b` will be shown.
472: 470:     pub show_b: bool,
473: 471: }
474: 472: 
475: 473: /// Retained view state for [`EitherKeepAlive`].
476: 474: pub struct EitherKeepAliveState<A, B> {
477: 475:     a: Option<A>,
478: 476:     b: Option<B>,
479: 477:     showing_b: bool,
480: 478: }
481: 479: 
482: 480: impl<A, B> Render for EitherKeepAlive<A, B>
483: 481: where
484: 482:     A: Render,
485: 483:     B: Render,
486: 484: {
487: 485:     type State = EitherKeepAliveState<A::State, B::State>;
488: 486: 
489: 487:     fn build(self) -> Self::State {
490: 488:         let showing_b = self.show_b;
491: 489:         let a = self.a.map(Render::build);
492: 490:         let b = self.b.map(Render::build);
493: 491:         EitherKeepAliveState { a, b, showing_b }
494: 492:     }
495: 493: 
496: 494:     fn rebuild(self, state: &mut Self::State) {
497: 495:         // set or update A -- `None` just means "no change"
498: 496:         match (self.a, &mut state.a) {
499: 497:             (Some(new), Some(old)) => new.rebuild(old),
500: 498:             (Some(new), None) => state.a = Some(new.build()),
501: 499:             _ => {}
502: 500:         }
503: 501: 
504: 502:         // set or update B
505: 503:         match (self.b, &mut state.b) {
506: 504:             (Some(new), Some(old)) => new.rebuild(old),
507: 505:             (Some(new), None) => state.b = Some(new.build()),
508: 506:             _ => {}
509: 507:         }
510: 508: 
511: 509:         match (self.show_b, state.showing_b) {
512: 510:             // transition from A to B
513: 511:             (true, false) => match (&mut state.a, &mut state.b) {
514: 512:                 (Some(a), Some(b)) => {
515: 513:                     a.insert_before_this(b);
516: 514:                     a.unmount();
517: 515:                 }
518: 516:                 _ => unreachable!(),
519: 517:             },
520: 518:             // transition from B to A
521: 519:             (false, true) => match (&mut state.a, &mut state.b) {
522: 520:                 (Some(a), Some(b)) => {
523: 521:                     b.insert_before_this(a);
524: 522:                     b.unmount();
525: 523:                 }
526: 524:                 _ => unreachable!(),
527: 525:             },
528: 526:             _ => {}
529: 527:         }
530: 528:         state.showing_b = self.show_b;
531: 529:     }
532: 530: }
533: 531: 
534: 532: impl<A, B> AddAnyAttr for EitherKeepAlive<A, B>
535: 533: where
536: 534:     A: RenderHtml,
537: 535:     B: RenderHtml,
538: 536: {
539: 537:     type Output<SomeNewAttr: Attribute> = EitherKeepAlive<
540: 538:         <A as AddAnyAttr>::Output<SomeNewAttr::Cloneable>,
541: 539:         <B as AddAnyAttr>::Output<SomeNewAttr::Cloneable>,
542: 540:     >;
543: 541: 
544: 542:     fn add_any_attr<NewAttr: Attribute>(
545: 543:         self,
546: 544:         attr: NewAttr,
547: 545:     ) -> Self::Output<NewAttr>
548: 546:     where
549: 547:         Self::Output<NewAttr>: RenderHtml,
550: 548:     {
551: 549:         let EitherKeepAlive { a, b, show_b } = self;
552: 550:         let attr = attr.into_cloneable();
553: 551:         EitherKeepAlive {
554: 552:             a: a.map(|a| a.add_any_attr(attr.clone())),
555: 553:             b: b.map(|b| b.add_any_attr(attr.clone())),
556: 554:             show_b,
557: 555:         }
558: 556:     }
559: 557: }
560: 558: 
561: 559: impl<A, B> RenderHtml for EitherKeepAlive<A, B>
562: 560: where
563: 561:     A: RenderHtml,
564: 562:     B: RenderHtml,
565: 563: {
566: 564:     type AsyncOutput = EitherKeepAlive<A::AsyncOutput, B::AsyncOutput>;
567: 565:     type Owned = EitherKeepAlive<A::Owned, B::Owned>;
568: 566: 
569: 567:     const MIN_LENGTH: usize = 0;
570: 568: 
571: 569:     fn dry_resolve(&mut self) {
572: 570:         if let Some(inner) = &mut self.a {
573: 571:             inner.dry_resolve();
574: 572:         }
575: 573:         if let Some(inner) = &mut self.b {
576: 574:             inner.dry_resolve();
577: 575:         }
578: 576:     }
579: 577: 
580: 578:     async fn resolve(self) -> Self::AsyncOutput {
581: 579:         let EitherKeepAlive { a, b, show_b } = self;
582: 580:         let (a, b) = join(
583: 581:             async move {
584: 582:                 match a {
585: 583:                     Some(a) => Some(a.resolve().await),
586: 584:                     None => None,
587: 585:                 }
588: 586:             },
589: 587:             async move {
590: 588:                 match b {
591: 589:                     Some(b) => Some(b.resolve().await),
592: 590:                     None => None,
593: 591:                 }
594: 592:             },
595: 593:         )
596: 594:         .await;
597: 595:         EitherKeepAlive { a, b, show_b }
598: 596:     }
599: 597: 
600: 598:     fn to_html_with_buf(
601: 599:         self,
602: 600:         buf: &mut String,
603: 601:         position: &mut Position,
604: 602:         escape: bool,
605: 603:         mark_branches: bool,
606: 604:         extra_attrs: Vec<AnyAttribute>,
607: 605:     ) {
608: 606:         if self.show_b {
609: 607:             self.b
610: 608:                 .expect("rendering B to HTML without filling it")
611: 609:                 .to_html_with_buf(
612: 610:                     buf,
613: 611:                     position,
614: 612:                     escape,
615: 613:                     mark_branches,
616: 614:                     extra_attrs,
617: 615:                 );
618: 616:         } else {
619: 617:             self.a
620: 618:                 .expect("rendering A to HTML without filling it")
621: 619:                 .to_html_with_buf(
622: 620:                     buf,
623: 621:                     position,
624: 622:                     escape,
625: 623:                     mark_branches,
626: 624:                     extra_attrs,
627: 625:                 );
628: 626:         }
629: 627:     }
630: 628: 
631: 629:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
632: 630:         self,
633: 631:         buf: &mut StreamBuilder,
634: 632:         position: &mut Position,
635: 633:         escape: bool,
636: 634:         mark_branches: bool,
637: 635:         extra_attrs: Vec<AnyAttribute>,
638: 636:     ) where
639: 637:         Self: Sized,
640: 638:     {
641: 639:         if self.show_b {
642: 640:             self.b
643: 641:                 .expect("rendering B to HTML without filling it")
644: 642:                 .to_html_async_with_buf::<OUT_OF_ORDER>(
645: 643:                     buf,
646: 644:                     position,
647: 645:                     escape,
648: 646:                     mark_branches,
649: 647:                     extra_attrs,
650: 648:                 );
651: 649:         } else {
652: 650:             self.a
653: 651:                 .expect("rendering A to HTML without filling it")
654: 652:                 .to_html_async_with_buf::<OUT_OF_ORDER>(
655: 653:                     buf,
656: 654:                     position,
657: 655:                     escape,
658: 656:                     mark_branches,
659: 657:                     extra_attrs,
660: 658:                 );
661: 659:         }
662: 660:     }
663: 661: 
664: 662:     fn hydrate<const FROM_SERVER: bool>(
665: 663:         self,
666: 664:         cursor: &Cursor,
667: 665:         position: &PositionState,
668: 666:     ) -> Self::State {
669: 667:         let showing_b = self.show_b;
670: 668:         let a = self.a.map(|a| {
671: 669:             if showing_b {
672: 670:                 a.build()
673: 671:             } else {
674: 672:                 a.hydrate::<FROM_SERVER>(cursor, position)
675: 673:             }
676: 674:         });
677: 675:         let b = self.b.map(|b| {
678: 676:             if showing_b {
679: 677:                 b.hydrate::<FROM_SERVER>(cursor, position)
680: 678:             } else {
681: 679:                 b.build()
682: 680:             }
683: 681:         });
684: 682: 
685: 683:         EitherKeepAliveState { showing_b, a, b }
686: 684:     }
687: 685: 
688: 686:     async fn hydrate_async(
689: 687:         self,
690: 688:         cursor: &Cursor,
691: 689:         position: &PositionState,
692: 690:     ) -> Self::State {
693: 691:         let showing_b = self.show_b;
694: 692:         let a = if let Some(a) = self.a {
695: 693:             Some(if showing_b {
696: 694:                 a.build()
697: 695:             } else {
698: 696:                 a.hydrate_async(cursor, position).await
699: 697:             })
700: 698:         } else {
701: 699:             None
702: 700:         };
703: 701:         let b = if let Some(b) = self.b {
704: 702:             Some(if showing_b {
705: 703:                 b.hydrate_async(cursor, position).await
706: 704:             } else {
707: 705:                 b.build()
708: 706:             })
709: 707:         } else {
710: 708:             None
711: 709:         };
712: 710: 
713: 711:         EitherKeepAliveState { showing_b, a, b }
714: 712:     }
715: 713: 
716: 714:     fn into_owned(self) -> Self::Owned {
717: 715:         EitherKeepAlive {
718: 716:             a: self.a.map(|a| a.into_owned()),
719: 717:             b: self.b.map(|b| b.into_owned()),
720: 718:             show_b: self.show_b,
721: 719:         }
722: 720:     }
723: 721: }
724: 722: 
725: 723: impl<A, B> Mountable for EitherKeepAliveState<A, B>
726: 724: where
727: 725:     A: Mountable,
728: 726:     B: Mountable,
729: 727: {
730: 728:     fn unmount(&mut self) {
731: 729:         if self.showing_b {
732: 730:             self.b.as_mut().expect("B was not present").unmount();
733: 731:         } else {
734: 732:             self.a.as_mut().expect("A was not present").unmount();
735: 733:         }
736: 734:     }
737: 735: 
738: 736:     fn mount(
739: 737:         &mut self,
740: 738:         parent: &crate::renderer::types::Element,
741: 739:         marker: Option<&crate::renderer::types::Node>,
742: 740:     ) {
743: 741:         if self.showing_b {
744: 742:             self.b
745: 743:                 .as_mut()
746: 744:                 .expect("B was not present")
747: 745:                 .mount(parent, marker);
748: 746:         } else {
749: 747:             self.a
750: 748:                 .as_mut()
751: 749:                 .expect("A was not present")
752: 750:                 .mount(parent, marker);
753: 751:         }
754: 752:     }
755: 753: 
756: 754:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
757: 755:         if self.showing_b {
758: 756:             self.b
759: 757:                 .as_ref()
760: 758:                 .expect("B was not present")
761: 759:                 .insert_before_this(child)
762: 760:         } else {
763: 761:             self.a
764: 762:                 .as_ref()
765: 763:                 .expect("A was not present")
766: 764:                 .insert_before_this(child)
767: 765:         }
768: 766:     }
769: 767: 
770: 768:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
771: 769:         if self.showing_b {
772: 770:             self.b
773: 771:                 .as_ref()
774: 772:                 .map(|inner| inner.elements())
775: 773:                 .unwrap_or_default()
776: 774:         } else {
777: 775:             self.a
778: 776:                 .as_ref()
779: 777:                 .map(|inner| inner.elements())
780: 778:                 .unwrap_or_default()
781: 779:         }
782: 780:     }
783: 781: }
784: 782: 
785: 783: macro_rules! tuples {
786: 784:     ($num:literal => $($ty:ident),*) => {
787: 785:         paste::paste! {
788: 786:             #[doc = concat!("Retained view state for ", stringify!([<EitherOf $num>]), ".")]
789: 787:             pub struct [<EitherOf $num State>]<$($ty,)*>
790: 788:             where
791: 789:                 $($ty: Render,)*
792: 790: 
793: 791:             {
794: 792:                 /// Which child view state is being displayed.
795: 793:                 pub state: [<EitherOf $num>]<$($ty::State,)*>,
796: 794:             }
797: 795: 
798: 796:             impl<$($ty,)*> Mountable for [<EitherOf $num State>]<$($ty,)*>
799: 797:             where
800: 798:                 $($ty: Render,)*
801: 799: 
802: 800:             {
803: 801:                 fn unmount(&mut self) {
804: 802:                     match &mut self.state {
805: 803:                         $([<EitherOf $num>]::$ty(this) => [<EitherOf $num>]::$ty(this.unmount()),)*
806: 804:                     };
807: 805:                 }
808: 806: 
809: 807:                 fn mount(
810: 808:                     &mut self,
811: 809:                     parent: &crate::renderer::types::Element,
812: 810:                     marker: Option<&crate::renderer::types::Node>,
813: 811:                 ) {
814: 812:                     match &mut self.state {
815: 813:                         $([<EitherOf $num>]::$ty(this) => [<EitherOf $num>]::$ty(this.mount(parent, marker)),)*
816: 814:                     };
817: 815:                 }
818: 816: 
819: 817:                 fn insert_before_this(&self,
820: 818:                     child: &mut dyn Mountable,
821: 819:                 ) -> bool {
822: 820:                     match &self.state {
823: 821:                         $([<EitherOf $num>]::$ty(this) =>this.insert_before_this(child),)*
824: 822:                     }
825: 823:                 }
826: 824: 
827: 825:                 fn elements(&self) -> Vec<crate::renderer::types::Element> {
828: 826:                     match &self.state {
829: 827:                         $([<EitherOf $num>]::$ty(this) => this.elements(),)*
830: 828:                     }
831: 829:                 }
832: 830:             }
833: 831: 
834: 832:             impl<$($ty,)*> Render for [<EitherOf $num>]<$($ty,)*>
835: 833:             where
836: 834:                 $($ty: Render,)*
837: 835: 
838: 836:             {
839: 837:                 type State = [<EitherOf $num State>]<$($ty,)*>;
840: 838: 
841: 839: 
842: 840:                 fn build(self) -> Self::State {
843: 841:                     let state = match self {
844: 842:                         $([<EitherOf $num>]::$ty(this) => [<EitherOf $num>]::$ty(this.build()),)*
845: 843:                     };
846: 844:                     Self::State { state }
847: 845:                 }
848: 846: 
849: 847:                 fn rebuild(self, state: &mut Self::State) {
850: 848:                     let new_state = match (self, &mut state.state) {
851: 849:                         // rebuild same state and return early
852: 850:                         $(([<EitherOf $num>]::$ty(new), [<EitherOf $num>]::$ty(old)) => { return new.rebuild(old); },)*
853: 851:                         // or mount new state
854: 852:                         $(([<EitherOf $num>]::$ty(new), _) => {
855: 853:                             let mut new = new.build();
856: 854:                             state.insert_before_this(&mut new);
857: 855:                             [<EitherOf $num>]::$ty(new)
858: 856:                         },)*
859: 857:                     };
860: 858: 
861: 859:                     // and then unmount old state
862: 860:                     match &mut state.state {
863: 861:                         $([<EitherOf $num>]::$ty(this) => this.unmount(),)*
864: 862:                     };
865: 863: 
866: 864:                     // and store the new state
867: 865:                     state.state = new_state;
868: 866:                 }
869: 867:             }
870: 868: 
871: 869:             impl<$($ty,)*> AddAnyAttr for [<EitherOf $num>]<$($ty,)*>
872: 870:             where
873: 871:                 $($ty: RenderHtml,)*
874: 872: 
875: 873:             {
876: 874:                 type Output<SomeNewAttr: Attribute> = [<EitherOf $num>]<
877: 875:                     $(<$ty as AddAnyAttr>::Output<SomeNewAttr>,)*
878: 876:                 >;
879: 877: 
880: 878:                 fn add_any_attr<NewAttr: Attribute>(
881: 879:                     self,
882: 880:                     attr: NewAttr,
883: 881:                 ) -> Self::Output<NewAttr>
884: 882:                 where
885: 883:                     Self::Output<NewAttr>: RenderHtml,
886: 884:                 {
887: 885:                     match self {
888: 886:                         $([<EitherOf $num>]::$ty(this) => [<EitherOf $num>]::$ty(this.add_any_attr(attr)),)*
889: 887:                     }
890: 888:                 }
891: 889:             }
892: 890: 
893: 891:             impl<$($ty,)*> RenderHtml for [<EitherOf $num>]<$($ty,)*>
894: 892:             where
895: 893:                 $($ty: RenderHtml,)*
896: 894: 
897: 895:             {
898: 896:                 type AsyncOutput = [<EitherOf $num>]<$($ty::AsyncOutput,)*>;
899: 897:                 type Owned = [<EitherOf $num>]<$($ty::Owned,)*>;
900: 898: 
901: 899:                 const MIN_LENGTH: usize = max_usize(&[$($ty ::MIN_LENGTH,)*]);
902: 900: 
903: 901: 
904: 902:                 fn dry_resolve(&mut self) {
905: 903:                     match self {
906: 904:                         $([<EitherOf $num>]::$ty(this) => {
907: 905:                             this.dry_resolve();
908: 906:                         })*
909: 907:                     }
910: 908:                 }
911: 909: 
912: 910:                 async fn resolve(self) -> Self::AsyncOutput {
913: 911:                     match self {
914: 912:                         $([<EitherOf $num>]::$ty(this) => [<EitherOf $num>]::$ty(this.resolve().await),)*
915: 913:                     }
916: 914:                 }
917: 915: 
918: 916:                 #[inline(always)]
919: 917:                 fn html_len(&self) -> usize {
920: 918:                     match self {
921: 919:                         $([<EitherOf $num>]::$ty(i) => i.html_len(),)*
922: 920:                     }
923: 921:                 }
924: 922: 
925: 923:                 fn to_html_with_buf(
926: 924:                     self,
927: 925:                     buf: &mut String,
928: 926:                     position: &mut Position,
929: 927:                     escape: bool,
930: 928:                     mark_branches: bool,
931: 929:                     extra_attrs: Vec<AnyAttribute>
932: 930:                 ) {
933: 931:                     match self {
934: 932:                         $([<EitherOf $num>]::$ty(this) => {
935: 933:                             if mark_branches && escape {
936: 934:                                 buf.open_branch(stringify!($ty));
937: 935:                             }
938: 936:                             this.to_html_with_buf(buf, position, escape, mark_branches, extra_attrs);
939: 937:                             if mark_branches && escape {
940: 938:                                 buf.close_branch(stringify!($ty));
941: 939:                                 if *position == Position::NextChildAfterText {
942: 940:                                     *position = Position::NextChild;
943: 941:                                 }
944: 942:                             }
945: 943:                         })*
946: 944:                     }
947: 945:                 }
948: 946: 
949: 947:                 fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
950: 948:                     self,
951: 949:                     buf: &mut StreamBuilder,
952: 950:                     position: &mut Position,
953: 951:                     escape: bool,
954: 952:                     mark_branches: bool,
955: 953:                     extra_attrs: Vec<AnyAttribute>
956: 954:                 ) where
957: 955:                     Self: Sized,
958: 956:                 {
959: 957:                     match self {
960: 958:                         $([<EitherOf $num>]::$ty(this) => {
961: 959:                             if mark_branches && escape {
962: 960:                                 buf.open_branch(stringify!($ty));
963: 961:                             }
964: 962:                             this.to_html_async_with_buf::<OUT_OF_ORDER>(buf, position, escape, mark_branches, extra_attrs);
965: 963:                             if mark_branches && escape {
966: 964:                                 buf.close_branch(stringify!($ty));
967: 965:                                 if *position == Position::NextChildAfterText {
968: 966:                                     *position = Position::NextChild;
969: 967:                                 }
970: 968:                             }
971: 969:                         })*
972: 970:                     }
973: 971:                 }
974: 972: 
975: 973:                 fn hydrate<const FROM_SERVER: bool>(
976: 974:                     self,
977: 975:                     cursor: &Cursor,
978: 976:                     position: &PositionState,
979: 977:                 ) -> Self::State {
980: 978:                     let state = match self {
981: 979:                         $([<EitherOf $num>]::$ty(this) => {
982: 980:                             [<EitherOf $num>]::$ty(this.hydrate::<FROM_SERVER>(cursor, position))
983: 981:                         })*
984: 982:                     };
985: 983: 
986: 984:                     Self::State { state }
987: 985:                 }
988: 986: 
989: 987:                 async fn hydrate_async(
990: 988:                     self,
991: 989:                     cursor: &Cursor,
992: 990:                     position: &PositionState,
993: 991:                 ) -> Self::State {
994: 992:                     let state = match self {
995: 993:                         $([<EitherOf $num>]::$ty(this) => {
996: 994:                             [<EitherOf $num>]::$ty(this.hydrate_async(cursor, position).await)
997: 995:                         })*
998: 996:                     };
999: 997: 
1000: 998:                     Self::State { state }
1001: 999:                 }
1002: 1000: 
1003: 1001:                 fn into_owned(self) -> Self::Owned {
1004: 1002:                     match self {
1005: 1003:                         $([<EitherOf $num>]::$ty(this) => {
1006: 1004:                             [<EitherOf $num>]::$ty(this.into_owned())
1007: 1005:                         })*
1008: 1006:                     }
1009: 1007:                 }
1010: 1008:             }
1011: 1009:         }
1012: 1010:     }
1013: 1011: }
1014: 1012: 
1015: 1013: tuples!(3 => A, B, C);
1016: 1014: tuples!(4 => A, B, C, D);
1017: 1015: tuples!(5 => A, B, C, D, E);
1018: 1016: tuples!(6 => A, B, C, D, E, F);
1019: 1017: tuples!(7 => A, B, C, D, E, F, G);
1020: 1018: tuples!(8 => A, B, C, D, E, F, G, H);
1021: 1019: tuples!(9 => A, B, C, D, E, F, G, H, I);
1022: 1020: tuples!(10 => A, B, C, D, E, F, G, H, I, J);
1023: 1021: tuples!(11 => A, B, C, D, E, F, G, H, I, J, K);
1024: 1022: tuples!(12 => A, B, C, D, E, F, G, H, I, J, K, L);
1025: 1023: tuples!(13 => A, B, C, D, E, F, G, H, I, J, K, L, M);
1026: 1024: tuples!(14 => A, B, C, D, E, F, G, H, I, J, K, L, M, N);
1027: 1025: tuples!(15 => A, B, C, D, E, F, G, H, I, J, K, L, M, N, O);
1028: 1026: tuples!(16 => A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
1029: 1027: ```
1030: 1028: ```
1031: 1029: ```
1032: 1030: ```
1033: 1031: ```
1034: 1032: ```
1035: 1033: ```
1036: 1034: ```
1037: ```
```
