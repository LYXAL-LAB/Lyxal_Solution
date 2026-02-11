### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_server\src\action.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server\src\action.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
4: 2:     actions::{Action, ArcAction},
5: 3:     owner::use_context,
6: 4:     traits::DefinedAt,
7: 5: };
8: 6: use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{
9: 7:     error::{FromServerFnError, ServerFnUrlError},
10: 8:     ServerFn,
11: 9: };
12: 10: use std::{ops::Deref, panic::Location, sync::Arc};
13: 11: 
14: 12: /// An error that can be caused by a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server action.
15: 13: ///
16: 14: /// This is used for propagating errors from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the lyx-core-lyx_core_lyx-core-lyx_core_client when JS/WASM are not
17: 15: /// supported.
18: 16: #[derive(Clone, Debug, PartialEq, Eq)]
19: 17: pub struct ServerActionError {
20: 18:     path: Arc<str>,
21: 19:     err: Arc<str>,
22: 20: }
23: 21: 
24: 22: impl ServerActionError {
25: 23:     /// Creates a new error associated with the given path.
26: 24:     pub fn new(path: &str, err: &str) -> Self {
27: 25:         Self {
28: 26:             path: path.into(),
29: 27:             err: err.into(),
30: 28:         }
31: 29:     }
32: 30: 
33: 31:     /// The path with which this error is associated.
34: 32:     pub fn path(&self) -> &str {
35: 33:         &self.path
36: 34:     }
37: 35: 
38: 36:     /// The error message.
39: 37:     pub fn err(&self) -> &str {
40: 38:         &self.err
41: 39:     }
42: 40: }
43: 41: 
44: 42: /// An [`ArcAction`] that can be used to call a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
45: 43: pub struct ArcServerAction<S>
46: 44: where
47: 45:     S: ServerFn + 'static,
48: 46:     S::Output: 'static,
49: 47: {
50: 48:     inner: ArcAction<S, Result<S::Output, S::Error>>,
51: 49:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
52: 50:     defined_at: &'static Location<'static>,
53: 51: }
54: 52: 
55: 53: impl<S> ArcServerAction<S>
56: 54: where
57: 55:     S: ServerFn + Clone + Send + Sync + 'static,
58: 56:     S::Output: Send + Sync + 'static,
59: 57:     S::Error: Send + Sync + 'static,
60: 58:     S::Error: FromServerFnError,
61: 59: {
62: 60:     /// Creates a new [`ArcAction`] that will call the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function `S` when dispatched.
63: 61:     #[track_caller]
64: 62:     pub fn new() -> Self {
65: 63:         let err = use_context::<ServerActionError>().and_then(|error| {
66: 64:             (error.path() == S::PATH)
67: 65:                 .then(|| ServerFnUrlError::<S::Error>::decode_err(error.err()))
68: 66:                 .map(Err)
69: 67:         });
70: 68:         Self {
71: 69:             inner: ArcAction::new_with_value(err, |input: &S| {
72: 70:                 S::run_on_lyx-core-lyx_core_lyx-core-lyx_core_client(input.clone())
73: 71:             }),
74: 72:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
75: 73:             defined_at: Location::caller(),
76: 74:         }
77: 75:     }
78: 76: }
79: 77: 
80: 78: impl<S> Deref for ArcServerAction<S>
81: 79: where
82: 80:     S: ServerFn + 'static,
83: 81:     S::Output: 'static,
84: 82: {
85: 83:     type Target = ArcAction<S, Result<S::Output, S::Error>>;
86: 84: 
87: 85:     fn deref(&self) -> &Self::Target {
88: 86:         &self.inner
89: 87:     }
90: 88: }
91: 89: 
92: 90: impl<S> Clone for ArcServerAction<S>
93: 91: where
94: 92:     S: ServerFn + 'static,
95: 93:     S::Output: 'static,
96: 94: {
97: 95:     fn clone(&self) -> Self {
98: 96:         Self {
99: 97:             inner: self.inner.clone(),
100: 98:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
101: 99:             defined_at: self.defined_at,
102: 100:         }
103: 101:     }
104: 102: }
105: 103: 
106: 104: impl<S> Default for ArcServerAction<S>
107: 105: where
108: 106:     S: ServerFn + Clone + Send + Sync + 'static,
109: 107:     S::Output: Send + Sync + 'static,
110: 108:     S::Error: Send + Sync + 'static,
111: 109: {
112: 110:     fn default() -> Self {
113: 111:         Self::new()
114: 112:     }
115: 113: }
116: 114: 
117: 115: impl<S> DefinedAt for ArcServerAction<S>
118: 116: where
119: 117:     S: ServerFn + 'static,
120: 118:     S::Output: 'static,
121: 119: {
122: 120:     fn defined_at(&self) -> Option<&'static Location<'static>> {
123: 121:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
124: 122:         {
125: 123:             Some(self.defined_at)
126: 124:         }
127: 125:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
128: 126:         {
129: 127:             None
130: 128:         }
131: 129:     }
132: 130: }
133: 131: 
134: 132: /// An [`Action`] that can be used to call a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
135: 133: pub struct ServerAction<S>
136: 134: where
137: 135:     S: ServerFn + 'static,
138: 136:     S::Output: 'static,
139: 137: {
140: 138:     inner: Action<S, Result<S::Output, S::Error>>,
141: 139:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
142: 140:     defined_at: &'static Location<'static>,
143: 141: }
144: 142: 
145: 143: impl<S> ServerAction<S>
146: 144: where
147: 145:     S: ServerFn + Send + Sync + Clone + 'static,
148: 146:     S::Output: Send + Sync + 'static,
149: 147:     S::Error: Send + Sync + 'static,
150: 148: {
151: 149:     /// Creates a new [`Action`] that will call the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function `S` when dispatched.
152: 150:     pub fn new() -> Self {
153: 151:         let err = use_context::<ServerActionError>().and_then(|error| {
154: 152:             (error.path() == S::PATH)
155: 153:                 .then(|| ServerFnUrlError::<S::Error>::decode_err(error.err()))
156: 154:                 .map(Err)
157: 155:         });
158: 156:         Self {
159: 157:             inner: Action::new_with_value(err, |input: &S| {
160: 158:                 S::run_on_lyx-core-lyx_core_lyx-core-lyx_core_client(input.clone())
161: 159:             }),
162: 160:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
163: 161:             defined_at: Location::caller(),
164: 162:         }
165: 163:     }
166: 164: }
167: 165: 
168: 166: impl<S> Clone for ServerAction<S>
169: 167: where
170: 168:     S: ServerFn + 'static,
171: 169:     S::Output: 'static,
172: 170: {
173: 171:     fn clone(&self) -> Self {
174: 172:         *self
175: 173:     }
176: 174: }
177: 175: 
178: 176: impl<S> Copy for ServerAction<S>
179: 177: where
180: 178:     S: ServerFn + 'static,
181: 179:     S::Output: 'static,
182: 180: {
183: 181: }
184: 182: 
185: 183: impl<S> Deref for ServerAction<S>
186: 184: where
187: 185:     S: ServerFn + Clone + Send + Sync + 'static,
188: 186:     S::Output: Send + Sync + 'static,
189: 187:     S::Error: Send + Sync + 'static,
190: 188: {
191: 189:     type Target = Action<S, Result<S::Output, S::Error>>;
192: 190: 
193: 191:     fn deref(&self) -> &Self::Target {
194: 192:         &self.inner
195: 193:     }
196: 194: }
197: 195: 
198: 196: impl<S> From<ServerAction<S>> for Action<S, Result<S::Output, S::Error>>
199: 197: where
200: 198:     S: ServerFn + 'static,
201: 199:     S::Output: 'static,
202: 200: {
203: 201:     fn from(value: ServerAction<S>) -> Self {
204: 202:         value.inner
205: 203:     }
206: 204: }
207: 205: 
208: 206: impl<S> Default for ServerAction<S>
209: 207: where
210: 208:     S: ServerFn + Clone + Send + Sync + 'static,
211: 209:     S::Output: Send + Sync + 'static,
212: 210:     S::Error: Send + Sync + 'static,
213: 211: {
214: 212:     fn default() -> Self {
215: 213:         Self::new()
216: 214:     }
217: 215: }
218: 216: 
219: 217: impl<S> DefinedAt for ServerAction<S>
220: 218: where
221: 219:     S: ServerFn + 'static,
222: 220:     S::Output: 'static,
223: 221: {
224: 222:     fn defined_at(&self) -> Option<&'static Location<'static>> {
225: 223:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
226: 224:         {
227: 225:             Some(self.defined_at)
228: 226:         }
229: 227:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
230: 228:         {
231: 229:             None
232: 230:         }
233: 231:     }
234: 232: }
235: ```
```
