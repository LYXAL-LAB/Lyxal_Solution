### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\memo.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\memo.rs
2: ```rust
3: 1: use super::ArcMemo;
4: 2: use crate::{
5: 3:     owner::{ArenaItem, FromLocal, LocalStorage, Storage, SyncStorage},
6: 4:     signal::{
7: 5:         guards::{Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Plain, ReadGuard},
8: 6:         ArcReadSignal,
9: 7:     },
10: 8:     traits::{DefinedAt, Dispose, Get, ReadUntracked, Track},
11: 9:     unwrap_signal,
12: 10: };
13: 11: use std::{fmt::Debug, hash::Hash, panic::Location};
14: 12: 
15: 13: /// A memo is an efficient derived reactive value based on other reactive values.
16: 14: ///
17: 15: /// Unlike a "derived signal," a memo comes with two guarantees:
18: 16: /// 1. The memo will only run *once* per change, no matter how many times you
19: 17: ///    access its value.
20: 18: /// 2. The memo will only notify its dependents if the value of the computation changes.
21: 19: ///
22: 20: /// This makes a memo the perfect tool for expensive computations.
23: 21: ///
24: 22: /// Memos have a certain overhead compared to derived signals. In most cases, you should
25: 23: /// create a derived signal. But if the derivation calculation is expensive, you should
26: 24: /// create a memo.
27: 25: ///
28: 26: /// Memos are lazy: they do not run at all until they are read for the first time, and they will
29: 27: /// not re-run the calculation when a source signal changes until they are read again.
30: 28: ///
31: 29: /// This is an arena-allocated type, which is `Copy` and is disposed when its reactive
32: 30: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted signal that lives as
33: 31: /// as long as a reference to it is alive, see [`ArcMemo`].
34: 32: ///
35: 33: /// ```
36: 34: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
37: 35: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::Memo;
38: 36: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
39: 37: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::signal;
40: 38: /// # tokio_test::block_on(async move {
41: 39: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
42: 40: /// # tokio::task::LocalSet::new().run_until(async {
43: 41: /// # fn really_expensive_computation(value: i32) -> i32 { value };
44: 42: /// let (value, set_value) = signal(0);
45: 43: ///
46: 44: /// // 🆗 we could create a derived signal with a simple function
47: 45: /// let double_value = move || value.get() * 2;
48: 46: /// set_value.set(2);
49: 47: /// assert_eq!(double_value(), 4);
50: 48: ///
51: 49: /// // but imagine the computation is really expensive
52: 50: /// let expensive = move || really_expensive_computation(value.get()); // lazy: doesn't run until called
53: 51: /// Effect::new(move |_| {
54: 52: ///   // 🆗 run #1: calls `really_expensive_computation` the first time
55: 53: ///   println!("expensive = {}", expensive());
56: 54: /// });
57: 55: /// Effect::new(move |_| {
58: 56: ///   // ❌ run #2: this calls `really_expensive_computation` a second time!
59: 57: ///   let value = expensive();
60: 58: ///   // do something else...
61: 59: /// });
62: 60: ///
63: 61: /// // instead, we create a memo
64: 62: /// // 🆗 run #1: the calculation runs once immediately
65: 63: /// let memoized = Memo::new(move |_| really_expensive_computation(value.get()));
66: 64: /// Effect::new(move |_| {
67: 65: ///   // 🆗 reads the current value of the memo
68: 66: ///   //    can be `memoized()` on nightly
69: 67: ///   println!("memoized = {}", memoized.get());
70: 68: /// });
71: 69: /// Effect::new(move |_| {
72: 70: ///   // ✅ reads the current value **without re-running the calculation**
73: 71: ///   let value = memoized.get();
74: 72: ///   // do something else...
75: 73: /// });
76: 74: /// # });
77: 75: /// # });
78: 76: /// ```
79: 77: ///
80: 78: /// ## Core Trait Implementations
81: 79: /// - [`.get()`](crate::traits::Get) clones the current value of the memo.
82: 80: ///   If you call it within an effect, it will cause that effect to subscribe
83: 81: ///   to the memo, and to re-run whenever the value of the memo changes.
84: 82: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
85: 83: ///     the memo without reactively tracking it.
86: 84: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
87: 85: ///   value of the memo by reference. If you call it within an effect, it will
88: 86: ///   cause that effect to subscribe to the memo, and to re-run whenever the
89: 87: ///   value of the memo changes.
90: 88: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
91: 89: ///     current value of the memo without reactively tracking it.
92: 90: /// - [`.with()`](crate::traits::With) allows you to reactively access the memo’s
93: 91: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
94: 92: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
95: 93: ///     the memo’s value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
96: 94: ///     tracking it.
97: 95: /// - [`.to_stream()`](crate::traits::ToStream) converts the memo to an `async`
98: 96: ///   stream of values.
99: 97: /// - [`::from_stream()`](crate::traits::FromStream) converts an `async` stream
100: 98: ///   of values into a memo containing the latest value.
101: 99: pub struct Memo<T, S = SyncStorage>
102: 100: where
103: 101:     S: Storage<T>,
104: 102: {
105: 103:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
106: 104:     defined_at: &'static Location<'static>,
107: 105:     inner: ArenaItem<ArcMemo<T, S>, S>,
108: 106: }
109: 107: 
110: 108: impl<T, S> Dispose for Memo<T, S>
111: 109: where
112: 110:     S: Storage<T>,
113: 111: {
114: 112:     fn dispose(self) {
115: 113:         self.inner.dispose()
116: 114:     }
117: 115: }
118: 116: 
119: 117: impl<T> From<ArcMemo<T, SyncStorage>> for Memo<T>
120: 118: where
121: 119:     T: Send + Sync + 'static,
122: 120: {
123: 121:     #[track_caller]
124: 122:     fn from(value: ArcMemo<T, SyncStorage>) -> Self {
125: 123:         Self {
126: 124:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
127: 125:             defined_at: Location::caller(),
128: 126:             inner: ArenaItem::new_with_storage(value),
129: 127:         }
130: 128:     }
131: 129: }
132: 130: 
133: 131: impl<T> FromLocal<ArcMemo<T, LocalStorage>> for Memo<T, LocalStorage>
134: 132: where
135: 133:     T: 'static,
136: 134: {
137: 135:     #[track_caller]
138: 136:     fn from_local(value: ArcMemo<T, LocalStorage>) -> Self {
139: 137:         Self {
140: 138:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
141: 139:             defined_at: Location::caller(),
142: 140:             inner: ArenaItem::new_with_storage(value),
143: 141:         }
144: 142:     }
145: 143: }
146: 144: 
147: 145: impl<T> Memo<T>
148: 146: where
149: 147:     T: Send + Sync + 'static,
150: 148: {
151: 149:     #[track_caller]
152: 150:     #[cfg_attr(
153: 151:         feature = "tracing",
154: 152:         tracing::instrument(level = "debug", skip_all)
155: 153:     )]
156: 154:     /// Creates a new memoized, computed reactive value.
157: 155:     ///
158: 156:     /// As with an [`Effect`](crate::effect::Effect), the argument to the memo function is the previous value,
159: 157:     /// i.e., the current value of the memo, which will be `None` for the initial calculation.
160: 158:     /// ```
161: 159:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
162: 160:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::Memo;
163: 161:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
164: 162:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::signal;
165: 163:     /// # tokio_test::block_on(async move {
166: 164:     /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio(); let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
167: 165:     /// # fn really_expensive_computation(value: i32) -> i32 { value };
168: 166:     /// let (value, set_value) = signal(0);
169: 167:     ///
170: 168:     /// // the memo will reactively update whenever `value` changes
171: 169:     /// let memoized =
172: 170:     ///     Memo::new(move |_| really_expensive_computation(value.get()));
173: 171:     /// # });
174: 172:     /// ```
175: 173:     pub fn new(fun: impl Fn(Option<&T>) -> T + Send + Sync + 'static) -> Self
176: 174:     where
177: 175:         T: PartialEq,
178: 176:     {
179: 177:         Self {
180: 178:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
181: 179:             defined_at: Location::caller(),
182: 180:             inner: ArenaItem::new_with_storage(ArcMemo::new(fun)),
183: 181:         }
184: 182:     }
185: 183: 
186: 184:     #[track_caller]
187: 185:     #[cfg_attr(
188: 186:         feature = "tracing",
189: 187:         tracing::instrument(level = "trace", skip_all)
190: 188:     )]
191: 189:     /// Creates a new memo with a custom comparison function. By default, memos simply use
192: 190:     /// [`PartialEq`] to compare the previous value to the new value. Passing a custom comparator
193: 191:     /// allows you to compare the old and new values using any criteria.
194: 192:     ///
195: 193:     /// `changed` should be a function that returns `true` if the new value is different from the
196: 194:     /// old value.
197: 195:     pub fn new_with_compare(
198: 196:         fun: impl Fn(Option<&T>) -> T + Send + Sync + 'static,
199: 197:         changed: fn(Option<&T>, Option<&T>) -> bool,
200: 198:     ) -> Self {
201: 199:         Self {
202: 200:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
203: 201:             defined_at: Location::caller(),
204: 202:             inner: ArenaItem::new_with_storage(ArcMemo::new_with_compare(
205: 203:                 fun, changed,
206: 204:             )),
207: 205:         }
208: 206:     }
209: 207: 
210: 208:     /// Creates a new memo by passing a function that computes the value.
211: 209:     ///
212: 210:     /// Unlike [`Memo::new`](), this receives ownership of the previous value. As a result, it
213: 211:     /// must return both the new value and a `bool` that is `true` if the value has changed.
214: 212:     ///
215: 213:     /// This is lazy: the function will not be called until the memo's value is read for the first
216: 214:     /// time.
217: 215:     #[track_caller]
218: 216:     #[cfg_attr(
219: 217:         feature = "tracing",
220: 218:         tracing::instrument(level = "trace", skip_all)
221: 219:     )]
222: 220:     pub fn new_owning(
223: 221:         fun: impl Fn(Option<T>) -> (T, bool) + Send + Sync + 'static,
224: 222:     ) -> Self {
225: 223:         Self {
226: 224:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
227: 225:             defined_at: Location::caller(),
228: 226:             inner: ArenaItem::new_with_storage(ArcMemo::new_owning(fun)),
229: 227:         }
230: 228:     }
231: 229: }
232: 230: 
233: 231: impl<T, S> Copy for Memo<T, S> where S: Storage<T> {}
234: 232: 
235: 233: impl<T, S> Clone for Memo<T, S>
236: 234: where
237: 235:     S: Storage<T>,
238: 236: {
239: 237:     fn clone(&self) -> Self {
240: 238:         *self
241: 239:     }
242: 240: }
243: 241: 
244: 242: impl<T, S> Debug for Memo<T, S>
245: 243: where
246: 244:     S: Debug + Storage<T>,
247: 245: {
248: 246:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
249: 247:         f.debug_struct("Memo")
250: 248:             .field("type", &std::any::type_name::<T>())
251: 249:             .field("store", &self.inner)
252: 250:             .finish()
253: 251:     }
254: 252: }
255: 253: 
256: 254: impl<T, S> PartialEq for Memo<T, S>
257: 255: where
258: 256:     S: Storage<T>,
259: 257: {
260: 258:     fn eq(&self, other: &Self) -> bool {
261: 259:         self.inner == other.inner
262: 260:     }
263: 261: }
264: 262: 
265: 263: impl<T, S> Eq for Memo<T, S> where S: Storage<T> {}
266: 264: 
267: 265: impl<T, S> Hash for Memo<T, S>
268: 266: where
269: 267:     S: Storage<T>,
270: 268: {
271: 269:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
272: 270:         self.inner.hash(state);
273: 271:     }
274: 272: }
275: 273: 
276: 274: impl<T, S> DefinedAt for Memo<T, S>
277: 275: where
278: 276:     S: Storage<T>,
279: 277: {
280: 278:     fn defined_at(&self) -> Option<&'static Location<'static>> {
281: 279:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
282: 280:         {
283: 281:             Some(self.defined_at)
284: 282:         }
285: 283:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
286: 284:         {
287: 285:             None
288: 286:         }
289: 287:     }
290: 288: }
291: 289: 
292: 290: impl<T, S> Track for Memo<T, S>
293: 291: where
294: 292:     T: 'static,
295: 293:     S: Storage<ArcMemo<T, S>> + Storage<T>,
296: 294:     ArcMemo<T, S>: Track,
297: 295: {
298: 296:     #[track_caller]
299: 297:     fn track(&self) {
300: 298:         if let Some(inner) = self.inner.try_get_value() {
301: 299:             inner.track();
302: 300:         }
303: 301:     }
304: 302: }
305: 303: 
306: 304: impl<T, S> ReadUntracked for Memo<T, S>
307: 305: where
308: 306:     T: 'static,
309: 307:     S: Storage<ArcMemo<T, S>> + Storage<T>,
310: 308: {
311: 309:     type Value =
312: 310:         ReadGuard<T, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Plain<Option<<S as Storage<T>>::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped>>, T>>;
313: 311: 
314: 312:     fn try_read_untracked(&self) -> Option<Self::Value> {
315: 313:         self.inner
316: 314:             .try_get_value()
317: 315:             .map(|inner| inner.read_untracked())
318: 316:     }
319: 317: }
320: 318: 
321: 319: impl<T, S> From<Memo<T, S>> for ArcMemo<T, S>
322: 320: where
323: 321:     T: 'static,
324: 322:     S: Storage<ArcMemo<T, S>> + Storage<T>,
325: 323: {
326: 324:     #[track_caller]
327: 325:     fn from(value: Memo<T, S>) -> Self {
328: 326:         value
329: 327:             .inner
330: 328:             .try_get_value()
331: 329:             .unwrap_or_else(unwrap_signal!(value))
332: 330:     }
333: 331: }
334: 332: 
335: 333: impl<T> From<ArcReadSignal<T>> for Memo<T>
336: 334: where
337: 335:     T: Clone + PartialEq + Send + Sync + 'static,
338: 336: {
339: 337:     #[track_caller]
340: 338:     fn from(value: ArcReadSignal<T>) -> Self {
341: 339:         Memo::new(move |_| value.get())
342: 340:     }
343: 341: }
344: ```
```
