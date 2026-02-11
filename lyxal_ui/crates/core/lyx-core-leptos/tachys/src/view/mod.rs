### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\mod.rs
18: 16: ```rust
19: 17: use self::add_attr::AddAnyAttr;
20: 18: use crate::{
21: 19:     html::attribute::any_attribute::AnyAttribute, hydration::Cursor,
22: 20:     ssr::StreamBuilder,
23: 21: };
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
25: 23: use std::{
26: 24:     cell::RefCell,
27: 25:     future::Future,
28: 26:     rc::Rc,
29: 27:     sync::{Arc, RwLock},
30: 28: };
31: 29: 
32: 30: /// Add attributes to typed views.
33: 31: pub mod add_attr;
34: 32: /// A typed-erased view type.
35: 33: pub mod any_view;
36: 34: /// Allows choosing between one of several views.
37: 35: pub mod either;
38: 36: /// View rendering for `Result<_, _>` types.
39: 37: pub mod error_boundary;
40: 38: /// A type-erased view collection.
41: 39: pub mod fragment;
42: 40: /// View implementations for several iterable types.
43: 41: pub mod iterators;
44: 42: /// Keyed list iteration.
45: 43: pub mod keyed;
46: 44: mod primitives;
47: 45: /// Optimized types for static strings known at compile time.
48: 46: #[cfg(all(feature = "nightly", rustc_nightly))]
49: 47: pub mod static_types;
50: 48: /// View implementation for string types.
51: 49: pub mod strings;
52: 50: /// Optimizations for creating views via HTML `<template>` nodes.
53: 51: pub mod template;
54: 52: /// View implementations for tuples.
55: 53: pub mod tuples;
56: 54: 
57: 55: /// The `Render` trait allows rendering something as part of the user interface.
58: 56: pub trait Render: Sized {
59: 57:     /// The “view state” for this type, which can be retained between updates.
60: 58:     ///
61: 59:     /// For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, for a text node, `State` might be the actual DOM text node
62: 60:     /// and the previous string, to allow for diffing between updates.
63: 61:     type State: Mountable;
64: 62: 
65: 63:     /// Creates the view for the first time, without hydrating from existing HTML.
66: 64:     fn build(self) -> Self::State;
67: 65: 
68: 66:     /// Updates the view with new data.
69: 67:     fn rebuild(self, state: &mut Self::State);
70: 68: }
71: 69: 
72: 70: #[doc(hidden)]
73: 71: pub trait MarkBranch {
74: 72:     fn open_branch(&mut self, branch_id: &str);
75: 73: 
76: 74:     fn close_branch(&mut self, branch_id: &str);
77: 75: }
78: 76: 
79: 77: impl MarkBranch for String {
80: 78:     fn open_branch(&mut self, branch_id: &str) {
81: 79:         self.push_str("<!--bo-");
82: 80:         self.push_str(branch_id);
83: 81:         self.push_str("-->");
84: 82:     }
85: 83: 
86: 84:     fn close_branch(&mut self, branch_id: &str) {
87: 85:         self.push_str("<!--bc-");
88: 86:         self.push_str(branch_id);
89: 87:         self.push_str("-->");
90: 88:     }
91: 89: }
92: 90: 
93: 91: impl MarkBranch for StreamBuilder {
94: 92:     fn open_branch(&mut self, branch_id: &str) {
95: 93:         self.sync_buf.push_str("<!--bo-");
96: 94:         self.sync_buf.push_str(branch_id);
97: 95:         self.sync_buf.push_str("-->");
98: 96:     }
99: 97: 
100: 98:     fn close_branch(&mut self, branch_id: &str) {
101: 99:         self.sync_buf.push_str("<!--bc-");
102: 100:         self.sync_buf.push_str(branch_id);
103: 101:         self.sync_buf.push_str("-->");
104: 102:     }
105: 103: }
106: 104: 
107: 105: /// The `RenderHtml` trait allows rendering something to HTML, and transforming
108: 106: /// that HTML into an interactive interface.
109: 107: ///
110: 108: /// This process is traditionally called “lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendering” and “hydration.” As a
111: 109: /// metaphor, this means that the structure of the view is created on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, then
112: 110: /// “dehydrated” to HTML, sent across the network, and “rehydrated” with interactivity
113: 111: /// in the browser.
114: 112: ///
115: 113: /// However, the same process can be done entirely in the browser: for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, a view
116: 114: /// can be transformed into some HTML that is used to create a `<template>` node, which
117: 115: /// can be cloned many times and “hydrated,” which is more efficient than creating the
118: 116: /// whole view piece by piece.
119: 117: pub trait RenderHtml
120: 118: where
121: 119:     Self: Render + AddAnyAttr + Send,
122: 120: {
123: 121:     /// The type of the view after waiting for all asynchronous data to load.
124: 122:     type AsyncOutput: RenderHtml;
125: 123: 
126: 124:     /// An equivalent value that is `'static`.
127: 125:     type Owned: RenderHtml + 'static;
128: 126: 
129: 127:     /// The minimum length of HTML created when this view is rendered.
130: 128:     const MIN_LENGTH: usize;
131: 129: 
132: 130:     /// Whether this should actually exist in the DOM, if it is the child of an element.
133: 131:     const EXISTS: bool = true;
134: 132: 
135: 133:     /// “Runs” the view without other side effects. For primitive types, this is a no-op. For
136: 134:     /// reactive types, this can be used to gather data about reactivity or about asynchronous data
137: 135:     /// that needs to be loaded.
138: 136:     fn dry_resolve(&mut self);
139: 137: 
140: 138:     /// Waits for any asynchronous sections of the view to load and returns the output.
141: 139:     fn resolve(self) -> impl Future<Output = Self::AsyncOutput> + Send;
142: 140: 
143: 141:     /// An estimated length for this view, when rendered to HTML.
144: 142:     ///
145: 143:     /// This is used for calculating the string buffer size when rendering HTML. It does not need
146: 144:     /// to be precise, but should be an lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate estimate. The more accurate, the fewer
147: 145:     /// reallocations will be required and the faster lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering will be.
148: 146:     fn html_len(&self) -> usize {
149: 147:         Self::MIN_LENGTH
150: 148:     }
151: 149: 
152: 150:     /// Renders a view to an HTML string.
153: 151:     fn to_html(self) -> String
154: 152:     where
155: 153:         Self: Sized,
156: 154:     {
157: 155:         let mut buf = String::with_capacity(self.html_len());
158: 156:         self.to_html_with_buf(
159: 157:             &mut buf,
160: 158:             &mut Position::FirstChild,
161: 159:             true,
162: 160:             false,
163: 161:             vec![],
164: 162:         );
165: 163:         buf
166: 164:     }
167: 165: 
168: 166:     /// Renders a view to HTML with branch markers. This can be used to support libraries that diff
169: 167:     /// HTML pages against one another, by marking sections of the view that branch to different
170: 168:     /// types with marker comments.
171: 169:     fn to_html_branching(self) -> String
172: 170:     where
173: 171:         Self: Sized,
174: 172:     {
175: 173:         let mut buf = String::with_capacity(self.html_len());
176: 174:         self.to_html_with_buf(
177: 175:             &mut buf,
178: 176:             &mut Position::FirstChild,
179: 177:             true,
180: 178:             true,
181: 179:             vec![],
182: 180:         );
183: 181:         buf
184: 182:     }
185: 183: 
186: 184:     /// Renders a view to an in-order stream of HTML.
187: 185:     fn to_html_stream_in_order(self) -> StreamBuilder
188: 186:     where
189: 187:         Self: Sized,
190: 188:     {
191: 189:         let mut builder = StreamBuilder::with_capacity(self.html_len(), None);
192: 190:         self.to_html_async_with_buf::<false>(
193: 191:             &mut builder,
194: 192:             &mut Position::FirstChild,
195: 193:             true,
196: 194:             false,
197: 195:             vec![],
198: 196:         );
199: 197:         builder.finish()
200: 198:     }
201: 199: 
202: 200:     /// Renders a view to an in-order stream of HTML with branch markers. This can be used to support libraries that diff
203: 201:     /// HTML pages against one another, by marking sections of the view that branch to different
204: 202:     /// types with marker comments.
205: 203:     fn to_html_stream_in_order_branching(self) -> StreamBuilder
206: 204:     where
207: 205:         Self: Sized,
208: 206:     {
209: 207:         let mut builder = StreamBuilder::with_capacity(self.html_len(), None);
210: 208:         self.to_html_async_with_buf::<false>(
211: 209:             &mut builder,
212: 210:             &mut Position::FirstChild,
213: 211:             true,
214: 212:             true,
215: 213:             vec![],
216: 214:         );
217: 215:         builder.finish()
218: 216:     }
219: 217: 
220: 218:     /// Renders a view to an out-of-order stream of HTML.
221: 219:     fn to_html_stream_out_of_order(self) -> StreamBuilder
222: 220:     where
223: 221:         Self: Sized,
224: 222:     {
225: 223:         //let capacity = self.html_len();
226: 224:         let mut builder =
227: 225:             StreamBuilder::with_capacity(self.html_len(), Some(vec![0]));
228: 226: 
229: 227:         self.to_html_async_with_buf::<true>(
230: 228:             &mut builder,
231: 229:             &mut Position::FirstChild,
232: 230:             true,
233: 231:             false,
234: 232:             vec![],
235: 233:         );
236: 234:         builder.finish()
237: 235:     }
238: 236: 
239: 237:     /// Renders a view to an out-of-order stream of HTML with branch markers. This can be used to support libraries that diff
240: 238:     /// HTML pages against one another, by marking sections of the view that branch to different
241: 239:     /// types with marker comments.
242: 240:     fn to_html_stream_out_of_order_branching(self) -> StreamBuilder
243: 241:     where
244: 242:         Self: Sized,
245: 243:     {
246: 244:         let mut builder =
247: 245:             StreamBuilder::with_capacity(self.html_len(), Some(vec![0]));
248: 246: 
249: 247:         self.to_html_async_with_buf::<true>(
250: 248:             &mut builder,
251: 249:             &mut Position::FirstChild,
252: 250:             true,
253: 251:             true,
254: 252:             vec![],
255: 253:         );
256: 254:         builder.finish()
257: 255:     }
258: 256: 
259: 257:     /// Renders a view to HTML, writing it into the given buffer.
260: 258:     fn to_html_with_buf(
261: 259:         self,
262: 260:         buf: &mut String,
263: 261:         position: &mut Position,
264: 262:         escape: bool,
265: 263:         mark_branches: bool,
266: 264:         extra_attrs: Vec<AnyAttribute>,
267: 265:     );
268: 266: 
269: 267:     /// Renders a view into a buffer of (synchronous or asynchronous) HTML chunks.
270: 268:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
271: 269:         self,
272: 270:         buf: &mut StreamBuilder,
273: 271:         position: &mut Position,
274: 272:         escape: bool,
275: 273:         mark_branches: bool,
276: 274:         extra_attrs: Vec<AnyAttribute>,
277: 275:     ) where
278: 276:         Self: Sized,
279: 277:     {
280: 278:         buf.with_buf(|buf| {
281: 279:             self.to_html_with_buf(
282: 280:                 buf,
283: 281:                 position,
284: 282:                 escape,
285: 283:                 mark_branches,
286: 284:                 extra_attrs,
287: 285:             )
288: 286:         });
289: 287:     }
290: 288: 
291: 289:     /// Makes a set of DOM nodes rendered from HTML interactive.
292: 290:     ///
293: 291:     /// If `FROM_SERVER` is `true`, this HTML was rendered using [`RenderHtml::to_html`]
294: 292:     /// (e.g., during lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering ).
295: 293:     ///
296: 294:     /// If `FROM_SERVER` is `false`, the HTML was rendered using [`ToTemplate::to_template`]
297: 295:     /// (e.g., into a `<template>` element).
298: 296:     fn hydrate<const FROM_SERVER: bool>(
299: 297:         self,
300: 298:         cursor: &Cursor,
301: 299:         position: &PositionState,
302: 300:     ) -> Self::State;
303: 301: 
304: 302:     /// Asynchronously makes a set of DOM nodes rendered from HTML interactive.
305: 303:     ///
306: 304:     /// Async hydration is useful for types that may need to wait before being hydrated:
307: 305:     /// for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, lazily-loaded routes need async hydration, because the lyx-core-lyx_core_lyx-core-lyx_core_client code
308: 306:     /// may be loading asynchronously, while the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server HTML was already rendered.
309: 307:     fn hydrate_async(
310: 308:         self,
311: 309:         cursor: &Cursor,
312: 310:         position: &PositionState,
313: 311:     ) -> impl Future<Output = Self::State> {
314: 312:         async { self.hydrate::<true>(cursor, position) }
315: 313:     }
316: 314: 
317: 315:     /// Hydrates using [`RenderHtml::hydrate`], beginning at the given element.
318: 316:     fn hydrate_from<const FROM_SERVER: bool>(
319: 317:         self,
320: 318:         el: &crate::renderer::types::Element,
321: 319:     ) -> Self::State
322: 320:     where
323: 321:         Self: Sized,
324: 322:     {
325: 323:         self.hydrate_from_position::<FROM_SERVER>(el, Position::default())
326: 324:     }
327: 325: 
328: 326:     /// Hydrates using [`RenderHtml::hydrate`], beginning at the given element and position.
329: 327:     fn hydrate_from_position<const FROM_SERVER: bool>(
330: 328:         self,
331: 329:         el: &crate::renderer::types::Element,
332: 330:         position: Position,
333: 331:     ) -> Self::State
334: 332:     where
335: 333:         Self: Sized,
336: 334:     {
337: 335:         let cursor = Cursor::new(el.clone());
338: 336:         let position = PositionState::new(position);
339: 337:         self.hydrate::<FROM_SERVER>(&cursor, &position)
340: 338:     }
341: 339: 
342: 340:     /// Convert into the equivalent value that is `'static`.
343: 341:     fn into_owned(self) -> Self::Owned;
344: 342: }
345: 343: 
346: 344: /// Allows a type to be mounted to the DOM.
347: 345: pub trait Mountable {
348: 346:     /// Detaches the view from the DOM.
349: 347:     fn unmount(&mut self);
350: 348: 
351: 349:     /// Mounts a node to the interface.
352: 350:     fn mount(
353: 351:         &mut self,
354: 352:         parent: &crate::renderer::types::Element,
355: 353:         marker: Option<&crate::renderer::types::Node>,
356: 354:     );
357: 355: 
358: 356:     /// Mounts a node to the interface. Returns `false` if it could not be mounted.
359: 357:     fn try_mount(
360: 358:         &mut self,
361: 359:         parent: &crate::renderer::types::Element,
362: 360:         marker: Option<&crate::renderer::types::Node>,
363: 361:     ) -> bool {
364: 362:         self.mount(parent, marker);
365: 363:         true
366: 364:     }
367: 365: 
368: 366:     /// Inserts another `Mountable` type before this one. Returns `false` if
369: 367:     /// this does not actually exist in the UI (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, `()`).
370: 368:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool;
371: 369: 
372: 370:     /// Inserts another `Mountable` type before this one, or before the marker
373: 371:     /// if this one doesn't exist in the UI (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, `()`).
374: 372:     fn insert_before_this_or_marker(
375: 373:         &self,
376: 374:         parent: &crate::renderer::types::Element,
377: 375:         child: &mut dyn Mountable,
378: 376:         marker: Option<&crate::renderer::types::Node>,
379: 377:     ) {
380: 378:         if !self.insert_before_this(child) {
381: 379:             child.mount(parent, marker);
382: 380:         }
383: 381:     }
384: 382: 
385: 383:     /// wip
386: 384:     fn elements(&self) -> Vec<crate::renderer::types::Element>;
387: 385: }
388: 386: 
389: 387: /// Indicates where a node should be mounted to its parent.
390: 388: pub enum MountKind {
391: 389:     /// Node should be mounted before this marker node.
392: 390:     Before(crate::renderer::types::Node),
393: 391:     /// Node should be lyx-platform-lyx_platform_lyx-platform-lyx_platform_appended to the parent’s children.
394: 392:     Append,
395: 393: }
396: 394: 
397: 395: impl<T> Mountable for Option<T>
398: 396: where
399: 397:     T: Mountable,
400: 398: {
401: 399:     fn unmount(&mut self) {
402: 400:         if let Some(ref mut mounted) = self {
403: 401:             mounted.unmount()
404: 402:         }
405: 403:     }
406: 404: 
407: 405:     fn mount(
408: 406:         &mut self,
409: 407:         parent: &crate::renderer::types::Element,
410: 408:         marker: Option<&crate::renderer::types::Node>,
411: 409:     ) {
412: 410:         if let Some(ref mut inner) = self {
413: 411:             inner.mount(parent, marker);
414: 412:         }
415: 413:     }
416: 414: 
417: 415:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
418: 416:         self.as_ref()
419: 417:             .map(|inner| inner.insert_before_this(child))
420: 418:             .unwrap_or(false)
421: 419:     }
422: 420: 
423: 421:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
424: 422:         self.as_ref()
425: 423:             .map(|inner| inner.elements())
426: 424:             .unwrap_or_default()
427: 425:     }
428: 426: }
429: 427: 
430: 428: impl<T> Mountable for Rc<RefCell<T>>
431: 429: where
432: 430:     T: Mountable,
433: 431: {
434: 432:     fn unmount(&mut self) {
435: 433:         self.borrow_mut().unmount()
436: 434:     }
437: 435: 
438: 436:     fn mount(
439: 437:         &mut self,
440: 438:         parent: &crate::renderer::types::Element,
441: 439:         marker: Option<&crate::renderer::types::Node>,
442: 440:     ) {
443: 441:         self.borrow_mut().mount(parent, marker);
444: 442:     }
445: 443: 
446: 444:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
447: 445:         self.borrow().insert_before_this(child)
448: 446:     }
449: 447: 
450: 448:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
451: 449:         self.borrow().elements()
452: 450:     }
453: 451: }
454: 452: 
455: 453: /// Allows data to be added to a static template.
456: 454: pub trait ToTemplate {
457: 455:     /// The HTML content of the static template.
458: 456:     const TEMPLATE: &'static str = "";
459: 457:     /// The `class` attribute content known at compile time.
460: 458:     const CLASS: &'static str = "";
461: 459:     /// The `style` attribute content known at compile time.
462: 460:     const STYLE: &'static str = "";
463: 461:     /// The length of the template.
464: 462:     const LEN: usize = Self::TEMPLATE.len();
465: 463: 
466: 464:     /// Renders a view type to a template. This does not take actual view data,
467: 465:     /// but can be used for constructing part of an HTML `<template>` that corresponds
468: 466:     /// to a view of a particular type.
469: 467:     fn to_template(
470: 468:         buf: &mut String,
471: 469:         class: &mut String,
472: 470:         style: &mut String,
473: 471:         inner_html: &mut String,
474: 472:         position: &mut Position,
475: 473:     );
476: 474: 
477: 475:     /// Renders a view type to a template in attribute position.
478: 476:     fn to_template_attribute(
479: 477:         buf: &mut String,
480: 478:         class: &mut String,
481: 479:         style: &mut String,
482: 480:         inner_html: &mut String,
483: 481:         position: &mut Position,
484: 482:     ) {
485: 483:         Self::to_template(buf, class, style, inner_html, position);
486: 484:     }
487: 485: }
488: 486: 
489: 487: /// Keeps track of what position the item currently being hydrated is in, relative to its siblings
490: 488: /// and parents.
491: 489: #[derive(Debug, Default, Clone)]
492: 490: pub struct PositionState(Arc<RwLock<Position>>);
493: 491: 
494: 492: impl PositionState {
495: 493:     /// Creates a new position tracker.
496: 494:     pub fn new(position: Position) -> Self {
497: 495:         Self(Arc::new(RwLock::new(position)))
498: 496:     }
499: 497: 
500: 498:     /// Sets the current position.
501: 499:     pub fn set(&self, position: Position) {
502: 500:         *self.0.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = position;
503: 501:     }
504: 502: 
505: 503:     /// Gets the current position.
506: 504:     pub fn get(&self) -> Position {
507: 505:         *self.0.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
508: 506:     }
509: 507: 
510: 508:     /// Creates a new [`PositionState`], which starts with the same [`Position`], but no longer
511: 509:     /// shares data with this `PositionState`.
512: 510:     pub fn deep_clone(&self) -> Self {
513: 511:         let current = self.get();
514: 512:         Self(Arc::new(RwLock::new(current)))
515: 513:     }
516: 514: }
517: 515: 
518: 516: /// The position of this element, relative to others.
519: 517: #[derive(Debug, Copy, Clone, PartialEq, Eq, Default)]
520: 518: pub enum Position {
521: 519:     /// This is the current node.
522: 520:     Current,
523: 521:     /// This is the first child of its parent.
524: 522:     #[default]
525: 523:     FirstChild,
526: 524:     /// This is the next child after another child.
527: 525:     NextChild,
528: 526:     /// This is the next child after a text node.
529: 527:     NextChildAfterText,
530: 528:     /// This is the only child of its parent.
531: 529:     OnlyChild,
532: 530:     /// This is the last child of its parent.
533: 531:     LastChild,
534: 532: }
535: 533: 
536: 534: /// Declares that this type can be converted into some other type, which can be rendered.
537: 535: pub trait IntoRender {
538: 536:     /// The renderable type into which this type can be converted.
539: 537:     type Output;
540: 538: 
541: 539:     /// Consumes this value, transforming it into the renderable type.
542: 540:     fn into_render(self) -> Self::Output;
543: 541: }
544: 542: 
545: 543: impl<T> IntoRender for T
546: 544: where
547: 545:     T: Render,
548: 546: {
549: 547:     type Output = Self;
550: 548: 
551: 549:     fn into_render(self) -> Self::Output {
552: 550:         self
553: 551:     }
554: 552: }
555: 553: ```
556: 554: ```
557: 555: ```
558: 556: ```
559: 557: ```
560: 558: ```
561: 559: ```
562: 560: ```
563: ```
```
