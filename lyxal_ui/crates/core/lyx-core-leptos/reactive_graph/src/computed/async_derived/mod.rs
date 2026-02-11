### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\async_derived\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\async_derived\mod.rs
2: ```rust
3: 1: mod arc_async_derived;
4: 2: pub use arc_async_derived::*;
5: 3: #[allow(clippy::module_inception)] // not a pub mod, who cares?
6: 4: mod async_derived;
7: 5: mod future_impls;
8: 6: mod inner;
9: 7: use crate::{
10: 8:     graph::{AnySubscriber, Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server},
11: 9:     owner::Owner,
12: 10: };
13: 11: pub use async_derived::*;
14: 12: pub use future_impls::*;
15: 13: use futures::Future;
16: 14: use pin_project_lite::pin_project;
17: 15: use std::{
18: 16:     pin::Pin,
19: 17:     task::{Context, Poll},
20: 18: };
21: 19: 
22: 20: pin_project! {
23: 21:     /// A [`Future`] wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper that sets the [`Owner`] and [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`] before polling the inner
24: 22:     /// `Future`.
25: 23:     #[derive(Clone)]
26: 24:     #[allow(missing_docs)]
27: 25:     pub struct ScopedFuture<Fut> {
28: 26:         pub owner: Owner,
29: 27:         pub oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>,
30: 28:         #[pin]
31: 29:         pub fut: Fut,
32: 30:     }
33: 31: }
34: 32: 
35: 33: impl<Fut> ScopedFuture<Fut> {
36: 34:     /// Wraps the given `Future` by taking the current [`Owner`] and [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`] and re-setting
37: 35:     /// them as the active owner and oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server every time the inner `Future` is polled.
38: 36:     pub fn new(fut: Fut) -> Self {
39: 37:         let owner = Owner::current().unwrap_or_default();
40: 38:         let oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::get();
41: 39:         Self {
42: 40:             owner,
43: 41:             oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
44: 42:             fut,
45: 43:         }
46: 44:     }
47: 45: 
48: 46:     /// Wraps the given `Future` by taking the current [`Owner`] re-setting it as the
49: 47:     /// active owner every time the inner `Future` is polled. Always untracks, i.e., clears
50: 48:     /// the active [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`] when polled.
51: 49:     pub fn new_untracked(fut: Fut) -> Self {
52: 50:         let owner = Owner::current().unwrap_or_default();
53: 51:         Self {
54: 52:             owner,
55: 53:             oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: None,
56: 54:             fut,
57: 55:         }
58: 56:     }
59: 57: 
60: 58:     #[doc(hidden)]
61: 59:     #[track_caller]
62: 60:     pub fn new_untracked_with_diagnostics(
63: 61:         fut: Fut,
64: 62:     ) -> ScopedFutureUntrackedWithDiagnostics<Fut> {
65: 63:         let owner = Owner::current().unwrap_or_default();
66: 64:         ScopedFutureUntrackedWithDiagnostics {
67: 65:             owner,
68: 66:             oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: None,
69: 67:             fut,
70: 68:         }
71: 69:     }
72: 70: }
73: 71: 
74: 72: impl<Fut: Future> Future for ScopedFuture<Fut> {
75: 73:     type Output = Fut::Output;
76: 74: 
77: 75:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
78: 76:         let this = self.project();
79: 77:         this.owner.with(|| {
80: 78:             #[cfg(debug_assertions)]
81: 79:             let _maybe_guard = if this.oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.is_none() {
82: 80:                 Some(crate::diagnostics::SpecialNonReactiveZone::enter())
83: 81:             } else {
84: 82:                 None
85: 83:             };
86: 84:             this.oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| this.fut.poll(cx))
87: 85:         })
88: 86:     }
89: 87: }
90: 88: 
91: 89: pin_project! {
92: 90:     /// A [`Future`] wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper that sets the [`Owner`] and [`Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`] before polling the inner
93: 91:     /// `Future`, output of [`ScopedFuture::new_untracked_with_diagnostics`].
94: 92:     ///
95: 93:     /// In lyx-core-lyx_core_lyx-core-lyx_core_leptos 0.9 this will be replaced with `ScopedFuture` itself.
96: 94:     #[derive(Clone)]
97: 95:     pub struct ScopedFutureUntrackedWithDiagnostics<Fut> {
98: 96:         owner: Owner,
99: 97:         oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Option<AnySubscriber>,
100: 98:         #[pin]
101: 99:         fut: Fut,
102: 100:     }
103: 101: }
104: 102: 
105: 103: impl<Fut: Future> Future for ScopedFutureUntrackedWithDiagnostics<Fut> {
106: 104:     type Output = Fut::Output;
107: 105: 
108: 106:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
109: 107:         let this = self.project();
110: 108:         this.owner
111: 109:             .with(|| this.oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| this.fut.poll(cx)))
112: 110:     }
113: 111: }
114: 112: 
115: 113: /// Utilities used to track whether asynchronous computeds are currently loading.
116: 114: pub mod suspense {
117: 115:     use crate::{
118: 116:         signal::ArcRwSignal,
119: 117:         traits::{Update, Write},
120: 118:     };
121: 119:     use futures::channel::oneshot::Sender;
122: 120:     use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
123: 121:     use slotmap::{DefaultKey, SlotMap};
124: 122:     use std::sync::{Arc, Mutex};
125: 123: 
126: 124:     /// Sends a one-time notification that the resource being read from is "local only," i.e.,
127: 125:     /// that it will only run on the lyx-core-lyx_core_lyx-core-lyx_core_client, not the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
128: 126:     #[derive(Clone, Debug)]
129: 127:     pub struct LocalResourceNotifier(Arc<Mutex<Option<Sender<()>>>>);
130: 128: 
131: 129:     impl LocalResourceNotifier {
132: 130:         /// Send the notification. If the inner channel has already been used, this does nothing.
133: 131:         pub fn notify(&mut self) {
134: 132:             if let Some(tx) = self.0.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().take() {
135: 133:                 tx.send(()).unwrap();
136: 134:             }
137: 135:         }
138: 136:     }
139: 137: 
140: 138:     impl From<Sender<()>> for LocalResourceNotifier {
141: 139:         fn from(value: Sender<()>) -> Self {
142: 140:             Self(Arc::new(Mutex::new(Some(value))))
143: 141:         }
144: 142:     }
145: 143: 
146: 144:     /// Tracks the collection of active async tasks.
147: 145:     #[derive(Clone, Debug)]
148: 146:     pub struct SuspenseContext {
149: 147:         /// The set of active tasks.
150: 148:         pub tasks: ArcRwSignal<SlotMap<DefaultKey, ()>>,
151: 149:     }
152: 150: 
153: 151:     impl SuspenseContext {
154: 152:         /// Generates a unique task ID.
155: 153:         pub fn task_id(&self) -> TaskHandle {
156: 154:             let key = self.tasks.write().insert(());
157: 155:             TaskHandle {
158: 156:                 tasks: self.tasks.clone(),
159: 157:                 key,
160: 158:             }
161: 159:         }
162: 160:     }
163: 161: 
164: 162:     /// A unique identifier that removes itself from the set of tasks when it is dropped.
165: 163:     #[derive(Debug)]
166: 164:     pub struct TaskHandle {
167: 165:         tasks: ArcRwSignal<SlotMap<DefaultKey, ()>>,
168: 166:         key: DefaultKey,
169: 167:     }
170: 168: 
171: 169:     impl Drop for TaskHandle {
172: 170:         fn drop(&mut self) {
173: 171:             self.tasks.update(|tasks| {
174: 172:                 tasks.remove(self.key);
175: 173:             });
176: 174:         }
177: 175:     }
178: 176: }
179: ```
```
