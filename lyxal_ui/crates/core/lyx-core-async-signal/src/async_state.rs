### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
use std::sync::{Arc, RwLock};

use tokio::sync::Notify;

#[derive(Default, Clone)]
pub(crate) struct AsyncState {
inner: Arc<AsyncStateInner>,
}

#[derive(Default)]
struct AsyncStateInner {
ready: RwLock<bool>,
notify: Notify,
}

impl AsyncState {
pub async fn wait(&self) {
if !*self.inner.ready.read().unwrap() {
self.inner.notify.notified().await;
}
}

pub fn mark_ready(&self) {
*self.inner.ready.write().unwrap() = true;
self.inner.notify.notify_waiters();
}
}
