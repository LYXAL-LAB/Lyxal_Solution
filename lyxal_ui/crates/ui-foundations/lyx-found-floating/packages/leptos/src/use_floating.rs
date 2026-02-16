1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\use_floating.rs
42: 40: ```rust
43: 41: use std::{
44: 42:     ops::Deref,
45: 43:     rc::Rc,
46: 44:     sync::{Arc, Mutex},
47: 45: };
48: 46: 
49: 47: use lyx_ui_foundations_dom::{
50: 48:     ComputePositionConfig, MiddlewareData, OwnedElementOrVirtual, Placement, Strategy,
51: 49:     VirtualElement, compute_position,
52: 50: };
53: 51: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{html::ElementType, prelude::*};
54: 52: use lyx-core-lyx_core_lyx-core-lyx_core_leptos_node_ref::AnyNodeRef;
55: 53: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
56: 54: use web_sys::wasm_bindgen::{JsCast, JsValue};
57: 55: 
58: 56: use crate::{
59: 57:     types::{FloatingStyles, UseFloatingOptions, UseFloatingReturn, WhileElementsMountedCleanupFn},
60: 58:     utils::{get_dpr::get_dpr, round_by_dpr::round_by_dpr},
61: 59: };
62: 60: 
63: 61: pub struct Virtual;
64: 62: 
65: 63: impl ElementType for Virtual {
66: 64:     type Output = JsValue;
67: 65: 
68: 66:     const TAG: &'static str = "virtual";
69: 67:     const SELF_CLOSING: bool = true;
70: 68:     const ESCAPE_CHILDREN: bool = true;
71: 69:     const NAMESPACE: Option<&'static str> = None;
72: 70: 
73: 71:     fn tag(&self) -> &str {
74: 72:         Self::TAG
75: 73:     }
76: 74: }
77: 75: 
78: 76: #[derive(Clone)]
79: 77: pub enum VirtualElementOrNodeRef {
80: 78:     VirtualElement(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Box<dyn VirtualElement<web_sys::Element>>>),
81: 79:     NodeRef(AnyNodeRef),
82: 80: }
83: 81: 
84: 82: impl VirtualElementOrNodeRef {
85: 83:     pub fn get(&self) -> Option<OwnedElementOrVirtual> {
86: 84:         match self {
87: 85:             VirtualElementOrNodeRef::VirtualElement(virtual_element) => {
88: 86:                 Some((**virtual_element).clone().into())
89: 87:             }
90: 88:             VirtualElementOrNodeRef::NodeRef(node_ref) => node_ref
91: 89:                 .get()
92: 90:                 .and_then(|element| element.dyn_into::<web_sys::Element>().ok())
93: 91:                 .map(|element| element.into()),
94: 92:         }
95: 93:     }
96: 94: 
97: 95:     pub fn get_untracked(&self) -> Option<OwnedElementOrVirtual> {
98: 96:         match self {
99: 97:             VirtualElementOrNodeRef::VirtualElement(virtual_element) => {
100: 98:                 Some((**virtual_element).clone().into())
101: 99:             }
102: 100:             VirtualElementOrNodeRef::NodeRef(node_ref) => node_ref
103: 101:                 .get_untracked()
104: 102:                 .and_then(|element| element.dyn_into::<web_sys::Element>().ok())
105: 103:                 .map(|element| element.into()),
106: 104:         }
107: 105:     }
108: 106: }
109: 107: 
110: 108: // impl<E: ElementType> Clone for VirtualElementOrNodeRef<E> {
111: 109: //     fn clone(&self) -> Self {
112: 110: //         match self {
113: 111: //             Self::VirtualElement(virtual_element) => Self::VirtualElement(virtual_element.clone()),
114: 112: //             Self::NodeRef(node_ref) => Self::NodeRef(*node_ref),
115: 113: //         }
116: 114: //     }
117: 115: // }
118: 116: 
119: 117: impl From<Box<dyn VirtualElement<web_sys::Element>>> for VirtualElementOrNodeRef {
120: 118:     fn from(value: Box<dyn VirtualElement<web_sys::Element>>) -> Self {
121: 119:         VirtualElementOrNodeRef::VirtualElement(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(value))
122: 120:     }
123: 121: }
124: 122: 
125: 123: impl From<AnyNodeRef> for VirtualElementOrNodeRef {
126: 124:     fn from(value: AnyNodeRef) -> Self {
127: 125:         VirtualElementOrNodeRef::NodeRef(value)
128: 126:     }
129: 127: }
130: 128: 
131: 129: #[derive(Clone, Copy)]
132: 130: pub struct Reference(MaybeProp<VirtualElementOrNodeRef>);
133: 131: 
134: 132: impl Deref for Reference {
135: 133:     type Target = MaybeProp<VirtualElementOrNodeRef>;
136: 134: 
137: 135:     fn deref(&self) -> &Self::Target {
138: 136:         &self.0
139: 137:     }
140: 138: }
141: 139: 
142: 140: impl From<MaybeProp<VirtualElementOrNodeRef>> for Reference {
143: 141:     fn from(value: MaybeProp<VirtualElementOrNodeRef>) -> Self {
144: 142:         Reference(value)
145: 143:     }
146: 144: }
147: 145: 
148: 146: impl From<Memo<VirtualElementOrNodeRef>> for Reference {
149: 147:     fn from(value: Memo<VirtualElementOrNodeRef>) -> Self {
150: 148:         Reference(value.into())
151: 149:     }
152: 150: }
153: 151: 
154: 152: impl From<ReadSignal<VirtualElementOrNodeRef>> for Reference {
155: 153:     fn from(value: ReadSignal<VirtualElementOrNodeRef>) -> Self {
156: 154:         Reference(value.into())
157: 155:     }
158: 156: }
159: 157: 
160: 158: impl From<RwSignal<VirtualElementOrNodeRef>> for Reference {
161: 159:     fn from(value: RwSignal<VirtualElementOrNodeRef>) -> Self {
162: 160:         Reference(value.into())
163: 161:     }
164: 162: }
165: 163: 
166: 164: impl From<Signal<VirtualElementOrNodeRef>> for Reference {
167: 165:     fn from(value: Signal<VirtualElementOrNodeRef>) -> Self {
168: 166:         Reference(value.into())
169: 167:     }
170: 168: }
171: 169: 
172: 170: impl From<VirtualElementOrNodeRef> for Reference {
173: 171:     fn from(value: VirtualElementOrNodeRef) -> Self {
174: 172:         Reference(value.into())
175: 173:     }
176: 174: }
177: 175: 
178: 176: impl From<Box<dyn VirtualElement<web_sys::Element>>> for Reference {
179: 177:     fn from(value: Box<dyn VirtualElement<web_sys::Element>>) -> Self {
180: 178:         Reference(VirtualElementOrNodeRef::from(value).into())
181: 179:     }
182: 180: }
183: 181: 
184: 182: impl From<AnyNodeRef> for Reference {
185: 183:     fn from(value: AnyNodeRef) -> Self {
186: 184:         Reference(VirtualElementOrNodeRef::from(value).into())
187: 185:     }
188: 186: }
189: 187: 
190: 188: /// Computes the `x` and `y` coordinates that will place the floating element next to a reference element.
191: 189: pub fn use_floating<R: Into<Reference>>(
192: 190:     reference: R,
193: 191:     floating: AnyNodeRef,
194: 192:     options: UseFloatingOptions,
195: 193: ) -> UseFloatingReturn {
196: 194:     let reference: Reference = reference.into();
197: 195: 
198: 196:     let open_option = Signal::derive(move || options.open.get().unwrap_or(true));
199: 197:     let placement_option_untracked = move || {
200: 198:         options
201: 199:             .placement
202: 200:             .get_untracked()
203: 201:             .unwrap_or(Placement::Bottom)
204: 202:     };
205: 203:     let strategy_option_untracked = move || {
206: 204:         options
207: 205:             .strategy
208: 206:             .get_untracked()
209: 207:             .unwrap_or(Strategy::Absolute)
210: 208:     };
211: 209:     let middleware_option_untracked = move || options.middleware.get_untracked();
212: 210:     let transform_option = move || options.transform.get().unwrap_or(true);
213: 211:     let while_elements_mounted_untracked = move || options.while_elements_mounted.get_untracked();
214: 212: 
215: 213:     let (x, set_x) = signal(0.0);
216: 214:     let (y, set_y) = signal(0.0);
217: 215:     let (strategy, set_strategy) = signal(strategy_option_untracked());
218: 216:     let (placement, set_placement) = signal(placement_option_untracked());
219: 217:     let (middleware_data, set_middleware_data) = signal(MiddlewareData::default());
220: 218:     let (is_positioned, set_is_positioned) = signal(false);
221: 219:     let floating_styles = Memo::new(move |_| {
222: 220:         let initial_styles = FloatingStyles {
223: 221:             position: strategy.get(),
224: 222:             top: "0".to_owned(),
225: 223:             left: "0".to_owned(),
226: 224:             transform: None,
227: 225:             will_change: None,
228: 226:         };
229: 227: 
230: 228:         match floating
231: 229:             .get()
232: 230:             .and_then(|floating| floating.dyn_into::<web_sys::Element>().ok())
233: 231:         {
234: 232:             Some(floating_element) => {
235: 233:                 let x_val = round_by_dpr(&floating_element, x.get());
236: 234:                 let y_val = round_by_dpr(&floating_element, y.get());
237: 235: 
238: 236:                 if transform_option() {
239: 237:                     FloatingStyles {
240: 238:                         transform: Some(format!("translate({x_val}px, {y_val}px)")),
241: 239:                         will_change: (get_dpr(&floating_element) >= 1.5)
242: 240:                             .then_some("transform".to_owned()),
243: 241:                         ..initial_styles
244: 242:                     }
245: 243:                 } else {
246: 244:                     FloatingStyles {
247: 245:                         left: format!("{x_val}px"),
248: 246:                         top: format!("{y_val}px"),
249: 247:                         ..initial_styles
250: 248:                     }
251: 249:                 }
252: 250:             }
253: 251:             _ => initial_styles,
254: 252:         }
255: 253:     });
256: 254: 
257: 255:     let update = Rc::new({
258: 256:         move || {
259: 257:             if let Some(reference) = reference.get_untracked()
260: 258:                 && let Some(reference_element) = reference.get_untracked()
261: 259:                 && let Some(floating_element) = floating
262: 260:                     .get_untracked()
263: 261:                     .and_then(|floating| floating.dyn_into::<web_sys::Element>().ok())
264: 262:             {
265: 263:                 let config = ComputePositionConfig {
266: 264:                     placement: Some(placement_option_untracked()),
267: 265:                     strategy: Some(strategy_option_untracked()),
268: 266:                     middleware: middleware_option_untracked()
269: 267:                         .map(|middleware| middleware.deref().clone()),
270: 268:                 };
271: 269: 
272: 270:                 let open = open_option.get_untracked();
273: 271: 
274: 272:                 let position =
275: 273:                     compute_position((&reference_element).into(), &floating_element, config);
276: 274:                 set_x.set(position.x);
277: 275:                 set_y.set(position.y);
278: 276:                 set_strategy.set(position.strategy);
279: 277:                 set_placement.set(position.placement);
280: 278:                 set_middleware_data.set(position.middleware_data);
281: 279:                 // The floating element's position may be recomputed while it's closed
282: 280:                 // but still mounted (such as when transitioning out). To ensure
283: 281:                 // `is_positioned` will be `false` initially on the next open,
284: 282:                 // avoid setting it to `true` when `open === false` (must be specified).
285: 283:                 set_is_positioned.set(open);
286: 284:             }
287: 285:         }
288: 286:     });
289: 287: 
290: 288:     let while_elements_mounted_cleanup: Arc<
291: 289:         Mutex<Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<WhileElementsMountedCleanupFn>>>,
292: 290:     > = Arc::new(Mutex::new(None));
293: 291: 
294: 292:     let cleanup = Arc::new({
295: 293:         let while_elements_mounted_cleanup = while_elements_mounted_cleanup.clone();
296: 294: 
297: 295:         move || {
298: 296:             if let Some(while_elements_mounted_cleanup) = while_elements_mounted_cleanup
299: 297:                 .lock()
300: 298:                 .expect("Lock should be acquired.")
301: 299:                 .as_ref()
302: 300:             {
303: 301:                 while_elements_mounted_cleanup();
304: 302:             }
305: 303:         }
306: 304:     });
307: 305: 
308: 306:     let attach = Rc::new({
309: 307:         let update = update.clone();
310: 308:         let cleanup = cleanup.clone();
311: 309:         let while_elements_mounted_cleanup = while_elements_mounted_cleanup.clone();
312: 310: 
313: 311:         move || {
314: 312:             cleanup();
315: 313: 
316: 314:             match while_elements_mounted_untracked() {
317: 315:                 Some(while_elements_mounted) => {
318: 316:                     if let Some(reference) = reference.get_untracked()
319: 317:                         && let Some(reference_element) = reference.get_untracked()
320: 318:                         && let Some(floating_element) = floating
321: 319:                             .get_untracked()
322: 320:                             .and_then(|floating| floating.dyn_into::<web_sys::Element>().ok())
323: 321:                     {
324: 322:                         *while_elements_mounted_cleanup
325: 323:                             .lock()
326: 324:                             .expect("Lock should be acquired.") =
327: 325:                             Some(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(while_elements_mounted(
328: 326:                                 (&reference_element).into(),
329: 327:                                 &floating_element,
330: 328:                                 update.clone(),
331: 329:                             )));
332: 330:                     }
333: 331:                 }
334: 332:                 _ => {
335: 333:                     update();
336: 334:                 }
337: 335:             }
338: 336:         }
339: 337:     });
340: 338: 
341: 339:     let reset = move || {
342: 340:         if !open_option.get_untracked() {
343: 341:             set_is_positioned.set(false);
344: 342:         }
345: 343:     };
346: 344: 
347: 345:     Effect::new({
348: 346:         let attach = attach.clone();
349: 347: 
350: 348:         move |_| {
351: 349:             if let Some(reference) = reference.get() {
352: 350:                 match reference {
353: 351:                     VirtualElementOrNodeRef::VirtualElement(_) => {
354: 352:                         attach();
355: 353:                     }
356: 354:                     VirtualElementOrNodeRef::NodeRef(reference) => {
357: 355:                         if reference
358: 356:                             .get()
359: 357:                             .and_then(|reference| reference.dyn_into::<web_sys::Element>().ok())
360: 358:                             .is_some()
361: 359:                         {
362: 360:                             attach();
363: 361:                         }
364: 362:                     }
365: 363:                 }
366: 364:             }
367: 365:         }
368: 366:     });
369: 367: 
370: 368:     Effect::new({
371: 369:         let attach = attach.clone();
372: 370: 
373: 371:         move |_| {
374: 372:             if floating
375: 373:                 .get()
376: 374:                 .and_then(|floating| floating.dyn_into::<web_sys::Element>().ok())
377: 375:                 .is_some()
378: 376:             {
379: 377:                 attach();
380: 378:             }
381: 379:         }
382: 380:     });
383: 381: 
384: 382:     Effect::new(move |_| {
385: 383:         reset();
386: 384:     });
387: 385: 
388: 386:     _ = Effect::watch(
389: 387:         move || open_option.get(),
390: 388:         {
391: 389:             let update = update.clone();
392: 390: 
393: 391:             move |_, _, _| {
394: 392:                 update();
395: 393:             }
396: 394:         },
397: 395:         false,
398: 396:     );
399: 397:     _ = Effect::watch(
400: 398:         move || options.placement.get(),
401: 399:         {
402: 400:             let update = update.clone();
403: 401: 
404: 402:             move |_, _, _| {
405: 403:                 update();
406: 404:             }
407: 405:         },
408: 406:         false,
409: 407:     );
410: 408:     _ = Effect::watch(
411: 409:         move || options.strategy.get(),
412: 410:         {
413: 411:             let update = update.clone();
414: 412: 
415: 413:             move |_, _, _| {
416: 414:                 update();
417: 415:             }
418: 416:         },
419: 417:         false,
420: 418:     );
421: 419:     _ = Effect::watch(
422: 420:         move || options.middleware.get(),
423: 421:         {
424: 422:             let update = update.clone();
425: 423: 
426: 424:             move |_, _, _| {
427: 425:                 update();
428: 426:             }
429: 427:         },
430: 428:         false,
431: 429:     );
432: 430:     _ = Effect::watch(
433: 431:         move || options.while_elements_mounted.get(),
434: 432:         move |_, _, _| {
435: 433:             attach();
436: 434:         },
437: 435:         false,
438: 436:     );
439: 437: 
440: 438:     on_cleanup(move || {
441: 439:         cleanup();
442: 440:     });
443: 441: 
444: 442:     UseFloatingReturn {
445: 443:         x: x.into(),
446: 444:         y: y.into(),
447: 445:         placement: placement.into(),
448: 446:         strategy: strategy.into(),
449: 447:         middleware_data: middleware_data.into(),
450: 448:         is_positioned: is_positioned.into(),
451: 449:         floating_styles: floating_styles.into(),
452: 450:         update: SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(update.clone()),
453: 451:     }
454: 452: }
455: 453: 
456: 454: #[cfg(target_arch = "wasm32")]
457: 455: #[cfg(test)]
458: 456: mod tests {
459: 457:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
460: 458:     use lyx-core-lyx_core_lyx-core-lyx_core_leptos_node_ref::AnyNodeRef;
461: 459:     use wasm_bindgen_test::*;
462: 460: 
463: 461:     use super::*;
464: 462: 
465: 463:     wasm_bindgen_test_configure!(run_in_browser);
466: 464: 
467: 465:     #[wasm_bindgen_test]
468: 466:     fn updates_is_positioned_when_position_is_computed() {
469: 467:         #[component]
470: 468:         fn Component() -> impl IntoView {
471: 469:             let reference = AnyNodeRef::new();
472: 470:             let floating = AnyNodeRef::new();
473: 471:             let UseFloatingReturn { is_positioned, .. } =
474: 472:                 use_floating(reference, floating, UseFloatingOptions::default());
475: 473: 
476: 474:             view! {
477: 475:                 <div node_ref=reference />
478: 476:                 <div node_ref=floating />
479: 477:                 <div id="test-is-positioned">{is_positioned}</div>
480: 478:             }
481: 479:         }
482: 480: 
483: 481:         mount_to_body(Component);
484: 482: 
485: 483:         // assert_eq!(
486: 484:         //     document
487: 485:         //         .get_element_by_id("test-is-positioned")
488: 486:         //         .and_then(|element| element.text_content()),
489: 487:         //     Some("true".to_owned())
490: 488:         // );
491: 489:     }
492: 490: }
493: 491: ```
494: 492: ```
495: 493: ```
496: 494: ```
497: 495: ```
498: 496: ```
499: 497: ```
500: 498: ```
501: 499: ```
502: 500: ```
503: 501: ```
504: 502: ```
505: 503: ```
506: 504: ```
507: 505: ```
508: 506: ```
509: 507: ```
510: 508: ```
511: 509: ```
512: 510: ```
513: ```
```

