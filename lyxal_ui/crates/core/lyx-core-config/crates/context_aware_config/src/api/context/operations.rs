### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\context\operations.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\operations.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\operations.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\operations.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\operations.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\operations.rs
10: 8: ```rust
11: 9: use actix_web::web::Json;
12: 10: use chrono::Utc;
13: 11: use diesel::{
14: 12:     Connection, ExpressionMethods, PgConnection, QueryDsl, RunQueryDsl, SelectableHelper,
15: 13:     r2d2::{ConnectionManager, PooledConnection},
16: 14:     result::{DatabaseErrorKind::*, Error::DatabaseError},
17: 15: };
18: 16: use serde_json::{Map, Value};
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{EncryptionKey, SchemaName, WorkspaceContext};
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{db_error, not_found, unexpected_error};
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
22: 20:     DBConnection, Overrides, User,
23: 21:     api::context::{Identifier, MoveRequest, PutRequest, UpdateRequest},
24: 22:     database::{
25: 23:         models::{Description, cac::Context},
26: 24:         schema::contexts::{self, dsl},
27: 25:     },
28: 26:     result,
29: 27: };
30: 28: 
31: 29: use crate::{
32: 30:     api::context::helpers::{
33: 31:         create_ctx_from_put_req, hash, replace_override_of_existing_ctx,
34: 32:         update_override_of_existing_ctx, validate_ctx,
35: 33:     },
36: 34:     helpers::calculate_context_weight,
37: 35: };
38: 36: 
39: 37: use super::{
40: 38:     helpers::validate_override_with_functions, types::UpdateContextOverridesChangeset,
41: 39:     validations::validate_override_with_default_configs,
42: 40: };
43: 41: 
44: 42: #[allow(clippy::too_many_arguments)]
45: 43: pub fn upsert(
46: 44:     req: PutRequest,
47: 45:     description: Description,
48: 46:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
49: 47:     already_under_txn: bool,
50: 48:     user: &User,
51: 49:     workspace_context: &WorkspaceContext,
52: 50:     replace: bool,
53: 51:     master_encryption_key: &Option<EncryptionKey>,
54: 52: ) -> result::Result<Context> {
55: 53:     use contexts::dsl::contexts;
56: 54:     let new_ctx = create_ctx_from_put_req(
57: 55:         req,
58: 56:         description,
59: 57:         conn,
60: 58:         user,
61: 59:         workspace_context,
62: 60:         master_encryption_key,
63: 61:     )?;
64: 62: 
65: 63:     if already_under_txn {
66: 64:         diesel::sql_query("SAVEPOINT put_ctx_savepoint").execute(conn)?;
67: 65:     }
68: 66:     let insert = diesel::insert_into(contexts)
69: 67:         .values(&new_ctx)
70: 68:         .returning(Context::as_returning())
71: 69:         .schema_name(&workspace_context.schema_name)
72: 70:         .execute(conn);
73: 71: 
74: 72:     match insert {
75: 73:         Ok(_) => Ok(new_ctx),
76: 74:         Err(DatabaseError(UniqueViolation, _)) => {
77: 75:             if already_under_txn {
78: 76:                 diesel::sql_query("ROLLBACK TO put_ctx_savepoint").execute(conn)?;
79: 77:             }
80: 78:             if replace {
81: 79:                 replace_override_of_existing_ctx(
82: 80:                     conn,
83: 81:                     new_ctx,
84: 82:                     user,
85: 83:                     &workspace_context.schema_name,
86: 84:                 )
87: 85:             } else {
88: 86:                 update_override_of_existing_ctx(
89: 87:                     conn,
90: 88:                     new_ctx,
91: 89:                     user,
92: 90:                     &workspace_context.schema_name,
93: 91:                 )
94: 92:             }
95: 93:         }
96: 94:         Err(e) => {
97: 95:             log::error!("failed to update context with db error: {:?}", e);
98: 96:             Err(db_error!(e))
99: 97:         }
100: 98:     }
101: 99: }
102: 100: 
103: 101: pub fn update(
104: 102:     workspace_context: &WorkspaceContext,
105: 103:     req: UpdateRequest,
106: 104:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
107: 105:     user: &User,
108: 106:     master_encryption_key: &Option<EncryptionKey>,
109: 107: ) -> result::Result<Context> {
110: 108:     let (context_id, context) = match req.context {
111: 109:         Identifier::Context(context) => {
112: 110:             let ctx_value: Map<String, Value> = context.into_inner().into();
113: 111:             (hash(&Value::Object(ctx_value.clone())), ctx_value)
114: 112:         }
115: 113:         Identifier::Id(id) => {
116: 114:             let ctx_value: Context = dsl::contexts
117: 115:                 .filter(dsl::id.eq(id.clone()))
118: 116:                 .schema_name(&workspace_context.schema_name)
119: 117:                 .get_result::<Context>(conn)?;
120: 118:             (id.clone(), ctx_value.value.into())
121: 119:         }
122: 120:     };
123: 121: 
124: 122:     let r_override = req.override_.clone().into_inner();
125: 123:     let ctx_override = Value::Object(r_override.clone().into());
126: 124: 
127: 125:     validate_override_with_default_configs(
128: 126:         conn,
129: 127:         &r_override,
130: 128:         &workspace_context.schema_name,
131: 129:     )?;
132: 130:     validate_override_with_functions(
133: 131:         workspace_context,
134: 132:         conn,
135: 133:         &r_override,
136: 134:         &context,
137: 135:         master_encryption_key,
138: 136:     )?;
139: 137: 
140: 138:     let update_request = UpdateContextOverridesChangeset {
141: 139:         override_id: hash(&ctx_override),
142: 140:         override_: r_override,
143: 141:         last_modified_at: Utc::now(),
144: 142:         last_modified_by: user.get_email(),
145: 143:         description: req.description.clone(),
146: 144:         change_reason: req.change_reason.clone(),
147: 145:     };
148: 146: 
149: 147:     diesel::update(dsl::contexts)
150: 148:         .filter(dsl::id.eq(context_id))
151: 149:         .set(update_request)
152: 150:         .schema_name(&workspace_context.schema_name)
153: 151:         .returning(Context::as_returning())
154: 152:         .get_result(conn)
155: 153:         .map_err(|e| db_error!(e))
156: 154: }
157: 155: 
158: 156: #[allow(clippy::too_many_arguments)]
159: 157: pub fn r#move(
160: 158:     workspace_context: &WorkspaceContext,
161: 159:     old_ctx_id: String,
162: 160:     req: Json<MoveRequest>,
163: 161:     req_description: Description,
164: 162:     conn: &mut PooledConnection<ConnectionManager<PgConnection>>,
165: 163:     already_under_txn: bool,
166: 164:     user: &User,
167: 165:     master_encryption_key: &Option<EncryptionKey>,
168: 166: ) -> result::Result<Context> {
169: 167:     use contexts::dsl;
170: 168:     let req = req.into_inner();
171: 169:     let ctx_condition = req.context.to_owned().into_inner();
172: 170:     let ctx_condition_value = Value::Object(ctx_condition.clone().into());
173: 171:     let change_reason = req.change_reason.clone();
174: 172: 
175: 173:     let new_ctx_id = hash(&ctx_condition_value);
176: 174: 
177: 175:     let dimension_data_map = validate_ctx(
178: 176:         conn,
179: 177:         workspace_context,
180: 178:         ctx_condition.clone(),
181: 179:         Overrides::default(),
182: 180:         master_encryption_key,
183: 181:     )?;
184: 182:     let weight = calculate_context_weight(&ctx_condition_value, &dimension_data_map)
185: 183:         .map_err(|_| unexpected_error!("Something Went Wrong"))?;
186: 184: 
187: 185:     if already_under_txn {
188: 186:         diesel::sql_query("SAVEPOINT update_ctx_savepoint").execute(conn)?;
189: 187:     }
190: 188: 
191: 189:     let context = diesel::update(dsl::contexts)
192: 190:         .filter(dsl::id.eq(&old_ctx_id))
193: 191:         .set((
194: 192:             dsl::id.eq(&new_ctx_id),
195: 193:             dsl::value.eq(&ctx_condition_value),
196: 194:             dsl::weight.eq(&weight),
197: 195:             dsl::last_modified_at.eq(Utc::now()),
198: 196:             dsl::last_modified_by.eq(user.get_email()),
199: 197:             dsl::description.eq(req_description.clone()),
200: 198:             dsl::change_reason.eq(change_reason.clone()),
201: 199:         ))
202: 200:         .returning(Context::as_returning())
203: 201:         .schema_name(&workspace_context.schema_name)
204: 202:         .get_result::<Context>(conn);
205: 203: 
206: 204:     let contruct_new_ctx_with_old_overrides = |ctx: Context| Context {
207: 205:         id: new_ctx_id,
208: 206:         value: ctx_condition,
209: 207:         created_at: Utc::now(),
210: 208:         created_by: user.get_email(),
211: 209:         override_id: ctx.override_id,
212: 210:         override_: ctx.override_,
213: 211:         last_modified_at: Utc::now(),
214: 212:         last_modified_by: user.get_email(),
215: 213:         weight,
216: 214:         description: req_description,
217: 215:         change_reason,
218: 216:     };
219: 217: 
220: 218:     let handle_unique_violation =
221: 219:         |db_conn: &mut DBConnection, already_under_txn: bool| {
222: 220:             if already_under_txn {
223: 221:                 let deleted_ctxt = diesel::delete(dsl::contexts)
224: 222:                     .filter(dsl::id.eq(&old_ctx_id))
225: 223:                     .schema_name(&workspace_context.schema_name)
226: 224:                     .get_result(db_conn)?;
227: 225: 
228: 226:                 let ctx = contruct_new_ctx_with_old_overrides(deleted_ctxt);
229: 227:                 update_override_of_existing_ctx(
230: 228:                     db_conn,
231: 229:                     ctx,
232: 230:                     user,
233: 231:                     &workspace_context.schema_name,
234: 232:                 )
235: 233:             } else {
236: 234:                 db_conn.transaction(|conn| {
237: 235:                     let deleted_ctxt = diesel::delete(dsl::contexts)
238: 236:                         .filter(dsl::id.eq(&old_ctx_id))
239: 237:                         .schema_name(&workspace_context.schema_name)
240: 238:                         .get_result(conn)?;
241: 239:                     let ctx = contruct_new_ctx_with_old_overrides(deleted_ctxt);
242: 240:                     update_override_of_existing_ctx(
243: 241:                         conn,
244: 242:                         ctx,
245: 243:                         user,
246: 244:                         &workspace_context.schema_name,
247: 245:                     )
248: 246:                 })
249: 247:             }
250: 248:         };
251: 249: 
252: 250:     match context {
253: 251:         Ok(ctx) => Ok(ctx),
254: 252:         Err(DatabaseError(UniqueViolation, _)) => {
255: 253:             if already_under_txn {
256: 254:                 diesel::sql_query("ROLLBACK TO update_ctx_savepoint").execute(conn)?;
257: 255:             }
258: 256:             handle_unique_violation(conn, already_under_txn)
259: 257:         }
260: 258:         Err(e) => {
261: 259:             log::error!("failed to move context with db error: {:?}", e);
262: 260:             Err(db_error!(e))
263: 261:         }
264: 262:     }
265: 263: }
266: 264: 
267: 265: pub fn delete(
268: 266:     ctx_id: String,
269: 267:     user: &User,
270: 268:     conn: &mut DBConnection,
271: 269:     schema_name: &SchemaName,
272: 270: ) -> result::Result<()> {
273: 271:     use contexts::dsl;
274: 272:     diesel::update(dsl::contexts)
275: 273:         .filter(dsl::id.eq(&ctx_id))
276: 274:         .set((
277: 275:             dsl::last_modified_at.eq(Utc::now()),
278: 276:             dsl::last_modified_by.eq(user.get_email()),
279: 277:         ))
280: 278:         .returning(Context::as_returning())
281: 279:         .schema_name(schema_name)
282: 280:         .execute(conn)?;
283: 281:     let deleted_row = diesel::delete(dsl::contexts.filter(dsl::id.eq(&ctx_id)))
284: 282:         .schema_name(schema_name)
285: 283:         .execute(conn);
286: 284:     match deleted_row {
287: 285:         Ok(0) => Err(not_found!("Context Id `{}` doesn't exists", ctx_id)),
288: 286:         Ok(_) => {
289: 287:             log::info!("{ctx_id} context deleted by {}", user.get_email());
290: 288:             Ok(())
291: 289:         }
292: 290:         Err(e) => {
293: 291:             log::error!("context delete query failed with error: {e}");
294: 292:             Err(unexpected_error!("Something went wrong."))
295: 293:         }
296: 294:     }
297: 295: }
298: 296: ```
299: 297: ```
300: 298: ```
301: 299: ```
302: ```
```
