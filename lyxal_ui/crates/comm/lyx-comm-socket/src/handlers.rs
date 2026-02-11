### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-socket\src\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-socket\src\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
54: 52: ```rust
55: 53: use std::{collections::HashSet, sync::Arc};
56: 54: 
57: 55: use axum::{
58: 56:     extract::{
59: 57:         WebSocketUpgrade,
60: 58:         ws::{Message, WebSocket},
61: 59:     },
62: 60:     http::{HeaderValue, header},
63: 61:     response::Response,
64: 62: };
65: 63: #[cfg(feature = "ssr")]
66: 64: use cookie::{Cookie, SameSite};
67: 65: use futures_util::{SinkExt, StreamExt, stream::SplitSink};
68: 66: use tokio::sync::{Mutex, broadcast, mpsc};
69: 67: use tracing::debug;
70: 68: use uuid::Uuid;
71: 69: 
72: 70: use crate::{ChannelMsg, ServerSocket};
73: 71: 
74: 72: const MAX_SUBSCRIPTIONS: usize = 10000;
75: 73: 
76: 74: async fn handle_websocket_with_context<C>(
77: 75:     ws: WebSocket,
78: 76:     socket: ServerSocket,
79: 77:     lyx-core-lyx_core_lyx-core-lyx_core_client_id: Uuid,
80: 78:     context: C,
81: 79: ) where
82: 80:     C: Send + Sync + 'static,
83: 81: {
84: 82:     let (ws_tx, mut ws_rx) = ws.split();
85: 83: 
86: 84:     let ws_tx = Arc::new(Mutex::new(ws_tx));
87: 85: 
88: 86:     let (lyx-core-lyx_core_lyx-core-lyx_core_client_tx, lyx-core-lyx_core_lyx-core-lyx_core_client_rx) = mpsc::channel(16);
89: 87: 
90: 88:     socket
91: 89:         .lock()
92: 90:         .await
93: 91:         .insert_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(lyx-core-lyx_core_lyx-core-lyx_core_client_id, lyx-core-lyx_core_lyx-core-lyx_core_client_tx);
94: 92: 
95: 93:     tokio::spawn({
96: 94:         let ws_tx = Arc::clone(&ws_tx);
97: 95:         let socket = socket.clone();
98: 96: 
99: 97:         async move {
100: 98:             recv_lyx-core-lyx_core_lyx-core-lyx_core_client_send(ws_tx, lyx-core-lyx_core_lyx-core-lyx_core_client_rx).await;
101: 99:             // Cleanup on disconnect
102: 100:             socket.lock().await.remove_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(lyx-core-lyx_core_lyx-core-lyx_core_client_id);
103: 101:         }
104: 102:     });
105: 103: 
106: 104:     let mut subscribed_keys = HashSet::new();
107: 105: 
108: 106:     while let Some(Ok(msg)) = ws_rx.next().await {
109: 107:         match msg {
110: 108:             Message::Close(_) => {
111: 109:                 break;
112: 110:             }
113: 111:             Message::Text(text) => {
114: 112:                 debug!("Received Text: {text}");
115: 113: 
116: 114:                 let mut socket = socket.lock().await;
117: 115: 
118: 116:                 let msg: ChannelMsg = serde_json::from_str(text.as_str()).unwrap();
119: 117: 
120: 118:                 match msg {
121: 119:                     ChannelMsg::Subscribe { key } => {
122: 120:                         if socket.can_subscribe(key.clone(), &context).await
123: 121:                             && subscribed_keys.len() < MAX_SUBSCRIPTIONS
124: 122:                         {
125: 123:                             let ws_tx = Arc::clone(&ws_tx);
126: 124:                             let broadcast_rx = socket.subscribe(key.clone());
127: 125: 
128: 126:                             let handle = tokio::spawn(async move {
129: 127:                                 recv_broadcast(Arc::clone(&ws_tx), broadcast_rx).await;
130: 128:                             });
131: 129: 
132: 130:                             subscribed_keys.insert(key.clone());
133: 131:                             socket.remember_handle(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key, handle);
134: 132:                         }
135: 133:                     }
136: 134:                     ChannelMsg::Unsubscribe { key } => {
137: 135:                         subscribed_keys.remove(&key);
138: 136:                         socket.unsubscribe(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key);
139: 137:                     }
140: 138:                     ChannelMsg::Msg { msg, key } => {
141: 139:                         if let Some(msg) = socket.map_msg(key.clone(), msg.clone(), &context) {
142: 140:                             socket.send_serialized(key, msg);
143: 141:                         }
144: 142:                     }
145: 143:                 }
146: 144:             }
147: 145:             _ => (),
148: 146:         }
149: 147:     }
150: 148: 
151: 149:     // Cleanup on disconnect
152: 150:     let mut socket = socket.lock().await;
153: 151:     socket.remove_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(lyx-core-lyx_core_lyx-core-lyx_core_client_id);
154: 152:     for key in subscribed_keys {
155: 153:         socket.unsubscribe(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key);
156: 154:     }
157: 155: }
158: 156: 
159: 157: async fn recv_lyx-core-lyx_core_lyx-core-lyx_core_client_send(
160: 158:     ws_tx: Arc<Mutex<SplitSink<WebSocket, Message>>>,
161: 159:     mut lyx-core-lyx_core_lyx-core-lyx_core_client_rx: mpsc::Receiver<ChannelMsg>,
162: 160: ) {
163: 161:     while let Some(msg) = lyx-core-lyx_core_lyx-core-lyx_core_client_rx.recv().await {
164: 162:         if ws_tx
165: 163:             .lock()
166: 164:             .await
167: 165:             .send(Message::text(serde_json::to_string(&msg).unwrap()))
168: 166:             .await
169: 167:             .is_err()
170: 168:         {
171: 169:             return; // disconnected.
172: 170:         }
173: 171:     }
174: 172: }
175: 173: 
176: 174: async fn recv_broadcast(
177: 175:     ws_tx: Arc<Mutex<SplitSink<WebSocket, Message>>>,
178: 176:     mut broadcast_rx: broadcast::Receiver<ChannelMsg>,
179: 177: ) {
180: 178:     while let Ok(msg) = broadcast_rx.recv().await {
181: 179:         if ws_tx
182: 180:             .lock()
183: 181:             .await
184: 182:             .send(Message::text(serde_json::to_string(&msg).unwrap()))
185: 183:             .await
186: 184:             .is_err()
187: 185:         {
188: 186:             return; // disconnected.
189: 187:         }
190: 188:     }
191: 189: }
192: 190: 
193: 191: /// This is used to handle the incoming WebSocket connection.
194: 192: ///
195: 193: /// ```
196: 194: /// # use axum::{extract::{State, WebSocketUpgrade}, response::Response};
197: 195: /// # use lyx_comm_socket::{ServerSocket, handlers::upgrade_websocket};
198: 196: /// #
199: 197: /// #[cfg(feature = "ssr")]
200: 198: /// pub async fn connect_to_websocket(
201: 199: ///     ws: WebSocketUpgrade,
202: 200: ///     State(socket): State<ServerSocket>,
203: 201: /// ) -> Response {
204: 202: ///     // You could do authentication here
205: 203: ///
206: 204: ///     // Provide extra context like the user's ID for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example that is passed to the permission filters
207: 205: ///     let ctx = ();
208: 206: ///
209: 207: ///     upgrade_websocket( ws, socket, ctx)
210: 208: /// }
211: 209: /// ```
212: 210: pub fn upgrade_websocket<C>(ws: WebSocketUpgrade, socket: ServerSocket, context: C) -> Response
213: 211: where
214: 212:     C: Send + Sync + 'static,
215: 213: {
216: 214:     let lyx-core-lyx_core_lyx-core-lyx_core_client_id = uuid::Uuid::new_v4();
217: 215: 
218: 216:     let mut response = ws.on_upgrade(move |websocket| {
219: 217:         handle_websocket_with_context(websocket, socket, lyx-core-lyx_core_lyx-core-lyx_core_client_id, context)
220: 218:     });
221: 219: 
222: 220:     let headers = response.headers_mut();
223: 221: 
224: 222:     let cookie = Cookie::build(("socket_lyx-core-lyx_core_lyx-core-lyx_core_client_id", lyx-core-lyx_core_lyx-core-lyx_core_client_id.to_string()))
225: 223:         .path("/")
226: 224:         .http_only(true)
227: 225:         .same_site(SameSite::Strict)
228: 226:         .build();
229: 227: 
230: 228:     headers.insert(
231: 229:         header::SET_COOKIE,
232: 230:         HeaderValue::from_str(&cookie.to_string()).unwrap(),
233: 231:     );
234: 232: 
235: 233:     response
236: 234: }
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
260: 258: ```
261: 259: ```
262: 260: ```
263: ```
```
