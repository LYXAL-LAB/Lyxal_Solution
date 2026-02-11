### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\renderer\dom.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\dom.rs
18: 16: ```rust
19: 17: #![allow(missing_docs)]
20: 18: 
21: 19: //! See [`Renderer`](crate::renderer::Renderer) and [`Rndr`](crate::renderer::Rndr) for additional information.
22: 20: 
23: 21: use super::{CastFrom, RemoveEventHandler};
24: 22: use crate::{
25: 23:     dom::{document, window},
26: 24:     ok_or_debug, or_debug,
27: 25:     view::{Mountable, ToTemplate},
28: 26: };
29: 27: use rustc_hash::FxHashSet;
30: 28: use std::{
31: 29:     any::TypeId,
32: 30:     borrow::Cow,
33: 31:     cell::{LazyCell, RefCell},
34: 32: };
35: 33: use wasm_bindgen::{intern, prelude::Closure, JsCast, JsValue};
36: 34: use web_sys::{AddEventListenerOptions, Comment, HtmlTemplateElement};
37: 35: 
38: 36: /// A [`Renderer`](crate::renderer::Renderer) that uses `web-sys` to manipulate DOM elements in the browser.
39: 37: #[derive(Debug, Copy, Clone, PartialEq, Eq, Hash, PartialOrd, Ord)]
40: 38: pub struct Dom;
41: 39: 
42: 40: thread_local! {
43: 41:     pub(crate) static GLOBAL_EVENTS: RefCell<FxHashSet<Cow<'static, str>>> = Default::default();
44: 42:     pub static TEMPLATE_CACHE: RefCell<Vec<(Cow<'static, str>, web_sys::Element)>> = Default::default();
45: 43: }
46: 44: 
47: 45: pub type Node = web_sys::Node;
48: 46: pub type Text = web_sys::Text;
49: 47: pub type Element = web_sys::Element;
50: 48: pub type Placeholder = web_sys::Comment;
51: 49: pub type Event = wasm_bindgen::JsValue;
52: 50: pub type ClassList = web_sys::DomTokenList;
53: 51: pub type CssStyleDeclaration = web_sys::CssStyleDeclaration;
54: 52: pub type TemplateElement = web_sys::HtmlTemplateElement;
55: 53: 
56: 54: /// A microtask is a short function which will run after the current task has
57: 55: /// completed its work and when there is no other code waiting to be run before
58: 56: /// control of the execution context is returned to the browser's event loop.
59: 57: ///
60: 58: /// Microtasks are especially useful for libraries and frameworks that need
61: 59: /// to perform final cleanup or other just-before-rendering tasks.
62: 60: ///
63: 61: /// [MDN queueMicrotask](https://developer.mozilla.org/en-US/docs/Web/API/queueMicrotask)
64: 62: pub fn queue_microtask(task: impl FnOnce() + 'static) {
65: 63:     use js_sys::{Function, Reflect};
66: 64: 
67: 65:     let task = Closure::once_into_js(task);
68: 66:     let window = window();
69: 67:     let queue_microtask =
70: 68:         Reflect::get(&window, &JsValue::from_str("queueMicrotask"))
71: 69:             .expect("queueMicrotask not available");
72: 70:     let queue_microtask = queue_microtask.unchecked_into::<Function>();
73: 71:     _ = queue_microtask.call1(&JsValue::UNDEFINED, &task);
74: 72: }
75: 73: 
76: 74: fn queue(fun: Box<dyn FnOnce()>) {
77: 75:     use std::cell::{Cell, RefCell};
78: 76: 
79: 77:     thread_local! {
80: 78:         static PENDING: Cell<bool> = const { Cell::new(false) };
81: 79:         static QUEUE: RefCell<Vec<Box<dyn FnOnce()>>> = RefCell::new(Vec::new());
82: 80:     }
83: 81: 
84: 82:     QUEUE.with_borrow_mut(|q| q.push(fun));
85: 83:     if !PENDING.replace(true) {
86: 84:         queue_microtask(|| {
87: 85:             let tasks = QUEUE.take();
88: 86:             for task in tasks {
89: 87:                 task();
90: 88:             }
91: 89:             PENDING.set(false);
92: 90:         })
93: 91:     }
94: 92: }
95: 93: 
96: 94: impl Dom {
97: 95:     pub fn intern(text: &str) -> &str {
98: 96:         intern(text)
99: 97:     }
100: 98: 
101: 99:     pub fn create_element(tag: &str, namespace: Option<&str>) -> Element {
102: 100:         if let Some(namespace) = namespace {
103: 101:             document()
104: 102:                 .create_element_ns(
105: 103:                     Some(Self::intern(namespace)),
106: 104:                     Self::intern(tag),
107: 105:                 )
108: 106:                 .unwrap()
109: 107:         } else {
110: 108:             document().create_element(Self::intern(tag)).unwrap()
111: 109:         }
112: 110:     }
113: 111: 
114: 112:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
115: 113:     pub fn create_text_node(text: &str) -> Text {
116: 114:         document().create_text_node(text)
117: 115:     }
118: 116: 
119: 117:     pub fn create_placeholder() -> Placeholder {
120: 118:         thread_local! {
121: 119:             static COMMENT: LazyCell<Comment> = LazyCell::new(|| {
122: 120:                 document().create_comment("")
123: 121:             });
124: 122:         }
125: 123:         COMMENT.with(|n| n.clone_node().unwrap().unchecked_into())
126: 124:     }
127: 125: 
128: 126:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
129: 127:     pub fn set_text(node: &Text, text: &str) {
130: 128:         node.set_node_value(Some(text));
131: 129:     }
132: 130: 
133: 131:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
134: 132:     pub fn set_attribute(node: &Element, name: &str, value: &str) {
135: 133:         or_debug!(node.set_attribute(name, value), node, "setAttribute");
136: 134:     }
137: 135: 
138: 136:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
139: 137:     pub fn remove_attribute(node: &Element, name: &str) {
140: 138:         or_debug!(node.remove_attribute(name), node, "removeAttribute");
141: 139:     }
142: 140: 
143: 141:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
144: 142:     pub fn insert_node(
145: 143:         parent: &Element,
146: 144:         new_child: &Node,
147: 145:         anchor: Option<&Node>,
148: 146:     ) {
149: 147:         ok_or_debug!(
150: 148:             parent.insert_before(new_child, anchor),
151: 149:             parent,
152: 150:             "insertNode"
153: 151:         );
154: 152:     }
155: 153: 
156: 154:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
157: 155:     pub fn try_insert_node(
158: 156:         parent: &Element,
159: 157:         new_child: &Node,
160: 158:         anchor: Option<&Node>,
161: 159:     ) -> bool {
162: 160:         parent.insert_before(new_child, anchor).is_ok()
163: 161:     }
164: 162: 
165: 163:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
166: 164:     pub fn remove_node(parent: &Element, child: &Node) -> Option<Node> {
167: 165:         ok_or_debug!(parent.remove_child(child), parent, "removeNode")
168: 166:     }
169: 167: 
170: 168:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
171: 169:     pub fn remove(node: &Node) {
172: 170:         node.unchecked_ref::<Element>().remove();
173: 171:     }
174: 172: 
175: 173:     pub fn get_parent(node: &Node) -> Option<Node> {
176: 174:         node.parent_node()
177: 175:     }
178: 176: 
179: 177:     pub fn first_child(node: &Node) -> Option<Node> {
180: 178:         #[cfg(debug_assertions)]
181: 179:         {
182: 180:             let node = node.first_child();
183: 181:             // if it's a comment node that starts with hot-reload, it's a marker that should be
184: 182:             // ignored
185: 183:             if let Some(node) = node.as_ref() {
186: 184:                 if node.node_type() == 8
187: 185:                     && node
188: 186:                         .text_content()
189: 187:                         .unwrap_or_default()
190: 188:                         .starts_with("hot-reload")
191: 189:                 {
192: 190:                     return Self::next_sibling(node);
193: 191:                 }
194: 192:             }
195: 193: 
196: 194:             node
197: 195:         }
198: 196:         #[cfg(not(debug_assertions))]
199: 197:         {
200: 198:             node.first_child()
201: 199:         }
202: 200:     }
203: 201: 
204: 202:     pub fn next_sibling(node: &Node) -> Option<Node> {
205: 203:         #[cfg(debug_assertions)]
206: 204:         {
207: 205:             let node = node.next_sibling();
208: 206:             // if it's a comment node that starts with hot-reload, it's a marker that should be
209: 207:             // ignored
210: 208:             if let Some(node) = node.as_ref() {
211: 209:                 if node.node_type() == 8
212: 210:                     && node
213: 211:                         .text_content()
214: 212:                         .unwrap_or_default()
215: 213:                         .starts_with("hot-reload")
216: 214:                 {
217: 215:                     return Self::next_sibling(node);
218: 216:                 }
219: 217:             }
220: 218: 
221: 219:             node
222: 220:         }
223: 221:         #[cfg(not(debug_assertions))]
224: 222:         {
225: 223:             node.next_sibling()
226: 224:         }
227: 225:     }
228: 226: 
229: 227:     pub fn log_node(node: &Node) {
230: 228:         web_sys::console::log_1(node);
231: 229:     }
232: 230: 
233: 231:     #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace"))]
234: 232:     pub fn clear_children(parent: &Element) {
235: 233:         parent.set_text_content(Some(""));
236: 234:     }
237: 235: 
238: 236:     /// Mounts the new child before the marker as its sibling.
239: 237:     ///
240: 238:     /// ## Panics
241: 239:     /// The default implementation panics if `before` does not have a parent [`crate::renderer::types::Element`].
242: 240:     pub fn mount_before<M>(new_child: &mut M, before: &Node)
243: 241:     where
244: 242:         M: Mountable,
245: 243:     {
246: 244:         let parent = Element::cast_from(
247: 245:             Self::get_parent(before).expect("could not find parent element"),
248: 246:         )
249: 247:         .expect("placeholder parent should be Element");
250: 248:         new_child.mount(&parent, Some(before));
251: 249:     }
252: 250: 
253: 251:     /// Tries to mount the new child before the marker as its sibling.
254: 252:     ///
255: 253:     /// Returns `false` if the child did not have a valid parent.
256: 254:     #[track_caller]
257: 255:     pub fn try_mount_before<M>(new_child: &mut M, before: &Node) -> bool
258: 256:     where
259: 257:         M: Mountable,
260: 258:     {
261: 259:         if let Some(parent) =
262: 260:             Self::get_parent(before).and_then(Element::cast_from)
263: 261:         {
264: 262:             new_child.mount(&parent, Some(before));
265: 263:             true
266: 264:         } else {
267: 265:             false
268: 266:         }
269: 267:     }
270: 268: 
271: 269:     pub fn set_property_or_value(el: &Element, key: &str, value: &JsValue) {
272: 270:         if key == "value" {
273: 271:             queue(Box::new({
274: 272:                 let el = el.clone();
275: 273:                 let value = value.clone();
276: 274:                 move || {
277: 275:                     Self::set_property(&el, "value", &value);
278: 276:                 }
279: 277:             }))
280: 278:         } else {
281: 279:             Self::set_property(el, key, value);
282: 280:         }
283: 281:     }
284: 282: 
285: 283:     pub fn set_property(el: &Element, key: &str, value: &JsValue) {
286: 284:         or_debug!(
287: 285:             js_sys::Reflect::set(
288: 286:                 el,
289: 287:                 &wasm_bindgen::JsValue::from_str(key),
290: 288:                 value,
291: 289:             ),
292: 290:             el,
293: 291:             "setProperty"
294: 292:         );
295: 293:     }
296: 294: 
297: 295:     pub fn add_event_listener(
298: 296:         el: &Element,
299: 297:         name: &str,
300: 298:         cb: Box<dyn FnMut(Event)>,
301: 299:     ) -> RemoveEventHandler<Element> {
302: 300:         let cb = wasm_bindgen::closure::Closure::wrap(cb);
303: 301:         let name = intern(name);
304: 302:         or_debug!(
305: 303:             el.add_event_listener_with_callback(
306: 304:                 name,
307: 305:                 cb.as_ref().unchecked_ref()
308: 306:             ),
309: 307:             el,
310: 308:             "addEventListener"
311: 309:         );
312: 310: 
313: 311:         // return the remover
314: 312:         RemoveEventHandler::new({
315: 313:             let name = name.to_owned();
316: 314:             let el = el.clone();
317: 315:             // safe to construct this here, because it will only run in the browser
318: 316:             // so it will always be accessed or dropped from the main thread
319: 317:             let cb = send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(move || {
320: 318:                 or_debug!(
321: 319:                     el.remove_event_listener_with_callback(
322: 320:                         intern(&name),
323: 321:                         cb.as_ref().unchecked_ref()
324: 322:                     ),
325: 323:                     &el,
326: 324:                     "removeEventListener"
327: 325:                 )
328: 326:             });
329: 327:             move || cb()
330: 328:         })
331: 329:     }
332: 330: 
333: 331:     pub fn add_event_listener_use_capture(
334: 332:         el: &Element,
335: 333:         name: &str,
336: 334:         cb: Box<dyn FnMut(Event)>,
337: 335:     ) -> RemoveEventHandler<Element> {
338: 336:         let cb = wasm_bindgen::closure::Closure::wrap(cb);
339: 337:         let name = intern(name);
340: 338:         let options = AddEventListenerOptions::new();
341: 339:         options.set_capture(true);
342: 340:         or_debug!(
343: 341:             el.add_event_listener_with_callback_and_add_event_listener_options(
344: 342:                 name,
345: 343:                 cb.as_ref().unchecked_ref(),
346: 344:                 &options
347: 345:             ),
348: 346:             el,
349: 347:             "addEventListenerUseCapture"
350: 348:         );
351: 349: 
352: 350:         // return the remover
353: 351:         RemoveEventHandler::new({
354: 352:             let name = name.to_owned();
355: 353:             let el = el.clone();
356: 354:             // safe to construct this here, because it will only run in the browser
357: 355:             // so it will always be accessed or dropped from the main thread
358: 356:             let cb = send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(move || {
359: 357:                 or_debug!(
360: 358:                     el.remove_event_listener_with_callback_and_bool(
361: 359:                         intern(&name),
362: 360:                         cb.as_ref().unchecked_ref(),
363: 361:                         true
364: 362:                     ),
365: 363:                     &el,
366: 364:                     "removeEventListener"
367: 365:                 )
368: 366:             });
369: 367:             move || cb()
370: 368:         })
371: 369:     }
372: 370: 
373: 371:     pub fn event_target<T>(ev: &Event) -> T
374: 372:     where
375: 373:         T: CastFrom<Element>,
376: 374:     {
377: 375:         let el = ev
378: 376:             .unchecked_ref::<web_sys::Event>()
379: 377:             .target()
380: 378:             .expect("event.target not found")
381: 379:             .unchecked_into::<Element>();
382: 380:         T::cast_from(el).expect("incorrect element type")
383: 381:     }
384: 382: 
385: 383:     pub fn add_event_listener_delegated(
386: 384:         el: &Element,
387: 385:         name: Cow<'static, str>,
388: 386:         delegation_key: Cow<'static, str>,
389: 387:         cb: Box<dyn FnMut(Event)>,
390: 388:     ) -> RemoveEventHandler<Element> {
391: 389:         let cb = Closure::wrap(cb);
392: 390:         let key = intern(&delegation_key);
393: 391:         or_debug!(
394: 392:             js_sys::Reflect::set(el, &JsValue::from_str(key), cb.as_ref()),
395: 393:             el,
396: 394:             "set property"
397: 395:         );
398: 396: 
399: 397:         GLOBAL_EVENTS.with_borrow_mut(|events| {
400: 398:             if !events.contains(&name) {
401: 399:                 // create global handler
402: 400:                 let key = JsValue::from_str(key);
403: 401:                 let handler = move |ev: web_sys::Event| {
404: 402:                     let target = ev.target();
405: 403:                     let node = ev.composed_path().get(0);
406: 404:                     let mut node = if node.is_undefined() || node.is_null() {
407: 405:                         JsValue::from(target)
408: 406:                     } else {
409: 407:                         node
410: 408:                     };
411: 409: 
412: 410:                     // TODO reverse Shadow DOM retargetting
413: 411:                     // TODO simulate currentTarget
414: 412: 
415: 413:                     while !node.is_null() {
416: 414:                         let node_is_disabled = js_sys::Reflect::get(
417: 415:                             &node,
418: 416:                             &JsValue::from_str("disabled"),
419: 417:                         )
420: 418:                         .unwrap()
421: 419:                         .is_truthy();
422: 420:                         if !node_is_disabled {
423: 421:                             let maybe_handler =
424: 422:                                 js_sys::Reflect::get(&node, &key).unwrap();
425: 423:                             if !maybe_handler.is_undefined() {
426: 424:                                 let f = maybe_handler
427: 425:                                     .unchecked_ref::<js_sys::Function>();
428: 426:                                 let _ = f.call1(&node, &ev);
429: 427: 
430: 428:                                 if ev.cancel_bubble() {
431: 429:                                     return;
432: 430:                                 }
433: 431:                             }
434: 432:                         }
435: 433: 
436: 434:                         // navigate up tree
437: 435:                         if let Some(parent) =
438: 436:                             node.unchecked_ref::<web_sys::Node>().parent_node()
439: 437:                         {
440: 438:                             node = parent.into()
441: 439:                         } else if let Some(root) =
442: 440:                             node.dyn_ref::<web_sys::ShadowRoot>()
443: 441:                         {
444: 442:                             node = root.host().unchecked_into();
445: 443:                         } else {
446: 444:                             node = JsValue::null()
447: 445:                         }
448: 446:                     }
449: 447:                 };
450: 448: 
451: 449:                 let handler =
452: 450:                     Box::new(handler) as Box<dyn FnMut(web_sys::Event)>;
453: 451:                 let handler = Closure::wrap(handler).into_js_value();
454: 452:                 window()
455: 453:                     .add_event_listener_with_callback(
456: 454:                         &name,
457: 455:                         handler.unchecked_ref(),
458: 456:                     )
459: 457:                     .unwrap();
460: 458: 
461: 459:                 // register that we've created handler
462: 460:                 events.insert(name);
463: 461:             }
464: 462:         });
465: 463: 
466: 464:         // return the remover
467: 465:         RemoveEventHandler::new({
468: 466:             let key = key.to_owned();
469: 467:             let el = el.clone();
470: 468:             // safe to construct this here, because it will only run in the browser
471: 469:             // so it will always be accessed or dropped from the main thread
472: 470:             let el_cb = send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new((el, cb));
473: 471:             move || {
474: 472:                 let (el, cb) = el_cb.take();
475: 473:                 drop(cb);
476: 474:                 or_debug!(
477: 475:                     js_sys::Reflect::delete_property(
478: 476:                         &el,
479: 477:                         &JsValue::from_str(&key)
480: 478:                     ),
481: 479:                     &el,
482: 480:                     "delete property"
483: 481:                 );
484: 482:             }
485: 483:         })
486: 484:     }
487: 485: 
488: 486:     pub fn class_list(el: &Element) -> ClassList {
489: 487:         el.class_list()
490: 488:     }
491: 489: 
492: 490:     pub fn add_class(list: &ClassList, name: &str) {
493: 491:         or_debug!(list.add_1(name), list.unchecked_ref(), "add()");
494: 492:     }
495: 493: 
496: 494:     pub fn remove_class(list: &ClassList, name: &str) {
497: 495:         or_debug!(list.remove_1(name), list.unchecked_ref(), "remove()");
498: 496:     }
499: 497: 
500: 498:     pub fn style(el: &Element) -> CssStyleDeclaration {
501: 499:         el.unchecked_ref::<web_sys::HtmlElement>().style()
502: 500:     }
503: 501: 
504: 502:     pub fn set_css_property(
505: 503:         style: &CssStyleDeclaration,
506: 504:         name: &str,
507: 505:         value: &str,
508: 506:     ) {
509: 507:         or_debug!(
510: 508:             style.set_property(name, value),
511: 509:             style.unchecked_ref(),
512: 510:             "setProperty"
513: 511:         );
514: 512:     }
515: 513: 
516: 514:     pub fn remove_css_property(style: &CssStyleDeclaration, name: &str) {
517: 515:         or_debug!(
518: 516:             style.remove_property(name),
519: 517:             style.unchecked_ref(),
520: 518:             "removeProperty"
521: 519:         );
522: 520:     }
523: 521: 
524: 522:     pub fn set_inner_html(el: &Element, html: &str) {
525: 523:         el.set_inner_html(html);
526: 524:     }
527: 525: 
528: 526:     pub fn get_template<V>() -> TemplateElement
529: 527:     where
530: 528:         V: ToTemplate + 'static,
531: 529:     {
532: 530:         thread_local! {
533: 531:             static TEMPLATE_ELEMENT: LazyCell<HtmlTemplateElement> =
534: 532:                 LazyCell::new(|| document().create_element(Dom::intern("template")).unwrap().unchecked_into());
535: 533:             static TEMPLATES: RefCell<Vec<(TypeId, HtmlTemplateElement)>> = Default::default();
536: 534:         }
537: 535: 
538: 536:         TEMPLATES.with_borrow_mut(|t| {
539: 537:             let id = TypeId::of::<V>();
540: 538:             t.iter()
541: 539:                 .find_map(|entry| (entry.0 == id).then(|| entry.1.clone()))
542: 540:                 .unwrap_or_else(|| {
543: 541:                     let tpl = TEMPLATE_ELEMENT.with(|t| {
544: 542:                         t.clone_node()
545: 543:                             .unwrap()
546: 544:                             .unchecked_into::<HtmlTemplateElement>()
547: 545:                     });
548: 546:                     let mut buf = String::new();
549: 547:                     V::to_template(
550: 548:                         &mut buf,
551: 549:                         &mut String::new(),
552: 550:                         &mut String::new(),
553: 551:                         &mut String::new(),
554: 552:                         &mut Default::default(),
555: 553:                     );
556: 554:                     tpl.set_inner_html(&buf);
557: 555:                     t.push((id, tpl.clone()));
558: 556:                     tpl
559: 557:                 })
560: 558:         })
561: 559:     }
562: 560: 
563: 561:     pub fn clone_template(tpl: &TemplateElement) -> Element {
564: 562:         tpl.content()
565: 563:             .clone_node_with_deep(true)
566: 564:             .unwrap()
567: 565:             .unchecked_into()
568: 566:     }
569: 567: 
570: 568:     pub fn create_element_from_html(html: Cow<'static, str>) -> Element {
571: 569:         let tpl = TEMPLATE_CACHE.with_borrow_mut(|cache| {
572: 570:             if let Some(tpl_content) = cache.iter().find_map(|(key, tpl)| {
573: 571:                 (html == *key)
574: 572:                     .then_some(Self::clone_template(tpl.unchecked_ref()))
575: 573:             }) {
576: 574:                 tpl_content
577: 575:             } else {
578: 576:                 let tpl = document()
579: 577:                     .create_element(Self::intern("template"))
580: 578:                     .unwrap();
581: 579:                 tpl.set_inner_html(&html);
582: 580:                 let tpl_content = Self::clone_template(tpl.unchecked_ref());
583: 581:                 cache.push((html, tpl));
584: 582:                 tpl_content
585: 583:             }
586: 584:         });
587: 585:         tpl.first_element_child().unwrap_or(tpl)
588: 586:     }
589: 587: 
590: 588:     pub fn create_svg_element_from_html(html: Cow<'static, str>) -> Element {
591: 589:         let tpl = TEMPLATE_CACHE.with_borrow_mut(|cache| {
592: 590:             if let Some(tpl_content) = cache.iter().find_map(|(key, tpl)| {
593: 591:                 (html == *key)
594: 592:                     .then_some(Self::clone_template(tpl.unchecked_ref()))
595: 593:             }) {
596: 594:                 tpl_content
597: 595:             } else {
598: 596:                 let tpl = document()
599: 597:                     .create_element(Self::intern("template"))
600: 598:                     .unwrap();
601: 599:                 let svg = document()
602: 600:                     .create_element_ns(
603: 601:                         Some(Self::intern("http://www.w3.org/2000/svg")),
604: 602:                         Self::intern("svg"),
605: 603:                     )
606: 604:                     .unwrap();
607: 605:                 let g = document()
608: 606:                     .create_element_ns(
609: 607:                         Some(Self::intern("http://www.w3.org/2000/svg")),
610: 608:                         Self::intern("g"),
611: 609:                     )
612: 610:                     .unwrap();
613: 611:                 g.set_inner_html(&html);
614: 612:                 svg.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_child(&g).unwrap();
615: 613:                 tpl.unchecked_ref::<TemplateElement>()
616: 614:                     .content()
617: 615:                     .lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_child(&svg)
618: 616:                     .unwrap();
619: 617:                 let tpl_content = Self::clone_template(tpl.unchecked_ref());
620: 618:                 cache.push((html, tpl));
621: 619:                 tpl_content
622: 620:             }
623: 621:         });
624: 622: 
625: 623:         let svg = tpl.first_element_child().unwrap();
626: 624:         svg.first_element_child().unwrap_or(svg)
627: 625:     }
628: 626: }
629: 627: 
630: 628: impl Mountable for Node {
631: 629:     fn unmount(&mut self) {
632: 630:         todo!()
633: 631:     }
634: 632: 
635: 633:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
636: 634:         Dom::insert_node(parent, self, marker);
637: 635:     }
638: 636: 
639: 637:     fn try_mount(&mut self, parent: &Element, marker: Option<&Node>) -> bool {
640: 638:         Dom::try_insert_node(parent, self, marker)
641: 639:     }
642: 640: 
643: 641:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
644: 642:         let parent = Dom::get_parent(self).and_then(Element::cast_from);
645: 643:         if let Some(parent) = parent {
646: 644:             child.mount(&parent, Some(self));
647: 645:             return true;
648: 646:         }
649: 647:         false
650: 648:     }
651: 649: 
652: 650:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
653: 651:         vec![]
654: 652:     }
655: 653: }
656: 654: 
657: 655: impl Mountable for Text {
658: 656:     fn unmount(&mut self) {
659: 657:         self.remove();
660: 658:     }
661: 659: 
662: 660:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
663: 661:         Dom::insert_node(parent, self, marker);
664: 662:     }
665: 663: 
666: 664:     fn try_mount(&mut self, parent: &Element, marker: Option<&Node>) -> bool {
667: 665:         Dom::try_insert_node(parent, self, marker)
668: 666:     }
669: 667: 
670: 668:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
671: 669:         let parent =
672: 670:             Dom::get_parent(self.as_ref()).and_then(Element::cast_from);
673: 671:         if let Some(parent) = parent {
674: 672:             child.mount(&parent, Some(self));
675: 673:             return true;
676: 674:         }
677: 675:         false
678: 676:     }
679: 677: 
680: 678:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
681: 679:         vec![]
682: 680:     }
683: 681: }
684: 682: 
685: 683: impl Mountable for Comment {
686: 684:     fn unmount(&mut self) {
687: 685:         self.remove();
688: 686:     }
689: 687: 
690: 688:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
691: 689:         Dom::insert_node(parent, self, marker);
692: 690:     }
693: 691: 
694: 692:     fn try_mount(&mut self, parent: &Element, marker: Option<&Node>) -> bool {
695: 693:         Dom::try_insert_node(parent, self, marker)
696: 694:     }
697: 695: 
698: 696:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
699: 697:         let parent =
700: 698:             Dom::get_parent(self.as_ref()).and_then(Element::cast_from);
701: 699:         if let Some(parent) = parent {
702: 700:             child.mount(&parent, Some(self));
703: 701:             return true;
704: 702:         }
705: 703:         false
706: 704:     }
707: 705: 
708: 706:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
709: 707:         vec![]
710: 708:     }
711: 709: }
712: 710: 
713: 711: impl Mountable for Element {
714: 712:     fn unmount(&mut self) {
715: 713:         self.remove();
716: 714:     }
717: 715: 
718: 716:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
719: 717:         Dom::insert_node(parent, self, marker);
720: 718:     }
721: 719: 
722: 720:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
723: 721:         let parent =
724: 722:             Dom::get_parent(self.as_ref()).and_then(Element::cast_from);
725: 723:         if let Some(parent) = parent {
726: 724:             child.mount(&parent, Some(self));
727: 725:             return true;
728: 726:         }
729: 727:         false
730: 728:     }
731: 729: 
732: 730:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
733: 731:         vec![self.clone()]
734: 732:     }
735: 733: }
736: 734: 
737: 735: impl CastFrom<Node> for Text {
738: 736:     fn cast_from(node: Node) -> Option<Text> {
739: 737:         node.clone().dyn_into().ok()
740: 738:     }
741: 739: }
742: 740: 
743: 741: impl CastFrom<Node> for Comment {
744: 742:     fn cast_from(node: Node) -> Option<Comment> {
745: 743:         node.clone().dyn_into().ok()
746: 744:     }
747: 745: }
748: 746: 
749: 747: impl CastFrom<Node> for Element {
750: 748:     fn cast_from(node: Node) -> Option<Element> {
751: 749:         node.clone().dyn_into().ok()
752: 750:     }
753: 751: }
754: 752: 
755: 753: impl<T> CastFrom<JsValue> for T
756: 754: where
757: 755:     T: JsCast,
758: 756: {
759: 757:     fn cast_from(source: JsValue) -> Option<Self> {
760: 758:         source.dyn_into::<T>().ok()
761: 759:     }
762: 760: }
763: 761: 
764: 762: impl<T> CastFrom<Element> for T
765: 763: where
766: 764:     T: JsCast,
767: 765: {
768: 766:     fn cast_from(source: Element) -> Option<Self> {
769: 767:         source.dyn_into::<T>().ok()
770: 768:     }
771: 769: }
772: 770: ```
773: 771: ```
774: 772: ```
775: 773: ```
776: 774: ```
777: 775: ```
778: 776: ```
779: 777: ```
780: ```
```
