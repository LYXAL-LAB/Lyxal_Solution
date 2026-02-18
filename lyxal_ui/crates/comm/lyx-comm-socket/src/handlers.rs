### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\handlers.rs
use std::{collections::HashSet, sync::Arc};

use axum::{
extract::{
WebSocketUpgrade,
ws::{Message, WebSocket},
},
http::{HeaderValue, header},
response::Response,
};
#[cfg(feature = "ssr")]
use cookie::{Cookie, SameSite};
use futures_util::{SinkExt, StreamExt, stream::SplitSink};
use tokio::sync::{Mutex, broadcast, mpsc};
use tracing::debug;
use uuid::Uuid;

use crate::{ChannelMsg, ServerSocket};

const MAX_SUBSCRIPTIONS: usize = 10000;

async fn handle_websocket_with_context<C>(
ws: WebSocket,
socket: ServerSocket,
lyx-core-lyx_core_lyx-core-lyx_core_client_id: Uuid,
context: C,
) where
C: Send + Sync + 'static,
{
let (ws_tx, mut ws_rx) = ws.split();

let ws_tx = Arc::new(Mutex::new(ws_tx));

let (lyx-core-lyx_core_lyx-core-lyx_core_client_tx, lyx-core-lyx_core_lyx-core-lyx_core_client_rx) = mpsc::channel(16);

socket
.lock()
.await
.insert_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(lyx-core-lyx_core_lyx-core-lyx_core_client_id, lyx-core-lyx_core_lyx-core-lyx_core_client_tx);

tokio::spawn({
let ws_tx = Arc::clone(&ws_tx);
let socket = socket.clone();

async move {
recv_lyx-core-lyx_core_lyx-core-lyx_core_client_send(ws_tx, lyx-core-lyx_core_lyx-core-lyx_core_client_rx).await;
// Cleanup on disconnect
socket.lock().await.remove_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(lyx-core-lyx_core_lyx-core-lyx_core_client_id);
}
});

let mut subscribed_keys = HashSet::new();

while let Some(Ok(msg)) = ws_rx.next().await {
match msg {
Message::Close(_) => {
break;
}
Message::Text(text) => {
debug!("Received Text: {text}");

let mut socket = socket.lock().await;

let msg: ChannelMsg = serde_json::from_str(text.as_str()).unwrap();

match msg {
ChannelMsg::Subscribe { key } => {
if socket.can_subscribe(key.clone(), &context).await
&& subscribed_keys.len() < MAX_SUBSCRIPTIONS
{
let ws_tx = Arc::clone(&ws_tx);
let broadcast_rx = socket.subscribe(key.clone());

let handle = tokio::spawn(async move {
recv_broadcast(Arc::clone(&ws_tx), broadcast_rx).await;
});

subscribed_keys.insert(key.clone());
socket.remember_handle(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key, handle);
}
}
ChannelMsg::Unsubscribe { key } => {
subscribed_keys.remove(&key);
socket.unsubscribe(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key);
}
ChannelMsg::Msg { msg, key } => {
if let Some(msg) = socket.map_msg(key.clone(), msg.clone(), &context) {
socket.send_serialized(key, msg);
}
}
}
}
_ => (),
}
}

// Cleanup on disconnect
let mut socket = socket.lock().await;
socket.remove_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(lyx-core-lyx_core_lyx-core-lyx_core_client_id);
for key in subscribed_keys {
socket.unsubscribe(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key);
}
}

async fn recv_lyx-core-lyx_core_lyx-core-lyx_core_client_send(
ws_tx: Arc<Mutex<SplitSink<WebSocket, Message>>>,
mut lyx-core-lyx_core_lyx-core-lyx_core_client_rx: mpsc::Receiver<ChannelMsg>,
) {
while let Some(msg) = lyx-core-lyx_core_lyx-core-lyx_core_client_rx.recv().await {
if ws_tx
.lock()
.await
.send(Message::text(serde_json::to_string(&msg).unwrap()))
.await
.is_err()
{
return; // disconnected.
}
}
}

async fn recv_broadcast(
ws_tx: Arc<Mutex<SplitSink<WebSocket, Message>>>,
mut broadcast_rx: broadcast::Receiver<ChannelMsg>,
) {
while let Ok(msg) = broadcast_rx.recv().await {
if ws_tx
.lock()
.await
.send(Message::text(serde_json::to_string(&msg).unwrap()))
.await
.is_err()
{
return; // disconnected.
}
}
}

/// This is used to handle the incoming WebSocket connection.
///
/// 196: 194: /// # use axum::{extract::{State, WebSocketUpgrade}, response::Response};
/// # use lyx_comm_socket::{ServerSocket, handlers::upgrade_websocket};
/// #
/// #[cfg(feature = "ssr")]
/// pub async fn connect_to_websocket(
///     ws: WebSocketUpgrade,
///     State(socket): State<ServerSocket>,
/// ) -> Response {
///     // You could do authentication here
///
///     // Provide extra context like the user's ID for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example that is passed to the permission filters
///     let ctx = ();
///
///     upgrade_websocket( ws, socket, ctx)
/// }
/// 212: 210: pub fn upgrade_websocket<C>(ws: WebSocketUpgrade, socket: ServerSocket, context: C) -> Response
where
C: Send + Sync + 'static,
{
let lyx-core-lyx_core_lyx-core-lyx_core_client_id = uuid::Uuid::new_v4();

let mut response = ws.on_upgrade(move |websocket| {
handle_websocket_with_context(websocket, socket, lyx-core-lyx_core_lyx-core-lyx_core_client_id, context)
});

let headers = response.headers_mut();

let cookie = Cookie::build(("socket_lyx-core-lyx_core_lyx-core-lyx_core_client_id", lyx-core-lyx_core_lyx-core-lyx_core_client_id.to_string()))
.path("/")
.http_only(true)
.same_site(SameSite::Strict)
.build();

headers.insert(
header::SET_COOKIE,
HeaderValue::from_str(&cookie.to_string()).unwrap(),
);

response
}
