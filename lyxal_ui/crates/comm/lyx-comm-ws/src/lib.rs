### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\lib.rs
#![doc = include_str!("../README.md")]
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]

// #![feature(unboxed_closures)]
use crate::messages::ServerSignalMessage;
#[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
pub use bidirectional::BiDirectionalSignal;
#[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
pub use channel::ChannelSignal;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
prelude::*,
lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{BoxedStream, Websocket, codec::JsonEncoding},
task::spawn_local,
};
use messages::{BiDirectionalMessage, ChannelMessage, Messages};
#[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
pub use read_only::ReadOnlySignal;

use std::sync::{Arc, Mutex};
pub use ws_signals::WsSignals;
mod bidirectional;
mod channel;
pub mod error;
pub mod messages;
mod read_only;
mod ws_signals;

pub mod traits;

#[cfg(any(feature = "csr", feature = "hydrate"))]
#[derive(Clone)]
pub struct ServerSignalWebSocket {
send: Arc<Mutex<Sender<Result<Messages, ServerFnError>>>>,
delayed_msgs: Arc<Mutex<Vec<Messages>>>,
on_disconnect: Arc<Mutex<Option<Box<dyn Fn() + Send + Sync>>>>,
on_reconnect: Arc<Mutex<Option<Box<dyn Fn() + Send + Sync>>>>,
on_connect: Arc<Mutex<Option<Box<dyn Fn() + Send + Sync>>>>,
}
#[cfg(any(feature = "csr", feature = "hydrate"))]
impl ServerSignalWebSocket {
pub fn send(&self, msg: &Messages) -> Result<(), serde_json::Error> {
// Try to send the message immediately. If the send fails (channel closed or full),
// push it onto the delayed queue to be flushed when a reconnect succeeds.
let cloned = msg.to_owned();
if let Ok(mut lock) = self.send.lock() {
if lock.try_send(Ok(cloned)).is_err() {
// queue for later
if let Ok(mut delayed) = self.delayed_msgs.lock() {
delayed.push(msg.to_owned());
}
}
} else {
// couldn't lock send - queue the message
if let Ok(mut delayed) = self.delayed_msgs.lock() {
delayed.push(msg.to_owned());
}
}
Ok(())
}

#[must_use]
pub fn new() -> Self {
Self::default()
}

/// Set a callback to be called when the websocket connection is lost.
/// # Panics
/// Panics if the lock is poisoned.
pub fn set_on_disconnect(&self, on_disconnect: impl Fn() + Send + Sync + 'static) {
*self.on_disconnect.lock().unwrap() = Some(Box::new(on_disconnect));
}

/// Set a callback to be called when the websocket connection is reestablished.
/// # Panics
/// Panics if the lock is poisoned.
pub fn set_on_reconnect(&self, on_reconnect: impl Fn() + Send + Sync + 'static) {
*self.on_reconnect.lock().unwrap() = Some(Box::new(on_reconnect));
}

/// Set a callback to be called when the websocket connection is first established.
/// # Panics
/// Panics if the lock is poisoned.
pub fn set_on_connect(&self, on_connect: impl Fn() + Send + Sync + 'static) {
*self.on_connect.lock().unwrap() = Some(Box::new(on_connect));
}
}
#[cfg(any(feature = "csr", feature = "hydrate"))]
impl Default for ServerSignalWebSocket {
fn default() -> Self {
let (initial_tx, _initial_rx) = mpsc::channel(0);

let delayed_msgs: Arc<Mutex<Vec<Messages>>> = Arc::new(Mutex::new(Vec::new()));
let send = Arc::new(Mutex::new(initial_tx));
let state_signals = WsSignals::new();
let id = Arc::new(String::new());
let on_disconnect = Arc::new(Mutex::new(None::<Box<dyn Fn() + Send + Sync + 'static>>));
let on_reconnect = Arc::new(Mutex::new(None::<Box<dyn Fn() + Send + Sync + 'static>>));
let on_connect = Arc::new(Mutex::new(None::<Box<dyn Fn() + Send + Sync + 'static>>));
let first_connect = Arc::new(Mutex::new(true));
{
let on_disconnect = on_disconnect.clone();
let on_reconnect = on_reconnect.clone();
let on_connect = on_connect.clone();
let mut state_signals = state_signals.clone();
let delayed_msgs = delayed_msgs.clone();
let send_arc = send.clone();
let first_connect = first_connect.clone();
spawn_local(async move {
use std::time::Duration;
loop {
// create a fresh channel for this connection attempt
let (tx, rx) = mpsc::channel(32);

// swap in the new sender so callers will use it
if let Ok(mut guard) = send_arc.lock() {
*guard = tx.clone();
}

match lyx-comm-ws_websocket(rx.into()).await {
Ok(mut messages) => {
// flush any delayed messages onto the new sender
if let Ok(mut delayed) = delayed_msgs.lock() {
for msg in delayed.drain(..) {
// ignore errors here; if it fails, re-queue below on next loop
let _ = tx.clone().try_send(Ok(msg));
}
}

let mut first = first_connect.lock().unwrap();
let is_first_connect = *first;
if *first {
*first = false;
}
drop(first);

if !is_first_connect {
for message in state_signals.get_reconnect_messages() {
let _ = tx.clone().try_send(Ok(message));
}
}

// Fire lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate connection callback
if is_first_connect {
if let Some(ref on_connect) = *on_connect.lock().unwrap() {
on_connect();
}
}

let mut first_message_received = false;
while let Some(msg) = messages.next().await {
let Ok(msg) = msg else {
continue;
};

// Fire on_reconnect after first successful message (confirms connection is working)
if !first_message_received && !is_first_connect {
if let Some(ref on_reconnect) = *on_reconnect.lock().unwrap() {
on_reconnect();
}
first_message_received = true;
}

match msg {
Messages::ServerSignal(lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg) => match lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg {
ServerSignalMessage::Establish(_) => {
// Usually lyx-core-lyx_core_lyx-core-lyx_core_client-to-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server message, ignore if received
}
ServerSignalMessage::EstablishResponse((name, value)) => {
state_signals.set_json(&name, value);
}
ServerSignalMessage::Update(update) => {
spawn_local({
let state_signals = state_signals.clone();
async move {
state_signals
.update(
&update.get_name().clone(),
update,
None,
)
.await;
}
});
}
ServerSignalMessage::Delete(name) => {
let _ = state_signals.delete_signal(&name);
}
},
Messages::BiDirectional(bidirectional) => match bidirectional {
BiDirectionalMessage::Establish(_) => {
// Usually lyx-core-lyx_core_lyx-core-lyx_core_client-to-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server message, ignore if received
}
BiDirectionalMessage::EstablishResponse((name, value)) => {
state_signals.set_json(&name, value);
let recv = state_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&name).unwrap();
spawn_local(handle_broadcasts_lyx-core-lyx_core_lyx-core-lyx_core_client(recv, tx.clone()));
}
BiDirectionalMessage::Update(update) => {
spawn_local({
let state_signals = state_signals.clone();
let id = id.clone();
async move {
state_signals
.update(
&update.get_name().clone(),
update,
Some(id.to_string()),
)
.await;
}
});
}
BiDirectionalMessage::Delete(name) => {
let _ = state_signals.delete_signal(&name);
}
},
Messages::Channel(channel) => match channel {
ChannelMessage::Establish(_) => {
// Usually lyx-core-lyx_core_lyx-core-lyx_core_client-to-lyx-platform-lyx_platform_lyx-platform-lyx_platform_server message, ignore if received
}
ChannelMessage::EstablishResponse(name) => {
let recv =
state_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_channel(&name).unwrap();
spawn_local(handle_broadcasts_lyx-core-lyx_core_lyx-core-lyx_core_client(recv, tx.clone()));
}
ChannelMessage::Message(name, value) => {
state_signals.handle_message(&name, value);
}
ChannelMessage::Delete(name) => {
let _ = state_signals.delete_channel(&name);
}
},
}
}
}
Err(e) => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("{e}"),
}
if let Some(ref on_disconnect) = *on_disconnect.lock().unwrap() {
on_disconnect();
}
// connection lost - wait and retry
gloo_timers::future::sleep(Duration::from_secs(1)).await;
}
});
}

let ws_lyx-core-lyx_core_lyx-core-lyx_core_client = Self {
send,
delayed_msgs,
on_disconnect,
on_reconnect,
on_connect,
};

// Provide ClientSignals for Child Components to work
provide_context(state_signals);

ws_lyx-core-lyx_core_lyx-core-lyx_core_client
}
}

#[cfg(any(feature = "csr", feature = "hydrate"))]
#[inline]
fn provide_websocket_inner() -> Option<()> {
if use_context::<ServerSignalWebSocket>().is_none() {
provide_context(ServerSignalWebSocket::new());
}
Some(())
}

#[allow(clippy::unused_async)]
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(protocol = Websocket<JsonEncoding, JsonEncoding>,endpoint="lyx-comm-ws_websocket")]
pub async fn lyx-comm-ws_websocket(
input: BoxedStream<Messages, ServerFnError>,
) -> Result<BoxedStream<Messages, ServerFnError>, ServerFnError> {
use futures::{SinkExt, StreamExt, channel::mpsc};
let mut input = input;
let (mut tx, rx) = mpsc::channel(1);
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals = use_context::<WsSignals>().unwrap();
let id = Arc::new(nanoid::nanoid!());
// spawn a task to listen to the input stream of messages coming in over the websocket
tokio::spawn(async move {
while let Some(msg) = input.next().await {
let Ok(msg) = msg else {
break;
};
match msg {
Messages::ServerSignal(lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg) => match lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_msg {
ServerSignalMessage::Establish(name) => {
let recv = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&name).unwrap();
tx.send(Ok(Messages::ServerSignal(
ServerSignalMessage::EstablishResponse((
name.clone(),
lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.json(&name).unwrap().unwrap(),
)),
)))
.await
.unwrap();
tokio::spawn(handle_broadcasts(id.to_string(), recv, tx.clone()));
}
_ => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Unexpected lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signal message from lyx-core-lyx_core_lyx-core-lyx_core_client"),
},
Messages::BiDirectional(bidirectional) => match bidirectional {
BiDirectionalMessage::Establish(name) => {
let recv = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(&name).unwrap();
tx.send(Ok(Messages::BiDirectional(
BiDirectionalMessage::EstablishResponse((
name.clone(),
lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.json(&name).unwrap().unwrap(),
)),
)))
.await
.unwrap();
tokio::spawn(handle_broadcasts(id.to_string(), recv, tx.clone()));
}
BiDirectionalMessage::Update(update) => {
lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals
.update(&update.get_name().clone(), update, Some(id.to_string()))
.await;
}
_ => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Unexpected bi-directional message from lyx-core-lyx_core_lyx-core-lyx_core_client"),
},
Messages::Channel(channel) => match channel {
ChannelMessage::Establish(name) => {
let recv = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.add_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server_channel(&name).unwrap();
tx.send(Ok(Messages::Channel(ChannelMessage::EstablishResponse(
name.clone(),
))))
.await
.unwrap();
tokio::spawn(handle_broadcasts(id.to_string(), recv, tx.clone()));
}

ChannelMessage::Message(name, value) => {
lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signals.handle_message(&name, value);
}
_ => lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::error!("Unexpected channel message from lyx-core-lyx_core_lyx-core-lyx_core_client"),
},
}
}
});

Ok(rx.into())
}
use futures::{
SinkExt, StreamExt,
channel::mpsc::{self, Sender},
};

#[cfg(any(feature = "csr", feature = "hydrate"))]
async fn handle_broadcasts_lyx-core-lyx_core_lyx-core-lyx_core_client(
mut receiver: tokio::sync::broadcast::Receiver<(Option<String>, Messages)>,
mut sink: Sender<Result<Messages, ServerFnError>>,
) {
while let Ok(message) = receiver.recv().await {
if sink.send(Ok(message.1)).await.is_err() {
break;
}
}
}

#[cfg(feature = "ssr")]
async fn handle_broadcasts(
id: String,
mut receiver: tokio::sync::broadcast::Receiver<(Option<String>, Messages)>,
mut sink: Sender<Result<Messages, ServerFnError>>,
) {
while let Ok(message) = receiver.recv().await {
if message.0.is_some_and(|v| id == v) {
continue;
}
if sink.send(Ok(message.1)).await.is_err() {
break;
}
}
}

#[cfg(all(feature = "ssr", not(any(feature = "hydrate", feature = "csr"))))]
#[inline]
fn provide_websocket_inner() -> Option<()> {
None
}
/// Establishes and provides a WebSocket connection for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signals.
///
/// This function sets up a WebSocket connection to the specified URL and provides
/// the necessary context for handling lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signals. It's designed to work differently
/// based on whether lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering (SSR) is enabled or the "hydrate" feature is enabled.
///
/// # Returns
///
/// Returns a `Result` which is:
/// - `Some(())` if the connection is successfully established (lyx-core-lyx_core_lyx-core-lyx_core_client-side only).
/// - `None` if running in SSR mode.
///
/// # Features
///
/// - When the "hydrate" feature is enabled (lyx-core-lyx_core_lyx-core-lyx_core_client-side):
///   - Creates a new WebSocket connection.
///   - Sets up message handling for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server signals.
///   - Provides context for `ServerSignalWebSocket` and `ClientSignals`.
///
/// - When the "ssr" feature is enabled (lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side):
///   - Returns `None` without establishing a connection.
///
/// # Examples
///
/// 463: 461: /// use lyx-comm-ws::provide_websocket;
/// fn setup_websocket() {
///     if let Some(_) = provide_websocket() {
///         println!("WebSocket connection established");
///     } else {
///         println!("Running in SSR mode or connection failed");
///     }
/// }
/// 472: 470: ///
/// # Note
///
/// This function should be called in the root component of your Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_application
/// to ensure the WebSocket connection is available throughout the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.
#[cfg(any(feature = "csr", feature = "hydrate", feature = "ssr"))]
pub fn provide_websocket() -> Option<()> {
provide_websocket_inner()
}
