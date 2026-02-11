### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-async-signal\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-async-signal\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\src\lib.rs
26: 24: ```rust
27: 25: //! # About async signal
28: 26: //!
29: 27: //! `lyx-core-src` is a library built on top of
30: 28: //! [Leptos](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos) that extends the functionality of Leptos signals
31: 29: //!  to provide a mechanism for generating values  asynchronously. This library
32: 30: //! is particularly useful in lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering (SSR) contexts where
33: 31: //! certain lyx-platform-lyx_platform_lyx-platform-lyx_platform_application elements need to be generated asynchronously before the
34: 32: //! associated signal is set.
35: 33: //!
36: 34: //! # Use case
37: 35: //!
38: 36: //! A typical lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example is generating breadcrumbs for a page. Breadcrumbs, which
39: 37: //! lyx-platform-lyx_platform_lyx-platform-lyx_platform_appear at the top of the page, often depend on deeper page elements or
40: 38: //! lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side data. With `lyx-core-src`, you can generate these
41: 39: //! breadcrumbs asynchronously in SSR mode and still allow them to react to
42: 40: //! changes dynamically in other modes.
43: 41: //!
44: 42: //! This pattern mimics the behavior of `lyx-core-lyx_core_lyx-core-meta` for managing HTML meta
45: 43: //! elements but extends the functionality to any lyx-platform-lyx_platform_lyx-platform-lyx_platform_application element.
46: 44: //!
47: 45: //! # Example
48: 46: //!
49: 47: //! Check the
50: 48: //! [breadcrumbs lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example](https://github.com/demiurg-dev/lyx-core-src/tree/main/sample-crumbs)
51: 49: //! in the repository.
52: 50: //!
53: 51: //! # Leptos versions
54: 52: //!
55: 53: //! The currently supported Leptos version is `0.7.x`.
56: 54: 
57: 55: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
58: 56: use serde::de::DeserializeOwned;
59: 57: use serde::Serialize;
60: 58: 
61: 59: #[cfg(feature = "ssr")]
62: 60: mod async_state;
63: 61: #[cfg(feature = "ssr")]
64: 62: use async_state::AsyncState;
65: 63: 
66: 64: /// An async write signal. This is almost the same as the regular Leptos write
67: 65: /// signal, but under  the hood also takes care of notifying the resource about
68: 66: /// the new value (in SSR mode).
69: 67: #[derive(Clone)]
70: 68: pub struct AsyncWriteSignal<T>
71: 69: where
72: 70:     T: 'static,
73: 71: {
74: 72:     inner: WriteSignal<T>,
75: 73:     #[cfg(feature = "ssr")]
76: 74:     state: AsyncState,
77: 75: }
78: 76: 
79: 77: /// Creates a new async signal, that is, a pair of a resource and an async write
80: 78: /// signal. The default provided value is used only as a placeholder value in
81: 79: /// the case that write signal is never written to (detected by the dropped
82: 80: /// value before write/set).
83: 81: pub fn async_signal<T>(default: T) -> (Resource<T>, AsyncWriteSignal<T>)
84: 82: where
85: 83:     T: Clone + Send + Sync + PartialEq + Serialize + DeserializeOwned,
86: 84: {
87: 85:     let (signal_read, signal_write) = signal(default);
88: 86:     #[cfg(feature = "ssr")]
89: 87:     let state = AsyncState::default();
90: 88:     let signal_write = AsyncWriteSignal {
91: 89:         inner: signal_write,
92: 90:         #[cfg(feature = "ssr")]
93: 91:         state: state.clone(),
94: 92:     };
95: 93:     let resource = Resource::new(
96: 94:         move || signal_read.get(),
97: 95:         move |_| {
98: 96:             #[cfg(feature = "ssr")]
99: 97:             let state = state.clone();
100: 98:             async move {
101: 99:                 #[cfg(feature = "ssr")]
102: 100:                 state.wait().await;
103: 101:                 signal_read.get_untracked()
104: 102:             }
105: 103:         },
106: 104:     );
107: 105:     (resource, signal_write)
108: 106: }
109: 107: 
110: 108: impl<T> Set for AsyncWriteSignal<T>
111: 109: where
112: 110:     T: Send + Sync + 'static,
113: 111: {
114: 112:     type Value = T;
115: 113: 
116: 114:     fn set(&self, value: Self::Value) {
117: 115:         self.inner.set(value);
118: 116:         #[cfg(feature = "ssr")]
119: 117:         self.state.mark_ready();
120: 118:     }
121: 119: 
122: 120:     fn try_set(&self, value: Self::Value) -> Option<Self::Value> {
123: 121:         let res = self.inner.try_set(value);
124: 122:         #[cfg(feature = "ssr")]
125: 123:         self.state.mark_ready();
126: 124:         res
127: 125:     }
128: 126: }
129: 127: 
130: 128: #[cfg(feature = "ssr")]
131: 129: impl<T> Drop for AsyncWriteSignal<T> {
132: 130:     fn drop(&mut self) {
133: 131:         self.state.mark_ready();
134: 132:     }
135: 133: }
136: 134: ```
137: 135: ```
138: 136: ```
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: 143: ```
146: 144: ```
147: 145: ```
148: ```
```
