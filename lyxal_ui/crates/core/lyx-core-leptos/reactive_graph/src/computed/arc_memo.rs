### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\arc_memo.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\arc_memo.rs
2: ```rust
3: 1: use super::inner::MemoInner;
4: 2: use crate::{
5: 3:     graph::{
6: 4:         AnySource, AnySubscriber, ReactiveNode, Source, Subscriber,
7: 5:         ToAnySource, ToAnySubscriber,
8: 6:     },
9: 7:     owner::{Storage, StorageAccess, SyncStorage},
10: 8:     signal::{
11: 9:         guards::{Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Plain, ReadGuard},
12: 10:         ArcReadSignal, ArcRwSignal,
13: 11:     },
14: 12:     traits::{DefinedAt, Get, IsDisposed, ReadUntracked},
15: 13: };
16: 14: use core::fmt::Debug;
17: 15: use std::{
18: 16:     hash::Hash,
19: 17:     panic::Location,
20: 18:     sync::{Arc, Weak},
21: 19: };
22: 20: 
23: 21: /// An efficient derived reactive value based on other reactive values.
24: 22: ///
25: 23: /// This is a reference-counted memo, which is `Clone` but not `Copy`.
26: 24: /// For arena-allocated `Copy` memos, use [`Memo`](super::Memo).
27: 25: ///
28: 26: /// Unlike a "derived signal," a memo comes with two guarantees:
29: 27: /// 1. The memo will only run *once* per change, no matter how many times you
30: 28: ///    access its value.
31: 29: /// 2. The memo will only notify its dependents if the value of the computation changes.
32: 30: ///
33: 31: /// This makes a memo the perfect tool for expensive computations.
34: 32: ///
35: 33: /// Memos have a certain overhead compared to derived signals. In most cases, you should
36: 34: /// create a derived signal. But if the derivation calculation is expensive, you should
37: 35: /// create a memo.
38: 36: ///
39: 37: /// As with an [`Effect`](crate::effect::Effect), the argument to the memo function is the previous value,
40: 38: /// i.e., the current value of the memo, which will be `None` for the initial calculation.
41: 39: ///
42: 40: /// ## Examples
43: 41: /// ```
44: 42: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
45: 43: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
46: 44: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::signal;
47: 45: /// # fn really_expensive_computation(value: i32) -> i32 { value };
48: 46: /// let (value, set_value) = signal(0);
49: 47: ///
50: 48: /// // 🆗 we could create a derived signal with a simple function
51: 49: /// let double_value = move || value.get() * 2;
52: 50: /// set_value.set(2);
53: 51: /// assert_eq!(double_value(), 4);
54: 52: ///
55: 53: /// // but imagine the computation is really expensive
56: 54: /// let expensive = move || really_expensive_computation(value.get()); // lazy: doesn't run until called
57: 55: /// // 🆗 run #1: calls `really_expensive_computation` the first time
58: 56: /// println!("expensive = {}", expensive());
59: 57: /// // ❌ run #2: this calls `really_expensive_computation` a second time!
60: 58: /// let some_value = expensive();
61: 59: ///
62: 60: /// // instead, we create a memo
63: 61: /// // 🆗 run #1: the calculation runs once immediately
64: 62: /// let memoized = ArcMemo::new(move |_| really_expensive_computation(value.get()));
65: 63: /// // 🆗 reads the current value of the memo
66: 64: /// //    can be `memoized()` on nightly
67: 65: /// println!("memoized = {}", memoized.get());
68: 66: /// // ✅ reads the current value **without re-running the calculation**
69: 67: /// let some_value = memoized.get();
70: 68: /// ```
71: 69: ///
72: 70: /// ## Core Trait Implementations
73: 71: /// - [`.get()`](crate::traits::Get) clones the current value of the memo.
74: 72: ///   If you call it within an effect, it will cause that effect to subscribe
75: 73: ///   to the memo, and to re-run whenever the value of the memo changes.
76: 74: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
77: 75: ///     the memo without reactively tracking it.
78: 76: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
79: 77: ///   value of the memo by reference. If you call it within an effect, it will
80: 78: ///   cause that effect to subscribe to the memo, and to re-run whenever the
81: 79: ///   value of the memo changes.
82: 80: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
83: 81: ///     current value of the memo without reactively tracking it.
84: 82: /// - [`.with()`](crate::traits::With) allows you to reactively access the memo’s
85: 83: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
86: 84: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
87: 85: ///     the memo’s value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
88: 86: ///     tracking it.
89: 87: /// - [`.to_stream()`](crate::traits::ToStream) converts the memo to an `async`
90: 88: ///   stream of values.
91: 89: /// - [`::from_stream()`](crate::traits::FromStream) converts an `async` stream
92: 90: ///   of values into a memo containing the latest value.
93: 91: pub struct ArcMemo<T, S = SyncStorage>
94: 92: where
95: 93:     S: Storage<T>,
96: 94: {
97: 95:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
98: 96:     defined_at: &'static Location<'static>,
99: 97:     inner: Arc<MemoInner<T, S>>,
100: 98: }
101: 99: 
102: 100: impl<T: 'static> ArcMemo<T, SyncStorage>
103: 101: where
104: 102:     SyncStorage: Storage<T>,
105: 103: {
106: 104:     /// Creates a new memo by passing a function that computes the value.
107: 105:     ///
108: 106:     /// This is lazy: the function will not be called until the memo's value is read for the first
109: 107:     /// time.
110: 108:     #[track_caller]
111: 109:     #[cfg_attr(
112: 110:         feature = "tracing",
113: 111:         tracing::instrument(level = "trace", skip_all)
114: 112:     )]
115: 113:     pub fn new(fun: impl Fn(Option<&T>) -> T + Send + Sync + 'static) -> Self
116: 114:     where
117: 115:         T: PartialEq,
118: 116:     {
119: 117:         Self::new_with_compare(fun, |lhs, rhs| lhs.as_ref() != rhs.as_ref())
120: 118:     }
121: 119: 
122: 120:     /// Creates a new memo by passing a function that computes the value, and a comparison function
123: 121:     /// that takes the previous value and the new value and returns `true` if the value has
124: 122:     /// changed.
125: 123:     ///
126: 124:     /// This is lazy: the function will not be called until the memo's value is read for the first
127: 125:     /// time.
128: 126:     #[track_caller]
129: 127:     #[cfg_attr(
130: 128:         feature = "tracing",
131: 129:         tracing::instrument(level = "trace", skip_all)
132: 130:     )]
133: 131:     pub fn new_with_compare(
134: 132:         fun: impl Fn(Option<&T>) -> T + Send + Sync + 'static,
135: 133:         changed: fn(Option<&T>, Option<&T>) -> bool,
136: 134:     ) -> Self {
137: 135:         Self::new_owning(move |prev: Option<T>| {
138: 136:             let new_value = fun(prev.as_ref());
139: 137:             let changed = changed(prev.as_ref(), Some(&new_value));
140: 138:             (new_value, changed)
141: 139:         })
142: 140:     }
143: 141: 
144: 142:     /// Creates a new memo by passing a function that computes the value.
145: 143:     ///
146: 144:     /// Unlike [`ArcMemo::new`](), this receives ownership of the previous value. As a result, it
147: 145:     /// must return both the new value and a `bool` that is `true` if the value has changed.
148: 146:     ///
149: 147:     /// This is lazy: the function will not be called until the memo's value is read for the first
150: 148:     /// time.
151: 149:     #[track_caller]
152: 150:     #[cfg_attr(
153: 151:         feature = "tracing",
154: 152:         tracing::instrument(level = "trace", skip_all)
155: 153:     )]
156: 154:     pub fn new_owning(
157: 155:         fun: impl Fn(Option<T>) -> (T, bool) + Send + Sync + 'static,
158: 156:     ) -> Self {
159: 157:         let inner = Arc::new_cyclic(|weak| {
160: 158:             let subscriber = AnySubscriber(
161: 159:                 weak.as_ptr() as usize,
162: 160:                 Weak::clone(weak) as Weak<dyn Subscriber + Send + Sync>,
163: 161:             );
164: 162: 
165: 163:             MemoInner::new(Arc::new(fun), subscriber)
166: 164:         });
167: 165:         Self {
168: 166:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
169: 167:             defined_at: Location::caller(),
170: 168:             inner,
171: 169:         }
172: 170:     }
173: 171: }
174: 172: 
175: 173: impl<T, S> Clone for ArcMemo<T, S>
176: 174: where
177: 175:     S: Storage<T>,
178: 176: {
179: 177:     fn clone(&self) -> Self {
180: 178:         Self {
181: 179:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
182: 180:             defined_at: self.defined_at,
183: 181:             inner: Arc::clone(&self.inner),
184: 182:         }
185: 183:     }
186: 184: }
187: 185: 
188: 186: impl<T, S> DefinedAt for ArcMemo<T, S>
189: 187: where
190: 188:     S: Storage<T>,
191: 189: {
192: 190:     #[inline(always)]
193: 191:     fn defined_at(&self) -> Option<&'static Location<'static>> {
194: 192:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
195: 193:         {
196: 194:             Some(self.defined_at)
197: 195:         }
198: 196:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
199: 197:         {
200: 198:             None
201: 199:         }
202: 200:     }
203: 201: }
204: 202: 
205: 203: impl<T, S> Debug for ArcMemo<T, S>
206: 204: where
207: 205:     S: Storage<T>,
208: 206: {
209: 207:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
210: 208:         f.debug_struct("ArcMemo")
211: 209:             .field("type", &std::any::type_name::<T>())
212: 210:             .field("data", &Arc::as_ptr(&self.inner))
213: 211:             .finish()
214: 212:     }
215: 213: }
216: 214: 
217: 215: impl<T, S> PartialEq for ArcMemo<T, S>
218: 216: where
219: 217:     S: Storage<T>,
220: 218: {
221: 219:     fn eq(&self, other: &Self) -> bool {
222: 220:         Arc::ptr_eq(&self.inner, &other.inner)
223: 221:     }
224: 222: }
225: 223: 
226: 224: impl<T, S> Eq for ArcMemo<T, S> where S: Storage<T> {}
227: 225: 
228: 226: impl<T, S> Hash for ArcMemo<T, S>
229: 227: where
230: 228:     S: Storage<T>,
231: 229: {
232: 230:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
233: 231:         std::ptr::hash(&Arc::as_ptr(&self.inner), state);
234: 232:     }
235: 233: }
236: 234: 
237: 235: impl<T: 'static, S> ReactiveNode for ArcMemo<T, S>
238: 236: where
239: 237:     S: Storage<T>,
240: 238: {
241: 239:     fn mark_dirty(&self) {
242: 240:         self.inner.mark_dirty();
243: 241:     }
244: 242: 
245: 243:     fn mark_check(&self) {
246: 244:         self.inner.mark_check();
247: 245:     }
248: 246: 
249: 247:     fn mark_subscribers_check(&self) {
250: 248:         self.inner.mark_subscribers_check();
251: 249:     }
252: 250: 
253: 251:     fn update_if_necessary(&self) -> bool {
254: 252:         self.inner.update_if_necessary()
255: 253:     }
256: 254: }
257: 255: 
258: 256: impl<T: 'static, S> IsDisposed for ArcMemo<T, S>
259: 257: where
260: 258:     S: Storage<T>,
261: 259: {
262: 260:     #[inline(always)]
263: 261:     fn is_disposed(&self) -> bool {
264: 262:         false
265: 263:     }
266: 264: }
267: 265: 
268: 266: impl<T: 'static, S> ToAnySource for ArcMemo<T, S>
269: 267: where
270: 268:     S: Storage<T>,
271: 269: {
272: 270:     fn to_any_source(&self) -> AnySource {
273: 271:         AnySource(
274: 272:             Arc::as_ptr(&self.inner) as usize,
275: 273:             Arc::downgrade(&self.inner) as Weak<dyn Source + Send + Sync>,
276: 274:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
277: 275:             self.defined_at,
278: 276:         )
279: 277:     }
280: 278: }
281: 279: 
282: 280: impl<T: 'static, S> Source for ArcMemo<T, S>
283: 281: where
284: 282:     S: Storage<T>,
285: 283: {
286: 284:     fn add_subscriber(&self, subscriber: AnySubscriber) {
287: 285:         self.inner.add_subscriber(subscriber);
288: 286:     }
289: 287: 
290: 288:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
291: 289:         self.inner.remove_subscriber(subscriber);
292: 290:     }
293: 291: 
294: 292:     fn clear_subscribers(&self) {
295: 293:         self.inner.clear_subscribers();
296: 294:     }
297: 295: }
298: 296: 
299: 297: impl<T: 'static, S> ToAnySubscriber for ArcMemo<T, S>
300: 298: where
301: 299:     S: Storage<T>,
302: 300: {
303: 301:     fn to_any_subscriber(&self) -> AnySubscriber {
304: 302:         AnySubscriber(
305: 303:             Arc::as_ptr(&self.inner) as usize,
306: 304:             Arc::downgrade(&self.inner) as Weak<dyn Subscriber + Send + Sync>,
307: 305:         )
308: 306:     }
309: 307: }
310: 308: 
311: 309: impl<T: 'static, S> Subscriber for ArcMemo<T, S>
312: 310: where
313: 311:     S: Storage<T>,
314: 312: {
315: 313:     fn add_source(&self, source: AnySource) {
316: 314:         self.inner.add_source(source);
317: 315:     }
318: 316: 
319: 317:     fn clear_sources(&self, subscriber: &AnySubscriber) {
320: 318:         self.inner.clear_sources(subscriber);
321: 319:     }
322: 320: }
323: 321: 
324: 322: impl<T: 'static, S> ReadUntracked for ArcMemo<T, S>
325: 323: where
326: 324:     S: Storage<T>,
327: 325: {
328: 326:     type Value = ReadGuard<T, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Plain<Option<S::Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped>>, T>>;
329: 327: 
330: 328:     fn try_read_untracked(&self) -> Option<Self::Value> {
331: 329:         self.update_if_necessary();
332: 330: 
333: 331:         Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::try_new(Arc::clone(&self.inner.value), |t| {
334: 332:             // safe to unwrap here because update_if_necessary
335: 333:             // guarantees the value is Some
336: 334:             t.as_ref().unwrap().as_borrowed()
337: 335:         })
338: 336:         .map(ReadGuard::new)
339: 337:     }
340: 338: }
341: 339: 
342: 340: impl<T> From<ArcReadSignal<T>> for ArcMemo<T, SyncStorage>
343: 341: where
344: 342:     T: Clone + PartialEq + Send + Sync + 'static,
345: 343: {
346: 344:     #[track_caller]
347: 345:     fn from(value: ArcReadSignal<T>) -> Self {
348: 346:         ArcMemo::new(move |_| value.get())
349: 347:     }
350: 348: }
351: 349: 
352: 350: impl<T> From<ArcRwSignal<T>> for ArcMemo<T, SyncStorage>
353: 351: where
354: 352:     T: Clone + PartialEq + Send + Sync + 'static,
355: 353: {
356: 354:     #[track_caller]
357: 355:     fn from(value: ArcRwSignal<T>) -> Self {
358: 356:         ArcMemo::new(move |_| value.get())
359: 357:     }
360: 358: }
361: ```
```
