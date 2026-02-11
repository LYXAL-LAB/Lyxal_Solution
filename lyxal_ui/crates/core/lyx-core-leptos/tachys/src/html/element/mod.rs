### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\element\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\mod.rs
18: 16: ```rust
19: 17: #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
20: 18: use crate::hydration::set_currently_hydrating;
21: 19: #[cfg(erase_components)]
22: 20: use crate::view::any_view::AnyView;
23: 21: use crate::{
24: 22:     html::attribute::Attribute,
25: 23:     hydration::{failed_to_cast_element, Cursor},
26: 24:     renderer::{CastFrom, Rndr},
27: 25:     ssr::StreamBuilder,
28: 26:     view::{
29: 27:         add_attr::AddAnyAttr, IntoRender, Mountable, Position, PositionState,
30: 28:         Render, RenderHtml, ToTemplate,
31: 29:     },
32: 30: };
33: 31: use lyx-core-lyx_core_lyx-core-lyx_core_const_str_slice_concat::{
34: 32:     const_concat, const_concat_with_prefix, str_from_buffer,
35: 33: };
36: 34: use futures::future::join;
37: 35: use std::ops::Deref;
38: 36: 
39: 37: mod custom;
40: 38: mod element_ext;
41: 39: mod elements;
42: 40: mod inner_html;
43: 41: use super::attribute::{
44: 42:     any_attribute::AnyAttribute, escape_attr, NextAttribute,
45: 43: };
46: 44: pub use custom::*;
47: 45: pub use element_ext::*;
48: 46: pub use elements::*;
49: 47: pub use inner_html::*;
50: 48: #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
51: 49: use std::panic::Location;
52: 50: 
53: 51: /// The typed representation of an HTML element.
54: 52: #[derive(Debug, PartialEq, Eq)]
55: 53: pub struct HtmlElement<E, At, Ch> {
56: 54:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
57: 55:     pub(crate) defined_at: &'static Location<'static>,
58: 56:     pub(crate) tag: E,
59: 57:     pub(crate) attributes: At,
60: 58:     pub(crate) children: Ch,
61: 59: }
62: 60: 
63: 61: impl<E: Clone, At: Clone, Ch: Clone> Clone for HtmlElement<E, At, Ch> {
64: 62:     fn clone(&self) -> Self {
65: 63:         HtmlElement {
66: 64:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
67: 65:             defined_at: self.defined_at,
68: 66:             tag: self.tag.clone(),
69: 67:             attributes: self.attributes.clone(),
70: 68:             children: self.children.clone(),
71: 69:         }
72: 70:     }
73: 71: }
74: 72: 
75: 73: impl<E: Copy, At: Copy, Ch: Copy> Copy for HtmlElement<E, At, Ch> {}
76: 74: 
77: 75: /*impl<E, At, Ch> ElementType for HtmlElement<E, At, Ch>
78: 76: where
79: 77:     E: ElementType,
80: 78: {
81: 79:     type Output = E::Output;
82: 80: 
83: 81:     const TAG: &'static str = E::TAG;
84: 82: 
85: 83:     const SELF_CLOSING: bool = E::SELF_CLOSING;
86: 84: 
87: 85:     fn tag(&self) -> &str {
88: 86:         Self::TAG
89: 87:     }
90: 88: }*/
91: 89: 
92: 90: #[cfg(not(erase_components))]
93: 91: impl<E, At, Ch, NewChild> ElementChild<NewChild> for HtmlElement<E, At, Ch>
94: 92: where
95: 93:     E: ElementWithChildren,
96: 94:     Ch: RenderHtml + lyx-core-lyx_core_lyx-core-lyx_core_next_tuple::NextTuple,
97: 95:     <Ch as lyx-core-lyx_core_lyx-core-lyx_core_next_tuple::NextTuple>::Output<NewChild::Output>: Render,
98: 96: 
99: 97:     NewChild: IntoRender,
100: 98:     NewChild::Output: RenderHtml,
101: 99: {
102: 100:     type Output = HtmlElement<
103: 101:         E,
104: 102:         At,
105: 103:         <Ch as lyx-core-lyx_core_lyx-core-lyx_core_next_tuple::NextTuple>::Output<NewChild::Output>,
106: 104:     >;
107: 105: 
108: 106:     fn child(self, child: NewChild) -> Self::Output {
109: 107:         HtmlElement {
110: 108:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
111: 109:             defined_at: self.defined_at,
112: 110:             tag: self.tag,
113: 111:             attributes: self.attributes,
114: 112:             children: self.children.lyx-core-lyx_core_lyx-core-lyx_core_next_tuple(child.into_render()),
115: 113:         }
116: 114:     }
117: 115: }
118: 116: 
119: 117: #[cfg(erase_components)]
120: 118: impl<E, At, Ch, NewChild> ElementChild<NewChild> for HtmlElement<E, At, Ch>
121: 119: where
122: 120:     E: ElementWithChildren,
123: 121:     Ch: RenderHtml + NextChildren,
124: 122: 
125: 123:     NewChild: IntoRender,
126: 124:     NewChild::Output: RenderHtml,
127: 125: {
128: 126:     type Output =
129: 127:         HtmlElement<E, At, crate::view::iterators::StaticVec<AnyView>>;
130: 128: 
131: 129:     fn child(self, child: NewChild) -> Self::Output {
132: 130:         use crate::view::any_view::IntoAny;
133: 131: 
134: 132:         HtmlElement {
135: 133:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
136: 134:             defined_at: self.defined_at,
137: 135:             tag: self.tag,
138: 136:             attributes: self.attributes,
139: 137:             children: self
140: 138:                 .children
141: 139:                 .next_children(child.into_render().into_any()),
142: 140:         }
143: 141:     }
144: 142: }
145: 143: 
146: 144: #[cfg(erase_components)]
147: 145: trait NextChildren {
148: 146:     fn next_children(
149: 147:         self,
150: 148:         child: AnyView,
151: 149:     ) -> crate::view::iterators::StaticVec<AnyView>;
152: 150: }
153: 151: 
154: 152: #[cfg(erase_components)]
155: 153: mod erased_tuples {
156: 154:     use super::*;
157: 155:     use crate::view::{any_view::IntoAny, iterators::StaticVec};
158: 156: 
159: 157:     impl NextChildren for StaticVec<AnyView> {
160: 158:         fn next_children(mut self, child: AnyView) -> StaticVec<AnyView> {
161: 159:             self.0.push(child);
162: 160:             self
163: 161:         }
164: 162:     }
165: 163: 
166: 164:     impl NextChildren for () {
167: 165:         fn next_children(self, child: AnyView) -> StaticVec<AnyView> {
168: 166:             vec![child].into()
169: 167:         }
170: 168:     }
171: 169: 
172: 170:     impl<T: RenderHtml> NextChildren for (T,) {
173: 171:         fn next_children(self, child: AnyView) -> StaticVec<AnyView> {
174: 172:             vec![self.0.into_owned().into_any(), child].into()
175: 173:         }
176: 174:     }
177: 175: 
178: 176:     macro_rules! impl_next_children_tuples {
179: 177:         ($($ty:ident),*) => {
180: 178:             impl<$($ty: RenderHtml),*> NextChildren for ($($ty,)*)
181: 179:              {
182: 180:                 fn next_children(
183: 181:                     self, child: AnyView,
184: 182:                 ) -> StaticVec<AnyView> {
185: 183:                     #[allow(non_snake_case)]
186: 184:                     let ($($ty,)*) = self;
187: 185:                     vec![$($ty.into_owned().into_any(),)* child].into()
188: 186:                 }
189: 187:             }
190: 188:         };
191: 189:     }
192: 190: 
193: 191:     impl_next_children_tuples!(AA, BB);
194: 192:     impl_next_children_tuples!(AA, BB, CC);
195: 193:     impl_next_children_tuples!(AA, BB, CC, DD);
196: 194:     impl_next_children_tuples!(AA, BB, CC, DD, EE);
197: 195:     impl_next_children_tuples!(AA, BB, CC, DD, EE, FF);
198: 196:     impl_next_children_tuples!(AA, BB, CC, DD, EE, FF, GG);
199: 197:     impl_next_children_tuples!(AA, BB, CC, DD, EE, FF, GG, HH);
200: 198:     impl_next_children_tuples!(AA, BB, CC, DD, EE, FF, GG, HH, II);
201: 199:     impl_next_children_tuples!(AA, BB, CC, DD, EE, FF, GG, HH, II, JJ);
202: 200:     impl_next_children_tuples!(AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK);
203: 201:     impl_next_children_tuples!(AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL);
204: 202:     impl_next_children_tuples!(
205: 203:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM
206: 204:     );
207: 205:     impl_next_children_tuples!(
208: 206:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN
209: 207:     );
210: 208:     impl_next_children_tuples!(
211: 209:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO
212: 210:     );
213: 211:     impl_next_children_tuples!(
214: 212:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP
215: 213:     );
216: 214:     impl_next_children_tuples!(
217: 215:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ
218: 216:     );
219: 217:     impl_next_children_tuples!(
220: 218:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR
221: 219:     );
222: 220:     impl_next_children_tuples!(
223: 221:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR,
224: 222:         SS
225: 223:     );
226: 224:     impl_next_children_tuples!(
227: 225:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR,
228: 226:         SS, TT
229: 227:     );
230: 228:     impl_next_children_tuples!(
231: 229:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR,
232: 230:         SS, TT, UU
233: 231:     );
234: 232:     impl_next_children_tuples!(
235: 233:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR,
236: 234:         SS, TT, UU, VV
237: 235:     );
238: 236:     impl_next_children_tuples!(
239: 237:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR,
240: 238:         SS, TT, UU, VV, WW
241: 239:     );
242: 240:     impl_next_children_tuples!(
243: 241:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR,
244: 242:         SS, TT, UU, VV, WW, XX
245: 243:     );
246: 244:     impl_next_children_tuples!(
247: 245:         AA, BB, CC, DD, EE, FF, GG, HH, II, JJ, KK, LL, MM, NN, OO, PP, QQ, RR,
248: 246:         SS, TT, UU, VV, WW, XX, YY
249: 247:     );
250: 248: }
251: 249: 
252: 250: impl<E, At, Ch> AddAnyAttr for HtmlElement<E, At, Ch>
253: 251: where
254: 252:     E: ElementType + Send,
255: 253:     At: Attribute + Send,
256: 254:     Ch: RenderHtml + Send,
257: 255: {
258: 256:     type Output<SomeNewAttr: Attribute> =
259: 257:         HtmlElement<E, <At as NextAttribute>::Output<SomeNewAttr>, Ch>;
260: 258: 
261: 259:     fn add_any_attr<NewAttr: Attribute>(
262: 260:         self,
263: 261:         attr: NewAttr,
264: 262:     ) -> Self::Output<NewAttr> {
265: 263:         let HtmlElement {
266: 264:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
267: 265:             defined_at,
268: 266:             tag,
269: 267:             attributes,
270: 268:             children,
271: 269:         } = self;
272: 270:         HtmlElement {
273: 271:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
274: 272:             defined_at,
275: 273:             tag,
276: 274:             attributes: attributes.add_any_attr(attr),
277: 275:             children,
278: 276:         }
279: 277:     }
280: 278: }
281: 279: 
282: 280: /// Adds a child to the element.
283: 281: pub trait ElementChild<NewChild>
284: 282: where
285: 283:     NewChild: IntoRender,
286: 284: {
287: 285:     /// The type of the element, with the child added.
288: 286:     type Output;
289: 287: 
290: 288:     /// Adds a child to an element.
291: 289:     fn child(self, child: NewChild) -> Self::Output;
292: 290: }
293: 291: 
294: 292: /// An HTML element.
295: 293: pub trait ElementType: Send + 'static {
296: 294:     /// The underlying native widget type that this represents.
297: 295:     type Output;
298: 296: 
299: 297:     /// The element's tag.
300: 298:     const TAG: &'static str;
301: 299:     /// Whether the element is self-closing.
302: 300:     const SELF_CLOSING: bool;
303: 301:     /// Whether the element's children should be escaped. This should be `true` except for elements
304: 302:     /// like `<style>` and `<script>`, which include other languages that should not use HTML
305: 303:     /// entity escaping.
306: 304:     const ESCAPE_CHILDREN: bool;
307: 305:     /// The element's namespace, if it is not HTML.
308: 306:     const NAMESPACE: Option<&'static str>;
309: 307: 
310: 308:     /// The element's tag.
311: 309:     fn tag(&self) -> &str;
312: 310: }
313: 311: 
314: 312: /// Denotes that the type that implements this has a particular HTML element type.
315: 313: pub trait HasElementType {
316: 314:     /// The element type.
317: 315:     type ElementType;
318: 316: }
319: 317: 
320: 318: pub(crate) trait ElementWithChildren {}
321: 319: 
322: 320: impl<E, At, Ch> HasElementType for HtmlElement<E, At, Ch>
323: 321: where
324: 322:     E: ElementType,
325: 323: {
326: 324:     type ElementType = E::Output;
327: 325: }
328: 326: 
329: 327: impl<E, At, Ch> Render for HtmlElement<E, At, Ch>
330: 328: where
331: 329:     E: ElementType,
332: 330:     At: Attribute,
333: 331:     Ch: Render,
334: 332: {
335: 333:     type State = ElementState<At::State, Ch::State>;
336: 334: 
337: 335:     fn rebuild(self, state: &mut Self::State) {
338: 336:         // check whether the tag is the same, for custom elements
339: 337:         // because this is const `false` for all other element types,
340: 338:         // the compiler should be able to optimize it out
341: 339:         if E::TAG.is_empty() {
342: 340:             // see https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/4412
343: 341:             let new_tag = self.tag.tag();
344: 342: 
345: 343:             // this is not particularly efficient, but it saves us from
346: 344:             // having to keep track of the tag name for every element state
347: 345:             let old_tag = state.el.tag_name();
348: 346:             if new_tag != old_tag {
349: 347:                 let mut new_state = self.build();
350: 348:                 state.insert_before_this(&mut new_state);
351: 349:                 state.unmount();
352: 350:                 *state = new_state;
353: 351:                 return;
354: 352:             }
355: 353:         }
356: 354: 
357: 355:         // rebuild attributes and children for any element
358: 356:         let ElementState {
359: 357:             attrs, children, ..
360: 358:         } = state;
361: 359:         self.attributes.rebuild(attrs);
362: 360:         if let Some(children) = children {
363: 361:             self.children.rebuild(children);
364: 362:         }
365: 363:     }
366: 364: 
367: 365:     fn build(self) -> Self::State {
368: 366:         let el = Rndr::create_element(self.tag.tag(), E::NAMESPACE);
369: 367: 
370: 368:         let attrs = self.attributes.build(&el);
371: 369: 
372: 370:         let children = if E::SELF_CLOSING {
373: 371:             None
374: 372:         } else {
375: 373:             let mut children = self.children.build();
376: 374:             children.mount(&el, None);
377: 375:             Some(children)
378: 376:         };
379: 377: 
380: 378:         ElementState {
381: 379:             el,
382: 380:             attrs,
383: 381:             children,
384: 382:         }
385: 383:     }
386: 384: }
387: 385: 
388: 386: impl<E, At, Ch> RenderHtml for HtmlElement<E, At, Ch>
389: 387: where
390: 388:     E: ElementType + Send,
391: 389:     At: Attribute + Send,
392: 390:     Ch: RenderHtml + Send,
393: 391: {
394: 392:     type AsyncOutput = HtmlElement<E, At::AsyncOutput, Ch::AsyncOutput>;
395: 393:     type Owned = HtmlElement<E, At::CloneableOwned, Ch::Owned>;
396: 394: 
397: 395:     const MIN_LENGTH: usize = if E::SELF_CLOSING {
398: 396:         3 // < ... />
399: 397:         + E::TAG.len()
400: 398:         + At::MIN_LENGTH
401: 399:     } else {
402: 400:         2 // < ... >
403: 401:         + E::TAG.len()
404: 402:         + At::MIN_LENGTH
405: 403:         + Ch::MIN_LENGTH
406: 404:         + 3 // </ ... >
407: 405:         + E::TAG.len()
408: 406:     };
409: 407: 
410: 408:     fn dry_resolve(&mut self) {
411: 409:         self.attributes.dry_resolve();
412: 410:         self.children.dry_resolve();
413: 411:     }
414: 412: 
415: 413:     async fn resolve(self) -> Self::AsyncOutput {
416: 414:         let (attributes, children) =
417: 415:             join(self.attributes.resolve(), self.children.resolve()).await;
418: 416:         HtmlElement {
419: 417:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
420: 418:             defined_at: self.defined_at,
421: 419:             tag: self.tag,
422: 420:             attributes,
423: 421:             children,
424: 422:         }
425: 423:     }
426: 424: 
427: 425:     fn html_len(&self) -> usize {
428: 426:         if E::SELF_CLOSING {
429: 427:             3 // < ... />
430: 428:         + E::TAG.len()
431: 429:         + self.attributes.html_len()
432: 430:         } else {
433: 431:             2 // < ... >
434: 432:         + E::TAG.len()
435: 433:         + self.attributes.html_len()
436: 434:         + self.children.html_len()
437: 435:         + 3 // </ ... >
438: 436:         + E::TAG.len()
439: 437:         }
440: 438:     }
441: 439: 
442: 440:     fn to_html_with_buf(
443: 441:         self,
444: 442:         buf: &mut String,
445: 443:         position: &mut Position,
446: 444:         _escape: bool,
447: 445:         mark_branches: bool,
448: 446:         extra_attributes: Vec<AnyAttribute>,
449: 447:     ) {
450: 448:         // opening tag
451: 449:         buf.push('<');
452: 450:         buf.push_str(self.tag.tag());
453: 451: 
454: 452:         let inner_html =
455: 453:             attributes_to_html((self.attributes, extra_attributes), buf);
456: 454: 
457: 455:         buf.push('>');
458: 456: 
459: 457:         if !E::SELF_CLOSING {
460: 458:             if !inner_html.is_empty() {
461: 459:                 buf.push_str(&inner_html);
462: 460:             } else if Ch::EXISTS {
463: 461:                 // children
464: 462:                 *position = Position::FirstChild;
465: 463:                 self.children.to_html_with_buf(
466: 464:                     buf,
467: 465:                     position,
468: 466:                     E::ESCAPE_CHILDREN,
469: 467:                     mark_branches,
470: 468:                     vec![],
471: 469:                 );
472: 470:             }
473: 471: 
474: 472:             // closing tag
475: 473:             buf.push_str("</");
476: 474:             buf.push_str(self.tag.tag());
477: 475:             buf.push('>');
478: 476:         }
479: 477:         *position = Position::NextChild;
480: 478:     }
481: 479: 
482: 480:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
483: 481:         self,
484: 482:         buffer: &mut StreamBuilder,
485: 483:         position: &mut Position,
486: 484:         _escape: bool,
487: 485:         mark_branches: bool,
488: 486:         extra_attributes: Vec<AnyAttribute>,
489: 487:     ) where
490: 488:         Self: Sized,
491: 489:     {
492: 490:         let mut buf = String::with_capacity(Self::MIN_LENGTH);
493: 491:         // opening tag
494: 492:         buf.push('<');
495: 493:         buf.push_str(self.tag.tag());
496: 494: 
497: 495:         let inner_html =
498: 496:             attributes_to_html((self.attributes, extra_attributes), &mut buf);
499: 497: 
500: 498:         buf.push('>');
501: 499:         buffer.push_sync(&buf);
502: 500: 
503: 501:         if !E::SELF_CLOSING {
504: 502:             // children
505: 503:             *position = Position::FirstChild;
506: 504:             if !inner_html.is_empty() {
507: 505:                 buffer.push_sync(&inner_html);
508: 506:             } else if Ch::EXISTS {
509: 507:                 self.children.to_html_async_with_buf::<OUT_OF_ORDER>(
510: 508:                     buffer,
511: 509:                     position,
512: 510:                     E::ESCAPE_CHILDREN,
513: 511:                     mark_branches,
514: 512:                     vec![],
515: 513:                 );
516: 514:             }
517: 515: 
518: 516:             // closing tag
519: 517:             let mut buf = String::with_capacity(3 + E::TAG.len());
520: 518:             buf.push_str("</");
521: 519:             buf.push_str(self.tag.tag());
522: 520:             buf.push('>');
523: 521:             buffer.push_sync(&buf);
524: 522:         }
525: 523:         *position = Position::NextChild;
526: 524:     }
527: 525: 
528: 526:     fn hydrate<const FROM_SERVER: bool>(
529: 527:         self,
530: 528:         cursor: &Cursor,
531: 529:         position: &PositionState,
532: 530:     ) -> Self::State {
533: 531:         // non-Static custom elements need special support in templates
534: 532:         // because they haven't been inserted type-wise
535: 533:         if E::TAG.is_empty() && !FROM_SERVER {
536: 534:             panic!("Custom elements are not supported in ViewTemplate.");
537: 535:         }
538: 536: 
539: 537:         // codegen optimisation:
540: 538:         fn inner_1(
541: 539:             cursor: &Cursor,
542: 540:             position: &PositionState,
543: 541:             tag_name: &str,
544: 542:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
545: 543:             defined_at: &'static std::panic::Location<'static>,
546: 544:         ) -> crate::renderer::types::Element {
547: 545:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
548: 546:             {
549: 547:                 set_currently_hydrating(Some(defined_at));
550: 548:             }
551: 549: 
552: 550:             let curr_position = position.get();
553: 551:             if curr_position == Position::FirstChild {
554: 552:                 cursor.child();
555: 553:             } else if curr_position != Position::Current {
556: 554:                 cursor.sibling();
557: 555:             }
558: 556:             crate::renderer::types::Element::cast_from(cursor.current())
559: 557:                 .unwrap_or_else(|| {
560: 558:                     failed_to_cast_element(tag_name, cursor.current())
561: 559:                 })
562: 560:         }
563: 561:         let el = inner_1(
564: 562:             cursor,
565: 563:             position,
566: 564:             E::TAG,
567: 565:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
568: 566:             self.defined_at,
569: 567:         );
570: 568: 
571: 569:         let attrs = self.attributes.hydrate::<FROM_SERVER>(&el);
572: 570: 
573: 571:         // hydrate children
574: 572:         let children = if !Ch::EXISTS || !E::ESCAPE_CHILDREN {
575: 573:             None
576: 574:         } else {
577: 575:             position.set(Position::FirstChild);
578: 576:             Some(self.children.hydrate::<FROM_SERVER>(cursor, position))
579: 577:         };
580: 578: 
581: 579:         // codegen optimisation:
582: 580:         fn inner_2(
583: 581:             cursor: &Cursor,
584: 582:             position: &PositionState,
585: 583:             el: &crate::renderer::types::Element,
586: 584:         ) {
587: 585:             // go to next sibling
588: 586:             cursor.set(
589: 587:                 <crate::renderer::types::Element as AsRef<
590: 588:                     crate::renderer::types::Node,
591: 589:                 >>::as_ref(el)
592: 590:                 .clone(),
593: 591:             );
594: 592:             position.set(Position::NextChild);
595: 593:         }
596: 594:         inner_2(cursor, position, &el);
597: 595: 
598: 596:         ElementState {
599: 597:             el,
600: 598:             attrs,
601: 599:             children,
602: 600:         }
603: 601:     }
604: 602: 
605: 603:     async fn hydrate_async(
606: 604:         self,
607: 605:         cursor: &Cursor,
608: 606:         position: &PositionState,
609: 607:     ) -> Self::State {
610: 608:         // codegen optimisation:
611: 609:         fn inner_1(
612: 610:             cursor: &Cursor,
613: 611:             position: &PositionState,
614: 612:             tag_name: &str,
615: 613:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
616: 614:             defined_at: &'static std::panic::Location<'static>,
617: 615:         ) -> crate::renderer::types::Element {
618: 616:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
619: 617:             {
620: 618:                 set_currently_hydrating(Some(defined_at));
621: 619:             }
622: 620: 
623: 621:             let curr_position = position.get();
624: 622:             if curr_position == Position::FirstChild {
625: 623:                 cursor.child();
626: 624:             } else if curr_position != Position::Current {
627: 625:                 cursor.sibling();
628: 626:             }
629: 627:             crate::renderer::types::Element::cast_from(cursor.current())
630: 628:                 .unwrap_or_else(|| {
631: 629:                     failed_to_cast_element(tag_name, cursor.current())
632: 630:                 })
633: 631:         }
634: 632:         let el = inner_1(
635: 633:             cursor,
636: 634:             position,
637: 635:             E::TAG,
638: 636:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
639: 637:             self.defined_at,
640: 638:         );
641: 639: 
642: 640:         let attrs = self.attributes.hydrate::<true>(&el);
643: 641: 
644: 642:         // hydrate children
645: 643:         let children = if !Ch::EXISTS || !E::ESCAPE_CHILDREN {
646: 644:             None
647: 645:         } else {
648: 646:             position.set(Position::FirstChild);
649: 647:             Some(self.children.hydrate_async(cursor, position).await)
650: 648:         };
651: 649: 
652: 650:         // codegen optimisation:
653: 651:         fn inner_2(
654: 652:             cursor: &Cursor,
655: 653:             position: &PositionState,
656: 654:             el: &crate::renderer::types::Element,
657: 655:         ) {
658: 656:             // go to next sibling
659: 657:             cursor.set(
660: 658:                 <crate::renderer::types::Element as AsRef<
661: 659:                     crate::renderer::types::Node,
662: 660:                 >>::as_ref(el)
663: 661:                 .clone(),
664: 662:             );
665: 663:             position.set(Position::NextChild);
666: 664:         }
667: 665:         inner_2(cursor, position, &el);
668: 666: 
669: 667:         ElementState {
670: 668:             el,
671: 669:             attrs,
672: 670:             children,
673: 671:         }
674: 672:     }
675: 673: 
676: 674:     fn into_owned(self) -> Self::Owned {
677: 675:         HtmlElement {
678: 676:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
679: 677:             defined_at: self.defined_at,
680: 678:             tag: self.tag,
681: 679:             attributes: self.attributes.into_cloneable_owned(),
682: 680:             children: self.children.into_owned(),
683: 681:         }
684: 682:     }
685: 683: }
686: 684: 
687: 685: /// Renders an [`Attribute`] (which can be one or more HTML attributes) into an HTML buffer.
688: 686: pub fn attributes_to_html<At>(attr: At, buf: &mut String) -> String
689: 687: where
690: 688:     At: Attribute,
691: 689: {
692: 690:     // `class` and `style` are created first, and pushed later
693: 691:     // this is because they can be filled by a mixture of values that include
694: 692:     // either the whole value (`class="..."` or `style="..."`) and individual
695: 693:     // classes and styles (`class:foo=true` or `style:height="40px"`), so they
696: 694:     // need to be filled during the whole attribute-creation process and then
697: 695:     // added
698: 696: 
699: 697:     // String doesn't allocate until the first push, so this is cheap if there
700: 698:     // is no class or style on an element
701: 699:     let mut class = String::new();
702: 700:     let mut style = String::new();
703: 701:     let mut inner_html = String::new();
704: 702: 
705: 703:     // inject regular attributes, and fill class and style
706: 704:     attr.to_html(buf, &mut class, &mut style, &mut inner_html);
707: 705: 
708: 706:     if !class.is_empty() {
709: 707:         buf.push(' ');
710: 708:         buf.push_str("class=\"");
711: 709:         buf.push_str(&escape_attr(class.trim_start().trim_end()));
712: 710:         buf.push('"');
713: 711:     }
714: 712:     if !style.is_empty() {
715: 713:         buf.push(' ');
716: 714:         buf.push_str("style=\"");
717: 715:         buf.push_str(&escape_attr(style.trim_start().trim_end()));
718: 716:         buf.push('"');
719: 717:     }
720: 718: 
721: 719:     inner_html
722: 720: }
723: 721: 
724: 722: /// The retained view state for an HTML element.
725: 723: pub struct ElementState<At, Ch> {
726: 724:     pub(crate) el: crate::renderer::types::Element,
727: 725:     pub(crate) attrs: At,
728: 726:     pub(crate) children: Option<Ch>,
729: 727: }
730: 728: 
731: 729: impl<At, Ch> Deref for ElementState<At, Ch> {
732: 730:     type Target = crate::renderer::types::Element;
733: 731: 
734: 732:     fn deref(&self) -> &Self::Target {
735: 733:         &self.el
736: 734:     }
737: 735: }
738: 736: 
739: 737: impl<At, Ch> Mountable for ElementState<At, Ch> {
740: 738:     fn unmount(&mut self) {
741: 739:         Rndr::remove(&self.el);
742: 740:     }
743: 741: 
744: 742:     fn mount(
745: 743:         &mut self,
746: 744:         parent: &crate::renderer::types::Element,
747: 745:         marker: Option<&crate::renderer::types::Node>,
748: 746:     ) {
749: 747:         Rndr::insert_node(parent, &self.el, marker);
750: 748:     }
751: 749: 
752: 750:     fn try_mount(
753: 751:         &mut self,
754: 752:         parent: &crate::renderer::types::Element,
755: 753:         marker: Option<&crate::renderer::types::Node>,
756: 754:     ) -> bool {
757: 755:         Rndr::try_insert_node(parent, &self.el, marker)
758: 756:     }
759: 757: 
760: 758:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
761: 759:         // codegen optimisation:
762: 760:         fn inner(
763: 761:             element: &crate::renderer::types::Element,
764: 762:             child: &mut dyn Mountable,
765: 763:         ) -> bool {
766: 764:             if let Some(parent) = Rndr::get_parent(element)
767: 765:                 .and_then(crate::renderer::types::Element::cast_from)
768: 766:             {
769: 767:                 child.mount(&parent, Some(element));
770: 768:                 true
771: 769:             } else {
772: 770:                 false
773: 771:             }
774: 772:         }
775: 773:         inner(&self.el, child)
776: 774:     }
777: 775: 
778: 776:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
779: 777:         // codegen optimisation:
780: 778:         fn inner(
781: 779:             element: &crate::renderer::types::Element,
782: 780:         ) -> Vec<crate::renderer::types::Element> {
783: 781:             vec![element.clone()]
784: 782:         }
785: 783:         inner(&self.el)
786: 784:     }
787: 785: }
788: 786: 
789: 787: impl<E, At, Ch> ToTemplate for HtmlElement<E, At, Ch>
790: 788: where
791: 789:     E: ElementType,
792: 790:     At: Attribute + ToTemplate,
793: 791:     Ch: Render + ToTemplate,
794: 792: {
795: 793:     const TEMPLATE: &'static str = str_from_buffer(&const_concat(&[
796: 794:         "<",
797: 795:         E::TAG,
798: 796:         At::TEMPLATE,
799: 797:         str_from_buffer(&const_concat_with_prefix(
800: 798:             &[At::CLASS],
801: 799:             " class=\"",
802: 800:             "\"",
803: 801:         )),
804: 802:         str_from_buffer(&const_concat_with_prefix(
805: 803:             &[At::STYLE],
806: 804:             " style=\"",
807: 805:             "\"",
808: 806:         )),
809: 807:         ">",
810: 808:         Ch::TEMPLATE,
811: 809:         "</",
812: 810:         E::TAG,
813: 811:         ">",
814: 812:     ]));
815: 813: 
816: 814:     #[allow(unused)] // the variables `class` and `style` might be used, but only with `nightly` feature
817: 815:     fn to_template(
818: 816:         buf: &mut String,
819: 817:         class: &mut String,
820: 818:         style: &mut String,
821: 819:         inner_html: &mut String,
822: 820:         position: &mut Position,
823: 821:     ) {
824: 822:         // for custom elements without type known at compile time, do nothing
825: 823:         if !E::TAG.is_empty() {
826: 824:             // opening tag and attributes
827: 825:             let mut class = String::new();
828: 826:             let mut style = String::new();
829: 827:             let mut inner_html = String::new();
830: 828: 
831: 829:             buf.push('<');
832: 830:             buf.push_str(E::TAG);
833: 831:             <At as ToTemplate>::to_template_attribute(
834: 832:                 buf,
835: 833:                 &mut class,
836: 834:                 &mut style,
837: 835:                 &mut inner_html,
838: 836:                 position,
839: 837:             );
840: 838: 
841: 839:             if !class.is_empty() {
842: 840:                 buf.push(' ');
843: 841:                 buf.push_str("class=\"");
844: 842:                 buf.push_str(class.trim_start().trim_end());
845: 843:                 buf.push('"');
846: 844:             }
847: 845:             if !style.is_empty() {
848: 846:                 buf.push(' ');
849: 847:                 buf.push_str("style=\"");
850: 848:                 buf.push_str(style.trim_start().trim_end());
851: 849:                 buf.push('"');
852: 850:             }
853: 851:             buf.push('>');
854: 852: 
855: 853:             // children
856: 854:             *position = Position::FirstChild;
857: 855:             class.clear();
858: 856:             style.clear();
859: 857:             inner_html.clear();
860: 858:             Ch::to_template(
861: 859:                 buf,
862: 860:                 &mut class,
863: 861:                 &mut style,
864: 862:                 &mut inner_html,
865: 863:                 position,
866: 864:             );
867: 865: 
868: 866:             // closing tag
869: 867:             buf.push_str("</");
870: 868:             buf.push_str(E::TAG);
871: 869:             buf.push('>');
872: 870:             *position = Position::NextChild;
873: 871:         }
874: 872:     }
875: 873: }
876: 874: /*
877: 875: #[cfg(all(test, feature = "testing"))]
878: 876: mod tests {
879: 877:     #[cfg(all(feature = "nightly", rustc_nightly))]
880: 878:     use super::RenderHtml;
881: 879:     use super::{main, p, HtmlElement};
882: 880:     use crate::{
883: 881:         html::{
884: 882:             attribute::global::GlobalAttributes,
885: 883:             element::{em, ElementChild, Main},
886: 884:         },
887: 885:         renderer::mock_dom::MockDom,
888: 886:         view::Render,
889: 887:     };
890: 888: 
891: 889:     #[test]
892: 890:     fn mock_dom_creates_element() {
893: 891:         let el: HtmlElement<Main, _, _, MockDom> =
894: 892:             main().child(p().id("test").lang("en").child("Hello, world!"));
895: 893:         let el = el.build();
896: 894:         assert_eq!(
897: 895:             el.el.to_debug_html(),
898: 896:             "<main><p id=\"test\" lang=\"en\">Hello, world!</p></main>"
899: 897:         );
900: 898:     }
901: 899: 
902: 900:     #[test]
903: 901:     fn mock_dom_creates_element_with_several_children() {
904: 902:         let el: HtmlElement<Main, _, _, MockDom> = main().child(p().child((
905: 903:             "Hello, ",
906: 904:             em().child("beautiful"),
907: 905:             " world!",
908: 906:         )));
909: 907:         let el = el.build();
910: 908:         assert_eq!(
911: 909:             el.el.to_debug_html(),
912: 910:             "<main><p>Hello, <em>beautiful</em> world!</p></main>"
913: 911:         );
914: 912:     }
915: 913: 
916: 914:     #[cfg(all(feature = "nightly", rustc_nightly))]
917: 915:     #[test]
918: 916:     fn html_render_allocates_lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate_buffer() {
919: 917:         use crate::view::static_types::Static;
920: 918: 
921: 919:         let el: HtmlElement<Main, _, _, MockDom> = main().child(p().child((
922: 920:             Static::<"Hello, ">,
923: 921:             em().child(Static::<"beautiful">),
924: 922:             Static::<" world!">,
925: 923:         )));
926: 924:         let allocated_len = el.html_len();
927: 925:         let html = el.to_html();
928: 926:         assert_eq!(
929: 927:             html,
930: 928:             "<main><p>Hello, <em>beautiful</em> world!</p></main>"
931: 929:         );
932: 930:         assert_eq!(html.len(), allocated_len);
933: 931:     }
934: 932: }
935: 933:  */
936: 934: ```
937: 935: ```
938: 936: ```
939: 937: ```
940: 938: ```
941: 939: ```
942: 940: ```
943: 941: ```
944: ```
```
