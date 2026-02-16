1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\main.rs
10: 8: ```rust
11: 9: #![deny(unused_crate_dependencies)]
12: 10: mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state;
13: 11: mod log_span;
14: 12: mod organisation;
15: 13: mod resolve;
16: 14: mod webhooks;
17: 15: mod workspace;
18: 16: use json_subscriber::fmt;
19: 17: use std::{io::Result, time::Duration};
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::bad_argument;
21: 19: 
22: 20: use actix_files::Files;
23: 21: use actix_web::{
24: 22:     App, HttpRequest, HttpResponse, HttpServer,
25: 23:     middleware::{Compress, Condition},
26: 24:     web::{self, Data, PathConfig, QueryConfig, get, scope},
27: 25: };
28: 26: use lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config::api::*;
29: 27: use lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform::api::*;
30: 28: use lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
31: 29: use lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend::types::{Envs as UIEnvs, SsrSharedHttpRequestHeaders};
32: 30: use idgenerator::{IdGeneratorOptions, IdInstance};
33: 31: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
34: 32: use lyx-core-actix::{LeptosRoutes, generate_route_list};
35: 33: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
36: 34:     aws::kms,
37: 35:     helpers::{get_from_env_or_default, get_from_env_unsafe},
38: 36:     middlewares::{
39: 37:         auth_n::AuthNHandler,
40: 38:         auth_z::{AuthZHandler, AuthZManager},
41: 39:         request_response_logging::RequestResponseLogger,
42: 40:         workspace_context::OrgWorkspaceMiddlewareFactory,
43: 41:     },
44: 42:     service::types::{AppEnv, Resource},
45: 43: };
46: 44: use tracing_actix_web::TracingLogger;
47: 45: use tracing_subscriber::{EnvFilter, layer::SubscriberExt, util::SubscriberInitExt};
48: 46: 
49: 47: use crate::log_span::CustomRootSpanBuilder;
50: 48: 
51: 49: pub fn use_request_headers() -> Option<SsrSharedHttpRequestHeaders> {
52: 50:     use_context::<HttpRequest>().map(|req| {
53: 51:         let headers = req.headers();
54: 52:         let cookie = headers
55: 53:             .get("Cookie")
56: 54:             .and_then(|h| h.to_str().ok().map(String::from));
57: 55: 
58: 56:         SsrSharedHttpRequestHeaders { cookie }
59: 57:     })
60: 58: }
61: 59: 
62: 60: #[actix_web::get("favicon.ico")]
63: 61: async fn favicon(
64: 62:     lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: actix_web::web::Data<lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions>,
65: 63: ) -> actix_web::Result<actix_files::NamedFile> {
66: 64:     let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.into_inner();
67: 65:     let site_root = &lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_root;
68: 66:     Ok(actix_files::NamedFile::open(format!(
69: 67:         "{site_root}/favicon.ico"
70: 68:     ))?)
71: 69: }
72: 70: 
73: 71: #[actix_web::main]
74: 72: async fn main() -> Result<()> {
75: 73:     dotenv::dotenv().ok();
76: 74:     // Initialize tracing subscriber with custom JSON formatter
77: 75:     tracing_subscriber::registry()
78: 76:         .with(EnvFilter::from_default_env())
79: 77:         .with(
80: 78:             fmt::layer()
81: 79:                 .with_current_span(true)
82: 80:                 .flatten_current_span_on_top_level(true)
83: 81:                 .flatten_event(true)
84: 82:                 .with_span_list(false)
85: 83:                 .with_target(false),
86: 84:         )
87: 85:         .init();
88: 86: 
89: 87:     let service_prefix: String =
90: 88:         get_from_env_unsafe("SERVICE_PREFIX").expect("SERVICE_PREFIX is not set");
91: 89: 
92: 90:     let worker_id: u32 = get_from_env_unsafe("WORKER_ID").expect("WORKER_ID is not set");
93: 91: 
94: 92:     let options = IdGeneratorOptions::new()
95: 93:         .worker_id(worker_id)
96: 94:         .worker_id_bit_len(8)
97: 95:         .seq_bit_len(12);
98: 96: 
99: 97:     IdInstance::init(options).expect("Failed to initialize ID generator");
100: 98: 
101: 99:     /*
102: 100:         Reading from a env returns a String at best we cannot obtain a &'static str from it,
103: 101:         which seems logical as it not known at compiletime, and there is no straightforward way to do this.
104: 102: 
105: 103:         Leptos' Router component base prop type is &'static str, since service_prefix is of String type
106: 104:         we cannot give this as base value.
107: 105: 
108: 106:         This can be solved, if somehow we can tell rust that this String is going to live for entirety of the process,
109: 107:         here comes Box::leak() to our rescue, which keeps the value in the memory for the entire process lifetime,
110: 108:         this also enables to borrow the String value as &'static str .
111: 109:     */
112: 110:     let service_prefix_str: &'static str = Box::leak(service_prefix.into_boxed_str());
113: 111:     let base = match service_prefix_str {
114: 112:         "" | "/" => "".to_owned(),
115: 113:         prefix => "/".to_owned() + prefix,
116: 114:     };
117: 115: 
118: 116:     let cac_port: u16 = get_from_env_unsafe("PORT").unwrap_or(8080);
119: 117: 
120: 118:     /* Frontend configurations */
121: 119:     let ui_redirect_path = format!("{}/admin/organisations", base);
122: 120: 
123: 121:     let ui_envs = UIEnvs {
124: 122:         service_prefix: service_prefix_str,
125: 123:         host: get_from_env_or_default("API_HOSTNAME", String::new()),
126: 124:     };
127: 125: 
128: 126:     let routes_ui_envs = ui_envs.clone();
129: 127: 
130: 128:     let conf = get_configuration(Some("Cargo.toml")).await.unwrap();
131: 129:     // Generate the list of routes in your Leptos App
132: 130:     let routes = generate_route_list(move || {
133: 131:         view! { <App lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_envs=routes_ui_envs.clone() /> }
134: 132:     });
135: 133: 
136: 134:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env = get_from_env_unsafe("APP_ENV").expect("APP_ENV is not set");
137: 135:     let kms_lyx-core-lyx_core_lyx-core-lyx_core_client = match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
138: 136:         AppEnv::DEV | AppEnv::TEST => None,
139: 137:         _ => Some(kms::new_lyx-core-lyx_core_lyx-core-lyx_core_client().await),
140: 138:     };
141: 139: 
142: 140:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = Data::new(
143: 141:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state::get(
144: 142:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env,
145: 143:             cac_port,
146: 144:             &kms_lyx-core-lyx_core_lyx-core-lyx_core_client,
147: 145:             service_prefix_str.to_owned(),
148: 146:             &base,
149: 147:         )
150: 148:         .await,
151: 149:     );
152: 150: 
153: 151:     let auth_n = AuthNHandler::init(&kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env, base.clone()).await;
154: 152:     let auth_z = AuthZHandler::init(&kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env).await;
155: 153:     let auth_z_manager = AuthZManager::init(&kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env).await;
156: 154: 
157: 155:     HttpServer::new(move || {
158: 156:         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = &conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
159: 157:         let site_root = &lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_root;
160: 158:         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_envs = ui_envs.clone();
161: 159:         App::new()
162: 160:             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.clone())
163: 161:             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(PathConfig::default().error_handler(|err, _| bad_argument!(err).into()))
164: 162:             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(QueryConfig::default().error_handler(|err, _| bad_argument!(err).into()))
165: 163:             .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(
166: 164:                 lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.to_owned(),
167: 165:                 routes.to_owned(),
168: 166:                 move || {
169: 167:                     provide_context(use_request_headers());
170: 168:                     view! { <App lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_envs=lyx-core-lyx_core_lyx-core-lyx_core_leptos_envs.clone() /> }
171: 169:                 },
172: 170:             )
173: 171:             .service(
174: 172:                 scope(&base)
175: 173:                     .route(
176: 174:                         "/health",
177: 175:                         get().to(|| async { HttpResponse::Ok().body("Health is good :D") }),
178: 176:                     )
179: 177:                     .service(auth_n.routes())
180: 178:                     .service(auth_n.org_routes())
181: 179:                     .service(web::redirect("", ui_redirect_path.to_string()))
182: 180:                     .service(web::redirect("/", ui_redirect_path.to_string()))
183: 181:                     .service(web::redirect("/admin", ui_redirect_path.to_string()))
184: 182:                     .service(web::redirect("/admin/", ui_redirect_path.to_string()))
185: 183:                     .service(web::redirect("/admin/{org_id}/", "workspaces"))
186: 184:                     .service(web::redirect("/admin/{org_id}/{tenant}/", "default-config"))
187: 185:                     /***************************** V1 Routes *****************************/
188: 186:                     .service(
189: 187:                         scope("/context")
190: 188:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Context)
191: 189:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
192: 190:                             .service(context::endpoints()),
193: 191:                     )
194: 192:                     .service(
195: 193:                         scope("/dimension")
196: 194:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Dimension)
197: 195:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
198: 196:                             .service(dimension::endpoints()),
199: 197:                     )
200: 198:                     .service(
201: 199:                         scope("/default-config")
202: 200:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::DefaultConfig)
203: 201:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
204: 202:                             .service(default_config::endpoints()),
205: 203:                     )
206: 204:                     .service(
207: 205:                         scope("/config")
208: 206:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Config)
209: 207:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
210: 208:                             .service(config::endpoints()),
211: 209:                     )
212: 210:                     .service(
213: 211:                         scope("/audit")
214: 212:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::AuditLog)
215: 213:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
216: 214:                             .service(audit_log::endpoints()),
217: 215:                     )
218: 216:                     .service(
219: 217:                         scope("/function")
220: 218:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Function)
221: 219:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
222: 220:                             .service(functions::endpoints()),
223: 221:                     )
224: 222:                     .service(
225: 223:                         scope("/types")
226: 224:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::TypeTemplate)
227: 225:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
228: 226:                             .service(type_templates::endpoints()),
229: 227:                     )
230: 228:                     .service(
231: 229:                         experiments::endpoints(scope("/experiments"))
232: 230:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Experiment)
233: 231:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true)),
234: 232:                     )
235: 233:                     .service(
236: 234:                         experiment_groups::endpoints(scope("/experiment-groups"))
237: 235:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::ExperimentGroup)
238: 236:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
239: 237:                     )
240: 238:                     .service(
241: 239:                         scope("/lyx-core-lyx_core_lyx-core-lyx_core_superposition/organisations")
242: 240:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Organisation)
243: 241:                             .wrap(OrgWorkspaceMiddlewareFactory::new(false, false))
244: 242:                             .service(organisation::endpoints()),
245: 243:                     )
246: 244:                     .service(workspace::endpoints(scope("/workspaces"))
247: 245:                         .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Workspace)
248: 246:                         .wrap(OrgWorkspaceMiddlewareFactory::new(true, false))
249: 247:                     )
250: 248:                     .service(
251: 249:                         scope("/webhook")
252: 250:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Webhook)
253: 251:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
254: 252:                             .service(webhooks::endpoints()),
255: 253:                     )
256: 254:                     .service(
257: 255:                         scope("/variables")
258: 256:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Variable)
259: 257:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
260: 258:                             .service(variables::endpoints())
261: 259:                     )
262: 260:                     .service(
263: 261:                         scope("/resolve")
264: 262:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Config)
265: 263:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
266: 264:                             .service(resolve::endpoints()),
267: 265:                     )
268: 266:                     .service(
269: 267:                         scope("/auth")
270: 268:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Auth)
271: 269:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
272: 270:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Data::new(auth_z_manager.clone()))
273: 271:                             .service(auth_z_manager.endpoints())
274: 272:                     )
275: 273:                     .service(
276: 274:                         scope("/master-encryption-key")
277: 275:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::MasterEncryptionKey)
278: 276:                             .wrap(OrgWorkspaceMiddlewareFactory::new(false, false))
279: 277:                             .service(secrets::master_key_endpoints())
280: 278:                     )
281: 279:                     .service(
282: 280:                         scope("/secrets")
283: 281:                             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Resource::Secret)
284: 282:                             .wrap(OrgWorkspaceMiddlewareFactory::new(true, true))
285: 283:                             .service(secrets::endpoints())
286: 284:                     )
287: 285:                     /***************************** UI Routes ******************************/
288: 286:                     .route("/fxn/{tail:.*}", lyx-core-actix::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns())
289: 287:                     // serve JS/WASM/CSS from `pkg`
290: 288:                     .service(Files::new("/pkg", format!("{site_root}/pkg")))
291: 289:                     // serve other assets from the `assets` directory
292: 290:                     .service(Files::new("/assets", site_root.to_string()))
293: 291:                     // serve the favicon from /favicon.ico
294: 292:             )
295: 293:             .route(
296: 294:                 "/health",
297: 295:                 get().to(|| async { HttpResponse::Ok().body("Health is good :D") }),
298: 296:             )
299: 297:             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Data::new(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.to_owned()))
300: 298:             // Auth middlewares are innermost so outer middlewares still run on auth failures.
301: 299:             // Note: in actix-web, the last `.wrap()` runs first on requests.
302: 300:             .wrap(auth_z.clone())
303: 301:             .wrap(auth_n.clone())
304: 302:             .wrap(
305: 303:                 actix_web::middleware::DefaultHeaders::new()
306: 304:                     .add(("X-SERVER-VERSION", lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.cac_version.to_string()))
307: 305:                     .add(("Cache-Control", "no-store".to_string()))
308: 306:             )
309: 307:             .wrap(Condition::new(
310: 308:                 matches!(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env, AppEnv::PROD | AppEnv::SANDBOX),
311: 309:                 Compress::default(),
312: 310:             ))
313: 311:             // Conditionally add request/response logging middleware for development
314: 312:             .wrap(RequestResponseLogger)
315: 313:             .wrap(TracingLogger::<CustomRootSpanBuilder>::new())
316: 314:     })
317: 315:     .bind(("0.0.0.0", cac_port))?
318: 316:     .workers(get_from_env_or_default("ACTIX_WORKER_COUNT", 5))
319: 317:     .keep_alive(Duration::from_secs(
320: 318:         get_from_env_unsafe("ACTIX_KEEP_ALIVE").unwrap_or(120),
321: 319:     ))
322: 320:     .run()
323: 321:     .await
324: 322: }
325: 323: ```
326: 324: ```
327: 325: ```
328: 326: ```
329: ```
```

