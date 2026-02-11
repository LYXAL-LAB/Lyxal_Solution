### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_superposition\src\webhooks\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\webhooks\handlers.rs
10: 8: ```rust
11: 9: use super::helper::{fetch_webhook, validate_events};
12: 10: use actix_web::{
13: 11:     HttpResponse, Scope, delete, get, patch, post,
14: 12:     web::{self, Data, Json, Query},
15: 13: };
16: 14: use chrono::Utc;
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config::helpers::validate_change_reason;
18: 16: use diesel::{ExpressionMethods, PgArrayExpressionMethods, QueryDsl, RunQueryDsl};
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::{AppState, DbConnection, WorkspaceContext};
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
22: 20:     PaginatedResponse, User,
23: 21:     api::webhook::{CreateWebhookRequest, UpdateWebhookRequest, WebhookName},
24: 22:     custom_query::PaginationParams,
25: 23:     database::{
26: 24:         models::others::{Webhook, WebhookEvent},
27: 25:         schema::webhooks::{self, dsl::*},
28: 26:     },
29: 27:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
30: 28: };
31: 29: pub fn endpoints() -> Scope {
32: 30:     Scope::new("")
33: 31:         .service(create_handler)
34: 32:         .service(list_handler)
35: 33:         .service(get_handler)
36: 34:         .service(update_handler)
37: 35:         .service(delete_handler)
38: 36:         .service(get_by_event_handler)
39: 37: }
40: 38: 
41: 39: #[authorized]
42: 40: #[post("")]
43: 41: async fn create_handler(
44: 42:     workspace_context: WorkspaceContext,
45: 43:     request: Json<CreateWebhookRequest>,
46: 44:     db_conn: DbConnection,
47: 45:     user: User,
48: 46:     state: Data<AppState>,
49: 47: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Webhook>> {
50: 48:     let DbConnection(mut conn) = db_conn;
51: 49:     let req = request.into_inner();
52: 50: 
53: 51:     validate_change_reason(
54: 52:         &workspace_context,
55: 53:         &req.change_reason,
56: 54:         &mut conn,
57: 55:         &state.master_encryption_key,
58: 56:     )?;
59: 57: 
60: 58:     validate_events(&req.events, None, &workspace_context.schema_name, &mut conn)?;
61: 59:     let now = Utc::now();
62: 60:     let webhook_data = Webhook {
63: 61:         name: req.name.to_string(),
64: 62:         description: req.description,
65: 63:         enabled: req.enabled,
66: 64:         url: req.url,
67: 65:         method: req.method,
68: 66:         payload_version: req.payload_version.unwrap_or_default(),
69: 67:         custom_headers: req.custom_headers.unwrap_or_default(),
70: 68:         events: req.events,
71: 69:         max_retries: 0,
72: 70:         last_triggered_at: None,
73: 71:         change_reason: req.change_reason,
74: 72:         created_by: user.email.clone(),
75: 73:         created_at: now,
76: 74:         last_modified_by: user.email,
77: 75:         last_modified_at: now,
78: 76:     };
79: 77: 
80: 78:     diesel::insert_into(webhooks::table)
81: 79:         .values(&webhook_data)
82: 80:         .schema_name(&workspace_context.schema_name)
83: 81:         .execute(&mut conn)?;
84: 82: 
85: 83:     Ok(Json(webhook_data))
86: 84: }
87: 85: 
88: 86: #[authorized]
89: 87: #[patch("/{webhook_name}")]
90: 88: async fn update_handler(
91: 89:     workspace_context: WorkspaceContext,
92: 90:     params: web::Path<WebhookName>,
93: 91:     db_conn: DbConnection,
94: 92:     user: User,
95: 93:     request: Json<UpdateWebhookRequest>,
96: 94:     state: Data<AppState>,
97: 95: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Webhook>> {
98: 96:     let DbConnection(mut conn) = db_conn;
99: 97:     let req = request.into_inner();
100: 98:     let w_name: String = params.into_inner().into();
101: 99: 
102: 100:     validate_change_reason(
103: 101:         &workspace_context,
104: 102:         &req.change_reason,
105: 103:         &mut conn,
106: 104:         &state.master_encryption_key,
107: 105:     )?;
108: 106: 
109: 107:     if let Some(webhook_events) = &req.events {
110: 108:         validate_events(
111: 109:             webhook_events,
112: 110:             Some(&w_name),
113: 111:             &workspace_context.schema_name,
114: 112:             &mut conn,
115: 113:         )?;
116: 114:     }
117: 115: 
118: 116:     let update = diesel::update(webhooks::table)
119: 117:         .filter(webhooks::name.eq(w_name))
120: 118:         .set((
121: 119:             req,
122: 120:             last_modified_at.eq(Utc::now()),
123: 121:             last_modified_by.eq(user.get_email()),
124: 122:         ))
125: 123:         .schema_name(&workspace_context.schema_name)
126: 124:         .get_result::<Webhook>(&mut conn)?;
127: 125: 
128: 126:     Ok(Json(update))
129: 127: }
130: 128: 
131: 129: #[authorized]
132: 130: #[get("/{webhook_name}")]
133: 131: async fn get_handler(
134: 132:     workspace_context: WorkspaceContext,
135: 133:     params: web::Path<WebhookName>,
136: 134:     db_conn: DbConnection,
137: 135: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Webhook>> {
138: 136:     let DbConnection(mut conn) = db_conn;
139: 137:     let webhook_row = fetch_webhook(
140: 138:         &params.into_inner(),
141: 139:         &workspace_context.schema_name,
142: 140:         &mut conn,
143: 141:     )?;
144: 142:     Ok(Json(webhook_row))
145: 143: }
146: 144: 
147: 145: #[authorized]
148: 146: #[get("")]
149: 147: async fn list_handler(
150: 148:     workspace_context: WorkspaceContext,
151: 149:     db_conn: DbConnection,
152: 150:     pagination: Query<PaginationParams>,
153: 151: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<Webhook>>> {
154: 152:     let DbConnection(mut conn) = db_conn;
155: 153: 
156: 154:     if let Some(true) = pagination.all {
157: 155:         let result: Vec<Webhook> = webhooks
158: 156:             .schema_name(&workspace_context.schema_name)
159: 157:             .get_results(&mut conn)?;
160: 158:         return Ok(Json(PaginatedResponse::all(result)));
161: 159:     }
162: 160: 
163: 161:     let total_items: i64 = webhooks
164: 162:         .count()
165: 163:         .schema_name(&workspace_context.schema_name)
166: 164:         .get_result(&mut conn)?;
167: 165:     let limit = pagination.count.unwrap_or(10);
168: 166:     let mut builder = webhooks
169: 167:         .schema_name(&workspace_context.schema_name)
170: 168:         .into_boxed()
171: 169:         .order(webhooks::last_modified_at.desc())
172: 170:         .limit(limit);
173: 171:     if let Some(page) = pagination.page {
174: 172:         let offset = (page - 1) * limit;
175: 173:         builder = builder.offset(offset);
176: 174:     }
177: 175:     let data: Vec<Webhook> = builder.load(&mut conn)?;
178: 176:     let total_pages = (total_items as f64 / limit as f64).ceil() as i64;
179: 177: 
180: 178:     Ok(Json(PaginatedResponse {
181: 179:         total_pages,
182: 180:         total_items,
183: 181:         data,
184: 182:     }))
185: 183: }
186: 184: 
187: 185: #[authorized]
188: 186: #[delete("/{webhook_name}")]
189: 187: async fn delete_handler(
190: 188:     workspace_context: WorkspaceContext,
191: 189:     params: web::Path<WebhookName>,
192: 190:     db_conn: DbConnection,
193: 191:     user: User,
194: 192: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<HttpResponse> {
195: 193:     let DbConnection(mut conn) = db_conn;
196: 194:     let w_name: String = params.into_inner().into();
197: 195: 
198: 196:     diesel::update(webhooks::table)
199: 197:         .filter(webhooks::name.eq(&w_name))
200: 198:         .set((
201: 199:             webhooks::last_modified_at.eq(Utc::now()),
202: 200:             webhooks::last_modified_by.eq(user.get_email()),
203: 201:         ))
204: 202:         .schema_name(&workspace_context.schema_name)
205: 203:         .execute(&mut conn)?;
206: 204:     diesel::delete(webhooks.filter(webhooks::name.eq(&w_name)))
207: 205:         .schema_name(&workspace_context.schema_name)
208: 206:         .execute(&mut conn)?;
209: 207:     Ok(HttpResponse::NoContent().finish())
210: 208: }
211: 209: 
212: 210: #[authorized]
213: 211: #[get("/event/{event}")]
214: 212: async fn get_by_event_handler(
215: 213:     workspace_context: WorkspaceContext,
216: 214:     params: web::Path<WebhookEvent>,
217: 215:     db_conn: DbConnection,
218: 216: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Webhook>> {
219: 217:     let DbConnection(mut conn) = db_conn;
220: 218:     let event = params.into_inner();
221: 219:     let webhook_row = webhooks
222: 220:         .filter(webhooks::events.contains(vec![event]))
223: 221:         .schema_name(&workspace_context.schema_name)
224: 222:         .first::<Webhook>(&mut conn)?;
225: 223:     Ok(Json(webhook_row))
226: 224: }
227: 225: ```
228: 226: ```
229: 227: ```
230: 228: ```
231: ```
```
