1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-ws\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
54: 52: ```rust
55: 53: #![doc = include_str!("../README.md")]
56: 54: #![warn(clippy::pedantic)]
57: 55: #![warn(clippy::nursery)]
58: 56: 
59: 57: // #![feature(unboxed_closures)]
60: 58: use crate::messages::ServerSignalMessage;
61: 59: #[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
62: 60: pub use bidirectional::BiDirectionalSignal;
63: 61: #[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
64: 62: pub use channel::ChannelSignal;
65: 63: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
66: 64:     prelude::*,
67: 65:     lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{BoxedStream, Websocket, codec::JsonEncoding},
68: 66:     task::spawn_local,
69: 67: };
70: 68: use messages::{BiDirectionalMessage, ChannelMessage, Messages};
71: 69: #[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
72: 70: pub use read_only::ReadOnlySignal;
73: 71: 
74: 72: use std::sync::{Arc, Mutex};
75: 73: pub use ws_signals::WsSignals;
76: 74: mod bidirectional;
77: 75: mod channel;
78: 76: pub mod error;
79: 77: pub mod messages;
80: 78: mod read_only;
81: 79: mod ws_signals;
82: 80: 
83: 81: pub mod traits;
84: 82: 
85: 83: #[cfg(any(feature = "csr", feature = "hydrate"))]
86: 84: #[derive(Clone)]
87: 85: pub struct ServerSignalWebSocket {
88: 86:     send: Arc<Mutex<Sender<Result<Messages, ServerFnError>>>>,
89: 87:     delayed_msgs: Arc<Mutex<Vec<Messages>>>,
90: 88:     on_disconnect: Arc<Mutex<Option<Box<dyn Fn() + Send + Sync>>>>,
91: 89:     on_reconnect: Arc<Mutex<Option<Box<dyn Fn() + Send + Sync>>>>,
92: 90:     on_connect: Arc<Mutex<Option<Box<dyn Fn() + Send + Sync>>>>,
93: 91: }
94: 92: #[cfg(any(feature = "csr", feature = "hydrate"))]
95: 93: impl ServerSignalWebSocket {
96: 94:     pub fn send(&self, msg: &Messages) -> Result<(), serde_json::Error> {
97: 95:         // Try to send the message immediately. If the send fails (channel closed or full),
98: 96:         // push it onto the delayed queue to be flushed when a reconnect succeeds.
99: 97:         let cloned = msg.to_owned();
100: 98:         if let Ok(mut lock) = self.send.lock() {
101: 99:             if lock.try_send(Ok(cloned)).is_err() {
102: 100:                 // queue for later
103: 101:                 if let Ok(mut delayed) = self.delayed_msgs.lock() {
104: 102:                     delayed.push(msg.to_owned());
105: 103:                 }
106: 104:             }
107: 105:         } else {
108: 106:             // couldn't lock send - queue the message
109: 107:             if let Ok(mut delayed) = self.delayed_msgs.lock() {
110: 108:                 delayed.push(msg.to_owned());
111: 109:             }
112: 110:         }
113: 111:         Ok(())
114: 112:     }
115: 113: 
116: 114:     #[must_use]
117: 115:     pub fn new() -> Self {
118: 116:         Self::default()
119: 117:     }
120: 118: 
121: 119:     /// Set a callback to be called when the websocket connection is lost.
122: 120:     /// # Panics
123: 121:     /// Panics if the lock is poisoned.
124: 122:     pub fn set_on_disconnect(&self, on_disconnect: impl Fn() + Send + Sync + 'static) {
125: 123:         *self.on_disconnect.lock().unwrap() = Some(Box::new(on_disconnect));
126: 124:     }
127: 125: 
128: 126:     /// Set a callback to be called when the websocket connection is reestablished.
129: 127:     /// # Panics
130: 128:     /// Panics if the lock is poisoned.
131: 129:     pub fn set_on_reconnect(&self, on_reconnect: impl Fn() + Send + Sync + 'static) {
132: 130:         *self.on_reconnect.lock().unwrap() = Some(Box::new(on_reconnect));
133: 131:     }
134: 132: 
135: 133:     /// Set a callback to be called when the websocket connection is first established.
136: 134:     /// # Panics
137: 135:     /// Panics if the lock is poisoned.
138: 136:     pub fn set_on_connect(&self, on_connect: impl Fn() + Send + Sync + 'static) {
139: 137:         *self.on_connect.lock().unwrap() = Some(Box::new(on_connect));
140: 138:     }
141: 139: }
142: 140: #[cfg(any(feature = "csr", feature = "hydrate"))]
143: 141: impl Default for ServerSignalWebSocket {
144: 142:     fn default() -> Self {
145: 143:         let (initial_tx, _initial_rx) = mpsc::channel(0);
146: 144: 
147: 145:         let delayed_msgs: Arc<Mutex<Vec<Messages>>> = Arc::new(Mutex::new(Vec::new()));
148: 146:         let send = Arc::new(Mutex::new(initial_tx));
149: 147:         let state_signals = WsSignals::new();
150: 148:         let id = Arc::new(String::new());
151: 149:         let on_disconnect = Arc::new(Mutex::new(None::<Box<dyn Fn() + Send + Sync + 'static>>));
152: 150:         let on_reconnect = Arc::new(Mutex::new(None::<Box<dyn Fn() + Send + Sync + 'static>>));
153: 151:         let on_connect = Arc::new(Mutex::new(None::<Box<dyn Fn() + Send + Sync + 'static>>));
154: 152:         let first_connect = Arc::new(Mutex::new(true));
155: 153:         {
156: 154:             let on_disconnect = on_disconnect.clone();
157: 155:             let on_reconnect = on_reconnect.clone();
158: 156:             let on_connect = on_connect.clone();
159: 157:             let mut state_signals = state_signals.clone();
160: 158:             let delayed_msgs = delayed_msgs.clone();
161: 159:             let send_arc = send.clone();
162: 160:             let first_connect = first_connect.clone();
163: 161:             spawn_local(async move {
164: 162:                 use std::time::Duration;
165: 163:                 loop {
166: 164:                     // create a fresh channel for this connection attempt
167: 165:                     let (tx, rx) = mpsc::channel(32);
168: 166: 
169: 167:                     // swap in the new sender so callers will use it
170: 168:                     if let Ok(mut guard) = send_arc.lock() {
171: 169:                         *guard = tx.clone();
172: 170:                     }
173: 171: 
174: 172:                     match lyx-comm-ws_websocket(rx.into()).await {
175: 173:                         Ok(mut messages) => {
176: 174:                             // flush any delayed messages onto the new sender
177: 175:                             if let Ok(mut delayed) = delayed_msgs.lock() {
178: 176:                                 for msg in delayed.drain(..) {
179: 177:                                     // ignore errors here; if it fails, re-queue below on next loop
180: 178:                                     let _ = tx.clone().try_send(Ok(msg));
181: 179:                                 }
182: 180:                             }
183: 181: 
184: 182:                             let mut first = first_connect.lock().unwrap();
185: 183:                             let is_first_connect = *first;
186: 184:                             if *first {
187: 185:                                 *first = false;
188: 186:                             }
189: 187:                             drop(first);
190: 188: 
191: 189:                             if !is_first_connect {
192: 190:                                 for message in state_signals.get_reconnect_messages() {
193: 191:                                     let _ = tx.clone().try_send(Ok(message));
194: 192:                                 }
195: 193:                             }
196: 194: 
197: 195:                             // Fire lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate connection callback
198: 196:                             if is_first_connect {
199: 197:                                 if let Some(ref on_connect) = *on_connect.lock().unwrap() {
200: 198:                                     on_connect();
201: 199:                                 }
202: 200:                             }
203: 201: 
204: 202:                             let mut first_message_received = false;
205: 203:                             while let Some(msg) = messages.next().await {
206: 204:                                 let Ok(msg) = msg else {
207: 205:                                     continue;
208: 206:                                 };
209: 207: 
210: 208:                                 // Fire on_reconnect after first successful message (confirms connection is working)
211: 209:                                 if !first_message_received && !is_first_connect {
212: 210:                                     if let Some(ref on_reconnect) = *on_reconnect.lock().unwrap() {
213: 211:                                         on_reconnect();
214: 212:                                     }
215: 213:                                     first_message_received = true;
216: 214:                                 }
217: 215: 
218: 216:                                 match msg {
219: 217:                                     Messages::ServerSignal(lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg) => match lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg {
220: 218:                                         ServerSignalMessage::Establish(_) => {
221: 219:                                             // Usually lyx-core-lyx_core_lyx-core-lyx_core_client-to-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server message, ignore if received
222: 220:                                         }
223: 221:                                         ServerSignalMessage::EstablishResponse((name, value)) => {
224: 222:                                             state_signals.set_json(&name, value);
225: 223:                                         }
226: 224:                                         ServerSignalMessage::Update(update) => {
227: 225:                                             spawn_local({
228: 226:                                                 let state_signals = state_signals.clone();
229: 227:                                                 async move {
230: 228:                                                     state_signals
231: 229:                                                         .update(
232: 230:                                                             &update.get_name().clone(),
233: 231:                                                             update,
234: 232:                                                             None,
235: 233:                                                         )
236: 234:                                                         .await;
237: 235:                                                 }
238: 236:                                             });
239: 237:                                         }
240: 238:                                         ServerSignalMessage::Delete(name) => {
241: 239:                                             let _ = state_signals.delete_signal(&name);
242: 240:                                         }
243: 241:                                     },
244: 242:                                     Messages::BiDirectional(bidirectional) => match bidirectional {
245: 243:                                         BiDirectionalMessage::Establish(_) => {
246: 244:                                             // Usually lyx-core-lyx_core_lyx-core-lyx_core_client-to-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server message, ignore if received
247: 245:                                         }
248: 246:                                         BiDirectionalMessage::EstablishResponse((name, value)) => {
249: 247:                                             state_signals.set_json(&name, value);
250: 248:                                             let recv = state_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&name).unwrap();
251: 249:                                             spawn_local(handle_broadcasts_lyx-core-lyx_core_lyx-core-lyx_core_client(recv, tx.clone()));
252: 250:                                         }
253: 251:                                         BiDirectionalMessage::Update(update) => {
254: 252:                                             spawn_local({
255: 253:                                                 let state_signals = state_signals.clone();
256: 254:                                                 let id = id.clone();
257: 255:                                                 async move {
258: 256:                                                     state_signals
259: 257:                                                         .update(
260: 258:                                                             &update.get_name().clone(),
261: 259:                                                             update,
262: 260:                                                             Some(id.to_string()),
263: 261:                                                         )
264: 262:                                                         .await;
265: 263:                                                 }
266: 264:                                             });
267: 265:                                         }
268: 266:                                         BiDirectionalMessage::Delete(name) => {
269: 267:                                             let _ = state_signals.delete_signal(&name);
270: 268:                                         }
271: 269:                                     },
272: 270:                                     Messages::Channel(channel) => match channel {
273: 271:                                         ChannelMessage::Establish(_) => {
274: 272:                                             // Usually lyx-core-lyx_core_lyx-core-lyx_core_client-to-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server message, ignore if received
275: 273:                                         }
276: 274:                                         ChannelMessage::EstablishResponse(name) => {
277: 275:                                             let recv =
278: 276:                                                 state_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_channel(&name).unwrap();
279: 277:                                             spawn_local(handle_broadcasts_lyx-core-lyx_core_lyx-core-lyx_core_client(recv, tx.clone()));
280: 278:                                         }
281: 279:                                         ChannelMessage::Message(name, value) => {
282: 280:                                             state_signals.handle_message(&name, value);
283: 281:                                         }
284: 282:                                         ChannelMessage::Delete(name) => {
285: 283:                                             let _ = state_signals.delete_channel(&name);
286: 284:                                         }
287: 285:                                     },
288: 286:                                 }
289: 287:                             }
290: 288:                         }
291: 289:                         Err(e) => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("{e}"),
292: 290:                     }
293: 291:                     if let Some(ref on_disconnect) = *on_disconnect.lock().unwrap() {
294: 292:                         on_disconnect();
295: 293:                     }
296: 294:                     // connection lost - wait and retry
297: 295:                     gloo_timers::future::sleep(Duration::from_secs(1)).await;
298: 296:                 }
299: 297:             });
300: 298:         }
301: 299: 
302: 300:         let ws_lyx-core-lyx_core_lyx-core-lyx_core_client = Self {
303: 301:             send,
304: 302:             delayed_msgs,
305: 303:             on_disconnect,
306: 304:             on_reconnect,
307: 305:             on_connect,
308: 306:         };
309: 307: 
310: 308:         // Provide ClientSignals for Child Components to work
311: 309:         provide_context(state_signals);
312: 310: 
313: 311:         ws_lyx-core-lyx_core_lyx-core-lyx_core_client
314: 312:     }
315: 313: }
316: 314: 
317: 315: #[cfg(any(feature = "csr", feature = "hydrate"))]
318: 316: #[inline]
319: 317: fn provide_websocket_inner() -> Option<()> {
320: 318:     if use_context::<ServerSignalWebSocket>().is_none() {
321: 319:         provide_context(ServerSignalWebSocket::new());
322: 320:     }
323: 321:     Some(())
324: 322: }
325: 323: 
326: 324: #[allow(clippy::unused_async)]
327: 325: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(protocol = Websocket<JsonEncoding, JsonEncoding>,endpoint="lyx-comm-ws_websocket")]
328: 326: pub async fn lyx-comm-ws_websocket(
329: 327:     input: BoxedStream<Messages, ServerFnError>,
330: 328: ) -> Result<BoxedStream<Messages, ServerFnError>, ServerFnError> {
331: 329:     use futures::{SinkExt, StreamExt, channel::mpsc};
332: 330:     let mut input = input;
333: 331:     let (mut tx, rx) = mpsc::channel(1);
334: 332:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals = use_context::<WsSignals>().unwrap();
335: 333:     let id = Arc::new(nanoid::nanoid!());
336: 334:     // spawn a task to listen to the input stream of messages coming in over the websocket
337: 335:     tokio::spawn(async move {
338: 336:         while let Some(msg) = input.next().await {
339: 337:             let Ok(msg) = msg else {
340: 338:                 break;
341: 339:             };
342: 340:             match msg {
343: 341:                 Messages::ServerSignal(lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg) => match lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg {
344: 342:                     ServerSignalMessage::Establish(name) => {
345: 343:                         let recv = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&name).unwrap();
346: 344:                         tx.send(Ok(Messages::ServerSignal(
347: 345:                             ServerSignalMessage::EstablishResponse((
348: 346:                                 name.clone(),
349: 347:                                 lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.json(&name).unwrap().unwrap(),
350: 348:                             )),
351: 349:                         )))
352: 350:                         .await
353: 351:                         .unwrap();
354: 352:                         tokio::spawn(handle_broadcasts(id.to_string(), recv, tx.clone()));
355: 353:                     }
356: 354:                     _ => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Unexpected lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signal message from lyx-core-lyx_core_lyx-core-lyx_core_client"),
357: 355:                 },
358: 356:                 Messages::BiDirectional(bidirectional) => match bidirectional {
359: 357:                     BiDirectionalMessage::Establish(name) => {
360: 358:                         let recv = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&name).unwrap();
361: 359:                         tx.send(Ok(Messages::BiDirectional(
362: 360:                             BiDirectionalMessage::EstablishResponse((
363: 361:                                 name.clone(),
364: 362:                                 lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.json(&name).unwrap().unwrap(),
365: 363:                             )),
366: 364:                         )))
367: 365:                         .await
368: 366:                         .unwrap();
369: 367:                         tokio::spawn(handle_broadcasts(id.to_string(), recv, tx.clone()));
370: 368:                     }
371: 369:                     BiDirectionalMessage::Update(update) => {
372: 370:                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals
373: 371:                             .update(&update.get_name().clone(), update, Some(id.to_string()))
374: 372:                             .await;
375: 373:                     }
376: 374:                     _ => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Unexpected bi-directional message from lyx-core-lyx_core_lyx-core-lyx_core_client"),
377: 375:                 },
378: 376:                 Messages::Channel(channel) => match channel {
379: 377:                     ChannelMessage::Establish(name) => {
380: 378:                         let recv = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_channel(&name).unwrap();
381: 379:                         tx.send(Ok(Messages::Channel(ChannelMessage::EstablishResponse(
382: 380:                             name.clone(),
383: 381:                         ))))
384: 382:                         .await
385: 383:                         .unwrap();
386: 384:                         tokio::spawn(handle_broadcasts(id.to_string(), recv, tx.clone()));
387: 385:                     }
388: 386: 
389: 387:                     ChannelMessage::Message(name, value) => {
390: 388:                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.handle_message(&name, value);
391: 389:                     }
392: 390:                     _ => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Unexpected channel message from lyx-core-lyx_core_lyx-core-lyx_core_client"),
393: 391:                 },
394: 392:             }
395: 393:         }
396: 394:     });
397: 395: 
398: 396:     Ok(rx.into())
399: 397: }
400: 398: use futures::{
401: 399:     SinkExt, StreamExt,
402: 400:     channel::mpsc::{self, Sender},
403: 401: };
404: 402: 
405: 403: #[cfg(any(feature = "csr", feature = "hydrate"))]
406: 404: async fn handle_broadcasts_lyx-core-lyx_core_lyx-core-lyx_core_client(
407: 405:     mut receiver: tokio::sync::broadcast::Receiver<(Option<String>, Messages)>,
408: 406:     mut sink: Sender<Result<Messages, ServerFnError>>,
409: 407: ) {
410: 408:     while let Ok(message) = receiver.recv().await {
411: 409:         if sink.send(Ok(message.1)).await.is_err() {
412: 410:             break;
413: 411:         }
414: 412:     }
415: 413: }
416: 414: 
417: 415: #[cfg(feature = "ssr")]
418: 416: async fn handle_broadcasts(
419: 417:     id: String,
420: 418:     mut receiver: tokio::sync::broadcast::Receiver<(Option<String>, Messages)>,
421: 419:     mut sink: Sender<Result<Messages, ServerFnError>>,
422: 420: ) {
423: 421:     while let Ok(message) = receiver.recv().await {
424: 422:         if message.0.is_some_and(|v| id == v) {
425: 423:             continue;
426: 424:         }
427: 425:         if sink.send(Ok(message.1)).await.is_err() {
428: 426:             break;
429: 427:         }
430: 428:     }
431: 429: }
432: 430: 
433: 431: #[cfg(all(feature = "ssr", not(any(feature = "hydrate", feature = "csr"))))]
434: 432: #[inline]
435: 433: fn provide_websocket_inner() -> Option<()> {
436: 434:     None
437: 435: }
438: 436: /// Establishes and provides a WebSocket connection for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signals.
439: 437: ///
440: 438: /// This function sets up a WebSocket connection to the specified URL and provides
441: 439: /// the necessary context for handling lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signals. It's designed to work differently
442: 440: /// based on whether lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering (SSR) is enabled or the "hydrate" feature is enabled.
443: 441: ///
444: 442: /// # Returns
445: 443: ///
446: 444: /// Returns a `Result` which is:
447: 445: /// - `Some(())` if the connection is successfully established (lyx-core-lyx_core_lyx-core-lyx_core_client-side only).
448: 446: /// - `None` if running in SSR mode.
449: 447: ///
450: 448: /// # Features
451: 449: ///
452: 450: /// - When the "hydrate" feature is enabled (lyx-core-lyx_core_lyx-core-lyx_core_client-side):
453: 451: ///   - Creates a new WebSocket connection.
454: 452: ///   - Sets up message handling for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signals.
455: 453: ///   - Provides context for `ServerSignalWebSocket` and `ClientSignals`.
456: 454: ///
457: 455: /// - When the "ssr" feature is enabled (lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side):
458: 456: ///   - Returns `None` without establishing a connection.
459: 457: ///
460: 458: /// # Examples
461: 459: ///
462: 460: /// ```rust
463: 461: /// use lyx-comm-ws::provide_websocket;
464: 462: /// fn setup_websocket() {
465: 463: ///     if let Some(_) = provide_websocket() {
466: 464: ///         println!("WebSocket connection established");
467: 465: ///     } else {
468: 466: ///         println!("Running in SSR mode or connection failed");
469: 467: ///     }
470: 468: /// }
471: 469: /// ```
472: 470: ///
473: 471: /// # Note
474: 472: ///
475: 473: /// This function should be called in the root component of your Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_application
476: 474: /// to ensure the WebSocket connection is available throughout the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.
477: 475: #[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
478: 476: pub fn provide_websocket() -> Option<()> {
479: 477:     provide_websocket_inner()
480: 478: }
481: 479: ```
482: 480: ```
483: 481: ```
484: 482: ```
485: 483: ```
486: 484: ```
487: 485: ```
488: 486: ```
489: 487: ```
490: 488: ```
491: 489: ```
492: 490: ```
493: 491: ```
494: 492: ```
495: 493: ```
496: 494: ```
497: 495: ```
498: 496: ```
499: 497: ```
500: 498: ```
501: 499: ```
502: 500: ```
503: 501: ```
504: 502: ```
505: 503: ```
506: 504: ```
507: ```
```

