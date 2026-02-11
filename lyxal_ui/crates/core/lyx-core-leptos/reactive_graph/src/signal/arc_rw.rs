### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\arc_rw.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\arc_rw.rs
2: ```rust
3: 1: use super::{
4: 2:     guards::{Plain, ReadGuard, UntrackedWriteGuard, WriteGuard},
5: 3:     subscriber_traits::AsSubscriberSet,
6: 4:     ArcReadSignal, ArcWriteSignal,
7: 5: };
8: 6: use crate::{
9: 7:     graph::{ReactiveNode, SubscriberSet},
10: 8:     prelude::{IsDisposed, Notify},
11: 9:     traits::{DefinedAt, IntoInner, ReadUntracked, UntrackableGuard, Write},
12: 10: };
13: 11: use core::fmt::{Debug, Formatter, Result};
14: 12: use std::{
15: 13:     hash::Hash,
16: 14:     panic::Location,
17: 15:     sync::{Arc, RwLock},
18: 16: };
19: 17: 
20: 18: /// A reference-counted signal that can be read from or written to.
21: 19: ///
22: 20: /// A signal is a piece of data that may change over time, and notifies other
23: 21: /// code when it has changed. This is the atomic unit of reactivity, which begins all other
24: 22: /// processes of reactive updates.
25: 23: ///
26: 24: /// This is a reference-counted signal, which is `Clone` but not `Copy`.
27: 25: /// For arena-allocated `Copy` signals, use [`RwSignal`](super::RwSignal).
28: 26: ///
29: 27: /// ## Core Trait Implementations
30: 28: ///
31: 29: /// ### Reading the Value
32: 30: /// - [`.get()`](crate::traits::Get) clones the current value of the signal.
33: 31: ///   If you call it within an effect, it will cause that effect to subscribe
34: 32: ///   to the signal, and to re-run whenever the value of the signal changes.
35: 33: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
36: 34: ///     the signal without reactively tracking it.
37: 35: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
38: 36: ///   value of the signal by reference. If you call it within an effect, it will
39: 37: ///   cause that effect to subscribe to the signal, and to re-run whenever the
40: 38: ///   value of the signal changes.
41: 39: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
42: 40: ///     current value of the signal without reactively tracking it.
43: 41: /// - [`.with()`](crate::traits::With) allows you to reactively access the signal’s
44: 42: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
45: 43: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
46: 44: ///     the signal’s value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
47: 45: ///     tracking it.
48: 46: /// - [`.to_stream()`](crate::traits::ToStream) converts the signal to an `async`
49: 47: ///   stream of values.
50: 48: ///
51: 49: /// ### Updating the Value
52: 50: /// - [`.set()`](crate::traits::Set) sets the signal to a new value.
53: 51: /// - [`.update()`](crate::traits::Update) updates the value of the signal by
54: 52: ///   lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a closure that takes a mutable reference.
55: 53: /// - [`.write()`](crate::traits::Write) returns a guard through which the signal
56: 54: ///   can be mutated, and which notifies subscribers when it is dropped.
57: 55: ///
58: 56: /// > Each of these has a related `_untracked()` method, which updates the signal
59: 57: /// > without notifying subscribers. Untracked updates are not desirable in most
60: 58: /// > cases, as they cause “tearing” between the signal’s value and its observed
61: 59: /// > value. If you want a non-reactive container, used [`ArenaItem`](crate::owner::ArenaItem)
62: 60: /// > instead.
63: 61: ///
64: 62: /// ## Examples
65: 63: ///
66: 64: /// ```
67: 65: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
68: 66: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
69: 67: /// let count = ArcRwSignal::new(0);
70: 68: ///
71: 69: /// // ✅ calling the getter clones and returns the value
72: 70: /// //    this can be `count()` on nightly
73: 71: /// assert_eq!(count.get(), 0);
74: 72: ///
75: 73: /// // ✅ calling the setter sets the value
76: 74: /// //    this can be `set_count(1)` on nightly
77: 75: /// count.set(1);
78: 76: /// assert_eq!(count.get(), 1);
79: 77: ///
80: 78: /// // ❌ you could call the getter within the setter
81: 79: /// // set_count.set(count.get() + 1);
82: 80: ///
83: 81: /// // ✅ however it's more efficient to use .update() and mutate the value in place
84: 82: /// count.update(|count: &mut i32| *count += 1);
85: 83: /// assert_eq!(count.get(), 2);
86: 84: ///
87: 85: /// // ✅ you can create "derived signals" with a Fn() -> T interface
88: 86: /// let double_count = {
89: 87: ///   // clone before moving into the closure because we use it below
90: 88: ///   let count = count.clone();
91: 89: ///   move || count.get() * 2
92: 90: /// };
93: 91: /// count.set(0);
94: 92: /// assert_eq!(double_count(), 0);
95: 93: /// count.set(1);
96: 94: /// assert_eq!(double_count(), 2);
97: 95: /// ```
98: 96: pub struct ArcRwSignal<T> {
99: 97:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
100: 98:     pub(crate) defined_at: &'static Location<'static>,
101: 99:     pub(crate) value: Arc<RwLock<T>>,
102: 100:     pub(crate) inner: Arc<RwLock<SubscriberSet>>,
103: 101: }
104: 102: 
105: 103: impl<T> Clone for ArcRwSignal<T> {
106: 104:     #[track_caller]
107: 105:     fn clone(&self) -> Self {
108: 106:         Self {
109: 107:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
110: 108:             defined_at: self.defined_at,
111: 109:             value: Arc::clone(&self.value),
112: 110:             inner: Arc::clone(&self.inner),
113: 111:         }
114: 112:     }
115: 113: }
116: 114: 
117: 115: impl<T> Debug for ArcRwSignal<T> {
118: 116:     fn fmt(&self, f: &mut Formatter<'_>) -> Result {
119: 117:         f.debug_struct("ArcRwSignal")
120: 118:             .field("type", &std::any::type_name::<T>())
121: 119:             .field("value", &Arc::as_ptr(&self.value))
122: 120:             .finish()
123: 121:     }
124: 122: }
125: 123: 
126: 124: impl<T> PartialEq for ArcRwSignal<T> {
127: 125:     fn eq(&self, other: &Self) -> bool {
128: 126:         Arc::ptr_eq(&self.value, &other.value)
129: 127:     }
130: 128: }
131: 129: 
132: 130: impl<T> Eq for ArcRwSignal<T> {}
133: 131: 
134: 132: impl<T> Hash for ArcRwSignal<T> {
135: 133:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
136: 134:         std::ptr::hash(&Arc::as_ptr(&self.value), state);
137: 135:     }
138: 136: }
139: 137: 
140: 138: impl<T> Default for ArcRwSignal<T>
141: 139: where
142: 140:     T: Default,
143: 141: {
144: 142:     #[track_caller]
145: 143:     fn default() -> Self {
146: 144:         Self::new(T::default())
147: 145:     }
148: 146: }
149: 147: 
150: 148: impl<T> ArcRwSignal<T> {
151: 149:     /// Creates a new signal, taking the initial value as its argument.
152: 150:     #[cfg_attr(
153: 151:         feature = "tracing",
154: 152:         tracing::instrument(level = "trace", skip_all)
155: 153:     )]
156: 154:     #[track_caller]
157: 155:     pub fn new(value: T) -> Self {
158: 156:         Self {
159: 157:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
160: 158:             defined_at: Location::caller(),
161: 159:             value: Arc::new(RwLock::new(value)),
162: 160:             inner: Arc::new(RwLock::new(SubscriberSet::new())),
163: 161:         }
164: 162:     }
165: 163: 
166: 164:     /// Returns a read-only handle to the signal.
167: 165:     #[track_caller]
168: 166:     pub fn read_only(&self) -> ArcReadSignal<T> {
169: 167:         ArcReadSignal {
170: 168:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
171: 169:             defined_at: Location::caller(),
172: 170:             value: Arc::clone(&self.value),
173: 171:             inner: Arc::clone(&self.inner),
174: 172:         }
175: 173:     }
176: 174: 
177: 175:     /// Returns a write-only handle to the signal.
178: 176:     #[track_caller]
179: 177:     pub fn write_only(&self) -> ArcWriteSignal<T> {
180: 178:         ArcWriteSignal {
181: 179:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
182: 180:             defined_at: Location::caller(),
183: 181:             value: Arc::clone(&self.value),
184: 182:             inner: Arc::clone(&self.inner),
185: 183:         }
186: 184:     }
187: 185: 
188: 186:     /// Splits the signal into its readable and writable halves.
189: 187:     #[track_caller]
190: 188:     pub fn split(&self) -> (ArcReadSignal<T>, ArcWriteSignal<T>) {
191: 189:         (self.read_only(), self.write_only())
192: 190:     }
193: 191: 
194: 192:     /// Reunites the two halves of a signal. Returns `None` if the two signals
195: 193:     /// provided were not created from the same signal.
196: 194:     #[track_caller]
197: 195:     pub fn unite(
198: 196:         read: ArcReadSignal<T>,
199: 197:         write: ArcWriteSignal<T>,
200: 198:     ) -> Option<Self> {
201: 199:         if Arc::ptr_eq(&read.inner, &write.inner) {
202: 200:             Some(Self {
203: 201:                 #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
204: 202:                 defined_at: Location::caller(),
205: 203:                 value: read.value,
206: 204:                 inner: read.inner,
207: 205:             })
208: 206:         } else {
209: 207:             None
210: 208:         }
211: 209:     }
212: 210: }
213: 211: 
214: 212: impl<T> DefinedAt for ArcRwSignal<T> {
215: 213:     #[inline(always)]
216: 214:     fn defined_at(&self) -> Option<&'static Location<'static>> {
217: 215:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
218: 216:         {
219: 217:             Some(self.defined_at)
220: 218:         }
221: 219:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
222: 220:         {
223: 221:             None
224: 222:         }
225: 223:     }
226: 224: }
227: 225: 
228: 226: impl<T> IsDisposed for ArcRwSignal<T> {
229: 227:     #[inline(always)]
230: 228:     fn is_disposed(&self) -> bool {
231: 229:         false
232: 230:     }
233: 231: }
234: 232: 
235: 233: impl<T> IntoInner for ArcRwSignal<T> {
236: 234:     type Value = T;
237: 235: 
238: 236:     #[inline(always)]
239: 237:     fn into_inner(self) -> Option<Self::Value> {
240: 238:         Some(Arc::into_inner(self.value)?.into_inner().unwrap())
241: 239:     }
242: 240: }
243: 241: 
244: 242: impl<T> AsSubscriberSet for ArcRwSignal<T> {
245: 243:     type Output = Arc<RwLock<SubscriberSet>>;
246: 244: 
247: 245:     #[inline(always)]
248: 246:     fn as_subscriber_set(&self) -> Option<Self::Output> {
249: 247:         Some(Arc::clone(&self.inner))
250: 248:     }
251: 249: }
252: 250: 
253: 251: impl<T: 'static> ReadUntracked for ArcRwSignal<T> {
254: 252:     type Value = ReadGuard<T, Plain<T>>;
255: 253: 
256: 254:     fn try_read_untracked(&self) -> Option<Self::Value> {
257: 255:         Plain::try_new(Arc::clone(&self.value)).map(ReadGuard::new)
258: 256:     }
259: 257: }
260: 258: 
261: 259: impl<T> Notify for ArcRwSignal<T> {
262: 260:     fn notify(&self) {
263: 261:         self.mark_dirty();
264: 262:     }
265: 263: }
266: 264: 
267: 265: impl<T: 'static> Write for ArcRwSignal<T> {
268: 266:     type Value = T;
269: 267: 
270: 268:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
271: 269:         self.value
272: 270:             .write()
273: 271:             .ok()
274: 272:             .map(|guard| WriteGuard::new(self.clone(), guard))
275: 273:     }
276: 274: 
277: 275:     #[allow(refining_impl_trait)]
278: 276:     fn try_write_untracked(&self) -> Option<UntrackedWriteGuard<Self::Value>> {
279: 277:         UntrackedWriteGuard::try_new(Arc::clone(&self.value))
280: 278:     }
281: 279: }
282: ```
```
