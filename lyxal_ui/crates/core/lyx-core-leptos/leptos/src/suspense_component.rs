### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\suspense_component.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\suspense_component.rs
2: ```rust
3: 1: use crate::{
4: 2:     children::{TypedChildren, ViewFnOnce},
5: 3:     error::ErrorBoundarySuspendedChildren,
6: 4:     IntoView,
7: 5: };
8: 6: use futures::{channel::oneshot, select, FutureExt};
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_hydration_context::SerializedDataId;
10: 8: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::component;
11: 9: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
13: 11:     computed::{
14: 12:         suspense::{LocalResourceNotifier, SuspenseContext},
15: 13:         ArcMemo, ScopedFuture,
16: 14:     },
17: 15:     effect::RenderEffect,
18: 16:     owner::{provide_context, use_context, Owner},
19: 17:     signal::ArcRwSignal,
20: 18:     traits::{
21: 19:         Dispose, Get, Read, ReadUntracked, Track, With, WithUntracked,
22: 20:         WriteValue,
23: 21:     },
24: 22: };
25: 23: use slotmap::{DefaultKey, SlotMap};
26: 24: use std::sync::{Arc, Mutex};
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
28: 26:     either::Either,
29: 27:     html::attribute::{any_attribute::AnyAttribute, Attribute},
30: 28:     hydration::Cursor,
31: 29:     lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{OwnedView, OwnedViewState},
32: 30:     ssr::StreamBuilder,
33: 31:     view::{
34: 32:         add_attr::AddAnyAttr,
35: 33:         either::{EitherKeepAlive, EitherKeepAliveState},
36: 34:         Mountable, Position, PositionState, Render, RenderHtml,
37: 35:     },
38: 36: };
39: 37: use lyx-core-any_error::ErrorHookFuture;
40: 38: 
41: 39: /// If any [`Resource`](crate::prelude::Resource) is read in the `children` of this
42: 40: /// component, it will show the `fallback` while they are loading. Once all are resolved,
43: 41: /// it will render the `children`.
44: 42: ///
45: 43: /// Each time one of the resources is loading again, it will fall back. To keep the current
46: 44: /// children instead, use [Transition](crate::prelude::Transition).
47: 45: ///
48: 46: /// Note that the `children` will be rendered initially (in order to capture the fact that
49: 47: /// those resources are read under the suspense), so you cannot assume that resources read
50: 48: /// synchronously have
51: 49: /// `Some` value in `children`. However, you can read resources asynchronously by using
52: 50: /// [Suspend](crate::prelude::Suspend).
53: 51: ///
54: 52: /// ```
55: 53: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
56: 54: /// # if false { // don't run in doctests
57: 55: /// async fn fetch_cats(how_many: u32) -> Vec<String> { vec![] }
58: 56: ///
59: 57: /// let (cat_count, set_cat_count) = signal::<u32>(1);
60: 58: ///
61: 59: /// let cats = Resource::new(move || cat_count.get(), |count| fetch_cats(count));
62: 60: ///
63: 61: /// view! {
64: 62: ///   <div>
65: 63: ///     <Suspense fallback=move || view! { <p>"Loading (Suspense Fallback)..."</p> }>
66: 64: ///       // you can access a resource synchronously
67: 65: ///       {move || {
68: 66: ///           cats.get().map(|data| {
69: 67: ///             data
70: 68: ///               .into_iter()
71: 69: ///               .map(|src| {
72: 70: ///                   view! {
73: 71: ///                     <img src={src}/>
74: 72: ///                   }
75: 73: ///               })
76: 74: ///               .collect_view()
77: 75: ///           })
78: 76: ///         }
79: 77: ///       }
80: 78: ///       // or you can use `Suspend` to read resources asynchronously
81: 79: ///       {move || Suspend::new(async move {
82: 80: ///         cats.await
83: 81: ///               .into_iter()
84: 82: ///               .map(|src| {
85: 83: ///                   view! {
86: 84: ///                     <img src={src}/>
87: 85: ///                   }
88: 86: ///               })
89: 87: ///               .collect_view()
90: 88: ///       })}
91: 89: ///     </Suspense>
92: 90: ///   </div>
93: 91: /// }
94: 92: /// # ;}
95: 93: /// ```
96: 94: #[component]
97: 95: pub fn Suspense<Chil>(
98: 96:     /// A function that returns a fallback that will be shown while resources are still loading.
99: 97:     /// By default this is an empty view.
100: 98:     #[prop(optional, into)]
101: 99:     fallback: ViewFnOnce,
102: 100:     /// Children will be rendered once initially to catch any resource reads, then hidden until all
103: 101:     /// data have loaded.
104: 102:     children: TypedChildren<Chil>,
105: 103: ) -> impl IntoView
106: 104: where
107: 105:     Chil: IntoView + Send + 'static,
108: 106: {
109: 107:     let error_boundary_parent = use_context::<ErrorBoundarySuspendedChildren>();
110: 108: 
111: 109:     let owner = Owner::new();
112: 110:     owner.with(|| {
113: 111:         let (starts_local, id) = {
114: 112:             Owner::current_shared_context()
115: 113:                 .map(|sc| {
116: 114:                     let id = sc.next_id();
117: 115:                     (sc.get_incomplete_chunk(&id), id)
118: 116:                 })
119: 117:                 .unwrap_or_else(|| (false, Default::default()))
120: 118:         };
121: 119:         let fallback = fallback.run();
122: 120:         let children = children.into_inner()();
123: 121:         let tasks = ArcRwSignal::new(SlotMap::<DefaultKey, ()>::new());
124: 122:         provide_context(SuspenseContext {
125: 123:             tasks: tasks.clone(),
126: 124:         });
127: 125:         let none_pending = ArcMemo::new({
128: 126:             let tasks = tasks.clone();
129: 127:             move |prev: Option<&bool>| {
130: 128:                 tasks.track();
131: 129:                 if prev.is_none() && starts_local {
132: 130:                     false
133: 131:                 } else {
134: 132:                     tasks.with(SlotMap::is_empty)
135: 133:                 }
136: 134:             }
137: 135:         });
138: 136:         let has_tasks =
139: 137:             Arc::new(move || !tasks.with_untracked(SlotMap::is_empty));
140: 138: 
141: 139:         OwnedView::new(SuspenseBoundary::<false, _, _> {
142: 140:             id,
143: 141:             none_pending,
144: 142:             fallback,
145: 143:             children,
146: 144:             error_boundary_parent,
147: 145:             has_tasks,
148: 146:         })
149: 147:     })
150: 148: }
151: 149: 
152: 150: fn nonce_or_not() -> Option<Arc<str>> {
153: 151:     #[cfg(feature = "nonce")]
154: 152:     {
155: 153:         use crate::nonce::Nonce;
156: 154:         use_context::<Nonce>().map(|n| n.0)
157: 155:     }
158: 156:     #[cfg(not(feature = "nonce"))]
159: 157:     {
160: 158:         None
161: 159:     }
162: 160: }
163: 161: 
164: 162: pub(crate) struct SuspenseBoundary<const TRANSITION: bool, Fal, Chil> {
165: 163:     pub id: SerializedDataId,
166: 164:     pub none_pending: ArcMemo<bool>,
167: 165:     pub fallback: Fal,
168: 166:     pub children: Chil,
169: 167:     pub error_boundary_parent: Option<ErrorBoundarySuspendedChildren>,
170: 168:     pub has_tasks: Arc<dyn Fn() -> bool + Send + Sync>,
171: 169: }
172: 170: 
173: 171: impl<const TRANSITION: bool, Fal, Chil> Render
174: 172:     for SuspenseBoundary<TRANSITION, Fal, Chil>
175: 173: where
176: 174:     Fal: Render + Send + 'static,
177: 175:     Chil: Render + Send + 'static,
178: 176: {
179: 177:     type State = RenderEffect<
180: 178:         OwnedViewState<EitherKeepAliveState<Chil::State, Fal::State>>,
181: 179:     >;
182: 180: 
183: 181:     fn build(self) -> Self::State {
184: 182:         let mut children = Some(self.children);
185: 183:         let mut fallback = Some(self.fallback);
186: 184:         let none_pending = self.none_pending;
187: 185:         let mut nth_run = 0;
188: 186:         let outer_owner = Owner::new();
189: 187: 
190: 188:         RenderEffect::new(move |prev| {
191: 189:             // show the fallback if
192: 190:             // 1) there are pending futures, and
193: 191:             // 2) we are either in a Suspense (not Transition), or it's the first fallback
194: 192:             //    (because we initially render the children to register Futures, the "first
195: 193:             //    fallback" is probably the 2nd run
196: 194:             let show_b = !none_pending.get() && (!TRANSITION || nth_run < 2);
197: 195:             nth_run += 1;
198: 196:             let this = OwnedView::new_with_owner(
199: 197:                 EitherKeepAlive {
200: 198:                     a: children.take(),
201: 199:                     b: fallback.take(),
202: 200:                     show_b,
203: 201:                 },
204: 202:                 outer_owner.clone(),
205: 203:             );
206: 204: 
207: 205:             let state = if let Some(mut state) = prev {
208: 206:                 this.rebuild(&mut state);
209: 207:                 state
210: 208:             } else {
211: 209:                 this.build()
212: 210:             };
213: 211: 
214: 212:             if nth_run == 1 && !(self.has_tasks)() {
215: 213:                 // if this is the first run, and there are no pending resources at this point,
216: 214:                 // it means that there were no actually-async resources read while rendering the children
217: 215:                 // this means that we're effectively on the settled second run: none_pending
218: 216:                 // won't change false => true and cause this to rerender (and therefore increment nth_run)
219: 217:                 //
220: 218:                 // we increment it manually here so that future resource changes won't cause the transition fallback
221: 219:                 // to be displayed for the first time
222: 220:                 // see https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/3868, https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/4492
223: 221:                 nth_run += 1;
224: 222:             }
225: 223: 
226: 224:             state
227: 225:         })
228: 226:     }
229: 227: 
230: 228:     fn rebuild(self, state: &mut Self::State) {
231: 229:         let new = self.build();
232: 230:         let mut old = std::mem::replace(state, new);
233: 231:         old.insert_before_this(state);
234: 232:         old.unmount();
235: 233:     }
236: 234: }
237: 235: 
238: 236: impl<const TRANSITION: bool, Fal, Chil> AddAnyAttr
239: 237:     for SuspenseBoundary<TRANSITION, Fal, Chil>
240: 238: where
241: 239:     Fal: RenderHtml + Send + 'static,
242: 240:     Chil: RenderHtml + Send + 'static,
243: 241: {
244: 242:     type Output<SomeNewAttr: Attribute> = SuspenseBoundary<
245: 243:         TRANSITION,
246: 244:         Fal,
247: 245:         Chil::Output<SomeNewAttr::CloneableOwned>,
248: 246:     >;
249: 247: 
250: 248:     fn add_any_attr<NewAttr: Attribute>(
251: 249:         self,
252: 250:         attr: NewAttr,
253: 251:     ) -> Self::Output<NewAttr>
254: 252:     where
255: 253:         Self::Output<NewAttr>: RenderHtml,
256: 254:     {
257: 255:         let attr = attr.into_cloneable_owned();
258: 256:         let SuspenseBoundary {
259: 257:             id,
260: 258:             none_pending,
261: 259:             fallback,
262: 260:             children,
263: 261:             error_boundary_parent,
264: 262:             has_tasks,
265: 263:         } = self;
266: 264:         SuspenseBoundary {
267: 265:             id,
268: 266:             none_pending,
269: 267:             fallback,
270: 268:             children: children.add_any_attr(attr),
271: 269:             error_boundary_parent,
272: 270:             has_tasks,
273: 271:         }
274: 272:     }
275: 273: }
276: 274: 
277: 275: impl<const TRANSITION: bool, Fal, Chil> RenderHtml
278: 276:     for SuspenseBoundary<TRANSITION, Fal, Chil>
279: 277: where
280: 278:     Fal: RenderHtml + Send + 'static,
281: 279:     Chil: RenderHtml + Send + 'static,
282: 280: {
283: 281:     // i.e., if this is the child of another Suspense during SSR, don't wait for it: it will handle
284: 282:     // itself
285: 283:     type AsyncOutput = Self;
286: 284:     type Owned = Self;
287: 285: 
288: 286:     const MIN_LENGTH: usize = Chil::MIN_LENGTH;
289: 287: 
290: 288:     fn dry_resolve(&mut self) {}
291: 289: 
292: 290:     async fn resolve(self) -> Self::AsyncOutput {
293: 291:         self
294: 292:     }
295: 293: 
296: 294:     fn to_html_with_buf(
297: 295:         self,
298: 296:         buf: &mut String,
299: 297:         position: &mut Position,
300: 298:         escape: bool,
301: 299:         mark_branches: bool,
302: 300:         extra_attrs: Vec<AnyAttribute>,
303: 301:     ) {
304: 302:         self.fallback.to_html_with_buf(
305: 303:             buf,
306: 304:             position,
307: 305:             escape,
308: 306:             mark_branches,
309: 307:             extra_attrs,
310: 308:         );
311: 309:     }
312: 310: 
313: 311:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
314: 312:         mut self,
315: 313:         buf: &mut StreamBuilder,
316: 314:         position: &mut Position,
317: 315:         escape: bool,
318: 316:         mark_branches: bool,
319: 317:         extra_attrs: Vec<AnyAttribute>,
320: 318:     ) where
321: 319:         Self: Sized,
322: 320:     {
323: 321:         buf.next_id();
324: 322:         let suspense_context = use_context::<SuspenseContext>().unwrap();
325: 323:         let owner = Owner::current().unwrap();
326: 324: 
327: 325:         let mut notify_error_boundary =
328: 326:             self.error_boundary_parent.map(|children| {
329: 327:                 let (tx, rx) = oneshot::channel();
330: 328:                 children.write_value().push(rx);
331: 329:                 tx
332: 330:             });
333: 331: 
334: 332:         // we need to wait for one of two things: either
335: 333:         // 1. all tasks are finished loading, or
336: 334:         // 2. we read from a local resource, meaning this Suspense can never resolve on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
337: 335: 
338: 336:         // first, create listener for tasks
339: 337:         let tasks = suspense_context.tasks.clone();
340: 338:         let (tasks_tx, mut tasks_rx) =
341: 339:             futures::channel::oneshot::channel::<()>();
342: 340: 
343: 341:         let mut tasks_tx = Some(tasks_tx);
344: 342: 
345: 343:         // now, create listener for local resources
346: 344:         let (local_tx, mut local_rx) =
347: 345:             futures::channel::oneshot::channel::<()>();
348: 346:         provide_context(LocalResourceNotifier::from(local_tx));
349: 347: 
350: 348:         // walk over the tree of children once to make sure that all resource loads are registered
351: 349:         self.children.dry_resolve();
352: 350:         let children = Arc::new(Mutex::new(Some(self.children)));
353: 351: 
354: 352:         // check the set of tasks to see if it is empty, now or later
355: 353:         let eff = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect::new_isomorphic({
356: 354:             let children = Arc::clone(&children);
357: 355:             move |double_checking: Option<bool>| {
358: 356:                 // on the first run, always track the tasks
359: 357:                 if double_checking.is_none() {
360: 358:                     tasks.track();
361: 359:                 }
362: 360: 
363: 361:                 if let Some(curr_tasks) = tasks.try_read_untracked() {
364: 362:                     if curr_tasks.is_empty() {
365: 363:                         if double_checking == Some(true) {
366: 364:                             // we have finished loading, and checking the children again told us there are
367: 365:                             // no more pending tasks. so we can render both the children and the error boundary
368: 366: 
369: 367:                             if let Some(tx) = tasks_tx.take() {
370: 368:                                 // If the receiver has dropped, it means the ScopedFuture has already
371: 369:                                 // dropped, so it doesn't matter if we manage to send this.
372: 370:                                 _ = tx.send(());
373: 371:                             }
374: 372:                             if let Some(tx) = notify_error_boundary.take() {
375: 373:                                 _ = tx.send(());
376: 374:                             }
377: 375:                         } else {
378: 376:                             // release the read guard on tasks, as we'll be updating it again
379: 377:                             drop(curr_tasks);
380: 378:                             // check the children for additional pending tasks
381: 379:                             // the will catch additional resource reads nested inside a conditional depending on initial resource reads
382: 380:                             if let Some(children) =
383: 381:                                 children.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().as_mut()
384: 382:                             {
385: 383:                                 children.dry_resolve();
386: 384:                             }
387: 385: 
388: 386:                             if tasks
389: 387:                                 .try_read()
390: 388:                                 .map(|n| n.is_empty())
391: 389:                                 .unwrap_or(false)
392: 390:                             {
393: 391:                                 // there are no additional pending tasks, and we can simply return
394: 392:                                 if let Some(tx) = tasks_tx.take() {
395: 393:                                     // If the receiver has dropped, it means the ScopedFuture has already
396: 394:                                     // dropped, so it doesn't matter if we manage to send this.
397: 395:                                     _ = tx.send(());
398: 396:                                 }
399: 397:                                 if let Some(tx) = notify_error_boundary.take() {
400: 398:                                     _ = tx.send(());
401: 399:                                 }
402: 400:                             }
403: 401: 
404: 402:                             // tell ourselves that we're just double-checking
405: 403:                             return true;
406: 404:                         }
407: 405:                     } else {
408: 406:                         tasks.track();
409: 407:                     }
410: 408:                 }
411: 409:                 false
412: 410:             }
413: 411:         });
414: 412: 
415: 413:         let mut fut = Box::pin(ScopedFuture::new(ErrorHookFuture::new(
416: 414:             async move {
417: 415:                 // race the local resource notifier against the set of tasks
418: 416:                 //
419: 417:                 // if there are local resources, we just return the fallback immediately
420: 418:                 //
421: 419:                 // otherwise, we want to wait for resources to load before trying to resolve the body
422: 420:                 //
423: 421:                 // this is *less efficient* than just resolving the body
424: 422:                 // however, it means that you can use reactive accesses to resources/async derived
425: 423:                 // inside component props, at any level, and have those picked up by Suspense, and
426: 424:                 // that it will wait for those to resolve
427: 425:                 select! {
428: 426:                     // if there are local resources, bail
429: 427:                     // this will only have fired by this point for local resources accessed
430: 428:                     // *synchronously*
431: 429:                     _ = local_rx => {
432: 430:                         let sc = Owner::current_shared_context().expect("no shared context");
433: 431:                         sc.set_incomplete_chunk(self.id);
434: 432:                         None
435: 433:                     }
436: 434:                     _ = tasks_rx => {
437: 435:                         let children = {
438: 436:                             let mut children_lock = children.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
439: 437:                             children_lock.take().expect("children should not be removed until we render here")
440: 438:                         };
441: 439: 
442: 440:                         // if we ran this earlier, reactive reads would always be registered as None
443: 441:                         // this is fine in the case where we want to use Suspend and .await on some future
444: 442:                         // but in situations like a <For each=|| some_resource.snapshot()/> we actually
445: 443:                         // want to be able to 1) synchronously read a resource's value, but still 2) wait
446: 444:                         // for it to load before we render everything
447: 445:                         let mut children = Box::pin(children.resolve().fuse());
448: 446: 
449: 447:                         // we continue racing the children against the "do we have any local
450: 448:                         // resources?" Future
451: 449:                         select! {
452: 450:                             _ = local_rx => {
453: 451:                                 let sc = Owner::current_shared_context().expect("no shared context");
454: 452:                                 sc.set_incomplete_chunk(self.id);
455: 453:                                 None
456: 454:                             }
457: 455:                             children = children => {
458: 456:                                 // clean up the (now useless) effect
459: 457:                                 eff.dispose();
460: 458: 
461: 459:                                 Some(OwnedView::new_with_owner(children, owner))
462: 460:                             }
463: 461:                         }
464: 462:                     }
465: 463:                 }
466: 464:             },
467: 465:         )));
468: 466:         match fut.as_mut().now_or_never() {
469: 467:             Some(Some(resolved)) => {
470: 468:                 Either::<Fal, _>::Right(resolved)
471: 469:                     .to_html_async_with_buf::<OUT_OF_ORDER>(
472: 470:                         buf,
473: 471:                         position,
474: 472:                         escape,
475: 473:                         mark_branches,
476: 474:                         extra_attrs,
477: 475:                     );
478: 476:             }
479: 477:             Some(None) => {
480: 478:                 Either::<_, Chil>::Left(self.fallback)
481: 479:                     .to_html_async_with_buf::<OUT_OF_ORDER>(
482: 480:                         buf,
483: 481:                         position,
484: 482:                         escape,
485: 483:                         mark_branches,
486: 484:                         extra_attrs,
487: 485:                     );
488: 486:             }
489: 487:             None => {
490: 488:                 let id = buf.clone_id();
491: 489: 
492: 490:                 // out-of-order streams immediately push fallback,
493: 491:                 // wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped by suspense markers
494: 492:                 if OUT_OF_ORDER {
495: 493:                     let mut fallback_position = *position;
496: 494:                     buf.push_fallback(
497: 495:                         self.fallback,
498: 496:                         &mut fallback_position,
499: 497:                         mark_branches,
500: 498:                         extra_attrs.clone(),
501: 499:                     );
502: 500:                     buf.push_async_out_of_order_with_nonce(
503: 501:                         fut,
504: 502:                         position,
505: 503:                         mark_branches,
506: 504:                         nonce_or_not(),
507: 505:                         extra_attrs,
508: 506:                     );
509: 507:                 } else {
510: 508:                     // calling this will walk over the tree, removing all event listeners
511: 509:                     // and other single-threaded values from the view tree. this needs to be
512: 510:                     // done because the fallback can be shifted to another thread in push_async below.
513: 511:                     self.fallback.dry_resolve();
514: 512: 
515: 513:                     buf.push_async({
516: 514:                         let mut position = *position;
517: 515:                         async move {
518: 516:                             let value = match fut.await {
519: 517:                                 None => Either::Left(self.fallback),
520: 518:                                 Some(value) => Either::Right(value),
521: 519:                             };
522: 520:                             let mut builder = StreamBuilder::new(id);
523: 521:                             value.to_html_async_with_buf::<OUT_OF_ORDER>(
524: 522:                                 &mut builder,
525: 523:                                 &mut position,
526: 524:                                 escape,
527: 525:                                 mark_branches,
528: 526:                                 extra_attrs,
529: 527:                             );
530: 528:                             builder.finish().take_chunks()
531: 529:                         }
532: 530:                     });
533: 531:                     *position = Position::NextChild;
534: 532:                 }
535: 533:             }
536: 534:         };
537: 535:     }
538: 536: 
539: 537:     fn hydrate<const FROM_SERVER: bool>(
540: 538:         self,
541: 539:         cursor: &Cursor,
542: 540:         position: &PositionState,
543: 541:     ) -> Self::State {
544: 542:         let cursor = cursor.to_owned();
545: 543:         let position = position.to_owned();
546: 544: 
547: 545:         let mut children = Some(self.children);
548: 546:         let mut fallback = Some(self.fallback);
549: 547:         let none_pending = self.none_pending;
550: 548:         let mut nth_run = 0;
551: 549:         let outer_owner = Owner::new();
552: 550: 
553: 551:         RenderEffect::new(move |prev| {
554: 552:             // show the fallback if
555: 553:             // 1) there are pending futures, and
556: 554:             // 2) we are either in a Suspense (not Transition), or it's the first fallback
557: 555:             //    (because we initially render the children to register Futures, the "first
558: 556:             //    fallback" is probably the 2nd run
559: 557:             let show_b = !none_pending.get() && (!TRANSITION || nth_run < 1);
560: 558:             nth_run += 1;
561: 559:             let this = OwnedView::new_with_owner(
562: 560:                 EitherKeepAlive {
563: 561:                     a: children.take(),
564: 562:                     b: fallback.take(),
565: 563:                     show_b,
566: 564:                 },
567: 565:                 outer_owner.clone(),
568: 566:             );
569: 567: 
570: 568:             if let Some(mut state) = prev {
571: 569:                 this.rebuild(&mut state);
572: 570:                 state
573: 571:             } else {
574: 572:                 this.hydrate::<FROM_SERVER>(&cursor, &position)
575: 573:             }
576: 574:         })
577: 575:     }
578: 576: 
579: 577:     fn into_owned(self) -> Self::Owned {
580: 578:         self
581: 579:     }
582: 580: }
583: 581: 
584: 582: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper that prevents [`Suspense`] from waiting for any resource reads that hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen inside
585: 583: /// `Unsuspend`.
586: 584: pub struct Unsuspend<T>(Box<dyn FnOnce() -> T + Send>);
587: 585: 
588: 586: impl<T> Unsuspend<T> {
589: 587:     /// Wraps the given function, such that it is not called until all resources are ready.
590: 588:     pub fn new(fun: impl FnOnce() -> T + Send + 'static) -> Self {
591: 589:         Self(Box::new(fun))
592: 590:     }
593: 591: }
594: 592: 
595: 593: impl<T> Render for Unsuspend<T>
596: 594: where
597: 595:     T: Render,
598: 596: {
599: 597:     type State = T::State;
600: 598: 
601: 599:     fn build(self) -> Self::State {
602: 600:         (self.0)().build()
603: 601:     }
604: 602: 
605: 603:     fn rebuild(self, state: &mut Self::State) {
606: 604:         (self.0)().rebuild(state);
607: 605:     }
608: 606: }
609: 607: 
610: 608: impl<T> AddAnyAttr for Unsuspend<T>
611: 609: where
612: 610:     T: AddAnyAttr + 'static,
613: 611: {
614: 612:     type Output<SomeNewAttr: Attribute> =
615: 613:         Unsuspend<T::Output<SomeNewAttr::CloneableOwned>>;
616: 614: 
617: 615:     fn add_any_attr<NewAttr: Attribute>(
618: 616:         self,
619: 617:         attr: NewAttr,
620: 618:     ) -> Self::Output<NewAttr>
621: 619:     where
622: 620:         Self::Output<NewAttr>: RenderHtml,
623: 621:     {
624: 622:         let attr = attr.into_cloneable_owned();
625: 623:         Unsuspend::new(move || (self.0)().add_any_attr(attr))
626: 624:     }
627: 625: }
628: 626: 
629: 627: impl<T> RenderHtml for Unsuspend<T>
630: 628: where
631: 629:     T: RenderHtml + 'static,
632: 630: {
633: 631:     type AsyncOutput = Self;
634: 632:     type Owned = Self;
635: 633: 
636: 634:     const MIN_LENGTH: usize = T::MIN_LENGTH;
637: 635: 
638: 636:     fn dry_resolve(&mut self) {}
639: 637: 
640: 638:     async fn resolve(self) -> Self::AsyncOutput {
641: 639:         self
642: 640:     }
643: 641: 
644: 642:     fn to_html_with_buf(
645: 643:         self,
646: 644:         buf: &mut String,
647: 645:         position: &mut Position,
648: 646:         escape: bool,
649: 647:         mark_branches: bool,
650: 648:         extra_attrs: Vec<AnyAttribute>,
651: 649:     ) {
652: 650:         (self.0)().to_html_with_buf(
653: 651:             buf,
654: 652:             position,
655: 653:             escape,
656: 654:             mark_branches,
657: 655:             extra_attrs,
658: 656:         );
659: 657:     }
660: 658: 
661: 659:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
662: 660:         self,
663: 661:         buf: &mut StreamBuilder,
664: 662:         position: &mut Position,
665: 663:         escape: bool,
666: 664:         mark_branches: bool,
667: 665:         extra_attrs: Vec<AnyAttribute>,
668: 666:     ) where
669: 667:         Self: Sized,
670: 668:     {
671: 669:         (self.0)().to_html_async_with_buf::<OUT_OF_ORDER>(
672: 670:             buf,
673: 671:             position,
674: 672:             escape,
675: 673:             mark_branches,
676: 674:             extra_attrs,
677: 675:         );
678: 676:     }
679: 677: 
680: 678:     fn hydrate<const FROM_SERVER: bool>(
681: 679:         self,
682: 680:         cursor: &Cursor,
683: 681:         position: &PositionState,
684: 682:     ) -> Self::State {
685: 683:         (self.0)().hydrate::<FROM_SERVER>(cursor, position)
686: 684:     }
687: 685: 
688: 686:     fn into_owned(self) -> Self::Owned {
689: 687:         self
690: 688:     }
691: 689: }
692: ```
```
