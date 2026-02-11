### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\write.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\write.rs
2: ```rust
3: 1: use super::{guards::WriteGuard, ArcWriteSignal};
4: 2: use crate::{
5: 3:     owner::{ArenaItem, FromLocal, LocalStorage, Storage, SyncStorage},
6: 4:     traits::{
7: 5:         DefinedAt, Dispose, IntoInner, IsDisposed, Notify, UntrackableGuard,
8: 6:         Write,
9: 7:     },
10: 8: };
11: 9: use core::fmt::Debug;
12: 10: use guardian::ArcRwLockWriteGuardian;
13: 11: use std::{hash::Hash, ops::DerefMut, panic::Location, sync::Arc};
14: 12: 
15: 13: /// An arena-allocated setter for a reactive signal.
16: 14: ///
17: 15: /// A signal is a piece of data that may change over time,
18: 16: /// and notifies other code when it has changed.
19: 17: ///
20: 18: /// This is an arena-allocated signal, which is `Copy` and is disposed when its reactive
21: 19: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted signal that lives
22: 20: /// as long as a reference to it is alive, see [`ArcWriteSignal`].
23: 21: ///
24: 22: /// ## Core Trait Implementations
25: 23: /// - [`.set()`](crate::traits::Set) sets the signal to a new value.
26: 24: /// - [`.update()`](crate::traits::Update) updates the value of the signal by
27: 25: ///   lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a closure that takes a mutable reference.
28: 26: /// - [`.write()`](crate::traits::Write) returns a guard through which the signal
29: 27: ///   can be mutated, and which notifies subscribers when it is dropped.
30: 28: ///
31: 29: /// > Each of these has a related `_untracked()` method, which updates the signal
32: 30: /// > without notifying subscribers. Untracked updates are not desirable in most
33: 31: /// > cases, as they cause “tearing” between the signal’s value and its observed
34: 32: /// > value. If you want a non-reactive container, use [`ArenaItem`] instead.
35: 33: ///
36: 34: /// ## Examples
37: 35: /// ```
38: 36: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*;  let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
39: 37: /// let (count, set_count) = signal(0);
40: 38: ///
41: 39: /// // ✅ calling the setter sets the value
42: 40: /// //    `set_count(1)` on nightly
43: 41: /// set_count.set(1);
44: 42: /// assert_eq!(count.get(), 1);
45: 43: ///
46: 44: /// // ❌ you could call the getter within the setter
47: 45: /// // set_count.set(count.get() + 1);
48: 46: ///
49: 47: /// // ✅ however it's more efficient to use .update() and mutate the value in place
50: 48: /// set_count.update(|count: &mut i32| *count += 1);
51: 49: /// assert_eq!(count.get(), 2);
52: 50: ///
53: 51: /// // ✅ `.write()` returns a guard that implements `DerefMut` and will notify when dropped
54: 52: /// *set_count.write() += 1;
55: 53: /// assert_eq!(count.get(), 3);
56: 54: /// ```
57: 55: pub struct WriteSignal<T, S = SyncStorage> {
58: 56:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
59: 57:     pub(crate) defined_at: &'static Location<'static>,
60: 58:     pub(crate) inner: ArenaItem<ArcWriteSignal<T>, S>,
61: 59: }
62: 60: 
63: 61: impl<T, S> Dispose for WriteSignal<T, S> {
64: 62:     fn dispose(self) {
65: 63:         self.inner.dispose()
66: 64:     }
67: 65: }
68: 66: 
69: 67: impl<T, S> Copy for WriteSignal<T, S> {}
70: 68: 
71: 69: impl<T, S> Clone for WriteSignal<T, S> {
72: 70:     fn clone(&self) -> Self {
73: 71:         *self
74: 72:     }
75: 73: }
76: 74: 
77: 75: impl<T, S> Debug for WriteSignal<T, S>
78: 76: where
79: 77:     S: Debug,
80: 78: {
81: 79:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
82: 80:         f.debug_struct("WriteSignal")
83: 81:             .field("type", &std::any::type_name::<T>())
84: 82:             .field("store", &self.inner)
85: 83:             .finish()
86: 84:     }
87: 85: }
88: 86: 
89: 87: impl<T, S> PartialEq for WriteSignal<T, S> {
90: 88:     fn eq(&self, other: &Self) -> bool {
91: 89:         self.inner == other.inner
92: 90:     }
93: 91: }
94: 92: 
95: 93: impl<T, S> Eq for WriteSignal<T, S> {}
96: 94: 
97: 95: impl<T, S> Hash for WriteSignal<T, S> {
98: 96:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
99: 97:         self.inner.hash(state);
100: 98:     }
101: 99: }
102: 100: 
103: 101: impl<T, S> DefinedAt for WriteSignal<T, S> {
104: 102:     fn defined_at(&self) -> Option<&'static Location<'static>> {
105: 103:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
106: 104:         {
107: 105:             Some(self.defined_at)
108: 106:         }
109: 107:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
110: 108:         {
111: 109:             None
112: 110:         }
113: 111:     }
114: 112: }
115: 113: 
116: 114: impl<T> From<ArcWriteSignal<T>> for WriteSignal<T>
117: 115: where
118: 116:     T: Send + Sync + 'static,
119: 117: {
120: 118:     #[track_caller]
121: 119:     fn from(value: ArcWriteSignal<T>) -> Self {
122: 120:         WriteSignal {
123: 121:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
124: 122:             defined_at: Location::caller(),
125: 123:             inner: ArenaItem::new_with_storage(value),
126: 124:         }
127: 125:     }
128: 126: }
129: 127: 
130: 128: impl<T> FromLocal<ArcWriteSignal<T>> for WriteSignal<T, LocalStorage>
131: 129: where
132: 130:     T: 'static,
133: 131: {
134: 132:     #[track_caller]
135: 133:     fn from_local(value: ArcWriteSignal<T>) -> Self {
136: 134:         WriteSignal {
137: 135:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
138: 136:             defined_at: Location::caller(),
139: 137:             inner: ArenaItem::new_with_storage(value),
140: 138:         }
141: 139:     }
142: 140: }
143: 141: 
144: 142: impl<T, S> IsDisposed for WriteSignal<T, S> {
145: 143:     fn is_disposed(&self) -> bool {
146: 144:         self.inner.is_disposed()
147: 145:     }
148: 146: }
149: 147: 
150: 148: impl<T, S> IntoInner for WriteSignal<T, S>
151: 149: where
152: 150:     S: Storage<ArcWriteSignal<T>>,
153: 151: {
154: 152:     type Value = T;
155: 153: 
156: 154:     #[inline(always)]
157: 155:     fn into_inner(self) -> Option<Self::Value> {
158: 156:         self.inner.into_inner()?.into_inner()
159: 157:     }
160: 158: }
161: 159: 
162: 160: impl<T, S> Notify for WriteSignal<T, S>
163: 161: where
164: 162:     T: 'static,
165: 163:     S: Storage<ArcWriteSignal<T>>,
166: 164: {
167: 165:     fn notify(&self) {
168: 166:         if let Some(inner) = self.inner.try_get_value() {
169: 167:             inner.notify();
170: 168:         }
171: 169:     }
172: 170: }
173: 171: 
174: 172: impl<T, S> Write for WriteSignal<T, S>
175: 173: where
176: 174:     T: 'static,
177: 175:     S: Storage<ArcWriteSignal<T>>,
178: 176: {
179: 177:     type Value = T;
180: 178: 
181: 179:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
182: 180:         let guard = self.inner.try_with_value(|n| {
183: 181:             ArcRwLockWriteGuardian::take(Arc::clone(&n.value)).ok()
184: 182:         })??;
185: 183:         Some(WriteGuard::new(*self, guard))
186: 184:     }
187: 185: 
188: 186:     fn try_write_untracked(
189: 187:         &self,
190: 188:     ) -> Option<impl DerefMut<Target = Self::Value>> {
191: 189:         self.inner
192: 190:             .try_with_value(|n| n.try_write_untracked())
193: 191:             .flatten()
194: 192:     }
195: 193: }
196: ```
```
