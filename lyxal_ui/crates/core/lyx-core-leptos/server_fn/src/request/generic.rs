### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\request\generic.rs
22: 20: ```rust
23: 21: //! This module uses platform-agnostic abstractions
24: 22: //! allowing users to run lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions on a wide range of
25: 23: //! platforms.
26: 24: //!
27: 25: //! The crates in use in this crate are:
28: 26: //!
29: 27: //! * `bytes`: platform-agnostic manipulation of bytes.
30: 28: //! * `http`: low-dependency HTTP abstractions' *front-end*.
31: 29: //!
32: 30: //! # Users
33: 31: //!
34: 32: //! * `wasm32-wasip*` integration crate `lyx-core-lyx_core_lyx-core-lyx_core_leptos_wasi` is using this
35: 33: //!   crate under the hood.
36: 34: 
37: 35: use crate::{
38: 36:     error::{FromServerFnError, IntoAppError, ServerFnErrorErr},
39: 37:     request::Req,
40: 38: };
41: 39: use bytes::Bytes;
42: 40: use futures::{
43: 41:     stream::{self, Stream},
44: 42:     Sink, StreamExt,
45: 43: };
46: 44: use http::{Request, Response};
47: 45: use std::borrow::Cow;
48: 46: 
49: 47: impl<Error, InputStreamError, OutputStreamError>
50: 48:     Req<Error, InputStreamError, OutputStreamError> for Request<Bytes>
51: 49: where
52: 50:     Error: FromServerFnError + Send,
53: 51:     InputStreamError: FromServerFnError + Send,
54: 52:     OutputStreamError: FromServerFnError + Send,
55: 53: {
56: 54:     type WebsocketResponse = Response<Bytes>;
57: 55: 
58: 56:     async fn try_into_bytes(self) -> Result<Bytes, Error> {
59: 57:         Ok(self.into_body())
60: 58:     }
61: 59: 
62: 60:     async fn try_into_string(self) -> Result<String, Error> {
63: 61:         String::from_utf8(self.into_body().into()).map_err(|err| {
64: 62:             ServerFnErrorErr::Deserialization(err.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
65: 63:         })
66: 64:     }
67: 65: 
68: 66:     fn try_into_stream(
69: 67:         self,
70: 68:     ) -> Result<impl Stream<Item = Result<Bytes, Bytes>> + Send + 'static, Error>
71: 69:     {
72: 70:         Ok(stream::iter(self.into_body())
73: 71:             .ready_chunks(16)
74: 72:             .map(|chunk| Ok(Bytes::from(chunk))))
75: 73:     }
76: 74: 
77: 75:     fn to_content_type(&self) -> Option<Cow<'_, str>> {
78: 76:         self.headers()
79: 77:             .get(http::header::CONTENT_TYPE)
80: 78:             .map(|val| String::from_utf8_lossy(val.as_bytes()))
81: 79:     }
82: 80: 
83: 81:     fn accepts(&self) -> Option<Cow<'_, str>> {
84: 82:         self.headers()
85: 83:             .get(http::header::ACCEPT)
86: 84:             .map(|val| String::from_utf8_lossy(val.as_bytes()))
87: 85:     }
88: 86: 
89: 87:     fn referer(&self) -> Option<Cow<'_, str>> {
90: 88:         self.headers()
91: 89:             .get(http::header::REFERER)
92: 90:             .map(|val| String::from_utf8_lossy(val.as_bytes()))
93: 91:     }
94: 92: 
95: 93:     fn as_query(&self) -> Option<&str> {
96: 94:         self.uri().query()
97: 95:     }
98: 96: 
99: 97:     async fn try_into_websocket(
100: 98:         self,
101: 99:     ) -> Result<
102: 100:         (
103: 101:             impl Stream<Item = Result<Bytes, Bytes>> + Send + 'static,
104: 102:             impl Sink<Bytes> + Send + 'static,
105: 103:             Self::WebsocketResponse,
106: 104:         ),
107: 105:         Error,
108: 106:     > {
109: 107:         Err::<
110: 108:             (
111: 109:                 futures::stream::Once<std::future::Ready<Result<Bytes, Bytes>>>,
112: 110:                 futures::sink::Drain<Bytes>,
113: 111:                 Self::WebsocketResponse,
114: 112:             ),
115: 113:             _,
116: 114:         >(Error::from_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_error(
117: 115:             crate::ServerFnErrorErr::Response(
118: 116:                 "Websockets are not supported on this platform.".to_string(),
119: 117:             ),
120: 118:         ))
121: 119:     }
122: 120: }
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
