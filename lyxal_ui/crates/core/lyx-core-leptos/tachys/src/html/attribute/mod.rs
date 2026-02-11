### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\mod.rs
18: 16: ```rust
19: 17: /// A type-erased `AnyAttribute`.
20: 18: pub mod any_attribute;
21: 19: /// Types for ARIA attributes.
22: 20: pub mod aria;
23: 21: /// Types for custom attributes.
24: 22: pub mod custom;
25: 23: /// Traits to define global attribute methods on all HTML elements.
26: 24: pub mod global;
27: 25: mod key;
28: 26: pub(crate) mod maybe_next_attr_erasure_macros;
29: 27: mod value;
30: 28: 
31: 29: use crate::view::{Position, ToTemplate};
32: 30: pub use key::*;
33: 31: use maybe_next_attr_erasure_macros::{
34: 32:     next_attr_combine, next_attr_output_type,
35: 33: };
36: 34: use std::{borrow::Cow, fmt::Debug, future::Future};
37: 35: pub use value::*;
38: 36: 
39: 37: /// Defines an attribute: anything that can modify an element.
40: 38: pub trait Attribute: NextAttribute + Send {
41: 39:     /// The minimum length of this attribute in HTML.
42: 40:     const MIN_LENGTH: usize;
43: 41: 
44: 42:     /// The state that should be retained between building and rebuilding.
45: 43:     type State;
46: 44:     /// The type once all async data have loaded.
47: 45:     type AsyncOutput: Attribute;
48: 46:     /// An equivalent to this attribute that can be cloned to be shared across elements.
49: 47:     type Cloneable: Attribute + Clone;
50: 48:     /// An equivalent to this attribute that can be cloned to be shared across elements, and
51: 49:     /// captures no references shorter than `'static`.
52: 50:     type CloneableOwned: Attribute + Clone + 'static;
53: 51: 
54: 52:     /// An lyx-platform-lyx_platform_lyx-platform-lyx_platform_approximation of the actual length of this attribute in HTML.
55: 53:     fn html_len(&self) -> usize;
56: 54: 
57: 55:     /// Renders the attribute to HTML.
58: 56:     ///
59: 57:     /// This separates a general buffer for attribute values from the `class` and `style`
60: 58:     /// attributes, so that multiple classes or styles can be combined, and also allows for an
61: 59:     /// `inner_html` attribute that sets the child HTML instead of an attribute.
62: 60:     fn to_html(
63: 61:         self,
64: 62:         buf: &mut String,
65: 63:         class: &mut String,
66: 64:         style: &mut String,
67: 65:         inner_html: &mut String,
68: 66:     );
69: 67: 
70: 68:     /// Adds interactivity as necessary, given DOM nodes that were created from HTML that has
71: 69:     /// either been rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, or cloned for a `<template>`.
72: 70:     fn hydrate<const FROM_SERVER: bool>(
73: 71:         self,
74: 72:         el: &crate::renderer::types::Element,
75: 73:     ) -> Self::State;
76: 74: 
77: 75:     /// Adds this attribute to the element during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering.
78: 76:     fn build(self, el: &crate::renderer::types::Element) -> Self::State;
79: 77: 
80: 78:     /// Applies a new value for the attribute.
81: 79:     fn rebuild(self, state: &mut Self::State);
82: 80: 
83: 81:     /// Converts this attribute into an equivalent that can be cloned.
84: 82:     fn into_cloneable(self) -> Self::Cloneable;
85: 83: 
86: 84:     /// Converts this attributes into an equivalent that can be cloned and is `'static`.
87: 85:     fn into_cloneable_owned(self) -> Self::CloneableOwned;
88: 86: 
89: 87:     /// “Runs” the attribute without other side effects. For primitive types, this is a no-op. For
90: 88:     /// reactive types, this can be used to gather data about reactivity or about asynchronous data
91: 89:     /// that needs to be loaded.
92: 90:     fn dry_resolve(&mut self);
93: 91: 
94: 92:     /// “Resolves” this into a type that is not waiting for any asynchronous data.
95: 93:     fn resolve(self) -> impl Future<Output = Self::AsyncOutput> + Send;
96: 94: 
97: 95:     /// Returns a set of attribute keys, associated with this attribute, if any.
98: 96:     ///
99: 97:     /// This is only used to manage the removal of type-erased attributes, when needed.
100: 98:     fn keys(&self) -> Vec<NamedAttributeKey> {
101: 99:         // TODO: remove default implementation in 0.9, or fix this whole lyx-platform-lyx_platform_lyx-platform-lyx_platform_approach
102: 100:         // by making it easier to remove attributes
103: 101:         vec![]
104: 102:     }
105: 103: }
106: 104: 
107: 105: /// An attribute key can be used to remove an attribute from an element.
108: 106: pub enum NamedAttributeKey {
109: 107:     /// An ordinary attribute.
110: 108:     Attribute(Cow<'static, str>),
111: 109:     /// A DOM property.
112: 110:     Property(Cow<'static, str>),
113: 111:     /// The `inner_html` pseudo-attribute.
114: 112:     InnerHtml,
115: 113: }
116: 114: 
117: 115: /// Adds another attribute to this one, returning a new attribute.
118: 116: ///
119: 117: /// This is typically achieved by creating or extending a tuple of attributes.
120: 118: pub trait NextAttribute {
121: 119:     /// The type of the new, combined attribute.
122: 120:     type Output<NewAttr: Attribute>: Attribute;
123: 121: 
124: 122:     /// Adds a new attribute.
125: 123:     fn add_any_attr<NewAttr: Attribute>(
126: 124:         self,
127: 125:         new_attr: NewAttr,
128: 126:     ) -> Self::Output<NewAttr>;
129: 127: }
130: 128: 
131: 129: impl Attribute for () {
132: 130:     const MIN_LENGTH: usize = 0;
133: 131: 
134: 132:     type State = ();
135: 133:     type AsyncOutput = ();
136: 134:     type Cloneable = ();
137: 135:     type CloneableOwned = ();
138: 136: 
139: 137:     fn html_len(&self) -> usize {
140: 138:         0
141: 139:     }
142: 140: 
143: 141:     fn to_html(
144: 142:         self,
145: 143:         _buf: &mut String,
146: 144:         _class: &mut String,
147: 145:         _style: &mut String,
148: 146:         _inner_html: &mut String,
149: 147:     ) {
150: 148:     }
151: 149: 
152: 150:     fn hydrate<const FROM_SERVER: bool>(
153: 151:         self,
154: 152:         _el: &crate::renderer::types::Element,
155: 153:     ) -> Self::State {
156: 154:     }
157: 155: 
158: 156:     fn build(self, _el: &crate::renderer::types::Element) -> Self::State {}
159: 157: 
160: 158:     fn rebuild(self, _state: &mut Self::State) {}
161: 159: 
162: 160:     fn into_cloneable(self) -> Self::Cloneable {
163: 161:         self
164: 162:     }
165: 163: 
166: 164:     fn into_cloneable_owned(self) -> Self::Cloneable {
167: 165:         self
168: 166:     }
169: 167: 
170: 168:     fn dry_resolve(&mut self) {}
171: 169: 
172: 170:     async fn resolve(self) -> Self::AsyncOutput {}
173: 171: 
174: 172:     fn keys(&self) -> Vec<NamedAttributeKey> {
175: 173:         vec![]
176: 174:     }
177: 175: }
178: 176: 
179: 177: impl NextAttribute for () {
180: 178:     #[cfg(not(erase_components))]
181: 179:     type Output<NewAttr: Attribute> = (NewAttr,);
182: 180: 
183: 181:     #[cfg(erase_components)]
184: 182:     type Output<NewAttr: Attribute> =
185: 183:         Vec<crate::html::attribute::any_attribute::AnyAttribute>;
186: 184: 
187: 185:     fn add_any_attr<NewAttr: Attribute>(
188: 186:         self,
189: 187:         new_attr: NewAttr,
190: 188:     ) -> Self::Output<NewAttr> {
191: 189:         #[cfg(not(erase_components))]
192: 190:         {
193: 191:             (new_attr,)
194: 192:         }
195: 193:         #[cfg(erase_components)]
196: 194:         {
197: 195:             use crate::html::attribute::any_attribute::IntoAnyAttribute;
198: 196: 
199: 197:             vec![new_attr.into_any_attr()]
200: 198:         }
201: 199:     }
202: 200: }
203: 201: 
204: 202: /// An attribute with a key and value.
205: 203: #[derive(Debug)]
206: 204: pub struct Attr<K, V>(pub K, pub V)
207: 205: where
208: 206:     K: AttributeKey,
209: 207:     V: AttributeValue;
210: 208: 
211: 209: impl<K, V> Clone for Attr<K, V>
212: 210: where
213: 211:     K: AttributeKey,
214: 212:     V: AttributeValue + Clone,
215: 213: {
216: 214:     fn clone(&self) -> Self {
217: 215:         Self(self.0.clone(), self.1.clone())
218: 216:     }
219: 217: }
220: 218: 
221: 219: impl<K, V> ToTemplate for Attr<K, V>
222: 220: where
223: 221:     K: AttributeKey,
224: 222:     V: AttributeValue,
225: 223: {
226: 224:     fn to_template(
227: 225:         buf: &mut String,
228: 226:         _class: &mut String,
229: 227:         _style: &mut String,
230: 228:         _inner_html: &mut String,
231: 229:         _position: &mut Position,
232: 230:     ) {
233: 231:         V::to_template(K::KEY, buf);
234: 232:     }
235: 233: }
236: 234: 
237: 235: impl<K, V> Attribute for Attr<K, V>
238: 236: where
239: 237:     K: AttributeKey + Send,
240: 238:     V: AttributeValue + Send,
241: 239: {
242: 240:     const MIN_LENGTH: usize = 0;
243: 241: 
244: 242:     type State = V::State;
245: 243:     type AsyncOutput = Attr<K, V::AsyncOutput>;
246: 244:     type Cloneable = Attr<K, V::Cloneable>;
247: 245:     type CloneableOwned = Attr<K, V::CloneableOwned>;
248: 246: 
249: 247:     fn html_len(&self) -> usize {
250: 248:         K::KEY.len() + 3 + self.1.html_len()
251: 249:     }
252: 250: 
253: 251:     fn to_html(
254: 252:         self,
255: 253:         buf: &mut String,
256: 254:         _class: &mut String,
257: 255:         _style: &mut String,
258: 256:         _inner_html: &mut String,
259: 257:     ) {
260: 258:         self.1.to_html(K::KEY, buf);
261: 259:     }
262: 260: 
263: 261:     fn hydrate<const FROM_SERVER: bool>(
264: 262:         self,
265: 263:         el: &crate::renderer::types::Element,
266: 264:     ) -> Self::State {
267: 265:         self.1.hydrate::<FROM_SERVER>(K::KEY, el)
268: 266:     }
269: 267: 
270: 268:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
271: 269:         V::build(self.1, el, K::KEY)
272: 270:     }
273: 271: 
274: 272:     fn rebuild(self, state: &mut Self::State) {
275: 273:         V::rebuild(self.1, K::KEY, state);
276: 274:     }
277: 275: 
278: 276:     fn into_cloneable(self) -> Self::Cloneable {
279: 277:         Attr(self.0, self.1.into_cloneable())
280: 278:     }
281: 279: 
282: 280:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
283: 281:         Attr(self.0, self.1.into_cloneable_owned())
284: 282:     }
285: 283: 
286: 284:     fn dry_resolve(&mut self) {
287: 285:         self.1.dry_resolve();
288: 286:     }
289: 287: 
290: 288:     async fn resolve(self) -> Self::AsyncOutput {
291: 289:         Attr(self.0, self.1.resolve().await)
292: 290:     }
293: 291: 
294: 292:     fn keys(&self) -> Vec<NamedAttributeKey> {
295: 293:         vec![NamedAttributeKey::Attribute(K::KEY.into())]
296: 294:     }
297: 295: }
298: 296: 
299: 297: impl<K, V> NextAttribute for Attr<K, V>
300: 298: where
301: 299:     K: AttributeKey,
302: 300:     V: AttributeValue,
303: 301: {
304: 302:     next_attr_output_type!(Self, NewAttr);
305: 303: 
306: 304:     fn add_any_attr<NewAttr: Attribute>(
307: 305:         self,
308: 306:         new_attr: NewAttr,
309: 307:     ) -> Self::Output<NewAttr> {
310: 308:         next_attr_combine!(self, new_attr)
311: 309:     }
312: 310: }
313: 311: 
314: 312: macro_rules! impl_attr_for_tuples {
315: 313:     ($first:ident, $($ty:ident),* $(,)?) => {
316: 314:         impl<$first, $($ty),*> Attribute for ($first, $($ty,)*)
317: 315:         where
318: 316:             $first: Attribute,
319: 317:             $($ty: Attribute),*,
320: 318:         {
321: 319:             const MIN_LENGTH: usize = $first::MIN_LENGTH $(+ $ty::MIN_LENGTH)*;
322: 320: 
323: 321:             type AsyncOutput = ($first::AsyncOutput, $($ty::AsyncOutput,)*);
324: 322:             type State = ($first::State, $($ty::State,)*);
325: 323:             type Cloneable = ($first::Cloneable, $($ty::Cloneable,)*);
326: 324:             type CloneableOwned = ($first::CloneableOwned, $($ty::CloneableOwned,)*);
327: 325: 
328: 326:             fn html_len(&self) -> usize {
329: 327:                 #[allow(non_snake_case)]
330: 328:                 let ($first, $($ty,)*) = self;
331: 329:                 $first.html_len() $(+ $ty.html_len())*
332: 330:             }
333: 331: 
334: 332:             fn to_html(self, buf: &mut String, class: &mut String, style: &mut String, inner_html: &mut String,) {
335: 333:                 #[allow(non_snake_case)]
336: 334:                     let ($first, $($ty,)* ) = self;
337: 335:                     $first.to_html(buf, class, style, inner_html);
338: 336:                     $($ty.to_html(buf, class, style, inner_html));*
339: 337:             }
340: 338: 
341: 339:             fn hydrate<const FROM_SERVER: bool>(self, el: &crate::renderer::types::Element) -> Self::State {
342: 340:                 #[allow(non_snake_case)]
343: 341:                     let ($first, $($ty,)* ) = self;
344: 342:                     (
345: 343:                         $first.hydrate::<FROM_SERVER>(el),
346: 344:                         $($ty.hydrate::<FROM_SERVER>(el)),*
347: 345:                     )
348: 346:             }
349: 347: 
350: 348:             fn build(self, el: &crate::renderer::types::Element) -> Self::State {
351: 349:                 #[allow(non_snake_case)]
352: 350:                     let ($first, $($ty,)*) = self;
353: 351:                     (
354: 352:                         $first.build(el),
355: 353:                         $($ty.build(el)),*
356: 354:                     )
357: 355:             }
358: 356: 
359: 357:             fn rebuild(self, state: &mut Self::State) {
360: 358:                 paste::paste! {
361: 359:                     let ([<$first:lower>], $([<$ty:lower>],)*) = self;
362: 360:                     let ([<view_ $first:lower>], $([<view_ $ty:lower>],)*) = state;
363: 361:                     [<$first:lower>].rebuild([<view_ $first:lower>]);
364: 362:                     $([<$ty:lower>].rebuild([<view_ $ty:lower>]));*
365: 363:                 }
366: 364:             }
367: 365: 
368: 366:             fn into_cloneable(self) -> Self::Cloneable {
369: 367:                 #[allow(non_snake_case)]
370: 368:                 let ($first, $($ty,)*) = self;
371: 369:                 (
372: 370:                     $first.into_cloneable(),
373: 371:                     $($ty.into_cloneable()),*
374: 372:                 )
375: 373:             }
376: 374: 
377: 375:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
378: 376:                 #[allow(non_snake_case)]
379: 377:                 let ($first, $($ty,)*) = self;
380: 378:                 (
381: 379:                     $first.into_cloneable_owned(),
382: 380:                     $($ty.into_cloneable_owned()),*
383: 381:                 )
384: 382:             }
385: 383: 
386: 384:             fn dry_resolve(&mut self) {
387: 385:                 #[allow(non_snake_case)]
388: 386:                 let ($first, $($ty,)*) = self;
389: 387:                 $first.dry_resolve();
390: 388:                 $($ty.dry_resolve());*
391: 389:             }
392: 390: 
393: 391:             async fn resolve(self) -> Self::AsyncOutput {
394: 392:                 #[allow(non_snake_case)]
395: 393:                 let ($first, $($ty,)*) = self;
396: 394:                 futures::join!(
397: 395:                     $first.resolve(),
398: 396:                     $($ty.resolve()),*
399: 397:                 )
400: 398:             }
401: 399: 
402: 400:             fn keys(&self) -> Vec<NamedAttributeKey> {
403: 401:                 #[allow(non_snake_case)]
404: 402:                 let ($first, $($ty,)*) = &self;
405: 403:                 let mut buf = $first.keys();
406: 404:                 $(buf.extend($ty.keys());)*
407: 405:                 buf
408: 406:             }
409: 407:         }
410: 408: 
411: 409:         impl<$first, $($ty),*> NextAttribute for ($first, $($ty,)*)
412: 410:         where
413: 411:             $first: Attribute,
414: 412:             $($ty: Attribute),*,
415: 413: 
416: 414:         {
417: 415:             type Output<NewAttr: Attribute> = ($first, $($ty,)* NewAttr);
418: 416: 
419: 417:             fn add_any_attr<NewAttr: Attribute>(
420: 418:                 self,
421: 419:                 new_attr: NewAttr,
422: 420:             ) -> Self::Output<NewAttr> {
423: 421:                 #[allow(non_snake_case)]
424: 422:                 let ($first, $($ty,)*) = self;
425: 423:                 ($first, $($ty,)* new_attr)
426: 424:             }
427: 425:         }
428: 426:     };
429: 427: }
430: 428: 
431: 429: macro_rules! impl_attr_for_tuples_truncate_additional {
432: 430:     ($first:ident, $($ty:ident),* $(,)?) => {
433: 431:         impl<$first, $($ty),*> Attribute for ($first, $($ty,)*)
434: 432:         where
435: 433:             $first: Attribute,
436: 434:             $($ty: Attribute),*,
437: 435:         {
438: 436:             const MIN_LENGTH: usize = $first::MIN_LENGTH $(+ $ty::MIN_LENGTH)*;
439: 437: 
440: 438:             type AsyncOutput = ($first::AsyncOutput, $($ty::AsyncOutput,)*);
441: 439:             type State = ($first::State, $($ty::State,)*);
442: 440:             type Cloneable = ($first::Cloneable, $($ty::Cloneable,)*);
443: 441:             type CloneableOwned = ($first::CloneableOwned, $($ty::CloneableOwned,)*);
444: 442: 
445: 443:             fn html_len(&self) -> usize {
446: 444:                 #[allow(non_snake_case)]
447: 445:                 let ($first, $($ty,)*) = self;
448: 446:                 $first.html_len() $(+ $ty.html_len())*
449: 447:             }
450: 448: 
451: 449:             fn to_html(self, buf: &mut String, class: &mut String, style: &mut String, inner_html: &mut String,) {
452: 450:                 #[allow(non_snake_case)]
453: 451:                 let ($first, $($ty,)* ) = self;
454: 452:                 $first.to_html(buf, class, style, inner_html);
455: 453:                 $($ty.to_html(buf, class, style, inner_html));*
456: 454:             }
457: 455: 
458: 456:             fn hydrate<const FROM_SERVER: bool>(self, el: &crate::renderer::types::Element) -> Self::State {
459: 457:                 #[allow(non_snake_case)]
460: 458:                 let ($first, $($ty,)* ) = self;
461: 459:                 (
462: 460:                     $first.hydrate::<FROM_SERVER>(el),
463: 461:                     $($ty.hydrate::<FROM_SERVER>(el)),*
464: 462:                 )
465: 463:             }
466: 464: 
467: 465:             fn build(self, el: &crate::renderer::types::Element) -> Self::State {
468: 466:                 #[allow(non_snake_case)]
469: 467:                 let ($first, $($ty,)*) = self;
470: 468:                 (
471: 469:                     $first.build(el),
472: 470:                     $($ty.build(el)),*
473: 471:                 )
474: 472:             }
475: 473: 
476: 474:             fn rebuild(self, state: &mut Self::State) {
477: 475:                 paste::paste! {
478: 476:                     let ([<$first:lower>], $([<$ty:lower>],)*) = self;
479: 477:                     let ([<view_ $first:lower>], $([<view_ $ty:lower>],)*) = state;
480: 478:                     [<$first:lower>].rebuild([<view_ $first:lower>]);
481: 479:                     $([<$ty:lower>].rebuild([<view_ $ty:lower>]));*
482: 480:                 }
483: 481:             }
484: 482: 
485: 483:             fn into_cloneable(self) -> Self::Cloneable {
486: 484:                 #[allow(non_snake_case)]
487: 485:                 let ($first, $($ty,)*) = self;
488: 486:                 (
489: 487:                     $first.into_cloneable(),
490: 488:                     $($ty.into_cloneable()),*
491: 489:                 )
492: 490:             }
493: 491: 
494: 492:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
495: 493:                 #[allow(non_snake_case)]
496: 494:                 let ($first, $($ty,)*) = self;
497: 495:                 (
498: 496:                     $first.into_cloneable_owned(),
499: 497:                     $($ty.into_cloneable_owned()),*
500: 498:                 )
501: 499:             }
502: 500: 
503: 501:             fn dry_resolve(&mut self) {
504: 502:                 #[allow(non_snake_case)]
505: 503:                 let ($first, $($ty,)*) = self;
506: 504:                 $first.dry_resolve();
507: 505:                 $($ty.dry_resolve());*
508: 506:             }
509: 507: 
510: 508:             async fn resolve(self) -> Self::AsyncOutput {
511: 509:                 #[allow(non_snake_case)]
512: 510:                 let ($first, $($ty,)*) = self;
513: 511:                 futures::join!(
514: 512:                     $first.resolve(),
515: 513:                     $($ty.resolve()),*
516: 514:                 )
517: 515:             }
518: 516: 
519: 517:             fn keys(&self) -> Vec<NamedAttributeKey> {
520: 518:                 #[allow(non_snake_case)]
521: 519:                 let ($first, $($ty,)*) = &self;
522: 520:                 let mut buf = $first.keys();
523: 521:                 $(buf.extend($ty.keys());)*
524: 522:                 buf
525: 523:             }
526: 524:         }
527: 525: 
528: 526:         impl<$first, $($ty),*> NextAttribute for ($first, $($ty,)*)
529: 527:         where
530: 528:             $first: Attribute,
531: 529:             $($ty: Attribute),*,
532: 530: 
533: 531:         {
534: 532:             type Output<NewAttr: Attribute> = ($first, $($ty,)*);
535: 533: 
536: 534:             fn add_any_attr<NewAttr: Attribute>(
537: 535:                 self,
538: 536:                 _new_attr: NewAttr,
539: 537:             ) -> Self::Output<NewAttr> {
540: 538:                 todo!("adding more than 26 attributes is not supported");
541: 539:                 //($first, $($ty,)*)
542: 540:             }
543: 541:         }
544: 542:     };
545: 543: }
546: 544: 
547: 545: impl<A> Attribute for (A,)
548: 546: where
549: 547:     A: Attribute,
550: 548: {
551: 549:     const MIN_LENGTH: usize = A::MIN_LENGTH;
552: 550: 
553: 551:     type AsyncOutput = (A::AsyncOutput,);
554: 552:     type State = A::State;
555: 553:     type Cloneable = (A::Cloneable,);
556: 554:     type CloneableOwned = (A::CloneableOwned,);
557: 555: 
558: 556:     fn html_len(&self) -> usize {
559: 557:         self.0.html_len()
560: 558:     }
561: 559: 
562: 560:     fn to_html(
563: 561:         self,
564: 562:         buf: &mut String,
565: 563:         class: &mut String,
566: 564:         style: &mut String,
567: 565:         inner_html: &mut String,
568: 566:     ) {
569: 567:         self.0.to_html(buf, class, style, inner_html);
570: 568:     }
571: 569: 
572: 570:     fn hydrate<const FROM_SERVER: bool>(
573: 571:         self,
574: 572:         el: &crate::renderer::types::Element,
575: 573:     ) -> Self::State {
576: 574:         self.0.hydrate::<FROM_SERVER>(el)
577: 575:     }
578: 576: 
579: 577:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
580: 578:         self.0.build(el)
581: 579:     }
582: 580: 
583: 581:     fn rebuild(self, state: &mut Self::State) {
584: 582:         self.0.rebuild(state);
585: 583:     }
586: 584: 
587: 585:     fn into_cloneable(self) -> Self::Cloneable {
588: 586:         (self.0.into_cloneable(),)
589: 587:     }
590: 588: 
591: 589:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
592: 590:         (self.0.into_cloneable_owned(),)
593: 591:     }
594: 592: 
595: 593:     fn dry_resolve(&mut self) {
596: 594:         self.0.dry_resolve();
597: 595:     }
598: 596: 
599: 597:     async fn resolve(self) -> Self::AsyncOutput {
600: 598:         (self.0.resolve().await,)
601: 599:     }
602: 600: 
603: 601:     fn keys(&self) -> Vec<NamedAttributeKey> {
604: 602:         self.0.keys()
605: 603:     }
606: 604: }
607: 605: 
608: 606: impl<A> NextAttribute for (A,)
609: 607: where
610: 608:     A: Attribute,
611: 609: {
612: 610:     next_attr_output_type!(A, NewAttr);
613: 611: 
614: 612:     fn add_any_attr<NewAttr: Attribute>(
615: 613:         self,
616: 614:         new_attr: NewAttr,
617: 615:     ) -> Self::Output<NewAttr> {
618: 616:         next_attr_combine!(self.0, new_attr)
619: 617:     }
620: 618: }
621: 619: 
622: 620: impl_attr_for_tuples!(A, B);
623: 621: impl_attr_for_tuples!(A, B, C);
624: 622: impl_attr_for_tuples!(A, B, C, D);
625: 623: impl_attr_for_tuples!(A, B, C, D, E);
626: 624: impl_attr_for_tuples!(A, B, C, D, E, F);
627: 625: impl_attr_for_tuples!(A, B, C, D, E, F, G);
628: 626: impl_attr_for_tuples!(A, B, C, D, E, F, G, H);
629: 627: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I);
630: 628: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J);
631: 629: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K);
632: 630: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L);
633: 631: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M);
634: 632: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N);
635: 633: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O);
636: 634: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
637: 635: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q);
638: 636: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R);
639: 637: impl_attr_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S);
640: 638: impl_attr_for_tuples!(
641: 639:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T
642: 640: );
643: 641: impl_attr_for_tuples!(
644: 642:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U
645: 643: );
646: 644: impl_attr_for_tuples!(
647: 645:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V
648: 646: );
649: 647: impl_attr_for_tuples!(
650: 648:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W
651: 649: );
652: 650: impl_attr_for_tuples!(
653: 651:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X
654: 652: );
655: 653: impl_attr_for_tuples!(
656: 654:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y
657: 655: );
658: 656: impl_attr_for_tuples_truncate_additional!(
659: 657:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y,
660: 658:     Z
661: 659: );
662: 660: ```
663: 661: ```
664: 662: ```
665: 663: ```
666: 664: ```
667: 665: ```
668: 666: ```
669: 667: ```
670: ```
```
