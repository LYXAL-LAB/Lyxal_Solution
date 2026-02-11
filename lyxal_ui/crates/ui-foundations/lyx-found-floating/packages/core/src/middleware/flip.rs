### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\flip.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\flip.rs
2: ```rust
3: 1: use lyx_ui_foundations_utils::{
4: 2:     Alignment, Axis, Placement, get_alignment, get_alignment_sides, get_expanded_placements,
5: 3:     get_opposite_axis_placements, get_opposite_placement, get_side, get_side_axis,
6: 4: };
7: 5: use serde::{Deserialize, Serialize};
8: 6: 
9: 7: use crate::{
10: 8:     detect_overflow::{DetectOverflowOptions, detect_overflow},
11: 9:     middleware::arrow::{ARROW_NAME, ArrowData},
12: 10:     types::{
13: 11:         Derivable, DerivableFn, Middleware, MiddlewareReturn, MiddlewareState,
14: 12:         MiddlewareWithOptions, Reset, ResetValue,
15: 13:     },
16: 14: };
17: 15: 
18: 16: /// Name of the [`Flip`] middleware.
19: 17: pub const FLIP_NAME: &str = "flip";
20: 18: 
21: 19: /// Cross axis option used by [`Flip`] middleware.
22: 20: #[derive(Copy, Clone, Debug, PartialEq)]
23: 21: pub enum CrossAxis {
24: 22:     /// Whether to check cross axis overflow for both side and alignment flipping.
25: 23:     True,
26: 24:     /// Whether to disable all cross axis overflow checking.
27: 25:     False,
28: 26:     /// Whether to check cross axis overflow for alignment flipping only.
29: 27:     Alignment,
30: 28: }
31: 29: 
32: 30: /// Fallback strategy used by [`Flip`] middleware.
33: 31: #[derive(Copy, Clone, Debug, Default, PartialEq)]
34: 32: pub enum FallbackStrategy {
35: 33:     #[default]
36: 34:     BestFit,
37: 35:     InitialPlacement,
38: 36: }
39: 37: 
40: 38: /// Options for [`Flip`] middleware.
41: 39: #[derive(Clone, Debug, PartialEq)]
42: 40: pub struct FlipOptions<Element: Clone> {
43: 41:     /// Options for [`detect_overflow`].
44: 42:     ///
45: 43:     /// Defaults to [`DetectOverflowOptions::default`].
46: 44:     pub detect_overflow: Option<DetectOverflowOptions<Element>>,
47: 45: 
48: 46:     /// The axis that runs along the side of the floating element. Determines whether overflow along this axis is checked to perform a flip.
49: 47:     ///
50: 48:     /// Defaults to `true`.
51: 49:     pub main_axis: Option<bool>,
52: 50: 
53: 51:     /// The axis that runs along the alignment of the floating element. Determines whether overflow along this axis is checked to perform a flip.
54: 52:     /// - [`CrossAxis::True`]: Whether to check cross axis overflow for both side and alignment flipping.
55: 53:     /// - [`CrossAxis::False`]: Whether to disable all cross axis overflow checking.
56: 54:     /// - [`CrossAxis::Alignment`]: Whether to check cross axis overflow for alignment flipping only.
57: 55:     ///
58: 56:     /// Defaults to `true`.
59: 57:     pub cross_axis: Option<CrossAxis>,
60: 58: 
61: 59:     /// Placements to try sequentially if the preferred `placement` does not fit.
62: 60:     ///
63: 61:     /// Defaults to the opposite placement.
64: 62:     pub fallback_placements: Option<Vec<Placement>>,
65: 63: 
66: 64:     /// What strategy to use when no placements fit.
67: 65:     ///
68: 66:     /// Defaults to [`FallbackStrategy::BestFit`].
69: 67:     pub fallback_strategy: Option<FallbackStrategy>,
70: 68: 
71: 69:     /// Whether to allow fallback to the perpendicular axis of the preferred placement, and if so, which side direction along the axis to prefer.
72: 70:     ///
73: 71:     /// Defaults to [`Option::None`] (disallow fallback).
74: 72:     pub fallback_axis_side_direction: Option<Alignment>,
75: 73: 
76: 74:     /// Whether to flip to placements with the opposite alignment if they fit better.
77: 75:     ///
78: 76:     /// Defaults to `true`.
79: 77:     pub flip_alignment: Option<bool>,
80: 78: }
81: 79: 
82: 80: impl<Element: Clone> FlipOptions<Element> {
83: 81:     /// Set `detect_overflow` option.
84: 82:     pub fn detect_overflow(mut self, value: DetectOverflowOptions<Element>) -> Self {
85: 83:         self.detect_overflow = Some(value);
86: 84:         self
87: 85:     }
88: 86: 
89: 87:     /// Set `main_axis` option.
90: 88:     pub fn main_axis(mut self, value: bool) -> Self {
91: 89:         self.main_axis = Some(value);
92: 90:         self
93: 91:     }
94: 92: 
95: 93:     /// Set `cross_axis` option.
96: 94:     pub fn cross_axis(mut self, value: CrossAxis) -> Self {
97: 95:         self.cross_axis = Some(value);
98: 96:         self
99: 97:     }
100: 98: 
101: 99:     /// Set `fallback_placements` option.
102: 100:     pub fn fallback_placements(mut self, value: Vec<Placement>) -> Self {
103: 101:         self.fallback_placements = Some(value);
104: 102:         self
105: 103:     }
106: 104: 
107: 105:     /// Set `fallback_strategy` option.
108: 106:     pub fn fallback_strategy(mut self, value: FallbackStrategy) -> Self {
109: 107:         self.fallback_strategy = Some(value);
110: 108:         self
111: 109:     }
112: 110: 
113: 111:     /// Set `fallback_axis_side_direction` option.
114: 112:     pub fn fallback_axis_side_direction(mut self, value: Alignment) -> Self {
115: 113:         self.fallback_axis_side_direction = Some(value);
116: 114:         self
117: 115:     }
118: 116: 
119: 117:     /// Set `flip_alignment` option.
120: 118:     pub fn flip_alignment(mut self, value: bool) -> Self {
121: 119:         self.flip_alignment = Some(value);
122: 120:         self
123: 121:     }
124: 122: }
125: 123: 
126: 124: impl<Element: Clone> Default for FlipOptions<Element> {
127: 125:     fn default() -> Self {
128: 126:         Self {
129: 127:             detect_overflow: Default::default(),
130: 128:             main_axis: Default::default(),
131: 129:             cross_axis: Default::default(),
132: 130:             fallback_placements: Default::default(),
133: 131:             fallback_strategy: Default::default(),
134: 132:             fallback_axis_side_direction: Default::default(),
135: 133:             flip_alignment: Default::default(),
136: 134:         }
137: 135:     }
138: 136: }
139: 137: 
140: 138: /// An overflow stored in [`FlipData`].
141: 139: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
142: 140: pub struct FlipDataOverflow {
143: 141:     pub placement: Placement,
144: 142:     pub overflows: Vec<f64>,
145: 143: }
146: 144: 
147: 145: /// Data stored by [`Flip`] middleware.
148: 146: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
149: 147: pub struct FlipData {
150: 148:     pub index: usize,
151: 149:     pub overflows: Vec<FlipDataOverflow>,
152: 150: }
153: 151: 
154: 152: /// Flip middleware.
155: 153: ///
156: 154: /// Optimizes the visibility of the floating element by flipping the `placement` in order to keep it in view when the preferred placement(s) will overflow the clipping boundary.
157: 155: /// Alternative to [`AutoPlacement`][`crate::middleware::AutoPlacement`].
158: 156: ///
159: 157: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/flip.html) for more documentation.
160: 158: #[derive(PartialEq)]
161: 159: pub struct Flip<'a, Element: Clone + 'static, Window: Clone> {
162: 160:     options: Derivable<'a, Element, Window, FlipOptions<Element>>,
163: 161: }
164: 162: 
165: 163: impl<'a, Element: Clone + 'static, Window: Clone> Flip<'a, Element, Window> {
166: 164:     /// Constructs a new instance of this middleware.
167: 165:     pub fn new(options: FlipOptions<Element>) -> Self {
168: 166:         Flip {
169: 167:             options: options.into(),
170: 168:         }
171: 169:     }
172: 170: 
173: 171:     /// Constructs a new instance of this middleware with derivable options.
174: 172:     pub fn new_derivable(options: Derivable<'a, Element, Window, FlipOptions<Element>>) -> Self {
175: 173:         Flip { options }
176: 174:     }
177: 175: 
178: 176:     /// Constructs a new instance of this middleware with derivable options function.
179: 177:     pub fn new_derivable_fn(
180: 178:         options: DerivableFn<'a, Element, Window, FlipOptions<Element>>,
181: 179:     ) -> Self {
182: 180:         Flip {
183: 181:             options: options.into(),
184: 182:         }
185: 183:     }
186: 184: }
187: 185: 
188: 186: impl<Element: Clone + 'static, Window: Clone> Clone for Flip<'_, Element, Window> {
189: 187:     fn clone(&self) -> Self {
190: 188:         Self {
191: 189:             options: self.options.clone(),
192: 190:         }
193: 191:     }
194: 192: }
195: 193: 
196: 194: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> Middleware<Element, Window>
197: 195:     for Flip<'static, Element, Window>
198: 196: {
199: 197:     fn name(&self) -> &'static str {
200: 198:         FLIP_NAME
201: 199:     }
202: 200: 
203: 201:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
204: 202:         let options = self.options.evaluate(state.clone());
205: 203: 
206: 204:         let MiddlewareState {
207: 205:             placement,
208: 206:             initial_placement,
209: 207:             middleware_data,
210: 208:             elements,
211: 209:             rects,
212: 210:             platform,
213: 211:             ..
214: 212:         } = state;
215: 213: 
216: 214:         let data: FlipData = middleware_data.get_as(self.name()).unwrap_or(FlipData {
217: 215:             index: 0,
218: 216:             overflows: vec![],
219: 217:         });
220: 218: 
221: 219:         let check_main_axis = options.main_axis.unwrap_or(true);
222: 220:         let check_cross_axis = options.cross_axis.unwrap_or(CrossAxis::True);
223: 221:         let specified_fallback_placements = options.fallback_placements.clone();
224: 222:         let fallback_strategy = options.fallback_strategy.unwrap_or_default();
225: 223:         let fallback_axis_side_direction = options.fallback_axis_side_direction;
226: 224:         let flip_alignment = options.flip_alignment.unwrap_or(true);
227: 225: 
228: 226:         // If a reset by the arrow was caused due to an alignment offset being added,
229: 227:         // we should skip any logic now since `flip()` has already done its work.
230: 228:         let arrow_data: Option<ArrowData> = middleware_data.get_as(ARROW_NAME);
231: 229:         if arrow_data
232: 230:             .and_then(|arrow_data| arrow_data.alignment_offset)
233: 231:             .is_some()
234: 232:         {
235: 233:             return MiddlewareReturn {
236: 234:                 x: None,
237: 235:                 y: None,
238: 236:                 data: None,
239: 237:                 reset: None,
240: 238:             };
241: 239:         }
242: 240: 
243: 241:         let side = get_side(placement);
244: 242:         let initial_side_axis = get_side_axis(initial_placement);
245: 243:         let is_base_placement = get_alignment(initial_placement).is_none();
246: 244:         let rtl = platform.is_rtl(elements.floating);
247: 245: 
248: 246:         let has_specified_fallback_placements = specified_fallback_placements.is_some();
249: 247:         let mut placements =
250: 248:             specified_fallback_placements.unwrap_or(if is_base_placement || !flip_alignment {
251: 249:                 vec![get_opposite_placement(initial_placement)]
252: 250:             } else {
253: 251:                 get_expanded_placements(initial_placement)
254: 252:             });
255: 253: 
256: 254:         let has_fallback_axis_side_direction = fallback_axis_side_direction.is_some();
257: 255: 
258: 256:         if !has_specified_fallback_placements && has_fallback_axis_side_direction {
259: 257:             placements.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(&mut get_opposite_axis_placements(
260: 258:                 initial_placement,
261: 259:                 flip_alignment,
262: 260:                 fallback_axis_side_direction,
263: 261:                 rtl,
264: 262:             ));
265: 263:         }
266: 264: 
267: 265:         placements.insert(0, initial_placement);
268: 266: 
269: 267:         let overflow = detect_overflow(
270: 268:             MiddlewareState {
271: 269:                 elements: elements.clone(),
272: 270:                 ..state
273: 271:             },
274: 272:             options.detect_overflow.unwrap_or_default(),
275: 273:         );
276: 274: 
277: 275:         let mut overflows: Vec<f64> = Vec::new();
278: 276:         let mut overflows_data = data.overflows;
279: 277: 
280: 278:         if check_main_axis {
281: 279:             overflows.push(overflow.side(side));
282: 280:         }
283: 281:         if check_cross_axis == CrossAxis::True || check_cross_axis == CrossAxis::Alignment {
284: 282:             let sides = get_alignment_sides(placement, rects, rtl);
285: 283:             overflows.push(overflow.side(sides.0));
286: 284:             overflows.push(overflow.side(sides.1));
287: 285:         }
288: 286: 
289: 287:         overflows_data.push(FlipDataOverflow {
290: 288:             placement,
291: 289:             overflows: overflows.clone(),
292: 290:         });
293: 291: 
294: 292:         // One or more sides is overflowing.
295: 293:         if !overflows.into_iter().all(|side| side <= 0.0) {
296: 294:             let next_index = data.index + 1;
297: 295:             let next_placement = placements.get(next_index);
298: 296: 
299: 297:             if let Some(next_placement) = next_placement {
300: 298:                 let ignore_cross_axis_overflow = if check_cross_axis == CrossAxis::Alignment {
301: 299:                     initial_side_axis != get_side_axis(*next_placement)
302: 300:                 } else {
303: 301:                     false
304: 302:                 };
305: 303: 
306: 304:                 if !ignore_cross_axis_overflow ||
307: 305:                     // We leave the current main axis only if every placement on that axis overflows the main axis.
308: 306:                     overflows_data.iter().all(|d| {
309: 307:                         if get_side_axis(d.placement) == initial_side_axis {
310: 308:                             d.overflows.first().is_some_and(|overflow| *overflow > 0.0)
311: 309:                         } else {
312: 310:                             true
313: 311:                         }
314: 312:                     })
315: 313:                 {
316: 314:                     // Try next placement and re-run the lifecycle.
317: 315:                     return MiddlewareReturn {
318: 316:                         x: None,
319: 317:                         y: None,
320: 318:                         data: Some(
321: 319:                             serde_json::to_value(FlipData {
322: 320:                                 index: next_index,
323: 321:                                 overflows: overflows_data,
324: 322:                             })
325: 323:                             .expect("Data should be valid JSON."),
326: 324:                         ),
327: 325:                         reset: Some(Reset::Value(ResetValue {
328: 326:                             placement: Some(*next_placement),
329: 327:                             rects: None,
330: 328:                         })),
331: 329:                     };
332: 330:                 }
333: 331:             }
334: 332: 
335: 333:             // First, find the candidates that fit on the main axis side of overflow, then find the placement that fits the best on the main cross axis side.
336: 334:             let mut reset_placement: Vec<&FlipDataOverflow> = overflows_data
337: 335:                 .iter()
338: 336:                 .filter(|overflow| overflow.overflows[0] <= 0.0)
339: 337:                 .collect();
340: 338:             reset_placement.sort_by(|a, b| a.overflows[1].total_cmp(&b.overflows[1]));
341: 339: 
342: 340:             let mut reset_placement = reset_placement.first().map(|overflow| overflow.placement);
343: 341: 
344: 342:             // Otherwise fallback.
345: 343:             if reset_placement.is_none() {
346: 344:                 match fallback_strategy {
347: 345:                     FallbackStrategy::BestFit => {
348: 346:                         let mut placement: Vec<(Placement, f64)> = overflows_data
349: 347:                             .into_iter()
350: 348:                             .filter(|overflow| {
351: 349:                                 if has_fallback_axis_side_direction {
352: 350:                                     let current_side_axis = get_side_axis(overflow.placement);
353: 351: 
354: 352:                                     // Create a bias to the `y` side axis due to horizontal reading directions favoring greater width.
355: 353:                                     current_side_axis == initial_side_axis
356: 354:                                         || current_side_axis == Axis::Y
357: 355:                                 } else {
358: 356:                                     true
359: 357:                                 }
360: 358:                             })
361: 359:                             .map(|overflow| {
362: 360:                                 (
363: 361:                                     overflow.placement,
364: 362:                                     overflow
365: 363:                                         .overflows
366: 364:                                         .into_iter()
367: 365:                                         .filter(|overflow| *overflow > 0.0)
368: 366:                                         .sum::<f64>(),
369: 367:                                 )
370: 368:                             })
371: 369:                             .collect();
372: 370:                         placement.sort_by(|a, b| a.1.total_cmp(&b.1));
373: 371: 
374: 372:                         let placement = placement.first().map(|v| v.0);
375: 373:                         if placement.is_some() {
376: 374:                             reset_placement = placement;
377: 375:                         }
378: 376:                     }
379: 377:                     FallbackStrategy::InitialPlacement => {
380: 378:                         reset_placement = Some(initial_placement);
381: 379:                     }
382: 380:                 }
383: 381:             }
384: 382: 
385: 383:             if placement != reset_placement.expect("Reset placement is not none.") {
386: 384:                 return MiddlewareReturn {
387: 385:                     x: None,
388: 386:                     y: None,
389: 387:                     data: None,
390: 388:                     reset: Some(Reset::Value(ResetValue {
391: 389:                         placement: reset_placement,
392: 390:                         rects: None,
393: 391:                     })),
394: 392:                 };
395: 393:             }
396: 394:         }
397: 395: 
398: 396:         MiddlewareReturn {
399: 397:             x: None,
400: 398:             y: None,
401: 399:             data: None,
402: 400:             reset: None,
403: 401:         }
404: 402:     }
405: 403: }
406: 404: 
407: 405: impl<Element: Clone, Window: Clone> MiddlewareWithOptions<Element, Window, FlipOptions<Element>>
408: 406:     for Flip<'_, Element, Window>
409: 407: {
410: 408:     fn options(&self) -> &Derivable<'_, Element, Window, FlipOptions<Element>> {
411: 409:         &self.options
412: 410:     }
413: 411: }
414: ```
```
