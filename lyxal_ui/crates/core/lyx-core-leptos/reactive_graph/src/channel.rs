### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\channel.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\channel.rs
2: ```rust
3: 1: use core::sync::atomic::Ordering::Relaxed;
4: 2: use futures::{task::AtomicWaker, Stream};
5: 3: use std::{
6: 4:     fmt::Debug,
7: 5:     hash::Hash,
8: 6:     pin::Pin,
9: 7:     sync::{atomic::AtomicBool, Arc, Weak},
10: 8:     task::{Context, Poll},
11: 9: };
12: 10: 
13: 11: #[derive(Debug)]
14: 12: pub(crate) struct Sender(Arc<Inner>);
15: 13: 
16: 14: #[derive(Debug)]
17: 15: pub(crate) struct Receiver(Weak<Inner>);
18: 16: 
19: 17: #[derive(Debug, Default)]
20: 18: struct Inner {
21: 19:     waker: AtomicWaker,
22: 20:     set: AtomicBool,
23: 21: }
24: 22: 
25: 23: impl Drop for Inner {
26: 24:     fn drop(&mut self) {
27: 25:         // Sender holds a strong reference to Inner, and Receiver holds a weak reference to Inner,
28: 26:         // so this will run when the Sender is dropped.
29: 27:         //
30: 28:         // The Receiver is usually owned by a spawned async task that is always waiting on the next
31: 29:         // value from its Stream. While it's waiting, it continues owning all the data it has
32: 30:         // captured. That data will not be dropped until the the stream ends.
33: 31:         //
34: 32:         // If we don't wake the waker a final time here, the spawned task will continue waiting for
35: 33:         // a final message from the Receiver that never arrives, because the waker never wakes it
36: 34:         // up again. So we wake the waker a final time, which tries to upgrade the Receiver, which
37: 35:         // fails, which causes the stream to yield Poll::Ready(None), ending the stream, and
38: 36:         // therefore ending the task, and therefore dropping all data that the stream has
39: 37:         // captured, avoiding a memory leak.
40: 38:         self.waker.wake();
41: 39:     }
42: 40: }
43: 41: 
44: 42: pub fn channel() -> (Sender, Receiver) {
45: 43:     let inner = Arc::new(Inner {
46: 44:         waker: AtomicWaker::new(),
47: 45:         set: AtomicBool::new(false),
48: 46:     });
49: 47:     let rx = Arc::downgrade(&inner);
50: 48:     (Sender(inner), Receiver(rx))
51: 49: }
52: 50: 
53: 51: impl Sender {
54: 52:     pub fn notify(&mut self) {
55: 53:         self.0.set.store(true, Relaxed);
56: 54:         self.0.waker.wake();
57: 55:     }
58: 56: }
59: 57: 
60: 58: impl Stream for Receiver {
61: 59:     type Item = ();
62: 60: 
63: 61:     fn poll_next(
64: 62:         self: Pin<&mut Self>,
65: 63:         cx: &mut Context<'_>,
66: 64:     ) -> Poll<Option<Self::Item>> {
67: 65:         if let Some(inner) = self.0.upgrade() {
68: 66:             inner.waker.register(cx.waker());
69: 67: 
70: 68:             if inner.set.swap(false, Relaxed) {
71: 69:                 Poll::Ready(Some(()))
72: 70:             } else {
73: 71:                 Poll::Pending
74: 72:             }
75: 73:         } else {
76: 74:             Poll::Ready(None)
77: 75:         }
78: 76:     }
79: 77: }
80: 78: 
81: 79: impl Hash for Sender {
82: 80:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
83: 81:         Arc::as_ptr(&self.0).hash(state)
84: 82:     }
85: 83: }
86: 84: 
87: 85: impl PartialEq for Sender {
88: 86:     fn eq(&self, other: &Self) -> bool {
89: 87:         Arc::ptr_eq(&self.0, &other.0)
90: 88:     }
91: 89: }
92: 90: 
93: 91: impl Eq for Sender {}
94: 92: 
95: 93: impl Hash for Receiver {
96: 94:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
97: 95:         Weak::as_ptr(&self.0).hash(state)
98: 96:     }
99: 97: }
100: 98: 
101: 99: impl PartialEq for Receiver {
102: 100:     fn eq(&self, other: &Self) -> bool {
103: 101:         Weak::ptr_eq(&self.0, &other.0)
104: 102:     }
105: 103: }
106: 104: 
107: 105: impl Eq for Receiver {}
108: ```
```
