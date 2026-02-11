### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\oco.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\oco.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::{
21: 19:         attribute::{any_attribute::AnyAttribute, AttributeValue},
22: 20:         class::IntoClass,
23: 21:         element::InnerHtmlValue,
24: 22:         property::IntoProperty,
25: 23:         style::IntoStyle,
26: 24:     },
27: 25:     hydration::Cursor,
28: 26:     no_attrs,
29: 27:     prelude::{Mountable, Render, RenderHtml},
30: 28:     renderer::Rndr,
31: 29:     view::{strings::StrState, Position, PositionState, ToTemplate},
32: 30: };
33: 31: use lyx-core-oco::Oco;
34: 32: use wasm_bindgen::JsValue;
35: 33: 
36: 34: /// Retained view state for [`Oco`].
37: 35: pub struct OcoStrState {
38: 36:     node: crate::renderer::types::Text,
39: 37:     str: Oco<'static, str>,
40: 38: }
41: 39: 
42: 40: impl Render for Oco<'static, str> {
43: 41:     type State = OcoStrState;
44: 42: 
45: 43:     fn build(self) -> Self::State {
46: 44:         let node = Rndr::create_text_node(&self);
47: 45:         OcoStrState { node, str: self }
48: 46:     }
49: 47: 
50: 48:     fn rebuild(self, state: &mut Self::State) {
51: 49:         let OcoStrState { node, str } = state;
52: 50:         if &self != str {
53: 51:             Rndr::set_text(node, &self);
54: 52:             *str = self;
55: 53:         }
56: 54:     }
57: 55: }
58: 56: 
59: 57: no_attrs!(Oco<'static, str>);
60: 58: 
61: 59: impl RenderHtml for Oco<'static, str> {
62: 60:     type AsyncOutput = Self;
63: 61:     type Owned = Self;
64: 62: 
65: 63:     const MIN_LENGTH: usize = 0;
66: 64: 
67: 65:     fn dry_resolve(&mut self) {}
68: 66: 
69: 67:     async fn resolve(self) -> Self::AsyncOutput {
70: 68:         self
71: 69:     }
72: 70: 
73: 71:     fn to_html_with_buf(
74: 72:         self,
75: 73:         buf: &mut String,
76: 74:         position: &mut Position,
77: 75:         escape: bool,
78: 76:         mark_branches: bool,
79: 77:         extra_attrs: Vec<AnyAttribute>,
80: 78:     ) {
81: 79:         <&str as RenderHtml>::to_html_with_buf(
82: 80:             &self,
83: 81:             buf,
84: 82:             position,
85: 83:             escape,
86: 84:             mark_branches,
87: 85:             extra_attrs,
88: 86:         )
89: 87:     }
90: 88: 
91: 89:     fn hydrate<const FROM_SERVER: bool>(
92: 90:         self,
93: 91:         cursor: &Cursor,
94: 92:         position: &PositionState,
95: 93:     ) -> Self::State {
96: 94:         let this: &str = self.as_ref();
97: 95:         let StrState { node, .. } = <&str as RenderHtml>::hydrate::<FROM_SERVER>(
98: 96:             this, cursor, position,
99: 97:         );
100: 98:         OcoStrState { node, str: self }
101: 99:     }
102: 100: 
103: 101:     fn into_owned(self) -> <Self as RenderHtml>::Owned {
104: 102:         self
105: 103:     }
106: 104: }
107: 105: 
108: 106: impl ToTemplate for Oco<'static, str> {
109: 107:     const TEMPLATE: &'static str = <&str as ToTemplate>::TEMPLATE;
110: 108: 
111: 109:     fn to_template(
112: 110:         buf: &mut String,
113: 111:         class: &mut String,
114: 112:         style: &mut String,
115: 113:         inner_html: &mut String,
116: 114:         position: &mut Position,
117: 115:     ) {
118: 116:         <&str as ToTemplate>::to_template(
119: 117:             buf, class, style, inner_html, position,
120: 118:         )
121: 119:     }
122: 120: }
123: 121: 
124: 122: impl Mountable for OcoStrState {
125: 123:     fn unmount(&mut self) {
126: 124:         self.node.unmount()
127: 125:     }
128: 126: 
129: 127:     fn mount(
130: 128:         &mut self,
131: 129:         parent: &crate::renderer::types::Element,
132: 130:         marker: Option<&crate::renderer::types::Node>,
133: 131:     ) {
134: 132:         Rndr::insert_node(parent, self.node.as_ref(), marker);
135: 133:     }
136: 134: 
137: 135:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
138: 136:         self.node.insert_before_this(child)
139: 137:     }
140: 138: 
141: 139:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
142: 140:         vec![]
143: 141:     }
144: 142: }
145: 143: 
146: 144: impl AttributeValue for Oco<'static, str> {
147: 145:     type AsyncOutput = Self;
148: 146:     type State = (crate::renderer::types::Element, Oco<'static, str>);
149: 147:     type Cloneable = Self;
150: 148:     type CloneableOwned = Self;
151: 149: 
152: 150:     fn html_len(&self) -> usize {
153: 151:         self.as_str().len()
154: 152:     }
155: 153: 
156: 154:     fn to_html(self, key: &str, buf: &mut String) {
157: 155:         <&str as AttributeValue>::to_html(self.as_str(), key, buf);
158: 156:     }
159: 157: 
160: 158:     fn to_template(_key: &str, _buf: &mut String) {}
161: 159: 
162: 160:     fn hydrate<const FROM_SERVER: bool>(
163: 161:         self,
164: 162:         key: &str,
165: 163:         el: &crate::renderer::types::Element,
166: 164:     ) -> Self::State {
167: 165:         let (el, _) = <&str as AttributeValue>::hydrate::<FROM_SERVER>(
168: 166:             self.as_str(),
169: 167:             key,
170: 168:             el,
171: 169:         );
172: 170:         (el, self)
173: 171:     }
174: 172: 
175: 173:     fn build(
176: 174:         self,
177: 175:         el: &crate::renderer::types::Element,
178: 176:         key: &str,
179: 177:     ) -> Self::State {
180: 178:         Rndr::set_attribute(el, key, &self);
181: 179:         (el.clone(), self)
182: 180:     }
183: 181: 
184: 182:     fn rebuild(self, key: &str, state: &mut Self::State) {
185: 183:         let (el, prev_value) = state;
186: 184:         if self != *prev_value {
187: 185:             Rndr::set_attribute(el, key, &self);
188: 186:         }
189: 187:         *prev_value = self;
190: 188:     }
191: 189: 
192: 190:     fn into_cloneable(mut self) -> Self::Cloneable {
193: 191:         // ensure it's reference-counted
194: 192:         self.upgrade_inplace();
195: 193:         self
196: 194:     }
197: 195: 
198: 196:     fn into_cloneable_owned(mut self) -> Self::CloneableOwned {
199: 197:         // ensure it's reference-counted
200: 198:         self.upgrade_inplace();
201: 199:         self
202: 200:     }
203: 201: 
204: 202:     fn dry_resolve(&mut self) {}
205: 203: 
206: 204:     async fn resolve(self) -> Self::AsyncOutput {
207: 205:         self
208: 206:     }
209: 207: }
210: 208: 
211: 209: impl IntoClass for Oco<'static, str> {
212: 210:     type AsyncOutput = Self;
213: 211:     type State = (crate::renderer::types::Element, Self);
214: 212:     type Cloneable = Self;
215: 213:     type CloneableOwned = Self;
216: 214: 
217: 215:     fn html_len(&self) -> usize {
218: 216:         self.as_str().len()
219: 217:     }
220: 218: 
221: 219:     fn to_html(self, class: &mut String) {
222: 220:         IntoClass::to_html(self.as_str(), class);
223: 221:     }
224: 222: 
225: 223:     fn hydrate<const FROM_SERVER: bool>(
226: 224:         self,
227: 225:         el: &crate::renderer::types::Element,
228: 226:     ) -> Self::State {
229: 227:         if !FROM_SERVER {
230: 228:             Rndr::set_attribute(el, "class", &self);
231: 229:         }
232: 230:         (el.clone(), self)
233: 231:     }
234: 232: 
235: 233:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
236: 234:         Rndr::set_attribute(el, "class", &self);
237: 235:         (el.clone(), self)
238: 236:     }
239: 237: 
240: 238:     fn rebuild(self, state: &mut Self::State) {
241: 239:         let (el, prev) = state;
242: 240:         if self != *prev {
243: 241:             Rndr::set_attribute(el, "class", &self);
244: 242:         }
245: 243:         *prev = self;
246: 244:     }
247: 245: 
248: 246:     fn into_cloneable(mut self) -> Self::Cloneable {
249: 247:         // ensure it's reference-counted
250: 248:         self.upgrade_inplace();
251: 249:         self
252: 250:     }
253: 251: 
254: 252:     fn into_cloneable_owned(mut self) -> Self::CloneableOwned {
255: 253:         // ensure it's reference-counted
256: 254:         self.upgrade_inplace();
257: 255:         self
258: 256:     }
259: 257: 
260: 258:     fn dry_resolve(&mut self) {}
261: 259: 
262: 260:     async fn resolve(self) -> Self::AsyncOutput {
263: 261:         self
264: 262:     }
265: 263: 
266: 264:     fn reset(state: &mut Self::State) {
267: 265:         let (el, _prev) = state;
268: 266:         Rndr::remove_attribute(el, "class");
269: 267:     }
270: 268: }
271: 269: 
272: 270: impl IntoProperty for Oco<'static, str> {
273: 271:     type State = (crate::renderer::types::Element, JsValue);
274: 272:     type Cloneable = Self;
275: 273:     type CloneableOwned = Self;
276: 274: 
277: 275:     fn hydrate<const FROM_SERVER: bool>(
278: 276:         self,
279: 277:         el: &crate::renderer::types::Element,
280: 278:         key: &str,
281: 279:     ) -> Self::State {
282: 280:         let value = JsValue::from_str(self.as_ref());
283: 281:         Rndr::set_property_or_value(el, key, &value);
284: 282:         (el.clone(), value)
285: 283:     }
286: 284: 
287: 285:     fn build(
288: 286:         self,
289: 287:         el: &crate::renderer::types::Element,
290: 288:         key: &str,
291: 289:     ) -> Self::State {
292: 290:         let value = JsValue::from_str(self.as_ref());
293: 291:         Rndr::set_property_or_value(el, key, &value);
294: 292:         (el.clone(), value)
295: 293:     }
296: 294: 
297: 295:     fn rebuild(self, state: &mut Self::State, key: &str) {
298: 296:         let (el, prev) = state;
299: 297:         let value = JsValue::from_str(self.as_ref());
300: 298:         Rndr::set_property_or_value(el, key, &value);
301: 299:         *prev = value;
302: 300:     }
303: 301: 
304: 302:     fn into_cloneable(self) -> Self::Cloneable {
305: 303:         self
306: 304:     }
307: 305: 
308: 306:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
309: 307:         self
310: 308:     }
311: 309: }
312: 310: 
313: 311: impl IntoStyle for Oco<'static, str> {
314: 312:     type AsyncOutput = Self;
315: 313:     type State = (crate::renderer::types::Element, Self);
316: 314:     type Cloneable = Self;
317: 315:     type CloneableOwned = Self;
318: 316: 
319: 317:     fn to_html(self, style: &mut String) {
320: 318:         style.push_str(&self);
321: 319:         style.push(';');
322: 320:     }
323: 321: 
324: 322:     fn hydrate<const FROM_SERVER: bool>(
325: 323:         self,
326: 324:         el: &crate::renderer::types::Element,
327: 325:     ) -> Self::State {
328: 326:         (el.clone(), self)
329: 327:     }
330: 328: 
331: 329:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
332: 330:         Rndr::set_attribute(el, "style", &self);
333: 331:         (el.clone(), self)
334: 332:     }
335: 333: 
336: 334:     fn rebuild(self, state: &mut Self::State) {
337: 335:         let (el, prev) = state;
338: 336:         if self != *prev {
339: 337:             Rndr::set_attribute(el, "style", &self);
340: 338:         }
341: 339:         *prev = self;
342: 340:     }
343: 341: 
344: 342:     fn into_cloneable(self) -> Self::Cloneable {
345: 343:         self
346: 344:     }
347: 345: 
348: 346:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
349: 347:         self
350: 348:     }
351: 349: 
352: 350:     fn dry_resolve(&mut self) {}
353: 351: 
354: 352:     async fn resolve(self) -> Self::AsyncOutput {
355: 353:         self
356: 354:     }
357: 355: 
358: 356:     fn reset(state: &mut Self::State) {
359: 357:         let (el, _prev) = state;
360: 358:         Rndr::remove_attribute(el, "style");
361: 359:     }
362: 360: }
363: 361: 
364: 362: impl InnerHtmlValue for Oco<'static, str> {
365: 363:     type AsyncOutput = Self;
366: 364:     type State = (crate::renderer::types::Element, Self);
367: 365:     type Cloneable = Self;
368: 366:     type CloneableOwned = Self;
369: 367: 
370: 368:     fn html_len(&self) -> usize {
371: 369:         self.len()
372: 370:     }
373: 371: 
374: 372:     fn to_html(self, buf: &mut String) {
375: 373:         buf.push_str(&self);
376: 374:     }
377: 375: 
378: 376:     fn to_template(_buf: &mut String) {}
379: 377: 
380: 378:     fn hydrate<const FROM_SERVER: bool>(
381: 379:         self,
382: 380:         el: &crate::renderer::types::Element,
383: 381:     ) -> Self::State {
384: 382:         if !FROM_SERVER {
385: 383:             Rndr::set_inner_html(el, &self);
386: 384:         }
387: 385:         (el.clone(), self)
388: 386:     }
389: 387: 
390: 388:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
391: 389:         Rndr::set_inner_html(el, &self);
392: 390:         (el.clone(), self)
393: 391:     }
394: 392: 
395: 393:     fn rebuild(self, state: &mut Self::State) {
396: 394:         if self != state.1 {
397: 395:             Rndr::set_inner_html(&state.0, &self);
398: 396:             state.1 = self;
399: 397:         }
400: 398:     }
401: 399: 
402: 400:     fn into_cloneable(mut self) -> Self::Cloneable {
403: 401:         // ensure it's reference-counted
404: 402:         self.upgrade_inplace();
405: 403:         self
406: 404:     }
407: 405: 
408: 406:     fn into_cloneable_owned(mut self) -> Self::CloneableOwned {
409: 407:         // ensure it's reference-counted
410: 408:         self.upgrade_inplace();
411: 409:         self
412: 410:     }
413: 411: 
414: 412:     fn dry_resolve(&mut self) {}
415: 413: 
416: 414:     async fn resolve(self) -> Self::AsyncOutput {
417: 415:         self
418: 416:     }
419: 417: }
420: 418: ```
421: 419: ```
422: 420: ```
423: 421: ```
424: 422: ```
425: 423: ```
426: 424: ```
427: 425: ```
428: ```
```
