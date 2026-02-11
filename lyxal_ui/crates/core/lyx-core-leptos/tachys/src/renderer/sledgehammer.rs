### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\sledgehammer.rs
18: 16: ```rust
19: 17: #![allow(missing_docs)] // Allow missing docs for experimental lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend
20: 18: 
21: 19: use super::{CastFrom, DomRenderer, RemoveEventHandler, Renderer};
22: 20: use crate::{
23: 21:     dom::window,
24: 22:     view::{Mountable, ToTemplate},
25: 23: };
26: 24: use linear_map::LinearMap;
27: 25: use rustc_hash::FxHashSet;
28: 26: use sledgehammer_bindgen::bindgen;
29: 27: use std::{
30: 28:     any::TypeId,
31: 29:     borrow::Cow,
32: 30:     cell::{Cell, RefCell},
33: 31:     rc::Rc,
34: 32: };
35: 33: use wasm_bindgen::{
36: 34:     prelude::{wasm_bindgen, Closure},
37: 35:     JsCast, JsValue,
38: 36: };
39: 37: use web_sys::Node;
40: 38: 
41: 39: #[wasm_bindgen]
42: 40: extern "C" {
43: 41:     #[wasm_bindgen]
44: 42:     fn queueMicrotask(closure: &Closure<dyn Fn() -> ()>);
45: 43: 
46: 44:     type Global;
47: 45: }
48: 46: 
49: 47: #[bindgen]
50: 48: mod js {
51: 49:     //#[extends(NodeInterpreter)]
52: 50:     struct Channel;
53: 51: 
54: 52:     const JS: &str = r#"
55: 53:         function Queue() {
56: 54:             var head, tail;
57: 55:             return Object.freeze({     
58: 56:                 enqueue(value) { 
59: 57:                     const link = {value, next: undefined};
60: 58:                     tail = head ? tail.next = link : head = link;
61: 59:                 },
62: 60:                 dequeue() {
63: 61:                     if (head) {
64: 62:                         const value = head.value;
65: 63:                         head = head.next;
66: 64:                         return value;
67: 65:                     }
68: 66:                 },
69: 67:                 peek() { return head?.value }
70: 68:             });
71: 69:         }
72: 70:         this.nodes = [null];
73: 71:         this.jsvalues = Queue();
74: 72:     "#;
75: 73: 
76: 74:     fn drop_node(id: u32) {
77: 75:         "this.nodes[$id$]=null;"
78: 76:     }
79: 77: 
80: 78:     fn store_body(id: u32) {
81: 79:         "this.nodes[$id$]=document.body;"
82: 80:     }
83: 81: 
84: 82:     fn create_text_node(id: u32, data: &str) {
85: 83:         "this.nodes[$id$]=document.createTextNode($data$);"
86: 84:     }
87: 85: 
88: 86:     fn create_comment(id: u32) {
89: 87:         "this.nodes[$id$]=document.createComment();"
90: 88:     }
91: 89: 
92: 90:     fn create_element(id: u32, name: &'static str<u8, name_cache>) {
93: 91:         "this.nodes[$id$]=document.createElement($name$);"
94: 92:     }
95: 93: 
96: 94:     fn set_attribute(
97: 95:         id: u32,
98: 96:         name: &str<u8, name_cache>,
99: 97:         val: impl Writable<u8>,
100: 98:     ) {
101: 99:         "this.nodes[$id$].setAttribute($name$,$val$);"
102: 100:     }
103: 101: 
104: 102:     fn remove_child(parent: u32, child: u32) {
105: 103:         "this.nodes[$parent$].removeChild(this.nodes[$child$]);"
106: 104:     }
107: 105: 
108: 106:     fn remove_attribute(id: u32, name: &str<u8, name_cache>) {
109: 107:         "this.nodes[$id$].removeAttribute($name$);"
110: 108:     }
111: 109: 
112: 110:     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_child(id: u32, id2: u32) {
113: 111:         "this.nodes[$id$].lyx-platform-lyx_platform_lyx-platform-lyx_platform_appendChild(nodes[$id2$]);"
114: 112:     }
115: 113: 
116: 114:     fn insert_before(parent: u32, child: u32, marker: u32) {
117: 115:         "this.nodes[$parent$].insertBefore(this.nodes[$child$],this.\
118: 116:          nodes[$marker$]);"
119: 117:     }
120: 118: 
121: 119:     fn set_text(id: u32, text: impl Writable<u8>) {
122: 120:         "this.nodes[$id$].textContent=$text$;"
123: 121:     }
124: 122: 
125: 123:     fn remove(id: u32) {
126: 124:         "this.nodes[$id$].remove();"
127: 125:     }
128: 126: 
129: 127:     fn replace(id: u32, id2: u32) {
130: 128:         "this.nodes[$id$].replaceWith(this.nodes[$id2$]);"
131: 129:     }
132: 130: 
133: 131:     fn first_child(parent: u32, child: u32) {
134: 132:         "this.nodes[$child$]=this.nodes[$parent$].firstChild;"
135: 133:     }
136: 134: 
137: 135:     fn next_sibling(anchor: u32, sibling: u32) {
138: 136:         "this.nodes[$sibling$]=this.nodes[$anchor$].nextSibling;"
139: 137:     }
140: 138: 
141: 139:     fn class_list(el: u32, class_list: u32) {
142: 140:         "this.nodes[$class_list$]=this.nodes[$el$].classList;"
143: 141:     }
144: 142: 
145: 143:     fn add_class(class_list: u32, name: &str<u8, class_cache>) {
146: 144:         "this.nodes[$class_list$].add($name$);"
147: 145:     }
148: 146: 
149: 147:     fn remove_class(class_list: u32, name: &str<u8, class_cache>) {
150: 148:         "this.nodes[$class_list$].remove($name$);"
151: 149:     }
152: 150: 
153: 151:     fn set_inner_html(node: u32, html: &str) {
154: 152:         "this.nodes[$node$].innerHTML = $html$;"
155: 153:     }
156: 154: 
157: 155:     fn clone_template(tpl_node: u32, into_node: u32) {
158: 156:         "this.nodes[$into_node$]=this.nodes[$tpl_node$].content.\
159: 157:          cloneNode(true);"
160: 158:     }
161: 159: 
162: 160:     fn set_property(node: u32, name: &str<u8, name_cache>) {
163: 161:         "{let jsv=this.jsvalues.dequeue();this.nodes[$node$][$name$]=jsv;}"
164: 162:     }
165: 163: 
166: 164:     fn add_listener(node: u32, name: &str<u8, name_cache>) {
167: 165:         "{let jsv=this.jsvalues.dequeue();this.nodes[$node$].\
168: 166:          addEventListener($name$, jsv);}"
169: 167:     }
170: 168: }
171: 169: 
172: 170: #[wasm_bindgen(inline_js = "
173: 171:     export function get_node(channel, id){
174: 172:         return channel.nodes[id];
175: 173:     }
176: 174: 
177: 175:     export function store_node(channel, id, node){
178: 176:         channel.nodes[id] = node;
179: 177:     }
180: 178: 
181: 179:     export function store_jsvalue(channel, value) {
182: 180:         channel.jsvalues.enqueue(value);
183: 181:     }
184: 182: ")]
185: 183: extern "C" {
186: 184:     fn get_node(channel: &JSChannel, id: u32) -> Node;
187: 185: 
188: 186:     fn store_node(channel: &JSChannel, id: u32, node: Node);
189: 187: 
190: 188:     fn store_jsvalue(channel: &JSChannel, value: JsValue);
191: 189: }
192: 190: 
193: 191: #[derive(Debug)]
194: 192: pub struct Sledgehammer;
195: 193: 
196: 194: impl Sledgehammer {
197: 195:     pub fn body() -> SNode {
198: 196:         let node = SNode::new();
199: 197:         with(|channel| channel.store_body(node.0 .0));
200: 198:         node
201: 199:     }
202: 200: 
203: 201:     pub fn store(node: Node) -> SNode {
204: 202:         let snode = SNode::new();
205: 203:         with(|channel| store_node(channel.js_channel(), snode.0 .0, node));
206: 204:         snode
207: 205:     }
208: 206: 
209: 207:     pub fn element(tag_name: &'static str) -> SNode {
210: 208:         let node = SNode::new();
211: 209:         with(|channel| channel.create_element(node.0 .0, tag_name));
212: 210:         node
213: 211:     }
214: 212: }
215: 213: 
216: 214: #[derive(Debug, Clone, PartialEq, Eq, Hash)]
217: 215: pub struct SNode(Rc<SNodeInner>);
218: 216: 
219: 217: #[derive(Debug, PartialEq, Eq, Hash)]
220: 218: struct SNodeInner(u32);
221: 219: 
222: 220: impl SNode {
223: 221:     fn new() -> Self {
224: 222:         let id = if let Some(id) = RECYCLE_IDS.with_borrow_mut(Vec::pop) {
225: 223:             id
226: 224:         } else {
227: 225:             let new_id = NEXT_ID.get();
228: 226:             NEXT_ID.set(new_id + 1);
229: 227:             new_id
230: 228:         };
231: 229:         Self(Rc::new(SNodeInner(id)))
232: 230:     }
233: 231: 
234: 232:     pub fn to_node(&self) -> Node {
235: 233:         CHANNEL.with_borrow(|channel| get_node(channel.js_channel(), self.0 .0))
236: 234:     }
237: 235: }
238: 236: 
239: 237: impl Drop for SNodeInner {
240: 238:     fn drop(&mut self) {
241: 239:         RECYCLE_IDS.with_borrow_mut(|lyx-core-lyx_core_lyx-core-lyx_core_ids| lyx-core-lyx_core_lyx-core-lyx_core_ids.push(self.0));
242: 240:         with(|channel| channel.drop_node(self.0));
243: 241:     }
244: 242: }
245: 243: 
246: 244: impl AsRef<SNode> for SNode {
247: 245:     fn as_ref(&self) -> &SNode {
248: 246:         self
249: 247:     }
250: 248: }
251: 249: 
252: 250: impl CastFrom<SNode> for SNode {
253: 251:     fn cast_from(source: SNode) -> Option<Self> {
254: 252:         Some(source)
255: 253:     }
256: 254: }
257: 255: 
258: 256: thread_local! {
259: 257:     static CHANNEL: RefCell<Channel> = RefCell::new(Channel::default());
260: 258:     static FLUSH_PENDING: Cell<bool> = const { Cell::new(false) };
261: 259:     static FLUSH_CLOSURE: Closure<dyn Fn()> = Closure::new(|| {
262: 260:         FLUSH_PENDING.set(false);
263: 261:         CHANNEL.with_borrow_mut(|channel| {
264: 262:             channel.flush();
265: 263:         });
266: 264:     });
267: 265:     static NEXT_ID: Cell<u32> = const { Cell::new(1) };
268: 266:     static RECYCLE_IDS: RefCell<Vec<u32>> = const { RefCell::new(Vec::new()) };
269: 267: 
270: 268:     pub(crate) static GLOBAL_EVENTS: RefCell<FxHashSet<Cow<'static, str>>> = Default::default();
271: 269: }
272: 270: 
273: 271: fn with(fun: impl FnOnce(&mut Channel)) {
274: 272:     CHANNEL.with_borrow_mut(fun);
275: 273:     flush();
276: 274: }
277: 275: 
278: 276: #[allow(unused)] // might be handy at some point!
279: 277: fn flush_sync() {
280: 278:     FLUSH_PENDING.set(false);
281: 279:     CHANNEL.with_borrow_mut(|channel| channel.flush());
282: 280: }
283: 281: 
284: 282: fn flush() {
285: 283:     let was_pending = FLUSH_PENDING.replace(true);
286: 284:     if !was_pending {
287: 285:         FLUSH_CLOSURE.with(queueMicrotask);
288: 286:     }
289: 287: }
290: 288: 
291: 289: impl Renderer for Sledgehammer {
292: 290:     type Node = SNode;
293: 291:     type Text = SNode;
294: 292:     type Element = SNode;
295: 293:     type Placeholder = SNode;
296: 294: 
297: 295:     fn intern(text: &str) -> &str {
298: 296:         text
299: 297:     }
300: 298: 
301: 299:     fn create_text_node(text: &str) -> Self::Text {
302: 300:         let node = SNode::new();
303: 301:         with(|channel| channel.create_text_node(node.0 .0, text));
304: 302:         node
305: 303:     }
306: 304: 
307: 305:     fn create_placeholder() -> Self::Placeholder {
308: 306:         let node = SNode::new();
309: 307:         with(|channel| channel.create_comment(node.0 .0));
310: 308:         node
311: 309:     }
312: 310: 
313: 311:     fn set_text(node: &Self::Text, text: &str) {
314: 312:         with(|channel| channel.set_text(node.0 .0, text));
315: 313:     }
316: 314: 
317: 315:     fn set_attribute(node: &Self::Element, name: &str, value: &str) {
318: 316:         with(|channel| channel.set_attribute(node.0 .0, name, value));
319: 317:     }
320: 318: 
321: 319:     fn remove_attribute(node: &Self::Element, name: &str) {
322: 320:         with(|channel| channel.remove_attribute(node.0 .0, name));
323: 321:     }
324: 322: 
325: 323:     fn insert_node(
326: 324:         parent: &Self::Element,
327: 325:         new_child: &Self::Node,
328: 326:         anchor: Option<&Self::Node>,
329: 327:     ) {
330: 328:         with(|channel| {
331: 329:             channel.insert_before(
332: 330:                 parent.0 .0,
333: 331:                 new_child.0 .0,
334: 332:                 anchor.map(|n| n.0 .0).unwrap_or(0),
335: 333:             )
336: 334:         });
337: 335:     }
338: 336: 
339: 337:     fn remove_node(
340: 338:         parent: &Self::Element,
341: 339:         child: &Self::Node,
342: 340:     ) -> Option<Self::Node> {
343: 341:         with(|channel| channel.remove_child(parent.0 .0, child.0 .0));
344: 342:         Some(child.clone())
345: 343:     }
346: 344: 
347: 345:     fn remove(node: &Self::Node) {
348: 346:         with(|channel| channel.remove(node.0 .0));
349: 347:     }
350: 348: 
351: 349:     fn get_parent(_node: &Self::Node) -> Option<Self::Node> {
352: 350:         todo!() // node.parent_node()
353: 351:     }
354: 352: 
355: 353:     fn first_child(node: &Self::Node) -> Option<Self::Node> {
356: 354:         let child = SNode::new();
357: 355:         with(|channel| channel.first_child(node.0 .0, child.0 .0));
358: 356:         Some(child)
359: 357:     }
360: 358: 
361: 359:     fn next_sibling(node: &Self::Node) -> Option<Self::Node> {
362: 360:         let sibling = SNode::new();
363: 361:         with(|channel| channel.next_sibling(node.0 .0, sibling.0 .0));
364: 362:         Some(sibling)
365: 363:     }
366: 364: 
367: 365:     fn log_node(_node: &Self::Node) {
368: 366:         todo!()
369: 367:     }
370: 368: 
371: 369:     fn clear_children(parent: &Self::Element) {
372: 370:         with(|channel| channel.set_text(parent.0 .0, ""));
373: 371:     }
374: 372: }
375: 373: 
376: 374: #[derive(Debug, Clone)]
377: 375: pub struct ClassList(SNode);
378: 376: 
379: 377: #[derive(Debug, Clone)]
380: 378: #[allow(dead_code)] // this will be used, it's just all unimplemented
381: 379: pub struct CssStyle(SNode);
382: 380: 
383: 381: impl DomRenderer for Sledgehammer {
384: 382:     type Event = JsValue;
385: 383:     type ClassList = ClassList;
386: 384:     type CssStyleDeclaration = CssStyle;
387: 385:     type TemplateElement = SNode;
388: 386: 
389: 387:     fn set_property(_el: &Self::Element, _key: &str, _value: &JsValue) {
390: 388:         todo!()
391: 389:     }
392: 390: 
393: 391:     fn add_event_listener(
394: 392:         el: &Self::Element,
395: 393:         name: &str,
396: 394:         cb: Box<dyn FnMut(Self::Event)>,
397: 395:     ) -> RemoveEventHandler<Self::Element> {
398: 396:         let cb = wasm_bindgen::closure::Closure::wrap(cb).into_js_value();
399: 397:         CHANNEL.with_borrow_mut(|channel| {
400: 398:             channel.add_listener(el.0 .0, name);
401: 399:             let channel = channel.js_channel();
402: 400:             store_jsvalue(channel, cb);
403: 401:         });
404: 402: 
405: 403:         // return the remover
406: 404:         RemoveEventHandler(Box::new(move |_el| todo!()))
407: 405:     }
408: 406: 
409: 407:     fn event_target<T>(_ev: &Self::Event) -> T
410: 408:     where
411: 409:         T: CastFrom<Self::Element>,
412: 410:     {
413: 411:         todo!()
414: 412:         /*let el = ev
415: 413:             .unchecked_ref::<Event>()
416: 414:             .target()
417: 415:             .expect("event.target not found")
418: 416:             .unchecked_into::<Element>();
419: 417:         T::cast_from(el).expect("incorrect element type")*/
420: 418:     }
421: 419: 
422: 420:     fn add_event_listener_delegated(
423: 421:         el: &Self::Element,
424: 422:         name: Cow<'static, str>,
425: 423:         delegation_key: Cow<'static, str>,
426: 424:         cb: Box<dyn FnMut(Self::Event)>,
427: 425:     ) -> RemoveEventHandler<Self::Element> {
428: 426:         let cb = Closure::wrap(cb).into_js_value();
429: 427:         CHANNEL.with_borrow_mut(|channel| {
430: 428:             channel.set_property(el.0 .0, &delegation_key);
431: 429:             let channel = channel.js_channel();
432: 430:             store_jsvalue(channel, cb);
433: 431:         });
434: 432: 
435: 433:         GLOBAL_EVENTS.with(|global_events| {
436: 434:             let mut events = global_events.borrow_mut();
437: 435:             if !events.contains(&name) {
438: 436:                 // create global handler
439: 437:                 let key = JsValue::from_str(&delegation_key);
440: 438:                 let handler = move |ev: web_sys::Event| {
441: 439:                     let target = ev.target();
442: 440:                     let node = ev.composed_path().get(0);
443: 441:                     let mut node = if node.is_undefined() || node.is_null() {
444: 442:                         JsValue::from(target)
445: 443:                     } else {
446: 444:                         node
447: 445:                     };
448: 446: 
449: 447:                     // TODO reverse Shadow DOM retargetting
450: 448:                     // TODO simulate currentTarget
451: 449: 
452: 450:                     while !node.is_null() {
453: 451:                         let node_is_disabled = js_sys::Reflect::get(
454: 452:                             &node,
455: 453:                             &JsValue::from_str("disabled"),
456: 454:                         )
457: 455:                         .unwrap()
458: 456:                         .is_truthy();
459: 457:                         if !node_is_disabled {
460: 458:                             let maybe_handler =
461: 459:                                 js_sys::Reflect::get(&node, &key).unwrap();
462: 460:                             if !maybe_handler.is_undefined() {
463: 461:                                 let f = maybe_handler
464: 462:                                     .unchecked_ref::<js_sys::Function>();
465: 463:                                 let _ = f.call1(&node, &ev);
466: 464: 
467: 465:                                 if ev.cancel_bubble() {
468: 466:                                     return;
469: 467:                                 }
470: 468:                             }
471: 469:                         }
472: 470: 
473: 471:                         // navigate up tree
474: 472:                         if let Some(parent) =
475: 473:                             node.unchecked_ref::<web_sys::Node>().parent_node()
476: 474:                         {
477: 475:                             node = parent.into()
478: 476:                         } else if let Some(root) =
479: 477:                             node.dyn_ref::<web_sys::ShadowRoot>()
480: 478:                         {
481: 479:                             node = root.host().unchecked_into();
482: 480:                         } else {
483: 481:                             node = JsValue::null()
484: 482:                         }
485: 483:                     }
486: 484:                 };
487: 485: 
488: 486:                 let handler =
489: 487:                     Box::new(handler) as Box<dyn FnMut(web_sys::Event)>;
490: 488:                 let handler = Closure::wrap(handler).into_js_value();
491: 489:                 window()
492: 490:                     .add_event_listener_with_callback(
493: 491:                         &name,
494: 492:                         handler.unchecked_ref(),
495: 493:                     )
496: 494:                     .unwrap();
497: 495: 
498: 496:                 // register that we've created handler
499: 497:                 events.insert(name);
500: 498:             }
501: 499:         });
502: 500: 
503: 501:         // return the remover
504: 502:         RemoveEventHandler(Box::new(move |_el| todo!()))
505: 503:     }
506: 504: 
507: 505:     fn class_list(el: &Self::Element) -> Self::ClassList {
508: 506:         let class_list = SNode::new();
509: 507:         with(|channel| channel.class_list(el.0 .0, class_list.0 .0));
510: 508:         ClassList(class_list)
511: 509:     }
512: 510: 
513: 511:     fn add_class(list: &Self::ClassList, name: &str) {
514: 512:         with(|channel| channel.add_class(list.0 .0 .0, name));
515: 513:     }
516: 514: 
517: 515:     fn remove_class(list: &Self::ClassList, name: &str) {
518: 516:         with(|channel| channel.remove_class(list.0 .0 .0, name));
519: 517:     }
520: 518: 
521: 519:     fn style(_el: &Self::Element) -> Self::CssStyleDeclaration {
522: 520:         todo!()
523: 521:         //el.unchecked_ref::<HtmlElement>().style()
524: 522:     }
525: 523: 
526: 524:     fn set_css_property(
527: 525:         _style: &Self::CssStyleDeclaration,
528: 526:         _name: &str,
529: 527:         _value: &str,
530: 528:     ) {
531: 529:         todo!()
532: 530:         /*or_debug!(
533: 531:             style.set_property(name, value),
534: 532:             style.unchecked_ref(),
535: 533:             "setProperty"
536: 534:         );*/
537: 535:     }
538: 536: 
539: 537:     fn set_inner_html(el: &Self::Element, html: &str) {
540: 538:         with(|channel| channel.set_inner_html(el.0 .0, html))
541: 539:     }
542: 540: 
543: 541:     fn get_template<V>() -> Self::TemplateElement
544: 542:     where
545: 543:         V: ToTemplate + 'static,
546: 544:     {
547: 545:         thread_local! {
548: 546:             static TEMPLATES: RefCell<Vec<(TypeId, SNode)>> = Default::default();
549: 547:         }
550: 548: 
551: 549:         TEMPLATES.with_borrow_mut(|t| {
552: 550:             let id = TypeId::of::<V>();
553: 551:             t.iter()
554: 552:                 .find_map(|entry| (entry.0 == id).then(|| entry.1.clone()))
555: 553:                 .unwrap_or_else(|| {
556: 554:                     let mut buf = String::new();
557: 555:                     V::to_template(
558: 556:                         &mut buf,
559: 557:                         &mut String::new(),
560: 558:                         &mut String::new(),
561: 559:                         &mut String::new(),
562: 560:                         &mut Default::default(),
563: 561:                     );
564: 562:                     let node = SNode::new();
565: 563:                     with(|channel| {
566: 564:                         channel.create_element(node.0 .0, "template");
567: 565:                         channel.set_inner_html(node.0 .0, &buf)
568: 566:                     });
569: 567:                     t.push((id, node.clone()));
570: 568:                     node
571: 569:                 })
572: 570:         })
573: 571:     }
574: 572: 
575: 573:     fn clone_template(tpl: &Self::TemplateElement) -> Self::Element {
576: 574:         let node = SNode::new();
577: 575:         with(|channel| {
578: 576:             channel.clone_template(tpl.0 .0, node.0 .0);
579: 577:         });
580: 578:         node
581: 579:     }
582: 580: 
583: 581:     fn create_element_from_html(_html: &str) -> Self::Element {
584: 582:         todo!()
585: 583:     }
586: 584: }
587: 585: 
588: 586: impl Mountable<Sledgehammer> for SNode {
589: 587:     fn unmount(&mut self) {
590: 588:         with(|channel| channel.remove(self.0 .0));
591: 589:     }
592: 590: 
593: 591:     fn mount(&mut self, parent: &SNode, marker: Option<&SNode>) {
594: 592:         Sledgehammer::insert_node(parent, self, marker);
595: 593:     }
596: 594: 
597: 595:     fn insert_before_this(
598: 596:         &self,
599: 597:         _child: &mut dyn Mountable<Sledgehammer>,
600: 598:     ) -> bool {
601: 599:         todo!()
602: 600:     }
603: 601: }
604: 602: ```
605: 603: ```
606: 604: ```
607: 605: ```
608: 606: ```
609: 607: ```
610: 608: ```
611: 609: ```
612: ```
```
