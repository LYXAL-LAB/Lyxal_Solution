### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\context\validations.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\validations.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\validations.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\validations.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\validations.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\context\validations.rs
10: 8: ```rust
11: 9: use std::collections::HashMap;
12: 10: 
13: 11: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
14: 12: use jsonschema::{Draft, JSONSchema, ValidationError};
15: 13: use serde_json::{Map, Value};
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{helpers::validation_err_to_str, service::types::SchemaName};
17: 15: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, validation_error};
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{DBConnection, DimensionInfo, database::schema, result};
19: 17: 
20: 18: pub fn validate_override_with_default_configs(
21: 19:     conn: &mut DBConnection,
22: 20:     override_: &Map<String, Value>,
23: 21:     schema_name: &SchemaName,
24: 22: ) -> result::Result<()> {
25: 23:     let keys_array: Vec<&String> = override_.keys().collect();
26: 24:     let res: Vec<(String, Value)> = schema::default_configs::dsl::default_configs
27: 25:         .filter(schema::default_configs::dsl::key.eq_any(keys_array))
28: 26:         .select((
29: 27:             schema::default_configs::dsl::key,
30: 28:             schema::default_configs::dsl::schema,
31: 29:         ))
32: 30:         .schema_name(schema_name)
33: 31:         .get_results::<(String, Value)>(conn)?;
34: 32: 
35: 33:     let map = Map::from_iter(res);
36: 34: 
37: 35:     for (key, value) in override_.iter() {
38: 36:         let schema = map
39: 37:             .get(key)
40: 38:             .ok_or(bad_argument!("failed to get schema for config key {}", key))?;
41: 39:         let instance = value;
42: 40:         let schema_compile_result = JSONSchema::options()
43: 41:             .with_draft(Draft::Draft7)
44: 42:             .compile(schema);
45: 43:         let jschema = match schema_compile_result {
46: 44:             Ok(jschema) => jschema,
47: 45:             Err(e) => {
48: 46:                 log::info!("Failed to compile as a Draft-7 JSON schema: {e}");
49: 47:                 return Err(bad_argument!(
50: 48:                     "failed to compile ({}) config key schema",
51: 49:                     key
52: 50:                 ));
53: 51:             }
54: 52:         };
55: 53:         if let Err(e) = jschema.validate(instance) {
56: 54:             let verrors = e.collect::<Vec<ValidationError>>();
57: 55:             log::error!("({key}) config key validation error: {:?}", verrors);
58: 56:             return Err(validation_error!(
59: 57:                 "schema validation failed for {key}: {}",
60: 58:                 validation_err_to_str(verrors)
61: 59:                     .first()
62: 60:                     .unwrap_or(&String::new())
63: 61:             ));
64: 62:         };
65: 63:     }
66: 64: 
67: 65:     Ok(())
68: 66: }
69: 67: 
70: 68: pub fn validate_dimensions(
71: 69:     cond: &Map<String, Value>,
72: 70:     dimension_schema_map: &HashMap<String, DimensionInfo>,
73: 71: ) -> result::Result<()> {
74: 72:     for (dimension, value) in cond.iter() {
75: 73:         let dimension_data = dimension_schema_map
76: 74:             .get(dimension)
77: 75:             .ok_or(bad_argument!("No matching dimension ({}) found", dimension))?;
78: 76: 
79: 77:         let schema_value = Value::from(&dimension_data.schema);
80: 78:         validate_context_jsonschema(value, &schema_value)?;
81: 79:     }
82: 80:     Ok(())
83: 81: }
84: 82: 
85: 83: pub fn validate_context_jsonschema(
86: 84:     dimension_value: &Value,
87: 85:     dimension_schema: &Value,
88: 86: ) -> result::Result<()> {
89: 87:     let dimension_schema = JSONSchema::options()
90: 88:         .with_draft(Draft::Draft7)
91: 89:         .compile(dimension_schema)
92: 90:         .map_err(|e| {
93: 91:             log::error!(
94: 92:                 "Failed to compile as a Draft-7 JSON schema: {}",
95: 93:                 e.to_string()
96: 94:             );
97: 95:             bad_argument!("Error encountered: invalid jsonschema for dimension.")
98: 96:         })?;
99: 97: 
100: 98:     dimension_schema.validate(dimension_value).map_err(|e| {
101: 99:         let verrors = e.collect::<Vec<ValidationError>>();
102: 100:         log::error!(
103: 101:             "failed to validate dimension value {}: {:?}",
104: 102:             dimension_value.to_string(),
105: 103:             verrors
106: 104:         );
107: 105:         validation_error!(
108: 106:             "failed to validate dimension value {}: {}",
109: 107:             dimension_value.to_string(),
110: 108:             validation_err_to_str(verrors)
111: 109:                 .first()
112: 110:                 .unwrap_or(&String::new())
113: 111:         )
114: 112:     })
115: 113: }
116: 114: 
117: 115: // ************ Tests *************
118: 116: 
119: 117: #[cfg(test)]
120: 118: mod tests {
121: 119:     use serde_json::json;
122: 120: 
123: 121:     use super::*;
124: 122: 
125: 123:     #[test]
126: 124:     fn test_validate_context_jsonschema() {
127: 125:         let test_schema = json!({
128: 126:             "type": "string",
129: 127:             "pattern": ".*"
130: 128:         });
131: 129: 
132: 130:         let str_dimension_val = json!("string1".to_owned());
133: 131:         let ok_str_context =
134: 132:             validate_context_jsonschema(&str_dimension_val, &test_schema);
135: 133: 
136: 134:         assert!(ok_str_context.is_ok());
137: 135:     }
138: 136: }
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: ```
```
