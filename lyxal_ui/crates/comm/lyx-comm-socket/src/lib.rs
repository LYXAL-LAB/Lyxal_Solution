### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-socket\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-socket\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
54: 52: ```rust
55: 53: //! Realtime pub/sub communication for Leptos + Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_applications.
56: 54: //!
57: 55: //! ## Usage
58: 56: //!
59: 57: //! ```
60: 58: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
61: 59: //! # use lyx_comm_socket::{expect_socket_context, ServerSocket, SocketMsg};
62: 60: //! # use serde::{Serialize, Deserialize};
63: 61: //! # use axum::extract::{State, FromRef};
64: 62: //! #
65: 63: //! # #[derive(FromRef, Clone)]
66: 64: //! # pub struct AppState {
67: 65: //! #     pub socket: ServerSocket,
68: 66: //! # }
69: 67: //! #
70: 68: //! // Define the key and message types
71: 69: //! #[derive(Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Debug)]
72: 70: //! pub struct MyKey {
73: 71: //!     pub bla: String,
74: 72: //! }
75: 73: //!
76: 74: //! #[derive(Clone, Serialize, Deserialize, Debug)]
77: 75: //! pub struct MyMsg {
78: 76: //!     pub awesome_msg: String,
79: 77: //! }
80: 78: //!
81: 79: //! // Implement the SocketMsg trait for MyMsg to link the key and message types
82: 80: //! impl SocketMsg for MyMsg {
83: 81: //!     type Key = MyKey;
84: 82: //!     #[cfg(feature = "ssr")]
85: 83: //!     type AppState = AppState;
86: 84: //! }
87: 85: //!
88: 86: //! #[component]
89: 87: //! pub fn MyComponent() -> impl IntoView {
90: 88: //!     let socket = expect_socket_context();
91: 89: //!
92: 90: //!     // Subscribe to receive messages that are sent with the given key
93: 91: //!     socket.subscribe(
94: 92: //!         MyKey {
95: 93: //!             bla: "bla".to_string(),
96: 94: //!         },
97: 95: //!         |msg: &MyMsg| {
98: 96: //!             // Simply log the message
99: 97: //!             lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log!("message: {msg:#?}");
100: 98: //!         },
101: 99: //!     );
102: 100: //!
103: 101: //!     let on_click = move || {
104: 102: //!         // Send a message with the given key
105: 103: //!         socket.send(
106: 104: //!             MyKey {
107: 105: //!                 bla: "bla".to_string(),
108: 106: //!             },
109: 107: //!             MyMsg {
110: 108: //!                 awesome_msg: "awesome message".to_string(),
111: 109: //!             },
112: 110: //!         );
113: 111: //!     };
114: 112: //!
115: 113: //!     view! { "..." }
116: 114: //! }
117: 115: //!
118: 116: //! #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
119: 117: //! pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_function() -> Result<(), ServerFnError> {
120: 118: //!     // Send from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
121: 119: //!     lyx_comm_socket::send(
122: 120: //!        &MyKey {
123: 121: //!            bla: "bla".to_string(),
124: 122: //!        },
125: 123: //!        &MyMsg {
126: 124: //!            awesome_msg: "Hello, world!".to_string(),
127: 125: //!        },
128: 126: //!     ).await;
129: 127: //!
130: 128: //!     Ok(())
131: 129: //! }
132: 130: //! ```
133: 131: //!
134: 132: //! For this to work you have to prepare a little bit.
135: 133: //!
136: 134: //! Define your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state in your lib.rs:
137: 135: //!
138: 136: //! ```
139: 137: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
140: 138: //!
141: 139: //! #[cfg(feature = "ssr")]
142: 140: //! #[derive(Clone, axum::extract::FromRef)]
143: 141: //! pub struct AppState {
144: 142: //!     // This is required for Leptos Axum Socket to work
145: 143: //!     pub socket: lyx_comm_socket::ServerSocket,
146: 144: //!
147: 145: //!     // this is required for Leptos to work with axum
148: 146: //!     pub lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: LeptosOptions,
149: 147: //! }
150: 148: //! ```
151: 149: //!
152: 150: //! Initialize your Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_app (probably in main.rs):
153: 151: //!
154: 152: //! ```
155: 153: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
156: 154: //! # use lyx_comm_socket::{ServerSocket, SocketMsg, SocketRoute, handlers::upgrade_websocket};
157: 155: //! # use serde::{Deserialize, Serialize};
158: 156: //! # use axum::{Router, extract::{State, WebSocketUpgrade, FromRef}, response::Response};
159: 157: //! # use lyx-core-axum::{generate_route_list, LeptosRoutes};
160: 158: //! #
161: 159: //! # #[derive(Clone, FromRef)]
162: 160: //! # pub struct AppState {
163: 161: //! #     pub lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket: ServerSocket,
164: 162: //! #     pub lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: LeptosOptions,
165: 163: //! # }
166: 164: //! #
167: 165: //! # fn shell(options: LeptosOptions) -> impl IntoView {
168: 166: //! #     ()
169: 167: //! # }
170: 168: //! # fn App() -> impl IntoView {
171: 169: //! #     ()
172: 170: //! # }
173: 171: //! #
174: 172: //! # #[derive(Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Debug)]
175: 173: //! # pub struct MyKey {
176: 174: //! #     pub bla: String,
177: 175: //! # }
178: 176: //! #
179: 177: //! # #[derive(Clone, Serialize, Deserialize, Debug)]
180: 178: //! # pub struct MyMsg {
181: 179: //! #     pub awesome_msg: String,
182: 180: //! # }
183: 181: //! #
184: 182: //! # impl SocketMsg for MyMsg {
185: 183: //! #     type Key = MyKey;
186: 184: //! #     #[cfg(feature = "ssr")]
187: 185: //! #     type AppState = AppState;
188: 186: //! # }
189: 187: //! #
190: 188: //! #[tokio::main]
191: 189: //! async fn main() {
192: 190: //!     let conf = get_configuration(None).unwrap();
193: 191: //!     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
194: 192: //!
195: 193: //!     let routes = generate_route_list(App);
196: 194: //!
197: 195: //!     // Construct the Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state
198: 196: //!     let state = AppState {
199: 197: //!         lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
200: 198: //!         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket: ServerSocket::new(),
201: 199: //!     };
202: 200: //!
203: 201: //!     // Optional: add subscription filters and message mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers
204: 202: //!     {
205: 203: //!         let mut lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket = state.lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket.lock().await;
206: 204: //!         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket.add_subscribe_filter(async |key: MyKey, _ctx: &()| { key.bla == "bla" });
207: 205: //!         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket.add_send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper(|key: MyKey, msg: MyMsg, _ctx: &()| {
208: 206: //!             if key.bla == "bla" {
209: 207: //!                 Some(MyMsg {
210: 208: //!                     awesome_msg: msg.awesome_msg.replace("old", "new"),
211: 209: //!                 })
212: 210: //!             } else {
213: 211: //!                 None
214: 212: //!             }
215: 213: //!         });
216: 214: //!     }
217: 215: //!
218: 216: //!     // Init the Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
219: 217: //!     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app: Router<AppState> = Router::new()
220: 218: //!         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&state, routes, {
221: 219: //!             let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = state.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
222: 220: //!             move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
223: 221: //!         })
224: 222: //!         .socket_route(connect_to_websocket)    // Register the socket route (implementation below)
225: 223: //!         .fallback(lyx-core-axum::file_and_error_handler::<AppState, _>(shell))
226: 224: //!         .with_state(state);    // Register the state
227: 225: //!
228: 226: //!     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
229: 227: //!     // axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
230: 228: //!     //    .await
231: 229: //!     //    .unwrap();
232: 230: //! }
233: 231: //!
234: 232: //! // Implement the `connect_to_websocket` handler:
235: 233: //! #[cfg(feature = "ssr")]
236: 234: //! pub async fn connect_to_websocket(
237: 235: //!     ws: WebSocketUpgrade,
238: 236: //!     State(socket): State<ServerSocket>,
239: 237: //! ) -> Response {
240: 238: //!     // You could do authentication here
241: 239: //!
242: 240: //!     // Provide extra context like the user's ID for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example that is passed to the permission filters
243: 241: //!     let ctx = ();
244: 242: //!
245: 243: //!     upgrade_websocket(ws, socket, ctx)
246: 244: //! }
247: 245: //! ```
248: 246: //!
249: 247: //! And finally provide the context in your root Leptos component:
250: 248: //!
251: 249: //! ```
252: 250: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
253: 251: //! # use lyx_comm_socket::provide_socket_context;
254: 252: //! #
255: 253: //! #[component]
256: 254: //! pub fn App() -> impl IntoView {
257: 255: //!     provide_socket_context();
258: 256: //!
259: 257: //!     view! { "..." }
260: 258: //! }
261: 259: //! ```
262: 260: //!
263: 261: //! ### Axum Handlers
264: 262: //!
265: 263: //! You can also send messages from inside axum handlers.
266: 264: //! Checkout [`ServerSocketInner::send`] and [`ServerSocketInner::send_to_self`].
267: 265: 
268: 266: pub mod channel;
269: 267: #[cfg(feature = "ssr")]
270: 268: pub mod handlers;
271: 269: 
272: 270: pub use crate::channel::*;
273: 271: 
274: 272: /// Implement this trait to link your socket message types to your key types.
275: 273: /// In order to use this crate you have to implement this trait for your socket messages.
276: 274: ///
277: 275: /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server you have to provide the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application state as well.
278: 276: ///
279: 277: /// ```
280: 278: /// # use lyx_comm_socket::{ServerSocket, SocketMsg};
281: 279: /// # use serde::{Serialize, Deserialize};
282: 280: /// # use axum::extract::FromRef;
283: 281: /// #
284: 282: /// # #[derive(FromRef, Clone)]
285: 283: /// # pub struct AppState {
286: 284: /// #     pub socket: ServerSocket,
287: 285: /// # }
288: 286: /// #
289: 287: /// // Define the key and message types
290: 288: /// #[derive(Clone, Serialize, Deserialize)]
291: 289: /// pub struct MyKey {
292: 290: ///     pub bla: String,
293: 291: /// }
294: 292: ///
295: 293: /// #[derive(Clone, Serialize, Deserialize, Debug)]
296: 294: /// pub struct MyMsg {
297: 295: ///     pub awesome_msg: String,
298: 296: /// }
299: 297: ///
300: 298: /// // Implement the SocketMsg trait for MyMsg to link the key and message types
301: 299: /// impl SocketMsg for MyMsg {
302: 300: ///     type Key = MyKey;
303: 301: ///     #[cfg(feature = "ssr")]
304: 302: ///     type AppState = AppState;
305: 303: /// }
306: 304: /// ```
307: 305: pub trait SocketMsg {
308: 306:     type Key;
309: 307:     #[cfg(feature = "ssr")]
310: 308:     type AppState;
311: 309: }
312: 310: 
313: 311: /// Trait to extend the Axum router
314: 312: #[cfg(feature = "ssr")]
315: 313: pub trait SocketRoute<S>
316: 314: where
317: 315:     S: Clone + Send + Sync + 'static,
318: 316: {
319: 317:     /// Add the necessary websocket route to the Axum router
320: 318:     fn socket_route<H, T>(self, handler: H) -> Self
321: 319:     where
322: 320:         H: axum::handler::Handler<T, S>,
323: 321:         T: 'static;
324: 322: }
325: 323: 
326: 324: #[cfg(feature = "ssr")]
327: 325: impl<S> SocketRoute<S> for axum::Router<S>
328: 326: where
329: 327:     S: Clone + Send + Sync + 'static,
330: 328:     ServerSocket: axum::extract::FromRef<S>,
331: 329: {
332: 330:     fn socket_route<H, T>(self, handler: H) -> Self
333: 331:     where
334: 332:         H: axum::handler::Handler<T, S>,
335: 333:         T: 'static,
336: 334:     {
337: 335:         use axum::routing::get;
338: 336:         use tracing::debug;
339: 337: 
340: 338:         debug!("Adding websocket route to {WEBSOCKET_CHANNEL_URL}");
341: 339: 
342: 340:         self.route(WEBSOCKET_CHANNEL_URL, get(handler))
343: 341:     }
344: 342: }
345: 343: ```
346: 344: ```
347: 345: ```
348: 346: ```
349: 347: ```
350: 348: ```
351: 349: ```
352: 350: ```
353: 351: ```
354: 352: ```
355: 353: ```
356: 354: ```
357: 355: ```
358: 356: ```
359: 357: ```
360: 358: ```
361: 359: ```
362: 360: ```
363: 361: ```
364: 362: ```
365: 363: ```
366: 364: ```
367: 365: ```
368: 366: ```
369: 367: ```
370: 368: ```
371: ```
```
