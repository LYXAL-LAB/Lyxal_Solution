### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\types.rs
2: ```rust
3: 1: use std::fmt::Debug;
4: 2: use std::{collections::HashMap, ptr};
5: 3: 
6: 4: use dyn_derive::dyn_trait;
7: 5: use serde::{Serialize, de::DeserializeOwned};
8: 6: 
9: 7: use lyx_ui_foundations_utils::{
10: 8:     ClientRectObject, Coords, Dimensions, ElementOrVirtual, ElementOrWindow, ElementRects, Length,
11: 9:     OwnedElementOrWindow, Placement, Rect, Strategy,
12: 10: };
13: 11: 
14: 12: pub type DerivableFn<'a, Element, Window, T> = &'a dyn Fn(MiddlewareState<Element, Window>) -> T;
15: 13: 
16: 14: pub enum Derivable<'a, Element: Clone + 'static, Window: Clone, T: Clone> {
17: 15:     Value(T),
18: 16:     Fn(DerivableFn<'a, Element, Window, T>),
19: 17: }
20: 18: 
21: 19: impl<Element: Clone, Window: Clone, T: Clone> Clone for Derivable<'_, Element, Window, T> {
22: 20:     fn clone(&self) -> Self {
23: 21:         match self {
24: 22:             Self::Value(value) => Self::Value(value.clone()),
25: 23:             Self::Fn(value) => Self::Fn(*value),
26: 24:         }
27: 25:     }
28: 26: }
29: 27: 
30: 28: impl<Element: Clone, Window: Clone, T: Clone> Derivable<'_, Element, Window, T> {
31: 29:     pub fn evaluate(&self, state: MiddlewareState<Element, Window>) -> T {
32: 30:         match self {
33: 31:             Derivable::Value(value) => value.clone(),
34: 32:             Derivable::Fn(func) => func(state),
35: 33:         }
36: 34:     }
37: 35: }
38: 36: 
39: 37: impl<Element: Clone, Window: Clone, T: Clone> From<T> for Derivable<'_, Element, Window, T> {
40: 38:     fn from(value: T) -> Self {
41: 39:         Derivable::Value(value)
42: 40:     }
43: 41: }
44: 42: 
45: 43: impl<'a, Element: Clone, Window: Clone, T: Clone> From<DerivableFn<'a, Element, Window, T>>
46: 44:     for Derivable<'a, Element, Window, T>
47: 45: {
48: 46:     fn from(value: DerivableFn<'a, Element, Window, T>) -> Self {
49: 47:         Derivable::Fn(value)
50: 48:     }
51: 49: }
52: 50: 
53: 51: impl<Element: Clone, Window: Clone, T: Clone + PartialEq> PartialEq
54: 52:     for Derivable<'_, Element, Window, T>
55: 53: {
56: 54:     fn eq(&self, other: &Self) -> bool {
57: 55:         match (self, other) {
58: 56:             (Self::Value(a), Self::Value(b)) => a == b,
59: 57:             (Self::Fn(a), Self::Fn(b)) => ptr::eq(a, b),
60: 58:             _ => false,
61: 59:         }
62: 60:     }
63: 61: }
64: 62: 
65: 63: /// Arguments for [`Platform::get_element_rects`].
66: 64: pub struct GetElementRectsArgs<'a, Element: Clone + 'static> {
67: 65:     pub reference: ElementOrVirtual<'a, Element>,
68: 66:     pub floating: &'a Element,
69: 67:     pub strategy: Strategy,
70: 68: }
71: 69: 
72: 70: /// Arguments for [`Platform::get_clipping_rect`].
73: 71: pub struct GetClippingRectArgs<'a, Element> {
74: 72:     pub element: &'a Element,
75: 73:     pub boundary: Boundary<Element>,
76: 74:     pub root_boundary: RootBoundary,
77: 75:     pub strategy: Strategy,
78: 76: }
79: 77: 
80: 78: /// Arguments for [`Platform::convert_offset_parent_relative_rect_to_viewport_relative_rect`].
81: 79: pub struct ConvertOffsetParentRelativeRectToViewportRelativeRectArgs<
82: 80:     'a,
83: 81:     Element: Clone + 'static,
84: 82:     Window: Clone,
85: 83: > {
86: 84:     pub elements: Option<Elements<'a, Element>>,
87: 85:     pub rect: Rect,
88: 86:     pub offset_parent: Option<ElementOrWindow<'a, Element, Window>>,
89: 87:     pub strategy: Strategy,
90: 88: }
91: 89: 
92: 90: /// Platform interface methods to work with the current platform.
93: 91: ///
94: 92: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/platform.html) for more documentation.
95: 93: pub trait Platform<Element: Clone, Window: Clone>: Debug {
96: 94:     fn get_element_rects(&self, args: GetElementRectsArgs<Element>) -> ElementRects;
97: 95: 
98: 96:     fn get_clipping_rect(&self, args: GetClippingRectArgs<Element>) -> Rect;
99: 97: 
100: 98:     fn get_dimensions(&self, element: &Element) -> Dimensions;
101: 99: 
102: 100:     fn convert_offset_parent_relative_rect_to_viewport_relative_rect(
103: 101:         &self,
104: 102:         _args: ConvertOffsetParentRelativeRectToViewportRelativeRectArgs<Element, Window>,
105: 103:     ) -> Option<Rect> {
106: 104:         None
107: 105:     }
108: 106: 
109: 107:     fn get_offset_parent(
110: 108:         &self,
111: 109:         _element: &Element,
112: 110:     ) -> Option<OwnedElementOrWindow<Element, Window>> {
113: 111:         None
114: 112:     }
115: 113: 
116: 114:     fn get_document_element(&self, _element: &Element) -> Option<Element> {
117: 115:         None
118: 116:     }
119: 117: 
120: 118:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(
121: 119:         &self,
122: 120:         _element: ElementOrVirtual<Element>,
123: 121:     ) -> Option<Vec<ClientRectObject>> {
124: 122:         None
125: 123:     }
126: 124: 
127: 125:     fn is_rtl(&self, _element: &Element) -> Option<bool> {
128: 126:         None
129: 127:     }
130: 128: 
131: 129:     fn get_scale(&self, _element: &Element) -> Option<Coords> {
132: 130:         None
133: 131:     }
134: 132: 
135: 133:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_length(&self, _element: &Element, _length: Length) -> Option<f64> {
136: 134:         None
137: 135:     }
138: 136: }
139: 137: 
140: 138: /// Data stored by middleware.
141: 139: #[derive(Clone, Debug, Default, PartialEq)]
142: 140: pub struct MiddlewareData {
143: 141:     values: HashMap<String, serde_json::Value>,
144: 142: }
145: 143: 
146: 144: impl MiddlewareData {
147: 145:     pub fn get(&self, key: &str) -> Option<&serde_json::Value> {
148: 146:         self.values.get(key)
149: 147:     }
150: 148: 
151: 149:     pub fn get_as<D: DeserializeOwned>(&self, key: &str) -> Option<D> {
152: 150:         self.values.get(key).map(|value| {
153: 151:             serde_json::from_value::<D>(value.clone()).expect("JSON should be valid data.")
154: 152:         })
155: 153:     }
156: 154: 
157: 155:     pub fn set(&mut self, key: &str, value: serde_json::Value) {
158: 156:         self.values.insert(key.into(), value);
159: 157:     }
160: 158: 
161: 159:     pub fn set_as<S: Serialize>(&mut self, key: &str, value: S) {
162: 160:         self.values.insert(
163: 161:             key.into(),
164: 162:             serde_json::to_value(value).expect("Data should be valid JSON."),
165: 163:         );
166: 164:     }
167: 165: }
168: 166: 
169: 167: /// Options for [`compute_position`][crate::compute_position::compute_position].
170: 168: #[derive(Clone)]
171: 169: pub struct ComputePositionConfig<'a, Element: 'static, Window: 'static> {
172: 170:     /// Object to interface with the current platform.
173: 171:     pub platform: &'a dyn Platform<Element, Window>,
174: 172: 
175: 173:     /// Where to place the floating element relative to the reference element.
176: 174:     ///
177: 175:     /// Defaults to [`Placement::Bottom`].
178: 176:     pub placement: Option<Placement>,
179: 177: 
180: 178:     /// The strategy to use when positioning the floating element.
181: 179:     ///
182: 180:     /// Defaults to [`Strategy::Absolute`].
183: 181:     pub strategy: Option<Strategy>,
184: 182: 
185: 183:     /// Array of middleware objects to modify the positioning or provide data for rendering.
186: 184:     ///
187: 185:     /// Defaults to an empty vector.
188: 186:     pub middleware: Option<Vec<Box<dyn Middleware<Element, Window>>>>,
189: 187: }
190: 188: 
191: 189: impl<'a, Element, Window> ComputePositionConfig<'a, Element, Window> {
192: 190:     pub fn new(platform: &'a dyn Platform<Element, Window>) -> Self {
193: 191:         ComputePositionConfig {
194: 192:             platform,
195: 193:             placement: None,
196: 194:             strategy: None,
197: 195:             middleware: None,
198: 196:         }
199: 197:     }
200: 198: 
201: 199:     /// Set `platform` option.
202: 200:     pub fn platform(mut self, value: &'a dyn Platform<Element, Window>) -> Self {
203: 201:         self.platform = value;
204: 202:         self
205: 203:     }
206: 204: 
207: 205:     /// Set `placement` option.
208: 206:     pub fn placement(mut self, value: Placement) -> Self {
209: 207:         self.placement = Some(value);
210: 208:         self
211: 209:     }
212: 210: 
213: 211:     /// Set `strategy` option.
214: 212:     pub fn strategy(mut self, value: Strategy) -> Self {
215: 213:         self.strategy = Some(value);
216: 214:         self
217: 215:     }
218: 216: 
219: 217:     /// Set `middleware` option.
220: 218:     pub fn middleware(mut self, value: Vec<Box<dyn Middleware<Element, Window>>>) -> Self {
221: 219:         self.middleware = Some(value);
222: 220:         self
223: 221:     }
224: 222: }
225: 223: 
226: 224: /// Return of [`compute_position`][crate::compute_position::compute_position].
227: 225: #[derive(Clone, Debug, PartialEq)]
228: 226: pub struct ComputePositionReturn {
229: 227:     pub x: f64,
230: 228:     pub y: f64,
231: 229: 
232: 230:     /// The final chosen placement of the floating element.
233: 231:     pub placement: Placement,
234: 232: 
235: 233:     /// The strategy used to position the floating element.
236: 234:     pub strategy: Strategy,
237: 235: 
238: 236:     /// Object containing data returned from all middleware, keyed by their name.
239: 237:     pub middleware_data: MiddlewareData,
240: 238: }
241: 239: 
242: 240: #[derive(Clone, Debug, PartialEq)]
243: 241: pub enum ResetRects {
244: 242:     True,
245: 243:     Value(ElementRects),
246: 244: }
247: 245: 
248: 246: #[derive(Clone, Debug, PartialEq)]
249: 247: pub struct ResetValue {
250: 248:     pub placement: Option<Placement>,
251: 249:     pub rects: Option<ResetRects>,
252: 250: }
253: 251: 
254: 252: #[derive(Clone, Debug, PartialEq)]
255: 253: pub enum Reset {
256: 254:     True,
257: 255:     Value(ResetValue),
258: 256: }
259: 257: 
260: 258: /// Return of [`Middleware::compute`].
261: 259: #[derive(Clone, Debug, PartialEq)]
262: 260: pub struct MiddlewareReturn {
263: 261:     pub x: Option<f64>,
264: 262:     pub y: Option<f64>,
265: 263:     pub data: Option<serde_json::Value>,
266: 264:     pub reset: Option<Reset>,
267: 265: }
268: 266: 
269: 267: /// Middleware used by [`compute_position`][`crate::compute_position::compute_position`].
270: 268: #[dyn_trait]
271: 269: pub trait Middleware<Element: Clone + 'static, Window: Clone + 'static>: Clone + PartialEq {
272: 270:     /// The name of this middleware.
273: 271:     fn name(&self) -> &'static str;
274: 272: 
275: 273:     /// Executes this middleware.
276: 274:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn;
277: 275: }
278: 276: 
279: 277: /// Middleware with options.
280: 278: pub trait MiddlewareWithOptions<Element: Clone, Window: Clone, O: Clone> {
281: 279:     /// The options passed to this middleware.
282: 280:     fn options(&self) -> &Derivable<'_, Element, Window, O>;
283: 281: }
284: 282: 
285: 283: pub struct Elements<'a, Element: Clone + 'static> {
286: 284:     pub reference: ElementOrVirtual<'a, Element>,
287: 285:     pub floating: &'a Element,
288: 286: }
289: 287: 
290: 288: impl<'a, Element: Clone> Elements<'a, Element> {
291: 289:     pub fn get_element_context(
292: 290:         &self,
293: 291:         element_context: ElementContext,
294: 292:     ) -> ElementOrVirtual<'a, Element> {
295: 293:         match element_context {
296: 294:             ElementContext::Reference => self.reference.clone(),
297: 295:             ElementContext::Floating => self.floating.into(),
298: 296:         }
299: 297:     }
300: 298: }
301: 299: 
302: 300: impl<Element: Clone> Clone for Elements<'_, Element> {
303: 301:     fn clone(&self) -> Self {
304: 302:         Self {
305: 303:             reference: self.reference.clone(),
306: 304:             floating: self.floating,
307: 305:         }
308: 306:     }
309: 307: }
310: 308: 
311: 309: /// State passed to [`Middleware::compute`].
312: 310: pub struct MiddlewareState<'a, Element: Clone + 'static, Window: Clone> {
313: 311:     pub x: f64,
314: 312:     pub y: f64,
315: 313:     pub initial_placement: Placement,
316: 314:     pub placement: Placement,
317: 315:     pub strategy: Strategy,
318: 316:     pub middleware_data: &'a MiddlewareData,
319: 317:     pub elements: Elements<'a, Element>,
320: 318:     pub rects: &'a ElementRects,
321: 319:     pub platform: &'a dyn Platform<Element, Window>,
322: 320: }
323: 321: 
324: 322: impl<Element: Clone, Window: Clone> Clone for MiddlewareState<'_, Element, Window> {
325: 323:     fn clone(&self) -> Self {
326: 324:         Self {
327: 325:             x: self.x,
328: 326:             y: self.y,
329: 327:             initial_placement: self.initial_placement,
330: 328:             placement: self.placement,
331: 329:             strategy: self.strategy,
332: 330:             middleware_data: self.middleware_data,
333: 331:             elements: self.elements.clone(),
334: 332:             rects: self.rects,
335: 333:             platform: self.platform,
336: 334:         }
337: 335:     }
338: 336: }
339: 337: 
340: 338: #[derive(Clone, Debug, PartialEq)]
341: 339: pub enum Boundary<Element> {
342: 340:     ClippingAncestors,
343: 341:     Element(Element),
344: 342:     Elements(Vec<Element>),
345: 343: }
346: 344: 
347: 345: #[derive(Clone, Debug, PartialEq)]
348: 346: pub enum RootBoundary {
349: 347:     Viewport,
350: 348:     Document,
351: 349:     Rect(Rect),
352: 350: }
353: 351: 
354: 352: #[derive(Copy, Clone, Debug, PartialEq)]
355: 353: pub enum ElementContext {
356: 354:     Reference,
357: 355:     Floating,
358: 356: }
359: ```
```
