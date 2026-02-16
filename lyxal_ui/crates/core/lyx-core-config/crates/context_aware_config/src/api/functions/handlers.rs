1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     HttpResponse, Result, Scope, delete, get, patch, post,
13: 11:     web::{Data, Json, Path},
14: 12: };
15: 13: use chrono::Utc;
16: 14: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{AppState, DbConnection, WorkspaceContext};
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, not_found, unexpected_error};
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
21: 19:     PaginatedResponse, User,
22: 20:     api::functions::{
23: 21:         CreateFunctionRequest, FunctionExecutionRequest, FunctionExecutionResponse,
24: 22:         FunctionName, FunctionStateChangeRequest, ListFunctionFilters, Stage, TestParam,
25: 23:         UpdateFunctionRequest,
26: 24:     },
27: 25:     custom_query::{self as lyx-core-lyx_core_lyx-core-lyx_core_superposition_query, PaginationParams},
28: 26:     database::{
29: 27:         models::cac::{Function, FunctionType},
30: 28:         schema::{self, functions::dsl as functions},
31: 29:     },
32: 30:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
33: 31: };
34: 32: 
35: 33: use crate::{
36: 34:     helpers::validate_change_reason,
37: 35:     validation_functions::{compile_fn, execute_fn},
38: 36: };
39: 37: 
40: 38: use super::helpers::fetch_function;
41: 39: 
42: 40: pub fn endpoints() -> Scope {
43: 41:     Scope::new("")
44: 42:         .service(create_handler)
45: 43:         .service(update_handler)
46: 44:         .service(get_handler)
47: 45:         .service(list_handler)
48: 46:         .service(delete_handler)
49: 47:         .service(test_handler)
50: 48:         .service(publish_handler)
51: 49: }
52: 50: 
53: 51: #[authorized]
54: 52: #[post("")]
55: 53: async fn create_handler(
56: 54:     workspace_context: WorkspaceContext,
57: 55:     request: Json<CreateFunctionRequest>,
58: 56:     db_conn: DbConnection,
59: 57:     user: User,
60: 58:     state: Data<AppState>,
61: 59: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Function>> {
62: 60:     let DbConnection(mut conn) = db_conn;
63: 61:     let req = request.into_inner();
64: 62: 
65: 63:     if req.function_type == FunctionType::ContextValidation
66: 64:         || req.function_type == FunctionType::ChangeReasonValidation
67: 65:     {
68: 66:         log::error!(
69: 67:             "Attempted to create reserved function type: {:?}",
70: 68:             req.function_type
71: 69:         );
72: 70:         return Err(bad_argument!(
73: 71:             "Cannot create function of type {:?}: This function type is reserved and cannot be created manually.",
74: 72:             req.function_type
75: 73:         ));
76: 74:     }
77: 75: 
78: 76:     validate_change_reason(
79: 77:         &workspace_context,
80: 78:         &req.change_reason,
81: 79:         &mut conn,
82: 80:         &state.master_encryption_key,
83: 81:     )?;
84: 82: 
85: 83:     compile_fn(&req.function)?;
86: 84: 
87: 85:     let now = Utc::now();
88: 86:     let function = Function {
89: 87:         function_name: req.function_name.into(),
90: 88:         draft_code: (req.function),
91: 89:         draft_runtime_version: req.runtime_version,
92: 90:         draft_edited_by: user.get_email(),
93: 91:         draft_edited_at: now,
94: 92:         published_code: None,
95: 93:         published_at: None,
96: 94:         published_by: None,
97: 95:         published_runtime_version: None,
98: 96:         description: req.description,
99: 97:         last_modified_at: now,
100: 98:         last_modified_by: user.get_email(),
101: 99:         change_reason: req.change_reason,
102: 100:         function_type: req.function_type,
103: 101:         created_at: now,
104: 102:         created_by: user.get_email(),
105: 103:     };
106: 104: 
107: 105:     let insert: Result<Function, diesel::result::Error> =
108: 106:         diesel::insert_into(functions::functions)
109: 107:             .values(&function)
110: 108:             .returning(Function::as_returning())
111: 109:             .schema_name(&workspace_context.schema_name)
112: 110:             .get_result(&mut conn);
113: 111: 
114: 112:     match insert {
115: 113:         Ok(res) => Ok(Json(res)),
116: 114:         Err(e) => match e {
117: 115:             diesel::result::Error::DatabaseError(kind, e) => {
118: 116:                 log::error!("Function error: {:?}", e);
119: 117:                 match kind {
120: 118:                     diesel::result::DatabaseErrorKind::UniqueViolation => {
121: 119:                         Err(bad_argument!("Function already exists."))
122: 120:                     }
123: 121:                     _ => Err(unexpected_error!(
124: 122:                         "Something went wrong, failed to create function"
125: 123:                     )),
126: 124:                 }
127: 125:             }
128: 126:             _ => {
129: 127:                 log::error!("Function creation failed with error: {e}");
130: 128:                 Err(unexpected_error!(
131: 129:                     "An error occured please contact the admin."
132: 130:                 ))
133: 131:             }
134: 132:         },
135: 133:     }
136: 134: }
137: 135: 
138: 136: #[authorized]
139: 137: #[patch("/{function_name}")]
140: 138: async fn update_handler(
141: 139:     workspace_context: WorkspaceContext,
142: 140:     params: Path<FunctionName>,
143: 141:     request: Json<UpdateFunctionRequest>,
144: 142:     db_conn: DbConnection,
145: 143:     user: User,
146: 144:     state: Data<AppState>,
147: 145: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Function>> {
148: 146:     let DbConnection(mut conn) = db_conn;
149: 147:     let req = request.into_inner();
150: 148:     let f_name: String = params.into_inner().into();
151: 149: 
152: 150:     // Function Linter Check
153: 151:     if let Some(function) = &req.draft_code {
154: 152:         compile_fn(function)?;
155: 153:     }
156: 154: 
157: 155:     validate_change_reason(
158: 156:         &workspace_context,
159: 157:         &req.change_reason,
160: 158:         &mut conn,
161: 159:         &state.master_encryption_key,
162: 160:     )?;
163: 161: 
164: 162:     let updated_function = diesel::update(functions::functions)
165: 163:         .filter(schema::functions::function_name.eq(f_name))
166: 164:         .set((
167: 165:             req,
168: 166:             functions::draft_edited_by.eq(user.get_email()),
169: 167:             functions::draft_edited_at.eq(Utc::now()),
170: 168:             functions::last_modified_by.eq(user.get_email()),
171: 169:             functions::last_modified_at.eq(Utc::now()),
172: 170:         ))
173: 171:         .returning(Function::as_returning())
174: 172:         .schema_name(&workspace_context.schema_name)
175: 173:         .get_result::<Function>(&mut conn)?;
176: 174: 
177: 175:     Ok(Json(updated_function))
178: 176: }
179: 177: 
180: 178: #[authorized]
181: 179: #[get("/{function_name}")]
182: 180: async fn get_handler(
183: 181:     workspace_context: WorkspaceContext,
184: 182:     params: Path<FunctionName>,
185: 183:     db_conn: DbConnection,
186: 184: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Function>> {
187: 185:     let DbConnection(mut conn) = db_conn;
188: 186:     let f_name: String = params.into_inner().into();
189: 187:     let function = fetch_function(&f_name, &mut conn, &workspace_context.schema_name)?;
190: 188: 
191: 189:     Ok(Json(function))
192: 190: }
193: 191: 
194: 192: #[authorized]
195: 193: #[get("")]
196: 194: async fn list_handler(
197: 195:     workspace_context: WorkspaceContext,
198: 196:     db_conn: DbConnection,
199: 197:     pagination: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<PaginationParams>,
200: 198:     filters: lyx-core-lyx_core_lyx-core-lyx_core_superposition_query::Query<ListFunctionFilters>,
201: 199: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<Function>>> {
202: 200:     let DbConnection(mut conn) = db_conn;
203: 201:     let query_builder = |f: &ListFunctionFilters| {
204: 202:         let mut builder = functions::functions
205: 203:             .schema_name(&workspace_context.schema_name)
206: 204:             .into_boxed();
207: 205:         if let Some(ref fntype) = f.function_type {
208: 206:             builder = builder.filter(functions::function_type.eq_any(fntype.0.clone()));
209: 207:         }
210: 208:         builder
211: 209:     };
212: 210:     if let Some(true) = pagination.all {
213: 211:         let result: Vec<Function> = query_builder(&filters).get_results(&mut conn)?;
214: 212:         return Ok(Json(PaginatedResponse::all(result)));
215: 213:     }
216: 214:     let n_functions: i64 = query_builder(&filters).count().get_result(&mut conn)?;
217: 215:     let limit = pagination.count.unwrap_or(10);
218: 216:     let offset = (pagination.page.unwrap_or(1) - 1) * limit;
219: 217:     let data: Vec<Function> = query_builder(&filters)
220: 218:         .order(functions::last_modified_at.desc())
221: 219:         .limit(limit)
222: 220:         .offset(offset)
223: 221:         .load(&mut conn)?;
224: 222:     let total_pages = (n_functions as f64 / limit as f64).ceil() as i64;
225: 223:     Ok(Json(PaginatedResponse {
226: 224:         total_pages,
227: 225:         total_items: n_functions,
228: 226:         data,
229: 227:     }))
230: 228: }
231: 229: 
232: 230: #[authorized]
233: 231: #[delete("/{function_name}")]
234: 232: async fn delete_handler(
235: 233:     workspace_context: WorkspaceContext,
236: 234:     params: Path<FunctionName>,
237: 235:     db_conn: DbConnection,
238: 236:     user: User,
239: 237: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
240: 238:     let DbConnection(mut conn) = db_conn;
241: 239:     let f_name: String = params.into_inner().into();
242: 240: 
243: 241:     let function = fetch_function(&f_name, &mut conn, &workspace_context.schema_name)?;
244: 242:     match function.function_type {
245: 243:         FunctionType::ContextValidation | FunctionType::ChangeReasonValidation => {
246: 244:             return Err(bad_argument!(
247: 245:                 "Cannot delete function of type {:?}: This function type is reserved and cannot be deleted.",
248: 246:                 function.function_type
249: 247:             ));
250: 248:         }
251: 249:         _ => {}
252: 250:     }
253: 251: 
254: 252:     diesel::update(functions::functions)
255: 253:         .filter(functions::function_name.eq(&f_name))
256: 254:         .set((
257: 255:             functions::last_modified_at.eq(Utc::now()),
258: 256:             functions::last_modified_by.eq(user.get_email()),
259: 257:         ))
260: 258:         .returning(Function::as_returning())
261: 259:         .schema_name(&workspace_context.schema_name)
262: 260:         .execute(&mut conn)?;
263: 261:     let deleted_row =
264: 262:         diesel::delete(functions::functions.filter(functions::function_name.eq(&f_name)))
265: 263:             .schema_name(&workspace_context.schema_name)
266: 264:             .execute(&mut conn)?;
267: 265:     match deleted_row {
268: 266:         0 => Err(not_found!("Function {} doesn't exists", f_name)),
269: 267:         _ => {
270: 268:             log::info!("{f_name} function deleted by {}", user.get_email());
271: 269:             Ok(HttpResponse::NoContent().finish())
272: 270:         }
273: 271:     }
274: 272: }
275: 273: 
276: 274: #[authorized]
277: 275: #[post("/{function_name}/{stage}/test")]
278: 276: async fn test_handler(
279: 277:     workspace_context: WorkspaceContext,
280: 278:     params: Path<TestParam>,
281: 279:     request: Json<FunctionExecutionRequest>,
282: 280:     db_conn: DbConnection,
283: 281:     state: Data<AppState>,
284: 282: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<FunctionExecutionResponse>> {
285: 283:     let DbConnection(mut conn) = db_conn;
286: 284:     let path_params = params.into_inner();
287: 285:     let fun_name: &String = &path_params.function_name.into();
288: 286:     let req = request.into_inner();
289: 287:     let function = fetch_function(fun_name, &mut conn, &workspace_context.schema_name)?;
290: 288: 
291: 289:     let (code, version) = match path_params.stage {
292: 290:         Stage::Draft => (function.draft_code, function.draft_runtime_version),
293: 291:         Stage::Published => {
294: 292:             match (function.published_code, function.published_runtime_version) {
295: 293:                 (Some(code), Some(version)) => (code, version),
296: 294:                 _ => {
297: 295:                     return Err(bad_argument!(
298: 296:                         "Function test failed as function not published yet"
299: 297:                     ));
300: 298:                 }
301: 299:             }
302: 300:         }
303: 301:     };
304: 302: 
305: 303:     let result = execute_fn(
306: 304:         &workspace_context,
307: 305:         &code,
308: 306:         &req,
309: 307:         version,
310: 308:         &mut conn,
311: 309:         &state.master_encryption_key,
312: 310:     )
313: 311:     .map_err(|(e, stdout)| {
314: 312:         bad_argument!(
315: 313:             "Function failed with error: {}, stdout: {:?}",
316: 314:             e,
317: 315:             stdout.unwrap_or_default()
318: 316:         )
319: 317:     })?;
320: 318: 
321: 319:     Ok(Json(result))
322: 320: }
323: 321: 
324: 322: #[authorized]
325: 323: #[patch("/{function_name}/publish")]
326: 324: async fn publish_handler(
327: 325:     workspace_context: WorkspaceContext,
328: 326:     params: Path<FunctionName>,
329: 327:     request: Json<FunctionStateChangeRequest>,
330: 328:     db_conn: DbConnection,
331: 329:     user: User,
332: 330:     state: Data<AppState>,
333: 331: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Function>> {
334: 332:     let DbConnection(mut conn) = db_conn;
335: 333:     let fun_name: String = params.into_inner().into();
336: 334:     let function = fetch_function(&fun_name, &mut conn, &workspace_context.schema_name)?;
337: 335:     let req = request.into_inner();
338: 336: 
339: 337:     validate_change_reason(
340: 338:         &workspace_context,
341: 339:         &req.change_reason,
342: 340:         &mut conn,
343: 341:         &state.master_encryption_key,
344: 342:     )?;
345: 343: 
346: 344:     let updated_function = diesel::update(functions::functions)
347: 345:         .filter(functions::function_name.eq(fun_name.clone()))
348: 346:         .set((
349: 347:             req,
350: 348:             functions::published_code.eq(Some(function.draft_code.clone())),
351: 349:             functions::published_runtime_version.eq(Some(function.draft_runtime_version)),
352: 350:             functions::published_by.eq(Some(user.get_email())),
353: 351:             functions::published_at.eq(Some(Utc::now())),
354: 352:             functions::last_modified_by.eq(user.get_email()),
355: 353:             functions::last_modified_at.eq(Utc::now()),
356: 354:         ))
357: 355:         .returning(Function::as_returning())
358: 356:         .schema_name(&workspace_context.schema_name)
359: 357:         .get_result::<Function>(&mut conn)?;
360: 358: 
361: 359:     Ok(Json(updated_function))
362: 360: }
363: 361: ```
364: 362: ```
365: 363: ```
366: 364: ```
367: ```
```

