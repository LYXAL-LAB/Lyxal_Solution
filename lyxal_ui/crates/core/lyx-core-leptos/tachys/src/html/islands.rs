### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\islands.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\islands.rs
18: 16: ```rust
19: 17: use super::attribute::{any_attribute::AnyAttribute, Attribute};
20: 18: use crate::{
21: 19:     hydration::Cursor,
22: 20:     prelude::{Render, RenderHtml},
23: 21:     ssr::StreamBuilder,
24: 22:     view::{add_attr::AddAnyAttr, Position, PositionState},
25: 23: };
26: 24: 
27: 25: /// An island of interactivity in an otherwise-inert HTML document.
28: 26: pub struct Island<View> {
29: 27:     has_element_representation: bool,
30: 28:     component: &'static str,
31: 29:     props_json: String,
32: 30:     view: View,
33: 31: }
34: 32: const ISLAND_TAG: &str = "lyx-core-lyx_core_lyx-core-lyx_core_leptos-island";
35: 33: const ISLAND_CHILDREN_TAG: &str = "lyx-core-lyx_core_lyx-core-lyx_core_leptos-children";
36: 34: 
37: 35: impl<View> Island<View> {
38: 36:     /// Creates a new island with the given component name.
39: 37:     pub fn new(component: &'static str, view: View) -> Self {
40: 38:         Island {
41: 39:             has_element_representation:
42: 40:                 Self::should_have_element_representation(),
43: 41:             component,
44: 42:             props_json: String::new(),
45: 43:             view,
46: 44:         }
47: 45:     }
48: 46: 
49: 47:     /// Adds serialized component props as JSON.
50: 48:     pub fn with_props(mut self, props_json: String) -> Self {
51: 49:         self.props_json = props_json;
52: 50:         self
53: 51:     }
54: 52: 
55: 53:     fn open_tag(component: &'static str, props: &str, buf: &mut String) {
56: 54:         buf.push('<');
57: 55:         buf.push_str(ISLAND_TAG);
58: 56:         buf.push(' ');
59: 57:         buf.push_str("data-component=\"");
60: 58:         buf.push_str(component);
61: 59:         buf.push('"');
62: 60:         if !props.is_empty() {
63: 61:             buf.push_str(" data-props=\"");
64: 62:             buf.push_str(&html_escape::encode_double_quoted_attribute(&props));
65: 63:             buf.push('"');
66: 64:         }
67: 65:         buf.push('>');
68: 66:     }
69: 67: 
70: 68:     fn close_tag(buf: &mut String) {
71: 69:         buf.push_str("</");
72: 70:         buf.push_str(ISLAND_TAG);
73: 71:         buf.push('>');
74: 72:     }
75: 73: 
76: 74:     /// Whether this island should be represented by an actual HTML element
77: 75:     fn should_have_element_representation() -> bool {
78: 76:         #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
79: 77:         {
80: 78:             use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::{use_context, IsHydrating};
81: 79:             let already_hydrating =
82: 80:                 use_context::<IsHydrating>().map(|h| h.0).unwrap_or(false);
83: 81:             !already_hydrating
84: 82:         }
85: 83:         #[cfg(not(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph"))]
86: 84:         {
87: 85:             true
88: 86:         }
89: 87:     }
90: 88: }
91: 89: 
92: 90: impl<View> Render for Island<View>
93: 91: where
94: 92:     View: Render,
95: 93: {
96: 94:     type State = View::State;
97: 95: 
98: 96:     fn build(self) -> Self::State {
99: 97:         self.view.build()
100: 98:     }
101: 99: 
102: 100:     fn rebuild(self, state: &mut Self::State) {
103: 101:         self.view.rebuild(state);
104: 102:     }
105: 103: }
106: 104: 
107: 105: impl<View> AddAnyAttr for Island<View>
108: 106: where
109: 107:     View: RenderHtml,
110: 108: {
111: 109:     type Output<SomeNewAttr: Attribute> =
112: 110:         Island<<View as AddAnyAttr>::Output<SomeNewAttr>>;
113: 111: 
114: 112:     fn add_any_attr<NewAttr: Attribute>(
115: 113:         self,
116: 114:         attr: NewAttr,
117: 115:     ) -> Self::Output<NewAttr>
118: 116:     where
119: 117:         Self::Output<NewAttr>: RenderHtml,
120: 118:     {
121: 119:         let Island {
122: 120:             has_element_representation,
123: 121:             component,
124: 122:             props_json,
125: 123:             view,
126: 124:         } = self;
127: 125:         Island {
128: 126:             has_element_representation,
129: 127:             component,
130: 128:             props_json,
131: 129:             view: view.add_any_attr(attr),
132: 130:         }
133: 131:     }
134: 132: }
135: 133: 
136: 134: impl<View> RenderHtml for Island<View>
137: 135: where
138: 136:     View: RenderHtml,
139: 137: {
140: 138:     type AsyncOutput = Island<View::AsyncOutput>;
141: 139:     type Owned = Island<View::Owned>;
142: 140: 
143: 141:     const MIN_LENGTH: usize = ISLAND_TAG.len() * 2
144: 142:         + "<>".len()
145: 143:         + "</>".len()
146: 144:         + "data-component".len()
147: 145:         + View::MIN_LENGTH;
148: 146: 
149: 147:     fn dry_resolve(&mut self) {
150: 148:         self.view.dry_resolve()
151: 149:     }
152: 150: 
153: 151:     async fn resolve(self) -> Self::AsyncOutput {
154: 152:         let Island {
155: 153:             has_element_representation,
156: 154:             component,
157: 155:             props_json,
158: 156:             view,
159: 157:         } = self;
160: 158:         Island {
161: 159:             has_element_representation,
162: 160:             component,
163: 161:             props_json,
164: 162:             view: view.resolve().await,
165: 163:         }
166: 164:     }
167: 165: 
168: 166:     fn to_html_with_buf(
169: 167:         self,
170: 168:         buf: &mut String,
171: 169:         position: &mut Position,
172: 170:         escape: bool,
173: 171:         mark_branches: bool,
174: 172:         extra_attrs: Vec<AnyAttribute>,
175: 173:     ) {
176: 174:         let has_element = self.has_element_representation;
177: 175:         if has_element {
178: 176:             Self::open_tag(self.component, &self.props_json, buf);
179: 177:         }
180: 178:         self.view.to_html_with_buf(
181: 179:             buf,
182: 180:             position,
183: 181:             escape,
184: 182:             mark_branches,
185: 183:             extra_attrs,
186: 184:         );
187: 185:         if has_element {
188: 186:             Self::close_tag(buf);
189: 187:         }
190: 188:     }
191: 189: 
192: 190:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
193: 191:         self,
194: 192:         buf: &mut StreamBuilder,
195: 193:         position: &mut Position,
196: 194:         escape: bool,
197: 195:         mark_branches: bool,
198: 196:         extra_attrs: Vec<AnyAttribute>,
199: 197:     ) where
200: 198:         Self: Sized,
201: 199:     {
202: 200:         let has_element = self.has_element_representation;
203: 201:         // insert the opening tag synchronously
204: 202:         let mut tag = String::new();
205: 203:         if has_element {
206: 204:             Self::open_tag(self.component, &self.props_json, &mut tag);
207: 205:         }
208: 206:         buf.push_sync(&tag);
209: 207: 
210: 208:         // streaming render for the view
211: 209:         self.view.to_html_async_with_buf::<OUT_OF_ORDER>(
212: 210:             buf,
213: 211:             position,
214: 212:             escape,
215: 213:             mark_branches,
216: 214:             extra_attrs,
217: 215:         );
218: 216: 
219: 217:         // and insert the closing tag synchronously
220: 218:         tag.clear();
221: 219:         if has_element {
222: 220:             Self::close_tag(&mut tag);
223: 221:         }
224: 222:         buf.push_sync(&tag);
225: 223:     }
226: 224: 
227: 225:     fn hydrate<const FROM_SERVER: bool>(
228: 226:         self,
229: 227:         cursor: &Cursor,
230: 228:         position: &PositionState,
231: 229:     ) -> Self::State {
232: 230:         if self.has_element_representation {
233: 231:             if position.get() == Position::FirstChild {
234: 232:                 cursor.child();
235: 233:             } else if position.get() == Position::NextChild {
236: 234:                 cursor.sibling();
237: 235:             }
238: 236:             position.set(Position::FirstChild);
239: 237:         }
240: 238: 
241: 239:         self.view.hydrate::<FROM_SERVER>(cursor, position)
242: 240:     }
243: 241: 
244: 242:     fn into_owned(self) -> Self::Owned {
245: 243:         Island {
246: 244:             has_element_representation: self.has_element_representation,
247: 245:             component: self.component,
248: 246:             props_json: self.props_json,
249: 247:             view: self.view.into_owned(),
250: 248:         }
251: 249:     }
252: 250: }
253: 251: 
254: 252: /// The children that will be projected into an [`Island`].
255: 253: pub struct IslandChildren<View> {
256: 254:     view: View,
257: 255:     on_hydrate: Option<Box<dyn Fn() + Send + Sync>>,
258: 256: }
259: 257: 
260: 258: impl<View> IslandChildren<View> {
261: 259:     /// Creates a new representation of the children.
262: 260:     pub fn new(view: View) -> Self {
263: 261:         IslandChildren {
264: 262:             view,
265: 263:             on_hydrate: None,
266: 264:         }
267: 265:     }
268: 266: 
269: 267:     /// Creates a new representation of the children, with a function to be called whenever
270: 268:     /// a child island hydrates.
271: 269:     pub fn new_with_on_hydrate(
272: 270:         view: View,
273: 271:         on_hydrate: impl Fn() + Send + Sync + 'static,
274: 272:     ) -> Self {
275: 273:         IslandChildren {
276: 274:             view,
277: 275:             on_hydrate: Some(Box::new(on_hydrate)),
278: 276:         }
279: 277:     }
280: 278: 
281: 279:     fn open_tag(buf: &mut String) {
282: 280:         buf.push('<');
283: 281:         buf.push_str(ISLAND_CHILDREN_TAG);
284: 282:         buf.push('>');
285: 283:     }
286: 284: 
287: 285:     fn close_tag(buf: &mut String) {
288: 286:         buf.push_str("</");
289: 287:         buf.push_str(ISLAND_CHILDREN_TAG);
290: 288:         buf.push('>');
291: 289:     }
292: 290: }
293: 291: 
294: 292: impl<View> Render for IslandChildren<View>
295: 293: where
296: 294:     View: Render,
297: 295: {
298: 296:     type State = ();
299: 297: 
300: 298:     fn build(self) -> Self::State {}
301: 299: 
302: 300:     fn rebuild(self, _state: &mut Self::State) {}
303: 301: }
304: 302: 
305: 303: impl<View> AddAnyAttr for IslandChildren<View>
306: 304: where
307: 305:     View: RenderHtml,
308: 306: {
309: 307:     type Output<SomeNewAttr: Attribute> =
310: 308:         IslandChildren<<View as AddAnyAttr>::Output<SomeNewAttr>>;
311: 309: 
312: 310:     fn add_any_attr<NewAttr: Attribute>(
313: 311:         self,
314: 312:         attr: NewAttr,
315: 313:     ) -> Self::Output<NewAttr>
316: 314:     where
317: 315:         Self::Output<NewAttr>: RenderHtml,
318: 316:     {
319: 317:         let IslandChildren { view, on_hydrate } = self;
320: 318:         IslandChildren {
321: 319:             view: view.add_any_attr(attr),
322: 320:             on_hydrate,
323: 321:         }
324: 322:     }
325: 323: }
326: 324: 
327: 325: impl<View> RenderHtml for IslandChildren<View>
328: 326: where
329: 327:     View: RenderHtml,
330: 328: {
331: 329:     type AsyncOutput = IslandChildren<View::AsyncOutput>;
332: 330:     type Owned = IslandChildren<View::Owned>;
333: 331: 
334: 332:     const MIN_LENGTH: usize = ISLAND_CHILDREN_TAG.len() * 2
335: 333:         + "<>".len()
336: 334:         + "</>".len()
337: 335:         + View::MIN_LENGTH;
338: 336: 
339: 337:     fn dry_resolve(&mut self) {
340: 338:         self.view.dry_resolve()
341: 339:     }
342: 340: 
343: 341:     async fn resolve(self) -> Self::AsyncOutput {
344: 342:         let IslandChildren { view, on_hydrate } = self;
345: 343:         IslandChildren {
346: 344:             view: view.resolve().await,
347: 345:             on_hydrate,
348: 346:         }
349: 347:     }
350: 348: 
351: 349:     fn to_html_with_buf(
352: 350:         self,
353: 351:         buf: &mut String,
354: 352:         position: &mut Position,
355: 353:         escape: bool,
356: 354:         mark_branches: bool,
357: 355:         extra_attrs: Vec<AnyAttribute>,
358: 356:     ) {
359: 357:         Self::open_tag(buf);
360: 358:         self.view.to_html_with_buf(
361: 359:             buf,
362: 360:             position,
363: 361:             escape,
364: 362:             mark_branches,
365: 363:             extra_attrs,
366: 364:         );
367: 365:         Self::close_tag(buf);
368: 366:     }
369: 367: 
370: 368:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
371: 369:         self,
372: 370:         buf: &mut StreamBuilder,
373: 371:         position: &mut Position,
374: 372:         escape: bool,
375: 373:         mark_branches: bool,
376: 374:         extra_attrs: Vec<AnyAttribute>,
377: 375:     ) where
378: 376:         Self: Sized,
379: 377:     {
380: 378:         // insert the opening tag synchronously
381: 379:         let mut tag = String::new();
382: 380:         Self::open_tag(&mut tag);
383: 381:         buf.push_sync(&tag);
384: 382: 
385: 383:         // streaming render for the view
386: 384:         self.view.to_html_async_with_buf::<OUT_OF_ORDER>(
387: 385:             buf,
388: 386:             position,
389: 387:             escape,
390: 388:             mark_branches,
391: 389:             extra_attrs,
392: 390:         );
393: 391: 
394: 392:         // and insert the closing tag synchronously
395: 393:         tag.clear();
396: 394:         Self::close_tag(&mut tag);
397: 395:         buf.push_sync(&tag);
398: 396:     }
399: 397: 
400: 398:     fn hydrate<const FROM_SERVER: bool>(
401: 399:         self,
402: 400:         cursor: &Cursor,
403: 401:         position: &PositionState,
404: 402:     ) -> Self::State {
405: 403:         // island children aren't hydrated
406: 404:         // we update the walk to pass over them
407: 405:         // but we don't hydrate their children
408: 406:         let curr_position = position.get();
409: 407:         if curr_position == Position::FirstChild {
410: 408:             cursor.child();
411: 409:         } else if curr_position != Position::Current {
412: 410:             cursor.sibling();
413: 411:         }
414: 412:         position.set(Position::NextChild);
415: 413: 
416: 414:         if let Some(on_hydrate) = self.on_hydrate {
417: 415:             use crate::{
418: 416:                 hydration::failed_to_cast_element, renderer::CastFrom,
419: 417:             };
420: 418: 
421: 419:             let el =
422: 420:                 crate::renderer::types::Element::cast_from(cursor.current())
423: 421:                     .unwrap_or_else(|| {
424: 422:                         failed_to_cast_element(
425: 423:                             "lyx-core-lyx_core_lyx-core-lyx_core_leptos-children",
426: 424:                             cursor.current(),
427: 425:                         )
428: 426:                     });
429: 427:             let cb = wasm_bindgen::closure::Closure::wrap(
430: 428:                 on_hydrate as Box<dyn Fn()>,
431: 429:             );
432: 430:             _ = js_sys::Reflect::set(
433: 431:                 &el,
434: 432:                 &wasm_bindgen::JsValue::from_str("$$on_hydrate"),
435: 433:                 &cb.into_js_value(),
436: 434:             );
437: 435:         }
438: 436:     }
439: 437: 
440: 438:     fn into_owned(self) -> Self::Owned {
441: 439:         IslandChildren {
442: 440:             view: self.view.into_owned(),
443: 441:             on_hydrate: self.on_hydrate,
444: 442:         }
445: 443:     }
446: 444: }
447: 445: ```
448: 446: ```
449: 447: ```
450: 448: ```
451: 449: ```
452: 450: ```
453: 451: ```
454: 452: ```
455: ```
```
