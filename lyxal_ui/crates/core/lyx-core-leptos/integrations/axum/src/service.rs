### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\integrations\axum\src\service.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\src\service.rs
2: ```rust
3: 1: use crate::{handle_response_inner, PinnedStream};
4: 2: use axum::{
5: 3:     body::Body,
6: 4:     http::{Request, Response, StatusCode},
7: 5: };
8: 6: use futures::{stream::once, Future, StreamExt};
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{config::LeptosOptions, context::provide_context, IntoView};
10: 8: use std::{
11: 9:     convert::Infallible,
12: 10:     pin::Pin,
13: 11:     task::{Context, Poll},
14: 12: };
15: 13: use tower::Service;
16: 14: 
17: 15: /// Service for serving error pages generated with the provided lyx-platform-lyx_platform_lyx-platform-lyx_platform_application shell.
18: 16: ///
19: 17: /// This error handler is typically set up as a fallback service on some other services, such as the
20: 18: /// Axum's Router set up with a Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_app, and is provided as a tower [`Service`] to enable composition
21: 19: /// with other tower services.
22: 20: ///
23: 21: /// The behavior of [`file_and_error_handler`] can be lyx-platform-lyx_platform_lyx-platform-lyx_platform_approximately replicated with the following by
24: 22: /// composing with the [`ServeDir`] service returned by [`site_pkg_dir_service`].
25: 23: ///
26: 24: /// [`file_and_error_handler`]: crate::file_and_error_handler
27: 25: /// [`site_pkg_dir_service`]: crate::site_pkg_dir_service
28: 26: /// [`Service`]: tower::Service
29: 27: /// [`ServeDir`]: tower_http::services::ServeDir
30: 28: ///
31: 29: /// ```
32: 30: /// # use axum::Router;
33: 31: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
34: 32: /// # use lyx-core-axum::{LeptosRoutes, generate_route_list};
35: 33: /// # #[component]
36: 34: /// # fn App() -> impl IntoView {
37: 35: /// #     view! { <main>"Hello, world!"</main> }
38: 36: /// # }
39: 37: /// # let conf = get_configuration(None).unwrap();
40: 38: /// # let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
41: 39: /// # let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
42: 40: /// # let routes = generate_route_list(App);
43: 41: /// fn shell(options: LeptosOptions) -> impl IntoView {
44: 42: ///     view! { <App/> }
45: 43: /// }
46: 44: ///
47: 45: /// let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
48: 46: ///     .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
49: 47: ///         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
50: 48: ///         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
51: 49: ///     })
52: 50: ///     // the following `fallback_service(...)` call lyx-platform-lyx_platform_lyx-platform-lyx_platform_approximately replicates
53: 51: ///     // .fallback(lyx-core-axum::file_and_error_handler(shell))
54: 52: ///     .fallback_service(
55: 53: ///         lyx-core-axum::site_pkg_dir_service(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options).fallback(
56: 54: ///             lyx-core-axum::ErrorHandler::new(shell, lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
57: 55: ///         ),
58: 56: ///     );
59: 57: /// ```
60: 58: #[derive(Clone, Debug)]
61: 59: pub struct ErrorHandler<CX, SH> {
62: 60:     additional_context: CX,
63: 61:     shell: SH,
64: 62:     options: LeptosOptions,
65: 63: }
66: 64: 
67: 65: impl<SH> ErrorHandler<(), SH> {
68: 66:     /// Create a new handler with the provided shell and options.
69: 67:     pub fn new(shell: SH, options: LeptosOptions) -> Self {
70: 68:         Self {
71: 69:             additional_context: (),
72: 70:             shell,
73: 71:             options,
74: 72:         }
75: 73:     }
76: 74: }
77: 75: 
78: 76: impl<CX, SH> ErrorHandler<CX, SH> {
79: 77:     /// Create a new handler with an additional context along with the provided shell and options.
80: 78:     pub fn new_with_context(
81: 79:         additional_context: CX,
82: 80:         shell: SH,
83: 81:         options: LeptosOptions,
84: 82:     ) -> Self {
85: 83:         Self {
86: 84:             additional_context,
87: 85:             shell,
88: 86:             options,
89: 87:         }
90: 88:     }
91: 89: }
92: 90: 
93: 91: impl<SH, IV> Service<Request<Body>> for ErrorHandler<(), SH>
94: 92: where
95: 93:     SH: Fn(LeptosOptions) -> IV + 'static + Clone + Send,
96: 94:     IV: IntoView + 'static,
97: 95: {
98: 96:     type Response = Response<Body>;
99: 97:     type Error = Infallible;
100: 98:     type Future = Pin<
101: 99:         Box<
102: 100:             dyn Future<Output = Result<Response<Body>, Infallible>>
103: 101:                 + Send
104: 102:                 + 'static,
105: 103:         >,
106: 104:     >;
107: 105: 
108: 106:     #[inline]
109: 107:     fn poll_ready(
110: 108:         &mut self,
111: 109:         _cx: &mut Context<'_>,
112: 110:     ) -> Poll<Result<(), Self::Error>> {
113: 111:         Poll::Ready(Ok(()))
114: 112:     }
115: 113: 
116: 114:     fn call(&mut self, req: Request<Body>) -> Self::Future {
117: 115:         let options = self.options.clone();
118: 116:         let shell = self.shell.clone();
119: 117:         render_error_handler(|| {}, shell, options, req)
120: 118:     }
121: 119: }
122: 120: 
123: 121: impl<CX, SH, IV> Service<Request<Body>> for ErrorHandler<CX, SH>
124: 122: where
125: 123:     CX: Fn() + 'static + Clone + Send,
126: 124:     SH: Fn(LeptosOptions) -> IV + 'static + Clone + Send,
127: 125:     IV: IntoView + 'static,
128: 126: {
129: 127:     type Response = Response<Body>;
130: 128:     type Error = Infallible;
131: 129:     type Future = Pin<
132: 130:         Box<
133: 131:             dyn Future<Output = Result<Response<Body>, Infallible>>
134: 132:                 + Send
135: 133:                 + 'static,
136: 134:         >,
137: 135:     >;
138: 136: 
139: 137:     #[inline]
140: 138:     fn poll_ready(
141: 139:         &mut self,
142: 140:         _cx: &mut Context<'_>,
143: 141:     ) -> Poll<Result<(), Self::Error>> {
144: 142:         Poll::Ready(Ok(()))
145: 143:     }
146: 144: 
147: 145:     fn call(&mut self, req: Request<Body>) -> Self::Future {
148: 146:         let options = self.options.clone();
149: 147:         let shell = self.shell.clone();
150: 148:         let additional_context = self.additional_context.clone();
151: 149:         render_error_handler(additional_context, shell, options, req)
152: 150:     }
153: 151: }
154: 152: 
155: 153: fn render_error_handler<IV>(
156: 154:     additional_context: impl Fn() + 'static + Clone + Send,
157: 155:     shell: impl Fn(LeptosOptions) -> IV + 'static + Clone + Send,
158: 156:     options: LeptosOptions,
159: 157:     req: Request<Body>,
160: 158: ) -> Pin<
161: 159:     Box<
162: 160:         dyn Future<Output = Result<Response<Body>, Infallible>>
163: 161:             + Send
164: 162:             + 'static,
165: 163:     >,
166: 164: >
167: 165: where
168: 166:     IV: IntoView + 'static,
169: 167: {
170: 168:     Box::pin(async move {
171: 169:         let mut res = handle_response_inner(
172: 170:             {
173: 171:                 let options = options.clone();
174: 172:                 let additional_context = additional_context.clone();
175: 173:                 move || {
176: 174:                     provide_context(options.clone());
177: 175:                     additional_context();
178: 176:                 }
179: 177:             },
180: 178:             {
181: 179:                 let options = options.clone();
182: 180:                 let shell = shell.clone();
183: 181:                 move || shell(options)
184: 182:             },
185: 183:             req,
186: 184:             |lyx-platform-lyx_platform_lyx-platform-lyx_platform_app, chunks, _supports_ooo| {
187: 185:                 Box::pin(async move {
188: 186:                     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = if cfg!(feature = "islands-router") {
189: 187:                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order_branching()
190: 188:                     } else {
191: 189:                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order()
192: 190:                     };
193: 191:                     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.collect::<String>().await;
194: 192:                     let chunks = chunks();
195: 193:                     Box::pin(once(async move { lyx-platform-lyx_platform_lyx-platform-lyx_platform_app }).chain(chunks))
196: 194:                         as PinnedStream<String>
197: 195:                 })
198: 196:             },
199: 197:         )
200: 198:         .await;
201: 199: 
202: 200:         // set the status to 404
203: 201:         // but if the status was already set (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, to a 302 redirect) don't
204: 202:         // overwrite it
205: 203:         let status = res.status_mut();
206: 204:         if *status == StatusCode::OK {
207: 205:             *res.status_mut() = StatusCode::NOT_FOUND;
208: 206:         }
209: 207: 
210: 208:         Ok(res)
211: 209:     })
212: 210: }
213: ```
```
