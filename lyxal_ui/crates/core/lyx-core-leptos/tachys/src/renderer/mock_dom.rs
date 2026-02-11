### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\renderer\mock_dom.rs
18: 16: ```rust
19: 17: #![allow(unused)]
20: 18: 
21: 19: //! A stupidly-simple mock DOM implementation that can be used for testing.
22: 20: //!
23: 21: //! Do not use this for anything real.
24: 22: 
25: 23: use super::{CastFrom, DomRenderer, RemoveEventHandler, Renderer};
26: 24: use crate::{
27: 25:     html::element::{CreateElement, ElementType},
28: 26:     view::Mountable,
29: 27: };
30: 28: use indexmap::IndexMap;
31: 29: use slotmap::{new_key_type, SlotMap};
32: 30: use std::{borrow::Cow, cell::RefCell, rc::Rc};
33: 31: use wasm_bindgen::JsValue;
34: 32: 
35: 33: /// A [`Renderer`] that uses a mock DOM structure running in Rust code.
36: 34: ///
37: 35: /// This is intended as a rendering background that can be used to test component logic, without
38: 36: /// running a browser.
39: 37: #[derive(Debug)]
40: 38: pub struct MockDom;
41: 39: 
42: 40: new_key_type! {
43: 41:     /// A unique identifier for a mock DOM node.
44: 42:     pub struct NodeId;
45: 43: }
46: 44: 
47: 45: /// A mock DOM node.
48: 46: #[derive(Clone, Debug, Default, PartialEq, Eq, Hash)]
49: 47: pub struct Node(NodeId);
50: 48: 
51: 49: /// A mock element.
52: 50: #[derive(Clone, Debug, Default, PartialEq, Eq, Hash)]
53: 51: pub struct Element(Node);
54: 52: 
55: 53: /// A mock text node.
56: 54: #[derive(Clone, Debug, Default, PartialEq, Eq, Hash)]
57: 55: pub struct Text(Node);
58: 56: 
59: 57: /// A mock comment node.
60: 58: #[derive(Clone, Debug, Default, PartialEq, Eq, Hash)]
61: 59: pub struct Placeholder(Node);
62: 60: 
63: 61: impl AsRef<Node> for Node {
64: 62:     fn as_ref(&self) -> &Node {
65: 63:         self
66: 64:     }
67: 65: }
68: 66: 
69: 67: impl AsRef<Node> for Element {
70: 68:     fn as_ref(&self) -> &Node {
71: 69:         &self.0
72: 70:     }
73: 71: }
74: 72: 
75: 73: impl AsRef<Node> for Text {
76: 74:     fn as_ref(&self) -> &Node {
77: 75:         &self.0
78: 76:     }
79: 77: }
80: 78: 
81: 79: impl AsRef<Node> for Placeholder {
82: 80:     fn as_ref(&self) -> &Node {
83: 81:         &self.0
84: 82:     }
85: 83: }
86: 84: 
87: 85: /// Tests whether two nodes are references to the same underlying node.
88: 86: pub fn node_eq(a: impl AsRef<Node>, b: impl AsRef<Node>) -> bool {
89: 87:     a.as_ref() == b.as_ref()
90: 88: }
91: 89: 
92: 90: impl From<Text> for Node {
93: 91:     fn from(value: Text) -> Self {
94: 92:         Node(value.0 .0)
95: 93:     }
96: 94: }
97: 95: 
98: 96: impl From<Element> for Node {
99: 97:     fn from(value: Element) -> Self {
100: 98:         Node(value.0 .0)
101: 99:     }
102: 100: }
103: 101: 
104: 102: impl From<Placeholder> for Node {
105: 103:     fn from(value: Placeholder) -> Self {
106: 104:         Node(value.0 .0)
107: 105:     }
108: 106: }
109: 107: 
110: 108: impl Element {
111: 109:     /// Outputs an HTML form of the element, for testing and debugging purposes.
112: 110:     pub fn to_debug_html(&self) -> String {
113: 111:         let mut buf = String::new();
114: 112:         self.debug_html(&mut buf);
115: 113:         buf
116: 114:     }
117: 115: }
118: 116: 
119: 117: /// The DOM data associated with a particular node.
120: 118: #[derive(Debug, PartialEq, Eq)]
121: 119: pub struct NodeData {
122: 120:     /// The node's parent.
123: 121:     pub parent: Option<NodeId>,
124: 122:     /// The node itself.
125: 123:     pub ty: NodeType,
126: 124: }
127: 125: 
128: 126: trait DebugHtml {
129: 127:     fn debug_html(&self, buf: &mut String);
130: 128: }
131: 129: 
132: 130: impl DebugHtml for Element {
133: 131:     fn debug_html(&self, buf: &mut String) {
134: 132:         Document::with_node(self.0 .0, |node| {
135: 133:             node.debug_html(buf);
136: 134:         });
137: 135:     }
138: 136: }
139: 137: 
140: 138: impl DebugHtml for Text {
141: 139:     fn debug_html(&self, buf: &mut String) {
142: 140:         Document::with_node(self.0 .0, |node| {
143: 141:             node.debug_html(buf);
144: 142:         });
145: 143:     }
146: 144: }
147: 145: 
148: 146: impl DebugHtml for Node {
149: 147:     fn debug_html(&self, buf: &mut String) {
150: 148:         Document::with_node(self.0, |node| {
151: 149:             node.debug_html(buf);
152: 150:         });
153: 151:     }
154: 152: }
155: 153: 
156: 154: impl DebugHtml for NodeData {
157: 155:     fn debug_html(&self, buf: &mut String) {
158: 156:         match &self.ty {
159: 157:             NodeType::Text(text) => buf.push_str(text),
160: 158:             NodeType::Element {
161: 159:                 tag,
162: 160:                 attrs,
163: 161:                 children,
164: 162:             } => {
165: 163:                 buf.push('<');
166: 164:                 buf.push_str(tag);
167: 165:                 for (k, v) in attrs {
168: 166:                     buf.push(' ');
169: 167:                     buf.push_str(k);
170: 168:                     buf.push_str("=\"");
171: 169:                     buf.push_str(v);
172: 170:                     buf.push('"');
173: 171:                 }
174: 172:                 buf.push('>');
175: 173: 
176: 174:                 for child in children {
177: 175:                     child.debug_html(buf);
178: 176:                 }
179: 177: 
180: 178:                 buf.push_str("</");
181: 179:                 buf.push_str(tag);
182: 180:                 buf.push('>');
183: 181:             }
184: 182:             NodeType::Placeholder => buf.push_str("<!>"),
185: 183:         }
186: 184:     }
187: 185: }
188: 186: 
189: 187: /// The mock DOM document.
190: 188: #[derive(Clone)]
191: 189: pub struct Document(Rc<RefCell<SlotMap<NodeId, NodeData>>>);
192: 190: 
193: 191: impl Document {
194: 192:     /// Creates a new document.
195: 193:     pub fn new() -> Self {
196: 194:         Document(Default::default())
197: 195:     }
198: 196: 
199: 197:     fn with_node<U>(id: NodeId, f: impl FnOnce(&NodeData) -> U) -> Option<U> {
200: 198:         DOCUMENT.with(|d| {
201: 199:             let data = d.0.borrow();
202: 200:             let data = data.get(id);
203: 201:             data.map(f)
204: 202:         })
205: 203:     }
206: 204: 
207: 205:     fn with_node_mut<U>(
208: 206:         id: NodeId,
209: 207:         f: impl FnOnce(&mut NodeData) -> U,
210: 208:     ) -> Option<U> {
211: 209:         DOCUMENT.with(|d| {
212: 210:             let mut data = d.0.borrow_mut();
213: 211:             let data = data.get_mut(id);
214: 212:             data.map(f)
215: 213:         })
216: 214:     }
217: 215: 
218: 216:     /// Resets the document's contents.
219: 217:     pub fn reset(&self) {
220: 218:         self.0.borrow_mut().clear();
221: 219:     }
222: 220: 
223: 221:     fn create_element(&self, tag: &str) -> Element {
224: 222:         Element(Node(self.0.borrow_mut().insert(NodeData {
225: 223:             parent: None,
226: 224:             ty: NodeType::Element {
227: 225:                 tag: tag.to_string().into(),
228: 226:                 attrs: IndexMap::new(),
229: 227:                 children: Vec::new(),
230: 228:             },
231: 229:         })))
232: 230:     }
233: 231: 
234: 232:     fn create_text_node(&self, data: &str) -> Text {
235: 233:         Text(Node(self.0.borrow_mut().insert(NodeData {
236: 234:             parent: None,
237: 235:             ty: NodeType::Text(data.to_string()),
238: 236:         })))
239: 237:     }
240: 238: 
241: 239:     fn create_placeholder(&self) -> Placeholder {
242: 240:         Placeholder(Node(self.0.borrow_mut().insert(NodeData {
243: 241:             parent: None,
244: 242:             ty: NodeType::Placeholder,
245: 243:         })))
246: 244:     }
247: 245: }
248: 246: 
249: 247: // TODO!
250: 248: impl DomRenderer for MockDom {
251: 249:     type Event = ();
252: 250:     type ClassList = ();
253: 251:     type CssStyleDeclaration = ();
254: 252:     type TemplateElement = ();
255: 253: 
256: 254:     fn set_property(el: &Self::Element, key: &str, value: &JsValue) {
257: 255:         todo!()
258: 256:     }
259: 257: 
260: 258:     fn add_event_listener(
261: 259:         el: &Self::Element,
262: 260:         name: &str,
263: 261:         cb: Box<dyn FnMut(Self::Event)>,
264: 262:     ) -> RemoveEventHandler<Self::Element> {
265: 263:         todo!()
266: 264:     }
267: 265: 
268: 266:     fn add_event_listener_delegated(
269: 267:         el: &Self::Element,
270: 268:         name: Cow<'static, str>,
271: 269:         delegation_key: Cow<'static, str>,
272: 270:         cb: Box<dyn FnMut(Self::Event)>,
273: 271:     ) -> RemoveEventHandler<Self::Element> {
274: 272:         todo!()
275: 273:     }
276: 274: 
277: 275:     fn class_list(el: &Self::Element) -> Self::ClassList {
278: 276:         todo!()
279: 277:     }
280: 278: 
281: 279:     fn add_class(class_list: &Self::ClassList, name: &str) {
282: 280:         todo!()
283: 281:     }
284: 282: 
285: 283:     fn remove_class(class_list: &Self::ClassList, name: &str) {
286: 284:         todo!()
287: 285:     }
288: 286: 
289: 287:     fn style(el: &Self::Element) -> Self::CssStyleDeclaration {
290: 288:         todo!()
291: 289:     }
292: 290: 
293: 291:     fn set_css_property(
294: 292:         style: &Self::CssStyleDeclaration,
295: 293:         name: &str,
296: 294:         value: &str,
297: 295:     ) {
298: 296:         todo!()
299: 297:     }
300: 298: 
301: 299:     fn set_inner_html(el: &Self::Element, html: &str) {
302: 300:         todo!()
303: 301:     }
304: 302: 
305: 303:     fn event_target<T>(ev: &Self::Event) -> T
306: 304:     where
307: 305:         T: CastFrom<Self::Element>,
308: 306:     {
309: 307:         todo!()
310: 308:     }
311: 309: 
312: 310:     fn get_template<V>() -> Self::TemplateElement
313: 311:     where
314: 312:         V: crate::view::ToTemplate + 'static,
315: 313:     {
316: 314:         todo!()
317: 315:     }
318: 316: 
319: 317:     fn clone_template(tpl: &Self::TemplateElement) -> Self::Element {
320: 318:         todo!()
321: 319:     }
322: 320: 
323: 321:     fn create_element_from_html(html: &str) -> Self::Element {
324: 322:         todo!()
325: 323:     }
326: 324: }
327: 325: 
328: 326: impl Default for Document {
329: 327:     fn default() -> Self {
330: 328:         Self::new()
331: 329:     }
332: 330: }
333: 331: 
334: 332: thread_local! {
335: 333:     static DOCUMENT: Document = Document::new();
336: 334: }
337: 335: 
338: 336: /// Returns the global document.
339: 337: pub fn document() -> Document {
340: 338:     DOCUMENT.with(Clone::clone)
341: 339: }
342: 340: 
343: 341: /// The type of mock DOM node.
344: 342: #[derive(Debug, PartialEq, Eq)]
345: 343: pub enum NodeType {
346: 344:     /// A text node.
347: 345:     Text(String),
348: 346:     /// An element.
349: 347:     Element {
350: 348:         /// The HTML tag name.
351: 349:         tag: Cow<'static, str>,
352: 350:         /// The attributes.
353: 351:         attrs: IndexMap<String, String>,
354: 352:         /// The element's children.
355: 353:         children: Vec<Node>,
356: 354:     },
357: 355:     /// A placeholder.
358: 356:     Placeholder,
359: 357: }
360: 358: 
361: 359: impl Mountable<MockDom> for Node {
362: 360:     fn unmount(&mut self) {
363: 361:         todo!()
364: 362:     }
365: 363: 
366: 364:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
367: 365:         MockDom::insert_node(parent, self, marker);
368: 366:     }
369: 367: 
370: 368:     fn insert_before_this(&self, child: &mut dyn Mountable<MockDom>) -> bool {
371: 369:         let parent = MockDom::get_parent(self).and_then(Element::cast_from);
372: 370:         if let Some(parent) = parent {
373: 371:             child.mount(&parent, Some(self));
374: 372:             return true;
375: 373:         }
376: 374:         false
377: 375:     }
378: 376: }
379: 377: 
380: 378: impl Mountable<MockDom> for Text {
381: 379:     fn unmount(&mut self) {
382: 380:         todo!()
383: 381:     }
384: 382: 
385: 383:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
386: 384:         MockDom::insert_node(parent, self.as_ref(), marker);
387: 385:     }
388: 386: 
389: 387:     fn insert_before_this(&self, child: &mut dyn Mountable<MockDom>) -> bool {
390: 388:         let parent =
391: 389:             MockDom::get_parent(self.as_ref()).and_then(Element::cast_from);
392: 390:         if let Some(parent) = parent {
393: 391:             child.mount(&parent, Some(self.as_ref()));
394: 392:             return true;
395: 393:         }
396: 394:         false
397: 395:     }
398: 396: }
399: 397: 
400: 398: impl Mountable<MockDom> for Element {
401: 399:     fn unmount(&mut self) {
402: 400:         todo!()
403: 401:     }
404: 402: 
405: 403:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
406: 404:         MockDom::insert_node(parent, self.as_ref(), marker);
407: 405:     }
408: 406: 
409: 407:     fn insert_before_this(&self, child: &mut dyn Mountable<MockDom>) -> bool {
410: 408:         let parent =
411: 409:             MockDom::get_parent(self.as_ref()).and_then(Element::cast_from);
412: 410:         if let Some(parent) = parent {
413: 411:             child.mount(&parent, Some(self.as_ref()));
414: 412:             return true;
415: 413:         }
416: 414:         false
417: 415:     }
418: 416: }
419: 417: 
420: 418: impl Mountable<MockDom> for Placeholder {
421: 419:     fn unmount(&mut self) {
422: 420:         todo!()
423: 421:     }
424: 422: 
425: 423:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
426: 424:         MockDom::insert_node(parent, self.as_ref(), marker);
427: 425:     }
428: 426: 
429: 427:     fn insert_before_this(&self, child: &mut dyn Mountable<MockDom>) -> bool {
430: 428:         let parent =
431: 429:             MockDom::get_parent(self.as_ref()).and_then(Element::cast_from);
432: 430:         if let Some(parent) = parent {
433: 431:             child.mount(&parent, Some(self.as_ref()));
434: 432:             return true;
435: 433:         }
436: 434:         false
437: 435:     }
438: 436: }
439: 437: 
440: 438: impl<E: ElementType> CreateElement<MockDom> for E {
441: 439:     fn create_element(&self) -> crate::renderer::types::Element {
442: 440:         document().create_element(E::TAG)
443: 441:     }
444: 442: }
445: 443: 
446: 444: impl Renderer for MockDom {
447: 445:     type Node = Node;
448: 446:     type Text = Text;
449: 447:     type Element = Element;
450: 448:     type Placeholder = Placeholder;
451: 449: 
452: 450:     fn intern(text: &str) -> &str {
453: 451:         text
454: 452:     }
455: 453: 
456: 454:     fn create_text_node(data: &str) -> Self::Text {
457: 455:         document().create_text_node(data)
458: 456:     }
459: 457: 
460: 458:     fn create_placeholder() -> Self::Placeholder {
461: 459:         document().create_placeholder()
462: 460:     }
463: 461: 
464: 462:     fn set_text(node: &Self::Text, text: &str) {
465: 463:         Document::with_node_mut(node.0 .0, |node| {
466: 464:             if let NodeType::Text(ref mut node) = node.ty {
467: 465:                 *node = text.to_string();
468: 466:             }
469: 467:         });
470: 468:     }
471: 469: 
472: 470:     fn set_attribute(node: &Self::Element, name: &str, value: &str) {
473: 471:         Document::with_node_mut(node.0 .0, |node| {
474: 472:             if let NodeType::Element { ref mut attrs, .. } = node.ty {
475: 473:                 attrs.insert(name.to_string(), value.to_string());
476: 474:             }
477: 475:         });
478: 476:     }
479: 477: 
480: 478:     fn remove_attribute(node: &Self::Element, name: &str) {
481: 479:         Document::with_node_mut(node.0 .0, |node| {
482: 480:             if let NodeType::Element { ref mut attrs, .. } = node.ty {
483: 481:                 attrs.shift_remove(name);
484: 482:             }
485: 483:         });
486: 484:     }
487: 485: 
488: 486:     fn insert_node(
489: 487:         parent: &Self::Element,
490: 488:         new_child: &Self::Node,
491: 489:         anchor: Option<&Self::Node>,
492: 490:     ) {
493: 491:         debug_assert!(&parent.0 != new_child);
494: 492:         // remove if already mounted
495: 493:         if let Some(parent) = MockDom::get_parent(new_child) {
496: 494:             let parent = Element(parent);
497: 495:             MockDom::remove_node(&parent, new_child);
498: 496:         }
499: 497:         // mount on new parent
500: 498:         Document::with_node_mut(parent.0 .0, |parent| {
501: 499:             if let NodeType::Element {
502: 500:                 ref mut children, ..
503: 501:             } = parent.ty
504: 502:             {
505: 503:                 match anchor {
506: 504:                     None => children.push(new_child.clone()),
507: 505:                     Some(anchor) => {
508: 506:                         let anchor_pos = children
509: 507:                             .iter()
510: 508:                             .position(|item| item.0 == anchor.0)
511: 509:                             .expect("anchor is not a child of the parent");
512: 510:                         children.insert(anchor_pos, new_child.clone());
513: 511:                     }
514: 512:                 }
515: 513:             } else {
516: 514:                 panic!("parent is not an element");
517: 515:             }
518: 516:         });
519: 517:         // set parent on child node
520: 518:         Document::with_node_mut(new_child.0, |node| {
521: 519:             node.parent = Some(parent.0 .0)
522: 520:         });
523: 521:     }
524: 522: 
525: 523:     fn remove_node(
526: 524:         parent: &Self::Element,
527: 525:         child: &Self::Node,
528: 526:     ) -> Option<Self::Node> {
529: 527:         let child = Document::with_node_mut(parent.0 .0, |parent| {
530: 528:             if let NodeType::Element {
531: 529:                 ref mut children, ..
532: 530:             } = parent.ty
533: 531:             {
534: 532:                 let current_pos = children
535: 533:                     .iter()
536: 534:                     .position(|item| item.0 == child.0)
537: 535:                     .expect("anchor is not a child of the parent");
538: 536:                 Some(children.remove(current_pos))
539: 537:             } else {
540: 538:                 None
541: 539:             }
542: 540:         })
543: 541:         .flatten()?;
544: 542:         Document::with_node_mut(child.0, |node| {
545: 543:             node.parent = None;
546: 544:         });
547: 545:         Some(child)
548: 546:     }
549: 547: 
550: 548:     fn remove(node: &Self::Node) {
551: 549:         let parent = Element(Node(
552: 550:             Self::get_parent(node)
553: 551:                 .expect("tried to remove a parentless node")
554: 552:                 .0,
555: 553:         ));
556: 554:         Self::remove_node(&parent, node);
557: 555:     }
558: 556: 
559: 557:     fn get_parent(node: &Self::Node) -> Option<Self::Node> {
560: 558:         Document::with_node(node.0, |node| node.parent)
561: 559:             .flatten()
562: 560:             .map(Node)
563: 561:     }
564: 562: 
565: 563:     fn first_child(node: &Self::Node) -> Option<Self::Node> {
566: 564:         Document::with_node(node.0, |node| match &node.ty {
567: 565:             NodeType::Text(_) => None,
568: 566:             NodeType::Element { children, .. } => children.first().cloned(),
569: 567:             NodeType::Placeholder => None,
570: 568:         })
571: 569:         .flatten()
572: 570:     }
573: 571: 
574: 572:     fn next_sibling(node: &Self::Node) -> Option<Self::Node> {
575: 573:         let node_id = node.0;
576: 574:         Document::with_node(node_id, |node| {
577: 575:             node.parent.and_then(|parent| {
578: 576:                 Document::with_node(parent, |parent| match &parent.ty {
579: 577:                     NodeType::Element { children, .. } => {
580: 578:                         let this = children
581: 579:                             .iter()
582: 580:                             .position(|check| check == &Node(node_id))?;
583: 581:                         children.get(this + 1).cloned()
584: 582:                     }
585: 583:                     _ => panic!(
586: 584:                         "Called next_sibling with parent as a node that's not \
587: 585:                          an Element."
588: 586:                     ),
589: 587:                 })
590: 588:             })
591: 589:         })
592: 590:         .flatten()
593: 591:         .flatten()
594: 592:     }
595: 593: 
596: 594:     fn log_node(node: &Self::Node) {
597: 595:         eprintln!("{node:?}");
598: 596:     }
599: 597: 
600: 598:     fn clear_children(parent: &Self::Element) {
601: 599:         let prev_children =
602: 600:             Document::with_node_mut(parent.0 .0, |node| match node.ty {
603: 601:                 NodeType::Element {
604: 602:                     ref mut children, ..
605: 603:                 } => std::mem::take(children),
606: 604:                 _ => panic!("Called clear_children on a non-Element node."),
607: 605:             })
608: 606:             .unwrap_or_default();
609: 607:         for child in prev_children {
610: 608:             Document::with_node_mut(child.0, |node| {
611: 609:                 node.parent = None;
612: 610:             });
613: 611:         }
614: 612:     }
615: 613: }
616: 614: 
617: 615: impl CastFrom<Node> for Text {
618: 616:     fn cast_from(source: Node) -> Option<Self> {
619: 617:         Document::with_node(source.0, |node| {
620: 618:             matches!(node.ty, NodeType::Text(_))
621: 619:         })
622: 620:         .and_then(|matches| matches.then_some(Text(Node(source.0))))
623: 621:     }
624: 622: }
625: 623: 
626: 624: impl CastFrom<Node> for Element {
627: 625:     fn cast_from(source: Node) -> Option<Self> {
628: 626:         Document::with_node(source.0, |node| {
629: 627:             matches!(node.ty, NodeType::Element { .. })
630: 628:         })
631: 629:         .and_then(|matches| matches.then_some(Element(Node(source.0))))
632: 630:     }
633: 631: }
634: 632: 
635: 633: impl CastFrom<Node> for Placeholder {
636: 634:     fn cast_from(source: Node) -> Option<Self> {
637: 635:         Document::with_node(source.0, |node| {
638: 636:             matches!(node.ty, NodeType::Placeholder)
639: 637:         })
640: 638:         .and_then(|matches| matches.then_some(Placeholder(Node(source.0))))
641: 639:     }
642: 640: }
643: 641: 
644: 642: #[cfg(test)]
645: 643: mod tests {
646: 644:     use super::MockDom;
647: 645:     use crate::{
648: 646:         html::element,
649: 647:         renderer::{mock_dom::node_eq, Renderer},
650: 648:     };
651: 649: 
652: 650:     #[test]
653: 651:     fn html_debugging_works() {
654: 652:         let main = MockDom::create_element(element::Main);
655: 653:         let p = MockDom::create_element(element::P);
656: 654:         MockDom::set_attribute(&p, "id", "foo");
657: 655:         let text = MockDom::create_text_node("Hello, world!");
658: 656:         MockDom::insert_node(&main, p.as_ref(), None);
659: 657:         MockDom::insert_node(&p, text.as_ref(), None);
660: 658:         assert_eq!(
661: 659:             main.to_debug_html(),
662: 660:             "<main><p id=\"foo\">Hello, world!</p></main>"
663: 661:         );
664: 662:     }
665: 663: 
666: 664:     #[test]
667: 665:     fn remove_attribute_works() {
668: 666:         let main = MockDom::create_element(element::Main);
669: 667:         let p = MockDom::create_element(element::P);
670: 668:         MockDom::set_attribute(&p, "id", "foo");
671: 669:         let text = MockDom::create_text_node("Hello, world!");
672: 670:         MockDom::insert_node(&main, p.as_ref(), None);
673: 671:         MockDom::insert_node(&p, text.as_ref(), None);
674: 672:         MockDom::remove_attribute(&p, "id");
675: 673:         assert_eq!(main.to_debug_html(), "<main><p>Hello, world!</p></main>");
676: 674:     }
677: 675: 
678: 676:     #[test]
679: 677:     fn remove_node_works() {
680: 678:         let main = MockDom::create_element(element::Main);
681: 679:         let p = MockDom::create_element(element::P);
682: 680:         MockDom::set_attribute(&p, "id", "foo");
683: 681:         let text = MockDom::create_text_node("Hello, world!");
684: 682:         MockDom::insert_node(&main, p.as_ref(), None);
685: 683:         MockDom::insert_node(&p, text.as_ref(), None);
686: 684:         MockDom::remove_node(&main, p.as_ref());
687: 685:         assert_eq!(main.to_debug_html(), "<main></main>");
688: 686:     }
689: 687: 
690: 688:     #[test]
691: 689:     fn insert_before_works() {
692: 690:         let main = MockDom::create_element(element::Main);
693: 691:         let p = MockDom::create_element(element::P);
694: 692:         let span = MockDom::create_element(element::Span);
695: 693:         let text = MockDom::create_text_node("Hello, world!");
696: 694:         MockDom::insert_node(&main, p.as_ref(), None);
697: 695:         MockDom::insert_node(&span, text.as_ref(), None);
698: 696:         MockDom::insert_node(&main, span.as_ref(), Some(p.as_ref()));
699: 697:         assert_eq!(
700: 698:             main.to_debug_html(),
701: 699:             "<main><span>Hello, world!</span><p></p></main>"
702: 700:         );
703: 701:     }
704: 702: 
705: 703:     #[test]
706: 704:     fn insert_before_sets_parent() {
707: 705:         let main = MockDom::create_element(element::Main);
708: 706:         let p = MockDom::create_element(element::P);
709: 707:         MockDom::insert_node(&main, p.as_ref(), None);
710: 708:         let parent =
711: 709:             MockDom::get_parent(p.as_ref()).expect("p should have parent set");
712: 710:         assert!(node_eq(parent, main));
713: 711:     }
714: 712: 
715: 713:     #[test]
716: 714:     fn insert_before_moves_node() {
717: 715:         let main = MockDom::create_element(element::Main);
718: 716:         let p = MockDom::create_element(element::P);
719: 717:         let span = MockDom::create_element(element::Span);
720: 718:         let text = MockDom::create_text_node("Hello, world!");
721: 719:         MockDom::insert_node(&main, p.as_ref(), None);
722: 720:         MockDom::insert_node(&span, text.as_ref(), None);
723: 721:         MockDom::insert_node(&main, span.as_ref(), Some(p.as_ref()));
724: 722:         MockDom::insert_node(&main, p.as_ref(), Some(span.as_ref()));
725: 723:         assert_eq!(
726: 724:             main.to_debug_html(),
727: 725:             "<main><p></p><span>Hello, world!</span></main>"
728: 726:         );
729: 727:     }
730: 728: 
731: 729:     #[test]
732: 730:     fn first_child_gets_first_child() {
733: 731:         let main = MockDom::create_element(element::Main);
734: 732:         let p = MockDom::create_element(element::P);
735: 733:         let span = MockDom::create_element(element::Span);
736: 734:         MockDom::insert_node(&main, p.as_ref(), None);
737: 735:         MockDom::insert_node(&p, span.as_ref(), None);
738: 736:         assert_eq!(
739: 737:             MockDom::first_child(main.as_ref()).as_ref(),
740: 738:             Some(p.as_ref())
741: 739:         );
742: 740:         assert_eq!(
743: 741:             MockDom::first_child(&MockDom::first_child(main.as_ref()).unwrap())
744: 742:                 .as_ref(),
745: 743:             Some(span.as_ref())
746: 744:         );
747: 745:     }
748: 746: 
749: 747:     #[test]
750: 748:     fn next_sibling_gets_next_sibling() {
751: 749:         let main = MockDom::create_element(element::Main);
752: 750:         let p = MockDom::create_element(element::P);
753: 751:         let span = MockDom::create_element(element::Span);
754: 752:         let text = MockDom::create_text_node("foo");
755: 753:         MockDom::insert_node(&main, p.as_ref(), None);
756: 754:         MockDom::insert_node(&main, span.as_ref(), None);
757: 755:         MockDom::insert_node(&main, text.as_ref(), None);
758: 756:         assert_eq!(
759: 757:             MockDom::next_sibling(p.as_ref()).as_ref(),
760: 758:             Some(span.as_ref())
761: 759:         );
762: 760:         assert_eq!(
763: 761:             MockDom::next_sibling(span.as_ref()).as_ref(),
764: 762:             Some(text.as_ref())
765: 763:         );
766: 764:     }
767: 765: }
768: 766: ```
769: 767: ```
770: 768: ```
771: 769: ```
772: 770: ```
773: 771: ```
774: 772: ```
775: 773: ```
776: ```
```
