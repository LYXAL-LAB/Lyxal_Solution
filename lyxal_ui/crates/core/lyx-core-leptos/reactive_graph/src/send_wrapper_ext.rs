### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\send_wrlyx-platform-lyx_platform_apper_ext.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_ext.rs
2: ```rust
3: 1: //! Additional wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper utilities for [`send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper`].
4: 2: 
5: 3: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
6: 4: use std::{
7: 5:     fmt::{Debug, Formatter},
8: 6:     hash,
9: 7:     ops::{Deref, DerefMut},
10: 8: };
11: 9: /// An optional value that can always be sent between threads, even if its inner value
12: 10: /// in the `Some(_)` case would not be threadsafe.
13: 11: ///
14: 12: /// This struct can be dereferenced to `Option<T>`.
15: 13: ///
16: 14: /// If it has been given a local (`!Send`) value, that value is wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped in a [`SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper`], which
17: 15: /// allows sending it between threads but will panic if it is accessed or updated from a  
18: 16: /// thread other than the one on which it was created.
19: 17: ///
20: 18: /// If it is created with `None` for a local (`!Send`) type, no `SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper` is created until a
21: 19: /// value is provided via [`DerefMut`] or [`update`](SendOption::update).
22: 20: ///
23: 21: /// ### Use Case
24: 22: /// This is useful for cases like browser-only types, which are `!Send` but cannot be constructed
25: 23: /// on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server anyway, and are only created in a single-threaded browser environment. The local
26: 24: /// `SendOption` can be created with its `None` variant and sent between threads without causing issues
27: 25: /// when it is dropped.
28: 26: ///
29: 27: /// ### Panics
30: 28: /// Dereferencing or dropping `SendOption` panics under the following conditions:
31: 29: /// 1) It is created via [`new_local`](SendOption::new_local) (signifying a `!Send` inner type),
32: 30: /// 2) It has `Some(_)` value, and
33: 31: /// 3) It has been sent to a thread other than the one on which it was created.
34: 32: pub struct SendOption<T> {
35: 33:     inner: Inner<T>,
36: 34: }
37: 35: 
38: 36: // SAFETY: `SendOption` can *only* be given a T in four ways
39: 37: // 1) via new(), which requires T: Send + Sync
40: 38: // 2) via new_local(), which wraps T in a SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper if given Some(T)
41: 39: // 3) via deref_mut(), which creates a SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Option<T>> as needed
42: 40: // 4) via update(), which either dereferences an existing SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper
43: 41: //    or creates a new SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper as needed
44: 42: unsafe impl<T> Send for SendOption<T> {}
45: 43: unsafe impl<T> Sync for SendOption<T> {}
46: 44: 
47: 45: impl<T> PartialEq for SendOption<T>
48: 46: where
49: 47:     T: PartialEq,
50: 48: {
51: 49:     fn eq(&self, other: &Self) -> bool {
52: 50:         self.deref() == other.deref()
53: 51:     }
54: 52: }
55: 53: 
56: 54: impl<T> Eq for SendOption<T> where T: Eq {}
57: 55: 
58: 56: impl<T> PartialOrd for SendOption<T>
59: 57: where
60: 58:     T: PartialOrd,
61: 59: {
62: 60:     fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
63: 61:         self.deref().partial_cmp(other.deref())
64: 62:     }
65: 63: }
66: 64: 
67: 65: impl<T> hash::Hash for SendOption<T>
68: 66: where
69: 67:     T: hash::Hash,
70: 68: {
71: 69:     fn hash<H: hash::Hasher>(&self, state: &mut H) {
72: 70:         self.deref().hash(state);
73: 71:     }
74: 72: }
75: 73: 
76: 74: enum Inner<T> {
77: 75:     /// A threadsafe value.
78: 76:     Threadsafe(Option<T>),
79: 77:     /// A non-threadsafe value. If accessed/dropped from a different thread in the Some() variant, it will panic.
80: 78:     Local(Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Option<T>>>),
81: 79: }
82: 80: 
83: 81: impl<T> SendOption<T>
84: 82: where
85: 83:     T: Send + Sync,
86: 84: {
87: 85:     /// Create a new threadsafe value.
88: 86:     pub fn new(value: Option<T>) -> Self {
89: 87:         Self {
90: 88:             inner: Inner::Threadsafe(value),
91: 89:         }
92: 90:     }
93: 91: }
94: 92: 
95: 93: impl<T> From<Option<T>> for SendOption<T>
96: 94: where
97: 95:     T: Send + Sync,
98: 96: {
99: 97:     fn from(value: Option<T>) -> Self {
100: 98:         Self::new(value)
101: 99:     }
102: 100: }
103: 101: 
104: 102: impl<T> SendOption<T> {
105: 103:     /// Create a new non-threadsafe value.
106: 104:     pub fn new_local(value: Option<T>) -> Self {
107: 105:         Self {
108: 106:             inner: if let Some(value) = value {
109: 107:                 Inner::Local(Some(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(Some(value))))
110: 108:             } else {
111: 109:                 Inner::Local(None)
112: 110:             },
113: 111:         }
114: 112:     }
115: 113: 
116: 114:     /// Update a value in place with a callback.
117: 115:     ///
118: 116:     /// # Panics
119: 117:     /// If the value is [`Inner::Local`] and it is called from a different thread than the one the instance has been created with, it will panic.
120: 118:     pub fn update(&mut self, cb: impl FnOnce(&mut Option<T>)) {
121: 119:         match &mut self.inner {
122: 120:             Inner::Threadsafe(value) => cb(value),
123: 121:             Inner::Local(value) => match value {
124: 122:                 Some(sw) => {
125: 123:                     cb(sw.deref_mut());
126: 124:                     if sw.is_none() {
127: 125:                         *value = None;
128: 126:                     }
129: 127:                 }
130: 128:                 None => {
131: 129:                     let mut inner = None;
132: 130:                     cb(&mut inner);
133: 131:                     if let Some(inner) = inner {
134: 132:                         *value = Some(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(Some(inner)));
135: 133:                     }
136: 134:                 }
137: 135:             },
138: 136:         }
139: 137:     }
140: 138: 
141: 139:     /// Consume the value.
142: 140:     ///
143: 141:     /// # Panics
144: 142:     /// Panics if the [`Inner::Local`] variant and it is called from a different thread than the one the instance has been created with.
145: 143:     pub fn take(self) -> Option<T> {
146: 144:         match self.inner {
147: 145:             Inner::Threadsafe(value) => value,
148: 146:             Inner::Local(value) => value.and_then(|value| value.take()),
149: 147:         }
150: 148:     }
151: 149: }
152: 150: 
153: 151: impl<T> Deref for SendOption<T> {
154: 152:     type Target = Option<T>;
155: 153: 
156: 154:     fn deref(&self) -> &Self::Target {
157: 155:         match &self.inner {
158: 156:             Inner::Threadsafe(value) => value,
159: 157:             Inner::Local(value) => match value {
160: 158:                 Some(value) => value.deref(),
161: 159:                 None => &None,
162: 160:             },
163: 161:         }
164: 162:     }
165: 163: }
166: 164: 
167: 165: impl<T> DerefMut for SendOption<T> {
168: 166:     fn deref_mut(&mut self) -> &mut Self::Target {
169: 167:         match &mut self.inner {
170: 168:             Inner::Threadsafe(value) => value,
171: 169:             Inner::Local(value) => match value {
172: 170:                 Some(value) => value.deref_mut(),
173: 171:                 None => {
174: 172:                     *value = Some(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(None));
175: 173:                     value.as_mut().unwrap().deref_mut()
176: 174:                 }
177: 175:             },
178: 176:         }
179: 177:     }
180: 178: }
181: 179: 
182: 180: impl<T: Debug> Debug for SendOption<T> {
183: 181:     fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
184: 182:         match &self.inner {
185: 183:             Inner::Threadsafe(value) => {
186: 184:                 write!(f, "SendOption::Threadsafe({value:?})")
187: 185:             }
188: 186:             Inner::Local(value) => {
189: 187:                 write!(f, "SendOption::Local({value:?})")
190: 188:             }
191: 189:         }
192: 190:     }
193: 191: }
194: 192: 
195: 193: impl<T: Clone> Clone for SendOption<T> {
196: 194:     fn clone(&self) -> Self {
197: 195:         Self {
198: 196:             inner: match &self.inner {
199: 197:                 Inner::Threadsafe(value) => Inner::Threadsafe(value.clone()),
200: 198:                 Inner::Local(value) => Inner::Local(value.clone()),
201: 199:             },
202: 200:         }
203: 201:     }
204: 202: }
205: ```
```
