### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
use axum::extract::FromRef;
use axum::http::HeaderMap;
use axum::http::header::COOKIE;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-lyx_core_lyx_logic_use::utils::header;
use regex::Regex;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::any::Any;
use std::pin::Pin;
use std::{collections::HashMap, sync::Arc};
use std::{fmt::Debug, hash::Hash};
use tokio::sync::broadcast::{self, Receiver};
use tokio::sync::mpsc;
use tokio::sync::{Mutex, MutexGuard};
use tokio::task::JoinHandle;
use tracing::{debug, error, instrument};
use uuid::Uuid;

use crate::{ChannelMsg, SocketMsg};

/// This has to be added to the axum state and is used to send and subscribe to channels.
#[derive(Clone, Debug, Default)]
pub struct ServerSocket(Arc<Mutex<ServerSocketInner>>);

impl ServerSocket {
pub fn new() -> Self {
Self::default()
}

/// Locks the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server socket for exclusive access. With this you can then send messages to the socket.
///
/// See [`ServerSocketInner::send`].
#[inline]
pub async fn lock(&self) -> MutexGuard<'_, ServerSocketInner> {
self.0.lock().await
}
}

type SubscribeFilterFn =
Arc<dyn Fn(Value, &dyn Any) -> Pin<Box<dyn Future<Output = bool> + Send>> + Send + Sync>;
type SendMapFn =
Arc<dyn Fn(Value, Value, &dyn Any) -> serde_json::Result<Option<Value>> + Send + Sync>;

/// This is used on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to manage socket connections.
#[derive(Default)]
pub struct ServerSocketInner {
sender_map: HashMap<Value, broadcast::Sender<ChannelMsg>>,
lyx-core-lyx_core_lyx-core-lyx_core_client_to_sender: HashMap<Uuid, mpsc::Sender<ChannelMsg>>,
subscribe_filters: Vec<SubscribeFilterFn>,
send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers: Vec<SendMapFn>,
handles: HashMap<(Uuid, Value), JoinHandle<()>>,
}

impl std::fmt::Debug for ServerSocketInner {
fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
f.debug_struct("ServerSocketChannels")
.field("sender_map", &self.sender_map)
.field("subscribe_filters", &self.subscribe_filters.len())
.field("send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers", &self.send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers.len())
.finish()
}
}

impl ServerSocketInner {
#[instrument]
fn sender(&mut self, key: Value) -> broadcast::Sender<ChannelMsg> {
let sender = self.sender_map.entry(key).or_insert_with(|| {
debug!("Creating new sender for key");

broadcast::Sender::new(16)
});
sender.clone()
}

/// Broadcast a message from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the subscribers of the given key.
///
/// This is used to send messages from an axum handler.
/// If you want to send from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function, use the module level [`send`] function.
///
/// ## Example
///
/// 138: 136:     /// # use lyx_comm_socket::{ServerSocket, SocketMsg};
/// # use serde::{Serialize, Deserialize};
/// # use axum::extract::{State, FromRef};
/// #
/// # #[derive(FromRef, Clone)]
/// # pub struct AppState {
/// #     pub socket: ServerSocket,
/// # }
/// #
/// # #[derive(Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Debug)]
/// # struct TheKey;
/// #
/// # #[derive(Clone, Serialize, Deserialize, Debug)]
/// # struct TheMessage;
/// #
/// # impl SocketMsg for TheMessage {
/// #     type Key = TheKey;
/// #     #[cfg(feature = "ssr")]
/// #     type AppState = AppState;
/// # }
///
/// async fn axum_handler(State(socket): State<ServerSocket>) {
///     socket.lock().await.send(&TheKey, &TheMessage);
/// }
/// 163: 161:     #[instrument]
pub fn send<Msg>(&mut self, key: &Msg::Key, msg: &Msg)
where
Msg: SocketMsg + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg: Deserialize<'de>,
Msg::Key: Hash + Eq + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg::Key: Deserialize<'de>,
{
let key = serde_json::to_value(key).unwrap();
let msg = serde_json::to_value(msg).unwrap();

self.send_serialized(key, msg);
}

/// Broadcast a message from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server to the subscribers of the given key.
///
/// This is used to send messages from an axum handler.
/// If you want to send from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function, use the module level [`send_to_self`] function.
///
/// ## Example
///
/// 185: 183:     /// # use lyx_comm_socket::{ServerSocket, SocketMsg};
/// # use serde::{Serialize, Deserialize};
/// # use axum::{extract::{State, FromRef}, http::header::HeaderMap};
/// #
/// # #[derive(FromRef, Clone)]
/// # pub struct AppState {
/// #     pub socket: ServerSocket,
/// # }
/// #
/// # #[derive(Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Debug)]
/// # struct TheKey;
/// #
/// # #[derive(Clone, Serialize, Deserialize, Debug)]
/// # struct TheMessage;
/// #
/// # impl SocketMsg for TheMessage {
/// #     type Key = TheKey;
/// #     #[cfg(feature = "ssr")]
/// #     type AppState = AppState;
/// # }
///
/// async fn axum_handler(State(socket): State<ServerSocket>, headers: HeaderMap) {
///     socket.lock().await.send_to_self(&TheKey, &TheMessage, &headers).await;
/// }
/// 210: 208:     #[instrument]
pub async fn send_to_self<Msg>(&mut self, key: &Msg::Key, msg: &Msg, headers: &HeaderMap)
where
Msg: SocketMsg + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg: Deserialize<'de>,
Msg::Key: Hash + Eq + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg::Key: Deserialize<'de>,
{
if let Some(cookie_header) = headers.get(COOKIE) {
match cookie_header.to_str() {
Ok(cookie_header) => match read_lyx-core-lyx_core_lyx-core-lyx_core_client_id_from_cookie_header(cookie_header) {
Ok(lyx-core-lyx_core_lyx-core-lyx_core_client_id) => {
let key = serde_json::to_value(key).unwrap();
let msg = serde_json::to_value(msg).unwrap();

self.send_serialized_to_self(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key, msg).await;
}
Err(err) => error!("Failed to parse Uuid from cookie: {:?}", err),
},
Err(err) => {
error!("Failed to parse cookie header: {:?}", err);
}
}
} else {
error!("Cookie header not found. Can't send to self");
}
}

#[instrument]
pub(crate) fn send_serialized(&mut self, key: Value, msg: Value) {
if let Err(err) = self.sender(key.clone()).send(ChannelMsg::Msg { msg, key }) {
debug!(
"Failed to send message because there are no receivers: {:?}",
err
);
}
}

#[instrument]
pub(crate) async fn send_serialized_to_self(&self, lyx-core-lyx_core_lyx-core-lyx_core_client_id: Uuid, key: Value, msg: Value) {
if let Some(sender) = self.lyx-core-lyx_core_lyx-core-lyx_core_client_to_sender.get(&lyx-core-lyx_core_lyx-core-lyx_core_client_id) {
if let Err(err) = sender.send(ChannelMsg::Msg { key, msg }).await {
debug!("Failed to send websocket message: {:?}", err);
}
} else {
error!(
"WebSocket transmitter for lyx-core-lyx_core_lyx-core-lyx_core_client ID {} not found",
lyx-core-lyx_core_lyx-core-lyx_core_client_id
);
}
}

pub(crate) fn insert_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(
&mut self,
lyx-core-lyx_core_lyx-core-lyx_core_client_id: Uuid,
sender: mpsc::Sender<ChannelMsg>,
) {
self.lyx-core-lyx_core_lyx-core-lyx_core_client_to_sender.insert(lyx-core-lyx_core_lyx-core-lyx_core_client_id, sender);
}

pub(crate) fn remove_lyx-core-lyx_core_lyx-core-lyx_core_client_sender(&mut self, lyx-core-lyx_core_lyx-core-lyx_core_client_id: Uuid) {
self.lyx-core-lyx_core_lyx-core-lyx_core_client_to_sender.remove(&lyx-core-lyx_core_lyx-core-lyx_core_client_id);
}

#[instrument]
pub(crate) fn subscribe(&mut self, key: Value) -> Receiver<ChannelMsg> {
self.sender(key).subscribe()
}

pub(crate) fn remember_handle(&mut self, lyx-core-lyx_core_lyx-core-lyx_core_client_id: Uuid, key: Value, handle: JoinHandle<()>) {
self.handles.insert((lyx-core-lyx_core_lyx-core-lyx_core_client_id, key), handle);
}

pub(crate) fn unsubscribe(&mut self, lyx-core-lyx_core_lyx-core-lyx_core_client_id: Uuid, key: Value) {
if let Some(handle) = self.handles.remove(&(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key)) {
handle.abort();
}
}

/// Add a subscribe filter to the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server. Whenever someone wants to subscribe ,
/// the filter will be called with the key and context.
/// It can then return `true` to allow the subscription or `false` to deny it.
/// If multiple filters are found for a given key,
/// the subscription will only be allowed if all filters return `true`.
pub fn add_subscribe_filter<K, C, F, Fut>(&mut self, filter: F)
where
K: Send + Sync,
for<'de> K: Deserialize<'de>,
F: Fn(K, C) -> Fut + Clone + Send + Sync + 'static,
Fut: Future<Output = bool> + Send,
C: Clone + Send + Sync + 'static,
{
self.subscribe_filters
.push(Arc::new(move |key: Value, ctx: &dyn Any| {
let ctx: &C = ctx.downcast_ref().expect("Invalid context type");
let ctx = ctx.clone();

let filter = filter.clone();

Box::pin(async move {
match serde_json::from_value(key) {
Ok(key) => filter(key, ctx).await,
Err(_) => {
// This filter doesn't lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply to the key
true
}
}
})
}));
}

/// Add a send mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper to the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server. Whenever someone wants to send a message,
/// the mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper will be called with the key, message, and context.
/// It can then return `Some(message)` to allow the message to be sent or `None` to deny it.
/// It can also modify the message before sending it.
///
/// Make sure you only add one mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper per message type (the message type also specifies the key type).
/// If you add multiple mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers for the same message type,
/// the first one added will be used and all subsequent ones will be ignored.
pub fn add_send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<M, C, F>(&mut self, mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper: F)
where
M: SocketMsg + Serialize,
for<'de> M: Deserialize<'de>,
for<'de> M::Key: Deserialize<'de>,
F: Fn(M::Key, M, &C) -> Option<M> + Send + Sync + 'static,
C: 'static,
{
self.send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers
.push(Arc::new(move |key: Value, msg: Value, ctx: &dyn Any| {
let key: M::Key = serde_json::from_value(key)?;
let msg: M = serde_json::from_value(msg)?;

let ctx: &C = ctx.downcast_ref().expect("Invalid context type");

mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper(key, msg, ctx).map(serde_json::to_value).transpose()
}));
}

pub(crate) async fn can_subscribe<C>(&self, key: Value, ctx: &C) -> bool
where
C: Send + Sync + 'static,
{
let mut can_subscribe = true;

for filter in &self.subscribe_filters {
can_subscribe = can_subscribe && filter(key.clone(), ctx).await;
}

can_subscribe
}

pub(crate) fn map_msg<C>(&self, key: Value, msg: Value, ctx: &C) -> Option<Value>
where
C: 'static,
{
for mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper in &self.send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers {
if let Ok(mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped_msg) = mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper(key.clone(), msg.clone(), ctx) {
return mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped_msg;
}
}

Some(msg)
}
}

/// Broadcast a message from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function to the subscribers of the given key.
///
/// You can call this function only from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
/// If you want to call this from an axum handler, use `ServerSocketInner::send` instead.
#[instrument]
pub async fn send<Msg>(key: &Msg::Key, msg: &Msg)
where
Msg: SocketMsg + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg: Deserialize<'de>,
Msg::Key: Hash + Eq + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg::Key: Deserialize<'de>,
Msg::AppState: Clone,
ServerSocket: FromRef<Msg::AppState>,
{
let state: Msg::AppState = match use_context() {
Some(state) => state,
None => {
error!(
"Failed to get the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state context. You can call this function only from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function. If you want to call this from an axum handler, use `ServerSocketInner::send` instead."
);
return;
}
};

ServerSocket::from_ref(&state).lock().await.send(key, msg);
}

/// Send a message from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function only to the connection that called this lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
///
/// You can call this function only from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
/// If you want to call this from an axum handler use [`ServerSocketInner::send_to_self`] instead.
#[instrument]
pub async fn send_to_self<Msg>(key: &Msg::Key, msg: &Msg)
where
Msg: SocketMsg + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg: Deserialize<'de>,
Msg::Key: Hash + Eq + Serialize + Clone + Send + Sync + Debug + 'static,
for<'de> Msg::Key: Deserialize<'de>,
Msg::AppState: Clone,
ServerSocket: FromRef<Msg::AppState>,
{
let lyx-core-lyx_core_lyx-core-lyx_core_client_id = match extract_lyx-core-lyx_core_lyx-core-lyx_core_client_id_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn() {
Ok(id) => id,
Err(err) => {
error!(
"Failed to extract lyx-core-lyx_core_lyx-core-lyx_core_client ID: {}. You can call this function only from a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function. If you want to call this from an axum handler use `ServerSocketInner::send_to_self` instead.",
err
);
return;
}
};

let key = serde_json::to_value(key).unwrap();
let msg = serde_json::to_value(msg).unwrap();

let state: Msg::AppState = expect_context();

ServerSocket::from_ref(&state)
.lock()
.await
.send_serialized_to_self(lyx-core-lyx_core_lyx-core-lyx_core_client_id, key, msg)
.await;
}

fn extract_lyx-core-lyx_core_lyx-core-lyx_core_client_id_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn() -> Result<Uuid, String> {
let cookie_header = header(COOKIE).ok_or("No cookie header found")?;

read_lyx-core-lyx_core_lyx-core-lyx_core_client_id_from_cookie_header(&cookie_header)
}

fn read_lyx-core-lyx_core_lyx-core-lyx_core_client_id_from_cookie_header(cookie_header: &str) -> Result<Uuid, String> {
// Parse value of cookie called socket_lyx-core-lyx_core_lyx-core-lyx_core_client_id
let re = Regex::new(r"socket_lyx-core-lyx_core_lyx-core-lyx_core_client_id=([^;]+)").unwrap();
let caps = re
.captures(cookie_header)
.ok_or("socket_lyx-core-lyx_core_lyx-core-lyx_core_client_id cookie not found")?;
let lyx-core-lyx_core_lyx-core-lyx_core_client_id_str = caps
.get(1)
.ok_or("socket_lyx-core-lyx_core_lyx-core-lyx_core_client_id cookie value not found")?;

Uuid::parse_str(lyx-core-lyx_core_lyx-core-lyx_core_client_id_str.as_str())
.map_err(|err| format!("Invalid UUID in socket_lyx-core-lyx_core_lyx-core-lyx_core_client_id cookie: {}", err))
}
