### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\property.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\property.rs
18: 16: ```rust
19: 17: use super::attribute::{
20: 18:     maybe_next_attr_erasure_macros::next_attr_output_type, Attribute,
21: 19:     NextAttribute,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::{
25: 23:         maybe_next_attr_erasure_macros::next_attr_combine, NamedAttributeKey,
26: 24:     },
27: 25:     renderer::Rndr,
28: 26:     view::{Position, ToTemplate},
29: 27: };
30: 28: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
31: 29: use std::{borrow::Cow, sync::Arc};
32: 30: use wasm_bindgen::JsValue;
33: 31: 
34: 32: /// Creates an [`Attribute`] that will set a DOM property on an element.
35: 33: #[inline(always)]
36: 34: pub fn prop<K, P>(key: K, value: P) -> Property<K, P>
37: 35: where
38: 36:     K: AsRef<str>,
39: 37:     P: IntoProperty,
40: 38: {
41: 39:     Property {
42: 40:         key,
43: 41:         value: (!cfg!(feature = "ssr")).then(|| SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(value)),
44: 42:     }
45: 43: }
46: 44: 
47: 45: /// An [`Attribute`] that will set a DOM property on an element.
48: 46: #[derive(Debug)]
49: 47: pub struct Property<K, P> {
50: 48:     key: K,
51: 49:     // property values will only be accessed in the browser
52: 50:     value: Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<P>>,
53: 51: }
54: 52: 
55: 53: impl<K, P> Clone for Property<K, P>
56: 54: where
57: 55:     K: Clone,
58: 56:     P: Clone,
59: 57: {
60: 58:     fn clone(&self) -> Self {
61: 59:         Self {
62: 60:             key: self.key.clone(),
63: 61:             value: self.value.clone(),
64: 62:         }
65: 63:     }
66: 64: }
67: 65: 
68: 66: impl<K, P> Attribute for Property<K, P>
69: 67: where
70: 68:     K: AsRef<str> + Send,
71: 69:     P: IntoProperty,
72: 70: {
73: 71:     const MIN_LENGTH: usize = 0;
74: 72: 
75: 73:     type AsyncOutput = Self;
76: 74:     type State = P::State;
77: 75:     type Cloneable = Property<Arc<str>, P::Cloneable>;
78: 76:     type CloneableOwned = Property<Arc<str>, P::CloneableOwned>;
79: 77: 
80: 78:     #[inline(always)]
81: 79:     fn html_len(&self) -> usize {
82: 80:         0
83: 81:     }
84: 82: 
85: 83:     fn to_html(
86: 84:         self,
87: 85:         _buf: &mut String,
88: 86:         _class: &mut String,
89: 87:         _style: &mut String,
90: 88:         _inner_html: &mut String,
91: 89:     ) {
92: 90:     }
93: 91: 
94: 92:     fn hydrate<const FROM_SERVER: bool>(
95: 93:         self,
96: 94:         el: &crate::renderer::types::Element,
97: 95:     ) -> Self::State {
98: 96:         self.value
99: 97:             .expect("property removed early")
100: 98:             .take()
101: 99:             .hydrate::<FROM_SERVER>(el, self.key.as_ref())
102: 100:     }
103: 101: 
104: 102:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
105: 103:         self.value
106: 104:             .expect("property removed early")
107: 105:             .take()
108: 106:             .build(el, self.key.as_ref())
109: 107:     }
110: 108: 
111: 109:     fn rebuild(self, state: &mut Self::State) {
112: 110:         self.value
113: 111:             .expect("property removed early")
114: 112:             .take()
115: 113:             .rebuild(state, self.key.as_ref())
116: 114:     }
117: 115: 
118: 116:     fn into_cloneable(self) -> Self::Cloneable {
119: 117:         Property {
120: 118:             key: self.key.as_ref().into(),
121: 119:             value: self
122: 120:                 .value
123: 121:                 .map(|value| SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(value.take().into_cloneable())),
124: 122:         }
125: 123:     }
126: 124: 
127: 125:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
128: 126:         Property {
129: 127:             key: self.key.as_ref().into(),
130: 128:             value: self.value.map(|value| {
131: 129:                 SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(value.take().into_cloneable_owned())
132: 130:             }),
133: 131:         }
134: 132:     }
135: 133: 
136: 134:     fn dry_resolve(&mut self) {}
137: 135: 
138: 136:     async fn resolve(self) -> Self::AsyncOutput {
139: 137:         self
140: 138:     }
141: 139: 
142: 140:     fn keys(&self) -> Vec<NamedAttributeKey> {
143: 141:         vec![NamedAttributeKey::Property(
144: 142:             self.key.as_ref().to_string().into(),
145: 143:         )]
146: 144:     }
147: 145: }
148: 146: 
149: 147: impl<K, P> NextAttribute for Property<K, P>
150: 148: where
151: 149:     K: AsRef<str> + Send,
152: 150:     P: IntoProperty,
153: 151: {
154: 152:     next_attr_output_type!(Self, NewAttr);
155: 153: 
156: 154:     fn add_any_attr<NewAttr: Attribute>(
157: 155:         self,
158: 156:         new_attr: NewAttr,
159: 157:     ) -> Self::Output<NewAttr> {
160: 158:         next_attr_combine!(self, new_attr)
161: 159:     }
162: 160: }
163: 161: 
164: 162: impl<K, P> ToTemplate for Property<K, P>
165: 163: where
166: 164:     K: AsRef<str>,
167: 165:     P: IntoProperty,
168: 166: {
169: 167:     fn to_template(
170: 168:         _buf: &mut String,
171: 169:         _class: &mut String,
172: 170:         _style: &mut String,
173: 171:         _inner_html: &mut String,
174: 172:         _position: &mut Position,
175: 173:     ) {
176: 174:     }
177: 175: }
178: 176: 
179: 177: /// A possible value for a DOM property.
180: 178: pub trait IntoProperty {
181: 179:     /// The view state retained between building and rebuilding.
182: 180:     type State;
183: 181:     /// An equivalent value that can be cloned.
184: 182:     type Cloneable: IntoProperty + Clone;
185: 183:     /// An equivalent value that can be cloned and is `'static`.
186: 184:     type CloneableOwned: IntoProperty + Clone + 'static;
187: 185: 
188: 186:     /// Adds the property on an element created from HTML.
189: 187:     fn hydrate<const FROM_SERVER: bool>(
190: 188:         self,
191: 189:         el: &crate::renderer::types::Element,
192: 190:         key: &str,
193: 191:     ) -> Self::State;
194: 192: 
195: 193:     /// Adds the property during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering.
196: 194:     fn build(
197: 195:         self,
198: 196:         el: &crate::renderer::types::Element,
199: 197:         key: &str,
200: 198:     ) -> Self::State;
201: 199: 
202: 200:     /// Updates the property with a new value.
203: 201:     fn rebuild(self, state: &mut Self::State, key: &str);
204: 202: 
205: 203:     /// Converts this to a cloneable type.
206: 204:     fn into_cloneable(self) -> Self::Cloneable;
207: 205: 
208: 206:     /// Converts this to a cloneable, owned type.
209: 207:     fn into_cloneable_owned(self) -> Self::CloneableOwned;
210: 208: }
211: 209: 
212: 210: macro_rules! prop_type {
213: 211:     ($prop_type:ty) => {
214: 212:         impl IntoProperty for $prop_type {
215: 213:             type State = (crate::renderer::types::Element, JsValue);
216: 214:             type Cloneable = Self;
217: 215:             type CloneableOwned = Self;
218: 216: 
219: 217:             fn hydrate<const FROM_SERVER: bool>(
220: 218:                 self,
221: 219:                 el: &crate::renderer::types::Element,
222: 220:                 key: &str,
223: 221:             ) -> Self::State {
224: 222:                 let value = self.into();
225: 223:                 Rndr::set_property_or_value(el, key, &value);
226: 224:                 (el.clone(), value)
227: 225:             }
228: 226: 
229: 227:             fn build(
230: 228:                 self,
231: 229:                 el: &crate::renderer::types::Element,
232: 230:                 key: &str,
233: 231:             ) -> Self::State {
234: 232:                 let value = self.into();
235: 233:                 Rndr::set_property_or_value(el, key, &value);
236: 234:                 (el.clone(), value)
237: 235:             }
238: 236: 
239: 237:             fn rebuild(self, state: &mut Self::State, key: &str) {
240: 238:                 let (el, prev) = state;
241: 239:                 let value = self.into();
242: 240:                 Rndr::set_property_or_value(el, key, &value);
243: 241:                 *prev = value;
244: 242:             }
245: 243: 
246: 244:             fn into_cloneable(self) -> Self::Cloneable {
247: 245:                 self
248: 246:             }
249: 247: 
250: 248:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
251: 249:                 self
252: 250:             }
253: 251:         }
254: 252: 
255: 253:         impl IntoProperty for Option<$prop_type> {
256: 254:             type State = (crate::renderer::types::Element, JsValue);
257: 255:             type Cloneable = Self;
258: 256:             type CloneableOwned = Self;
259: 257: 
260: 258:             fn hydrate<const FROM_SERVER: bool>(
261: 259:                 self,
262: 260:                 el: &crate::renderer::types::Element,
263: 261:                 key: &str,
264: 262:             ) -> Self::State {
265: 263:                 let was_some = self.is_some();
266: 264:                 let value = self.into();
267: 265:                 if was_some {
268: 266:                     Rndr::set_property_or_value(el, key, &value);
269: 267:                 }
270: 268:                 (el.clone(), value)
271: 269:             }
272: 270: 
273: 271:             fn build(
274: 272:                 self,
275: 273:                 el: &crate::renderer::types::Element,
276: 274:                 key: &str,
277: 275:             ) -> Self::State {
278: 276:                 let was_some = self.is_some();
279: 277:                 let value = self.into();
280: 278:                 if was_some {
281: 279:                     Rndr::set_property_or_value(el, key, &value);
282: 280:                 }
283: 281:                 (el.clone(), value)
284: 282:             }
285: 283: 
286: 284:             fn rebuild(self, state: &mut Self::State, key: &str) {
287: 285:                 let (el, prev) = state;
288: 286:                 let value = self.into();
289: 287:                 Rndr::set_property_or_value(el, key, &value);
290: 288:                 *prev = value;
291: 289:             }
292: 290: 
293: 291:             fn into_cloneable(self) -> Self::Cloneable {
294: 292:                 self
295: 293:             }
296: 294: 
297: 295:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
298: 296:                 self
299: 297:             }
300: 298:         }
301: 299:     };
302: 300: }
303: 301: 
304: 302: macro_rules! prop_type_str {
305: 303:     ($prop_type:ty) => {
306: 304:         impl IntoProperty for $prop_type {
307: 305:             type State = (crate::renderer::types::Element, JsValue);
308: 306:             type Cloneable = Arc<str>;
309: 307:             type CloneableOwned = Arc<str>;
310: 308: 
311: 309:             fn hydrate<const FROM_SERVER: bool>(
312: 310:                 self,
313: 311:                 el: &crate::renderer::types::Element,
314: 312:                 key: &str,
315: 313:             ) -> Self::State {
316: 314:                 let value = JsValue::from(&*self);
317: 315:                 Rndr::set_property_or_value(el, key, &value);
318: 316:                 (el.clone(), value)
319: 317:             }
320: 318: 
321: 319:             fn build(
322: 320:                 self,
323: 321:                 el: &crate::renderer::types::Element,
324: 322:                 key: &str,
325: 323:             ) -> Self::State {
326: 324:                 let value = JsValue::from(&*self);
327: 325:                 Rndr::set_property_or_value(el, key, &value);
328: 326:                 (el.clone(), value)
329: 327:             }
330: 328: 
331: 329:             fn rebuild(self, state: &mut Self::State, key: &str) {
332: 330:                 let (el, prev) = state;
333: 331:                 let value = JsValue::from(&*self);
334: 332:                 Rndr::set_property_or_value(el, key, &value);
335: 333:                 *prev = value;
336: 334:             }
337: 335: 
338: 336:             fn into_cloneable(self) -> Self::Cloneable {
339: 337:                 let this: &str = &*self;
340: 338:                 this.into()
341: 339:             }
342: 340: 
343: 341:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
344: 342:                 let this: &str = &*self;
345: 343:                 this.into()
346: 344:             }
347: 345:         }
348: 346: 
349: 347:         impl IntoProperty for Option<$prop_type> {
350: 348:             type State = (crate::renderer::types::Element, JsValue);
351: 349:             type Cloneable = Option<Arc<str>>;
352: 350:             type CloneableOwned = Option<Arc<str>>;
353: 351: 
354: 352:             fn hydrate<const FROM_SERVER: bool>(
355: 353:                 self,
356: 354:                 el: &crate::renderer::types::Element,
357: 355:                 key: &str,
358: 356:             ) -> Self::State {
359: 357:                 let was_some = self.is_some();
360: 358:                 let value = JsValue::from(self.map(|n| JsValue::from_str(&n)));
361: 359:                 if was_some {
362: 360:                     Rndr::set_property_or_value(el, key, &value);
363: 361:                 }
364: 362:                 (el.clone(), value)
365: 363:             }
366: 364: 
367: 365:             fn build(
368: 366:                 self,
369: 367:                 el: &crate::renderer::types::Element,
370: 368:                 key: &str,
371: 369:             ) -> Self::State {
372: 370:                 let was_some = self.is_some();
373: 371:                 let value = JsValue::from(self.map(|n| JsValue::from_str(&n)));
374: 372:                 if was_some {
375: 373:                     Rndr::set_property_or_value(el, key, &value);
376: 374:                 }
377: 375:                 (el.clone(), value)
378: 376:             }
379: 377: 
380: 378:             fn rebuild(self, state: &mut Self::State, key: &str) {
381: 379:                 let (el, prev) = state;
382: 380:                 let value = JsValue::from(self.map(|n| JsValue::from_str(&n)));
383: 381:                 Rndr::set_property_or_value(el, key, &value);
384: 382:                 *prev = value;
385: 383:             }
386: 384: 
387: 385:             fn into_cloneable(self) -> Self::Cloneable {
388: 386:                 self.map(|n| {
389: 387:                     let this: &str = &*n;
390: 388:                     this.into()
391: 389:                 })
392: 390:             }
393: 391: 
394: 392:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
395: 393:                 self.map(|n| {
396: 394:                     let this: &str = &*n;
397: 395:                     this.into()
398: 396:                 })
399: 397:             }
400: 398:         }
401: 399:     };
402: 400: }
403: 401: 
404: 402: impl IntoProperty for Arc<str> {
405: 403:     type State = (crate::renderer::types::Element, JsValue);
406: 404:     type Cloneable = Self;
407: 405:     type CloneableOwned = Self;
408: 406: 
409: 407:     fn hydrate<const FROM_SERVER: bool>(
410: 408:         self,
411: 409:         el: &crate::renderer::types::Element,
412: 410:         key: &str,
413: 411:     ) -> Self::State {
414: 412:         let value = JsValue::from_str(self.as_ref());
415: 413:         Rndr::set_property_or_value(el, key, &value);
416: 414:         (el.clone(), value)
417: 415:     }
418: 416: 
419: 417:     fn build(
420: 418:         self,
421: 419:         el: &crate::renderer::types::Element,
422: 420:         key: &str,
423: 421:     ) -> Self::State {
424: 422:         let value = JsValue::from_str(self.as_ref());
425: 423:         Rndr::set_property_or_value(el, key, &value);
426: 424:         (el.clone(), value)
427: 425:     }
428: 426: 
429: 427:     fn rebuild(self, state: &mut Self::State, key: &str) {
430: 428:         let (el, prev) = state;
431: 429:         let value = JsValue::from_str(self.as_ref());
432: 430:         Rndr::set_property_or_value(el, key, &value);
433: 431:         *prev = value;
434: 432:     }
435: 433: 
436: 434:     fn into_cloneable(self) -> Self::Cloneable {
437: 435:         self
438: 436:     }
439: 437: 
440: 438:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
441: 439:         self
442: 440:     }
443: 441: }
444: 442: 
445: 443: impl IntoProperty for Option<Arc<str>> {
446: 444:     type State = (crate::renderer::types::Element, JsValue);
447: 445:     type Cloneable = Self;
448: 446:     type CloneableOwned = Self;
449: 447: 
450: 448:     fn hydrate<const FROM_SERVER: bool>(
451: 449:         self,
452: 450:         el: &crate::renderer::types::Element,
453: 451:         key: &str,
454: 452:     ) -> Self::State {
455: 453:         let was_some = self.is_some();
456: 454:         let value = JsValue::from(self.map(|n| JsValue::from_str(&n)));
457: 455:         if was_some {
458: 456:             Rndr::set_property_or_value(el, key, &value);
459: 457:         }
460: 458:         (el.clone(), value)
461: 459:     }
462: 460: 
463: 461:     fn build(
464: 462:         self,
465: 463:         el: &crate::renderer::types::Element,
466: 464:         key: &str,
467: 465:     ) -> Self::State {
468: 466:         let was_some = self.is_some();
469: 467:         let value = JsValue::from(self.map(|n| JsValue::from_str(&n)));
470: 468:         if was_some {
471: 469:             Rndr::set_property_or_value(el, key, &value);
472: 470:         }
473: 471:         (el.clone(), value)
474: 472:     }
475: 473: 
476: 474:     fn rebuild(self, state: &mut Self::State, key: &str) {
477: 475:         let (el, prev) = state;
478: 476:         let value = JsValue::from(self.map(|n| JsValue::from_str(&n)));
479: 477:         Rndr::set_property_or_value(el, key, &value);
480: 478:         *prev = value;
481: 479:     }
482: 480: 
483: 481:     fn into_cloneable(self) -> Self::Cloneable {
484: 482:         self
485: 483:     }
486: 484: 
487: 485:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
488: 486:         self
489: 487:     }
490: 488: }
491: 489: 
492: 490: prop_type!(JsValue);
493: 491: prop_type!(usize);
494: 492: prop_type!(u8);
495: 493: prop_type!(u16);
496: 494: prop_type!(u32);
497: 495: prop_type!(u64);
498: 496: prop_type!(u128);
499: 497: prop_type!(isize);
500: 498: prop_type!(i8);
501: 499: prop_type!(i16);
502: 500: prop_type!(i32);
503: 501: prop_type!(i64);
504: 502: prop_type!(i128);
505: 503: prop_type!(f32);
506: 504: prop_type!(f64);
507: 505: prop_type!(bool);
508: 506: 
509: 507: prop_type_str!(String);
510: 508: prop_type_str!(&String);
511: 509: prop_type_str!(&str);
512: 510: prop_type_str!(Cow<'_, str>);
513: 511: ```
514: 512: ```
515: 513: ```
516: 514: ```
517: 515: ```
518: 516: ```
519: 517: ```
520: 518: ```
521: ```
```
