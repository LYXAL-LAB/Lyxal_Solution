### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
mod lyx-core-lyx_core_lyx-core-lyx_core_client;
#[cfg(feature = "ssr")]
mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;

/// `BiDirectionalSignal<T>` represents a reactive value that can be updated from both the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
/// and the lyx-core-lyx_core_lyx-core-lyx_core_client, with changes automatically synchronized between them in real time.
///
/// # Type Parameters
///
/// * `T`: The type of value stored in the signal. This type must satisfy:
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
/// // Create a bidirectional signal named "count_bi"
/// let count_bi = BiDirectionalSignal::<i32>::new("count_bi", 0).unwrap();
/// 78: 76: /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, if outside of a lyx-core-lyx_core_lyx-core-lyx_core_leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function context, eg in an Actix or Axum
/// handler:
/// 81: 79: /// #[cfg(feature = "ssr")]
/// use lyx-comm-ws::BiDirectionalSignal;
/// # fn get_signals_from_actix_or_axum() -> lyx-comm-ws::WsSignals { lyx-comm-ws::WsSignals::new() }
/// let mut signals = get_signals_from_actix_or_axum(); // get it from lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state
/// let count_bi = BiDirectionalSignal::<i32>::new_with_context(&mut signals, "count_bi", 0).unwrap();
/// 87: 85: ///
/// ,ignore
/// // On the lyx-core-lyx_core_lyx-core-lyx_core_client: update the value
/// count_bi.update(|value| *value += 1);
///
/// // On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server: update the value
/// count_bi.update(|value| *value += 100);
///
/// // Read the current value (on either side)
/// let current = count_bi.get();
/// 98: 96: ///
/// # Note
///
/// When using `BiDirectionalSignal`, ensure that you've set up the WebSocket connection
/// using the `provide_websocket` function in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application's root component.
#[cfg(feature = "ssr")]
pub type BiDirectionalSignal<T> = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::ServerBidirectionalSignal<T>;
#[cfg(all(any(feature = "csr", feature = "hydrate"), not(feature = "ssr")))]
pub type BiDirectionalSignal<T> = lyx-core-lyx_core_lyx-core-lyx_core_client::ClientBidirectionalSignal<T>;
