### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\trait_options.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\trait_options.rs
2: ```rust
3: 1: use crate::{
4: 2:     traits::{
5: 3:         DefinedAt, Get, GetUntracked, Read, ReadUntracked, Track, With,
6: 4:         WithUntracked,
7: 5:     },
8: 6:     unwrap_signal,
9: 7: };
10: 8: use std::panic::Location;
11: 9: 
12: 10: impl<T> DefinedAt for Option<T>
13: 11: where
14: 12:     T: DefinedAt,
15: 13: {
16: 14:     fn defined_at(&self) -> Option<&'static Location<'static>> {
17: 15:         self.as_ref().map(DefinedAt::defined_at).unwrap_or(None)
18: 16:     }
19: 17: }
20: 18: 
21: 19: impl<T> Track for Option<T>
22: 20: where
23: 21:     T: Track,
24: 22: {
25: 23:     fn track(&self) {
26: 24:         if let Some(signal) = self {
27: 25:             signal.track();
28: 26:         }
29: 27:     }
30: 28: }
31: 29: 
32: 30: /// An alternative [`ReadUntracked`](crate) trait that works with `Option<Readable>` types.
33: 31: pub trait ReadUntrackedOptional: Sized + DefinedAt {
34: 32:     /// The guard type that will be returned, which can be dereferenced to the value.
35: 33:     type Value;
36: 34: 
37: 35:     /// Returns the guard, or `None` if the signal has already been disposed.
38: 36:     #[track_caller]
39: 37:     fn try_read_untracked(&self) -> Option<Self::Value>;
40: 38: 
41: 39:     /// Returns the guard.
42: 40:     ///
43: 41:     /// # Panics
44: 42:     /// Panics if you try to access a signal that has been disposed.
45: 43:     #[track_caller]
46: 44:     fn read_untracked(&self) -> Self::Value {
47: 45:         self.try_read_untracked()
48: 46:             .unwrap_or_else(unwrap_signal!(self))
49: 47:     }
50: 48: }
51: 49: 
52: 50: impl<T> ReadUntrackedOptional for Option<T>
53: 51: where
54: 52:     Self: DefinedAt,
55: 53:     T: ReadUntracked,
56: 54: {
57: 55:     type Value = Option<<T as ReadUntracked>::Value>;
58: 56: 
59: 57:     fn try_read_untracked(&self) -> Option<Self::Value> {
60: 58:         Some(if let Some(signal) = self {
61: 59:             Some(signal.try_read_untracked()?)
62: 60:         } else {
63: 61:             None
64: 62:         })
65: 63:     }
66: 64: }
67: 65: 
68: 66: /// An alternative [`Read`](crate) trait that works with `Option<Readable>` types.
69: 67: pub trait ReadOptional: DefinedAt {
70: 68:     /// The guard type that will be returned, which can be dereferenced to the value.
71: 69:     type Value;
72: 70: 
73: 71:     /// Subscribes to the signal, and returns the guard, or `None` if the signal has already been disposed.
74: 72:     #[track_caller]
75: 73:     fn try_read(&self) -> Option<Self::Value>;
76: 74: 
77: 75:     /// Subscribes to the signal, and returns the guard.
78: 76:     ///
79: 77:     /// # Panics
80: 78:     /// Panics if you try to access a signal that has been disposed.
81: 79:     #[track_caller]
82: 80:     fn read(&self) -> Self::Value {
83: 81:         self.try_read().unwrap_or_else(unwrap_signal!(self))
84: 82:     }
85: 83: }
86: 84: 
87: 85: impl<T> ReadOptional for Option<T>
88: 86: where
89: 87:     Self: DefinedAt,
90: 88:     T: Read,
91: 89: {
92: 90:     type Value = Option<<T as Read>::Value>;
93: 91: 
94: 92:     fn try_read(&self) -> Option<Self::Value> {
95: 93:         Some(if let Some(readable) = self {
96: 94:             Some(readable.try_read()?)
97: 95:         } else {
98: 96:             None
99: 97:         })
100: 98:     }
101: 99: }
102: 100: 
103: 101: /// An alternative [`WithUntracked`](crate) trait that works with `Option<Withable>` types.
104: 102: pub trait WithUntrackedOptional: DefinedAt {
105: 103:     /// The type of the value contained in the signal.
106: 104:     type Value: ?Sized;
107: 105: 
108: 106:     /// Applies the closure to the value, and returns the result,
109: 107:     /// or `None` if the signal has already been disposed.
110: 108:     #[track_caller]
111: 109:     fn try_with_untracked<U>(
112: 110:         &self,
113: 111:         fun: impl FnOnce(Option<&Self::Value>) -> U,
114: 112:     ) -> Option<U>;
115: 113: 
116: 114:     /// Applies the closure to the value, and returns the result.
117: 115:     ///
118: 116:     /// # Panics
119: 117:     /// Panics if you try to access a signal that has been disposed.
120: 118:     #[track_caller]
121: 119:     fn with_untracked<U>(
122: 120:         &self,
123: 121:         fun: impl FnOnce(Option<&Self::Value>) -> U,
124: 122:     ) -> U {
125: 123:         self.try_with_untracked(fun)
126: 124:             .unwrap_or_else(unwrap_signal!(self))
127: 125:     }
128: 126: }
129: 127: 
130: 128: impl<T> WithUntrackedOptional for Option<T>
131: 129: where
132: 130:     Self: DefinedAt,
133: 131:     T: WithUntracked,
134: 132:     <T as WithUntracked>::Value: Sized,
135: 133: {
136: 134:     type Value = <T as WithUntracked>::Value;
137: 135: 
138: 136:     fn try_with_untracked<U>(
139: 137:         &self,
140: 138:         fun: impl FnOnce(Option<&Self::Value>) -> U,
141: 139:     ) -> Option<U> {
142: 140:         if let Some(signal) = self {
143: 141:             Some(signal.try_with_untracked(|val| fun(Some(val)))?)
144: 142:         } else {
145: 143:             Some(fun(None))
146: 144:         }
147: 145:     }
148: 146: }
149: 147: 
150: 148: /// An alternative [`With`](crate) trait that works with `Option<Withable>` types.
151: 149: pub trait WithOptional: DefinedAt {
152: 150:     /// The type of the value contained in the signal.
153: 151:     type Value: ?Sized;
154: 152: 
155: 153:     /// Subscribes to the signal, lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies the closure to the value, and returns the result,
156: 154:     /// or `None` if the signal has already been disposed.
157: 155:     #[track_caller]
158: 156:     fn try_with<U>(
159: 157:         &self,
160: 158:         fun: impl FnOnce(Option<&Self::Value>) -> U,
161: 159:     ) -> Option<U>;
162: 160: 
163: 161:     /// Subscribes to the signal, lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies the closure to the value, and returns the result.
164: 162:     ///
165: 163:     /// # Panics
166: 164:     /// Panics if you try to access a signal that has been disposed.
167: 165:     #[track_caller]
168: 166:     fn with<U>(&self, fun: impl FnOnce(Option<&Self::Value>) -> U) -> U {
169: 167:         self.try_with(fun).unwrap_or_else(unwrap_signal!(self))
170: 168:     }
171: 169: }
172: 170: 
173: 171: impl<T> WithOptional for Option<T>
174: 172: where
175: 173:     Self: DefinedAt,
176: 174:     T: With,
177: 175:     <T as With>::Value: Sized,
178: 176: {
179: 177:     type Value = <T as With>::Value;
180: 178: 
181: 179:     fn try_with<U>(
182: 180:         &self,
183: 181:         fun: impl FnOnce(Option<&Self::Value>) -> U,
184: 182:     ) -> Option<U> {
185: 183:         if let Some(signal) = self {
186: 184:             Some(signal.try_with(|val| fun(Some(val)))?)
187: 185:         } else {
188: 186:             Some(fun(None))
189: 187:         }
190: 188:     }
191: 189: }
192: 190: 
193: 191: impl<T> GetUntracked for Option<T>
194: 192: where
195: 193:     Self: DefinedAt,
196: 194:     T: GetUntracked,
197: 195: {
198: 196:     type Value = Option<<T as GetUntracked>::Value>;
199: 197: 
200: 198:     fn try_get_untracked(&self) -> Option<Self::Value> {
201: 199:         Some(if let Some(signal) = self {
202: 200:             Some(signal.try_get_untracked()?)
203: 201:         } else {
204: 202:             None
205: 203:         })
206: 204:     }
207: 205: }
208: 206: 
209: 207: impl<T> Get for Option<T>
210: 208: where
211: 209:     Self: DefinedAt,
212: 210:     T: Get,
213: 211: {
214: 212:     type Value = Option<<T as Get>::Value>;
215: 213: 
216: 214:     fn try_get(&self) -> Option<Self::Value> {
217: 215:         Some(if let Some(signal) = self {
218: 216:             Some(signal.try_get()?)
219: 217:         } else {
220: 218:             None
221: 219:         })
222: 220:     }
223: 221: }
224: 222: 
225: 223: /// Helper trait to implement flatten() on `Option<&Option<T>>`.
226: 224: pub trait FlattenOptionRefOption {
227: 225:     /// The type of the value contained in the double option.
228: 226:     type Value;
229: 227: 
230: 228:     /// Converts from `Option<&Option<T>>` to `Option<&T>`.
231: 229:     fn flatten(&self) -> Option<&Self::Value>;
232: 230: }
233: 231: 
234: 232: impl<'a, T> FlattenOptionRefOption for Option<&'a Option<T>> {
235: 233:     type Value = T;
236: 234: 
237: 235:     fn flatten(&self) -> Option<&'a T> {
238: 236:         self.map(Option::as_ref).flatten()
239: 237:     }
240: 238: }
241: ```
```
