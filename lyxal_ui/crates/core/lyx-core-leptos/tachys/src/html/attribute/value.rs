### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\value.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\value.rs
18: 16: ```rust
19: 17: use crate::renderer::Rndr;
20: 18: use std::{
21: 19:     borrow::Cow,
22: 20:     future::Future,
23: 21:     net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr, SocketAddrV4, SocketAddrV6},
24: 22:     num::{
25: 23:         NonZeroI128, NonZeroI16, NonZeroI32, NonZeroI64, NonZeroI8,
26: 24:         NonZeroIsize, NonZeroU128, NonZeroU16, NonZeroU32, NonZeroU64,
27: 25:         NonZeroU8, NonZeroUsize,
28: 26:     },
29: 27:     sync::Arc,
30: 28: };
31: 29: 
32: 30: /// Declares that this type can be converted into some other type, which is a valid attribute value.
33: 31: pub trait IntoAttributeValue {
34: 32:     /// The attribute value into which this type can be converted.
35: 33:     type Output;
36: 34: 
37: 35:     /// Consumes this value, transforming it into an attribute value.
38: 36:     fn into_attribute_value(self) -> Self::Output;
39: 37: }
40: 38: 
41: 39: impl<T> IntoAttributeValue for T
42: 40: where
43: 41:     T: AttributeValue,
44: 42: {
45: 43:     type Output = Self;
46: 44: 
47: 45:     fn into_attribute_value(self) -> Self::Output {
48: 46:         self
49: 47:     }
50: 48: }
51: 49: 
52: 50: /// A possible value for an HTML attribute.
53: 51: pub trait AttributeValue: Send {
54: 52:     /// The state that should be retained between building and rebuilding.
55: 53:     type State;
56: 54: 
57: 55:     /// The type once all async data have loaded.
58: 56:     type AsyncOutput: AttributeValue;
59: 57: 
60: 58:     /// A version of the value that can be cloned. This can be the same type, or a
61: 59:     /// reference-counted type. Generally speaking, this does *not* need to refer to the same data,
62: 60:     /// but should behave in the same way. So for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, making an event handler cloneable should
63: 61:     /// probably make it reference-counted (so that a `FnMut()` continues mutating the same
64: 62:     /// closure), but making a `String` cloneable does not necessarily need to make it an
65: 63:     /// `Arc<str>`, as two different clones of a `String` will still have the same value.
66: 64:     type Cloneable: AttributeValue + Clone;
67: 65: 
68: 66:     /// A cloneable type that is also `'static`. This is used for spreading across types when the
69: 67:     /// spreadable attribute needs to be owned. In some cases (`&'a str` to `Arc<str>`, etc.) the owned
70: 68:     /// cloneable type has worse performance than the cloneable type, so they are separate.
71: 69:     type CloneableOwned: AttributeValue + Clone + 'static;
72: 70: 
73: 71:     /// An lyx-platform-lyx_platform_lyx-platform-lyx_platform_approximation of the actual length of this attribute in HTML.
74: 72:     fn html_len(&self) -> usize;
75: 73: 
76: 74:     /// Renders the attribute value to HTML.
77: 75:     fn to_html(self, key: &str, buf: &mut String);
78: 76: 
79: 77:     /// Renders the attribute value to HTML for a `<template>`.
80: 78:     fn to_template(key: &str, buf: &mut String);
81: 79: 
82: 80:     /// Adds interactivity as necessary, given DOM nodes that were created from HTML that has
83: 81:     /// either been rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, or cloned for a `<template>`.
84: 82:     fn hydrate<const FROM_SERVER: bool>(
85: 83:         self,
86: 84:         key: &str,
87: 85:         el: &crate::renderer::types::Element,
88: 86:     ) -> Self::State;
89: 87: 
90: 88:     /// Adds this attribute to the element during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering.
91: 89:     fn build(
92: 90:         self,
93: 91:         el: &crate::renderer::types::Element,
94: 92:         key: &str,
95: 93:     ) -> Self::State;
96: 94: 
97: 95:     /// Applies a new value for the attribute.
98: 96:     fn rebuild(self, key: &str, state: &mut Self::State);
99: 97: 
100: 98:     /// Converts this attribute into an equivalent that can be cloned.
101: 99:     fn into_cloneable(self) -> Self::Cloneable;
102: 100: 
103: 101:     /// Converts this attributes into an equivalent that can be cloned and is `'static`.
104: 102:     fn into_cloneable_owned(self) -> Self::CloneableOwned;
105: 103: 
106: 104:     /// “Runs” the attribute without other side effects. For primitive types, this is a no-op. For
107: 105:     /// reactive types, this can be used to gather data about reactivity or about asynchronous data
108: 106:     /// that needs to be loaded.
109: 107:     fn dry_resolve(&mut self);
110: 108: 
111: 109:     /// “Resolves” this into a form that is not waiting for any asynchronous data.
112: 110:     fn resolve(self) -> impl Future<Output = Self::AsyncOutput> + Send;
113: 111: }
114: 112: 
115: 113: impl AttributeValue for () {
116: 114:     type State = ();
117: 115:     type AsyncOutput = ();
118: 116:     type Cloneable = ();
119: 117:     type CloneableOwned = ();
120: 118: 
121: 119:     fn html_len(&self) -> usize {
122: 120:         0
123: 121:     }
124: 122: 
125: 123:     fn to_html(self, _key: &str, _buf: &mut String) {}
126: 124: 
127: 125:     fn to_template(_key: &str, _buf: &mut String) {}
128: 126: 
129: 127:     fn hydrate<const FROM_SERVER: bool>(
130: 128:         self,
131: 129:         _key: &str,
132: 130:         _el: &crate::renderer::types::Element,
133: 131:     ) {
134: 132:     }
135: 133: 
136: 134:     fn build(
137: 135:         self,
138: 136:         _el: &crate::renderer::types::Element,
139: 137:         _key: &str,
140: 138:     ) -> Self::State {
141: 139:     }
142: 140: 
143: 141:     fn rebuild(self, _key: &str, _state: &mut Self::State) {}
144: 142: 
145: 143:     fn into_cloneable(self) -> Self::Cloneable {
146: 144:         self
147: 145:     }
148: 146: 
149: 147:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
150: 148:         self
151: 149:     }
152: 150: 
153: 151:     fn dry_resolve(&mut self) {}
154: 152: 
155: 153:     async fn resolve(self) {}
156: 154: }
157: 155: 
158: 156: impl<'a> AttributeValue for &'a str {
159: 157:     type State = (crate::renderer::types::Element, &'a str);
160: 158:     type AsyncOutput = &'a str;
161: 159:     type Cloneable = &'a str;
162: 160:     type CloneableOwned = Arc<str>;
163: 161: 
164: 162:     fn html_len(&self) -> usize {
165: 163:         self.len()
166: 164:     }
167: 165: 
168: 166:     fn to_html(self, key: &str, buf: &mut String) {
169: 167:         buf.push(' ');
170: 168:         buf.push_str(key);
171: 169:         buf.push_str("=\"");
172: 170:         buf.push_str(&escape_attr(self));
173: 171:         buf.push('"');
174: 172:     }
175: 173: 
176: 174:     fn to_template(_key: &str, _buf: &mut String) {}
177: 175: 
178: 176:     fn hydrate<const FROM_SERVER: bool>(
179: 177:         self,
180: 178:         key: &str,
181: 179:         el: &crate::renderer::types::Element,
182: 180:     ) -> Self::State {
183: 181:         // if we're actually hydrating from SSRed HTML, we don't need to set the attribute
184: 182:         // if we're hydrating from a CSR-cloned <template>, we do need to set non-StaticAttr attributes
185: 183:         if !FROM_SERVER {
186: 184:             Rndr::set_attribute(el, key, self);
187: 185:         }
188: 186:         (el.clone(), self)
189: 187:     }
190: 188: 
191: 189:     fn build(
192: 190:         self,
193: 191:         el: &crate::renderer::types::Element,
194: 192:         key: &str,
195: 193:     ) -> Self::State {
196: 194:         Rndr::set_attribute(el, key, self);
197: 195:         (el.to_owned(), self)
198: 196:     }
199: 197: 
200: 198:     fn rebuild(self, key: &str, state: &mut Self::State) {
201: 199:         let (el, prev_value) = state;
202: 200:         if self != *prev_value {
203: 201:             Rndr::set_attribute(el, key, self);
204: 202:         }
205: 203:         *prev_value = self;
206: 204:     }
207: 205: 
208: 206:     fn into_cloneable(self) -> Self::Cloneable {
209: 207:         self
210: 208:     }
211: 209: 
212: 210:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
213: 211:         self.into()
214: 212:     }
215: 213: 
216: 214:     fn dry_resolve(&mut self) {}
217: 215: 
218: 216:     async fn resolve(self) -> Self::AsyncOutput {
219: 217:         self
220: 218:     }
221: 219: }
222: 220: 
223: 221: impl<'a> AttributeValue for Cow<'a, str> {
224: 222:     type State = (crate::renderer::types::Element, Self);
225: 223:     type AsyncOutput = Self;
226: 224:     type Cloneable = Arc<str>;
227: 225:     type CloneableOwned = Arc<str>;
228: 226: 
229: 227:     fn html_len(&self) -> usize {
230: 228:         self.len()
231: 229:     }
232: 230: 
233: 231:     fn to_html(self, key: &str, buf: &mut String) {
234: 232:         buf.push(' ');
235: 233:         buf.push_str(key);
236: 234:         buf.push_str("=\"");
237: 235:         buf.push_str(&escape_attr(&self));
238: 236:         buf.push('"');
239: 237:     }
240: 238: 
241: 239:     fn to_template(_key: &str, _buf: &mut String) {}
242: 240: 
243: 241:     fn hydrate<const FROM_SERVER: bool>(
244: 242:         self,
245: 243:         key: &str,
246: 244:         el: &crate::renderer::types::Element,
247: 245:     ) -> Self::State {
248: 246:         // if we're actually hydrating from SSRed HTML, we don't need to set the attribute
249: 247:         // if we're hydrating from a CSR-cloned <template>, we do need to set non-StaticAttr attributes
250: 248:         if !FROM_SERVER {
251: 249:             Rndr::set_attribute(el, key, &self);
252: 250:         }
253: 251:         (el.clone(), self)
254: 252:     }
255: 253: 
256: 254:     fn build(
257: 255:         self,
258: 256:         el: &crate::renderer::types::Element,
259: 257:         key: &str,
260: 258:     ) -> Self::State {
261: 259:         Rndr::set_attribute(el, key, &self);
262: 260:         (el.to_owned(), self)
263: 261:     }
264: 262: 
265: 263:     fn rebuild(self, key: &str, state: &mut Self::State) {
266: 264:         let (el, prev_value) = state;
267: 265:         if self != *prev_value {
268: 266:             Rndr::set_attribute(el, key, &self);
269: 267:         }
270: 268:         *prev_value = self;
271: 269:     }
272: 270: 
273: 271:     fn into_cloneable(self) -> Self::Cloneable {
274: 272:         self.into()
275: 273:     }
276: 274: 
277: 275:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
278: 276:         self.into()
279: 277:     }
280: 278: 
281: 279:     fn dry_resolve(&mut self) {}
282: 280: 
283: 281:     async fn resolve(self) -> Self::AsyncOutput {
284: 282:         self
285: 283:     }
286: 284: }
287: 285: 
288: 286: #[cfg(all(feature = "nightly", rustc_nightly))]
289: 287: impl<const V: &'static str> AttributeValue
290: 288:     for crate::view::static_types::Static<V>
291: 289: {
292: 290:     type AsyncOutput = Self;
293: 291:     type State = ();
294: 292:     type Cloneable = Self;
295: 293:     type CloneableOwned = Self;
296: 294: 
297: 295:     fn html_len(&self) -> usize {
298: 296:         V.len()
299: 297:     }
300: 298: 
301: 299:     fn to_html(self, key: &str, buf: &mut String) {
302: 300:         <&str as AttributeValue>::to_html(V, key, buf);
303: 301:     }
304: 302: 
305: 303:     fn to_template(key: &str, buf: &mut String) {
306: 304:         buf.push(' ');
307: 305:         buf.push_str(key);
308: 306:         buf.push_str("=\"");
309: 307:         buf.push_str(V);
310: 308:         buf.push('"');
311: 309:     }
312: 310: 
313: 311:     fn hydrate<const FROM_SERVER: bool>(
314: 312:         self,
315: 313:         _key: &str,
316: 314:         _el: &crate::renderer::types::Element,
317: 315:     ) -> Self::State {
318: 316:     }
319: 317: 
320: 318:     fn build(
321: 319:         self,
322: 320:         el: &crate::renderer::types::Element,
323: 321:         key: &str,
324: 322:     ) -> Self::State {
325: 323:         <&str as AttributeValue>::build(V, el, key);
326: 324:     }
327: 325: 
328: 326:     fn rebuild(self, _key: &str, _state: &mut Self::State) {}
329: 327: 
330: 328:     fn into_cloneable(self) -> Self::Cloneable {
331: 329:         self
332: 330:     }
333: 331: 
334: 332:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
335: 333:         self
336: 334:     }
337: 335: 
338: 336:     fn dry_resolve(&mut self) {}
339: 337: 
340: 338:     async fn resolve(self) -> Self::AsyncOutput {
341: 339:         self
342: 340:     }
343: 341: }
344: 342: 
345: 343: impl<'a> AttributeValue for &'a String {
346: 344:     type AsyncOutput = Self;
347: 345:     type State = (crate::renderer::types::Element, &'a String);
348: 346:     type Cloneable = Self;
349: 347:     type CloneableOwned = Arc<str>;
350: 348: 
351: 349:     fn html_len(&self) -> usize {
352: 350:         self.len()
353: 351:     }
354: 352: 
355: 353:     fn to_html(self, key: &str, buf: &mut String) {
356: 354:         <&str as AttributeValue>::to_html(self.as_str(), key, buf);
357: 355:     }
358: 356: 
359: 357:     fn to_template(_key: &str, _buf: &mut String) {}
360: 358: 
361: 359:     fn hydrate<const FROM_SERVER: bool>(
362: 360:         self,
363: 361:         key: &str,
364: 362:         el: &crate::renderer::types::Element,
365: 363:     ) -> Self::State {
366: 364:         let (el, _) = <&str as AttributeValue>::hydrate::<FROM_SERVER>(
367: 365:             self.as_str(),
368: 366:             key,
369: 367:             el,
370: 368:         );
371: 369:         (el, self)
372: 370:     }
373: 371: 
374: 372:     fn build(
375: 373:         self,
376: 374:         el: &crate::renderer::types::Element,
377: 375:         key: &str,
378: 376:     ) -> Self::State {
379: 377:         Rndr::set_attribute(el, key, self);
380: 378:         (el.clone(), self)
381: 379:     }
382: 380: 
383: 381:     fn rebuild(self, key: &str, state: &mut Self::State) {
384: 382:         let (el, prev_value) = state;
385: 383:         if self != *prev_value {
386: 384:             Rndr::set_attribute(el, key, self);
387: 385:         }
388: 386:         *prev_value = self;
389: 387:     }
390: 388: 
391: 389:     fn into_cloneable(self) -> Self::Cloneable {
392: 390:         self
393: 391:     }
394: 392: 
395: 393:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
396: 394:         self.as_str().into()
397: 395:     }
398: 396: 
399: 397:     fn dry_resolve(&mut self) {}
400: 398: 
401: 399:     async fn resolve(self) -> Self::AsyncOutput {
402: 400:         self
403: 401:     }
404: 402: }
405: 403: 
406: 404: impl AttributeValue for String {
407: 405:     type AsyncOutput = Self;
408: 406:     type State = (crate::renderer::types::Element, String);
409: 407:     type Cloneable = Arc<str>;
410: 408:     type CloneableOwned = Arc<str>;
411: 409: 
412: 410:     fn html_len(&self) -> usize {
413: 411:         self.len()
414: 412:     }
415: 413: 
416: 414:     fn to_html(self, key: &str, buf: &mut String) {
417: 415:         <&str as AttributeValue>::to_html(self.as_str(), key, buf);
418: 416:     }
419: 417: 
420: 418:     fn to_template(_key: &str, _buf: &mut String) {}
421: 419: 
422: 420:     fn hydrate<const FROM_SERVER: bool>(
423: 421:         self,
424: 422:         key: &str,
425: 423:         el: &crate::renderer::types::Element,
426: 424:     ) -> Self::State {
427: 425:         let (el, _) = <&str as AttributeValue>::hydrate::<FROM_SERVER>(
428: 426:             self.as_str(),
429: 427:             key,
430: 428:             el,
431: 429:         );
432: 430:         (el, self)
433: 431:     }
434: 432: 
435: 433:     fn build(
436: 434:         self,
437: 435:         el: &crate::renderer::types::Element,
438: 436:         key: &str,
439: 437:     ) -> Self::State {
440: 438:         Rndr::set_attribute(el, key, &self);
441: 439:         (el.clone(), self)
442: 440:     }
443: 441: 
444: 442:     fn rebuild(self, key: &str, state: &mut Self::State) {
445: 443:         let (el, prev_value) = state;
446: 444:         if self != *prev_value {
447: 445:             Rndr::set_attribute(el, key, &self);
448: 446:         }
449: 447:         *prev_value = self;
450: 448:     }
451: 449: 
452: 450:     fn into_cloneable(self) -> Self::Cloneable {
453: 451:         self.into()
454: 452:     }
455: 453: 
456: 454:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
457: 455:         self.into()
458: 456:     }
459: 457: 
460: 458:     fn dry_resolve(&mut self) {}
461: 459: 
462: 460:     async fn resolve(self) -> Self::AsyncOutput {
463: 461:         self
464: 462:     }
465: 463: }
466: 464: 
467: 465: impl AttributeValue for Arc<str> {
468: 466:     type AsyncOutput = Self;
469: 467:     type State = (crate::renderer::types::Element, Arc<str>);
470: 468:     type Cloneable = Arc<str>;
471: 469:     type CloneableOwned = Arc<str>;
472: 470: 
473: 471:     fn html_len(&self) -> usize {
474: 472:         self.len()
475: 473:     }
476: 474: 
477: 475:     fn to_html(self, key: &str, buf: &mut String) {
478: 476:         <&str as AttributeValue>::to_html(self.as_ref(), key, buf);
479: 477:     }
480: 478: 
481: 479:     fn to_template(_key: &str, _buf: &mut String) {}
482: 480: 
483: 481:     fn hydrate<const FROM_SERVER: bool>(
484: 482:         self,
485: 483:         key: &str,
486: 484:         el: &crate::renderer::types::Element,
487: 485:     ) -> Self::State {
488: 486:         let (el, _) = <&str as AttributeValue>::hydrate::<FROM_SERVER>(
489: 487:             self.as_ref(),
490: 488:             key,
491: 489:             el,
492: 490:         );
493: 491:         (el, self)
494: 492:     }
495: 493: 
496: 494:     fn build(
497: 495:         self,
498: 496:         el: &crate::renderer::types::Element,
499: 497:         key: &str,
500: 498:     ) -> Self::State {
501: 499:         Rndr::set_attribute(el, key, &self);
502: 500:         (el.clone(), self)
503: 501:     }
504: 502: 
505: 503:     fn rebuild(self, key: &str, state: &mut Self::State) {
506: 504:         let (el, prev_value) = state;
507: 505:         if self != *prev_value {
508: 506:             Rndr::set_attribute(el, key, &self);
509: 507:         }
510: 508:         *prev_value = self;
511: 509:     }
512: 510: 
513: 511:     fn into_cloneable(self) -> Self::Cloneable {
514: 512:         self
515: 513:     }
516: 514: 
517: 515:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
518: 516:         self
519: 517:     }
520: 518: 
521: 519:     fn dry_resolve(&mut self) {}
522: 520: 
523: 521:     async fn resolve(self) -> Self::AsyncOutput {
524: 522:         self
525: 523:     }
526: 524: }
527: 525: // TODO impl AttributeValue for Rc<str> and Arc<str> too
528: 526: 
529: 527: impl AttributeValue for bool {
530: 528:     type AsyncOutput = Self;
531: 529:     type State = (crate::renderer::types::Element, bool);
532: 530:     type Cloneable = Self;
533: 531:     type CloneableOwned = Self;
534: 532: 
535: 533:     fn html_len(&self) -> usize {
536: 534:         0
537: 535:     }
538: 536: 
539: 537:     fn to_html(self, key: &str, buf: &mut String) {
540: 538:         if self {
541: 539:             buf.push(' ');
542: 540:             buf.push_str(key);
543: 541:         }
544: 542:     }
545: 543: 
546: 544:     fn to_template(_key: &str, _buf: &mut String) {}
547: 545: 
548: 546:     fn hydrate<const FROM_SERVER: bool>(
549: 547:         self,
550: 548:         key: &str,
551: 549:         el: &crate::renderer::types::Element,
552: 550:     ) -> Self::State {
553: 551:         // if we're actually hydrating from SSRed HTML, we don't need to set the attribute
554: 552:         // if we're hydrating from a CSR-cloned <template>, we do need to set non-StaticAttr attributes
555: 553:         if !FROM_SERVER {
556: 554:             Rndr::set_attribute(el, key, "");
557: 555:         }
558: 556:         (el.clone(), self)
559: 557:     }
560: 558: 
561: 559:     fn build(
562: 560:         self,
563: 561:         el: &crate::renderer::types::Element,
564: 562:         key: &str,
565: 563:     ) -> Self::State {
566: 564:         if self {
567: 565:             Rndr::set_attribute(el, key, "");
568: 566:         }
569: 567:         (el.clone(), self)
570: 568:     }
571: 569: 
572: 570:     fn rebuild(self, key: &str, state: &mut Self::State) {
573: 571:         let (el, prev_value) = state;
574: 572:         if self != *prev_value {
575: 573:             if self {
576: 574:                 Rndr::set_attribute(el, key, "");
577: 575:             } else {
578: 576:                 Rndr::remove_attribute(el, key);
579: 577:             }
580: 578:         }
581: 579:         *prev_value = self;
582: 580:     }
583: 581: 
584: 582:     fn into_cloneable(self) -> Self::Cloneable {
585: 583:         self
586: 584:     }
587: 585: 
588: 586:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
589: 587:         self
590: 588:     }
591: 589: 
592: 590:     fn dry_resolve(&mut self) {}
593: 591: 
594: 592:     async fn resolve(self) -> Self::AsyncOutput {
595: 593:         self
596: 594:     }
597: 595: }
598: 596: 
599: 597: impl<V> AttributeValue for Option<V>
600: 598: where
601: 599:     V: AttributeValue,
602: 600: {
603: 601:     type AsyncOutput = Option<V::AsyncOutput>;
604: 602:     type State = (crate::renderer::types::Element, Option<V::State>);
605: 603:     type Cloneable = Option<V::Cloneable>;
606: 604:     type CloneableOwned = Option<V::CloneableOwned>;
607: 605: 
608: 606:     fn html_len(&self) -> usize {
609: 607:         match self {
610: 608:             Some(i) => i.html_len(),
611: 609:             None => 0,
612: 610:         }
613: 611:     }
614: 612: 
615: 613:     fn to_html(self, key: &str, buf: &mut String) {
616: 614:         if let Some(v) = self {
617: 615:             v.to_html(key, buf);
618: 616:         }
619: 617:     }
620: 618: 
621: 619:     fn to_template(_key: &str, _buf: &mut String) {}
622: 620: 
623: 621:     fn hydrate<const FROM_SERVER: bool>(
624: 622:         self,
625: 623:         key: &str,
626: 624:         el: &crate::renderer::types::Element,
627: 625:     ) -> Self::State {
628: 626:         let state = self.map(|v| v.hydrate::<FROM_SERVER>(key, el));
629: 627:         (el.clone(), state)
630: 628:     }
631: 629: 
632: 630:     fn build(
633: 631:         self,
634: 632:         el: &crate::renderer::types::Element,
635: 633:         key: &str,
636: 634:     ) -> Self::State {
637: 635:         let el = el.clone();
638: 636:         let v = self.map(|v| v.build(&el, key));
639: 637:         (el, v)
640: 638:     }
641: 639: 
642: 640:     fn rebuild(self, key: &str, state: &mut Self::State) {
643: 641:         let (el, prev) = state;
644: 642:         match (self, prev.as_mut()) {
645: 643:             (None, None) => {}
646: 644:             (None, Some(_)) => {
647: 645:                 Rndr::remove_attribute(el, key);
648: 646:                 *prev = None;
649: 647:             }
650: 648:             (Some(value), None) => {
651: 649:                 *prev = Some(value.build(el, key));
652: 650:             }
653: 651:             (Some(new), Some(old)) => {
654: 652:                 new.rebuild(key, old);
655: 653:             }
656: 654:         }
657: 655:     }
658: 656: 
659: 657:     fn into_cloneable(self) -> Self::Cloneable {
660: 658:         self.map(|value| value.into_cloneable())
661: 659:     }
662: 660: 
663: 661:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
664: 662:         self.map(|value| value.into_cloneable_owned())
665: 663:     }
666: 664: 
667: 665:     fn dry_resolve(&mut self) {
668: 666:         if let Some(inner) = self.as_mut() {
669: 667:             inner.dry_resolve();
670: 668:         }
671: 669:     }
672: 670: 
673: 671:     async fn resolve(self) -> Self::AsyncOutput {
674: 672:         match self {
675: 673:             None => None,
676: 674:             Some(inner) => Some(inner.resolve().await),
677: 675:         }
678: 676:     }
679: 677: }
680: 678: 
681: 679: pub(crate) fn escape_attr(value: &str) -> Cow<'_, str> {
682: 680:     html_escape::encode_double_quoted_attribute(value)
683: 681: }
684: 682: 
685: 683: macro_rules! render_primitive {
686: 684:   ($($child_type:ty),* $(,)?) => {
687: 685:       $(
688: 686:         impl AttributeValue for $child_type
689: 687:         where
690: 688: 
691: 689:         {
692: 690:             type AsyncOutput = $child_type;
693: 691:             type State = (crate::renderer::types::Element, $child_type);
694: 692:             type Cloneable = Self;
695: 693:             type CloneableOwned = Self;
696: 694: 
697: 695:             fn html_len(&self) -> usize {
698: 696:                 0
699: 697:             }
700: 698: 
701: 699:             fn to_html(self, key: &str, buf: &mut String) {
702: 700:                 <String as AttributeValue>::to_html(self.to_string(), key, buf);
703: 701:             }
704: 702: 
705: 703:             fn to_template(_key: &str, _buf: &mut String) {}
706: 704: 
707: 705:             fn hydrate<const FROM_SERVER: bool>(
708: 706:                 self,
709: 707:                 key: &str,
710: 708:                 el: &crate::renderer::types::Element,
711: 709:             ) -> Self::State {
712: 710:                 // if we're actually hydrating from SSRed HTML, we don't need to set the attribute
713: 711:                 // if we're hydrating from a CSR-cloned <template>, we do need to set non-StaticAttr attributes
714: 712:                 if !FROM_SERVER {
715: 713:                     Rndr::set_attribute(el, key, &self.to_string());
716: 714:                 }
717: 715:                 (el.clone(), self)
718: 716:             }
719: 717: 
720: 718:             fn build(self, el: &crate::renderer::types::Element, key: &str) -> Self::State {
721: 719:                 Rndr::set_attribute(el, key, &self.to_string());
722: 720:                 (el.to_owned(), self)
723: 721:             }
724: 722: 
725: 723:             fn rebuild(self, key: &str, state: &mut Self::State) {
726: 724:                 let (el, prev_value) = state;
727: 725:                 if self != *prev_value {
728: 726:                     Rndr::set_attribute(el, key, &self.to_string());
729: 727:                 }
730: 728:                 *prev_value = self;
731: 729:             }
732: 730: 
733: 731:             fn into_cloneable(self) -> Self::Cloneable {
734: 732:                 self
735: 733:             }
736: 734: 
737: 735:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
738: 736:                 self
739: 737:             }
740: 738: 
741: 739:             fn dry_resolve(&mut self) {
742: 740:             }
743: 741: 
744: 742:             async fn resolve(self) -> Self::AsyncOutput {
745: 743:                 self
746: 744:             }
747: 745:         }
748: 746:       )*
749: 747:   }
750: 748: }
751: 749: 
752: 750: render_primitive![
753: 751:     usize,
754: 752:     u8,
755: 753:     u16,
756: 754:     u32,
757: 755:     u64,
758: 756:     u128,
759: 757:     isize,
760: 758:     i8,
761: 759:     i16,
762: 760:     i32,
763: 761:     i64,
764: 762:     i128,
765: 763:     f32,
766: 764:     f64,
767: 765:     char,
768: 766:     IpAddr,
769: 767:     SocketAddr,
770: 768:     SocketAddrV4,
771: 769:     SocketAddrV6,
772: 770:     Ipv4Addr,
773: 771:     Ipv6Addr,
774: 772:     NonZeroI8,
775: 773:     NonZeroU8,
776: 774:     NonZeroI16,
777: 775:     NonZeroU16,
778: 776:     NonZeroI32,
779: 777:     NonZeroU32,
780: 778:     NonZeroI64,
781: 779:     NonZeroU64,
782: 780:     NonZeroI128,
783: 781:     NonZeroU128,
784: 782:     NonZeroIsize,
785: 783:     NonZeroUsize,
786: 784: ];
787: 785: ```
788: 786: ```
789: 787: ```
790: 788: ```
791: 789: ```
792: 790: ```
793: 791: ```
794: 792: ```
795: ```
```
