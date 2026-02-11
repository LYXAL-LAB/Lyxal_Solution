### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\arc_write.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\arc_write.rs
2: ```rust
3: 1: use super::guards::{UntrackedWriteGuard, WriteGuard};
4: 2: use crate::{
5: 3:     graph::{ReactiveNode, SubscriberSet},
6: 4:     prelude::{IsDisposed, Notify},
7: 5:     traits::{DefinedAt, IntoInner, UntrackableGuard, Write},
8: 6: };
9: 7: use core::fmt::{Debug, Formatter, Result};
10: 8: use std::{
11: 9:     hash::Hash,
12: 10:     panic::Location,
13: 11:     sync::{Arc, RwLock},
14: 12: };
15: 13: 
16: 14: /// A reference-counted setter for a reactive signal.
17: 15: ///
18: 16: /// A signal is a piece of data that may change over time,
19: 17: /// and notifies other code when it has changed.
20: 18: ///
21: 19: /// This is a reference-counted signal, which is `Clone` but not `Copy`.
22: 20: /// For arena-allocated `Copy` signals, use [`WriteSignal`](super::WriteSignal).
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
34: 32: /// > value. If you want a non-reactive container, used [`ArenaItem`](crate::owner::ArenaItem)
35: 33: /// > instead.
36: 34: ///
37: 35: /// ## Examples
38: 36: /// ```
39: 37: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*;
40: 38: /// let (count, set_count) = arc_signal(0);
41: 39: ///
42: 40: /// // ✅ calling the setter sets the value
43: 41: /// //    `set_count(1)` on nightly
44: 42: /// set_count.set(1);
45: 43: /// assert_eq!(count.get(), 1);
46: 44: ///
47: 45: /// // ❌ you could call the getter within the setter
48: 46: /// // set_count.set(count.get() + 1);
49: 47: ///
50: 48: /// // ✅ however it's more efficient to use .update() and mutate the value in place
51: 49: /// set_count.update(|count: &mut i32| *count += 1);
52: 50: /// assert_eq!(count.get(), 2);
53: 51: ///
54: 52: /// // ✅ `.write()` returns a guard that implements `DerefMut` and will notify when dropped
55: 53: /// *set_count.write() += 1;
56: 54: /// assert_eq!(count.get(), 3);
57: 55: /// ```
58: 56: pub struct ArcWriteSignal<T> {
59: 57:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
60: 58:     pub(crate) defined_at: &'static Location<'static>,
61: 59:     pub(crate) value: Arc<RwLock<T>>,
62: 60:     pub(crate) inner: Arc<RwLock<SubscriberSet>>,
63: 61: }
64: 62: 
65: 63: impl<T> Clone for ArcWriteSignal<T> {
66: 64:     #[track_caller]
67: 65:     fn clone(&self) -> Self {
68: 66:         Self {
69: 67:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
70: 68:             defined_at: self.defined_at,
71: 69:             value: Arc::clone(&self.value),
72: 70:             inner: Arc::clone(&self.inner),
73: 71:         }
74: 72:     }
75: 73: }
76: 74: 
77: 75: impl<T> Debug for ArcWriteSignal<T> {
78: 76:     fn fmt(&self, f: &mut Formatter<'_>) -> Result {
79: 77:         f.debug_struct("ArcWriteSignal")
80: 78:             .field("type", &std::any::type_name::<T>())
81: 79:             .field("value", &Arc::as_ptr(&self.value))
82: 80:             .finish()
83: 81:     }
84: 82: }
85: 83: 
86: 84: impl<T> PartialEq for ArcWriteSignal<T> {
87: 85:     fn eq(&self, other: &Self) -> bool {
88: 86:         Arc::ptr_eq(&self.value, &other.value)
89: 87:     }
90: 88: }
91: 89: 
92: 90: impl<T> Eq for ArcWriteSignal<T> {}
93: 91: 
94: 92: impl<T> Hash for ArcWriteSignal<T> {
95: 93:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
96: 94:         std::ptr::hash(&Arc::as_ptr(&self.value), state);
97: 95:     }
98: 96: }
99: 97: 
100: 98: impl<T> DefinedAt for ArcWriteSignal<T> {
101: 99:     #[inline(always)]
102: 100:     fn defined_at(&self) -> Option<&'static Location<'static>> {
103: 101:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
104: 102:         {
105: 103:             Some(self.defined_at)
106: 104:         }
107: 105:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
108: 106:         {
109: 107:             None
110: 108:         }
111: 109:     }
112: 110: }
113: 111: 
114: 112: impl<T> IsDisposed for ArcWriteSignal<T> {
115: 113:     #[inline(always)]
116: 114:     fn is_disposed(&self) -> bool {
117: 115:         false
118: 116:     }
119: 117: }
120: 118: 
121: 119: impl<T> IntoInner for ArcWriteSignal<T> {
122: 120:     type Value = T;
123: 121: 
124: 122:     #[inline(always)]
125: 123:     fn into_inner(self) -> Option<Self::Value> {
126: 124:         Some(Arc::into_inner(self.value)?.into_inner().unwrap())
127: 125:     }
128: 126: }
129: 127: 
130: 128: impl<T> Notify for ArcWriteSignal<T> {
131: 129:     fn notify(&self) {
132: 130:         self.inner.mark_dirty();
133: 131:     }
134: 132: }
135: 133: 
136: 134: impl<T: 'static> Write for ArcWriteSignal<T> {
137: 135:     type Value = T;
138: 136: 
139: 137:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
140: 138:         self.value
141: 139:             .write()
142: 140:             .ok()
143: 141:             .map(|guard| WriteGuard::new(self.clone(), guard))
144: 142:     }
145: 143: 
146: 144:     #[allow(refining_impl_trait)]
147: 145:     fn try_write_untracked(&self) -> Option<UntrackedWriteGuard<Self::Value>> {
148: 146:         UntrackedWriteGuard::try_new(Arc::clone(&self.value))
149: 147:     }
150: 148: }
151: ```
```
