### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-ws\src\traits.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx-comm-ws\src\traits.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\comm\lyx_comm_ws\src\traits.rs
54: 52: ```rust
55: 53: use crate::{error::Error, messages::Messages};
56: 54: use async_trait::async_trait;
57: 55: use json_patch::Patch;
58: 56: use serde_json::Value;
59: 57: use std::any::Any;
60: 58: #[async_trait]
61: 59: pub trait WsSignalCore: private::DeleteTrait {
62: 60:     fn as_any(&self) -> &dyn Any;
63: 61:     fn name(&self) -> &str;
64: 62:     fn json(&self) -> Result<Value, Error>;
65: 63: 
66: 64:     async fn update_json(&self, patch: &Patch, id: Option<String>) -> Result<(), Error>;
67: 65: 
68: 66:     fn set_json(&self, new_value: Value) -> Result<(), Error>;
69: 67:     fn subscribe(
70: 68:         &self,
71: 69:     ) -> Result<tokio::sync::broadcast::Receiver<(Option<String>, Messages)>, Error>;
72: 70:     fn on_reconnect_message(&self) -> Result<Messages, Error>;
73: 71: }
74: 72: 
75: 73: /// Trait for channel signals that can handle lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and lyx-core-lyx_core_lyx-core-lyx_core_client-side message callbacks
76: 74: #[async_trait]
77: 75: pub trait ChannelSignalTrait: private::DeleteTrait + Send + Sync + 'static {
78: 76:     fn as_any(&self) -> &dyn Any;
79: 77: 
80: 78:     /// Subscribe to updates
81: 79:     fn subscribe(
82: 80:         &self,
83: 81:     ) -> Result<tokio::sync::broadcast::Receiver<(Option<String>, Messages)>, Error>;
84: 82:     /// Call callback function with message
85: 83:     fn handle_message(&self, message: Value) -> Result<(), Error>;
86: 84: 
87: 85:     fn on_reconnect_message(&self) -> Result<Messages, Error>;
88: 86: }
89: 87: 
90: 88: pub(crate) mod private {
91: 89:     use crate::error::Error;
92: 90: 
93: 91:     pub trait DeleteTrait {
94: 92:         fn delete(&self) -> Result<(), Error>;
95: 93:     }
96: 94: }
97: 95: ```
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: 101: ```
104: 102: ```
105: 103: ```
106: 104: ```
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
123: ```
```
