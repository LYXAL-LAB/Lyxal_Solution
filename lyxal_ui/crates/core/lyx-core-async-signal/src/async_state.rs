### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-async-signal\src\async_state.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\async_state.rs
24: ```rust
25: use std::sync::{Arc, RwLock};
26: 
27: use tokio::sync::Notify;
28: 
29: #[derive(Default, Clone)]
30: pub(crate) struct AsyncState {
31:     inner: Arc<AsyncStateInner>,
32: }
33: 
34: #[derive(Default)]
35: struct AsyncStateInner {
36:     ready: RwLock<bool>,
37:     notify: Notify,
38: }
39: 
40: impl AsyncState {
41:     pub async fn wait(&self) {
42:         if !*self.inner.ready.read().unwrap() {
43:             self.inner.notify.notified().await;
44:         }
45:     }
46: 
47:     pub fn mark_ready(&self) {
48:         *self.inner.ready.write().unwrap() = true;
49:         self.inner.notify.notify_waiters();
50:     }
51: }
52: ```
53: ```
54: ```
55: ```
56: ```
57: ```
58: ```
59: ```
60: ```
61: ```
62: ```
63: ```
```
