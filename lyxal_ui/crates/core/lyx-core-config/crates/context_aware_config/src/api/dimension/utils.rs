1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\utils.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\utils.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\utils.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\utils.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\utils.rs
10: 8: ```rust
11: 9: use chrono::Utc;
12: 10: use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::service::types::SchemaName;
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::unexpected_error;
15: 13: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
16: 14:     Cac, Condition, DBConnection,
17: 15:     database::{
18: 16:         models::{
19: 17:             ChangeReason,
20: 18:             cac::{Context, Dimension},
21: 19:         },
22: 20:         schema::{contexts::dsl::contexts, dimensions::dsl::*},
23: 21:     },
24: 22:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
25: 23: };
26: 24: 
27: 25: pub fn get_dimensions_data(
28: 26:     conn: &mut DBConnection,
29: 27:     schema_name: &SchemaName,
30: 28: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<Dimension>> {
31: 29:     Ok(dimensions
32: 30:         .schema_name(schema_name)
33: 31:         .load::<Dimension>(conn)?)
34: 32: }
35: 33: 
36: 34: pub fn get_dimension_usage_context_lyx-core-lyx_core_lyx-core-lyx_core_ids(
37: 35:     key: &str,
38: 36:     conn: &mut DBConnection,
39: 37:     schema_name: &SchemaName,
40: 38: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<String>> {
41: 39:     let result: Vec<Context> = contexts.schema_name(schema_name).load(conn)?;
42: 40: 
43: 41:     let mut context_lyx-core-lyx_core_lyx-core-lyx_core_ids = vec![];
44: 42:     for context in result.iter() {
45: 43:         let condition = Cac::<Condition>::validate_db_data(context.value.clone().into())
46: 44:             .map_err(|err| {
47: 45:                 log::error!("generate_cac : failed to decode context from db {}", err);
48: 46:                 unexpected_error!(err)
49: 47:             })?
50: 48:             .into_inner();
51: 49: 
52: 50:         if condition.get(key).is_some() {
53: 51:             context_lyx-core-lyx_core_lyx-core-lyx_core_ids.push(context.id.to_owned())
54: 52:         }
55: 53:     }
56: 54:     Ok(context_lyx-core-lyx_core_lyx-core-lyx_core_ids)
57: 55: }
58: 56: 
59: 57: /// Update the dependency graph of the cohorted dimension
60: 58: /// Follow its parents and update their graphs as well
61: 59: pub fn create_connections_with_dependents(
62: 60:     cohorted_dimension: &str,
63: 61:     dimension_name: &str,
64: 62:     user_email: &str,
65: 63:     schema_name: &SchemaName,
66: 64:     conn: &mut DBConnection,
67: 65: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
68: 66:     let mut dimensions_vector = get_dimensions_data(conn, schema_name)?;
69: 67:     let reason = format!(
70: 68:         "System Auto updated the dependency graph due to the creation of {}",
71: 69:         dimension_name
72: 70:     );
73: 71:     for dim in dimensions_vector.iter_mut() {
74: 72:         if dim.dimension == cohorted_dimension
75: 73:             && !dim.dependency_graph.contains_key(cohorted_dimension)
76: 74:         {
77: 75:             dim.dependency_graph
78: 76:                 .insert(cohorted_dimension.to_string(), vec![]);
79: 77:         }
80: 78:         if let Some(current_deps) = dim.dependency_graph.get_mut(cohorted_dimension) {
81: 79:             current_deps.push(dimension_name.to_string());
82: 80:             dim.dependency_graph
83: 81:                 .insert(dimension_name.to_string(), vec![]);
84: 82:             update_dimensions_in_db(dim, &reason, user_email, schema_name, conn)?;
85: 83:         }
86: 84:     }
87: 85:     Ok(())
88: 86: }
89: 87: 
90: 88: /// Update the dependency graph of the cohorted dimension
91: 89: /// Follow its parents and update their graphs as well
92: 90: pub fn remove_connections_with_dependents(
93: 91:     deleted_dimension_name: &str,
94: 92:     cohorted_dimension: &str,
95: 93:     user_email: &str,
96: 94:     schema_name: &SchemaName,
97: 95:     conn: &mut DBConnection,
98: 96: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
99: 97:     let mut dimensions_vector = get_dimensions_data(conn, schema_name)?;
100: 98:     let reason = format!(
101: 99:         "System Auto updated the dependency graph due to the removal of {}",
102: 100:         deleted_dimension_name
103: 101:     );
104: 102:     for dim in dimensions_vector.iter_mut() {
105: 103:         let mut to_be_updated = dim.dimension == cohorted_dimension;
106: 104:         dim.dependency_graph.remove(deleted_dimension_name);
107: 105:         if let Some(current_deps) = dim.dependency_graph.get_mut(cohorted_dimension) {
108: 106:             current_deps.retain(|d| d != deleted_dimension_name);
109: 107:             if current_deps.is_empty() && dim.dimension == cohorted_dimension {
110: 108:                 dim.dependency_graph.remove(cohorted_dimension);
111: 109:             }
112: 110:             to_be_updated = true;
113: 111:         }
114: 112:         if to_be_updated {
115: 113:             update_dimensions_in_db(dim, &reason, user_email, schema_name, conn)?;
116: 114:         }
117: 115:     }
118: 116:     Ok(())
119: 117: }
120: 118: 
121: 119: fn update_dimensions_in_db(
122: 120:     dimension_data: &mut Dimension,
123: 121:     reason: &str,
124: 122:     user_email: &str,
125: 123:     schema_name: &SchemaName,
126: 124:     conn: &mut DBConnection,
127: 125: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
128: 126:     let reason =
129: 127:         ChangeReason::try_from(reason.to_string()).map_err(|e| unexpected_error!(e))?;
130: 128:     dimension_data.change_reason = reason.clone();
131: 129:     dimension_data.last_modified_by = user_email.to_string();
132: 130:     dimension_data.last_modified_at = Utc::now();
133: 131:     diesel::update(dimensions)
134: 132:         .filter(dimension.eq(&dimension_data.dimension))
135: 133:         .set(dimension_data.clone())
136: 134:         .schema_name(schema_name)
137: 135:         .execute(conn)?;
138: 136:     Ok(())
139: 137: }
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: ```
```

