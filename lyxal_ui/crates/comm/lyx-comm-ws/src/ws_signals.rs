1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-ws\src\ws_signals.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\ws_signals.rs
54: 52: ```rust
55: 53: use std::sync::Arc;
56: 54: 
57: 55: use crate::error::Error;
58: 56: use crate::messages::Messages;
59: 57: use crate::messages::SignalUpdate;
60: 58: use crate::traits::ChannelSignalTrait;
61: 59: use crate::traits::WsSignalCore;
62: 60: use dashmap::DashMap;
63: 61: use dashmap::mapref::entry::Entry;
64: 62: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
65: 63: use serde_json::Value;
66: 64: use tokio::sync::broadcast::Receiver;
67: 65: 
68: 66: #[derive(Clone)]
69: 67: pub struct WsSignals {
70: 68:     signals: Arc<DashMap<String, Arc<dyn WsSignalCore + Send + Sync + 'static>>>,
71: 69:     channels: Arc<DashMap<String, Arc<dyn ChannelSignalTrait + Send + Sync + 'static>>>,
72: 70: }
73: 71: 
74: 72: impl WsSignals {
75: 73:     pub fn new() -> Self {
76: 74:         let signals = Arc::new(DashMap::new());
77: 75:         let channels = Arc::new(DashMap::new());
78: 76:         Self { signals, channels }
79: 77:     }
80: 78: 
81: 79:     pub fn create_signal<T>(&mut self, name: &str, value: T, msg: &Messages) -> Result<(), Error>
82: 80:     where
83: 81:         T: WsSignalCore + Send + Sync + Clone + 'static,
84: 82:     {
85: 83:         #[cfg(any(feature = "csr", feature = "hydrate"))]
86: 84:         {
87: 85:             use crate::ServerSignalWebSocket;
88: 86: 
89: 87:             let ws = use_context::<ServerSignalWebSocket>().ok_or(Error::MissingServerSignals)?;
90: 88: 
91: 89:             match self.signals.entry(name.to_owned()) {
92: 90:                 Entry::Vacant(entry) => {
93: 91:                     entry.insert(Arc::new(value));
94: 92:                     ws.send(msg)?;
95: 93:                     Ok(())
96: 94:                 }
97: 95:                 Entry::Occupied(_) => Err(Error::AddingSignalFailed),
98: 96:             }
99: 97:         }
100: 98: 
101: 99:         #[cfg(all(feature = "ssr", not(any(feature = "hydrate", feature = "csr"))))]
102: 100:         {
103: 101:             match self.signals.entry(name.to_owned()) {
104: 102:                 Entry::Vacant(entry) => {
105: 103:                     entry.insert(Arc::new(value));
106: 104:                     Ok(())
107: 105:                 }
108: 106:                 Entry::Occupied(_) => Err(Error::AddingSignalFailed),
109: 107:             }
110: 108:         }
111: 109:         #[cfg(not(any(feature = "ssr", feature = "hydrate", feature = "csr")))]
112: 110:         return Err(Error::AddingSignalFailed);
113: 111:     }
114: 112: 
115: 113:     pub fn create_channel<T>(&mut self, name: &str, value: T, msg: &Messages) -> Result<(), Error>
116: 114:     where
117: 115:         T: ChannelSignalTrait + Send + Sync + Clone + 'static,
118: 116:     {
119: 117:         #[cfg(any(feature = "csr", feature = "hydrate"))]
120: 118:         {
121: 119:             use crate::ServerSignalWebSocket;
122: 120: 
123: 121:             let ws = use_context::<ServerSignalWebSocket>().ok_or(Error::MissingServerSignals)?;
124: 122: 
125: 123:             match self.channels.entry(name.to_owned()) {
126: 124:                 Entry::Vacant(entry) => {
127: 125:                     entry.insert(Arc::new(value));
128: 126:                     ws.send(msg)?;
129: 127:                     Ok(())
130: 128:                 }
131: 129:                 Entry::Occupied(_) => Err(Error::AddingSignalFailed),
132: 130:             }
133: 131:         }
134: 132: 
135: 133:         #[cfg(all(feature = "ssr", not(any(feature = "hydrate", feature = "csr"))))]
136: 134:         {
137: 135:             match self.channels.entry(name.to_owned()) {
138: 136:                 Entry::Vacant(entry) => {
139: 137:                     entry.insert(Arc::new(value));
140: 138:                     Ok(())
141: 139:                 }
142: 140:                 Entry::Occupied(_) => Err(Error::AddingSignalFailed),
143: 141:             }
144: 142:         }
145: 143:         #[cfg(not(any(feature = "ssr", feature = "hydrate", feature = "csr")))]
146: 144:         return Err(Error::AddingSignalFailed);
147: 145:     }
148: 146: 
149: 147:     pub fn get_signal<T: Clone + 'static>(&mut self, name: &str) -> Option<T> {
150: 148:         self.signals
151: 149:             .get_mut(name)
152: 150:             .map(|value| value.as_any().downcast_ref::<T>().unwrap().clone())
153: 151:     }
154: 152: 
155: 153:     pub fn get_channel<T: Clone + 'static>(&mut self, name: &str) -> Option<T> {
156: 154:         self.channels
157: 155:             .get_mut(name)
158: 156:             .map(|value| value.as_any().downcast_ref::<T>().unwrap().clone())
159: 157:     }
160: 158: 
161: 159:     pub fn contains(&self, name: &str) -> bool {
162: 160:         self.signals.contains_key(name)
163: 161:     }
164: 162: 
165: 163:     pub fn add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&self, name: &str) -> Option<Receiver<(Option<String>, Messages)>> {
166: 164:         self.signals
167: 165:             .get(name)
168: 166:             .and_then(|v| v.value().subscribe().ok())
169: 167:     }
170: 168: 
171: 169:     pub fn add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_channel(&self, name: &str) -> Option<Receiver<(Option<String>, Messages)>> {
172: 170:         self.channels
173: 171:             .get(name)
174: 172:             .and_then(|v| v.value().subscribe().ok())
175: 173:     }
176: 174: 
177: 175:     pub fn handle_message(&self, name: &str, message: Value) -> Option<Result<(), Error>> {
178: 176:         self.channels.get(name).map(|v| v.handle_message(message))
179: 177:     }
180: 178: 
181: 179:     pub fn json(&self, name: &str) -> Option<Result<Value, Error>> {
182: 180:         self.signals.get(name).map(|v| v.json())
183: 181:     }
184: 182:     pub async fn update(
185: 183:         &self,
186: 184:         name: &str,
187: 185:         patch: SignalUpdate,
188: 186:         id: Option<String>,
189: 187:     ) -> Option<Result<(), Error>> {
190: 188:         match self.signals.get_mut(name) {
191: 189:             Some(value) => Some(value.update_json(patch.get_patch(), id).await),
192: 190:             None => None,
193: 191:         }
194: 192:     }
195: 193: 
196: 194:     pub fn set_json(&self, name: &str, new_value: Value) -> Option<Result<(), Error>> {
197: 195:         self.signals
198: 196:             .get_mut(name)
199: 197:             .map(|value| value.set_json(new_value))
200: 198:     }
201: 199: 
202: 200:     pub fn delete_signal(&mut self, name: &str) -> Result<(), Error> {
203: 201:         if let Some(signal) = self.signals.remove(name) {
204: 202:             signal.1.delete()?;
205: 203:             return Ok(());
206: 204:         }
207: 205:         Err(Error::DeletingSignalFailed)
208: 206:     }
209: 207: 
210: 208:     pub fn delete_channel(&mut self, name: &str) -> Result<(), Error> {
211: 209:         if let Some(signal) = self.channels.remove(name) {
212: 210:             signal.1.delete();
213: 211:             return Ok(());
214: 212:         }
215: 213:         Err(Error::DeletingChannelHandlerFailed)
216: 214:     }
217: 215: 
218: 216:     pub fn get_reconnect_messages(&self) -> Vec<Messages> {
219: 217:         let mut messages = Vec::new();
220: 218:         for data in self.signals.iter() {
221: 219:             if let Ok(message) = data.on_reconnect_message() {
222: 220:                 messages.push(message);
223: 221:             }
224: 222:         }
225: 223: 
226: 224:         for data in self.channels.iter() {
227: 225:             if let Ok(message) = data.on_reconnect_message() {
228: 226:                 messages.push(message);
229: 227:             }
230: 228:         }
231: 229:         messages
232: 230:     }
233: 231: }
234: 232: ```
235: 233: ```
236: 234: ```
237: 235: ```
238: 236: ```
239: 237: ```
240: 238: ```
241: 239: ```
242: 240: ```
243: 241: ```
244: 242: ```
245: 243: ```
246: 244: ```
247: 245: ```
248: 246: ```
249: 247: ```
250: 248: ```
251: 249: ```
252: 250: ```
253: 251: ```
254: 252: ```
255: 253: ```
256: 254: ```
257: 255: ```
258: 256: ```
259: 257: ```
260: ```
```

