1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\variables\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\variables\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\variables\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\variables\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\variables\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     Scope, delete, get, patch, post,
13: 11:     web::{self, Data, Json, Query},
14: 12: };
15: 13: use diesel::prelude::*;
16: 14: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{AppState, DbConnection, WorkspaceContext};
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
20: 18:     PaginatedResponse, SortBy, User,
21: 19:     api::variables::*,
22: 20:     custom_query::PaginationParams,
23: 21:     database::{models::others::Variable, schema::variables::dsl::*},
24: 22:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
25: 23: };
26: 24: 
27: 25: use crate::helpers::validate_change_reason;
28: 26: 
29: 27: pub fn endpoints() -> Scope {
30: 28:     web::scope("")
31: 29:         .service(list_handler)
32: 30:         .service(create_handler)
33: 31:         .service(get_handler)
34: 32:         .service(update_handler)
35: 33:         .service(delete_handler)
36: 34: }
37: 35: 
38: 36: #[authorized]
39: 37: #[get("")]
40: 38: async fn list_handler(
41: 39:     workspace_context: WorkspaceContext,
42: 40:     db_conn: DbConnection,
43: 41:     pagination: Query<PaginationParams>,
44: 42:     filters: Query<VariableFilters>,
45: 43: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<Variable>>> {
46: 44:     let DbConnection(mut conn) = db_conn;
47: 45: 
48: 46:     let filters = filters.into_inner();
49: 47: 
50: 48:     let query_builder = |filters: &VariableFilters| {
51: 49:         let mut builder = variables
52: 50:             .schema_name(&workspace_context.schema_name)
53: 51:             .into_boxed();
54: 52: 
55: 53:         if let Some(ref var_names) = filters.name {
56: 54:             builder = builder.filter(name.eq_any(var_names.0.clone()));
57: 55:         }
58: 56: 
59: 57:         if let Some(ref creators) = filters.created_by {
60: 58:             builder = builder.filter(created_by.eq_any(creators.0.clone()));
61: 59:         }
62: 60: 
63: 61:         if let Some(ref last_modifiers) = filters.last_modified_by {
64: 62:             builder = builder.filter(last_modified_by.eq_any(last_modifiers.0.clone()));
65: 63:         }
66: 64: 
67: 65:         builder
68: 66:     };
69: 67: 
70: 68:     if let Some(true) = pagination.all {
71: 69:         let result: Vec<Variable> = query_builder(&filters).get_results(&mut conn)?;
72: 70:         return Ok(Json(PaginatedResponse::all(result)));
73: 71:     }
74: 72: 
75: 73:     let base_query = query_builder(&filters);
76: 74:     let count_query = query_builder(&filters);
77: 75: 
78: 76:     let n_variables: i64 = count_query.count().get_result(&mut conn)?;
79: 77:     let limit = pagination.count.unwrap_or(10);
80: 78: 
81: 79:     let sort_on = filters.sort_on.unwrap_or_default();
82: 80:     let sort_by = filters.sort_by.unwrap_or_default();
83: 81: 
84: 82:     #[rustfmt::skip]
85: 83:     let base_query = match (sort_on, sort_by) {
86: 84:         (SortOn::Name,           SortBy::Asc)  => base_query.order(name.asc()),
87: 85:         (SortOn::Name,           SortBy::Desc) => base_query.order(name.desc()),
88: 86:         (SortOn::CreatedAt,      SortBy::Asc)  => base_query.order(created_at.asc()),
89: 87:         (SortOn::CreatedAt,      SortBy::Desc) => base_query.order(created_at.desc()),
90: 88:         (SortOn::LastModifiedAt, SortBy::Asc)  => base_query.order(last_modified_at.asc()),
91: 89:         (SortOn::LastModifiedAt, SortBy::Desc) => base_query.order(last_modified_at.desc()),
92: 90:     };
93: 91: 
94: 92:     let mut builder = base_query.limit(limit);
95: 93:     if let Some(page) = pagination.page {
96: 94:         let offset = (page - 1) * limit;
97: 95:         builder = builder.offset(offset);
98: 96:     }
99: 97:     let result: Vec<Variable> = builder.load(&mut conn)?;
100: 98:     let total_pages = (n_variables as f64 / limit as f64).ceil() as i64;
101: 99:     Ok(Json(PaginatedResponse {
102: 100:         total_pages,
103: 101:         total_items: n_variables,
104: 102:         data: result,
105: 103:     }))
106: 104: }
107: 105: 
108: 106: #[authorized]
109: 107: #[post("")]
110: 108: async fn create_handler(
111: 109:     workspace_context: WorkspaceContext,
112: 110:     req: web::Json<CreateVariableRequest>,
113: 111:     user: User,
114: 112:     db_conn: DbConnection,
115: 113:     state: Data<AppState>,
116: 114: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Variable>> {
117: 115:     let DbConnection(mut conn) = db_conn;
118: 116:     let req = req.into_inner();
119: 117: 
120: 118:     validate_change_reason(
121: 119:         &workspace_context,
122: 120:         &req.change_reason,
123: 121:         &mut conn,
124: 122:         &state.master_encryption_key,
125: 123:     )?;
126: 124: 
127: 125:     let now = chrono::Utc::now();
128: 126: 
129: 127:     let new_var = Variable {
130: 128:         name: req.name,
131: 129:         value: req.value,
132: 130:         description: req.description,
133: 131:         change_reason: req.change_reason,
134: 132:         created_at: now,
135: 133:         last_modified_at: now,
136: 134:         created_by: user.get_email(),
137: 135:         last_modified_by: user.get_email(),
138: 136:     };
139: 137: 
140: 138:     let created_var = diesel::insert_into(variables)
141: 139:         .values(&new_var)
142: 140:         .returning(Variable::as_returning())
143: 141:         .schema_name(&workspace_context.schema_name)
144: 142:         .get_result(&mut conn)?;
145: 143: 
146: 144:     Ok(Json(created_var))
147: 145: }
148: 146: 
149: 147: #[authorized]
150: 148: #[get("/{variable_name}")]
151: 149: async fn get_handler(
152: 150:     workspace_context: WorkspaceContext,
153: 151:     path: web::Path<String>,
154: 152:     db_conn: DbConnection,
155: 153: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Variable>> {
156: 154:     let DbConnection(mut conn) = db_conn;
157: 155: 
158: 156:     let var_name = path.into_inner();
159: 157: 
160: 158:     let var = variables
161: 159:         .filter(name.eq(var_name))
162: 160:         .schema_name(&workspace_context.schema_name)
163: 161:         .get_result::<Variable>(&mut conn)?;
164: 162: 
165: 163:     Ok(Json(var))
166: 164: }
167: 165: 
168: 166: #[authorized]
169: 167: #[patch("/{variable_name}")]
170: 168: async fn update_handler(
171: 169:     workspace_context: WorkspaceContext,
172: 170:     path: web::Path<String>,
173: 171:     req: web::Json<UpdateVariableRequest>,
174: 172:     user: User,
175: 173:     db_conn: DbConnection,
176: 174:     state: Data<AppState>,
177: 175: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Variable>> {
178: 176:     let DbConnection(mut conn) = db_conn;
179: 177:     let var_name = path.into_inner();
180: 178: 
181: 179:     validate_change_reason(
182: 180:         &workspace_context,
183: 181:         &req.change_reason,
184: 182:         &mut conn,
185: 183:         &state.master_encryption_key,
186: 184:     )?;
187: 185: 
188: 186:     let updated_var = diesel::update(variables)
189: 187:         .filter(name.eq(var_name))
190: 188:         .set((
191: 189:             req.into_inner(),
192: 190:             last_modified_at.eq(chrono::Utc::now()),
193: 191:             last_modified_by.eq(user.get_email()),
194: 192:         ))
195: 193:         .schema_name(&workspace_context.schema_name)
196: 194:         .get_result::<Variable>(&mut conn)?;
197: 195:     Ok(Json(updated_var))
198: 196: }
199: 197: 
200: 198: #[authorized]
201: 199: #[delete("/{variable_name}")]
202: 200: async fn delete_handler(
203: 201:     workspace_context: WorkspaceContext,
204: 202:     path: web::Path<String>,
205: 203:     user: User,
206: 204:     db_conn: DbConnection,
207: 205: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Variable>> {
208: 206:     let DbConnection(mut conn) = db_conn;
209: 207:     let var_name = path.into_inner();
210: 208: 
211: 209:     diesel::update(variables)
212: 210:         .filter(name.eq(&var_name))
213: 211:         .set((
214: 212:             last_modified_at.eq(chrono::Utc::now()),
215: 213:             last_modified_by.eq(user.get_email()),
216: 214:         ))
217: 215:         .schema_name(&workspace_context.schema_name)
218: 216:         .execute(&mut conn)?;
219: 217: 
220: 218:     let deleted_variable = diesel::delete(variables)
221: 219:         .filter(name.eq(&var_name))
222: 220:         .schema_name(&workspace_context.schema_name)
223: 221:         .get_result::<Variable>(&mut conn)?;
224: 222: 
225: 223:     Ok(Json(deleted_variable))
226: 224: }
227: 225: ```
228: 226: ```
229: 227: ```
230: 228: ```
231: ```
```

