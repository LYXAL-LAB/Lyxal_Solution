### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\iterators.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\iterators.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
21: 19:     RenderHtml,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::{any_attribute::AnyAttribute, Attribute},
25: 23:     hydration::Cursor,
26: 24:     renderer::Rndr,
27: 25:     ssr::StreamBuilder,
28: 26: };
29: 27: use lyx-core-lyx_core_lyx-core-lyx_core_either_of::Either;
30: 28: use itertools::Itertools;
31: 29: 
32: 30: /// Retained view state for an `Option`.
33: 31: pub type OptionState<T> = Either<<T as Render>::State, <() as Render>::State>;
34: 32: 
35: 33: impl<T> Render for Option<T>
36: 34: where
37: 35:     T: Render,
38: 36: {
39: 37:     type State = OptionState<T>;
40: 38: 
41: 39:     fn build(self) -> Self::State {
42: 40:         match self {
43: 41:             Some(value) => Either::Left(value),
44: 42:             None => Either::Right(()),
45: 43:         }
46: 44:         .build()
47: 45:     }
48: 46: 
49: 47:     fn rebuild(self, state: &mut Self::State) {
50: 48:         match self {
51: 49:             Some(value) => Either::Left(value),
52: 50:             None => Either::Right(()),
53: 51:         }
54: 52:         .rebuild(state)
55: 53:     }
56: 54: }
57: 55: 
58: 56: impl<T> AddAnyAttr for Option<T>
59: 57: where
60: 58:     T: AddAnyAttr,
61: 59: {
62: 60:     type Output<SomeNewAttr: Attribute> =
63: 61:         Option<<T as AddAnyAttr>::Output<SomeNewAttr>>;
64: 62: 
65: 63:     fn add_any_attr<NewAttr: Attribute>(
66: 64:         self,
67: 65:         attr: NewAttr,
68: 66:     ) -> Self::Output<NewAttr>
69: 67:     where
70: 68:         Self::Output<NewAttr>: RenderHtml,
71: 69:     {
72: 70:         self.map(|n| n.add_any_attr(attr))
73: 71:     }
74: 72: }
75: 73: 
76: 74: impl<T> RenderHtml for Option<T>
77: 75: where
78: 76:     T: RenderHtml,
79: 77: {
80: 78:     type AsyncOutput = Option<T::AsyncOutput>;
81: 79:     type Owned = Option<T::Owned>;
82: 80: 
83: 81:     const MIN_LENGTH: usize = T::MIN_LENGTH;
84: 82: 
85: 83:     fn dry_resolve(&mut self) {
86: 84:         if let Some(inner) = self.as_mut() {
87: 85:             inner.dry_resolve();
88: 86:         }
89: 87:     }
90: 88: 
91: 89:     async fn resolve(self) -> Self::AsyncOutput {
92: 90:         match self {
93: 91:             None => None,
94: 92:             Some(value) => Some(value.resolve().await),
95: 93:         }
96: 94:     }
97: 95: 
98: 96:     fn html_len(&self) -> usize {
99: 97:         match self {
100: 98:             Some(i) => i.html_len() + 3,
101: 99:             None => 3,
102: 100:         }
103: 101:     }
104: 102: 
105: 103:     fn to_html_with_buf(
106: 104:         self,
107: 105:         buf: &mut String,
108: 106:         position: &mut Position,
109: 107:         escape: bool,
110: 108:         mark_branches: bool,
111: 109:         extra_attrs: Vec<AnyAttribute>,
112: 110:     ) {
113: 111:         match self {
114: 112:             Some(value) => Either::Left(value),
115: 113:             None => Either::Right(()),
116: 114:         }
117: 115:         .to_html_with_buf(
118: 116:             buf,
119: 117:             position,
120: 118:             escape,
121: 119:             mark_branches,
122: 120:             extra_attrs,
123: 121:         )
124: 122:     }
125: 123: 
126: 124:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
127: 125:         self,
128: 126:         buf: &mut StreamBuilder,
129: 127:         position: &mut Position,
130: 128:         escape: bool,
131: 129:         mark_branches: bool,
132: 130:         extra_attrs: Vec<AnyAttribute>,
133: 131:     ) where
134: 132:         Self: Sized,
135: 133:     {
136: 134:         match self {
137: 135:             Some(value) => Either::Left(value),
138: 136:             None => Either::Right(()),
139: 137:         }
140: 138:         .to_html_async_with_buf::<OUT_OF_ORDER>(
141: 139:             buf,
142: 140:             position,
143: 141:             escape,
144: 142:             mark_branches,
145: 143:             extra_attrs,
146: 144:         )
147: 145:     }
148: 146: 
149: 147:     #[track_caller]
150: 148:     fn hydrate<const FROM_SERVER: bool>(
151: 149:         self,
152: 150:         cursor: &Cursor,
153: 151:         position: &PositionState,
154: 152:     ) -> Self::State {
155: 153:         match self {
156: 154:             Some(value) => Either::Left(value),
157: 155:             None => Either::Right(()),
158: 156:         }
159: 157:         .hydrate::<FROM_SERVER>(cursor, position)
160: 158:     }
161: 159: 
162: 160:     async fn hydrate_async(
163: 161:         self,
164: 162:         cursor: &Cursor,
165: 163:         position: &PositionState,
166: 164:     ) -> Self::State {
167: 165:         match self {
168: 166:             Some(value) => Either::Left(value),
169: 167:             None => Either::Right(()),
170: 168:         }
171: 169:         .hydrate_async(cursor, position)
172: 170:         .await
173: 171:     }
174: 172: 
175: 173:     fn into_owned(self) -> Self::Owned {
176: 174:         self.map(RenderHtml::into_owned)
177: 175:     }
178: 176: }
179: 177: 
180: 178: impl<T> Render for Vec<T>
181: 179: where
182: 180:     T: Render,
183: 181: {
184: 182:     type State = VecState<T::State>;
185: 183: 
186: 184:     fn build(self) -> Self::State {
187: 185:         let marker = Rndr::create_placeholder();
188: 186:         VecState {
189: 187:             states: self.into_iter().map(T::build).collect(),
190: 188:             marker,
191: 189:         }
192: 190:     }
193: 191: 
194: 192:     fn rebuild(self, state: &mut Self::State) {
195: 193:         let VecState { states, marker } = state;
196: 194:         let old = states;
197: 195:         // this is an unkeyed diff
198: 196:         if old.is_empty() {
199: 197:             let mut new = self.build().states;
200: 198:             for item in new.iter_mut() {
201: 199:                 Rndr::try_mount_before(item, marker.as_ref());
202: 200:             }
203: 201:             *old = new;
204: 202:         } else if self.is_empty() {
205: 203:             // TODO fast path for clearing
206: 204:             for item in old.iter_mut() {
207: 205:                 item.unmount();
208: 206:             }
209: 207:             old.clear();
210: 208:         } else {
211: 209:             let mut adds = vec![];
212: 210:             let mut removes_at_end = 0;
213: 211:             for item in self.into_iter().zip_longest(old.iter_mut()) {
214: 212:                 match item {
215: 213:                     itertools::EitherOrBoth::Both(new, old) => {
216: 214:                         T::rebuild(new, old)
217: 215:                     }
218: 216:                     itertools::EitherOrBoth::Left(new) => {
219: 217:                         let mut new_state = new.build();
220: 218:                         Rndr::try_mount_before(&mut new_state, marker.as_ref());
221: 219:                         adds.push(new_state);
222: 220:                     }
223: 221:                     itertools::EitherOrBoth::Right(old) => {
224: 222:                         removes_at_end += 1;
225: 223:                         old.unmount()
226: 224:                     }
227: 225:                 }
228: 226:             }
229: 227:             old.truncate(old.len() - removes_at_end);
230: 228:             old.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(&mut adds);
231: 229:         }
232: 230:     }
233: 231: }
234: 232: 
235: 233: /// Retained view state for a `Vec<_>`.
236: 234: pub struct VecState<T>
237: 235: where
238: 236:     T: Mountable,
239: 237: {
240: 238:     states: Vec<T>,
241: 239:     // Vecs keep a placeholder because they have the potential to add additional items,
242: 240:     // after their own items but before the next neighbor. It is much easier to add an
243: 241:     // item before a known placeholder than to add it after the last known item, so we
244: 242:     // just leave a placeholder here unlike zero-or-one iterators (Option, Result, etc.)
245: 243:     marker: crate::renderer::types::Placeholder,
246: 244: }
247: 245: 
248: 246: impl<T> Mountable for VecState<T>
249: 247: where
250: 248:     T: Mountable,
251: 249: {
252: 250:     fn unmount(&mut self) {
253: 251:         for state in self.states.iter_mut() {
254: 252:             state.unmount();
255: 253:         }
256: 254:         self.marker.unmount();
257: 255:     }
258: 256: 
259: 257:     fn mount(
260: 258:         &mut self,
261: 259:         parent: &crate::renderer::types::Element,
262: 260:         marker: Option<&crate::renderer::types::Node>,
263: 261:     ) {
264: 262:         for state in self.states.iter_mut() {
265: 263:             state.mount(parent, marker);
266: 264:         }
267: 265:         self.marker.mount(parent, marker);
268: 266:     }
269: 267: 
270: 268:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
271: 269:         for state in &self.states {
272: 270:             if state.insert_before_this(child) {
273: 271:                 return true;
274: 272:             }
275: 273:         }
276: 274:         self.marker.insert_before_this(child)
277: 275:     }
278: 276: 
279: 277:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
280: 278:         self.states
281: 279:             .iter()
282: 280:             .flat_map(|item| item.elements())
283: 281:             .collect()
284: 282:     }
285: 283: }
286: 284: 
287: 285: impl<T> AddAnyAttr for Vec<T>
288: 286: where
289: 287:     T: AddAnyAttr,
290: 288: {
291: 289:     type Output<SomeNewAttr: Attribute> =
292: 290:         Vec<<T as AddAnyAttr>::Output<SomeNewAttr::Cloneable>>;
293: 291: 
294: 292:     fn add_any_attr<NewAttr: Attribute>(
295: 293:         self,
296: 294:         attr: NewAttr,
297: 295:     ) -> Self::Output<NewAttr>
298: 296:     where
299: 297:         Self::Output<NewAttr>: RenderHtml,
300: 298:     {
301: 299:         let attr = attr.into_cloneable();
302: 300:         self.into_iter()
303: 301:             .map(|n| n.add_any_attr(attr.clone()))
304: 302:             .collect()
305: 303:     }
306: 304: }
307: 305: 
308: 306: impl<T> RenderHtml for Vec<T>
309: 307: where
310: 308:     T: RenderHtml,
311: 309: {
312: 310:     type AsyncOutput = Vec<T::AsyncOutput>;
313: 311:     type Owned = Vec<T::Owned>;
314: 312: 
315: 313:     const MIN_LENGTH: usize = 0;
316: 314: 
317: 315:     fn dry_resolve(&mut self) {
318: 316:         for inner in self.iter_mut() {
319: 317:             inner.dry_resolve();
320: 318:         }
321: 319:     }
322: 320: 
323: 321:     async fn resolve(self) -> Self::AsyncOutput {
324: 322:         futures::future::join_all(self.into_iter().map(T::resolve))
325: 323:             .await
326: 324:             .into_iter()
327: 325:             .collect()
328: 326:     }
329: 327: 
330: 328:     fn html_len(&self) -> usize {
331: 329:         self.iter().map(|n| n.html_len()).sum::<usize>() + 3
332: 330:     }
333: 331: 
334: 332:     fn to_html_with_buf(
335: 333:         self,
336: 334:         buf: &mut String,
337: 335:         position: &mut Position,
338: 336:         escape: bool,
339: 337:         mark_branches: bool,
340: 338:         extra_attrs: Vec<AnyAttribute>,
341: 339:     ) {
342: 340:         let mut children = self.into_iter();
343: 341:         if let Some(first) = children.next() {
344: 342:             first.to_html_with_buf(
345: 343:                 buf,
346: 344:                 position,
347: 345:                 escape,
348: 346:                 mark_branches,
349: 347:                 extra_attrs.clone(),
350: 348:             );
351: 349:         }
352: 350:         for child in children {
353: 351:             child.to_html_with_buf(
354: 352:                 buf,
355: 353:                 position,
356: 354:                 escape,
357: 355:                 mark_branches,
358: 356:                 // each child will have the extra attributes lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied
359: 357:                 extra_attrs.clone(),
360: 358:             );
361: 359:         }
362: 360:         if escape {
363: 361:             buf.push_str("<!>");
364: 362:             *position = Position::NextChild;
365: 363:         }
366: 364:     }
367: 365: 
368: 366:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
369: 367:         self,
370: 368:         buf: &mut StreamBuilder,
371: 369:         position: &mut Position,
372: 370:         escape: bool,
373: 371:         mark_branches: bool,
374: 372:         extra_attrs: Vec<AnyAttribute>,
375: 373:     ) where
376: 374:         Self: Sized,
377: 375:     {
378: 376:         let mut children = self.into_iter();
379: 377:         if let Some(first) = children.next() {
380: 378:             first.to_html_async_with_buf::<OUT_OF_ORDER>(
381: 379:                 buf,
382: 380:                 position,
383: 381:                 escape,
384: 382:                 mark_branches,
385: 383:                 extra_attrs.clone(),
386: 384:             );
387: 385:         }
388: 386:         for child in children {
389: 387:             child.to_html_async_with_buf::<OUT_OF_ORDER>(
390: 388:                 buf,
391: 389:                 position,
392: 390:                 escape,
393: 391:                 mark_branches,
394: 392:                 extra_attrs.clone(),
395: 393:             );
396: 394:         }
397: 395:         if escape {
398: 396:             buf.push_sync("<!>");
399: 397:             *position = Position::NextChild;
400: 398:         }
401: 399:     }
402: 400: 
403: 401:     fn hydrate<const FROM_SERVER: bool>(
404: 402:         self,
405: 403:         cursor: &Cursor,
406: 404:         position: &PositionState,
407: 405:     ) -> Self::State {
408: 406:         let states = self
409: 407:             .into_iter()
410: 408:             .map(|child| child.hydrate::<FROM_SERVER>(cursor, position))
411: 409:             .collect();
412: 410: 
413: 411:         let marker = cursor.next_placeholder(position);
414: 412:         position.set(Position::NextChild);
415: 413: 
416: 414:         VecState { states, marker }
417: 415:     }
418: 416: 
419: 417:     async fn hydrate_async(
420: 418:         self,
421: 419:         cursor: &Cursor,
422: 420:         position: &PositionState,
423: 421:     ) -> Self::State {
424: 422:         let mut states = Vec::with_capacity(self.len());
425: 423:         for child in self {
426: 424:             states.push(child.hydrate_async(cursor, position).await);
427: 425:         }
428: 426: 
429: 427:         let marker = cursor.next_placeholder(position);
430: 428:         position.set(Position::NextChild);
431: 429: 
432: 430:         VecState { states, marker }
433: 431:     }
434: 432: 
435: 433:     fn into_owned(self) -> Self::Owned {
436: 434:         self.into_iter()
437: 435:             .map(RenderHtml::into_owned)
438: 436:             .collect::<Vec<_>>()
439: 437:     }
440: 438: }
441: 439: 
442: 440: /// A container used for ErasedMode. It's slightly better than a raw Vec<> because the rendering traits don't have to worry about the length of the Vec changing, therefore no marker traits etc.
443: 441: pub struct StaticVec<T>(pub(crate) Vec<T>);
444: 442: 
445: 443: impl<T: Clone> Clone for StaticVec<T> {
446: 444:     fn clone(&self) -> Self {
447: 445:         Self(self.0.clone())
448: 446:     }
449: 447: }
450: 448: 
451: 449: impl<T> IntoIterator for StaticVec<T> {
452: 450:     type Item = T;
453: 451:     type IntoIter = std::vec::IntoIter<T>;
454: 452: 
455: 453:     fn into_iter(self) -> Self::IntoIter {
456: 454:         self.0.into_iter()
457: 455:     }
458: 456: }
459: 457: 
460: 458: impl<T> StaticVec<T> {
461: 459:     /// Iterates over the items.
462: 460:     pub fn iter(&self) -> std::slice::Iter<'_, T> {
463: 461:         self.0.iter()
464: 462:     }
465: 463: }
466: 464: 
467: 465: impl<T> From<Vec<T>> for StaticVec<T> {
468: 466:     fn from(vec: Vec<T>) -> Self {
469: 467:         Self(vec)
470: 468:     }
471: 469: }
472: 470: 
473: 471: impl<T> From<StaticVec<T>> for Vec<T> {
474: 472:     fn from(static_vec: StaticVec<T>) -> Self {
475: 473:         static_vec.0
476: 474:     }
477: 475: }
478: 476: 
479: 477: /// Retained view state for a `StaticVec<Vec<_>>`.
480: 478: pub struct StaticVecState<T>
481: 479: where
482: 480:     T: Mountable,
483: 481: {
484: 482:     states: Vec<T>,
485: 483:     marker: crate::renderer::types::Placeholder,
486: 484: }
487: 485: 
488: 486: impl<T> Mountable for StaticVecState<T>
489: 487: where
490: 488:     T: Mountable,
491: 489: {
492: 490:     fn unmount(&mut self) {
493: 491:         for state in self.states.iter_mut() {
494: 492:             state.unmount();
495: 493:         }
496: 494:         self.marker.unmount();
497: 495:     }
498: 496: 
499: 497:     fn mount(
500: 498:         &mut self,
501: 499:         parent: &crate::renderer::types::Element,
502: 500:         marker: Option<&crate::renderer::types::Node>,
503: 501:     ) {
504: 502:         for state in self.states.iter_mut() {
505: 503:             state.mount(parent, marker);
506: 504:         }
507: 505:         self.marker.mount(parent, marker);
508: 506:     }
509: 507: 
510: 508:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
511: 509:         for state in &self.states {
512: 510:             if state.insert_before_this(child) {
513: 511:                 return true;
514: 512:             }
515: 513:         }
516: 514:         self.marker.insert_before_this(child)
517: 515:     }
518: 516: 
519: 517:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
520: 518:         self.states
521: 519:             .iter()
522: 520:             .flat_map(|item| item.elements())
523: 521:             .collect()
524: 522:     }
525: 523: }
526: 524: 
527: 525: impl<T> Render for StaticVec<T>
528: 526: where
529: 527:     T: Render,
530: 528: {
531: 529:     type State = StaticVecState<T::State>;
532: 530: 
533: 531:     fn build(self) -> Self::State {
534: 532:         let marker = Rndr::create_placeholder();
535: 533:         Self::State {
536: 534:             states: self.0.into_iter().map(T::build).collect(),
537: 535:             marker,
538: 536:         }
539: 537:     }
540: 538: 
541: 539:     fn rebuild(self, state: &mut Self::State) {
542: 540:         let StaticVecState { states, marker } = state;
543: 541:         let old = states;
544: 542: 
545: 543:         // reuses the Vec impl
546: 544:         if old.is_empty() {
547: 545:             let mut new = self.build().states;
548: 546:             for item in new.iter_mut() {
549: 547:                 Rndr::mount_before(item, marker.as_ref());
550: 548:             }
551: 549:             *old = new;
552: 550:         } else if self.0.is_empty() {
553: 551:             // TODO fast path for clearing
554: 552:             for item in old.iter_mut() {
555: 553:                 item.unmount();
556: 554:             }
557: 555:             old.clear();
558: 556:         } else {
559: 557:             let mut adds = vec![];
560: 558:             let mut removes_at_end = 0;
561: 559:             for item in self.0.into_iter().zip_longest(old.iter_mut()) {
562: 560:                 match item {
563: 561:                     itertools::EitherOrBoth::Both(new, old) => {
564: 562:                         T::rebuild(new, old)
565: 563:                     }
566: 564:                     itertools::EitherOrBoth::Left(new) => {
567: 565:                         let mut new_state = new.build();
568: 566:                         Rndr::mount_before(&mut new_state, marker.as_ref());
569: 567:                         adds.push(new_state);
570: 568:                     }
571: 569:                     itertools::EitherOrBoth::Right(old) => {
572: 570:                         removes_at_end += 1;
573: 571:                         old.unmount()
574: 572:                     }
575: 573:                 }
576: 574:             }
577: 575:             old.truncate(old.len() - removes_at_end);
578: 576:             old.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(&mut adds);
579: 577:         }
580: 578:     }
581: 579: }
582: 580: 
583: 581: impl<T> AddAnyAttr for StaticVec<T>
584: 582: where
585: 583:     T: AddAnyAttr,
586: 584: {
587: 585:     type Output<SomeNewAttr: Attribute> =
588: 586:         StaticVec<<T as AddAnyAttr>::Output<SomeNewAttr::Cloneable>>;
589: 587: 
590: 588:     fn add_any_attr<NewAttr: Attribute>(
591: 589:         self,
592: 590:         attr: NewAttr,
593: 591:     ) -> Self::Output<NewAttr>
594: 592:     where
595: 593:         Self::Output<NewAttr>: RenderHtml,
596: 594:     {
597: 595:         let attr = attr.into_cloneable();
598: 596:         self.0
599: 597:             .into_iter()
600: 598:             .map(|n| n.add_any_attr(attr.clone()))
601: 599:             .collect::<Vec<_>>()
602: 600:             .into()
603: 601:     }
604: 602: }
605: 603: 
606: 604: impl<T> RenderHtml for StaticVec<T>
607: 605: where
608: 606:     T: RenderHtml,
609: 607: {
610: 608:     type AsyncOutput = StaticVec<T::AsyncOutput>;
611: 609:     type Owned = StaticVec<T::Owned>;
612: 610: 
613: 611:     const MIN_LENGTH: usize = 0;
614: 612: 
615: 613:     fn dry_resolve(&mut self) {
616: 614:         for inner in self.0.iter_mut() {
617: 615:             inner.dry_resolve();
618: 616:         }
619: 617:     }
620: 618: 
621: 619:     async fn resolve(self) -> Self::AsyncOutput {
622: 620:         futures::future::join_all(self.0.into_iter().map(T::resolve))
623: 621:             .await
624: 622:             .into_iter()
625: 623:             .collect::<Vec<_>>()
626: 624:             .into()
627: 625:     }
628: 626: 
629: 627:     fn html_len(&self) -> usize {
630: 628:         self.0.iter().map(RenderHtml::html_len).sum::<usize>() + 3
631: 629:     }
632: 630: 
633: 631:     fn to_html_with_buf(
634: 632:         self,
635: 633:         buf: &mut String,
636: 634:         position: &mut Position,
637: 635:         escape: bool,
638: 636:         mark_branches: bool,
639: 637:         extra_attrs: Vec<AnyAttribute>,
640: 638:     ) {
641: 639:         for child in self.0.into_iter() {
642: 640:             child.to_html_with_buf(
643: 641:                 buf,
644: 642:                 position,
645: 643:                 escape,
646: 644:                 mark_branches,
647: 645:                 extra_attrs.clone(),
648: 646:             );
649: 647:         }
650: 648:         if escape {
651: 649:             buf.push_str("<!>");
652: 650:             *position = Position::NextChild;
653: 651:         }
654: 652:     }
655: 653: 
656: 654:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
657: 655:         self,
658: 656:         buf: &mut StreamBuilder,
659: 657:         position: &mut Position,
660: 658:         escape: bool,
661: 659:         mark_branches: bool,
662: 660:         extra_attrs: Vec<AnyAttribute>,
663: 661:     ) where
664: 662:         Self: Sized,
665: 663:     {
666: 664:         for child in self.0.into_iter() {
667: 665:             child.to_html_async_with_buf::<OUT_OF_ORDER>(
668: 666:                 buf,
669: 667:                 position,
670: 668:                 escape,
671: 669:                 mark_branches,
672: 670:                 extra_attrs.clone(),
673: 671:             );
674: 672:         }
675: 673:         if escape {
676: 674:             buf.push_sync("<!>");
677: 675:             *position = Position::NextChild;
678: 676:         }
679: 677:     }
680: 678: 
681: 679:     fn hydrate<const FROM_SERVER: bool>(
682: 680:         self,
683: 681:         cursor: &Cursor,
684: 682:         position: &PositionState,
685: 683:     ) -> Self::State {
686: 684:         let states = self
687: 685:             .0
688: 686:             .into_iter()
689: 687:             .map(|child| child.hydrate::<FROM_SERVER>(cursor, position))
690: 688:             .collect();
691: 689: 
692: 690:         let marker = cursor.next_placeholder(position);
693: 691:         position.set(Position::NextChild);
694: 692: 
695: 693:         Self::State { states, marker }
696: 694:     }
697: 695: 
698: 696:     async fn hydrate_async(
699: 697:         self,
700: 698:         cursor: &Cursor,
701: 699:         position: &PositionState,
702: 700:     ) -> Self::State {
703: 701:         let mut states = Vec::with_capacity(self.0.len());
704: 702:         for child in self.0 {
705: 703:             states.push(child.hydrate_async(cursor, position).await);
706: 704:         }
707: 705: 
708: 706:         let marker = cursor.next_placeholder(position);
709: 707:         position.set(Position::NextChild);
710: 708: 
711: 709:         Self::State { states, marker }
712: 710:     }
713: 711: 
714: 712:     fn into_owned(self) -> Self::Owned {
715: 713:         self.0
716: 714:             .into_iter()
717: 715:             .map(RenderHtml::into_owned)
718: 716:             .collect::<Vec<_>>()
719: 717:             .into()
720: 718:     }
721: 719: }
722: 720: 
723: 721: impl<T, const N: usize> Render for [T; N]
724: 722: where
725: 723:     T: Render,
726: 724: {
727: 725:     type State = ArrayState<T::State, N>;
728: 726: 
729: 727:     fn build(self) -> Self::State {
730: 728:         Self::State {
731: 729:             states: self.map(T::build),
732: 730:         }
733: 731:     }
734: 732: 
735: 733:     fn rebuild(self, state: &mut Self::State) {
736: 734:         let Self::State { states } = state;
737: 735:         let old = states;
738: 736:         // this is an unkeyed diff
739: 737:         self.into_iter()
740: 738:             .zip(old.iter_mut())
741: 739:             .for_each(|(new, old)| T::rebuild(new, old));
742: 740:     }
743: 741: }
744: 742: 
745: 743: /// Retained view state for a `Vec<_>`.
746: 744: pub struct ArrayState<T, const N: usize>
747: 745: where
748: 746:     T: Mountable,
749: 747: {
750: 748:     states: [T; N],
751: 749: }
752: 750: 
753: 751: impl<T, const N: usize> Mountable for ArrayState<T, N>
754: 752: where
755: 753:     T: Mountable,
756: 754: {
757: 755:     fn unmount(&mut self) {
758: 756:         self.states.iter_mut().for_each(Mountable::unmount);
759: 757:     }
760: 758: 
761: 759:     fn mount(
762: 760:         &mut self,
763: 761:         parent: &crate::renderer::types::Element,
764: 762:         marker: Option<&crate::renderer::types::Node>,
765: 763:     ) {
766: 764:         for state in self.states.iter_mut() {
767: 765:             state.mount(parent, marker);
768: 766:         }
769: 767:     }
770: 768: 
771: 769:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
772: 770:         for state in &self.states {
773: 771:             if state.insert_before_this(child) {
774: 772:                 return true;
775: 773:             }
776: 774:         }
777: 775:         false
778: 776:     }
779: 777: 
780: 778:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
781: 779:         self.states
782: 780:             .iter()
783: 781:             .flat_map(|item| item.elements())
784: 782:             .collect()
785: 783:     }
786: 784: }
787: 785: impl<T, const N: usize> AddAnyAttr for [T; N]
788: 786: where
789: 787:     T: AddAnyAttr,
790: 788: {
791: 789:     type Output<SomeNewAttr: Attribute> =
792: 790:         [<T as AddAnyAttr>::Output<SomeNewAttr::Cloneable>; N];
793: 791: 
794: 792:     fn add_any_attr<NewAttr: Attribute>(
795: 793:         self,
796: 794:         attr: NewAttr,
797: 795:     ) -> Self::Output<NewAttr>
798: 796:     where
799: 797:         Self::Output<NewAttr>: RenderHtml,
800: 798:     {
801: 799:         let attr = attr.into_cloneable();
802: 800:         self.map(|n| n.add_any_attr(attr.clone()))
803: 801:     }
804: 802: }
805: 803: 
806: 804: impl<T, const N: usize> RenderHtml for [T; N]
807: 805: where
808: 806:     T: RenderHtml,
809: 807: {
810: 808:     type AsyncOutput = [T::AsyncOutput; N];
811: 809:     type Owned = [T::Owned; N];
812: 810: 
813: 811:     const MIN_LENGTH: usize = 0;
814: 812: 
815: 813:     fn dry_resolve(&mut self) {
816: 814:         for inner in self.iter_mut() {
817: 815:             inner.dry_resolve();
818: 816:         }
819: 817:     }
820: 818: 
821: 819:     async fn resolve(self) -> Self::AsyncOutput {
822: 820:         futures::future::join_all(self.into_iter().map(T::resolve))
823: 821:             .await
824: 822:             .into_iter()
825: 823:             .collect::<Vec<_>>()
826: 824:             .try_into()
827: 825:             .unwrap_or_else(|_| unreachable!())
828: 826:     }
829: 827: 
830: 828:     fn html_len(&self) -> usize {
831: 829:         self.iter().map(RenderHtml::html_len).sum::<usize>()
832: 830:     }
833: 831: 
834: 832:     fn to_html_with_buf(
835: 833:         self,
836: 834:         buf: &mut String,
837: 835:         position: &mut Position,
838: 836:         escape: bool,
839: 837:         mark_branches: bool,
840: 838:         extra_attrs: Vec<AnyAttribute>,
841: 839:     ) {
842: 840:         for child in self.into_iter() {
843: 841:             child.to_html_with_buf(
844: 842:                 buf,
845: 843:                 position,
846: 844:                 escape,
847: 845:                 mark_branches,
848: 846:                 extra_attrs.clone(),
849: 847:             );
850: 848:         }
851: 849:     }
852: 850: 
853: 851:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
854: 852:         self,
855: 853:         buf: &mut StreamBuilder,
856: 854:         position: &mut Position,
857: 855:         escape: bool,
858: 856:         mark_branches: bool,
859: 857:         extra_attrs: Vec<AnyAttribute>,
860: 858:     ) where
861: 859:         Self: Sized,
862: 860:     {
863: 861:         for child in self.into_iter() {
864: 862:             child.to_html_async_with_buf::<OUT_OF_ORDER>(
865: 863:                 buf,
866: 864:                 position,
867: 865:                 escape,
868: 866:                 mark_branches,
869: 867:                 extra_attrs.clone(),
870: 868:             );
871: 869:         }
872: 870:     }
873: 871: 
874: 872:     fn hydrate<const FROM_SERVER: bool>(
875: 873:         self,
876: 874:         cursor: &Cursor,
877: 875:         position: &PositionState,
878: 876:     ) -> Self::State {
879: 877:         let states =
880: 878:             self.map(|child| child.hydrate::<FROM_SERVER>(cursor, position));
881: 879:         ArrayState { states }
882: 880:     }
883: 881: 
884: 882:     async fn hydrate_async(
885: 883:         self,
886: 884:         cursor: &Cursor,
887: 885:         position: &PositionState,
888: 886:     ) -> Self::State {
889: 887:         let mut states = Vec::with_capacity(self.len());
890: 888:         for child in self {
891: 889:             states.push(child.hydrate_async(cursor, position).await);
892: 890:         }
893: 891:         let Ok(states) = <[<T as Render>::State; N]>::try_from(states) else {
894: 892:             unreachable!()
895: 893:         };
896: 894:         ArrayState { states }
897: 895:     }
898: 896: 
899: 897:     fn into_owned(self) -> Self::Owned {
900: 898:         self.into_iter()
901: 899:             .map(RenderHtml::into_owned)
902: 900:             .collect::<Vec<_>>()
903: 901:             .try_into()
904: 902:             .unwrap_or_else(|_| unreachable!())
905: 903:     }
906: 904: }
907: 905: ```
908: 906: ```
909: 907: ```
910: 908: ```
911: 909: ```
912: 910: ```
913: 911: ```
914: 912: ```
915: ```
```
