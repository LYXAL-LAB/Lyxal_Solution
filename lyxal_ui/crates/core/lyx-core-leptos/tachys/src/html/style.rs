### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\style.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\style.rs
18: 16: ```rust
19: 17: use super::attribute::{
20: 18:     maybe_next_attr_erasure_macros::next_attr_output_type, Attribute,
21: 19:     NextAttribute,
22: 20: };
23: 21: #[cfg(all(feature = "nightly", rustc_nightly))]
24: 22: use crate::view::static_types::Static;
25: 23: use crate::{
26: 24:     html::attribute::{
27: 25:         maybe_next_attr_erasure_macros::next_attr_combine, NamedAttributeKey,
28: 26:     },
29: 27:     renderer::{dom::CssStyleDeclaration, Rndr},
30: 28:     view::{Position, ToTemplate},
31: 29: };
32: 30: use std::{future::Future, sync::Arc};
33: 31: 
34: 32: /// Returns an [`Attribute`] that will add to an element's CSS styles.
35: 33: #[inline(always)]
36: 34: pub fn style<S>(style: S) -> Style<S>
37: 35: where
38: 36:     S: IntoStyle,
39: 37: {
40: 38:     Style { style }
41: 39: }
42: 40: 
43: 41: /// An [`Attribute`] that will add to an element's CSS styles.
44: 42: #[derive(Debug)]
45: 43: pub struct Style<S> {
46: 44:     style: S,
47: 45: }
48: 46: 
49: 47: impl<S> Clone for Style<S>
50: 48: where
51: 49:     S: Clone,
52: 50: {
53: 51:     fn clone(&self) -> Self {
54: 52:         Self {
55: 53:             style: self.style.clone(),
56: 54:         }
57: 55:     }
58: 56: }
59: 57: 
60: 58: impl<S> Attribute for Style<S>
61: 59: where
62: 60:     S: IntoStyle,
63: 61: {
64: 62:     const MIN_LENGTH: usize = 0;
65: 63: 
66: 64:     type AsyncOutput = Style<S::AsyncOutput>;
67: 65:     type State = S::State;
68: 66:     type Cloneable = Style<S::Cloneable>;
69: 67:     type CloneableOwned = Style<S::CloneableOwned>;
70: 68: 
71: 69:     // TODO
72: 70:     #[inline(always)]
73: 71:     fn html_len(&self) -> usize {
74: 72:         0
75: 73:     }
76: 74: 
77: 75:     fn to_html(
78: 76:         self,
79: 77:         _buf: &mut String,
80: 78:         _style: &mut String,
81: 79:         style: &mut String,
82: 80:         _inner_html: &mut String,
83: 81:     ) {
84: 82:         self.style.to_html(style);
85: 83:     }
86: 84: 
87: 85:     fn hydrate<const FROM_SERVER: bool>(
88: 86:         self,
89: 87:         el: &crate::renderer::types::Element,
90: 88:     ) -> Self::State {
91: 89:         self.style.hydrate::<FROM_SERVER>(el)
92: 90:     }
93: 91: 
94: 92:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
95: 93:         self.style.build(el)
96: 94:     }
97: 95: 
98: 96:     fn rebuild(self, state: &mut Self::State) {
99: 97:         self.style.rebuild(state)
100: 98:     }
101: 99: 
102: 100:     fn into_cloneable(self) -> Self::Cloneable {
103: 101:         Style {
104: 102:             style: self.style.into_cloneable(),
105: 103:         }
106: 104:     }
107: 105: 
108: 106:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
109: 107:         Style {
110: 108:             style: self.style.into_cloneable_owned(),
111: 109:         }
112: 110:     }
113: 111: 
114: 112:     fn dry_resolve(&mut self) {
115: 113:         self.style.dry_resolve();
116: 114:     }
117: 115: 
118: 116:     async fn resolve(self) -> Self::AsyncOutput {
119: 117:         Style {
120: 118:             style: self.style.resolve().await,
121: 119:         }
122: 120:     }
123: 121: 
124: 122:     fn keys(&self) -> Vec<NamedAttributeKey> {
125: 123:         vec![NamedAttributeKey::Attribute("style".into())]
126: 124:     }
127: 125: }
128: 126: 
129: 127: impl<S> NextAttribute for Style<S>
130: 128: where
131: 129:     S: IntoStyle,
132: 130: {
133: 131:     next_attr_output_type!(Self, NewAttr);
134: 132: 
135: 133:     fn add_any_attr<NewAttr: Attribute>(
136: 134:         self,
137: 135:         new_attr: NewAttr,
138: 136:     ) -> Self::Output<NewAttr> {
139: 137:         next_attr_combine!(self, new_attr)
140: 138:     }
141: 139: }
142: 140: 
143: 141: impl<S> ToTemplate for Style<S>
144: 142: where
145: 143:     S: IntoStyle,
146: 144: {
147: 145:     fn to_template(
148: 146:         _buf: &mut String,
149: 147:         _style: &mut String,
150: 148:         _class: &mut String,
151: 149:         _inner_html: &mut String,
152: 150:         _position: &mut Position,
153: 151:     ) {
154: 152:         // TODO: should there be some templating for static styles?
155: 153:     }
156: 154: }
157: 155: 
158: 156: /// Any type that can be added to the `style` attribute or set as a style in
159: 157: /// the [`CssStyleDeclaration`](web_sys::CssStyleDeclaration).
160: 158: ///
161: 159: /// This could be a plain string, or a property name-value pair.
162: 160: pub trait IntoStyle: Send {
163: 161:     /// The type after all async data have resolved.
164: 162:     type AsyncOutput: IntoStyle;
165: 163:     /// The view state retained between building and rebuilding.
166: 164:     type State;
167: 165:     /// An equivalent value that can be cloned.
168: 166:     type Cloneable: IntoStyle + Clone;
169: 167:     /// An equivalent value that can be cloned and is `'static`.
170: 168:     type CloneableOwned: IntoStyle + Clone + 'static;
171: 169: 
172: 170:     /// Renders the style to HTML.
173: 171:     fn to_html(self, style: &mut String);
174: 172: 
175: 173:     /// Adds interactivity as necessary, given DOM nodes that were created from HTML that has
176: 174:     /// either been rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, or cloned for a `<template>`.
177: 175:     fn hydrate<const FROM_SERVER: bool>(
178: 176:         self,
179: 177:         el: &crate::renderer::types::Element,
180: 178:     ) -> Self::State;
181: 179: 
182: 180:     /// Adds this style to the element during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering.
183: 181:     fn build(self, el: &crate::renderer::types::Element) -> Self::State;
184: 182: 
185: 183:     /// Updates the value.
186: 184:     fn rebuild(self, state: &mut Self::State);
187: 185: 
188: 186:     /// Converts this to a cloneable type.
189: 187:     fn into_cloneable(self) -> Self::Cloneable;
190: 188: 
191: 189:     /// Converts this to a cloneable, owned type.
192: 190:     fn into_cloneable_owned(self) -> Self::CloneableOwned;
193: 191: 
194: 192:     /// “Runs” the attribute without other side effects. For primitive types, this is a no-op. For
195: 193:     /// reactive types, this can be used to gather data about reactivity or about asynchronous data
196: 194:     /// that needs to be loaded.
197: 195:     fn dry_resolve(&mut self);
198: 196: 
199: 197:     /// “Resolves” this into a type that is not waiting for any asynchronous data.
200: 198:     fn resolve(self) -> impl Future<Output = Self::AsyncOutput> + Send;
201: 199: 
202: 200:     /// Reset the styling to the state before this style was added.
203: 201:     fn reset(state: &mut Self::State);
204: 202: }
205: 203: 
206: 204: impl<T: IntoStyle> IntoStyle for Option<T> {
207: 205:     type AsyncOutput = Option<T::AsyncOutput>;
208: 206:     type State = (crate::renderer::types::Element, Option<T::State>);
209: 207:     type Cloneable = Option<T::Cloneable>;
210: 208:     type CloneableOwned = Option<T::CloneableOwned>;
211: 209: 
212: 210:     fn to_html(self, style: &mut String) {
213: 211:         if let Some(t) = self {
214: 212:             t.to_html(style);
215: 213:         }
216: 214:     }
217: 215: 
218: 216:     fn hydrate<const FROM_SERVER: bool>(
219: 217:         self,
220: 218:         el: &crate::renderer::types::Element,
221: 219:     ) -> Self::State {
222: 220:         if let Some(t) = self {
223: 221:             (el.clone(), Some(t.hydrate::<FROM_SERVER>(el)))
224: 222:         } else {
225: 223:             (el.clone(), None)
226: 224:         }
227: 225:     }
228: 226: 
229: 227:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
230: 228:         if let Some(t) = self {
231: 229:             (el.clone(), Some(t.build(el)))
232: 230:         } else {
233: 231:             (el.clone(), None)
234: 232:         }
235: 233:     }
236: 234: 
237: 235:     fn rebuild(self, state: &mut Self::State) {
238: 236:         let el = &state.0;
239: 237:         let prev_state = &mut state.1;
240: 238:         let maybe_next_t_state = match (prev_state.take(), self) {
241: 239:             (Some(mut prev_t_state), None) => {
242: 240:                 T::reset(&mut prev_t_state);
243: 241:                 Some(None)
244: 242:             }
245: 243:             (None, Some(t)) => Some(Some(t.build(el))),
246: 244:             (Some(mut prev_t_state), Some(t)) => {
247: 245:                 t.rebuild(&mut prev_t_state);
248: 246:                 Some(Some(prev_t_state))
249: 247:             }
250: 248:             (None, None) => Some(None),
251: 249:         };
252: 250:         if let Some(next_t_state) = maybe_next_t_state {
253: 251:             state.1 = next_t_state;
254: 252:         }
255: 253:     }
256: 254: 
257: 255:     fn into_cloneable(self) -> Self::Cloneable {
258: 256:         self.map(|t| t.into_cloneable())
259: 257:     }
260: 258: 
261: 259:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
262: 260:         self.map(|t| t.into_cloneable_owned())
263: 261:     }
264: 262: 
265: 263:     fn dry_resolve(&mut self) {
266: 264:         if let Some(t) = self {
267: 265:             t.dry_resolve();
268: 266:         }
269: 267:     }
270: 268: 
271: 269:     async fn resolve(self) -> Self::AsyncOutput {
272: 270:         if let Some(t) = self {
273: 271:             Some(t.resolve().await)
274: 272:         } else {
275: 273:             None
276: 274:         }
277: 275:     }
278: 276: 
279: 277:     fn reset(state: &mut Self::State) {
280: 278:         if let Some(prev_t_state) = &mut state.1 {
281: 279:             T::reset(prev_t_state);
282: 280:         }
283: 281:     }
284: 282: }
285: 283: 
286: 284: impl<'a> IntoStyle for &'a str {
287: 285:     type AsyncOutput = Self;
288: 286:     type State = (crate::renderer::types::Element, &'a str);
289: 287:     type Cloneable = Self;
290: 288:     type CloneableOwned = Arc<str>;
291: 289: 
292: 290:     fn to_html(self, style: &mut String) {
293: 291:         style.push_str(self);
294: 292:         style.push(';');
295: 293:     }
296: 294: 
297: 295:     fn hydrate<const FROM_SERVER: bool>(
298: 296:         self,
299: 297:         el: &crate::renderer::types::Element,
300: 298:     ) -> Self::State {
301: 299:         (el.clone(), self)
302: 300:     }
303: 301: 
304: 302:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
305: 303:         Rndr::set_attribute(el, "style", self);
306: 304:         (el.clone(), self)
307: 305:     }
308: 306: 
309: 307:     fn rebuild(self, state: &mut Self::State) {
310: 308:         let (el, prev) = state;
311: 309:         if self != *prev {
312: 310:             Rndr::set_attribute(el, "style", self);
313: 311:         }
314: 312:         *prev = self;
315: 313:     }
316: 314: 
317: 315:     fn into_cloneable(self) -> Self::Cloneable {
318: 316:         self
319: 317:     }
320: 318: 
321: 319:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
322: 320:         self.into()
323: 321:     }
324: 322: 
325: 323:     fn dry_resolve(&mut self) {}
326: 324: 
327: 325:     async fn resolve(self) -> Self::AsyncOutput {
328: 326:         self
329: 327:     }
330: 328: 
331: 329:     fn reset(state: &mut Self::State) {
332: 330:         let (el, _prev) = state;
333: 331:         Rndr::remove_attribute(el, "style");
334: 332:     }
335: 333: }
336: 334: 
337: 335: impl IntoStyle for Arc<str> {
338: 336:     type AsyncOutput = Self;
339: 337:     type State = (crate::renderer::types::Element, Arc<str>);
340: 338:     type Cloneable = Self;
341: 339:     type CloneableOwned = Self;
342: 340: 
343: 341:     fn to_html(self, style: &mut String) {
344: 342:         style.push_str(&self);
345: 343:         style.push(';');
346: 344:     }
347: 345: 
348: 346:     fn hydrate<const FROM_SERVER: bool>(
349: 347:         self,
350: 348:         el: &crate::renderer::types::Element,
351: 349:     ) -> Self::State {
352: 350:         (el.clone(), self)
353: 351:     }
354: 352: 
355: 353:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
356: 354:         Rndr::set_attribute(el, "style", &self);
357: 355:         (el.clone(), self)
358: 356:     }
359: 357: 
360: 358:     fn rebuild(self, state: &mut Self::State) {
361: 359:         let (el, prev) = state;
362: 360:         if self != *prev {
363: 361:             Rndr::set_attribute(el, "style", &self);
364: 362:         }
365: 363:         *prev = self;
366: 364:     }
367: 365: 
368: 366:     fn into_cloneable(self) -> Self::Cloneable {
369: 367:         self
370: 368:     }
371: 369: 
372: 370:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
373: 371:         self
374: 372:     }
375: 373: 
376: 374:     fn dry_resolve(&mut self) {}
377: 375: 
378: 376:     async fn resolve(self) -> Self::AsyncOutput {
379: 377:         self
380: 378:     }
381: 379: 
382: 380:     fn reset(state: &mut Self::State) {
383: 381:         let (el, _prev) = state;
384: 382:         Rndr::remove_attribute(el, "style");
385: 383:     }
386: 384: }
387: 385: 
388: 386: impl IntoStyle for String {
389: 387:     type AsyncOutput = Self;
390: 388:     type State = (crate::renderer::types::Element, String);
391: 389:     type Cloneable = Arc<str>;
392: 390:     type CloneableOwned = Arc<str>;
393: 391: 
394: 392:     fn to_html(self, style: &mut String) {
395: 393:         style.push_str(&self);
396: 394:         style.push(';');
397: 395:     }
398: 396: 
399: 397:     fn hydrate<const FROM_SERVER: bool>(
400: 398:         self,
401: 399:         el: &crate::renderer::types::Element,
402: 400:     ) -> Self::State {
403: 401:         (el.clone(), self)
404: 402:     }
405: 403: 
406: 404:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
407: 405:         Rndr::set_attribute(el, "style", &self);
408: 406:         (el.clone(), self)
409: 407:     }
410: 408: 
411: 409:     fn rebuild(self, state: &mut Self::State) {
412: 410:         let (el, prev) = state;
413: 411:         if self != *prev {
414: 412:             Rndr::set_attribute(el, "style", &self);
415: 413:         }
416: 414:         *prev = self;
417: 415:     }
418: 416: 
419: 417:     fn into_cloneable(self) -> Self::Cloneable {
420: 418:         self.into()
421: 419:     }
422: 420: 
423: 421:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
424: 422:         self.into()
425: 423:     }
426: 424: 
427: 425:     fn dry_resolve(&mut self) {}
428: 426: 
429: 427:     async fn resolve(self) -> Self::AsyncOutput {
430: 428:         self
431: 429:     }
432: 430: 
433: 431:     fn reset(state: &mut Self::State) {
434: 432:         let (el, _prev) = state;
435: 433:         Rndr::remove_attribute(el, "style");
436: 434:     }
437: 435: }
438: 436: 
439: 437: /// Any type that can be used to set an individual style in the
440: 438: /// [`CssStyleDeclaration`](web_sys::CssStyleDeclaration).
441: 439: ///
442: 440: /// This is the value in a `(name, value)` tuple that implements [`IntoStyle`].
443: 441: pub trait IntoStyleValue: Send {
444: 442:     /// The type after all async data have resolved.
445: 443:     type AsyncOutput: IntoStyleValue;
446: 444:     /// The view state retained between building and rebuilding.
447: 445:     type State;
448: 446:     /// An equivalent value that can be cloned.
449: 447:     type Cloneable: Clone + IntoStyleValue;
450: 448:     /// An equivalent value that can be cloned and is `'static`.
451: 449:     type CloneableOwned: Clone + IntoStyleValue + 'static;
452: 450: 
453: 451:     /// Renders the style to HTML.
454: 452:     fn to_html(self, name: &str, style: &mut String);
455: 453: 
456: 454:     /// Adds this style to the element during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering.
457: 455:     fn build(self, style: &CssStyleDeclaration, name: &str) -> Self::State;
458: 456: 
459: 457:     /// Updates the value.
460: 458:     fn rebuild(
461: 459:         self,
462: 460:         style: &CssStyleDeclaration,
463: 461:         name: &str,
464: 462:         state: &mut Self::State,
465: 463:     );
466: 464: 
467: 465:     /// Adds interactivity as necessary, given DOM nodes that were created from HTML that has
468: 466:     /// either been rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, or cloned for a `<template>`.
469: 467:     fn hydrate(self, style: &CssStyleDeclaration, name: &str) -> Self::State;
470: 468: 
471: 469:     /// Converts this to a cloneable type.
472: 470:     fn into_cloneable(self) -> Self::Cloneable;
473: 471: 
474: 472:     /// Converts this to a cloneable, owned type.
475: 473:     fn into_cloneable_owned(self) -> Self::CloneableOwned;
476: 474: 
477: 475:     /// “Runs” the attribute without other side effects. For primitive types, this is a no-op. For
478: 476:     /// reactive types, this can be used to gather data about reactivity or about asynchronous data
479: 477:     /// that needs to be loaded.
480: 478:     fn dry_resolve(&mut self);
481: 479: 
482: 480:     /// “Resolves” this into a type that is not waiting for any asynchronous data.
483: 481:     fn resolve(self) -> impl Future<Output = Self::AsyncOutput> + Send;
484: 482: }
485: 483: 
486: 484: impl<K, V> IntoStyle for (K, V)
487: 485: where
488: 486:     K: AsRef<str> + Clone + Send + 'static,
489: 487:     V: IntoStyleValue,
490: 488: {
491: 489:     type AsyncOutput = (K, V::AsyncOutput);
492: 490:     type State = (crate::renderer::types::CssStyleDeclaration, K, V::State);
493: 491:     type Cloneable = (K, V::Cloneable);
494: 492:     type CloneableOwned = (K, V::CloneableOwned);
495: 493: 
496: 494:     fn to_html(self, style: &mut String) {
497: 495:         let (name, value) = self;
498: 496:         value.to_html(name.as_ref(), style);
499: 497:     }
500: 498: 
501: 499:     fn hydrate<const FROM_SERVER: bool>(
502: 500:         self,
503: 501:         el: &crate::renderer::types::Element,
504: 502:     ) -> Self::State {
505: 503:         let style = Rndr::style(el);
506: 504:         let state = self.1.hydrate(&style, self.0.as_ref());
507: 505:         (style, self.0, state)
508: 506:     }
509: 507: 
510: 508:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
511: 509:         let (name, value) = self;
512: 510:         let style = Rndr::style(el);
513: 511:         let state = value.build(&style, name.as_ref());
514: 512:         (style, name, state)
515: 513:     }
516: 514: 
517: 515:     fn rebuild(self, state: &mut Self::State) {
518: 516:         let (name, value) = self;
519: 517:         // state.1 was the previous name, theoretically the css name could be changed:
520: 518:         if name.as_ref() != state.1.as_ref() {
521: 519:             <Self as IntoStyle>::reset(state);
522: 520:             state.2 = value.build(&state.0, name.as_ref());
523: 521:         } else {
524: 522:             value.rebuild(&state.0, name.as_ref(), &mut state.2);
525: 523:         }
526: 524:     }
527: 525: 
528: 526:     fn into_cloneable(self) -> Self::Cloneable {
529: 527:         (self.0, self.1.into_cloneable())
530: 528:     }
531: 529: 
532: 530:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
533: 531:         (self.0, self.1.into_cloneable_owned())
534: 532:     }
535: 533: 
536: 534:     fn dry_resolve(&mut self) {
537: 535:         self.1.dry_resolve();
538: 536:     }
539: 537: 
540: 538:     async fn resolve(self) -> Self::AsyncOutput {
541: 539:         (self.0, self.1.resolve().await)
542: 540:     }
543: 541: 
544: 542:     /// Reset the renderer to the state before this style was added.
545: 543:     fn reset(state: &mut Self::State) {
546: 544:         let (style, name, _value) = state;
547: 545:         Rndr::remove_css_property(style, name.as_ref());
548: 546:     }
549: 547: }
550: 548: 
551: 549: macro_rules! impl_style_value {
552: 550:     ($ty:ty) => {
553: 551:         impl IntoStyleValue for $ty {
554: 552:             type AsyncOutput = Self;
555: 553:             type State = Self;
556: 554:             type Cloneable = Self;
557: 555:             type CloneableOwned = Self;
558: 556: 
559: 557:             fn to_html(self, name: &str, style: &mut String) {
560: 558:                 style.push_str(name);
561: 559:                 style.push(':');
562: 560:                 style.push_str(&self);
563: 561:                 style.push(';');
564: 562:             }
565: 563: 
566: 564:             fn build(
567: 565:                 self,
568: 566:                 style: &CssStyleDeclaration,
569: 567:                 name: &str,
570: 568:             ) -> Self::State {
571: 569:                 Rndr::set_css_property(style, name, &self);
572: 570:                 self
573: 571:             }
574: 572: 
575: 573:             fn rebuild(
576: 574:                 self,
577: 575:                 style: &CssStyleDeclaration,
578: 576:                 name: &str,
579: 577:                 state: &mut Self::State,
580: 578:             ) {
581: 579:                 if &self != &*state {
582: 580:                     Rndr::set_css_property(style, name, &self);
583: 581:                 }
584: 582:                 *state = self;
585: 583:             }
586: 584: 
587: 585:             fn hydrate(
588: 586:                 self,
589: 587:                 _style: &CssStyleDeclaration,
590: 588:                 _name: &str,
591: 589:             ) -> Self::State {
592: 590:                 self
593: 591:             }
594: 592: 
595: 593:             fn into_cloneable(self) -> Self::Cloneable {
596: 594:                 self
597: 595:             }
598: 596: 
599: 597:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
600: 598:                 self
601: 599:             }
602: 600: 
603: 601:             fn dry_resolve(&mut self) {}
604: 602: 
605: 603:             async fn resolve(self) -> Self::AsyncOutput {
606: 604:                 self
607: 605:             }
608: 606:         }
609: 607: 
610: 608:         impl IntoStyleValue for Option<$ty> {
611: 609:             type AsyncOutput = Self;
612: 610:             type State = Self;
613: 611:             type Cloneable = Self;
614: 612:             type CloneableOwned = Self;
615: 613: 
616: 614:             fn to_html(self, name: &str, style: &mut String) {
617: 615:                 if let Some(value) = self {
618: 616:                     style.push_str(name);
619: 617:                     style.push(':');
620: 618:                     style.push_str(&value);
621: 619:                     style.push(';');
622: 620:                 }
623: 621:             }
624: 622: 
625: 623:             fn build(
626: 624:                 self,
627: 625:                 style: &CssStyleDeclaration,
628: 626:                 name: &str,
629: 627:             ) -> Self::State {
630: 628:                 if let Some(value) = &self {
631: 629:                     Rndr::set_css_property(style, name, &value);
632: 630:                 }
633: 631:                 self
634: 632:             }
635: 633: 
636: 634:             fn rebuild(
637: 635:                 self,
638: 636:                 style: &CssStyleDeclaration,
639: 637:                 name: &str,
640: 638:                 state: &mut Self::State,
641: 639:             ) {
642: 640:                 match (&state, &self) {
643: 641:                     (None, None) => {}
644: 642:                     (Some(_), None) => Rndr::remove_css_property(style, name),
645: 643:                     (None, Some(value)) => {
646: 644:                         Rndr::set_css_property(style, name, &value)
647: 645:                     }
648: 646:                     (Some(old), Some(new)) => {
649: 647:                         if new != &*old {
650: 648:                             Rndr::set_css_property(style, name, &new);
651: 649:                         }
652: 650:                     }
653: 651:                 }
654: 652:                 *state = self;
655: 653:             }
656: 654: 
657: 655:             fn hydrate(
658: 656:                 self,
659: 657:                 _style: &CssStyleDeclaration,
660: 658:                 _name: &str,
661: 659:             ) -> Self::State {
662: 660:                 self
663: 661:             }
664: 662: 
665: 663:             fn into_cloneable(self) -> Self::Cloneable {
666: 664:                 self
667: 665:             }
668: 666: 
669: 667:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
670: 668:                 self
671: 669:             }
672: 670: 
673: 671:             fn dry_resolve(&mut self) {}
674: 672: 
675: 673:             async fn resolve(self) -> Self::AsyncOutput {
676: 674:                 self
677: 675:             }
678: 676:         }
679: 677:     };
680: 678: }
681: 679: 
682: 680: impl_style_value!(&'static str);
683: 681: impl_style_value!(Arc<str>);
684: 682: impl_style_value!(String);
685: 683: #[cfg(feature = "oco")]
686: 684: impl_style_value!(lyx-core-oco::Oco<'static, str>);
687: 685: 
688: 686: #[cfg(all(feature = "nightly", rustc_nightly))]
689: 687: impl<const V: &'static str> IntoStyleValue for Static<V> {
690: 688:     type AsyncOutput = Self;
691: 689:     type State = Self;
692: 690:     type Cloneable = Self;
693: 691:     type CloneableOwned = Self;
694: 692: 
695: 693:     fn to_html(self, name: &str, style: &mut String) {
696: 694:         style.push_str(name);
697: 695:         style.push(':');
698: 696:         style.push_str(V);
699: 697:         style.push(';');
700: 698:     }
701: 699: 
702: 700:     fn build(self, style: &CssStyleDeclaration, name: &str) -> Self::State {
703: 701:         Rndr::set_css_property(style, name, V);
704: 702:         self
705: 703:     }
706: 704: 
707: 705:     fn rebuild(
708: 706:         self,
709: 707:         _style: &CssStyleDeclaration,
710: 708:         _name: &str,
711: 709:         _state: &mut Self::State,
712: 710:     ) {
713: 711:     }
714: 712: 
715: 713:     fn hydrate(self, _style: &CssStyleDeclaration, _name: &str) -> Self::State {
716: 714:         self
717: 715:     }
718: 716: 
719: 717:     fn into_cloneable(self) -> Self::Cloneable {
720: 718:         self
721: 719:     }
722: 720: 
723: 721:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
724: 722:         self
725: 723:     }
726: 724: 
727: 725:     fn dry_resolve(&mut self) {}
728: 726: 
729: 727:     async fn resolve(self) -> Self::AsyncOutput {
730: 728:         self
731: 729:     }
732: 730: }
733: 731: 
734: 732: #[cfg(all(feature = "nightly", rustc_nightly))]
735: 733: impl<const V: &'static str> IntoStyleValue for Option<Static<V>> {
736: 734:     type AsyncOutput = Self;
737: 735:     type State = Self;
738: 736:     type Cloneable = Self;
739: 737:     type CloneableOwned = Self;
740: 738: 
741: 739:     fn to_html(self, name: &str, style: &mut String) {
742: 740:         if self.is_some() {
743: 741:             style.push_str(name);
744: 742:             style.push(':');
745: 743:             style.push_str(V);
746: 744:             style.push(';');
747: 745:         }
748: 746:     }
749: 747: 
750: 748:     fn build(self, style: &CssStyleDeclaration, name: &str) -> Self::State {
751: 749:         if self.is_some() {
752: 750:             Rndr::set_css_property(style, name, V);
753: 751:         }
754: 752:         self
755: 753:     }
756: 754: 
757: 755:     fn rebuild(
758: 756:         self,
759: 757:         style: &CssStyleDeclaration,
760: 758:         name: &str,
761: 759:         state: &mut Self::State,
762: 760:     ) {
763: 761:         match (&state, &self) {
764: 762:             (None, None) => {}
765: 763:             (Some(_), None) => Rndr::remove_css_property(style, name),
766: 764:             (None, Some(_)) => Rndr::set_css_property(style, name, V),
767: 765:             (Some(_), Some(_)) => {}
768: 766:         }
769: 767:         *state = self;
770: 768:     }
771: 769: 
772: 770:     fn hydrate(self, _style: &CssStyleDeclaration, _name: &str) -> Self::State {
773: 771:         self
774: 772:     }
775: 773: 
776: 774:     fn into_cloneable(self) -> Self::Cloneable {
777: 775:         self
778: 776:     }
779: 777: 
780: 778:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
781: 779:         self
782: 780:     }
783: 781: 
784: 782:     fn dry_resolve(&mut self) {}
785: 783: 
786: 784:     async fn resolve(self) -> Self::AsyncOutput {
787: 785:         self
788: 786:     }
789: 787: }
790: 788: 
791: 789: #[cfg(all(feature = "nightly", rustc_nightly))]
792: 790: impl<const V: &'static str> IntoStyle for crate::view::static_types::Static<V> {
793: 791:     type AsyncOutput = Self;
794: 792:     type State = ();
795: 793:     type Cloneable = Self;
796: 794:     type CloneableOwned = Self;
797: 795: 
798: 796:     fn to_html(self, style: &mut String) {
799: 797:         style.push_str(V);
800: 798:         style.push(';');
801: 799:     }
802: 800: 
803: 801:     fn hydrate<const FROM_SERVER: bool>(
804: 802:         self,
805: 803:         _el: &crate::renderer::types::Element,
806: 804:     ) -> Self::State {
807: 805:     }
808: 806: 
809: 807:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
810: 808:         Rndr::set_attribute(el, "style", V);
811: 809:     }
812: 810: 
813: 811:     fn rebuild(self, _state: &mut Self::State) {}
814: 812: 
815: 813:     fn into_cloneable(self) -> Self::Cloneable {
816: 814:         self
817: 815:     }
818: 816: 
819: 817:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
820: 818:         self
821: 819:     }
822: 820: 
823: 821:     fn dry_resolve(&mut self) {}
824: 822: 
825: 823:     async fn resolve(self) -> Self::AsyncOutput {
826: 824:         self
827: 825:     }
828: 826: 
829: 827:     fn reset(_state: &mut Self::State) {}
830: 828: }
831: 829: 
832: 830: /*
833: 831: #[cfg(test)]
834: 832: mod tests {
835: 833:     use crate::{
836: 834:         html::{
837: 835:             element::{p, HtmlElement},
838: 836:             style::style,
839: 837:         },
840: 838:         renderer::dom::Dom,
841: 839:         view::{Position, PositionState, RenderHtml},
842: 840:     };
843: 841: 
844: 842:     #[test]
845: 843:     fn adds_simple_style() {
846: 844:         let mut html = String::new();
847: 845:         let el: HtmlElement<_, _, _, Dom> = p(style("display: block"), ());
848: 846:         el.to_html(&mut html, &PositionState::new(Position::FirstChild));
849: 847: 
850: 848:         assert_eq!(html, r#"<p style="display: block;"></p>"#);
851: 849:     }
852: 850: 
853: 851:     #[test]
854: 852:     fn mixes_plain_and_specific_styles() {
855: 853:         let mut html = String::new();
856: 854:         let el: HtmlElement<_, _, _, Dom> =
857: 855:             p((style("display: block"), style(("color", "blue"))), ());
858: 856:         el.to_html(&mut html, &PositionState::new(Position::FirstChild));
859: 857: 
860: 858:         assert_eq!(html, r#"<p style="display: block;color:blue;"></p>"#);
861: 859:     }
862: 860: 
863: 861:     #[test]
864: 862:     fn handles_dynamic_styles() {
865: 863:         let mut html = String::new();
866: 864:         let el: HtmlElement<_, _, _, Dom> = p(
867: 865:             (
868: 866:                 style("display: block"),
869: 867:                 style(("color", "blue")),
870: 868:                 style(("font-weight", || "bold".to_string())),
871: 869:             ),
872: 870:             (),
873: 871:         );
874: 872:         el.to_html(&mut html, &PositionState::new(Position::FirstChild));
875: 873: 
876: 874:         assert_eq!(
877: 875:             html,
878: 876:             r#"<p style="display: block;color:blue;font-weight:bold;"></p>"#
879: 877:         );
880: 878:     }
881: 879: }
882: 880:  */
883: 881: ```
884: 882: ```
885: 883: ```
886: 884: ```
887: 885: ```
888: 886: ```
889: 887: ```
890: 888: ```
891: ```
```
