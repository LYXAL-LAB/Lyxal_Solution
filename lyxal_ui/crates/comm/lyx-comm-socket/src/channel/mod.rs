### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_socket\src\channel\mod.rs
use std::fmt::Debug;

use serde::{Deserialize, Serialize};

mod context;
#[cfg(feature = "ssr")]
mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;

pub use context::*;
use serde_json::Value;
#[cfg(feature = "ssr")]
pub use lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::{ServerSocket, ServerSocketInner, send, send_to_self};

pub const WEBSOCKET_CHANNEL_URL: &str = "/socket-msg";

#[derive(Debug, Serialize, Deserialize, Clone)]
pub(crate) enum ChannelMsg {
Msg { key: Value, msg: Value },
Subscribe { key: Value },
Unsubscribe { key: Value },
}
