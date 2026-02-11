### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_context_aware_config\src\api\dimension\validations.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\validations.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\validations.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\validations.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\validations.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config\src\api\dimension\validations.rs
10: 8: ```rust
11: 9: use std::collections::HashSet;
12: 10: 
13: 11: use diesel::{ExpressionMethods, OptionalExtension, QueryDsl, RunQueryDsl};
14: 12: use jsonschema::{Draft, JSONSchema, ValidationError};
15: 13: use serde_json::{Map, Value, json};
16: 14: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
17: 15:     helpers::{fetch_dimensions_info_map, validation_err_to_str},
18: 16:     service::types::SchemaName,
19: 17: };
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{unexpected_error, validation_error};
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
22: 20:     DBConnection,
23: 21:     api::dimension::DimensionName,
24: 22:     database::{
25: 23:         models::cac::{Dimension, DimensionType, FunctionType, Position},
26: 24:         schema::dimensions,
27: 25:     },
28: 26:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
29: 27: };
30: 28: 
31: 29: use crate::api::functions::helpers::check_fn_published;
32: 30: 
33: 31: pub fn validate_dimension_position(
34: 32:     dimension_name: DimensionName,
35: 33:     dimension_position: Position,
36: 34:     max_allowed: i64,
37: 35: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
38: 36:     let dimension_name: String = dimension_name.into();
39: 37:     let dimension_position: i32 = dimension_position.into();
40: 38:     match (dimension_name.as_str(), dimension_position) {
41: 39:         ("variantIds", 0) => Ok(()),
42: 40:         ("variantIds", d_position) => {
43: 41:             log::error!("invalid position: {d_position} for dimension: variantIds",);
44: 42:             Err(validation_error!(
45: 43:                 "variantIds' position should be equal to 0"
46: 44:             ))
47: 45:         }
48: 46:         (_, 0) => {
49: 47:             log::error!("invalid position: 0 for dimension: {dimension_name}",);
50: 48:             Err(validation_error!("Oth position is reserved for variantIds"))
51: 49:         }
52: 50:         (_, d_position) if d_position as i64 > max_allowed => {
53: 51:             log::error!(
54: 52:                 "position {d_position} value exceeds total number of dimensions {max_allowed}"
55: 53:             );
56: 54:             Err(validation_error!(
57: 55:                 "position value exceeds total number of dimensions"
58: 56:             ))
59: 57:         }
60: 58:         _ => Ok(()),
61: 59:     }
62: 60: }
63: 61: 
64: 62: pub fn validate_position_wrt_dependency(
65: 63:     dimension_name: &str,
66: 64:     position: &Position,
67: 65:     conn: &mut DBConnection,
68: 66:     schema_name: &SchemaName,
69: 67: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
70: 68:     let dimensions_info = fetch_dimensions_info_map(conn, schema_name)?;
71: 69: 
72: 70:     let Some(dimension) = dimensions_info.get(dimension_name) else {
73: 71:         return Err(unexpected_error!(
74: 72:             "Dimension {} not found while validating position with respect to dependencies",
75: 73:             dimension_name
76: 74:         ));
77: 75:     };
78: 76: 
79: 77:     let Some(dependent_dimensions) = dimension.dependency_graph.0.get(dimension_name)
80: 78:     else {
81: 79:         return Ok(());
82: 80:     };
83: 81: 
84: 82:     for dep_dimension in dependent_dimensions {
85: 83:         let Some(dep_dimension_info) = dimensions_info.get(dep_dimension) else {
86: 84:             return Err(unexpected_error!(
87: 85:                 "Dependent Dimension {} not found while validating position with respect to dependencies",
88: 86:                 dep_dimension
89: 87:             ));
90: 88:         };
91: 89: 
92: 90:         if dep_dimension_info.position >= **position {
93: 91:             return Err(validation_error!(
94: 92:                 "Position value invalid: position must be greater than the position of dependent dimension {} which is {}",
95: 93:                 dep_dimension,
96: 94:                 dep_dimension_info.position,
97: 95:             ));
98: 96:         }
99: 97:     }
100: 98: 
101: 99:     Ok(())
102: 100: }
103: 101: 
104: 102: pub fn get_cohort_meta_schema() -> JSONSchema {
105: 103:     let my_schema = json!({
106: 104:         "type": "object",
107: 105:         "properties": {
108: 106:             "type": { "type": "string" },
109: 107:             "enum": {
110: 108:                 "type": "array",
111: 109:                 "items": { "type": "string" },
112: 110:                 "contains": { "const": "otherwise" },
113: 111:                 "minContains": 1,
114: 112:                 "uniqueItems": true
115: 113:             },
116: 114:             "definitions": {
117: 115:                 "type": "object",
118: 116:                 "not": {
119: 117:                     "required": ["otherwise"]
120: 118:                 }
121: 119:             }
122: 120:         },
123: 121:         "required": ["type", "enum", "definitions"]
124: 122:     });
125: 123: 
126: 124:     JSONSchema::options()
127: 125:         .with_draft(Draft::Draft7)
128: 126:         .compile(&my_schema)
129: 127:         .expect("Error encountered: Failed to compile 'context_dimension_schema_value'. Ensure it adheres to the correct format and data type.")
130: 128: }
131: 129: 
132: 130: /*
133: 131:   This step is required because an empty object
134: 132:   is also a valid JSON schema. So added required
135: 133:   validations for the input.
136: 134: */
137: 135: // TODO: Recursive validation.
138: 136: 
139: 137: pub fn validate_jsonschema(
140: 138:     validation_schema: &JSONSchema,
141: 139:     schema: &Value,
142: 140: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
143: 141:     JSONSchema::options()
144: 142:         .with_draft(Draft::Draft7)
145: 143:         .compile(schema)
146: 144:         .map_err(|e| {
147: 145:             validation_error!("Invalid JSON schema (failed to compile): {:?}", e)
148: 146:         })?;
149: 147:     validation_schema.validate(schema).map_err(|e| {
150: 148:         let verrors = e.collect::<Vec<ValidationError>>();
151: 149:         validation_error!(
152: 150:             "schema validation failed: {}",
153: 151:             validation_err_to_str(verrors)
154: 152:                 .first()
155: 153:                 .unwrap_or(&String::new())
156: 154:         )
157: 155:     })
158: 156: }
159: 157: 
160: 158: pub fn allow_primitive_types(schema: &Map<String, Value>) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
161: 159:     match schema.get("type").cloned().unwrap_or_default() {
162: 160:         Value::String(type_val) if type_val != "array" && type_val != "object" => Ok(()),
163: 161:         Value::Array(arr)
164: 162:             if arr
165: 163:                 .iter()
166: 164:                 .all(|v| v.as_str().is_some_and(|s| s != "array" && s != "object")) =>
167: 165:         {
168: 166:             Ok(())
169: 167:         }
170: 168:         _ => Err(validation_error!(
171: 169:             "Invalid schema: expected a primitive type or an array of primitive types, found: {:?}",
172: 170:             schema
173: 171:         )),
174: 172:     }
175: 173: }
176: 174: 
177: 175: fn validate_cohort_jsonschema(schema: &Value) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<String>> {
178: 176:     let meta_schema = get_cohort_meta_schema();
179: 177:     JSONSchema::options()
180: 178:         .with_draft(Draft::Draft7)
181: 179:         .compile(schema)
182: 180:         .map_err(|e| {
183: 181:             validation_error!("Invalid JSON schema (failed to compile): {:?}", e)
184: 182:         })?;
185: 183:     meta_schema.validate(schema).map_err(|e| {
186: 184:         let verrors = e.collect::<Vec<ValidationError>>();
187: 185:         validation_error!(
188: 186:             "schema validation failed: {}",
189: 187:             validation_err_to_str(verrors)
190: 188:                 .first()
191: 189:                 .unwrap_or(&String::new())
192: 190:         )
193: 191:     })?;
194: 192:     let enum_options = schema
195: 193:         .get("enum")
196: 194:         .and_then(|v| v.as_array())
197: 195:         .ok_or_else(|| {
198: 196:             validation_error!("Cohort schema must have an 'enum' field of type array")
199: 197:         })?
200: 198:         .iter()
201: 199:         .filter_map(|v| v.as_str().map(str::to_string))
202: 200:         .collect::<Vec<String>>();
203: 201:     Ok(enum_options)
204: 202: }
205: 203: 
206: 204: pub fn does_dimension_exist_for_cohorting(
207: 205:     dim: &str,
208: 206:     schema_name: &SchemaName,
209: 207:     conn: &mut DBConnection,
210: 208: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Dimension> {
211: 209:     if let Some(dim) = dimensions::dsl::dimensions
212: 210:         .filter(dimensions::dsl::dimension.eq(dim))
213: 211:         .schema_name(schema_name)
214: 212:         .get_result::<Dimension>(conn)
215: 213:         .optional()?
216: 214:     {
217: 215:         match dim.dimension_type {
218: 216:             DimensionType::LocalCohort(_) => Err(validation_error!(
219: 217:                 "Dimension {} is a local cohort and cannot be used in cohorting",
220: 218:                 &dim.dimension
221: 219:             )),
222: 220:             _ => Ok(dim),
223: 221:         }
224: 222:     } else {
225: 223:         Err(validation_error!(
226: 224:             "Dimension {} used in cohort schema has not been created or does not exist. Please create the dimension first before using it in cohort schema.",
227: 225:             dim
228: 226:         ))
229: 227:     }
230: 228: }
231: 229: 
232: 230: pub fn validate_cohort_position(
233: 231:     position: &Position,
234: 232:     based_on_dimension: &Dimension,
235: 233:     create: bool,
236: 234: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
237: 235:     if create && *position > based_on_dimension.position {
238: 236:         return Err(validation_error!(
239: 237:             "While creating dimension, Cohort dimension position {} must be less than or equal to the position {} of the dimension it is based on",
240: 238:             **position,
241: 239:             *based_on_dimension.position
242: 240:         ));
243: 241:     } else if !create && *position >= based_on_dimension.position {
244: 242:         return Err(validation_error!(
245: 243:             "While updating dimension, Cohort dimension position {} must be less than the position {} of the dimension it is based on",
246: 244:             **position,
247: 245:             *based_on_dimension.position
248: 246:         ));
249: 247:     }
250: 248:     Ok(())
251: 249: }
252: 250: 
253: 251: pub fn validate_value_compute_function(
254: 252:     dimension_type: &DimensionType,
255: 253:     function: &Option<String>,
256: 254:     conn: &mut DBConnection,
257: 255:     schema_name: &SchemaName,
258: 256: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
259: 257:     let fn_type = FunctionType::ValueCompute;
260: 258:     match dimension_type {
261: 259:         DimensionType::LocalCohort(_) if function.is_some() => Err(validation_error!(
262: 260:             "Value Compute function should not be provided for local cohort dimensions"
263: 261:         )),
264: 262:         DimensionType::RemoteCohort(_) => {
265: 263:             if let Some(func_name) = function {
266: 264:                 check_fn_published(func_name, fn_type, conn, schema_name)
267: 265:             } else {
268: 266:                 Err(validation_error!(
269: 267:                     "Value Compute function must be provided for remote cohort dimensions"
270: 268:                 ))
271: 269:             }
272: 270:         }
273: 271:         _ => {
274: 272:             if let Some(func_name) = function {
275: 273:                 check_fn_published(func_name, fn_type, conn, schema_name)
276: 274:             } else {
277: 275:                 Ok(())
278: 276:             }
279: 277:         }
280: 278:     }
281: 279: }
282: 280: pub fn validate_validation_function(
283: 281:     function: &Option<String>,
284: 282:     conn: &mut DBConnection,
285: 283:     schema_name: &SchemaName,
286: 284: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
287: 285:     if let Some(func_name) = function {
288: 286:         check_fn_published(func_name, FunctionType::ValueValidation, conn, schema_name)
289: 287:     } else {
290: 288:         Ok(())
291: 289:     }
292: 290: }
293: 291: 
294: 292: pub fn validate_cohort_schema(
295: 293:     cohort_schema: &Value,
296: 294:     cohort_based_on: &String,
297: 295:     schema_name: &SchemaName,
298: 296:     conn: &mut DBConnection,
299: 297: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Dimension> {
300: 298:     if cohort_based_on.is_empty() {
301: 299:         return Err(validation_error!(
302: 300:             "Please specify a valid dimension that this cohort can derive from. Refer our API docs for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples",
303: 301:         ));
304: 302:     }
305: 303: 
306: 304:     let enum_options = validate_cohort_jsonschema(cohort_schema)?;
307: 305: 
308: 306:     let cohort_schema = cohort_schema.get("definitions").ok_or(validation_error!(
309: 307:         "Local cohorts require the jsonlogic rules to be written in the `definitions` field. Refer our API docs for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples",
310: 308:     ))?;
311: 309: 
312: 310:     let logic = match cohort_schema {
313: 311:         Value::Object(logic) if logic.is_empty() => {
314: 312:             return Err(validation_error!(
315: 313:                 "Empty object is not allowed as a schema, mention at least one cohort"
316: 314:             ));
317: 315:         }
318: 316:         Value::Object(logic) => {
319: 317:             let cohort_options = logic.keys();
320: 318:             if cohort_options.len() != enum_options.len() - 1 {
321: 319:                 return Err(validation_error!(
322: 320:                     "The definition of the cohort and the enum options do not match. Some enum options do not have a definition, found {} cohorts and {} enum options (not including otherwise)",
323: 321:                     cohort_options.len(),
324: 322:                     enum_options.len() - 1
325: 323:                 ));
326: 324:             }
327: 325:             for cohort in cohort_options {
328: 326:                 if !enum_options.contains(cohort) {
329: 327:                     return Err(validation_error!(
330: 328:                         "Cohort {} does not have a corresponding enum option",
331: 329:                         cohort
332: 330:                     ));
333: 331:                 }
334: 332:             }
335: 333:             logic
336: 334:         }
337: 335:         _ => {
338: 336:             return Err(validation_error!(
339: 337:                 "Invalid JSON Logic schema: expected an object, found: {}",
340: 338:                 cohort_schema
341: 339:             ));
342: 340:         }
343: 341:     };
344: 342: 
345: 343:     // check if only one dimension is used across all cohort enums
346: 344:     let mut dimensions_used = HashSet::new();
347: 345: 
348: 346:     for (cohort_option, expression) in logic.iter() {
349: 347:         let ast =
350: 348:             jsonlogic::expression::Expression::from_json(expression).map_err(|e| {
351: 349:                 validation_error!(
352: 350:                     "Invalid JSON Logic schema for cohort {}, found: {}",
353: 351:                     cohort_option,
354: 352:                     e
355: 353:                 )
356: 354:             })?;
357: 355: 
358: 356:         let dims = ast.get_variable_names().map_err(|e| {
359: 357:             validation_error!(
360: 358:                 "Invalid JSON Logic in cohort {}, error while parsing variable names: {}",
361: 359:                 cohort_option,
362: 360:                 e
363: 361:             )
364: 362:         })?;
365: 363:         dimensions_used.extend(dims);
366: 364:     }
367: 365: 
368: 366:     let dimensions_used = dimensions_used.into_iter().collect::<Vec<_>>();
369: 367: 
370: 368:     match dimensions_used[..] {
371: 369:         [] => {
372: 370:             // no dimensions? not allowed
373: 371:             Err(validation_error!(
374: 372:                 "No dimensions used in cohort schema, one dimension is required"
375: 373:             ))
376: 374:         }
377: 375:         [ref dim] => {
378: 376:             // check if the single dimension used exists in the dimensions table
379: 377:             let based_on_dimension =
380: 378:                 does_dimension_exist_for_cohorting(dim, schema_name, conn)?;
381: 379:             if dim != cohort_based_on {
382: 380:                 return Err(validation_error!(
383: 381:                     "Dimension used in cohort schema ({}) does not match the dimension specified in cohort_based_on ({})",
384: 382:                     dim,
385: 383:                     cohort_based_on
386: 384:                 ));
387: 385:             }
388: 386:             Ok(based_on_dimension)
389: 387:         }
390: 388:         _ => {
391: 389:             // more than one dimension? not allowed
392: 390:             Err(validation_error!(
393: 391:                 "Multiple dimensions used in cohort schema and that is not allowed: {:?}",
394: 392:                 dimensions_used
395: 393:             ))
396: 394:         }
397: 395:     }
398: 396: }
399: 397: 
400: 398: // ************ Tests *************
401: 399: 
402: 400: #[cfg(test)]
403: 401: mod tests {
404: 402:     use crate::helpers::get_meta_schema;
405: 403: 
406: 404:     use super::*;
407: 405: 
408: 406:     #[test]
409: 407:     fn test_get_meta_schema() {
410: 408:         let x = get_meta_schema();
411: 409: 
412: 410:         let ok_string_schema = json!({"type": "string", "pattern": ".*"});
413: 411:         let ok_string_validation = x.validate(&ok_string_schema);
414: 412:         assert!(ok_string_validation.is_ok());
415: 413: 
416: 414:         let error_object_schema = json!({"type": "object"});
417: 415:         let error_object_validation = x.validate(&error_object_schema).map_err(|e| {
418: 416:             let verrors = e.collect::<Vec<ValidationError>>();
419: 417:             format!(
420: 418:                 "Error While validating object dataType, Bad schema: {:?}",
421: 419:                 verrors.as_slice()
422: 420:             )
423: 421:         });
424: 422:         assert!(error_object_validation.is_err_and(|error| error.contains("Bad schema")));
425: 423: 
426: 424:         let ok_enum_schema = json!({"type": "string", "enum": ["ENUMVAL"]});
427: 425:         let ok_enum_validation = x.validate(&ok_enum_schema);
428: 426:         assert!(ok_enum_validation.is_ok());
429: 427:     }
430: 428: }
431: 429: ```
432: 430: ```
433: 431: ```
434: 432: ```
435: ```
```
