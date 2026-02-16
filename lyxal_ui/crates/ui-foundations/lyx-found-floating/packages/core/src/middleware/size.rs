1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\size.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\core\src\middleware\size.rs
42: 40: ```rust
43: 41: use std::ptr;
44: 42: 
45: 43: use lyx_ui_foundations_utils::{Alignment, Axis, Rect, Side, get_side_axis};
46: 44: 
47: 45: use crate::{
48: 46:     detect_overflow::{DetectOverflowOptions, detect_overflow},
49: 47:     middleware::shift::{SHIFT_NAME, ShiftData},
50: 48:     types::{
51: 49:         Derivable, DerivableFn, Middleware, MiddlewareReturn, MiddlewareState,
52: 50:         MiddlewareWithOptions, ResetRects, ResetValue,
53: 51:     },
54: 52: };
55: 53: 
56: 54: /// Name of the [`Size`] middleware.
57: 55: pub const SIZE_NAME: &str = "size";
58: 56: 
59: 57: /// State passed to [`SizeOptions::lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply`].
60: 58: #[derive(Clone)]
61: 59: pub struct ApplyState<'a, Element: Clone + 'static, Window: Clone> {
62: 60:     pub state: MiddlewareState<'a, Element, Window>,
63: 61:     pub available_width: f64,
64: 62:     pub available_height: f64,
65: 63: }
66: 64: 
67: 65: pub type ApplyFn<Element, Window> = dyn Fn(ApplyState<Element, Window>);
68: 66: 
69: 67: /// Options for [`Size`] middleware.
70: 68: #[derive(Clone)]
71: 69: pub struct SizeOptions<'a, Element: Clone + 'static, Window: Clone> {
72: 70:     /// Options for [`detect_overflow`].
73: 71:     ///
74: 72:     /// Defaults to [`DetectOverflowOptions::default`].
75: 73:     pub detect_overflow: Option<DetectOverflowOptions<Element>>,
76: 74: 
77: 75:     /// Function that is called to perform style mutations to the floating element to change its size.
78: 76:     pub lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply: Option<&'a ApplyFn<Element, Window>>,
79: 77: }
80: 78: 
81: 79: impl<'a, Element: Clone, Window: Clone> SizeOptions<'a, Element, Window> {
82: 80:     pub fn new() -> Self {
83: 81:         SizeOptions {
84: 82:             detect_overflow: None,
85: 83:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply: None,
86: 84:         }
87: 85:     }
88: 86: 
89: 87:     /// Set `detect_overflow` option.
90: 88:     pub fn detect_overflow(mut self, value: DetectOverflowOptions<Element>) -> Self {
91: 89:         self.detect_overflow = Some(value);
92: 90:         self
93: 91:     }
94: 92: 
95: 93:     /// Set `lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply` option.
96: 94:     pub fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply(mut self, value: &'a ApplyFn<Element, Window>) -> Self {
97: 95:         self.lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply = Some(value);
98: 96:         self
99: 97:     }
100: 98: }
101: 99: 
102: 100: impl<Element: Clone, Window: Clone> Default for SizeOptions<'_, Element, Window> {
103: 101:     fn default() -> Self {
104: 102:         Self {
105: 103:             detect_overflow: Default::default(),
106: 104:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply: Default::default(),
107: 105:         }
108: 106:     }
109: 107: }
110: 108: 
111: 109: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> PartialEq
112: 110:     for SizeOptions<'_, Element, Window>
113: 111: {
114: 112:     fn eq(&self, other: &Self) -> bool {
115: 113:         self.detect_overflow == other.detect_overflow
116: 114:             && match (self.lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply, other.lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply) {
117: 115:                 (Some(a), Some(b)) => ptr::eq(a, b),
118: 116:                 (None, None) => true,
119: 117:                 _ => false,
120: 118:             }
121: 119:     }
122: 120: }
123: 121: 
124: 122: /// Size middleware.
125: 123: ///
126: 124: /// Provides data that allows you to change the size of the floating element -
127: 125: /// for instance, prevent it from overflowing the clipping boundary or match the width of the reference element.
128: 126: ///
129: 127: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/size.html) for more documentation.
130: 128: #[derive(PartialEq)]
131: 129: pub struct Size<'a, Element: Clone + 'static, Window: Clone> {
132: 130:     options: Derivable<'a, Element, Window, SizeOptions<'a, Element, Window>>,
133: 131: }
134: 132: 
135: 133: impl<'a, Element: Clone + 'static, Window: Clone> Size<'a, Element, Window> {
136: 134:     /// Constructs a new instance of this middleware.
137: 135:     pub fn new(options: SizeOptions<'a, Element, Window>) -> Self {
138: 136:         Size {
139: 137:             options: options.into(),
140: 138:         }
141: 139:     }
142: 140: 
143: 141:     /// Constructs a new instance of this middleware with derivable options.
144: 142:     pub fn new_derivable(
145: 143:         options: Derivable<'a, Element, Window, SizeOptions<'a, Element, Window>>,
146: 144:     ) -> Self {
147: 145:         Size { options }
148: 146:     }
149: 147: 
150: 148:     /// Constructs a new instance of this middleware with derivable options function.
151: 149:     pub fn new_derivable_fn(
152: 150:         options: DerivableFn<'a, Element, Window, SizeOptions<'a, Element, Window>>,
153: 151:     ) -> Self {
154: 152:         Size {
155: 153:             options: options.into(),
156: 154:         }
157: 155:     }
158: 156: }
159: 157: 
160: 158: impl<Element: Clone, Window: Clone> Clone for Size<'_, Element, Window> {
161: 159:     fn clone(&self) -> Self {
162: 160:         Self {
163: 161:             options: self.options.clone(),
164: 162:         }
165: 163:     }
166: 164: }
167: 165: 
168: 166: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> Middleware<Element, Window>
169: 167:     for Size<'static, Element, Window>
170: 168: {
171: 169:     fn name(&self) -> &'static str {
172: 170:         SIZE_NAME
173: 171:     }
174: 172: 
175: 173:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
176: 174:         let options = self.options.evaluate(state.clone());
177: 175: 
178: 176:         let MiddlewareState {
179: 177:             placement,
180: 178:             elements,
181: 179:             rects,
182: 180:             middleware_data,
183: 181:             platform,
184: 182:             ..
185: 183:         } = state;
186: 184: 
187: 185:         let overflow = detect_overflow(
188: 186:             MiddlewareState {
189: 187:                 elements: elements.clone(),
190: 188:                 ..state
191: 189:             },
192: 190:             options.detect_overflow.unwrap_or_default(),
193: 191:         );
194: 192:         let side = placement.side();
195: 193:         let alignment = placement.alignment();
196: 194:         let is_y_axis = get_side_axis(placement) == Axis::Y;
197: 195:         let Rect { width, height, .. } = rects.floating;
198: 196: 
199: 197:         let height_side;
200: 198:         let width_side;
201: 199: 
202: 200:         match side {
203: 201:             Side::Top | Side::Bottom => {
204: 202:                 height_side = side;
205: 203:                 width_side = match alignment {
206: 204:                     Some(alignment) => {
207: 205:                         if alignment
208: 206:                             == match platform.is_rtl(elements.floating) {
209: 207:                                 Some(true) => Alignment::Start,
210: 208:                                 _ => Alignment::End,
211: 209:                             }
212: 210:                         {
213: 211:                             Side::Left
214: 212:                         } else {
215: 213:                             Side::Right
216: 214:                         }
217: 215:                     }
218: 216:                     None => Side::Right,
219: 217:                 };
220: 218:             }
221: 219:             Side::Right | Side::Left => {
222: 220:                 width_side = side;
223: 221:                 height_side = match alignment {
224: 222:                     Some(Alignment::End) => Side::Top,
225: 223:                     _ => Side::Bottom,
226: 224:                 };
227: 225:             }
228: 226:         }
229: 227: 
230: 228:         let maximum_clipping_height = height - overflow.top - overflow.bottom;
231: 229:         let maximum_clipping_width = width - overflow.left - overflow.right;
232: 230: 
233: 231:         let overflow_available_height =
234: 232:             maximum_clipping_height.min(height - overflow.side(height_side));
235: 233:         let overflow_available_width =
236: 234:             maximum_clipping_width.min(width - overflow.side(width_side));
237: 235: 
238: 236:         let no_shift = middleware_data.get(SHIFT_NAME).is_none();
239: 237: 
240: 238:         let mut available_height = overflow_available_height;
241: 239:         let mut available_width = overflow_available_width;
242: 240: 
243: 241:         let data: Option<ShiftData> = middleware_data.get_as(SHIFT_NAME);
244: 242:         if data.as_ref().is_some_and(|data| data.enabled.x) {
245: 243:             available_width = maximum_clipping_width;
246: 244:         }
247: 245:         if data.as_ref().is_some_and(|data| data.enabled.y) {
248: 246:             available_height = maximum_clipping_height;
249: 247:         }
250: 248: 
251: 249:         if no_shift && alignment.is_none() {
252: 250:             let x_min = overflow.left.max(0.0);
253: 251:             let x_max = overflow.right.max(0.0);
254: 252:             let y_min = overflow.top.max(0.0);
255: 253:             let y_max = overflow.bottom.max(0.0);
256: 254: 
257: 255:             if is_y_axis {
258: 256:                 available_width = width
259: 257:                     - 2.0
260: 258:                         * (if x_min != 0.0 || x_max != 0.0 {
261: 259:                             x_min + x_max
262: 260:                         } else {
263: 261:                             overflow.left.max(overflow.right)
264: 262:                         });
265: 263:             } else {
266: 264:                 available_height = height
267: 265:                     - 2.0
268: 266:                         * (if y_min != 0.0 || y_max != 0.0 {
269: 267:                             y_min + y_max
270: 268:                         } else {
271: 269:                             overflow.top.max(overflow.bottom)
272: 270:                         });
273: 271:             }
274: 272:         }
275: 273: 
276: 274:         if let Some(lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply) = options.lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply {
277: 275:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply(ApplyState {
278: 276:                 state: MiddlewareState {
279: 277:                     elements: elements.clone(),
280: 278:                     ..state
281: 279:                 },
282: 280:                 available_width,
283: 281:                 available_height,
284: 282:             });
285: 283:         }
286: 284: 
287: 285:         let next_dimensions = platform.get_dimensions(elements.floating);
288: 286: 
289: 287:         if width != next_dimensions.width || height != next_dimensions.height {
290: 288:             MiddlewareReturn {
291: 289:                 x: None,
292: 290:                 y: None,
293: 291:                 data: None,
294: 292:                 reset: Some(crate::Reset::Value(ResetValue {
295: 293:                     placement: None,
296: 294:                     rects: Some(ResetRects::True),
297: 295:                 })),
298: 296:             }
299: 297:         } else {
300: 298:             MiddlewareReturn {
301: 299:                 x: None,
302: 300:                 y: None,
303: 301:                 data: None,
304: 302:                 reset: None,
305: 303:             }
306: 304:         }
307: 305:     }
308: 306: }
309: 307: 
310: 308: impl<'a, Element: Clone, Window: Clone>
311: 309:     MiddlewareWithOptions<Element, Window, SizeOptions<'a, Element, Window>>
312: 310:     for Size<'a, Element, Window>
313: 311: {
314: 312:     fn options(&self) -> &Derivable<'_, Element, Window, SizeOptions<'a, Element, Window>> {
315: 313:         &self.options
316: 314:     }
317: 315: }
318: 316: ```
319: 317: ```
320: 318: ```
321: 319: ```
322: 320: ```
323: 321: ```
324: 322: ```
325: 323: ```
326: 324: ```
327: 325: ```
328: 326: ```
329: 327: ```
330: 328: ```
331: 329: ```
332: 330: ```
333: 331: ```
334: 332: ```
335: 333: ```
336: 334: ```
337: 335: ```
338: ```
```

