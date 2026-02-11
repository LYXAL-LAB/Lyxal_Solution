### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\async_derived\arc_async_derived.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\async_derived\arc_async_derived.rs
2: ```rust
3: 1: use super::{
4: 2:     inner::{ArcAsyncDerivedInner, AsyncDerivedState},
5: 3:     AsyncDerivedReadyFuture, ScopedFuture,
6: 4: };
7: 5: #[cfg(feature = "sandboxed-arenas")]
8: 6: use crate::owner::Sandboxed;
9: 7: use crate::{
10: 8:     channel::channel,
11: 9:     computed::suspense::SuspenseContext,
12: 10:     diagnostics::SpecialNonReactiveFuture,
13: 11:     graph::{
14: 12:         AnySource, AnySubscriber, ReactiveNode, Source, SourceSet, Subscriber,
15: 13:         SubscriberSet, ToAnySource, ToAnySubscriber, WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
16: 14:     },
17: 15:     owner::{use_context, Owner},
18: 16:     send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_ext::SendOption,
19: 17:     signal::{
20: 18:         guards::{AsyncPlain, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut, ReadGuard, WriteGuard},
21: 19:         ArcTrigger,
22: 20:     },
23: 21:     traits::{
24: 22:         DefinedAt, IsDisposed, Notify, ReadUntracked, Track, UntrackableGuard,
25: 23:         Write,
26: 24:     },
27: 25:     transition::AsyncTransition,
28: 26: };
29: 27: use async_lock::RwLock as AsyncRwLock;
30: 28: use core::fmt::Debug;
31: 29: use futures::{channel::oneshot, FutureExt, StreamExt};
32: 30: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
33: 31: use std::{
34: 32:     future::Future,
35: 33:     mem,
36: 34:     ops::{Deref, DerefMut},
37: 35:     panic::Location,
38: 36:     sync::{
39: 37:         atomic::{AtomicBool, Ordering},
40: 38:         Arc, RwLock, Weak,
41: 39:     },
42: 40:     task::Waker,
43: 41: };
44: 42: 
45: 43: /// A reactive value that is derived by running an asynchronous computation in response to changes
46: 44: /// in its sources.
47: 45: ///
48: 46: /// When one of its dependencies changes, this will re-run its async computation, then notify other
49: 47: /// values that depend on it that it has changed.
50: 48: ///
51: 49: /// This is a reference-counted type, which is `Clone` but not `Copy`.
52: 50: /// For arena-allocated `Copy` memos, use [`AsyncDerived`](super::AsyncDerived).
53: 51: ///
54: 52: /// ## Examples
55: 53: /// ```rust
56: 54: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
57: 55: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
58: 56: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
59: 57: /// # tokio_test::block_on(async move {
60: 58: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
61: 59: /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
62: 60: ///
63: 61: /// let signal1 = RwSignal::new(0);
64: 62: /// let signal2 = RwSignal::new(0);
65: 63: /// let derived = ArcAsyncDerived::new(move || async move {
66: 64: ///   // reactive values can be tracked anywhere in the `async` block
67: 65: ///   let value1 = signal1.get();
68: 66: ///   tokio::time::sleep(std::time::Duration::from_millis(25)).await;
69: 67: ///   let value2 = signal2.get();
70: 68: ///
71: 69: ///   value1 + value2
72: 70: /// });
73: 71: ///
74: 72: /// // the value can be accessed synchronously as `Option<T>`
75: 73: /// assert_eq!(derived.get(), None);
76: 74: /// // we can also .await the value, i.e., convert it into a Future
77: 75: /// assert_eq!(derived.clone().await, 0);
78: 76: /// assert_eq!(derived.get(), Some(0));
79: 77: ///
80: 78: /// signal1.set(1);
81: 79: /// // while the new value is still pending, the signal holds the old value
82: 80: /// tokio::time::sleep(std::time::Duration::from_millis(5)).await;
83: 81: /// assert_eq!(derived.get(), Some(0));
84: 82: ///
85: 83: /// // setting multiple dependencies will hold until the latest change is ready
86: 84: /// signal2.set(1);
87: 85: /// assert_eq!(derived.await, 2);
88: 86: /// # });
89: 87: /// ```
90: 88: ///
91: 89: /// ## Core Trait Implementations
92: 90: /// - [`.get()`](crate::traits::Get) clones the current value as an `Option<T>`.
93: 91: ///   If you call it within an effect, it will cause that effect to subscribe
94: 92: ///   to the memo, and to re-run whenever the value of the memo changes.
95: 93: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
96: 94: ///     without reactively tracking it.
97: 95: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
98: 96: ///   value by reference. If you call it within an effect, it will
99: 97: ///   cause that effect to subscribe to the memo, and to re-run whenever the
100: 98: ///   value changes.
101: 99: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
102: 100: ///     current value without reactively tracking it.
103: 101: /// - [`.with()`](crate::traits::With) allows you to reactively access the
104: 102: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
105: 103: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
106: 104: ///     the value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
107: 105: ///     tracking it.
108: 106: /// - [`IntoFuture`](std::future::Future) allows you to create a [`Future`] that resolves
109: 107: ///   when this resource is done loading.
110: 108: pub struct ArcAsyncDerived<T> {
111: 109:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
112: 110:     pub(crate) defined_at: &'static Location<'static>,
113: 111:     // the current state of this signal
114: 112:     pub(crate) value: Arc<AsyncRwLock<SendOption<T>>>,
115: 113:     // holds wakers generated when you .await this
116: 114:     pub(crate) wakers: Arc<RwLock<Vec<Waker>>>,
117: 115:     pub(crate) inner: Arc<RwLock<ArcAsyncDerivedInner>>,
118: 116:     pub(crate) loading: Arc<AtomicBool>,
119: 117: }
120: 118: 
121: 119: #[allow(dead_code)]
122: 120: pub(crate) trait BlockingLock<T> {
123: 121:     fn blocking_read_arc(self: &Arc<Self>)
124: 122:         -> async_lock::RwLockReadGuardArc<T>;
125: 123: 
126: 124:     fn blocking_write_arc(
127: 125:         self: &Arc<Self>,
128: 126:     ) -> async_lock::RwLockWriteGuardArc<T>;
129: 127: 
130: 128:     fn blocking_read(&self) -> async_lock::RwLockReadGuard<'_, T>;
131: 129: 
132: 130:     fn blocking_write(&self) -> async_lock::RwLockWriteGuard<'_, T>;
133: 131: }
134: 132: 
135: 133: impl<T> BlockingLock<T> for AsyncRwLock<T> {
136: 134:     fn blocking_read_arc(
137: 135:         self: &Arc<Self>,
138: 136:     ) -> async_lock::RwLockReadGuardArc<T> {
139: 137:         #[cfg(not(target_family = "wasm"))]
140: 138:         {
141: 139:             self.read_arc_blocking()
142: 140:         }
143: 141:         #[cfg(target_family = "wasm")]
144: 142:         {
145: 143:             self.read_arc().now_or_never().unwrap()
146: 144:         }
147: 145:     }
148: 146: 
149: 147:     fn blocking_write_arc(
150: 148:         self: &Arc<Self>,
151: 149:     ) -> async_lock::RwLockWriteGuardArc<T> {
152: 150:         #[cfg(not(target_family = "wasm"))]
153: 151:         {
154: 152:             self.write_arc_blocking()
155: 153:         }
156: 154:         #[cfg(target_family = "wasm")]
157: 155:         {
158: 156:             self.write_arc().now_or_never().unwrap()
159: 157:         }
160: 158:     }
161: 159: 
162: 160:     fn blocking_read(&self) -> async_lock::RwLockReadGuard<'_, T> {
163: 161:         #[cfg(not(target_family = "wasm"))]
164: 162:         {
165: 163:             self.read_blocking()
166: 164:         }
167: 165:         #[cfg(target_family = "wasm")]
168: 166:         {
169: 167:             self.read().now_or_never().unwrap()
170: 168:         }
171: 169:     }
172: 170: 
173: 171:     fn blocking_write(&self) -> async_lock::RwLockWriteGuard<'_, T> {
174: 172:         #[cfg(not(target_family = "wasm"))]
175: 173:         {
176: 174:             self.write_blocking()
177: 175:         }
178: 176:         #[cfg(target_family = "wasm")]
179: 177:         {
180: 178:             self.write().now_or_never().unwrap()
181: 179:         }
182: 180:     }
183: 181: }
184: 182: 
185: 183: impl<T> Clone for ArcAsyncDerived<T> {
186: 184:     fn clone(&self) -> Self {
187: 185:         Self {
188: 186:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
189: 187:             defined_at: self.defined_at,
190: 188:             value: Arc::clone(&self.value),
191: 189:             wakers: Arc::clone(&self.wakers),
192: 190:             inner: Arc::clone(&self.inner),
193: 191:             loading: Arc::clone(&self.loading),
194: 192:         }
195: 193:     }
196: 194: }
197: 195: 
198: 196: impl<T> Debug for ArcAsyncDerived<T> {
199: 197:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
200: 198:         let mut f = f.debug_struct("ArcAsyncDerived");
201: 199:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
202: 200:         f.field("defined_at", &self.defined_at);
203: 201:         f.finish_non_exhaustive()
204: 202:     }
205: 203: }
206: 204: 
207: 205: impl<T> DefinedAt for ArcAsyncDerived<T> {
208: 206:     #[inline(always)]
209: 207:     fn defined_at(&self) -> Option<&'static Location<'static>> {
210: 208:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
211: 209:         {
212: 210:             Some(self.defined_at)
213: 211:         }
214: 212:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
215: 213:         {
216: 214:             None
217: 215:         }
218: 216:     }
219: 217: }
220: 218: 
221: 219: // This helps create a derived async signal.
222: 220: // It needs to be implemented as a macro because it needs to be flexible over
223: 221: // whether `fun` returns a `Future` that is `Send`. Doing it as a function would,
224: 222: // as far as I can tell, require repeating most of the function body.
225: 223: macro_rules! spawn_derived {
226: 224:     ($spawner:expr, $initial:ident, $fun:ident, $should_spawn:literal, $force_spawn:literal, $should_track:literal, $source:expr) => {{
227: 225:         let (notifier, mut rx) = channel();
228: 226: 
229: 227:         let is_ready = $initial.is_some() && !$force_spawn;
230: 228: 
231: 229:         let owner = Owner::new();
232: 230:         let inner = Arc::new(RwLock::new(ArcAsyncDerivedInner {
233: 231:             owner: owner.clone(),
234: 232:             notifier,
235: 233:             sources: SourceSet::new(),
236: 234:             subscribers: SubscriberSet::new(),
237: 235:             state: AsyncDerivedState::Clean,
238: 236:             version: 0,
239: 237:             suspenses: Vec::new(),
240: 238:             pending_suspenses: Vec::new()
241: 239:         }));
242: 240:         let value = Arc::new(AsyncRwLock::new($initial));
243: 241:         let wakers = Arc::new(RwLock::new(Vec::new()));
244: 242: 
245: 243:         let this = ArcAsyncDerived {
246: 244:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
247: 245:             defined_at: Location::caller(),
248: 246:             value: Arc::clone(&value),
249: 247:             wakers,
250: 248:             inner: Arc::clone(&inner),
251: 249:             loading: Arc::new(AtomicBool::new(!is_ready)),
252: 250:         };
253: 251:         let any_subscriber = this.to_any_subscriber();
254: 252:         let initial_fut = if $should_track {
255: 253:             owner.with_cleanup(|| {
256: 254:                 any_subscriber
257: 255:                     .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| ScopedFuture::new($fun()))
258: 256:             })
259: 257:         } else {
260: 258:             owner.with_cleanup(|| {
261: 259:                 any_subscriber
262: 260:                     .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked(|| ScopedFuture::new($fun()))
263: 261:             })
264: 262:         };
265: 263:         #[cfg(feature = "sandboxed-arenas")]
266: 264:         let initial_fut = Sandboxed::new(initial_fut);
267: 265:         let mut initial_fut = Box::pin(initial_fut);
268: 266: 
269: 267:         let (was_ready, mut initial_fut) = {
270: 268:             if is_ready {
271: 269:                 (true, None)
272: 270:             } else {
273: 271:                 // if we don't already know that it's ready, we need to poll once, initially
274: 272:                 // so that the correct value is set synchronously
275: 273:                 let initial = initial_fut.as_mut().now_or_never();
276: 274:                 match initial {
277: 275:                     None => {
278: 276:                         inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().notifier.notify();
279: 277:                         (false, Some(initial_fut))
280: 278:                     }
281: 279:                     Some(orig_value) => {
282: 280:                         let mut guard = this.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
283: 281: 
284: 282:                         guard.state = AsyncDerivedState::Clean;
285: 283:                         *value.blocking_write() = orig_value;
286: 284:                         this.loading.store(false, Ordering::Relaxed);
287: 285:                         (true, None)
288: 286:                     }
289: 287:                 }
290: 288:             }
291: 289:         };
292: 290: 
293: 291:         let mut first_run = {
294: 292:             let (ready_tx, ready_rx) = oneshot::channel();
295: 293:             if !was_ready {
296: 294:                 AsyncTransition::register(ready_rx);
297: 295:             }
298: 296:             Some(ready_tx)
299: 297:         };
300: 298: 
301: 299:         if was_ready {
302: 300:             first_run.take();
303: 301:         }
304: 302: 
305: 303:         if let Some(source) = $source {
306: 304:             any_subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| source.track());
307: 305:         }
308: 306: 
309: 307:         if $should_spawn {
310: 308:             $spawner({
311: 309:                 let value = Arc::downgrade(&this.value);
312: 310:                 let inner = Arc::downgrade(&this.inner);
313: 311:                 let wakers = Arc::downgrade(&this.wakers);
314: 312:                 let loading = Arc::downgrade(&this.loading);
315: 313:                 let fut = async move {
316: 314:                     // if the AsyncDerived has *already* been marked dirty (i.e., one of its
317: 315:                     // sources has changed after creation), we should throw out the Future
318: 316:                     // we already created, because its values might be stale
319: 317:                     let already_dirty = inner.upgrade()
320: 318:                         .as_ref()
321: 319:                         .and_then(|inner| inner.read().ok())
322: 320:                         .map(|inner| inner.state == AsyncDerivedState::Dirty)
323: 321:                         .unwrap_or(false);
324: 322:                     if already_dirty {
325: 323:                         initial_fut.take();
326: 324:                     }
327: 325: 
328: 326:                     while rx.next().await.is_some() {
329: 327:                         let update_if_necessary = !owner.paused() && if $should_track {
330: 328:                             any_subscriber
331: 329:                                 .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| any_subscriber.update_if_necessary())
332: 330:                         } else {
333: 331:                             any_subscriber
334: 332:                                 .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked(|| any_subscriber.update_if_necessary())
335: 333:                         };
336: 334:                         if update_if_necessary || first_run.is_some() {
337: 335:                             match (value.upgrade(), inner.upgrade(), wakers.upgrade(), loading.upgrade()) {
338: 336:                                 (Some(value), Some(inner), Some(wakers), Some(loading)) => {
339: 337:                                     // generate new Future
340: 338:                                     let owner = inner.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().owner.clone();
341: 339:                                     let fut = initial_fut.take().unwrap_or_else(|| {
342: 340:                                         let fut = if $should_track {
343: 341:                                             owner.with_cleanup(|| {
344: 342:                                                 any_subscriber
345: 343:                                                     .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| ScopedFuture::new($fun()))
346: 344:                                             })
347: 345:                                         } else {
348: 346:                                             owner.with_cleanup(|| {
349: 347:                                                 any_subscriber
350: 348:                                                     .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_untracked(|| ScopedFuture::new($fun()))
351: 349:                                             })
352: 350:                                         };
353: 351:                                         #[cfg(feature = "sandboxed-arenas")]
354: 352:                                         let fut = Sandboxed::new(fut);
355: 353:                                         Box::pin(fut)
356: 354:                                     });
357: 355: 
358: 356:                                     // register with global transition listener, if any
359: 357:                                     let ready_tx = first_run.take().unwrap_or_else(|| {
360: 358:                                         let (ready_tx, ready_rx) = oneshot::channel();
361: 359:                                         if !was_ready {
362: 360:                                             AsyncTransition::register(ready_rx);
363: 361:                                         }
364: 362:                                         ready_tx
365: 363:                                     });
366: 364: 
367: 365:                                     // generate and assign new value
368: 366:                                     loading.store(true, Ordering::Relaxed);
369: 367: 
370: 368:                                     let this_version = {
371: 369:                                         let mut guard = inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
372: 370:                                         guard.version += 1;
373: 371:                                         let version = guard.version;
374: 372:                                         let suspense_lyx-core-lyx_core_lyx-core-lyx_core_ids = mem::take(&mut guard.suspenses)
375: 373:                                             .into_iter()
376: 374:                                             .map(|sc| sc.task_id())
377: 375:                                             .collect::<Vec<_>>();
378: 376:                                         guard.pending_suspenses.extend(suspense_lyx-core-lyx_core_lyx-core-lyx_core_ids);
379: 377:                                         version
380: 378:                                     };
381: 379: 
382: 380:                                     let new_value = fut.await;
383: 381: 
384: 382:                                     let latest_version = {
385: 383:                                         let mut guard = inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
386: 384:                                         drop(mem::take(&mut guard.pending_suspenses));
387: 385:                                         guard.version
388: 386:                                     };
389: 387: 
390: 388:                                     if latest_version == this_version {
391: 389:                                         Self::set_inner_value(new_value, value, wakers, inner, loading, Some(ready_tx)).await;
392: 390:                                     }
393: 391:                                 }
394: 392:                                 _ => break,
395: 393:                             }
396: 394:                         }
397: 395:                     }
398: 396:                 };
399: 397: 
400: 398:                 #[cfg(feature = "sandboxed-arenas")]
401: 399:                 let fut = Sandboxed::new(fut);
402: 400: 
403: 401:                 fut
404: 402:             });
405: 403:         }
406: 404: 
407: 405:         (this, is_ready)
408: 406:     }};
409: 407: }
410: 408: 
411: 409: impl<T: 'static> ArcAsyncDerived<T> {
412: 410:     async fn set_inner_value(
413: 411:         new_value: SendOption<T>,
414: 412:         value: Arc<AsyncRwLock<SendOption<T>>>,
415: 413:         wakers: Arc<RwLock<Vec<Waker>>>,
416: 414:         inner: Arc<RwLock<ArcAsyncDerivedInner>>,
417: 415:         loading: Arc<AtomicBool>,
418: 416:         ready_tx: Option<oneshot::Sender<()>>,
419: 417:     ) {
420: 418:         *value.write().await.deref_mut() = new_value;
421: 419:         Self::notify_subs(&wakers, &inner, &loading, ready_tx);
422: 420:     }
423: 421: 
424: 422:     fn notify_subs(
425: 423:         wakers: &Arc<RwLock<Vec<Waker>>>,
426: 424:         inner: &Arc<RwLock<ArcAsyncDerivedInner>>,
427: 425:         loading: &Arc<AtomicBool>,
428: 426:         ready_tx: Option<oneshot::Sender<()>>,
429: 427:     ) {
430: 428:         loading.store(false, Ordering::Relaxed);
431: 429: 
432: 430:         let prev_state = mem::replace(
433: 431:             &mut inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().state,
434: 432:             AsyncDerivedState::Notifying,
435: 433:         );
436: 434: 
437: 435:         if let Some(ready_tx) = ready_tx {
438: 436:             // if it's an Err, that just means the Receiver was dropped
439: 437:             // we don't particularly care about that: the point is to notify if
440: 438:             // it still exists, but we don't need to know if Suspense is no
441: 439:             // longer listening
442: 440:             _ = ready_tx.send(());
443: 441:         }
444: 442: 
445: 443:         // notify reactive subscribers that we're not loading any more
446: 444:         for sub in (&inner.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().subscribers).into_iter() {
447: 445:             sub.mark_dirty();
448: 446:         }
449: 447: 
450: 448:         // notify async .awaiters
451: 449:         for waker in mem::take(&mut *wakers.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()) {
452: 450:             waker.wake();
453: 451:         }
454: 452: 
455: 453:         // if this was marked dirty before notifications began, this means it
456: 454:         // had been notified while loading; marking it clean will cause it not to
457: 455:         // run on the next tick of the async loop, so here it should be left dirty
458: 456:         inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().state = prev_state;
459: 457:     }
460: 458: }
461: 459: 
462: 460: impl<T: 'static> ArcAsyncDerived<T> {
463: 461:     /// Creates a new async derived computation.
464: 462:     ///
465: 463:     /// This runs eagerly: i.e., calls `fun` once when created and immediately spawns the `Future`
466: 464:     /// as a new task.
467: 465:     #[track_caller]
468: 466:     pub fn new<Fut>(fun: impl Fn() -> Fut + Send + Sync + 'static) -> Self
469: 467:     where
470: 468:         T: Send + Sync + 'static,
471: 469:         Fut: Future<Output = T> + Send + 'static,
472: 470:     {
473: 471:         Self::new_with_initial(None, fun)
474: 472:     }
475: 473: 
476: 474:     /// Creates a new async derived computation with an initial value as a fallback, and begins running the
477: 475:     /// `Future` eagerly to get the actual first value.
478: 476:     #[track_caller]
479: 477:     pub fn new_with_initial<Fut>(
480: 478:         initial_value: Option<T>,
481: 479:         fun: impl Fn() -> Fut + Send + Sync + 'static,
482: 480:     ) -> Self
483: 481:     where
484: 482:         T: Send + Sync + 'static,
485: 483:         Fut: Future<Output = T> + Send + 'static,
486: 484:     {
487: 485:         let fun = move || {
488: 486:             let fut = fun();
489: 487:             let fut = async move { SendOption::new(Some(fut.await)) };
490: 488:             #[cfg(feature = "sandboxed-arenas")]
491: 489:             let fut = Sandboxed::new(fut);
492: 490:             fut
493: 491:         };
494: 492:         let initial_value = SendOption::new(initial_value);
495: 493:         let (this, _) = spawn_derived!(
496: 494:             crate::spawn,
497: 495:             initial_value,
498: 496:             fun,
499: 497:             true,
500: 498:             true,
501: 499:             true,
502: 500:             None::<ArcTrigger>
503: 501:         );
504: 502:         this
505: 503:     }
506: 504: 
507: 505:     /// Creates a new async derived computation with an initial value, and does not spawn a task
508: 506:     /// initially.
509: 507:     ///
510: 508:     /// This is mostly used with manual dependency tracking, for primitives built on top of this
511: 509:     /// where you do not want to run the run the `Future` unnecessarily.
512: 510:     #[doc(hidden)]
513: 511:     #[track_caller]
514: 512:     pub fn new_with_manual_dependencies<Fut, S>(
515: 513:         initial_value: Option<T>,
516: 514:         fun: impl Fn() -> Fut + Send + Sync + 'static,
517: 515:         source: &S,
518: 516:     ) -> Self
519: 517:     where
520: 518:         T: Send + Sync + 'static,
521: 519:         Fut: Future<Output = T> + Send + 'static,
522: 520:         S: Track,
523: 521:     {
524: 522:         let fun = move || {
525: 523:             let fut = fun();
526: 524:             let fut =
527: 525:                 ScopedFuture::new_untracked_with_diagnostics(async move {
528: 526:                     SendOption::new(Some(fut.await))
529: 527:                 });
530: 528:             #[cfg(feature = "sandboxed-arenas")]
531: 529:             let fut = Sandboxed::new(fut);
532: 530:             fut
533: 531:         };
534: 532:         let initial_value = SendOption::new(initial_value);
535: 533:         let (this, _) = spawn_derived!(
536: 534:             crate::spawn,
537: 535:             initial_value,
538: 536:             fun,
539: 537:             true,
540: 538:             false,
541: 539:             false,
542: 540:             Some(source)
543: 541:         );
544: 542:         this
545: 543:     }
546: 544: 
547: 545:     /// Creates a new async derived computation that will be guaranteed to run on the current
548: 546:     /// thread.
549: 547:     ///
550: 548:     /// This runs eagerly: i.e., calls `fun` once when created and immediately spawns the `Future`
551: 549:     /// as a new task.
552: 550:     #[track_caller]
553: 551:     pub fn new_unsync<Fut>(fun: impl Fn() -> Fut + 'static) -> Self
554: 552:     where
555: 553:         T: 'static,
556: 554:         Fut: Future<Output = T> + 'static,
557: 555:     {
558: 556:         Self::new_unsync_with_initial(None, fun)
559: 557:     }
560: 558: 
561: 559:     /// Creates a new async derived computation with an initial value as a fallback, and begins running the
562: 560:     /// `Future` eagerly to get the actual first value.
563: 561:     #[track_caller]
564: 562:     pub fn new_unsync_with_initial<Fut>(
565: 563:         initial_value: Option<T>,
566: 564:         fun: impl Fn() -> Fut + 'static,
567: 565:     ) -> Self
568: 566:     where
569: 567:         T: 'static,
570: 568:         Fut: Future<Output = T> + 'static,
571: 569:     {
572: 570:         let fun = move || {
573: 571:             let fut = fun();
574: 572:             let fut = async move { SendOption::new_local(Some(fut.await)) };
575: 573:             #[cfg(feature = "sandboxed-arenas")]
576: 574:             let fut = Sandboxed::new(fut);
577: 575:             fut
578: 576:         };
579: 577:         let initial_value = SendOption::new_local(initial_value);
580: 578:         let (this, _) = spawn_derived!(
581: 579:             crate::spawn_local,
582: 580:             initial_value,
583: 581:             fun,
584: 582:             true,
585: 583:             true,
586: 584:             true,
587: 585:             None::<ArcTrigger>
588: 586:         );
589: 587:         this
590: 588:     }
591: 589: 
592: 590:     /// Returns a `Future` that is ready when this resource has next finished loading.
593: 591:     pub fn ready(&self) -> AsyncDerivedReadyFuture {
594: 592:         AsyncDerivedReadyFuture::new(
595: 593:             self.to_any_source(),
596: 594:             &self.loading,
597: 595:             &self.wakers,
598: 596:         )
599: 597:     }
600: 598: }
601: 599: 
602: 600: impl<T: 'static> ArcAsyncDerived<T> {
603: 601:     #[doc(hidden)]
604: 602:     #[track_caller]
605: 603:     pub fn new_mock<Fut>(fun: impl Fn() -> Fut + 'static) -> Self
606: 604:     where
607: 605:         T: 'static,
608: 606:         Fut: Future<Output = T> + 'static,
609: 607:     {
610: 608:         let initial = SendOption::new_local(None::<T>);
611: 609:         let fun = move || {
612: 610:             let fut = fun();
613: 611:             let fut = async move { SendOption::new_local(Some(fut.await)) };
614: 612:             #[cfg(feature = "sandboxed-arenas")]
615: 613:             let fut = Sandboxed::new(fut);
616: 614:             fut
617: 615:         };
618: 616:         let (this, _) = spawn_derived!(
619: 617:             crate::spawn_local,
620: 618:             initial,
621: 619:             fun,
622: 620:             false,
623: 621:             false,
624: 622:             true,
625: 623:             None::<ArcTrigger>
626: 624:         );
627: 625:         this
628: 626:     }
629: 627: }
630: 628: 
631: 629: impl<T: 'static> ReadUntracked for ArcAsyncDerived<T> {
632: 630:     type Value =
633: 631:         ReadGuard<Option<T>, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<AsyncPlain<SendOption<T>>, Option<T>>>;
634: 632: 
635: 633:     fn try_read_untracked(&self) -> Option<Self::Value> {
636: 634:         if let Some(suspense_context) = use_context::<SuspenseContext>() {
637: 635:             // create a handle to register it with suspense
638: 636:             let handle = suspense_context.task_id();
639: 637: 
640: 638:             // check if the task is *already* ready
641: 639:             let mut ready =
642: 640:                 Box::pin(SpecialNonReactiveFuture::new(self.ready()));
643: 641:             match ready.as_mut().now_or_never() {
644: 642:                 Some(_) => {
645: 643:                     // if it's already ready, drop the handle immediately
646: 644:                     // this will immediately notify the suspense context that it's complete
647: 645:                     drop(handle);
648: 646:                 }
649: 647:                 None => {
650: 648:                     // otherwise, spawn a task to wait for it to be ready, then drop the handle,
651: 649:                     // which will notify the suspense
652: 650:                     crate::spawn(async move {
653: 651:                         ready.await;
654: 652:                         drop(handle);
655: 653:                     });
656: 654:                 }
657: 655:             }
658: 656: 
659: 657:             // register the suspense context with our list of them, to be notified later if this re-runs
660: 658:             self.inner
661: 659:                 .write()
662: 660:                 .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
663: 661:                 .suspenses
664: 662:                 .push(suspense_context);
665: 663:         }
666: 664:         AsyncPlain::try_new(&self.value).map(|plain| {
667: 665:             ReadGuard::new(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::new_with_guard(plain, |v| v.deref()))
668: 666:         })
669: 667:     }
670: 668: }
671: 669: 
672: 670: impl<T: 'static> Notify for ArcAsyncDerived<T> {
673: 671:     fn notify(&self) {
674: 672:         Self::notify_subs(&self.wakers, &self.inner, &self.loading, None);
675: 673:     }
676: 674: }
677: 675: 
678: 676: impl<T: 'static> Write for ArcAsyncDerived<T> {
679: 677:     type Value = Option<T>;
680: 678: 
681: 679:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
682: 680:         // increment the version, such that a rerun triggered previously does not overwrite this
683: 681:         // new value
684: 682:         let mut guard = self.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
685: 683:         guard.version += 1;
686: 684: 
687: 685:         // tell any suspenses to stop waiting for this
688: 686:         drop(mem::take(&mut guard.pending_suspenses));
689: 687: 
690: 688:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut::new(
691: 689:             WriteGuard::new(self.clone(), self.value.blocking_write()),
692: 690:             |v| v.deref(),
693: 691:             |v| v.deref_mut(),
694: 692:         ))
695: 693:     }
696: 694: 
697: 695:     fn try_write_untracked(
698: 696:         &self,
699: 697:     ) -> Option<impl DerefMut<Target = Self::Value>> {
700: 698:         // increment the version, such that a rerun triggered previously does not overwrite this
701: 699:         // new value
702: 700:         let mut guard = self.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
703: 701:         guard.version += 1;
704: 702: 
705: 703:         // tell any suspenses to stop waiting for this
706: 704:         drop(mem::take(&mut guard.pending_suspenses));
707: 705: 
708: 706:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut::new(
709: 707:             self.value.blocking_write(),
710: 708:             |v| v.deref(),
711: 709:             |v| v.deref_mut(),
712: 710:         ))
713: 711:     }
714: 712: }
715: 713: 
716: 714: impl<T: 'static> IsDisposed for ArcAsyncDerived<T> {
717: 715:     #[inline(always)]
718: 716:     fn is_disposed(&self) -> bool {
719: 717:         false
720: 718:     }
721: 719: }
722: 720: 
723: 721: impl<T: 'static> ToAnySource for ArcAsyncDerived<T> {
724: 722:     fn to_any_source(&self) -> AnySource {
725: 723:         AnySource(
726: 724:             Arc::as_ptr(&self.inner) as usize,
727: 725:             Arc::downgrade(&self.inner) as Weak<dyn Source + Send + Sync>,
728: 726:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
729: 727:             self.defined_at,
730: 728:         )
731: 729:     }
732: 730: }
733: 731: 
734: 732: impl<T: 'static> ToAnySubscriber for ArcAsyncDerived<T> {
735: 733:     fn to_any_subscriber(&self) -> AnySubscriber {
736: 734:         AnySubscriber(
737: 735:             Arc::as_ptr(&self.inner) as usize,
738: 736:             Arc::downgrade(&self.inner) as Weak<dyn Subscriber + Send + Sync>,
739: 737:         )
740: 738:     }
741: 739: }
742: 740: 
743: 741: impl<T> Source for ArcAsyncDerived<T> {
744: 742:     fn add_subscriber(&self, subscriber: AnySubscriber) {
745: 743:         self.inner.add_subscriber(subscriber);
746: 744:     }
747: 745: 
748: 746:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
749: 747:         self.inner.remove_subscriber(subscriber);
750: 748:     }
751: 749: 
752: 750:     fn clear_subscribers(&self) {
753: 751:         self.inner.clear_subscribers();
754: 752:     }
755: 753: }
756: 754: 
757: 755: impl<T> ReactiveNode for ArcAsyncDerived<T> {
758: 756:     fn mark_dirty(&self) {
759: 757:         self.inner.mark_dirty();
760: 758:     }
761: 759: 
762: 760:     fn mark_check(&self) {
763: 761:         self.inner.mark_check();
764: 762:     }
765: 763: 
766: 764:     fn mark_subscribers_check(&self) {
767: 765:         self.inner.mark_subscribers_check();
768: 766:     }
769: 767: 
770: 768:     fn update_if_necessary(&self) -> bool {
771: 769:         self.inner.update_if_necessary()
772: 770:     }
773: 771: }
774: 772: 
775: 773: impl<T> Subscriber for ArcAsyncDerived<T> {
776: 774:     fn add_source(&self, source: AnySource) {
777: 775:         self.inner.add_source(source);
778: 776:     }
779: 777: 
780: 778:     fn clear_sources(&self, subscriber: &AnySubscriber) {
781: 779:         self.inner.clear_sources(subscriber);
782: 780:     }
783: 781: }
784: ```
```
