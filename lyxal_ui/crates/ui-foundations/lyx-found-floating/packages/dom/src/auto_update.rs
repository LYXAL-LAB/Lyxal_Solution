1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\auto_update.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\auto_update.rs
42: 40: ```rust
43: 41: use std::{cell::RefCell, rc::Rc};
44: 42: 
45: 43: use lyx_ui_foundations_utils::{
46: 44:     ClientRectObject,
47: 45:     dom::{OverflowAncestor, get_document_element, get_overflow_ancestors, get_window},
48: 46: };
49: 47: use web_sys::{
50: 48:     AddEventListenerOptions, Element, EventTarget, IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverEntry,
51: 49:     IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverInit, ResizeOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, ResizeOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverEntry,
52: 50:     wasm_bindgen::{JsCast, JsValue, closure::Closure},
53: 51:     window,
54: 52: };
55: 53: 
56: 54: use crate::{
57: 55:     types::{ElementOrVirtual, OwnedElementOrVirtual},
58: 56:     utils::{get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect::get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect, rects_are_equal::rects_are_equal},
59: 57: };
60: 58: 
61: 59: fn request_animation_frame(callback: &Closure<dyn FnMut()>) -> i32 {
62: 60:     window()
63: 61:         .expect("Window should exist.")
64: 62:         .request_animation_frame(callback.as_ref().unchecked_ref())
65: 63:         .expect("Request animation frame should be successful.")
66: 64: }
67: 65: 
68: 66: fn cancel_animation_frame(handle: i32) {
69: 67:     window()
70: 68:         .expect("Window should exist.")
71: 69:         .cancel_animation_frame(handle)
72: 70:         .expect("Cancel animation frame should be successful.")
73: 71: }
74: 72: 
75: 73: fn observe_move(element: Element, on_move: Rc<dyn Fn()>) -> Box<dyn Fn()> {
76: 74:     let io: Rc<RefCell<Option<IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server>>> = Rc::new(RefCell::new(None));
77: 75:     let timeout_id: Rc<RefCell<Option<i32>>> = Rc::new(RefCell::new(None));
78: 76: 
79: 77:     let window = get_window(Some(&element));
80: 78:     let root = get_document_element(Some((&element).into()));
81: 79: 
82: 80:     type ObserveClosure = Closure<dyn Fn(Vec<IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverEntry>)>;
83: 81:     let observe_closure: Rc<RefCell<Option<ObserveClosure>>> = Rc::new(RefCell::new(None));
84: 82: 
85: 83:     let cleanup_io = io.clone();
86: 84:     let cleanup_timeout_id = timeout_id.clone();
87: 85:     let cleanup_window = window.clone();
88: 86:     let cleanup_observe_closure = observe_closure.clone();
89: 87:     let cleanup = move || {
90: 88:         if let Some(timeout_id) = cleanup_timeout_id.take() {
91: 89:             cleanup_window.clear_timeout_with_handle(timeout_id);
92: 90:         }
93: 91: 
94: 92:         if let Some(io) = cleanup_io.take() {
95: 93:             io.disconnect();
96: 94:         }
97: 95: 
98: 96:         _ = cleanup_observe_closure.take();
99: 97:     };
100: 98:     let cleanup_rc = Rc::new(cleanup);
101: 99:     type RefreshFn = Box<dyn Fn(bool, f64)>;
102: 100:     let refresh_closure: Rc<RefCell<Option<RefreshFn>>> = Rc::new(RefCell::new(None));
103: 101:     let refresh_closure_clone = refresh_closure.clone();
104: 102: 
105: 103:     let refresh_cleanup = cleanup_rc.clone();
106: 104:     *refresh_closure_clone.borrow_mut() = Some(Box::new(move |skip: bool, threshold: f64| {
107: 105:         refresh_cleanup();
108: 106: 
109: 107:         let element_rect_for_root_margin = element.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect();
110: 108: 
111: 109:         if !skip {
112: 110:             on_move();
113: 111:         }
114: 112: 
115: 113:         if element_rect_for_root_margin.width() == 0.0
116: 114:             || element_rect_for_root_margin.height() == 0.0
117: 115:         {
118: 116:             return;
119: 117:         }
120: 118: 
121: 119:         let inset_top = element_rect_for_root_margin.top().floor();
122: 120:         let inset_right = (root.lyx-core-lyx_core_lyx-core-lyx_core_client_width() as f64
123: 121:             - (element_rect_for_root_margin.left() + element_rect_for_root_margin.width()))
124: 122:         .floor();
125: 123:         let inset_bottom = (root.lyx-core-lyx_core_lyx-core-lyx_core_client_height() as f64
126: 124:             - (element_rect_for_root_margin.top() + element_rect_for_root_margin.height()))
127: 125:         .floor();
128: 126:         let inset_left = element_rect_for_root_margin.left().floor();
129: 127:         let root_margin = format!(
130: 128:             "{}px {}px {}px {}px",
131: 129:             -inset_top, -inset_right, -inset_bottom, -inset_left
132: 130:         );
133: 131: 
134: 132:         let is_first_update: Rc<RefCell<bool>> = Rc::new(RefCell::new(true));
135: 133: 
136: 134:         let timeout_refresh = refresh_closure.clone();
137: 135:         let timeout_closure: Rc<Closure<dyn Fn()>> = Rc::new(Closure::new(move || {
138: 136:             timeout_refresh
139: 137:                 .borrow()
140: 138:                 .as_ref()
141: 139:                 .expect("Refresh closure should exist.")(false, 1e-7)
142: 140:         }));
143: 141: 
144: 142:         let observe_timeout_id = timeout_id.clone();
145: 143:         let observe_window = window.clone();
146: 144:         let observe_refresh = refresh_closure.clone();
147: 145:         let local_observe_closure = Closure::new({
148: 146:             let element = element.clone();
149: 147: 
150: 148:             move |entries: Vec<IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverEntry>| {
151: 149:                 let ratio = entries[0].intersection_ratio();
152: 150: 
153: 151:                 if ratio != threshold {
154: 152:                     if !*is_first_update.borrow() {
155: 153:                         observe_refresh
156: 154:                             .borrow()
157: 155:                             .as_ref()
158: 156:                             .expect("Refresh closure should exist.")(
159: 157:                             false, 1.0
160: 158:                         );
161: 159:                         return;
162: 160:                     }
163: 161: 
164: 162:                     if ratio == 0.0 {
165: 163:                         // If the reference is clipped, the ratio is 0. Throttle the refresh to prevent an infinite loop of updates.
166: 164:                         observe_timeout_id.replace(Some(
167: 165:                             observe_window
168: 166:                                 .set_timeout_with_callback_and_timeout_and_arguments_0(
169: 167:                                     (*timeout_closure).as_ref().unchecked_ref(),
170: 168:                                     1000,
171: 169:                                 )
172: 170:                                 .expect("Set timeout should be successful."),
173: 171:                         ));
174: 172:                     } else {
175: 173:                         observe_refresh
176: 174:                             .borrow()
177: 175:                             .as_ref()
178: 176:                             .expect("Refresh closure should exist.")(
179: 177:                             false, ratio
180: 178:                         );
181: 179:                     }
182: 180:                 }
183: 181: 
184: 182:                 if ratio == 1.0
185: 183:                     && !rects_are_equal(
186: 184:                         &element_rect_for_root_margin.clone().into(),
187: 185:                         &element.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect().into(),
188: 186:                     )
189: 187:                 {
190: 188:                     // It's possible that even though the ratio is reported as 1, the
191: 189:                     // element is not actually fully within the IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server's root
192: 190:                     // area anymore. This can hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen under performance constraints. This may
193: 191:                     // be a bug in the browser's IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server implementation. To
194: 192:                     // work around this, we compare the element's bounding rect now with
195: 193:                     // what it was at the time we created the IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server. If they
196: 194:                     // are not equal then the element moved, so we refresh.
197: 195:                     observe_refresh
198: 196:                         .borrow()
199: 197:                         .as_ref()
200: 198:                         .expect("Refresh closure should exist.")(false, 1.0);
201: 199:                 }
202: 200: 
203: 201:                 is_first_update.replace(false);
204: 202:             }
205: 203:         });
206: 204: 
207: 205:         let options = IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverInit::new();
208: 206:         options.set_root_margin(&root_margin);
209: 207:         options.set_threshold(&JsValue::from_f64(threshold.clamp(0.0, 1.0)));
210: 208: 
211: 209:         let local_io = IntersectionOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::new_with_options(
212: 210:             local_observe_closure.as_ref().unchecked_ref(),
213: 211:             &options,
214: 212:         )
215: 213:         .expect("Intersection oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server should be created.");
216: 214: 
217: 215:         observe_closure.replace(Some(local_observe_closure));
218: 216: 
219: 217:         local_io.observe(&element);
220: 218:         io.replace(Some(local_io));
221: 219:     }));
222: 220: 
223: 221:     refresh_closure_clone
224: 222:         .borrow()
225: 223:         .as_ref()
226: 224:         .expect("Refresh closure should exist.")(true, 1.0);
227: 225: 
228: 226:     Box::new(move || {
229: 227:         cleanup_rc();
230: 228:     })
231: 229: }
232: 230: 
233: 231: /// Options for [`auto_update`].
234: 232: #[derive(Clone, Debug, Default, PartialEq)]
235: 233: pub struct AutoUpdateOptions {
236: 234:     /// Whether to update the position when an overflow ancestor is scrolled.
237: 235:     ///
238: 236:     /// Defaults to `true`.
239: 237:     pub ancestor_scroll: Option<bool>,
240: 238: 
241: 239:     /// Whether to update the position when an overflow ancestor is resized. This uses the native `resize` event.
242: 240:     ///
243: 241:     /// Defaults to `true`.
244: 242:     pub ancestor_resize: Option<bool>,
245: 243: 
246: 244:     /// Whether to update the position when either the reference or floating elements resized. This uses a `ResizeOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server`.
247: 245:     ///
248: 246:     /// Defaults to `true`.
249: 247:     pub element_resize: Option<bool>,
250: 248: 
251: 249:     /// Whether to update the position when the reference relocated on the screen due to layout shift.
252: 250:     ///
253: 251:     /// Defaults to `true`.
254: 252:     pub layout_shift: Option<bool>,
255: 253: 
256: 254:     /// Whether to update on every animation frame if necessary.
257: 255:     /// Only use if you need to update the position in response to an animation using transforms.
258: 256:     ///
259: 257:     /// Defaults to `false`.
260: 258:     pub animation_frame: Option<bool>,
261: 259: }
262: 260: 
263: 261: impl AutoUpdateOptions {
264: 262:     /// Set `ancestor_scroll` option.
265: 263:     pub fn ancestor_scroll(mut self, value: bool) -> Self {
266: 264:         self.ancestor_scroll = Some(value);
267: 265:         self
268: 266:     }
269: 267: 
270: 268:     /// Set `ancestor_resize` option.
271: 269:     pub fn ancestor_resize(mut self, value: bool) -> Self {
272: 270:         self.ancestor_resize = Some(value);
273: 271:         self
274: 272:     }
275: 273: 
276: 274:     /// Set `element_resize` option.
277: 275:     pub fn element_resize(mut self, value: bool) -> Self {
278: 276:         self.element_resize = Some(value);
279: 277:         self
280: 278:     }
281: 279: 
282: 280:     /// Set `layout_shift` option.
283: 281:     pub fn layout_shift(mut self, value: bool) -> Self {
284: 282:         self.layout_shift = Some(value);
285: 283:         self
286: 284:     }
287: 285: 
288: 286:     /// Set `animation_frame` option.
289: 287:     pub fn animation_frame(mut self, value: bool) -> Self {
290: 288:         self.animation_frame = Some(value);
291: 289:         self
292: 290:     }
293: 291: }
294: 292: 
295: 293: /// Automatically updates the position of the floating element when necessary.
296: 294: /// Should only be called when the floating element is mounted on the DOM or visible on the screen.
297: 295: pub fn auto_update(
298: 296:     reference: ElementOrVirtual,
299: 297:     floating: &Element,
300: 298:     update: Rc<dyn Fn()>,
301: 299:     options: AutoUpdateOptions,
302: 300: ) -> Box<dyn Fn()> {
303: 301:     let ancestor_scoll = options.ancestor_scroll.unwrap_or(true);
304: 302:     let ancestor_resize = options.ancestor_resize.unwrap_or(true);
305: 303:     let element_resize = options.element_resize.unwrap_or(true);
306: 304:     let layout_shift = options.layout_shift.unwrap_or(true);
307: 305:     let animation_frame = options.animation_frame.unwrap_or(false);
308: 306: 
309: 307:     let reference_element = reference.clone().resolve();
310: 308: 
311: 309:     let owned_reference = match reference.clone() {
312: 310:         ElementOrVirtual::Element(e) => OwnedElementOrVirtual::Element(e.clone()),
313: 311:         ElementOrVirtual::VirtualElement(ve) => OwnedElementOrVirtual::VirtualElement(ve.clone()),
314: 312:     };
315: 313: 
316: 314:     let ancestors = if ancestor_scoll || ancestor_resize {
317: 315:         let mut ancestors = vec![];
318: 316: 
319: 317:         if let Some(reference) = reference_element.as_ref() {
320: 318:             ancestors = get_overflow_ancestors(reference, ancestors, true);
321: 319:         }
322: 320: 
323: 321:         ancestors.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append(&mut get_overflow_ancestors(floating, vec![], true));
324: 322: 
325: 323:         ancestors
326: 324:     } else {
327: 325:         vec![]
328: 326:     };
329: 327: 
330: 328:     let update_closure: Closure<dyn Fn()> = Closure::new({
331: 329:         let update = update.clone();
332: 330: 
333: 331:         move || {
334: 332:             update();
335: 333:         }
336: 334:     });
337: 335: 
338: 336:     for ancestor in &ancestors {
339: 337:         let event_target: &EventTarget = match ancestor {
340: 338:             OverflowAncestor::Element(element) => element,
341: 339:             OverflowAncestor::Window(window) => window,
342: 340:         };
343: 341: 
344: 342:         if ancestor_scoll {
345: 343:             let options = AddEventListenerOptions::new();
346: 344:             options.set_passive(true);
347: 345: 
348: 346:             event_target
349: 347:                 .add_event_listener_with_callback_and_add_event_listener_options(
350: 348:                     "scroll",
351: 349:                     update_closure.as_ref().unchecked_ref(),
352: 350:                     &options,
353: 351:                 )
354: 352:                 .expect("Scroll event listener should be added.");
355: 353:         }
356: 354: 
357: 355:         if ancestor_resize {
358: 356:             event_target
359: 357:                 .add_event_listener_with_callback("resize", update_closure.as_ref().unchecked_ref())
360: 358:                 .expect("Resize event listener should be added.");
361: 359:         }
362: 360:     }
363: 361: 
364: 362:     let cleanup_observe_move = reference_element.as_ref().and_then(|reference_element| {
365: 363:         layout_shift.then(|| observe_move(reference_element.clone(), update.clone()))
366: 364:     });
367: 365: 
368: 366:     let reobserve_frame: Rc<RefCell<Option<i32>>> = Rc::new(RefCell::new(None));
369: 367:     let resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Rc<RefCell<Option<ResizeOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server>>> = Rc::new(RefCell::new(None));
370: 368: 
371: 369:     if element_resize {
372: 370:         let reobserve_floating = floating.clone();
373: 371:         let reobserve_closure: Rc<Closure<dyn FnMut()>> = Rc::new(Closure::new({
374: 372:             let resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server = resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.clone();
375: 373: 
376: 374:             move || {
377: 375:                 resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server
378: 376:                     .borrow()
379: 377:                     .as_ref()
380: 378:                     .expect("Resize oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server should exist.")
381: 379:                     .observe(&reobserve_floating);
382: 380:             }
383: 381:         }));
384: 382: 
385: 383:         let resize_reference_element = reference_element.clone();
386: 384:         let resize_closure: Closure<dyn Fn(Vec<ResizeOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverEntry>)> = Closure::new({
387: 385:             let reobserve_frame = reobserve_frame.clone();
388: 386:             let update = update.clone();
389: 387: 
390: 388:             move |entries: Vec<ResizeOblyx-platform-lyx_platform_lyx-platform-lyx_platform_serverEntry>| {
391: 389:                 if let Some(first_entry) = entries.first()
392: 390:                     && resize_reference_element
393: 391:                         .as_ref()
394: 392:                         .is_some_and(|reference_element| first_entry.target() == *reference_element)
395: 393:                 {
396: 394:                     if let Some(reobserve_frame) = reobserve_frame.take() {
397: 395:                         cancel_animation_frame(reobserve_frame);
398: 396:                     }
399: 397: 
400: 398:                     reobserve_frame
401: 399:                         .replace(Some(request_animation_frame(reobserve_closure.as_ref())));
402: 400:                 }
403: 401: 
404: 402:                 update();
405: 403:             }
406: 404:         });
407: 405: 
408: 406:         resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.replace(Some(
409: 407:             ResizeOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::new(resize_closure.into_js_value().unchecked_ref())
410: 408:                 .expect("Resize oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server should be created."),
411: 409:         ));
412: 410: 
413: 411:         if let Some(reference) = reference_element.as_ref()
414: 412:             && !animation_frame
415: 413:         {
416: 414:             resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server
417: 415:                 .borrow()
418: 416:                 .as_ref()
419: 417:                 .expect("Resize oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server should exist.")
420: 418:                 .observe(reference);
421: 419:         }
422: 420: 
423: 421:         resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server
424: 422:             .borrow()
425: 423:             .as_ref()
426: 424:             .expect("Resize oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server should exist.")
427: 425:             .observe(floating);
428: 426:     }
429: 427: 
430: 428:     let frame_id: Rc<RefCell<Option<i32>>> = Rc::new(RefCell::new(None));
431: 429:     let prev_ref_rect: Rc<RefCell<Option<ClientRectObject>>> =
432: 430:         Rc::new(RefCell::new(animation_frame.then(|| {
433: 431:             get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(reference, false, false, None)
434: 432:         })));
435: 433: 
436: 434:     let frame_loop_frame_id = frame_id.clone();
437: 435:     let frame_loop_closure = Rc::new(RefCell::new(None));
438: 436:     let frame_loop_closure_clone = frame_loop_closure.clone();
439: 437: 
440: 438:     *frame_loop_closure_clone.borrow_mut() = Some(Closure::new({
441: 439:         let owned_reference = owned_reference.clone();
442: 440:         let update = update.clone();
443: 441:         let prev_ref_rect = prev_ref_rect.clone();
444: 442:         let frame_loop_frame_id = frame_loop_frame_id.clone();
445: 443: 
446: 444:         move || {
447: 445:             let next_ref_rect =
448: 446:                 get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect((&owned_reference).into(), false, false, None);
449: 447: 
450: 448:             if let Some(prev_ref_rect) = prev_ref_rect.borrow().as_ref()
451: 449:                 && !rects_are_equal(prev_ref_rect, &next_ref_rect)
452: 450:             {
453: 451:                 update();
454: 452:             }
455: 453: 
456: 454:             prev_ref_rect.replace(Some(next_ref_rect));
457: 455:             frame_loop_frame_id.replace(Some(request_animation_frame(
458: 456:                 frame_loop_closure
459: 457:                     .borrow()
460: 458:                     .as_ref()
461: 459:                     .expect("Frame loop closure should exist."),
462: 460:             )));
463: 461:         }
464: 462:     }));
465: 463: 
466: 464:     if animation_frame {
467: 465:         // Frame loop closure can't be called here, so the code below is copied.
468: 466: 
469: 467:         let next_ref_rect = get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect((&owned_reference).into(), false, false, None);
470: 468: 
471: 469:         if let Some(prev_ref_rect) = prev_ref_rect.borrow().as_ref()
472: 470:             && (next_ref_rect.x != prev_ref_rect.x
473: 471:                 || next_ref_rect.y != prev_ref_rect.y
474: 472:                 || next_ref_rect.width != prev_ref_rect.width
475: 473:                 || next_ref_rect.height != prev_ref_rect.height)
476: 474:         {
477: 475:             update();
478: 476:         }
479: 477: 
480: 478:         prev_ref_rect.replace(Some(next_ref_rect));
481: 479:         frame_loop_frame_id.replace(Some(request_animation_frame(
482: 480:             frame_loop_closure_clone
483: 481:                 .borrow()
484: 482:                 .as_ref()
485: 483:                 .expect("Frame loop closure should exist."),
486: 484:         )));
487: 485:     }
488: 486: 
489: 487:     update();
490: 488: 
491: 489:     Box::new(move || {
492: 490:         for ancestor in &ancestors {
493: 491:             let event_target: &EventTarget = match ancestor {
494: 492:                 OverflowAncestor::Element(element) => element,
495: 493:                 OverflowAncestor::Window(window) => window,
496: 494:             };
497: 495: 
498: 496:             if ancestor_scoll {
499: 497:                 event_target
500: 498:                     .remove_event_listener_with_callback(
501: 499:                         "scroll",
502: 500:                         update_closure.as_ref().unchecked_ref(),
503: 501:                     )
504: 502:                     .expect("Scroll event listener should be removed.");
505: 503:             }
506: 504: 
507: 505:             if ancestor_resize {
508: 506:                 event_target
509: 507:                     .remove_event_listener_with_callback(
510: 508:                         "resize",
511: 509:                         update_closure.as_ref().unchecked_ref(),
512: 510:                     )
513: 511:                     .expect("Resize event listener should be removed.");
514: 512:             }
515: 513:         }
516: 514: 
517: 515:         if let Some(cleanup_observe_move) = &cleanup_observe_move {
518: 516:             cleanup_observe_move();
519: 517:         }
520: 518: 
521: 519:         if let Some(reobserve_frame) = reobserve_frame.take() {
522: 520:             cancel_animation_frame(reobserve_frame);
523: 521:         }
524: 522: 
525: 523:         if let Some(resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server) = resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.take() {
526: 524:             resize_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.disconnect();
527: 525:         }
528: 526: 
529: 527:         if let Some(frame_id) = frame_id.take() {
530: 528:             cancel_animation_frame(frame_id);
531: 529:         }
532: 530:     })
533: 531: }
534: 532: ```
535: 533: ```
536: 534: ```
537: 535: ```
538: 536: ```
539: 537: ```
540: 538: ```
541: 539: ```
542: 540: ```
543: 541: ```
544: 542: ```
545: 543: ```
546: 544: ```
547: 545: ```
548: 546: ```
549: 547: ```
550: 548: ```
551: 549: ```
552: 550: ```
553: 551: ```
554: ```
```

