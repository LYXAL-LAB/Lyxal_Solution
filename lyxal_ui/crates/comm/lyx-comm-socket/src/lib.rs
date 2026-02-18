### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\lib.rs
//! Realtime pub/sub communication for Leptos + Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_applications.
//!
//! ## Usage
//!
//! 60: 58: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
//! # use lyx_comm_socket::{expect_socket_context, ServerSocket, SocketMsg};
//! # use serde::{Serialize, Deserialize};
//! # use axum::extract::{State, FromRef};
//! #
//! # #[derive(FromRef, Clone)]
//! # pub struct AppState {
//! #     pub socket: ServerSocket,
//! # }
//! #
//! // Define the key and message types
//! #[derive(Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Debug)]
//! pub struct MyKey {
//!     pub bla: String,
//! }
//!
//! #[derive(Clone, Serialize, Deserialize, Debug)]
//! pub struct MyMsg {
//!     pub awesome_msg: String,
//! }
//!
//! // Implement the SocketMsg trait for MyMsg to link the key and message types
//! impl SocketMsg for MyMsg {
//!     type Key = MyKey;
//!     #[cfg(feature = "ssr")]
//!     type AppState = AppState;
//! }
//!
//! #[component]
//! pub fn MyComponent() -> impl IntoView {
//!     let socket = expect_socket_context();
//!
//!     // Subscribe to receive messages that are sent with the given key
//!     socket.subscribe(
//!         MyKey {
//!             bla: "bla".to_string(),
//!         },
//!         |msg: &MyMsg| {
//!             // Simply log the message
//!             lyx-core-lyx_core_lyx-core-lyx_core_leptos::logging::log!("message: {msg:#?}");
//!         },
//!     );
//!
//!     let on_click = move || {
//!         // Send a message with the given key
//!         socket.send(
//!             MyKey {
//!                 bla: "bla".to_string(),
//!             },
//!             MyMsg {
//!                 awesome_msg: "awesome message".to_string(),
//!             },
//!         );
//!     };
//!
//!     view! { "..." }
//! }
//!
//! #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
//! pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_function() -> Result<(), ServerFnError> {
//!     // Send from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
//!     lyx_comm_socket::send(
//!        &MyKey {
//!            bla: "bla".to_string(),
//!        },
//!        &MyMsg {
//!            awesome_msg: "Hello, world!".to_string(),
//!        },
//!     ).await;
//!
//!     Ok(())
//! }
//! 133: 131: //!
//! For this to work you have to prepare a little bit.
//!
//! Define your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state in your lib.rs:
//!
//! 139: 137: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
//!
//! #[cfg(feature = "ssr")]
//! #[derive(Clone, axum::extract::FromRef)]
//! pub struct AppState {
//!     // This is required for Leptos Axum Socket to work
//!     pub socket: lyx_comm_socket::ServerSocket,
//!
//!     // this is required for Leptos to work with axum
//!     pub lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: LeptosOptions,
//! }
//! 151: 149: //!
//! Initialize your Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_app (probably in main.rs):
//!
//! 155: 153: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
//! # use lyx_comm_socket::{ServerSocket, SocketMsg, SocketRoute, handlers::upgrade_websocket};
//! # use serde::{Deserialize, Serialize};
//! # use axum::{Router, extract::{State, WebSocketUpgrade, FromRef}, response::Response};
//! # use lyx-core-axum::{generate_route_list, LeptosRoutes};
//! #
//! # #[derive(Clone, FromRef)]
//! # pub struct AppState {
//! #     pub lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket: ServerSocket,
//! #     pub lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: LeptosOptions,
//! # }
//! #
//! # fn shell(options: LeptosOptions) -> impl IntoView {
//! #     ()
//! # }
//! # fn App() -> impl IntoView {
//! #     ()
//! # }
//! #
//! # #[derive(Clone, Serialize, Deserialize, PartialEq, Eq, Hash, Debug)]
//! # pub struct MyKey {
//! #     pub bla: String,
//! # }
//! #
//! # #[derive(Clone, Serialize, Deserialize, Debug)]
//! # pub struct MyMsg {
//! #     pub awesome_msg: String,
//! # }
//! #
//! # impl SocketMsg for MyMsg {
//! #     type Key = MyKey;
//! #     #[cfg(feature = "ssr")]
//! #     type AppState = AppState;
//! # }
//! #
//! #[tokio::main]
//! async fn main() {
//!     let conf = get_configuration(None).unwrap();
//!     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
//!
//!     let routes = generate_route_list(App);
//!
//!     // Construct the Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state
//!     let state = AppState {
//!         lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options,
//!         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket: ServerSocket::new(),
//!     };
//!
//!     // Optional: add subscription filters and message mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers
//!     {
//!         let mut lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket = state.lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket.lock().await;
//!         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket.add_subscribe_filter(async |key: MyKey, _ctx: &()| { key.bla == "bla" });
//!         lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_socket.add_send_mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper(|key: MyKey, msg: MyMsg, _ctx: &()| {
//!             if key.bla == "bla" {
//!                 Some(MyMsg {
//!                     awesome_msg: msg.awesome_msg.replace("old", "new"),
//!                 })
//!             } else {
//!                 None
//!             }
//!         });
//!     }
//!
//!     // Init the Axum lyx-platform-lyx_platform_lyx-platform-lyx_platform_app
//!     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app: Router<AppState> = Router::new()
//!         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&state, routes, {
//!             let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = state.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
//!             move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
//!         })
//!         .socket_route(connect_to_websocket)    // Register the socket route (implementation below)
//!         .fallback(lyx-core-axum::file_and_error_handler::<AppState, _>(shell))
//!         .with_state(state);    // Register the state
//!
//!     let listener = tokio::net::TcpListener::bind(&addr).await.unwrap();
//!     // axum::serve(listener, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.into_make_service())
//!     //    .await
//!     //    .unwrap();
//! }
//!
//! // Implement the `connect_to_websocket` handler:
//! #[cfg(feature = "ssr")]
//! pub async fn connect_to_websocket(
//!     ws: WebSocketUpgrade,
//!     State(socket): State<ServerSocket>,
//! ) -> Response {
//!     // You could do authentication here
//!
//!     // Provide extra context like the user's ID for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example that is passed to the permission filters
//!     let ctx = ();
//!
//!     upgrade_websocket(ws, socket, ctx)
//! }
//! 248: 246: //!
//! And finally provide the context in your root Leptos component:
//!
//! 252: 250: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
//! # use lyx_comm_socket::provide_socket_context;
//! #
//! #[component]
//! pub fn App() -> impl IntoView {
//!     provide_socket_context();
//!
//!     view! { "..." }
//! }
//! 262: 260: //!
//! ### Axum Handlers
//!
//! You can also send messages from inside axum handlers.
//! Checkout [`ServerSocketInner::send`] and [`ServerSocketInner::send_to_self`].

pub mod channel;
#[cfg(feature = "ssr")]
pub mod handlers;

pub use crate::channel::*;

/// Implement this trait to link your socket message types to your key types.
/// In order to use this crate you have to implement this trait for your socket messages.
///
/// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server you have to provide the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application state as well.
///
/// 280: 278: /// # use lyx_comm_socket::{ServerSocket, SocketMsg};
/// # use serde::{Serialize, Deserialize};
/// # use axum::extract::FromRef;
/// #
/// # #[derive(FromRef, Clone)]
/// # pub struct AppState {
/// #     pub socket: ServerSocket,
/// # }
/// #
/// // Define the key and message types
/// #[derive(Clone, Serialize, Deserialize)]
/// pub struct MyKey {
///     pub bla: String,
/// }
///
/// #[derive(Clone, Serialize, Deserialize, Debug)]
/// pub struct MyMsg {
///     pub awesome_msg: String,
/// }
///
/// // Implement the SocketMsg trait for MyMsg to link the key and message types
/// impl SocketMsg for MyMsg {
///     type Key = MyKey;
///     #[cfg(feature = "ssr")]
///     type AppState = AppState;
/// }
/// 307: 305: pub trait SocketMsg {
type Key;
#[cfg(feature = "ssr")]
type AppState;
}

/// Trait to extend the Axum router
#[cfg(feature = "ssr")]
pub trait SocketRoute<S>
where
S: Clone + Send + Sync + 'static,
{
/// Add the necessary websocket route to the Axum router
fn socket_route<H, T>(self, handler: H) -> Self
where
H: axum::handler::Handler<T, S>,
T: 'static;
}

#[cfg(feature = "ssr")]
impl<S> SocketRoute<S> for axum::Router<S>
where
S: Clone + Send + Sync + 'static,
ServerSocket: axum::extract::FromRef<S>,
{
fn socket_route<H, T>(self, handler: H) -> Self
where
H: axum::handler::Handler<T, S>,
T: 'static,
{
use axum::routing::get;
use tracing::debug;

debug!("Adding websocket route to {WEBSOCKET_CHANNEL_URL}");

self.route(WEBSOCKET_CHANNEL_URL, get(handler))
}
}
