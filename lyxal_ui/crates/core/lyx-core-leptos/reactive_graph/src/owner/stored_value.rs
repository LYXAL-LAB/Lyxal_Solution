### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\owner\stored_value.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\owner\stored_value.rs
2: ```rust
3: 1: use super::{
4: 2:     arc_stored_value::ArcStoredValue, ArenaItem, LocalStorage, Storage,
5: 3:     SyncStorage,
6: 4: };
7: 5: use crate::{
8: 6:     signal::guards::{Plain, ReadGuard, UntrackedWriteGuard},
9: 7:     traits::{
10: 8:         DefinedAt, Dispose, IntoInner, IsDisposed, ReadValue, WriteValue,
11: 9:     },
12: 10:     unwrap_signal,
13: 11: };
14: 12: use std::{
15: 13:     fmt::{Debug, Formatter},
16: 14:     hash::Hash,
17: 15:     panic::Location,
18: 16: };
19: 17: 
20: 18: /// A **non-reactive**, `Copy` handle for any value.
21: 19: ///
22: 20: /// This allows you to create a stable reference for any value by storing it within
23: 21: /// the reactive system. Like the signal types (e.g., [`ReadSignal`](crate::signal::ReadSignal)
24: 22: /// and [`RwSignal`](crate::signal::RwSignal)), it is `Copy` and `'static`. Unlike the signal
25: 23: /// types, it is not reactive; accessing it does not cause effects to subscribe, and
26: 24: /// updating it does not notify anything else.
27: 25: pub struct StoredValue<T, S = SyncStorage> {
28: 26:     value: ArenaItem<ArcStoredValue<T>, S>,
29: 27:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
30: 28:     defined_at: &'static Location<'static>,
31: 29: }
32: 30: 
33: 31: impl<T, S> Copy for StoredValue<T, S> {}
34: 32: 
35: 33: impl<T, S> Clone for StoredValue<T, S> {
36: 34:     fn clone(&self) -> Self {
37: 35:         *self
38: 36:     }
39: 37: }
40: 38: 
41: 39: impl<T, S> Debug for StoredValue<T, S>
42: 40: where
43: 41:     S: Debug,
44: 42: {
45: 43:     fn fmt(&self, f: &mut Formatter<'_>) -> core::fmt::Result {
46: 44:         f.debug_struct("StoredValue")
47: 45:             .field("type", &std::any::type_name::<T>())
48: 46:             .field("value", &self.value)
49: 47:             .finish()
50: 48:     }
51: 49: }
52: 50: 
53: 51: impl<T, S> PartialEq for StoredValue<T, S> {
54: 52:     fn eq(&self, other: &Self) -> bool {
55: 53:         self.value == other.value
56: 54:     }
57: 55: }
58: 56: 
59: 57: impl<T, S> Eq for StoredValue<T, S> {}
60: 58: 
61: 59: impl<T, S> Hash for StoredValue<T, S> {
62: 60:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
63: 61:         self.value.hash(state);
64: 62:     }
65: 63: }
66: 64: 
67: 65: impl<T, S> DefinedAt for StoredValue<T, S> {
68: 66:     fn defined_at(&self) -> Option<&'static Location<'static>> {
69: 67:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
70: 68:         {
71: 69:             Some(self.defined_at)
72: 70:         }
73: 71:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
74: 72:         {
75: 73:             None
76: 74:         }
77: 75:     }
78: 76: }
79: 77: 
80: 78: impl<T, S> StoredValue<T, S>
81: 79: where
82: 80:     T: 'static,
83: 81:     S: Storage<ArcStoredValue<T>>,
84: 82: {
85: 83:     /// Stores the given value in the arena allocator.
86: 84:     #[track_caller]
87: 85:     pub fn new_with_storage(value: T) -> Self {
88: 86:         Self {
89: 87:             value: ArenaItem::new_with_storage(ArcStoredValue::new(value)),
90: 88:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
91: 89:             defined_at: Location::caller(),
92: 90:         }
93: 91:     }
94: 92: }
95: 93: 
96: 94: impl<T, S> Default for StoredValue<T, S>
97: 95: where
98: 96:     T: Default + 'static,
99: 97:     S: Storage<ArcStoredValue<T>>,
100: 98: {
101: 99:     #[track_caller] // Default trait is not annotated with #[track_caller]
102: 100:     fn default() -> Self {
103: 101:         Self::new_with_storage(Default::default())
104: 102:     }
105: 103: }
106: 104: 
107: 105: impl<T> StoredValue<T>
108: 106: where
109: 107:     T: Send + Sync + 'static,
110: 108: {
111: 109:     /// Stores the given value in the arena allocator.
112: 110:     #[track_caller]
113: 111:     pub fn new(value: T) -> Self {
114: 112:         StoredValue::new_with_storage(value)
115: 113:     }
116: 114: }
117: 115: 
118: 116: impl<T> StoredValue<T, LocalStorage>
119: 117: where
120: 118:     T: 'static,
121: 119: {
122: 120:     /// Stores the given value in the arena allocator.
123: 121:     #[track_caller]
124: 122:     pub fn new_local(value: T) -> Self {
125: 123:         StoredValue::new_with_storage(value)
126: 124:     }
127: 125: }
128: 126: 
129: 127: impl<T, S> ReadValue for StoredValue<T, S>
130: 128: where
131: 129:     T: 'static,
132: 130:     S: Storage<ArcStoredValue<T>>,
133: 131: {
134: 132:     type Value = ReadGuard<T, Plain<T>>;
135: 133: 
136: 134:     fn try_read_value(&self) -> Option<ReadGuard<T, Plain<T>>> {
137: 135:         self.value
138: 136:             .try_get_value()
139: 137:             .and_then(|inner| inner.try_read_value())
140: 138:     }
141: 139: }
142: 140: 
143: 141: impl<T, S> WriteValue for StoredValue<T, S>
144: 142: where
145: 143:     T: 'static,
146: 144:     S: Storage<ArcStoredValue<T>>,
147: 145: {
148: 146:     type Value = T;
149: 147: 
150: 148:     fn try_write_value(&self) -> Option<UntrackedWriteGuard<T>> {
151: 149:         self.value
152: 150:             .try_get_value()
153: 151:             .and_then(|inner| inner.try_write_value())
154: 152:     }
155: 153: }
156: 154: 
157: 155: impl<T, S> IsDisposed for StoredValue<T, S> {
158: 156:     fn is_disposed(&self) -> bool {
159: 157:         self.value.is_disposed()
160: 158:     }
161: 159: }
162: 160: 
163: 161: impl<T, S> Dispose for StoredValue<T, S> {
164: 162:     fn dispose(self) {
165: 163:         self.value.dispose();
166: 164:     }
167: 165: }
168: 166: 
169: 167: impl<T, S> IntoInner for StoredValue<T, S>
170: 168: where
171: 169:     T: 'static,
172: 170:     S: Storage<ArcStoredValue<T>>,
173: 171: {
174: 172:     type Value = T;
175: 173: 
176: 174:     #[inline(always)]
177: 175:     fn into_inner(self) -> Option<Self::Value> {
178: 176:         self.value.into_inner()?.into_inner()
179: 177:     }
180: 178: }
181: 179: 
182: 180: impl<T> From<ArcStoredValue<T>> for StoredValue<T>
183: 181: where
184: 182:     T: Send + Sync + 'static,
185: 183: {
186: 184:     #[track_caller]
187: 185:     fn from(value: ArcStoredValue<T>) -> Self {
188: 186:         StoredValue {
189: 187:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
190: 188:             defined_at: Location::caller(),
191: 189:             value: ArenaItem::new(value),
192: 190:         }
193: 191:     }
194: 192: }
195: 193: 
196: 194: impl<T, S> From<StoredValue<T, S>> for ArcStoredValue<T>
197: 195: where
198: 196:     S: Storage<ArcStoredValue<T>>,
199: 197: {
200: 198:     #[track_caller]
201: 199:     fn from(value: StoredValue<T, S>) -> Self {
202: 200:         value
203: 201:             .value
204: 202:             .try_get_value()
205: 203:             .unwrap_or_else(unwrap_signal!(value))
206: 204:     }
207: 205: }
208: 206: 
209: 207: /// Creates a new [`StoredValue`].
210: 208: #[inline(always)]
211: 209: #[track_caller]
212: 210: #[deprecated(
213: 211:     since = "0.7.0-beta5",
214: 212:     note = "This function is being removed to conform to Rust idioms. Please \
215: 213:             use `StoredValue::new()` or `StoredValue::new_local()` instead."
216: 214: )]
217: 215: pub fn store_value<T>(value: T) -> StoredValue<T>
218: 216: where
219: 217:     T: Send + Sync + 'static,
220: 218: {
221: 219:     StoredValue::new(value)
222: 220: }
223: 221: 
224: 222: /// Converts some value into a locally-stored type, using [`LocalStorage`].
225: 223: ///
226: 224: /// This is modeled on [`From`] but special-cased for this thread-local storage method, which
227: 225: /// allows for better type inference for the default case.
228: 226: pub trait FromLocal<T> {
229: 227:     /// Converts between the types.
230: 228:     fn from_local(value: T) -> Self;
231: 229: }
232: ```
```
