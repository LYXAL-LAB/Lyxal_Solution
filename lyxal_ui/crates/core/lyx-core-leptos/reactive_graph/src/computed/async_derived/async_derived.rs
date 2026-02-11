### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\async_derived\async_derived.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\async_derived\async_derived.rs
2: ```rust
3: 1: use super::{ArcAsyncDerived, AsyncDerivedReadyFuture, BlockingLock};
4: 2: use crate::{
5: 3:     graph::{
6: 4:         AnySource, AnySubscriber, ReactiveNode, Source, Subscriber,
7: 5:         ToAnySource, ToAnySubscriber,
8: 6:     },
9: 7:     owner::{ArenaItem, FromLocal, LocalStorage, Storage, SyncStorage},
10: 8:     send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_ext::SendOption,
11: 9:     signal::guards::{AsyncPlain, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut, ReadGuard, WriteGuard},
12: 10:     traits::{
13: 11:         DefinedAt, Dispose, IsDisposed, Notify, ReadUntracked,
14: 12:         UntrackableGuard, Write,
15: 13:     },
16: 14:     unwrap_signal,
17: 15: };
18: 16: use core::fmt::Debug;
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
20: 18: use std::{
21: 19:     future::Future,
22: 20:     mem,
23: 21:     ops::{Deref, DerefMut},
24: 22:     panic::Location,
25: 23: };
26: 24: 
27: 25: /// A reactive value that is derived by running an asynchronous computation in response to changes
28: 26: /// in its sources.
29: 27: ///
30: 28: /// When one of its dependencies changes, this will re-run its async computation, then notify other
31: 29: /// values that depend on it that it has changed.
32: 30: ///
33: 31: /// This is an arena-allocated type, which is `Copy` and is disposed when its reactive
34: 32: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted signal that lives as
35: 33: /// as long as a reference to it is alive, see [`ArcAsyncDerived`].
36: 34: ///
37: 35: /// ## Examples
38: 36: /// ```rust
39: 37: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
40: 38: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
41: 39: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
42: 40: /// # tokio_test::block_on(async move {
43: 41: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
44: 42: /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
45: 43: ///
46: 44: /// let signal1 = RwSignal::new(0);
47: 45: /// let signal2 = RwSignal::new(0);
48: 46: /// let derived = AsyncDerived::new(move || async move {
49: 47: ///   // reactive values can be tracked anywhere in the `async` block
50: 48: ///   let value1 = signal1.get();
51: 49: ///   tokio::time::sleep(std::time::Duration::from_millis(25)).await;
52: 50: ///   let value2 = signal2.get();
53: 51: ///
54: 52: ///   value1 + value2
55: 53: /// });
56: 54: ///
57: 55: /// // the value can be accessed synchronously as `Option<T>`
58: 56: /// assert_eq!(derived.get(), None);
59: 57: /// // we can also .await the value, i.e., convert it into a Future
60: 58: /// assert_eq!(derived.await, 0);
61: 59: /// assert_eq!(derived.get(), Some(0));
62: 60: ///
63: 61: /// signal1.set(1);
64: 62: /// // while the new value is still pending, the signal holds the old value
65: 63: /// tokio::time::sleep(std::time::Duration::from_millis(5)).await;
66: 64: /// assert_eq!(derived.get(), Some(0));
67: 65: ///
68: 66: /// // setting multiple dependencies will hold until the latest change is ready
69: 67: /// signal2.set(1);
70: 68: /// assert_eq!(derived.await, 2);
71: 69: /// # });
72: 70: /// ```
73: 71: ///
74: 72: /// ## Core Trait Implementations
75: 73: /// - [`.get()`](crate::traits::Get) clones the current value as an `Option<T>`.
76: 74: ///   If you call it within an effect, it will cause that effect to subscribe
77: 75: ///   to the memo, and to re-run whenever the value of the memo changes.
78: 76: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
79: 77: ///     without reactively tracking it.
80: 78: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
81: 79: ///   value by reference. If you call it within an effect, it will
82: 80: ///   cause that effect to subscribe to the memo, and to re-run whenever the
83: 81: ///   value changes.
84: 82: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
85: 83: ///     current value without reactively tracking it.
86: 84: /// - [`.with()`](crate::traits::With) allows you to reactively access the
87: 85: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
88: 86: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
89: 87: ///     the value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
90: 88: ///     tracking it.
91: 89: /// - [`IntoFuture`](std::future::Future) allows you to create a [`Future`] that resolves
92: 90: ///   when this resource is done loading.
93: 91: pub struct AsyncDerived<T, S = SyncStorage> {
94: 92:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
95: 93:     defined_at: &'static Location<'static>,
96: 94:     pub(crate) inner: ArenaItem<ArcAsyncDerived<T>, S>,
97: 95: }
98: 96: 
99: 97: impl<T, S> Dispose for AsyncDerived<T, S> {
100: 98:     fn dispose(self) {
101: 99:         self.inner.dispose()
102: 100:     }
103: 101: }
104: 102: 
105: 103: impl<T, S> From<ArcAsyncDerived<T>> for AsyncDerived<T, S>
106: 104: where
107: 105:     T: 'static,
108: 106:     S: Storage<ArcAsyncDerived<T>>,
109: 107: {
110: 108:     fn from(value: ArcAsyncDerived<T>) -> Self {
111: 109:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
112: 110:         let defined_at = value.defined_at;
113: 111:         Self {
114: 112:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
115: 113:             defined_at,
116: 114:             inner: ArenaItem::new_with_storage(value),
117: 115:         }
118: 116:     }
119: 117: }
120: 118: 
121: 119: impl<T, S> From<AsyncDerived<T, S>> for ArcAsyncDerived<T>
122: 120: where
123: 121:     T: 'static,
124: 122:     S: Storage<ArcAsyncDerived<T>>,
125: 123: {
126: 124:     #[track_caller]
127: 125:     fn from(value: AsyncDerived<T, S>) -> Self {
128: 126:         value
129: 127:             .inner
130: 128:             .try_get_value()
131: 129:             .unwrap_or_else(unwrap_signal!(value))
132: 130:     }
133: 131: }
134: 132: 
135: 133: impl<T> FromLocal<ArcAsyncDerived<T>> for AsyncDerived<T, LocalStorage>
136: 134: where
137: 135:     T: 'static,
138: 136: {
139: 137:     fn from_local(value: ArcAsyncDerived<T>) -> Self {
140: 138:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
141: 139:         let defined_at = value.defined_at;
142: 140:         Self {
143: 141:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
144: 142:             defined_at,
145: 143:             inner: ArenaItem::new_with_storage(value),
146: 144:         }
147: 145:     }
148: 146: }
149: 147: 
150: 148: impl<T> AsyncDerived<T>
151: 149: where
152: 150:     T: 'static,
153: 151: {
154: 152:     /// Creates a new async derived computation.
155: 153:     ///
156: 154:     /// This runs eagerly: i.e., calls `fun` once when created and immediately spawns the `Future`
157: 155:     /// as a new task.
158: 156:     #[track_caller]
159: 157:     pub fn new<Fut>(fun: impl Fn() -> Fut + Send + Sync + 'static) -> Self
160: 158:     where
161: 159:         T: Send + Sync + 'static,
162: 160:         Fut: Future<Output = T> + Send + 'static,
163: 161:     {
164: 162:         Self {
165: 163:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
166: 164:             defined_at: Location::caller(),
167: 165:             inner: ArenaItem::new_with_storage(ArcAsyncDerived::new(fun)),
168: 166:         }
169: 167:     }
170: 168: 
171: 169:     /// Creates a new async derived computation with an initial value.
172: 170:     ///
173: 171:     /// If the initial value is `Some(_)`, the task will not be run initially.
174: 172:     pub fn new_with_initial<Fut>(
175: 173:         initial_value: Option<T>,
176: 174:         fun: impl Fn() -> Fut + Send + Sync + 'static,
177: 175:     ) -> Self
178: 176:     where
179: 177:         T: Send + Sync + 'static,
180: 178:         Fut: Future<Output = T> + Send + 'static,
181: 179:     {
182: 180:         Self {
183: 181:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
184: 182:             defined_at: Location::caller(),
185: 183:             inner: ArenaItem::new_with_storage(
186: 184:                 ArcAsyncDerived::new_with_initial(initial_value, fun),
187: 185:             ),
188: 186:         }
189: 187:     }
190: 188: }
191: 189: 
192: 190: impl<T> AsyncDerived<T> {
193: 191:     #[doc(hidden)]
194: 192:     pub fn new_mock<Fut>(fun: impl Fn() -> Fut + 'static) -> Self
195: 193:     where
196: 194:         T: 'static,
197: 195:         Fut: Future<Output = T> + 'static,
198: 196:     {
199: 197:         Self {
200: 198:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
201: 199:             defined_at: Location::caller(),
202: 200:             inner: ArenaItem::new_with_storage(ArcAsyncDerived::new_mock(fun)),
203: 201:         }
204: 202:     }
205: 203: 
206: 204:     /// Same as [`AsyncDerived::new_unsync`] except it produces AsyncDerived<T> instead of AsyncDerived<T, LocalStorage>.
207: 205:     /// The internal value will still be wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped in a [`send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper`].
208: 206:     pub fn new_unsync_threadsafe_storage<Fut>(
209: 207:         fun: impl Fn() -> Fut + 'static,
210: 208:     ) -> Self
211: 209:     where
212: 210:         T: 'static,
213: 211:         Fut: Future<Output = T> + 'static,
214: 212:     {
215: 213:         Self {
216: 214:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
217: 215:             defined_at: Location::caller(),
218: 216:             inner: ArenaItem::new_with_storage(ArcAsyncDerived::new_unsync(
219: 217:                 fun,
220: 218:             )),
221: 219:         }
222: 220:     }
223: 221: }
224: 222: 
225: 223: impl<T> AsyncDerived<T, LocalStorage>
226: 224: where
227: 225:     T: 'static,
228: 226: {
229: 227:     /// Creates a new async derived computation that will be guaranteed to run on the current
230: 228:     /// thread.
231: 229:     ///
232: 230:     /// This runs eagerly: i.e., calls `fun` once when created and immediately spawns the `Future`
233: 231:     /// as a new task.
234: 232:     pub fn new_unsync<Fut>(fun: impl Fn() -> Fut + 'static) -> Self
235: 233:     where
236: 234:         T: 'static,
237: 235:         Fut: Future<Output = T> + 'static,
238: 236:     {
239: 237:         Self {
240: 238:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
241: 239:             defined_at: Location::caller(),
242: 240:             inner: ArenaItem::new_with_storage(ArcAsyncDerived::new_unsync(
243: 241:                 fun,
244: 242:             )),
245: 243:         }
246: 244:     }
247: 245: 
248: 246:     /// Creates a new async derived computation with an initial value. Async work will be
249: 247:     /// guaranteed to run only on the current thread.
250: 248:     ///
251: 249:     /// If the initial value is `Some(_)`, the task will not be run initially.
252: 250:     pub fn new_unsync_with_initial<Fut>(
253: 251:         initial_value: Option<T>,
254: 252:         fun: impl Fn() -> Fut + 'static,
255: 253:     ) -> Self
256: 254:     where
257: 255:         T: 'static,
258: 256:         Fut: Future<Output = T> + 'static,
259: 257:     {
260: 258:         Self {
261: 259:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
262: 260:             defined_at: Location::caller(),
263: 261:             inner: ArenaItem::new_with_storage(
264: 262:                 ArcAsyncDerived::new_unsync_with_initial(initial_value, fun),
265: 263:             ),
266: 264:         }
267: 265:     }
268: 266: }
269: 267: 
270: 268: impl<T, S> AsyncDerived<T, S>
271: 269: where
272: 270:     T: 'static,
273: 271:     S: Storage<ArcAsyncDerived<T>>,
274: 272: {
275: 273:     /// Returns a `Future` that is ready when this resource has next finished loading.
276: 274:     #[track_caller]
277: 275:     pub fn ready(&self) -> AsyncDerivedReadyFuture {
278: 276:         let this = self
279: 277:             .inner
280: 278:             .try_get_value()
281: 279:             .unwrap_or_else(unwrap_signal!(self));
282: 280:         this.ready()
283: 281:     }
284: 282: }
285: 283: 
286: 284: impl<T, S> Copy for AsyncDerived<T, S> {}
287: 285: 
288: 286: impl<T, S> Clone for AsyncDerived<T, S> {
289: 287:     fn clone(&self) -> Self {
290: 288:         *self
291: 289:     }
292: 290: }
293: 291: 
294: 292: impl<T, S> Debug for AsyncDerived<T, S>
295: 293: where
296: 294:     S: Debug,
297: 295: {
298: 296:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
299: 297:         f.debug_struct("AsyncDerived")
300: 298:             .field("type", &std::any::type_name::<T>())
301: 299:             .field("store", &self.inner)
302: 300:             .finish()
303: 301:     }
304: 302: }
305: 303: 
306: 304: impl<T, S> DefinedAt for AsyncDerived<T, S> {
307: 305:     #[inline(always)]
308: 306:     fn defined_at(&self) -> Option<&'static Location<'static>> {
309: 307:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
310: 308:         {
311: 309:             Some(self.defined_at)
312: 310:         }
313: 311:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
314: 312:         {
315: 313:             None
316: 314:         }
317: 315:     }
318: 316: }
319: 317: 
320: 318: impl<T, S> ReadUntracked for AsyncDerived<T, S>
321: 319: where
322: 320:     T: 'static,
323: 321:     S: Storage<ArcAsyncDerived<T>>,
324: 322: {
325: 323:     type Value =
326: 324:         ReadGuard<Option<T>, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<AsyncPlain<SendOption<T>>, Option<T>>>;
327: 325: 
328: 326:     fn try_read_untracked(&self) -> Option<Self::Value> {
329: 327:         self.inner
330: 328:             .try_get_value()
331: 329:             .map(|inner| inner.read_untracked())
332: 330:     }
333: 331: }
334: 332: 
335: 333: impl<T, S> Notify for AsyncDerived<T, S>
336: 334: where
337: 335:     T: 'static,
338: 336:     S: Storage<ArcAsyncDerived<T>>,
339: 337: {
340: 338:     fn notify(&self) {
341: 339:         self.inner.try_with_value(|inner| inner.notify());
342: 340:     }
343: 341: }
344: 342: 
345: 343: impl<T, S> Write for AsyncDerived<T, S>
346: 344: where
347: 345:     T: 'static,
348: 346:     S: Storage<ArcAsyncDerived<T>>,
349: 347: {
350: 348:     type Value = Option<T>;
351: 349: 
352: 350:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
353: 351:         let guard = self
354: 352:             .inner
355: 353:             .try_with_value(|n| n.value.blocking_write_arc())?;
356: 354: 
357: 355:         self.inner.try_with_value(|n| {
358: 356:             let mut guard = n.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
359: 357:             // increment the version, such that a rerun triggered previously does not overwrite this
360: 358:             // new value
361: 359:             guard.version += 1;
362: 360: 
363: 361:             // tell any suspenses to stop waiting for this
364: 362:             drop(mem::take(&mut guard.pending_suspenses));
365: 363:         });
366: 364: 
367: 365:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut::new(
368: 366:             WriteGuard::new(*self, guard),
369: 367:             |v| v.deref(),
370: 368:             |v| v.deref_mut(),
371: 369:         ))
372: 370:     }
373: 371: 
374: 372:     fn try_write_untracked(
375: 373:         &self,
376: 374:     ) -> Option<impl DerefMut<Target = Self::Value>> {
377: 375:         self.inner.try_with_value(|n| {
378: 376:             let mut guard = n.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
379: 377:             // increment the version, such that a rerun triggered previously does not overwrite this
380: 378:             // new value
381: 379:             guard.version += 1;
382: 380: 
383: 381:             // tell any suspenses to stop waiting for this
384: 382:             drop(mem::take(&mut guard.pending_suspenses));
385: 383:         });
386: 384: 
387: 385:         self.inner
388: 386:             .try_with_value(|n| n.value.blocking_write_arc())
389: 387:             .map(|inner| {
390: 388:                 Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut::new(inner, |v| v.deref(), |v| v.deref_mut())
391: 389:             })
392: 390:     }
393: 391: }
394: 392: 
395: 393: impl<T, S> IsDisposed for AsyncDerived<T, S>
396: 394: where
397: 395:     T: 'static,
398: 396:     S: Storage<ArcAsyncDerived<T>>,
399: 397: {
400: 398:     fn is_disposed(&self) -> bool {
401: 399:         self.inner.is_disposed()
402: 400:     }
403: 401: }
404: 402: 
405: 403: impl<T, S> ToAnySource for AsyncDerived<T, S>
406: 404: where
407: 405:     T: 'static,
408: 406:     S: Storage<ArcAsyncDerived<T>>,
409: 407: {
410: 408:     fn to_any_source(&self) -> AnySource {
411: 409:         self.inner
412: 410:             .try_get_value()
413: 411:             .map(|inner| inner.to_any_source())
414: 412:             .unwrap_or_else(unwrap_signal!(self))
415: 413:     }
416: 414: }
417: 415: 
418: 416: impl<T, S> ToAnySubscriber for AsyncDerived<T, S>
419: 417: where
420: 418:     T: 'static,
421: 419:     S: Storage<ArcAsyncDerived<T>>,
422: 420: {
423: 421:     fn to_any_subscriber(&self) -> AnySubscriber {
424: 422:         self.inner
425: 423:             .try_get_value()
426: 424:             .map(|inner| inner.to_any_subscriber())
427: 425:             .unwrap_or_else(unwrap_signal!(self))
428: 426:     }
429: 427: }
430: 428: 
431: 429: impl<T, S> Source for AsyncDerived<T, S>
432: 430: where
433: 431:     T: 'static,
434: 432:     S: Storage<ArcAsyncDerived<T>>,
435: 433: {
436: 434:     fn add_subscriber(&self, subscriber: AnySubscriber) {
437: 435:         if let Some(inner) = self.inner.try_get_value() {
438: 436:             inner.add_subscriber(subscriber);
439: 437:         }
440: 438:     }
441: 439: 
442: 440:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
443: 441:         if let Some(inner) = self.inner.try_get_value() {
444: 442:             inner.remove_subscriber(subscriber);
445: 443:         }
446: 444:     }
447: 445: 
448: 446:     fn clear_subscribers(&self) {
449: 447:         if let Some(inner) = self.inner.try_get_value() {
450: 448:             inner.clear_subscribers();
451: 449:         }
452: 450:     }
453: 451: }
454: 452: 
455: 453: impl<T, S> ReactiveNode for AsyncDerived<T, S>
456: 454: where
457: 455:     T: 'static,
458: 456:     S: Storage<ArcAsyncDerived<T>>,
459: 457: {
460: 458:     fn mark_dirty(&self) {
461: 459:         if let Some(inner) = self.inner.try_get_value() {
462: 460:             inner.mark_dirty();
463: 461:         }
464: 462:     }
465: 463: 
466: 464:     fn mark_check(&self) {
467: 465:         if let Some(inner) = self.inner.try_get_value() {
468: 466:             inner.mark_check();
469: 467:         }
470: 468:     }
471: 469: 
472: 470:     fn mark_subscribers_check(&self) {
473: 471:         if let Some(inner) = self.inner.try_get_value() {
474: 472:             inner.mark_subscribers_check();
475: 473:         }
476: 474:     }
477: 475: 
478: 476:     fn update_if_necessary(&self) -> bool {
479: 477:         if let Some(inner) = self.inner.try_get_value() {
480: 478:             inner.update_if_necessary()
481: 479:         } else {
482: 480:             false
483: 481:         }
484: 482:     }
485: 483: }
486: 484: 
487: 485: impl<T, S> Subscriber for AsyncDerived<T, S>
488: 486: where
489: 487:     T: 'static,
490: 488:     S: Storage<ArcAsyncDerived<T>>,
491: 489: {
492: 490:     fn add_source(&self, source: AnySource) {
493: 491:         if let Some(inner) = self.inner.try_get_value() {
494: 492:             inner.add_source(source);
495: 493:         }
496: 494:     }
497: 495: 
498: 496:     fn clear_sources(&self, subscriber: &AnySubscriber) {
499: 497:         if let Some(inner) = self.inner.try_get_value() {
500: 498:             inner.clear_sources(subscriber);
501: 499:         }
502: 500:     }
503: 501: }
504: ```
```
