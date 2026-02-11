### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\middlewares\request_response_logging.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\request_response_logging.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\request_response_logging.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\request_response_logging.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\request_response_logging.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\request_response_logging.rs
10: 8: ```rust
11: 9: use actix_web::HttpMessage;
12: 10: use actix_web::body::MessageBody;
13: 11: use actix_web::dev::{
14: 12:     Payload, Service, ServiceRequest, ServiceResponse, Transform, forward_ready,
15: 13: };
16: 14: use actix_web::http::header::ContentType;
17: 15: use actix_web::web::Bytes;
18: 16: use actix_web::{Error, error::PayloadError, http::header};
19: 17: use futures_util::future::{Ready, ok};
20: 18: use futures_util::stream::{StreamExt, once};
21: 19: use std::collections::HashMap;
22: 20: use std::future::Future;
23: 21: use std::pin::Pin;
24: 22: use std::rc::Rc;
25: 23: use std::task::{Context, Poll};
26: 24: use std::time::Instant;
27: 25: use tracing::{info, trace, warn};
28: 26: 
29: 27: #[derive(Default)]
30: 28: pub struct RequestResponseLogger;
31: 29: 
32: 30: // Custom body wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for logging request/response bodies
33: 31: pub struct LoggingBody<B> {
34: 32:     inner: B,
35: 33:     headers: HashMap<String, String>,
36: 34:     body_bytes: Vec<u8>,
37: 35:     consumed: bool,
38: 36:     start_time: Instant,
39: 37: }
40: 38: 
41: 39: impl<B> LoggingBody<B> {
42: 40:     fn new(body: B, headers: HashMap<String, String>, start_time: Instant) -> Self {
43: 41:         Self {
44: 42:             inner: body,
45: 43:             headers,
46: 44:             body_bytes: Vec::new(),
47: 45:             consumed: false,
48: 46:             start_time,
49: 47:         }
50: 48:     }
51: 49: }
52: 50: 
53: 51: impl<B> MessageBody for LoggingBody<B>
54: 52: where
55: 53:     B: MessageBody + Unpin,
56: 54: {
57: 55:     type Error = B::Error;
58: 56: 
59: 57:     fn size(&self) -> actix_web::body::BodySize {
60: 58:         self.inner.size()
61: 59:     }
62: 60: 
63: 61:     fn poll_next(
64: 62:         self: Pin<&mut Self>,
65: 63:         cx: &mut Context<'_>,
66: 64:     ) -> Poll<Option<Result<Bytes, Self::Error>>> {
67: 65:         let this = self.get_mut();
68: 66:         let inner = Pin::new(&mut this.inner);
69: 67: 
70: 68:         match inner.poll_next(cx) {
71: 69:             Poll::Ready(Some(Ok(chunk))) => {
72: 70:                 this.body_bytes.extend_from_slice(&chunk);
73: 71:                 Poll::Ready(Some(Ok(chunk)))
74: 72:             }
75: 73:             Poll::Ready(Some(Err(e))) => Poll::Ready(Some(Err(e))),
76: 74:             Poll::Ready(None) => {
77: 75:                 if !this.consumed {
78: 76:                     this.consumed = true;
79: 77:                     let latency_ms = this.start_time.elapsed().as_millis() as u64;
80: 78:                     let is_json_response = this
81: 79:                         .headers
82: 80:                         .get(header::CONTENT_TYPE.as_str())
83: 81:                         .map(|ct| ct.starts_with(&ContentType::json().to_string()))
84: 82:                         .unwrap_or(false);
85: 83:                     let response_body = if is_json_response {
86: 84:                         String::from_utf8_lossy(&this.body_bytes).into_owned()
87: 85:                     } else {
88: 86:                         "(non-JSON response body omitted)".to_string()
89: 87:                     };
90: 88:                     trace!(
91: 89:                         body = %response_body,
92: 90:                         "ResponseSignal"
93: 91:                     );
94: 92:                     info!(latency = latency_ms, "GoldenSignal");
95: 93:                 }
96: 94:                 Poll::Ready(None)
97: 95:             }
98: 96:             Poll::Pending => Poll::Pending,
99: 97:         }
100: 98:     }
101: 99: }
102: 100: 
103: 101: impl<S, B> Transform<S, ServiceRequest> for RequestResponseLogger
104: 102: where
105: 103:     S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
106: 104:     S::Future: 'static,
107: 105:     B: MessageBody + Unpin + 'static,
108: 106: {
109: 107:     type Response = ServiceResponse<LoggingBody<B>>;
110: 108:     type Error = Error;
111: 109:     type InitError = ();
112: 110:     type Transform = RequestResponseLoggerMiddleware<S>;
113: 111:     type Future = Ready<Result<Self::Transform, Self::InitError>>;
114: 112: 
115: 113:     fn new_transform(&self, service: S) -> Self::Future {
116: 114:         ok(RequestResponseLoggerMiddleware {
117: 115:             service: Rc::new(service),
118: 116:         })
119: 117:     }
120: 118: }
121: 119: 
122: 120: pub struct RequestResponseLoggerMiddleware<S> {
123: 121:     service: Rc<S>,
124: 122: }
125: 123: 
126: 124: impl<S, B> Service<ServiceRequest> for RequestResponseLoggerMiddleware<S>
127: 125: where
128: 126:     S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error> + 'static,
129: 127:     S::Future: 'static,
130: 128:     B: MessageBody + Unpin + 'static,
131: 129: {
132: 130:     type Response = ServiceResponse<LoggingBody<B>>;
133: 131:     type Error = Error;
134: 132:     type Future = Pin<Box<dyn Future<Output = Result<Self::Response, Self::Error>>>>;
135: 133: 
136: 134:     forward_ready!(service);
137: 135: 
138: 136:     fn call(&self, req: ServiceRequest) -> Self::Future {
139: 137:         let service = self.service.clone();
140: 138: 
141: 139:         Box::pin(async move {
142: 140:             let mut res: ServiceResponse<B>;
143: 141: 
144: 142:             let query_string = req.query_string().to_string();
145: 143: 
146: 144:             let request_id = req
147: 145:                 .extensions()
148: 146:                 .get::<tracing_actix_web::RequestId>()
149: 147:                 .map(|req_id| header::HeaderValue::from_str(&req_id.to_string()));
150: 148: 
151: 149:             let (http_req, mut payload) = req.into_parts();
152: 150:             let mut body_bytes = Vec::new();
153: 151: 
154: 152:             while let Some(chunk) = payload.next().await {
155: 153:                 match chunk {
156: 154:                     Ok(bytes) => body_bytes.extend_from_slice(&bytes),
157: 155:                     Err(e) => {
158: 156:                         warn!("Error reading request body: {}", e);
159: 157:                         break;
160: 158:                     }
161: 159:                 }
162: 160:             }
163: 161: 
164: 162:             let request_body = if body_bytes.is_empty() {
165: 163:                 String::from("(empty)")
166: 164:             } else {
167: 165:                 String::from_utf8_lossy(&body_bytes).into_owned()
168: 166:             };
169: 167: 
170: 168:             trace!(
171: 169:                 query = %if query_string.is_empty() {
172: 170:                     "(none)".to_string()
173: 171:                 } else {
174: 172:                     query_string.clone()
175: 173:                 },
176: 174:                 body = %request_body,
177: 175:                 "RequestSignal"
178: 176:             );
179: 177: 
180: 178:             let new_payload = if body_bytes.is_empty() {
181: 179:                 Payload::None
182: 180:             } else {
183: 181:                 let bytes = Bytes::from(body_bytes);
184: 182:                 let stream = once(async move { Ok::<Bytes, PayloadError>(bytes) });
185: 183:                 Payload::from(Box::pin(stream)
186: 184:                     as Pin<
187: 185:                         Box<dyn futures_util::Stream<Item = Result<Bytes, PayloadError>>>,
188: 186:                     >)
189: 187:             };
190: 188:             let new_req = ServiceRequest::from_parts(http_req, new_payload);
191: 189:             let start_time = Instant::now();
192: 190:             res = service.call(new_req).await?;
193: 191: 
194: 192:             if let Some(Ok(request_id)) = request_id {
195: 193:                 res.headers_mut()
196: 194:                     .insert(header::HeaderName::from_static("x-request-id"), request_id);
197: 195:             }
198: 196:             let response_headers: HashMap<String, String> = res
199: 197:                 .headers()
200: 198:                 .iter()
201: 199:                 .filter_map(|(name, value)| {
202: 200:                     value
203: 201:                         .to_str()
204: 202:                         .ok()
205: 203:                         .map(|v| (name.as_str().to_string(), v.to_string()))
206: 204:                 })
207: 205:                 .collect();
208: 206: 
209: 207:             let logged_res = res
210: 208:                 .map_body(|_, body| LoggingBody::new(body, response_headers, start_time));
211: 209: 
212: 210:             Ok(logged_res)
213: 211:         })
214: 212:     }
215: 213: }
216: 214: ```
217: 215: ```
218: 216: ```
219: 217: ```
220: ```
```
