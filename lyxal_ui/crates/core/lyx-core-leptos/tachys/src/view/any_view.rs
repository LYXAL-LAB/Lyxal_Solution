### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\any_view.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\any_view.rs
18: 16: ```rust
19: 17: #![allow(clippy::type_complexity)]
20: 18: #[cfg(feature = "ssr")]
21: 19: use super::MarkBranch;
22: 20: use super::{
23: 21:     add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
24: 22:     RenderHtml,
25: 23: };
26: 24: use crate::{
27: 25:     erased::{Erased, ErasedLocal},
28: 26:     html::attribute::{
29: 27:         any_attribute::{AnyAttribute, AnyAttributeState, IntoAnyAttribute},
30: 28:         Attribute,
31: 29:     },
32: 30:     hydration::Cursor,
33: 31:     renderer::Rndr,
34: 32:     ssr::StreamBuilder,
35: 33: };
36: 34: use futures::future::{join, join_all};
37: 35: use std::{any::TypeId, fmt::Debug};
38: 36: #[cfg(any(feature = "ssr", feature = "hydrate"))]
39: 37: use std::{future::Future, pin::Pin};
40: 38: 
41: 39: /// A type-erased view. This can be used if control flow requires that multiple different types of
42: 40: /// view must be received, and it is either impossible or too cumbersome to use the `EitherOf___`
43: 41: /// enums.
44: 42: ///
45: 43: /// It can also be used to create recursive components, which otherwise cannot return themselves
46: 44: /// due to the static typing of the view tree.
47: 45: ///
48: 46: /// Generally speaking, using `AnyView` restricts the amount of information available to the
49: 47: /// compiler and should be limited to situations in which it is necessary to preserve the maximum
50: 48: /// amount of type information possible.
51: 49: pub struct AnyView {
52: 50:     type_id: TypeId,
53: 51:     value: Erased,
54: 52:     build: fn(Erased) -> AnyViewState,
55: 53:     rebuild: fn(Erased, &mut AnyViewState),
56: 54:     // The fields below are cfg-gated so they will not be included in WASM bundles if not needed.
57: 55:     // Ordinarily, the compiler can simply omit this dead code because the methods are not called.
58: 56:     // With this type-erased wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper, however, the compiler is not *always* able to correctly
59: 57:     // eliminate that code.
60: 58:     #[cfg(feature = "ssr")]
61: 59:     html_len: usize,
62: 60:     #[cfg(feature = "ssr")]
63: 61:     to_html:
64: 62:         fn(Erased, &mut String, &mut Position, bool, bool, Vec<AnyAttribute>),
65: 63:     #[cfg(feature = "ssr")]
66: 64:     to_html_async: fn(
67: 65:         Erased,
68: 66:         &mut StreamBuilder,
69: 67:         &mut Position,
70: 68:         bool,
71: 69:         bool,
72: 70:         Vec<AnyAttribute>,
73: 71:     ),
74: 72:     #[cfg(feature = "ssr")]
75: 73:     to_html_async_ooo: fn(
76: 74:         Erased,
77: 75:         &mut StreamBuilder,
78: 76:         &mut Position,
79: 77:         bool,
80: 78:         bool,
81: 79:         Vec<AnyAttribute>,
82: 80:     ),
83: 81:     #[cfg(feature = "ssr")]
84: 82:     #[allow(clippy::type_complexity)]
85: 83:     resolve: fn(Erased) -> Pin<Box<dyn Future<Output = AnyView> + Send>>,
86: 84:     #[cfg(feature = "ssr")]
87: 85:     dry_resolve: fn(&mut Erased),
88: 86:     #[cfg(feature = "hydrate")]
89: 87:     #[allow(clippy::type_complexity)]
90: 88:     hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server: fn(Erased, &Cursor, &PositionState) -> AnyViewState,
91: 89:     #[cfg(feature = "hydrate")]
92: 90:     #[allow(clippy::type_complexity)]
93: 91:     hydrate_async: fn(
94: 92:         Erased,
95: 93:         &Cursor,
96: 94:         &PositionState,
97: 95:     ) -> Pin<Box<dyn Future<Output = AnyViewState>>>,
98: 96: }
99: 97: 
100: 98: impl AnyView {
101: 99:     #[doc(hidden)]
102: 100:     pub fn as_type_id(&self) -> TypeId {
103: 101:         self.type_id
104: 102:     }
105: 103: }
106: 104: 
107: 105: impl Debug for AnyView {
108: 106:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
109: 107:         f.debug_struct("AnyView")
110: 108:             .field("type_id", &self.type_id)
111: 109:             .finish_non_exhaustive()
112: 110:     }
113: 111: }
114: 112: /// Retained view state for [`AnyView`].
115: 113: pub struct AnyViewState {
116: 114:     type_id: TypeId,
117: 115:     state: ErasedLocal,
118: 116:     unmount: fn(&mut ErasedLocal),
119: 117:     mount: fn(
120: 118:         &mut ErasedLocal,
121: 119:         parent: &crate::renderer::types::Element,
122: 120:         marker: Option<&crate::renderer::types::Node>,
123: 121:     ),
124: 122:     insert_before_this: fn(&ErasedLocal, child: &mut dyn Mountable) -> bool,
125: 123:     elements: fn(&ErasedLocal) -> Vec<crate::renderer::types::Element>,
126: 124:     placeholder: Option<crate::renderer::types::Placeholder>,
127: 125: }
128: 126: 
129: 127: impl Debug for AnyViewState {
130: 128:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
131: 129:         f.debug_struct("AnyViewState")
132: 130:             .field("type_id", &self.type_id)
133: 131:             .field("state", &"")
134: 132:             .field("unmount", &self.unmount)
135: 133:             .field("mount", &self.mount)
136: 134:             .field("insert_before_this", &self.insert_before_this)
137: 135:             .finish()
138: 136:     }
139: 137: }
140: 138: 
141: 139: /// Allows converting some view into [`AnyView`].
142: 140: pub trait IntoAny {
143: 141:     /// Converts the view into a type-erased [`AnyView`].
144: 142:     fn into_any(self) -> AnyView;
145: 143: }
146: 144: 
147: 145: /// A more general version of [`IntoAny`] that allows into [`AnyView`],
148: 146: /// but also erasing other types that don't implement [`RenderHtml`] like routing.
149: 147: pub trait IntoMaybeErased {
150: 148:     /// The type of the output.
151: 149:     type Output: IntoMaybeErased;
152: 150: 
153: 151:     /// Converts the view into a type-erased view if in erased mode.
154: 152:     fn into_maybe_erased(self) -> Self::Output;
155: 153: }
156: 154: 
157: 155: impl<T> IntoMaybeErased for T
158: 156: where
159: 157:     T: RenderHtml,
160: 158: {
161: 159:     #[cfg(not(erase_components))]
162: 160:     type Output = Self;
163: 161: 
164: 162:     #[cfg(erase_components)]
165: 163:     type Output = AnyView;
166: 164: 
167: 165:     fn into_maybe_erased(self) -> Self::Output {
168: 166:         #[cfg(not(erase_components))]
169: 167:         {
170: 168:             self
171: 169:         }
172: 170:         #[cfg(erase_components)]
173: 171:         {
174: 172:             self.into_owned().into_any()
175: 173:         }
176: 174:     }
177: 175: }
178: 176: 
179: 177: fn mount_any<T>(
180: 178:     state: &mut ErasedLocal,
181: 179:     parent: &crate::renderer::types::Element,
182: 180:     marker: Option<&crate::renderer::types::Node>,
183: 181: ) where
184: 182:     T: Render,
185: 183:     T::State: 'static,
186: 184: {
187: 185:     state.get_mut::<T::State>().mount(parent, marker)
188: 186: }
189: 187: 
190: 188: fn unmount_any<T>(state: &mut ErasedLocal)
191: 189: where
192: 190:     T: Render,
193: 191:     T::State: 'static,
194: 192: {
195: 193:     state.get_mut::<T::State>().unmount();
196: 194: }
197: 195: 
198: 196: fn insert_before_this<T>(state: &ErasedLocal, child: &mut dyn Mountable) -> bool
199: 197: where
200: 198:     T: Render,
201: 199:     T::State: 'static,
202: 200: {
203: 201:     state.get_ref::<T::State>().insert_before_this(child)
204: 202: }
205: 203: 
206: 204: fn elements<T>(state: &ErasedLocal) -> Vec<crate::renderer::types::Element>
207: 205: where
208: 206:     T: Render,
209: 207:     T::State: 'static,
210: 208: {
211: 209:     state.get_ref::<T::State>().elements()
212: 210: }
213: 211: 
214: 212: impl<T> IntoAny for T
215: 213: where
216: 214:     T: Send,
217: 215:     T: RenderHtml,
218: 216: {
219: 217:     fn into_any(self) -> AnyView {
220: 218:         #[cfg(feature = "ssr")]
221: 219:         fn dry_resolve<T: RenderHtml + 'static>(value: &mut Erased) {
222: 220:             value.get_mut::<T>().dry_resolve();
223: 221:         }
224: 222: 
225: 223:         #[cfg(feature = "ssr")]
226: 224:         fn resolve<T: RenderHtml + 'static>(
227: 225:             value: Erased,
228: 226:         ) -> Pin<Box<dyn Future<Output = AnyView> + Send>> {
229: 227:             use futures::FutureExt;
230: 228: 
231: 229:             async move { value.into_inner::<T>().resolve().await.into_any() }
232: 230:                 .boxed()
233: 231:         }
234: 232: 
235: 233:         #[cfg(feature = "ssr")]
236: 234:         fn to_html<T: RenderHtml + 'static>(
237: 235:             value: Erased,
238: 236:             buf: &mut String,
239: 237:             position: &mut Position,
240: 238:             escape: bool,
241: 239:             mark_branches: bool,
242: 240:             extra_attrs: Vec<AnyAttribute>,
243: 241:         ) {
244: 242:             value.into_inner::<T>().to_html_with_buf(
245: 243:                 buf,
246: 244:                 position,
247: 245:                 escape,
248: 246:                 mark_branches,
249: 247:                 extra_attrs,
250: 248:             );
251: 249:             if !T::EXISTS {
252: 250:                 buf.push_str("<!--<() />-->");
253: 251:             }
254: 252:         }
255: 253: 
256: 254:         #[cfg(feature = "ssr")]
257: 255:         fn to_html_async<T: RenderHtml + 'static>(
258: 256:             value: Erased,
259: 257:             buf: &mut StreamBuilder,
260: 258:             position: &mut Position,
261: 259:             escape: bool,
262: 260:             mark_branches: bool,
263: 261:             extra_attrs: Vec<AnyAttribute>,
264: 262:         ) {
265: 263:             value.into_inner::<T>().to_html_async_with_buf::<false>(
266: 264:                 buf,
267: 265:                 position,
268: 266:                 escape,
269: 267:                 mark_branches,
270: 268:                 extra_attrs,
271: 269:             );
272: 270:             if !T::EXISTS {
273: 271:                 buf.push_sync("<!--<() />-->");
274: 272:             }
275: 273:         }
276: 274: 
277: 275:         #[cfg(feature = "ssr")]
278: 276:         fn to_html_async_ooo<T: RenderHtml + 'static>(
279: 277:             value: Erased,
280: 278:             buf: &mut StreamBuilder,
281: 279:             position: &mut Position,
282: 280:             escape: bool,
283: 281:             mark_branches: bool,
284: 282:             extra_attrs: Vec<AnyAttribute>,
285: 283:         ) {
286: 284:             value.into_inner::<T>().to_html_async_with_buf::<true>(
287: 285:                 buf,
288: 286:                 position,
289: 287:                 escape,
290: 288:                 mark_branches,
291: 289:                 extra_attrs,
292: 290:             );
293: 291:             if !T::EXISTS {
294: 292:                 buf.push_sync("<!--<() />-->");
295: 293:             }
296: 294:         }
297: 295: 
298: 296:         fn build<T: RenderHtml + 'static>(value: Erased) -> AnyViewState {
299: 297:             let state = ErasedLocal::new(value.into_inner::<T>().build());
300: 298:             let placeholder = (!T::EXISTS).then(Rndr::create_placeholder);
301: 299:             AnyViewState {
302: 300:                 type_id: TypeId::of::<T>(),
303: 301:                 state,
304: 302:                 mount: mount_any::<T>,
305: 303:                 unmount: unmount_any::<T>,
306: 304:                 insert_before_this: insert_before_this::<T>,
307: 305:                 elements: elements::<T>,
308: 306:                 placeholder,
309: 307:             }
310: 308:         }
311: 309: 
312: 310:         #[cfg(feature = "hydrate")]
313: 311:         fn hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T: RenderHtml + 'static>(
314: 312:             value: Erased,
315: 313:             cursor: &Cursor,
316: 314:             position: &PositionState,
317: 315:         ) -> AnyViewState {
318: 316:             let state = ErasedLocal::new(
319: 317:                 value.into_inner::<T>().hydrate::<true>(cursor, position),
320: 318:             );
321: 319:             let placeholder =
322: 320:                 (!T::EXISTS).then(|| cursor.next_placeholder(position));
323: 321:             AnyViewState {
324: 322:                 type_id: TypeId::of::<T>(),
325: 323:                 state,
326: 324:                 mount: mount_any::<T>,
327: 325:                 unmount: unmount_any::<T>,
328: 326:                 insert_before_this: insert_before_this::<T>,
329: 327:                 elements: elements::<T>,
330: 328:                 placeholder,
331: 329:             }
332: 330:         }
333: 331: 
334: 332:         #[cfg(feature = "hydrate")]
335: 333:         fn hydrate_async<T: RenderHtml + 'static>(
336: 334:             value: Erased,
337: 335:             cursor: &Cursor,
338: 336:             position: &PositionState,
339: 337:         ) -> Pin<Box<dyn Future<Output = AnyViewState>>> {
340: 338:             let cursor = cursor.clone();
341: 339:             let position = position.clone();
342: 340:             Box::pin(async move {
343: 341:                 let state = ErasedLocal::new(
344: 342:                     value
345: 343:                         .into_inner::<T>()
346: 344:                         .hydrate_async(&cursor, &position)
347: 345:                         .await,
348: 346:                 );
349: 347:                 let placeholder =
350: 348:                     (!T::EXISTS).then(|| cursor.next_placeholder(&position));
351: 349:                 AnyViewState {
352: 350:                     type_id: TypeId::of::<T>(),
353: 351:                     state,
354: 352:                     mount: mount_any::<T>,
355: 353:                     unmount: unmount_any::<T>,
356: 354:                     insert_before_this: insert_before_this::<T>,
357: 355:                     elements: elements::<T>,
358: 356:                     placeholder,
359: 357:                 }
360: 358:             })
361: 359:         }
362: 360: 
363: 361:         fn rebuild<T: RenderHtml + 'static>(
364: 362:             value: Erased,
365: 363:             state: &mut AnyViewState,
366: 364:         ) {
367: 365:             let state = state.state.get_mut::<<T as Render>::State>();
368: 366:             value.into_inner::<T>().rebuild(state);
369: 367:         }
370: 368: 
371: 369:         let value = self.into_owned();
372: 370:         AnyView {
373: 371:             type_id: TypeId::of::<T::Owned>(),
374: 372:             build: build::<T::Owned>,
375: 373:             rebuild: rebuild::<T::Owned>,
376: 374:             #[cfg(feature = "ssr")]
377: 375:             resolve: resolve::<T::Owned>,
378: 376:             #[cfg(feature = "ssr")]
379: 377:             dry_resolve: dry_resolve::<T::Owned>,
380: 378:             #[cfg(feature = "ssr")]
381: 379:             html_len: value.html_len(),
382: 380:             #[cfg(feature = "ssr")]
383: 381:             to_html: to_html::<T::Owned>,
384: 382:             #[cfg(feature = "ssr")]
385: 383:             to_html_async: to_html_async::<T::Owned>,
386: 384:             #[cfg(feature = "ssr")]
387: 385:             to_html_async_ooo: to_html_async_ooo::<T::Owned>,
388: 386:             #[cfg(feature = "hydrate")]
389: 387:             hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server: hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::<T::Owned>,
390: 388:             #[cfg(feature = "hydrate")]
391: 389:             hydrate_async: hydrate_async::<T::Owned>,
392: 390:             value: Erased::new(value),
393: 391:         }
394: 392:     }
395: 393: }
396: 394: 
397: 395: impl Render for AnyView {
398: 396:     type State = AnyViewState;
399: 397: 
400: 398:     fn build(self) -> Self::State {
401: 399:         (self.build)(self.value)
402: 400:     }
403: 401: 
404: 402:     fn rebuild(self, state: &mut Self::State) {
405: 403:         if self.type_id == state.type_id {
406: 404:             (self.rebuild)(self.value, state)
407: 405:         } else {
408: 406:             let mut new = self.build();
409: 407:             if let Some(placeholder) = &mut state.placeholder {
410: 408:                 placeholder.insert_before_this(&mut new);
411: 409:                 placeholder.unmount();
412: 410:             } else {
413: 411:                 state.insert_before_this(&mut new);
414: 412:             }
415: 413:             state.unmount();
416: 414:             *state = new;
417: 415:         }
418: 416:     }
419: 417: }
420: 418: 
421: 419: impl AddAnyAttr for AnyView {
422: 420:     type Output<SomeNewAttr: Attribute> = AnyViewWithAttrs;
423: 421: 
424: 422:     #[allow(unused_variables)]
425: 423:     fn add_any_attr<NewAttr: Attribute>(
426: 424:         self,
427: 425:         attr: NewAttr,
428: 426:     ) -> Self::Output<NewAttr>
429: 427:     where
430: 428:         Self::Output<NewAttr>: RenderHtml,
431: 429:     {
432: 430:         AnyViewWithAttrs {
433: 431:             view: self,
434: 432:             attrs: vec![attr.into_cloneable_owned().into_any_attr()],
435: 433:         }
436: 434:     }
437: 435: }
438: 436: 
439: 437: impl RenderHtml for AnyView {
440: 438:     type AsyncOutput = Self;
441: 439:     type Owned = Self;
442: 440: 
443: 441:     fn dry_resolve(&mut self) {
444: 442:         #[cfg(feature = "ssr")]
445: 443:         {
446: 444:             (self.dry_resolve)(&mut self.value)
447: 445:         }
448: 446:         #[cfg(not(feature = "ssr"))]
449: 447:         panic!(
450: 448:             "You are rendering AnyView to HTML without the `ssr` feature \
451: 449:              enabled."
452: 450:         );
453: 451:     }
454: 452: 
455: 453:     async fn resolve(self) -> Self::AsyncOutput {
456: 454:         #[cfg(feature = "ssr")]
457: 455:         {
458: 456:             (self.resolve)(self.value).await
459: 457:         }
460: 458:         #[cfg(not(feature = "ssr"))]
461: 459:         panic!(
462: 460:             "You are rendering AnyView to HTML without the `ssr` feature \
463: 461:              enabled."
464: 462:         );
465: 463:     }
466: 464: 
467: 465:     const MIN_LENGTH: usize = 0;
468: 466: 
469: 467:     fn to_html_with_buf(
470: 468:         self,
471: 469:         buf: &mut String,
472: 470:         position: &mut Position,
473: 471:         escape: bool,
474: 472:         mark_branches: bool,
475: 473:         extra_attrs: Vec<AnyAttribute>,
476: 474:     ) {
477: 475:         #[cfg(feature = "ssr")]
478: 476:         {
479: 477:             let type_id = if mark_branches && escape {
480: 478:                 format!("{:?}", self.type_id)
481: 479:             } else {
482: 480:                 Default::default()
483: 481:             };
484: 482:             if mark_branches && escape {
485: 483:                 buf.open_branch(&type_id);
486: 484:             }
487: 485:             (self.to_html)(
488: 486:                 self.value,
489: 487:                 buf,
490: 488:                 position,
491: 489:                 escape,
492: 490:                 mark_branches,
493: 491:                 extra_attrs,
494: 492:             );
495: 493:             if mark_branches && escape {
496: 494:                 buf.close_branch(&type_id);
497: 495:                 if *position == Position::NextChildAfterText {
498: 496:                     *position = Position::NextChild;
499: 497:                 }
500: 498:             }
501: 499:         }
502: 500:         #[cfg(not(feature = "ssr"))]
503: 501:         {
504: 502:             _ = mark_branches;
505: 503:             _ = buf;
506: 504:             _ = position;
507: 505:             _ = escape;
508: 506:             _ = extra_attrs;
509: 507:             panic!(
510: 508:                 "You are rendering AnyView to HTML without the `ssr` feature \
511: 509:                  enabled."
512: 510:             );
513: 511:         }
514: 512:     }
515: 513: 
516: 514:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
517: 515:         self,
518: 516:         buf: &mut StreamBuilder,
519: 517:         position: &mut Position,
520: 518:         escape: bool,
521: 519:         mark_branches: bool,
522: 520:         extra_attrs: Vec<AnyAttribute>,
523: 521:     ) where
524: 522:         Self: Sized,
525: 523:     {
526: 524:         #[cfg(feature = "ssr")]
527: 525:         if OUT_OF_ORDER {
528: 526:             let type_id = if mark_branches && escape {
529: 527:                 format!("{:?}", self.type_id)
530: 528:             } else {
531: 529:                 Default::default()
532: 530:             };
533: 531:             if mark_branches && escape {
534: 532:                 buf.open_branch(&type_id);
535: 533:             }
536: 534:             (self.to_html_async_ooo)(
537: 535:                 self.value,
538: 536:                 buf,
539: 537:                 position,
540: 538:                 escape,
541: 539:                 mark_branches,
542: 540:                 extra_attrs,
543: 541:             );
544: 542:             if mark_branches && escape {
545: 543:                 buf.close_branch(&type_id);
546: 544:                 if *position == Position::NextChildAfterText {
547: 545:                     *position = Position::NextChild;
548: 546:                 }
549: 547:             }
550: 548:         } else {
551: 549:             let type_id = if mark_branches && escape {
552: 550:                 format!("{:?}", self.type_id)
553: 551:             } else {
554: 552:                 Default::default()
555: 553:             };
556: 554:             if mark_branches && escape {
557: 555:                 buf.open_branch(&type_id);
558: 556:             }
559: 557:             (self.to_html_async)(
560: 558:                 self.value,
561: 559:                 buf,
562: 560:                 position,
563: 561:                 escape,
564: 562:                 mark_branches,
565: 563:                 extra_attrs,
566: 564:             );
567: 565:             if mark_branches && escape {
568: 566:                 buf.close_branch(&type_id);
569: 567:                 if *position == Position::NextChildAfterText {
570: 568:                     *position = Position::NextChild;
571: 569:                 }
572: 570:             }
573: 571:         }
574: 572:         #[cfg(not(feature = "ssr"))]
575: 573:         {
576: 574:             _ = buf;
577: 575:             _ = position;
578: 576:             _ = escape;
579: 577:             _ = mark_branches;
580: 578:             _ = extra_attrs;
581: 579:             panic!(
582: 580:                 "You are rendering AnyView to HTML without the `ssr` feature \
583: 581:                  enabled."
584: 582:             );
585: 583:         }
586: 584:     }
587: 585: 
588: 586:     fn hydrate<const FROM_SERVER: bool>(
589: 587:         self,
590: 588:         cursor: &Cursor,
591: 589:         position: &PositionState,
592: 590:     ) -> Self::State {
593: 591:         #[cfg(feature = "hydrate")]
594: 592:         {
595: 593:             if FROM_SERVER {
596: 594:                 (self.hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server)(self.value, cursor, position)
597: 595:             } else {
598: 596:                 panic!(
599: 597:                     "hydrating AnyView from inside a ViewTemplate is not \
600: 598:                      supported."
601: 599:                 );
602: 600:             }
603: 601:         }
604: 602:         #[cfg(not(feature = "hydrate"))]
605: 603:         {
606: 604:             _ = cursor;
607: 605:             _ = position;
608: 606:             panic!(
609: 607:                 "You are trying to hydrate AnyView without the `hydrate` \
610: 608:                  feature enabled."
611: 609:             );
612: 610:         }
613: 611:     }
614: 612: 
615: 613:     async fn hydrate_async(
616: 614:         self,
617: 615:         cursor: &Cursor,
618: 616:         position: &PositionState,
619: 617:     ) -> Self::State {
620: 618:         #[cfg(feature = "hydrate")]
621: 619:         {
622: 620:             let state =
623: 621:                 (self.hydrate_async)(self.value, cursor, position).await;
624: 622:             state
625: 623:         }
626: 624:         #[cfg(not(feature = "hydrate"))]
627: 625:         {
628: 626:             _ = cursor;
629: 627:             _ = position;
630: 628:             panic!(
631: 629:                 "You are trying to hydrate AnyView without the `hydrate` \
632: 630:                  feature enabled."
633: 631:             );
634: 632:         }
635: 633:     }
636: 634: 
637: 635:     fn html_len(&self) -> usize {
638: 636:         #[cfg(feature = "ssr")]
639: 637:         {
640: 638:             self.html_len
641: 639:         }
642: 640:         #[cfg(not(feature = "ssr"))]
643: 641:         {
644: 642:             0
645: 643:         }
646: 644:     }
647: 645: 
648: 646:     fn into_owned(self) -> Self::Owned {
649: 647:         self
650: 648:     }
651: 649: }
652: 650: 
653: 651: impl Mountable for AnyViewState {
654: 652:     fn unmount(&mut self) {
655: 653:         (self.unmount)(&mut self.state);
656: 654:         if let Some(placeholder) = &mut self.placeholder {
657: 655:             placeholder.unmount();
658: 656:         }
659: 657:     }
660: 658: 
661: 659:     fn mount(
662: 660:         &mut self,
663: 661:         parent: &crate::renderer::types::Element,
664: 662:         marker: Option<&crate::renderer::types::Node>,
665: 663:     ) {
666: 664:         (self.mount)(&mut self.state, parent, marker);
667: 665:         if let Some(placeholder) = &mut self.placeholder {
668: 666:             placeholder.mount(parent, marker);
669: 667:         }
670: 668:     }
671: 669: 
672: 670:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
673: 671:         let before_view = (self.insert_before_this)(&self.state, child);
674: 672:         if before_view {
675: 673:             return true;
676: 674:         }
677: 675: 
678: 676:         if let Some(placeholder) = &self.placeholder {
679: 677:             placeholder.insert_before_this(child)
680: 678:         } else {
681: 679:             false
682: 680:         }
683: 681:     }
684: 682: 
685: 683:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
686: 684:         (self.elements)(&self.state)
687: 685:     }
688: 686: }
689: 687: 
690: 688: /// wip
691: 689: pub struct AnyViewWithAttrs {
692: 690:     view: AnyView,
693: 691:     attrs: Vec<AnyAttribute>,
694: 692: }
695: 693: 
696: 694: impl Render for AnyViewWithAttrs {
697: 695:     type State = AnyViewWithAttrsState;
698: 696: 
699: 697:     fn build(self) -> Self::State {
700: 698:         let view = self.view.build();
701: 699:         let elements = view.elements();
702: 700:         let mut attrs = Vec::with_capacity(elements.len() * self.attrs.len());
703: 701:         for attr in self.attrs {
704: 702:             for el in &elements {
705: 703:                 attrs.push(attr.clone().build(el))
706: 704:             }
707: 705:         }
708: 706:         AnyViewWithAttrsState { view, attrs }
709: 707:     }
710: 708: 
711: 709:     fn rebuild(self, state: &mut Self::State) {
712: 710:         self.view.rebuild(&mut state.view);
713: 711: 
714: 712:         // at this point, we have rebuilt the inner view
715: 713:         // now we need to update attributes that were spread onto this
716: 714:         // this lyx-platform-lyx_platform_lyx-platform-lyx_platform_approach is not ideal, but it avolyx-core-lyx_core_lyx-core-lyx_core_ids two edge cases:
717: 715:         // 1) merging attributes from two unrelated views (https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/4268)
718: 716:         // 2) failing to re-create attributes from the same view (https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/4512)
719: 717:         for element in state.elements() {
720: 718:             // first, remove the previous set of attributes
721: 719:             self.attrs
722: 720:                 .clone()
723: 721:                 .rebuild(&mut (element.clone(), Vec::new()));
724: 722:             // then, add the new set of attributes
725: 723:             self.attrs.clone().build(&element);
726: 724:         }
727: 725:     }
728: 726: }
729: 727: 
730: 728: impl RenderHtml for AnyViewWithAttrs {
731: 729:     type AsyncOutput = Self;
732: 730:     type Owned = Self;
733: 731:     const MIN_LENGTH: usize = 0;
734: 732: 
735: 733:     fn dry_resolve(&mut self) {
736: 734:         self.view.dry_resolve();
737: 735:         for attr in &mut self.attrs {
738: 736:             attr.dry_resolve();
739: 737:         }
740: 738:     }
741: 739: 
742: 740:     async fn resolve(self) -> Self::AsyncOutput {
743: 741:         let resolve_view = self.view.resolve();
744: 742:         let resolve_attrs =
745: 743:             join_all(self.attrs.into_iter().map(|attr| attr.resolve()));
746: 744:         let (view, attrs) = join(resolve_view, resolve_attrs).await;
747: 745:         Self { view, attrs }
748: 746:     }
749: 747: 
750: 748:     fn to_html_with_buf(
751: 749:         self,
752: 750:         buf: &mut String,
753: 751:         position: &mut Position,
754: 752:         escape: bool,
755: 753:         mark_branches: bool,
756: 754:         mut extra_attrs: Vec<AnyAttribute>,
757: 755:     ) {
758: 756:         // `extra_attrs` will be empty here in most cases, but it will have
759: 757:         // attributes in it already if this is, itself, receiving additional attrs
760: 758:         extra_attrs.extend(self.attrs);
761: 759:         self.view.to_html_with_buf(
762: 760:             buf,
763: 761:             position,
764: 762:             escape,
765: 763:             mark_branches,
766: 764:             extra_attrs,
767: 765:         );
768: 766:     }
769: 767: 
770: 768:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
771: 769:         self,
772: 770:         buf: &mut StreamBuilder,
773: 771:         position: &mut Position,
774: 772:         escape: bool,
775: 773:         mark_branches: bool,
776: 774:         mut extra_attrs: Vec<AnyAttribute>,
777: 775:     ) where
778: 776:         Self: Sized,
779: 777:     {
780: 778:         extra_attrs.extend(self.attrs);
781: 779:         self.view.to_html_async_with_buf::<OUT_OF_ORDER>(
782: 780:             buf,
783: 781:             position,
784: 782:             escape,
785: 783:             mark_branches,
786: 784:             extra_attrs,
787: 785:         );
788: 786:     }
789: 787: 
790: 788:     fn hydrate<const FROM_SERVER: bool>(
791: 789:         self,
792: 790:         cursor: &Cursor,
793: 791:         position: &PositionState,
794: 792:     ) -> Self::State {
795: 793:         let view = self.view.hydrate::<FROM_SERVER>(cursor, position);
796: 794:         let elements = view.elements();
797: 795:         let mut attrs = Vec::with_capacity(elements.len() * self.attrs.len());
798: 796:         for attr in self.attrs {
799: 797:             for el in &elements {
800: 798:                 attrs.push(attr.clone().hydrate::<FROM_SERVER>(el));
801: 799:             }
802: 800:         }
803: 801:         AnyViewWithAttrsState { view, attrs }
804: 802:     }
805: 803: 
806: 804:     async fn hydrate_async(
807: 805:         self,
808: 806:         cursor: &Cursor,
809: 807:         position: &PositionState,
810: 808:     ) -> Self::State {
811: 809:         let view = self.view.hydrate_async(cursor, position).await;
812: 810:         let elements = view.elements();
813: 811:         let mut attrs = Vec::with_capacity(elements.len() * self.attrs.len());
814: 812:         for attr in self.attrs {
815: 813:             for el in &elements {
816: 814:                 attrs.push(attr.clone().hydrate::<true>(el));
817: 815:             }
818: 816:         }
819: 817:         AnyViewWithAttrsState { view, attrs }
820: 818:     }
821: 819: 
822: 820:     fn html_len(&self) -> usize {
823: 821:         self.view.html_len()
824: 822:             + self.attrs.iter().map(|attr| attr.html_len()).sum::<usize>()
825: 823:     }
826: 824: 
827: 825:     fn into_owned(self) -> Self::Owned {
828: 826:         self
829: 827:     }
830: 828: }
831: 829: 
832: 830: impl AddAnyAttr for AnyViewWithAttrs {
833: 831:     type Output<SomeNewAttr: Attribute> = AnyViewWithAttrs;
834: 832: 
835: 833:     fn add_any_attr<NewAttr: Attribute>(
836: 834:         mut self,
837: 835:         attr: NewAttr,
838: 836:     ) -> Self::Output<NewAttr>
839: 837:     where
840: 838:         Self::Output<NewAttr>: RenderHtml,
841: 839:     {
842: 840:         self.attrs.push(attr.into_cloneable_owned().into_any_attr());
843: 841:         self
844: 842:     }
845: 843: }
846: 844: 
847: 845: /// State for any view with attributes spread onto it.
848: 846: pub struct AnyViewWithAttrsState {
849: 847:     view: AnyViewState,
850: 848:     #[allow(dead_code)] // keeps attribute states alive until dropped
851: 849:     attrs: Vec<AnyAttributeState>,
852: 850: }
853: 851: 
854: 852: impl Mountable for AnyViewWithAttrsState {
855: 853:     fn unmount(&mut self) {
856: 854:         self.view.unmount();
857: 855:     }
858: 856: 
859: 857:     fn mount(
860: 858:         &mut self,
861: 859:         parent: &crate::renderer::types::Element,
862: 860:         marker: Option<&crate::renderer::types::Node>,
863: 861:     ) {
864: 862:         self.view.mount(parent, marker)
865: 863:     }
866: 864: 
867: 865:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
868: 866:         self.view.insert_before_this(child)
869: 867:     }
870: 868: 
871: 869:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
872: 870:         self.view.elements()
873: 871:     }
874: 872: }
875: 873: 
876: 874: /*
877: 875: #[cfg(test)]
878: 876: mod tests {
879: 877:     use super::IntoAny;
880: 878:     use crate::{
881: 879:         html::element::{p, span},
882: 880:         renderer::mock_dom::MockDom,
883: 881:         view::{any_view::AnyView, RenderHtml},
884: 882:     };
885: 883: 
886: 884:     #[test]
887: 885:     fn should_handle_html_creation() {
888: 886:         let x = 1;
889: 887:         let mut buf = String::new();
890: 888:         let view: AnyView<MockDom> = if x == 0 {
891: 889:             p((), "foo").into_any()
892: 890:         } else {
893: 891:             span((), "bar").into_any()
894: 892:         };
895: 893:         view.to_html(&mut buf, &Default::default());
896: 894:         assert_eq!(buf, "<span>bar</span><!>");
897: 895:     }
898: 896: }
899: 897:  */
900: 898: ```
901: 899: ```
902: 900: ```
903: 901: ```
904: 902: ```
905: 903: ```
906: 904: ```
907: 905: ```
908: ```
```
