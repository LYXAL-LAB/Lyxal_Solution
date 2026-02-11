### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\effect\effect.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\effect\effect.rs
2: ```rust
3: 1: use crate::{
4: 2:     channel::{channel, Receiver},
5: 3:     effect::{inner::EffectInner, EffectFunction},
6: 4:     graph::{
7: 5:         AnySubscriber, ReactiveNode, SourceSet, Subscriber, ToAnySubscriber,
8: 6:         WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
9: 7:     },
10: 8:     owner::{ArenaItem, LocalStorage, Owner, Storage, SyncStorage},
11: 9:     traits::Dispose,
12: 10: };
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
14: 12: use futures::StreamExt;
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
16: 14: use std::{
17: 15:     mem,
18: 16:     sync::{atomic::AtomicBool, Arc, RwLock},
19: 17: };
20: 18: 
21: 19: /// Effects run a certain chunk of code whenever the signals they depend on change.
22: 20: ///
23: 21: /// Creating an effect runs the given function once after any current synchronous work is done.
24: 22: /// This tracks its reactive values read within it, and reruns the function whenever the value
25: 23: /// of a dependency changes.
26: 24: ///
27: 25: /// Effects are intended to run *side-effects* of the system, not to synchronize state
28: 26: /// *within* the system. In other words: In most cases, you usually should not write to
29: 27: /// signals inside effects. (If you need to define a signal that depends on the value of
30: 28: /// other signals, use a derived signal or a [`Memo`](crate::computed::Memo)).
31: 29: ///
32: 30: /// You can provide an effect function without parameters or one with one parameter.
33: 31: /// If you provide such a parameter, the effect function is called with an argument containing
34: 32: /// whatever value it returned the last time it ran. On the initial run, this is `None`.
35: 33: ///
36: 34: /// Effects stop running when their reactive [`Owner`] is disposed.
37: 35: ///
38: 36: ///
39: 37: /// ## Example
40: 38: ///
41: 39: /// ```
42: 40: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
43: 41: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
44: 42: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
45: 43: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
46: 44: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::ArenaItem;
47: 45: /// # tokio_test::block_on(async move {
48: 46: /// # tokio::task::LocalSet::new().run_until(async move {
49: 47: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
50: 48: /// let a = RwSignal::new(0);
51: 49: /// let b = RwSignal::new(0);
52: 50: ///
53: 51: /// // ✅ use effects to interact between reactive state and the outside world
54: 52: /// Effect::new(move || {
55: 53: ///   // on the next “tick” prints "Value: 0" and subscribes to `a`
56: 54: ///   println!("Value: {}", a.get());
57: 55: /// });
58: 56: ///
59: 57: /// # assert_eq!(a.get(), 0);
60: 58: /// a.set(1);
61: 59: /// # assert_eq!(a.get(), 1);
62: 60: /// // ✅ because it's subscribed to `a`, the effect reruns and prints "Value: 1"
63: 61: ///
64: 62: /// // ❌ don't use effects to synchronize state within the reactive system
65: 63: /// Effect::new(move || {
66: 64: ///   // this technically works but can cause unnecessary re-renders
67: 65: ///   // and easily lead to problems like infinite loops
68: 66: ///   b.set(a.get() + 1);
69: 67: /// });
70: 68: /// # }).await;
71: 69: /// # });
72: 70: /// ```
73: 71: /// ## Web-Specific Notes
74: 72: ///
75: 73: /// 1. **Scheduling**: Effects run after synchronous work, on the next “tick” of the reactive
76: 74: ///    system. This makes them suitable for “on mount” actions: they will fire immediately after
77: 75: ///    DOM rendering.
78: 76: /// 2. By default, effects do not run unless the `effects` feature is enabled. If you are using
79: 77: ///    this with a web framework, this generally means that effects **do not run on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server**.
80: 78: ///    and you can call browser-specific APIs within the effect function without causing issues.
81: 79: ///    If you need an effect to run on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, use [`Effect::new_isomorphic`].
82: 80: #[derive(Debug, Clone, Copy)]
83: 81: pub struct Effect<S> {
84: 82:     inner: Option<ArenaItem<StoredEffect, S>>,
85: 83: }
86: 84: 
87: 85: type StoredEffect = Option<Arc<RwLock<EffectInner>>>;
88: 86: 
89: 87: impl<S> Dispose for Effect<S> {
90: 88:     fn dispose(self) {
91: 89:         if let Some(inner) = self.inner {
92: 90:             inner.dispose()
93: 91:         }
94: 92:     }
95: 93: }
96: 94: 
97: 95: fn effect_base() -> (Receiver, Owner, Arc<RwLock<EffectInner>>) {
98: 96:     let (mut oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, rx) = channel();
99: 97: 
100: 98:     // spawn the effect asynchronously
101: 99:     // we'll notify once so it runs on the next tick,
102: 100:     // to register observed values
103: 101:     oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.notify();
104: 102: 
105: 103:     let owner = Owner::new();
106: 104:     let inner = Arc::new(RwLock::new(EffectInner {
107: 105:         dirty: true,
108: 106:         oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
109: 107:         sources: SourceSet::new(),
110: 108:     }));
111: 109: 
112: 110:     (rx, owner, inner)
113: 111: }
114: 112: 
115: 113: #[cfg(debug_assertions)]
116: 114: thread_local! {
117: 115:     static EFFECT_SCOPE_ACTIVE: AtomicBool = const { AtomicBool::new(false) };
118: 116: }
119: 117: 
120: 118: #[cfg(debug_assertions)]
121: 119: /// Returns whether the current thread is currently running an effect.
122: 120: pub fn in_effect_scope() -> bool {
123: 121:     EFFECT_SCOPE_ACTIVE
124: 122:         .with(|scope| scope.load(std::sync::atomic::Ordering::Relaxed))
125: 123: }
126: 124: 
127: 125: /// Set a static to true whilst running the given function.
128: 126: /// [`is_in_effect_scope`] will return true whilst the function is running.
129: 127: fn run_in_effect_scope<T>(fun: impl FnOnce() -> T) -> T {
130: 128:     #[cfg(debug_assertions)]
131: 129:     {
132: 130:         // For the theoretical nested case, set back to initial value rather than false:
133: 131:         let initial = EFFECT_SCOPE_ACTIVE.with(|scope| {
134: 132:             scope.swap(true, std::sync::atomic::Ordering::Relaxed)
135: 133:         });
136: 134:         let result = fun();
137: 135:         EFFECT_SCOPE_ACTIVE.with(|scope| {
138: 136:             scope.store(initial, std::sync::atomic::Ordering::Relaxed)
139: 137:         });
140: 138:         result
141: 139:     }
142: 140:     #[cfg(not(debug_assertions))]
143: 141:     {
144: 142:         fun()
145: 143:     }
146: 144: }
147: 145: 
148: 146: impl<S> Effect<S>
149: 147: where
150: 148:     S: Storage<StoredEffect>,
151: 149: {
152: 150:     /// Stops this effect before it is disposed.
153: 151:     pub fn stop(self) {
154: 152:         if let Some(inner) = self
155: 153:             .inner
156: 154:             .and_then(|this| this.try_update_value(|inner| inner.take()))
157: 155:         {
158: 156:             drop(inner);
159: 157:         }
160: 158:     }
161: 159: }
162: 160: 
163: 161: impl Effect<LocalStorage> {
164: 162:     /// Creates a new effect, which runs once on the next “tick”, and then runs again when reactive values
165: 163:     /// that are read inside it change.
166: 164:     ///
167: 165:     /// This spawns a task on the local thread using
168: 166:     /// [`spawn_local`](lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local). For an effect that can be spawned on
169: 167:     /// any thread, use [`new_sync`](Effect::new_sync).
170: 168:     pub fn new<T, M>(mut fun: impl EffectFunction<T, M> + 'static) -> Self
171: 169:     where
172: 170:         T: 'static,
173: 171:     {
174: 172:         let inner = cfg!(feature = "effects").then(|| {
175: 173:             let (mut rx, owner, inner) = effect_base();
176: 174:             let value = Arc::new(RwLock::new(None::<T>));
177: 175:             let mut first_run = true;
178: 176: 
179: 177:             Executor::spawn_local({
180: 178:                 let value = Arc::clone(&value);
181: 179:                 let subscriber = inner.to_any_subscriber();
182: 180: 
183: 181:                 async move {
184: 182:                     while rx.next().await.is_some() {
185: 183:                         if !owner.paused()
186: 184:                             && (subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
187: 185:                                 subscriber.update_if_necessary()
188: 186:                             }) || first_run)
189: 187:                         {
190: 188:                             first_run = false;
191: 189:                             subscriber.clear_sources(&subscriber);
192: 190: 
193: 191:                             let old_value =
194: 192:                                 mem::take(&mut *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned());
195: 193:                             let new_value = owner.with_cleanup(|| {
196: 194:                                 subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
197: 195:                                     run_in_effect_scope(|| fun.run(old_value))
198: 196:                                 })
199: 197:                             });
200: 198:                             *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(new_value);
201: 199:                         }
202: 200:                     }
203: 201:                 }
204: 202:             });
205: 203: 
206: 204:             ArenaItem::new_with_storage(Some(inner))
207: 205:         });
208: 206: 
209: 207:         Self { inner }
210: 208:     }
211: 209: 
212: 210:     /// A version of [`Effect::new`] that only listens to any dependency
213: 211:     /// that is accessed inside `dependency_fn`.
214: 212:     ///
215: 213:     /// The return value of `dependency_fn` is passed into `handler` as an argument together with the previous value.
216: 214:     /// Additionally, the last return value of `handler` is provided as a third argument, as is done in [`Effect::new`].
217: 215:     ///
218: 216:     /// ## Usage
219: 217:     ///
220: 218:     /// ```
221: 219:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
222: 220:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::traits::*;
223: 221:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::signal;
224: 222:     /// # tokio_test::block_on(async move {
225: 223:     /// # tokio::task::LocalSet::new().run_until(async move {
226: 224:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
227: 225:     /// #
228: 226:     /// let (num, set_num) = signal(0);
229: 227:     ///
230: 228:     /// let effect = Effect::watch(
231: 229:     ///     move || num.get(),
232: 230:     ///     move |num, prev_num, _| {
233: 231:     ///         // log::debug!("Number: {}; Prev: {:?}", num, prev_num);
234: 232:     ///     },
235: 233:     ///     false,
236: 234:     /// );
237: 235:     /// # assert_eq!(num.get(), 0);
238: 236:     ///
239: 237:     /// set_num.set(1); // > "Number: 1; Prev: Some(0)"
240: 238:     /// # assert_eq!(num.get(), 1);
241: 239:     ///
242: 240:     /// effect.stop(); // stop watching
243: 241:     ///
244: 242:     /// set_num.set(2); // (nothing hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appens)
245: 243:     /// # assert_eq!(num.get(), 2);
246: 244:     /// # }).await;
247: 245:     /// # });
248: 246:     /// ```
249: 247:     ///
250: 248:     /// The callback itself doesn't track any signal that is accessed within it.
251: 249:     ///
252: 250:     /// ```
253: 251:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
254: 252:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::traits::*;
255: 253:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::signal;
256: 254:     /// # tokio_test::block_on(async move {
257: 255:     /// # tokio::task::LocalSet::new().run_until(async move {
258: 256:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
259: 257:     /// #
260: 258:     /// let (num, set_num) = signal(0);
261: 259:     /// let (cb_num, set_cb_num) = signal(0);
262: 260:     ///
263: 261:     /// Effect::watch(
264: 262:     ///     move || num.get(),
265: 263:     ///     move |num, _, _| {
266: 264:     ///         // log::debug!("Number: {}; Cb: {}", num, cb_num.get());
267: 265:     ///     },
268: 266:     ///     false,
269: 267:     /// );
270: 268:     ///
271: 269:     /// # assert_eq!(num.get(), 0);
272: 270:     /// set_num.set(1); // > "Number: 1; Cb: 0"
273: 271:     /// # assert_eq!(num.get(), 1);
274: 272:     ///
275: 273:     /// # assert_eq!(cb_num.get(), 0);
276: 274:     /// set_cb_num.set(1); // (nothing hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appens)
277: 275:     /// # assert_eq!(cb_num.get(), 1);
278: 276:     ///
279: 277:     /// set_num.set(2); // > "Number: 2; Cb: 1"
280: 278:     /// # assert_eq!(num.get(), 2);
281: 279:     /// # }).await;
282: 280:     /// # });
283: 281:     /// ```
284: 282:     ///
285: 283:     /// ## Immediate
286: 284:     ///
287: 285:     /// If the final parameter `immediate` is true, the `handler` will run immediately.
288: 286:     /// If it's `false`, the `handler` will run only after
289: 287:     /// the first change is detected of any signal that is accessed in `dependency_fn`.
290: 288:     ///
291: 289:     /// ```
292: 290:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
293: 291:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::traits::*;
294: 292:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::signal;
295: 293:     /// # tokio_test::block_on(async move {
296: 294:     /// # tokio::task::LocalSet::new().run_until(async move {
297: 295:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
298: 296:     /// #
299: 297:     /// let (num, set_num) = signal(0);
300: 298:     ///
301: 299:     /// Effect::watch(
302: 300:     ///     move || num.get(),
303: 301:     ///     move |num, prev_num, _| {
304: 302:     ///         // log::debug!("Number: {}; Prev: {:?}", num, prev_num);
305: 303:     ///     },
306: 304:     ///     true,
307: 305:     /// ); // > "Number: 0; Prev: None"
308: 306:     ///
309: 307:     /// # assert_eq!(num.get(), 0);
310: 308:     /// set_num.set(1); // > "Number: 1; Prev: Some(0)"
311: 309:     /// # assert_eq!(num.get(), 1);
312: 310:     /// # }).await;
313: 311:     /// # });
314: 312:     /// ```
315: 313:     pub fn watch<D, T>(
316: 314:         mut dependency_fn: impl FnMut() -> D + 'static,
317: 315:         mut handler: impl FnMut(&D, Option<&D>, Option<T>) -> T + 'static,
318: 316:         immediate: bool,
319: 317:     ) -> Self
320: 318:     where
321: 319:         D: 'static,
322: 320:         T: 'static,
323: 321:     {
324: 322:         let inner = cfg!(feature = "effects").then(|| {
325: 323:             let (mut rx, owner, inner) = effect_base();
326: 324:             let mut first_run = true;
327: 325:             let dep_value = Arc::new(RwLock::new(None::<D>));
328: 326:             let watch_value = Arc::new(RwLock::new(None::<T>));
329: 327: 
330: 328:             Executor::spawn_local({
331: 329:                 let dep_value = Arc::clone(&dep_value);
332: 330:                 let watch_value = Arc::clone(&watch_value);
333: 331:                 let subscriber = inner.to_any_subscriber();
334: 332: 
335: 333:                 async move {
336: 334:                     while rx.next().await.is_some() {
337: 335:                         if !owner.paused()
338: 336:                             && (subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
339: 337:                                 subscriber.update_if_necessary()
340: 338:                             }) || first_run)
341: 339:                         {
342: 340:                             subscriber.clear_sources(&subscriber);
343: 341: 
344: 342:                             let old_dep_value = mem::take(
345: 343:                                 &mut *dep_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(),
346: 344:                             );
347: 345:                             let new_dep_value = owner.with_cleanup(|| {
348: 346:                                 subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&mut dependency_fn)
349: 347:                             });
350: 348: 
351: 349:                             let old_watch_value = mem::take(
352: 350:                                 &mut *watch_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(),
353: 351:                             );
354: 352: 
355: 353:                             if immediate || !first_run {
356: 354:                                 let new_watch_value = handler(
357: 355:                                     &new_dep_value,
358: 356:                                     old_dep_value.as_ref(),
359: 357:                                     old_watch_value,
360: 358:                                 );
361: 359: 
362: 360:                                 *watch_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() =
363: 361:                                     Some(new_watch_value);
364: 362:                             }
365: 363: 
366: 364:                             *dep_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() =
367: 365:                                 Some(new_dep_value);
368: 366: 
369: 367:                             first_run = false;
370: 368:                         }
371: 369:                     }
372: 370:                 }
373: 371:             });
374: 372: 
375: 373:             ArenaItem::new_with_storage(Some(inner))
376: 374:         });
377: 375: 
378: 376:         Self { inner }
379: 377:     }
380: 378: }
381: 379: 
382: 380: impl Effect<SyncStorage> {
383: 381:     /// Creates a new effect, which runs once on the next “tick”, and then runs again when reactive values
384: 382:     /// that are read inside it change.
385: 383:     ///
386: 384:     /// This spawns a task that can be run on any thread. For an effect that will be spawned on
387: 385:     /// the current thread, use [`new`](Effect::new).
388: 386:     pub fn new_sync<T, M>(
389: 387:         fun: impl EffectFunction<T, M> + Send + Sync + 'static,
390: 388:     ) -> Self
391: 389:     where
392: 390:         T: Send + Sync + 'static,
393: 391:     {
394: 392:         if !cfg!(feature = "effects") {
395: 393:             return Self { inner: None };
396: 394:         }
397: 395: 
398: 396:         Self::new_isomorphic(fun)
399: 397:     }
400: 398: 
401: 399:     /// Creates a new effect, which runs once on the next “tick”, and then runs again when reactive values
402: 400:     /// that are read inside it change.
403: 401:     ///
404: 402:     /// This will run whether the `effects` feature is enabled or not.
405: 403:     pub fn new_isomorphic<T, M>(
406: 404:         mut fun: impl EffectFunction<T, M> + Send + Sync + 'static,
407: 405:     ) -> Self
408: 406:     where
409: 407:         T: Send + Sync + 'static,
410: 408:     {
411: 409:         let (mut rx, owner, inner) = effect_base();
412: 410:         let mut first_run = true;
413: 411:         let value = Arc::new(RwLock::new(None::<T>));
414: 412: 
415: 413:         let task = {
416: 414:             let value = Arc::clone(&value);
417: 415:             let subscriber = inner.to_any_subscriber();
418: 416: 
419: 417:             async move {
420: 418:                 while rx.next().await.is_some() {
421: 419:                     if !owner.paused()
422: 420:                         && (subscriber
423: 421:                             .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| subscriber.update_if_necessary())
424: 422:                             || first_run)
425: 423:                     {
426: 424:                         first_run = false;
427: 425:                         subscriber.clear_sources(&subscriber);
428: 426: 
429: 427:                         let old_value =
430: 428:                             mem::take(&mut *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned());
431: 429:                         let new_value = owner.with_cleanup(|| {
432: 430:                             subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
433: 431:                                 run_in_effect_scope(|| fun.run(old_value))
434: 432:                             })
435: 433:                         });
436: 434:                         *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(new_value);
437: 435:                     }
438: 436:                 }
439: 437:             }
440: 438:         };
441: 439: 
442: 440:         crate::spawn(task);
443: 441: 
444: 442:         Self {
445: 443:             inner: Some(ArenaItem::new_with_storage(Some(inner))),
446: 444:         }
447: 445:     }
448: 446: 
449: 447:     /// This is to [`Effect::watch`] what [`Effect::new_sync`] is to [`Effect::new`].
450: 448:     pub fn watch_sync<D, T>(
451: 449:         mut dependency_fn: impl FnMut() -> D + Send + Sync + 'static,
452: 450:         mut handler: impl FnMut(&D, Option<&D>, Option<T>) -> T
453: 451:             + Send
454: 452:             + Sync
455: 453:             + 'static,
456: 454:         immediate: bool,
457: 455:     ) -> Self
458: 456:     where
459: 457:         D: Send + Sync + 'static,
460: 458:         T: Send + Sync + 'static,
461: 459:     {
462: 460:         let (mut rx, owner, inner) = effect_base();
463: 461:         let mut first_run = true;
464: 462:         let dep_value = Arc::new(RwLock::new(None::<D>));
465: 463:         let watch_value = Arc::new(RwLock::new(None::<T>));
466: 464: 
467: 465:         let inner = cfg!(feature = "effects").then(|| {
468: 466:             crate::spawn({
469: 467:                 let dep_value = Arc::clone(&dep_value);
470: 468:                 let watch_value = Arc::clone(&watch_value);
471: 469:                 let subscriber = inner.to_any_subscriber();
472: 470: 
473: 471:                 async move {
474: 472:                     while rx.next().await.is_some() {
475: 473:                         if !owner.paused()
476: 474:                             && (subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
477: 475:                                 subscriber.update_if_necessary()
478: 476:                             }) || first_run)
479: 477:                         {
480: 478:                             subscriber.clear_sources(&subscriber);
481: 479: 
482: 480:                             let old_dep_value = mem::take(
483: 481:                                 &mut *dep_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(),
484: 482:                             );
485: 483:                             let new_dep_value = owner.with_cleanup(|| {
486: 484:                                 subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&mut dependency_fn)
487: 485:                             });
488: 486: 
489: 487:                             let old_watch_value = mem::take(
490: 488:                                 &mut *watch_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(),
491: 489:                             );
492: 490: 
493: 491:                             if immediate || !first_run {
494: 492:                                 let new_watch_value = handler(
495: 493:                                     &new_dep_value,
496: 494:                                     old_dep_value.as_ref(),
497: 495:                                     old_watch_value,
498: 496:                                 );
499: 497: 
500: 498:                                 *watch_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() =
501: 499:                                     Some(new_watch_value);
502: 500:                             }
503: 501: 
504: 502:                             *dep_value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() =
505: 503:                                 Some(new_dep_value);
506: 504: 
507: 505:                             first_run = false;
508: 506:                         }
509: 507:                     }
510: 508:                 }
511: 509:             });
512: 510: 
513: 511:             ArenaItem::new_with_storage(Some(inner))
514: 512:         });
515: 513: 
516: 514:         Self { inner }
517: 515:     }
518: 516: }
519: 517: 
520: 518: impl<S> ToAnySubscriber for Effect<S>
521: 519: where
522: 520:     S: Storage<StoredEffect>,
523: 521: {
524: 522:     fn to_any_subscriber(&self) -> AnySubscriber {
525: 523:         self.inner
526: 524:             .and_then(|inner| {
527: 525:                 inner
528: 526:                     .try_with_value(|inner| {
529: 527:                         inner.as_ref().map(|inner| inner.to_any_subscriber())
530: 528:                     })
531: 529:                     .flatten()
532: 530:             })
533: 531:             .expect("tried to set effect that has been stopped")
534: 532:     }
535: 533: }
536: 534: 
537: 535: /// Creates an [`Effect`].
538: 536: #[inline(always)]
539: 537: #[track_caller]
540: 538: #[deprecated = "This function is being removed to conform to Rust idioms. \
541: 539:                 Please use `Effect::new()` instead."]
542: 540: pub fn create_effect<T>(
543: 541:     fun: impl FnMut(Option<T>) -> T + 'static,
544: 542: ) -> Effect<LocalStorage>
545: 543: where
546: 544:     T: 'static,
547: 545: {
548: 546:     Effect::new(fun)
549: 547: }
550: 548: 
551: 549: /// Creates an [`Effect`], equivalent to [Effect::watch].
552: 550: #[inline(always)]
553: 551: #[track_caller]
554: 552: #[deprecated = "This function is being removed to conform to Rust idioms. \
555: 553:                 Please use `Effect::watch()` instead."]
556: 554: pub fn watch<W, T>(
557: 555:     deps: impl Fn() -> W + 'static,
558: 556:     callback: impl Fn(&W, Option<&W>, Option<T>) -> T + Clone + 'static,
559: 557:     immediate: bool,
560: 558: ) -> impl Fn() + Clone
561: 559: where
562: 560:     W: Clone + 'static,
563: 561:     T: 'static,
564: 562: {
565: 563:     let watch = Effect::watch(deps, callback, immediate);
566: 564: 
567: 565:     move || watch.stop()
568: 566: }
569: ```
```
