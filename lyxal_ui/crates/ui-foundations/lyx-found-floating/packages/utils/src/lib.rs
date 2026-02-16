1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\utils\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\utils\src\lib.rs
34: 32: ```rust
35: 33: //! Rust port of [Floating UI](https://floating-ui.com/).
36: 34: //!
37: 35: //! Utility functions shared across Floating UI packages. You may use these functions in your own projects, but are subject to breaking changes.
38: 36: //!
39: 37: //! See [the Rust Floating UI book](https://floating-ui.rustforweb.org/) for more documenation.
40: 38: //!
41: 39: //! See [@floating-ui/utils](https://www.npmjs.com/package/@floating-ui/utils) for the original package.
42: 40: 
43: 41: #[cfg(feature = "dom")]
44: 42: pub mod dom;
45: 43: 
46: 44: use std::rc::Rc;
47: 45: 
48: 46: use dyn_derive::dyn_trait;
49: 47: use serde::{Deserialize, Serialize};
50: 48: 
51: 49: #[derive(Copy, Clone, Debug, PartialEq)]
52: 50: pub enum Alignment {
53: 51:     Start,
54: 52:     End,
55: 53: }
56: 54: 
57: 55: #[derive(Copy, Clone, Debug, PartialEq)]
58: 56: pub enum Side {
59: 57:     Top,
60: 58:     Right,
61: 59:     Bottom,
62: 60:     Left,
63: 61: }
64: 62: 
65: 63: impl Side {
66: 64:     pub fn opposite(&self) -> Side {
67: 65:         match self {
68: 66:             Side::Top => Side::Bottom,
69: 67:             Side::Right => Side::Left,
70: 68:             Side::Bottom => Side::Top,
71: 69:             Side::Left => Side::Right,
72: 70:         }
73: 71:     }
74: 72: 
75: 73:     pub fn axis(&self) -> Axis {
76: 74:         match self {
77: 75:             Side::Top => Axis::Y,
78: 76:             Side::Right => Axis::X,
79: 77:             Side::Bottom => Axis::Y,
80: 78:             Side::Left => Axis::X,
81: 79:         }
82: 80:     }
83: 81: }
84: 82: 
85: 83: #[derive(Copy, Clone, Debug, PartialEq)]
86: 84: pub enum AlignedPlacement {
87: 85:     TopStart,
88: 86:     TopEnd,
89: 87:     RightStart,
90: 88:     RightEnd,
91: 89:     BottomStart,
92: 90:     BottomEnd,
93: 91:     LeftStart,
94: 92:     LeftEnd,
95: 93: }
96: 94: 
97: 95: #[derive(Copy, Clone, Debug, PartialEq, Serialize, Deserialize)]
98: 96: pub enum Placement {
99: 97:     Top,
100: 98:     TopStart,
101: 99:     TopEnd,
102: 100:     Right,
103: 101:     RightStart,
104: 102:     RightEnd,
105: 103:     Bottom,
106: 104:     BottomStart,
107: 105:     BottomEnd,
108: 106:     Left,
109: 107:     LeftStart,
110: 108:     LeftEnd,
111: 109: }
112: 110: 
113: 111: impl Placement {
114: 112:     pub fn alignment(&self) -> Option<Alignment> {
115: 113:         match self {
116: 114:             Placement::Top => None,
117: 115:             Placement::TopStart => Some(Alignment::Start),
118: 116:             Placement::TopEnd => Some(Alignment::End),
119: 117:             Placement::Right => None,
120: 118:             Placement::RightStart => Some(Alignment::Start),
121: 119:             Placement::RightEnd => Some(Alignment::End),
122: 120:             Placement::Bottom => None,
123: 121:             Placement::BottomStart => Some(Alignment::Start),
124: 122:             Placement::BottomEnd => Some(Alignment::End),
125: 123:             Placement::Left => None,
126: 124:             Placement::LeftStart => Some(Alignment::Start),
127: 125:             Placement::LeftEnd => Some(Alignment::End),
128: 126:         }
129: 127:     }
130: 128: 
131: 129:     pub fn side(&self) -> Side {
132: 130:         match self {
133: 131:             Placement::Top => Side::Top,
134: 132:             Placement::TopStart => Side::Top,
135: 133:             Placement::TopEnd => Side::Top,
136: 134:             Placement::Right => Side::Right,
137: 135:             Placement::RightStart => Side::Right,
138: 136:             Placement::RightEnd => Side::Right,
139: 137:             Placement::Bottom => Side::Bottom,
140: 138:             Placement::BottomStart => Side::Bottom,
141: 139:             Placement::BottomEnd => Side::Bottom,
142: 140:             Placement::Left => Side::Left,
143: 141:             Placement::LeftStart => Side::Left,
144: 142:             Placement::LeftEnd => Side::Left,
145: 143:         }
146: 144:     }
147: 145: 
148: 146:     pub fn opposite(&self) -> Placement {
149: 147:         match self {
150: 148:             Placement::Top => Placement::Bottom,
151: 149:             Placement::TopStart => Placement::BottomStart,
152: 150:             Placement::TopEnd => Placement::BottomEnd,
153: 151:             Placement::Right => Placement::Left,
154: 152:             Placement::RightStart => Placement::LeftStart,
155: 153:             Placement::RightEnd => Placement::LeftEnd,
156: 154:             Placement::Bottom => Placement::Top,
157: 155:             Placement::BottomStart => Placement::TopStart,
158: 156:             Placement::BottomEnd => Placement::TopEnd,
159: 157:             Placement::Left => Placement::Right,
160: 158:             Placement::LeftStart => Placement::RightStart,
161: 159:             Placement::LeftEnd => Placement::RightEnd,
162: 160:         }
163: 161:     }
164: 162: 
165: 163:     pub fn opposite_alignment(&self) -> Placement {
166: 164:         match self {
167: 165:             Placement::Top => Placement::Top,
168: 166:             Placement::TopStart => Placement::TopEnd,
169: 167:             Placement::TopEnd => Placement::TopStart,
170: 168:             Placement::Right => Placement::Right,
171: 169:             Placement::RightStart => Placement::RightEnd,
172: 170:             Placement::RightEnd => Placement::RightStart,
173: 171:             Placement::Bottom => Placement::Bottom,
174: 172:             Placement::BottomStart => Placement::BottomEnd,
175: 173:             Placement::BottomEnd => Placement::BottomStart,
176: 174:             Placement::Left => Placement::Left,
177: 175:             Placement::LeftStart => Placement::LeftEnd,
178: 176:             Placement::LeftEnd => Placement::LeftStart,
179: 177:         }
180: 178:     }
181: 179: }
182: 180: 
183: 181: impl From<(Side, Option<Alignment>)> for Placement {
184: 182:     fn from(value: (Side, Option<Alignment>)) -> Self {
185: 183:         match value {
186: 184:             (Side::Top, None) => Placement::Top,
187: 185:             (Side::Top, Some(Alignment::Start)) => Placement::TopStart,
188: 186:             (Side::Top, Some(Alignment::End)) => Placement::TopEnd,
189: 187:             (Side::Right, None) => Placement::Right,
190: 188:             (Side::Right, Some(Alignment::Start)) => Placement::RightStart,
191: 189:             (Side::Right, Some(Alignment::End)) => Placement::RightEnd,
192: 190:             (Side::Bottom, None) => Placement::Bottom,
193: 191:             (Side::Bottom, Some(Alignment::Start)) => Placement::BottomStart,
194: 192:             (Side::Bottom, Some(Alignment::End)) => Placement::BottomEnd,
195: 193:             (Side::Left, None) => Placement::Left,
196: 194:             (Side::Left, Some(Alignment::Start)) => Placement::LeftStart,
197: 195:             (Side::Left, Some(Alignment::End)) => Placement::LeftEnd,
198: 196:         }
199: 197:     }
200: 198: }
201: 199: 
202: 200: #[derive(Copy, Clone, Debug, PartialEq)]
203: 201: pub enum Strategy {
204: 202:     Absolute,
205: 203:     Fixed,
206: 204: }
207: 205: 
208: 206: #[derive(Copy, Clone, Debug, PartialEq)]
209: 207: pub enum Axis {
210: 208:     X,
211: 209:     Y,
212: 210: }
213: 211: 
214: 212: impl Axis {
215: 213:     pub fn opposite(&self) -> Axis {
216: 214:         match self {
217: 215:             Axis::X => Axis::Y,
218: 216:             Axis::Y => Axis::X,
219: 217:         }
220: 218:     }
221: 219: 
222: 220:     pub fn length(&self) -> Length {
223: 221:         match self {
224: 222:             Axis::X => Length::Width,
225: 223:             Axis::Y => Length::Height,
226: 224:         }
227: 225:     }
228: 226: }
229: 227: 
230: 228: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
231: 229: pub struct Coords {
232: 230:     pub x: f64,
233: 231:     pub y: f64,
234: 232: }
235: 233: 
236: 234: impl Coords {
237: 235:     pub fn new(value: f64) -> Self {
238: 236:         Self { x: value, y: value }
239: 237:     }
240: 238: 
241: 239:     pub fn axis(&self, axis: Axis) -> f64 {
242: 240:         match axis {
243: 241:             Axis::X => self.x,
244: 242:             Axis::Y => self.y,
245: 243:         }
246: 244:     }
247: 245: 
248: 246:     pub fn update_axis<F>(&mut self, axis: Axis, update: F)
249: 247:     where
250: 248:         F: Fn(f64) -> f64,
251: 249:     {
252: 250:         match axis {
253: 251:             Axis::X => {
254: 252:                 self.x = update(self.x);
255: 253:             }
256: 254:             Axis::Y => {
257: 255:                 self.y = update(self.y);
258: 256:             }
259: 257:         }
260: 258:     }
261: 259: }
262: 260: 
263: 261: #[derive(Copy, Clone, Debug, PartialEq)]
264: 262: pub enum Length {
265: 263:     Width,
266: 264:     Height,
267: 265: }
268: 266: 
269: 267: #[derive(Clone, Debug)]
270: 268: pub struct Dimensions {
271: 269:     pub width: f64,
272: 270:     pub height: f64,
273: 271: }
274: 272: 
275: 273: impl Dimensions {
276: 274:     pub fn length(&self, length: Length) -> f64 {
277: 275:         match length {
278: 276:             Length::Width => self.width,
279: 277:             Length::Height => self.height,
280: 278:         }
281: 279:     }
282: 280: }
283: 281: 
284: 282: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
285: 283: pub struct SideObject {
286: 284:     pub top: f64,
287: 285:     pub right: f64,
288: 286:     pub bottom: f64,
289: 287:     pub left: f64,
290: 288: }
291: 289: 
292: 290: impl SideObject {
293: 291:     pub fn side(&self, side: Side) -> f64 {
294: 292:         match side {
295: 293:             Side::Top => self.top,
296: 294:             Side::Right => self.right,
297: 295:             Side::Bottom => self.bottom,
298: 296:             Side::Left => self.left,
299: 297:         }
300: 298:     }
301: 299: }
302: 300: 
303: 301: #[derive(Clone, Debug, PartialEq)]
304: 302: pub struct PartialSideObject {
305: 303:     pub top: Option<f64>,
306: 304:     pub right: Option<f64>,
307: 305:     pub bottom: Option<f64>,
308: 306:     pub left: Option<f64>,
309: 307: }
310: 308: 
311: 309: #[derive(Clone, Debug, PartialEq)]
312: 310: pub struct Rect {
313: 311:     pub x: f64,
314: 312:     pub y: f64,
315: 313:     pub width: f64,
316: 314:     pub height: f64,
317: 315: }
318: 316: 
319: 317: impl Rect {
320: 318:     pub fn axis(&self, axis: Axis) -> f64 {
321: 319:         match axis {
322: 320:             Axis::X => self.x,
323: 321:             Axis::Y => self.y,
324: 322:         }
325: 323:     }
326: 324: 
327: 325:     pub fn length(&self, length: Length) -> f64 {
328: 326:         match length {
329: 327:             Length::Width => self.width,
330: 328:             Length::Height => self.height,
331: 329:         }
332: 330:     }
333: 331: }
334: 332: 
335: 333: #[derive(Clone, Debug, PartialEq)]
336: 334: pub enum Padding {
337: 335:     All(f64),
338: 336:     PerSide(PartialSideObject),
339: 337: }
340: 338: 
341: 339: #[derive(Clone, Debug, PartialEq)]
342: 340: pub struct ClientRectObject {
343: 341:     pub x: f64,
344: 342:     pub y: f64,
345: 343:     pub width: f64,
346: 344:     pub height: f64,
347: 345:     pub top: f64,
348: 346:     pub right: f64,
349: 347:     pub bottom: f64,
350: 348:     pub left: f64,
351: 349: }
352: 350: 
353: 351: impl From<Rect> for ClientRectObject {
354: 352:     fn from(value: Rect) -> Self {
355: 353:         ClientRectObject {
356: 354:             x: value.x,
357: 355:             y: value.y,
358: 356:             width: value.width,
359: 357:             height: value.height,
360: 358:             top: value.y,
361: 359:             right: value.x + value.width,
362: 360:             bottom: value.y + value.height,
363: 361:             left: value.x,
364: 362:         }
365: 363:     }
366: 364: }
367: 365: 
368: 366: cfg_if::cfg_if! {
369: 367:     if #[cfg(feature = "dom")] {
370: 368:         impl ClientRectObject {
371: 369:             pub fn from_dom_rect_list(value: web_sys::DomRectList) -> Vec<Self> {
372: 370:                 (0..value.length())
373: 371:                     .filter_map(|i| value.item(i).map(ClientRectObject::from))
374: 372:                     .collect()
375: 373:             }
376: 374:         }
377: 375: 
378: 376:         impl From<web_sys::DomRect> for ClientRectObject {
379: 377:             fn from(value: web_sys::DomRect) -> Self {
380: 378:                 Self {
381: 379:                     x: value.x(),
382: 380:                     y: value.y(),
383: 381:                     width: value.width(),
384: 382:                     height: value.height(),
385: 383:                     top: value.top(),
386: 384:                     right: value.right(),
387: 385:                     bottom: value.bottom(),
388: 386:                     left: value.left(),
389: 387:                 }
390: 388:             }
391: 389:         }
392: 390:     }
393: 391: }
394: 392: 
395: 393: #[derive(Clone, Debug, PartialEq)]
396: 394: pub struct ElementRects {
397: 395:     pub reference: Rect,
398: 396:     pub floating: Rect,
399: 397: }
400: 398: 
401: 399: /// Custom positioning reference element.
402: 400: ///
403: 401: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/virtual-elements.html) for more documentation.
404: 402: #[dyn_trait]
405: 403: pub trait VirtualElement<Element: 'static>: Clone + PartialEq {
406: 404:     fn get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(&self) -> ClientRectObject;
407: 405: 
408: 406:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(&self) -> Option<Vec<ClientRectObject>>;
409: 407: 
410: 408:     fn context_element(&self) -> Option<Element>;
411: 409: }
412: 410: 
413: 411: #[dyn_trait]
414: 412: pub trait GetBoundingClientRectCloneable: Clone {
415: 413:     fn call(&self) -> ClientRectObject;
416: 414: }
417: 415: 
418: 416: impl<F> GetBoundingClientRectCloneable for F
419: 417: where
420: 418:     F: Fn() -> ClientRectObject + Clone + 'static,
421: 419: {
422: 420:     fn call(&self) -> ClientRectObject {
423: 421:         self()
424: 422:     }
425: 423: }
426: 424: 
427: 425: #[dyn_trait]
428: 426: pub trait GetClientRectsCloneable: Clone {
429: 427:     fn call(&self) -> Vec<ClientRectObject>;
430: 428: }
431: 429: 
432: 430: impl<F> GetClientRectsCloneable for F
433: 431: where
434: 432:     F: Fn() -> Vec<ClientRectObject> + Clone + 'static,
435: 433: {
436: 434:     fn call(&self) -> Vec<ClientRectObject> {
437: 435:         self()
438: 436:     }
439: 437: }
440: 438: 
441: 439: #[derive(Clone)]
442: 440: pub struct DefaultVirtualElement<Element: Clone> {
443: 441:     pub get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect: Rc<dyn GetBoundingClientRectCloneable>,
444: 442:     pub get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects: Option<Rc<dyn GetClientRectsCloneable>>,
445: 443:     pub context_element: Option<Element>,
446: 444: }
447: 445: 
448: 446: impl<Element: Clone> DefaultVirtualElement<Element> {
449: 447:     pub fn new(get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect: Rc<dyn GetBoundingClientRectCloneable>) -> Self {
450: 448:         DefaultVirtualElement {
451: 449:             get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect,
452: 450:             get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects: None,
453: 451:             context_element: None,
454: 452:         }
455: 453:     }
456: 454: 
457: 455:     pub fn get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(
458: 456:         mut self,
459: 457:         get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect: Rc<dyn GetBoundingClientRectCloneable>,
460: 458:     ) -> Self {
461: 459:         self.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect = get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect;
462: 460:         self
463: 461:     }
464: 462: 
465: 463:     pub fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(mut self, get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects: Rc<dyn GetClientRectsCloneable>) -> Self {
466: 464:         self.get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects = Some(get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects);
467: 465:         self
468: 466:     }
469: 467: 
470: 468:     pub fn context_element(mut self, context_element: Element) -> Self {
471: 469:         self.context_element = Some(context_element);
472: 470:         self
473: 471:     }
474: 472: }
475: 473: 
476: 474: impl<Element: Clone + PartialEq + 'static> VirtualElement<Element>
477: 475:     for DefaultVirtualElement<Element>
478: 476: {
479: 477:     fn get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(&self) -> ClientRectObject {
480: 478:         (self.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect).call()
481: 479:     }
482: 480: 
483: 481:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(&self) -> Option<Vec<ClientRectObject>> {
484: 482:         self.get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects
485: 483:             .as_ref()
486: 484:             .map(|get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects| get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.call())
487: 485:     }
488: 486: 
489: 487:     fn context_element(&self) -> Option<Element> {
490: 488:         self.context_element.clone()
491: 489:     }
492: 490: }
493: 491: 
494: 492: impl<Element: Clone + PartialEq + 'static> PartialEq for DefaultVirtualElement<Element> {
495: 493:     fn eq(&self, other: &Self) -> bool {
496: 494:         Rc::ptr_eq(
497: 495:             &self.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect,
498: 496:             &other.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect,
499: 497:         ) && match (
500: 498:             self.get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.as_ref(),
501: 499:             other.get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.as_ref(),
502: 500:         ) {
503: 501:             (Some(a), Some(b)) => Rc::ptr_eq(a, b),
504: 502:             (None, None) => true,
505: 503:             _ => false,
506: 504:         } && self.context_element == other.context_element
507: 505:     }
508: 506: }
509: 507: 
510: 508: #[derive(Clone)]
511: 509: pub enum ElementOrVirtual<'a, Element: Clone + 'static> {
512: 510:     Element(&'a Element),
513: 511:     VirtualElement(Box<dyn VirtualElement<Element>>),
514: 512: }
515: 513: 
516: 514: impl<Element: Clone + 'static> ElementOrVirtual<'_, Element> {
517: 515:     pub fn resolve(self) -> Option<Element> {
518: 516:         match self {
519: 517:             ElementOrVirtual::Element(element) => Some(element.clone()),
520: 518:             ElementOrVirtual::VirtualElement(virtal_element) => virtal_element.context_element(),
521: 519:         }
522: 520:     }
523: 521: }
524: 522: 
525: 523: impl<'a, Element: Clone> From<&'a Element> for ElementOrVirtual<'a, Element> {
526: 524:     fn from(value: &'a Element) -> Self {
527: 525:         ElementOrVirtual::Element(value)
528: 526:     }
529: 527: }
530: 528: 
531: 529: impl<Element: Clone> From<Box<dyn VirtualElement<Element>>> for ElementOrVirtual<'_, Element> {
532: 530:     fn from(value: Box<dyn VirtualElement<Element>>) -> Self {
533: 531:         ElementOrVirtual::VirtualElement(value)
534: 532:     }
535: 533: }
536: 534: 
537: 535: impl<'a, Element: Clone> From<&'a OwnedElementOrVirtual<Element>>
538: 536:     for ElementOrVirtual<'a, Element>
539: 537: {
540: 538:     fn from(value: &'a OwnedElementOrVirtual<Element>) -> Self {
541: 539:         match value {
542: 540:             OwnedElementOrVirtual::Element(element) => ElementOrVirtual::Element(element),
543: 541:             OwnedElementOrVirtual::VirtualElement(virtual_element) => {
544: 542:                 ElementOrVirtual::VirtualElement(virtual_element.clone())
545: 543:             }
546: 544:         }
547: 545:     }
548: 546: }
549: 547: 
550: 548: #[derive(Clone)]
551: 549: pub enum OwnedElementOrVirtual<Element: 'static> {
552: 550:     Element(Element),
553: 551:     VirtualElement(Box<dyn VirtualElement<Element>>),
554: 552: }
555: 553: 
556: 554: impl<Element: 'static> OwnedElementOrVirtual<Element> {
557: 555:     pub fn resolve(self) -> Option<Element> {
558: 556:         match self {
559: 557:             OwnedElementOrVirtual::Element(element) => Some(element),
560: 558:             OwnedElementOrVirtual::VirtualElement(virtal_element) => {
561: 559:                 virtal_element.context_element()
562: 560:             }
563: 561:         }
564: 562:     }
565: 563: }
566: 564: 
567: 565: impl<Element> From<Element> for OwnedElementOrVirtual<Element> {
568: 566:     fn from(value: Element) -> Self {
569: 567:         OwnedElementOrVirtual::Element(value)
570: 568:     }
571: 569: }
572: 570: 
573: 571: impl<Element> From<Box<dyn VirtualElement<Element>>> for OwnedElementOrVirtual<Element> {
574: 572:     fn from(value: Box<dyn VirtualElement<Element>>) -> Self {
575: 573:         OwnedElementOrVirtual::VirtualElement(value)
576: 574:     }
577: 575: }
578: 576: 
579: 577: #[derive(Clone, Debug, PartialEq)]
580: 578: pub enum ElementOrWindow<'a, Element, Window> {
581: 579:     Element(&'a Element),
582: 580:     Window(&'a Window),
583: 581: }
584: 582: 
585: 583: impl<'a, Element, Window> From<&'a OwnedElementOrWindow<Element, Window>>
586: 584:     for ElementOrWindow<'a, Element, Window>
587: 585: {
588: 586:     fn from(value: &'a OwnedElementOrWindow<Element, Window>) -> Self {
589: 587:         match value {
590: 588:             OwnedElementOrWindow::Element(element) => ElementOrWindow::Element(element),
591: 589:             OwnedElementOrWindow::Window(window) => ElementOrWindow::Window(window),
592: 590:         }
593: 591:     }
594: 592: }
595: 593: 
596: 594: #[derive(Clone, Debug, PartialEq)]
597: 595: pub enum OwnedElementOrWindow<Element, Window> {
598: 596:     Element(Element),
599: 597:     Window(Window),
600: 598: }
601: 599: 
602: 600: pub const ALL_PLACEMENTS: [Placement; 12] = [
603: 601:     Placement::Top,
604: 602:     Placement::TopStart,
605: 603:     Placement::TopEnd,
606: 604:     Placement::Right,
607: 605:     Placement::RightStart,
608: 606:     Placement::RightEnd,
609: 607:     Placement::Bottom,
610: 608:     Placement::BottomStart,
611: 609:     Placement::BottomEnd,
612: 610:     Placement::Left,
613: 611:     Placement::LeftStart,
614: 612:     Placement::LeftEnd,
615: 613: ];
616: 614: 
617: 615: pub const ALL_SIDES: [Side; 4] = [Side::Top, Side::Right, Side::Bottom, Side::Left];
618: 616: 
619: 617: pub fn clamp(start: f64, value: f64, end: f64) -> f64 {
620: 618:     value.min(end).max(start)
621: 619: }
622: 620: 
623: 621: pub fn get_side(placement: Placement) -> Side {
624: 622:     placement.side()
625: 623: }
626: 624: 
627: 625: pub fn get_alignment(placement: Placement) -> Option<Alignment> {
628: 626:     placement.alignment()
629: 627: }
630: 628: 
631: 629: pub fn get_placement(side: Side, alignment: Option<Alignment>) -> Placement {
632: 630:     (side, alignment).into()
633: 631: }
634: 632: 
635: 633: pub fn get_opposite_axis(axis: Axis) -> Axis {
636: 634:     axis.opposite()
637: 635: }
638: 636: 
639: 637: pub fn get_axis_length(axis: Axis) -> Length {
640: 638:     axis.length()
641: 639: }
642: 640: 
643: 641: pub fn get_side_axis(placement: Placement) -> Axis {
644: 642:     placement.side().axis()
645: 643: }
646: 644: 
647: 645: pub fn get_alignment_axis(placement: Placement) -> Axis {
648: 646:     get_opposite_axis(get_side_axis(placement))
649: 647: }
650: 648: 
651: 649: pub fn get_alignment_sides(
652: 650:     placement: Placement,
653: 651:     rects: &ElementRects,
654: 652:     rtl: Option<bool>,
655: 653: ) -> (Side, Side) {
656: 654:     let alignment = get_alignment(placement);
657: 655:     let alignment_axis = get_alignment_axis(placement);
658: 656:     let length = get_axis_length(alignment_axis);
659: 657: 
660: 658:     let mut main_alignment_side = match (alignment_axis, alignment) {
661: 659:         (Axis::X, Some(Alignment::Start)) => match rtl {
662: 660:             Some(true) => Side::Left,
663: 661:             _ => Side::Right,
664: 662:         },
665: 663:         (Axis::X, _) => match rtl {
666: 664:             Some(true) => Side::Right,
667: 665:             _ => Side::Left,
668: 666:         },
669: 667:         (Axis::Y, Some(Alignment::Start)) => Side::Bottom,
670: 668:         (Axis::Y, _) => Side::Top,
671: 669:     };
672: 670: 
673: 671:     if rects.reference.length(length) > rects.floating.length(length) {
674: 672:         main_alignment_side = get_opposite_side(main_alignment_side);
675: 673:     }
676: 674: 
677: 675:     (main_alignment_side, get_opposite_side(main_alignment_side))
678: 676: }
679: 677: 
680: 678: pub fn get_expanded_placements(placement: Placement) -> Vec<Placement> {
681: 679:     let opposite_placement = get_opposite_placement(placement);
682: 680: 
683: 681:     vec![
684: 682:         get_opposite_alignment_placement(placement),
685: 683:         opposite_placement,
686: 684:         get_opposite_alignment_placement(opposite_placement),
687: 685:     ]
688: 686: }
689: 687: 
690: 688: pub fn get_opposite_alignment_placement(placement: Placement) -> Placement {
691: 689:     placement.opposite_alignment()
692: 690: }
693: 691: 
694: 692: const LR_SIDE_LIST: [Side; 2] = [Side::Left, Side::Right];
695: 693: const RL_SIDE_LIST: [Side; 2] = [Side::Right, Side::Left];
696: 694: const TB_SIDE_LIST: [Side; 2] = [Side::Top, Side::Bottom];
697: 695: const BT_SIDE_LIST: [Side; 2] = [Side::Bottom, Side::Top];
698: 696: 
699: 697: pub fn get_side_list(side: Side, is_start: bool, rtl: Option<bool>) -> [Side; 2] {
700: 698:     match side {
701: 699:         Side::Top | Side::Bottom => match rtl {
702: 700:             Some(true) => {
703: 701:                 if is_start {
704: 702:                     RL_SIDE_LIST
705: 703:                 } else {
706: 704:                     LR_SIDE_LIST
707: 705:                 }
708: 706:             }
709: 707:             _ => {
710: 708:                 if is_start {
711: 709:                     LR_SIDE_LIST
712: 710:                 } else {
713: 711:                     RL_SIDE_LIST
714: 712:                 }
715: 713:             }
716: 714:         },
717: 715:         Side::Right | Side::Left => {
718: 716:             if is_start {
719: 717:                 TB_SIDE_LIST
720: 718:             } else {
721: 719:                 BT_SIDE_LIST
722: 720:             }
723: 721:         }
724: 722:     }
725: 723: }
726: 724: 
727: 725: pub fn get_opposite_side(side: Side) -> Side {
728: 726:     side.opposite()
729: 727: }
730: 728: 
731: 729: pub fn get_opposite_axis_placements(
732: 730:     placement: Placement,
733: 731:     flip_alignment: bool,
734: 732:     direction: Option<Alignment>,
735: 733:     rtl: Option<bool>,
736: 734: ) -> Vec<Placement> {
737: 735:     let alignment = get_alignment(placement);
738: 736:     let side_list = get_side_list(
739: 737:         get_side(placement),
740: 738:         direction.is_some_and(|d| d == Alignment::Start),
741: 739:         rtl,
742: 740:     );
743: 741: 
744: 742:     let mut list: Vec<Placement> = side_list
745: 743:         .into_iter()
746: 744:         .map(|side| get_placement(side, alignment))
747: 745:         .collect();
748: 746: 
749: 747:     if flip_alignment {
750: 748:         let mut opposite_list: Vec<Placement> = list
751: 749:             .clone()
752: 750:             .into_iter()
753: 751:             .map(get_opposite_alignment_placement)
754: 752:             .collect();
755: 753: 
756: 754:         list.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(&mut opposite_list);
757: 755:     }
758: 756: 
759: 757:     list
760: 758: }
761: 759: 
762: 760: pub fn get_opposite_placement(placement: Placement) -> Placement {
763: 761:     placement.opposite()
764: 762: }
765: 763: 
766: 764: pub fn expand_padding_object(padding: PartialSideObject) -> SideObject {
767: 765:     SideObject {
768: 766:         top: padding.top.unwrap_or(0.0),
769: 767:         right: padding.right.unwrap_or(0.0),
770: 768:         bottom: padding.bottom.unwrap_or(0.0),
771: 769:         left: padding.left.unwrap_or(0.0),
772: 770:     }
773: 771: }
774: 772: 
775: 773: pub fn get_padding_object(padding: Padding) -> SideObject {
776: 774:     match padding {
777: 775:         Padding::All(padding) => SideObject {
778: 776:             top: padding,
779: 777:             right: padding,
780: 778:             bottom: padding,
781: 779:             left: padding,
782: 780:         },
783: 781:         Padding::PerSide(padding) => expand_padding_object(padding),
784: 782:     }
785: 783: }
786: 784: 
787: 785: pub fn rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(rect: Rect) -> ClientRectObject {
788: 786:     ClientRectObject {
789: 787:         x: rect.x,
790: 788:         y: rect.y,
791: 789:         width: rect.width,
792: 790:         height: rect.height,
793: 791:         top: rect.y,
794: 792:         right: rect.x + rect.width,
795: 793:         bottom: rect.y + rect.height,
796: 794:         left: rect.x,
797: 795:     }
798: 796: }
799: 797: ```
800: 798: ```
801: 799: ```
802: 800: ```
803: 801: ```
804: 802: ```
805: 803: ```
806: 804: ```
807: 805: ```
808: 806: ```
809: 807: ```
810: 808: ```
811: 809: ```
812: 810: ```
813: 811: ```
814: 812: ```
815: ```
```

