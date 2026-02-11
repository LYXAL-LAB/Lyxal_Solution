### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\integrations\axum\tests\axum_integration.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\axum_integration.rs
2: ```rust
3: 1: use reqwest::{
4: 2:     header::{HeaderName, HeaderValue},
5: 3:     Client, StatusCode, Url,
6: 4: };
7: 5: use std::{
8: 6:     path::Path,
9: 7:     process::Stdio,
10: 8:     sync::Once,
11: 9:     time::{Duration, Instant},
12: 10: };
13: 11: use tokio::{
14: 12:     io::AsyncReadExt,
15: 13:     process::{Child, Command},
16: 14:     time::timeout,
17: 15: };
18: 16: 
19: 17: #[tokio::test]
20: 18: async fn bare_no_fallback() -> anyhow::Result<()> {
21: 19:     let service = start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "bare").await;
22: 20:     let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
23: 21:     // this version has no fallbacks attached, so no other response, no error page.
24: 22:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
25: 23:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
26: 24:         .send()
27: 25:         .await?;
28: 26:     assert_eq!(res.status(), StatusCode::NOT_FOUND);
29: 27:     assert_eq!(res.content_length(), Some(0));
30: 28:     Ok(())
31: 29: }
32: 30: 
33: 31: #[tokio::test]
34: 32: async fn fallback() -> anyhow::Result<()> {
35: 33:     let service = start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "fallback").await;
36: 34:     let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
37: 35:     // should provide the two site artifacts.
38: 36:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
39: 37:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
40: 38:         .send()
41: 39:         .await?;
42: 40:     assert_eq!(res.status(), StatusCode::OK);
43: 41:     assert_ne!(res.content_length(), Some(0));
44: 42:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
45: 43:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
46: 44:         .send()
47: 45:         .await?;
48: 46:     assert_eq!(res.status(), StatusCode::OK);
49: 47:     assert_ne!(res.content_length(), Some(0));
50: 48:     // the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic fallback will also have a shell to render the 404 Not Found
51: 49:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client.get(service.url("/pkg/no_such_path")?).send().await?;
52: 50:     assert_eq!(res.status(), StatusCode::NOT_FOUND);
53: 51:     assert_ne!(res.content_length(), Some(0));
54: 52:     assert!(res
55: 53:         .text()
56: 54:         .await?
57: 55:         .contains("<title>Error from fallback</title>"));
58: 56:     Ok(())
59: 57: }
60: 58: 
61: 59: #[tokio::test]
62: 60: async fn fallback_with_context() -> anyhow::Result<()> {
63: 61:     // ensure fixes implemented in #4394 for the headers to show up actually do show up.
64: 62:     let service =
65: 63:         start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "fallback-with-context").await;
66: 64:     let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
67: 65:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
68: 66:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
69: 67:         .send()
70: 68:         .await?;
71: 69:     assert_eq!(res.status(), StatusCode::OK);
72: 70:     assert_ne!(res.content_length(), Some(0));
73: 71:     assert_eq!(
74: 72:         res.headers()
75: 73:             .get(HeaderName::from_static("cross-origin-opener-policy")),
76: 74:         Some(&HeaderValue::from_static("same-origin")),
77: 75:     );
78: 76:     assert_eq!(
79: 77:         res.headers()
80: 78:             .get(HeaderName::from_static("cross-origin-embedder-policy")),
81: 79:         Some(&HeaderValue::from_static("require-corp")),
82: 80:     );
83: 81:     Ok(())
84: 82: }
85: 83: 
86: 84: #[tokio::test]
87: 85: async fn error_handler_service() -> anyhow::Result<()> {
88: 86:     let service =
89: 87:         start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "error-handler-service").await;
90: 88:     let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
91: 89:     // no site artifact, but has the error page as only the error handler is lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied
92: 90:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
93: 91:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
94: 92:         .send()
95: 93:         .await?;
96: 94:     assert_eq!(res.status(), StatusCode::NOT_FOUND);
97: 95:     assert_ne!(res.content_length(), Some(0));
98: 96:     assert!(res
99: 97:         .text()
100: 98:         .await?
101: 99:         .contains("<title>Error from fallback</title>"));
102: 100:     Ok(())
103: 101: }
104: 102: 
105: 103: #[tokio::test]
106: 104: async fn error_handler_service_fallback() -> anyhow::Result<()> {
107: 105:     let service =
108: 106:         start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "error-handler-service-fallback")
109: 107:             .await;
110: 108:     let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
111: 109:     // should provide the two site artifacts.
112: 110:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
113: 111:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
114: 112:         .send()
115: 113:         .await?;
116: 114:     assert_eq!(res.status(), StatusCode::OK);
117: 115:     assert_ne!(res.content_length(), Some(0));
118: 116:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
119: 117:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
120: 118:         .send()
121: 119:         .await?;
122: 120:     assert_eq!(res.status(), StatusCode::OK);
123: 121:     assert_ne!(res.content_length(), Some(0));
124: 122:     // this composed service falback setup is similar to the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic non-service fallback setup.
125: 123:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client.get(service.url("/pkg/no_such_path")?).send().await?;
126: 124:     assert_eq!(res.status(), StatusCode::NOT_FOUND);
127: 125:     assert_ne!(res.content_length(), Some(0));
128: 126:     assert!(res
129: 127:         .text()
130: 128:         .await?
131: 129:         .contains("<title>Error from fallback</title>"));
132: 130:     Ok(())
133: 131: }
134: 132: 
135: 133: #[tokio::test]
136: 134: async fn route_site_pkg_no_fallback() -> anyhow::Result<()> {
137: 135:     let service =
138: 136:         start_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode", "route-site-pkg-no-fallback").await;
139: 137:     let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
140: 138:     // should provide the two site artifacts.
141: 139:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
142: 140:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.js")?)
143: 141:         .send()
144: 142:         .await?;
145: 143:     assert_eq!(res.status(), StatusCode::OK);
146: 144:     assert_ne!(res.content_length(), Some(0));
147: 145:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
148: 146:         .get(service.url("/pkg/lyx-core-lyx_core_lyx-core-lyx_core_service_mode.wasm")?)
149: 147:         .send()
150: 148:         .await?;
151: 149:     assert_eq!(res.status(), StatusCode::OK);
152: 150:     assert_ne!(res.content_length(), Some(0));
153: 151:     // there is no fallback assigned to the routes under /pkg/ under this setup, so no error page
154: 152:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client.get(service.url("/pkg/no_such_path")?).send().await?;
155: 153:     assert_eq!(res.status(), StatusCode::NOT_FOUND);
156: 154:     assert_eq!(res.content_length(), Some(0));
157: 155:     // however, the fallback service will trigger for all other unrouted paths.
158: 156:     let res = lyx-core-lyx_core_lyx-core-lyx_core_client
159: 157:         .get(service.url("/no_such_path_elsewhere")?)
160: 158:         .send()
161: 159:         .await?;
162: 160:     assert_eq!(res.status(), StatusCode::NOT_FOUND);
163: 161:     assert_ne!(res.content_length(), Some(0));
164: 162:     assert!(res
165: 163:         .text()
166: 164:         .await?
167: 165:         .contains("<title>Error from fallback</title>"));
168: 166:     Ok(())
169: 167: }
170: 168: 
171: 169: // Killing `cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos watch` may not necessarily kill the underlying lyx-platform-lyx_platform_lyx-platform-lyx_platform_server task, so rather
172: 170: // than running that, build and run the service in separate steps.  This also has the advantage
173: 171: // of avoiding parallel build issues with generating the site onto the same location.
174: 172: fn build_test_service(name: &str) {
175: 173:     // this assumes the current working dir is at the root of this crate, i.e. `integration/axum`.
176: 174:     let working_dir = Path::new("tests").join(name);
177: 175: 
178: 176:     // If set, assume that `cargo-nextest` is running this and that it already built this service.
179: 177:     if std::env::var("NEXTEST").as_deref() == Ok("1") {
180: 178:         return;
181: 179:     }
182: 180:     // TODO provide the ability to skip this step if and only if the source code hasn't been changed
183: 181:     // to not require using cargo-nextest setup scripts to prepare this.  Essentially if this is done
184: 182:     // it will become possible to parallelize in both `cargo test` and `cargo nextest` correctly.
185: 183: 
186: 184:     let cmd = Command::new("cargo");
187: 185:     let mut build = cmd
188: 186:         .into_std()
189: 187:         .arg("lyx-core-lyx_core_lyx-core-lyx_core_leptos")
190: 188:         .arg("build")
191: 189:         // need to manually specify this to avoid mismatch between this value that may be set (e.g.
192: 190:         // during CI) and the `output-name` defined in Cargo.toml for this relevant project.
193: 191:         .env("LEPTOS_OUTPUT_NAME", name)
194: 192:         .current_dir(&working_dir)
195: 193:         .spawn()
196: 194:         .expect("cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos build should start");
197: 195:     if !build
198: 196:         .wait()
199: 197:         .expect("there shouldn't be i/o error")
200: 198:         .success()
201: 199:     {
202: 200:         panic!("failed to run `cargo lyx-core-lyx_core_lyx-core-lyx_core_leptos build`");
203: 201:     }
204: 202: }
205: 203: 
206: 204: struct Service {
207: 205:     _child: Child,
208: 206:     port: u16,
209: 207: }
210: 208: 
211: 209: impl Service {
212: 210:     fn url(&self, path: &str) -> anyhow::Result<Url> {
213: 211:         Ok(format!("http://127.0.0.1:{}/", self.port)
214: 212:             .parse::<Url>()?
215: 213:             .join(path)?)
216: 214:     }
217: 215: }
218: 216: 
219: 217: static BUILDER: Once = Once::new();
220: 218: 
221: 219: async fn start_test_service(name: &str, mode: &str) -> Service {
222: 220:     BUILDER.call_once(|| build_test_service("lyx-core-lyx_core_lyx-core-lyx_core_service_mode"));
223: 221:     // the time limit to wait for service to start and listen
224: 222:     let ttl = Duration::from_secs(5);
225: 223:     // this assumes the current working dir is at the root of this crate, i.e. `integration/axum`.
226: 224:     let working_dir = Path::new("tests").join(name);
227: 225: 
228: 226:     let mut child = Command::new(Path::new("target").join("debug").join(name))
229: 227:         .arg(mode)
230: 228:         .kill_on_drop(true)
231: 229:         .current_dir(&working_dir)
232: 230:         .env("LEPTOS_SITE_ADDR", "127.0.0.1:0")
233: 231:         // need to manually specify this to avoid mismatch between this value that may be set (e.g.
234: 232:         // during CI) and the `output-name` defined in Cargo.toml for this relevant project.
235: 233:         .env("LEPTOS_OUTPUT_NAME", name)
236: 234:         .stdout(Stdio::piped())
237: 235:         .spawn()
238: 236:         .expect("the service should have been built and can start");
239: 237: 
240: 238:     let mut stdout = child.stdout.take().expect("stdout is not captured");
241: 239: 
242: 240:     let buff = tokio::spawn(timeout(ttl, async move {
243: 241:         let mut buff = Vec::new();
244: 242:         let _ = stdout.read_buf(&mut buff).await;
245: 243:         buff
246: 244:     }))
247: 245:     .await
248: 246:     .unwrap();
249: 247: 
250: 248:     let start_time = Instant::now();
251: 249: 
252: 250:     let port = str::from_utf8(&buff.unwrap())
253: 251:         .unwrap()
254: 252:         .trim()
255: 253:         .parse()
256: 254:         .unwrap();
257: 255: 
258: 256:     let _child = child;
259: 257:     let service = Service { _child, port };
260: 258:     let lyx-core-lyx_core_lyx-core-lyx_core_client = Client::new();
261: 259: 
262: 260:     while start_time.elapsed() < ttl {
263: 261:         if lyx-core-lyx_core_lyx-core-lyx_core_client
264: 262:             .get(service.url("/").unwrap())
265: 263:             .timeout(ttl)
266: 264:             .send()
267: 265:             .await
268: 266:             .is_ok()
269: 267:         {
270: 268:             return service;
271: 269:         }
272: 270:         tokio::time::sleep(Duration::from_secs(1)).await;
273: 271:     }
274: 272:     panic!("The web lyx-platform-lyx_platform_lyx-platform-lyx_platform_server did not become ready within the expected time.");
275: 273: }
276: ```
```
