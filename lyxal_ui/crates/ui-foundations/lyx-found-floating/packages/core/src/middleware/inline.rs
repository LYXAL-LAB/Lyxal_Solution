### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\inline.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\inline.rs
2: ```rust
3: 1: use std::rc::Rc;
4: 2: 
5: 3: use lyx_ui_foundations_utils::{
6: 4:     Axis, ClientRectObject, Coords, DefaultVirtualElement, ElementOrVirtual, Padding, Rect, Side,
7: 5:     get_padding_object, get_side_axis, rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect,
8: 6: };
9: 7: 
10: 8: use crate::types::{
11: 9:     Derivable, DerivableFn, GetElementRectsArgs, Middleware, MiddlewareReturn, MiddlewareState,
12: 10:     MiddlewareWithOptions, Reset, ResetRects, ResetValue,
13: 11: };
14: 12: 
15: 13: fn get_bounding_rect(rects: Vec<ClientRectObject>) -> Rect {
16: 14:     let min_x = rects
17: 15:         .iter()
18: 16:         .map(|rect| rect.left)
19: 17:         .reduce(f64::min)
20: 18:         .unwrap_or(f64::INFINITY);
21: 19:     let min_y = rects
22: 20:         .iter()
23: 21:         .map(|rect| rect.top)
24: 22:         .reduce(f64::min)
25: 23:         .unwrap_or(f64::INFINITY);
26: 24:     let max_x = rects
27: 25:         .iter()
28: 26:         .map(|rect| rect.right)
29: 27:         .reduce(f64::max)
30: 28:         .unwrap_or(f64::NEG_INFINITY);
31: 29:     let max_y = rects
32: 30:         .iter()
33: 31:         .map(|rect| rect.bottom)
34: 32:         .reduce(f64::max)
35: 33:         .unwrap_or(f64::NEG_INFINITY);
36: 34:     Rect {
37: 35:         x: min_x,
38: 36:         y: min_y,
39: 37:         width: max_x - min_x,
40: 38:         height: max_y - min_y,
41: 39:     }
42: 40: }
43: 41: 
44: 42: fn get_rects_by_line(rects: Vec<ClientRectObject>) -> Vec<ClientRectObject> {
45: 43:     let mut sorted_rects = rects.clone();
46: 44:     sorted_rects.sort_by(|a, b| a.y.total_cmp(&b.y));
47: 45: 
48: 46:     let mut groups: Vec<Vec<ClientRectObject>> = vec![];
49: 47:     let mut prev_rect: Option<ClientRectObject> = None;
50: 48:     for rect in sorted_rects {
51: 49:         if prev_rect.is_none()
52: 50:             || prev_rect.is_some_and(|prev_rect| rect.y - prev_rect.y > prev_rect.height / 2.0)
53: 51:         {
54: 52:             groups.push(vec![rect.clone()]);
55: 53:         } else {
56: 54:             groups
57: 55:                 .last_mut()
58: 56:                 .expect("Last group should exist.")
59: 57:                 .push(rect.clone());
60: 58:         }
61: 59:         prev_rect = Some(rect);
62: 60:     }
63: 61: 
64: 62:     groups
65: 63:         .into_iter()
66: 64:         .map(|rects| rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(get_bounding_rect(rects)))
67: 65:         .collect()
68: 66: }
69: 67: 
70: 68: /// Name of the [`Inline`] middleware.
71: 69: pub const INLINE_NAME: &str = "inline";
72: 70: 
73: 71: /// Options for [`Inline`].
74: 72: #[derive(Clone, Debug, Default, PartialEq)]
75: 73: pub struct InlineOptions {
76: 74:     /// Viewport-relative `x` coordinate to choose a `ClientRect`.
77: 75:     ///
78: 76:     /// Defaults to [`None`].
79: 77:     pub x: Option<f64>,
80: 78: 
81: 79:     /// Viewport-relative `y` coordinate to choose a `ClientRect`.
82: 80:     ///
83: 81:     /// Defaults to [`None`].
84: 82:     pub y: Option<f64>,
85: 83: 
86: 84:     /// Represents the padding around a disjoined rect when choosing it.
87: 85:     ///
88: 86:     /// Defaults to `2` on all sides.
89: 87:     pub padding: Option<Padding>,
90: 88: }
91: 89: 
92: 90: impl InlineOptions {
93: 91:     /// Set `x` option.
94: 92:     pub fn x(mut self, value: f64) -> Self {
95: 93:         self.x = Some(value);
96: 94:         self
97: 95:     }
98: 96: 
99: 97:     /// Set `y` option.
100: 98:     pub fn y(mut self, value: f64) -> Self {
101: 99:         self.y = Some(value);
102: 100:         self
103: 101:     }
104: 102: 
105: 103:     /// Set `x` and `y` options using [`Coords`].
106: 104:     pub fn coords(mut self, value: Coords) -> Self {
107: 105:         self.x = Some(value.x);
108: 106:         self.y = Some(value.y);
109: 107:         self
110: 108:     }
111: 109: 
112: 110:     /// Set `padding` option.
113: 111:     pub fn padding(mut self, value: Padding) -> Self {
114: 112:         self.padding = Some(value);
115: 113:         self
116: 114:     }
117: 115: }
118: 116: 
119: 117: /// Inline middleware.
120: 118: ///
121: 119: /// Provides improved positioning for inline reference elements that can span over multiple lines, such as hyperlinks or range selections.
122: 120: ///
123: 121: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/inline.html) for more documentation.
124: 122: #[derive(PartialEq)]
125: 123: pub struct Inline<'a, Element: Clone + 'static, Window: Clone> {
126: 124:     options: Derivable<'a, Element, Window, InlineOptions>,
127: 125: }
128: 126: 
129: 127: impl<'a, Element: Clone + 'static, Window: Clone> Inline<'a, Element, Window> {
130: 128:     /// Constructs a new instance of this middleware.
131: 129:     pub fn new(options: InlineOptions) -> Self {
132: 130:         Inline {
133: 131:             options: options.into(),
134: 132:         }
135: 133:     }
136: 134: 
137: 135:     /// Constructs a new instance of this middleware with derivable options.
138: 136:     pub fn new_derivable(options: Derivable<'a, Element, Window, InlineOptions>) -> Self {
139: 137:         Inline { options }
140: 138:     }
141: 139: 
142: 140:     /// Constructs a new instance of this middleware with derivable options function.
143: 141:     pub fn new_derivable_fn(options: DerivableFn<'a, Element, Window, InlineOptions>) -> Self {
144: 142:         Inline {
145: 143:             options: options.into(),
146: 144:         }
147: 145:     }
148: 146: }
149: 147: 
150: 148: impl<Element: Clone, Window: Clone> Clone for Inline<'_, Element, Window> {
151: 149:     fn clone(&self) -> Self {
152: 150:         Self {
153: 151:             options: self.options.clone(),
154: 152:         }
155: 153:     }
156: 154: }
157: 155: 
158: 156: impl<Element: Clone + PartialEq + 'static, Window: Clone + PartialEq + 'static>
159: 157:     Middleware<Element, Window> for Inline<'static, Element, Window>
160: 158: {
161: 159:     fn name(&self) -> &'static str {
162: 160:         INLINE_NAME
163: 161:     }
164: 162: 
165: 163:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
166: 164:         let options = self.options.evaluate(state.clone());
167: 165: 
168: 166:         let MiddlewareState {
169: 167:             placement,
170: 168:             strategy,
171: 169:             elements,
172: 170:             rects,
173: 171:             platform,
174: 172:             ..
175: 173:         } = state;
176: 174: 
177: 175:         // A MouseEvent's lyx-core-lyx_core_lyx-core-lyx_core_client{X,Y} coords can be up to 2 pixels off a ClientRect's bounds,
178: 176:         // despite the event listener being triggered. A padding of 2 seems to handle this issue.
179: 177:         let padding = options.padding.unwrap_or(Padding::All(2.0));
180: 178: 
181: 179:         let native_lyx-core-lyx_core_lyx-core-lyx_core_client_rects = platform
182: 180:             .get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(elements.reference)
183: 181:             .unwrap_or(vec![]);
184: 182: 
185: 183:         let lyx-core-lyx_core_lyx-core-lyx_core_client_rects = get_rects_by_line(native_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.clone());
186: 184:         let fallback = rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(get_bounding_rect(native_lyx-core-lyx_core_lyx-core-lyx_core_client_rects));
187: 185:         let padding_object = get_padding_object(padding);
188: 186: 
189: 187:         let get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect = move || {
190: 188:             // There are two rects and they are disjoined.
191: 189:             if lyx-core-lyx_core_lyx-core-lyx_core_client_rects.len() == 2
192: 190:                 && lyx-core-lyx_core_lyx-core-lyx_core_client_rects[0].left > lyx-core-lyx_core_lyx-core-lyx_core_client_rects[1].right
193: 191:                 && let Some(x) = options.x
194: 192:                 && let Some(y) = options.y
195: 193:             {
196: 194:                 return lyx-core-lyx_core_lyx-core-lyx_core_client_rects
197: 195:                     .clone()
198: 196:                     .into_iter()
199: 197:                     .find(|rect| {
200: 198:                         x > rect.left - padding_object.left
201: 199:                             && x < rect.right + padding_object.right
202: 200:                             && y > rect.top - padding_object.top
203: 201:                             && rect.y < rect.bottom + padding_object.bottom
204: 202:                     })
205: 203:                     .unwrap_or(fallback.clone());
206: 204:             }
207: 205: 
208: 206:             // There are 2 or more connected rects.
209: 207:             if lyx-core-lyx_core_lyx-core-lyx_core_client_rects.len() >= 2 {
210: 208:                 if get_side_axis(placement) == Axis::Y {
211: 209:                     let first_rect = lyx-core-lyx_core_lyx-core-lyx_core_client_rects.first().expect("Enough elements exist.");
212: 210:                     let last_rect = lyx-core-lyx_core_lyx-core-lyx_core_client_rects.last().expect("Enough elements exist.");
213: 211:                     let is_top = placement.side() == Side::Top;
214: 212: 
215: 213:                     let top = first_rect.top;
216: 214:                     let bottom = last_rect.bottom;
217: 215:                     let left = if is_top {
218: 216:                         first_rect.left
219: 217:                     } else {
220: 218:                         last_rect.left
221: 219:                     };
222: 220:                     let right = if is_top {
223: 221:                         first_rect.right
224: 222:                     } else {
225: 223:                         last_rect.right
226: 224:                     };
227: 225:                     let width = right - left;
228: 226:                     let height = bottom - top;
229: 227: 
230: 228:                     return ClientRectObject {
231: 229:                         x: left,
232: 230:                         y: top,
233: 231:                         width,
234: 232:                         height,
235: 233:                         top,
236: 234:                         right,
237: 235:                         bottom,
238: 236:                         left,
239: 237:                     };
240: 238:                 }
241: 239: 
242: 240:                 let is_left_side = placement.side() == Side::Left;
243: 241:                 let max_right = lyx-core-lyx_core_lyx-core-lyx_core_client_rects
244: 242:                     .iter()
245: 243:                     .map(|rect| rect.right)
246: 244:                     .reduce(f64::max)
247: 245:                     .expect("Enough elements exist.");
248: 246:                 let min_left = lyx-core-lyx_core_lyx-core-lyx_core_client_rects
249: 247:                     .iter()
250: 248:                     .map(|rect| rect.left)
251: 249:                     .reduce(f64::min)
252: 250:                     .expect("Enough elements exist.");
253: 251:                 let measure_rects: Vec<&ClientRectObject> = lyx-core-lyx_core_lyx-core-lyx_core_client_rects
254: 252:                     .iter()
255: 253:                     .filter(|rect| {
256: 254:                         if is_left_side {
257: 255:                             rect.left == min_left
258: 256:                         } else {
259: 257:                             rect.right == max_right
260: 258:                         }
261: 259:                     })
262: 260:                     .collect();
263: 261: 
264: 262:                 let top = measure_rects.first().expect("Enough elements exist.").top;
265: 263:                 let bottom = measure_rects.last().expect("Enough elements exist.").bottom;
266: 264:                 let left = min_left;
267: 265:                 let right = max_right;
268: 266:                 let width = right - left;
269: 267:                 let height = bottom - top;
270: 268: 
271: 269:                 return ClientRectObject {
272: 270:                     x: left,
273: 271:                     y: top,
274: 272:                     width,
275: 273:                     height,
276: 274:                     top,
277: 275:                     right,
278: 276:                     bottom,
279: 277:                     left,
280: 278:                 };
281: 279:             }
282: 280: 
283: 281:             fallback.clone()
284: 282:         };
285: 283: 
286: 284:         let reset_rects = platform.get_element_rects(GetElementRectsArgs {
287: 285:             reference: ElementOrVirtual::VirtualElement(Box::new(DefaultVirtualElement::new(
288: 286:                 Rc::new(get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect),
289: 287:             ))),
290: 288:             floating: elements.floating,
291: 289:             strategy,
292: 290:         });
293: 291: 
294: 292:         if rects.reference.x != reset_rects.reference.x
295: 293:             || rects.reference.y != reset_rects.reference.y
296: 294:             || rects.reference.width != reset_rects.reference.width
297: 295:             || rects.reference.height != reset_rects.reference.height
298: 296:         {
299: 297:             MiddlewareReturn {
300: 298:                 x: None,
301: 299:                 y: None,
302: 300:                 data: None,
303: 301:                 reset: Some(Reset::Value(ResetValue {
304: 302:                     placement: None,
305: 303:                     rects: Some(ResetRects::Value(reset_rects)),
306: 304:                 })),
307: 305:             }
308: 306:         } else {
309: 307:             MiddlewareReturn {
310: 308:                 x: None,
311: 309:                 y: None,
312: 310:                 data: None,
313: 311:                 reset: None,
314: 312:             }
315: 313:         }
316: 314:     }
317: 315: }
318: 316: 
319: 317: impl<Element: Clone, Window: Clone> MiddlewareWithOptions<Element, Window, InlineOptions>
320: 318:     for Inline<'_, Element, Window>
321: 319: {
322: 320:     fn options(&self) -> &Derivable<'_, Element, Window, InlineOptions> {
323: 321:         &self.options
324: 322:     }
325: 323: }
326: ```
```
