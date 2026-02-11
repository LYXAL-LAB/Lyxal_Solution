### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\actions\multi_action.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\actions\multi_action.rs
2: ```rust
3: 1: use crate::{
4: 2:     diagnostics::is_suppressing_resource_load,
5: 3:     owner::{ArenaItem, FromLocal, LocalStorage, Storage, SyncStorage},
6: 4:     signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
7: 5:     traits::{DefinedAt, Dispose, GetUntracked, Set, Update},
8: 6:     unwrap_signal,
9: 7: };
10: 8: use std::{fmt::Debug, future::Future, panic::Location, pin::Pin, sync::Arc};
11: 9: 
12: 10: /// An action that synchronizes multiple imperative `async` calls to the reactive system,
13: 11: /// tracking the progress of each one.
14: 12: ///
15: 13: /// Where an [`Action`](super::Action) fires a single call, a `MultiAction` allows you to
16: 14: /// keep track of multiple in-flight actions.
17: 15: ///
18: 16: /// If you’re trying to load data by running an `async` function reactively, you probably
19: 17: /// want to use an [`AsyncDerived`](crate::computed::AsyncDerived) instead.
20: 18: /// If you’re trying to occasionally run an `async` function in response to something
21: 19: /// like a user adding a task to a todo list, you’re in the right place.
22: 20: ///
23: 21: /// The reference-counted, `Clone` (but not `Copy` version of a `MultiAction` is an [`ArcMultiAction`].
24: 22: ///
25: 23: /// ```rust
26: 24: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
27: 25: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
28: 26: /// # tokio_test::block_on(async move {
29: 27: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
30: 28: /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
31: 29: /// async fn send_new_todo_to_api(task: String) -> usize {
32: 30: ///   // do something...
33: 31: ///   // return a task id
34: 32: ///   42
35: 33: /// }
36: 34: /// let add_todo = MultiAction::new(|task: &String| {
37: 35: ///   // `task` is given as `&String` because its value is available in `input`
38: 36: ///   send_new_todo_to_api(task.clone())
39: 37: /// });
40: 38: ///
41: 39: /// add_todo.dispatch("Buy milk".to_string());
42: 40: /// add_todo.dispatch("???".to_string());
43: 41: /// add_todo.dispatch("Profit!!!".to_string());
44: 42: ///
45: 43: /// let submissions = add_todo.submissions();
46: 44: /// assert_eq!(submissions.with(Vec::len), 3);
47: 45: /// # });
48: 46: /// ```
49: 47: pub struct MultiAction<I, O, S = SyncStorage> {
50: 48:     inner: ArenaItem<ArcMultiAction<I, O>, S>,
51: 49:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
52: 50:     defined_at: &'static Location<'static>,
53: 51: }
54: 52: 
55: 53: impl<I, O, S> Dispose for MultiAction<I, O, S> {
56: 54:     fn dispose(self) {
57: 55:         self.inner.dispose()
58: 56:     }
59: 57: }
60: 58: 
61: 59: impl<I, O, S> DefinedAt for MultiAction<I, O, S>
62: 60: where
63: 61:     I: 'static,
64: 62:     O: 'static,
65: 63: {
66: 64:     fn defined_at(&self) -> Option<&'static Location<'static>> {
67: 65:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
68: 66:         {
69: 67:             Some(self.defined_at)
70: 68:         }
71: 69:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
72: 70:         {
73: 71:             None
74: 72:         }
75: 73:     }
76: 74: }
77: 75: 
78: 76: impl<I, O, S> Copy for MultiAction<I, O, S>
79: 77: where
80: 78:     I: 'static,
81: 79:     O: 'static,
82: 80: {
83: 81: }
84: 82: 
85: 83: impl<I, O, S> Clone for MultiAction<I, O, S>
86: 84: where
87: 85:     I: 'static,
88: 86:     O: 'static,
89: 87: {
90: 88:     fn clone(&self) -> Self {
91: 89:         *self
92: 90:     }
93: 91: }
94: 92: 
95: 93: impl<I, O> MultiAction<I, O>
96: 94: where
97: 95:     I: Send + Sync + 'static,
98: 96:     O: Send + Sync + 'static,
99: 97: {
100: 98:     /// Creates a new multi-action.
101: 99:     ///
102: 100:     /// The input to the `async` function should always be a single value,
103: 101:     /// but it can be of any type. The argument is always passed by reference to the
104: 102:     /// function, because it is stored in [Submission::input] as well.
105: 103:     ///
106: 104:     /// ```rust
107: 105:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
108: 106:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
109: 107:     /// # tokio_test::block_on(async move {
110: 108:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
111: 109:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
112: 110:     /// // if there's a single argument, just use that
113: 111:     /// let action1 = MultiAction::new(|input: &String| {
114: 112:     ///     let input = input.clone();
115: 113:     ///     async move { todo!() }
116: 114:     /// });
117: 115:     ///
118: 116:     /// // if there are no arguments, use the unit type `()`
119: 117:     /// let action2 = MultiAction::new(|input: &()| async { todo!() });
120: 118:     ///
121: 119:     /// // if there are multiple arguments, use a tuple
122: 120:     /// let action3 =
123: 121:     ///     MultiAction::new(|input: &(usize, String)| async { todo!() });
124: 122:     /// # });
125: 123:     /// ```
126: 124:     #[track_caller]
127: 125:     pub fn new<Fut>(
128: 126:         action_fn: impl Fn(&I) -> Fut + Send + Sync + 'static,
129: 127:     ) -> Self
130: 128:     where
131: 129:         Fut: Future<Output = O> + Send + 'static,
132: 130:     {
133: 131:         Self {
134: 132:             inner: ArenaItem::new_with_storage(ArcMultiAction::new(action_fn)),
135: 133:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
136: 134:             defined_at: Location::caller(),
137: 135:         }
138: 136:     }
139: 137: }
140: 138: 
141: 139: impl<I, O, S> MultiAction<I, O, S>
142: 140: where
143: 141:     I: Send + Sync + 'static,
144: 142:     O: Send + Sync + 'static,
145: 143:     S: Storage<ArcMultiAction<I, O>>,
146: 144: {
147: 145:     /// Calls the `async` function with a reference to the input type as its argument.
148: 146:     ///
149: 147:     /// This can be called any number of times: each submission will be dispatched, running
150: 148:     /// concurrently, and its status can be checked via the
151: 149:     /// [`submissions()`](MultiAction::submissions) signal.
152: 150:     /// ```rust
153: 151:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
154: 152:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
155: 153:     /// # tokio_test::block_on(async move {
156: 154:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
157: 155:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
158: 156:     /// async fn send_new_todo_to_api(task: String) -> usize {
159: 157:     ///   // do something...
160: 158:     ///   // return a task id
161: 159:     ///   42
162: 160:     /// }
163: 161:     /// let add_todo = MultiAction::new(|task: &String| {
164: 162:     ///   // `task` is given as `&String` because its value is available in `input`
165: 163:     ///   send_new_todo_to_api(task.clone())
166: 164:     /// });
167: 165:     ///
168: 166:     /// let submissions = add_todo.submissions();
169: 167:     /// let pending_submissions = move || {
170: 168:     ///   submissions.with(|subs| subs.iter().filter(|sub| sub.pending().get()).count())
171: 169:     /// };
172: 170:     ///
173: 171:     /// add_todo.dispatch("Buy milk".to_string());
174: 172:     /// assert_eq!(submissions.with(Vec::len), 1);
175: 173:     /// assert_eq!(pending_submissions(), 1);
176: 174:     ///
177: 175:     /// add_todo.dispatch("???".to_string());
178: 176:     /// add_todo.dispatch("Profit!!!".to_string());
179: 177:     ///
180: 178:     /// assert_eq!(submissions.with(Vec::len), 3);
181: 179:     /// assert_eq!(pending_submissions(), 3);
182: 180:     ///
183: 181:     /// // when submissions resolve, they are not removed from the set
184: 182:     /// // however, their `pending` signal is now `false`, and this can be used to filter them
185: 183:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
186: 184:     /// assert_eq!(submissions.with(Vec::len), 3);
187: 185:     /// assert_eq!(pending_submissions(), 0);
188: 186:     /// # });
189: 187:     /// ```
190: 188:     pub fn dispatch(&self, input: I) {
191: 189:         if !is_suppressing_resource_load() {
192: 190:             self.inner.try_with_value(|inner| inner.dispatch(input));
193: 191:         }
194: 192:     }
195: 193: 
196: 194:     /// Synchronously adds a submission with the given value.
197: 195:     ///
198: 196:     /// This takes the output value, rather than the input, because it is adding a result, not an
199: 197:     /// input.
200: 198:     ///
201: 199:     /// This can be useful for use cases like handling errors, where the error can already be known
202: 200:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client side.
203: 201:     /// ```rust
204: 202:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
205: 203:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
206: 204:     /// # tokio_test::block_on(async move {
207: 205:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
208: 206:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
209: 207:     /// async fn send_new_todo_to_api(task: String) -> usize {
210: 208:     ///   // do something...
211: 209:     ///   // return a task id
212: 210:     ///   42
213: 211:     /// }
214: 212:     /// let add_todo = MultiAction::new(|task: &String| {
215: 213:     ///   // `task` is given as `&String` because its value is available in `input`
216: 214:     ///   send_new_todo_to_api(task.clone())
217: 215:     /// });
218: 216:     ///
219: 217:     /// let submissions = add_todo.submissions();
220: 218:     /// let pending_submissions = move || {
221: 219:     ///   submissions.with(|subs| subs.iter().filter(|sub| sub.pending().get()).count())
222: 220:     /// };
223: 221:     ///
224: 222:     /// add_todo.dispatch("Buy milk".to_string());
225: 223:     /// assert_eq!(submissions.with(Vec::len), 1);
226: 224:     /// assert_eq!(pending_submissions(), 1);
227: 225:     ///
228: 226:     /// add_todo.dispatch_sync(42);
229: 227:     ///
230: 228:     /// assert_eq!(submissions.with(Vec::len), 2);
231: 229:     /// assert_eq!(pending_submissions(), 1);
232: 230:     /// # });
233: 231:     /// ```
234: 232:     pub fn dispatch_sync(&self, value: O) {
235: 233:         self.inner
236: 234:             .try_with_value(|inner| inner.dispatch_sync(value));
237: 235:     }
238: 236: }
239: 237: 
240: 238: impl<I, O> MultiAction<I, O>
241: 239: where
242: 240:     I: Send + Sync + 'static,
243: 241:     O: Send + Sync + 'static,
244: 242: {
245: 243:     /// The set of all submissions to this multi-action.
246: 244:     /// ```rust
247: 245:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
248: 246:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
249: 247:     /// # tokio_test::block_on(async move {
250: 248:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
251: 249:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
252: 250:     /// async fn send_new_todo_to_api(task: String) -> usize {
253: 251:     ///   // do something...
254: 252:     ///   // return a task id
255: 253:     ///   42
256: 254:     /// }
257: 255:     /// let add_todo = MultiAction::new(|task: &String| {
258: 256:     ///   // `task` is given as `&String` because its value is available in `input`
259: 257:     ///   send_new_todo_to_api(task.clone())
260: 258:     /// });
261: 259:     ///
262: 260:     /// let submissions = add_todo.submissions();
263: 261:     ///
264: 262:     /// add_todo.dispatch("Buy milk".to_string());
265: 263:     /// add_todo.dispatch("???".to_string());
266: 264:     /// add_todo.dispatch("Profit!!!".to_string());
267: 265:     ///
268: 266:     /// assert_eq!(submissions.with(Vec::len), 3);
269: 267:     /// # });
270: 268:     /// ```
271: 269:     pub fn submissions(&self) -> ReadSignal<Vec<ArcSubmission<I, O>>> {
272: 270:         self.inner
273: 271:             .try_with_value(|inner| inner.submissions())
274: 272:             .unwrap_or_else(unwrap_signal!(self))
275: 273:             .into()
276: 274:     }
277: 275: }
278: 276: 
279: 277: impl<I, O, S> MultiAction<I, O, S>
280: 278: where
281: 279:     I: 'static,
282: 280:     O: 'static,
283: 281:     S: Storage<ArcMultiAction<I, O>>
284: 282:         + Storage<ArcReadSignal<Vec<ArcSubmission<I, O>>>>,
285: 283: {
286: 284:     /// How many times an action has successfully resolved.
287: 285:     /// ```rust
288: 286:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
289: 287:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
290: 288:     /// # tokio_test::block_on(async move {
291: 289:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
292: 290:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
293: 291:     /// async fn send_new_todo_to_api(task: String) -> usize {
294: 292:     ///   // do something...
295: 293:     ///   // return a task id
296: 294:     ///   42
297: 295:     /// }
298: 296:     /// let add_todo = MultiAction::new(|task: &String| {
299: 297:     ///   // `task` is given as `&String` because its value is available in `input`
300: 298:     ///   send_new_todo_to_api(task.clone())
301: 299:     /// });
302: 300:     ///
303: 301:     /// let version = add_todo.version();
304: 302:     ///
305: 303:     /// add_todo.dispatch("Buy milk".to_string());
306: 304:     /// add_todo.dispatch("???".to_string());
307: 305:     /// add_todo.dispatch("Profit!!!".to_string());
308: 306:     ///
309: 307:     /// assert_eq!(version.get(), 0);
310: 308:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
311: 309:     ///
312: 310:     /// // when they've all resolved
313: 311:     /// assert_eq!(version.get(), 3);
314: 312:     /// # });
315: 313:     /// ```
316: 314:     pub fn version(&self) -> RwSignal<usize> {
317: 315:         self.inner
318: 316:             .try_with_value(|inner| inner.version())
319: 317:             .unwrap_or_else(unwrap_signal!(self))
320: 318:             .into()
321: 319:     }
322: 320: }
323: 321: 
324: 322: /// An action that synchronizes multiple imperative `async` calls to the reactive system,
325: 323: /// tracking the progress of each one.
326: 324: ///
327: 325: /// Where an [`Action`](super::Action) fires a single call, a `MultiAction` allows you to
328: 326: /// keep track of multiple in-flight actions.
329: 327: ///
330: 328: /// If you’re trying to load data by running an `async` function reactively, you probably
331: 329: /// want to use an [`AsyncDerived`](crate::computed::AsyncDerived) instead.
332: 330: /// If you’re trying to occasionally run an `async` function in response to something
333: 331: /// like a user adding a task to a todo list, you’re in the right place.
334: 332: ///
335: 333: /// The arena-allocated, `Copy` version of an `ArcMultiAction` is a [`MultiAction`].
336: 334: ///
337: 335: /// ```rust
338: 336: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
339: 337: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
340: 338: /// # tokio_test::block_on(async move {
341: 339: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
342: 340: /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
343: 341: /// async fn send_new_todo_to_api(task: String) -> usize {
344: 342: ///   // do something...
345: 343: ///   // return a task id
346: 344: ///   42
347: 345: /// }
348: 346: /// let add_todo = ArcMultiAction::new(|task: &String| {
349: 347: ///   // `task` is given as `&String` because its value is available in `input`
350: 348: ///   send_new_todo_to_api(task.clone())
351: 349: /// });
352: 350: ///
353: 351: /// add_todo.dispatch("Buy milk".to_string());
354: 352: /// add_todo.dispatch("???".to_string());
355: 353: /// add_todo.dispatch("Profit!!!".to_string());
356: 354: ///
357: 355: /// let submissions = add_todo.submissions();
358: 356: /// assert_eq!(submissions.with(Vec::len), 3);
359: 357: /// # });
360: 358: /// ```
361: 359: pub struct ArcMultiAction<I, O> {
362: 360:     version: ArcRwSignal<usize>,
363: 361:     submissions: ArcRwSignal<Vec<ArcSubmission<I, O>>>,
364: 362:     #[allow(clippy::complexity)]
365: 363:     action_fn: Arc<
366: 364:         dyn Fn(&I) -> Pin<Box<dyn Future<Output = O> + Send>> + Send + Sync,
367: 365:     >,
368: 366: }
369: 367: 
370: 368: impl<I, O> Debug for ArcMultiAction<I, O>
371: 369: where
372: 370:     I: 'static,
373: 371:     O: 'static,
374: 372: {
375: 373:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
376: 374:         f.debug_struct("ArcMultiAction")
377: 375:             .field("version", &self.version)
378: 376:             .field("submissions", &self.submissions)
379: 377:             .finish()
380: 378:     }
381: 379: }
382: 380: 
383: 381: impl<I, O> Clone for ArcMultiAction<I, O>
384: 382: where
385: 383:     I: 'static,
386: 384:     O: 'static,
387: 385: {
388: 386:     fn clone(&self) -> Self {
389: 387:         Self {
390: 388:             version: self.version.clone(),
391: 389:             submissions: self.submissions.clone(),
392: 390:             action_fn: Arc::clone(&self.action_fn),
393: 391:         }
394: 392:     }
395: 393: }
396: 394: 
397: 395: impl<I, O> ArcMultiAction<I, O> {
398: 396:     /// Creates a new multi-action.
399: 397:     ///
400: 398:     /// The input to the `async` function should always be a single value,
401: 399:     /// but it can be of any type. The argument is always passed by reference to the
402: 400:     /// function, because it is stored in [Submission::input] as well.
403: 401:     ///
404: 402:     /// ```rust
405: 403:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
406: 404:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
407: 405:     /// # tokio_test::block_on(async move {
408: 406:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
409: 407:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
410: 408:     /// // if there's a single argument, just use that
411: 409:     /// let action1 = ArcMultiAction::new(|input: &String| {
412: 410:     ///     let input = input.clone();
413: 411:     ///     async move { todo!() }
414: 412:     /// });
415: 413:     ///
416: 414:     /// // if there are no arguments, use the unit type `()`
417: 415:     /// let action2 = ArcMultiAction::new(|input: &()| async { todo!() });
418: 416:     ///
419: 417:     /// // if there are multiple arguments, use a tuple
420: 418:     /// let action3 =
421: 419:     ///     ArcMultiAction::new(|input: &(usize, String)| async { todo!() });
422: 420:     /// # });
423: 421:     /// ```
424: 422:     #[track_caller]
425: 423:     pub fn new<Fut>(
426: 424:         action_fn: impl Fn(&I) -> Fut + Send + Sync + 'static,
427: 425:     ) -> Self
428: 426:     where
429: 427:         Fut: Future<Output = O> + Send + 'static,
430: 428:     {
431: 429:         let action_fn = Arc::new(move |input: &I| {
432: 430:             let fut = action_fn(input);
433: 431:             Box::pin(fut) as Pin<Box<dyn Future<Output = O> + Send>>
434: 432:         });
435: 433:         Self {
436: 434:             version: ArcRwSignal::new(0),
437: 435:             submissions: ArcRwSignal::new(Vec::new()),
438: 436:             action_fn,
439: 437:         }
440: 438:     }
441: 439: }
442: 440: 
443: 441: impl<I, O> ArcMultiAction<I, O>
444: 442: where
445: 443:     I: Send + Sync + 'static,
446: 444:     O: Send + Sync + 'static,
447: 445: {
448: 446:     /// Calls the `async` function with a reference to the input type as its argument.
449: 447:     ///
450: 448:     /// This can be called any number of times: each submission will be dispatched, running
451: 449:     /// concurrently, and its status can be checked via the
452: 450:     /// [`submissions()`](MultiAction::submissions) signal.
453: 451:     /// ```rust
454: 452:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
455: 453:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
456: 454:     /// # tokio_test::block_on(async move {
457: 455:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
458: 456:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
459: 457:     /// async fn send_new_todo_to_api(task: String) -> usize {
460: 458:     ///   // do something...
461: 459:     ///   // return a task id
462: 460:     ///   42
463: 461:     /// }
464: 462:     /// let add_todo = ArcMultiAction::new(|task: &String| {
465: 463:     ///   // `task` is given as `&String` because its value is available in `input`
466: 464:     ///   send_new_todo_to_api(task.clone())
467: 465:     /// });
468: 466:     ///
469: 467:     /// let submissions = add_todo.submissions();
470: 468:     /// let pending_submissions = {
471: 469:     ///     let submissions = submissions.clone();
472: 470:     ///     move || {
473: 471:     ///         submissions.with(|subs| subs.iter().filter(|sub| sub.pending().get()).count())
474: 472:     ///     }
475: 473:     /// };
476: 474:     ///
477: 475:     /// add_todo.dispatch("Buy milk".to_string());
478: 476:     /// assert_eq!(submissions.with(Vec::len), 1);
479: 477:     /// assert_eq!(pending_submissions(), 1);
480: 478:     ///
481: 479:     /// add_todo.dispatch("???".to_string());
482: 480:     /// add_todo.dispatch("Profit!!!".to_string());
483: 481:     ///
484: 482:     /// assert_eq!(submissions.with(Vec::len), 3);
485: 483:     /// assert_eq!(pending_submissions(), 3);
486: 484:     ///
487: 485:     /// // when submissions resolve, they are not removed from the set
488: 486:     /// // however, their `pending` signal is now `false`, and this can be used to filter them
489: 487:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
490: 488:     /// assert_eq!(submissions.with(Vec::len), 3);
491: 489:     /// assert_eq!(pending_submissions(), 0);
492: 490:     /// # });
493: 491:     /// ```
494: 492:     pub fn dispatch(&self, input: I) {
495: 493:         if !is_suppressing_resource_load() {
496: 494:             let fut = (self.action_fn)(&input);
497: 495: 
498: 496:             let submission = ArcSubmission {
499: 497:                 input: ArcRwSignal::new(Some(input)),
500: 498:                 value: ArcRwSignal::new(None),
501: 499:                 pending: ArcRwSignal::new(true),
502: 500:                 canceled: ArcRwSignal::new(false),
503: 501:             };
504: 502: 
505: 503:             self.submissions
506: 504:                 .try_update(|subs| subs.push(submission.clone()));
507: 505: 
508: 506:             let version = self.version.clone();
509: 507: 
510: 508:             crate::spawn(async move {
511: 509:                 let new_value = fut.await;
512: 510:                 let canceled = submission.canceled.get_untracked();
513: 511:                 if !canceled {
514: 512:                     submission.value.try_set(Some(new_value));
515: 513:                 }
516: 514:                 submission.input.try_set(None);
517: 515:                 submission.pending.try_set(false);
518: 516:                 version.try_update(|n| *n += 1);
519: 517:             })
520: 518:         }
521: 519:     }
522: 520: 
523: 521:     /// Synchronously adds a submission with the given value.
524: 522:     ///
525: 523:     /// This takes the output value, rather than the input, because it is adding a result, not an
526: 524:     /// input.
527: 525:     ///
528: 526:     /// This can be useful for use cases like handling errors, where the error can already be known
529: 527:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client side.
530: 528:     /// ```rust
531: 529:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
532: 530:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
533: 531:     /// # tokio_test::block_on(async move {
534: 532:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
535: 533:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
536: 534:     /// async fn send_new_todo_to_api(task: String) -> usize {
537: 535:     ///   // do something...
538: 536:     ///   // return a task id
539: 537:     ///   42
540: 538:     /// }
541: 539:     /// let add_todo = ArcMultiAction::new(|task: &String| {
542: 540:     ///   // `task` is given as `&String` because its value is available in `input`
543: 541:     ///   send_new_todo_to_api(task.clone())
544: 542:     /// });
545: 543:     ///
546: 544:     /// let submissions = add_todo.submissions();
547: 545:     /// let pending_submissions = {
548: 546:     ///     let submissions = submissions.clone();
549: 547:     ///     move || {
550: 548:     ///         submissions.with(|subs| subs.iter().filter(|sub| sub.pending().get()).count())
551: 549:     ///     }
552: 550:     /// };
553: 551:     ///
554: 552:     /// add_todo.dispatch("Buy milk".to_string());
555: 553:     /// assert_eq!(submissions.with(Vec::len), 1);
556: 554:     /// assert_eq!(pending_submissions(), 1);
557: 555:     ///
558: 556:     /// add_todo.dispatch_sync(42);
559: 557:     ///
560: 558:     /// assert_eq!(submissions.with(Vec::len), 2);
561: 559:     /// assert_eq!(pending_submissions(), 1);
562: 560:     /// # });
563: 561:     /// ```
564: 562:     pub fn dispatch_sync(&self, value: O) {
565: 563:         let submission = ArcSubmission {
566: 564:             input: ArcRwSignal::new(None),
567: 565:             value: ArcRwSignal::new(Some(value)),
568: 566:             pending: ArcRwSignal::new(false),
569: 567:             canceled: ArcRwSignal::new(false),
570: 568:         };
571: 569: 
572: 570:         self.submissions
573: 571:             .try_update(|subs| subs.push(submission.clone()));
574: 572:         self.version.try_update(|n| *n += 1);
575: 573:     }
576: 574: }
577: 575: 
578: 576: impl<I, O> ArcMultiAction<I, O> {
579: 577:     /// The set of all submissions to this multi-action.
580: 578:     /// ```rust
581: 579:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
582: 580:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
583: 581:     /// # tokio_test::block_on(async move {
584: 582:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
585: 583:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
586: 584:     /// async fn send_new_todo_to_api(task: String) -> usize {
587: 585:     ///   // do something...
588: 586:     ///   // return a task id
589: 587:     ///   42
590: 588:     /// }
591: 589:     /// let add_todo = ArcMultiAction::new(|task: &String| {
592: 590:     ///   // `task` is given as `&String` because its value is available in `input`
593: 591:     ///   send_new_todo_to_api(task.clone())
594: 592:     /// });
595: 593:     ///
596: 594:     /// let submissions = add_todo.submissions();
597: 595:     ///
598: 596:     /// add_todo.dispatch("Buy milk".to_string());
599: 597:     /// add_todo.dispatch("???".to_string());
600: 598:     /// add_todo.dispatch("Profit!!!".to_string());
601: 599:     ///
602: 600:     /// assert_eq!(submissions.with(Vec::len), 3);
603: 601:     /// # });
604: 602:     /// ```
605: 603:     pub fn submissions(&self) -> ArcReadSignal<Vec<ArcSubmission<I, O>>> {
606: 604:         self.submissions.read_only()
607: 605:     }
608: 606: 
609: 607:     /// How many times an action has successfully resolved.
610: 608:     /// ```rust
611: 609:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::actions::*;
612: 610:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
613: 611:     /// # tokio_test::block_on(async move {
614: 612:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
615: 613:     /// # let _guard = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
616: 614:     /// async fn send_new_todo_to_api(task: String) -> usize {
617: 615:     ///   // do something...
618: 616:     ///   // return a task id
619: 617:     ///   42
620: 618:     /// }
621: 619:     /// let add_todo = ArcMultiAction::new(|task: &String| {
622: 620:     ///   // `task` is given as `&String` because its value is available in `input`
623: 621:     ///   send_new_todo_to_api(task.clone())
624: 622:     /// });
625: 623:     ///
626: 624:     /// let version = add_todo.version();
627: 625:     ///
628: 626:     /// add_todo.dispatch("Buy milk".to_string());
629: 627:     /// add_todo.dispatch("???".to_string());
630: 628:     /// add_todo.dispatch("Profit!!!".to_string());
631: 629:     ///
632: 630:     /// assert_eq!(version.get(), 0);
633: 631:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
634: 632:     ///
635: 633:     /// // when they've all resolved
636: 634:     /// assert_eq!(version.get(), 3);
637: 635:     /// # });
638: 636:     /// ```
639: 637:     pub fn version(&self) -> ArcRwSignal<usize> {
640: 638:         self.version.clone()
641: 639:     }
642: 640: }
643: 641: 
644: 642: /// An action that has been submitted by dispatching it to a [`MultiAction`].
645: 643: #[derive(Debug, PartialEq, Eq, Hash)]
646: 644: pub struct ArcSubmission<I, O> {
647: 645:     /// The current argument that was dispatched to the `async` function.
648: 646:     /// `Some` while we are waiting for it to resolve, `None` if it has resolved.
649: 647:     input: ArcRwSignal<Option<I>>,
650: 648:     /// The most recent return value of the `async` function.
651: 649:     value: ArcRwSignal<Option<O>>,
652: 650:     pending: ArcRwSignal<bool>,
653: 651:     /// Controls this submission has been canceled.
654: 652:     canceled: ArcRwSignal<bool>,
655: 653: }
656: 654: 
657: 655: impl<I, O> ArcSubmission<I, O>
658: 656: where
659: 657:     I: 'static,
660: 658:     O: 'static,
661: 659: {
662: 660:     /// The current argument that was dispatched to the `async` function.
663: 661:     /// `Some` while we are waiting for it to resolve, `None` if it has resolved.
664: 662:     #[track_caller]
665: 663:     pub fn input(&self) -> ArcReadSignal<Option<I>> {
666: 664:         self.input.read_only()
667: 665:     }
668: 666: 
669: 667:     /// The most recent return value of the `async` function.
670: 668:     #[track_caller]
671: 669:     pub fn value(&self) -> ArcReadSignal<Option<O>> {
672: 670:         self.value.read_only()
673: 671:     }
674: 672: 
675: 673:     /// Whether this submision is still waiting to resolve.
676: 674:     #[track_caller]
677: 675:     pub fn pending(&self) -> ArcReadSignal<bool> {
678: 676:         self.pending.read_only()
679: 677:     }
680: 678: 
681: 679:     /// Whether this submission has been canceled.
682: 680:     #[track_caller]
683: 681:     pub fn canceled(&self) -> ArcReadSignal<bool> {
684: 682:         self.canceled.read_only()
685: 683:     }
686: 684: 
687: 685:     /// Cancels the submission. This will not necessarily prevent the `Future`
688: 686:     /// from continuing to run, but it will update the returned value.
689: 687:     #[track_caller]
690: 688:     pub fn cancel(&self) {
691: 689:         // TODO if we set these up to race against a cancel signal, we could actually drop the
692: 690:         // futures
693: 691:         self.canceled.try_set(true);
694: 692:     }
695: 693: }
696: 694: 
697: 695: impl<I, O> Clone for ArcSubmission<I, O> {
698: 696:     fn clone(&self) -> Self {
699: 697:         Self {
700: 698:             input: self.input.clone(),
701: 699:             value: self.value.clone(),
702: 700:             pending: self.pending.clone(),
703: 701:             canceled: self.canceled.clone(),
704: 702:         }
705: 703:     }
706: 704: }
707: 705: 
708: 706: /// An action that has been submitted by dispatching it to a [`MultiAction`].
709: 707: #[derive(Debug, PartialEq, Eq, Hash)]
710: 708: pub struct Submission<I, O, S = SyncStorage>
711: 709: where
712: 710:     I: 'static,
713: 711:     O: 'static,
714: 712: {
715: 713:     /// The current argument that was dispatched to the `async` function.
716: 714:     /// `Some` while we are waiting for it to resolve, `None` if it has resolved.
717: 715:     input: RwSignal<Option<I>, S>,
718: 716:     /// The most recent return value of the `async` function.
719: 717:     value: RwSignal<Option<O>, S>,
720: 718:     pending: RwSignal<bool>,
721: 719:     /// Controls this submission has been canceled.
722: 720:     canceled: RwSignal<bool>,
723: 721: }
724: 722: 
725: 723: impl<I, O> From<ArcSubmission<I, O>> for Submission<I, O>
726: 724: where
727: 725:     I: Send + Sync + 'static,
728: 726:     O: Send + Sync + 'static,
729: 727: {
730: 728:     fn from(value: ArcSubmission<I, O>) -> Self {
731: 729:         let ArcSubmission {
732: 730:             input,
733: 731:             value,
734: 732:             pending,
735: 733:             canceled,
736: 734:         } = value;
737: 735:         Self {
738: 736:             input: input.into(),
739: 737:             value: value.into(),
740: 738:             pending: pending.into(),
741: 739:             canceled: canceled.into(),
742: 740:         }
743: 741:     }
744: 742: }
745: 743: 
746: 744: impl<I, O> FromLocal<ArcSubmission<I, O>> for Submission<I, O, LocalStorage>
747: 745: where
748: 746:     I: 'static,
749: 747:     O: 'static,
750: 748: {
751: 749:     fn from_local(value: ArcSubmission<I, O>) -> Self {
752: 750:         let ArcSubmission {
753: 751:             input,
754: 752:             value,
755: 753:             pending,
756: 754:             canceled,
757: 755:         } = value;
758: 756:         Self {
759: 757:             input: RwSignal::from_local(input),
760: 758:             value: RwSignal::from_local(value),
761: 759:             pending: pending.into(),
762: 760:             canceled: canceled.into(),
763: 761:         }
764: 762:     }
765: 763: }
766: 764: 
767: 765: impl<I, O, S> Submission<I, O, S>
768: 766: where
769: 767:     S: Storage<ArcRwSignal<Option<I>>> + Storage<ArcReadSignal<Option<I>>>,
770: 768: {
771: 769:     /// The current argument that was dispatched to the `async` function.
772: 770:     /// `Some` while we are waiting for it to resolve, `None` if it has resolved.
773: 771:     #[track_caller]
774: 772:     pub fn input(&self) -> ReadSignal<Option<I>, S> {
775: 773:         self.input.read_only()
776: 774:     }
777: 775: }
778: 776: 
779: 777: impl<I, O, S> Submission<I, O, S>
780: 778: where
781: 779:     S: Storage<ArcRwSignal<Option<O>>> + Storage<ArcReadSignal<Option<O>>>,
782: 780: {
783: 781:     /// The most recent return value of the `async` function.
784: 782:     #[track_caller]
785: 783:     pub fn value(&self) -> ReadSignal<Option<O>, S> {
786: 784:         self.value.read_only()
787: 785:     }
788: 786: }
789: 787: 
790: 788: impl<I, O, S> Submission<I, O, S> {
791: 789:     /// Whether this submision is still waiting to resolve.
792: 790:     #[track_caller]
793: 791:     pub fn pending(&self) -> ReadSignal<bool> {
794: 792:         self.pending.read_only()
795: 793:     }
796: 794: 
797: 795:     /// Whether this submission has been canceled.
798: 796:     #[track_caller]
799: 797:     pub fn canceled(&self) -> ReadSignal<bool> {
800: 798:         self.canceled.read_only()
801: 799:     }
802: 800: 
803: 801:     /// Cancels the submission. This will not necessarily prevent the `Future`
804: 802:     /// from continuing to run, but it will update the returned value.
805: 803:     #[track_caller]
806: 804:     pub fn cancel(&self) {
807: 805:         self.canceled.try_set(true);
808: 806:     }
809: 807: }
810: 808: 
811: 809: impl<I, O, S> Clone for Submission<I, O, S> {
812: 810:     fn clone(&self) -> Self {
813: 811:         *self
814: 812:     }
815: 813: }
816: 814: 
817: 815: impl<I, O, S> Copy for Submission<I, O, S> {}
818: ```
```
