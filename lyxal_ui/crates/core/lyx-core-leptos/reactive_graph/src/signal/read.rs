### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\read.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\read.rs
2: ```rust
3: 1: use super::{
4: 2:     guards::{Plain, ReadGuard},
5: 3:     subscriber_traits::AsSubscriberSet,
6: 4:     ArcReadSignal,
7: 5: };
8: 6: use crate::{
9: 7:     graph::SubscriberSet,
10: 8:     owner::{ArenaItem, FromLocal, LocalStorage, Storage, SyncStorage},
11: 9:     traits::{DefinedAt, Dispose, IntoInner, IsDisposed, ReadUntracked},
12: 10:     unwrap_signal,
13: 11: };
14: 12: use core::fmt::Debug;
15: 13: use std::{
16: 14:     hash::Hash,
17: 15:     panic::Location,
18: 16:     sync::{Arc, RwLock},
19: 17: };
20: 18: 
21: 19: /// An arena-allocated getter for a reactive signal.
22: 20: ///
23: 21: /// A signal is a piece of data that may change over time,
24: 22: /// and notifies other code when it has changed.
25: 23: ///
26: 24: /// This is an arena-allocated signal, which is `Copy` and is disposed when its reactive
27: 25: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted signal that lives
28: 26: /// as long as a reference to it is alive, see [`ArcReadSignal`].
29: 27: ///
30: 28: /// ## Core Trait Implementations
31: 29: /// - [`.get()`](crate::traits::Get) clones the current value of the signal.
32: 30: ///   If you call it within an effect, it will cause that effect to subscribe
33: 31: ///   to the signal, and to re-run whenever the value of the signal changes.
34: 32: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
35: 33: ///     the signal without reactively tracking it.
36: 34: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
37: 35: ///   value of the signal by reference. If you call it within an effect, it will
38: 36: ///   cause that effect to subscribe to the signal, and to re-run whenever the
39: 37: ///   value of the signal changes.
40: 38: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
41: 39: ///     current value of the signal without reactively tracking it.
42: 40: /// - [`.with()`](crate::traits::With) allows you to reactively access the signal’s
43: 41: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
44: 42: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
45: 43: ///     the signal’s value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
46: 44: ///     tracking it.
47: 45: /// - [`.to_stream()`](crate::traits::ToStream) converts the signal to an `async`
48: 46: ///   stream of values.
49: 47: /// - [`::from_stream()`](crate::traits::FromStream) converts an `async` stream
50: 48: ///   of values into a signal containing the latest value.
51: 49: ///
52: 50: /// ## Examples
53: 51: /// ```
54: 52: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*;  let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
55: 53: /// let (count, set_count) = signal(0);
56: 54: ///
57: 55: /// // calling .get() clones and returns the value
58: 56: /// assert_eq!(count.get(), 0);
59: 57: /// // calling .read() accesses the value by reference
60: 58: /// assert_eq!(count.read(), 0);
61: 59: /// ```
62: 60: pub struct ReadSignal<T, S = SyncStorage> {
63: 61:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
64: 62:     pub(crate) defined_at: &'static Location<'static>,
65: 63:     pub(crate) inner: ArenaItem<ArcReadSignal<T>, S>,
66: 64: }
67: 65: 
68: 66: impl<T, S> Dispose for ReadSignal<T, S> {
69: 67:     fn dispose(self) {
70: 68:         self.inner.dispose()
71: 69:     }
72: 70: }
73: 71: 
74: 72: impl<T, S> Copy for ReadSignal<T, S> {}
75: 73: 
76: 74: impl<T, S> Clone for ReadSignal<T, S> {
77: 75:     fn clone(&self) -> Self {
78: 76:         *self
79: 77:     }
80: 78: }
81: 79: 
82: 80: impl<T, S> Debug for ReadSignal<T, S>
83: 81: where
84: 82:     S: Debug,
85: 83: {
86: 84:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
87: 85:         f.debug_struct("ReadSignal")
88: 86:             .field("type", &std::any::type_name::<T>())
89: 87:             .field("store", &self.inner)
90: 88:             .finish()
91: 89:     }
92: 90: }
93: 91: 
94: 92: impl<T, S> PartialEq for ReadSignal<T, S> {
95: 93:     fn eq(&self, other: &Self) -> bool {
96: 94:         self.inner == other.inner
97: 95:     }
98: 96: }
99: 97: 
100: 98: impl<T, S> Eq for ReadSignal<T, S> {}
101: 99: 
102: 100: impl<T, S> Hash for ReadSignal<T, S> {
103: 101:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
104: 102:         self.inner.hash(state);
105: 103:     }
106: 104: }
107: 105: 
108: 106: impl<T, S> DefinedAt for ReadSignal<T, S> {
109: 107:     fn defined_at(&self) -> Option<&'static Location<'static>> {
110: 108:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
111: 109:         {
112: 110:             Some(self.defined_at)
113: 111:         }
114: 112:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
115: 113:         {
116: 114:             None
117: 115:         }
118: 116:     }
119: 117: }
120: 118: 
121: 119: impl<T, S> IsDisposed for ReadSignal<T, S> {
122: 120:     fn is_disposed(&self) -> bool {
123: 121:         self.inner.is_disposed()
124: 122:     }
125: 123: }
126: 124: 
127: 125: impl<T, S> IntoInner for ReadSignal<T, S>
128: 126: where
129: 127:     S: Storage<ArcReadSignal<T>>,
130: 128: {
131: 129:     type Value = T;
132: 130: 
133: 131:     #[inline(always)]
134: 132:     fn into_inner(self) -> Option<Self::Value> {
135: 133:         self.inner.into_inner()?.into_inner()
136: 134:     }
137: 135: }
138: 136: 
139: 137: impl<T, S> AsSubscriberSet for ReadSignal<T, S>
140: 138: where
141: 139:     S: Storage<ArcReadSignal<T>>,
142: 140: {
143: 141:     type Output = Arc<RwLock<SubscriberSet>>;
144: 142: 
145: 143:     fn as_subscriber_set(&self) -> Option<Self::Output> {
146: 144:         self.inner
147: 145:             .try_with_value(|inner| inner.as_subscriber_set())
148: 146:             .flatten()
149: 147:     }
150: 148: }
151: 149: 
152: 150: impl<T, S> ReadUntracked for ReadSignal<T, S>
153: 151: where
154: 152:     T: 'static,
155: 153:     S: Storage<ArcReadSignal<T>>,
156: 154: {
157: 155:     type Value = ReadGuard<T, Plain<T>>;
158: 156: 
159: 157:     fn try_read_untracked(&self) -> Option<Self::Value> {
160: 158:         self.inner
161: 159:             .try_get_value()
162: 160:             .map(|inner| inner.read_untracked())
163: 161:     }
164: 162: }
165: 163: 
166: 164: impl<T> From<ArcReadSignal<T>> for ReadSignal<T>
167: 165: where
168: 166:     T: Send + Sync + 'static,
169: 167: {
170: 168:     #[track_caller]
171: 169:     fn from(value: ArcReadSignal<T>) -> Self {
172: 170:         ReadSignal {
173: 171:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
174: 172:             defined_at: Location::caller(),
175: 173:             inner: ArenaItem::new_with_storage(value),
176: 174:         }
177: 175:     }
178: 176: }
179: 177: 
180: 178: impl<T> FromLocal<ArcReadSignal<T>> for ReadSignal<T, LocalStorage>
181: 179: where
182: 180:     T: 'static,
183: 181: {
184: 182:     #[track_caller]
185: 183:     fn from_local(value: ArcReadSignal<T>) -> Self {
186: 184:         ReadSignal {
187: 185:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
188: 186:             defined_at: Location::caller(),
189: 187:             inner: ArenaItem::new_with_storage(value),
190: 188:         }
191: 189:     }
192: 190: }
193: 191: 
194: 192: impl<T, S> From<ReadSignal<T, S>> for ArcReadSignal<T>
195: 193: where
196: 194:     T: 'static,
197: 195:     S: Storage<ArcReadSignal<T>>,
198: 196: {
199: 197:     #[track_caller]
200: 198:     fn from(value: ReadSignal<T, S>) -> Self {
201: 199:         value
202: 200:             .inner
203: 201:             .try_get_value()
204: 202:             .unwrap_or_else(unwrap_signal!(value))
205: 203:     }
206: 204: }
207: ```
```
