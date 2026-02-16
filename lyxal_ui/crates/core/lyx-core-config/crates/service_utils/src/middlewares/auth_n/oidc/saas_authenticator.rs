1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\saas_authenticator.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\saas_authenticator.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\saas_authenticator.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\saas_authenticator.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\saas_authenticator.rs
10: 8: ```rust
11: 9: use std::sync::Arc;
12: 10: 
13: 11: use actix_web::{
14: 12:     HttpRequest, HttpResponse,
15: 13:     cookie::{Cookie, time::Duration},
16: 14:     error::{ErrorBadRequest, ErrorInternalServerError},
17: 15:     http::header,
18: 16:     web::{self, Data, Json, get, resource},
19: 17: };
20: 18: use derive_more::{Deref, DerefMut};
21: 19: use futures_util::future::LocalBoxFuture;
22: 20: use openidconnect::{
23: 21:     self as oidcrs, ClientId, ClientSecret, IssuerUrl, RedirectUrl,
24: 22:     ResourceOwnerPassword, ResourceOwnerUsername, Scope, TokenResponse, TokenUrl,
25: 23:     core::{CoreClient, CoreProviderMetadata},
26: 24: };
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;
28: 26: 
29: 27: use crate::{
30: 28:     extensions::HttpRequestExt,
31: 29:     helpers::get_from_env_unsafe,
32: 30:     middlewares::auth_n::{
33: 31:         authentication::{Authenticator, Login},
34: 32:         oidc::{
35: 33:             OIDCAuthenticator,
36: 34:             types::{
37: 35:                 GlobalUserClaims, GlobalUserTokenResponse, OrgUserClaims,
38: 36:                 OrgUserTokenResponse,
39: 37:             },
40: 38:             utils::{presence_no_check, try_user_from, verify_presence},
41: 39:         },
42: 40:     },
43: 41: };
44: 42: 
45: 43: #[derive(Clone)]
46: 44: pub struct AuthenticatorInner {
47: 45:     lyx-core-lyx_core_lyx-core-lyx_core_client: CoreClient,
48: 46:     provider_metadata: CoreProviderMetadata,
49: 47:     lyx-core-lyx_core_lyx-core-lyx_core_client_id: String,
50: 48:     lyx-core-lyx_core_lyx-core-lyx_core_client_secret: String,
51: 49:     base_url: String,
52: 50:     path_prefix: String,
53: 51:     issuer_endpoint_format: String,
54: 52:     token_endpoint_format: String,
55: 53: }
56: 54: 
57: 55: /// An OIDC Authenticator implementation for SaaS setups
58: 56: /// where each organisation has its own OIDC provider endpoints
59: 57: /// First issuer also acts as a global identity provider which
60: 58: /// provides authorization to the individual orgs
61: 59: ///
62: 60: /// Env(s) needed for OIDC SaaS Authenticator:
63: 61: /// OIDC_CLIENT_ID, OIDC_CLIENT_SECRET, OIDC_REDIRECT_HOST - reused from Simple OIDC Authenticator
64: 62: /// OIDC_ORG_TOKEN_ENDPOINT_FORMAT, OIDC_ORG_ISSUER_ENDPOINT_FORMAT - new envs for SaaS setup
65: 63: #[derive(Deref, DerefMut, Clone)]
66: 64: pub struct SaasOIDCAuthenticator(Arc<AuthenticatorInner>);
67: 65: 
68: 66: impl SaasOIDCAuthenticator {
69: 67:     pub async fn new(
70: 68:         idp_url: String,
71: 69:         base_url: String,
72: 70:         path_prefix: String,
73: 71:         lyx-core-lyx_core_lyx-core-lyx_core_client_id: String,
74: 72:         lyx-core-lyx_core_lyx-core-lyx_core_client_secret: String,
75: 73:     ) -> Result<Self, Box<dyn std::error::Error>> {
76: 74:         let issuer_endpoint_format =
77: 75:             get_from_env_unsafe::<String>("OIDC_ORG_ISSUER_ENDPOINT_FORMAT").unwrap();
78: 76:         let token_endpoint_format =
79: 77:             get_from_env_unsafe::<String>("OIDC_ORG_TOKEN_ENDPOINT_FORMAT").unwrap();
80: 78: 
81: 79:         let issuer_url = IssuerUrl::new(idp_url)
82: 80:             .map_err(|e| format!("Unable to create issuer url: {}", e))
83: 81:             .unwrap();
84: 82: 
85: 83:         // Discover OpenID Provider metadata
86: 84:         let provider_metadata = CoreProviderMetadata::discover_async(
87: 85:             issuer_url,
88: 86:             oidcrs::reqwest::async_http_lyx-core-lyx_core_lyx-core-lyx_core_client,
89: 87:         )
90: 88:         .await?;
91: 89: 
92: 90:         // Create lyx-core-lyx_core_lyx-core-lyx_core_client
93: 91:         let lyx-core-lyx_core_lyx-core-lyx_core_client = CoreClient::from_provider_metadata(
94: 92:             provider_metadata.clone(),
95: 93:             ClientId::new(lyx-core-lyx_core_lyx-core-lyx_core_client_id.clone()),
96: 94:             Some(ClientSecret::new(lyx-core-lyx_core_lyx-core-lyx_core_client_secret.clone())),
97: 95:         )
98: 96:         .set_redirect_uri(RedirectUrl::new(format!(
99: 97:             "{base_url}{path_prefix}/oidc/login"
100: 98:         ))?);
101: 99: 
102: 100:         Ok(Self(Arc::new(AuthenticatorInner {
103: 101:             lyx-core-lyx_core_lyx-core-lyx_core_client,
104: 102:             provider_metadata,
105: 103:             lyx-core-lyx_core_lyx-core-lyx_core_client_id,
106: 104:             lyx-core-lyx_core_lyx-core-lyx_core_client_secret,
107: 105:             base_url,
108: 106:             path_prefix,
109: 107:             issuer_endpoint_format,
110: 108:             token_endpoint_format,
111: 109:         })))
112: 110:     }
113: 111: 
114: 112:     fn get_org_lyx-core-lyx_core_lyx-core-lyx_core_client(&self, org_id: &str) -> Result<CoreClient, String> {
115: 113:         let issuer_url = match self.get_issuer_url(org_id) {
116: 114:             Ok(issuer_url) => issuer_url,
117: 115:             Err(e) => return Err(format!("Unable to create issuer url: {e}")),
118: 116:         };
119: 117: 
120: 118:         let token_url = match self.get_token_url(org_id) {
121: 119:             Ok(token_url) => token_url,
122: 120:             Err(e) => return Err(format!("Unable to create token url: {e}")),
123: 121:         };
124: 122: 
125: 123:         let redirect_url = match RedirectUrl::new(format!(
126: 124:             "{}{}/",
127: 125:             self.base_url.clone(),
128: 126:             self.path_prefix
129: 127:         )) {
130: 128:             Ok(redirect_url) => redirect_url,
131: 129:             Err(e) => return Err(format!("Unable to create redirect url: {e}")),
132: 130:         };
133: 131: 
134: 132:         let provider = self
135: 133:             .provider_metadata
136: 134:             .clone()
137: 135:             .set_issuer(issuer_url)
138: 136:             .set_token_endpoint(Some(token_url));
139: 137: 
140: 138:         Ok(CoreClient::from_provider_metadata(
141: 139:             provider,
142: 140:             ClientId::new(self.lyx-core-lyx_core_lyx-core-lyx_core_client_id.clone()),
143: 141:             Some(ClientSecret::new(self.lyx-core-lyx_core_lyx-core-lyx_core_client_secret.clone())),
144: 142:         )
145: 143:         .set_redirect_uri(redirect_url))
146: 144:     }
147: 145: 
148: 146:     fn get_issuer_url(
149: 147:         &self,
150: 148:         organisation_id: &str,
151: 149:     ) -> Result<IssuerUrl, url::ParseError> {
152: 150:         let issuer_endpoint = self
153: 151:             .issuer_endpoint_format
154: 152:             .replace("<organisation>", organisation_id);
155: 153:         IssuerUrl::new(issuer_endpoint)
156: 154:     }
157: 155: 
158: 156:     fn get_token_url(&self, organisation_id: &str) -> Result<TokenUrl, url::ParseError> {
159: 157:         let token_endpoint = self
160: 158:             .token_endpoint_format
161: 159:             .replace("<organisation>", organisation_id);
162: 160:         TokenUrl::new(token_endpoint)
163: 161:     }
164: 162: 
165: 163:     fn decode_global_token(&self, cookie: &str) -> Result<GlobalUserClaims, String> {
166: 164:         let ctr = serde_json::from_str::<GlobalUserTokenResponse>(cookie)
167: 165:             .map_err(|e| format!("Error while decoding token: {e}"))?;
168: 166:         ctr.id_token()
169: 167:             .ok_or(String::from("Id Token not found"))?
170: 168:             .claims(&self.lyx-core-lyx_core_lyx-core-lyx_core_client.id_token_verifier(), verify_presence)
171: 169:             .map_err(|e| format!("Error in claims verification: {e}"))
172: 170:             .cloned()
173: 171:     }
174: 172: 
175: 173:     fn decode_org_token(
176: 174:         &self,
177: 175:         org_id: &str,
178: 176:         cookie: &str,
179: 177:     ) -> Result<OrgUserClaims, String> {
180: 178:         let lyx-core-lyx_core_lyx-core-lyx_core_client = self
181: 179:             .get_org_lyx-core-lyx_core_lyx-core-lyx_core_client(org_id)
182: 180:             .map_err(|e| format!("Error in getting Org specific lyx-core-lyx_core_lyx-core-lyx_core_client: {e}"))?;
183: 181:         let id_token_verifier = lyx-core-lyx_core_lyx-core-lyx_core_client.id_token_verifier();
184: 182: 
185: 183:         let ctr = serde_json::from_str::<OrgUserTokenResponse>(cookie)
186: 184:             .map_err(|e| format!("Error while decoding token: {e}"))?;
187: 185:         ctr.id_token()
188: 186:             .ok_or(String::from("Id Token not found"))?
189: 187:             .claims(&id_token_verifier, presence_no_check)
190: 188:             .map_err(|e| format!("Error in claims verification: {e}"))
191: 189:             .cloned()
192: 190:     }
193: 191: 
194: 192:     async fn get_org_user(
195: 193:         self,
196: 194:         request: HttpRequest,
197: 195:         login_type: Login,
198: 196:     ) -> Result<User, HttpResponse> {
199: 197:         let org_id = request.get_organisation_id().unwrap_or_default();
200: 198:         let token = request.cookie(&login_type.to_string()).and_then(|c| {
201: 199:             self.decode_org_token(&org_id, c.value())
202: 200:                 .map_err(|e| log::error!("Error in decoding org_user : {e}"))
203: 201:                 .ok()
204: 202:         });
205: 203:         if let Some(token_response) = token {
206: 204:             Ok(try_user_from(&token_response).map_err(|e| {
207: 205:                 log::error!("Unable to get org_user: {e}");
208: 206:                 ErrorBadRequest(String::from("Unable to get user"))
209: 207:             })?)
210: 208:         } else {
211: 209:             self.generate_org_user(&request, &org_id, &login_type)
212: 210:                 .await
213: 211:                 .and_then(|token| {
214: 212:                     let cookie = Cookie::build(login_type.to_string(), token)
215: 213:                         .path(self.get_cookie_path())
216: 214:                         .http_only(true)
217: 215:                         .secure(true)
218: 216:                         .max_age(Duration::days(1))
219: 217:                         .finish();
220: 218:                     Err(HttpResponse::Found()
221: 219:                         .cookie(cookie)
222: 220:                         .insert_header((header::LOCATION, request.path().to_string()))
223: 221:                         .finish())
224: 222:                 })
225: 223:         }
226: 224:     }
227: 225: }
228: 226: 
229: 227: impl OIDCAuthenticator for SaasOIDCAuthenticator {
230: 228:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client(&self) -> &CoreClient {
231: 229:         &self.lyx-core-lyx_core_lyx-core-lyx_core_client
232: 230:     }
233: 231: 
234: 232:     fn get_global_user(
235: 233:         &self,
236: 234:         request: &HttpRequest,
237: 235:         path: String,
238: 236:     ) -> Result<User, HttpResponse> {
239: 237:         let token = request.cookie(&Login::Global.to_string()).and_then(|c| {
240: 238:             self.decode_global_token(c.value())
241: 239:                 .map_err(|e| log::error!("Error in decoding user : {e}"))
242: 240:                 .ok()
243: 241:         });
244: 242:         if let Some(token_response) = token {
245: 243:             Ok(try_user_from(&token_response).map_err(|e| {
246: 244:                 log::error!("Unable to get user: {e}");
247: 245:                 ErrorBadRequest(String::from("Unable to get user"))
248: 246:             })?)
249: 247:         } else {
250: 248:             log::error!("Error user not found in cookies");
251: 249:             Err(self.new_redirect(&Login::Global, path))
252: 250:         }
253: 251:     }
254: 252: }
255: 253: 
256: 254: impl Authenticator for SaasOIDCAuthenticator {
257: 255:     fn get_path_prefix(&self) -> String {
258: 256:         self.path_prefix.clone()
259: 257:     }
260: 258: 
261: 259:     fn authenticate(
262: 260:         &self,
263: 261:         request: &HttpRequest,
264: 262:         login_type: &Login,
265: 263:     ) -> LocalBoxFuture<'static, Result<User, HttpResponse>> {
266: 264:         let auth_n = self.clone();
267: 265:         match login_type {
268: 266:             Login::None => Box::pin(async { Ok(User::default()) }),
269: 267:             Login::Global => {
270: 268:                 let resp = auth_n.get_global_user(
271: 269:                     request,
272: 270:                     format!("{}/admin/organisations", self.path_prefix),
273: 271:                 );
274: 272:                 Box::pin(async { resp })
275: 273:             }
276: 274:             Login::Org(_) => {
277: 275:                 match auth_n.get_global_user(request, request.path().to_string()) {
278: 276:                     Err(e) => Box::pin(async { Err(e) }),
279: 277:                     Ok(_) => {
280: 278:                         let fut =
281: 279:                             auth_n.get_org_user(request.clone(), login_type.clone());
282: 280:                         Box::pin(fut)
283: 281:                     }
284: 282:                 }
285: 283:             }
286: 284:         }
287: 285:     }
288: 286: 
289: 287:     fn routes(&self) -> actix_web::Scope {
290: 288:         web::scope("oidc")
291: 289:             .lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_data(Data::new(self.to_owned()))
292: 290:             .service(resource("login").route(get().to(Self::login)))
293: 291:     }
294: 292: 
295: 293:     fn get_organisations(&self, req: &HttpRequest) -> HttpResponse {
296: 294:         let organisations = req
297: 295:             .cookie(&Login::Global.to_string())
298: 296:             .and_then(|user_cookie| {
299: 297:                 self.decode_global_token(user_cookie.value())
300: 298:                     .map_err(|e| log::error!("Error in decoding user : {e}"))
301: 299:                     .ok()
302: 300:             })
303: 301:             .map(|claims| claims.additional_claims().organisations.clone());
304: 302: 
305: 303:         match organisations {
306: 304:             Some(organisations) => HttpResponse::Ok().json(Json(organisations)),
307: 305:             None => self.new_redirect(
308: 306:                 &Login::Global,
309: 307:                 format!("{}/admin/organisations", self.path_prefix),
310: 308:             ),
311: 309:         }
312: 310:     }
313: 311: 
314: 312:     fn generate_org_user(
315: 313:         &self,
316: 314:         req: &HttpRequest,
317: 315:         org_id: &str,
318: 316:         login_type: &Login,
319: 317:     ) -> LocalBoxFuture<'_, Result<String, HttpResponse>> {
320: 318:         let lyx-core-lyx_core_lyx-core-lyx_core_client = match self.get_org_lyx-core-lyx_core_lyx-core-lyx_core_client(org_id) {
321: 319:             Ok(lyx-core-lyx_core_lyx-core-lyx_core_client) => lyx-core-lyx_core_lyx-core-lyx_core_client,
322: 320:             Err(e) => {
323: 321:                 log::error!("Error in getting Org specific lyx-core-lyx_core_lyx-core-lyx_core_client: {e}");
324: 322:                 return Box::pin(async {
325: 323:                     Err(ErrorInternalServerError(String::from(
326: 324:                         "Error in getting Org specific lyx-core-lyx_core_lyx-core-lyx_core_client",
327: 325:                     ))
328: 326:                     .into())
329: 327:                 });
330: 328:             }
331: 329:         };
332: 330: 
333: 331:         let user = req
334: 332:             .cookie(&Login::Global.to_string())
335: 333:             .and_then(|user_cookie| {
336: 334:                 self.decode_global_token(user_cookie.value())
337: 335:                     .map_err(|e| log::error!("Error in decoding user : {e}"))
338: 336:                     .ok()
339: 337:             })
340: 338:             .map(|claims| {
341: 339:                 (
342: 340:                     claims.preferred_username().cloned(),
343: 341:                     claims.additional_claims().switch_pass.clone(),
344: 342:                 )
345: 343:             });
346: 344:         let (username, switch_pass) = if let Some(user) = user {
347: 345:             user
348: 346:         } else {
349: 347:             return Box::pin(async { Err(ErrorBadRequest("Cookie incorrect").into()) });
350: 348:         };
351: 349: 
352: 350:         let username = if let Some(u) = username {
353: 351:             u
354: 352:         } else {
355: 353:             return Box::pin(async { Err(ErrorBadRequest("Username not found").into()) });
356: 354:         };
357: 355: 
358: 356:         let user = ResourceOwnerUsername::new(username.to_string());
359: 357:         let pass = ResourceOwnerPassword::new(switch_pass);
360: 358:         let redirect = self.new_redirect(
361: 359:             login_type,
362: 360:             format!("{}/admin/organisations", self.path_prefix),
363: 361:         );
364: 362: 
365: 363:         Box::pin(async move {
366: 364:             lyx-core-lyx_core_lyx-core-lyx_core_client
367: 365:                 .exchange_password(&user, &pass)
368: 366:                 .add_scope(Scope::new(String::from("openid")))
369: 367:                 .request_async(oidcrs::reqwest::async_http_lyx-core-lyx_core_lyx-core-lyx_core_client)
370: 368:                 .await
371: 369:                 .map_err(|e| {
372: 370:                     log::error!("Failed to switch organisation for token: {e}");
373: 371:                     Some(ErrorInternalServerError(
374: 372:                         "Failed to switch organisation for token".to_string(),
375: 373:                     ))
376: 374:                 })
377: 375:                 .and_then(|tr| {
378: 376:                     tr.id_token()
379: 377:                         .ok_or_else(|| {
380: 378:                             log::error!("No identity-token!");
381: 379:                             None
382: 380:                         })?
383: 381:                         .claims(&lyx-core-lyx_core_lyx-core-lyx_core_client.id_token_verifier(), presence_no_check)
384: 382:                         .map_err(|e| {
385: 383:                             log::error!("Couldn't verify claims: {e}");
386: 384:                             None
387: 385:                         })?;
388: 386: 
389: 387:                     serde_json::to_string(&tr).map_err(|e| {
390: 388:                         log::error!("Unable to stringify data: {e}");
391: 389:                         Some(ErrorInternalServerError(
392: 390:                             "Unable to stringify data".to_string(),
393: 391:                         ))
394: 392:                     })
395: 393:                 })
396: 394:                 .map_err(|e| e.map(Into::into).unwrap_or(redirect))
397: 395:         })
398: 396:     }
399: 397: }
400: 398: ```
401: 399: ```
402: 400: ```
403: 401: ```
404: ```
```

