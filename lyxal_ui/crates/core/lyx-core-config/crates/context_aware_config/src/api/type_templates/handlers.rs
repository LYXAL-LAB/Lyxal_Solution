### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\type_templates\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\type_templates\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\type_templates\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\type_templates\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\type_templates\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\type_templates\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     Scope, delete, get, post, routes,
13: 11:     web::{Data, Json, Path, Query},
14: 12: };
15: 13: use chrono::Utc;
16: 14: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
17: 15: use jsonschema::JSONSchema;
18: 16: use serde_json::Value;
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{AppState, DbConnection, WorkspaceContext};
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::bad_argument;
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
23: 21:     PaginatedResponse, User,
24: 22:     api::type_templates::{
25: 23:         TypeTemplateCreateRequest, TypeTemplateName, TypeTemplateUpdateRequest,
26: 24:     },
27: 25:     custom_query::PaginationParams,
28: 26:     database::{
29: 27:         models::cac::TypeTemplate,
30: 28:         schema::type_templates::{self, dsl},
31: 29:     },
32: 30:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
33: 31: };
34: 32: 
35: 33: use crate::helpers::validate_change_reason;
36: 34: 
37: 35: pub fn endpoints() -> Scope {
38: 36:     Scope::new("")
39: 37:         .service(get_handler)
40: 38:         .service(list_handler)
41: 39:         .service(create_handler)
42: 40:         .service(update_handler)
43: 41:         .service(delete_handler)
44: 42: }
45: 43: 
46: 44: #[authorized]
47: 45: #[post("")]
48: 46: async fn create_handler(
49: 47:     workspace_context: WorkspaceContext,
50: 48:     request: Json<TypeTemplateCreateRequest>,
51: 49:     db_conn: DbConnection,
52: 50:     user: User,
53: 51:     state: Data<AppState>,
54: 52: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<TypeTemplate>> {
55: 53:     let DbConnection(mut conn) = db_conn;
56: 54:     JSONSchema::compile(&Value::from(&request.type_schema)).map_err(|err| {
57: 55:         log::error!(
58: 56:             "Invalid jsonschema sent in the request, schema: {:?} error: {}",
59: 57:             request.type_schema,
60: 58:             err
61: 59:         );
62: 60:         bad_argument!(
63: 61:             "Invalid jsonschema sent in the request, validation error is: {}",
64: 62:             err.to_string()
65: 63:         )
66: 64:     })?;
67: 65: 
68: 66:     validate_change_reason(
69: 67:         &workspace_context,
70: 68:         &request.change_reason,
71: 69:         &mut conn,
72: 70:         &state.master_encryption_key,
73: 71:     )?;
74: 72: 
75: 73:     let now = Utc::now();
76: 74:     let type_template = TypeTemplate {
77: 75:         type_schema: request.type_schema.clone(),
78: 76:         type_name: request.type_name.clone().into(),
79: 77:         created_at: now,
80: 78:         created_by: user.email.clone(),
81: 79:         last_modified_at: now,
82: 80:         last_modified_by: user.email.clone(),
83: 81:         description: request.description.clone(),
84: 82:         change_reason: request.change_reason.clone(),
85: 83:     };
86: 84: 
87: 85:     let type_template = diesel::insert_into(type_templates::table)
88: 86:         .values(&type_template)
89: 87:         .returning(TypeTemplate::as_returning())
90: 88:         .schema_name(&workspace_context.schema_name)
91: 89:         .get_result::<TypeTemplate>(&mut conn)?;
92: 90:     Ok(Json(type_template))
93: 91: }
94: 92: 
95: 93: #[authorized]
96: 94: #[get("/{type_name}")]
97: 95: async fn get_handler(
98: 96:     workspace_context: WorkspaceContext,
99: 97:     type_name: Path<TypeTemplateName>,
100: 98:     db_conn: DbConnection,
101: 99: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<TypeTemplate>> {
102: 100:     let DbConnection(mut conn) = db_conn;
103: 101:     let type_name: String = type_name.into_inner().into();
104: 102:     let type_template = type_templates::table
105: 103:         .filter(type_templates::type_name.eq(type_name))
106: 104:         .schema_name(&workspace_context.schema_name)
107: 105:         .first::<TypeTemplate>(&mut conn)?;
108: 106: 
109: 107:     Ok(Json(type_template))
110: 108: }
111: 109: 
112: 110: #[authorized]
113: 111: #[routes]
114: 112: #[put("/{type_name}")]
115: 113: #[patch("/{type_name}")]
116: 114: async fn update_handler(
117: 115:     workspace_context: WorkspaceContext,
118: 116:     request: Json<TypeTemplateUpdateRequest>,
119: 117:     path: Path<TypeTemplateName>,
120: 118:     db_conn: DbConnection,
121: 119:     user: User,
122: 120:     state: Data<AppState>,
123: 121: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<TypeTemplate>> {
124: 122:     let DbConnection(mut conn) = db_conn;
125: 123:     let request = request.into_inner();
126: 124:     JSONSchema::compile(&Value::from(&request.type_schema)).map_err(|err| {
127: 125:         log::error!(
128: 126:             "Invalid jsonschema sent in the request, schema: {:?} error: {}",
129: 127:             request,
130: 128:             err
131: 129:         );
132: 130:         bad_argument!(
133: 131:             "Invalid jsonschema sent in the request, validation error is: {}",
134: 132:             err.to_string()
135: 133:         )
136: 134:     })?;
137: 135: 
138: 136:     validate_change_reason(
139: 137:         &workspace_context,
140: 138:         &request.change_reason,
141: 139:         &mut conn,
142: 140:         &state.master_encryption_key,
143: 141:     )?;
144: 142: 
145: 143:     let type_name: String = path.into_inner().into();
146: 144: 
147: 145:     let timestamp = Utc::now();
148: 146:     let updated_type = diesel::update(type_templates::table)
149: 147:         .filter(type_templates::type_name.eq(type_name))
150: 148:         .set((
151: 149:             request,
152: 150:             type_templates::last_modified_at.eq(timestamp),
153: 151:             type_templates::last_modified_by.eq(user.email.clone()),
154: 152:         ))
155: 153:         .returning(TypeTemplate::as_returning())
156: 154:         .schema_name(&workspace_context.schema_name)
157: 155:         .get_result::<TypeTemplate>(&mut conn)?;
158: 156:     Ok(Json(updated_type))
159: 157: }
160: 158: 
161: 159: #[authorized]
162: 160: #[delete("/{type_name}")]
163: 161: async fn delete_handler(
164: 162:     workspace_context: WorkspaceContext,
165: 163:     path: Path<TypeTemplateName>,
166: 164:     db_conn: DbConnection,
167: 165:     user: User,
168: 166: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<TypeTemplate>> {
169: 167:     let DbConnection(mut conn) = db_conn;
170: 168:     let type_name: String = path.into_inner().into();
171: 169:     diesel::update(dsl::type_templates)
172: 170:         .filter(dsl::type_name.eq(type_name.clone()))
173: 171:         .set((
174: 172:             dsl::last_modified_at.eq(Utc::now()),
175: 173:             dsl::last_modified_by.eq(user.email.clone()),
176: 174:         ))
177: 175:         .returning(TypeTemplate::as_returning())
178: 176:         .schema_name(&workspace_context.schema_name)
179: 177:         .execute(&mut conn)?;
180: 178:     let deleted_type =
181: 179:         diesel::delete(dsl::type_templates.filter(dsl::type_name.eq(type_name)))
182: 180:             .schema_name(&workspace_context.schema_name)
183: 181:             .get_result::<TypeTemplate>(&mut conn)?;
184: 182:     Ok(Json(deleted_type))
185: 183: }
186: 184: 
187: 185: #[authorized]
188: 186: #[get("")]
189: 187: async fn list_handler(
190: 188:     workspace_context: WorkspaceContext,
191: 189:     db_conn: DbConnection,
192: 190:     filters: Query<PaginationParams>,
193: 191: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<TypeTemplate>>> {
194: 192:     let DbConnection(mut conn) = db_conn;
195: 193: 
196: 194:     if let Some(true) = filters.all {
197: 195:         let result: Vec<TypeTemplate> = type_templates::dsl::type_templates
198: 196:             .schema_name(&workspace_context.schema_name)
199: 197:             .get_results(&mut conn)?;
200: 198:         return Ok(Json(PaginatedResponse::all(result)));
201: 199:     };
202: 200: 
203: 201:     let n_types: i64 = type_templates::dsl::type_templates
204: 202:         .count()
205: 203:         .schema_name(&workspace_context.schema_name)
206: 204:         .get_result(&mut conn)?;
207: 205:     let limit = filters.count.unwrap_or(10);
208: 206:     let mut builder = type_templates::dsl::type_templates
209: 207:         .schema_name(&workspace_context.schema_name)
210: 208:         .order(type_templates::dsl::created_at.desc())
211: 209:         .limit(limit)
212: 210:         .into_boxed();
213: 211:     if let Some(page) = filters.page {
214: 212:         let offset = (page - 1) * limit;
215: 213:         builder = builder.offset(offset);
216: 214:     }
217: 215:     let custom_types: Vec<TypeTemplate> = builder.load(&mut conn)?;
218: 216:     let total_pages = (n_types as f64 / limit as f64).ceil() as i64;
219: 217:     Ok(Json(PaginatedResponse {
220: 218:         total_pages,
221: 219:         total_items: n_types,
222: 220:         data: custom_types,
223: 221:     }))
224: 222: }
225: 223: ```
226: 224: ```
227: 225: ```
228: 226: ```
229: ```
```
