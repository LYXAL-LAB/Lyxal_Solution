### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\inner_html.rs
18: 16: ```rust
19: 17: use super::{ElementWithChildren, HtmlElement};
20: 18: use crate::{
21: 19:     html::attribute::{
22: 20:         maybe_next_attr_erasure_macros::{
23: 21:             next_attr_combine, next_attr_output_type,
24: 22:         },
25: 23:         Attribute, NamedAttributeKey, NextAttribute,
26: 24:     },
27: 25:     renderer::Rndr,
28: 26:     view::add_attr::AddAnyAttr,
29: 27: };
30: 28: use std::{future::Future, sync::Arc};
31: 29: 
32: 30: /// Returns an [`Attribute`] that sets the inner HTML of an element.
33: 31: ///
34: 32: /// No children should be given to this element, as this HTML will be used instead.
35: 33: ///
36: 34: /// # Security
37: 35: /// Be very careful when using this method. Always remember to
38: 36: /// sanitize the input to avoid a cross-site scripting (XSS)
39: 37: /// vulnerability.
40: 38: #[inline(always)]
41: 39: pub fn inner_html<T>(value: T) -> InnerHtml<T>
42: 40: where
43: 41:     T: InnerHtmlValue,
44: 42: {
45: 43:     InnerHtml { value }
46: 44: }
47: 45: 
48: 46: /// Sets the inner HTML of an element.
49: 47: #[derive(Debug)]
50: 48: pub struct InnerHtml<T> {
51: 49:     value: T,
52: 50: }
53: 51: 
54: 52: impl<T> Clone for InnerHtml<T>
55: 53: where
56: 54:     T: Clone,
57: 55: {
58: 56:     fn clone(&self) -> Self {
59: 57:         Self {
60: 58:             value: self.value.clone(),
61: 59:         }
62: 60:     }
63: 61: }
64: 62: 
65: 63: impl<T> Attribute for InnerHtml<T>
66: 64: where
67: 65:     T: InnerHtmlValue,
68: 66: {
69: 67:     const MIN_LENGTH: usize = 0;
70: 68: 
71: 69:     type AsyncOutput = InnerHtml<T::AsyncOutput>;
72: 70:     type State = T::State;
73: 71:     type Cloneable = InnerHtml<T::Cloneable>;
74: 72:     type CloneableOwned = InnerHtml<T::CloneableOwned>;
75: 73: 
76: 74:     fn html_len(&self) -> usize {
77: 75:         self.value.html_len()
78: 76:     }
79: 77: 
80: 78:     fn to_html(
81: 79:         self,
82: 80:         _buf: &mut String,
83: 81:         _class: &mut String,
84: 82:         _style: &mut String,
85: 83:         inner_html: &mut String,
86: 84:     ) {
87: 85:         self.value.to_html(inner_html);
88: 86:     }
89: 87: 
90: 88:     fn hydrate<const FROM_SERVER: bool>(
91: 89:         self,
92: 90:         el: &crate::renderer::types::Element,
93: 91:     ) -> Self::State {
94: 92:         self.value.hydrate::<FROM_SERVER>(el)
95: 93:     }
96: 94: 
97: 95:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
98: 96:         self.value.build(el)
99: 97:     }
100: 98: 
101: 99:     fn rebuild(self, state: &mut Self::State) {
102: 100:         self.value.rebuild(state);
103: 101:     }
104: 102: 
105: 103:     fn into_cloneable(self) -> Self::Cloneable {
106: 104:         InnerHtml {
107: 105:             value: self.value.into_cloneable(),
108: 106:         }
109: 107:     }
110: 108: 
111: 109:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
112: 110:         InnerHtml {
113: 111:             value: self.value.into_cloneable_owned(),
114: 112:         }
115: 113:     }
116: 114: 
117: 115:     fn dry_resolve(&mut self) {
118: 116:         self.value.dry_resolve();
119: 117:     }
120: 118: 
121: 119:     async fn resolve(self) -> Self::AsyncOutput {
122: 120:         InnerHtml {
123: 121:             value: self.value.resolve().await,
124: 122:         }
125: 123:     }
126: 124: 
127: 125:     fn keys(&self) -> Vec<NamedAttributeKey> {
128: 126:         vec![NamedAttributeKey::InnerHtml]
129: 127:     }
130: 128: }
131: 129: 
132: 130: impl<T> NextAttribute for InnerHtml<T>
133: 131: where
134: 132:     T: InnerHtmlValue,
135: 133: {
136: 134:     next_attr_output_type!(Self, NewAttr);
137: 135: 
138: 136:     fn add_any_attr<NewAttr: Attribute>(
139: 137:         self,
140: 138:         new_attr: NewAttr,
141: 139:     ) -> Self::Output<NewAttr> {
142: 140:         next_attr_combine!(self, new_attr)
143: 141:     }
144: 142: }
145: 143: 
146: 144: /// Sets the inner HTML of an element.
147: 145: pub trait InnerHtmlAttribute<T>
148: 146: where
149: 147:     T: InnerHtmlValue,
150: 148: 
151: 149:     Self: Sized + AddAnyAttr,
152: 150: {
153: 151:     /// Sets the inner HTML of this element.
154: 152:     ///
155: 153:     /// No children should be given to this element, as this HTML will be used instead.
156: 154:     ///
157: 155:     /// # Security
158: 156:     /// Be very careful when using this method. Always remember to
159: 157:     /// sanitize the input to avoid a cross-site scripting (XSS)
160: 158:     /// vulnerability.
161: 159:     fn inner_html(
162: 160:         self,
163: 161:         value: T,
164: 162:     ) -> <Self as AddAnyAttr>::Output<InnerHtml<T>> {
165: 163:         self.add_any_attr(inner_html(value))
166: 164:     }
167: 165: }
168: 166: 
169: 167: impl<T, E, At> InnerHtmlAttribute<T> for HtmlElement<E, At, ()>
170: 168: where
171: 169:     Self: AddAnyAttr,
172: 170:     E: ElementWithChildren,
173: 171:     At: Attribute,
174: 172:     T: InnerHtmlValue,
175: 173: {
176: 174:     fn inner_html(
177: 175:         self,
178: 176:         value: T,
179: 177:     ) -> <Self as AddAnyAttr>::Output<InnerHtml<T>> {
180: 178:         self.add_any_attr(inner_html(value))
181: 179:     }
182: 180: }
183: 181: 
184: 182: /// A possible value for [`InnerHtml`].
185: 183: pub trait InnerHtmlValue: Send {
186: 184:     /// The type after all async data have resolved.
187: 185:     type AsyncOutput: InnerHtmlValue;
188: 186:     /// The view state retained between building and rebuilding.
189: 187:     type State;
190: 188:     /// An equivalent value that can be cloned.
191: 189:     type Cloneable: InnerHtmlValue + Clone;
192: 190:     /// An equivalent value that can be cloned and is `'static`.
193: 191:     type CloneableOwned: InnerHtmlValue + Clone + 'static;
194: 192: 
195: 193:     /// The estimated length of the HTML.
196: 194:     fn html_len(&self) -> usize;
197: 195: 
198: 196:     /// Renders the class to HTML.
199: 197:     fn to_html(self, buf: &mut String);
200: 198: 
201: 199:     /// Renders the class to HTML for a `<template>`.
202: 200:     fn to_template(buf: &mut String);
203: 201: 
204: 202:     /// Adds interactivity as necessary, given DOM nodes that were created from HTML that has
205: 203:     /// either been rendered on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, or cloned for a `<template>`.
206: 204:     fn hydrate<const FROM_SERVER: bool>(
207: 205:         self,
208: 206:         el: &crate::renderer::types::Element,
209: 207:     ) -> Self::State;
210: 208: 
211: 209:     /// Adds this class to the element during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering.
212: 210:     fn build(self, el: &crate::renderer::types::Element) -> Self::State;
213: 211: 
214: 212:     /// Updates the value.
215: 213:     fn rebuild(self, state: &mut Self::State);
216: 214: 
217: 215:     /// Converts this to a cloneable type.
218: 216:     fn into_cloneable(self) -> Self::Cloneable;
219: 217: 
220: 218:     /// Converts this to a cloneable, owned type.
221: 219:     fn into_cloneable_owned(self) -> Self::CloneableOwned;
222: 220: 
223: 221:     /// “Runs” the attribute without other side effects. For primitive types, this is a no-op. For
224: 222:     /// reactive types, this can be used to gather data about reactivity or about asynchronous data
225: 223:     /// that needs to be loaded.
226: 224:     fn dry_resolve(&mut self);
227: 225: 
228: 226:     /// “Resolves” this into a type that is not waiting for any asynchronous data.
229: 227:     fn resolve(self) -> impl Future<Output = Self::AsyncOutput> + Send;
230: 228: }
231: 229: 
232: 230: impl InnerHtmlValue for String {
233: 231:     type AsyncOutput = Self;
234: 232:     type State = (crate::renderer::types::Element, Self);
235: 233:     type Cloneable = Arc<str>;
236: 234:     type CloneableOwned = Arc<str>;
237: 235: 
238: 236:     fn html_len(&self) -> usize {
239: 237:         self.len()
240: 238:     }
241: 239: 
242: 240:     fn to_html(self, buf: &mut String) {
243: 241:         buf.push_str(&self);
244: 242:     }
245: 243: 
246: 244:     fn to_template(_buf: &mut String) {}
247: 245: 
248: 246:     fn hydrate<const FROM_SERVER: bool>(
249: 247:         self,
250: 248:         el: &crate::renderer::types::Element,
251: 249:     ) -> Self::State {
252: 250:         if !FROM_SERVER {
253: 251:             Rndr::set_inner_html(el, &self);
254: 252:         }
255: 253:         (el.clone(), self)
256: 254:     }
257: 255: 
258: 256:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
259: 257:         Rndr::set_inner_html(el, &self);
260: 258:         (el.clone(), self)
261: 259:     }
262: 260: 
263: 261:     fn rebuild(self, state: &mut Self::State) {
264: 262:         if self != state.1 {
265: 263:             Rndr::set_inner_html(&state.0, &self);
266: 264:             state.1 = self;
267: 265:         }
268: 266:     }
269: 267: 
270: 268:     fn into_cloneable(self) -> Self::Cloneable {
271: 269:         self.into()
272: 270:     }
273: 271: 
274: 272:     fn into_cloneable_owned(self) -> Self::Cloneable {
275: 273:         self.into()
276: 274:     }
277: 275: 
278: 276:     fn dry_resolve(&mut self) {}
279: 277: 
280: 278:     async fn resolve(self) -> Self::AsyncOutput {
281: 279:         self
282: 280:     }
283: 281: }
284: 282: 
285: 283: impl InnerHtmlValue for Arc<str> {
286: 284:     type AsyncOutput = Self;
287: 285:     type State = (crate::renderer::types::Element, Self);
288: 286:     type Cloneable = Self;
289: 287:     type CloneableOwned = Self;
290: 288: 
291: 289:     fn html_len(&self) -> usize {
292: 290:         self.len()
293: 291:     }
294: 292: 
295: 293:     fn to_html(self, buf: &mut String) {
296: 294:         buf.push_str(&self);
297: 295:     }
298: 296: 
299: 297:     fn to_template(_buf: &mut String) {}
300: 298: 
301: 299:     fn hydrate<const FROM_SERVER: bool>(
302: 300:         self,
303: 301:         el: &crate::renderer::types::Element,
304: 302:     ) -> Self::State {
305: 303:         if !FROM_SERVER {
306: 304:             Rndr::set_inner_html(el, &self);
307: 305:         }
308: 306:         (el.clone(), self)
309: 307:     }
310: 308: 
311: 309:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
312: 310:         Rndr::set_inner_html(el, &self);
313: 311:         (el.clone(), self)
314: 312:     }
315: 313: 
316: 314:     fn rebuild(self, state: &mut Self::State) {
317: 315:         if self != state.1 {
318: 316:             Rndr::set_inner_html(&state.0, &self);
319: 317:             state.1 = self;
320: 318:         }
321: 319:     }
322: 320: 
323: 321:     fn into_cloneable(self) -> Self::Cloneable {
324: 322:         self
325: 323:     }
326: 324: 
327: 325:     fn into_cloneable_owned(self) -> Self::Cloneable {
328: 326:         self
329: 327:     }
330: 328: 
331: 329:     fn dry_resolve(&mut self) {}
332: 330: 
333: 331:     async fn resolve(self) -> Self::AsyncOutput {
334: 332:         self
335: 333:     }
336: 334: }
337: 335: 
338: 336: impl InnerHtmlValue for &str {
339: 337:     type AsyncOutput = Self;
340: 338:     type State = (crate::renderer::types::Element, Self);
341: 339:     type Cloneable = Self;
342: 340:     type CloneableOwned = Arc<str>;
343: 341: 
344: 342:     fn html_len(&self) -> usize {
345: 343:         self.len()
346: 344:     }
347: 345: 
348: 346:     fn to_html(self, buf: &mut String) {
349: 347:         buf.push_str(self);
350: 348:     }
351: 349: 
352: 350:     fn to_template(_buf: &mut String) {}
353: 351: 
354: 352:     fn hydrate<const FROM_SERVER: bool>(
355: 353:         self,
356: 354:         el: &crate::renderer::types::Element,
357: 355:     ) -> Self::State {
358: 356:         if !FROM_SERVER {
359: 357:             Rndr::set_inner_html(el, self);
360: 358:         }
361: 359:         (el.clone(), self)
362: 360:     }
363: 361: 
364: 362:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
365: 363:         Rndr::set_inner_html(el, self);
366: 364:         (el.clone(), self)
367: 365:     }
368: 366: 
369: 367:     fn rebuild(self, state: &mut Self::State) {
370: 368:         if self != state.1 {
371: 369:             Rndr::set_inner_html(&state.0, self);
372: 370:             state.1 = self;
373: 371:         }
374: 372:     }
375: 373: 
376: 374:     fn into_cloneable(self) -> Self::Cloneable {
377: 375:         self
378: 376:     }
379: 377: 
380: 378:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
381: 379:         self.into()
382: 380:     }
383: 381: 
384: 382:     fn dry_resolve(&mut self) {}
385: 383: 
386: 384:     async fn resolve(self) -> Self::AsyncOutput {
387: 385:         self
388: 386:     }
389: 387: }
390: 388: 
391: 389: impl<T> InnerHtmlValue for Option<T>
392: 390: where
393: 391:     T: InnerHtmlValue,
394: 392: {
395: 393:     type AsyncOutput = Self;
396: 394:     type State = (crate::renderer::types::Element, Option<T::State>);
397: 395:     type Cloneable = Option<T::Cloneable>;
398: 396:     type CloneableOwned = Option<T::CloneableOwned>;
399: 397: 
400: 398:     fn html_len(&self) -> usize {
401: 399:         match self {
402: 400:             Some(i) => i.html_len(),
403: 401:             None => 0,
404: 402:         }
405: 403:     }
406: 404: 
407: 405:     fn to_html(self, buf: &mut String) {
408: 406:         if let Some(value) = self {
409: 407:             value.to_html(buf);
410: 408:         }
411: 409:     }
412: 410: 
413: 411:     fn to_template(_buf: &mut String) {}
414: 412: 
415: 413:     fn hydrate<const FROM_SERVER: bool>(
416: 414:         self,
417: 415:         el: &crate::renderer::types::Element,
418: 416:     ) -> Self::State {
419: 417:         (el.clone(), self.map(|n| n.hydrate::<FROM_SERVER>(el)))
420: 418:     }
421: 419: 
422: 420:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
423: 421:         (el.clone(), self.map(|n| n.build(el)))
424: 422:     }
425: 423: 
426: 424:     fn rebuild(self, state: &mut Self::State) {
427: 425:         let new_state = match (self, &mut state.1) {
428: 426:             (None, None) => None,
429: 427:             (None, Some(_)) => {
430: 428:                 Rndr::set_inner_html(&state.0, "");
431: 429:                 Some(None)
432: 430:             }
433: 431:             (Some(new), None) => Some(Some(new.build(&state.0))),
434: 432:             (Some(new), Some(state)) => {
435: 433:                 new.rebuild(state);
436: 434:                 None
437: 435:             }
438: 436:         };
439: 437:         if let Some(new_state) = new_state {
440: 438:             state.1 = new_state;
441: 439:         }
442: 440:     }
443: 441: 
444: 442:     fn into_cloneable(self) -> Self::Cloneable {
445: 443:         self.map(|inner| inner.into_cloneable())
446: 444:     }
447: 445: 
448: 446:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
449: 447:         self.map(|inner| inner.into_cloneable_owned())
450: 448:     }
451: 449: 
452: 450:     fn dry_resolve(&mut self) {}
453: 451: 
454: 452:     async fn resolve(self) -> Self::AsyncOutput {
455: 453:         self
456: 454:     }
457: 455: }
458: 456: ```
459: 457: ```
460: 458: ```
461: 459: ```
462: 460: ```
463: 461: ```
464: 462: ```
465: 463: ```
466: ```
```
