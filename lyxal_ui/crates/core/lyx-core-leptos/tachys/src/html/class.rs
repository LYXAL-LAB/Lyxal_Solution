### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\class.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\class.rs
18: 16: ```rust
19: 17: use super::attribute::{
20: 18:     maybe_next_attr_erasure_macros::next_attr_output_type, Attribute,
21: 19:     NamedAttributeKey, NextAttribute,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::maybe_next_attr_erasure_macros::next_attr_combine,
25: 23:     renderer::Rndr,
26: 24:     view::{Position, ToTemplate},
27: 25: };
28: 26: use std::{borrow::Cow, future::Future, sync::Arc};
29: 27: 
30: 28: /// Adds a CSS class.
31: 29: #[inline(always)]
32: 30: pub fn class<C>(class: C) -> Class<C>
33: 31: where
34: 32:     C: IntoClass,
35: 33: {
36: 34:     Class { class }
37: 35: }
38: 36: 
39: 37: /// A CSS class.
40: 38: #[derive(Debug)]
41: 39: pub struct Class<C> {
42: 40:     class: C,
43: 41: }
44: 42: 
45: 43: impl<C> Clone for Class<C>
46: 44: where
47: 45:     C: Clone,
48: 46: {
49: 47:     fn clone(&self) -> Self {
50: 48:         Self {
51: 49:             class: self.class.clone(),
52: 50:         }
53: 51:     }
54: 52: }
55: 53: 
56: 54: impl<C> Attribute for Class<C>
57: 55: where
58: 56:     C: IntoClass,
59: 57: {
60: 58:     const MIN_LENGTH: usize = C::MIN_LENGTH;
61: 59: 
62: 60:     type AsyncOutput = Class<C::AsyncOutput>;
63: 61:     type State = C::State;
64: 62:     type Cloneable = Class<C::Cloneable>;
65: 63:     type CloneableOwned = Class<C::CloneableOwned>;
66: 64: 
67: 65:     fn html_len(&self) -> usize {
68: 66:         self.class.html_len() + 1
69: 67:     }
70: 68: 
71: 69:     fn to_html(
72: 70:         self,
73: 71:         _buf: &mut String,
74: 72:         class: &mut String,
75: 73:         _style: &mut String,
76: 74:         _inner_html: &mut String,
77: 75:     ) {
78: 76:         // If this is a class="..." attribute (not class:name=value), clear previous value
79: 77:         if self.class.should_overwrite() {
80: 78:             class.clear();
81: 79:         }
82: 80:         class.push(' ');
83: 81:         self.class.to_html(class);
84: 82:     }
85: 83: 
86: 84:     fn hydrate<const FROM_SERVER: bool>(
87: 85:         self,
88: 86:         el: &crate::renderer::types::Element,
89: 87:     ) -> Self::State {
90: 88:         self.class.hydrate::<FROM_SERVER>(el)
91: 89:     }
92: 90: 
93: 91:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
94: 92:         self.class.build(el)
95: 93:     }
96: 94: 
97: 95:     fn rebuild(self, state: &mut Self::State) {
98: 96:         self.class.rebuild(state)
99: 97:     }
100: 98: 
101: 99:     fn into_cloneable(self) -> Self::Cloneable {
102: 100:         Class {
103: 101:             class: self.class.into_cloneable(),
104: 102:         }
105: 103:     }
106: 104: 
107: 105:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
108: 106:         Class {
109: 107:             class: self.class.into_cloneable_owned(),
110: 108:         }
111: 109:     }
112: 110: 
113: 111:     fn dry_resolve(&mut self) {
114: 112:         self.class.dry_resolve();
115: 113:     }
116: 114: 
117: 115:     async fn resolve(self) -> Self::AsyncOutput {
118: 116:         Class {
119: 117:             class: self.class.resolve().await,
120: 118:         }
121: 119:     }
122: 120: 
123: 121:     fn keys(&self) -> Vec<NamedAttributeKey> {
124: 122:         vec![NamedAttributeKey::Attribute("class".into())]
125: 123:     }
126: 124: }
127: 125: 
128: 126: impl<C> NextAttribute for Class<C>
129: 127: where
130: 128:     C: IntoClass,
131: 129: {
132: 130:     next_attr_output_type!(Self, NewAttr);
133: 131: 
134: 132:     fn add_any_attr<NewAttr: Attribute>(
135: 133:         self,
136: 134:         new_attr: NewAttr,
137: 135:     ) -> Self::Output<NewAttr> {
138: 136:         next_attr_combine!(self, new_attr)
139: 137:     }
140: 138: }
141: 139: 
142: 140: impl<C> ToTemplate for Class<C>
143: 141: where
144: 142:     C: IntoClass,
145: 143: {
146: 144:     const CLASS: &'static str = C::TEMPLATE;
147: 145: 
148: 146:     fn to_template(
149: 147:         _buf: &mut String,
150: 148:         class: &mut String,
151: 149:         _style: &mut String,
152: 150:         _inner_html: &mut String,
153: 151:         _position: &mut Position,
154: 152:     ) {
155: 153:         C::to_template(class);
156: 154:     }
157: 155: }
158: 156: 
159: 157: /// A possible value for a CSS class.
160: 158: pub trait IntoClass: Send {
161: 159:     /// The HTML that should be included in a `<template>`.
162: 160:     const TEMPLATE: &'static str = "";
163: 161:     /// The minimum length of the HTML.
164: 162:     const MIN_LENGTH: usize = Self::TEMPLATE.len();
165: 163: 
166: 164:     /// The type after all async data have resolved.
167: 165:     type AsyncOutput: IntoClass;
168: 166:     /// The view state retained between building and rebuilding.
169: 167:     type State;
170: 168:     /// An equivalent value that can be cloned.
171: 169:     type Cloneable: IntoClass + Clone;
172: 170:     /// An equivalent value that can be cloned and is `'static`.
173: 171:     type CloneableOwned: IntoClass + Clone + 'static;
174: 172: 
175: 173:     /// The estimated length of the HTML.
176: 174:     fn html_len(&self) -> usize;
177: 175: 
178: 176:     /// Renders the class to HTML.
179: 177:     fn to_html(self, class: &mut String);
180: 178: 
181: 179:     /// Whether this class attribute should overwrite previous class values.
182: 180:     /// Returns `true` for `class="..."` attributes, `false` for `class:name=value` directives.
183: 181:     fn should_overwrite(&self) -> bool {
184: 182:         false
185: 183:     }
186: 184: 
187: 185:     /// Renders the class to HTML for a `<template>`.
188: 186:     #[allow(unused)] // it's used with `nightly` feature
189: 187:     fn to_template(class: &mut String) {}
190: 188: 
191: 189:     /// Adds interactivity as necessary, given DOM nodes that were created from HTML that has
192: 190:     /// either been rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, or cloned for a `<template>`.
193: 191:     fn hydrate<const FROM_SERVER: bool>(
194: 192:         self,
195: 193:         el: &crate::renderer::types::Element,
196: 194:     ) -> Self::State;
197: 195: 
198: 196:     /// Adds this class to the element during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering.
199: 197:     fn build(self, el: &crate::renderer::types::Element) -> Self::State;
200: 198: 
201: 199:     /// Updates the value.
202: 200:     fn rebuild(self, state: &mut Self::State);
203: 201: 
204: 202:     /// Converts this to a cloneable type.
205: 203:     fn into_cloneable(self) -> Self::Cloneable;
206: 204: 
207: 205:     /// Converts this to a cloneable, owned type.
208: 206:     fn into_cloneable_owned(self) -> Self::CloneableOwned;
209: 207: 
210: 208:     /// “Runs” the attribute without other side effects. For primitive types, this is a no-op. For
211: 209:     /// reactive types, this can be used to gather data about reactivity or about asynchronous data
212: 210:     /// that needs to be loaded.
213: 211:     fn dry_resolve(&mut self);
214: 212: 
215: 213:     /// “Resolves” this into a type that is not waiting for any asynchronous data.
216: 214:     fn resolve(self) -> impl Future<Output = Self::AsyncOutput> + Send;
217: 215: 
218: 216:     /// Reset the class list to the state before this class was added.
219: 217:     fn reset(state: &mut Self::State);
220: 218: }
221: 219: 
222: 220: impl<T: IntoClass> IntoClass for Option<T> {
223: 221:     type AsyncOutput = Option<T::AsyncOutput>;
224: 222:     type State = (crate::renderer::types::Element, Option<T::State>);
225: 223:     type Cloneable = Option<T::Cloneable>;
226: 224:     type CloneableOwned = Option<T::CloneableOwned>;
227: 225: 
228: 226:     fn html_len(&self) -> usize {
229: 227:         self.as_ref().map_or(0, IntoClass::html_len)
230: 228:     }
231: 229: 
232: 230:     fn to_html(self, class: &mut String) {
233: 231:         if let Some(t) = self {
234: 232:             t.to_html(class);
235: 233:         }
236: 234:     }
237: 235: 
238: 236:     fn hydrate<const FROM_SERVER: bool>(
239: 237:         self,
240: 238:         el: &crate::renderer::types::Element,
241: 239:     ) -> Self::State {
242: 240:         if let Some(t) = self {
243: 241:             (el.clone(), Some(t.hydrate::<FROM_SERVER>(el)))
244: 242:         } else {
245: 243:             (el.clone(), None)
246: 244:         }
247: 245:     }
248: 246: 
249: 247:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
250: 248:         if let Some(t) = self {
251: 249:             (el.clone(), Some(t.build(el)))
252: 250:         } else {
253: 251:             (el.clone(), None)
254: 252:         }
255: 253:     }
256: 254: 
257: 255:     fn rebuild(self, state: &mut Self::State) {
258: 256:         let el = &state.0;
259: 257:         let prev_state = &mut state.1;
260: 258:         let maybe_next_t_state = match (prev_state.take(), self) {
261: 259:             (Some(mut prev_t_state), None) => {
262: 260:                 T::reset(&mut prev_t_state);
263: 261:                 Some(None)
264: 262:             }
265: 263:             (None, Some(t)) => Some(Some(t.build(el))),
266: 264:             (Some(mut prev_t_state), Some(t)) => {
267: 265:                 t.rebuild(&mut prev_t_state);
268: 266:                 Some(Some(prev_t_state))
269: 267:             }
270: 268:             (None, None) => Some(None),
271: 269:         };
272: 270:         if let Some(next_t_state) = maybe_next_t_state {
273: 271:             state.1 = next_t_state;
274: 272:         }
275: 273:     }
276: 274: 
277: 275:     fn into_cloneable(self) -> Self::Cloneable {
278: 276:         self.map(|t| t.into_cloneable())
279: 277:     }
280: 278: 
281: 279:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
282: 280:         self.map(|t| t.into_cloneable_owned())
283: 281:     }
284: 282: 
285: 283:     fn dry_resolve(&mut self) {
286: 284:         if let Some(t) = self {
287: 285:             t.dry_resolve();
288: 286:         }
289: 287:     }
290: 288: 
291: 289:     async fn resolve(self) -> Self::AsyncOutput {
292: 290:         if let Some(t) = self {
293: 291:             Some(t.resolve().await)
294: 292:         } else {
295: 293:             None
296: 294:         }
297: 295:     }
298: 296: 
299: 297:     fn reset(state: &mut Self::State) {
300: 298:         if let Some(prev_t_state) = &mut state.1 {
301: 299:             T::reset(prev_t_state);
302: 300:         }
303: 301:     }
304: 302: }
305: 303: 
306: 304: impl IntoClass for &str {
307: 305:     type AsyncOutput = Self;
308: 306:     type State = (crate::renderer::types::Element, Self);
309: 307:     type Cloneable = Self;
310: 308:     type CloneableOwned = Arc<str>;
311: 309: 
312: 310:     fn html_len(&self) -> usize {
313: 311:         self.len()
314: 312:     }
315: 313: 
316: 314:     fn to_html(self, class: &mut String) {
317: 315:         class.push_str(self);
318: 316:     }
319: 317: 
320: 318:     fn should_overwrite(&self) -> bool {
321: 319:         true
322: 320:     }
323: 321: 
324: 322:     fn hydrate<const FROM_SERVER: bool>(
325: 323:         self,
326: 324:         el: &crate::renderer::types::Element,
327: 325:     ) -> Self::State {
328: 326:         if !FROM_SERVER {
329: 327:             Rndr::set_attribute(el, "class", self);
330: 328:         }
331: 329:         (el.clone(), self)
332: 330:     }
333: 331: 
334: 332:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
335: 333:         Rndr::set_attribute(el, "class", self);
336: 334:         (el.clone(), self)
337: 335:     }
338: 336: 
339: 337:     fn rebuild(self, state: &mut Self::State) {
340: 338:         let (el, prev) = state;
341: 339:         if self != *prev {
342: 340:             Rndr::set_attribute(el, "class", self);
343: 341:         }
344: 342:         *prev = self;
345: 343:     }
346: 344: 
347: 345:     fn into_cloneable(self) -> Self::Cloneable {
348: 346:         self
349: 347:     }
350: 348: 
351: 349:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
352: 350:         self.into()
353: 351:     }
354: 352: 
355: 353:     fn dry_resolve(&mut self) {}
356: 354: 
357: 355:     async fn resolve(self) -> Self::AsyncOutput {
358: 356:         self
359: 357:     }
360: 358: 
361: 359:     fn reset(state: &mut Self::State) {
362: 360:         let (el, _prev) = state;
363: 361:         Rndr::remove_attribute(el, "class");
364: 362:     }
365: 363: }
366: 364: 
367: 365: impl IntoClass for Cow<'_, str> {
368: 366:     type AsyncOutput = Self;
369: 367:     type State = (crate::renderer::types::Element, Self);
370: 368:     type Cloneable = Arc<str>;
371: 369:     type CloneableOwned = Arc<str>;
372: 370: 
373: 371:     fn html_len(&self) -> usize {
374: 372:         self.len()
375: 373:     }
376: 374: 
377: 375:     fn to_html(self, class: &mut String) {
378: 376:         IntoClass::to_html(&*self, class);
379: 377:     }
380: 378: 
381: 379:     fn should_overwrite(&self) -> bool {
382: 380:         true
383: 381:     }
384: 382: 
385: 383:     fn hydrate<const FROM_SERVER: bool>(
386: 384:         self,
387: 385:         el: &crate::renderer::types::Element,
388: 386:     ) -> Self::State {
389: 387:         if !FROM_SERVER {
390: 388:             Rndr::set_attribute(el, "class", &self);
391: 389:         }
392: 390:         (el.clone(), self)
393: 391:     }
394: 392: 
395: 393:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
396: 394:         Rndr::set_attribute(el, "class", &self);
397: 395:         (el.clone(), self)
398: 396:     }
399: 397: 
400: 398:     fn rebuild(self, state: &mut Self::State) {
401: 399:         let (el, prev) = state;
402: 400:         if self != *prev {
403: 401:             Rndr::set_attribute(el, "class", &self);
404: 402:         }
405: 403:         *prev = self;
406: 404:     }
407: 405: 
408: 406:     fn into_cloneable(self) -> Self::Cloneable {
409: 407:         self.into()
410: 408:     }
411: 409: 
412: 410:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
413: 411:         self.into()
414: 412:     }
415: 413: 
416: 414:     fn dry_resolve(&mut self) {}
417: 415: 
418: 416:     async fn resolve(self) -> Self::AsyncOutput {
419: 417:         self
420: 418:     }
421: 419: 
422: 420:     fn reset(state: &mut Self::State) {
423: 421:         let (el, _prev) = state;
424: 422:         Rndr::remove_attribute(el, "class");
425: 423:     }
426: 424: }
427: 425: 
428: 426: impl IntoClass for String {
429: 427:     type AsyncOutput = Self;
430: 428:     type State = (crate::renderer::types::Element, Self);
431: 429:     type Cloneable = Arc<str>;
432: 430:     type CloneableOwned = Arc<str>;
433: 431: 
434: 432:     fn html_len(&self) -> usize {
435: 433:         self.len()
436: 434:     }
437: 435: 
438: 436:     fn to_html(self, class: &mut String) {
439: 437:         IntoClass::to_html(self.as_str(), class);
440: 438:     }
441: 439: 
442: 440:     fn should_overwrite(&self) -> bool {
443: 441:         true
444: 442:     }
445: 443: 
446: 444:     fn hydrate<const FROM_SERVER: bool>(
447: 445:         self,
448: 446:         el: &crate::renderer::types::Element,
449: 447:     ) -> Self::State {
450: 448:         if !FROM_SERVER {
451: 449:             Rndr::set_attribute(el, "class", &self);
452: 450:         }
453: 451:         (el.clone(), self)
454: 452:     }
455: 453: 
456: 454:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
457: 455:         Rndr::set_attribute(el, "class", &self);
458: 456:         (el.clone(), self)
459: 457:     }
460: 458: 
461: 459:     fn rebuild(self, state: &mut Self::State) {
462: 460:         let (el, prev) = state;
463: 461:         if self != *prev {
464: 462:             Rndr::set_attribute(el, "class", &self);
465: 463:         }
466: 464:         *prev = self;
467: 465:     }
468: 466: 
469: 467:     fn into_cloneable(self) -> Self::Cloneable {
470: 468:         self.into()
471: 469:     }
472: 470: 
473: 471:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
474: 472:         self.into()
475: 473:     }
476: 474: 
477: 475:     fn dry_resolve(&mut self) {}
478: 476: 
479: 477:     async fn resolve(self) -> Self::AsyncOutput {
480: 478:         self
481: 479:     }
482: 480: 
483: 481:     fn reset(state: &mut Self::State) {
484: 482:         let (el, _prev) = state;
485: 483:         Rndr::remove_attribute(el, "class");
486: 484:     }
487: 485: }
488: 486: 
489: 487: impl IntoClass for Arc<str> {
490: 488:     type AsyncOutput = Self;
491: 489:     type State = (crate::renderer::types::Element, Self);
492: 490:     type Cloneable = Self;
493: 491:     type CloneableOwned = Self;
494: 492: 
495: 493:     fn html_len(&self) -> usize {
496: 494:         self.len()
497: 495:     }
498: 496: 
499: 497:     fn to_html(self, class: &mut String) {
500: 498:         IntoClass::to_html(self.as_ref(), class);
501: 499:     }
502: 500: 
503: 501:     fn should_overwrite(&self) -> bool {
504: 502:         true
505: 503:     }
506: 504: 
507: 505:     fn hydrate<const FROM_SERVER: bool>(
508: 506:         self,
509: 507:         el: &crate::renderer::types::Element,
510: 508:     ) -> Self::State {
511: 509:         if !FROM_SERVER {
512: 510:             Rndr::set_attribute(el, "class", &self);
513: 511:         }
514: 512:         (el.clone(), self)
515: 513:     }
516: 514: 
517: 515:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
518: 516:         Rndr::set_attribute(el, "class", &self);
519: 517:         (el.clone(), self)
520: 518:     }
521: 519: 
522: 520:     fn rebuild(self, state: &mut Self::State) {
523: 521:         let (el, prev) = state;
524: 522:         if self != *prev {
525: 523:             Rndr::set_attribute(el, "class", &self);
526: 524:         }
527: 525:         *prev = self;
528: 526:     }
529: 527: 
530: 528:     fn into_cloneable(self) -> Self::Cloneable {
531: 529:         self
532: 530:     }
533: 531: 
534: 532:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
535: 533:         self
536: 534:     }
537: 535: 
538: 536:     fn dry_resolve(&mut self) {}
539: 537: 
540: 538:     async fn resolve(self) -> Self::AsyncOutput {
541: 539:         self
542: 540:     }
543: 541: 
544: 542:     fn reset(state: &mut Self::State) {
545: 543:         let (el, _prev) = state;
546: 544:         Rndr::remove_attribute(el, "class");
547: 545:     }
548: 546: }
549: 547: 
550: 548: impl IntoClass for (&'static str, bool) {
551: 549:     type AsyncOutput = Self;
552: 550:     type State = (crate::renderer::types::ClassList, bool, &'static str);
553: 551:     type Cloneable = Self;
554: 552:     type CloneableOwned = Self;
555: 553: 
556: 554:     fn html_len(&self) -> usize {
557: 555:         self.0.len()
558: 556:     }
559: 557: 
560: 558:     fn to_html(self, class: &mut String) {
561: 559:         let (name, include) = self;
562: 560:         if include {
563: 561:             class.push_str(name);
564: 562:         }
565: 563:     }
566: 564: 
567: 565:     fn hydrate<const FROM_SERVER: bool>(
568: 566:         self,
569: 567:         el: &crate::renderer::types::Element,
570: 568:     ) -> Self::State {
571: 569:         let (name, include) = self;
572: 570:         let class_list = Rndr::class_list(el);
573: 571:         if !FROM_SERVER && include {
574: 572:             Rndr::add_class(&class_list, name);
575: 573:         }
576: 574:         (class_list, self.1, name)
577: 575:     }
578: 576: 
579: 577:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
580: 578:         let (name, include) = self;
581: 579:         let class_list = Rndr::class_list(el);
582: 580:         if include {
583: 581:             Rndr::add_class(&class_list, name);
584: 582:         }
585: 583:         (class_list, self.1, name)
586: 584:     }
587: 585: 
588: 586:     fn rebuild(self, state: &mut Self::State) {
589: 587:         let (name, include) = self;
590: 588:         let (class_list, prev_include, prev_name) = state;
591: 589:         if name == *prev_name {
592: 590:             if include != *prev_include {
593: 591:                 if include {
594: 592:                     Rndr::add_class(class_list, name);
595: 593:                 } else {
596: 594:                     Rndr::remove_class(class_list, name);
597: 595:                 }
598: 596:             }
599: 597:         } else {
600: 598:             if *prev_include {
601: 599:                 Rndr::remove_class(class_list, prev_name);
602: 600:             }
603: 601:             if include {
604: 602:                 Rndr::add_class(class_list, name);
605: 603:             }
606: 604:         }
607: 605:         *prev_include = include;
608: 606:         *prev_name = name;
609: 607:     }
610: 608: 
611: 609:     fn into_cloneable(self) -> Self::Cloneable {
612: 610:         self
613: 611:     }
614: 612: 
615: 613:     fn into_cloneable_owned(self) -> Self::Cloneable {
616: 614:         self
617: 615:     }
618: 616: 
619: 617:     fn dry_resolve(&mut self) {}
620: 618: 
621: 619:     async fn resolve(self) -> Self::AsyncOutput {
622: 620:         self
623: 621:     }
624: 622: 
625: 623:     fn reset(state: &mut Self::State) {
626: 624:         let (class_list, _, name) = state;
627: 625:         Rndr::remove_class(class_list, name);
628: 626:     }
629: 627: }
630: 628: 
631: 629: #[cfg(all(feature = "nightly", rustc_nightly))]
632: 630: impl<const V: &'static str> IntoClass for crate::view::static_types::Static<V> {
633: 631:     const TEMPLATE: &'static str = V;
634: 632: 
635: 633:     type AsyncOutput = Self;
636: 634:     type State = ();
637: 635:     type Cloneable = Self;
638: 636:     type CloneableOwned = Self;
639: 637: 
640: 638:     fn html_len(&self) -> usize {
641: 639:         V.len()
642: 640:     }
643: 641: 
644: 642:     fn to_html(self, class: &mut String) {
645: 643:         class.push_str(V);
646: 644:     }
647: 645: 
648: 646:     fn to_template(class: &mut String) {
649: 647:         class.push_str(V);
650: 648:     }
651: 649: 
652: 650:     fn hydrate<const FROM_SERVER: bool>(
653: 651:         self,
654: 652:         _el: &crate::renderer::types::Element,
655: 653:     ) -> Self::State {
656: 654:     }
657: 655: 
658: 656:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
659: 657:         Rndr::set_attribute(el, "class", V);
660: 658:     }
661: 659: 
662: 660:     fn rebuild(self, _state: &mut Self::State) {}
663: 661: 
664: 662:     fn into_cloneable(self) -> Self::Cloneable {
665: 663:         self
666: 664:     }
667: 665: 
668: 666:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
669: 667:         self
670: 668:     }
671: 669: 
672: 670:     fn dry_resolve(&mut self) {}
673: 671: 
674: 672:     async fn resolve(self) -> Self::AsyncOutput {
675: 673:         self
676: 674:     }
677: 675: 
678: 676:     fn reset(_state: &mut Self::State) {}
679: 677: }
680: 678: 
681: 679: /* #[cfg(test)]
682: 680: mod tests {
683: 681:     use crate::{
684: 682:         html::{
685: 683:             class::class,
686: 684:             element::{p, HtmlElement},
687: 685:         },
688: 686:         renderer::dom::Dom,
689: 687:         view::{Position, PositionState, RenderHtml},
690: 688:     };
691: 689: 
692: 690:     #[test]
693: 691:     fn adds_simple_class() {
694: 692:         let mut html = String::new();
695: 693:         let el: HtmlElement<_, _, _, Dom> = p(class("foo bar"), ());
696: 694:         el.to_html(&mut html, &PositionState::new(Position::FirstChild));
697: 695: 
698: 696:         assert_eq!(html, r#"<p class="foo bar"></p>"#);
699: 697:     }
700: 698: 
701: 699:     #[test]
702: 700:     fn adds_class_with_dynamic() {
703: 701:         let mut html = String::new();
704: 702:         let el: HtmlElement<_, _, _, Dom> =
705: 703:             p((class("foo bar"), class(("baz", true))), ());
706: 704:         el.to_html(&mut html, &PositionState::new(Position::FirstChild));
707: 705: 
708: 706:         assert_eq!(html, r#"<p class="foo bar baz"></p>"#);
709: 707:     }
710: 708: 
711: 709:     #[test]
712: 710:     fn adds_class_with_dynamic_and_function() {
713: 711:         let mut html = String::new();
714: 712:         let el: HtmlElement<_, _, _, Dom> = p(
715: 713:             (
716: 714:                 class("foo bar"),
717: 715:                 class(("baz", || true)),
718: 716:                 class(("boo", false)),
719: 717:             ),
720: 718:             (),
721: 719:         );
722: 720:         el.to_html(&mut html, &PositionState::new(Position::FirstChild));
723: 721: 
724: 722:         assert_eq!(html, r#"<p class="foo bar baz"></p>"#);
725: 723:     }
726: 724: } */
727: 725: ```
728: 726: ```
729: 727: ```
730: 728: ```
731: 729: ```
732: 730: ```
733: 731: ```
734: 732: ```
735: ```
```
