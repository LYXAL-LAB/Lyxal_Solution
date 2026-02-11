### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_superposition\src\organisation\handlers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\organisation\handlers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\organisation\handlers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\organisation\handlers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\organisation\handlers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\organisation\handlers.rs
10: 8: ```rust
11: 9: use actix_web::{
12: 10:     Scope, get, post, routes,
13: 11:     web::{Json, Path, Query},
14: 12: };
15: 13: use chrono::Utc;
16: 14: use diesel::prelude::*;
17: 15: use idgenerator::IdInstance;
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::DbConnection;
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_derives::authorized;
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
21: 19:     PaginatedResponse, User,
22: 20:     api::organisation::{CreateRequest, UpdateRequest},
23: 21:     custom_query::PaginationParams,
24: 22:     database::{
25: 23:         models::{OrgStatus, Organisation},
26: 24:         lyx-core-lyx_core_lyx-core-lyx_core_superposition_schema::lyx-core-lyx_core_lyx-core-lyx_core_superposition::organisations::{
27: 25:             self, updated_at, updated_by,
28: 26:         },
29: 27:     },
30: 28:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
31: 29: };
32: 30: 
33: 31: pub fn endpoints() -> Scope {
34: 32:     Scope::new("")
35: 33:         .service(create_handler)
36: 34:         .service(list_handler)
37: 35:         .service(get_handler)
38: 36:         .service(update_handler)
39: 37: }
40: 38: 
41: 39: #[authorized]
42: 40: #[post("")]
43: 41: pub async fn create_handler(
44: 42:     request: Json<CreateRequest>,
45: 43:     db_conn: DbConnection,
46: 44:     user: User,
47: 45: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Organisation>> {
48: 46:     let DbConnection(mut conn) = db_conn;
49: 47: 
50: 48:     // Generating a numeric ID from IdInstance and prefixing it with `orgid`
51: 49:     let numeric_id = IdInstance::next_id();
52: 50:     let org_id = format!("orgid{}", numeric_id);
53: 51:     let now = Utc::now();
54: 52:     let req = request.into_inner();
55: 53: 
56: 54:     let new_org = Organisation {
57: 55:         id: org_id,
58: 56:         name: req.name,
59: 57:         country_code: req.country_code,
60: 58:         contact_email: req.contact_email,
61: 59:         contact_phone: req.contact_phone,
62: 60:         created_by: user.get_username(),
63: 61:         admin_email: req.admin_email,
64: 62:         status: OrgStatus::PendingKyb,
65: 63:         sector: req.sector,
66: 64:         created_at: now,
67: 65:         updated_at: now,
68: 66:         updated_by: user.get_username(),
69: 67:     };
70: 68: 
71: 69:     let new_org = diesel::insert_into(organisations::table)
72: 70:         .values(&new_org)
73: 71:         .get_result(&mut conn)?;
74: 72: 
75: 73:     Ok(Json(new_org))
76: 74: }
77: 75: 
78: 76: #[authorized]
79: 77: #[routes]
80: 78: #[put("/{org_id}")]
81: 79: #[patch("/{org_id}")]
82: 80: pub async fn update_handler(
83: 81:     org_id: Path<String>,
84: 82:     request: Json<UpdateRequest>,
85: 83:     db_conn: DbConnection,
86: 84:     user: User,
87: 85: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Organisation>> {
88: 86:     let DbConnection(mut conn) = db_conn;
89: 87:     let org_id = org_id.into_inner();
90: 88:     let now = Utc::now();
91: 89:     let req = request.into_inner();
92: 90: 
93: 91:     let updated_org = diesel::update(organisations::table)
94: 92:         .filter(organisations::id.eq(org_id))
95: 93:         .set((req, updated_at.eq(now), updated_by.eq(user.get_email())))
96: 94:         .get_result(&mut conn)?;
97: 95: 
98: 96:     Ok(Json(updated_org))
99: 97: }
100: 98: 
101: 99: #[authorized]
102: 100: #[get("/{org_id}")]
103: 101: pub async fn get_handler(
104: 102:     org_id: Path<String>,
105: 103:     db_conn: DbConnection,
106: 104: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<Organisation>> {
107: 105:     let DbConnection(mut conn) = db_conn;
108: 106: 
109: 107:     let org = organisations::table
110: 108:         .find(org_id.as_str())
111: 109:         .first::<Organisation>(&mut conn)?;
112: 110: 
113: 111:     Ok(Json(org))
114: 112: }
115: 113: 
116: 114: #[authorized]
117: 115: #[get("")]
118: 116: pub async fn list_handler(
119: 117:     db_conn: DbConnection,
120: 118:     filters: Query<PaginationParams>,
121: 119: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<PaginatedResponse<Organisation>>> {
122: 120:     let DbConnection(mut conn) = db_conn;
123: 121: 
124: 122:     if let Some(true) = filters.all {
125: 123:         let result: Vec<Organisation> = organisations::table
126: 124:             .order(organisations::created_at.desc())
127: 125:             .get_results(&mut conn)?;
128: 126: 
129: 127:         return Ok(Json(PaginatedResponse::all(result)));
130: 128:     }
131: 129: 
132: 130:     // Get total count of organisations
133: 131:     let total_items: i64 = organisations::table.count().get_result(&mut conn)?;
134: 132: 
135: 133:     // Set up pagination
136: 134:     let limit = filters.count.unwrap_or(10);
137: 135:     let mut builder = organisations::table
138: 136:         .into_boxed()
139: 137:         .order(organisations::created_at.desc())
140: 138:         .limit(limit);
141: 139: 
142: 140:     // Apply offset if page is specified
143: 141:     if let Some(page) = filters.page {
144: 142:         let offset = (page - 1) * limit;
145: 143:         builder = builder.offset(offset);
146: 144:     }
147: 145: 
148: 146:     // Get paginated results
149: 147:     let data: Vec<Organisation> = builder.load(&mut conn)?;
150: 148: 
151: 149:     let total_pages = (total_items as f64 / limit as f64).ceil() as i64;
152: 150: 
153: 151:     Ok(Json(PaginatedResponse {
154: 152:         total_pages,
155: 153:         total_items,
156: 154:         data,
157: 155:     }))
158: 156: }
159: 157: ```
160: 158: ```
161: 159: ```
162: 160: ```
163: ```
```
