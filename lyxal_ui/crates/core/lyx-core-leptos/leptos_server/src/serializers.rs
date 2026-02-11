### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_server\src\serializers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server\src\serializers.rs
2: ```rust
3: 1: use core::str::FromStr;
4: 2: use serde::{de::DeserializeOwned, Serialize};
5: 3: 
6: 4: pub trait SerializableData<Ser: Serializer>: Sized {
7: 5:     type SerErr;
8: 6:     type DeErr;
9: 7: 
10: 8:     fn ser(&self) -> Result<String, Self::SerErr>;
11: 9: 
12: 10:     fn de(data: &str) -> Result<Self, Self::DeErr>;
13: 11: }
14: 12: 
15: 13: pub trait Serializer {}
16: 14: 
17: 15: /// A [`Serializer`] that serializes using [`ToString`] and deserializes
18: 16: /// using [`FromStr`](core::str::FromStr).
19: 17: pub struct Str;
20: 18: 
21: 19: impl Serializer for Str {}
22: 20: 
23: 21: impl<T> SerializableData<Str> for T
24: 22: where
25: 23:     T: ToString + FromStr,
26: 24: {
27: 25:     type SerErr = ();
28: 26:     type DeErr = <T as FromStr>::Err;
29: 27: 
30: 28:     fn ser(&self) -> Result<String, Self::SerErr> {
31: 29:         Ok(self.to_string())
32: 30:     }
33: 31: 
34: 32:     fn de(data: &str) -> Result<Self, Self::DeErr> {
35: 33:         T::from_str(data)
36: 34:     }
37: 35: }
38: 36: 
39: 37: /// A [`Serializer`] that serializes using [`serde_json`].
40: 38: pub struct SerdeJson;
41: 39: 
42: 40: impl Serializer for SerdeJson {}
43: 41: 
44: 42: impl<T> SerializableData<SerdeJson> for T
45: 43: where
46: 44:     T: DeserializeOwned + Serialize,
47: 45: {
48: 46:     type SerErr = serde_json::Error;
49: 47:     type DeErr = serde_json::Error;
50: 48: 
51: 49:     fn ser(&self) -> Result<String, Self::SerErr> {
52: 50:         serde_json::to_string(&self)
53: 51:     }
54: 52: 
55: 53:     fn de(data: &str) -> Result<Self, Self::DeErr> {
56: 54:         serde_json::from_str(data)
57: 55:     }
58: 56: }
59: 57: 
60: 58: #[cfg(feature = "miniserde")]
61: 59: mod miniserde {
62: 60:     use super::{SerializableData, Serializer};
63: 61:     use miniserde::{json, Deserialize, Serialize};
64: 62: 
65: 63:     /// A [`Serializer`] that serializes and deserializes using [`miniserde`].
66: 64:     pub struct Miniserde;
67: 65: 
68: 66:     impl Serializer for Miniserde {}
69: 67: 
70: 68:     impl<T> SerializableData<Miniserde> for T
71: 69:     where
72: 70:         T: Deserialize + Serialize,
73: 71:     {
74: 72:         type SerErr = ();
75: 73:         type DeErr = miniserde::Error;
76: 74: 
77: 75:         fn ser(&self) -> Result<String, Self::SerErr> {
78: 76:             Ok(json::to_string(&self))
79: 77:         }
80: 78: 
81: 79:         fn de(data: &str) -> Result<Self, Self::DeErr> {
82: 80:             json::from_str(data)
83: 81:         }
84: 82:     }
85: 83: }
86: 84: #[cfg(feature = "miniserde")]
87: 85: pub use miniserde::*;
88: 86: 
89: 87: #[cfg(feature = "serde-lite")]
90: 88: mod serde_lite {
91: 89:     use super::{SerializableData, Serializer};
92: 90:     use serde_lite::{Deserialize, Serialize};
93: 91:     use thiserror::Error;
94: 92: 
95: 93:     #[derive(Error, Debug)]
96: 94:     pub enum SerdeLiteError {
97: 95:         #[error("serde_lite error {0:?}")]
98: 96:         SerdeLite(serde_lite::Error),
99: 97:         #[error("serde_json error {0:?}")]
100: 98:         SerdeJson(serde_json::Error),
101: 99:     }
102: 100: 
103: 101:     impl From<serde_lite::Error> for SerdeLiteError {
104: 102:         fn from(value: serde_lite::Error) -> Self {
105: 103:             SerdeLiteError::SerdeLite(value)
106: 104:         }
107: 105:     }
108: 106: 
109: 107:     impl From<serde_json::Error> for SerdeLiteError {
110: 108:         fn from(value: serde_json::Error) -> Self {
111: 109:             SerdeLiteError::SerdeJson(value)
112: 110:         }
113: 111:     }
114: 112: 
115: 113:     /// A [`Serializer`] that serializes and deserializes using [`serde_lite`].
116: 114:     pub struct SerdeLite;
117: 115: 
118: 116:     impl Serializer for SerdeLite {}
119: 117: 
120: 118:     impl<T> SerializableData<SerdeLite> for T
121: 119:     where
122: 120:         T: Deserialize + Serialize,
123: 121:     {
124: 122:         type SerErr = SerdeLiteError;
125: 123:         type DeErr = SerdeLiteError;
126: 124: 
127: 125:         fn ser(&self) -> Result<String, Self::SerErr> {
128: 126:             let intermediate = self.serialize()?;
129: 127:             Ok(serde_json::to_string(&intermediate)?)
130: 128:         }
131: 129: 
132: 130:         fn de(data: &str) -> Result<Self, Self::DeErr> {
133: 131:             let intermediate = serde_json::from_str(data)?;
134: 132:             Ok(Self::deserialize(&intermediate)?)
135: 133:         }
136: 134:     }
137: 135: }
138: 136: #[cfg(feature = "serde-lite")]
139: 137: pub use serde_lite::*;
140: 138: 
141: 139: #[cfg(feature = "rkyv")]
142: 140: mod rkyv {
143: 141:     use super::{SerializableData, Serializer};
144: 142:     use base64::{engine::general_purpose::STANDARD_NO_PAD, Engine as _};
145: 143:     use rkyv::{
146: 144:         de::deserializers::SharedDeserializeMap,
147: 145:         ser::serializers::AllocSerializer,
148: 146:         validation::validators::DefaultValidator, Archive, CheckBytes,
149: 147:         Deserialize, Serialize,
150: 148:     };
151: 149:     use std::{error::Error, sync::Arc};
152: 150:     use thiserror::Error;
153: 151: 
154: 152:     /// A [`Serializer`] that serializes and deserializes using [`rkyv`].
155: 153:     pub struct Rkyv;
156: 154: 
157: 155:     impl Serializer for Rkyv {}
158: 156: 
159: 157:     #[derive(Error, Debug)]
160: 158:     pub enum RkyvError {
161: 159:         #[error("rkyv error {0:?}")]
162: 160:         Rkyv(Arc<dyn Error>),
163: 161:         #[error("base64 error {0:?}")]
164: 162:         Base64Decode(base64::DecodeError),
165: 163:     }
166: 164: 
167: 165:     impl From<Arc<dyn Error>> for RkyvError {
168: 166:         fn from(value: Arc<dyn Error>) -> Self {
169: 167:             RkyvError::Rkyv(value)
170: 168:         }
171: 169:     }
172: 170: 
173: 171:     impl From<base64::DecodeError> for RkyvError {
174: 172:         fn from(value: base64::DecodeError) -> Self {
175: 173:             RkyvError::Base64Decode(value)
176: 174:         }
177: 175:     }
178: 176: 
179: 177:     impl<T> SerializableData<Rkyv> for T
180: 178:     where
181: 179:         T: Serialize<AllocSerializer<1024>>,
182: 180:         T: Archive,
183: 181:         T::Archived: for<'b> CheckBytes<DefaultValidator<'b>>
184: 182:             + Deserialize<T, SharedDeserializeMap>,
185: 183:     {
186: 184:         type SerErr = RkyvError;
187: 185:         type DeErr = RkyvError;
188: 186: 
189: 187:         fn ser(&self) -> Result<String, Self::SerErr> {
190: 188:             let bytes = rkyv::to_bytes::<T, 1024>(self)
191: 189:                 .map_err(|e| Arc::new(e) as Arc<dyn Error>)?;
192: 190:             Ok(STANDARD_NO_PAD.encode(bytes))
193: 191:         }
194: 192: 
195: 193:         fn de(data: &str) -> Result<Self, Self::DeErr> {
196: 194:             let bytes = STANDARD_NO_PAD.decode(data.as_bytes())?;
197: 195:             Ok(rkyv::from_bytes::<T>(&bytes)
198: 196:                 .map_err(|e| Arc::new(e) as Arc<dyn Error>)?)
199: 197:         }
200: 198:     }
201: 199: }
202: 200: 
203: 201: #[cfg(feature = "rkyv")]
204: 202: pub use rkyv::*;
205: 203: 
206: 204: #[cfg(feature = "serde-wasm-bindgen")]
207: 205: mod serde_wasm_bindgen {
208: 206:     use super::{SerializableData, Serializer};
209: 207:     use serde::{de::DeserializeOwned, Serialize};
210: 208: 
211: 209:     /// A [`Serializer`] that serializes using [`serde_json`] and deserializes using
212: 210:     /// [`serde-wasm-bindgen`].
213: 211:     pub struct SerdeWasmBindgen;
214: 212: 
215: 213:     impl Serializer for SerdeWasmBindgen {}
216: 214: 
217: 215:     impl<T> SerializableData<SerdeWasmBindgen> for T
218: 216:     where
219: 217:         T: DeserializeOwned + Serialize,
220: 218:     {
221: 219:         type SerErr = serde_json::Error;
222: 220:         type DeErr = wasm_bindgen::JsValue;
223: 221: 
224: 222:         fn ser(&self) -> Result<String, Self::SerErr> {
225: 223:             serde_json::to_string(&self)
226: 224:         }
227: 225: 
228: 226:         fn de(data: &str) -> Result<Self, Self::DeErr> {
229: 227:             let json = js_sys::JSON::parse(data)?;
230: 228:             serde_wasm_bindgen::from_value(json).map_err(Into::into)
231: 229:         }
232: 230:     }
233: 231: }
234: 232: 
235: 233: #[cfg(feature = "serde-wasm-bindgen")]
236: 234: pub use serde_wasm_bindgen::*;
237: ```
```
