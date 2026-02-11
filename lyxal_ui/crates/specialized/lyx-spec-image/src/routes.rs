### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-image\src\routes.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-image\src\routes.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\routes.rs
46: 44: ```rust
47: 45: use crate::optimizer::{CachedImage, CachedImageOption, CreateImageError, ImageOptimizer};
48: 46: use axum::extract::FromRef;
49: 47: use axum::response::Response as AxumResponse;
50: 48: use axum::{
51: 49:     body::Body,
52: 50:     http::{Request, Response, Uri},
53: 51:     response::IntoResponse,
54: 52: };
55: 53: use std::convert::Infallible;
56: 54: use tower::ServiceExt;
57: 55: use tower_http::services::fs::ServeFileSystemResponseBody;
58: 56: use tower_http::services::ServeDir;
59: 57: 
60: 58: /// This trait prevents using incorrect route for image cache handler.
61: 59: pub trait ImageCacheRoute<S>
62: 60: where
63: 61:     S: Clone + Send + Sync + 'static,
64: 62: {
65: 63:     /// Adds a route to the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app for serving cached images.
66: 64:     /// Requires an axum State that contains the optimizer [`crate::ImageOptimizer`].
67: 65:     ///
68: 66:     /// ```
69: 67:     /// use lyx-core-lyx_core_lyx-spec-image::*;
70: 68:     /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
71: 69:     /// use axum::*;
72: 70:     /// use axum::routing::post;
73: 71:     /// use lyx-core-axum::{generate_route_list, handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns, LeptosRoutes};
74: 72:     ///
75: 73:     /// #[cfg(feature = "ssr")]
76: 74:     /// async fn your_main_function() {
77: 75:     ///
78: 76:     ///   let options = get_configuration(None).await.unwrap().lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
79: 77:     ///   let optimizer = ImageOptimizer::new("/__cache/image", options.site_root.clone(), 1);
80: 78:     ///   let state = AppState {lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: options, optimizer: optimizer.clone() };
81: 79:     ///   let routes = generate_route_list(App);
82: 80:     ///
83: 81:     ///   let router: Router<()> = Router::new()
84: 82:     ///    .route("/api/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
85: 83:     ///    // Add a handler for serving the cached images.
86: 84:     ///    .image_cache_route(&state)
87: 85:     ///    .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context(&state, routes, optimizer.provide_context(), App)
88: 86:     ///    .with_state(state);
89: 87:     ///
90: 88:     ///   // Rest of your function ...
91: 89:     /// }
92: 90:     ///
93: 91:     /// // Composite App State with the optimizer and lyx-core-lyx_core_lyx-core-lyx_core_leptos options.
94: 92:     /// #[derive(Clone, axum::extract::FromRef)]
95: 93:     /// struct AppState {
96: 94:     ///   lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions,
97: 95:     ///   optimizer: lyx-core-lyx_core_lyx-spec-image::ImageOptimizer,
98: 96:     /// }
99: 97:     ///
100: 98:     /// #[component]
101: 99:     /// fn App() -> impl IntoView {
102: 100:     ///   provide_image_context();
103: 101:     ///   ()
104: 102:     /// }
105: 103:     ///
106: 104:     /// ```
107: 105:     ///
108: 106:     ///
109: 107:     fn image_cache_route(self, state: &S) -> Self;
110: 108: }
111: 109: 
112: 110: impl<S> ImageCacheRoute<S> for axum::Router<S>
113: 111: where
114: 112:     S: Clone + Send + Sync + 'static,
115: 113:     ImageOptimizer: FromRef<S>,
116: 114: {
117: 115:     fn image_cache_route(self, state: &S) -> Self {
118: 116:         let optimizer = ImageOptimizer::from_ref(state);
119: 117: 
120: 118:         let path = optimizer.api_handler_path.clone();
121: 119:         let handler = move |req: Request<Body>| image_cache_handler_inner(optimizer, req);
122: 120: 
123: 121:         self.route(&path, axum::routing::get(handler))
124: 122:     }
125: 123: }
126: 124: 
127: 125: async fn image_cache_handler_inner(optimizer: ImageOptimizer, req: Request<Body>) -> AxumResponse {
128: 126:     let root = optimizer.root_file_path.clone();
129: 127:     let cache_result = check_cache_image(&optimizer, req.uri().clone()).await;
130: 128: 
131: 129:     match cache_result {
132: 130:         Ok(Some(uri)) => {
133: 131:             let response = execute_file_handler(uri, &root).await.unwrap();
134: 132:             response.into_response()
135: 133:         }
136: 134: 
137: 135:         Ok(None) => Response::builder()
138: 136:             .status(404)
139: 137:             .body("Invalid Image.".to_string())
140: 138:             .unwrap()
141: 139:             .into_response(),
142: 140: 
143: 141:         Err(e) => {
144: 142:             tracing::error!("Failed to create image: {:?}", e);
145: 143:             Response::builder()
146: 144:                 .status(500)
147: 145:                 .body("Error creating image".to_string())
148: 146:                 .unwrap()
149: 147:                 .into_response()
150: 148:         }
151: 149:     }
152: 150: }
153: 151: 
154: 152: async fn execute_file_handler(
155: 153:     uri: Uri,
156: 154:     root: &str,
157: 155: ) -> Result<Response<ServeFileSystemResponseBody>, Infallible> {
158: 156:     let req = Request::builder()
159: 157:         .uri(uri.clone())
160: 158:         .body(Body::empty())
161: 159:         .unwrap();
162: 160:     ServeDir::new(root).oneshot(req).await
163: 161: }
164: 162: 
165: 163: async fn check_cache_image(
166: 164:     optimizer: &ImageOptimizer,
167: 165:     uri: Uri,
168: 166: ) -> Result<Option<Uri>, CreateImageError> {
169: 167:     let cache_image = {
170: 168:         let url = uri.to_string();
171: 169: 
172: 170:         if let Some(img) = CachedImage::from_url_encoded(&url).ok() {
173: 171:             let result = optimizer.create_image(&img).await;
174: 172: 
175: 173:             if let Ok(true) = result {
176: 174:                 tracing::info!("Created Image: {}", img);
177: 175:             }
178: 176: 
179: 177:             result?;
180: 178: 
181: 179:             img
182: 180:         } else {
183: 181:             return Ok(None);
184: 182:         }
185: 183:     };
186: 184: 
187: 185:     let file_path = cache_image.get_file_path();
188: 186: 
189: 187:     add_file_to_cache(optimizer, cache_image).await;
190: 188: 
191: 189:     let uri_string = "/".to_string() + &file_path;
192: 190:     let maybe_uri = (uri_string).parse::<Uri>().ok();
193: 191: 
194: 192:     if let Some(uri) = maybe_uri {
195: 193:         Ok(Some(uri))
196: 194:     } else {
197: 195:         tracing::error!("Failed to create uri: File path {file_path}");
198: 196:         Ok(None)
199: 197:     }
200: 198: }
201: 199: 
202: 200: // When the image is created, it will be added to the cache.
203: 201: // Mostly helpful for dev lyx-platform-lyx_platform_lyx-platform-lyx_platform_server startup.
204: 202: async fn add_file_to_cache(optimizer: &ImageOptimizer, image: CachedImage) {
205: 203:     if let CachedImageOption::Blur(_) = image.option {
206: 204:         if optimizer.cache.get(&image).is_none() {
207: 205:             let path = optimizer.get_file_path_from_root(&image);
208: 206:             match tokio::fs::read_to_string(path).await {
209: 207:                 Ok(data) => {
210: 208:                     optimizer.cache.insert(image, data);
211: 209:                     tracing::debug!("Added image to cache (size {})", optimizer.cache.len())
212: 210:                 }
213: 211:                 Err(e) => {
214: 212:                     tracing::error!("Failed to read image [{}] with error: {:?}", image, e);
215: 213:                 }
216: 214:             }
217: 215:         }
218: 216:     }
219: 217: }
220: 218: ```
221: 219: ```
222: 220: ```
223: 221: ```
224: 222: ```
225: 223: ```
226: 224: ```
227: 225: ```
228: 226: ```
229: 227: ```
230: 228: ```
231: 229: ```
232: 230: ```
233: 231: ```
234: 232: ```
235: 233: ```
236: 234: ```
237: 235: ```
238: 236: ```
239: 237: ```
240: 238: ```
241: 239: ```
242: ```
```
