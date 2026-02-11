### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\suspense.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\suspense.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::attribute::{any_attribute::AnyAttribute, Attribute},
21: 19:     hydration::Cursor,
22: 20:     ssr::StreamBuilder,
23: 21:     view::{
24: 22:         add_attr::AddAnyAttr, iterators::OptionState, Mountable, Position,
25: 23:         PositionState, Render, RenderHtml,
26: 24:     },
27: 25: };
28: 26: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
29: 27: use futures::{
30: 28:     future::{AbortHandle, Abortable},
31: 29:     select, FutureExt,
32: 30: };
33: 31: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
34: 32: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
35: 33:     computed::{
36: 34:         suspense::{LocalResourceNotifier, SuspenseContext},
37: 35:         ScopedFuture,
38: 36:     },
39: 37:     graph::{
40: 38:         AnySource, AnySubscriber, Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, ReactiveNode, Source, Subscriber,
41: 39:         ToAnySubscriber, WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
42: 40:     },
43: 41:     owner::{on_cleanup, provide_context, use_context},
44: 42: };
45: 43: use std::{
46: 44:     cell::RefCell,
47: 45:     fmt::Debug,
48: 46:     future::{Future, IntoFuture},
49: 47:     mem,
50: 48:     pin::Pin,
51: 49:     rc::Rc,
52: 50:     sync::{Arc, Mutex, Weak},
53: 51: };
54: 52: use lyx-core-any_error::ErrorHook;
55: 53: 
56: 54: /// A suspended `Future`, which can be used in the view.
57: 55: pub struct Suspend<T> {
58: 56:     pub(crate) subscriber: SuspendSubscriber,
59: 57:     pub(crate) inner: Pin<Box<dyn Future<Output = T> + Send>>,
60: 58: }
61: 59: 
62: 60: #[derive(Debug, Clone)]
63: 61: pub(crate) struct SuspendSubscriber {
64: 62:     inner: Arc<SuspendSubscriberInner>,
65: 63: }
66: 64: 
67: 65: #[derive(Debug)]
68: 66: struct SuspendSubscriberInner {
69: 67:     outer_subscriber: Option<AnySubscriber>,
70: 68:     sources: Mutex<Vec<AnySource>>,
71: 69: }
72: 70: 
73: 71: impl SuspendSubscriber {
74: 72:     pub fn new() -> Self {
75: 73:         let outer_subscriber = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::get();
76: 74:         Self {
77: 75:             inner: Arc::new(SuspendSubscriberInner {
78: 76:                 outer_subscriber,
79: 77:                 sources: Default::default(),
80: 78:             }),
81: 79:         }
82: 80:     }
83: 81: 
84: 82:     /// Re-links all reactive sources from this to another subscriber.
85: 83:     ///
86: 84:     /// This is used to collect reactive dependencies during the rendering phase, and only later
87: 85:     /// connect them to any outer effect, to prevent the completion of async resources from
88: 86:     /// triggering the render effect to run a second time.
89: 87:     pub fn forward(&self) {
90: 88:         if let Some(to) = &self.inner.outer_subscriber {
91: 89:             let sources =
92: 90:                 mem::take(&mut *self.inner.sources.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned());
93: 91:             for source in sources {
94: 92:                 source.add_subscriber(to.clone());
95: 93:                 to.add_source(source);
96: 94:             }
97: 95:         }
98: 96:     }
99: 97: }
100: 98: 
101: 99: impl ReactiveNode for SuspendSubscriberInner {
102: 100:     fn mark_dirty(&self) {}
103: 101: 
104: 102:     fn mark_check(&self) {}
105: 103: 
106: 104:     fn mark_subscribers_check(&self) {}
107: 105: 
108: 106:     fn update_if_necessary(&self) -> bool {
109: 107:         false
110: 108:     }
111: 109: }
112: 110: 
113: 111: impl Subscriber for SuspendSubscriberInner {
114: 112:     fn add_source(&self, source: AnySource) {
115: 113:         self.sources.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().push(source);
116: 114:     }
117: 115: 
118: 116:     fn clear_sources(&self, subscriber: &AnySubscriber) {
119: 117:         for source in mem::take(&mut *self.sources.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()) {
120: 118:             source.remove_subscriber(subscriber);
121: 119:         }
122: 120:     }
123: 121: }
124: 122: 
125: 123: impl ToAnySubscriber for SuspendSubscriber {
126: 124:     fn to_any_subscriber(&self) -> AnySubscriber {
127: 125:         AnySubscriber(
128: 126:             Arc::as_ptr(&self.inner) as usize,
129: 127:             Arc::downgrade(&self.inner) as Weak<dyn Subscriber + Send + Sync>,
130: 128:         )
131: 129:     }
132: 130: }
133: 131: 
134: 132: impl<T> Suspend<T> {
135: 133:     /// Creates a new suspended view.
136: 134:     pub fn new<Fut>(fut: Fut) -> Self
137: 135:     where
138: 136:         Fut: IntoFuture<Output = T>,
139: 137:         Fut::IntoFuture: Send + 'static,
140: 138:     {
141: 139:         let subscriber = SuspendSubscriber::new();
142: 140:         let any_subscriber = subscriber.to_any_subscriber();
143: 141:         let inner = any_subscriber
144: 142:             .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| Box::pin(ScopedFuture::new(fut.into_future())));
145: 143:         Self { subscriber, inner }
146: 144:     }
147: 145: }
148: 146: 
149: 147: impl<T> Debug for Suspend<T> {
150: 148:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
151: 149:         f.debug_struct("Suspend").finish()
152: 150:     }
153: 151: }
154: 152: 
155: 153: /// Retained view state for [`Suspend`].
156: 154: pub struct SuspendState<T>
157: 155: where
158: 156:     T: Render,
159: 157: {
160: 158:     inner: Rc<RefCell<OptionState<T>>>,
161: 159: }
162: 160: 
163: 161: impl<T> Mountable for SuspendState<T>
164: 162: where
165: 163:     T: Render,
166: 164: {
167: 165:     fn unmount(&mut self) {
168: 166:         self.inner.borrow_mut().unmount();
169: 167:     }
170: 168: 
171: 169:     fn mount(
172: 170:         &mut self,
173: 171:         parent: &crate::renderer::types::Element,
174: 172:         marker: Option<&crate::renderer::types::Node>,
175: 173:     ) {
176: 174:         self.inner.borrow_mut().mount(parent, marker);
177: 175:     }
178: 176: 
179: 177:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
180: 178:         self.inner.borrow_mut().insert_before_this(child)
181: 179:     }
182: 180: 
183: 181:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
184: 182:         self.inner.borrow().elements()
185: 183:     }
186: 184: }
187: 185: 
188: 186: impl<T> Render for Suspend<T>
189: 187: where
190: 188:     T: Render + 'static,
191: 189: {
192: 190:     type State = SuspendState<T>;
193: 191: 
194: 192:     fn build(self) -> Self::State {
195: 193:         let Self { subscriber, inner } = self;
196: 194: 
197: 195:         // create a Future that will be aborted on on_cleanup
198: 196:         // this prevents trying to access signals or other resources inside the Suspend, after the
199: 197:         // await, if they have already been cleaned up
200: 198:         let (abort_handle, abort_registration) = AbortHandle::new_pair();
201: 199:         let mut fut = Box::pin(Abortable::new(inner, abort_registration));
202: 200:         on_cleanup(move || abort_handle.abort());
203: 201: 
204: 202:         // poll the future once immediately
205: 203:         // if it's already available, start in the ready state
206: 204:         // otherwise, start with the fallback
207: 205:         let initial = fut.as_mut().now_or_never().and_then(Result::ok);
208: 206:         let initially_pending = initial.is_none();
209: 207:         let inner = Rc::new(RefCell::new(initial.build()));
210: 208: 
211: 209:         // get a unique ID if there's a SuspenseContext
212: 210:         let id = use_context::<SuspenseContext>().map(|sc| sc.task_id());
213: 211:         let error_hook = use_context::<Arc<dyn ErrorHook>>();
214: 212: 
215: 213:         // if the initial state was pending, spawn a future to wait for it
216: 214:         // spawning immediately means that our now_or_never poll result isn't lost
217: 215:         // if it wasn't pending at first, we don't need to poll the Future again
218: 216:         if initially_pending {
219: 217:             lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
220: 218:                 let state = Rc::clone(&inner);
221: 219:                 async move {
222: 220:                     let _guard = error_hook.as_ref().map(|hook| {
223: 221:                         lyx-core-any_error::set_error_hook(Arc::clone(hook))
224: 222:                     });
225: 223: 
226: 224:                     let value = fut.as_mut().await;
227: 225:                     drop(id);
228: 226: 
229: 227:                     if let Ok(value) = value {
230: 228:                         Some(value).rebuild(&mut *state.borrow_mut());
231: 229:                     }
232: 230: 
233: 231:                     subscriber.forward();
234: 232:                 }
235: 233:             });
236: 234:         } else {
237: 235:             subscriber.forward();
238: 236:         }
239: 237: 
240: 238:         SuspendState { inner }
241: 239:     }
242: 240: 
243: 241:     fn rebuild(self, state: &mut Self::State) {
244: 242:         let Self { subscriber, inner } = self;
245: 243: 
246: 244:         // create a Future that will be aborted on on_cleanup
247: 245:         // this prevents trying to access signals or other resources inside the Suspend, after the
248: 246:         // await, if they have already been cleaned up
249: 247:         let (abort_handle, abort_registration) = AbortHandle::new_pair();
250: 248:         let fut = Abortable::new(inner, abort_registration);
251: 249:         on_cleanup(move || abort_handle.abort());
252: 250: 
253: 251:         // get a unique ID if there's a SuspenseContext
254: 252:         let id = use_context::<SuspenseContext>().map(|sc| sc.task_id());
255: 253:         let error_hook = use_context::<Arc<dyn ErrorHook>>();
256: 254: 
257: 255:         // spawn the future, and rebuild the state when it resolves
258: 256:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
259: 257:             let state = Rc::clone(&state.inner);
260: 258:             async move {
261: 259:                 let _guard = error_hook
262: 260:                     .as_ref()
263: 261:                     .map(|hook| lyx-core-any_error::set_error_hook(Arc::clone(hook)));
264: 262: 
265: 263:                 let value = fut.await;
266: 264:                 drop(id);
267: 265: 
268: 266:                 // waiting a tick here allows Suspense to remount if necessary, which prevents some
269: 267:                 // edge cases in which a rebuild can't hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen while unmounted because the DOM node
270: 268:                 // has no parent
271: 269:                 Executor::tick().await;
272: 270:                 if let Ok(value) = value {
273: 271:                     Some(value).rebuild(&mut *state.borrow_mut());
274: 272:                 }
275: 273: 
276: 274:                 subscriber.forward();
277: 275:             }
278: 276:         });
279: 277:     }
280: 278: }
281: 279: 
282: 280: impl<T> AddAnyAttr for Suspend<T>
283: 281: where
284: 282:     T: Send + AddAnyAttr + 'static,
285: 283: {
286: 284:     type Output<SomeNewAttr: Attribute> =
287: 285:         Suspend<<T as AddAnyAttr>::Output<SomeNewAttr::CloneableOwned>>;
288: 286: 
289: 287:     fn add_any_attr<NewAttr: Attribute>(
290: 288:         self,
291: 289:         attr: NewAttr,
292: 290:     ) -> Self::Output<NewAttr>
293: 291:     where
294: 292:         Self::Output<NewAttr>: RenderHtml,
295: 293:     {
296: 294:         let attr = attr.into_cloneable_owned();
297: 295:         Suspend::new(async move {
298: 296:             let this = self.inner.await;
299: 297:             this.add_any_attr(attr)
300: 298:         })
301: 299:     }
302: 300: }
303: 301: 
304: 302: impl<T> RenderHtml for Suspend<T>
305: 303: where
306: 304:     T: RenderHtml + Sized + 'static,
307: 305: {
308: 306:     type AsyncOutput = Option<T>;
309: 307:     type Owned = Self;
310: 308: 
311: 309:     const MIN_LENGTH: usize = T::MIN_LENGTH;
312: 310: 
313: 311:     fn to_html_with_buf(
314: 312:         self,
315: 313:         buf: &mut String,
316: 314:         position: &mut Position,
317: 315:         escape: bool,
318: 316:         mark_branches: bool,
319: 317:         extra_attrs: Vec<AnyAttribute>,
320: 318:     ) {
321: 319:         // TODO wrap this with a Suspense as needed
322: 320:         // currently this is just used for Routes, which creates a Suspend but never actually needs
323: 321:         // it (because we don't lazy-load routes on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server)
324: 322:         if let Some(inner) = self.inner.now_or_never() {
325: 323:             inner.to_html_with_buf(
326: 324:                 buf,
327: 325:                 position,
328: 326:                 escape,
329: 327:                 mark_branches,
330: 328:                 extra_attrs,
331: 329:             );
332: 330:         }
333: 331:     }
334: 332: 
335: 333:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
336: 334:         self,
337: 335:         buf: &mut StreamBuilder,
338: 336:         position: &mut Position,
339: 337:         escape: bool,
340: 338:         mark_branches: bool,
341: 339:         extra_attrs: Vec<AnyAttribute>,
342: 340:     ) where
343: 341:         Self: Sized,
344: 342:     {
345: 343:         let mut fut = Box::pin(self.inner);
346: 344:         match fut.as_mut().now_or_never() {
347: 345:             Some(inner) => inner.to_html_async_with_buf::<OUT_OF_ORDER>(
348: 346:                 buf,
349: 347:                 position,
350: 348:                 escape,
351: 349:                 mark_branches,
352: 350:                 extra_attrs,
353: 351:             ),
354: 352:             None => {
355: 353:                 if use_context::<SuspenseContext>().is_none() {
356: 354:                     buf.next_id();
357: 355:                     let (local_tx, mut local_rx) =
358: 356:                         futures::channel::oneshot::channel::<()>();
359: 357:                     provide_context(LocalResourceNotifier::from(local_tx));
360: 358:                     let mut fut = fut.fuse();
361: 359:                     let fut = async move {
362: 360:                         select! {
363: 361:                             _  = local_rx => None,
364: 362:                             value = fut => Some(value)
365: 363:                         }
366: 364:                     };
367: 365:                     let id = buf.clone_id();
368: 366: 
369: 367:                     // out-of-order streams immediately push fallback,
370: 368:                     // wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped by suspense markers
371: 369:                     if OUT_OF_ORDER {
372: 370:                         let mut fallback_position = *position;
373: 371:                         buf.push_fallback::<()>(
374: 372:                             (),
375: 373:                             &mut fallback_position,
376: 374:                             mark_branches,
377: 375:                             extra_attrs.clone(),
378: 376:                         );
379: 377: 
380: 378:                         // TODO in 0.8: this should include a nonce
381: 379:                         // we do have access to nonces via context (because this is the `lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph` module)
382: 380:                         // but unfortunately the Nonce type is defined in `lyx-core-lyx_core_lyx-core-lyx_core_leptos`, not in `lyx-core-lyx_core_lyx-core-lyx_core_tachys`
383: 381:                         //
384: 382:                         // missing it here only affects top-level Suspend, not Suspense components
385: 383:                         buf.push_async_out_of_order(
386: 384:                             fut,
387: 385:                             position,
388: 386:                             mark_branches,
389: 387:                             extra_attrs,
390: 388:                         );
391: 389:                     } else {
392: 390:                         buf.push_async({
393: 391:                             let mut position = *position;
394: 392:                             async move {
395: 393:                                 let value = fut.await;
396: 394:                                 let mut builder = StreamBuilder::new(id);
397: 395:                                 value.to_html_async_with_buf::<OUT_OF_ORDER>(
398: 396:                                     &mut builder,
399: 397:                                     &mut position,
400: 398:                                     escape,
401: 399:                                     mark_branches,
402: 400:                                     extra_attrs,
403: 401:                                 );
404: 402:                                 builder.finish().take_chunks()
405: 403:                             }
406: 404:                         });
407: 405:                         *position = Position::NextChild;
408: 406:                     }
409: 407:                 }
410: 408:             }
411: 409:         }
412: 410:     }
413: 411: 
414: 412:     // TODO cancellation
415: 413:     fn hydrate<const FROM_SERVER: bool>(
416: 414:         self,
417: 415:         cursor: &Cursor,
418: 416:         position: &PositionState,
419: 417:     ) -> Self::State {
420: 418:         let Self { subscriber, inner } = self;
421: 419: 
422: 420:         // create a Future that will be aborted on on_cleanup
423: 421:         // this prevents trying to access signals or other resources inside the Suspend, after the
424: 422:         // await, if they have already been cleaned up
425: 423:         let (abort_handle, abort_registration) = AbortHandle::new_pair();
426: 424:         let mut fut = Box::pin(Abortable::new(inner, abort_registration));
427: 425:         on_cleanup(move || abort_handle.abort());
428: 426: 
429: 427:         // poll the future once immediately
430: 428:         // if it's already available, start in the ready state
431: 429:         // otherwise, start with the fallback
432: 430:         let initial = fut.as_mut().now_or_never().and_then(Result::ok);
433: 431:         let initially_pending = initial.is_none();
434: 432:         let inner = Rc::new(RefCell::new(
435: 433:             initial.hydrate::<FROM_SERVER>(cursor, position),
436: 434:         ));
437: 435: 
438: 436:         // get a unique ID if there's a SuspenseContext
439: 437:         let id = use_context::<SuspenseContext>().map(|sc| sc.task_id());
440: 438:         let error_hook = use_context::<Arc<dyn ErrorHook>>();
441: 439: 
442: 440:         // if the initial state was pending, spawn a future to wait for it
443: 441:         // spawning immediately means that our now_or_never poll result isn't lost
444: 442:         // if it wasn't pending at first, we don't need to poll the Future again
445: 443:         if initially_pending {
446: 444:             lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
447: 445:                 let state = Rc::clone(&inner);
448: 446:                 async move {
449: 447:                     let _guard = error_hook.as_ref().map(|hook| {
450: 448:                         lyx-core-any_error::set_error_hook(Arc::clone(hook))
451: 449:                     });
452: 450: 
453: 451:                     let value = fut.as_mut().await;
454: 452:                     drop(id);
455: 453: 
456: 454:                     if let Ok(value) = value {
457: 455:                         Some(value).rebuild(&mut *state.borrow_mut());
458: 456:                     }
459: 457: 
460: 458:                     subscriber.forward();
461: 459:                 }
462: 460:             });
463: 461:         } else {
464: 462:             subscriber.forward();
465: 463:         }
466: 464: 
467: 465:         SuspendState { inner }
468: 466:     }
469: 467: 
470: 468:     async fn resolve(self) -> Self::AsyncOutput {
471: 469:         Some(self.inner.await)
472: 470:     }
473: 471: 
474: 472:     fn dry_resolve(&mut self) {
475: 473:         // this is a little crazy, but if a Suspend is immediately available, we end up
476: 474:         // with a situation where polling it multiple times (here in dry_resolve and then in
477: 475:         // resolve) causes a runtime panic
478: 476:         // (see https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/3113)
479: 477:         //
480: 478:         // at the same time, we do need to dry_resolve Suspend so that we can register synchronous
481: 479:         // resource reads that hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen inside them
482: 480:         // (see https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/2917)
483: 481:         //
484: 482:         // fuse()-ing the Future doesn't work, because that will cause the subsequent resolve()
485: 483:         // simply to be pending forever
486: 484:         //
487: 485:         // in this case, though, we can simply... discover that the data are already here, and then
488: 486:         // stuff them back into a new Future, which can safely be polled after its completion
489: 487:         if let Some(mut inner) = self.inner.as_mut().now_or_never() {
490: 488:             inner.dry_resolve();
491: 489:             self.inner = Box::pin(async move { inner })
492: 490:                 as Pin<Box<dyn Future<Output = T> + Send>>;
493: 491:         }
494: 492:     }
495: 493: 
496: 494:     fn into_owned(self) -> Self::Owned {
497: 495:         self
498: 496:     }
499: 497: }
500: 498: ```
501: 499: ```
502: 500: ```
503: 501: ```
504: 502: ```
505: 503: ```
506: 504: ```
507: 505: ```
508: ```
```
