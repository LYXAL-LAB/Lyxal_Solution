### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\owner\arc_stored_value.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\owner\arc_stored_value.rs
2: ```rust
3: 1: use crate::{
4: 2:     signal::guards::{Plain, ReadGuard, UntrackedWriteGuard},
5: 3:     traits::{DefinedAt, IntoInner, IsDisposed, ReadValue, WriteValue},
6: 4: };
7: 5: use std::{
8: 6:     fmt::{Debug, Formatter},
9: 7:     hash::Hash,
10: 8:     panic::Location,
11: 9:     sync::{Arc, RwLock},
12: 10: };
13: 11: 
14: 12: /// A reference-counted getter for any value non-reactively.
15: 13: ///
16: 14: /// This is a reference-counted value, which is `Clone` but not `Copy`.
17: 15: /// For arena-allocated `Copy` values, use [`StoredValue`](super::StoredValue).
18: 16: ///
19: 17: /// This allows you to create a stable reference for any value by storing it within
20: 18: /// the reactive system. Unlike e.g. [`ArcRwSignal`](crate::signal::ArcRwSignal), it is not reactive;
21: 19: /// accessing it does not cause effects to subscribe, and
22: 20: /// updating it does not notify anything else.
23: 21: pub struct ArcStoredValue<T> {
24: 22:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
25: 23:     defined_at: &'static Location<'static>,
26: 24:     value: Arc<RwLock<T>>,
27: 25: }
28: 26: 
29: 27: impl<T> Clone for ArcStoredValue<T> {
30: 28:     fn clone(&self) -> Self {
31: 29:         Self {
32: 30:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
33: 31:             defined_at: self.defined_at,
34: 32:             value: Arc::clone(&self.value),
35: 33:         }
36: 34:     }
37: 35: }
38: 36: 
39: 37: impl<T> Debug for ArcStoredValue<T> {
40: 38:     fn fmt(&self, f: &mut Formatter<'_>) -> core::fmt::Result {
41: 39:         f.debug_struct("ArcStoredValue")
42: 40:             .field("type", &std::any::type_name::<T>())
43: 41:             .field("value", &Arc::as_ptr(&self.value))
44: 42:             .finish()
45: 43:     }
46: 44: }
47: 45: 
48: 46: impl<T: Default> Default for ArcStoredValue<T> {
49: 47:     #[track_caller]
50: 48:     fn default() -> Self {
51: 49:         Self {
52: 50:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
53: 51:             defined_at: Location::caller(),
54: 52:             value: Arc::new(RwLock::new(T::default())),
55: 53:         }
56: 54:     }
57: 55: }
58: 56: 
59: 57: impl<T> PartialEq for ArcStoredValue<T> {
60: 58:     fn eq(&self, other: &Self) -> bool {
61: 59:         Arc::ptr_eq(&self.value, &other.value)
62: 60:     }
63: 61: }
64: 62: 
65: 63: impl<T> Eq for ArcStoredValue<T> {}
66: 64: 
67: 65: impl<T> Hash for ArcStoredValue<T> {
68: 66:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
69: 67:         std::ptr::hash(&Arc::as_ptr(&self.value), state);
70: 68:     }
71: 69: }
72: 70: 
73: 71: impl<T> DefinedAt for ArcStoredValue<T> {
74: 72:     fn defined_at(&self) -> Option<&'static Location<'static>> {
75: 73:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
76: 74:         {
77: 75:             Some(self.defined_at)
78: 76:         }
79: 77:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
80: 78:         {
81: 79:             None
82: 80:         }
83: 81:     }
84: 82: }
85: 83: 
86: 84: impl<T> ArcStoredValue<T> {
87: 85:     /// Creates a new stored value, taking the initial value as its argument.
88: 86:     #[cfg_attr(
89: 87:         feature = "tracing",
90: 88:         tracing::instrument(level = "trace", skip_all)
91: 89:     )]
92: 90:     #[track_caller]
93: 91:     pub fn new(value: T) -> Self {
94: 92:         Self {
95: 93:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
96: 94:             defined_at: Location::caller(),
97: 95:             value: Arc::new(RwLock::new(value)),
98: 96:         }
99: 97:     }
100: 98: }
101: 99: 
102: 100: impl<T> ReadValue for ArcStoredValue<T>
103: 101: where
104: 102:     T: 'static,
105: 103: {
106: 104:     type Value = ReadGuard<T, Plain<T>>;
107: 105: 
108: 106:     fn try_read_value(&self) -> Option<ReadGuard<T, Plain<T>>> {
109: 107:         Plain::try_new(Arc::clone(&self.value)).map(ReadGuard::new)
110: 108:     }
111: 109: }
112: 110: 
113: 111: impl<T> WriteValue for ArcStoredValue<T>
114: 112: where
115: 113:     T: 'static,
116: 114: {
117: 115:     type Value = T;
118: 116: 
119: 117:     fn try_write_value(&self) -> Option<UntrackedWriteGuard<T>> {
120: 118:         UntrackedWriteGuard::try_new(self.value.clone())
121: 119:     }
122: 120: }
123: 121: 
124: 122: impl<T> IsDisposed for ArcStoredValue<T> {
125: 123:     fn is_disposed(&self) -> bool {
126: 124:         false
127: 125:     }
128: 126: }
129: 127: 
130: 128: impl<T> IntoInner for ArcStoredValue<T> {
131: 129:     type Value = T;
132: 130: 
133: 131:     #[inline(always)]
134: 132:     fn into_inner(self) -> Option<Self::Value> {
135: 133:         Some(Arc::into_inner(self.value)?.into_inner().unwrap())
136: 134:     }
137: 135: }
138: ```
```
