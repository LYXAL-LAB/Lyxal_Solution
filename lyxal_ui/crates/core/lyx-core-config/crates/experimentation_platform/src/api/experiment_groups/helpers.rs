1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\helpers.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\helpers.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\helpers.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\helpers.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_experimentation_platform\src\api\experiment_groups\helpers.rs
10: 8: ```rust
11: 9: use std::collections::HashSet;
12: 10: 
13: 11: use actix_web::web::{Data, Json};
14: 12: use diesel::{
15: 13:     BoolExpressionMethods, ExpressionMethods, QueryDsl, RunQueryDsl, SelectableHelper,
16: 14: };
17: 15: use serde_json::Value;
18: 16: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
19: 17:     helpers::generate_snowflake_id,
20: 18:     service::types::{AppState, SchemaName, WorkspaceContext},
21: 19: };
22: 20: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros::{bad_argument, unexpected_error};
23: 21: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::{
24: 22:     Condition, DBConnection, User,
25: 23:     api::experiment_groups::ExpGroupMemberRequest,
26: 24:     database::{
27: 25:         models::{
28: 26:             ChangeReason, Description,
29: 27:             experimentation::{
30: 28:                 Bucket, Buckets, Experiment, ExperimentGroup, ExperimentStatusType,
31: 29:                 GroupType, TrafficPercentage,
32: 30:             },
33: 31:         },
34: 32:         schema::{
35: 33:             experiment_groups::dsl as experiment_groups, experiments::dsl as experiments,
36: 34:         },
37: 35:     },
38: 36:     result as lyx-core-lyx_core_lyx-core-lyx_core_superposition,
39: 37: };
40: 38: 
41: 39: use crate::api::experiments::helpers::{ensure_experiments_exist, hash};
42: 40: 
43: 41: pub fn fetch_and_validate_members(
44: 42:     new_members: &[i64],
45: 43:     existing_members: &[i64],
46: 44:     conn: &mut DBConnection,
47: 45:     schema_name: &SchemaName,
48: 46: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<Experiment>> {
49: 47:     if new_members.is_empty() {
50: 48:         return Ok(Vec::new());
51: 49:     }
52: 50:     let new_members = HashSet::from_iter(new_members.to_owned());
53: 51:     let existing_members = HashSet::from_iter(existing_members.to_owned());
54: 52:     let repeating_members = new_members
55: 53:         .intersection(&existing_members)
56: 54:         .collect::<Vec<_>>();
57: 55:     if !repeating_members.is_empty() {
58: 56:         return Err(bad_argument!(
59: 57:             "The new members list contains IDs that are already in the group: {}",
60: 58:             repeating_members
61: 59:                 .iter()
62: 60:                 .map(|id| id.to_string())
63: 61:                 .collect::<Vec<_>>()
64: 62:                 .join(", ")
65: 63:         ));
66: 64:     }
67: 65: 
68: 66:     let members: Vec<Experiment> = experiments::experiments
69: 67:         .filter(
70: 68:             experiments::id
71: 69:                 .eq_any(&new_members)
72: 70:                 .and(experiments::status.eq(ExperimentStatusType::CREATED)),
73: 71:         )
74: 72:         .schema_name(schema_name)
75: 73:         .get_results::<Experiment>(conn)?;
76: 74: 
77: 75:     ensure_experiments_exist(
78: 76:         &new_members,
79: 77:         &members,
80: 78:         "The following experiment IDs are not present in the database/are not in the created stage",
81: 79:     )?;
82: 80:     Ok(members)
83: 81: }
84: 82: 
85: 83: /// validates if the members in the members lit can be part of the experiment group
86: 84: /// it checks the following
87: 85: /// - if their contexts contain the group context
88: 86: /// - if the sum of their traffic percentages does not exceed 100%
89: 87: pub fn validate_experiment_group_constraints(
90: 88:     member_experiments: &[Experiment],
91: 89:     existing_members: &[i64],
92: 90:     group_context: &Condition,
93: 91: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Vec<i64>> {
94: 92:     let existing_members = HashSet::from_iter(existing_members.to_owned());
95: 93: 
96: 94:     for member_experiment in member_experiments.iter() {
97: 95:         if !member_experiment
98: 96:             .context
99: 97:             .contains(group_context)
100: 98:             .map_err(|e| bad_argument!("The contexts do not match. Error: {}", e))?
101: 99:         {
102: 100:             return Err(bad_argument!(
103: 101:                 "Experiment with id {} does not fit in with the experiment group. The contexts do not match.",
104: 102:                 member_experiment.id
105: 103:             ));
106: 104:         }
107: 105:     }
108: 106: 
109: 107:     let all_members = member_experiments
110: 108:         .iter()
111: 109:         .map(|exp| exp.id)
112: 110:         .collect::<HashSet<i64>>()
113: 111:         .union(&existing_members)
114: 112:         .cloned()
115: 113:         .collect::<Vec<_>>();
116: 114:     Ok(all_members)
117: 115: }
118: 116: 
119: 117: pub fn add_members(
120: 118:     exp_group_id: &i64,
121: 119:     member_experiments: &[Experiment],
122: 120:     mut req: ExpGroupMemberRequest,
123: 121:     conn: &mut DBConnection,
124: 122:     schema_name: &SchemaName,
125: 123:     user: &User,
126: 124: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
127: 125:     if req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.is_empty() {
128: 126:         return Err(bad_argument!(
129: 127:             "Please provide at least one experiment ID to add to the group"
130: 128:         ));
131: 129:     }
132: 130:     let experiment_group = fetch_experiment_group(exp_group_id, conn, schema_name)?;
133: 131: 
134: 132:     if experiment_group.group_type == GroupType::SystemGenerated {
135: 133:         return Err(bad_argument!(
136: 134:             "Cannot add members to a system-generated experiment groups."
137: 135:         ));
138: 136:     }
139: 137: 
140: 138:     req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids = validate_experiment_group_constraints(
141: 139:         member_experiments,
142: 140:         &experiment_group.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids,
143: 141:         &experiment_group.context,
144: 142:     )?;
145: 143: 
146: 144:     let updated_group = diesel::update(experiment_groups::experiment_groups)
147: 145:         .filter(experiment_groups::id.eq(exp_group_id))
148: 146:         .set((
149: 147:             req,
150: 148:             experiment_groups::last_modified_by.eq(user.email.clone()),
151: 149:             experiment_groups::last_modified_at.eq(chrono::Utc::now()),
152: 150:         ))
153: 151:         .returning(ExperimentGroup::as_returning())
154: 152:         .schema_name(schema_name)
155: 153:         .get_result(conn)?;
156: 154:     Ok(Json(updated_group))
157: 155: }
158: 156: 
159: 157: pub fn remove_members(
160: 158:     id: &i64,
161: 159:     mut req: ExpGroupMemberRequest,
162: 160:     conn: &mut DBConnection,
163: 161:     schema_name: &SchemaName,
164: 162:     user: &User,
165: 163: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<Json<ExperimentGroup>> {
166: 164:     if req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.is_empty() {
167: 165:         return Err(bad_argument!(
168: 166:             "Please provide at least one experiment ID to remove from the group"
169: 167:         ));
170: 168:     }
171: 169: 
172: 170:     let experiment_group = fetch_experiment_group(id, conn, schema_name)?;
173: 171: 
174: 172:     if experiment_group.group_type == GroupType::SystemGenerated {
175: 173:         return Err(bad_argument!(
176: 174:             "Cannot remove members from a system-generated experiment group."
177: 175:         ));
178: 176:     }
179: 177: 
180: 178:     let current_members: HashSet<i64> =
181: 179:         HashSet::from_iter(experiment_group.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.clone());
182: 180:     let members_to_remove = HashSet::from_iter(req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids);
183: 181:     req.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids = current_members
184: 182:         .difference(&members_to_remove)
185: 183:         .cloned()
186: 184:         .collect::<Vec<_>>();
187: 185: 
188: 186:     let experiments_to_remove: Vec<Experiment> = experiments::experiments
189: 187:         .filter(experiments::id.eq_any(members_to_remove.clone()))
190: 188:         .schema_name(schema_name)
191: 189:         .for_update()
192: 190:         .get_results::<Experiment>(conn)?;
193: 191: 
194: 192:     ensure_experiments_exist(
195: 193:         &HashSet::from_iter(members_to_remove),
196: 194:         &experiments_to_remove,
197: 195:         "The following experiment IDs are not present in the database",
198: 196:     )?;
199: 197: 
200: 198:     let mut buckets = experiment_group.buckets;
201: 199:     for member_experiment in &experiments_to_remove {
202: 200:         update_bucket_allocation(
203: 201:             member_experiment,
204: 202:             &mut buckets,
205: 203:             &TrafficPercentage::default(),
206: 204:         )?;
207: 205:     }
208: 206: 
209: 207:     let updated_group = diesel::update(experiment_groups::experiment_groups)
210: 208:         .filter(experiment_groups::id.eq(&id))
211: 209:         .set((
212: 210:             req,
213: 211:             experiment_groups::buckets.eq(buckets),
214: 212:             experiment_groups::last_modified_by.eq(user.email.clone()),
215: 213:             experiment_groups::last_modified_at.eq(chrono::Utc::now()),
216: 214:         ))
217: 215:         .returning(ExperimentGroup::as_returning())
218: 216:         .schema_name(schema_name)
219: 217:         .get_result(conn)?;
220: 218:     Ok(Json(updated_group))
221: 219: }
222: 220: 
223: 221: pub fn update_bucket_allocation(
224: 222:     experiment: &Experiment,
225: 223:     exp_group_buckets: &mut Buckets,
226: 224:     exp_traffic_percentage: &TrafficPercentage,
227: 225: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
228: 226:     let mut current_exp_buckets = vec![];
229: 227:     let mut unassigned_buckets = vec![];
230: 228: 
231: 229:     // Separate current exp buckets and unassigned buckets
232: 230:     for bucket in exp_group_buckets.iter_mut() {
233: 231:         if let Some(buck) = bucket {
234: 232:             if experiment.variants.iter().any(|v| v.id == *buck.variant_id) {
235: 233:                 current_exp_buckets.push(bucket);
236: 234:             }
237: 235:         } else {
238: 236:             unassigned_buckets.push(bucket);
239: 237:         }
240: 238:     }
241: 239: 
242: 240:     let required_bucket_count =
243: 241:         **exp_traffic_percentage as usize * experiment.variants.len();
244: 242:     let current_bucket_count = current_exp_buckets.len();
245: 243:     let bucket_diff = required_bucket_count.abs_diff(current_bucket_count);
246: 244: 
247: 245:     match required_bucket_count.cmp(&current_bucket_count) {
248: 246:         std::cmp::Ordering::Greater => {
249: 247:             assign_additional_buckets(&mut unassigned_buckets, experiment, bucket_diff)?;
250: 248:         }
251: 249:         std::cmp::Ordering::Less => {
252: 250:             unassign_excess_buckets(&mut current_exp_buckets, experiment, bucket_diff);
253: 251:         }
254: 252:         std::cmp::Ordering::Equal => (),
255: 253:     }
256: 254: 
257: 255:     Ok(())
258: 256: }
259: 257: 
260: 258: fn assign_additional_buckets(
261: 259:     unassigned_buckets: &mut Vec<&mut Option<Bucket>>,
262: 260:     experiment: &Experiment,
263: 261:     additional_needed: usize,
264: 262: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
265: 263:     if additional_needed > unassigned_buckets.len() {
266: 264:         return Err(bad_argument!(
267: 265:             "Not enough empty buckets to accommodate the updated traffic percentage. Required additional: {}, Available: {}",
268: 266:             additional_needed,
269: 267:             unassigned_buckets.len()
270: 268:         ));
271: 269:     }
272: 270:     let variants = experiment.variants.clone().into_inner();
273: 271:     let variants_len = variants.len();
274: 272: 
275: 273:     // Reverse the unassigned_buckets to fill from the front
276: 274:     unassigned_buckets.reverse();
277: 275: 
278: 276:     for variant in variants {
279: 277:         for _ in 0..additional_needed / variants_len {
280: 278:             if let Some(bucket) = unassigned_buckets.pop() {
281: 279:                 *bucket = Some(Bucket {
282: 280:                     experiment_id: experiment.id.to_string(),
283: 281:                     variant_id: variant.id.clone(),
284: 282:                 });
285: 283:             }
286: 284:         }
287: 285:     }
288: 286: 
289: 287:     Ok(())
290: 288: }
291: 289: 
292: 290: fn unassign_excess_buckets(
293: 291:     current_buckets: &mut [&mut Option<Bucket>],
294: 292:     experiment: &Experiment,
295: 293:     excess_count: usize,
296: 294: ) {
297: 295:     let variants = experiment.variants.clone().into_inner();
298: 296:     let variants_len = variants.len();
299: 297:     for variant in variants {
300: 298:         for _ in 0..excess_count / variants_len {
301: 299:             if let Some(bucket) = current_buckets
302: 300:                 .iter_mut()
303: 301:                 .rev()
304: 302:                 .find(|b| b.as_ref().is_some_and(|b| *b.variant_id == *variant.id))
305: 303:             {
306: 304:                 **bucket = None;
307: 305:             }
308: 306:         }
309: 307:     }
310: 308: }
311: 309: 
312: 310: pub fn detach_experiment_from_group(
313: 311:     experiment: &Experiment,
314: 312:     experiment_group_id: i64,
315: 313:     conn: &mut DBConnection,
316: 314:     workspace_context: &WorkspaceContext,
317: 315:     user: &User,
318: 316: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
319: 317:     let experiment_group = fetch_experiment_group(
320: 318:         &experiment_group_id,
321: 319:         conn,
322: 320:         &workspace_context.schema_name,
323: 321:     )?;
324: 322: 
325: 323:     let mut buckets = experiment_group.buckets;
326: 324:     update_bucket_allocation(experiment, &mut buckets, &TrafficPercentage::default())?;
327: 325: 
328: 326:     let mut member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids = experiment_group.member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids;
329: 327:     member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.retain(|&id| id != experiment.id);
330: 328: 
331: 329:     diesel::update(experiment_groups::experiment_groups)
332: 330:         .filter(experiment_groups::id.eq(&experiment_group_id))
333: 331:         .set((
334: 332:             experiment_groups::change_reason.eq(ChangeReason::try_from(format!(
335: 333:                 "Removed experiment {} from group {}",
336: 334:                 experiment.id, experiment_group_id
337: 335:             ))
338: 336:             .map_err(|e| unexpected_error!(e))?),
339: 337:             experiment_groups::member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids.eq(member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids),
340: 338:             experiment_groups::buckets.eq(buckets),
341: 339:             experiment_groups::last_modified_by.eq(user.email.clone()),
342: 340:             experiment_groups::last_modified_at.eq(chrono::Utc::now()),
343: 341:         ))
344: 342:         .returning(ExperimentGroup::as_returning())
345: 343:         .schema_name(&workspace_context.schema_name)
346: 344:         .execute(conn)?;
347: 345: 
348: 346:     if experiment_group.group_type == GroupType::SystemGenerated {
349: 347:         diesel::delete(experiment_groups::experiment_groups)
350: 348:             .filter(experiment_groups::id.eq(&experiment_group_id))
351: 349:             .schema_name(&workspace_context.schema_name)
352: 350:             .execute(conn)?;
353: 351:     }
354: 352: 
355: 353:     Ok(())
356: 354: }
357: 355: 
358: 356: pub fn create_system_generated_experiment_group(
359: 357:     experiment: &Experiment,
360: 358:     exp_traffic_percentage: &TrafficPercentage,
361: 359:     state: &Data<AppState>,
362: 360:     conn: &mut DBConnection,
363: 361:     schema_name: &SchemaName,
364: 362:     user: &User,
365: 363: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<ExperimentGroup> {
366: 364:     let context = experiment.context.clone();
367: 365:     let id = generate_snowflake_id(state)?;
368: 366:     let context_hash = hash(&Value::Object(context.clone().into()));
369: 367:     let now = chrono::Utc::now();
370: 368: 
371: 369:     let variants = experiment.variants.clone().into_inner();
372: 370:     let group_traffic_percentage =
373: 371:         TrafficPercentage::try_from(variants.len() as u8 * **exp_traffic_percentage)
374: 372:             .map_err(|e| unexpected_error!(e))?;
375: 373: 
376: 374:     let mut buckets = Buckets::default();
377: 375:     update_bucket_allocation(experiment, &mut buckets, exp_traffic_percentage)?;
378: 376: 
379: 377:     let new_experiment_group = ExperimentGroup {
380: 378:         id,
381: 379:         context_hash,
382: 380:         name: experiment.name.clone(),
383: 381:         description: Description::try_from(format!(
384: 382:             "Experiment group for experiment {}",
385: 383:             experiment.name
386: 384:         ))
387: 385:         .map_err(|e| unexpected_error!(e))?,
388: 386:         change_reason: ChangeReason::try_from(format!(
389: 387:             "System generated experiment group for experiment {}",
390: 388:             experiment.id
391: 389:         ))
392: 390:         .map_err(|e| unexpected_error!(e))?,
393: 391:         created_by: user.get_email(),
394: 392:         last_modified_by: user.get_email(),
395: 393:         created_at: now,
396: 394:         last_modified_at: now,
397: 395:         context,
398: 396:         traffic_percentage: group_traffic_percentage,
399: 397:         member_experiment_lyx-core-lyx_core_lyx-core-lyx_core_ids: vec![experiment.id],
400: 398:         buckets,
401: 399:         group_type: GroupType::SystemGenerated,
402: 400:     };
403: 401:     let new_experiment_group = diesel::insert_into(experiment_groups::experiment_groups)
404: 402:         .values(&new_experiment_group)
405: 403:         .returning(ExperimentGroup::as_returning())
406: 404:         .schema_name(schema_name)
407: 405:         .get_result::<ExperimentGroup>(conn)?;
408: 406:     Ok(new_experiment_group)
409: 407: }
410: 408: 
411: 409: pub fn update_experiment_group_buckets(
412: 410:     experiment: &Experiment,
413: 411:     experiment_group_id: &i64,
414: 412:     exp_traffic_percentage: &TrafficPercentage,
415: 413:     conn: &mut DBConnection,
416: 414:     schema_name: &SchemaName,
417: 415:     user: &User,
418: 416: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<()> {
419: 417:     let experiment_group =
420: 418:         fetch_experiment_group(experiment_group_id, conn, schema_name)?;
421: 419: 
422: 420:     let new_traffic_percentage = match experiment_group.group_type {
423: 421:         GroupType::SystemGenerated => TrafficPercentage::try_from(
424: 422:             experiment.variants.clone().into_inner().len() as i32
425: 423:                 * (**exp_traffic_percentage as i32),
426: 424:         )
427: 425:         .map_err(|e| unexpected_error!(e))?,
428: 426:         GroupType::UserCreated => experiment_group.traffic_percentage,
429: 427:     };
430: 428: 
431: 429:     let mut buckets = experiment_group.buckets;
432: 430:     update_bucket_allocation(experiment, &mut buckets, exp_traffic_percentage)?;
433: 431: 
434: 432:     diesel::update(experiment_groups::experiment_groups)
435: 433:         .filter(experiment_groups::id.eq(experiment_group.id))
436: 434:         .set((
437: 435:             experiment_groups::buckets.eq(buckets),
438: 436:             experiment_groups::traffic_percentage.eq(new_traffic_percentage),
439: 437:             experiment_groups::change_reason.eq(ChangeReason::try_from(format!(
440: 438:                 "Updated traffic percentage for experiment group {}",
441: 439:                 experiment_group.id
442: 440:             ))
443: 441:             .map_err(|e| unexpected_error!(e))?),
444: 442:             experiment_groups::last_modified_by.eq(user.get_email()),
445: 443:             experiment_groups::last_modified_at.eq(chrono::Utc::now()),
446: 444:         ))
447: 445:         .returning(ExperimentGroup::as_returning())
448: 446:         .schema_name(schema_name)
449: 447:         .execute(conn)?;
450: 448:     Ok(())
451: 449: }
452: 450: 
453: 451: pub fn fetch_experiment_group(
454: 452:     id: &i64,
455: 453:     conn: &mut DBConnection,
456: 454:     schema_name: &SchemaName,
457: 455: ) -> lyx-core-lyx_core_lyx-core-lyx_core_superposition::Result<ExperimentGroup> {
458: 456:     let experiment_group = experiment_groups::experiment_groups
459: 457:         .filter(experiment_groups::id.eq(id))
460: 458:         .schema_name(schema_name)
461: 459:         .for_update()
462: 460:         .get_result::<ExperimentGroup>(conn)?;
463: 461:     Ok(experiment_group)
464: 462: }
465: 463: ```
466: 464: ```
467: 465: ```
468: 466: ```
469: ```
```

