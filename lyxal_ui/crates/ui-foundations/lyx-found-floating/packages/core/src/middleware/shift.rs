### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\shift.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
32: ```rust
33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
34: ```rust
35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
36: ```rust
37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
38: ```rust
39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\shift.rs
40: ```rust
41: use std::fmt::Debug;
42: 
43: use dyn_derive::dyn_trait;
44: use lyx_ui_foundations_utils::{Axis, Coords, Side, clamp, get_opposite_axis, get_side_axis};
45: use serde::{Deserialize, Serialize};
46: 
47: use crate::{
48:     detect_overflow::{DetectOverflowOptions, detect_overflow},
49:     middleware::{OFFSET_NAME, OffsetData},
50:     types::{
51:         Derivable, DerivableFn, Middleware, MiddlewareReturn, MiddlewareState,
52:         MiddlewareWithOptions,
53:     },
54: };
55: 
56: /// Name of the [`Shift`] middleware.
57: pub const SHIFT_NAME: &str = "shift";
58: 
59: /// Limiter used by [`Shift`] middleware. Limits the shifting done in order to prevent detachment.
60: #[dyn_trait]
61: pub trait Limiter<Element: Clone + 'static, Window: Clone + 'static>: Clone + PartialEq {
62:     fn compute(&self, state: MiddlewareState<Element, Window>) -> Coords;
63: }
64: 
65: /// Options for [`Shift`] middleware.
66: #[derive(Clone, PartialEq)]
67: pub struct ShiftOptions<Element: Clone + 'static, Window: Clone + 'static> {
68:     /// Options for [`detect_overflow`].
69:     ///
70:     /// Defaults to [`DetectOverflowOptions::default`].
71:     pub detect_overflow: Option<DetectOverflowOptions<Element>>,
72: 
73:     /// The axis that runs along the alignment of the floating element. Determines whether overflow along this axis is checked to perform shifting.
74:     ///
75:     /// Defaults to `true`.
76:     pub main_axis: Option<bool>,
77: 
78:     /// The axis that runs along the side of the floating element. Determines whether overflow along this axis is checked to perform shifting.
79:     ///
80:     /// Defaults to `false`.
81:     pub cross_axis: Option<bool>,
82: 
83:     /// Accepts a limiter that limits the shifting done in order to prevent detachment.
84:     ///
85:     /// Defaults to [`DefaultLimiter`].
86:     pub limiter: Option<Box<dyn Limiter<Element, Window>>>,
87: }
88: 
89: impl<Element: Clone, Window: Clone> ShiftOptions<Element, Window> {
90:     /// Set `detect_overflow` option.
91:     pub fn detect_overflow(mut self, value: DetectOverflowOptions<Element>) -> Self {
92:         self.detect_overflow = Some(value);
93:         self
94:     }
95: 
96:     /// Set `main_axis` option.
97:     pub fn main_axis(mut self, value: bool) -> Self {
98:         self.main_axis = Some(value);
99:         self
100:     }
101: 
102:     /// Set `cross_axis` option.
103:     pub fn cross_axis(mut self, value: bool) -> Self {
104:         self.cross_axis = Some(value);
105:         self
106:     }
107: 
108:     /// Set `limiter` option.
109:     pub fn limiter(mut self, value: Box<dyn Limiter<Element, Window>>) -> Self {
110:         self.limiter = Some(value);
111:         self
112:     }
113: }
114: 
115: impl<Element: Clone, Window: Clone> Default for ShiftOptions<Element, Window> {
116:     fn default() -> Self {
117:         Self {
118:             detect_overflow: Default::default(),
119:             main_axis: Default::default(),
120:             cross_axis: Default::default(),
121:             limiter: Default::default(),
122:         }
123:     }
124: }
125: 
126: /// Enabled sides stored in [`ShiftData`].
127: #[derive(Clone, Debug, Default, PartialEq, Serialize, Deserialize)]
128: pub struct ShiftDataEnabled {
129:     pub x: bool,
130:     pub y: bool,
131: }
132: 
133: impl ShiftDataEnabled {
134:     pub fn set_axis(mut self, axis: Axis, enabled: bool) -> Self {
135:         match axis {
136:             Axis::X => {
137:                 self.x = enabled;
138:             }
139:             Axis::Y => {
140:                 self.y = enabled;
141:             }
142:         }
143:         self
144:     }
145: }
146: 
147: /// Data stored by [`Shift`] middleware.
148: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
149: pub struct ShiftData {
150:     pub x: f64,
151:     pub y: f64,
152:     pub enabled: ShiftDataEnabled,
153: }
154: 
155: /// Shift middleware.
156: ///
157: /// Optimizes the visibility of the floating element by shifting it in order to keep it in view when it will overflow the clipping boundary.
158: ///
159: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/shift.html) for more documentation.
160: #[derive(PartialEq)]
161: pub struct Shift<'a, Element: Clone + 'static, Window: Clone + 'static> {
162:     options: Derivable<'a, Element, Window, ShiftOptions<Element, Window>>,
163: }
164: 
165: impl<'a, Element: Clone, Window: Clone> Shift<'a, Element, Window> {
166:     /// Constructs a new instance of this middleware.
167:     pub fn new(options: ShiftOptions<Element, Window>) -> Self {
168:         Shift {
169:             options: options.into(),
170:         }
171:     }
172: 
173:     /// Constructs a new instance of this middleware with derivable options.
174:     pub fn new_derivable(
175:         options: Derivable<'a, Element, Window, ShiftOptions<Element, Window>>,
176:     ) -> Self {
177:         Shift { options }
178:     }
179: 
180:     /// Constructs a new instance of this middleware with derivable options function.
181:     pub fn new_derivable_fn(
182:         options: DerivableFn<'a, Element, Window, ShiftOptions<Element, Window>>,
183:     ) -> Self {
184:         Shift {
185:             options: options.into(),
186:         }
187:     }
188: }
189: 
190: impl<Element: Clone, Window: Clone> Clone for Shift<'_, Element, Window> {
191:     fn clone(&self) -> Self {
192:         Self {
193:             options: self.options.clone(),
194:         }
195:     }
196: }
197: 
198: impl<Element: Clone + PartialEq + 'static, Window: Clone + PartialEq + 'static>
199:     Middleware<Element, Window> for Shift<'static, Element, Window>
200: {
201:     fn name(&self) -> &'static str {
202:         SHIFT_NAME
203:     }
204: 
205:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
206:         let options = self.options.evaluate(state.clone());
207: 
208:         let MiddlewareState {
209:             x, y, placement, ..
210:         } = state;
211: 
212:         let check_main_axis = options.main_axis.unwrap_or(true);
213:         let check_cross_axis = options.cross_axis.unwrap_or(false);
214:         #[allow(clippy::unwrap_or_default)]
215:         let limiter = options.limiter.unwrap_or(Box::<DefaultLimiter>::default());
216: 
217:         let coords = Coords { x, y };
218:         let overflow = detect_overflow(
219:             MiddlewareState {
220:                 elements: state.elements.clone(),
221:                 ..state
222:             },
223:             options.detect_overflow.unwrap_or_default(),
224:         );
225:         let cross_axis = get_side_axis(placement);
226:         let main_axis = get_opposite_axis(cross_axis);
227: 
228:         let mut main_axis_coord = coords.axis(main_axis);
229:         let mut cross_axis_coord = coords.axis(cross_axis);
230: 
231:         if check_main_axis {
232:             let min_side = match main_axis {
233:                 Axis::X => Side::Left,
234:                 Axis::Y => Side::Top,
235:             };
236:             let max_side = match main_axis {
237:                 Axis::X => Side::Right,
238:                 Axis::Y => Side::Bottom,
239:             };
240:             let min = main_axis_coord + overflow.side(min_side);
241:             let max = main_axis_coord - overflow.side(max_side);
242: 
243:             main_axis_coord = clamp(min, main_axis_coord, max);
244:         }
245: 
246:         if check_cross_axis {
247:             let min_side = match cross_axis {
248:                 Axis::X => Side::Left,
249:                 Axis::Y => Side::Top,
250:             };
251:             let max_side = match cross_axis {
252:                 Axis::X => Side::Right,
253:                 Axis::Y => Side::Bottom,
254:             };
255:             let min = cross_axis_coord + overflow.side(min_side);
256:             let max = cross_axis_coord - overflow.side(max_side);
257: 
258:             cross_axis_coord = clamp(min, cross_axis_coord, max);
259:         }
260: 
261:         let limited_coords = limiter.compute(MiddlewareState {
262:             x: match main_axis {
263:                 Axis::X => main_axis_coord,
264:                 Axis::Y => cross_axis_coord,
265:             },
266:             y: match main_axis {
267:                 Axis::X => cross_axis_coord,
268:                 Axis::Y => main_axis_coord,
269:             },
270:             ..state
271:         });
272: 
273:         MiddlewareReturn {
274:             x: Some(limited_coords.x),
275:             y: Some(limited_coords.y),
276:             data: Some(
277:                 serde_json::to_value(ShiftData {
278:                     x: limited_coords.x - x,
279:                     y: limited_coords.y - y,
280:                     enabled: ShiftDataEnabled::default()
281:                         .set_axis(main_axis, check_main_axis)
282:                         .set_axis(cross_axis, check_cross_axis),
283:                 })
284:                 .expect("Data should be valid JSON."),
285:             ),
286:             reset: None,
287:         }
288:     }
289: }
290: 
291: impl<Element: Clone, Window: Clone>
292:     MiddlewareWithOptions<Element, Window, ShiftOptions<Element, Window>>
293:     for Shift<'_, Element, Window>
294: {
295:     fn options(&self) -> &Derivable<'_, Element, Window, ShiftOptions<Element, Window>> {
296:         &self.options
297:     }
298: }
299: 
300: /// Default [`Limiter`], which doesn't limit shifting.
301: #[derive(Clone, Debug, Default, PartialEq)]
302: pub struct DefaultLimiter;
303: 
304: impl<Element: Clone + 'static, Window: Clone + 'static> Limiter<Element, Window>
305:     for DefaultLimiter
306: {
307:     fn compute(&self, state: MiddlewareState<Element, Window>) -> Coords {
308:         Coords {
309:             x: state.x,
310:             y: state.y,
311:         }
312:     }
313: }
314: 
315: /// Axes configuration for [`LimitShiftOffset`].
316: #[derive(Clone, Default, Debug, PartialEq)]
317: pub struct LimitShiftOffsetValues {
318:     pub main_axis: Option<f64>,
319: 
320:     pub cross_axis: Option<f64>,
321: }
322: 
323: impl LimitShiftOffsetValues {
324:     /// Set `main_axis` option.
325:     pub fn main_axis(mut self, value: f64) -> Self {
326:         self.main_axis = Some(value);
327:         self
328:     }
329: 
330:     /// Set `cross_axis` option.
331:     pub fn cross_axis(mut self, value: f64) -> Self {
332:         self.cross_axis = Some(value);
333:         self
334:     }
335: }
336: 
337: /// Offset configuration for [`LimitShiftOptions`].
338: #[derive(Clone, Debug, PartialEq)]
339: pub enum LimitShiftOffset {
340:     Value(f64),
341:     Values(LimitShiftOffsetValues),
342: }
343: 
344: impl Default for LimitShiftOffset {
345:     fn default() -> Self {
346:         LimitShiftOffset::Value(0.0)
347:     }
348: }
349: 
350: /// Options for [`LimitShift`] limiter.
351: #[derive(Clone, PartialEq)]
352: pub struct LimitShiftOptions<'a, Element: Clone + 'static, Window: Clone> {
353:     pub offset: Option<Derivable<'a, Element, Window, LimitShiftOffset>>,
354: 
355:     pub main_axis: Option<bool>,
356: 
357:     pub cross_axis: Option<bool>,
358: }
359: 
360: impl<'a, Element: Clone, Window: Clone> LimitShiftOptions<'a, Element, Window> {
361:     /// Set `offset` option.
362:     pub fn offset(mut self, value: LimitShiftOffset) -> Self {
363:         self.offset = Some(value.into());
364:         self
365:     }
366: 
367:     /// Set `offset` option with derivable offset.
368:     pub fn offset_derivable(
369:         mut self,
370:         value: Derivable<'a, Element, Window, LimitShiftOffset>,
371:     ) -> Self {
372:         self.offset = Some(value);
373:         self
374:     }
375: 
376:     /// Set `offset` option with derivable offset function.
377:     pub fn offset_derivable_fn(
378:         mut self,
379:         value: DerivableFn<'a, Element, Window, LimitShiftOffset>,
380:     ) -> Self {
381:         self.offset = Some(value.into());
382:         self
383:     }
384: 
385:     /// Set `main_axis` option.
386:     pub fn main_axis(mut self, value: bool) -> Self {
387:         self.main_axis = Some(value);
388:         self
389:     }
390: 
391:     /// Set `cross_axis` option.
392:     pub fn cross_axis(mut self, value: bool) -> Self {
393:         self.cross_axis = Some(value);
394:         self
395:     }
396: }
397: 
398: impl<Element: Clone + 'static, Window: Clone> Default for LimitShiftOptions<'_, Element, Window> {
399:     fn default() -> Self {
400:         Self {
401:             offset: Default::default(),
402:             main_axis: Default::default(),
403:             cross_axis: Default::default(),
404:         }
405:     }
406: }
407: 
408: /// Built-in [`Limiter`], that will stop [`Shift`] at a certain point.
409: #[derive(Clone, Default, PartialEq)]
410: pub struct LimitShift<'a, Element: Clone + 'static, Window: Clone> {
411:     options: LimitShiftOptions<'a, Element, Window>,
412: }
413: 
414: impl<'a, Element: Clone, Window: Clone> LimitShift<'a, Element, Window> {
415:     pub fn new(options: LimitShiftOptions<'a, Element, Window>) -> Self {
416:         LimitShift { options }
417:     }
418: }
419: 
420: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> Limiter<Element, Window>
421:     for LimitShift<'static, Element, Window>
422: {
423:     fn compute(&self, state: MiddlewareState<Element, Window>) -> Coords {
424:         let MiddlewareState {
425:             x,
426:             y,
427:             placement,
428:             rects,
429:             middleware_data,
430:             ..
431:         } = state;
432: 
433:         let offset = self
434:             .options
435:             .offset
436:             .clone()
437:             .unwrap_or(Derivable::Value(LimitShiftOffset::default()));
438:         let check_main_axis = self.options.main_axis.unwrap_or(true);
439:         let check_cross_axis = self.options.cross_axis.unwrap_or(true);
440: 
441:         let coords = Coords { x, y };
442:         let cross_axis = get_side_axis(placement);
443:         let main_axis = get_opposite_axis(cross_axis);
444: 
445:         let mut main_axis_coord = coords.axis(main_axis);
446:         let mut cross_axis_coord = coords.axis(cross_axis);
447: 
448:         let raw_offset = offset.evaluate(state.clone());
449:         let (computed_main_axis, computed_cross_axis) = match raw_offset {
450:             LimitShiftOffset::Value(value) => (value, 0.0),
451:             LimitShiftOffset::Values(values) => (
452:                 values.main_axis.unwrap_or(0.0),
453:                 values.cross_axis.unwrap_or(0.0),
454:             ),
455:         };
456: 
457:         if check_main_axis {
458:             let len = main_axis.length();
459:             let limit_min =
460:                 rects.reference.axis(main_axis) - rects.floating.length(len) + computed_main_axis;
461:             let limit_max =
462:                 rects.reference.axis(main_axis) + rects.reference.length(len) - computed_main_axis;
463: 
464:             main_axis_coord = clamp(limit_min, main_axis_coord, limit_max);
465:         }
466: 
467:         if check_cross_axis {
468:             let len = main_axis.length();
469:             let is_origin_side = match placement.side() {
470:                 Side::Top | Side::Left => true,
471:                 Side::Bottom | Side::Right => false,
472:             };
473: 
474:             let data: Option<OffsetData> = middleware_data.get_as(OFFSET_NAME);
475:             let data_cross_axis = data.map_or(0.0, |data| data.diff_coords.axis(cross_axis));
476: 
477:             let limit_min = rects.reference.axis(cross_axis) - rects.floating.length(len)
478:                 + if is_origin_side { data_cross_axis } else { 0.0 }
479:                 + if is_origin_side {
480:                     0.0
481:                 } else {
482:                     computed_cross_axis
483:                 };
484:             let limit_max = rects.reference.axis(cross_axis)
485:                 + rects.reference.length(len)
486:                 + if is_origin_side { 0.0 } else { data_cross_axis }
487:                 - if is_origin_side {
488:                     computed_cross_axis
489:                 } else {
490:                     0.0
491:                 };
492: 
493:             cross_axis_coord = clamp(limit_min, cross_axis_coord, limit_max);
494:         }
495: 
496:         Coords {
497:             x: match main_axis {
498:                 Axis::X => main_axis_coord,
499:                 Axis::Y => cross_axis_coord,
500:             },
501:             y: match main_axis {
502:                 Axis::X => cross_axis_coord,
503:                 Axis::Y => main_axis_coord,
504:             },
505:         }
506:     }
507: }
508: ```
509: ```
510: ```
511: ```
512: ```
513: ```
514: ```
515: ```
516: ```
517: ```
518: ```
519: ```
520: ```
521: ```
522: ```
523: ```
524: ```
525: ```
526: ```
527: ```
```
