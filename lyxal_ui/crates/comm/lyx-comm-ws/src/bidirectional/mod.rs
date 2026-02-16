1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-ws\src\bidirectional\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\bidirectional\mod.rs
54: 52: ```rust
55: 53: mod lyx-core-lyx_core_lyx-core-lyx_core_client;
56: 54: #[cfg(feature = "ssr")]
57: 55: mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;
58: 56: 
59: 57: /// `BiDirectionalSignal<T>` represents a reactive value that can be updated from both the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
60: 58: /// and the lyx-core-lyx_core_lyx-core-lyx_core_client, with changes automatically synchronized between them in real time.
61: 59: ///
62: 60: /// # Type Parameters
63: 61: ///
64: 62: /// * `T`: The type of value stored in the signal. This type must satisfy:
65: 63: ///   - `serde::Serialize`: For serialization when sending updates across the network.
66: 64: ///   - `serde::de::DeserializeOwned`: For deserialization when receiving updates.
67: 65: ///   - `Clone`: To allow the value to be cloned when necessary.
68: 66: ///   - `Send`: To ensure the value can be safely transferred across thread boundaries.
69: 67: ///   - `Sync`: To allow the value to be safely shared between threads.
70: 68: ///
71: 69: /// # Usage
72: 70: ///
73: 71: /// On both lyx-core-lyx_core_lyx-core-lyx_core_client and lyx-platform-lyx_platform_lyx-platform-lyx_platform_server:
74: 72: /// ```rust,ignore
75: 73: /// // Create a bidirectional signal named "count_bi"
76: 74: /// let count_bi = BiDirectionalSignal::<i32>::new("count_bi", 0).unwrap();
77: 75: /// ```
78: 76: /// On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server, if outside of a lyx-core-lyx_core_lyx-core-lyx_core_leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function context, eg in an Actix or Axum
79: 77: /// handler:
80: 78: /// ```rust
81: 79: /// #[cfg(feature = "ssr")]
82: 80: /// use lyx-comm-ws::BiDirectionalSignal;
83: 81: /// # fn get_signals_from_actix_or_axum() -> lyx-comm-ws::WsSignals { lyx-comm-ws::WsSignals::new() }
84: 82: /// let mut signals = get_signals_from_actix_or_axum(); // get it from lyx-platform-lyx_platform_lyx-platform-lyx_platform_app state
85: 83: /// let count_bi = BiDirectionalSignal::<i32>::new_with_context(&mut signals, "count_bi", 0).unwrap();
86: 84: /// ```
87: 85: ///
88: 86: /// ```rust,ignore
89: 87: /// // On the lyx-core-lyx_core_lyx-core-lyx_core_client: update the value
90: 88: /// count_bi.update(|value| *value += 1);
91: 89: ///
92: 90: /// // On the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server: update the value
93: 91: /// count_bi.update(|value| *value += 100);
94: 92: ///
95: 93: /// // Read the current value (on either side)
96: 94: /// let current = count_bi.get();
97: 95: /// ```
98: 96: ///
99: 97: /// # Note
100: 98: ///
101: 99: /// When using `BiDirectionalSignal`, ensure that you've set up the WebSocket connection
102: 100: /// using the `provide_websocket` function in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application's root component.
103: 101: #[cfg(feature = "ssr")]
104: 102: pub type BiDirectionalSignal<T> = lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::ServerBidirectionalSignal<T>;
105: 103: #[cfg(all(any(feature = "csr", feature = "hydrate"), not(feature = "ssr")))]
106: 104: pub type BiDirectionalSignal<T> = lyx-core-lyx_core_lyx-core-lyx_core_client::ClientBidirectionalSignal<T>;
107: 105: ```
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
133: ```
```

