1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\types.rs
42: 40: ```rust
43: 41: use std::{fmt::Display, rc::Rc};
44: 42: 
45: 43: use lyx_ui_foundations_dom::{
46: 44:     AutoUpdateOptions, ElementOrVirtual, Middleware, MiddlewareData, Placement, Strategy,
47: 45:     auto_update,
48: 46: };
49: 47: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{prelude::*, lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::style::IntoStyle};
50: 48: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
51: 49: use web_sys::{Element, Window};
52: 50: 
53: 51: pub type WhileElementsMountedFn =
54: 52:     dyn Fn(ElementOrVirtual, &Element, Rc<dyn Fn()>) -> WhileElementsMountedCleanupFn;
55: 53: 
56: 54: pub type WhileElementsMountedCleanupFn = Box<dyn Fn()>;
57: 55: 
58: 56: pub type Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMiddleware = SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Vec<Box<dyn Middleware<Element, Window>>>>;
59: 57: 
60: 58: /// Options for [`use_floating`][`crate::use_floating::use_floating`].
61: 59: #[derive(Clone, Default)]
62: 60: pub struct UseFloatingOptions {
63: 61:     /// Represents the open/close state of the floating element.
64: 62:     ///
65: 63:     /// Defaults to `true`.
66: 64:     pub open: MaybeProp<bool>,
67: 65: 
68: 66:     /// Where to place the floating element relative to the reference element.
69: 67:     ///
70: 68:     /// Defaults to [`Placement::Bottom`].
71: 69:     pub placement: MaybeProp<Placement>,
72: 70: 
73: 71:     /// The strategy to use when positioning the floating element.
74: 72:     ///
75: 73:     /// Defaults to [`Strategy::Absolute`].
76: 74:     pub strategy: MaybeProp<Strategy>,
77: 75: 
78: 76:     /// Array of middleware objects to modify the positioning or provide data for rendering.
79: 77:     ///
80: 78:     /// Defaults to an empty vector.
81: 79:     pub middleware: MaybeProp<Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMiddleware>,
82: 80: 
83: 81:     ///  Whether to use `transform` for positioning instead of `top` and `left` in the `floatingStyles` object.
84: 82:     ///
85: 83:     /// Defaults to `true`.
86: 84:     pub transform: MaybeProp<bool>,
87: 85: 
88: 86:     /// Callback to handle mounting/unmounting of the elements.
89: 87:     ///
90: 88:     /// Defaults to [`Option::None`].
91: 89:     pub while_elements_mounted: MaybeProp<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Rc<WhileElementsMountedFn>>>,
92: 90: }
93: 91: 
94: 92: impl UseFloatingOptions {
95: 93:     /// Set `open` option.
96: 94:     pub fn open<I: Into<MaybeProp<bool>>>(mut self, value: I) -> Self {
97: 95:         self.open = value.into();
98: 96:         self
99: 97:     }
100: 98: 
101: 99:     /// Set `placement` option.
102: 100:     pub fn placement<I: Into<MaybeProp<Placement>>>(mut self, value: I) -> Self {
103: 101:         self.placement = value.into();
104: 102:         self
105: 103:     }
106: 104: 
107: 105:     /// Set `strategy` option.
108: 106:     pub fn strategy<I: Into<MaybeProp<Strategy>>>(mut self, value: I) -> Self {
109: 107:         self.strategy = value.into();
110: 108:         self
111: 109:     }
112: 110: 
113: 111:     /// Set `middleware` option.
114: 112:     pub fn middleware<I: Into<MaybeProp<Wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMiddleware>>>(mut self, value: I) -> Self {
115: 113:         self.middleware = value.into();
116: 114:         self
117: 115:     }
118: 116: 
119: 117:     /// Set `transform` option.
120: 118:     pub fn transform<I: Into<MaybeProp<bool>>>(mut self, value: I) -> Self {
121: 119:         self.transform = value.into();
122: 120:         self
123: 121:     }
124: 122: 
125: 123:     /// Set `while_elements_mounted` option.
126: 124:     pub fn while_elements_mounted<I: Into<MaybeProp<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Rc<WhileElementsMountedFn>>>>>(
127: 125:         mut self,
128: 126:         value: I,
129: 127:     ) -> Self {
130: 128:         self.while_elements_mounted = value.into();
131: 129:         self
132: 130:     }
133: 131: 
134: 132:     /// Set `while_elements_mounted` option to [`auto_update`] with [`AutoUpdateOptions::default`].
135: 133:     pub fn while_elements_mounted_auto_update(self) -> Self {
136: 134:         let auto_update_rc: SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Rc<WhileElementsMountedFn>> =
137: 135:             SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(Rc::new(|reference, floating, update| {
138: 136:                 auto_update(reference, floating, update, AutoUpdateOptions::default())
139: 137:             }));
140: 138:         self.while_elements_mounted(auto_update_rc)
141: 139:     }
142: 140: 
143: 141:     /// Set `while_elements_mounted` option to [`auto_update`] with [`AutoUpdateOptions::default`] when `enabled` is `true`.
144: 142:     pub fn while_elements_mounted_auto_update_with_enabled(self, enabled: Signal<bool>) -> Self {
145: 143:         let auto_update_rc: SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Rc<WhileElementsMountedFn>> =
146: 144:             SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(Rc::new(|reference, floating, update| {
147: 145:                 auto_update(reference, floating, update, AutoUpdateOptions::default())
148: 146:             }));
149: 147:         self.while_elements_mounted(MaybeProp::derive(move || {
150: 148:             if enabled.get() {
151: 149:                 Some(auto_update_rc.clone())
152: 150:             } else {
153: 151:                 None
154: 152:             }
155: 153:         }))
156: 154:     }
157: 155: 
158: 156:     /// Set `while_elements_mounted` option to [`auto_update`] with `options`.
159: 157:     pub fn while_elements_mounted_auto_update_with_options(
160: 158:         self,
161: 159:         options: Signal<AutoUpdateOptions>,
162: 160:     ) -> Self {
163: 161:         let auto_update_rc =
164: 162:             move |options: AutoUpdateOptions| -> SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Rc<WhileElementsMountedFn>> {
165: 163:                 SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(Rc::new(move |reference, floating, update| {
166: 164:                     auto_update(reference, floating, update, options.clone())
167: 165:                 }))
168: 166:             };
169: 167: 
170: 168:         self.while_elements_mounted(MaybeProp::derive(move || {
171: 169:             Some(auto_update_rc(options.get()))
172: 170:         }))
173: 171:     }
174: 172: 
175: 173:     /// Set `while_elements_mounted` option to [`auto_update`] with `options` when `enabled` is `true`.
176: 174:     pub fn while_elements_mounted_auto_update_with_enabled_and_options(
177: 175:         self,
178: 176:         enabled: Signal<bool>,
179: 177:         options: Signal<AutoUpdateOptions>,
180: 178:     ) -> Self {
181: 179:         let auto_update_rc =
182: 180:             move |options: AutoUpdateOptions| -> SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Rc<WhileElementsMountedFn>> {
183: 181:                 SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(Rc::new(move |reference, floating, update| {
184: 182:                     auto_update(reference, floating, update, options.clone())
185: 183:                 }))
186: 184:             };
187: 185: 
188: 186:         self.while_elements_mounted(MaybeProp::derive(move || {
189: 187:             if enabled.get() {
190: 188:                 Some(auto_update_rc(options.get()))
191: 189:             } else {
192: 190:                 None
193: 191:             }
194: 192:         }))
195: 193:     }
196: 194: }
197: 195: 
198: 196: /// CSS styles to lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply to the floating element to position it.
199: 197: #[derive(Clone, Debug, PartialEq)]
200: 198: pub struct FloatingStyles {
201: 199:     pub position: Strategy,
202: 200:     pub top: String,
203: 201:     pub left: String,
204: 202:     pub transform: Option<String>,
205: 203:     pub will_change: Option<String>,
206: 204: }
207: 205: 
208: 206: impl FloatingStyles {
209: 207:     pub fn style_position(&self) -> String {
210: 208:         match self.position {
211: 209:             Strategy::Absolute => "absolute".to_owned(),
212: 210:             Strategy::Fixed => "fixed".to_owned(),
213: 211:         }
214: 212:     }
215: 213: 
216: 214:     pub fn style_top(&self) -> String {
217: 215:         self.top.clone()
218: 216:     }
219: 217: 
220: 218:     pub fn style_left(&self) -> String {
221: 219:         self.left.clone()
222: 220:     }
223: 221: 
224: 222:     pub fn style_transform(&self) -> Option<String> {
225: 223:         self.transform.clone()
226: 224:     }
227: 225: 
228: 226:     pub fn style_will_change(&self) -> Option<String> {
229: 227:         self.will_change.clone()
230: 228:     }
231: 229: }
232: 230: 
233: 231: impl Display for FloatingStyles {
234: 232:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
235: 233:         write!(
236: 234:             f,
237: 235:             "position: {}; top: {}; left: {};{}{}",
238: 236:             match self.position {
239: 237:                 Strategy::Absolute => "absolute",
240: 238:                 Strategy::Fixed => "fixed",
241: 239:             },
242: 240:             self.top,
243: 241:             self.left,
244: 242:             self.transform
245: 243:                 .as_ref()
246: 244:                 .map_or("".to_owned(), |transform| format!(
247: 245:                     " transform: {transform};"
248: 246:                 ),),
249: 247:             self.will_change
250: 248:                 .as_ref()
251: 249:                 .map_or("".to_owned(), |will_change| format!(
252: 250:                     " will-change: {will_change};"
253: 251:                 ))
254: 252:         )
255: 253:     }
256: 254: }
257: 255: 
258: 256: impl IntoStyle for FloatingStyles {
259: 257:     type AsyncOutput = Self;
260: 258:     type State = (lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element, Self);
261: 259:     type Cloneable = Self;
262: 260:     type CloneableOwned = Self;
263: 261:     fn to_html(self, style: &mut String) {
264: 262:         style.push_str(&self.to_string());
265: 263:     }
266: 264: 
267: 265:     fn hydrate<const FROM_SERVER: bool>(
268: 266:         self,
269: 267:         el: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
270: 268:     ) -> Self::State {
271: 269:         (el.clone(), self)
272: 270:     }
273: 271: 
274: 272:     fn build(self, el: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element) -> Self::State {
275: 273:         lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::Rndr::set_attribute(el, "style", &self.to_string());
276: 274:         (el.clone(), self)
277: 275:     }
278: 276: 
279: 277:     fn rebuild(self, state: &mut Self::State) {
280: 278:         let (el, prev) = state;
281: 279:         if self != *prev {
282: 280:             lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::Rndr::set_attribute(el, "style", &self.to_string());
283: 281:         }
284: 282:         *prev = self;
285: 283:     }
286: 284: 
287: 285:     fn into_cloneable(self) -> Self::Cloneable {
288: 286:         self
289: 287:     }
290: 288: 
291: 289:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
292: 290:         self
293: 291:     }
294: 292: 
295: 293:     fn dry_resolve(&mut self) {}
296: 294: 
297: 295:     async fn resolve(self) -> Self::AsyncOutput {
298: 296:         self
299: 297:     }
300: 298: 
301: 299:     fn reset(state: &mut Self::State) {
302: 300:         let (el, _prev) = state;
303: 301:         lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::Rndr::remove_attribute(el, "style");
304: 302:     }
305: 303: }
306: 304: 
307: 305: /// Return of [`use_floating`][crate::use_floating::use_floating].
308: 306: pub struct UseFloatingReturn {
309: 307:     /// The x-coord of the floating element.
310: 308:     pub x: Signal<f64>,
311: 309: 
312: 310:     /// The y-coord of the floating element.
313: 311:     pub y: Signal<f64>,
314: 312: 
315: 313:     /// The stateful placement, which can be different from the initial `placement` passed as options.
316: 314:     pub placement: Signal<Placement>,
317: 315: 
318: 316:     /// The strategy to use when positioning the floating element.
319: 317:     pub strategy: Signal<Strategy>,
320: 318: 
321: 319:     /// Additional data from middleware.
322: 320:     pub middleware_data: Signal<MiddlewareData>,
323: 321: 
324: 322:     /// Indicates if the floating element has been positioned.
325: 323:     pub is_positioned: Signal<bool>,
326: 324: 
327: 325:     /// CSS styles to lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply to the floating element to position it.
328: 326:     pub floating_styles: Signal<FloatingStyles>,
329: 327: 
330: 328:     /// The function to update floating position manually.
331: 329:     pub update: SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Rc<dyn Fn()>>,
332: 330: }
333: 331: ```
334: 332: ```
335: 333: ```
336: 334: ```
337: 335: ```
338: 336: ```
339: 337: ```
340: 338: ```
341: 339: ```
342: 340: ```
343: 341: ```
344: 342: ```
345: 343: ```
346: 344: ```
347: 345: ```
348: 346: ```
349: 347: ```
350: 348: ```
351: 349: ```
352: 350: ```
353: ```
```

