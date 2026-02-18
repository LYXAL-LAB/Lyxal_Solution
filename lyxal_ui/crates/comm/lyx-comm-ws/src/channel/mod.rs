### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\channel\mod.rs
mod lyx-core-lyx_core_lyx-core-lyx_core_client;
#[cfg(feature = "ssr")]
mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;

/// `ChannelSignal<T>` represents a simple message channel for communication between the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and lyx-core-lyx_core_lyx-core-lyx_core_client.
/// It enables sending and receiving messages of type `T` in a reactive, event-driven manner.
///
/// # Type Parameters
///
/// * `T`: The type of message transmitted through the channel. This type must satisfy:
///   - `serde::Serialize`: For serialization when sending updates across the network.
///   - `serde::de::DeserializeOwned`: For deserialization when receiving updates.
///   - `Clone`: To allow the value to be cloned when necessary.
///   - `Send`: To ensure the value can be safely transferred across thread boundaries.
///   - `Sync`: To allow the value to be safely shared between threads.
///
/// # Usage
///
/// On both lyx-core-lyx_core_lyx-core-lyx_core_client and lyx-platform-lyx_platform_lyx-platform-lyx_platform_server:
/// ,ignore
/// // Create a channel signal named "echo"
/// let echo_channel = ChannelSignal::<String>::new("echo").unwrap();
/// 78: 76: /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, if outside of a lyx-core-lyx_core_lyx-core-lyx_core_leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function context, eg in an Actix or Axum
/// handler:
/// 81: 79: /// #[cfg(feature = "ssr")]
/// use lyx-comm-ws::ChannelSignal;
///     # fn get_signals_from_actix_or_axum() -> lyx-comm-ws::WsSignals { lyx-comm-ws::WsSignals::new() }
///     let mut signals = get_signals_from_actix_or_axum(); // get it from lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state
///     let echo_channel = ChannelSignal::<String>::new_with_context(&mut signals, "echo").unwrap();
/// 87: 85: ///
/// ,ignore
/// // On the lyx-core-lyx_core_lyx-core-lyx_core_client: listen for messages from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
/// echo_channel.on_lyx-core-lyx_core_lyx-core-lyx_core_client(move |msg: &String| {
///     // Handle incoming message
///     println!("Received: {}", msg);
/// });
///
/// // On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server: listen for messages from the lyx-core-lyx_core_lyx-core-lyx_core_client
/// echo_channel.on_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(move |msg: &String| {
///     // Echo the message back to all lyx-core-lyx_core_lyx-core-lyx_core_clients
///     echo_channel.send_message(msg.clone()).unwrap();
/// });
///
/// // To send a message from the lyx-core-lyx_core_lyx-core-lyx_core_client:
/// echo_channel.send_message("Hello!".to_string()).ok();
/// 104: 102: ///
/// # Note
///
/// When using `ChannelSignal`, ensure that you've set up the WebSocket connection
/// using the `provide_websocket` function in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application's root component.
#[cfg(feature = "ssr")]
pub type ChannelSignal<T> = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::ServerChannelSignal<T>;
#[cfg(all(any(feature = "csr", feature = "hydrate"), not(feature = "ssr")))]
pub type ChannelSignal<T> = lyx-core-lyx_core_lyx-core-lyx_core_client::ClientChannelSignal<T>;
