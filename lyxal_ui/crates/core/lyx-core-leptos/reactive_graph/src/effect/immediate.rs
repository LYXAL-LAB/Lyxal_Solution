### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\effect\immediate.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\effect\immediate.rs
2: ```rust
3: 1: use crate::{
4: 2:     graph::{AnySubscriber, ReactiveNode, ToAnySubscriber},
5: 3:     owner::on_cleanup,
6: 4:     traits::{DefinedAt, Dispose},
7: 5: };
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
9: 7: use std::{
10: 8:     panic::Location,
11: 9:     sync::{Arc, Mutex, RwLock},
12: 10: };
13: 11: 
14: 12: /// Effects run a certain chunk of code whenever the signals they depend on change.
15: 13: ///
16: 14: /// The effect runs on creation and again as soon as any tracked signal changes.
17: 15: ///
18: 16: /// NOTE: you probably want use [`Effect`](super::Effect) instead.
19: 17: /// This is for the few cases where it's important to execute effects immediately and in order.
20: 18: ///
21: 19: /// [ImmediateEffect]s stop running when dropped.
22: 20: ///
23: 21: /// NOTE: since effects are executed immediately, they might recurse.
24: 22: /// Under recursion or parallelism only the last run to start is tracked.
25: 23: ///
26: 24: /// ## Example
27: 25: ///
28: 26: /// ```
29: 27: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
30: 28: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
31: 29: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
32: 30: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::ImmediateEffect;
33: 31: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::ArenaItem;
34: 32: /// # let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
35: 33: /// let a = RwSignal::new(0);
36: 34: /// let b = RwSignal::new(0);
37: 35: ///
38: 36: /// // ✅ use effects to interact between reactive state and the outside world
39: 37: /// let _drop_guard = ImmediateEffect::new(move || {
40: 38: ///   // on the next “tick” prints "Value: 0" and subscribes to `a`
41: 39: ///   println!("Value: {}", a.get());
42: 40: /// });
43: 41: ///
44: 42: /// // The effect runs immediately and subscribes to `a`, in the process it prints "Value: 0"
45: 43: /// # assert_eq!(a.get(), 0);
46: 44: /// a.set(1);
47: 45: /// # assert_eq!(a.get(), 1);
48: 46: /// // ✅ because it's subscribed to `a`, the effect reruns and prints "Value: 1"
49: 47: /// ```
50: 48: /// ## Notes
51: 49: ///
52: 50: /// 1. **Scheduling**: Effects run immediately, as soon as any tracked signal changes.
53: 51: /// 2. By default, effects do not run unless the `effects` feature is enabled. If you are using
54: 52: ///    this with a web framework, this generally means that effects **do not run on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server**.
55: 53: ///    and you can call browser-specific APIs within the effect function without causing issues.
56: 54: ///    If you need an effect to run on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, use [`ImmediateEffect::new_isomorphic`].
57: 55: #[derive(Debug, Clone)]
58: 56: pub struct ImmediateEffect {
59: 57:     inner: StoredEffect,
60: 58: }
61: 59: 
62: 60: type StoredEffect = Option<Arc<RwLock<inner::EffectInner>>>;
63: 61: 
64: 62: impl Dispose for ImmediateEffect {
65: 63:     fn dispose(self) {}
66: 64: }
67: 65: 
68: 66: impl ImmediateEffect {
69: 67:     /// Creates a new effect which runs immediately, then again as soon as any tracked signal changes.
70: 68:     /// (Unless [batch] is used.)
71: 69:     ///
72: 70:     /// NOTE: this requires a `Fn` function because it might recurse.
73: 71:     /// Use [Self::new_mut] to pass a `FnMut` function, it'll panic on recursion.
74: 72:     #[track_caller]
75: 73:     #[must_use]
76: 74:     pub fn new(fun: impl Fn() + Send + Sync + 'static) -> Self {
77: 75:         if !cfg!(feature = "effects") {
78: 76:             return Self { inner: None };
79: 77:         }
80: 78: 
81: 79:         let inner = inner::EffectInner::new(fun);
82: 80: 
83: 81:         inner.update_if_necessary();
84: 82: 
85: 83:         Self { inner: Some(inner) }
86: 84:     }
87: 85:     /// Creates a new effect which runs immediately, then again as soon as any tracked signal changes.
88: 86:     /// (Unless [batch] is used.)
89: 87:     ///
90: 88:     /// # Panics
91: 89:     /// Panics on recursion or if triggered in parallel. Also see [Self::new]
92: 90:     #[track_caller]
93: 91:     #[must_use]
94: 92:     pub fn new_mut(fun: impl FnMut() + Send + Sync + 'static) -> Self {
95: 93:         const MSG: &str = "The effect recursed or its function panicked.";
96: 94:         let fun = Mutex::new(fun);
97: 95:         Self::new(move || fun.try_lock().expect(MSG)())
98: 96:     }
99: 97:     /// Creates a new effect which runs immediately, then again as soon as any tracked signal changes.
100: 98:     /// (Unless [batch] is used.)
101: 99:     ///
102: 100:     /// NOTE: this requires a `Fn` function because it might recurse.
103: 101:     /// Use [Self::new_mut_scoped] to pass a `FnMut` function, it'll panic on recursion.
104: 102:     /// NOTE: this effect is automatically cleaned up when the current owner is cleared or disposed.
105: 103:     #[track_caller]
106: 104:     pub fn new_scoped(fun: impl Fn() + Send + Sync + 'static) {
107: 105:         let effect = Self::new(fun);
108: 106: 
109: 107:         on_cleanup(move || effect.dispose());
110: 108:     }
111: 109:     /// Creates a new effect which runs immediately, then again as soon as any tracked signal changes.
112: 110:     /// (Unless [batch] is used.)
113: 111:     ///
114: 112:     /// NOTE: this effect is automatically cleaned up when the current owner is cleared or disposed.
115: 113:     ///
116: 114:     /// # Panics
117: 115:     /// Panics on recursion or if triggered in parallel. Also see [Self::new_scoped]
118: 116:     #[track_caller]
119: 117:     pub fn new_mut_scoped(fun: impl FnMut() + Send + Sync + 'static) {
120: 118:         let effect = Self::new_mut(fun);
121: 119: 
122: 120:         on_cleanup(move || effect.dispose());
123: 121:     }
124: 122: 
125: 123:     /// Creates a new effect which runs immediately, then again as soon as any tracked signal changes.
126: 124:     ///
127: 125:     /// This will run whether the `effects` feature is enabled or not.
128: 126:     #[track_caller]
129: 127:     #[must_use]
130: 128:     pub fn new_isomorphic(fun: impl Fn() + Send + Sync + 'static) -> Self {
131: 129:         let inner = inner::EffectInner::new(fun);
132: 130: 
133: 131:         inner.update_if_necessary();
134: 132: 
135: 133:         Self { inner: Some(inner) }
136: 134:     }
137: 135: }
138: 136: 
139: 137: impl ToAnySubscriber for ImmediateEffect {
140: 138:     fn to_any_subscriber(&self) -> AnySubscriber {
141: 139:         const MSG: &str = "tried to set effect that has been stopped";
142: 140:         self.inner.as_ref().expect(MSG).to_any_subscriber()
143: 141:     }
144: 142: }
145: 143: 
146: 144: impl DefinedAt for ImmediateEffect {
147: 145:     fn defined_at(&self) -> Option<&'static Location<'static>> {
148: 146:         self.inner.as_ref()?.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().defined_at()
149: 147:     }
150: 148: }
151: 149: 
152: 150: /// Defers any [ImmediateEffect]s from running until the end of the function.
153: 151: ///
154: 152: /// NOTE: this affects only [ImmediateEffect]s, not other effects.
155: 153: ///
156: 154: /// NOTE: this is rarely needed, but it is useful for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example when multiple signals
157: 155: /// need to be updated atomically (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example a double-bound signal tree).
158: 156: pub fn batch<T>(f: impl FnOnce() -> T) -> T {
159: 157:     struct ExecuteOnDrop;
160: 158:     impl Drop for ExecuteOnDrop {
161: 159:         fn drop(&mut self) {
162: 160:             let effects = {
163: 161:                 let mut batch = inner::BATCH.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
164: 162:                 batch.take().unwrap().into_inner().expect("lock poisoned")
165: 163:             };
166: 164:             // TODO: Should we skip the effects if it's panicking?
167: 165:             for effect in effects {
168: 166:                 effect.update_if_necessary();
169: 167:             }
170: 168:         }
171: 169:     }
172: 170:     let mut execute_on_drop = None;
173: 171:     {
174: 172:         let mut batch = inner::BATCH.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
175: 173:         if batch.is_none() {
176: 174:             execute_on_drop = Some(ExecuteOnDrop);
177: 175:         } else {
178: 176:             // Nested batching has no effect.
179: 177:         }
180: 178:         *batch = Some(batch.take().unwrap_or_default());
181: 179:     }
182: 180:     let ret = f();
183: 181:     drop(execute_on_drop);
184: 182:     ret
185: 183: }
186: 184: 
187: 185: mod inner {
188: 186:     use crate::{
189: 187:         graph::{
190: 188:             AnySource, AnySubscriber, ReactiveNode, ReactiveNodeState,
191: 189:             SourceSet, Subscriber, ToAnySubscriber, WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
192: 190:         },
193: 191:         log_warning,
194: 192:         owner::Owner,
195: 193:         traits::DefinedAt,
196: 194:     };
197: 195:     use indexmap::IndexSet;
198: 196:     use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
199: 197:     use std::{
200: 198:         panic::Location,
201: 199:         sync::{Arc, RwLock, Weak},
202: 200:         thread::{self, ThreadId},
203: 201:     };
204: 202: 
205: 203:     /// Only the [super::batch] function ever writes to the outer RwLock.
206: 204:     /// While the effects will write to the inner one.
207: 205:     pub(super) static BATCH: RwLock<Option<RwLock<IndexSet<AnySubscriber>>>> =
208: 206:         RwLock::new(None);
209: 207: 
210: 208:     /// Handles subscription logic for effects.
211: 209:     ///
212: 210:     /// To handle parallelism and recursion we assign ordered (1..) lyx-core-lyx_core_lyx-core-lyx_core_ids to each run.
213: 211:     /// We only keep the sources tracked by the run with the highest id (the last one).
214: 212:     ///
215: 213:     /// We do this by:
216: 214:     /// - Clearing the sources before every run, so the last one clears anything before it.
217: 215:     /// - We stop tracking sources after the last run has completed.
218: 216:     ///   (A parent run will start before and end after a recursive child run.)
219: 217:     /// - To handle parallelism with the last run, we only allow sources to be added by its thread.
220: 218:     pub(super) struct EffectInner {
221: 219:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
222: 220:         defined_at: &'static Location<'static>,
223: 221:         owner: Owner,
224: 222:         state: ReactiveNodeState,
225: 223:         /// The number of effect runs in this 'batch'.
226: 224:         /// Cleared when no runs are *ongoing* anymore.
227: 225:         /// Used to assign ordered lyx-core-lyx_core_lyx-core-lyx_core_ids to each run, and to know when we can clear these values.
228: 226:         run_count_start: usize,
229: 227:         /// The number of effect runs that have completed in the current 'batch'.
230: 228:         /// Cleared when no runs are *ongoing* anymore.
231: 229:         /// Used to know when we can clear these values.
232: 230:         run_done_count: usize,
233: 231:         /// Given ordered lyx-core-lyx_core_lyx-core-lyx_core_ids (1..), the run with the highest id that has completed in this 'batch'.
234: 232:         /// Cleared when no runs are *ongoing* anymore.
235: 233:         /// Used to know whether the current run is the latest one.
236: 234:         run_done_max: usize,
237: 235:         /// The [ThreadId] of the run with the highest id.
238: 236:         /// Used to prevent over-subscribing during parallel execution with the last run.
239: 237:         ///
240: 238:         /// ```text
241: 239:         /// Thread 1:
242: 240:         /// -------------------------
243: 241:         ///   ---   ---    =======
244: 242:         ///
245: 243:         /// Thread 2:
246: 244:         /// -------------------------
247: 245:         ///             -----------
248: 246:         /// ```
249: 247:         ///
250: 248:         /// In the parallel lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example above, we can see why we need this.
251: 249:         /// The last run is marked using `=`, but another run in the other thread might
252: 250:         /// also be gathering sources. So we only allow the run from the correct [ThreadId] to push sources.
253: 251:         last_run_thread_id: ThreadId,
254: 252:         fun: Arc<dyn Fn() + Send + Sync>,
255: 253:         sources: SourceSet,
256: 254:         any_subscriber: AnySubscriber,
257: 255:     }
258: 256: 
259: 257:     impl EffectInner {
260: 258:         #[track_caller]
261: 259:         pub fn new(
262: 260:             fun: impl Fn() + Send + Sync + 'static,
263: 261:         ) -> Arc<RwLock<EffectInner>> {
264: 262:             let owner = Owner::new();
265: 263:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
266: 264:             let defined_at = Location::caller();
267: 265: 
268: 266:             Arc::new_cyclic(|weak| {
269: 267:                 let any_subscriber = AnySubscriber(
270: 268:                     weak.as_ptr() as usize,
271: 269:                     Weak::clone(weak) as Weak<dyn Subscriber + Send + Sync>,
272: 270:                 );
273: 271: 
274: 272:                 RwLock::new(EffectInner {
275: 273:                     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
276: 274:                     defined_at,
277: 275:                     owner,
278: 276:                     state: ReactiveNodeState::Dirty,
279: 277:                     run_count_start: 0,
280: 278:                     run_done_count: 0,
281: 279:                     run_done_max: 0,
282: 280:                     last_run_thread_id: thread::current().id(),
283: 281:                     fun: Arc::new(fun),
284: 282:                     sources: SourceSet::new(),
285: 283:                     any_subscriber,
286: 284:                 })
287: 285:             })
288: 286:         }
289: 287:     }
290: 288: 
291: 289:     impl ToAnySubscriber for Arc<RwLock<EffectInner>> {
292: 290:         fn to_any_subscriber(&self) -> AnySubscriber {
293: 291:             AnySubscriber(
294: 292:                 Arc::as_ptr(self) as usize,
295: 293:                 Arc::downgrade(self) as Weak<dyn Subscriber + Send + Sync>,
296: 294:             )
297: 295:         }
298: 296:     }
299: 297: 
300: 298:     impl ReactiveNode for RwLock<EffectInner> {
301: 299:         fn mark_subscribers_check(&self) {}
302: 300: 
303: 301:         fn update_if_necessary(&self) -> bool {
304: 302:             let state = {
305: 303:                 let guard = self.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
306: 304: 
307: 305:                 if guard.owner.paused() {
308: 306:                     return false;
309: 307:                 }
310: 308: 
311: 309:                 guard.state
312: 310:             };
313: 311: 
314: 312:             let needs_update = match state {
315: 313:                 ReactiveNodeState::Clean => false,
316: 314:                 ReactiveNodeState::Check => {
317: 315:                     let sources = self.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().sources.clone();
318: 316:                     sources
319: 317:                         .into_iter()
320: 318:                         .any(|source| source.update_if_necessary())
321: 319:                 }
322: 320:                 ReactiveNodeState::Dirty => true,
323: 321:             };
324: 322: 
325: 323:             {
326: 324:                 if let Some(batch) = &*BATCH.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() {
327: 325:                     let mut batch = batch.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
328: 326:                     let subscriber =
329: 327:                         self.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().any_subscriber.clone();
330: 328: 
331: 329:                     batch.insert(subscriber);
332: 330:                     return needs_update;
333: 331:                 }
334: 332:             }
335: 333: 
336: 334:             if needs_update {
337: 335:                 let mut guard = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
338: 336: 
339: 337:                 let owner = guard.owner.clone();
340: 338:                 let any_subscriber = guard.any_subscriber.clone();
341: 339:                 let fun = guard.fun.clone();
342: 340: 
343: 341:                 // New run has started.
344: 342:                 guard.run_count_start += 1;
345: 343:                 // We get a value for this run, the highest value will be what we keep the sources from.
346: 344:                 let recursion_count = guard.run_count_start;
347: 345:                 // We clear the sources before running the effect.
348: 346:                 // Note that this is tied to the ordering of the initial write lock acquisition
349: 347:                 // to ensure the last run is also the last to clear them.
350: 348:                 guard.sources.clear_sources(&any_subscriber);
351: 349:                 // Only this thread will be able to subscribe.
352: 350:                 guard.last_run_thread_id = thread::current().id();
353: 351: 
354: 352:                 if recursion_count > 2 {
355: 353:                     warn_excessive_recursion(&guard);
356: 354:                 }
357: 355: 
358: 356:                 drop(guard);
359: 357: 
360: 358:                 // We execute the effect.
361: 359:                 // Note that *this could hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen in parallel across threads*.
362: 360:                 owner.with_cleanup(|| any_subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| fun()));
363: 361: 
364: 362:                 let mut guard = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
365: 363: 
366: 364:                 // This run has completed.
367: 365:                 guard.run_done_count += 1;
368: 366: 
369: 367:                 // We update the done count.
370: 368:                 // Sources will only be added if recursion_done_max < recursion_count_start.
371: 369:                 // (Meaning the last run is not done yet.)
372: 370:                 guard.run_done_max =
373: 371:                     Ord::max(recursion_count, guard.run_done_max);
374: 372: 
375: 373:                 // The same amount of runs has started and completed,
376: 374:                 // so we can clear everything up for next time.
377: 375:                 if guard.run_count_start == guard.run_done_count {
378: 376:                     guard.run_count_start = 0;
379: 377:                     guard.run_done_count = 0;
380: 378:                     guard.run_done_max = 0;
381: 379:                     // Can be left unchanged, it'll be set again next time.
382: 380:                     // guard.last_run_thread_id = thread::current().id();
383: 381:                 }
384: 382: 
385: 383:                 guard.state = ReactiveNodeState::Clean;
386: 384:             }
387: 385: 
388: 386:             needs_update
389: 387:         }
390: 388: 
391: 389:         fn mark_check(&self) {
392: 390:             self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().state = ReactiveNodeState::Check;
393: 391:             self.update_if_necessary();
394: 392:         }
395: 393: 
396: 394:         fn mark_dirty(&self) {
397: 395:             self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().state = ReactiveNodeState::Dirty;
398: 396:             self.update_if_necessary();
399: 397:         }
400: 398:     }
401: 399: 
402: 400:     impl Subscriber for RwLock<EffectInner> {
403: 401:         fn add_source(&self, source: AnySource) {
404: 402:             let mut guard = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
405: 403:             if guard.run_done_max < guard.run_count_start
406: 404:                 && guard.last_run_thread_id == thread::current().id()
407: 405:             {
408: 406:                 guard.sources.insert(source);
409: 407:             }
410: 408:         }
411: 409: 
412: 410:         fn clear_sources(&self, subscriber: &AnySubscriber) {
413: 411:             self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().sources.clear_sources(subscriber);
414: 412:         }
415: 413:     }
416: 414: 
417: 415:     impl DefinedAt for EffectInner {
418: 416:         fn defined_at(&self) -> Option<&'static Location<'static>> {
419: 417:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
420: 418:             {
421: 419:                 Some(self.defined_at)
422: 420:             }
423: 421:             #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
424: 422:             {
425: 423:                 None
426: 424:             }
427: 425:         }
428: 426:     }
429: 427: 
430: 428:     impl std::fmt::Debug for EffectInner {
431: 429:         fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
432: 430:             f.debug_struct("EffectInner")
433: 431:                 .field("owner", &self.owner)
434: 432:                 .field("state", &self.state)
435: 433:                 .field("sources", &self.sources)
436: 434:                 .field("any_subscriber", &self.any_subscriber)
437: 435:                 .finish()
438: 436:         }
439: 437:     }
440: 438: 
441: 439:     fn warn_excessive_recursion(effect: &EffectInner) {
442: 440:         const MSG: &str = "ImmediateEffect recursed more than once.";
443: 441:         match effect.defined_at() {
444: 442:             Some(defined_at) => {
445: 443:                 log_warning(format_args!("{MSG} Defined at: {defined_at}"));
446: 444:             }
447: 445:             None => {
448: 446:                 log_warning(format_args!("{MSG}"));
449: 447:             }
450: 448:         }
451: 449:     }
452: 450: }
453: ```
```
