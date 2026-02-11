### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\src\lib.rs
2: ```rust
3: 1: //! This crate makes it easier to write asynchronous code that is executor-agnostic, by providing a
4: 2: //! utility that can be used to spawn tasks in a variety of executors.
5: 3: //!
6: 4: //! It only supports single executor per program, but that executor can be set at runtime, anywhere
7: 5: //! in your crate (or an lyx-platform-lyx_platform_lyx-platform-lyx_platform_application that depends on it).
8: 6: //!
9: 7: //! This can be extended to support any executor or runtime that supports spawning [`Future`]s.
10: 8: //!
11: 9: //! This is a least common denominator implementation in many ways. Limitations include:
12: 10: //! - setting an executor is a one-time, global action
13: 11: //! - no "join handle" or other result is returned from the spawn
14: 12: //! - the `Future` must output `()`
15: 13: //!
16: 14: //! ```no_run
17: 15: //! use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
18: 16: //!
19: 17: //! // make sure an Executor has been initialized with one of the init_ functions
20: 18: //!
21: 19: //! // spawn a thread-safe Future
22: 20: //! Executor::spawn(async { /* ... */ });
23: 21: //!
24: 22: //! // spawn a Future that is !Send
25: 23: //! Executor::spawn_local(async { /* ... */ });
26: 24: //! ```
27: 25: 
28: 26: #![forbid(unsafe_code)]
29: 27: #![deny(missing_docs)]
30: 28: #![cfg_attr(docsrs, feature(doc_cfg))]
31: 29: 
32: 30: use std::{future::Future, pin::Pin, sync::OnceLock};
33: 31: use thiserror::Error;
34: 32: 
35: 33: /// A future that has been pinned.
36: 34: pub type PinnedFuture<T> = Pin<Box<dyn Future<Output = T> + Send>>;
37: 35: /// A future that has been pinned.
38: 36: pub type PinnedLocalFuture<T> = Pin<Box<dyn Future<Output = T>>>;
39: 37: 
40: 38: // Type alias for the spawn function pointer.
41: 39: type SpawnFn = fn(PinnedFuture<()>);
42: 40: // Type alias for the spawn_local function pointer.
43: 41: type SpawnLocalFn = fn(PinnedLocalFuture<()>);
44: 42: // Type alias for the poll_local function pointer.
45: 43: type PollLocalFn = fn();
46: 44: 
47: 45: /// Holds the function pointers for the current global executor.
48: 46: #[derive(Clone, Copy)]
49: 47: struct ExecutorFns {
50: 48:     spawn: SpawnFn,
51: 49:     spawn_local: SpawnLocalFn,
52: 50:     poll_local: PollLocalFn,
53: 51: }
54: 52: 
55: 53: // Use a single OnceLock to ensure atomic initialization of all functions.
56: 54: static EXECUTOR_FNS: OnceLock<ExecutorFns> = OnceLock::new();
57: 55: 
58: 56: // No-op functions to use when an executor doesn't support a specific operation.
59: 57: #[cfg(any(feature = "tokio", feature = "wasm-bindgen", feature = "glib"))]
60: 58: #[cold]
61: 59: #[inline(never)]
62: 60: fn no_op_poll() {}
63: 61: 
64: 62: #[cfg(all(not(feature = "wasm-bindgen"), not(debug_assertions)))]
65: 63: #[cold]
66: 64: #[inline(never)]
67: 65: fn no_op_spawn(_: PinnedFuture<()>) {
68: 66:     #[cfg(debug_assertions)]
69: 67:     eprintln!(
70: 68:         "Warning: Executor::spawn called, but no global 'spawn' function is \
71: 69:          configured (perhaps only spawn_local is supported, e.g., on wasm \
72: 70:          without threading?)."
73: 71:     );
74: 72: }
75: 73: 
76: 74: // Wasm panics if you spawn without an executor
77: 75: #[cfg(feature = "wasm-bindgen")]
78: 76: #[cold]
79: 77: #[inline(never)]
80: 78: fn no_op_spawn(_: PinnedFuture<()>) {
81: 79:     panic!(
82: 80:         "Executor::spawn called, but no global 'spawn' function is configured."
83: 81:     );
84: 82: }
85: 83: 
86: 84: #[cfg(not(debug_assertions))]
87: 85: #[cold]
88: 86: #[inline(never)]
89: 87: fn no_op_spawn_local(_: PinnedLocalFuture<()>) {
90: 88:     panic!(
91: 89:         "Executor::spawn_local called, but no global 'spawn_local' function \
92: 90:          is configured."
93: 91:     );
94: 92: }
95: 93: 
96: 94: /// Errors that can occur when using the executor.
97: 95: #[derive(Error, Debug)]
98: 96: pub enum ExecutorError {
99: 97:     /// The executor has already been set.
100: 98:     #[error("Global executor has already been set.")]
101: 99:     AlreadySet,
102: 100: }
103: 101: 
104: 102: /// A global async executor that can spawn tasks.
105: 103: pub struct Executor;
106: 104: 
107: 105: impl Executor {
108: 106:     /// Spawns a thread-safe [`Future`].
109: 107:     ///
110: 108:     /// Uses the globally configured executor.
111: 109:     /// Panics if no global executor has been initialized.
112: 110:     #[inline(always)]
113: 111:     #[track_caller]
114: 112:     pub fn spawn(fut: impl Future<Output = ()> + Send + 'static) {
115: 113:         let pinned_fut = Box::pin(fut);
116: 114: 
117: 115:         if let Some(fns) = EXECUTOR_FNS.get() {
118: 116:             (fns.spawn)(pinned_fut)
119: 117:         } else {
120: 118:             // No global executor set.
121: 119:             handle_uninitialized_spawn(pinned_fut);
122: 120:         }
123: 121:     }
124: 122: 
125: 123:     /// Spawns a [`Future`] that cannot be sent across threads.
126: 124:     ///
127: 125:     /// Uses the globally configured executor.
128: 126:     /// Panics if no global executor has been initialized.
129: 127:     #[inline(always)]
130: 128:     #[track_caller]
131: 129:     pub fn spawn_local(fut: impl Future<Output = ()> + 'static) {
132: 130:         let pinned_fut = Box::pin(fut);
133: 131: 
134: 132:         if let Some(fns) = EXECUTOR_FNS.get() {
135: 133:             (fns.spawn_local)(pinned_fut)
136: 134:         } else {
137: 135:             // No global executor set.
138: 136:             handle_uninitialized_spawn_local(pinned_fut);
139: 137:         }
140: 138:     }
141: 139: 
142: 140:     /// Waits until the next "tick" of the current async executor.
143: 141:     /// Respects the global executor.
144: 142:     #[inline(always)]
145: 143:     pub async fn tick() {
146: 144:         let (tx, rx) = futures::channel::oneshot::channel();
147: 145:         #[cfg(not(all(feature = "wasm-bindgen", target_family = "wasm")))]
148: 146:         Executor::spawn(async move {
149: 147:             _ = tx.send(());
150: 148:         });
151: 149:         #[cfg(all(feature = "wasm-bindgen", target_family = "wasm"))]
152: 150:         Executor::spawn_local(async move {
153: 151:             _ = tx.send(());
154: 152:         });
155: 153: 
156: 154:         _ = rx.await;
157: 155:     }
158: 156: 
159: 157:     /// Polls the global async executor.
160: 158:     ///
161: 159:     /// Uses the globally configured executor.
162: 160:     /// Does nothing if the global executor does not support polling.
163: 161:     #[inline(always)]
164: 162:     pub fn poll_local() {
165: 163:         if let Some(fns) = EXECUTOR_FNS.get() {
166: 164:             (fns.poll_local)()
167: 165:         }
168: 166:         // If not initialized or doesn't support polling, do nothing gracefully.
169: 167:     }
170: 168: }
171: 169: 
172: 170: impl Executor {
173: 171:     /// Globally sets the [`tokio`] runtime as the executor used to spawn tasks.
174: 172:     ///
175: 173:     /// Returns `Err(_)` if a global executor has already been set.
176: 174:     ///
177: 175:     /// Requires the `tokio` feature to be activated on this crate.
178: 176:     #[cfg(feature = "tokio")]
179: 177:     #[cfg_attr(docsrs, doc(cfg(feature = "tokio")))]
180: 178:     pub fn init_tokio() -> Result<(), ExecutorError> {
181: 179:         let executor_impl = ExecutorFns {
182: 180:             spawn: |fut| {
183: 181:                 tokio::spawn(fut);
184: 182:             },
185: 183:             spawn_local: |fut| {
186: 184:                 tokio::task::spawn_local(fut);
187: 185:             },
188: 186:             // Tokio doesn't have an explicit global poll function like LocalPool::run_until_stalled
189: 187:             poll_local: no_op_poll,
190: 188:         };
191: 189:         EXECUTOR_FNS
192: 190:             .set(executor_impl)
193: 191:             .map_err(|_| ExecutorError::AlreadySet)
194: 192:     }
195: 193: 
196: 194:     /// Globally sets the [`wasm-bindgen-futures`] runtime as the executor used to spawn tasks.
197: 195:     ///
198: 196:     /// Returns `Err(_)` if a global executor has already been set.
199: 197:     ///
200: 198:     /// Requires the `wasm-bindgen` feature to be activated on this crate.
201: 199:     #[cfg(feature = "wasm-bindgen")]
202: 200:     #[cfg_attr(docsrs, doc(cfg(feature = "wasm-bindgen")))]
203: 201:     pub fn init_wasm_bindgen() -> Result<(), ExecutorError> {
204: 202:         let executor_impl = ExecutorFns {
205: 203:             // wasm-bindgen-futures only supports spawn_local
206: 204:             spawn: no_op_spawn,
207: 205:             spawn_local: |fut| {
208: 206:                 wasm_bindgen_futures::spawn_local(fut);
209: 207:             },
210: 208:             poll_local: no_op_poll,
211: 209:         };
212: 210:         EXECUTOR_FNS
213: 211:             .set(executor_impl)
214: 212:             .map_err(|_| ExecutorError::AlreadySet)
215: 213:     }
216: 214: 
217: 215:     /// Globally sets the [`glib`] runtime as the executor used to spawn tasks.
218: 216:     ///
219: 217:     /// Returns `Err(_)` if a global executor has already been set.
220: 218:     ///
221: 219:     /// Requires the `glib` feature to be activated on this crate.
222: 220:     #[cfg(feature = "glib")]
223: 221:     #[cfg_attr(docsrs, doc(cfg(feature = "glib")))]
224: 222:     pub fn init_glib() -> Result<(), ExecutorError> {
225: 223:         let executor_impl = ExecutorFns {
226: 224:             spawn: |fut| {
227: 225:                 let main_context = glib::MainContext::default();
228: 226:                 main_context.spawn(fut);
229: 227:             },
230: 228:             spawn_local: |fut| {
231: 229:                 let main_context = glib::MainContext::default();
232: 230:                 main_context.spawn_local(fut);
233: 231:             },
234: 232:             // Glib needs event loop integration, explicit polling isn't the standard model here.
235: 233:             poll_local: no_op_poll,
236: 234:         };
237: 235:         EXECUTOR_FNS
238: 236:             .set(executor_impl)
239: 237:             .map_err(|_| ExecutorError::AlreadySet)
240: 238:     }
241: 239: 
242: 240:     /// Globally sets the [`futures`] executor as the executor used to spawn tasks,
243: 241:     /// lazily creating a thread pool to spawn tasks into.
244: 242:     ///
245: 243:     /// Returns `Err(_)` if a global executor has already been set.
246: 244:     ///
247: 245:     /// Requires the `futures-executor` feature to be activated on this crate.
248: 246:     #[cfg(feature = "futures-executor")]
249: 247:     #[cfg_attr(docsrs, doc(cfg(feature = "futures-executor")))]
250: 248:     pub fn init_futures_executor() -> Result<(), ExecutorError> {
251: 249:         use futures::{
252: 250:             executor::{LocalPool, LocalSpawner, ThreadPool},
253: 251:             task::{LocalSpawnExt, SpawnExt},
254: 252:         };
255: 253:         use std::cell::RefCell;
256: 254: 
257: 255:         // Keep the lazy-init ThreadPool and thread-local LocalPool for spawn_local impl
258: 256:         static THREAD_POOL: OnceLock<ThreadPool> = OnceLock::new();
259: 257:         thread_local! {
260: 258:             static LOCAL_POOL: RefCell<LocalPool> = RefCell::new(LocalPool::new());
261: 259:             // SPAWNER is derived from LOCAL_POOL, keep it for efficiency inside the closure
262: 260:             static SPAWNER: LocalSpawner = LOCAL_POOL.with(|pool| pool.borrow().spawner());
263: 261:         }
264: 262: 
265: 263:         fn get_thread_pool() -> &'static ThreadPool {
266: 264:             THREAD_POOL.get_or_init(|| {
267: 265:                 ThreadPool::new()
268: 266:                     .expect("could not create futures executor ThreadPool")
269: 267:             })
270: 268:         }
271: 269: 
272: 270:         let executor_impl = ExecutorFns {
273: 271:             spawn: |fut| {
274: 272:                 get_thread_pool()
275: 273:                     .spawn(fut)
276: 274:                     .expect("failed to spawn future on ThreadPool");
277: 275:             },
278: 276:             spawn_local: |fut| {
279: 277:                 // Use the thread_local SPAWNER derived from LOCAL_POOL
280: 278:                 SPAWNER.with(|spawner| {
281: 279:                     spawner
282: 280:                         .spawn_local(fut)
283: 281:                         .expect("failed to spawn local future");
284: 282:                 });
285: 283:             },
286: 284:             poll_local: || {
287: 285:                 // Use the thread_local LOCAL_POOL
288: 286:                 LOCAL_POOL.with(|pool| {
289: 287:                     // Use try_borrow_mut to prevent panic during re-entrant calls
290: 288:                     if let Ok(mut pool) = pool.try_borrow_mut() {
291: 289:                         pool.run_until_stalled();
292: 290:                     }
293: 291:                     // If already borrowed, we're likely in a nested poll, so do nothing.
294: 292:                 });
295: 293:             },
296: 294:         };
297: 295: 
298: 296:         EXECUTOR_FNS
299: 297:             .set(executor_impl)
300: 298:             .map_err(|_| ExecutorError::AlreadySet)
301: 299:     }
302: 300: 
303: 301:     /// Globally sets the [`async_executor`] executor as the executor used to spawn tasks,
304: 302:     /// lazily creating a thread pool to spawn tasks into.
305: 303:     ///
306: 304:     /// Returns `Err(_)` if a global executor has already been set.
307: 305:     ///
308: 306:     /// Requires the `async-executor` feature to be activated on this crate.
309: 307:     #[cfg(feature = "async-executor")]
310: 308:     #[cfg_attr(docsrs, doc(cfg(feature = "async-executor")))]
311: 309:     pub fn init_async_executor() -> Result<(), ExecutorError> {
312: 310:         use async_executor::{Executor as AsyncExecutor, LocalExecutor};
313: 311: 
314: 312:         // Keep the lazy-init global Executor and thread-local LocalExecutor for spawn_local impl
315: 313:         static ASYNC_EXECUTOR: OnceLock<AsyncExecutor<'static>> =
316: 314:             OnceLock::new();
317: 315:         thread_local! {
318: 316:             static LOCAL_EXECUTOR_POOL: LocalExecutor<'static> = const { LocalExecutor::new() };
319: 317:         }
320: 318: 
321: 319:         fn get_async_executor() -> &'static AsyncExecutor<'static> {
322: 320:             ASYNC_EXECUTOR.get_or_init(AsyncExecutor::new)
323: 321:         }
324: 322: 
325: 323:         let executor_impl = ExecutorFns {
326: 324:             spawn: |fut| {
327: 325:                 get_async_executor().spawn(fut).detach();
328: 326:             },
329: 327:             spawn_local: |fut| {
330: 328:                 LOCAL_EXECUTOR_POOL.with(|pool| pool.spawn(fut).detach());
331: 329:             },
332: 330:             poll_local: || {
333: 331:                 LOCAL_EXECUTOR_POOL.with(|pool| {
334: 332:                     // try_tick polls the local executor without blocking
335: 333:                     // This prevents issues if called recursively or from within a task.
336: 334:                     pool.try_tick();
337: 335:                 });
338: 336:             },
339: 337:         };
340: 338:         EXECUTOR_FNS
341: 339:             .set(executor_impl)
342: 340:             .map_err(|_| ExecutorError::AlreadySet)
343: 341:     }
344: 342: 
345: 343:     /// Globally sets a custom executor as the executor used to spawn tasks.
346: 344:     ///
347: 345:     /// Requires the custom executor to be `Send + Sync` as it will be stored statically.
348: 346:     ///
349: 347:     /// Returns `Err(_)` if a global executor has already been set.
350: 348:     pub fn init_custom_executor(
351: 349:         custom_executor: impl CustomExecutor + Send + Sync + 'static,
352: 350:     ) -> Result<(), ExecutorError> {
353: 351:         // Store the custom executor instance itself to call its methods.
354: 352:         // Use Box for dynamic dispatch.
355: 353:         static CUSTOM_EXECUTOR_INSTANCE: OnceLock<
356: 354:             Box<dyn CustomExecutor + Send + Sync>,
357: 355:         > = OnceLock::new();
358: 356: 
359: 357:         CUSTOM_EXECUTOR_INSTANCE
360: 358:             .set(Box::new(custom_executor))
361: 359:             .map_err(|_| ExecutorError::AlreadySet)?;
362: 360: 
363: 361:         // Now set the ExecutorFns using the stored instance
364: 362:         let executor_impl = ExecutorFns {
365: 363:             spawn: |fut| {
366: 364:                 // Unwrap is safe because we just set it successfully or returned Err.
367: 365:                 CUSTOM_EXECUTOR_INSTANCE.get().unwrap().spawn(fut);
368: 366:             },
369: 367:             spawn_local: |fut| {
370: 368:                 CUSTOM_EXECUTOR_INSTANCE.get().unwrap().spawn_local(fut);
371: 369:             },
372: 370:             poll_local: || {
373: 371:                 CUSTOM_EXECUTOR_INSTANCE.get().unwrap().poll_local();
374: 372:             },
375: 373:         };
376: 374: 
377: 375:         EXECUTOR_FNS
378: 376:             .set(executor_impl)
379: 377:             .map_err(|_| ExecutorError::AlreadySet)
380: 378:         // If setting EXECUTOR_FNS fails (extremely unlikely race if called *concurrently*
381: 379:         // with another init_* after CUSTOM_EXECUTOR_INSTANCE was set), we technically
382: 380:         // leave CUSTOM_EXECUTOR_INSTANCE set but EXECUTOR_FNS not. This is an edge case,
383: 381:         // but the primary race condition is solved.
384: 382:     }
385: 383: 
386: 384:     /// Sets a custom executor *for the current thread only*.
387: 385:     ///
388: 386:     /// This overrides the global executor for calls to `spawn`, `spawn_local`, and `poll_local`
389: 387:     /// made *from the current thread*. It does not affect other threads or the global state.
390: 388:     ///
391: 389:     /// The provided `custom_executor` must implement [`CustomExecutor`] and `'static`, but does
392: 390:     /// **not** need to be `Send` or `Sync`.
393: 391:     ///
394: 392:     /// Returns `Err(ExecutorError::AlreadySet)` if a *local* executor has already been set
395: 393:     /// *for this thread*.
396: 394:     pub fn init_local_custom_executor(
397: 395:         custom_executor: impl CustomExecutor + 'static,
398: 396:     ) -> Result<(), ExecutorError> {
399: 397:         // Store the custom executor instance itself to call its methods.
400: 398:         // Use Box for dynamic dispatch.
401: 399:         thread_local! {
402: 400:             static CUSTOM_EXECUTOR_INSTANCE: OnceLock<
403: 401:                 Box<dyn CustomExecutor>,
404: 402:             > = OnceLock::new();
405: 403:         };
406: 404: 
407: 405:         CUSTOM_EXECUTOR_INSTANCE.with(|this| {
408: 406:             this.set(Box::new(custom_executor))
409: 407:                 .map_err(|_| ExecutorError::AlreadySet)
410: 408:         })?;
411: 409: 
412: 410:         // Now set the ExecutorFns using the stored instance
413: 411:         let executor_impl = ExecutorFns {
414: 412:             spawn: |fut| {
415: 413:                 // Unwrap is safe because we just set it successfully or returned Err.
416: 414:                 CUSTOM_EXECUTOR_INSTANCE
417: 415:                     .with(|this| this.get().unwrap().spawn(fut));
418: 416:             },
419: 417:             spawn_local: |fut| {
420: 418:                 CUSTOM_EXECUTOR_INSTANCE
421: 419:                     .with(|this| this.get().unwrap().spawn_local(fut));
422: 420:             },
423: 421:             poll_local: || {
424: 422:                 CUSTOM_EXECUTOR_INSTANCE
425: 423:                     .with(|this| this.get().unwrap().poll_local());
426: 424:             },
427: 425:         };
428: 426: 
429: 427:         EXECUTOR_FNS
430: 428:             .set(executor_impl)
431: 429:             .map_err(|_| ExecutorError::AlreadySet)
432: 430:     }
433: 431: }
434: 432: 
435: 433: /// A trait for custom executors.
436: 434: /// Custom executors can be used to integrate with any executor that supports spawning futures.
437: 435: ///
438: 436: /// If used with `init_custom_executor`, the implementation must be `Send + Sync + 'static`.
439: 437: ///
440: 438: /// All methods can be called recursively. Implementors should be mindful of potential
441: 439: /// deadlocks or excessive resource consumption if recursive calls are not handled carefully
442: 440: /// (e.g., using `try_borrow_mut` or non-blocking polls within implementations).
443: 441: pub trait CustomExecutor {
444: 442:     /// Spawns a future, usually on a thread pool.
445: 443:     fn spawn(&self, fut: PinnedFuture<()>);
446: 444:     /// Spawns a local future. May require calling `poll_local` to make progress.
447: 445:     fn spawn_local(&self, fut: PinnedLocalFuture<()>);
448: 446:     /// Polls the executor, if it supports polling. Implementations should ideally be
449: 447:     /// non-blocking or use mechanisms like `try_tick` or `try_borrow_mut` to handle
450: 448:     /// re-entrant calls safely.
451: 449:     fn poll_local(&self);
452: 450: }
453: 451: 
454: 452: // Ensure CustomExecutor is object-safe
455: 453: #[allow(dead_code)]
456: 454: fn test_object_safety(_: Box<dyn CustomExecutor + Send + Sync>) {} // Added Send + Sync constraint here for global usage
457: 455: 
458: 456: /// Handles the case where `Executor::spawn` is called without an initialized executor.
459: 457: #[cold] // Less likely path
460: 458: #[inline(never)]
461: 459: #[track_caller]
462: 460: fn handle_uninitialized_spawn(_fut: PinnedFuture<()>) {
463: 461:     let caller = std::panic::Location::caller();
464: 462:     #[cfg(all(debug_assertions, feature = "tracing"))]
465: 463:     {
466: 464:         tracing::error!(
467: 465:             target: "lyx-core-lyx_core_lyx-core-lyx_core_any_spawner",
468: 466:             spawn_caller=%caller,
469: 467:             "Executor::spawn called before a global executor was initialized. Task dropped."
470: 468:         );
471: 469:         // Drop the future implicitly after logging
472: 470:         drop(_fut);
473: 471:     }
474: 472:     #[cfg(all(debug_assertions, not(feature = "tracing")))]
475: 473:     {
476: 474:         panic!(
477: 475:             "At {caller}, tried to spawn a Future with Executor::spawn() \
478: 476:              before a global executor was initialized."
479: 477:         );
480: 478:     }
481: 479:     // In release builds (without tracing), call the specific no-op function.
482: 480:     #[cfg(not(debug_assertions))]
483: 481:     {
484: 482:         no_op_spawn(_fut);
485: 483:     }
486: 484: }
487: 485: 
488: 486: /// Handles the case where `Executor::spawn_local` is called without an initialized executor.
489: 487: #[cold] // Less likely path
490: 488: #[inline(never)]
491: 489: #[track_caller]
492: 490: fn handle_uninitialized_spawn_local(_fut: PinnedLocalFuture<()>) {
493: 491:     let caller = std::panic::Location::caller();
494: 492:     #[cfg(all(debug_assertions, feature = "tracing"))]
495: 493:     {
496: 494:         tracing::error!(
497: 495:             target: "lyx-core-lyx_core_lyx-core-lyx_core_any_spawner",
498: 496:             spawn_caller=%caller,
499: 497:             "Executor::spawn_local called before a global executor was initialized. \
500: 498:             Task likely dropped or panicked."
501: 499:         );
502: 500:         // Fall through to panic or no-op depending on build/target
503: 501:     }
504: 502:     #[cfg(all(debug_assertions, not(feature = "tracing")))]
505: 503:     {
506: 504:         panic!(
507: 505:             "At {caller}, tried to spawn a Future with \
508: 506:              Executor::spawn_local() before a global executor was initialized."
509: 507:         );
510: 508:     }
511: 509:     // In release builds (without tracing), call the specific no-op function (which usually panics).
512: 510:     #[cfg(not(debug_assertions))]
513: 511:     {
514: 512:         no_op_spawn_local(_fut);
515: 513:     }
516: 514: }
517: ```
```
