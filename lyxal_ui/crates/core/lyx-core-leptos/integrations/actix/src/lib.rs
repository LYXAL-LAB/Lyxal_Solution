### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\integrations\actix\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\actix\src\lib.rs
2: ```rust
3: 1: #![forbid(unsafe_code)]
4: 2: #![deny(missing_docs)]
5: 3: 
6: 4: //! Provides functions to easily integrate Leptos with Actix.
7: 5: //!
8: 6: //! For more details on how to use the integrations, see the
9: 7: //! [`lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples`](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples)
10: 8: //! directory in the Leptos repository.
11: 9: 
12: 10: use actix_files::NamedFile;
13: 11: use actix_http::header::{HeaderName, HeaderValue, ACCEPT, LOCATION, REFERER};
14: 12: use actix_web::{
15: 13:     dev::{ServiceFactory, ServiceRequest},
16: 14:     http::header,
17: 15:     test,
18: 16:     web::{Data, Payload, ServiceConfig},
19: 17:     *,
20: 18: };
21: 19: use dashmap::DashMap;
22: 20: use futures::{stream::once, Stream, StreamExt};
23: 21: use http::StatusCode;
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_hydration_context::SsrSharedContext;
25: 23: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
26: 24:     config::LeptosOptions,
27: 25:     context::{provide_context, use_context},
28: 26:     hydration::IslandsRouterNavigation,
29: 27:     prelude::expect_context,
30: 28:     reactive::{computed::ScopedFuture, owner::Owner},
31: 29:     IntoView,
32: 30: };
33: 31: use lyx-core-utils::{
34: 32:     BoxedFnOnce, ExtendResponse, PinnedFuture, PinnedStream,
35: 33: };
36: 34: use lyx-core-lyx_core_lyx-core-meta::ServerMetaContext;
37: 35: use lyx-core-lyx_core_lyx-core-router::{
38: 36:     components::provide_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_redirect,
39: 37:     location::RequestUrl,
40: 38:     static_routes::{RegenerationFn, ResolvedStaticPath},
41: 39:     ExpandOptionals, Method, PathSegment, RouteList, RouteListing, SsrMode,
42: 40: };
43: 41: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
44: 42: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
45: 43: use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{
46: 44:     error::ServerFnErrorErr, redirect::REDIRECT_HEADER,
47: 45:     request::actix::ActixRequest,
48: 46: };
49: 47: use std::{
50: 48:     collections::HashSet,
51: 49:     fmt::{Debug, Display},
52: 50:     future::Future,
53: 51:     ops::{Deref, DerefMut},
54: 52:     path::Path,
55: 53:     sync::{Arc, LazyLock, RwLock},
56: 54: };
57: 55: 
58: 56: /// This struct lets you define headers and override the status of the Response from an Element or a Server Function
59: 57: /// Typically contained inside of a ResponseOptions. Setting this is useful for cookies and custom responses.
60: 58: #[derive(Debug, Clone, Default)]
61: 59: pub struct ResponseParts {
62: 60:     /// If provided, this will overwrite any other status code for this response.
63: 61:     pub status: Option<StatusCode>,
64: 62:     /// The map of headers that should be added to the response.
65: 63:     pub headers: header::HeaderMap,
66: 64: }
67: 65: 
68: 66: impl ResponseParts {
69: 67:     /// Insert a header, overwriting any previous value with the same key
70: 68:     pub fn insert_header(
71: 69:         &mut self,
72: 70:         key: header::HeaderName,
73: 71:         value: header::HeaderValue,
74: 72:     ) {
75: 73:         self.headers.insert(key, value);
76: 74:     }
77: 75: 
78: 76:     /// Append a header, leaving any header with the same key intact
79: 77:     pub fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_header(
80: 78:         &mut self,
81: 79:         key: header::HeaderName,
82: 80:         value: header::HeaderValue,
83: 81:     ) {
84: 82:         self.headers.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(key, value);
85: 83:     }
86: 84: }
87: 85: 
88: 86: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for an Actix [`HttpRequest`] that allows it to be used in an
89: 87: /// `Send`/`Sync` setting like Leptos's Context API.
90: 88: #[derive(Debug, Clone)]
91: 89: pub struct Request(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<HttpRequest>);
92: 90: 
93: 91: impl Request {
94: 92:     /// Wraps an existing Actix request.
95: 93:     pub fn new(req: &HttpRequest) -> Self {
96: 94:         Self(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(req.clone()))
97: 95:     }
98: 96: 
99: 97:     /// Consumes the wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper and returns the inner Actix request.
100: 98:     pub fn into_inner(self) -> HttpRequest {
101: 99:         self.0.take()
102: 100:     }
103: 101: }
104: 102: 
105: 103: impl Deref for Request {
106: 104:     type Target = HttpRequest;
107: 105: 
108: 106:     fn deref(&self) -> &Self::Target {
109: 107:         &self.0
110: 108:     }
111: 109: }
112: 110: 
113: 111: impl DerefMut for Request {
114: 112:     fn deref_mut(&mut self) -> &mut Self::Target {
115: 113:         &mut self.0
116: 114:     }
117: 115: }
118: 116: 
119: 117: /// Allows you to override details of the HTTP response like the status code and add Headers/Cookies.
120: 118: #[derive(Debug, Clone, Default)]
121: 119: pub struct ResponseOptions(pub Arc<RwLock<ResponseParts>>);
122: 120: 
123: 121: impl ResponseOptions {
124: 122:     /// A simpler way to overwrite the contents of `ResponseOptions` with a new `ResponseParts`.
125: 123:     pub fn overwrite(&self, parts: ResponseParts) {
126: 124:         let mut writable = self.0.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
127: 125:         *writable = parts
128: 126:     }
129: 127:     /// Set the status of the returned Response.
130: 128:     pub fn set_status(&self, status: StatusCode) {
131: 129:         let mut writeable = self.0.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
132: 130:         let res_parts = &mut *writeable;
133: 131:         res_parts.status = Some(status);
134: 132:     }
135: 133:     /// Insert a header, overwriting any previous value with the same key.
136: 134:     pub fn insert_header(
137: 135:         &self,
138: 136:         key: header::HeaderName,
139: 137:         value: header::HeaderValue,
140: 138:     ) {
141: 139:         let mut writeable = self.0.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
142: 140:         let res_parts = &mut *writeable;
143: 141:         res_parts.headers.insert(key, value);
144: 142:     }
145: 143:     /// Append a header, leaving any header with the same key intact.
146: 144:     pub fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_header(
147: 145:         &self,
148: 146:         key: header::HeaderName,
149: 147:         value: header::HeaderValue,
150: 148:     ) {
151: 149:         let mut writeable = self.0.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
152: 150:         let res_parts = &mut *writeable;
153: 151:         res_parts.headers.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(key, value);
154: 152:     }
155: 153: }
156: 154: 
157: 155: struct ActixResponse(HttpResponse);
158: 156: 
159: 157: impl ExtendResponse for ActixResponse {
160: 158:     type ResponseOptions = ResponseOptions;
161: 159: 
162: 160:     fn from_stream(
163: 161:         stream: impl Stream<Item = String> + Send + 'static,
164: 162:     ) -> Self {
165: 163:         ActixResponse(
166: 164:             HttpResponse::Ok()
167: 165:                 .content_type("text/html")
168: 166:                 .streaming(stream.map(|chunk| {
169: 167:                     Ok(web::Bytes::from(chunk)) as Result<web::Bytes>
170: 168:                 })),
171: 169:         )
172: 170:     }
173: 171: 
174: 172:     fn extend_response(&mut self, res_options: &Self::ResponseOptions) {
175: 173:         let mut res_options = res_options.0.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
176: 174: 
177: 175:         let headers = self.0.headers_mut();
178: 176:         for (key, value) in std::mem::take(&mut res_options.headers) {
179: 177:             headers.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(key, value);
180: 178:         }
181: 179: 
182: 180:         // Set status to what is returned in the function
183: 181:         if let Some(status) = res_options.status {
184: 182:             *self.0.status_mut() = status;
185: 183:         }
186: 184:     }
187: 185: 
188: 186:     fn set_default_content_type(&mut self, content_type: &str) {
189: 187:         let headers = self.0.headers_mut();
190: 188:         if !headers.contains_key(header::CONTENT_TYPE) {
191: 189:             // Set the Content Type headers on all responses. This makes Firefox show the page source
192: 190:             // without complaining
193: 191:             headers.insert(
194: 192:                 header::CONTENT_TYPE,
195: 193:                 HeaderValue::from_str(content_type).unwrap(),
196: 194:             );
197: 195:         }
198: 196:     }
199: 197: }
200: 198: 
201: 199: /// Provides an easy way to redirect the user from within a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
202: 200: ///
203: 201: /// Calling `redirect` in a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function will redirect the browser in three
204: 202: /// situations:
205: 203: /// 1. A lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function that is calling in a [blocking
206: 204: ///    resource](lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::Resource::new_blocking).
207: 205: /// 2. A lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function that is called from WASM running in the lyx-core-lyx_core_lyx-core-lyx_core_client (e.g., a dispatched action
208: 206: ///    or a spawned `Future`).
209: 207: /// 3. A `<form>` submitted to the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function endpoint using default browser APIs (often due
210: 208: ///    to using [`ActionForm`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::form::ActionForm) without JS/WASM present.)
211: 209: ///
212: 210: /// Using it with a non-blocking [`Resource`](lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::Resource) will not work if you are using streaming rendering,
213: 211: /// as the response's headers will already have been sent by the time the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function calls `redirect()`.
214: 212: ///
215: 213: /// ### Implementation
216: 214: ///
217: 215: /// This sets the `Location` header to the URL given.
218: 216: ///
219: 217: /// If the route or lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function in which this is called is being accessed
220: 218: /// by an ordinary `GET` request or an HTML `<form>` without any enhancement, it also sets a
221: 219: /// status code of `302` for a temporary redirect. (This is determined by whether the `Accept`
222: 220: /// header contains `text/html` as it does for an ordinary navigation.)
223: 221: ///
224: 222: /// Otherwise, it sets a custom header that indicates to the lyx-core-lyx_core_lyx-core-lyx_core_client that it should redirect,
225: 223: /// without actually setting the status code. This means that the lyx-core-lyx_core_lyx-core-lyx_core_client will not follow the
226: 224: /// redirect, and can therefore return the value of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function and then handle
227: 225: /// the redirect with lyx-core-lyx_core_lyx-core-lyx_core_client-side routing.
228: 226: #[cfg_attr(
229: 227:     feature = "tracing",
230: 228:     tracing::instrument(level = "trace", fields(error), skip_all)
231: 229: )]
232: 230: pub fn redirect(path: &str) {
233: 231:     if let (Some(req), Some(res)) =
234: 232:         (use_context::<Request>(), use_context::<ResponseOptions>())
235: 233:     {
236: 234:         // insert the Location header in any case
237: 235:         res.insert_header(
238: 236:             header::LOCATION,
239: 237:             header::HeaderValue::from_str(path)
240: 238:                 .expect("Failed to create HeaderValue"),
241: 239:         );
242: 240: 
243: 241:         let accepts_html = req
244: 242:             .headers()
245: 243:             .get(ACCEPT)
246: 244:             .and_then(|v| v.to_str().ok())
247: 245:             .map(|v| v.contains("text/html"))
248: 246:             .unwrap_or(false);
249: 247:         if accepts_html {
250: 248:             // if the request accepts text/html, it's a plain form request and needs
251: 249:             // to have the 302 code set
252: 250:             res.set_status(StatusCode::FOUND);
253: 251:         } else {
254: 252:             // otherwise, we sent it from the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server fn lyx-core-lyx_core_lyx-core-lyx_core_client and actually don't want
255: 253:             // to set a real redirect, as this will break the ability to return data
256: 254:             // instead, set the REDIRECT_HEADER to indicate that the lyx-core-lyx_core_lyx-core-lyx_core_client should redirect
257: 255:             res.insert_header(
258: 256:                 HeaderName::from_static(REDIRECT_HEADER),
259: 257:                 HeaderValue::from_str("").unwrap(),
260: 258:             );
261: 259:         }
262: 260:     } else {
263: 261:         let msg = "Couldn't retrieve either Parts or ResponseOptions while \
264: 262:                    trying to redirect().";
265: 263: 
266: 264:         #[cfg(feature = "tracing")]
267: 265:         tracing::warn!("{}", &msg);
268: 266: 
269: 267:         #[cfg(not(feature = "tracing"))]
270: 268:         eprintln!("{}", &msg);
271: 269:     }
272: 270: }
273: 271: 
274: 272: /// An Actix [struct@Route](actix_web::Route) that listens for a `POST` request with
275: 273: /// Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function arguments in the body, runs the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function if found,
276: 274: /// and returns the resulting [HttpResponse].
277: 275: ///
278: 276: /// This can then be set up at an lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate route in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application:
279: 277: ///
280: 278: /// ```no_run
281: 279: /// use actix_web::*;
282: 280: ///
283: 281: /// fn register_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_functions() {
284: 282: ///   // call ServerFn::register() for each of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions you've defined
285: 283: /// }
286: 284: ///
287: 285: /// # #[cfg(feature = "default")]
288: 286: /// #[actix_web::main]
289: 287: /// async fn main() -> std::io::Result<()> {
290: 288: ///     // make sure you actually register your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions
291: 289: ///     register_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_functions();
292: 290: ///
293: 291: ///     HttpServer::new(|| {
294: 292: ///         App::new()
295: 293: ///             // "/api" should match the prefix, if any, declared when defining lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions
296: 294: ///             // {tail:.*} passes the remainder of the URL as the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function name
297: 295: ///             .route("/api/{tail:.*}", lyx-core-actix::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns())
298: 296: ///     })
299: 297: ///     .bind(("127.0.0.1", 8080))?
300: 298: ///     .run()
301: 299: ///     .await
302: 300: /// }
303: 301: /// # #[cfg(not(feature = "default"))]
304: 302: /// # fn main() {}
305: 303: /// ```
306: 304: ///
307: 305: /// ## Provided Context Types
308: 306: /// This function always provides context values including the following types:
309: 307: /// - [ResponseOptions]
310: 308: /// - [Request]
311: 309: #[cfg_attr(
312: 310:     feature = "tracing",
313: 311:     tracing::instrument(level = "trace", fields(error), skip_all)
314: 312: )]
315: 313: pub fn handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns() -> Route {
316: 314:     handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(|| {})
317: 315: }
318: 316: 
319: 317: /// An Actix [struct@Route](actix_web::Route) that listens for `GET` or `POST` requests with
320: 318: /// Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function arguments in the URL (`GET`) or body (`POST`),
321: 319: /// runs the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function if found, and returns the resulting [HttpResponse].
322: 320: ///
323: 321: /// This can then be set up at an lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate route in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application:
324: 322: ///
325: 323: /// This version allows you to pass in a closure that adds additional route data to the
326: 324: /// context, allowing you to pass in info about the route or user from Actix, or other info.
327: 325: ///
328: 326: /// **NOTE**: If your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions expect a context, make sure to provide it both in
329: 327: /// [`handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context`] **and** in [`LeptosRoutes::lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context`] (or whatever
330: 328: /// rendering method you are using). During SSR, lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions are called by the rendering
331: 329: /// method, while subsequent calls from the lyx-core-lyx_core_lyx-core-lyx_core_client are handled by the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function handler.
332: 330: /// The same context needs to be provided to both handlers.
333: 331: ///
334: 332: /// ## Provided Context Types
335: 333: /// This function always provides context values including the following types:
336: 334: /// - [ResponseOptions]
337: 335: /// - [Request]
338: 336: #[cfg_attr(
339: 337:     feature = "tracing",
340: 338:     tracing::instrument(level = "trace", fields(error), skip_all)
341: 339: )]
342: 340: pub fn handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(
343: 341:     additional_context: impl Fn() + 'static + Clone + Send,
344: 342: ) -> Route {
345: 343:     web::to(move |req: HttpRequest, payload: Payload| {
346: 344:         let additional_context = additional_context.clone();
347: 345:         async move {
348: 346:             let additional_context = additional_context.clone();
349: 347: 
350: 348:             let path = req.path();
351: 349:             let method = req.method();
352: 350:             if let Some(mut service) =
353: 351:                 lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::actix::get_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_service(path, method)
354: 352:             {
355: 353:                 let owner = Owner::new();
356: 354:                 owner
357: 355:                     .with(|| {
358: 356:                         ScopedFuture::new(async move {
359: 357:                             provide_context(Request::new(&req));
360: 358:                             let res_options = ResponseOptions::default();
361: 359:                             provide_context(res_options.clone());
362: 360:                             additional_context();
363: 361: 
364: 362:                             // store Accepts and Referer in case we need them for redirect (below)
365: 363:                             let accepts_html = req
366: 364:                                 .headers()
367: 365:                                 .get(ACCEPT)
368: 366:                                 .and_then(|v| v.to_str().ok())
369: 367:                                 .map(|v| v.contains("text/html"))
370: 368:                                 .unwrap_or(false);
371: 369:                             let referrer = req.headers().get(REFERER).cloned();
372: 370: 
373: 371:                             // actually run the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server fn
374: 372:                             let mut res = ActixResponse(
375: 373:                                 service
376: 374:                                     .run(ActixRequest::from((req, payload)))
377: 375:                                     .await
378: 376:                                     .take(),
379: 377:                             );
380: 378: 
381: 379:                             // if it accepts text/html (i.e., is a plain form post) and doesn't already have a
382: 380:                             // Location set, then redirect to the Referer
383: 381:                             if accepts_html {
384: 382:                                 if let Some(referrer) = referrer {
385: 383:                                     let has_location =
386: 384:                                         res.0.headers().get(LOCATION).is_some();
387: 385:                                     if !has_location {
388: 386:                                         *res.0.status_mut() = StatusCode::FOUND;
389: 387:                                         res.0
390: 388:                                             .headers_mut()
391: 389:                                             .insert(LOCATION, referrer);
392: 390:                                     }
393: 391:                                 }
394: 392:                             }
395: 393: 
396: 394:                             // the Location header may have been set to Referer, so any redirection by the
397: 395:                             // user must overwrite it
398: 396:                             {
399: 397:                                 let mut res_options =
400: 398:                                     res_options.0.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
401: 399:                                 let headers = res.0.headers_mut();
402: 400: 
403: 401:                                 for location in
404: 402:                                     res_options.headers.remove(header::LOCATION)
405: 403:                                 {
406: 404:                                     headers.insert(header::LOCATION, location);
407: 405:                                 }
408: 406:                             }
409: 407: 
410: 408:                             // lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply status code and headers if user changed them
411: 409:                             res.extend_response(&res_options);
412: 410:                             res.0
413: 411:                         })
414: 412:                     })
415: 413:                     .await
416: 414:             } else {
417: 415:                 HttpResponse::BadRequest().body(format!(
418: 416:                     "Could not find a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function at the route {:?}. \
419: 417:                      \n\nIt's likely that either
420: 418:                          1. The API prefix you specify in the `#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]` \
421: 419:                      macro doesn't match the prefix at which your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server \
422: 420:                      function handler is mounted, or \n2. You are on a \
423: 421:                      platform that doesn't support automatic lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function \
424: 422:                      registration and you need to call \
425: 423:                      ServerFn::register_explicit() on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function \
426: 424:                      type, somewhere in your `main` function.",
427: 425:                     req.path()
428: 426:                 ))
429: 427:             }
430: 428:         }
431: 429:     })
432: 430: }
433: 431: 
434: 432: /// Returns an Actix [struct@Route](actix_web::Route) that listens for a `GET` request and tries
435: 433: /// to route it using [lyx-core-lyx_core_lyx-core-router], serving an HTML stream of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application. The stream
436: 434: /// will include fallback content for any `<Suspense/>` nodes, and be immediately interactive,
437: 435: /// but requires some lyx-core-lyx_core_lyx-core-lyx_core_client-side JavaScript.
438: 436: ///
439: 437: /// This can then be set up at an lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate route in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application:
440: 438: /// ```no_run
441: 439: /// use actix_web::{App, HttpServer};
442: 440: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
443: 441: /// use lyx-core-lyx_core_lyx-core-router::Method;
444: 442: /// use std::{env, net::SocketAddr};
445: 443: ///
446: 444: /// #[component]
447: 445: /// fn MyApp() -> impl IntoView {
448: 446: ///     view! { <main>"Hello, world!"</main> }
449: 447: /// }
450: 448: ///
451: 449: /// # #[cfg(feature = "default")]
452: 450: /// #[actix_web::main]
453: 451: /// async fn main() -> std::io::Result<()> {
454: 452: ///     let conf = get_configuration(Some("Cargo.toml")).unwrap();
455: 453: ///     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr.clone();
456: 454: ///     HttpServer::new(move || {
457: 455: ///         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = &conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
458: 456: ///
459: 457: ///         App::new()
460: 458: ///             // {tail:.*} passes the remainder of the URL as the route
461: 459: ///             // the actual routing will be handled by `lyx-core-lyx_core_lyx-core-router`
462: 460: ///             .route(
463: 461: ///                 "/{tail:.*}",
464: 462: ///                 lyx-core-actix::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream(MyApp, Method::Get),
465: 463: ///             )
466: 464: ///     })
467: 465: ///     .bind(&addr)?
468: 466: ///     .run()
469: 467: ///     .await
470: 468: /// }
471: 469: /// # #[cfg(not(feature = "default"))]
472: 470: /// # fn main() {}
473: 471: /// ```
474: 472: ///
475: 473: /// ## Provided Context Types
476: 474: /// This function always provides context values including the following types:
477: 475: /// - [ResponseOptions]
478: 476: /// - [Request]
479: 477: /// - [MetaContext](lyx-core-lyx_core_lyx-core-meta::MetaContext)
480: 478: #[cfg_attr(
481: 479:     feature = "tracing",
482: 480:     tracing::instrument(level = "trace", fields(error), skip_all)
483: 481: )]
484: 482: pub fn render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream<IV>(
485: 483:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
486: 484:     method: Method,
487: 485: ) -> Route
488: 486: where
489: 487:     IV: IntoView + 'static,
490: 488: {
491: 489:     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context(|| {}, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn, method)
492: 490: }
493: 491: 
494: 492: /// Returns an Actix [struct@Route](actix_web::Route) that listens for a `GET` request and tries
495: 493: /// to route it using [lyx-core-lyx_core_lyx-core-router], serving an in-order HTML stream of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
496: 494: /// This stream will pause at each `<Suspense/>` node and wait for it to resolve before
497: 495: /// sending down its HTML. The lyx-platform-lyx_platform_lyx-platform-lyx_platform_app will become interactive once it has fully loaded.
498: 496: ///
499: 497: /// This can then be set up at an lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate route in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application:
500: 498: /// ```no_run
501: 499: /// use actix_web::{App, HttpServer};
502: 500: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
503: 501: /// use lyx-core-lyx_core_lyx-core-router::Method;
504: 502: /// use std::{env, net::SocketAddr};
505: 503: ///
506: 504: /// #[component]
507: 505: /// fn MyApp() -> impl IntoView {
508: 506: ///     view! { <main>"Hello, world!"</main> }
509: 507: /// }
510: 508: ///
511: 509: /// # #[cfg(feature = "default")]
512: 510: /// #[actix_web::main]
513: 511: /// async fn main() -> std::io::Result<()> {
514: 512: ///     let conf = get_configuration(Some("Cargo.toml")).unwrap();
515: 513: ///     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr.clone();
516: 514: ///     HttpServer::new(move || {
517: 515: ///         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = &conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
518: 516: ///
519: 517: ///         App::new()
520: 518: ///             // {tail:.*} passes the remainder of the URL as the route
521: 519: ///             // the actual routing will be handled by `lyx-core-lyx_core_lyx-core-router`
522: 520: ///             .route(
523: 521: ///                 "/{tail:.*}",
524: 522: ///                 lyx-core-actix::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_in_order(
525: 523: ///                     MyApp,
526: 524: ///                     Method::Get,
527: 525: ///                 ),
528: 526: ///             )
529: 527: ///     })
530: 528: ///     .bind(&addr)?
531: 529: ///     .run()
532: 530: ///     .await
533: 531: /// }
534: 532: ///
535: 533: /// # #[cfg(not(feature = "default"))]
536: 534: /// # fn main() {}
537: 535: /// ```
538: 536: ///
539: 537: /// ## Provided Context Types
540: 538: /// This function always provides context values including the following types:
541: 539: /// - [ResponseOptions]
542: 540: /// - [Request]
543: 541: #[cfg_attr(
544: 542:     feature = "tracing",
545: 543:     tracing::instrument(level = "trace", fields(error), skip_all)
546: 544: )]
547: 545: pub fn render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_in_order<IV>(
548: 546:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
549: 547:     method: Method,
550: 548: ) -> Route
551: 549: where
552: 550:     IV: IntoView + 'static,
553: 551: {
554: 552:     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_in_order_with_context(|| {}, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn, method)
555: 553: }
556: 554: 
557: 555: /// Returns an Actix [struct@Route](actix_web::Route) that listens for a `GET` request and tries
558: 556: /// to route it using [lyx-core-lyx_core_lyx-core-router], asynchronously rendering an HTML page after all
559: 557: /// `async` resources have loaded.
560: 558: ///
561: 559: /// This can then be set up at an lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate route in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application:
562: 560: /// ```no_run
563: 561: /// use actix_web::{App, HttpServer};
564: 562: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
565: 563: /// use lyx-core-lyx_core_lyx-core-router::Method;
566: 564: /// use std::{env, net::SocketAddr};
567: 565: ///
568: 566: /// #[component]
569: 567: /// fn MyApp() -> impl IntoView {
570: 568: ///     view! { <main>"Hello, world!"</main> }
571: 569: /// }
572: 570: ///
573: 571: /// # #[cfg(feature = "default")]
574: 572: /// #[actix_web::main]
575: 573: /// async fn main() -> std::io::Result<()> {
576: 574: ///     let conf = get_configuration(Some("Cargo.toml")).unwrap();
577: 575: ///     let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr.clone();
578: 576: ///     HttpServer::new(move || {
579: 577: ///         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = &conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
580: 578: ///
581: 579: ///         App::new()
582: 580: ///             // {tail:.*} passes the remainder of the URL as the route
583: 581: ///             // the actual routing will be handled by `lyx-core-lyx_core_lyx-core-router`
584: 582: ///             .route(
585: 583: ///                 "/{tail:.*}",
586: 584: ///                 lyx-core-actix::render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async(MyApp, Method::Get),
587: 585: ///             )
588: 586: ///     })
589: 587: ///     .bind(&addr)?
590: 588: ///     .run()
591: 589: ///     .await
592: 590: /// }
593: 591: /// # #[cfg(not(feature = "default"))]
594: 592: /// # fn main() {}
595: 593: /// ```
596: 594: ///
597: 595: /// ## Provided Context Types
598: 596: /// This function always provides context values including the following types:
599: 597: /// - [ResponseOptions]
600: 598: /// - [Request]
601: 599: #[cfg_attr(
602: 600:     feature = "tracing",
603: 601:     tracing::instrument(level = "trace", fields(error), skip_all)
604: 602: )]
605: 603: pub fn render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async<IV>(
606: 604:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
607: 605:     method: Method,
608: 606: ) -> Route
609: 607: where
610: 608:     IV: IntoView + 'static,
611: 609: {
612: 610:     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async_with_context(|| {}, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn, method)
613: 611: }
614: 612: 
615: 613: /// Returns an Actix [struct@Route] that listens for a `GET` request and tries
616: 614: /// to route it using [lyx-core-lyx_core_lyx-core-router], serving an HTML stream of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
617: 615: ///
618: 616: /// This function allows you to provide additional information to Leptos for your route.
619: 617: /// It could be used to pass in Path Info, Connection Info, or anything your heart desires.
620: 618: ///
621: 619: /// ## Provided Context Types
622: 620: /// This function always provides context values including the following types:
623: 621: /// - [ResponseOptions]
624: 622: /// - [Request]
625: 623: #[cfg_attr(
626: 624:     feature = "tracing",
627: 625:     tracing::instrument(level = "trace", fields(error), skip_all)
628: 626: )]
629: 627: pub fn render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context<IV>(
630: 628:     additional_context: impl Fn() + 'static + Clone + Send,
631: 629:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
632: 630:     method: Method,
633: 631: ) -> Route
634: 632: where
635: 633:     IV: IntoView + 'static,
636: 634: {
637: 635:     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context_and_replace_blocks(
638: 636:         additional_context,
639: 637:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn,
640: 638:         method,
641: 639:         false,
642: 640:     )
643: 641: }
644: 642: 
645: 643: /// Returns an Actix [struct@Route](actix_web::Route) that listens for a `GET` request and tries
646: 644: /// to route it using [lyx-core-lyx_core_lyx-core-router], serving an HTML stream of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
647: 645: ///
648: 646: /// This function allows you to provide additional information to Leptos for your route.
649: 647: /// It could be used to pass in Path Info, Connection Info, or anything your heart desires.
650: 648: ///
651: 649: /// `replace_blocks` additionally lets you specify whether `<Suspense/>` fragments that read
652: 650: /// from blocking resources should be retrojected into the HTML that's initially served, rather
653: 651: /// than dynamically inserting them with JavaScript on the lyx-core-lyx_core_lyx-core-lyx_core_client. This means you will have
654: 652: /// better support if JavaScript is not enabled, in exchange for a marginally slower response time.
655: 653: ///
656: 654: /// ## Provided Context Types
657: 655: /// This function always provides context values including the following types:
658: 656: /// - [ResponseOptions]
659: 657: /// - [Request]
660: 658: #[cfg_attr(
661: 659:     feature = "tracing",
662: 660:     tracing::instrument(level = "trace", fields(error), skip_all)
663: 661: )]
664: 662: pub fn render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context_and_replace_blocks<IV>(
665: 663:     additional_context: impl Fn() + 'static + Clone + Send,
666: 664:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
667: 665:     method: Method,
668: 666:     replace_blocks: bool,
669: 667: ) -> Route
670: 668: where
671: 669:     IV: IntoView + 'static,
672: 670: {
673: 671:     _ = replace_blocks; // TODO
674: 672:     handle_response(
675: 673:         method,
676: 674:         additional_context,
677: 675:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn,
678: 676:         |lyx-platform-lyx_platform_lyx-platform-lyx_platform_app, chunks, supports_ooo| {
679: 677:             Box::pin(async move {
680: 678:                 let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = if cfg!(feature = "islands-router") {
681: 679:                     if supports_ooo {
682: 680:                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_out_of_order_branching()
683: 681:                     } else {
684: 682:                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order_branching()
685: 683:                     }
686: 684:                 } else if supports_ooo {
687: 685:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_out_of_order()
688: 686:                 } else {
689: 687:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order()
690: 688:                 };
691: 689:                 Box::pin(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.chain(chunks())) as PinnedStream<String>
692: 690:             })
693: 691:         },
694: 692:     )
695: 693: }
696: 694: 
697: 695: /// Returns an Actix [struct@Route](actix_web::Route) that listens for a `GET` request and tries
698: 696: /// to route it using [lyx-core-lyx_core_lyx-core-router], serving an in-order HTML stream of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
699: 697: ///
700: 698: /// This function allows you to provide additional information to Leptos for your route.
701: 699: /// It could be used to pass in Path Info, Connection Info, or anything your heart desires.
702: 700: ///
703: 701: /// ## Provided Context Types
704: 702: /// This function always provides context values including the following types:
705: 703: /// - [ResponseOptions]
706: 704: /// - [Request]
707: 705: /// - [MetaContext](lyx-core-lyx_core_lyx-core-meta::MetaContext)
708: 706: #[cfg_attr(
709: 707:     feature = "tracing",
710: 708:     tracing::instrument(level = "trace", fields(error), skip_all)
711: 709: )]
712: 710: pub fn render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_in_order_with_context<IV>(
713: 711:     additional_context: impl Fn() + 'static + Clone + Send,
714: 712:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
715: 713:     method: Method,
716: 714: ) -> Route
717: 715: where
718: 716:     IV: IntoView + 'static,
719: 717: {
720: 718:     handle_response(
721: 719:         method,
722: 720:         additional_context,
723: 721:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn,
724: 722:         |lyx-platform-lyx_platform_lyx-platform-lyx_platform_app, chunks, _supports_ooo| {
725: 723:             Box::pin(async move {
726: 724:                 let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = if cfg!(feature = "islands-router") {
727: 725:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order_branching()
728: 726:                 } else {
729: 727:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order()
730: 728:                 };
731: 729:                 Box::pin(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.chain(chunks())) as PinnedStream<String>
732: 730:             })
733: 731:         },
734: 732:     )
735: 733: }
736: 734: 
737: 735: /// Returns an Actix [struct@Route](actix_web::Route) that listens for a `GET` request and tries
738: 736: /// to route it using [lyx-core-lyx_core_lyx-core-router], asynchronously serving the page once all `async`
739: 737: /// resources have loaded.
740: 738: ///
741: 739: /// This function allows you to provide additional information to Leptos for your route.
742: 740: /// It could be used to pass in Path Info, Connection Info, or anything your heart desires.
743: 741: ///
744: 742: /// ## Provided Context Types
745: 743: /// This function always provides context values including the following types:
746: 744: /// - [ResponseOptions]
747: 745: /// - [Request]
748: 746: #[cfg_attr(
749: 747:     feature = "tracing",
750: 748:     tracing::instrument(level = "trace", fields(error), skip_all)
751: 749: )]
752: 750: pub fn render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async_with_context<IV>(
753: 751:     additional_context: impl Fn() + 'static + Clone + Send,
754: 752:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
755: 753:     method: Method,
756: 754: ) -> Route
757: 755: where
758: 756:     IV: IntoView + 'static,
759: 757: {
760: 758:     handle_response(method, additional_context, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn, async_stream_builder)
761: 759: }
762: 760: 
763: 761: fn async_stream_builder<IV>(
764: 762:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app: IV,
765: 763:     chunks: BoxedFnOnce<PinnedStream<String>>,
766: 764:     _supports_ooo: bool,
767: 765: ) -> PinnedFuture<PinnedStream<String>>
768: 766: where
769: 767:     IV: IntoView + 'static,
770: 768: {
771: 769:     Box::pin(async move {
772: 770:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = if cfg!(feature = "islands-router") {
773: 771:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order_branching()
774: 772:         } else {
775: 773:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order()
776: 774:         };
777: 775:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.collect::<String>().await;
778: 776:         let chunks = chunks();
779: 777:         Box::pin(once(async move { lyx-platform-lyx_platform_lyx-platform-lyx_platform_app }).chain(chunks)) as PinnedStream<String>
780: 778:     })
781: 779: }
782: 780: 
783: 781: #[cfg_attr(
784: 782:     feature = "tracing",
785: 783:     tracing::instrument(level = "trace", fields(error), skip_all)
786: 784: )]
787: 785: fn provide_contexts(
788: 786:     req: Request,
789: 787:     meta_context: &ServerMetaContext,
790: 788:     res_options: &ResponseOptions,
791: 789: ) {
792: 790:     let path = lyx-core-lyx_core_lyx-core-lyx_core_leptos_corrected_path(&req);
793: 791: 
794: 792:     provide_context(RequestUrl::new(&path));
795: 793:     provide_context(meta_context.clone());
796: 794:     provide_context(res_options.clone());
797: 795:     provide_context(req);
798: 796:     provide_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_redirect(redirect);
799: 797:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::nonce::provide_nonce();
800: 798: }
801: 799: 
802: 800: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_corrected_path(req: &HttpRequest) -> String {
803: 801:     let path = req.path();
804: 802:     let query = req.query_string();
805: 803:     if query.is_empty() {
806: 804:         "http://lyx-core-lyx_core_lyx-core-lyx_core_leptos".to_string() + path
807: 805:     } else {
808: 806:         "http://lyx-core-lyx_core_lyx-core-lyx_core_leptos".to_string() + path + "?" + query
809: 807:     }
810: 808: }
811: 809: 
812: 810: #[allow(clippy::type_complexity)]
813: 811: fn handle_response<IV>(
814: 812:     method: Method,
815: 813:     additional_context: impl Fn() + 'static + Clone + Send,
816: 814:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
817: 815:     stream_builder: fn(
818: 816:         IV,
819: 817:         BoxedFnOnce<PinnedStream<String>>,
820: 818:         bool,
821: 819:     ) -> PinnedFuture<PinnedStream<String>>,
822: 820: ) -> Route
823: 821: where
824: 822:     IV: IntoView + 'static,
825: 823: {
826: 824:     let handler = move |req: HttpRequest| {
827: 825:         let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone();
828: 826:         let add_context = additional_context.clone();
829: 827: 
830: 828:         async move {
831: 829:             let is_island_router_navigation = cfg!(feature = "islands-router")
832: 830:                 && req.headers().get("Islands-Router").is_some();
833: 831: 
834: 832:             let res_options = ResponseOptions::default();
835: 833:             let (meta_context, meta_output) = ServerMetaContext::new();
836: 834: 
837: 835:             let additional_context = {
838: 836:                 let meta_context = meta_context.clone();
839: 837:                 let res_options = res_options.clone();
840: 838:                 let req = Request::new(&req);
841: 839:                 move || {
842: 840:                     provide_contexts(req, &meta_context, &res_options);
843: 841:                     add_context();
844: 842: 
845: 843:                     if is_island_router_navigation {
846: 844:                         provide_context(IslandsRouterNavigation);
847: 845:                     }
848: 846:                 }
849: 847:             };
850: 848: 
851: 849:             let res = ActixResponse::from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app(
852: 850:                 lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn,
853: 851:                 meta_output,
854: 852:                 additional_context,
855: 853:                 res_options,
856: 854:                 stream_builder,
857: 855:                 !is_island_router_navigation,
858: 856:             )
859: 857:             .await;
860: 858: 
861: 859:             res.0
862: 860:         }
863: 861:     };
864: 862:     match method {
865: 863:         Method::Get => web::get().to(handler),
866: 864:         Method::Post => web::post().to(handler),
867: 865:         Method::Put => web::put().to(handler),
868: 866:         Method::Delete => web::delete().to(handler),
869: 867:         Method::Patch => web::patch().to(handler),
870: 868:     }
871: 869: }
872: 870: 
873: 871: /// Generates a list of all routes defined in Leptos's Router in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app. We can then use this to automatically
874: 872: /// create routes in Actix's App without having to use wildcard matching or fallbacks. Takes in your root lyx-platform-lyx_platform_lyx-platform-lyx_platform_app Element
875: 873: /// as an argument so it can walk you lyx-platform-lyx_platform_lyx-platform-lyx_platform_app tree. This version is tailored to generated Actix compatible paths.
876: 874: pub fn generate_route_list<IV>(
877: 875:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + 'static + Send + Clone,
878: 876: ) -> Vec<ActixRouteListing>
879: 877: where
880: 878:     IV: IntoView + 'static,
881: 879: {
882: 880:     generate_route_list_with_exclusions_and_ssg(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn, None).0
883: 881: }
884: 882: 
885: 883: /// Generates a list of all routes defined in Leptos's Router in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app. We can then use this to automatically
886: 884: /// create routes in Actix's App without having to use wildcard matching or fallbacks. Takes in your root lyx-platform-lyx_platform_lyx-platform-lyx_platform_app Element
887: 885: /// as an argument so it can walk you lyx-platform-lyx_platform_lyx-platform-lyx_platform_app tree. This version is tailored to generated Actix compatible paths.
888: 886: pub fn generate_route_list_with_ssg<IV>(
889: 887:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + 'static + Send + Clone,
890: 888: ) -> (Vec<ActixRouteListing>, StaticRouteGenerator)
891: 889: where
892: 890:     IV: IntoView + 'static,
893: 891: {
894: 892:     generate_route_list_with_exclusions_and_ssg(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn, None)
895: 893: }
896: 894: 
897: 895: /// Generates a list of all routes defined in Leptos's Router in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app. We can then use this to automatically
898: 896: /// create routes in Actix's App without having to use wildcard matching or fallbacks. Takes in your root lyx-platform-lyx_platform_lyx-platform-lyx_platform_app Element
899: 897: /// as an argument so it can walk you lyx-platform-lyx_platform_lyx-platform-lyx_platform_app tree. This version is tailored to generated Actix compatible paths. Adding excluded_routes
900: 898: /// to this function will stop `.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes()` from generating a route for it, allowing a custom handler. These need to be in Actix path format
901: 899: pub fn generate_route_list_with_exclusions<IV>(
902: 900:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + 'static + Send + Clone,
903: 901:     excluded_routes: Option<Vec<String>>,
904: 902: ) -> Vec<ActixRouteListing>
905: 903: where
906: 904:     IV: IntoView + 'static,
907: 905: {
908: 906:     generate_route_list_with_exclusions_and_ssg(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn, excluded_routes).0
909: 907: }
910: 908: 
911: 909: /// Generates a list of all routes defined in Leptos's Router in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app. We can then use this to automatically
912: 910: /// create routes in Actix's App without having to use wildcard matching or fallbacks. Takes in your root lyx-platform-lyx_platform_lyx-platform-lyx_platform_app Element
913: 911: /// as an argument so it can walk you lyx-platform-lyx_platform_lyx-platform-lyx_platform_app tree. This version is tailored to generated Actix compatible paths. Adding excluded_routes
914: 912: /// to this function will stop `.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes()` from generating a route for it, allowing a custom handler. These need to be in Actix path format
915: 913: pub fn generate_route_list_with_exclusions_and_ssg<IV>(
916: 914:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + 'static + Send + Clone,
917: 915:     excluded_routes: Option<Vec<String>>,
918: 916: ) -> (Vec<ActixRouteListing>, StaticRouteGenerator)
919: 917: where
920: 918:     IV: IntoView + 'static,
921: 919: {
922: 920:     generate_route_list_with_exclusions_and_ssg_and_context(
923: 921:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn,
924: 922:         excluded_routes,
925: 923:         || {},
926: 924:     )
927: 925: }
928: 926: 
929: 927: trait ActixPath {
930: 928:     fn to_actix_path(&self) -> String;
931: 929: }
932: 930: 
933: 931: impl ActixPath for Vec<PathSegment> {
934: 932:     fn to_actix_path(&self) -> String {
935: 933:         let mut path = String::new();
936: 934:         for segment in self.iter() {
937: 935:             // TODO trailing slash handling
938: 936:             let raw = segment.as_raw_str();
939: 937:             if !raw.is_empty() && !raw.starts_with('/') {
940: 938:                 path.push('/');
941: 939:             }
942: 940:             match segment {
943: 941:                 PathSegment::Static(s) => path.push_str(s),
944: 942:                 PathSegment::Param(s) => {
945: 943:                     path.push('{');
946: 944:                     path.push_str(s);
947: 945:                     path.push('}');
948: 946:                 }
949: 947:                 PathSegment::Splat(s) => {
950: 948:                     path.push('{');
951: 949:                     path.push_str(s);
952: 950:                     path.push_str(":.*}");
953: 951:                 }
954: 952:                 PathSegment::Unit => {}
955: 953:                 PathSegment::OptionalParam(_) => {
956: 954:                     #[cfg(feature = "tracing")]
957: 955:                     tracing::error!(
958: 956:                         "to_axum_path should only be called on expanded \
959: 957:                          paths, which do not have OptionalParam any longer"
960: 958:                     );
961: 959:                     Default::default()
962: 960:                 }
963: 961:             }
964: 962:         }
965: 963:         path
966: 964:     }
967: 965: }
968: 966: 
969: 967: #[derive(Clone, Debug, Default)]
970: 968: /// A route that this lyx-platform-lyx_platform_lyx-platform-lyx_platform_application can serve.
971: 969: pub struct ActixRouteListing {
972: 970:     path: String,
973: 971:     mode: SsrMode,
974: 972:     methods: Vec<lyx-core-lyx_core_lyx-core-router::Method>,
975: 973:     regenerate: Vec<RegenerationFn>,
976: 974:     exclude: bool,
977: 975: }
978: 976: 
979: 977: trait IntoRouteListing: Sized {
980: 978:     fn into_route_listing(self) -> Vec<ActixRouteListing>;
981: 979: }
982: 980: 
983: 981: impl IntoRouteListing for RouteListing {
984: 982:     fn into_route_listing(self) -> Vec<ActixRouteListing> {
985: 983:         self.path()
986: 984:             .to_vec()
987: 985:             .expand_optionals()
988: 986:             .into_iter()
989: 987:             .map(|path| {
990: 988:                 let path = path.to_actix_path();
991: 989:                 let path = if path.is_empty() {
992: 990:                     "/".to_string()
993: 991:                 } else {
994: 992:                     path
995: 993:                 };
996: 994:                 let mode = self.mode();
997: 995:                 let methods = self.methods().collect();
998: 996:                 let regenerate = self.regenerate().into();
999: 997:                 ActixRouteListing {
1000: 998:                     path,
1001: 999:                     mode: mode.clone(),
1002: 1000:                     methods,
1003: 1001:                     regenerate,
1004: 1002:                     exclude: false,
1005: 1003:                 }
1006: 1004:             })
1007: 1005:             .collect()
1008: 1006:     }
1009: 1007: }
1010: 1008: 
1011: 1009: impl ActixRouteListing {
1012: 1010:     /// Create a route listing from its parts.
1013: 1011:     pub fn new(
1014: 1012:         path: String,
1015: 1013:         mode: SsrMode,
1016: 1014:         methods: impl IntoIterator<Item = lyx-core-lyx_core_lyx-core-router::Method>,
1017: 1015:         regenerate: impl Into<Vec<RegenerationFn>>,
1018: 1016:     ) -> Self {
1019: 1017:         Self {
1020: 1018:             path,
1021: 1019:             mode,
1022: 1020:             methods: methods.into_iter().collect(),
1023: 1021:             regenerate: regenerate.into(),
1024: 1022:             exclude: false,
1025: 1023:         }
1026: 1024:     }
1027: 1025: 
1028: 1026:     /// The path this route handles.
1029: 1027:     pub fn path(&self) -> &str {
1030: 1028:         &self.path
1031: 1029:     }
1032: 1030: 
1033: 1031:     /// The rendering mode for this path.
1034: 1032:     pub fn mode(&self) -> SsrMode {
1035: 1033:         self.mode.clone()
1036: 1034:     }
1037: 1035: 
1038: 1036:     /// The HTTP request methods this path can handle.
1039: 1037:     pub fn methods(&self) -> impl Iterator<Item = lyx-core-lyx_core_lyx-core-router::Method> + '_ {
1040: 1038:         self.methods.iter().copied()
1041: 1039:     }
1042: 1040: }
1043: 1041: 
1044: 1042: /// Generates a list of all routes defined in Leptos's Router in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app. We can then use this to automatically
1045: 1043: /// create routes in Actix's App without having to use wildcard matching or fallbacks. Takes in your root lyx-platform-lyx_platform_lyx-platform-lyx_platform_app Element
1046: 1044: /// as an argument so it can walk you lyx-platform-lyx_platform_lyx-platform-lyx_platform_app tree. This version is tailored to generated Actix compatible paths. Adding excluded_routes
1047: 1045: /// to this function will stop `.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes()` from generating a route for it, allowing a custom handler. These need to be in Actix path format.
1048: 1046: /// Additional context will be provided to the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app Element.
1049: 1047: pub fn generate_route_list_with_exclusions_and_ssg_and_context<IV>(
1050: 1048:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + 'static + Send + Clone,
1051: 1049:     excluded_routes: Option<Vec<String>>,
1052: 1050:     additional_context: impl Fn() + 'static + Send + Clone,
1053: 1051: ) -> (Vec<ActixRouteListing>, StaticRouteGenerator)
1054: 1052: where
1055: 1053:     IV: IntoView + 'static,
1056: 1054: {
1057: 1055:     let _ = lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio();
1058: 1056: 
1059: 1057:     let owner = Owner::new_root(Some(Arc::new(SsrSharedContext::new())));
1060: 1058:     let (mock_meta, _) = ServerMetaContext::new();
1061: 1059:     let routes = owner
1062: 1060:         .with(|| {
1063: 1061:             // stub out a path for now
1064: 1062:             provide_context(RequestUrl::new(""));
1065: 1063:             provide_context(ResponseOptions::default());
1066: 1064:             provide_context(mock_meta);
1067: 1065:             additional_context();
1068: 1066:             RouteList::generate(&lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn)
1069: 1067:         })
1070: 1068:         .unwrap_or_default();
1071: 1069: 
1072: 1070:     let generator = StaticRouteGenerator::new(
1073: 1071:         &routes,
1074: 1072:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1075: 1073:         additional_context.clone(),
1076: 1074:     );
1077: 1075: 
1078: 1076:     // Axum's Router defines Root routes as "/" not ""
1079: 1077:     let mut routes = routes
1080: 1078:         .into_inner()
1081: 1079:         .into_iter()
1082: 1080:         .flat_map(IntoRouteListing::into_route_listing)
1083: 1081:         .collect::<Vec<_>>();
1084: 1082: 
1085: 1083:     let routes = if routes.is_empty() {
1086: 1084:         vec![ActixRouteListing::new(
1087: 1085:             "/".to_string(),
1088: 1086:             Default::default(),
1089: 1087:             [lyx-core-lyx_core_lyx-core-router::Method::Get],
1090: 1088:             vec![],
1091: 1089:         )]
1092: 1090:     } else {
1093: 1091:         // Routes to exclude from auto generation
1094: 1092:         if let Some(excluded_routes) = &excluded_routes {
1095: 1093:             routes.retain(|p| !excluded_routes.iter().any(|e| e == p.path()))
1096: 1094:         }
1097: 1095:         routes
1098: 1096:     };
1099: 1097: 
1100: 1098:     let excluded =
1101: 1099:         excluded_routes
1102: 1100:             .into_iter()
1103: 1101:             .flatten()
1104: 1102:             .map(|path| ActixRouteListing {
1105: 1103:                 path,
1106: 1104:                 mode: Default::default(),
1107: 1105:                 methods: Vec::new(),
1108: 1106:                 regenerate: Vec::new(),
1109: 1107:                 exclude: true,
1110: 1108:             });
1111: 1109: 
1112: 1110:     (routes.into_iter().chain(excluded).collect(), generator)
1113: 1111: }
1114: 1112: 
1115: 1113: /// Allows generating any prerendered routes.
1116: 1114: #[allow(clippy::type_complexity)]
1117: 1115: pub struct StaticRouteGenerator(
1118: 1116:     // this is here to keep the root owner alive for the duration
1119: 1117:     // of the route generation, so that base context provided continues
1120: 1118:     // to exist until it is dropped
1121: 1119:     #[allow(dead_code)] Owner,
1122: 1120:     Box<dyn FnOnce(&LeptosOptions) -> PinnedFuture<()> + Send>,
1123: 1121: );
1124: 1122: 
1125: 1123: impl StaticRouteGenerator {
1126: 1124:     fn render_route<IV: IntoView + 'static>(
1127: 1125:         path: String,
1128: 1126:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1129: 1127:         additional_context: impl Fn() + Clone + Send + 'static,
1130: 1128:     ) -> impl Future<Output = (Owner, String)> {
1131: 1129:         let (meta_context, meta_output) = ServerMetaContext::new();
1132: 1130:         let additional_context = {
1133: 1131:             let add_context = additional_context.clone();
1134: 1132:             move || {
1135: 1133:                 let mock_req = test::TestRequest::with_uri(&path)
1136: 1134:                     .insert_header(("Accept", "text/html"))
1137: 1135:                     .to_http_request();
1138: 1136:                 let res_options = ResponseOptions::default();
1139: 1137:                 provide_contexts(
1140: 1138:                     Request::new(&mock_req),
1141: 1139:                     &meta_context,
1142: 1140:                     &res_options,
1143: 1141:                 );
1144: 1142:                 add_context();
1145: 1143:             }
1146: 1144:         };
1147: 1145: 
1148: 1146:         let (owner, stream) = lyx-core-utils::build_response(
1149: 1147:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1150: 1148:             additional_context,
1151: 1149:             async_stream_builder,
1152: 1150:             false,
1153: 1151:         );
1154: 1152: 
1155: 1153:         let sc = owner.shared_context().unwrap();
1156: 1154: 
1157: 1155:         async move {
1158: 1156:             let stream = stream.await;
1159: 1157:             while let Some(pending) = sc.await_deferred() {
1160: 1158:                 pending.await;
1161: 1159:             }
1162: 1160: 
1163: 1161:             let html = meta_output
1164: 1162:                 .inject_meta_context(stream)
1165: 1163:                 .await
1166: 1164:                 .collect::<String>()
1167: 1165:                 .await;
1168: 1166:             (owner, html)
1169: 1167:         }
1170: 1168:     }
1171: 1169: 
1172: 1170:     /// Creates a new static route generator from the given list of route definitions.
1173: 1171:     pub fn new<IV>(
1174: 1172:         routes: &RouteList,
1175: 1173:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1176: 1174:         additional_context: impl Fn() + Clone + Send + 'static,
1177: 1175:     ) -> Self
1178: 1176:     where
1179: 1177:         IV: IntoView + 'static,
1180: 1178:     {
1181: 1179:         let owner = Owner::new();
1182: 1180:         Self(owner.clone(), {
1183: 1181:             let routes = routes.clone();
1184: 1182:             Box::new(move |options| {
1185: 1183:                 let options = options.clone();
1186: 1184:                 let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone();
1187: 1185:                 let additional_context = additional_context.clone();
1188: 1186: 
1189: 1187:                 owner.with(|| {
1190: 1188:                     additional_context();
1191: 1189:                     Box::pin(ScopedFuture::new(routes.generate_static_files(
1192: 1190:                         move |path: &ResolvedStaticPath| {
1193: 1191:                             Self::render_route(
1194: 1192:                                 path.to_string(),
1195: 1193:                                 lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1196: 1194:                                 additional_context.clone(),
1197: 1195:                             )
1198: 1196:                         },
1199: 1197:                         move |path: &ResolvedStaticPath,
1200: 1198:                               owner: &Owner,
1201: 1199:                               html: String| {
1202: 1200:                             let options = options.clone();
1203: 1201:                             let path = path.to_owned();
1204: 1202:                             let response_options = owner.with(use_context);
1205: 1203:                             async move {
1206: 1204:                                 write_static_route(
1207: 1205:                                     &options,
1208: 1206:                                     response_options,
1209: 1207:                                     path.as_ref(),
1210: 1208:                                     &html,
1211: 1209:                                 )
1212: 1210:                                 .await
1213: 1211:                             }
1214: 1212:                         },
1215: 1213:                         was_404,
1216: 1214:                     )))
1217: 1215:                 })
1218: 1216:             })
1219: 1217:         })
1220: 1218:     }
1221: 1219: 
1222: 1220:     /// Generates the routes.
1223: 1221:     pub async fn generate(self, options: &LeptosOptions) {
1224: 1222:         (self.1)(options).await
1225: 1223:     }
1226: 1224: }
1227: 1225: 
1228: 1226: static STATIC_HEADERS: LazyLock<DashMap<String, ResponseOptions>> =
1229: 1227:     LazyLock::new(DashMap::new);
1230: 1228: 
1231: 1229: fn was_404(owner: &Owner) -> bool {
1232: 1230:     let resp = owner.with(|| expect_context::<ResponseOptions>());
1233: 1231:     let status = resp.0.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().status;
1234: 1232: 
1235: 1233:     if let Some(status) = status {
1236: 1234:         return status == StatusCode::NOT_FOUND;
1237: 1235:     }
1238: 1236: 
1239: 1237:     false
1240: 1238: }
1241: 1239: 
1242: 1240: fn static_path(options: &LeptosOptions, path: &str) -> String {
1243: 1241:     use lyx-core-utils::static_file_path;
1244: 1242: 
1245: 1243:     // If the path ends with a trailing slash, we generate the path
1246: 1244:     // as a directory with a index.html file inside.
1247: 1245:     if path != "/" && path.ends_with("/") {
1248: 1246:         static_file_path(options, &format!("{path}index"))
1249: 1247:     } else {
1250: 1248:         static_file_path(options, path)
1251: 1249:     }
1252: 1250: }
1253: 1251: 
1254: 1252: async fn write_static_route(
1255: 1253:     options: &LeptosOptions,
1256: 1254:     response_options: Option<ResponseOptions>,
1257: 1255:     path: &str,
1258: 1256:     html: &str,
1259: 1257: ) -> Result<(), std::io::Error> {
1260: 1258:     if let Some(options) = response_options {
1261: 1259:         STATIC_HEADERS.insert(path.to_string(), options);
1262: 1260:     }
1263: 1261: 
1264: 1262:     let path = static_path(options, path);
1265: 1263:     let path = Path::new(&path);
1266: 1264:     if let Some(path) = path.parent() {
1267: 1265:         tokio::fs::create_dir_all(path).await?;
1268: 1266:     }
1269: 1267:     tokio::fs::write(path, &html).await?;
1270: 1268: 
1271: 1269:     Ok(())
1272: 1270: }
1273: 1271: 
1274: 1272: fn handle_static_route<IV>(
1275: 1273:     additional_context: impl Fn() + 'static + Clone + Send,
1276: 1274:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1277: 1275:     regenerate: Vec<RegenerationFn>,
1278: 1276: ) -> Route
1279: 1277: where
1280: 1278:     IV: IntoView + 'static,
1281: 1279: {
1282: 1280:     let handler = move |req: HttpRequest, data: Data<LeptosOptions>| {
1283: 1281:         Box::pin({
1284: 1282:             let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone();
1285: 1283:             let additional_context = additional_context.clone();
1286: 1284:             let regenerate = regenerate.clone();
1287: 1285:             async move {
1288: 1286:                 let options = data.into_inner();
1289: 1287:                 let orig_path = req.uri().path();
1290: 1288:                 let path = static_path(&options, orig_path);
1291: 1289:                 let path = Path::new(&path);
1292: 1290:                 let exists = tokio::fs::try_exists(path).await.unwrap_or(false);
1293: 1291: 
1294: 1292:                 let (response_options, html) = if !exists {
1295: 1293:                     let path = ResolvedStaticPath::new(orig_path);
1296: 1294: 
1297: 1295:                     let (owner, html) = path
1298: 1296:                         .build(
1299: 1297:                             move |path: &ResolvedStaticPath| {
1300: 1298:                                 StaticRouteGenerator::render_route(
1301: 1299:                                     path.to_string(),
1302: 1300:                                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1303: 1301:                                     additional_context.clone(),
1304: 1302:                                 )
1305: 1303:                             },
1306: 1304:                             move |path: &ResolvedStaticPath,
1307: 1305:                                   owner: &Owner,
1308: 1306:                                   html: String| {
1309: 1307:                                 let options = options.clone();
1310: 1308:                                 let path = path.to_owned();
1311: 1309:                                 let response_options = owner.with(use_context);
1312: 1310:                                 async move {
1313: 1311:                                     write_static_route(
1314: 1312:                                         &options,
1315: 1313:                                         response_options,
1316: 1314:                                         path.as_ref(),
1317: 1315:                                         &html,
1318: 1316:                                     )
1319: 1317:                                     .await
1320: 1318:                                 }
1321: 1319:                             },
1322: 1320:                             was_404,
1323: 1321:                             regenerate,
1324: 1322:                         )
1325: 1323:                         .await;
1326: 1324:                     (owner.with(use_context::<ResponseOptions>), html)
1327: 1325:                 } else {
1328: 1326:                     let headers =
1329: 1327:                         STATIC_HEADERS.get(orig_path).map(|v| v.clone());
1330: 1328:                     (headers, None)
1331: 1329:                 };
1332: 1330: 
1333: 1331:                 // if html is Some(_), it means that `was_error_response` is true and we're not
1334: 1332:                 // actually going to cache this route, just return it as HTML
1335: 1333:                 //
1336: 1334:                 // this if for thing like 404s, where we do not want to cache an endless series of
1337: 1335:                 // typos (or malicious requests)
1338: 1336:                 let mut res = ActixResponse(match html {
1339: 1337:                     Some(html) => {
1340: 1338:                         HttpResponse::Ok().content_type("text/html").body(html)
1341: 1339:                     }
1342: 1340:                     None => match NamedFile::open(path) {
1343: 1341:                         Ok(res) => res.into_response(&req),
1344: 1342:                         Err(err) => HttpResponse::InternalServerError()
1345: 1343:                             .body(err.to_string()),
1346: 1344:                     },
1347: 1345:                 });
1348: 1346: 
1349: 1347:                 if let Some(options) = response_options {
1350: 1348:                     res.extend_response(&options);
1351: 1349:                 }
1352: 1350: 
1353: 1351:                 res.0
1354: 1352:             }
1355: 1353:         })
1356: 1354:     };
1357: 1355:     web::get().to(handler)
1358: 1356: }
1359: 1357: 
1360: 1358: /// This trait allows one to pass a list of routes and a render function to Actix's router, letting us avoid
1361: 1359: /// having to use wildcards or manually define all routes in multiple places.
1362: 1360: pub trait LeptosRoutes {
1363: 1361:     /// Adds routes to the Axum router that have either
1364: 1362:     /// 1) been generated by `lyx-core-lyx_core_lyx-core-router`, or
1365: 1363:     /// 2) handle a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
1366: 1364:     fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes<IV>(
1367: 1365:         self,
1368: 1366:         paths: Vec<ActixRouteListing>,
1369: 1367:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1370: 1368:     ) -> Self
1371: 1369:     where
1372: 1370:         IV: IntoView + 'static;
1373: 1371: 
1374: 1372:     /// Adds routes to the Axum router that have either
1375: 1373:     /// 1) been generated by `lyx-core-lyx_core_lyx-core-router`, or
1376: 1374:     /// 2) handle a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function.
1377: 1375:     ///
1378: 1376:     /// Runs `additional_context` to provide additional data to the reactive system via context,
1379: 1377:     /// when handling a route.
1380: 1378:     fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context<IV>(
1381: 1379:         self,
1382: 1380:         paths: Vec<ActixRouteListing>,
1383: 1381:         additional_context: impl Fn() + 'static + Clone + Send,
1384: 1382:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1385: 1383:     ) -> Self
1386: 1384:     where
1387: 1385:         IV: IntoView + 'static;
1388: 1386: }
1389: 1387: 
1390: 1388: /// The default implementation of `LeptosRoutes` which takes in a list of paths, and dispatches GET requests
1391: 1389: /// to those paths to Leptos's renderer.
1392: 1390: impl<T> LeptosRoutes for actix_web::App<T>
1393: 1391: where
1394: 1392:     T: ServiceFactory<
1395: 1393:         ServiceRequest,
1396: 1394:         Config = (),
1397: 1395:         Error = Error,
1398: 1396:         InitError = (),
1399: 1397:     >,
1400: 1398: {
1401: 1399:     #[cfg_attr(
1402: 1400:         feature = "tracing",
1403: 1401:         tracing::instrument(level = "trace", fields(error), skip_all)
1404: 1402:     )]
1405: 1403:     fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes<IV>(
1406: 1404:         self,
1407: 1405:         paths: Vec<ActixRouteListing>,
1408: 1406:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1409: 1407:     ) -> Self
1410: 1408:     where
1411: 1409:         IV: IntoView + 'static,
1412: 1410:     {
1413: 1411:         self.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context(paths, || {}, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn)
1414: 1412:     }
1415: 1413: 
1416: 1414:     #[cfg_attr(
1417: 1415:         feature = "tracing",
1418: 1416:         tracing::instrument(level = "trace", fields(error), skip_all)
1419: 1417:     )]
1420: 1418:     fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context<IV>(
1421: 1419:         self,
1422: 1420:         paths: Vec<ActixRouteListing>,
1423: 1421:         additional_context: impl Fn() + 'static + Clone + Send,
1424: 1422:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1425: 1423:     ) -> Self
1426: 1424:     where
1427: 1425:         IV: IntoView + 'static,
1428: 1426:     {
1429: 1427:         let mut router = self;
1430: 1428: 
1431: 1429:         let excluded = paths
1432: 1430:             .iter()
1433: 1431:             .filter(|&p| p.exclude)
1434: 1432:             .map(|p| p.path.as_str())
1435: 1433:             .collect::<HashSet<_>>();
1436: 1434: 
1437: 1435:         // register lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions first to allow for wildcard route in Leptos's Router
1438: 1436:         for (path, _) in lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::actix::lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_paths() {
1439: 1437:             if !excluded.contains(path) {
1440: 1438:                 let additional_context = additional_context.clone();
1441: 1439:                 let handler =
1442: 1440:                     handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(additional_context);
1443: 1441:                 router = router.route(path, handler);
1444: 1442:             }
1445: 1443:         }
1446: 1444: 
1447: 1445:         // register routes defined in Leptos's Router
1448: 1446:         for listing in paths.iter().filter(|p| !p.exclude) {
1449: 1447:             let path = listing.path();
1450: 1448:             let mode = listing.mode();
1451: 1449: 
1452: 1450:             for method in listing.methods() {
1453: 1451:                 let additional_context = additional_context.clone();
1454: 1452:                 let additional_context_and_method = move || {
1455: 1453:                     provide_context(method);
1456: 1454:                     additional_context();
1457: 1455:                 };
1458: 1456:                 router = if matches!(listing.mode(), SsrMode::Static(_)) {
1459: 1457:                     router.route(
1460: 1458:                         path,
1461: 1459:                         handle_static_route(
1462: 1460:                             additional_context_and_method.clone(),
1463: 1461:                             lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1464: 1462:                             listing.regenerate.clone(),
1465: 1463:                         ),
1466: 1464:                     )
1467: 1465:                 } else {
1468: 1466:                     router
1469: 1467:                         .route(path, web::head().to(HttpResponse::Ok))
1470: 1468:                         .route(
1471: 1469:                             path,
1472: 1470:                             match mode {
1473: 1471:                                 SsrMode::OutOfOrder => {
1474: 1472:                                     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context(
1475: 1473:                                         additional_context_and_method.clone(),
1476: 1474:                                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1477: 1475:                                         method,
1478: 1476:                                     )
1479: 1477:                                 }
1480: 1478:                                 SsrMode::PartiallyBlocked => {
1481: 1479:                                     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context_and_replace_blocks(
1482: 1480:                                         additional_context_and_method.clone(),
1483: 1481:                                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1484: 1482:                                         method,
1485: 1483:                                         true,
1486: 1484:                                     )
1487: 1485:                                 }
1488: 1486:                                 SsrMode::InOrder => {
1489: 1487:                                     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_in_order_with_context(
1490: 1488:                                         additional_context_and_method.clone(),
1491: 1489:                                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1492: 1490:                                         method,
1493: 1491:                                     )
1494: 1492:                                 }
1495: 1493:                                 SsrMode::Async => render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async_with_context(
1496: 1494:                                     additional_context_and_method.clone(),
1497: 1495:                                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1498: 1496:                                     method,
1499: 1497:                                 ),
1500: 1498:                                 _ => unreachable!()
1501: 1499:                             },
1502: 1500:                         )
1503: 1501:                 };
1504: 1502:             }
1505: 1503:         }
1506: 1504: 
1507: 1505:         router
1508: 1506:     }
1509: 1507: }
1510: 1508: 
1511: 1509: /// The default implementation of `LeptosRoutes` which takes in a list of paths, and dispatches GET requests
1512: 1510: /// to those paths to Leptos's renderer.
1513: 1511: impl LeptosRoutes for &mut ServiceConfig {
1514: 1512:     #[cfg_attr(
1515: 1513:         feature = "tracing",
1516: 1514:         tracing::instrument(level = "trace", fields(error), skip_all)
1517: 1515:     )]
1518: 1516:     fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes<IV>(
1519: 1517:         self,
1520: 1518:         paths: Vec<ActixRouteListing>,
1521: 1519:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1522: 1520:     ) -> Self
1523: 1521:     where
1524: 1522:         IV: IntoView + 'static,
1525: 1523:     {
1526: 1524:         self.lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context(paths, || {}, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn)
1527: 1525:     }
1528: 1526: 
1529: 1527:     #[cfg_attr(
1530: 1528:         feature = "tracing",
1531: 1529:         tracing::instrument(level = "trace", fields(error), skip_all)
1532: 1530:     )]
1533: 1531:     fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context<IV>(
1534: 1532:         self,
1535: 1533:         paths: Vec<ActixRouteListing>,
1536: 1534:         additional_context: impl Fn() + 'static + Clone + Send,
1537: 1535:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn: impl Fn() -> IV + Clone + Send + 'static,
1538: 1536:     ) -> Self
1539: 1537:     where
1540: 1538:         IV: IntoView + 'static,
1541: 1539:     {
1542: 1540:         let mut router = self;
1543: 1541: 
1544: 1542:         let excluded = paths
1545: 1543:             .iter()
1546: 1544:             .filter(|&p| p.exclude)
1547: 1545:             .map(|p| p.path.as_str())
1548: 1546:             .collect::<HashSet<_>>();
1549: 1547: 
1550: 1548:         // register lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions first to allow for wildcard route in Leptos's Router
1551: 1549:         for (path, _) in lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::actix::lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_paths() {
1552: 1550:             if !excluded.contains(path) {
1553: 1551:                 let additional_context = additional_context.clone();
1554: 1552:                 let handler =
1555: 1553:                     handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns_with_context(additional_context);
1556: 1554:                 router = router.route(path, handler);
1557: 1555:             }
1558: 1556:         }
1559: 1557: 
1560: 1558:         // register routes defined in Leptos's Router
1561: 1559:         for listing in paths.iter().filter(|p| !p.exclude) {
1562: 1560:             let path = listing.path();
1563: 1561:             let mode = listing.mode();
1564: 1562: 
1565: 1563:             for method in listing.methods() {
1566: 1564:                 if matches!(listing.mode(), SsrMode::Static(_)) {
1567: 1565:                     router = router.route(
1568: 1566:                         path,
1569: 1567:                         handle_static_route(
1570: 1568:                             additional_context.clone(),
1571: 1569:                             lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1572: 1570:                             listing.regenerate.clone(),
1573: 1571:                         ),
1574: 1572:                     )
1575: 1573:                 } else {
1576: 1574:                     router = router.route(
1577: 1575:                             path,
1578: 1576:                             match mode {
1579: 1577:                                 SsrMode::OutOfOrder => {
1580: 1578:                                     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context(
1581: 1579:                                         additional_context.clone(),
1582: 1580:                                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1583: 1581:                                         method,
1584: 1582:                                     )
1585: 1583:                                 }
1586: 1584:                                 SsrMode::PartiallyBlocked => {
1587: 1585:                                     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_with_context_and_replace_blocks(
1588: 1586:                                         additional_context.clone(),
1589: 1587:                                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1590: 1588:                                         method,
1591: 1589:                                         true,
1592: 1590:                                     )
1593: 1591:                                 }
1594: 1592:                                 SsrMode::InOrder => {
1595: 1593:                                     render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_to_stream_in_order_with_context(
1596: 1594:                                         additional_context.clone(),
1597: 1595:                                         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1598: 1596:                                         method,
1599: 1597:                                     )
1600: 1598:                                 }
1601: 1599:                                 SsrMode::Async => render_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_async_with_context(
1602: 1600:                                     additional_context.clone(),
1603: 1601:                                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_fn.clone(),
1604: 1602:                                     method,
1605: 1603:                                 ),
1606: 1604:                                 _ => unreachable!()
1607: 1605:                             },
1608: 1606:                         );
1609: 1607:                 }
1610: 1608:             }
1611: 1609:         }
1612: 1610: 
1613: 1611:         router
1614: 1612:     }
1615: 1613: }
1616: 1614: 
1617: 1615: /// A helper to make it easier to use Actix extractors in lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions.
1618: 1616: ///
1619: 1617: /// It is generic over some type `T` that implements [`FromRequest`] and can
1620: 1618: /// therefore be used in an extractor. The compiler can often infer this type.
1621: 1619: ///
1622: 1620: /// Any error that occurs during extraction is converted to a [`ServerFnError`].
1623: 1621: ///
1624: 1622: /// ```rust
1625: 1623: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
1626: 1624: ///
1627: 1625: /// #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
1628: 1626: /// pub async fn extract_connection_info() -> Result<String, ServerFnError> {
1629: 1627: ///     use actix_web::dev::ConnectionInfo;
1630: 1628: ///     use lyx-core-actix::*;
1631: 1629: ///
1632: 1630: ///     // this can be any type you can use an Actix extractor with, as long as
1633: 1631: ///     // it works on the head, not the body of the request
1634: 1632: ///     let info: ConnectionInfo = extract().await?;
1635: 1633: ///
1636: 1634: ///     // do something with the data
1637: 1635: ///
1638: 1636: ///     Ok(format!("{info:?}"))
1639: 1637: /// }
1640: 1638: /// ```
1641: 1639: pub async fn extract<T>() -> Result<T, ServerFnErrorErr>
1642: 1640: where
1643: 1641:     T: actix_web::FromRequest,
1644: 1642:     <T as FromRequest>::Error: Display,
1645: 1643: {
1646: 1644:     let req = use_context::<Request>().ok_or_else(|| {
1647: 1645:         ServerFnErrorErr::ServerError(
1648: 1646:             "HttpRequest should have been provided via context".to_string(),
1649: 1647:         )
1650: 1648:     })?;
1651: 1649: 
1652: 1650:     SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(async move {
1653: 1651:         T::extract(&req)
1654: 1652:             .await
1655: 1653:             .map_err(|e| ServerFnErrorErr::ServerError(e.to_string()))
1656: 1654:     })
1657: 1655:     .await
1658: 1656: }
1659: ```
```
