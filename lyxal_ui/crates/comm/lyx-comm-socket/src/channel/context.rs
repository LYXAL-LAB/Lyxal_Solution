### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-socket\src\channel\context.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-socket\src\channel\context.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\context.rs
54: 52: ```rust
55: 53: use std::{collections::HashMap, sync::Arc};
56: 54: 
57: 55: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
58: 56: use lyx-core-lyx_core_lyx_logic_use::core::ConnectionReadyState;
59: 57: use serde::Serialize;
60: 58: use serde_json::Value;
61: 59: 
62: 60: use crate::{ChannelMsg, SocketMsg};
63: 61: 
64: 62: type SendFn = StoredValue<Arc<dyn Fn(&ChannelMsg) + Send + Sync + 'static>>;
65: 63: type SimpleFn = StoredValue<Arc<dyn Fn() + Send + Sync + 'static>>;
66: 64: 
67: 65: /// The context to be used for sending and subscribing to messages in your component.
68: 66: /// You probably don't want to use this directly, but rather use the `expect_socket_context` hook.
69: 67: #[derive(Copy, Clone)]
70: 68: #[allow(dead_code)]
71: 69: pub struct SocketContext {
72: 70:     pub(crate) ready_state: Signal<ConnectionReadyState>,
73: 71:     pub(crate) send: SendFn,
74: 72:     pub(crate) open: SimpleFn,
75: 73:     pub(crate) close: SimpleFn,
76: 74:     pub(crate) message: Signal<Option<ChannelMsg>>,
77: 75:     effect_stops: StoredValue<HashMap<Value, Box<dyn Fn() + Send + Sync + 'static>>>,
78: 76:     subscribers: StoredValue<HashMap<Value, Arc<dyn Fn() + Send + Sync>>>,
79: 77: }
80: 78: 
81: 79: // #[cfg(not(feature = "ssr"))]
82: 80: impl SocketContext {
83: 81:     fn new(query: String) -> Self {
84: 82:         use crate::WEBSOCKET_CHANNEL_URL;
85: 83:         use lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::codee::string::JsonSerdeCodec;
86: 84:         use lyx-core-lyx_core_lyx_logic_use::{
87: 85:             ReconnectLimit, UseWebSocketOptions, UseWebSocketReturn, use_websocket_with_options,
88: 86:         };
89: 87: 
90: 88:         let query = if query.is_empty() {
91: 89:             String::new()
92: 90:         } else {
93: 91:             format!("?{query}")
94: 92:         };
95: 93:         let url = format!("{WEBSOCKET_CHANNEL_URL}{query}");
96: 94: 
97: 95:         let UseWebSocketReturn {
98: 96:             message,
99: 97:             send,
100: 98:             ready_state,
101: 99:             open,
102: 100:             close,
103: 101:             ..
104: 102:         } = use_websocket_with_options::<ChannelMsg, ChannelMsg, JsonSerdeCodec, _, _>(
105: 103:             &url,
106: 104:             UseWebSocketOptions::default()
107: 105:                 .reconnect_limit(ReconnectLimit::Infinite)
108: 106:                 .on_error(|error| {
109: 107:                     lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("WebSocket error: {}", error);
110: 108:                 }),
111: 109:         );
112: 110: 
113: 111:         Self {
114: 112:             message,
115: 113:             send: StoredValue::new(Arc::new(send)),
116: 114:             ready_state,
117: 115:             open: StoredValue::new(Arc::new(open)),
118: 116:             close: StoredValue::new(Arc::new(close)),
119: 117:             effect_stops: StoredValue::new(HashMap::new()),
120: 118:             subscribers: StoredValue::new(HashMap::new()),
121: 119:         }
122: 120:     }
123: 121: 
124: 122:     /// Disconnects and re-connects the WebSocket. This helps if you want to reset the context on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
125: 123:     /// For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, you can use this method to update the websocket handler context when the user logs out or in.
126: 124:     pub fn reconnect(&self) {
127: 125:         #[cfg(not(feature = "ssr"))]
128: 126:         {
129: 127:             for (_, stop) in self.effect_stops.write_value().drain() {
130: 128:                 stop();
131: 129:             }
132: 130: 
133: 131:             self.close.get_value()();
134: 132:             self.open.get_value()();
135: 133: 
136: 134:             for (key, subscriber) in &*self.subscribers.read_value() {
137: 135:                 self.subscribe_effect(key.clone(), Arc::clone(subscriber));
138: 136:             }
139: 137:         }
140: 138:     }
141: 139: 
142: 140:     /// When someone sends a message with the given key, the handler will be called.
143: 141:     pub fn subscribe<Msg>(self, key_value: Msg::Key, handler: impl Fn(&Msg) + Send + Sync + 'static)
144: 142:     where
145: 143:         Msg: SocketMsg + serde::Serialize + Clone,
146: 144:         for<'de> Msg: serde::Deserialize<'de>,
147: 145:         Msg::Key: serde::Serialize,
148: 146:         for<'de> Msg::Key: serde::Deserialize<'de>,
149: 147:     {
150: 148:         #[cfg(feature = "ssr")]
151: 149:         {
152: 150:             let _ = key_value;
153: 151:             let _ = handler;
154: 152:         }
155: 153: 
156: 154:         #[cfg(not(feature = "ssr"))]
157: 155:         {
158: 156:             let key_value = serde_json::to_value(key_value)
159: 157:                 .map_err(|err| {
160: 158:                     lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Failed to serialize key: {}", err);
161: 159:                 })
162: 160:                 .unwrap();
163: 161: 
164: 162:             let handler = {
165: 163:                 let key_value = key_value.clone();
166: 164: 
167: 165:                 Arc::new(move || {
168: 166:                     if let Some(msg) = self.message.read().as_ref() {
169: 167:                         match msg {
170: 168:                             ChannelMsg::Msg { msg, key } if &key_value == key => {
171: 169:                                 match serde_json::from_value(msg.clone()) {
172: 170:                                     Err(err) => {
173: 171:                                         lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!(
174: 172:                                             "Failed to deserialize message: {}",
175: 173:                                             err
176: 174:                                         );
177: 175:                                     }
178: 176:                                     Ok(msg) => {
179: 177:                                         handler(&msg);
180: 178:                                     }
181: 179:                                 }
182: 180:                             }
183: 181:                             _ => (),
184: 182:                         }
185: 183:                     }
186: 184:                 }) as Arc<dyn Fn() + Send + Sync>
187: 185:             };
188: 186: 
189: 187:             self.subscribers
190: 188:                 .write_value()
191: 189:                 .insert(key_value.clone(), Arc::clone(&handler));
192: 190:             self.subscribe_effect(key_value, handler);
193: 191:         }
194: 192:     }
195: 193: 
196: 194:     #[cfg(not(feature = "ssr"))]
197: 195:     fn subscribe_effect(self, key_value: Value, handler: Arc<dyn Fn() + Send + Sync>) {
198: 196:         Effect::new({
199: 197:             let key_value = key_value.clone();
200: 198: 
201: 199:             move || {
202: 200:                 if self.ready_state.get() == ConnectionReadyState::Open {
203: 201:                     self.send.get_value()(&ChannelMsg::Subscribe {
204: 202:                         key: key_value.clone(),
205: 203:                     });
206: 204:                 }
207: 205:             }
208: 206:         });
209: 207: 
210: 208:         on_cleanup({
211: 209:             let key_value = key_value.clone();
212: 210: 
213: 211:             move || {
214: 212:                 self.unsubscribe(key_value);
215: 213:             }
216: 214:         });
217: 215: 
218: 216:         let effect = Effect::new(move || handler());
219: 217: 
220: 218:         self.effect_stops
221: 219:             .write_value()
222: 220:             .insert(key_value, Box::new(move || effect.stop()));
223: 221:     }
224: 222: 
225: 223:     /// Stop listening for messages with the given key.
226: 224:     pub fn unsubscribe<Key>(self, key: Key)
227: 225:     where
228: 226:         Key: serde::Serialize,
229: 227:     {
230: 228:         #[cfg(feature = "ssr")]
231: 229:         {
232: 230:             let _ = key;
233: 231:         }
234: 232: 
235: 233:         #[cfg(not(feature = "ssr"))]
236: 234:         {
237: 235:             let key_value = serde_json::to_value(key)
238: 236:                 .map_err(|err| {
239: 237:                     lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Failed to serialize key: {}", err);
240: 238:                 })
241: 239:                 .unwrap();
242: 240: 
243: 241:             self.effect_stops.write_value().remove(&key_value);
244: 242:             self.subscribers.write_value().remove(&key_value);
245: 243: 
246: 244:             self.send.get_value()(&ChannelMsg::Unsubscribe { key: key_value });
247: 245:         }
248: 246:     }
249: 247: 
250: 248:     /// Broadcast a message to all subscribers of the given key.
251: 249:     pub fn send<Msg>(self, key: Msg::Key, msg: Msg)
252: 250:     where
253: 251:         Msg: SocketMsg + serde::Serialize + Clone,
254: 252:         for<'de> Msg: serde::Deserialize<'de>,
255: 253:         Msg::Key: serde::Serialize,
256: 254:         for<'de> Msg::Key: serde::Deserialize<'de>,
257: 255:     {
258: 256:         #[cfg(feature = "ssr")]
259: 257:         {
260: 258:             let _ = key;
261: 259:             let _ = msg;
262: 260:         }
263: 261: 
264: 262:         #[cfg(not(feature = "ssr"))]
265: 263:         {
266: 264:             let key_value = serde_json::to_value(key)
267: 265:                 .map_err(|err| {
268: 266:                     lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Failed to serialize key: {}", err);
269: 267:                 })
270: 268:                 .unwrap();
271: 269: 
272: 270:             let msg_value = serde_json::to_value(msg)
273: 271:                 .map_err(|err| {
274: 272:                     lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Failed to serialize message: {}", err);
275: 273:                 })
276: 274:                 .unwrap();
277: 275: 
278: 276:             self.send.get_value()(&ChannelMsg::Msg {
279: 277:                 msg: msg_value,
280: 278:                 key: key_value,
281: 279:             });
282: 280:         }
283: 281:     }
284: 282: }
285: 283: 
286: 284: /// Call this in your root component to provide the socket context.
287: 285: #[inline(always)]
288: 286: pub fn provide_socket_context() -> SocketContext {
289: 287:     if let Some(ctx) = use_context::<SocketContext>() {
290: 288:         ctx
291: 289:     } else {
292: 290:         let ctx = SocketContext::new("".to_string());
293: 291:         provide_context(ctx);
294: 292:         ctx
295: 293:     }
296: 294: }
297: 295: 
298: 296: /// Call this in your root component to provide the socket context.
299: 297: ///
300: 298: /// ## Example
301: 299: ///
302: 300: /// ```ignore
303: 301: /// provide_socket_context_with_query(&[("user_id", "123456789")]);
304: 302: /// ```
305: 303: #[inline(always)]
306: 304: pub fn provide_socket_context_with_query<T: Serialize + ?Sized>(query: &T) -> SocketContext {
307: 305:     let query_string = serde_urlencoded::to_string(query).expect("Failed to serialize query");
308: 306:     let ctx = SocketContext::new(query_string);
309: 307:     provide_context(ctx);
310: 308:     ctx
311: 309: }
312: 310: 
313: 311: /// Call this when you want to subscribe or send a message in your component.
314: 312: #[inline(always)]
315: 313: pub fn expect_socket_context() -> SocketContext {
316: 314:     expect_context()
317: 315: }
318: 316: 
319: 317: /// Call this when you want to subscribe or send a message in your component.
320: 318: #[inline(always)]
321: 319: pub fn use_socket_context() -> Option<SocketContext> {
322: 320:     use_context()
323: 321: }
324: 322: ```
325: 323: ```
326: 324: ```
327: 325: ```
328: 326: ```
329: 327: ```
330: 328: ```
331: 329: ```
332: 330: ```
333: 331: ```
334: 332: ```
335: 333: ```
336: 334: ```
337: 335: ```
338: 336: ```
339: 337: ```
340: 338: ```
341: 339: ```
342: 340: ```
343: 341: ```
344: 342: ```
345: 343: ```
346: 344: ```
347: 345: ```
348: 346: ```
349: 347: ```
350: ```
```
