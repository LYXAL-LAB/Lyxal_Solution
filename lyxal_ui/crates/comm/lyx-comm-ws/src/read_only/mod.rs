1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-ws\src\read_only\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\read_only\mod.rs
54: 52: ```rust
55: 53: mod lyx-core-lyx_core_lyx-core-lyx_core_client;
56: 54: #[cfg(feature = "ssr")]
57: 55: mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;
58: 56: 
59: 57: /// `ReadOnlySignal<T>` represents a reactive value that can be updated from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
60: 58: /// and reflected in the lyx-core-lyx_core_lyx-core-lyx_core_client-side UI.
61: 59: ///
62: 60: /// # Type Parameters
63: 61: ///
64: 62: /// * `T`: The type of value stored in the signal. This type must satisfy the following trait bounds:
65: 63: ///   - `serde::Serialize`: For serialization when sending updates across the network.
66: 64: ///   - `serde::Deserialize<'static>`: For deserialization when receiving updates.
67: 65: ///   - `Clone`: To allow the value to be cloned when necessary.
68: 66: ///   - `Send`: To ensure the value can be safely transferred across thread boundaries.
69: 67: ///   - `Sync`: To allow the value to be safely shared between threads.
70: 68: /// # Usage
71: 69: ///
72: 70: /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server:
73: 71: /// ```rust,ignore
74: 72: /// #[cfg(feature = "ssr")]
75: 73: /// fn create_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signal() -> ReadOnlySignal<i32> {
76: 74: ///     ReadOnlySignal::new("counter", 0).unwrap()
77: 75: /// }
78: 76: /// ```
79: 77: /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, while outside of a lyx-core-lyx_core_lyx-core-lyx_core_leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function context, eg in an Actix or Axum
80: 78: /// handler:
81: 79: /// ```rust
82: 80: /// #[cfg(feature = "ssr")]
83: 81: /// use lyx-comm-ws::ReadOnlySignal;
84: 82: /// fn create_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signal() -> ReadOnlySignal<i32> {
85: 83: ///     # fn get_signals_from_actix_or_axum() -> lyx-comm-ws::WsSignals { lyx-comm-ws::WsSignals::new() }
86: 84: ///     let mut signals = get_signals_from_actix_or_axum(); // get it from lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state
87: 85: ///     ReadOnlySignal::new_with_context(&mut signals, "counter", 0).unwrap()
88: 86: /// }
89: 87: /// ```
90: 88: ///
91: 89: /// On the lyx-core-lyx_core_lyx-core-lyx_core_client:
92: 90: /// ```rust,ignore
93: 91: /// #[cfg(any(feature = "csr", feature = "hydrate"))]
94: 92: /// fn use_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_signal() {
95: 93: ///     let counter = ReadOnlySignal::<i32>::new("counter", 0);
96: 94: ///     // Use `counter.get()` to read the current value
97: 95: /// }
98: 96: /// ```
99: 97: ///
100: 98: /// # Note
101: 99: ///
102: 100: /// When using `ReadOnlySignal`, ensure that you've set up the WebSocket connection
103: 101: /// using the `provide_websocket` function in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application's root component.
104: 102: #[cfg(feature = "ssr")]
105: 103: pub type ReadOnlySignal<T> = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::ServerReadOnlySignal<T>;
106: 104: #[cfg(all(any(feature = "csr", feature = "hydrate"), not(feature = "ssr")))]
107: 105: pub type ReadOnlySignal<T> = lyx-core-lyx_core_lyx-core-lyx_core_client::ClientReadOnlySignal<T>;
108: 106: ```
109: 107: ```
110: 108: ```
111: 109: ```
112: 110: ```
113: 111: ```
114: 112: ```
115: 113: ```
116: 114: ```
117: 115: ```
118: 116: ```
119: 117: ```
120: 118: ```
121: 119: ```
122: 120: ```
123: 121: ```
124: 122: ```
125: 123: ```
126: 124: ```
127: 125: ```
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: 130: ```
133: 131: ```
134: ```
```

