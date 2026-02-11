### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\strings.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\strings.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     Mountable, Position, PositionState, Render, RenderHtml, ToTemplate,
21: 19: };
22: 20: use crate::{
23: 21:     html::attribute::any_attribute::AnyAttribute,
24: 22:     hydration::Cursor,
25: 23:     no_attrs,
26: 24:     renderer::{CastFrom, Rndr},
27: 25: };
28: 26: use std::{borrow::Cow, rc::Rc, sync::Arc};
29: 27: 
30: 28: no_attrs!(&'a str);
31: 29: no_attrs!(String);
32: 30: no_attrs!(Arc<str>);
33: 31: no_attrs!(Cow<'a, str>);
34: 32: 
35: 33: /// Retained view state for `&str`.
36: 34: pub struct StrState<'a> {
37: 35:     pub(crate) node: crate::renderer::types::Text,
38: 36:     str: &'a str,
39: 37: }
40: 38: 
41: 39: impl<'a> Render for &'a str {
42: 40:     type State = StrState<'a>;
43: 41: 
44: 42:     fn build(self) -> Self::State {
45: 43:         let node = Rndr::create_text_node(self);
46: 44:         StrState { node, str: self }
47: 45:     }
48: 46: 
49: 47:     fn rebuild(self, state: &mut Self::State) {
50: 48:         let StrState { node, str } = state;
51: 49:         if &self != str {
52: 50:             Rndr::set_text(node, self);
53: 51:             *str = self;
54: 52:         }
55: 53:     }
56: 54: }
57: 55: 
58: 56: impl RenderHtml for &str {
59: 57:     type AsyncOutput = Self;
60: 58:     type Owned = String;
61: 59: 
62: 60:     const MIN_LENGTH: usize = 0;
63: 61: 
64: 62:     fn dry_resolve(&mut self) {}
65: 63: 
66: 64:     async fn resolve(self) -> Self::AsyncOutput {
67: 65:         self
68: 66:     }
69: 67: 
70: 68:     fn html_len(&self) -> usize {
71: 69:         self.len()
72: 70:     }
73: 71: 
74: 72:     fn to_html_with_buf(
75: 73:         self,
76: 74:         buf: &mut String,
77: 75:         position: &mut Position,
78: 76:         escape: bool,
79: 77:         _mark_branches: bool,
80: 78:         _extra_attrs: Vec<AnyAttribute>,
81: 79:     ) {
82: 80:         // add a comment node to separate from previous sibling, if any
83: 81:         if matches!(position, Position::NextChildAfterText) {
84: 82:             buf.push_str("<!>")
85: 83:         }
86: 84:         if self.is_empty() && escape {
87: 85:             buf.push(' ');
88: 86:         } else if escape {
89: 87:             let escaped = html_escape::encode_text(self);
90: 88:             buf.push_str(&escaped);
91: 89:         } else {
92: 90:             buf.push_str(self);
93: 91:         }
94: 92:         *position = Position::NextChildAfterText;
95: 93:     }
96: 94: 
97: 95:     fn hydrate<const FROM_SERVER: bool>(
98: 96:         self,
99: 97:         cursor: &Cursor,
100: 98:         position: &PositionState,
101: 99:     ) -> Self::State {
102: 100:         if position.get() == Position::FirstChild {
103: 101:             cursor.child();
104: 102:         } else {
105: 103:             cursor.sibling();
106: 104:         }
107: 105: 
108: 106:         // separating placeholder marker comes before text node
109: 107:         if matches!(position.get(), Position::NextChildAfterText) {
110: 108:             cursor.sibling();
111: 109:         }
112: 110: 
113: 111:         let node = cursor.current();
114: 112:         let node = crate::renderer::types::Text::cast_from(node.clone())
115: 113:             .unwrap_or_else(|| {
116: 114:                 crate::hydration::failed_to_cast_text_node(node)
117: 115:             });
118: 116: 
119: 117:         if !FROM_SERVER {
120: 118:             Rndr::set_text(&node, self);
121: 119:         }
122: 120:         position.set(Position::NextChildAfterText);
123: 121: 
124: 122:         StrState { node, str: self }
125: 123:     }
126: 124: 
127: 125:     fn into_owned(self) -> Self::Owned {
128: 126:         self.to_string()
129: 127:     }
130: 128: }
131: 129: 
132: 130: impl ToTemplate for &str {
133: 131:     const TEMPLATE: &'static str = " <!>";
134: 132: 
135: 133:     fn to_template(
136: 134:         buf: &mut String,
137: 135:         _class: &mut String,
138: 136:         _style: &mut String,
139: 137:         _inner_html: &mut String,
140: 138:         position: &mut Position,
141: 139:     ) {
142: 140:         if matches!(*position, Position::NextChildAfterText) {
143: 141:             buf.push_str("<!>")
144: 142:         }
145: 143:         buf.push(' ');
146: 144:         *position = Position::NextChildAfterText;
147: 145:     }
148: 146: }
149: 147: 
150: 148: impl Mountable for StrState<'_> {
151: 149:     fn unmount(&mut self) {
152: 150:         self.node.unmount()
153: 151:     }
154: 152: 
155: 153:     fn mount(
156: 154:         &mut self,
157: 155:         parent: &crate::renderer::types::Element,
158: 156:         marker: Option<&crate::renderer::types::Node>,
159: 157:     ) {
160: 158:         Rndr::insert_node(parent, self.node.as_ref(), marker);
161: 159:     }
162: 160: 
163: 161:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
164: 162:         self.node.insert_before_this(child)
165: 163:     }
166: 164: 
167: 165:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
168: 166:         vec![]
169: 167:     }
170: 168: }
171: 169: 
172: 170: /// Retained view state for `String`.
173: 171: pub struct StringState {
174: 172:     node: crate::renderer::types::Text,
175: 173:     str: String,
176: 174: }
177: 175: 
178: 176: impl Render for String {
179: 177:     type State = StringState;
180: 178: 
181: 179:     fn build(self) -> Self::State {
182: 180:         let node = Rndr::create_text_node(&self);
183: 181:         StringState { node, str: self }
184: 182:     }
185: 183: 
186: 184:     fn rebuild(self, state: &mut Self::State) {
187: 185:         let StringState { node, str } = state;
188: 186:         if &self != str {
189: 187:             Rndr::set_text(node, &self);
190: 188:             *str = self;
191: 189:         }
192: 190:     }
193: 191: }
194: 192: 
195: 193: impl RenderHtml for String {
196: 194:     const MIN_LENGTH: usize = 0;
197: 195:     type AsyncOutput = Self;
198: 196:     type Owned = Self;
199: 197: 
200: 198:     fn dry_resolve(&mut self) {}
201: 199: 
202: 200:     async fn resolve(self) -> Self::AsyncOutput {
203: 201:         self
204: 202:     }
205: 203: 
206: 204:     fn html_len(&self) -> usize {
207: 205:         self.len()
208: 206:     }
209: 207: 
210: 208:     fn to_html_with_buf(
211: 209:         self,
212: 210:         buf: &mut String,
213: 211:         position: &mut Position,
214: 212:         escape: bool,
215: 213:         mark_branches: bool,
216: 214:         extra_attrs: Vec<AnyAttribute>,
217: 215:     ) {
218: 216:         <&str as RenderHtml>::to_html_with_buf(
219: 217:             self.as_str(),
220: 218:             buf,
221: 219:             position,
222: 220:             escape,
223: 221:             mark_branches,
224: 222:             extra_attrs,
225: 223:         )
226: 224:     }
227: 225: 
228: 226:     fn hydrate<const FROM_SERVER: bool>(
229: 227:         self,
230: 228:         cursor: &Cursor,
231: 229:         position: &PositionState,
232: 230:     ) -> Self::State {
233: 231:         let StrState { node, .. } =
234: 232:             self.as_str().hydrate::<FROM_SERVER>(cursor, position);
235: 233:         StringState { node, str: self }
236: 234:     }
237: 235: 
238: 236:     fn into_owned(self) -> Self::Owned {
239: 237:         self
240: 238:     }
241: 239: }
242: 240: 
243: 241: impl ToTemplate for String {
244: 242:     const TEMPLATE: &'static str = <&str as ToTemplate>::TEMPLATE;
245: 243: 
246: 244:     fn to_template(
247: 245:         buf: &mut String,
248: 246:         class: &mut String,
249: 247:         style: &mut String,
250: 248:         inner_html: &mut String,
251: 249:         position: &mut Position,
252: 250:     ) {
253: 251:         <&str as ToTemplate>::to_template(
254: 252:             buf, class, style, inner_html, position,
255: 253:         )
256: 254:     }
257: 255: }
258: 256: 
259: 257: impl Mountable for StringState {
260: 258:     fn unmount(&mut self) {
261: 259:         self.node.unmount()
262: 260:     }
263: 261: 
264: 262:     fn mount(
265: 263:         &mut self,
266: 264:         parent: &crate::renderer::types::Element,
267: 265:         marker: Option<&crate::renderer::types::Node>,
268: 266:     ) {
269: 267:         Rndr::insert_node(parent, self.node.as_ref(), marker);
270: 268:     }
271: 269: 
272: 270:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
273: 271:         self.node.insert_before_this(child)
274: 272:     }
275: 273: 
276: 274:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
277: 275:         vec![]
278: 276:     }
279: 277: }
280: 278: 
281: 279: /// Retained view state for `Rc<str>`.
282: 280: pub struct RcStrState {
283: 281:     node: crate::renderer::types::Text,
284: 282:     str: Rc<str>,
285: 283: }
286: 284: 
287: 285: impl Render for Rc<str> {
288: 286:     type State = RcStrState;
289: 287: 
290: 288:     fn build(self) -> Self::State {
291: 289:         let node = Rndr::create_text_node(&self);
292: 290:         RcStrState { node, str: self }
293: 291:     }
294: 292: 
295: 293:     fn rebuild(self, state: &mut Self::State) {
296: 294:         let RcStrState { node, str } = state;
297: 295:         if !Rc::ptr_eq(&self, str) {
298: 296:             Rndr::set_text(node, &self);
299: 297:             *str = self;
300: 298:         }
301: 299:     }
302: 300: }
303: 301: 
304: 302: // can't Send an Rc<str> between threads, so can't implement async HTML rendering that might need
305: 303: // to send it
306: 304: /*
307: 305: impl RenderHtml for Rc<str>
308: 306: where
309: 307: 
310: 308: {
311: 309:     type AsyncOutput = Self;
312: 310: 
313: 311:     const MIN_LENGTH: usize = 0;
314: 312: 
315: 313:     async fn resolve(self) -> Self::AsyncOutput {
316: 314:     self
317: 315:     }
318: 316: 
319: 317:     fn html_len(&self) -> usize {
320: 318:         self.len()
321: 319:     }
322: 320: 
323: 321:     fn to_html_with_buf(self, buf: &mut String, position: &mut Position, escape: bool, mark_branches: bool) {
324: 322:         <&str as RenderHtml>::to_html_with_buf(&self, buf, position)
325: 323:     }
326: 324: 
327: 325:     fn hydrate<const FROM_SERVER: bool>(
328: 326:         self,
329: 327:         cursor: &Cursor,
330: 328:         position: &PositionState,
331: 329:     ) -> Self::State {
332: 330:         let this: &str = self.as_ref();
333: 331:         let StrState { node, .. } =
334: 332:             this.hydrate::<FROM_SERVER>(cursor, position);
335: 333:         RcStrState { node, str: self }
336: 334:     }
337: 335: }*/
338: 336: 
339: 337: impl ToTemplate for Rc<str> {
340: 338:     const TEMPLATE: &'static str = <&str as ToTemplate>::TEMPLATE;
341: 339: 
342: 340:     fn to_template(
343: 341:         buf: &mut String,
344: 342:         class: &mut String,
345: 343:         style: &mut String,
346: 344:         inner_html: &mut String,
347: 345:         position: &mut Position,
348: 346:     ) {
349: 347:         <&str as ToTemplate>::to_template(
350: 348:             buf, class, style, inner_html, position,
351: 349:         )
352: 350:     }
353: 351: }
354: 352: 
355: 353: impl Mountable for RcStrState {
356: 354:     fn unmount(&mut self) {
357: 355:         self.node.unmount()
358: 356:     }
359: 357: 
360: 358:     fn mount(
361: 359:         &mut self,
362: 360:         parent: &crate::renderer::types::Element,
363: 361:         marker: Option<&crate::renderer::types::Node>,
364: 362:     ) {
365: 363:         Rndr::insert_node(parent, self.node.as_ref(), marker);
366: 364:     }
367: 365: 
368: 366:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
369: 367:         self.node.insert_before_this(child)
370: 368:     }
371: 369: 
372: 370:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
373: 371:         vec![]
374: 372:     }
375: 373: }
376: 374: 
377: 375: /// Retained view state for `Arc<str>`.
378: 376: pub struct ArcStrState {
379: 377:     node: crate::renderer::types::Text,
380: 378:     str: Arc<str>,
381: 379: }
382: 380: 
383: 381: impl Render for Arc<str> {
384: 382:     type State = ArcStrState;
385: 383: 
386: 384:     fn build(self) -> Self::State {
387: 385:         let node = Rndr::create_text_node(&self);
388: 386:         ArcStrState { node, str: self }
389: 387:     }
390: 388: 
391: 389:     fn rebuild(self, state: &mut Self::State) {
392: 390:         let ArcStrState { node, str } = state;
393: 391:         if self != *str {
394: 392:             Rndr::set_text(node, &self);
395: 393:             *str = self;
396: 394:         }
397: 395:     }
398: 396: }
399: 397: 
400: 398: impl RenderHtml for Arc<str> {
401: 399:     type AsyncOutput = Self;
402: 400:     type Owned = Self;
403: 401: 
404: 402:     const MIN_LENGTH: usize = 0;
405: 403: 
406: 404:     fn dry_resolve(&mut self) {}
407: 405: 
408: 406:     async fn resolve(self) -> Self::AsyncOutput {
409: 407:         self
410: 408:     }
411: 409: 
412: 410:     fn html_len(&self) -> usize {
413: 411:         self.len()
414: 412:     }
415: 413: 
416: 414:     fn to_html_with_buf(
417: 415:         self,
418: 416:         buf: &mut String,
419: 417:         position: &mut Position,
420: 418:         escape: bool,
421: 419:         mark_branches: bool,
422: 420:         extra_attrs: Vec<AnyAttribute>,
423: 421:     ) {
424: 422:         <&str as RenderHtml>::to_html_with_buf(
425: 423:             &self,
426: 424:             buf,
427: 425:             position,
428: 426:             escape,
429: 427:             mark_branches,
430: 428:             extra_attrs,
431: 429:         )
432: 430:     }
433: 431: 
434: 432:     fn hydrate<const FROM_SERVER: bool>(
435: 433:         self,
436: 434:         cursor: &Cursor,
437: 435:         position: &PositionState,
438: 436:     ) -> Self::State {
439: 437:         let this: &str = self.as_ref();
440: 438:         let StrState { node, .. } =
441: 439:             this.hydrate::<FROM_SERVER>(cursor, position);
442: 440:         ArcStrState { node, str: self }
443: 441:     }
444: 442: 
445: 443:     fn into_owned(self) -> Self::Owned {
446: 444:         self
447: 445:     }
448: 446: }
449: 447: 
450: 448: impl ToTemplate for Arc<str> {
451: 449:     const TEMPLATE: &'static str = <&str as ToTemplate>::TEMPLATE;
452: 450: 
453: 451:     fn to_template(
454: 452:         buf: &mut String,
455: 453:         class: &mut String,
456: 454:         style: &mut String,
457: 455:         inner_html: &mut String,
458: 456:         position: &mut Position,
459: 457:     ) {
460: 458:         <&str as ToTemplate>::to_template(
461: 459:             buf, class, style, inner_html, position,
462: 460:         )
463: 461:     }
464: 462: }
465: 463: 
466: 464: impl Mountable for ArcStrState {
467: 465:     fn unmount(&mut self) {
468: 466:         self.node.unmount()
469: 467:     }
470: 468: 
471: 469:     fn mount(
472: 470:         &mut self,
473: 471:         parent: &crate::renderer::types::Element,
474: 472:         marker: Option<&crate::renderer::types::Node>,
475: 473:     ) {
476: 474:         Rndr::insert_node(parent, self.node.as_ref(), marker);
477: 475:     }
478: 476: 
479: 477:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
480: 478:         self.node.insert_before_this(child)
481: 479:     }
482: 480: 
483: 481:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
484: 482:         vec![]
485: 483:     }
486: 484: }
487: 485: 
488: 486: /// Retained view state for `Cow<'_, str>`.
489: 487: pub struct CowStrState<'a> {
490: 488:     node: crate::renderer::types::Text,
491: 489:     str: Cow<'a, str>,
492: 490: }
493: 491: 
494: 492: impl<'a> Render for Cow<'a, str> {
495: 493:     type State = CowStrState<'a>;
496: 494: 
497: 495:     fn build(self) -> Self::State {
498: 496:         let node = Rndr::create_text_node(&self);
499: 497:         CowStrState { node, str: self }
500: 498:     }
501: 499: 
502: 500:     fn rebuild(self, state: &mut Self::State) {
503: 501:         let CowStrState { node, str } = state;
504: 502:         if self != *str {
505: 503:             Rndr::set_text(node, &self);
506: 504:             *str = self;
507: 505:         }
508: 506:     }
509: 507: }
510: 508: 
511: 509: impl RenderHtml for Cow<'_, str> {
512: 510:     type AsyncOutput = Self;
513: 511:     type Owned = String;
514: 512: 
515: 513:     const MIN_LENGTH: usize = 0;
516: 514: 
517: 515:     fn dry_resolve(&mut self) {}
518: 516: 
519: 517:     async fn resolve(self) -> Self::AsyncOutput {
520: 518:         self
521: 519:     }
522: 520: 
523: 521:     fn html_len(&self) -> usize {
524: 522:         self.len()
525: 523:     }
526: 524: 
527: 525:     fn to_html_with_buf(
528: 526:         self,
529: 527:         buf: &mut String,
530: 528:         position: &mut Position,
531: 529:         escape: bool,
532: 530:         mark_branches: bool,
533: 531:         extra_attrs: Vec<AnyAttribute>,
534: 532:     ) {
535: 533:         <&str as RenderHtml>::to_html_with_buf(
536: 534:             &self,
537: 535:             buf,
538: 536:             position,
539: 537:             escape,
540: 538:             mark_branches,
541: 539:             extra_attrs,
542: 540:         )
543: 541:     }
544: 542: 
545: 543:     fn hydrate<const FROM_SERVER: bool>(
546: 544:         self,
547: 545:         cursor: &Cursor,
548: 546:         position: &PositionState,
549: 547:     ) -> Self::State {
550: 548:         let this: &str = self.as_ref();
551: 549:         let StrState { node, .. } =
552: 550:             this.hydrate::<FROM_SERVER>(cursor, position);
553: 551:         CowStrState { node, str: self }
554: 552:     }
555: 553: 
556: 554:     fn into_owned(self) -> <Self as RenderHtml>::Owned {
557: 555:         self.into_owned()
558: 556:     }
559: 557: }
560: 558: 
561: 559: impl ToTemplate for Cow<'_, str> {
562: 560:     const TEMPLATE: &'static str = <&str as ToTemplate>::TEMPLATE;
563: 561: 
564: 562:     fn to_template(
565: 563:         buf: &mut String,
566: 564:         class: &mut String,
567: 565:         style: &mut String,
568: 566:         inner_html: &mut String,
569: 567:         position: &mut Position,
570: 568:     ) {
571: 569:         <&str as ToTemplate>::to_template(
572: 570:             buf, class, style, inner_html, position,
573: 571:         )
574: 572:     }
575: 573: }
576: 574: 
577: 575: impl Mountable for CowStrState<'_> {
578: 576:     fn unmount(&mut self) {
579: 577:         self.node.unmount()
580: 578:     }
581: 579: 
582: 580:     fn mount(
583: 581:         &mut self,
584: 582:         parent: &crate::renderer::types::Element,
585: 583:         marker: Option<&crate::renderer::types::Node>,
586: 584:     ) {
587: 585:         Rndr::insert_node(parent, self.node.as_ref(), marker);
588: 586:     }
589: 587: 
590: 588:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
591: 589:         self.node.insert_before_this(child)
592: 590:     }
593: 591: 
594: 592:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
595: 593:         vec![]
596: 594:     }
597: 595: }
598: 596: ```
599: 597: ```
600: 598: ```
601: 599: ```
602: 600: ```
603: 601: ```
604: 602: ```
605: 603: ```
606: ```
```
