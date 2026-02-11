### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\browser.rs
22: 20: ```rust
23: 21: use super::ClientRes;
24: 22: use crate::{
25: 23:     error::{FromServerFnError, IntoAppError, ServerFnErrorErr},
26: 24:     redirect::REDIRECT_HEADER,
27: 25: };
28: 26: use bytes::Bytes;
29: 27: use futures::{Stream, StreamExt};
30: 28: pub use gloo_net::http::Response;
31: 29: use http::{HeaderMap, HeaderName, HeaderValue};
32: 30: use js_sys::Uint8Array;
33: 31: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
34: 32: use std::{future::Future, str::FromStr};
35: 33: use wasm_bindgen::JsCast;
36: 34: use wasm_streams::ReadableStream;
37: 35: 
38: 36: /// The response to a `fetch` request made in the browser.
39: 37: pub struct BrowserResponse(pub(crate) SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Response>);
40: 38: 
41: 39: impl BrowserResponse {
42: 40:     /// Generate the headers from the internal [`Response`] object.
43: 41:     /// This is a workaround for the fact that the `Response` object does not
44: 42:     /// have a [`HeaderMap`] directly. This function will iterate over the
45: 43:     /// headers and convert them to a [`HeaderMap`].
46: 44:     pub fn generate_headers(&self) -> HeaderMap {
47: 45:         self.0
48: 46:             .headers()
49: 47:             .entries()
50: 48:             .filter_map(|(key, value)| {
51: 49:                 let key = HeaderName::from_str(&key).ok()?;
52: 50:                 let value = HeaderValue::from_str(&value).ok()?;
53: 51:                 Some((key, value))
54: 52:             })
55: 53:             .collect()
56: 54:     }
57: 55: }
58: 56: 
59: 57: impl<E: FromServerFnError> ClientRes<E> for BrowserResponse {
60: 58:     fn try_into_string(self) -> impl Future<Output = Result<String, E>> + Send {
61: 59:         // the browser won't send this async work between threads (because it's single-threaded)
62: 60:         // so we can safely wrap this
63: 61:         SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(async move {
64: 62:             self.0.text().await.map_err(|e| {
65: 63:                 ServerFnErrorErr::Deserialization(e.to_string())
66: 64:                     .into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
67: 65:             })
68: 66:         })
69: 67:     }
70: 68: 
71: 69:     fn try_into_bytes(self) -> impl Future<Output = Result<Bytes, E>> + Send {
72: 70:         // the browser won't send this async work between threads (because it's single-threaded)
73: 71:         // so we can safely wrap this
74: 72:         SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(async move {
75: 73:             self.0.binary().await.map(Bytes::from).map_err(|e| {
76: 74:                 ServerFnErrorErr::Deserialization(e.to_string())
77: 75:                     .into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
78: 76:             })
79: 77:         })
80: 78:     }
81: 79: 
82: 80:     fn try_into_stream(
83: 81:         self,
84: 82:     ) -> Result<impl Stream<Item = Result<Bytes, Bytes>> + Send + 'static, E>
85: 83:     {
86: 84:         let stream = ReadableStream::from_raw(self.0.body().unwrap())
87: 85:             .into_stream()
88: 86:             .map(|data| match data {
89: 87:                 Err(e) => {
90: 88:                     web_sys::console::error_1(&e);
91: 89:                     Err(E::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(ServerFnErrorErr::Request(
92: 90:                         format!("{e:?}"),
93: 91:                     ))
94: 92:                     .ser())
95: 93:                 }
96: 94:                 Ok(data) => {
97: 95:                     let data = data.unchecked_into::<Uint8Array>();
98: 96:                     let mut buf = Vec::new();
99: 97:                     let length = data.length();
100: 98:                     buf.resize(length as usize, 0);
101: 99:                     data.copy_to(&mut buf);
102: 100:                     Ok(Bytes::from(buf))
103: 101:                 }
104: 102:             });
105: 103:         Ok(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(stream))
106: 104:     }
107: 105: 
108: 106:     fn status(&self) -> u16 {
109: 107:         self.0.status()
110: 108:     }
111: 109: 
112: 110:     fn status_text(&self) -> String {
113: 111:         self.0.status_text()
114: 112:     }
115: 113: 
116: 114:     fn location(&self) -> String {
117: 115:         self.0
118: 116:             .headers()
119: 117:             .get("Location")
120: 118:             .unwrap_or_else(|| self.0.url())
121: 119:     }
122: 120: 
123: 121:     fn has_redirect(&self) -> bool {
124: 122:         self.0.headers().get(REDIRECT_HEADER).is_some()
125: 123:     }
126: 124: }
127: 125: ```
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: 130: ```
133: 131: ```
134: 132: ```
135: 133: ```
136: 134: ```
137: ```
```
