### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\functions\helpers.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\functions\helpers.rs
10: 8: ```rust
11: 9: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper};
12: 10: use secrecy::ExposeSecret;
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
14: 12:     encryption::{decrypt_secret, decrypt_workspace_key},
15: 13:     service::types::{EncryptionKey, SchemaName, WorkspaceContext},
16: 14: };
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{unexpected_error, validation_error};
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
19: 17:     DBConnection,
20: 18:     database::{
21: 19:         models::cac::{Function, FunctionCode, FunctionType},
22: 20:         schema::{
23: 21:             self, functions::dsl::functions, secrets::dsl as secrets_dsl,
24: 22:             variables::dsl as variables,
25: 23:         },
26: 24:     },
27: 25:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
28: 26: };
29: 27: 
30: 28: use super::types::FunctionInfo;
31: 29: 
32: 30: pub fn fetch_function(
33: 31:     f_name: &String,
34: 32:     conn: &mut DBConnection,
35: 33:     schema_name: &SchemaName,
36: 34: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Function> {
37: 35:     Ok(functions
38: 36:         .filter(schema::functions::function_name.eq(f_name))
39: 37:         .schema_name(schema_name)
40: 38:         .get_result::<Function>(conn)?)
41: 39: }
42: 40: 
43: 41: pub fn get_published_function_code(
44: 42:     conn: &mut DBConnection,
45: 43:     f_name: &str,
46: 44:     f_type: FunctionType,
47: 45:     schema_name: &SchemaName,
48: 46: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<FunctionInfo> {
49: 47:     let function = functions
50: 48:         .filter(schema::functions::function_name.eq(f_name))
51: 49:         .select(FunctionInfo::as_select())
52: 50:         .schema_name(schema_name)
53: 51:         .first(conn)?;
54: 52: 
55: 53:     if function.function_type != f_type {
56: 54:         return Err(validation_error!(
57: 55:             "Function type mismatch for function: {}",
58: 56:             f_name
59: 57:         ));
60: 58:     }
61: 59: 
62: 60:     Ok(function)
63: 61: }
64: 62: 
65: 63: pub fn get_published_functions_by_names(
66: 64:     conn: &mut DBConnection,
67: 65:     function_names: Vec<String>,
68: 66:     f_type: FunctionType,
69: 67:     schema_name: &SchemaName,
70: 68: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<FunctionInfo>> {
71: 69:     let functions_data = functions
72: 70:         .filter(schema::functions::function_name.eq_any(function_names))
73: 71:         .select(FunctionInfo::as_select())
74: 72:         .schema_name(schema_name)
75: 73:         .load::<FunctionInfo>(conn)?;
76: 74: 
77: 75:     functions_data.iter().try_for_each(|f| {
78: 76:         (f.function_type == f_type).then_some(()).ok_or_else(|| {
79: 77:             validation_error!("Function type mismatch for function: {}", f.function_name)
80: 78:         })
81: 79:     })?;
82: 80: 
83: 81:     Ok(functions_data)
84: 82: }
85: 83: 
86: 84: pub fn check_fn_published(
87: 85:     fn_name: &str,
88: 86:     fn_type: FunctionType,
89: 87:     conn: &mut DBConnection,
90: 88:     schema_name: &SchemaName,
91: 89: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
92: 90:     let FunctionInfo { published_code, .. } =
93: 91:         get_published_function_code(conn, fn_name, fn_type, schema_name)?;
94: 92:     if published_code.is_some() {
95: 93:         Ok(())
96: 94:     } else {
97: 95:         Err(validation_error!(
98: 96:             "Function {}'s published code does not exist.",
99: 97:             fn_name
100: 98:         ))
101: 99:     }
102: 100: }
103: 101: 
104: 102: pub fn generate_template(name: &str, vars: &[(String, String)]) -> String {
105: 103:     if vars.is_empty() {
106: 104:         return String::new();
107: 105:     }
108: 106:     let map: serde_json::Map<String, serde_json::Value> = vars
109: 107:         .iter()
110: 108:         .map(|(k, v)| (k.clone(), serde_json::Value::String(v.clone())))
111: 109:         .collect();
112: 110:     let json = serde_json::to_string_pretty(&map).unwrap_or_default();
113: 111:     format!("const {} = {};", name, json)
114: 112: }
115: 113: 
116: 114: pub fn inject_variables_into_code(
117: 115:     code: &str,
118: 116:     conn: &mut DBConnection,
119: 117:     schema_name: &SchemaName,
120: 118: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<FunctionCode> {
121: 119:     let vars: Vec<(String, String)> = variables::variables
122: 120:         .select((variables::name, variables::value))
123: 121:         .schema_name(schema_name)
124: 122:         .load(conn)?;
125: 123: 
126: 124:     let vars_template = generate_template("VARS", &vars);
127: 125:     let processed_code = format!("{}\n\n{}", vars_template, code);
128: 126: 
129: 127:     Ok(FunctionCode(processed_code))
130: 128: }
131: 129: 
132: 130: pub fn inject_secrets_into_code(
133: 131:     workspace_context: &WorkspaceContext,
134: 132:     code: &str,
135: 133:     conn: &mut DBConnection,
136: 134:     master_encryption_key: &Option<EncryptionKey>,
137: 135: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<FunctionCode> {
138: 136:     let all_secrets: Vec<(String, String)> = secrets_dsl::secrets
139: 137:         .select((secrets_dsl::name, secrets_dsl::encrypted_value))
140: 138:         .schema_name(&workspace_context.schema_name)
141: 139:         .load(conn)?;
142: 140: 
143: 141:     if all_secrets.is_empty() {
144: 142:         let secrets_template = generate_template("SECRETS", &[]);
145: 143:         let processed_code = format!("{}\n\n{}", secrets_template, code);
146: 144:         return Ok(FunctionCode(processed_code));
147: 145:     }
148: 146: 
149: 147:     // If master_encryption_key is not available, we cannot decrypt secrets
150: 148:     let Some(master_encryption_key) = master_encryption_key else {
151: 149:         log::warn!(
152: 150:             "Master encryption key not configured, skipping secret injection in function code"
153: 151:         );
154: 152:         let secrets_template = generate_template("SECRETS", &[]);
155: 153:         let processed_code = format!("{}\n\n{}", secrets_template, code);
156: 154:         return Ok(FunctionCode(processed_code));
157: 155:     };
158: 156: 
159: 157:     let workspace = &workspace_context.settings;
160: 158: 
161: 159:     let workspace_key =
162: 160:         decrypt_workspace_key(&workspace.encryption_key, master_encryption_key)
163: 161:             .map_err(|e| unexpected_error!("Failed to decrypt workspace key: {}", e))?;
164: 162: 
165: 163:     let decrypted_secrets: lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<(String, String)>> = all_secrets
166: 164:         .into_iter()
167: 165:         .map(|(name, encrypted_value)| {
168: 166:             let decrypted_value = decrypt_secret(&encrypted_value, &workspace_key)
169: 167:                 .map_err(|e| {
170: 168:                     unexpected_error!("Failed to decrypt secret '{}': {}", name, e)
171: 169:                 })?;
172: 170:             Ok((name, decrypted_value.expose_secret().to_string()))
173: 171:         })
174: 172:         .collect();
175: 173: 
176: 174:     let secrets_template = generate_template("SECRETS", &decrypted_secrets?);
177: 175:     let processed_code = format!("{}\n\n{}", secrets_template, code);
178: 176: 
179: 177:     Ok(FunctionCode(processed_code))
180: 178: }
181: 179: 
182: 180: pub fn get_first_function_by_type(
183: 181:     function_type: FunctionType,
184: 182:     conn: &mut DBConnection,
185: 183:     schema_name: &SchemaName,
186: 184: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<FunctionInfo> {
187: 185:     let function = functions
188: 186:         .filter(schema::functions::function_type.eq(function_type))
189: 187:         .select(FunctionInfo::as_select())
190: 188:         .schema_name(schema_name)
191: 189:         .first(conn)?;
192: 190:     Ok(function)
193: 191: }
194: 192: 
195: 193: pub fn inject_secrets_and_variables_into_code(
196: 194:     code: &str,
197: 195:     conn: &mut DBConnection,
198: 196:     workspace_context: &WorkspaceContext,
199: 197:     master_encryption_key: &Option<EncryptionKey>,
200: 198: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<FunctionCode> {
201: 199:     let code_with_secrets =
202: 200:         inject_secrets_into_code(workspace_context, code, conn, master_encryption_key)?;
203: 201: 
204: 202:     let final_code = inject_variables_into_code(
205: 203:         &code_with_secrets,
206: 204:         conn,
207: 205:         &workspace_context.schema_name,
208: 206:     )?;
209: 207: 
210: 208:     Ok(final_code)
211: 209: }
212: 210: ```
213: 211: ```
214: 212: ```
215: 213: ```
216: ```
```
