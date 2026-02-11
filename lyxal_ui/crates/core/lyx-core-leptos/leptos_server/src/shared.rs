### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_server\src\shared.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server\src\shared.rs
2: ```rust
3: 1: use crate::{FromEncodedStr, IntoEncodedString};
4: 2: #[cfg(feature = "rkyv")]
5: 3: use codee::binary::RkyvCodec;
6: 4: #[cfg(feature = "serde-wasm-bindgen")]
7: 5: use codee::string::JsonSerdeWasmCodec;
8: 6: #[cfg(feature = "miniserde")]
9: 7: use codee::string::MiniserdeCodec;
10: 8: #[cfg(feature = "serde-lite")]
11: 9: use codee::SerdeLite;
12: 10: use codee::{
13: 11:     string::{FromToStringCodec, JsonSerdeCodec},
14: 12:     Decoder, Encoder,
15: 13: };
16: 14: use std::{
17: 15:     fmt::{Debug, Display},
18: 16:     hash::Hash,
19: 17:     marker::PhantomData,
20: 18:     ops::{Deref, DerefMut},
21: 19: };
22: 20: 
23: 21: /// A smart pointer that allows you to share identical, synchronously-loaded data between the
24: 22: /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and the lyx-core-lyx_core_lyx-core-lyx_core_client.
25: 23: ///
26: 24: /// If this constructed on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, it serializes its value into the shared context. If it is
27: 25: /// constructed on the lyx-core-lyx_core_lyx-core-lyx_core_client during hydration, it reads its value from the shared context. If
28: 26: /// it it constructed on the lyx-core-lyx_core_lyx-core-lyx_core_client at any other time, it simply runs on the lyx-core-lyx_core_lyx-core-lyx_core_client.
29: 27: #[derive(Debug)]
30: 28: pub struct SharedValue<T, Ser = JsonSerdeCodec> {
31: 29:     value: T,
32: 30:     ser: PhantomData<Ser>,
33: 31: }
34: 32: 
35: 33: impl<T, Ser> SharedValue<T, Ser> {
36: 34:     /// Returns the inner value.
37: 35:     pub fn into_inner(self) -> T {
38: 36:         self.value
39: 37:     }
40: 38: }
41: 39: 
42: 40: impl<T> SharedValue<T, JsonSerdeCodec>
43: 41: where
44: 42:     JsonSerdeCodec: Encoder<T> + Decoder<T>,
45: 43:     <JsonSerdeCodec as Encoder<T>>::Error: Debug,
46: 44:     <JsonSerdeCodec as Decoder<T>>::Error: Debug,
47: 45:     <JsonSerdeCodec as Encoder<T>>::Encoded: IntoEncodedString,
48: 46:     <JsonSerdeCodec as Decoder<T>>::Encoded: FromEncodedStr,
49: 47:     <<JsonSerdeCodec as codee::Decoder<T>>::Encoded as FromEncodedStr>::DecodingError:
50: 48:         Debug,
51: 49: {
52: 50:     /// Wraps the initial value.
53: 51:     ///
54: 52:     /// If this is on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, the function will be invoked and the value serialized. When it runs
55: 53:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client, it will be deserialized without running the function again.
56: 54:     ///
57: 55:     /// This uses the [`JsonSerdeCodec`] encoding.
58: 56:     pub fn new(initial: impl FnOnce() -> T) -> Self {
59: 57:         SharedValue::new_with_encoding(initial)
60: 58:     }
61: 59: }
62: 60: 
63: 61: impl<T> SharedValue<T, FromToStringCodec>
64: 62: where
65: 63:     FromToStringCodec: Encoder<T> + Decoder<T>,
66: 64:     <FromToStringCodec as Encoder<T>>::Error: Debug,
67: 65:     <FromToStringCodec as Decoder<T>>::Error: Debug,
68: 66:     <FromToStringCodec as Encoder<T>>::Encoded: IntoEncodedString,
69: 67:     <FromToStringCodec as Decoder<T>>::Encoded: FromEncodedStr,
70: 68:     <<FromToStringCodec as codee::Decoder<T>>::Encoded as FromEncodedStr>::DecodingError:
71: 69:         Debug,
72: 70: {
73: 71:     /// Wraps the initial value.
74: 72:     ///
75: 73:     /// If this is on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, the function will be invoked and the value serialized. When it runs
76: 74:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client, it will be deserialized without running the function again.
77: 75:     ///
78: 76:     /// This uses the [`FromToStringCodec`] encoding.
79: 77:     pub fn new_str(initial: impl FnOnce() -> T) -> Self {
80: 78:         SharedValue::new_with_encoding(initial)
81: 79:     }
82: 80: }
83: 81: 
84: 82: #[cfg(feature = "serde-lite")]
85: 83: #[cfg_attr(docsrs, doc(cfg(feature = "serde-lite")))]
86: 84: impl<T> SharedValue<T, SerdeLite<JsonSerdeCodec>>
87: 85: where
88: 86:     SerdeLite<JsonSerdeCodec>: Encoder<T> + Decoder<T>,
89: 87:     <SerdeLite<JsonSerdeCodec> as Encoder<T>>::Error: Debug,
90: 88:     <SerdeLite<JsonSerdeCodec> as Decoder<T>>::Error: Debug,
91: 89:     <SerdeLite<JsonSerdeCodec> as Encoder<T>>::Encoded: IntoEncodedString,
92: 90:     <SerdeLite<JsonSerdeCodec> as Decoder<T>>::Encoded: FromEncodedStr,
93: 91:     <<SerdeLite<JsonSerdeCodec> as codee::Decoder<T>>::Encoded as FromEncodedStr>::DecodingError:
94: 92:         Debug,
95: 93: {
96: 94:     /// Wraps the initial value.
97: 95:     ///
98: 96:     /// If this is on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, the function will be invoked and the value serialized. When it runs
99: 97:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client, it will be deserialized without running the function again.
100: 98:     ///
101: 99:     /// This uses the [`SerdeLite`] encoding.
102: 100:     pub fn new_serde_lite(initial: impl FnOnce() -> T) -> Self {
103: 101:         SharedValue::new_with_encoding(initial)
104: 102:     }
105: 103: }
106: 104: 
107: 105: #[cfg(feature = "serde-wasm-bindgen")]
108: 106: #[cfg_attr(docsrs, doc(cfg(feature = "serde-wasm-bindgen")))]
109: 107: impl<T> SharedValue<T, JsonSerdeWasmCodec>
110: 108: where
111: 109:     JsonSerdeWasmCodec: Encoder<T> + Decoder<T>,
112: 110:     <JsonSerdeWasmCodec as Encoder<T>>::Error: Debug,
113: 111:     <JsonSerdeWasmCodec as Decoder<T>>::Error: Debug,
114: 112:     <JsonSerdeWasmCodec as Encoder<T>>::Encoded: IntoEncodedString,
115: 113:     <JsonSerdeWasmCodec as Decoder<T>>::Encoded: FromEncodedStr,
116: 114:     <<JsonSerdeWasmCodec as codee::Decoder<T>>::Encoded as FromEncodedStr>::DecodingError:
117: 115:         Debug,
118: 116: {
119: 117:     /// Wraps the initial value.
120: 118:     ///
121: 119:     /// If this is on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, the function will be invoked and the value serialized. When it runs
122: 120:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client, it will be deserialized without running the function again.
123: 121:     ///
124: 122:     /// This uses the [`JsonSerdeWasmCodec`] encoding.
125: 123:     pub fn new_serde_wb(initial: impl FnOnce() -> T) -> Self {
126: 124:         SharedValue::new_with_encoding(initial)
127: 125:     }
128: 126: }
129: 127: 
130: 128: #[cfg(feature = "miniserde")]
131: 129: #[cfg_attr(docsrs, doc(cfg(feature = "miniserde")))]
132: 130: impl<T> SharedValue<T, MiniserdeCodec>
133: 131: where
134: 132:     MiniserdeCodec: Encoder<T> + Decoder<T>,
135: 133:     <MiniserdeCodec as Encoder<T>>::Error: Debug,
136: 134:     <MiniserdeCodec as Decoder<T>>::Error: Debug,
137: 135:     <MiniserdeCodec as Encoder<T>>::Encoded: IntoEncodedString,
138: 136:     <MiniserdeCodec as Decoder<T>>::Encoded: FromEncodedStr,
139: 137:     <<MiniserdeCodec as codee::Decoder<T>>::Encoded as FromEncodedStr>::DecodingError:
140: 138:         Debug,
141: 139: {
142: 140:     /// Wraps the initial value.
143: 141:     ///
144: 142:     /// If this is on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, the function will be invoked and the value serialized. When it runs
145: 143:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client, it will be deserialized without running the function again.
146: 144:     ///
147: 145:     /// This uses the [`MiniserdeCodec`] encoding.
148: 146:     pub fn new_miniserde(initial: impl FnOnce() -> T) -> Self {
149: 147:         SharedValue::new_with_encoding(initial)
150: 148:     }
151: 149: }
152: 150: 
153: 151: #[cfg(feature = "rkyv")]
154: 152: #[cfg_attr(docsrs, doc(cfg(feature = "rkyv")))]
155: 153: impl<T> SharedValue<T, RkyvCodec>
156: 154: where
157: 155:     RkyvCodec: Encoder<T> + Decoder<T>,
158: 156:     <RkyvCodec as Encoder<T>>::Error: Debug,
159: 157:     <RkyvCodec as Decoder<T>>::Error: Debug,
160: 158:     <RkyvCodec as Encoder<T>>::Encoded: IntoEncodedString,
161: 159:     <RkyvCodec as Decoder<T>>::Encoded: FromEncodedStr,
162: 160:     <<RkyvCodec as codee::Decoder<T>>::Encoded as FromEncodedStr>::DecodingError:
163: 161:         Debug,
164: 162: {
165: 163:     /// Wraps the initial value.
166: 164:     ///
167: 165:     /// If this is on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, the function will be invoked and the value serialized. When it runs
168: 166:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client, it will be deserialized without running the function again.
169: 167:     ///
170: 168:     /// This uses the [`RkyvCodec`] encoding.
171: 169:     pub fn new_rkyv(initial: impl FnOnce() -> T) -> Self {
172: 170:         SharedValue::new_with_encoding(initial)
173: 171:     }
174: 172: }
175: 173: 
176: 174: impl<T, Ser> SharedValue<T, Ser>
177: 175: where
178: 176:     Ser: Encoder<T> + Decoder<T>,
179: 177:     <Ser as Encoder<T>>::Error: Debug,
180: 178:     <Ser as Decoder<T>>::Error: Debug,
181: 179:     <Ser as Encoder<T>>::Encoded: IntoEncodedString,
182: 180:     <Ser as Decoder<T>>::Encoded: FromEncodedStr,
183: 181:     <<Ser as codee::Decoder<T>>::Encoded as FromEncodedStr>::DecodingError:
184: 182:         Debug,
185: 183: {
186: 184:     /// Wraps the initial value.
187: 185:     ///
188: 186:     /// If this is on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, the function will be invoked and the value serialized. When it runs
189: 187:     /// on the lyx-core-lyx_core_lyx-core-lyx_core_client, it will be deserialized without running the function again.
190: 188:     ///
191: 189:     /// This uses `Ser` as an encoding.
192: 190:     pub fn new_with_encoding(initial: impl FnOnce() -> T) -> Self {
193: 191:         let value: T;
194: 192:         #[cfg(feature = "hydration")]
195: 193:         {
196: 194:             use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner;
197: 195:             use std::borrow::Borrow;
198: 196: 
199: 197:             let sc = Owner::current_shared_context();
200: 198:             let id = sc.as_ref().map(|sc| sc.next_id()).unwrap_or_default();
201: 199:             let serialized = sc.as_ref().and_then(|sc| sc.read_data(&id));
202: 200:             let hydrating =
203: 201:                 sc.as_ref().map(|sc| sc.during_hydration()).unwrap_or(false);
204: 202:             value = if hydrating {
205: 203:                 let value = match serialized {
206: 204:                     None => {
207: 205:                         #[cfg(feature = "tracing")]
208: 206:                         tracing::error!("couldn't deserialize");
209: 207:                         None
210: 208:                     }
211: 209:                     Some(data) => {
212: 210:                         match <Ser as Decoder<T>>::Encoded::from_encoded_str(
213: 211:                             &data,
214: 212:                         ) {
215: 213:                             #[allow(unused_variables)] // used in tracing
216: 214:                             Err(e) => {
217: 215:                                 #[cfg(feature = "tracing")]
218: 216:                                 tracing::error!(
219: 217:                                     "couldn't deserialize from {data:?}: {e:?}"
220: 218:                                 );
221: 219:                                 None
222: 220:                             }
223: 221:                             Ok(encoded) => {
224: 222:                                 let decoded = Ser::decode(encoded.borrow());
225: 223:                                 #[cfg(feature = "tracing")]
226: 224:                                 let decoded = decoded
227: 225:                                     .inspect_err(|e| tracing::error!("{e:?}"));
228: 226:                                 decoded.ok()
229: 227:                             }
230: 228:                         }
231: 229:                     }
232: 230:                 };
233: 231:                 value.unwrap_or_else(initial)
234: 232:             } else {
235: 233:                 let init = initial();
236: 234:                 #[cfg(feature = "ssr")]
237: 235:                 if let Some(sc) = sc {
238: 236:                     if sc.get_is_hydrating() {
239: 237:                         match Ser::encode(&init)
240: 238:                             .map(IntoEncodedString::into_encoded_string)
241: 239:                         {
242: 240:                             Ok(value) => sc.write_async(
243: 241:                                 id,
244: 242:                                 Box::pin(async move { value }),
245: 243:                             ),
246: 244:                             #[allow(unused_variables)] // used in tracing
247: 245:                             Err(e) => {
248: 246:                                 #[cfg(feature = "tracing")]
249: 247:                                 tracing::error!("couldn't serialize: {e:?}");
250: 248:                             }
251: 249:                         }
252: 250:                     }
253: 251:                 }
254: 252:                 init
255: 253:             }
256: 254:         }
257: 255:         #[cfg(not(feature = "hydration"))]
258: 256:         {
259: 257:             value = initial();
260: 258:         }
261: 259:         Self {
262: 260:             value,
263: 261:             ser: PhantomData,
264: 262:         }
265: 263:     }
266: 264: }
267: 265: 
268: 266: impl<T, Ser> Deref for SharedValue<T, Ser> {
269: 267:     type Target = T;
270: 268: 
271: 269:     fn deref(&self) -> &Self::Target {
272: 270:         &self.value
273: 271:     }
274: 272: }
275: 273: 
276: 274: impl<T, Ser> DerefMut for SharedValue<T, Ser> {
277: 275:     fn deref_mut(&mut self) -> &mut Self::Target {
278: 276:         &mut self.value
279: 277:     }
280: 278: }
281: 279: 
282: 280: impl<T, Ser> PartialEq for SharedValue<T, Ser>
283: 281: where
284: 282:     T: PartialEq,
285: 283: {
286: 284:     fn eq(&self, other: &Self) -> bool {
287: 285:         self.value == other.value
288: 286:     }
289: 287: }
290: 288: 
291: 289: impl<T, Ser> Eq for SharedValue<T, Ser> where T: Eq {}
292: 290: 
293: 291: impl<T, Ser> Display for SharedValue<T, Ser>
294: 292: where
295: 293:     T: Display,
296: 294: {
297: 295:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
298: 296:         write!(f, "{}", self.value)
299: 297:     }
300: 298: }
301: 299: 
302: 300: impl<T, Ser> Hash for SharedValue<T, Ser>
303: 301: where
304: 302:     T: Hash,
305: 303: {
306: 304:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
307: 305:         self.value.hash(state);
308: 306:     }
309: 307: }
310: 308: 
311: 309: impl<T, Ser> PartialOrd for SharedValue<T, Ser>
312: 310: where
313: 311:     T: PartialOrd,
314: 312: {
315: 313:     fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
316: 314:         self.value.partial_cmp(&other.value)
317: 315:     }
318: 316: }
319: 317: 
320: 318: impl<T, Ser> Ord for SharedValue<T, Ser>
321: 319: where
322: 320:     T: Ord,
323: 321: {
324: 322:     fn cmp(&self, other: &Self) -> std::cmp::Ordering {
325: 323:         self.value.cmp(&other.value)
326: 324:     }
327: 325: }
328: ```
```
