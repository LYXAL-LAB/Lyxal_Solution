### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\generic.rs
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
37: 35: use super::{Res, TryRes};
38: 36: use crate::error::{
39: 37:     FromServerFnError, IntoAppError, ServerFnErrorErr, ServerFnErrorWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper,
40: 38:     SERVER_FN_ERROR_HEADER,
41: 39: };
42: 40: use bytes::Bytes;
43: 41: use futures::{Stream, TryStreamExt};
44: 42: use http::{header, HeaderValue, Response, StatusCode};
45: 43: use std::pin::Pin;
46: 44: use lyx-core-any_error::Error;
47: 45: 
48: 46: /// The Body of a Response whose *execution model* can be
49: 47: /// customised using the variants.
50: 48: pub enum Body {
51: 49:     /// The response body will be written synchronously.
52: 50:     Sync(Bytes),
53: 51: 
54: 52:     /// The response body will be written asynchronously,
55: 53:     /// this execution model is also known as
56: 54:     /// "streaming".
57: 55:     Async(Pin<Box<dyn Stream<Item = Result<Bytes, Error>> + Send + 'static>>),
58: 56: }
59: 57: 
60: 58: impl From<String> for Body {
61: 59:     fn from(value: String) -> Self {
62: 60:         Body::Sync(Bytes::from(value))
63: 61:     }
64: 62: }
65: 63: 
66: 64: impl From<Bytes> for Body {
67: 65:     fn from(value: Bytes) -> Self {
68: 66:         Body::Sync(value)
69: 67:     }
70: 68: }
71: 69: 
72: 70: impl<E> TryRes<E> for Response<Body>
73: 71: where
74: 72:     E: Send + Sync + FromServerFnError,
75: 73: {
76: 74:     fn try_from_string(content_type: &str, data: String) -> Result<Self, E> {
77: 75:         let builder = http::Response::builder();
78: 76:         builder
79: 77:             .status(200)
80: 78:             .header(http::header::CONTENT_TYPE, content_type)
81: 79:             .body(data.into())
82: 80:             .map_err(|e| {
83: 81:                 ServerFnErrorErr::Response(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
84: 82:             })
85: 83:     }
86: 84: 
87: 85:     fn try_from_bytes(content_type: &str, data: Bytes) -> Result<Self, E> {
88: 86:         let builder = http::Response::builder();
89: 87:         builder
90: 88:             .status(200)
91: 89:             .header(http::header::CONTENT_TYPE, content_type)
92: 90:             .body(Body::Sync(data))
93: 91:             .map_err(|e| {
94: 92:                 ServerFnErrorErr::Response(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
95: 93:             })
96: 94:     }
97: 95: 
98: 96:     fn try_from_stream(
99: 97:         content_type: &str,
100: 98:         data: impl Stream<Item = Result<Bytes, Bytes>> + Send + 'static,
101: 99:     ) -> Result<Self, E> {
102: 100:         let builder = http::Response::builder();
103: 101:         builder
104: 102:             .status(200)
105: 103:             .header(http::header::CONTENT_TYPE, content_type)
106: 104:             .body(Body::Async(Box::pin(
107: 105:                 data.map_err(|e| ServerFnErrorWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper(E::de(e)))
108: 106:                     .map_err(Error::from),
109: 107:             )))
110: 108:             .map_err(|e| {
111: 109:                 ServerFnErrorErr::Response(e.to_string()).into_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_error()
112: 110:             })
113: 111:     }
114: 112: }
115: 113: 
116: 114: impl Res for Response<Body> {
117: 115:     fn error_response(path: &str, err: Bytes) -> Self {
118: 116:         Response::builder()
119: 117:             .status(http::StatusCode::INTERNAL_SERVER_ERROR)
120: 118:             .header(SERVER_FN_ERROR_HEADER, path)
121: 119:             .body(err.into())
122: 120:             .unwrap()
123: 121:     }
124: 122: 
125: 123:     fn content_type(&mut self, content_type: &str) {
126: 124:         if let Ok(content_type) = HeaderValue::from_str(content_type) {
127: 125:             self.headers_mut()
128: 126:                 .insert(header::CONTENT_TYPE, content_type);
129: 127:         }
130: 128:     }
131: 129: 
132: 130:     fn redirect(&mut self, path: &str) {
133: 131:         if let Ok(path) = HeaderValue::from_str(path) {
134: 132:             self.headers_mut().insert(header::LOCATION, path);
135: 133:             *self.status_mut() = StatusCode::FOUND;
136: 134:         }
137: 135:     }
138: 136: }
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: 143: ```
146: 144: ```
147: 145: ```
148: 146: ```
149: ```
```
