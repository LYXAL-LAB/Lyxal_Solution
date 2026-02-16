1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-drag-reorder\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
46: 44: ```rust
47: 45: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
48: 46: ```rust
49: 47: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
50: 48: ```rust
51: 49: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
52: 50: ```rust
53: 51: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_drag_reorder\src\lib.rs
54: 52: ```rust
55: 53: #![doc = include_str!("../README.md")]
56: 54: 
57: 55: use std::collections::HashMap;
58: 56: 
59: 57: use js_sys::Function;
60: 58: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{ev, html::ElementType, prelude::*, lyx-core-lyx_core_lyx-core-lyx_core_tachys::dom::event_target};
61: 59: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
62: 60: use wasm_bindgen::{prelude::Closure, JsCast};
63: 61: 
64: 62: /// Return value for [`use_drag_reorder`].
65: 63: pub struct UseDragReorderReturn<E, SetDraggable, OnDragStart, OnDragEnd>
66: 64: where
67: 65:     E: ElementType,
68: 66:     E::Output: 'static,
69: 67:     SetDraggable: Fn(bool) + Copy,
70: 68:     OnDragStart: Fn(ev::DragEvent) + Clone,
71: 69:     OnDragEnd: Fn(ev::DragEvent) + Clone,
72: 70: {
73: 71:     /// Node ref which should be assigned to the panel element.
74: 72:     pub node_ref: NodeRef<E>,
75: 73:     /// Is this panel being dragged.
76: 74:     pub is_dragging: Signal<bool>,
77: 75:     /// The current position this panel is being hovered over.
78: 76:     ///
79: 77:     /// This is useful for styling. Typically you would have a line above or below this panel to indicate
80: 78:     /// the dragged panel can be dropped.
81: 79:     pub hover_position: Signal<Option<HoverPosition>>,
82: 80:     /// Is the panel draggable.
83: 81:     pub draggable: Signal<bool>,
84: 82:     /// Enables/disables the panel to be draggable.
85: 83:     pub set_draggable: SetDraggable,
86: 84:     /// Callback which should be assigned to the `on:dragstart` event.
87: 85:     pub on_dragstart: OnDragStart,
88: 86:     /// Callback which should be assigned to the `on:dragend` event.
89: 87:     pub on_dragend: OnDragEnd,
90: 88: }
91: 89: 
92: 90: /// A hovering panels position either above or below.
93: 91: #[derive(Clone, Copy, Debug, PartialEq, Eq)]
94: 92: pub enum HoverPosition {
95: 93:     Above,
96: 94:     Below,
97: 95: }
98: 96: 
99: 97: /// Registers a panel with drag reordering for a given ID.
100: 98: pub fn use_drag_reorder<E>(
101: 99:     id: impl Into<Oco<'static, str>>,
102: 100: ) -> UseDragReorderReturn<
103: 101:     E,
104: 102:     impl Fn(bool) + Copy,
105: 103:     impl Fn(ev::DragEvent) + Clone,
106: 104:     impl Fn(ev::DragEvent) + Clone,
107: 105: >
108: 106: where
109: 107:     E: ElementType + 'static,
110: 108:     E::Output: JsCast + Into<web_sys::Element> + Clone + 'static,
111: 109: {
112: 110:     let DragReorderContext {
113: 111:         column_refs,
114: 112:         panel_order,
115: 113:         currently_dragged_panel,
116: 114:         hover_info,
117: 115:         panels,
118: 116:     } = expect_context();
119: 117:     let mut id: Oco<'static, str> = id.into();
120: 118:     id.upgrade_inplace();
121: 119:     let node_ref = NodeRef::<E>::new();
122: 120: 
123: 121:     Effect::new({
124: 122:         let id = id.clone();
125: 123:         move |_| match node_ref.get() {
126: 124:             Some(node_ref) => {
127: 125:                 panels
128: 126:                     .write()
129: 127:                     .insert(id.clone(), SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(node_ref.into()));
130: 128:             }
131: 129:             None => {
132: 130:                 panels.write().remove(&id);
133: 131:             }
134: 132:         }
135: 133:     });
136: 134: 
137: 135:     on_cleanup({
138: 136:         let id = id.clone();
139: 137:         move || {
140: 138:             panels.write().remove(&id);
141: 139:         }
142: 140:     });
143: 141: 
144: 142:     let is_dragging = Signal::derive({
145: 143:         let id = id.clone();
146: 144:         move || currently_dragged_panel.read().as_deref() == Some(id.as_str())
147: 145:     });
148: 146:     let hover_position = Signal::derive({
149: 147:         let id = id.clone();
150: 148:         let panel_order = panel_order.clone();
151: 149:         move || match &*hover_info.read() {
152: 150:             Some(HoverInfo {
153: 151:                 panel: Some(panel), ..
154: 152:             }) => {
155: 153:                 let currently_dragged_panel = currently_dragged_panel.read();
156: 154:                 let Some(currently_dragged_panel) = &*currently_dragged_panel else {
157: 155:                     return None;
158: 156:                 };
159: 157: 
160: 158:                 let hovering_this_panel = panel.id == id.as_str();
161: 159:                 let is_currently_dragged_panel = currently_dragged_panel == id.as_str();
162: 160: 
163: 161:                 let currently_dragged_panel_index =
164: 162:                     panel_order
165: 163:                         .iter()
166: 164:                         .enumerate()
167: 165:                         .find_map(|(column_index, column)| {
168: 166:                             column
169: 167:                                 .read()
170: 168:                                 .iter()
171: 169:                                 .position(|panel_id| panel_id == currently_dragged_panel)
172: 170:                                 .map(|pos| (column_index, pos))
173: 171:                         });
174: 172:                 let hovering_neighbour_panel = match (currently_dragged_panel_index, panel.position)
175: 173:                 {
176: 174:                     (Some((column_index, panel_index)), HoverPosition::Above) => panel_order
177: 175:                         .get(column_index)
178: 176:                         .and_then(|column| {
179: 177:                             column
180: 178:                                 .read()
181: 179:                                 .get(panel_index + 1)
182: 180:                                 .map(|below_id| below_id.as_str() == id)
183: 181:                         })
184: 182:                         .unwrap_or(false),
185: 183:                     (Some((column_index, panel_index)), HoverPosition::Below)
186: 184:                         if panel_index > 0 =>
187: 185:                     {
188: 186:                         panel_order
189: 187:                             .get(column_index)
190: 188:                             .and_then(|column| {
191: 189:                                 column
192: 190:                                     .read()
193: 191:                                     .get(panel_index - 1)
194: 192:                                     .map(|below_id| below_id.as_str() == id)
195: 193:                             })
196: 194:                             .unwrap_or(false)
197: 195:                     }
198: 196:                     _ => false,
199: 197:                 };
200: 198:                 if hovering_this_panel && !is_currently_dragged_panel && !hovering_neighbour_panel {
201: 199:                     Some(panel.position)
202: 200:                 } else {
203: 201:                     None
204: 202:                 }
205: 203:             }
206: 204:             _ => None,
207: 205:         }
208: 206:     });
209: 207: 
210: 208:     let draggable = RwSignal::new(false);
211: 209:     let set_draggable = move |can_drag: bool| {
212: 210:         draggable.set(can_drag);
213: 211:     };
214: 212: 
215: 213:     let on_dragover_cb: RwSignal<Option<Function>, LocalStorage> = RwSignal::new_local(None);
216: 214: 
217: 215:     let on_drag_start = {
218: 216:         let id = id.clone();
219: 217:         move |ev: ev::DragEvent| {
220: 218:             currently_dragged_panel.set(Some(id.clone()));
221: 219: 
222: 220:             let dragged_el = event_target::<web_sys::HtmlElement>(&ev);
223: 221:             let mouse_x = ev.lyx-core-lyx_core_lyx-core-lyx_core_client_x() as f64;
224: 222:             let mouse_y = ev.lyx-core-lyx_core_lyx-core-lyx_core_client_y() as f64;
225: 223:             let rect = dragged_el.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect();
226: 224: 
227: 225:             // Calculate the center of the element
228: 226:             let center_x = rect.x() + rect.width() / 2.0;
229: 227:             let center_y = rect.y() + rect.height() / 2.0;
230: 228: 
231: 229:             // Calculate the offset from the mouse position to the center of the element
232: 230:             let offset_x = mouse_x - center_x;
233: 231:             let offset_y = mouse_y - center_y;
234: 232: 
235: 233:             // Necessary for firefox to emit drag events
236: 234:             if let Some(data_transfer) = ev.data_transfer() {
237: 235:                 let _ = data_transfer.set_data("text/plain", &id);
238: 236:             }
239: 237: 
240: 238:             let column_refs = column_refs.clone();
241: 239:             let panel_order = panel_order.clone();
242: 240:             let on_dragover: Function = Closure::wrap(Box::new(move |ev: web_sys::DragEvent| {
243: 241:                 ev.prevent_default();
244: 242: 
245: 243:                 let mouse_x = ev.lyx-core-lyx_core_lyx-core-lyx_core_client_x() as f64 - offset_x;
246: 244:                 let mouse_y = ev.lyx-core-lyx_core_lyx-core-lyx_core_client_y() as f64 - offset_y;
247: 245: 
248: 246:                 let (closest_column, _) = column_refs.iter().enumerate().fold(
249: 247:                     (None, f64::INFINITY),
250: 248:                     |(column, closest_dist), (i, column_ref)| {
251: 249:                         let Some(column_ref) = &*column_ref.read_untracked() else {
252: 250:                             return (column, closest_dist);
253: 251:                         };
254: 252:                         let rect = column_ref.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect();
255: 253:                         let center_x = rect.left() + rect.width() / 2.0;
256: 254:                         let dist = (mouse_x - center_x).abs();
257: 255:                         if dist < closest_dist {
258: 256:                             (Some((i, column_ref.clone())), dist)
259: 257:                         } else {
260: 258:                             (column, closest_dist)
261: 259:                         }
262: 260:                     },
263: 261:                 );
264: 262: 
265: 263:                 if let Some((column_index, _)) = closest_column {
266: 264:                     let (closest_panel, _) = panels.read_untracked().iter().fold(
267: 265:                         (None, f64::INFINITY),
268: 266:                         |(closest_panel, closest_dist), (panel_id, panel_ref)| {
269: 267:                             let is_in_column = panel_order
270: 268:                                 .get(column_index)
271: 269:                                 .map(|column_panels| {
272: 270:                                     column_panels.read_untracked().contains(panel_id)
273: 271:                                 })
274: 272:                                 .unwrap_or(false);
275: 273:                             if !is_in_column {
276: 274:                                 return (closest_panel, closest_dist);
277: 275:                             }
278: 276: 
279: 277:                             let rect = panel_ref.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect();
280: 278:                             let center_y = rect.top() + rect.height() / 2.0;
281: 279:                             let dist = (mouse_y - center_y).abs();
282: 280:                             if dist < closest_dist {
283: 281:                                 (Some((panel_id.clone(), panel_ref.clone(), center_y)), dist)
284: 282:                             } else {
285: 283:                                 (closest_panel, closest_dist)
286: 284:                             }
287: 285:                         },
288: 286:                     );
289: 287: 
290: 288:                     let new_hover_info = if let Some((panel_id, _, center_y)) = closest_panel {
291: 289:                         if mouse_y < center_y {
292: 290:                             Some(HoverInfo {
293: 291:                                 column_index,
294: 292:                                 panel: Some(HoveredPanel {
295: 293:                                     id: panel_id,
296: 294:                                     position: HoverPosition::Above,
297: 295:                                 }),
298: 296:                             })
299: 297:                         } else {
300: 298:                             Some(HoverInfo {
301: 299:                                 column_index,
302: 300:                                 panel: Some(HoveredPanel {
303: 301:                                     id: panel_id,
304: 302:                                     position: HoverPosition::Below,
305: 303:                                 }),
306: 304:                             })
307: 305:                         }
308: 306:                     } else {
309: 307:                         Some(HoverInfo {
310: 308:                             column_index,
311: 309:                             panel: None,
312: 310:                         })
313: 311:                     };
314: 312: 
315: 313:                     hover_info.maybe_update(move |hovered| {
316: 314:                         if hovered != &new_hover_info {
317: 315:                             *hovered = new_hover_info;
318: 316:                             true
319: 317:                         } else {
320: 318:                             false
321: 319:                         }
322: 320:                     });
323: 321:                 }
324: 322:             }) as Box<dyn FnMut(_)>)
325: 323:             .into_js_value()
326: 324:             .dyn_into()
327: 325:             .unwrap();
328: 326: 
329: 327:             document()
330: 328:                 .add_event_listener_with_callback_and_bool("dragover", &on_dragover, false)
331: 329:                 .unwrap();
332: 330: 
333: 331:             on_dragover_cb.set(Some(on_dragover));
334: 332:         }
335: 333:     };
336: 334: 
337: 335:     let on_drag_end = {
338: 336:         let id = id.clone();
339: 337:         move |_ev: ev::DragEvent| {
340: 338:             if let Some(on_dragover) = on_dragover_cb.write().take() {
341: 339:                 document()
342: 340:                     .remove_event_listener_with_callback("dragover", &on_dragover)
343: 341:                     .unwrap();
344: 342:             }
345: 343: 
346: 344:             let id = id.clone();
347: 345:             request_animation_frame(move || {
348: 346:                 let mut current = currently_dragged_panel.write();
349: 347:                 if current.as_deref() == Some(&id) {
350: 348:                     hover_info.set(None);
351: 349:                     draggable.set(false);
352: 350:                     *current = None;
353: 351:                 }
354: 352:             });
355: 353:         }
356: 354:     };
357: 355: 
358: 356:     UseDragReorderReturn {
359: 357:         node_ref,
360: 358:         is_dragging,
361: 359:         hover_position,
362: 360:         draggable: draggable.into(),
363: 361:         set_draggable,
364: 362:         on_dragstart: on_drag_start,
365: 363:         on_dragend: on_drag_end,
366: 364:     }
367: 365: }
368: 366: 
369: 367: #[derive(Clone)]
370: 368: struct DragReorderContext {
371: 369:     column_refs: Vec<Signal<Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<web_sys::Element>>>>,
372: 370:     panel_order: Vec<RwSignal<Vec<Oco<'static, str>>>>,
373: 371:     currently_dragged_panel: RwSignal<Option<Oco<'static, str>>>,
374: 372:     hover_info: RwSignal<Option<HoverInfo>>,
375: 373:     panels: RwSignal<HashMap<Oco<'static, str>, SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<web_sys::Element>>>,
376: 374: }
377: 375: 
378: 376: #[derive(Clone, Debug, PartialEq, Eq)]
379: 377: struct HoverInfo {
380: 378:     column_index: usize,
381: 379:     panel: Option<HoveredPanel>,
382: 380: }
383: 381: 
384: 382: #[derive(Clone, Debug, PartialEq, Eq)]
385: 383: struct HoveredPanel {
386: 384:     id: Oco<'static, str>,
387: 385:     position: HoverPosition,
388: 386: }
389: 387: 
390: 388: pub fn provide_drag_reorder<const COLUMNS: usize, E>(
391: 389:     panel_order: [RwSignal<Vec<Oco<'static, str>>>; COLUMNS],
392: 390: ) -> [NodeRef<E>; COLUMNS]
393: 391: where
394: 392:     E: ElementType + 'static,
395: 393:     E::Output: JsCast + Into<web_sys::Element> + Clone + 'static,
396: 394: {
397: 395:     let column_refs: Vec<NodeRef<E>> = panel_order
398: 396:         .iter()
399: 397:         .map(|_| NodeRef::new())
400: 398:         .collect::<Vec<_>>();
401: 399:     let ctx = DragReorderContext {
402: 400:         panel_order: panel_order.to_vec(),
403: 401:         column_refs: column_refs
404: 402:             .clone()
405: 403:             .into_iter()
406: 404:             .map(|column_ref| {
407: 405:                 Signal::derive(move || {
408: 406:                     column_ref
409: 407:                         .get()
410: 408:                         .map(|column_ref| SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(column_ref.into()))
411: 409:                 })
412: 410:             })
413: 411:             .collect(),
414: 412:         currently_dragged_panel: RwSignal::new(None),
415: 413:         hover_info: RwSignal::new(None),
416: 414:         panels: RwSignal::new(HashMap::new()),
417: 415:     };
418: 416: 
419: 417:     Effect::new({
420: 418:         move |mut last_on_dragend: Option<Function>| {
421: 419:             if let Some(last_on_dragend) = last_on_dragend.take() {
422: 420:                 let _ = document().remove_event_listener_with_callback("dragend", &last_on_dragend);
423: 421:             }
424: 422: 
425: 423:             let on_dragend: Function = Closure::wrap(Box::new(move |_ev: web_sys::MouseEvent| {
426: 424:                 if let Some((currently_dragged_panel, hover_info)) = ctx
427: 425:                     .currently_dragged_panel
428: 426:                     .read_untracked()
429: 427:                     .as_ref()
430: 428:                     .zip(ctx.hover_info.get_untracked())
431: 429:                 {
432: 430:                     reorder_panel_order(&panel_order, &currently_dragged_panel, hover_info);
433: 431:                 }
434: 432:             }) as Box<dyn FnMut(_)>)
435: 433:             .into_js_value()
436: 434:             .dyn_into()
437: 435:             .unwrap();
438: 436: 
439: 437:             document()
440: 438:                 .add_event_listener_with_callback("dragend", &on_dragend)
441: 439:                 .unwrap();
442: 440: 
443: 441:             on_cleanup({
444: 442:                 let on_dragend = SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(on_dragend.clone());
445: 443:                 move || {
446: 444:                     let _ = document()
447: 445:                         .remove_event_listener_with_callback("dragend", &on_dragend.take());
448: 446:                 }
449: 447:             });
450: 448: 
451: 449:             on_dragend
452: 450:         }
453: 451:     });
454: 452: 
455: 453:     provide_context(ctx);
456: 454: 
457: 455:     column_refs
458: 456:         .try_into()
459: 457:         .ok()
460: 458:         .expect("vec should be same size as array")
461: 459: }
462: 460: 
463: 461: fn reorder_panel_order(
464: 462:     panel_order: &[RwSignal<Vec<Oco<'static, str>>>],
465: 463:     currently_dragged_panel: &str,
466: 464:     hover_info: HoverInfo,
467: 465: ) {
468: 466:     // Extract hover information
469: 467:     let HoverInfo {
470: 468:         column_index: to_col_index,
471: 469:         panel: maybe_hovered_panel,
472: 470:     } = hover_info;
473: 471: 
474: 472:     // Initialize variables to store the original position of the dragged panel
475: 473:     let mut from_col_index = None;
476: 474:     let mut from_row_index = None;
477: 475: 
478: 476:     // Find the column and row index of the currently dragged panel
479: 477:     for (col_idx, col_signal) in panel_order.iter().enumerate() {
480: 478:         let col_panels = col_signal.get_untracked();
481: 479:         if let Some(row_idx) = col_panels
482: 480:             .iter()
483: 481:             .position(|panel_id| panel_id.as_str() == currently_dragged_panel)
484: 482:         {
485: 483:             from_col_index = Some(col_idx);
486: 484:             from_row_index = Some(row_idx);
487: 485:             break;
488: 486:         }
489: 487:     }
490: 488: 
491: 489:     // Proceed only if the dragged panel was found
492: 490:     if let (Some(from_col_index), Some(from_row_index)) = (from_col_index, from_row_index) {
493: 491:         // Get the target column's panels
494: 492:         let to_col_signal = &panel_order[to_col_index];
495: 493:         let mut to_col_panels = to_col_signal.get_untracked();
496: 494: 
497: 495:         // Determine the insertion index
498: 496:         let insert_row_index = match maybe_hovered_panel {
499: 497:             Some(HoveredPanel {
500: 498:                 id: hovered_panel_id,
501: 499:                 position: hover_position,
502: 500:             }) => {
503: 501:                 // Find the index of the hovered panel in the target column
504: 502:                 if let Some(hovered_row_index) = to_col_panels
505: 503:                     .iter()
506: 504:                     .position(|panel_id| panel_id.as_str() == hovered_panel_id)
507: 505:                 {
508: 506:                     // Determine the insertion index based on the hover position
509: 507:                     let mut idx = match hover_position {
510: 508:                         HoverPosition::Above => hovered_row_index,
511: 509:                         HoverPosition::Below => hovered_row_index + 1,
512: 510:                     };
513: 511: 
514: 512:                     // Adjust the insertion index if moving within the same column
515: 513:                     if from_col_index == to_col_index && from_row_index < idx {
516: 514:                         idx -= 1;
517: 515:                     }
518: 516:                     idx
519: 517:                 } else {
520: 518:                     // If hovered panel is not found, insert at the end
521: 519:                     to_col_panels.len()
522: 520:                 }
523: 521:             }
524: 522:             None => {
525: 523:                 // No hovered panel; insert at the end of the column
526: 524:                 to_col_panels.len()
527: 525:             }
528: 526:         };
529: 527: 
530: 528:         // Remove the dragged panel from its original position
531: 529:         let from_col_signal = &panel_order[from_col_index];
532: 530:         let mut from_col_panels = from_col_signal.get_untracked();
533: 531:         from_col_panels.remove(from_row_index);
534: 532: 
535: 533:         if from_col_index == to_col_index {
536: 534:             // Insert the panel into the same column at the new position
537: 535:             from_col_panels.insert(
538: 536:                 insert_row_index,
539: 537:                 Oco::from(currently_dragged_panel.to_string()),
540: 538:             );
541: 539:             from_col_signal.set(from_col_panels);
542: 540:         } else {
543: 541:             // Write back the modified original column
544: 542:             from_col_signal.set(from_col_panels);
545: 543: 
546: 544:             // Insert the panel into the new column
547: 545:             to_col_panels.insert(
548: 546:                 insert_row_index,
549: 547:                 Oco::from(currently_dragged_panel.to_string()),
550: 548:             );
551: 549:             to_col_signal.set(to_col_panels);
552: 550:         }
553: 551:     }
554: 552: }
555: 553: ```
556: 554: ```
557: 555: ```
558: 556: ```
559: 557: ```
560: 558: ```
561: 559: ```
562: 560: ```
563: 561: ```
564: 562: ```
565: 563: ```
566: 564: ```
567: 565: ```
568: 566: ```
569: 567: ```
570: 568: ```
571: 569: ```
572: 570: ```
573: 571: ```
574: 572: ```
575: 573: ```
576: 574: ```
577: 575: ```
578: 576: ```
579: 577: ```
580: 578: ```
581: ```
```

