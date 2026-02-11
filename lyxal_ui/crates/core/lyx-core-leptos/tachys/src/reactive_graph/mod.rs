### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\mod.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::attribute::{any_attribute::AnyAttribute, Attribute, AttributeValue},
21: 19:     hydration::Cursor,
22: 20:     renderer::Rndr,
23: 21:     ssr::StreamBuilder,
24: 22:     view::{
25: 23:         add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
26: 24:         RenderHtml, ToTemplate,
27: 25:     },
28: 26: };
29: 27: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::RenderEffect;
30: 28: use std::{
31: 29:     cell::RefCell,
32: 30:     rc::Rc,
33: 31:     sync::{Arc, Mutex},
34: 32: };
35: 33: 
36: 34: /// Types for two way data binding.
37: 35: pub mod bind;
38: 36: mod class;
39: 37: mod inner_html;
40: 38: /// Provides a reactive [`NodeRef`](node_ref::NodeRef) type.
41: 39: pub mod node_ref;
42: 40: mod owned;
43: 41: mod property;
44: 42: mod style;
45: 43: mod suspense;
46: 44: 
47: 45: pub use owned::*;
48: 46: pub use suspense::*;
49: 47: 
50: 48: impl<F, V> ToTemplate for F
51: 49: where
52: 50:     F: ReactiveFunction<Output = V>,
53: 51:     V: ToTemplate,
54: 52: {
55: 53:     const TEMPLATE: &'static str = V::TEMPLATE;
56: 54: 
57: 55:     fn to_template(
58: 56:         buf: &mut String,
59: 57:         class: &mut String,
60: 58:         style: &mut String,
61: 59:         inner_html: &mut String,
62: 60:         position: &mut Position,
63: 61:     ) {
64: 62:         // FIXME this seems wrong
65: 63:         V::to_template(buf, class, style, inner_html, position)
66: 64:     }
67: 65: }
68: 66: 
69: 67: impl<F, V> Render for F
70: 68: where
71: 69:     F: ReactiveFunction<Output = V>,
72: 70:     V: Render,
73: 71:     V::State: 'static,
74: 72: {
75: 73:     type State = RenderEffectState<V::State>;
76: 74: 
77: 75:     #[track_caller]
78: 76:     fn build(mut self) -> Self::State {
79: 77:         let hook = lyx-core-any_error::get_error_hook();
80: 78:         RenderEffect::new(move |prev| {
81: 79:             let _guard = hook
82: 80:                 .as_ref()
83: 81:                 .map(|h| lyx-core-any_error::set_error_hook(Arc::clone(h)));
84: 82:             let value = self.invoke();
85: 83:             if let Some(mut state) = prev {
86: 84:                 value.rebuild(&mut state);
87: 85:                 state
88: 86:             } else {
89: 87:                 value.build()
90: 88:             }
91: 89:         })
92: 90:         .into()
93: 91:     }
94: 92: 
95: 93:     #[track_caller]
96: 94:     fn rebuild(self, state: &mut Self::State) {
97: 95:         let new = self.build();
98: 96:         let mut old = std::mem::replace(state, new);
99: 97:         old.insert_before_this(state);
100: 98:         old.unmount();
101: 99:     }
102: 100: }
103: 101: 
104: 102: /// Retained view state for a [`RenderEffect`].
105: 103: pub struct RenderEffectState<T: 'static>(Option<RenderEffect<T>>);
106: 104: 
107: 105: impl<T> From<RenderEffect<T>> for RenderEffectState<T> {
108: 106:     fn from(value: RenderEffect<T>) -> Self {
109: 107:         Self(Some(value))
110: 108:     }
111: 109: }
112: 110: 
113: 111: impl<T> Mountable for RenderEffectState<T>
114: 112: where
115: 113:     T: Mountable,
116: 114: {
117: 115:     fn unmount(&mut self) {
118: 116:         if let Some(ref mut inner) = self.0 {
119: 117:             inner.unmount();
120: 118:         }
121: 119:     }
122: 120: 
123: 121:     fn mount(
124: 122:         &mut self,
125: 123:         parent: &crate::renderer::types::Element,
126: 124:         marker: Option<&crate::renderer::types::Node>,
127: 125:     ) {
128: 126:         if let Some(ref mut inner) = self.0 {
129: 127:             inner.mount(parent, marker);
130: 128:         }
131: 129:     }
132: 130: 
133: 131:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
134: 132:         if let Some(inner) = &self.0 {
135: 133:             inner.insert_before_this(child)
136: 134:         } else {
137: 135:             false
138: 136:         }
139: 137:     }
140: 138: 
141: 139:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
142: 140:         self.0
143: 141:             .as_ref()
144: 142:             .map(|inner| inner.elements())
145: 143:             .unwrap_or_default()
146: 144:     }
147: 145: }
148: 146: 
149: 147: impl<F, V> RenderHtml for F
150: 148: where
151: 149:     F: ReactiveFunction<Output = V>,
152: 150:     V: RenderHtml + 'static,
153: 151:     V::State: 'static,
154: 152: {
155: 153:     type AsyncOutput = V::AsyncOutput;
156: 154:     type Owned = Self;
157: 155: 
158: 156:     const MIN_LENGTH: usize = 0;
159: 157: 
160: 158:     fn dry_resolve(&mut self) {
161: 159:         self.invoke().dry_resolve();
162: 160:     }
163: 161: 
164: 162:     async fn resolve(mut self) -> Self::AsyncOutput {
165: 163:         self.invoke().resolve().await
166: 164:     }
167: 165: 
168: 166:     fn html_len(&self) -> usize {
169: 167:         V::MIN_LENGTH
170: 168:     }
171: 169: 
172: 170:     fn to_html_with_buf(
173: 171:         mut self,
174: 172:         buf: &mut String,
175: 173:         position: &mut Position,
176: 174:         escape: bool,
177: 175:         mark_branches: bool,
178: 176:         extra_attrs: Vec<AnyAttribute>,
179: 177:     ) {
180: 178:         let value = self.invoke();
181: 179:         value.to_html_with_buf(
182: 180:             buf,
183: 181:             position,
184: 182:             escape,
185: 183:             mark_branches,
186: 184:             extra_attrs,
187: 185:         )
188: 186:     }
189: 187: 
190: 188:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
191: 189:         mut self,
192: 190:         buf: &mut StreamBuilder,
193: 191:         position: &mut Position,
194: 192:         escape: bool,
195: 193:         mark_branches: bool,
196: 194:         extra_attrs: Vec<AnyAttribute>,
197: 195:     ) where
198: 196:         Self: Sized,
199: 197:     {
200: 198:         let value = self.invoke();
201: 199:         value.to_html_async_with_buf::<OUT_OF_ORDER>(
202: 200:             buf,
203: 201:             position,
204: 202:             escape,
205: 203:             mark_branches,
206: 204:             extra_attrs,
207: 205:         );
208: 206:     }
209: 207: 
210: 208:     fn hydrate<const FROM_SERVER: bool>(
211: 209:         mut self,
212: 210:         cursor: &Cursor,
213: 211:         position: &PositionState,
214: 212:     ) -> Self::State {
215: 213:         /// codegen optimisation:
216: 214:         fn prep(
217: 215:             cursor: &Cursor,
218: 216:             position: &PositionState,
219: 217:         ) -> (
220: 218:             Cursor,
221: 219:             PositionState,
222: 220:             Option<Arc<dyn lyx-core-any_error::ErrorHook>>,
223: 221:         ) {
224: 222:             let cursor = cursor.clone();
225: 223:             let position = position.clone();
226: 224:             let hook = lyx-core-any_error::get_error_hook();
227: 225:             (cursor, position, hook)
228: 226:         }
229: 227:         let (cursor, position, hook) = prep(cursor, position);
230: 228: 
231: 229:         RenderEffect::new(move |prev| {
232: 230:             /// codegen optimisation:
233: 231:             fn get_guard(
234: 232:                 hook: &Option<Arc<dyn lyx-core-any_error::ErrorHook>>,
235: 233:             ) -> Option<lyx-core-any_error::ResetErrorHookOnDrop> {
236: 234:                 hook.as_ref()
237: 235:                     .map(|h| lyx-core-any_error::set_error_hook(Arc::clone(h)))
238: 236:             }
239: 237:             let _guard = get_guard(&hook);
240: 238: 
241: 239:             let value = self.invoke();
242: 240:             if let Some(mut state) = prev {
243: 241:                 value.rebuild(&mut state);
244: 242:                 state
245: 243:             } else {
246: 244:                 value.hydrate::<FROM_SERVER>(&cursor, &position)
247: 245:             }
248: 246:         })
249: 247:         .into()
250: 248:     }
251: 249: 
252: 250:     async fn hydrate_async(
253: 251:         self,
254: 252:         cursor: &Cursor,
255: 253:         position: &PositionState,
256: 254:     ) -> Self::State {
257: 255:         /// codegen optimisation:
258: 256:         fn prep(
259: 257:             cursor: &Cursor,
260: 258:             position: &PositionState,
261: 259:         ) -> (
262: 260:             Cursor,
263: 261:             PositionState,
264: 262:             Option<Arc<dyn lyx-core-any_error::ErrorHook>>,
265: 263:         ) {
266: 264:             let cursor = cursor.clone();
267: 265:             let position = position.clone();
268: 266:             let hook = lyx-core-any_error::get_error_hook();
269: 267:             (cursor, position, hook)
270: 268:         }
271: 269:         let (cursor, position, hook) = prep(cursor, position);
272: 270: 
273: 271:         let mut fun = self.into_shared();
274: 272: 
275: 273:         RenderEffect::new_with_async_value(
276: 274:             {
277: 275:                 let mut fun = fun.clone();
278: 276:                 move |prev| {
279: 277:                     /// codegen optimisation:
280: 278:                     fn get_guard(
281: 279:                         hook: &Option<Arc<dyn lyx-core-any_error::ErrorHook>>,
282: 280:                     ) -> Option<lyx-core-any_error::ResetErrorHookOnDrop>
283: 281:                     {
284: 282:                         hook.as_ref()
285: 283:                             .map(|h| lyx-core-any_error::set_error_hook(Arc::clone(h)))
286: 284:                     }
287: 285:                     let _guard = get_guard(&hook);
288: 286: 
289: 287:                     let value = fun.invoke();
290: 288:                     if let Some(mut state) = prev {
291: 289:                         value.rebuild(&mut state);
292: 290:                         state
293: 291:                     } else {
294: 292:                         unreachable!()
295: 293:                     }
296: 294:                 }
297: 295:             },
298: 296:             async move { fun.invoke().hydrate_async(&cursor, &position).await },
299: 297:         )
300: 298:         .await
301: 299:         .into()
302: 300:     }
303: 301: 
304: 302:     fn into_owned(self) -> Self::Owned {
305: 303:         self
306: 304:     }
307: 305: }
308: 306: 
309: 307: impl<F, V> AddAnyAttr for F
310: 308: where
311: 309:     F: ReactiveFunction<Output = V>,
312: 310:     V: RenderHtml + 'static,
313: 311: {
314: 312:     type Output<SomeNewAttr: Attribute> =
315: 313:         Box<dyn FnMut() -> V::Output<SomeNewAttr::CloneableOwned> + Send>;
316: 314: 
317: 315:     fn add_any_attr<NewAttr: Attribute>(
318: 316:         mut self,
319: 317:         attr: NewAttr,
320: 318:     ) -> Self::Output<NewAttr>
321: 319:     where
322: 320:         Self::Output<NewAttr>: RenderHtml,
323: 321:     {
324: 322:         let attr = attr.into_cloneable_owned();
325: 323:         Box::new(move || self.invoke().add_any_attr(attr.clone()))
326: 324:     }
327: 325: }
328: 326: 
329: 327: impl<M> Mountable for RenderEffect<M>
330: 328: where
331: 329:     M: Mountable + 'static,
332: 330: {
333: 331:     fn unmount(&mut self) {
334: 332:         self.with_value_mut(|state| state.unmount());
335: 333:     }
336: 334: 
337: 335:     fn mount(
338: 336:         &mut self,
339: 337:         parent: &crate::renderer::types::Element,
340: 338:         marker: Option<&crate::renderer::types::Node>,
341: 339:     ) {
342: 340:         self.with_value_mut(|state| {
343: 341:             state.mount(parent, marker);
344: 342:         });
345: 343:     }
346: 344: 
347: 345:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
348: 346:         self.with_value_mut(|value| value.insert_before_this(child))
349: 347:             .unwrap_or(false)
350: 348:     }
351: 349: 
352: 350:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
353: 351:         self.with_value_mut(|inner| inner.elements())
354: 352:             .unwrap_or_default()
355: 353:     }
356: 354: }
357: 355: 
358: 356: impl<T> Drop for RenderEffectState<T> {
359: 357:     fn drop(&mut self) {
360: 358:         if let Some(effect) = self.0.take() {
361: 359:             drop(effect.take_value());
362: 360:             drop(effect);
363: 361:         }
364: 362:     }
365: 363: }
366: 364: 
367: 365: impl<M, E> Mountable for Result<M, E>
368: 366: where
369: 367:     M: Mountable,
370: 368: {
371: 369:     fn unmount(&mut self) {
372: 370:         if let Ok(ref mut inner) = self {
373: 371:             inner.unmount();
374: 372:         }
375: 373:     }
376: 374: 
377: 375:     fn mount(
378: 376:         &mut self,
379: 377:         parent: &crate::renderer::types::Element,
380: 378:         marker: Option<&crate::renderer::types::Node>,
381: 379:     ) {
382: 380:         if let Ok(ref mut inner) = self {
383: 381:             inner.mount(parent, marker);
384: 382:         }
385: 383:     }
386: 384: 
387: 385:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
388: 386:         if let Ok(inner) = &self {
389: 387:             inner.insert_before_this(child)
390: 388:         } else {
391: 389:             false
392: 390:         }
393: 391:     }
394: 392: 
395: 393:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
396: 394:         self.as_ref()
397: 395:             .map(|inner| inner.elements())
398: 396:             .unwrap_or_default()
399: 397:     }
400: 398: }
401: 399: 
402: 400: // Dynamic attributes
403: 401: impl<F, V> AttributeValue for F
404: 402: where
405: 403:     F: ReactiveFunction<Output = V>,
406: 404:     V: AttributeValue + 'static,
407: 405:     V::State: 'static,
408: 406: {
409: 407:     type AsyncOutput = V::AsyncOutput;
410: 408:     type State = RenderEffect<V::State>;
411: 409:     type Cloneable = SharedReactiveFunction<V>;
412: 410:     type CloneableOwned = SharedReactiveFunction<V>;
413: 411: 
414: 412:     fn html_len(&self) -> usize {
415: 413:         0
416: 414:     }
417: 415: 
418: 416:     fn to_html(mut self, key: &str, buf: &mut String) {
419: 417:         let value = self.invoke();
420: 418:         value.to_html(key, buf);
421: 419:     }
422: 420: 
423: 421:     fn to_template(_key: &str, _buf: &mut String) {}
424: 422: 
425: 423:     fn hydrate<const FROM_SERVER: bool>(
426: 424:         mut self,
427: 425:         key: &str,
428: 426:         el: &crate::renderer::types::Element,
429: 427:     ) -> Self::State {
430: 428:         let key = Rndr::intern(key);
431: 429:         let key = key.to_owned();
432: 430:         let el = el.to_owned();
433: 431: 
434: 432:         RenderEffect::new(move |prev| {
435: 433:             let value = self.invoke();
436: 434:             if let Some(mut state) = prev {
437: 435:                 value.rebuild(&key, &mut state);
438: 436:                 state
439: 437:             } else {
440: 438:                 value.hydrate::<FROM_SERVER>(&key, &el)
441: 439:             }
442: 440:         })
443: 441:     }
444: 442: 
445: 443:     fn build(
446: 444:         mut self,
447: 445:         el: &crate::renderer::types::Element,
448: 446:         key: &str,
449: 447:     ) -> Self::State {
450: 448:         let key = Rndr::intern(key);
451: 449:         let key = key.to_owned();
452: 450:         let el = el.to_owned();
453: 451: 
454: 452:         RenderEffect::new(move |prev| {
455: 453:             let value = self.invoke();
456: 454:             if let Some(mut state) = prev {
457: 455:                 value.rebuild(&key, &mut state);
458: 456:                 state
459: 457:             } else {
460: 458:                 value.build(&el, &key)
461: 459:             }
462: 460:         })
463: 461:     }
464: 462: 
465: 463:     fn rebuild(mut self, key: &str, state: &mut Self::State) {
466: 464:         let key = Rndr::intern(key);
467: 465:         let key = key.to_owned();
468: 466:         let prev_value = state.take_value();
469: 467: 
470: 468:         *state = RenderEffect::new_with_value(
471: 469:             move |prev| {
472: 470:                 let value = self.invoke();
473: 471:                 if let Some(mut state) = prev {
474: 472:                     value.rebuild(&key, &mut state);
475: 473:                     state
476: 474:                 } else {
477: 475:                     unreachable!()
478: 476:                 }
479: 477:             },
480: 478:             prev_value,
481: 479:         );
482: 480:     }
483: 481: 
484: 482:     fn into_cloneable(self) -> Self::Cloneable {
485: 483:         self.into_shared()
486: 484:     }
487: 485: 
488: 486:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
489: 487:         self.into_shared()
490: 488:     }
491: 489: 
492: 490:     fn dry_resolve(&mut self) {
493: 491:         self.invoke();
494: 492:     }
495: 493: 
496: 494:     async fn resolve(mut self) -> Self::AsyncOutput {
497: 495:         self.invoke().resolve().await
498: 496:     }
499: 497: }
500: 498: 
501: 499: impl<V> AttributeValue for Suspend<V>
502: 500: where
503: 501:     V: AttributeValue + 'static,
504: 502:     V::State: 'static,
505: 503: {
506: 504:     type State = Rc<RefCell<Option<V::State>>>;
507: 505:     type AsyncOutput = V;
508: 506:     type Cloneable = ();
509: 507:     type CloneableOwned = ();
510: 508: 
511: 509:     fn html_len(&self) -> usize {
512: 510:         0
513: 511:     }
514: 512: 
515: 513:     fn to_html(self, _key: &str, _buf: &mut String) {
516: 514:         #[cfg(feature = "tracing")]
517: 515:         tracing::error!(
518: 516:             "Suspended attributes cannot be used outside Suspense."
519: 517:         );
520: 518:     }
521: 519: 
522: 520:     fn to_template(_key: &str, _buf: &mut String) {}
523: 521: 
524: 522:     fn hydrate<const FROM_SERVER: bool>(
525: 523:         self,
526: 524:         key: &str,
527: 525:         el: &crate::renderer::types::Element,
528: 526:     ) -> Self::State {
529: 527:         let key = key.to_owned();
530: 528:         let el = el.to_owned();
531: 529:         let state = Rc::new(RefCell::new(None));
532: 530:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
533: 531:             let state = Rc::clone(&state);
534: 532:             async move {
535: 533:                 *state.borrow_mut() =
536: 534:                     Some(self.inner.await.hydrate::<FROM_SERVER>(&key, &el));
537: 535:                 self.subscriber.forward();
538: 536:             }
539: 537:         });
540: 538:         state
541: 539:     }
542: 540: 
543: 541:     fn build(
544: 542:         self,
545: 543:         el: &crate::renderer::types::Element,
546: 544:         key: &str,
547: 545:     ) -> Self::State {
548: 546:         let key = key.to_owned();
549: 547:         let el = el.to_owned();
550: 548:         let state = Rc::new(RefCell::new(None));
551: 549:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
552: 550:             let state = Rc::clone(&state);
553: 551:             async move {
554: 552:                 *state.borrow_mut() = Some(self.inner.await.build(&el, &key));
555: 553:                 self.subscriber.forward();
556: 554:             }
557: 555:         });
558: 556:         state
559: 557:     }
560: 558: 
561: 559:     fn rebuild(self, key: &str, state: &mut Self::State) {
562: 560:         let key = key.to_owned();
563: 561:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
564: 562:             let state = Rc::clone(state);
565: 563:             async move {
566: 564:                 let value = self.inner.await;
567: 565:                 let mut state = state.borrow_mut();
568: 566:                 if let Some(state) = state.as_mut() {
569: 567:                     value.rebuild(&key, state);
570: 568:                 }
571: 569:                 self.subscriber.forward();
572: 570:             }
573: 571:         });
574: 572:     }
575: 573: 
576: 574:     fn into_cloneable(self) -> Self::Cloneable {
577: 575:         #[cfg(feature = "tracing")]
578: 576:         tracing::error!("Suspended attributes cannot be spread");
579: 577:     }
580: 578: 
581: 579:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
582: 580:         #[cfg(feature = "tracing")]
583: 581:         tracing::error!("Suspended attributes cannot be spread");
584: 582:     }
585: 583: 
586: 584:     fn dry_resolve(&mut self) {}
587: 585: 
588: 586:     async fn resolve(self) -> Self::AsyncOutput {
589: 587:         self.inner.await
590: 588:     }
591: 589: }
592: 590: 
593: 591: /// A reactive function that can be shared across multiple locations and across threads.
594: 592: pub type SharedReactiveFunction<T> = Arc<Mutex<dyn FnMut() -> T + Send>>;
595: 593: 
596: 594: /// A reactive view function.
597: 595: pub trait ReactiveFunction: Send + 'static {
598: 596:     /// The return type of the function.
599: 597:     type Output;
600: 598: 
601: 599:     /// Call the function.
602: 600:     fn invoke(&mut self) -> Self::Output;
603: 601: 
604: 602:     /// Converts the function into a cloneable, shared type.
605: 603:     fn into_shared(self) -> Arc<Mutex<dyn FnMut() -> Self::Output + Send>>;
606: 604: }
607: 605: 
608: 606: impl<T: 'static> ReactiveFunction for Arc<Mutex<dyn FnMut() -> T + Send>> {
609: 607:     type Output = T;
610: 608: 
611: 609:     fn invoke(&mut self) -> Self::Output {
612: 610:         let mut fun = self.lock().expect("lock poisoned");
613: 611:         fun()
614: 612:     }
615: 613: 
616: 614:     fn into_shared(self) -> Arc<Mutex<dyn FnMut() -> Self::Output + Send>> {
617: 615:         self
618: 616:     }
619: 617: }
620: 618: 
621: 619: impl<T: Send + Sync + 'static> ReactiveFunction
622: 620:     for Arc<dyn Fn() -> T + Send + Sync>
623: 621: {
624: 622:     type Output = T;
625: 623: 
626: 624:     fn invoke(&mut self) -> Self::Output {
627: 625:         self()
628: 626:     }
629: 627: 
630: 628:     fn into_shared(self) -> Arc<Mutex<dyn FnMut() -> Self::Output + Send>> {
631: 629:         Arc::new(Mutex::new(move || self()))
632: 630:     }
633: 631: }
634: 632: 
635: 633: impl<F, T> ReactiveFunction for F
636: 634: where
637: 635:     F: FnMut() -> T + Send + 'static,
638: 636: {
639: 637:     type Output = T;
640: 638: 
641: 639:     fn invoke(&mut self) -> Self::Output {
642: 640:         self()
643: 641:     }
644: 642: 
645: 643:     fn into_shared(self) -> Arc<Mutex<dyn FnMut() -> Self::Output + Send>> {
646: 644:         Arc::new(Mutex::new(self))
647: 645:     }
648: 646: }
649: 647: 
650: 648: macro_rules! reactive_impl {
651: 649:     ($name:ident, <$($gen:ident),*>, $v:ty, $dry_resolve:literal, $( $where_clause:tt )*) =>
652: 650:     {
653: 651:         #[allow(deprecated)]
654: 652:         impl<$($gen),*> Render for $name<$($gen),*>
655: 653:         where
656: 654:             $v: Render + Clone + Send + Sync + 'static,
657: 655:             <$v as Render>::State: 'static,
658: 656:             $($where_clause)*
659: 657:         {
660: 658:             type State = RenderEffectState<<$v as Render>::State>;
661: 659: 
662: 660:             #[track_caller]
663: 661:             fn build(self) -> Self::State {
664: 662:                 (move || self.get()).build()
665: 663:             }
666: 664: 
667: 665:             #[track_caller]
668: 666:             fn rebuild(self, state: &mut Self::State) {
669: 667:                 let new = self.build();
670: 668:                 let mut old = std::mem::replace(state, new);
671: 669:                 old.insert_before_this(state);
672: 670:                 old.unmount();
673: 671:             }
674: 672:         }
675: 673: 
676: 674:         #[allow(deprecated)]
677: 675:         impl<$($gen),*> AddAnyAttr for $name<$($gen),*>
678: 676:         where
679: 677:             $v: RenderHtml + Clone + Send + Sync + 'static,
680: 678:             <$v as Render>::State: 'static,
681: 679:             $($where_clause)*
682: 680:         {
683: 681:             type Output<SomeNewAttr: Attribute> = Self;
684: 682: 
685: 683:             fn add_any_attr<NewAttr: Attribute>(
686: 684:                 self,
687: 685:                 _attr: NewAttr,
688: 686:             ) -> Self::Output<NewAttr> {
689: 687:                 todo!()
690: 688:             }
691: 689:         }
692: 690: 
693: 691:         #[allow(deprecated)]
694: 692:         impl<$($gen),*> RenderHtml for $name<$($gen),*>
695: 693:         where
696: 694:             $v: RenderHtml + Clone + Send + Sync + 'static,
697: 695:             <$v as Render>::State: 'static,
698: 696:             $($where_clause)*
699: 697:         {
700: 698:             type AsyncOutput = Self;
701: 699:             type Owned = Self;
702: 700: 
703: 701:             const MIN_LENGTH: usize = 0;
704: 702: 
705: 703:             fn dry_resolve(&mut self) {
706: 704:                 if $dry_resolve {
707: 705:                     _ = self.get();
708: 706:                 }
709: 707:             }
710: 708: 
711: 709:             async fn resolve(self) -> Self::AsyncOutput {
712: 710:                 self
713: 711:             }
714: 712: 
715: 713:             fn html_len(&self) -> usize {
716: 714:                 <$v>::MIN_LENGTH
717: 715:             }
718: 716: 
719: 717:             fn to_html_with_buf(
720: 718:                 self,
721: 719:                 buf: &mut String,
722: 720:                 position: &mut Position,
723: 721:                 escape: bool,
724: 722:                 mark_branches: bool,
725: 723:                 extra_attrs: Vec<AnyAttribute>,
726: 724:             ) {
727: 725:                 let value = self.get();
728: 726:                 value.to_html_with_buf(
729: 727:                     buf,
730: 728:                     position,
731: 729:                     escape,
732: 730:                     mark_branches,
733: 731:                     extra_attrs,
734: 732:                 )
735: 733:             }
736: 734: 
737: 735:             fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
738: 736:                 self,
739: 737:                 buf: &mut StreamBuilder,
740: 738:                 position: &mut Position,
741: 739:                 escape: bool,
742: 740:                 mark_branches: bool,
743: 741:                 extra_attrs: Vec<AnyAttribute>,
744: 742:             ) where
745: 743:                 Self: Sized,
746: 744:             {
747: 745:                 let value = self.get();
748: 746:                 value.to_html_async_with_buf::<OUT_OF_ORDER>(
749: 747:                     buf,
750: 748:                     position,
751: 749:                     escape,
752: 750:                     mark_branches,
753: 751:                     extra_attrs,
754: 752:                 );
755: 753:             }
756: 754: 
757: 755:             fn hydrate<const FROM_SERVER: bool>(
758: 756:                 self,
759: 757:                 cursor: &Cursor,
760: 758:                 position: &PositionState,
761: 759:             ) -> Self::State {
762: 760:                 (move || self.get())
763: 761:                     .hydrate::<FROM_SERVER>(cursor, position)
764: 762:             }
765: 763: 
766: 764:             fn into_owned(self) -> Self::Owned {
767: 765:                 self
768: 766:             }
769: 767:         }
770: 768: 
771: 769:         #[allow(deprecated)]
772: 770:         impl<$($gen),*> AttributeValue for $name<$($gen),*>
773: 771:         where
774: 772:             $v: AttributeValue + Send + Sync + Clone + 'static,
775: 773:             <$v as AttributeValue>::State: 'static,
776: 774:             $($where_clause)*
777: 775:         {
778: 776:             type AsyncOutput = Self;
779: 777:             type State = RenderEffect<<$v as AttributeValue>::State>;
780: 778:             type Cloneable = Self;
781: 779:             type CloneableOwned = Self;
782: 780: 
783: 781:             fn html_len(&self) -> usize {
784: 782:                 0
785: 783:             }
786: 784: 
787: 785:             fn to_html(self, key: &str, buf: &mut String) {
788: 786:                 let value = self.get();
789: 787:                 value.to_html(key, buf);
790: 788:             }
791: 789: 
792: 790:             fn to_template(_key: &str, _buf: &mut String) {}
793: 791: 
794: 792:             fn hydrate<const FROM_SERVER: bool>(
795: 793:                 self,
796: 794:                 key: &str,
797: 795:                 el: &crate::renderer::types::Element,
798: 796:             ) -> Self::State {
799: 797:                 (move || self.get()).hydrate::<FROM_SERVER>(key, el)
800: 798:             }
801: 799: 
802: 800:             fn build(
803: 801:                 self,
804: 802:                 el: &crate::renderer::types::Element,
805: 803:                 key: &str,
806: 804:             ) -> Self::State {
807: 805:                 (move || self.get()).build(el, key)
808: 806:             }
809: 807: 
810: 808:             fn rebuild(self, key: &str, state: &mut Self::State) {
811: 809:                 (move || self.get()).rebuild(key, state)
812: 810:             }
813: 811: 
814: 812:             fn into_cloneable(self) -> Self::Cloneable {
815: 813:                 self
816: 814:             }
817: 815: 
818: 816:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
819: 817:                 self
820: 818:             }
821: 819: 
822: 820:             fn dry_resolve(&mut self) {}
823: 821: 
824: 822:             async fn resolve(self) -> Self::AsyncOutput {
825: 823:                 self
826: 824:             }
827: 825:         }
828: 826:     };
829: 827: }
830: 828: 
831: 829: #[cfg(not(feature = "nightly"))]
832: 830: mod stable {
833: 831:     use super::RenderEffectState;
834: 832:     use crate::{
835: 833:         html::attribute::{
836: 834:             any_attribute::AnyAttribute, Attribute, AttributeValue,
837: 835:         },
838: 836:         hydration::Cursor,
839: 837:         ssr::StreamBuilder,
840: 838:         view::{
841: 839:             add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
842: 840:             RenderHtml,
843: 841:         },
844: 842:     };
845: 843:     #[allow(deprecated)]
846: 844:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::MaybeSignal;
847: 845:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
848: 846:         computed::{ArcMemo, Memo},
849: 847:         effect::RenderEffect,
850: 848:         owner::Storage,
851: 849:         signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
852: 850:         traits::Get,
853: 851:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{ArcSignal, Signal},
854: 852:     };
855: 853: 
856: 854:     reactive_impl!(
857: 855:         RwSignal,
858: 856:         <V, S>,
859: 857:         V,
860: 858:         false,
861: 859:         RwSignal<V, S>: Get<Value = V>,
862: 860:         S: Storage<V> + Storage<Option<V>>,
863: 861:         S: Send + Sync + 'static,
864: 862:     );
865: 863:     reactive_impl!(
866: 864:         ReadSignal,
867: 865:         <V, S>,
868: 866:         V,
869: 867:         false,
870: 868:         ReadSignal<V, S>: Get<Value = V>,
871: 869:         S: Storage<V> + Storage<Option<V>>,
872: 870:         S: Send + Sync + 'static,
873: 871:     );
874: 872:     reactive_impl!(
875: 873:         Memo,
876: 874:         <V, S>,
877: 875:         V,
878: 876:         true,
879: 877:         Memo<V, S>: Get<Value = V>,
880: 878:         S: Storage<V> + Storage<Option<V>>,
881: 879:         S: Send + Sync + 'static,
882: 880:     );
883: 881:     reactive_impl!(
884: 882:         Signal,
885: 883:         <V, S>,
886: 884:         V,
887: 885:         true,
888: 886:         Signal<V, S>: Get<Value = V>,
889: 887:         S: Storage<V> + Storage<Option<V>>,
890: 888:         S: Send + Sync + 'static,
891: 889:     );
892: 890:     reactive_impl!(
893: 891:         MaybeSignal,
894: 892:         <V, S>,
895: 893:         V,
896: 894:         true,
897: 895:         MaybeSignal<V, S>: Get<Value = V>,
898: 896:         S: Storage<V> + Storage<Option<V>>,
899: 897:         S: Send + Sync + 'static,
900: 898:     );
901: 899:     reactive_impl!(ArcRwSignal, <V>, V, false, ArcRwSignal<V>: Get<Value = V>);
902: 900:     reactive_impl!(ArcReadSignal, <V>, V, false, ArcReadSignal<V>: Get<Value = V>);
903: 901:     reactive_impl!(ArcMemo, <V>, V, false, ArcMemo<V>: Get<Value = V>);
904: 902:     reactive_impl!(ArcSignal, <V>, V, true, ArcSignal<V>: Get<Value = V>);
905: 903: }
906: 904: 
907: 905: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
908: 906: mod lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores {
909: 907:     use super::RenderEffectState;
910: 908:     use crate::{
911: 909:         html::attribute::{
912: 910:             any_attribute::AnyAttribute, Attribute, AttributeValue,
913: 911:         },
914: 912:         hydration::Cursor,
915: 913:         ssr::StreamBuilder,
916: 914:         view::{
917: 915:             add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
918: 916:             RenderHtml,
919: 917:         },
920: 918:     };
921: 919:     #[allow(deprecated)]
922: 920:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{effect::RenderEffect, owner::Storage, traits::Get};
923: 921:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores::{
924: 922:         ArcField, ArcStore, AtIndex, AtKeyed, DerefedField, Field,
925: 923:         KeyedSubfield, Store, StoreField, Subfield,
926: 924:     };
927: 925:     use std::ops::{Deref, DerefMut, Index, IndexMut};
928: 926: 
929: 927:     reactive_impl!(
930: 928:         Subfield,
931: 929:         <Inner, Prev, V>,
932: 930:         V,
933: 931:         false,
934: 932:         Subfield<Inner, Prev, V>: Get<Value = V>,
935: 933:         Prev: Send + Sync + 'static,
936: 934:         Inner: Send + Sync + Clone + 'static,
937: 935:     );
938: 936: 
939: 937:     reactive_impl!(
940: 938:         AtKeyed,
941: 939:         <Inner, Prev, K, V>,
942: 940:         V,
943: 941:         false,
944: 942:         AtKeyed<Inner, Prev, K, V>: Get<Value = V>,
945: 943:         Prev: Send + Sync + 'static,
946: 944:         Inner: Send + Sync + Clone + 'static,
947: 945:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
948: 946:         for<'a> &'a V: IntoIterator,
949: 947:     );
950: 948: 
951: 949:     reactive_impl!(
952: 950:         KeyedSubfield,
953: 951:         <Inner, Prev, K, V>,
954: 952:         V,
955: 953:         false,
956: 954:         KeyedSubfield<Inner, Prev, K, V>: Get<Value = V>,
957: 955:         Prev: Send + Sync + 'static,
958: 956:         Inner: Send + Sync + Clone + 'static,
959: 957:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
960: 958:         for<'a> &'a V: IntoIterator,
961: 959:     );
962: 960: 
963: 961:     reactive_impl!(
964: 962:         DerefedField,
965: 963:         <S>,
966: 964:         <S::Value as Deref>::Target,
967: 965:         false,
968: 966:         S: Clone + StoreField + Send + Sync + 'static,
969: 967:         <S as StoreField>::Value: Deref + DerefMut
970: 968:     );
971: 969: 
972: 970:     reactive_impl!(
973: 971:         AtIndex,
974: 972:         <Inner, Prev>,
975: 973:         <Prev as Index<usize>>::Output,
976: 974:         false,
977: 975:         AtIndex<Inner, Prev>: Get<Value = Prev::Output>,
978: 976:         Prev: Send + Sync + IndexMut<usize> + 'static,
979: 977:         Inner: Send + Sync + Clone + 'static,
980: 978:     );
981: 979:     reactive_impl!(
982: 980:         Store,
983: 981:         <V, S>,
984: 982:         V,
985: 983:         false,
986: 984:         Store<V, S>: Get<Value = V>,
987: 985:         S: Storage<V> + Storage<Option<V>>,
988: 986:         S: Send + Sync + 'static,
989: 987:     );
990: 988:     reactive_impl!(
991: 989:         Field,
992: 990:         <V, S>,
993: 991:         V,
994: 992:         false,
995: 993:         Field<V, S>: Get<Value = V>,
996: 994:         S: Storage<V> + Storage<Option<V>>,
997: 995:         S: Send + Sync + 'static,
998: 996:     );
999: 997:     reactive_impl!(ArcStore, <V>, V, false, ArcStore<V>: Get<Value = V>);
1000: 998:     reactive_impl!(ArcField, <V>, V, false, ArcField<V>: Get<Value = V>);
1001: 999: }
1002: 1000: 
1003: 1001: /*
1004: 1002: #[cfg(test)]
1005: 1003: mod tests {
1006: 1004:     use crate::{
1007: 1005:         html::element::{button, main, HtmlElement},
1008: 1006:         renderer::mock_dom::MockDom,
1009: 1007:         view::Render,
1010: 1008:     };
1011: 1009:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::{create_runtime, RwSignal, SignalGet, SignalSet};
1012: 1010: 
1013: 1011:     #[test]
1014: 1012:     fn create_dynamic_element() {
1015: 1013:         let rt = create_runtime();
1016: 1014:         let count = RwSignal::new(0);
1017: 1015:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app: HtmlElement<_, _, _, MockDom> =
1018: 1016:             button((), move || count.get().to_string());
1019: 1017:         let el = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.build();
1020: 1018:         assert_eq!(el.el.to_debug_html(), "<button>0</button>");
1021: 1019:         rt.dispose();
1022: 1020:     }
1023: 1021: 
1024: 1022:     #[test]
1025: 1023:     fn update_dynamic_element() {
1026: 1024:         let rt = create_runtime();
1027: 1025:         let count = RwSignal::new(0);
1028: 1026:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app: HtmlElement<_, _, _, MockDom> =
1029: 1027:             button((), move || count.get().to_string());
1030: 1028:         let el = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.build();
1031: 1029:         assert_eq!(el.el.to_debug_html(), "<button>0</button>");
1032: 1030:         count.set(1);
1033: 1031:         assert_eq!(el.el.to_debug_html(), "<button>1</button>");
1034: 1032:         rt.dispose();
1035: 1033:     }
1036: 1034: 
1037: 1035:     #[test]
1038: 1036:     fn update_dynamic_element_among_siblings() {
1039: 1037:         let rt = create_runtime();
1040: 1038:         let count = RwSignal::new(0);
1041: 1039:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app: HtmlElement<_, _, _, MockDom> = main(
1042: 1040:             (),
1043: 1041:             button(
1044: 1042:                 (),
1045: 1043:                 ("Hello, my ", move || count.get().to_string(), " friends."),
1046: 1044:             ),
1047: 1045:         );
1048: 1046:         let el = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.build();
1049: 1047:         assert_eq!(
1050: 1048:             el.el.to_debug_html(),
1051: 1049:             "<main><button>Hello, my 0 friends.</button></main>"
1052: 1050:         );
1053: 1051:         count.set(42);
1054: 1052:         assert_eq!(
1055: 1053:             el.el.to_debug_html(),
1056: 1054:             "<main><button>Hello, my 42 friends.</button></main>"
1057: 1055:         );
1058: 1056:         rt.dispose();
1059: 1057:     }
1060: 1058: }
1061: 1059:  */
1062: 1060: ```
1063: 1061: ```
1064: 1062: ```
1065: 1063: ```
1066: 1064: ```
1067: 1065: ```
1068: 1066: ```
1069: 1067: ```
1070: ```
```
