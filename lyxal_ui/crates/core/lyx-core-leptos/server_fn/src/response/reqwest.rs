### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\reqwest.rs
22: 20: ```rust
23: 21: use super::ClientRes;
24: 22: use crate::error::{FromServerFnError, IntoAppError, ServerFnErrorErr};
25: 23: use bytes::Bytes;
26: 24: use futures::{Stream, TryStreamExt};
27: 25: use reqwest::Response;
28: 26: 
29: 27: impl<E: FromServerFnError> ClientRes<E> for Response {
30: 28:     async fn try_into_string(self) -> Result<String, E> {
31: 29:         self.text().await.map_err(|e| {
32: 30:             ServerFnErrorErr::Deserialization(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
33: 31:         })
34: 32:     }
35: 33: 
36: 34:     async fn try_into_bytes(self) -> Result<Bytes, E> {
37: 35:         self.bytes().await.map_err(|e| {
38: 36:             ServerFnErrorErr::Deserialization(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
39: 37:         })
40: 38:     }
41: 39: 
42: 40:     fn try_into_stream(
43: 41:         self,
44: 42:     ) -> Result<impl Stream<Item = Result<Bytes, Bytes>> + Send + 'static, E>
45: 43:     {
46: 44:         Ok(self.bytes_stream().map_err(|e| {
47: 45:             E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(ServerFnErrorErr::Response(e.to_string()))
48: 46:                 .ser()
49: 47:         }))
50: 48:     }
51: 49: 
52: 50:     fn status(&self) -> u16 {
53: 51:         self.status().as_u16()
54: 52:     }
55: 53: 
56: 54:     fn status_text(&self) -> String {
57: 55:         self.status().to_string()
58: 56:     }
59: 57: 
60: 58:     fn location(&self) -> String {
61: 59:         self.headers()
62: 60:             .get("Location")
63: 61:             .map(|value| String::from_utf8_lossy(value.as_bytes()).to_string())
64: 62:             .unwrap_or_else(|| self.url().to_string())
65: 63:     }
66: 64: 
67: 65:     fn has_redirect(&self) -> bool {
68: 66:         self.headers().get("Location").is_some()
69: 67:     }
70: 68: }
71: 69: ```
72: 70: ```
73: 71: ```
74: 72: ```
75: 73: ```
76: 74: ```
77: 75: ```
78: 76: ```
79: 77: ```
80: 78: ```
81: ```
```
