### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\arc_read.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\arc_read.rs
2: ```rust
3: 1: use super::{
4: 2:     guards::{Plain, ReadGuard},
5: 3:     subscriber_traits::AsSubscriberSet,
6: 4: };
7: 5: use crate::{
8: 6:     graph::SubscriberSet,
9: 7:     traits::{DefinedAt, IntoInner, IsDisposed, ReadUntracked},
10: 8: };
11: 9: use core::fmt::{Debug, Formatter, Result};
12: 10: use std::{
13: 11:     hash::Hash,
14: 12:     panic::Location,
15: 13:     sync::{Arc, RwLock},
16: 14: };
17: 15: 
18: 16: /// A reference-counted getter for a reactive signal.
19: 17: ///
20: 18: /// A signal is a piece of data that may change over time,
21: 19: /// and notifies other code when it has changed.
22: 20: ///
23: 21: /// This is a reference-counted signal, which is `Clone` but not `Copy`.
24: 22: /// For arena-allocated `Copy` signals, use [`ReadSignal`](super::ReadSignal).
25: 23: ///
26: 24: /// ## Core Trait Implementations
27: 25: /// - [`.get()`](crate::traits::Get) clones the current value of the signal.
28: 26: ///   If you call it within an effect, it will cause that effect to subscribe
29: 27: ///   to the signal, and to re-run whenever the value of the signal changes.
30: 28: ///   - [`.get_untracked()`](crate::traits::GetUntracked) clones the value of
31: 29: ///     the signal without reactively tracking it.
32: 30: /// - [`.read()`](crate::traits::Read) returns a guard that allows accessing the
33: 31: ///   value of the signal by reference. If you call it within an effect, it will
34: 32: ///   cause that effect to subscribe to the signal, and to re-run whenever the
35: 33: ///   value of the signal changes.
36: 34: ///   - [`.read_untracked()`](crate::traits::ReadUntracked) gives access to the
37: 35: ///     current value of the signal without reactively tracking it.
38: 36: /// - [`.with()`](crate::traits::With) allows you to reactively access the signal’s
39: 37: ///   value without cloning by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function.
40: 38: ///   - [`.with_untracked()`](crate::traits::WithUntracked) allows you to access
41: 39: ///     the signal’s value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a callback function without reactively
42: 40: ///     tracking it.
43: 41: /// - [`.to_stream()`](crate::traits::ToStream) converts the signal to an `async`
44: 42: ///   stream of values.
45: 43: /// - [`::from_stream()`](crate::traits::FromStream) converts an `async` stream
46: 44: ///   of values into a signal containing the latest value.
47: 45: ///
48: 46: /// ## Examples
49: 47: /// ```
50: 48: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*;
51: 49: /// let (count, set_count) = arc_signal(0);
52: 50: ///
53: 51: /// // calling .get() clones and returns the value
54: 52: /// assert_eq!(count.get(), 0);
55: 53: /// // calling .read() accesses the value by reference
56: 54: /// assert_eq!(count.read(), 0);
57: 55: /// ```
58: 56: pub struct ArcReadSignal<T> {
59: 57:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
60: 58:     pub(crate) defined_at: &'static Location<'static>,
61: 59:     pub(crate) value: Arc<RwLock<T>>,
62: 60:     pub(crate) inner: Arc<RwLock<SubscriberSet>>,
63: 61: }
64: 62: 
65: 63: impl<T> Clone for ArcReadSignal<T> {
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
77: 75: impl<T> Debug for ArcReadSignal<T> {
78: 76:     fn fmt(&self, f: &mut Formatter<'_>) -> Result {
79: 77:         f.debug_struct("ArcReadSignal")
80: 78:             .field("type", &std::any::type_name::<T>())
81: 79:             .field("value", &Arc::as_ptr(&self.value))
82: 80:             .finish()
83: 81:     }
84: 82: }
85: 83: 
86: 84: impl<T: Default> Default for ArcReadSignal<T> {
87: 85:     #[track_caller]
88: 86:     fn default() -> Self {
89: 87:         Self {
90: 88:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
91: 89:             defined_at: Location::caller(),
92: 90:             value: Arc::new(RwLock::new(T::default())),
93: 91:             inner: Arc::new(RwLock::new(SubscriberSet::new())),
94: 92:         }
95: 93:     }
96: 94: }
97: 95: 
98: 96: impl<T> PartialEq for ArcReadSignal<T> {
99: 97:     fn eq(&self, other: &Self) -> bool {
100: 98:         Arc::ptr_eq(&self.value, &other.value)
101: 99:     }
102: 100: }
103: 101: 
104: 102: impl<T> Eq for ArcReadSignal<T> {}
105: 103: 
106: 104: impl<T> Hash for ArcReadSignal<T> {
107: 105:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
108: 106:         std::ptr::hash(&Arc::as_ptr(&self.value), state);
109: 107:     }
110: 108: }
111: 109: 
112: 110: impl<T> DefinedAt for ArcReadSignal<T> {
113: 111:     #[inline(always)]
114: 112:     fn defined_at(&self) -> Option<&'static Location<'static>> {
115: 113:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
116: 114:         {
117: 115:             Some(self.defined_at)
118: 116:         }
119: 117:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
120: 118:         {
121: 119:             None
122: 120:         }
123: 121:     }
124: 122: }
125: 123: 
126: 124: impl<T> IsDisposed for ArcReadSignal<T> {
127: 125:     #[inline(always)]
128: 126:     fn is_disposed(&self) -> bool {
129: 127:         false
130: 128:     }
131: 129: }
132: 130: 
133: 131: impl<T> IntoInner for ArcReadSignal<T> {
134: 132:     type Value = T;
135: 133: 
136: 134:     #[inline(always)]
137: 135:     fn into_inner(self) -> Option<Self::Value> {
138: 136:         Some(Arc::into_inner(self.value)?.into_inner().unwrap())
139: 137:     }
140: 138: }
141: 139: 
142: 140: impl<T> AsSubscriberSet for ArcReadSignal<T> {
143: 141:     type Output = Arc<RwLock<SubscriberSet>>;
144: 142: 
145: 143:     #[inline(always)]
146: 144:     fn as_subscriber_set(&self) -> Option<Self::Output> {
147: 145:         Some(Arc::clone(&self.inner))
148: 146:     }
149: 147: }
150: 148: 
151: 149: impl<T: 'static> ReadUntracked for ArcReadSignal<T> {
152: 150:     type Value = ReadGuard<T, Plain<T>>;
153: 151: 
154: 152:     #[track_caller]
155: 153:     fn try_read_untracked(&self) -> Option<Self::Value> {
156: 154:         Plain::try_new(Arc::clone(&self.value)).map(ReadGuard::new)
157: 155:     }
158: 156: }
159: ```
```
