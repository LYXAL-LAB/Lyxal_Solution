### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\actions\action.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\actions\action.rs
2: ```rust
3: 1: use crate::{
4: 2:     computed::{ArcMemo, Memo, ScopedFuture},
5: 3:     diagnostics::is_suppressing_resource_load,
6: 4:     graph::untrack,
7: 5:     owner::{ArcStoredValue, ArenaItem, Owner},
8: 6:     send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_ext::SendOption,
9: 7:     signal::{ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal, ArcRwSignal, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal, RwSignal},
10: 8:     traits::{DefinedAt, Dispose, Get, GetUntracked, GetValue, Update, Write},
11: 9:     unwrap_signal,
12: 10: };
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
14: 12: use futures::{channel::oneshot, select, FutureExt};
15: 13: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
16: 14: use std::{
17: 15:     future::Future,
18: 16:     ops::{Deref, DerefMut},
19: 17:     panic::Location,
20: 18:     pin::Pin,
21: 19:     sync::Arc,
22: 20: };
23: 21: 
24: 22: /// An action runs some asynchronous code when you dispatch a new value to it, and gives you
25: 23: /// reactive access to the result.
26: 24: ///
27: 25: /// Actions are intended for mutating or updating data, not for loading data. If you find yourself
28: 26: /// creating an action and immediately dispatching a value to it, this is probably the wrong
29: 27: /// primitive.
30: 28: ///
31: 29: /// The arena-allocated, `Copy` version of an `ArcAction` is an [`Action`].
32: 30: ///
33: 31: /// ```rust
34: 32: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
35: 33: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
36: 34: /// # tokio_test::block_on(async move {
37: 35: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
38: 36: /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
39: 37: /// async fn send_new_todo_to_api(task: String) -> usize {
40: 38: ///     // do something...
41: 39: ///     // return a task id
42: 40: ///     42
43: 41: /// }
44: 42: /// let save_data = ArcAction::new(|task: &String| {
45: 43: ///   // `task` is given as `&String` because its value is available in `input`
46: 44: ///   send_new_todo_to_api(task.clone())
47: 45: /// });
48: 46: ///
49: 47: /// // the argument currently running
50: 48: /// let input = save_data.input();
51: 49: /// // the most recent returned result
52: 50: /// let result_of_call = save_data.value();
53: 51: /// // whether the call is pending
54: 52: /// let pending = save_data.pending();
55: 53: /// // how many times the action has run
56: 54: /// // useful for reactively updating something else in response to a `dispatch` and response
57: 55: /// let version = save_data.version();
58: 56: ///
59: 57: /// // before we do anything
60: 58: /// assert_eq!(input.get(), None); // no argument yet
61: 59: /// assert_eq!(pending.get(), false); // isn't pending a response
62: 60: /// assert_eq!(result_of_call.get(), None); // there's no "last value"
63: 61: /// assert_eq!(version.get(), 0);
64: 62: ///
65: 63: /// // dispatch the action
66: 64: /// save_data.dispatch("My todo".to_string());
67: 65: ///
68: 66: /// // when we're making the call
69: 67: /// assert_eq!(input.get(), Some("My todo".to_string()));
70: 68: /// assert_eq!(pending.get(), true); // is pending
71: 69: /// assert_eq!(result_of_call.get(), None); // has not yet gotten a response
72: 70: ///
73: 71: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
74: 72: ///
75: 73: /// // after call has resolved
76: 74: /// assert_eq!(input.get(), None); // input clears out after resolved
77: 75: /// assert_eq!(pending.get(), false); // no longer pending
78: 76: /// assert_eq!(result_of_call.get(), Some(42));
79: 77: /// assert_eq!(version.get(), 1);
80: 78: /// # });
81: 79: /// ```
82: 80: ///
83: 81: /// The input to the `async` function should always be a single value,
84: 82: /// but it can be of any type. The argument is always passed by reference to the
85: 83: /// function, because it is stored in [Action::input] as well.
86: 84: ///
87: 85: /// ```rust
88: 86: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
89: 87: /// // if there's a single argument, just use that
90: 88: /// let action1 = ArcAction::new(|input: &String| {
91: 89: ///     let input = input.clone();
92: 90: ///     async move { todo!() }
93: 91: /// });
94: 92: ///
95: 93: /// // if there are no arguments, use the unit type `()`
96: 94: /// let action2 = ArcAction::new(|input: &()| async { todo!() });
97: 95: ///
98: 96: /// // if there are multiple arguments, use a tuple
99: 97: /// let action3 = ArcAction::new(|input: &(usize, String)| async { todo!() });
100: 98: /// ```
101: 99: pub struct ArcAction<I, O> {
102: 100:     in_flight: ArcRwSignal<usize>,
103: 101:     input: ArcRwSignal<SendOption<I>>,
104: 102:     value: ArcRwSignal<SendOption<O>>,
105: 103:     version: ArcRwSignal<usize>,
106: 104:     dispatched: ArcStoredValue<usize>,
107: 105:     #[allow(clippy::complexity)]
108: 106:     action_fn: Arc<
109: 107:         dyn Fn(&I) -> Pin<Box<dyn Future<Output = O> + Send>> + Send + Sync,
110: 108:     >,
111: 109:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
112: 110:     defined_at: &'static Location<'static>,
113: 111: }
114: 112: 
115: 113: impl<I, O> Clone for ArcAction<I, O> {
116: 114:     fn clone(&self) -> Self {
117: 115:         Self {
118: 116:             in_flight: self.in_flight.clone(),
119: 117:             input: self.input.clone(),
120: 118:             value: self.value.clone(),
121: 119:             version: self.version.clone(),
122: 120:             dispatched: self.dispatched.clone(),
123: 121:             action_fn: self.action_fn.clone(),
124: 122:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
125: 123:             defined_at: self.defined_at,
126: 124:         }
127: 125:     }
128: 126: }
129: 127: 
130: 128: impl<I, O> ArcAction<I, O>
131: 129: where
132: 130:     I: 'static,
133: 131:     O: 'static,
134: 132: {
135: 133:     /// Creates a new action. This is lazy: it does not run the action function until some value
136: 134:     /// is dispatched.
137: 135:     ///
138: 136:     /// The constructor takes a function which will create a new `Future` from some input data.
139: 137:     /// When the action is dispatched, this `action_fn` will run, and the `Future` it returns will
140: 138:     /// be spawned.
141: 139:     ///
142: 140:     /// The `action_fn` must be `Send + Sync` so that the `ArcAction` is `Send + Sync`. The
143: 141:     /// `Future` must be `Send` so that it can be moved across threads by the async executor as
144: 142:     /// needed.
145: 143:     ///
146: 144:     /// ```rust
147: 145:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
148: 146:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
149: 147:     /// # tokio_test::block_on(async move {
150: 148:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
151: 149:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
152: 150:     /// let act = ArcAction::new(|n: &u8| {
153: 151:     ///     let n = n.to_owned();
154: 152:     ///     async move { n * 2 }
155: 153:     /// });
156: 154:     ///
157: 155:     /// act.dispatch(3);
158: 156:     /// assert_eq!(act.input().get(), Some(3));
159: 157:     ///
160: 158:     /// // Remember that async functions already return a future if they are
161: 159:     /// // not `await`ed. You can save keystrokes by leaving out the `async move`
162: 160:     ///
163: 161:     /// let act2 = Action::new(|n: &String| yell(n.to_owned()));
164: 162:     /// act2.dispatch(String::from("i'm in a doctest"));
165: 163:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
166: 164:     ///
167: 165:     /// // after it resolves
168: 166:     /// assert_eq!(act2.value().get(), Some("I'M IN A DOCTEST".to_string()));
169: 167:     ///
170: 168:     /// async fn yell(n: String) -> String {
171: 169:     ///     n.to_uppercase()
172: 170:     /// }
173: 171:     /// # });
174: 172:     /// ```
175: 173:     #[track_caller]
176: 174:     pub fn new<F, Fu>(action_fn: F) -> Self
177: 175:     where
178: 176:         F: Fn(&I) -> Fu + Send + Sync + 'static,
179: 177:         Fu: Future<Output = O> + Send + 'static,
180: 178:         I: Send + Sync,
181: 179:         O: Send + Sync,
182: 180:     {
183: 181:         Self::new_with_value(None, action_fn)
184: 182:     }
185: 183: 
186: 184:     /// Creates a new action, initializing it with the given value.
187: 185:     ///
188: 186:     /// This is lazy: it does not run the action function until some value is dispatched.
189: 187:     ///
190: 188:     /// The constructor takes a function which will create a new `Future` from some input data.
191: 189:     /// When the action is dispatched, this `action_fn` will run, and the `Future` it returns will
192: 190:     /// be spawned.
193: 191:     ///
194: 192:     /// The `action_fn` must be `Send + Sync` so that the `ArcAction` is `Send + Sync`. The
195: 193:     /// `Future` must be `Send` so that it can be moved across threads by the async executor as
196: 194:     /// needed.
197: 195:     #[track_caller]
198: 196:     pub fn new_with_value<F, Fu>(value: Option<O>, action_fn: F) -> Self
199: 197:     where
200: 198:         F: Fn(&I) -> Fu + Send + Sync + 'static,
201: 199:         Fu: Future<Output = O> + Send + 'static,
202: 200:         I: Send + Sync,
203: 201:         O: Send + Sync,
204: 202:     {
205: 203:         let owner = Owner::current().unwrap_or_default();
206: 204:         ArcAction {
207: 205:             in_flight: ArcRwSignal::new(0),
208: 206:             input: ArcRwSignal::new(SendOption::new(None)),
209: 207:             value: ArcRwSignal::new(SendOption::new(value)),
210: 208:             version: Default::default(),
211: 209:             dispatched: Default::default(),
212: 210:             action_fn: Arc::new(move |input| {
213: 211:                 Box::pin(owner.with(|| {
214: 212:                     ScopedFuture::new_untracked(untrack(|| action_fn(input)))
215: 213:                 }))
216: 214:             }),
217: 215:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
218: 216:             defined_at: Location::caller(),
219: 217:         }
220: 218:     }
221: 219: 
222: 220:     /// Clears the value of the action, setting its current value to `None`.
223: 221:     ///
224: 222:     /// This has no other effect: i.e., it will not cancel in-flight actions, set the
225: 223:     /// input, etc.
226: 224:     #[track_caller]
227: 225:     pub fn clear(&self) {
228: 226:         if let Some(mut guard) = self.value.try_write() {
229: 227:             **guard = None;
230: 228:         }
231: 229:     }
232: 230: }
233: 231: 
234: 232: /// A handle that allows aborting an in-flight action. It is returned from [`Action::dispatch`] or
235: 233: /// [`ArcAction::dispatch`].
236: 234: #[derive(Debug)]
237: 235: pub struct ActionAbortHandle(oneshot::Sender<()>);
238: 236: 
239: 237: impl ActionAbortHandle {
240: 238:     /// Aborts the action.
241: 239:     ///
242: 240:     /// This will cause the dispatched task to complete, without updating the action's value. The
243: 241:     /// dispatched action's `Future` will no longer be polled. This does not guarantee that side
244: 242:     /// effects created by that `Future` no longer run: for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, if the action dispatches an
245: 243:     /// HTTP request, whether that request is actually canceled or not depends on whether the
246: 244:     /// request library actually cancels a request when its `Future` is dropped.
247: 245:     pub fn abort(self) {
248: 246:         let _ = self.0.send(());
249: 247:     }
250: 248: }
251: 249: 
252: 250: impl<I, O> ArcAction<I, O>
253: 251: where
254: 252:     I: Send + Sync + 'static,
255: 253:     O: Send + Sync + 'static,
256: 254: {
257: 255:     /// Calls the `async` function with a reference to the input type as its argument.
258: 256:     #[track_caller]
259: 257:     pub fn dispatch(&self, input: I) -> ActionAbortHandle {
260: 258:         let (abort_tx, mut abort_rx) = oneshot::channel();
261: 259:         if !is_suppressing_resource_load() {
262: 260:             let mut fut = (self.action_fn)(&input).fuse();
263: 261: 
264: 262:             // Update the state before loading
265: 263:             self.in_flight.update(|n| *n += 1);
266: 264:             let current_version = self.dispatched.get_value();
267: 265:             self.input.try_update(|inp| **inp = Some(input));
268: 266: 
269: 267:             // Spawn the task
270: 268:             crate::spawn({
271: 269:                 let input = self.input.clone();
272: 270:                 let version = self.version.clone();
273: 271:                 let dispatched = self.dispatched.clone();
274: 272:                 let value = self.value.clone();
275: 273:                 let in_flight = self.in_flight.clone();
276: 274:                 async move {
277: 275:                     select! {
278: 276:                         // if the abort message has been sent, bail and do nothing
279: 277:                         _ = abort_rx => {
280: 278:                             in_flight.update(|n| *n = n.saturating_sub(1));
281: 279:                         },
282: 280:                         // otherwise, update the value
283: 281:                         result = fut => {
284: 282:                             in_flight.update(|n| *n = n.saturating_sub(1));
285: 283:                             let is_latest = dispatched.get_value() <= current_version;
286: 284:                             if is_latest {
287: 285:                                 version.update(|n| *n += 1);
288: 286:                                 value.update(|n| **n = Some(result));
289: 287:                             }
290: 288:                         }
291: 289:                     }
292: 290:                     if in_flight.get_untracked() == 0 {
293: 291:                         input.update(|inp| **inp = None);
294: 292:                     }
295: 293:                 }
296: 294:             });
297: 295:         }
298: 296: 
299: 297:         ActionAbortHandle(abort_tx)
300: 298:     }
301: 299: }
302: 300: 
303: 301: impl<I, O> ArcAction<I, O>
304: 302: where
305: 303:     I: 'static,
306: 304:     O: 'static,
307: 305: {
308: 306:     /// Calls the `async` function with a reference to the input type as its argument,
309: 307:     /// ensuring that it is spawned on the current thread.
310: 308:     #[track_caller]
311: 309:     pub fn dispatch_local(&self, input: I) -> ActionAbortHandle {
312: 310:         let (abort_tx, mut abort_rx) = oneshot::channel();
313: 311:         if !is_suppressing_resource_load() {
314: 312:             let mut fut = (self.action_fn)(&input).fuse();
315: 313: 
316: 314:             // Update the state before loading
317: 315:             self.in_flight.update(|n| *n += 1);
318: 316:             let current_version = self.dispatched.get_value();
319: 317:             self.input.try_update(|inp| **inp = Some(input));
320: 318: 
321: 319:             // Spawn the task
322: 320:             Executor::spawn_local({
323: 321:                 let input = self.input.clone();
324: 322:                 let version = self.version.clone();
325: 323:                 let value = self.value.clone();
326: 324:                 let dispatched = self.dispatched.clone();
327: 325:                 let in_flight = self.in_flight.clone();
328: 326:                 async move {
329: 327:                     select! {
330: 328:                         // if the abort message has been sent, bail and do nothing
331: 329:                         _ = abort_rx => {
332: 330:                             in_flight.update(|n| *n = n.saturating_sub(1));
333: 331:                         },
334: 332:                         // otherwise, update the value
335: 333:                         result = fut => {
336: 334:                             in_flight.update(|n| *n = n.saturating_sub(1));
337: 335:                             let is_latest = dispatched.get_value() <= current_version;
338: 336:                             if is_latest {
339: 337:                                 version.update(|n| *n += 1);
340: 338:                                 value.update(|n| **n = Some(result));
341: 339:                             }
342: 340:                         }
343: 341:                     }
344: 342:                     if in_flight.get_untracked() == 0 {
345: 343:                         input.update(|inp| **inp = None);
346: 344:                     }
347: 345:                 }
348: 346:             });
349: 347:         }
350: 348:         ActionAbortHandle(abort_tx)
351: 349:     }
352: 350: }
353: 351: 
354: 352: impl<I, O> ArcAction<I, O>
355: 353: where
356: 354:     I: 'static,
357: 355:     O: 'static,
358: 356: {
359: 357:     /// Creates a new action, which will only be run on the thread in which it is created.
360: 358:     ///
361: 359:     /// In all other ways, this is identical to [`ArcAction::new`].
362: 360:     #[track_caller]
363: 361:     pub fn new_unsync<F, Fu>(action_fn: F) -> Self
364: 362:     where
365: 363:         F: Fn(&I) -> Fu + 'static,
366: 364:         Fu: Future<Output = O> + 'static,
367: 365:     {
368: 366:         let action_fn = move |inp: &I| SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(action_fn(inp));
369: 367:         Self::new_unsync_with_value(None, action_fn)
370: 368:     }
371: 369: 
372: 370:     /// Creates a new action that will only run on the current thread, initializing it with the given value.
373: 371:     ///
374: 372:     /// In all other ways, this is identical to [`ArcAction::new_with_value`].
375: 373:     #[track_caller]
376: 374:     pub fn new_unsync_with_value<F, Fu>(value: Option<O>, action_fn: F) -> Self
377: 375:     where
378: 376:         F: Fn(&I) -> Fu + 'static,
379: 377:         Fu: Future<Output = O> + 'static,
380: 378:     {
381: 379:         let owner = Owner::current().unwrap_or_default();
382: 380:         let action_fn = SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(action_fn);
383: 381:         ArcAction {
384: 382:             in_flight: ArcRwSignal::new(0),
385: 383:             input: ArcRwSignal::new(SendOption::new_local(None)),
386: 384:             value: ArcRwSignal::new(SendOption::new_local(value)),
387: 385:             version: Default::default(),
388: 386:             dispatched: Default::default(),
389: 387:             action_fn: Arc::new(move |input| {
390: 388:                 Box::pin(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(owner.with(|| {
391: 389:                     ScopedFuture::new_untracked(untrack(|| action_fn(input)))
392: 390:                 })))
393: 391:             }),
394: 392:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
395: 393:             defined_at: Location::caller(),
396: 394:         }
397: 395:     }
398: 396: }
399: 397: 
400: 398: impl<I, O> ArcAction<I, O>
401: 399: where
402: 400:     I: 'static,
403: 401:     O: 'static,
404: 402: {
405: 403:     /// The number of times the action has successfully completed.
406: 404:     ///
407: 405:     /// ```rust
408: 406:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
409: 407:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
410: 408:     /// # tokio_test::block_on(async move {
411: 409:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
412: 410:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
413: 411:     /// let act = ArcAction::new(|n: &u8| {
414: 412:     ///     let n = n.to_owned();
415: 413:     ///     async move { n * 2 }
416: 414:     /// });
417: 415:     ///
418: 416:     /// let version = act.version();
419: 417:     /// act.dispatch(3);
420: 418:     /// assert_eq!(version.get(), 0);
421: 419:     ///
422: 420:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
423: 421:     /// // after it resolves
424: 422:     /// assert_eq!(version.get(), 1);
425: 423:     /// # });
426: 424:     /// ```
427: 425:     #[track_caller]
428: 426:     pub fn version(&self) -> ArcRwSignal<usize> {
429: 427:         self.version.clone()
430: 428:     }
431: 429: 
432: 430:     /// The current argument that was dispatched to the async function. This value will
433: 431:     /// be `Some` while we are waiting for it to resolve, and `None` after it has resolved.
434: 432:     ///
435: 433:     /// ```rust
436: 434:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
437: 435:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
438: 436:     /// # tokio_test::block_on(async move {
439: 437:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
440: 438:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
441: 439:     /// let act = ArcAction::new(|n: &u8| {
442: 440:     ///     let n = n.to_owned();
443: 441:     ///     async move { n * 2 }
444: 442:     /// });
445: 443:     ///
446: 444:     /// let input = act.input();
447: 445:     /// assert_eq!(input.get(), None);
448: 446:     /// act.dispatch(3);
449: 447:     /// assert_eq!(input.get(), Some(3));
450: 448:     ///
451: 449:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
452: 450:     /// // after it resolves
453: 451:     /// assert_eq!(input.get(), None);
454: 452:     /// # });
455: 453:     /// ```
456: 454:     #[track_caller]
457: 455:     pub fn input(&self) -> ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<Option<I>> {
458: 456:         ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal::new(
459: 457:             self.input.clone(),
460: 458:             |n| n.deref(),
461: 459:             |n| n.deref_mut(),
462: 460:         )
463: 461:     }
464: 462: 
465: 463:     /// The most recent return value of the `async` function. This will be `None` before
466: 464:     /// the action has ever run successfully, and subsequently will always be `Some(_)`,
467: 465:     /// holding the old value until a new value has been received.
468: 466:     ///
469: 467:     /// ```rust
470: 468:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
471: 469:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
472: 470:     /// # tokio_test::block_on(async move {
473: 471:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
474: 472:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
475: 473:     /// let act = ArcAction::new(|n: &u8| {
476: 474:     ///     let n = n.to_owned();
477: 475:     ///     async move { n * 2 }
478: 476:     /// });
479: 477:     ///
480: 478:     /// let value = act.value();
481: 479:     /// assert_eq!(value.get(), None);
482: 480:     /// act.dispatch(3);
483: 481:     /// assert_eq!(value.get(), None);
484: 482:     ///
485: 483:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
486: 484:     /// // after it resolves
487: 485:     /// assert_eq!(value.get(), Some(6));
488: 486:     /// // dispatch another value, and it still holds the old value
489: 487:     /// act.dispatch(3);
490: 488:     /// assert_eq!(value.get(), Some(6));
491: 489:     /// # });
492: 490:     /// ```
493: 491:     #[track_caller]
494: 492:     pub fn value(&self) -> ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<Option<O>> {
495: 493:         ArcMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal::new(
496: 494:             self.value.clone(),
497: 495:             |n| n.deref(),
498: 496:             |n| n.deref_mut(),
499: 497:         )
500: 498:     }
501: 499: 
502: 500:     /// Whether the action has been dispatched and is currently waiting to resolve.
503: 501:     ///
504: 502:     /// ```rust
505: 503:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
506: 504:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
507: 505:     /// # tokio_test::block_on(async move {
508: 506:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
509: 507:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
510: 508:     /// let act = ArcAction::new(|n: &u8| {
511: 509:     ///     let n = n.to_owned();
512: 510:     ///     async move { n * 2 }
513: 511:     /// });
514: 512:     ///
515: 513:     /// let pending = act.pending();
516: 514:     /// assert_eq!(pending.get(), false);
517: 515:     /// act.dispatch(3);
518: 516:     /// assert_eq!(pending.get(), true);
519: 517:     ///
520: 518:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
521: 519:     /// // after it resolves
522: 520:     /// assert_eq!(pending.get(), false);
523: 521:     /// # });
524: 522:     /// ```
525: 523:     #[track_caller]
526: 524:     pub fn pending(&self) -> ArcMemo<bool> {
527: 525:         let in_flight = self.in_flight.clone();
528: 526:         ArcMemo::new(move |_| in_flight.get() > 0)
529: 527:     }
530: 528: }
531: 529: 
532: 530: impl<I, O> DefinedAt for ArcAction<I, O>
533: 531: where
534: 532:     I: 'static,
535: 533:     O: 'static,
536: 534: {
537: 535:     fn defined_at(&self) -> Option<&'static Location<'static>> {
538: 536:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
539: 537:         {
540: 538:             Some(self.defined_at)
541: 539:         }
542: 540:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
543: 541:         {
544: 542:             None
545: 543:         }
546: 544:     }
547: 545: }
548: 546: 
549: 547: /// An action runs some asynchronous code when you dispatch a new value to it, and gives you
550: 548: /// reactive access to the result.
551: 549: ///
552: 550: /// Actions are intended for mutating or updating data, not for loading data. If you find yourself
553: 551: /// creating an action and immediately dispatching a value to it, this is probably the wrong
554: 552: /// primitive.
555: 553: ///
556: 554: /// The reference-counted, `Clone` (but not `Copy` version of an `Action` is an [`ArcAction`].
557: 555: ///
558: 556: /// ```rust
559: 557: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
560: 558: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
561: 559: /// # tokio_test::block_on(async move {
562: 560: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
563: 561: /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
564: 562: /// async fn send_new_todo_to_api(task: String) -> usize {
565: 563: ///     // do something...
566: 564: ///     // return a task id
567: 565: ///     42
568: 566: /// }
569: 567: /// let save_data = Action::new(|task: &String| {
570: 568: ///   // `task` is given as `&String` because its value is available in `input`
571: 569: ///   send_new_todo_to_api(task.clone())
572: 570: /// });
573: 571: ///
574: 572: /// // the argument currently running
575: 573: /// let input = save_data.input();
576: 574: /// // the most recent returned result
577: 575: /// let result_of_call = save_data.value();
578: 576: /// // whether the call is pending
579: 577: /// let pending = save_data.pending();
580: 578: /// // how many times the action has run
581: 579: /// // useful for reactively updating something else in response to a `dispatch` and response
582: 580: /// let version = save_data.version();
583: 581: ///
584: 582: /// // before we do anything
585: 583: /// assert_eq!(input.get(), None); // no argument yet
586: 584: /// assert_eq!(pending.get(), false); // isn't pending a response
587: 585: /// assert_eq!(result_of_call.get(), None); // there's no "last value"
588: 586: /// assert_eq!(version.get(), 0);
589: 587: ///
590: 588: /// // dispatch the action
591: 589: /// save_data.dispatch("My todo".to_string());
592: 590: ///
593: 591: /// // when we're making the call
594: 592: /// assert_eq!(input.get(), Some("My todo".to_string()));
595: 593: /// assert_eq!(pending.get(), true); // is pending
596: 594: /// assert_eq!(result_of_call.get(), None); // has not yet gotten a response
597: 595: ///
598: 596: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
599: 597: ///
600: 598: /// // after call has resolved
601: 599: /// assert_eq!(input.get(), None); // input clears out after resolved
602: 600: /// assert_eq!(pending.get(), false); // no longer pending
603: 601: /// assert_eq!(result_of_call.get(), Some(42));
604: 602: /// assert_eq!(version.get(), 1);
605: 603: /// # });
606: 604: /// ```
607: 605: ///
608: 606: /// The input to the `async` function should always be a single value,
609: 607: /// but it can be of any type. The argument is always passed by reference to the
610: 608: /// function, because it is stored in [Action::input] as well.
611: 609: ///
612: 610: /// ```rust
613: 611: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
614: 612: /// // if there's a single argument, just use that
615: 613: /// let action1 = Action::new(|input: &String| {
616: 614: ///     let input = input.clone();
617: 615: ///     async move { todo!() }
618: 616: /// });
619: 617: ///
620: 618: /// // if there are no arguments, use the unit type `()`
621: 619: /// let action2 = Action::new(|input: &()| async { todo!() });
622: 620: ///
623: 621: /// // if there are multiple arguments, use a tuple
624: 622: /// let action3 = Action::new(|input: &(usize, String)| async { todo!() });
625: 623: /// ```
626: 624: pub struct Action<I, O> {
627: 625:     inner: ArenaItem<ArcAction<I, O>>,
628: 626:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
629: 627:     defined_at: &'static Location<'static>,
630: 628: }
631: 629: 
632: 630: impl<I, O> Dispose for Action<I, O> {
633: 631:     fn dispose(self) {
634: 632:         self.inner.dispose()
635: 633:     }
636: 634: }
637: 635: 
638: 636: impl<I, O> Action<I, O>
639: 637: where
640: 638:     I: Send + Sync + 'static,
641: 639:     O: Send + Sync + 'static,
642: 640: {
643: 641:     /// Creates a new action. This is lazy: it does not run the action function until some value
644: 642:     /// is dispatched.
645: 643:     ///
646: 644:     /// The constructor takes a function which will create a new `Future` from some input data.
647: 645:     /// When the action is dispatched, this `action_fn` will run, and the `Future` it returns will
648: 646:     /// be spawned.
649: 647:     ///
650: 648:     /// The `action_fn` must be `Send + Sync` so that the `ArcAction` is `Send + Sync`. The
651: 649:     /// `Future` must be `Send` so that it can be moved across threads by the async executor as
652: 650:     /// needed. In order to be stored in the `Copy` arena, the input and output types should also
653: 651:     /// be `Send + Sync`.
654: 652:     ///
655: 653:     /// ```rust
656: 654:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
657: 655:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
658: 656:     /// # tokio_test::block_on(async move {
659: 657:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
660: 658:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
661: 659:     /// let act = Action::new(|n: &u8| {
662: 660:     ///     let n = n.to_owned();
663: 661:     ///     async move { n * 2 }
664: 662:     /// });
665: 663:     ///
666: 664:     /// act.dispatch(3);
667: 665:     /// assert_eq!(act.input().get(), Some(3));
668: 666:     ///
669: 667:     /// // Remember that async functions already return a future if they are
670: 668:     /// // not `await`ed. You can save keystrokes by leaving out the `async move`
671: 669:     ///
672: 670:     /// let act2 = Action::new(|n: &String| yell(n.to_owned()));
673: 671:     /// act2.dispatch(String::from("i'm in a doctest"));
674: 672:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
675: 673:     ///
676: 674:     /// // after it resolves
677: 675:     /// assert_eq!(act2.value().get(), Some("I'M IN A DOCTEST".to_string()));
678: 676:     ///
679: 677:     /// async fn yell(n: String) -> String {
680: 678:     ///     n.to_uppercase()
681: 679:     /// }
682: 680:     /// # });
683: 681:     /// ```
684: 682:     #[track_caller]
685: 683:     pub fn new<F, Fu>(action_fn: F) -> Self
686: 684:     where
687: 685:         F: Fn(&I) -> Fu + Send + Sync + 'static,
688: 686:         Fu: Future<Output = O> + Send + 'static,
689: 687:     {
690: 688:         Self {
691: 689:             inner: ArenaItem::new(ArcAction::new(action_fn)),
692: 690:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
693: 691:             defined_at: Location::caller(),
694: 692:         }
695: 693:     }
696: 694: 
697: 695:     /// Creates a new action, initializing it with the given value.
698: 696:     ///
699: 697:     /// This is lazy: it does not run the action function until some value is dispatched.
700: 698:     ///
701: 699:     /// The constructor takes a function which will create a new `Future` from some input data.
702: 700:     /// When the action is dispatched, this `action_fn` will run, and the `Future` it returns will
703: 701:     /// be spawned.
704: 702:     ///
705: 703:     /// The `action_fn` must be `Send + Sync` so that the `ArcAction` is `Send + Sync`. The
706: 704:     /// `Future` must be `Send` so that it can be moved across threads by the async executor as
707: 705:     /// needed. In order to be stored in the `Copy` arena, the input and output types should also
708: 706:     /// be `Send + Sync`.
709: 707:     #[track_caller]
710: 708:     pub fn new_with_value<F, Fu>(value: Option<O>, action_fn: F) -> Self
711: 709:     where
712: 710:         F: Fn(&I) -> Fu + Send + Sync + 'static,
713: 711:         Fu: Future<Output = O> + Send + 'static,
714: 712:     {
715: 713:         Self {
716: 714:             inner: ArenaItem::new(ArcAction::new_with_value(value, action_fn)),
717: 715:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
718: 716:             defined_at: Location::caller(),
719: 717:         }
720: 718:     }
721: 719: }
722: 720: 
723: 721: impl<I, O> Action<I, O>
724: 722: where
725: 723:     I: 'static,
726: 724:     O: 'static,
727: 725: {
728: 726:     /// Clears the value of the action, setting its current value to `None`.
729: 727:     ///
730: 728:     /// This has no other effect: i.e., it will not cancel in-flight actions, set the
731: 729:     /// input, etc.
732: 730:     #[track_caller]
733: 731:     pub fn clear(&self) {
734: 732:         self.inner.try_with_value(|inner| inner.clear());
735: 733:     }
736: 734: }
737: 735: 
738: 736: impl<I, O> Action<I, O>
739: 737: where
740: 738:     I: 'static,
741: 739:     O: 'static,
742: 740: {
743: 741:     /// Creates a new action, which does not require its inputs or outputs to be `Send`. In all other
744: 742:     /// ways, this is the same as [`Action::new`]. If this action is accessed from outside the
745: 743:     /// thread on which it was created, it panics.
746: 744:     #[track_caller]
747: 745:     pub fn new_local<F, Fu>(action_fn: F) -> Self
748: 746:     where
749: 747:         F: Fn(&I) -> Fu + 'static,
750: 748:         Fu: Future<Output = O> + 'static,
751: 749:     {
752: 750:         Self {
753: 751:             inner: ArenaItem::new(ArcAction::new_unsync(action_fn)),
754: 752:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
755: 753:             defined_at: Location::caller(),
756: 754:         }
757: 755:     }
758: 756: 
759: 757:     /// Creates a new action with the initial value, which does not require its inputs or outputs to be `Send`. In all other
760: 758:     /// ways, this is the same as [`Action::new_with_value`]. If this action is accessed from outside the
761: 759:     /// thread on which it was created, it panics.
762: 760:     #[track_caller]
763: 761:     pub fn new_local_with_value<F, Fu>(value: Option<O>, action_fn: F) -> Self
764: 762:     where
765: 763:         F: Fn(&I) -> Fu + 'static,
766: 764:         Fu: Future<Output = O> + Send + 'static,
767: 765:     {
768: 766:         Self {
769: 767:             inner: ArenaItem::new(ArcAction::new_unsync_with_value(
770: 768:                 value, action_fn,
771: 769:             )),
772: 770:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
773: 771:             defined_at: Location::caller(),
774: 772:         }
775: 773:     }
776: 774: }
777: 775: 
778: 776: impl<I, O> Action<I, O>
779: 777: where
780: 778:     I: 'static,
781: 779:     O: 'static,
782: 780: {
783: 781:     /// The number of times the action has successfully completed.
784: 782:     ///
785: 783:     /// ```rust
786: 784:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
787: 785:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
788: 786:     /// # tokio_test::block_on(async move {
789: 787:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
790: 788:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
791: 789:     /// let act = Action::new(|n: &u8| {
792: 790:     ///     let n = n.to_owned();
793: 791:     ///     async move { n * 2 }
794: 792:     /// });
795: 793:     ///
796: 794:     /// let version = act.version();
797: 795:     /// act.dispatch(3);
798: 796:     /// assert_eq!(version.get(), 0);
799: 797:     ///
800: 798:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
801: 799:     /// // after it resolves
802: 800:     /// assert_eq!(version.get(), 1);
803: 801:     /// # });
804: 802:     /// ```
805: 803:     #[track_caller]
806: 804:     pub fn version(&self) -> RwSignal<usize> {
807: 805:         let inner = self
808: 806:             .inner
809: 807:             .try_with_value(|inner| inner.version())
810: 808:             .unwrap_or_else(unwrap_signal!(self));
811: 809:         inner.into()
812: 810:     }
813: 811: 
814: 812:     /// Whether the action has been dispatched and is currently waiting to resolve.
815: 813:     ///
816: 814:     /// ```rust
817: 815:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
818: 816:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
819: 817:     /// # tokio_test::block_on(async move {
820: 818:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
821: 819:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
822: 820:     /// let act = Action::new(|n: &u8| {
823: 821:     ///     let n = n.to_owned();
824: 822:     ///     async move { n * 2 }
825: 823:     /// });
826: 824:     ///
827: 825:     /// let pending = act.pending();
828: 826:     /// assert_eq!(pending.get(), false);
829: 827:     /// act.dispatch(3);
830: 828:     /// assert_eq!(pending.get(), true);
831: 829:     ///
832: 830:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
833: 831:     /// // after it resolves
834: 832:     /// assert_eq!(pending.get(), false);
835: 833:     /// # });
836: 834:     /// ```
837: 835:     #[track_caller]
838: 836:     pub fn pending(&self) -> Memo<bool> {
839: 837:         let inner = self
840: 838:             .inner
841: 839:             .try_with_value(|inner| inner.pending())
842: 840:             .unwrap_or_else(unwrap_signal!(self));
843: 841:         inner.into()
844: 842:     }
845: 843: }
846: 844: 
847: 845: impl<I, O> Action<I, O>
848: 846: where
849: 847:     I: 'static,
850: 848:     O: 'static,
851: 849: {
852: 850:     /// The current argument that was dispatched to the async function. This value will
853: 851:     /// be `Some` while we are waiting for it to resolve, and `None` after it has resolved.
854: 852:     ///
855: 853:     /// ```rust
856: 854:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
857: 855:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
858: 856:     /// # tokio_test::block_on(async move {
859: 857:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
860: 858:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
861: 859:     /// let act = Action::new(|n: &u8| {
862: 860:     ///     let n = n.to_owned();
863: 861:     ///     async move { n * 2 }
864: 862:     /// });
865: 863:     ///
866: 864:     /// let input = act.input();
867: 865:     /// assert_eq!(input.get(), None);
868: 866:     /// act.dispatch(3);
869: 867:     /// assert_eq!(input.get(), Some(3));
870: 868:     ///
871: 869:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
872: 870:     /// // after it resolves
873: 871:     /// assert_eq!(input.get(), None);
874: 872:     /// # });
875: 873:     /// ```
876: 874:     #[track_caller]
877: 875:     pub fn input(&self) -> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<Option<I>> {
878: 876:         self.inner
879: 877:             .try_with_value(|inner| inner.input())
880: 878:             .unwrap_or_else(unwrap_signal!(self))
881: 879:             .into()
882: 880:     }
883: 881: 
884: 882:     /// The current argument that was dispatched to the async function. This value will
885: 883:     /// be `Some` while we are waiting for it to resolve, and `None` after it has resolved.
886: 884:     ///
887: 885:     /// Returns a thread-local signal using [`LocalStorage`].
888: 886:     #[track_caller]
889: 887:     #[deprecated = "You can now use .input() for any value, whether it's \
890: 888:                     thread-safe or not."]
891: 889:     pub fn input_local(&self) -> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<Option<I>> {
892: 890:         self.inner
893: 891:             .try_with_value(|inner| inner.input())
894: 892:             .unwrap_or_else(unwrap_signal!(self))
895: 893:             .into()
896: 894:     }
897: 895: }
898: 896: 
899: 897: impl<I, O> Action<I, O>
900: 898: where
901: 899:     I: 'static,
902: 900:     O: 'static,
903: 901: {
904: 902:     /// The most recent return value of the `async` function. This will be `None` before
905: 903:     /// the action has ever run successfully, and subsequently will always be `Some(_)`,
906: 904:     /// holding the old value until a new value has been received.
907: 905:     ///
908: 906:     /// ```rust
909: 907:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
910: 908:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
911: 909:     /// # tokio_test::block_on(async move {
912: 910:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
913: 911:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
914: 912:     /// let act = Action::new(|n: &u8| {
915: 913:     ///     let n = n.to_owned();
916: 914:     ///     async move { n * 2 }
917: 915:     /// });
918: 916:     ///
919: 917:     /// let value = act.value();
920: 918:     /// assert_eq!(value.get(), None);
921: 919:     /// act.dispatch(3);
922: 920:     /// assert_eq!(value.get(), None);
923: 921:     ///
924: 922:     /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
925: 923:     /// // after it resolves
926: 924:     /// assert_eq!(value.get(), Some(6));
927: 925:     /// // dispatch another value, and it still holds the old value
928: 926:     /// act.dispatch(3);
929: 927:     /// assert_eq!(value.get(), Some(6));
930: 928:     /// # });
931: 929:     /// ```
932: 930:     #[track_caller]
933: 931:     pub fn value(&self) -> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<Option<O>> {
934: 932:         self.inner
935: 933:             .try_with_value(|inner| inner.value())
936: 934:             .unwrap_or_else(unwrap_signal!(self))
937: 935:             .into()
938: 936:     }
939: 937: 
940: 938:     /// The most recent return value of the `async` function. This will be `None` before
941: 939:     /// the action has ever run successfully, and subsequently will always be `Some(_)`,
942: 940:     /// holding the old value until a new value has been received.
943: 941:     ///
944: 942:     /// Returns a thread-local signal using [`LocalStorage`].
945: 943:     #[deprecated = "You can now use .value() for any value, whether it's \
946: 944:                     thread-safe or not."]
947: 945:     #[track_caller]
948: 946:     pub fn value_local(&self) -> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedSignal<Option<O>>
949: 947:     where
950: 948:         O: Send + Sync,
951: 949:     {
952: 950:         self.inner
953: 951:             .try_with_value(|inner| inner.value())
954: 952:             .unwrap_or_else(unwrap_signal!(self))
955: 953:             .into()
956: 954:     }
957: 955: }
958: 956: 
959: 957: impl<I, O> Action<I, O>
960: 958: where
961: 959:     I: Send + Sync + 'static,
962: 960:     O: Send + Sync + 'static,
963: 961: {
964: 962:     /// Calls the `async` function with a reference to the input type as its argument.
965: 963:     #[track_caller]
966: 964:     pub fn dispatch(&self, input: I) -> ActionAbortHandle {
967: 965:         self.inner
968: 966:             .try_get_value()
969: 967:             .map(|inner| inner.dispatch(input))
970: 968:             .unwrap_or_else(unwrap_signal!(self))
971: 969:     }
972: 970: }
973: 971: 
974: 972: impl<I, O> Action<I, O>
975: 973: where
976: 974:     I: 'static,
977: 975:     O: 'static,
978: 976: {
979: 977:     /// Calls the `async` function with a reference to the input type as its argument.
980: 978:     #[track_caller]
981: 979:     pub fn dispatch_local(&self, input: I) -> ActionAbortHandle {
982: 980:         self.inner
983: 981:             .try_get_value()
984: 982:             .map(|inner| inner.dispatch_local(input))
985: 983:             .unwrap_or_else(unwrap_signal!(self))
986: 984:     }
987: 985: }
988: 986: 
989: 987: impl<I, O> Action<I, O>
990: 988: where
991: 989:     I: Send + Sync + 'static,
992: 990:     O: Send + Sync + 'static,
993: 991: {
994: 992:     /// Creates a new action, which does not require the action itself to be `Send`, but will run
995: 993:     /// it on the same thread it was created on.
996: 994:     ///
997: 995:     /// In all other ways, this is identical to [`Action::new`].
998: 996:     #[track_caller]
999: 997:     pub fn new_unsync<F, Fu>(action_fn: F) -> Self
1000: 998:     where
1001: 999:         F: Fn(&I) -> Fu + 'static,
1002: 1000:         Fu: Future<Output = O> + 'static,
1003: 1001:     {
1004: 1002:         Self {
1005: 1003:             inner: ArenaItem::new_with_storage(ArcAction::new_unsync(
1006: 1004:                 action_fn,
1007: 1005:             )),
1008: 1006:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
1009: 1007:             defined_at: Location::caller(),
1010: 1008:         }
1011: 1009:     }
1012: 1010: 
1013: 1011:     /// Creates a new action, which does not require the action itself to be `Send`, but will run
1014: 1012:     /// it on the same thread it was created on, and gives an initial value.
1015: 1013:     ///
1016: 1014:     /// In all other ways, this is identical to [`Action::new`].
1017: 1015:     #[track_caller]
1018: 1016:     pub fn new_unsync_with_value<F, Fu>(value: Option<O>, action_fn: F) -> Self
1019: 1017:     where
1020: 1018:         F: Fn(&I) -> Fu + 'static,
1021: 1019:         Fu: Future<Output = O> + 'static,
1022: 1020:     {
1023: 1021:         Self {
1024: 1022:             inner: ArenaItem::new_with_storage(
1025: 1023:                 ArcAction::new_unsync_with_value(value, action_fn),
1026: 1024:             ),
1027: 1025:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
1028: 1026:             defined_at: Location::caller(),
1029: 1027:         }
1030: 1028:     }
1031: 1029: }
1032: 1030: 
1033: 1031: impl<I, O> Action<I, O>
1034: 1032: where
1035: 1033:     I: 'static,
1036: 1034:     O: 'static,
1037: 1035: {
1038: 1036:     /// Creates a new action, which neither requires the action itself nor the
1039: 1037:     /// value it returns to be `Send`. If this action is accessed from outside the
1040: 1038:     /// thread on which it was created, it panics.
1041: 1039:     ///
1042: 1040:     /// This combines the features of [`Action::new_local`] and [`Action::new_unsync`].
1043: 1041:     #[track_caller]
1044: 1042:     pub fn new_unsync_local<F, Fu>(action_fn: F) -> Self
1045: 1043:     where
1046: 1044:         F: Fn(&I) -> Fu + 'static,
1047: 1045:         Fu: Future<Output = O> + 'static,
1048: 1046:     {
1049: 1047:         Self {
1050: 1048:             inner: ArenaItem::new_with_storage(ArcAction::new_unsync(
1051: 1049:                 action_fn,
1052: 1050:             )),
1053: 1051:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
1054: 1052:             defined_at: Location::caller(),
1055: 1053:         }
1056: 1054:     }
1057: 1055: 
1058: 1056:     /// Creates a new action, which neither requires the action itself nor the
1059: 1057:     /// value it returns to be `Send`, and provides it with an initial value.
1060: 1058:     /// If this action is accessed from outside the thread on which it was created, it panics.
1061: 1059:     ///
1062: 1060:     /// This combines the features of [`Action::new_local_with_value`] and
1063: 1061:     /// [`Action::new_unsync_with_value`].
1064: 1062:     #[track_caller]
1065: 1063:     pub fn new_unsync_local_with_value<F, Fu>(
1066: 1064:         value: Option<O>,
1067: 1065:         action_fn: F,
1068: 1066:     ) -> Self
1069: 1067:     where
1070: 1068:         F: Fn(&I) -> Fu + 'static,
1071: 1069:         Fu: Future<Output = O> + 'static,
1072: 1070:     {
1073: 1071:         Self {
1074: 1072:             inner: ArenaItem::new_with_storage(
1075: 1073:                 ArcAction::new_unsync_with_value(value, action_fn),
1076: 1074:             ),
1077: 1075:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
1078: 1076:             defined_at: Location::caller(),
1079: 1077:         }
1080: 1078:     }
1081: 1079: }
1082: 1080: 
1083: 1081: impl<I, O> DefinedAt for Action<I, O> {
1084: 1082:     fn defined_at(&self) -> Option<&'static Location<'static>> {
1085: 1083:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
1086: 1084:         {
1087: 1085:             Some(self.defined_at)
1088: 1086:         }
1089: 1087:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
1090: 1088:         {
1091: 1089:             None
1092: 1090:         }
1093: 1091:     }
1094: 1092: }
1095: 1093: 
1096: 1094: impl<I, O> Clone for Action<I, O> {
1097: 1095:     fn clone(&self) -> Self {
1098: 1096:         *self
1099: 1097:     }
1100: 1098: }
1101: 1099: 
1102: 1100: impl<I, O> Copy for Action<I, O> {}
1103: 1101: 
1104: 1102: /// Creates a new action. This is lazy: it does not run the action function until some value
1105: 1103: /// is dispatched.
1106: 1104: ///
1107: 1105: /// The constructor takes a function which will create a new `Future` from some input data.
1108: 1106: /// When the action is dispatched, this `action_fn` will run, and the `Future` it returns will
1109: 1107: /// be spawned.
1110: 1108: ///
1111: 1109: /// The `action_fn` must be `Send + Sync` so that the `ArcAction` is `Send + Sync`. The
1112: 1110: /// `Future` must be `Send` so that it can be moved across threads by the async executor as
1113: 1111: /// needed. In order to be stored in the `Copy` arena, the input and output types should also
1114: 1112: /// be `Send + Sync`.
1115: 1113: ///
1116: 1114: /// ```rust
1117: 1115: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
1118: 1116: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
1119: 1117: /// # tokio_test::block_on(async move {
1120: 1118: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
1121: 1119: /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
1122: 1120: /// let act = Action::new(|n: &u8| {
1123: 1121: ///     let n = n.to_owned();
1124: 1122: ///     async move { n * 2 }
1125: 1123: /// });
1126: 1124: ///
1127: 1125: /// act.dispatch(3);
1128: 1126: /// assert_eq!(act.input().get(), Some(3));
1129: 1127: ///
1130: 1128: /// // Remember that async functions already return a future if they are
1131: 1129: /// // not `await`ed. You can save keystrokes by leaving out the `async move`
1132: 1130: ///
1133: 1131: /// let act2 = Action::new(|n: &String| yell(n.to_owned()));
1134: 1132: /// act2.dispatch(String::from("i'm in a doctest"));
1135: 1133: /// # tokio::time::sleep(std::time::Duration::from_millis(10)).await;
1136: 1134: ///
1137: 1135: /// // after it resolves
1138: 1136: /// assert_eq!(act2.value().get(), Some("I'M IN A DOCTEST".to_string()));
1139: 1137: ///
1140: 1138: /// async fn yell(n: String) -> String {
1141: 1139: ///     n.to_uppercase()
1142: 1140: /// }
1143: 1141: /// # });
1144: 1142: /// ```
1145: 1143: #[inline(always)]
1146: 1144: #[track_caller]
1147: 1145: #[deprecated = "This function is being removed to conform to Rust idioms. \
1148: 1146:                 Please use `Action::new()` instead."]
1149: 1147: pub fn create_action<I, O, F, Fu>(action_fn: F) -> Action<I, O>
1150: 1148: where
1151: 1149:     I: Send + Sync + 'static,
1152: 1150:     O: Send + Sync + 'static,
1153: 1151:     F: Fn(&I) -> Fu + Send + Sync + 'static,
1154: 1152:     Fu: Future<Output = O> + Send + 'static,
1155: 1153: {
1156: 1154:     Action::new(action_fn)
1157: 1155: }
1158: ```
```
