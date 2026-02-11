### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\lib.rs
2: ```rust
3: 1: //! An implementation of a fine-grained reactive system.
4: 2: //!
5: 3: //! Fine-grained reactivity is an lyx-platform-lyx_platform_lyx-platform-lyx_platform_approach to modeling the flow of data through an interactive
6: 4: //! lyx-platform-lyx_platform_lyx-platform-lyx_platform_application by composing together three categories of reactive primitives:
7: 5: //! 1. **Signals**: atomic units of state, which can be directly mutated.
8: 6: //! 2. **Computations**: derived values, which cannot be mutated directly but update whenever the signals
9: 7: //!    they depend on change. These include both synchronous and asynchronous derived values.
10: 8: //! 3. **Effects**: side effects that synchronize the reactive system with the non-reactive world
11: 9: //!    outside it.
12: 10: //!
13: 11: //! Signals and computations are "source" nodes in the reactive graph, because an oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server can
14: 12: //! subscribe to them to respond to changes in their values. Effects and computations are "subscriber"
15: 13: //! nodes, because they can listen to changes in other values.
16: 14: //!
17: 15: //! ```rust
18: 16: //! # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
19: 17: //! # let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
20: 18: //! use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
21: 19: //!     computed::ArcMemo,
22: 20: //!     effect::Effect,
23: 21: //!     prelude::{Read, Set},
24: 22: //!     signal::ArcRwSignal,
25: 23: //! };
26: 24: //!
27: 25: //! let count = ArcRwSignal::new(1);
28: 26: //! let double_count = ArcMemo::new({
29: 27: //!     let count = count.clone();
30: 28: //!     move |_| *count.read() * 2
31: 29: //! });
32: 30: //!
33: 31: //! // the effect will run once initially
34: 32: //! Effect::new(move |_| {
35: 33: //!     println!("double_count = {}", *double_count.read());
36: 34: //! });
37: 35: //!
38: 36: //! // updating `count` will propagate changes to the dependencies,
39: 37: //! // causing the effect to run again
40: 38: //! count.set(2);
41: 39: //! ```
42: 40: //!
43: 41: //! This reactivity is called "fine grained" because updating the value of a signal only affects
44: 42: //! the effects and computations that depend on its value, without requiring any diffing or update
45: 43: //! calculations for other values.
46: 44: //!
47: 45: //! This model is especially suitable for building user interfaces, i.e., long-lived systems in
48: 46: //! which changes can begin from many different entry points. It is not particularly useful in
49: 47: //! "run-once" programs like a CLI.
50: 48: //!
51: 49: //! ## Design Principles and Assumptions
52: 50: //! - **Effects are expensive.** The library is built on the assumption that the side effects
53: 51: //!   (making a network request, rendering something to the DOM, writing to disk) are orders of
54: 52: //!   magnitude more expensive than propagating signal updates. As a result, the algorithm is
55: 53: //!   designed to avoid re-running side effects unnecessarily, and is willing to sacrifice a small
56: 54: //!   amount of raw update speed to that goal.
57: 55: //! - **Automatic dependency tracking.** Dependencies are not specified as a compile-time list, but
58: 56: //!   tracked at runtime. This in turn enables **dynamic dependency tracking**: subscribers
59: 57: //!   unsubscribe from their sources between runs, which means that a subscriber that contains a
60: 58: //!   condition branch will not re-run when dependencies update that are only used in the inactive
61: 59: //!   branch.
62: 60: //! - **Asynchronous effect scheduling.** Effects are spawned as asynchronous tasks. This means
63: 61: //!   that while updating a signal will immediately update its value, effects that depend on it
64: 62: //!   will not run until the next "tick" of the async runtime. (This in turn means that the
65: 63: //!   reactive system is *async runtime agnostic*: it can be used in the browser with
66: 64: //!   `wasm-bindgen-futures`, in a native binary with `tokio`, in a GTK lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with `glib`,
67: 65: //!   etc.)
68: 66: //!
69: 67: //! The reactive-graph algorithm used in this crate is based on that of
70: 68: //! [Reactively](https://github.com/modderme123/reactively), as described
71: 69: //! [in this article](https://dev.to/modderme123/super-charging-fine-grained-reactive-performance-47ph).
72: 70: 
73: 71: #![cfg_attr(all(feature = "nightly", rustc_nightly), feature(unboxed_closures))]
74: 72: #![cfg_attr(all(feature = "nightly", rustc_nightly), feature(fn_traits))]
75: 73: #![deny(missing_docs)]
76: 74: 
77: 75: use std::{fmt::Arguments, future::Future};
78: 76: 
79: 77: pub mod actions;
80: 78: pub(crate) mod channel;
81: 79: pub mod computed;
82: 80: pub mod diagnostics;
83: 81: pub mod effect;
84: 82: pub mod graph;
85: 83: pub mod owner;
86: 84: pub mod send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_ext;
87: 85: #[cfg(feature = "serde")]
88: 86: mod serde;
89: 87: pub mod signal;
90: 88: mod trait_options;
91: 89: pub mod traits;
92: 90: pub mod transition;
93: 91: pub mod wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers;
94: 92: 
95: 93: mod into_reactive_value;
96: 94: pub use into_reactive_value::*;
97: 95: 
98: 96: /// A standard way to wrap functions and closures to pass them to components.
99: 97: pub mod callback;
100: 98: 
101: 99: use computed::ScopedFuture;
102: 100: 
103: 101: #[cfg(all(feature = "nightly", rustc_nightly))]
104: 102: mod nightly;
105: 103: 
106: 104: /// Reexports frequently-used traits.
107: 105: pub mod prelude {
108: 106:     pub use crate::{
109: 107:         into_reactive_value::IntoReactiveValue, owner::FromLocal, traits::*,
110: 108:     };
111: 109: }
112: 110: 
113: 111: // TODO remove this, it's just useful while developing
114: 112: #[allow(unused)]
115: 113: #[doc(hidden)]
116: 114: pub fn log_warning(text: Arguments) {
117: 115:     #[cfg(all(target_arch = "wasm32", target_os = "unknown"))]
118: 116:     {
119: 117:         web_sys::console::warn_1(&text.to_string().into());
120: 118:     }
121: 119:     #[cfg(all(
122: 120:         not(feature = "tracing"),
123: 121:         not(all(target_arch = "wasm32", target_os = "unknown"))
124: 122:     ))]
125: 123:     {
126: 124:         eprintln!("{text}");
127: 125:     }
128: 126: }
129: 127: 
130: 128: /// Calls [`Executor::spawn`](lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn) on non-wasm targets and [`Executor::spawn_local`](lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local) on wasm targets, but ensures that the task also runs in the current arena, if
131: 129: /// multithreaded arena sandboxing is enabled.
132: 130: pub fn spawn(task: impl Future<Output = ()> + Send + 'static) {
133: 131:     #[cfg(feature = "sandboxed-arenas")]
134: 132:     let task = owner::Sandboxed::new(task);
135: 133: 
136: 134:     #[cfg(not(target_family = "wasm"))]
137: 135:     lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn(task);
138: 136: 
139: 137:     #[cfg(target_family = "wasm")]
140: 138:     lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local(task);
141: 139: }
142: 140: 
143: 141: /// Calls [`Executor::spawn_local`](lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local), but ensures that the task also runs in the current arena, if
144: 142: /// multithreaded arena sandboxing is enabled.
145: 143: pub fn spawn_local(task: impl Future<Output = ()> + 'static) {
146: 144:     #[cfg(feature = "sandboxed-arenas")]
147: 145:     let task = owner::Sandboxed::new(task);
148: 146: 
149: 147:     lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local(task);
150: 148: }
151: 149: 
152: 150: /// Calls [`Executor::spawn_local`](lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor), but ensures that the task runs under the current reactive [`Owner`](crate::owner::Owner) and oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
153: 151: ///
154: 152: /// Does not cancel the task if the owner is cleaned up.
155: 153: pub fn spawn_local_scoped(task: impl Future<Output = ()> + 'static) {
156: 154:     let task = ScopedFuture::new(task);
157: 155: 
158: 156:     #[cfg(feature = "sandboxed-arenas")]
159: 157:     let task = owner::Sandboxed::new(task);
160: 158: 
161: 159:     lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local(task);
162: 160: }
163: 161: 
164: 162: /// Calls [`Executor::spawn_local`](lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor), but ensures that the task runs under the current reactive [`Owner`](crate::owner::Owner) and oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.
165: 163: ///
166: 164: /// Cancels the task if the owner is cleaned up.
167: 165: pub fn spawn_local_scoped_with_cancellation(
168: 166:     task: impl Future<Output = ()> + 'static,
169: 167: ) {
170: 168:     use crate::owner::on_cleanup;
171: 169:     use futures::future::{AbortHandle, Abortable};
172: 170: 
173: 171:     let (abort_handle, abort_registration) = AbortHandle::new_pair();
174: 172:     on_cleanup(move || abort_handle.abort());
175: 173: 
176: 174:     let task = Abortable::new(task, abort_registration);
177: 175:     let task = ScopedFuture::new(task);
178: 176: 
179: 177:     #[cfg(feature = "sandboxed-arenas")]
180: 178:     let task = owner::Sandboxed::new(task);
181: 179: 
182: 180:     lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local(async move {
183: 181:         _ = task.await;
184: 182:     });
185: 183: }
186: ```
```
