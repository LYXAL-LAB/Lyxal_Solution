### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\auto_placement.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\auto_placement.rs
2: ```rust
3: 1: use lyx_ui_foundations_utils::{
4: 2:     ALL_PLACEMENTS, Alignment, Placement, get_alignment, get_alignment_sides,
5: 3:     get_opposite_alignment_placement, get_side,
6: 4: };
7: 5: use serde::{Deserialize, Serialize};
8: 6: 
9: 7: use crate::{
10: 8:     detect_overflow::{DetectOverflowOptions, detect_overflow},
11: 9:     types::{
12: 10:         Derivable, DerivableFn, Middleware, MiddlewareReturn, MiddlewareState,
13: 11:         MiddlewareWithOptions, Reset, ResetValue,
14: 12:     },
15: 13: };
16: 14: 
17: 15: fn get_placement_list(
18: 16:     alignment: Option<Alignment>,
19: 17:     auto_alignment: bool,
20: 18:     allowed_placements: Vec<Placement>,
21: 19: ) -> Vec<Placement> {
22: 20:     let allowed_placements_sorted_by_alignment: Vec<Placement> = match alignment {
23: 21:         Some(alignment) => {
24: 22:             let mut list = vec![];
25: 23: 
26: 24:             list.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(
27: 25:                 &mut allowed_placements
28: 26:                     .clone()
29: 27:                     .into_iter()
30: 28:                     .filter(|placement| get_alignment(*placement) == Some(alignment))
31: 29:                     .collect(),
32: 30:             );
33: 31: 
34: 32:             list.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(
35: 33:                 &mut allowed_placements
36: 34:                     .clone()
37: 35:                     .into_iter()
38: 36:                     .filter(|placement| get_alignment(*placement) != Some(alignment))
39: 37:                     .collect(),
40: 38:             );
41: 39: 
42: 40:             list
43: 41:         }
44: 42:         None => allowed_placements
45: 43:             .into_iter()
46: 44:             .filter(|placement| get_alignment(*placement).is_none())
47: 45:             .collect(),
48: 46:     };
49: 47: 
50: 48:     allowed_placements_sorted_by_alignment
51: 49:         .into_iter()
52: 50:         .filter(|placement| match alignment {
53: 51:             Some(alignment) => {
54: 52:                 get_alignment(*placement) == Some(alignment)
55: 53:                     || (if auto_alignment {
56: 54:                         get_opposite_alignment_placement(*placement) != *placement
57: 55:                     } else {
58: 56:                         false
59: 57:                     })
60: 58:             }
61: 59:             None => true,
62: 60:         })
63: 61:         .collect()
64: 62: }
65: 63: 
66: 64: /// Name of the [`AutoPlacement`] middleware.
67: 65: pub const AUTO_PLACEMENT_NAME: &str = "autoPlacement";
68: 66: 
69: 67: /// Options for [`AutoPlacement`] middleware.
70: 68: #[derive(Clone, Debug, PartialEq)]
71: 69: pub struct AutoPlacementOptions<Element: Clone> {
72: 70:     /// Options for [`detect_overflow`].
73: 71:     ///
74: 72:     /// Defaults to [`DetectOverflowOptions::default`].
75: 73:     pub detect_overflow: Option<DetectOverflowOptions<Element>>,
76: 74: 
77: 75:     /// The axis that runs along the alignment of the floating element. Determines whether to check for most space along this axis.
78: 76:     ///
79: 77:     /// Defaults to `false`.
80: 78:     pub cross_axis: Option<bool>,
81: 79: 
82: 80:     /// Choose placements with a particular alignment.
83: 81:     ///
84: 82:     /// Defaults to [`Option::None`].
85: 83:     pub alignment: Option<Alignment>,
86: 84: 
87: 85:     /// Whether to choose placements with the opposite alignment if the preferred alignment does not fit.
88: 86:     ///
89: 87:     /// Defaults to `true`.
90: 88:     pub auto_alignment: Option<bool>,
91: 89: 
92: 90:     /// Which placements are allowed to be chosen. Placements must be within the [`alignment`][`Self::alignment`] option if explicitly set.
93: 91:     ///
94: 92:     /// Defaults to all possible placements.
95: 93:     pub allowed_placements: Option<Vec<Placement>>,
96: 94: }
97: 95: 
98: 96: impl<Element: Clone> AutoPlacementOptions<Element> {
99: 97:     /// Set `detect_overflow` option.
100: 98:     pub fn detect_overflow(mut self, value: DetectOverflowOptions<Element>) -> Self {
101: 99:         self.detect_overflow = Some(value);
102: 100:         self
103: 101:     }
104: 102: 
105: 103:     /// Set `cross_axis` option.
106: 104:     pub fn cross_axis(mut self, value: bool) -> Self {
107: 105:         self.cross_axis = Some(value);
108: 106:         self
109: 107:     }
110: 108: 
111: 109:     /// Set `alignment` option.
112: 110:     pub fn alignment(mut self, value: Alignment) -> Self {
113: 111:         self.alignment = Some(value);
114: 112:         self
115: 113:     }
116: 114: 
117: 115:     /// Set `auto_alignment` option.
118: 116:     pub fn auto_alignment(mut self, value: bool) -> Self {
119: 117:         self.auto_alignment = Some(value);
120: 118:         self
121: 119:     }
122: 120: 
123: 121:     /// Set `alignment` option.
124: 122:     pub fn allowed_placements(mut self, value: Vec<Placement>) -> Self {
125: 123:         self.allowed_placements = Some(value);
126: 124:         self
127: 125:     }
128: 126: }
129: 127: 
130: 128: impl<Element: Clone> Default for AutoPlacementOptions<Element> {
131: 129:     fn default() -> Self {
132: 130:         Self {
133: 131:             detect_overflow: Default::default(),
134: 132:             cross_axis: Default::default(),
135: 133:             alignment: Default::default(),
136: 134:             auto_alignment: Default::default(),
137: 135:             allowed_placements: Default::default(),
138: 136:         }
139: 137:     }
140: 138: }
141: 139: 
142: 140: /// An overflow stored in [`AutoPlacementData`].
143: 141: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
144: 142: pub struct AutoPlacementDataOverflow {
145: 143:     pub placement: Placement,
146: 144:     pub overflows: Vec<f64>,
147: 145: }
148: 146: 
149: 147: /// Data stored by [`AutoPlacement`] middleware.
150: 148: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
151: 149: pub struct AutoPlacementData {
152: 150:     pub index: usize,
153: 151:     pub overflows: Vec<AutoPlacementDataOverflow>,
154: 152: }
155: 153: 
156: 154: /// Auto placement middleware.
157: 155: ///
158: 156: /// Optimizes the visibility of the floating element by choosing the placement that has the most space available automatically, without needing to specify a preferred placement.
159: 157: /// Alternative to [`Flip`][`crate::middleware::Flip`].
160: 158: ///
161: 159: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/auto-placement.html) for more documentation.
162: 160: #[derive(PartialEq)]
163: 161: pub struct AutoPlacement<'a, Element: Clone + 'static, Window: Clone> {
164: 162:     options: Derivable<'a, Element, Window, AutoPlacementOptions<Element>>,
165: 163: }
166: 164: 
167: 165: impl<Element: Clone + 'static, Window: Clone> Clone for AutoPlacement<'_, Element, Window> {
168: 166:     fn clone(&self) -> Self {
169: 167:         Self {
170: 168:             options: self.options.clone(),
171: 169:         }
172: 170:     }
173: 171: }
174: 172: 
175: 173: impl<'a, Element: Clone + 'static, Window: Clone> AutoPlacement<'a, Element, Window> {
176: 174:     /// Constructs a new instance of this middleware.
177: 175:     pub fn new(options: AutoPlacementOptions<Element>) -> Self {
178: 176:         AutoPlacement {
179: 177:             options: options.into(),
180: 178:         }
181: 179:     }
182: 180: 
183: 181:     /// Constructs a new instance of this middleware with derivable options.
184: 182:     pub fn new_derivable(
185: 183:         options: Derivable<'a, Element, Window, AutoPlacementOptions<Element>>,
186: 184:     ) -> Self {
187: 185:         AutoPlacement { options }
188: 186:     }
189: 187: 
190: 188:     /// Constructs a new instance of this middleware with derivable options function.
191: 189:     pub fn new_derivable_fn(
192: 190:         options: DerivableFn<'a, Element, Window, AutoPlacementOptions<Element>>,
193: 191:     ) -> Self {
194: 192:         AutoPlacement {
195: 193:             options: options.into(),
196: 194:         }
197: 195:     }
198: 196: }
199: 197: 
200: 198: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> Middleware<Element, Window>
201: 199:     for AutoPlacement<'static, Element, Window>
202: 200: {
203: 201:     fn name(&self) -> &'static str {
204: 202:         AUTO_PLACEMENT_NAME
205: 203:     }
206: 204: 
207: 205:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
208: 206:         let options = self.options.evaluate(state.clone());
209: 207: 
210: 208:         let MiddlewareState {
211: 209:             rects,
212: 210:             middleware_data,
213: 211:             placement,
214: 212:             platform,
215: 213:             elements,
216: 214:             ..
217: 215:         } = state;
218: 216: 
219: 217:         let data: AutoPlacementData =
220: 218:             middleware_data
221: 219:                 .get_as(self.name())
222: 220:                 .unwrap_or(AutoPlacementData {
223: 221:                     index: 0,
224: 222:                     overflows: vec![],
225: 223:                 });
226: 224: 
227: 225:         let cross_axis = options.cross_axis.unwrap_or(false);
228: 226:         let alignment = options.alignment;
229: 227:         let has_allowed_placements = options.allowed_placements.is_some();
230: 228:         let allowed_placements = options
231: 229:             .allowed_placements
232: 230:             .unwrap_or(Vec::from(ALL_PLACEMENTS));
233: 231:         let auto_alignment = options.auto_alignment.unwrap_or(true);
234: 232: 
235: 233:         let placements: Vec<Placement> = if alignment.is_some() || !has_allowed_placements {
236: 234:             get_placement_list(alignment, auto_alignment, allowed_placements)
237: 235:         } else {
238: 236:             allowed_placements
239: 237:         };
240: 238: 
241: 239:         let overflow = detect_overflow(
242: 240:             MiddlewareState {
243: 241:                 elements: elements.clone(),
244: 242:                 ..state
245: 243:             },
246: 244:             options.detect_overflow.unwrap_or_default(),
247: 245:         );
248: 246: 
249: 247:         let current_index = data.index;
250: 248:         let current_placement = placements.get(current_index);
251: 249: 
252: 250:         if let Some(current_placement) = current_placement {
253: 251:             let current_placement = *current_placement;
254: 252: 
255: 253:             let alignment_sides =
256: 254:                 get_alignment_sides(current_placement, rects, platform.is_rtl(elements.floating));
257: 255: 
258: 256:             // Make `compute_coords` start from the right place.
259: 257:             if placement != current_placement {
260: 258:                 return MiddlewareReturn {
261: 259:                     x: None,
262: 260:                     y: None,
263: 261:                     data: None,
264: 262:                     reset: Some(Reset::Value(ResetValue {
265: 263:                         placement: Some(placements[0]),
266: 264:                         rects: None,
267: 265:                     })),
268: 266:                 };
269: 267:             }
270: 268: 
271: 269:             let current_overflows = vec![
272: 270:                 overflow.side(get_side(current_placement)),
273: 271:                 overflow.side(alignment_sides.0),
274: 272:                 overflow.side(alignment_sides.1),
275: 273:             ];
276: 274: 
277: 275:             let mut all_overflows = data.overflows.clone();
278: 276:             all_overflows.push(AutoPlacementDataOverflow {
279: 277:                 placement,
280: 278:                 overflows: current_overflows,
281: 279:             });
282: 280: 
283: 281:             let next_placement = placements.get(current_index + 1);
284: 282: 
285: 283:             // There are more placements to check.
286: 284:             if let Some(next_placement) = next_placement {
287: 285:                 return MiddlewareReturn {
288: 286:                     x: None,
289: 287:                     y: None,
290: 288:                     data: Some(
291: 289:                         serde_json::to_value(AutoPlacementData {
292: 290:                             index: current_index + 1,
293: 291:                             overflows: all_overflows.clone(),
294: 292:                         })
295: 293:                         .expect("Data should be valid JSON."),
296: 294:                     ),
297: 295:                     reset: Some(Reset::Value(ResetValue {
298: 296:                         placement: Some(*next_placement),
299: 297:                         rects: None,
300: 298:                     })),
301: 299:                 };
302: 300:             }
303: 301: 
304: 302:             let mut placements_sorted_by_most_space: Vec<_> = all_overflows
305: 303:                 .clone()
306: 304:                 .into_iter()
307: 305:                 .map(|overflow| {
308: 306:                     let alignment = get_alignment(overflow.placement);
309: 307: 
310: 308:                     (
311: 309:                         overflow.placement,
312: 310:                         if alignment.is_some() && cross_axis {
313: 311:                             // Check along the main axis and main cross axis side.
314: 312:                             overflow.overflows[0..2].iter().sum()
315: 313:                         } else {
316: 314:                             // Check only the main axis.
317: 315:                             overflow.overflows[0]
318: 316:                         },
319: 317:                         overflow.overflows,
320: 318:                     )
321: 319:                 })
322: 320:                 .collect();
323: 321: 
324: 322:             placements_sorted_by_most_space.sort_by(|a, b| a.1.total_cmp(&b.1));
325: 323: 
326: 324:             let placements_that_fit_on_each_side: Vec<_> = placements_sorted_by_most_space
327: 325:                 .clone()
328: 326:                 .into_iter()
329: 327:                 .filter(|overflow| {
330: 328:                     // Aligned placements should not check their opposite cross axis side.
331: 329:                     overflow.2[0..match get_alignment(overflow.0) {
332: 330:                         Some(_) => 2,
333: 331:                         None => 3,
334: 332:                     }]
335: 333:                         .iter()
336: 334:                         .all(|v| *v <= 0.0)
337: 335:                 })
338: 336:                 .collect();
339: 337: 
340: 338:             let reset_placement = placements_that_fit_on_each_side
341: 339:                 .first()
342: 340:                 .map(|v| v.0)
343: 341:                 .unwrap_or(placements_sorted_by_most_space[0].0);
344: 342: 
345: 343:             if reset_placement != placement {
346: 344:                 return MiddlewareReturn {
347: 345:                     x: None,
348: 346:                     y: None,
349: 347:                     data: Some(
350: 348:                         serde_json::to_value(AutoPlacementData {
351: 349:                             index: current_index + 1,
352: 350:                             overflows: all_overflows,
353: 351:                         })
354: 352:                         .expect("Data should be valid JSON."),
355: 353:                     ),
356: 354:                     reset: Some(Reset::Value(ResetValue {
357: 355:                         placement: Some(reset_placement),
358: 356:                         rects: None,
359: 357:                     })),
360: 358:                 };
361: 359:             }
362: 360:         }
363: 361: 
364: 362:         MiddlewareReturn {
365: 363:             x: None,
366: 364:             y: None,
367: 365:             data: None,
368: 366:             reset: None,
369: 367:         }
370: 368:     }
371: 369: }
372: 370: 
373: 371: impl<Element: Clone, Window: Clone>
374: 372:     MiddlewareWithOptions<Element, Window, AutoPlacementOptions<Element>>
375: 373:     for AutoPlacement<'_, Element, Window>
376: 374: {
377: 375:     fn options(&self) -> &Derivable<'_, Element, Window, AutoPlacementOptions<Element>> {
378: 376:         &self.options
379: 377:     }
380: 378: }
381: 379: 
382: 380: #[cfg(test)]
383: 381: mod tests {
384: 382:     use super::*;
385: 383: 
386: 384:     #[test]
387: 385:     fn test_base_placement() {
388: 386:         assert_eq!(
389: 387:             get_placement_list(
390: 388:                 None,
391: 389:                 false,
392: 390:                 vec![
393: 391:                     Placement::Top,
394: 392:                     Placement::Bottom,
395: 393:                     Placement::Left,
396: 394:                     Placement::Right,
397: 395:                     Placement::TopStart,
398: 396:                     Placement::RightEnd,
399: 397:                 ]
400: 398:             ),
401: 399:             vec![
402: 400:                 Placement::Top,
403: 401:                 Placement::Bottom,
404: 402:                 Placement::Left,
405: 403:                 Placement::Right,
406: 404:             ]
407: 405:         )
408: 406:     }
409: 407: 
410: 408:     #[test]
411: 409:     fn test_start_alignment_without_auto_alignment() {
412: 410:         assert_eq!(
413: 411:             get_placement_list(
414: 412:                 Some(Alignment::Start),
415: 413:                 false,
416: 414:                 vec![
417: 415:                     Placement::Top,
418: 416:                     Placement::Bottom,
419: 417:                     Placement::Left,
420: 418:                     Placement::Right,
421: 419:                     Placement::TopStart,
422: 420:                     Placement::RightEnd,
423: 421:                     Placement::LeftStart,
424: 422:                 ]
425: 423:             ),
426: 424:             vec![Placement::TopStart, Placement::LeftStart]
427: 425:         )
428: 426:     }
429: 427: 
430: 428:     #[test]
431: 429:     fn test_start_alignment_with_auto_alignment() {
432: 430:         assert_eq!(
433: 431:             get_placement_list(
434: 432:                 Some(Alignment::Start),
435: 433:                 true,
436: 434:                 vec![
437: 435:                     Placement::Top,
438: 436:                     Placement::Bottom,
439: 437:                     Placement::Left,
440: 438:                     Placement::Right,
441: 439:                     Placement::TopStart,
442: 440:                     Placement::RightEnd,
443: 441:                     Placement::LeftStart,
444: 442:                 ]
445: 443:             ),
446: 444:             vec![
447: 445:                 Placement::TopStart,
448: 446:                 Placement::LeftStart,
449: 447:                 Placement::RightEnd,
450: 448:             ]
451: 449:         )
452: 450:     }
453: 451: 
454: 452:     #[test]
455: 453:     fn test_end_alignment_without_auto_alignment() {
456: 454:         assert_eq!(
457: 455:             get_placement_list(
458: 456:                 Some(Alignment::End),
459: 457:                 false,
460: 458:                 vec![
461: 459:                     Placement::Top,
462: 460:                     Placement::Bottom,
463: 461:                     Placement::Left,
464: 462:                     Placement::Right,
465: 463:                     Placement::TopStart,
466: 464:                     Placement::RightEnd,
467: 465:                     Placement::LeftStart,
468: 466:                 ]
469: 467:             ),
470: 468:             vec![Placement::RightEnd,]
471: 469:         )
472: 470:     }
473: 471: 
474: 472:     #[test]
475: 473:     fn test_end_alignment_with_auto_alignment() {
476: 474:         assert_eq!(
477: 475:             get_placement_list(
478: 476:                 Some(Alignment::End),
479: 477:                 true,
480: 478:                 vec![
481: 479:                     Placement::Top,
482: 480:                     Placement::Bottom,
483: 481:                     Placement::Left,
484: 482:                     Placement::Right,
485: 483:                     Placement::TopStart,
486: 484:                     Placement::RightEnd,
487: 485:                     Placement::LeftStart,
488: 486:                 ]
489: 487:             ),
490: 488:             vec![
491: 489:                 Placement::RightEnd,
492: 490:                 Placement::TopStart,
493: 491:                 Placement::LeftStart
494: 492:             ]
495: 493:         )
496: 494:     }
497: 495: }
498: ```
```
