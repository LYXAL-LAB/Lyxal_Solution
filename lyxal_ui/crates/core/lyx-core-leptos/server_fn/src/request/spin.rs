### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\spin.rs
22: 20: ```rust
23: 21: use crate::{error::ServerFnError, request::Req};
24: 22: use axum::body::{Body, Bytes};
25: 23: use futures::{Stream, StreamExt};
26: 24: use http::{
27: 25:     header::{ACCEPT, CONTENT_TYPE, REFERER},
28: 26:     Request,
29: 27: };
30: 28: use http_body_util::BodyExt;
31: 29: use std::borrow::Cow;
32: 30: 
33: 31: impl<E> Req<E> for IncomingRequest
34: 32: where
35: 33:     CustErr: 'static,
36: 34: {
37: 35:     fn as_query(&self) -> Option<&str> {
38: 36:         self.uri().query()
39: 37:     }
40: 38: 
41: 39:     fn to_content_type(&self) -> Option<Cow<'_, str>> {
42: 40:         self.headers()
43: 41:             .get(CONTENT_TYPE)
44: 42:             .map(|h| String::from_utf8_lossy(h.as_bytes()))
45: 43:     }
46: 44: 
47: 45:     fn accepts(&self) -> Option<Cow<'_, str>> {
48: 46:         self.headers()
49: 47:             .get(ACCEPT)
50: 48:             .map(|h| String::from_utf8_lossy(h.as_bytes()))
51: 49:     }
52: 50: 
53: 51:     fn referer(&self) -> Option<Cow<'_, str>> {
54: 52:         self.headers()
55: 53:             .get(REFERER)
56: 54:             .map(|h| String::from_utf8_lossy(h.as_bytes()))
57: 55:     }
58: 56: 
59: 57:     async fn try_into_bytes(self) -> Result<Bytes, E> {
60: 58:         let (_parts, body) = self.into_parts();
61: 59: 
62: 60:         body.collect().await.map(|c| c.to_bytes()).map_err(|e| {
63: 61:             ServerFnErrorErr::Deserialization(e.to_string()).into()
64: 62:         })
65: 63:     }
66: 64: 
67: 65:     async fn try_into_string(self) -> Result<String, E> {
68: 66:         let bytes = self.try_into_bytes().await?;
69: 67:         String::from_utf8(bytes.to_vec()).map_err(|e| {
70: 68:             ServerFnErrorErr::Deserialization(e.to_string()).into()
71: 69:         })
72: 70:     }
73: 71: 
74: 72:     fn try_into_stream(
75: 73:         self,
76: 74:     ) -> Result<impl Stream<Item = Result<Bytes, Bytes>> + Send + 'static, E>
77: 75:     {
78: 76:         Ok(self.into_body().into_data_stream().map(|chunk| {
79: 77:             chunk.map_err(|e| {
80: 78:                 E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(ServerFnErrorErr::Deserialization(
81: 79:                     e.to_string(),
82: 80:                 ))
83: 81:                 .ser()
84: 82:             })
85: 83:         }))
86: 84:     }
87: 85: }
88: 86: ```
89: 87: ```
90: 88: ```
91: 89: ```
92: 90: ```
93: 91: ```
94: 92: ```
95: 93: ```
96: 94: ```
97: 95: ```
98: ```
```
