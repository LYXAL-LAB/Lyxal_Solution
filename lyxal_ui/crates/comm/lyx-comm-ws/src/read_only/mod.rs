### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
mod lyx-core-lyx_core_lyx-core-lyx_core_client;
#[cfg(feature = "ssr")]
mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;

/// `ReadOnlySignal<T>` represents a reactive value that can be updated from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
/// and reflected in the lyx-core-lyx_core_lyx-core-lyx_core_client-side UI.
///
/// # Type Parameters
///
/// * `T`: The type of value stored in the signal. This type must satisfy the following trait bounds:
///   - `serde::Serialize`: For serialization when sending updates across the network.
///   - `serde::Deserialize<'static>`: For deserialization when receiving updates.
///   - `Clone`: To allow the value to be cloned when necessary.
///   - `Send`: To ensure the value can be safely transferred across thread boundaries.
///   - `Sync`: To allow the value to be safely shared between threads.
/// # Usage
///
/// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server:
/// ,ignore
/// #[cfg(feature = "ssr")]
/// fn create_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signal() -> ReadOnlySignal<i32> {
///     ReadOnlySignal::new("counter", 0).unwrap()
/// }
/// 79: 77: /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, while outside of a lyx-core-lyx_core_lyx-core-lyx_core_leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function context, eg in an Actix or Axum
/// handler:
/// 82: 80: /// #[cfg(feature = "ssr")]
/// use lyx-comm-ws::ReadOnlySignal;
/// fn create_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signal() -> ReadOnlySignal<i32> {
///     # fn get_signals_from_actix_or_axum() -> lyx-comm-ws::WsSignals { lyx-comm-ws::WsSignals::new() }
///     let mut signals = get_signals_from_actix_or_axum(); // get it from lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state
///     ReadOnlySignal::new_with_context(&mut signals, "counter", 0).unwrap()
/// }
/// 90: 88: ///
/// On the lyx-core-lyx_core_lyx-core-lyx_core_client:
/// ,ignore
/// #[cfg(any(feature = "csr", feature = "hydrate"))]
/// fn use_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signal() {
///     let counter = ReadOnlySignal::<i32>::new("counter", 0);
///     // Use `counter.get()` to read the current value
/// }
/// 99: 97: ///
/// # Note
///
/// When using `ReadOnlySignal`, ensure that you've set up the WebSocket connection
/// using the `provide_websocket` function in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application's root component.
#[cfg(feature = "ssr")]
pub type ReadOnlySignal<T> = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::ServerReadOnlySignal<T>;
#[cfg(all(any(feature = "csr", feature = "hydrate"), not(feature = "ssr")))]
pub type ReadOnlySignal<T> = lyx-core-lyx_core_lyx-core-lyx_core_client::ClientReadOnlySignal<T>;
