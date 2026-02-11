### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\transition.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\transition.rs
2: ```rust
3: 1: //! Utilities to wait for asynchronous primitives to resolve.
4: 2: 
5: 3: use futures::{channel::oneshot, future::join_all};
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
7: 5: use std::{
8: 6:     future::Future,
9: 7:     sync::{mpsc, OnceLock, RwLock},
10: 8: };
11: 9: 
12: 10: static TRANSITION: OnceLock<RwLock<Option<TransitionInner>>> = OnceLock::new();
13: 11: 
14: 12: fn global_transition() -> &'static RwLock<Option<TransitionInner>> {
15: 13:     TRANSITION.get_or_init(|| RwLock::new(None))
16: 14: }
17: 15: 
18: 16: #[derive(Debug, Clone)]
19: 17: struct TransitionInner {
20: 18:     tx: mpsc::Sender<oneshot::Receiver<()>>,
21: 19: }
22: 20: 
23: 21: /// Transitions allow you to wait for all asynchronous resources created during them to resolve.
24: 22: #[derive(Debug)]
25: 23: pub struct AsyncTransition;
26: 24: 
27: 25: impl AsyncTransition {
28: 26:     /// Calls the `action` function, and returns a `Future` that resolves when any
29: 27:     /// [`AsyncDerived`](crate::computed::AsyncDerived) or
30: 28:     /// or [`ArcAsyncDerived`](crate::computed::ArcAsyncDerived) that is read during the action
31: 29:     /// has resolved.
32: 30:     ///
33: 31:     /// This allows for an inversion of control: the caller does not need to know when all the
34: 32:     /// resources created inside the `action` will resolve, but can wait for them to notify it.
35: 33:     pub async fn run<T, U>(action: impl FnOnce() -> T) -> U
36: 34:     where
37: 35:         T: Future<Output = U>,
38: 36:     {
39: 37:         let (tx, rx) = mpsc::channel();
40: 38:         let global_transition = global_transition();
41: 39:         let inner = TransitionInner { tx };
42: 40:         let prev = Option::replace(
43: 41:             &mut *global_transition.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(),
44: 42:             inner.clone(),
45: 43:         );
46: 44:         let value = action().await;
47: 45:         _ = std::mem::replace(
48: 46:             &mut *global_transition.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned(),
49: 47:             prev,
50: 48:         );
51: 49:         let mut pending = Vec::new();
52: 50:         while let Ok(tx) = rx.try_recv() {
53: 51:             pending.push(tx);
54: 52:         }
55: 53:         join_all(pending).await;
56: 54:         value
57: 55:     }
58: 56: 
59: 57:     pub(crate) fn register(rx: oneshot::Receiver<()>) {
60: 58:         if let Some(tx) = global_transition()
61: 59:             .read()
62: 60:             .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
63: 61:             .as_ref()
64: 62:             .map(|n| &n.tx)
65: 63:         {
66: 64:             // if it's an Err, that just means the Receiver was dropped
67: 65:             // i.e., the transition is no longer listening, in which case it doesn't matter if we
68: 66:             // successfully register with it or not
69: 67:             _ = tx.send(rx);
70: 68:         }
71: 69:     }
72: 70: }
73: ```
```
