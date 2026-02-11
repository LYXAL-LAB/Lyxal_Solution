### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\src\response\actix.rs
22: 20: ```rust
23: 21: use super::{Res, TryRes};
24: 22: use crate::error::{
25: 23:     FromServerFnError, ServerFnErrorWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper, SERVER_FN_ERROR_HEADER,
26: 24: };
27: 25: use actix_web::{
28: 26:     http::{
29: 27:         header,
30: 28:         header::{HeaderValue, CONTENT_TYPE, LOCATION},
31: 29:         StatusCode,
32: 30:     },
33: 31:     HttpResponse,
34: 32: };
35: 33: use bytes::Bytes;
36: 34: use futures::{Stream, StreamExt};
37: 35: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
38: 36: 
39: 37: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped Actix response.
40: 38: ///
41: 39: /// This uses a [`SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper`] that allows the Actix `HttpResponse` type to be `Send`, but panics
42: 40: /// if it it is ever sent to another thread. Actix pins request handling to a single thread, so this
43: 41: /// is necessary to be compatible with traits that require `Send` but should never panic in actual use.
44: 42: pub struct ActixResponse(pub(crate) SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<HttpResponse>);
45: 43: 
46: 44: impl ActixResponse {
47: 45:     /// Returns the raw Actix response.
48: 46:     pub fn take(self) -> HttpResponse {
49: 47:         self.0.take()
50: 48:     }
51: 49: }
52: 50: 
53: 51: impl From<HttpResponse> for ActixResponse {
54: 52:     fn from(value: HttpResponse) -> Self {
55: 53:         Self(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(value))
56: 54:     }
57: 55: }
58: 56: 
59: 57: impl<E> TryRes<E> for ActixResponse
60: 58: where
61: 59:     E: FromServerFnError,
62: 60: {
63: 61:     fn try_from_string(content_type: &str, data: String) -> Result<Self, E> {
64: 62:         let mut builder = HttpResponse::build(StatusCode::OK);
65: 63:         Ok(ActixResponse(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(
66: 64:             builder
67: 65:                 .insert_header((header::CONTENT_TYPE, content_type))
68: 66:                 .body(data),
69: 67:         )))
70: 68:     }
71: 69: 
72: 70:     fn try_from_bytes(content_type: &str, data: Bytes) -> Result<Self, E> {
73: 71:         let mut builder = HttpResponse::build(StatusCode::OK);
74: 72:         Ok(ActixResponse(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(
75: 73:             builder
76: 74:                 .insert_header((header::CONTENT_TYPE, content_type))
77: 75:                 .body(data),
78: 76:         )))
79: 77:     }
80: 78: 
81: 79:     fn try_from_stream(
82: 80:         content_type: &str,
83: 81:         data: impl Stream<Item = Result<Bytes, Bytes>> + 'static,
84: 82:     ) -> Result<Self, E> {
85: 83:         let mut builder = HttpResponse::build(StatusCode::OK);
86: 84:         Ok(ActixResponse(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(
87: 85:             builder
88: 86:                 .insert_header((header::CONTENT_TYPE, content_type))
89: 87:                 .streaming(data.map(|data| {
90: 88:                     data.map_err(|e| ServerFnErrorWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper(E::de(e)))
91: 89:                 })),
92: 90:         )))
93: 91:     }
94: 92: }
95: 93: 
96: 94: impl Res for ActixResponse {
97: 95:     fn error_response(path: &str, err: Bytes) -> Self {
98: 96:         ActixResponse(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(
99: 97:             HttpResponse::build(StatusCode::INTERNAL_SERVER_ERROR)
100: 98:                 .lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_header((SERVER_FN_ERROR_HEADER, path))
101: 99:                 .body(err),
102: 100:         ))
103: 101:     }
104: 102: 
105: 103:     fn content_type(&mut self, content_type: &str) {
106: 104:         if let Ok(content_type) = HeaderValue::from_str(content_type) {
107: 105:             self.0.headers_mut().insert(CONTENT_TYPE, content_type);
108: 106:         }
109: 107:     }
110: 108: 
111: 109:     fn redirect(&mut self, path: &str) {
112: 110:         if let Ok(path) = HeaderValue::from_str(path) {
113: 111:             *self.0.status_mut() = StatusCode::FOUND;
114: 112:             self.0.headers_mut().insert(LOCATION, path);
115: 113:         }
116: 114:     }
117: 115: }
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
128: ```
```
