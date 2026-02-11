### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\rw.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\rw.rs
2: ```rust
3: 1: use super::{
4: 2:     guards::{Plain, ReadGuard},
5: 3:     subscriber_traits::AsSubscriberSet,
6: 4:     ArcReadSignal, ArcRwSignal, ArcWriteSignal, ReadSignal, WriteSignal,
7: 5: };
8: 6: use crate::{
9: 7:     graph::{ReactiveNode, SubscriberSet},
10: 8:     owner::{ArenaItem, FromLocal, LocalStorage, Storage, SyncStorage},
11: 9:     signal::guards::{UntrackedWriteGuard, WriteGuard},
12: 10:     traits::{
13: 11:         DefinedAt, Dispose, IntoInner, IsDisposed, Notify, ReadUntracked,
14: 12:         UntrackableGuard, Write,
15: 13:     },
16: 14:     unwrap_signal,
17: 15: };
18: 16: use core::fmt::Debug;
19: 17: use guardian::ArcRwLockWriteGuardian;
20: 18: use std::{
21: 19:     hash::Hash,
22: 20:     panic::Location,
23: 21:     sync::{Arc, RwLock},
24: 22: };
25: 23: 
26: 24: /// An arena-allocated signal that can be read from or written to.
27: 25: ///
28: 26: /// A signal is a piece of data that may change over time, and notifies other
29: 27: /// code when it has changed. This is the atomic unit of reactivity, which begins all other
30: 28: /// processes of reactive updates.
31: 29: ///
32: 30: /// This is an arena-allocated signal, which is `Copy` and is disposed when its reactive
33: 31: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted signal that lives
34: 32: /// as long as a reference to it is alive, see [`ArcRwSignal`].
35: 33: ///
36: 34: /// ## Core Trait Implementations
37: 35: ///
38: 36: /// ### Reading the Value
39: 37: /// - [`.get()`](crate::traits::Get) clones the current value of the signal.
40: 38: ///   If you call it within an effect, it will cause that effect to subscribe
41: 39: ///   to the signal, and to re-run whenever the value of the signal changes.
42: 40: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
43: 41: ///     the signal without reactively tracking it.
44: 42: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
45: 43: ///   value of the signal by reference. If you call it within an effect, it will
46: 44: ///   cause that effect to subscribe to the signal, and to re-run whenever the
47: 45: ///   value of the signal changes.
48: 46: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
49: 47: ///     current value of the signal without reactively tracking it.
50: 48: /// - [`.with()`](crate::traits::With) allows you to reactively access the signal’s
51: 49: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
52: 50: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
53: 51: ///     the signal’s value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
54: 52: ///     tracking it.
55: 53: /// - [`.to_stream()`](crate::traits::ToStream) converts the signal to an `async`
56: 54: ///   stream of values.
57: 55: ///
58: 56: /// ### Updating the Value
59: 57: /// - [`.set()`](crate::traits::Set) sets the signal to a new value.
60: 58: /// - [`.update()`](crate::traits::Update) updates the value of the signal by
61: 59: ///   lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a closure that takes a mutable reference.
62: 60: /// - [`.write()`](crate::traits::Write) returns a guard through which the signal
63: 61: ///   can be mutated, and which notifies subscribers when it is dropped.
64: 62: ///
65: 63: /// > Each of these has a related `_untracked()` method, which updates the signal
66: 64: /// > without notifying subscribers. Untracked updates are not desirable in most
67: 65: /// > cases, as they cause “tearing” between the signal’s value and its observed
68: 66: /// > value. If you want a non-reactive container, used [`ArenaItem`] instead.
69: 67: ///
70: 68: /// ## Examples
71: 69: ///
72: 70: /// ```
73: 71: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
74: 72: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
75: 73: /// let count = ArcRwSignal::new(0);
76: 74: ///
77: 75: /// // ✅ calling the getter clones and returns the value
78: 76: /// //    this can be `count()` on nightly
79: 77: /// assert_eq!(count.get(), 0);
80: 78: ///
81: 79: /// // ✅ calling the setter sets the value
82: 80: /// //    this can be `set_count(1)` on nightly
83: 81: /// count.set(1);
84: 82: /// assert_eq!(count.get(), 1);
85: 83: ///
86: 84: /// // ❌ you could call the getter within the setter
87: 85: /// // set_count.set(count.get() + 1);
88: 86: ///
89: 87: /// // ✅ however it's more efficient to use .update() and mutate the value in place
90: 88: /// count.update(|count: &mut i32| *count += 1);
91: 89: /// assert_eq!(count.get(), 2);
92: 90: ///
93: 91: /// // ✅ you can create "derived signals" with a Fn() -> T interface
94: 92: /// let double_count = {
95: 93: ///   // clone before moving into the closure because we use it below
96: 94: ///   let count = count.clone();
97: 95: ///   move || count.get() * 2
98: 96: /// };
99: 97: /// count.set(0);
100: 98: /// assert_eq!(double_count(), 0);
101: 99: /// count.set(1);
102: 100: /// assert_eq!(double_count(), 2);
103: 101: /// ```
104: 102: pub struct RwSignal<T, S = SyncStorage> {
105: 103:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
106: 104:     defined_at: &'static Location<'static>,
107: 105:     inner: ArenaItem<ArcRwSignal<T>, S>,
108: 106: }
109: 107: 
110: 108: impl<T, S> Dispose for RwSignal<T, S> {
111: 109:     fn dispose(self) {
112: 110:         self.inner.dispose()
113: 111:     }
114: 112: }
115: 113: 
116: 114: impl<T> RwSignal<T>
117: 115: where
118: 116:     T: Send + Sync + 'static,
119: 117: {
120: 118:     /// Creates a new signal, taking the initial value as its argument.
121: 119:     #[cfg_attr(
122: 120:         feature = "tracing",
123: 121:         tracing::instrument(level = "trace", skip_all)
124: 122:     )]
125: 123:     #[track_caller]
126: 124:     pub fn new(value: T) -> Self {
127: 125:         Self::new_with_storage(value)
128: 126:     }
129: 127: }
130: 128: 
131: 129: impl<T, S> RwSignal<T, S>
132: 130: where
133: 131:     T: 'static,
134: 132:     S: Storage<ArcRwSignal<T>>,
135: 133: {
136: 134:     /// Creates a new signal with the given arena storage method.
137: 135:     #[cfg_attr(
138: 136:         feature = "tracing",
139: 137:         tracing::instrument(level = "trace", skip_all)
140: 138:     )]
141: 139:     #[track_caller]
142: 140:     pub fn new_with_storage(value: T) -> Self {
143: 141:         Self {
144: 142:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
145: 143:             defined_at: Location::caller(),
146: 144:             inner: ArenaItem::new_with_storage(ArcRwSignal::new(value)),
147: 145:         }
148: 146:     }
149: 147: }
150: 148: 
151: 149: impl<T> RwSignal<T, LocalStorage>
152: 150: where
153: 151:     T: 'static,
154: 152: {
155: 153:     /// Creates a new signal, taking the initial value as its argument. Unlike [`RwSignal::new`],
156: 154:     /// this pins the value to the current thread. Accessing it from any other thread will panic.
157: 155:     #[cfg_attr(
158: 156:         feature = "tracing",
159: 157:         tracing::instrument(level = "trace", skip_all)
160: 158:     )]
161: 159:     #[track_caller]
162: 160:     pub fn new_local(value: T) -> Self {
163: 161:         Self::new_with_storage(value)
164: 162:     }
165: 163: }
166: 164: 
167: 165: impl<T, S> RwSignal<T, S>
168: 166: where
169: 167:     T: 'static,
170: 168:     S: Storage<ArcRwSignal<T>> + Storage<ArcReadSignal<T>>,
171: 169: {
172: 170:     /// Returns a read-only handle to the signal.
173: 171:     #[inline(always)]
174: 172:     #[track_caller]
175: 173:     pub fn read_only(&self) -> ReadSignal<T, S> {
176: 174:         ReadSignal {
177: 175:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
178: 176:             defined_at: Location::caller(),
179: 177:             inner: ArenaItem::new_with_storage(
180: 178:                 self.inner
181: 179:                     .try_get_value()
182: 180:                     .map(|inner| inner.read_only())
183: 181:                     .unwrap_or_else(unwrap_signal!(self)),
184: 182:             ),
185: 183:         }
186: 184:     }
187: 185: }
188: 186: 
189: 187: impl<T, S> RwSignal<T, S>
190: 188: where
191: 189:     T: 'static,
192: 190:     S: Storage<ArcRwSignal<T>> + Storage<ArcWriteSignal<T>>,
193: 191: {
194: 192:     /// Returns a write-only handle to the signal.
195: 193:     #[inline(always)]
196: 194:     #[track_caller]
197: 195:     pub fn write_only(&self) -> WriteSignal<T, S> {
198: 196:         WriteSignal {
199: 197:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
200: 198:             defined_at: Location::caller(),
201: 199:             inner: ArenaItem::new_with_storage(
202: 200:                 self.inner
203: 201:                     .try_get_value()
204: 202:                     .map(|inner| inner.write_only())
205: 203:                     .unwrap_or_else(unwrap_signal!(self)),
206: 204:             ),
207: 205:         }
208: 206:     }
209: 207: }
210: 208: 
211: 209: impl<T, S> RwSignal<T, S>
212: 210: where
213: 211:     T: 'static,
214: 212:     S: Storage<ArcRwSignal<T>>
215: 213:         + Storage<ArcWriteSignal<T>>
216: 214:         + Storage<ArcReadSignal<T>>,
217: 215: {
218: 216:     /// Splits the signal into its readable and writable halves.
219: 217:     #[track_caller]
220: 218:     #[inline(always)]
221: 219:     pub fn split(&self) -> (ReadSignal<T, S>, WriteSignal<T, S>) {
222: 220:         (self.read_only(), self.write_only())
223: 221:     }
224: 222: 
225: 223:     /// Reunites the two halves of a signal. Returns `None` if the two signals
226: 224:     /// provided were not created from the same signal.
227: 225:     #[track_caller]
228: 226:     pub fn unite(
229: 227:         read: ReadSignal<T, S>,
230: 228:         write: WriteSignal<T, S>,
231: 229:     ) -> Option<Self> {
232: 230:         match (read.inner.try_get_value(), write.inner.try_get_value()) {
233: 231:             (Some(read), Some(write)) => {
234: 232:                 if Arc::ptr_eq(&read.inner, &write.inner) {
235: 233:                     Some(Self {
236: 234:                         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
237: 235:                         defined_at: Location::caller(),
238: 236:                         inner: ArenaItem::new_with_storage(ArcRwSignal {
239: 237:                             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
240: 238:                             defined_at: Location::caller(),
241: 239:                             value: Arc::clone(&read.value),
242: 240:                             inner: Arc::clone(&read.inner),
243: 241:                         }),
244: 242:                     })
245: 243:                 } else {
246: 244:                     None
247: 245:                 }
248: 246:             }
249: 247:             _ => None,
250: 248:         }
251: 249:     }
252: 250: }
253: 251: 
254: 252: impl<T, S> Copy for RwSignal<T, S> {}
255: 253: 
256: 254: impl<T, S> Clone for RwSignal<T, S> {
257: 255:     fn clone(&self) -> Self {
258: 256:         *self
259: 257:     }
260: 258: }
261: 259: 
262: 260: impl<T, S> Debug for RwSignal<T, S>
263: 261: where
264: 262:     S: Debug,
265: 263: {
266: 264:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
267: 265:         f.debug_struct("RwSignal")
268: 266:             .field("type", &std::any::type_name::<T>())
269: 267:             .field("store", &self.inner)
270: 268:             .finish()
271: 269:     }
272: 270: }
273: 271: 
274: 272: impl<T, S> Default for RwSignal<T, S>
275: 273: where
276: 274:     T: Default + 'static,
277: 275:     S: Storage<ArcRwSignal<T>>,
278: 276: {
279: 277:     #[track_caller]
280: 278:     fn default() -> Self {
281: 279:         Self::new_with_storage(T::default())
282: 280:     }
283: 281: }
284: 282: 
285: 283: impl<T, S> PartialEq for RwSignal<T, S> {
286: 284:     fn eq(&self, other: &Self) -> bool {
287: 285:         self.inner == other.inner
288: 286:     }
289: 287: }
290: 288: 
291: 289: impl<T, S> Eq for RwSignal<T, S> {}
292: 290: 
293: 291: impl<T, S> Hash for RwSignal<T, S> {
294: 292:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
295: 293:         self.inner.hash(state);
296: 294:     }
297: 295: }
298: 296: 
299: 297: impl<T, S> DefinedAt for RwSignal<T, S> {
300: 298:     fn defined_at(&self) -> Option<&'static Location<'static>> {
301: 299:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
302: 300:         {
303: 301:             Some(self.defined_at)
304: 302:         }
305: 303:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
306: 304:         {
307: 305:             None
308: 306:         }
309: 307:     }
310: 308: }
311: 309: 
312: 310: impl<T: 'static, S> IsDisposed for RwSignal<T, S> {
313: 311:     fn is_disposed(&self) -> bool {
314: 312:         self.inner.is_disposed()
315: 313:     }
316: 314: }
317: 315: 
318: 316: impl<T, S> IntoInner for RwSignal<T, S>
319: 317: where
320: 318:     S: Storage<ArcRwSignal<T>>,
321: 319: {
322: 320:     type Value = T;
323: 321: 
324: 322:     #[inline(always)]
325: 323:     fn into_inner(self) -> Option<Self::Value> {
326: 324:         self.inner.into_inner()?.into_inner()
327: 325:     }
328: 326: }
329: 327: 
330: 328: impl<T, S> AsSubscriberSet for RwSignal<T, S>
331: 329: where
332: 330:     S: Storage<ArcRwSignal<T>>,
333: 331: {
334: 332:     type Output = Arc<RwLock<SubscriberSet>>;
335: 333: 
336: 334:     fn as_subscriber_set(&self) -> Option<Self::Output> {
337: 335:         self.inner
338: 336:             .try_with_value(|inner| inner.as_subscriber_set())
339: 337:             .flatten()
340: 338:     }
341: 339: }
342: 340: 
343: 341: impl<T, S> ReadUntracked for RwSignal<T, S>
344: 342: where
345: 343:     T: 'static,
346: 344:     S: Storage<ArcRwSignal<T>>,
347: 345: {
348: 346:     type Value = ReadGuard<T, Plain<T>>;
349: 347: 
350: 348:     fn try_read_untracked(&self) -> Option<Self::Value> {
351: 349:         self.inner
352: 350:             .try_get_value()
353: 351:             .map(|inner| inner.read_untracked())
354: 352:     }
355: 353: }
356: 354: 
357: 355: impl<T, S> Notify for RwSignal<T, S>
358: 356: where
359: 357:     S: Storage<ArcRwSignal<T>>,
360: 358: {
361: 359:     fn notify(&self) {
362: 360:         self.mark_dirty();
363: 361:     }
364: 362: }
365: 363: 
366: 364: impl<T, S> Write for RwSignal<T, S>
367: 365: where
368: 366:     T: 'static,
369: 367:     S: Storage<ArcRwSignal<T>>,
370: 368: {
371: 369:     type Value = T;
372: 370: 
373: 371:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
374: 372:         let guard = self.inner.try_with_value(|n| {
375: 373:             ArcRwLockWriteGuardian::take(Arc::clone(&n.value)).ok()
376: 374:         })??;
377: 375:         Some(WriteGuard::new(*self, guard))
378: 376:     }
379: 377: 
380: 378:     #[allow(refining_impl_trait)]
381: 379:     fn try_write_untracked(&self) -> Option<UntrackedWriteGuard<Self::Value>> {
382: 380:         self.inner
383: 381:             .try_with_value(|n| n.try_write_untracked())
384: 382:             .flatten()
385: 383:     }
386: 384: }
387: 385: 
388: 386: impl<T> From<ArcRwSignal<T>> for RwSignal<T>
389: 387: where
390: 388:     T: Send + Sync + 'static,
391: 389: {
392: 390:     #[track_caller]
393: 391:     fn from(value: ArcRwSignal<T>) -> Self {
394: 392:         RwSignal {
395: 393:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
396: 394:             defined_at: Location::caller(),
397: 395:             inner: ArenaItem::new_with_storage(value),
398: 396:         }
399: 397:     }
400: 398: }
401: 399: 
402: 400: impl<'a, T> From<&'a ArcRwSignal<T>> for RwSignal<T>
403: 401: where
404: 402:     T: Send + Sync + 'static,
405: 403: {
406: 404:     #[track_caller]
407: 405:     fn from(value: &'a ArcRwSignal<T>) -> Self {
408: 406:         value.clone().into()
409: 407:     }
410: 408: }
411: 409: 
412: 410: impl<T> FromLocal<ArcRwSignal<T>> for RwSignal<T, LocalStorage>
413: 411: where
414: 412:     T: 'static,
415: 413: {
416: 414:     #[track_caller]
417: 415:     fn from_local(value: ArcRwSignal<T>) -> Self {
418: 416:         RwSignal {
419: 417:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
420: 418:             defined_at: Location::caller(),
421: 419:             inner: ArenaItem::new_with_storage(value),
422: 420:         }
423: 421:     }
424: 422: }
425: 423: 
426: 424: impl<T, S> From<RwSignal<T, S>> for ArcRwSignal<T>
427: 425: where
428: 426:     T: 'static,
429: 427:     S: Storage<ArcRwSignal<T>>,
430: 428: {
431: 429:     #[track_caller]
432: 430:     fn from(value: RwSignal<T, S>) -> Self {
433: 431:         value
434: 432:             .inner
435: 433:             .try_get_value()
436: 434:             .unwrap_or_else(unwrap_signal!(value))
437: 435:     }
438: 436: }
439: ```
```
