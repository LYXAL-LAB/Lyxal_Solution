### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\event.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\event.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::attribute::{
21: 19:         maybe_next_attr_erasure_macros::next_attr_combine, Attribute,
22: 20:         NamedAttributeKey,
23: 21:     },
24: 22:     renderer::{CastFrom, RemoveEventHandler, Rndr},
25: 23:     view::{Position, ToTemplate},
26: 24: };
27: 25: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
28: 26: use std::{
29: 27:     borrow::Cow,
30: 28:     cell::RefCell,
31: 29:     fmt::Debug,
32: 30:     marker::PhantomData,
33: 31:     ops::{Deref, DerefMut},
34: 32:     rc::Rc,
35: 33: };
36: 34: use wasm_bindgen::convert::FromWasmAbi;
37: 35: 
38: 36: /// A cloneable event callback.
39: 37: pub type SharedEventCallback<E> = Rc<RefCell<dyn FnMut(E)>>;
40: 38: 
41: 39: /// A function that can be called in response to an event.
42: 40: pub trait EventCallback<E>: 'static {
43: 41:     /// Runs the event handler.
44: 42:     fn invoke(&mut self, event: E);
45: 43: 
46: 44:     /// Converts this into a cloneable/shared event handler.
47: 45:     fn into_shared(self) -> SharedEventCallback<E>;
48: 46: }
49: 47: 
50: 48: impl<E: 'static> EventCallback<E> for SharedEventCallback<E> {
51: 49:     fn invoke(&mut self, event: E) {
52: 50:         let mut fun = self.borrow_mut();
53: 51:         fun(event)
54: 52:     }
55: 53: 
56: 54:     fn into_shared(self) -> SharedEventCallback<E> {
57: 55:         self
58: 56:     }
59: 57: }
60: 58: 
61: 59: impl<F, E> EventCallback<E> for F
62: 60: where
63: 61:     F: FnMut(E) + 'static,
64: 62: {
65: 63:     fn invoke(&mut self, event: E) {
66: 64:         self(event)
67: 65:     }
68: 66: 
69: 67:     fn into_shared(self) -> SharedEventCallback<E> {
70: 68:         Rc::new(RefCell::new(self))
71: 69:     }
72: 70: }
73: 71: 
74: 72: /// An event listener with a typed event target.
75: 73: pub struct Targeted<E, T> {
76: 74:     event: E,
77: 75:     el_ty: PhantomData<T>,
78: 76: }
79: 77: 
80: 78: impl<E, T> Targeted<E, T> {
81: 79:     /// Returns the inner event.
82: 80:     pub fn into_inner(self) -> E {
83: 81:         self.event
84: 82:     }
85: 83: 
86: 84:     /// Returns the event's target, as an HTML element of the correct type.
87: 85:     pub fn target(&self) -> T
88: 86:     where
89: 87:         T: CastFrom<crate::renderer::types::Element>,
90: 88: 
91: 89:         crate::renderer::types::Event: From<E>,
92: 90:         E: Clone,
93: 91:     {
94: 92:         let ev = crate::renderer::types::Event::from(self.event.clone());
95: 93:         Rndr::event_target(&ev)
96: 94:     }
97: 95: }
98: 96: 
99: 97: impl<E, T> Deref for Targeted<E, T> {
100: 98:     type Target = E;
101: 99: 
102: 100:     fn deref(&self) -> &Self::Target {
103: 101:         &self.event
104: 102:     }
105: 103: }
106: 104: 
107: 105: impl<E, T> DerefMut for Targeted<E, T> {
108: 106:     fn deref_mut(&mut self) -> &mut Self::Target {
109: 107:         &mut self.event
110: 108:     }
111: 109: }
112: 110: 
113: 111: impl<E, T> From<E> for Targeted<E, T> {
114: 112:     fn from(event: E) -> Self {
115: 113:         Targeted {
116: 114:             event,
117: 115:             el_ty: PhantomData,
118: 116:         }
119: 117:     }
120: 118: }
121: 119: 
122: 120: /// Creates an [`Attribute`] that will add an event listener to an element.
123: 121: pub fn on<E, F>(event: E, cb: F) -> On<E, F>
124: 122: where
125: 123:     F: FnMut(E::EventType) + 'static,
126: 124:     E: EventDescriptor + Send + 'static,
127: 125:     E::EventType: 'static,
128: 126:     E::EventType: From<crate::renderer::types::Event>,
129: 127: {
130: 128:     On {
131: 129:         event,
132: 130:         #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
133: 131:         owner: lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::current().unwrap_or_default(),
134: 132:         cb: (!cfg!(feature = "ssr")).then(|| SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(cb)),
135: 133:     }
136: 134: }
137: 135: 
138: 136: /// Creates an [`Attribute`] that will add an event listener with a typed target to an element.
139: 137: #[allow(clippy::type_complexity)]
140: 138: pub fn on_target<E, T, F>(
141: 139:     event: E,
142: 140:     mut cb: F,
143: 141: ) -> On<E, Box<dyn FnMut(E::EventType)>>
144: 142: where
145: 143:     T: HasElementType,
146: 144:     F: FnMut(Targeted<E::EventType, <T as HasElementType>::ElementType>)
147: 145:         + 'static,
148: 146:     E: EventDescriptor + Send + 'static,
149: 147:     E::EventType: 'static,
150: 148: 
151: 149:     E::EventType: From<crate::renderer::types::Event>,
152: 150: {
153: 151:     on(event, Box::new(move |ev: E::EventType| cb(ev.into())))
154: 152: }
155: 153: 
156: 154: /// An [`Attribute`] that adds an event listener to an element.
157: 155: pub struct On<E, F> {
158: 156:     event: E,
159: 157:     #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
160: 158:     owner: lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner,
161: 159:     cb: Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<F>>,
162: 160: }
163: 161: 
164: 162: impl<E, F> Clone for On<E, F>
165: 163: where
166: 164:     E: Clone,
167: 165:     F: Clone,
168: 166: {
169: 167:     fn clone(&self) -> Self {
170: 168:         Self {
171: 169:             event: self.event.clone(),
172: 170:             #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
173: 171:             owner: self.owner.clone(),
174: 172:             cb: self.cb.clone(),
175: 173:         }
176: 174:     }
177: 175: }
178: 176: 
179: 177: impl<E, F> On<E, F>
180: 178: where
181: 179:     F: EventCallback<E::EventType>,
182: 180:     E: EventDescriptor + Send + 'static,
183: 181:     E::EventType: 'static,
184: 182:     E::EventType: From<crate::renderer::types::Event>,
185: 183: {
186: 184:     /// Attaches the event listener to the element.
187: 185:     pub fn attach(
188: 186:         self,
189: 187:         el: &crate::renderer::types::Element,
190: 188:     ) -> RemoveEventHandler<crate::renderer::types::Element> {
191: 189:         fn attach_inner(
192: 190:             el: &crate::renderer::types::Element,
193: 191:             cb: Box<dyn FnMut(crate::renderer::types::Event)>,
194: 192:             name: Cow<'static, str>,
195: 193:             // TODO investigate: does passing this as an option
196: 194:             // (rather than, say, having a const DELEGATED: bool)
197: 195:             // add to binary size?
198: 196:             delegation_key: Option<Cow<'static, str>>,
199: 197:         ) -> RemoveEventHandler<crate::renderer::types::Element> {
200: 198:             match delegation_key {
201: 199:                 None => Rndr::add_event_listener(el, &name, cb),
202: 200:                 Some(key) => {
203: 201:                     Rndr::add_event_listener_delegated(el, name, key, cb)
204: 202:                 }
205: 203:             }
206: 204:         }
207: 205: 
208: 206:         let mut cb = self.cb.expect("callback removed before attaching").take();
209: 207: 
210: 208:         #[cfg(feature = "tracing")]
211: 209:         let span = tracing::Span::current();
212: 210: 
213: 211:         let cb = Box::new(move |ev: crate::renderer::types::Event| {
214: 212:             #[cfg(all(debug_assertions, feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph"))]
215: 213:             let _rx_guard =
216: 214:                 lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
217: 215:             #[cfg(feature = "tracing")]
218: 216:             let _tracing_guard = span.enter();
219: 217: 
220: 218:             let ev = E::EventType::from(ev);
221: 219: 
222: 220:             #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
223: 221:             self.owner.with(|| cb.invoke(ev));
224: 222:             #[cfg(not(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph"))]
225: 223:             cb.invoke(ev);
226: 224:         }) as Box<dyn FnMut(crate::renderer::types::Event)>;
227: 225: 
228: 226:         attach_inner(
229: 227:             el,
230: 228:             cb,
231: 229:             self.event.name(),
232: 230:             (E::BUBBLES && cfg!(feature = "delegation"))
233: 231:                 .then(|| self.event.event_delegation_key()),
234: 232:         )
235: 233:     }
236: 234: 
237: 235:     /// Attaches the event listener to the element as a listener that is triggered during the capture phase,
238: 236:     /// meaning it will fire before any event listeners further down in the DOM.
239: 237:     pub fn attach_capture(
240: 238:         self,
241: 239:         el: &crate::renderer::types::Element,
242: 240:     ) -> RemoveEventHandler<crate::renderer::types::Element> {
243: 241:         fn attach_inner(
244: 242:             el: &crate::renderer::types::Element,
245: 243:             cb: Box<dyn FnMut(crate::renderer::types::Event)>,
246: 244:             name: Cow<'static, str>,
247: 245:         ) -> RemoveEventHandler<crate::renderer::types::Element> {
248: 246:             Rndr::add_event_listener_use_capture(el, &name, cb)
249: 247:         }
250: 248: 
251: 249:         let mut cb = self.cb.expect("callback removed before attaching").take();
252: 250: 
253: 251:         #[cfg(feature = "tracing")]
254: 252:         let span = tracing::Span::current();
255: 253: 
256: 254:         let cb = Box::new(move |ev: crate::renderer::types::Event| {
257: 255:             #[cfg(all(debug_assertions, feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph"))]
258: 256:             let _rx_guard =
259: 257:                 lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::diagnostics::SpecialNonReactiveZone::enter();
260: 258:             #[cfg(feature = "tracing")]
261: 259:             let _tracing_guard = span.enter();
262: 260: 
263: 261:             let ev = E::EventType::from(ev);
264: 262: 
265: 263:             #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
266: 264:             self.owner.with(|| cb.invoke(ev));
267: 265:             #[cfg(not(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph"))]
268: 266:             cb.invoke(ev);
269: 267:         }) as Box<dyn FnMut(crate::renderer::types::Event)>;
270: 268: 
271: 269:         attach_inner(el, cb, self.event.name())
272: 270:     }
273: 271: }
274: 272: 
275: 273: impl<E, F> Debug for On<E, F>
276: 274: where
277: 275:     E: Debug,
278: 276: {
279: 277:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
280: 278:         f.debug_tuple("On").field(&self.event).finish()
281: 279:     }
282: 280: }
283: 281: 
284: 282: impl<E, F> Attribute for On<E, F>
285: 283: where
286: 284:     F: EventCallback<E::EventType>,
287: 285:     E: EventDescriptor + Send + 'static,
288: 286:     E::EventType: 'static,
289: 287: 
290: 288:     E::EventType: From<crate::renderer::types::Event>,
291: 289: {
292: 290:     const MIN_LENGTH: usize = 0;
293: 291:     type AsyncOutput = Self;
294: 292:     // a function that can be called once to remove the event listener
295: 293:     type State = (
296: 294:         crate::renderer::types::Element,
297: 295:         Option<RemoveEventHandler<crate::renderer::types::Element>>,
298: 296:     );
299: 297:     type Cloneable = On<E, SharedEventCallback<E::EventType>>;
300: 298:     type CloneableOwned = On<E, SharedEventCallback<E::EventType>>;
301: 299: 
302: 300:     #[inline(always)]
303: 301:     fn html_len(&self) -> usize {
304: 302:         0
305: 303:     }
306: 304: 
307: 305:     #[inline(always)]
308: 306:     fn to_html(
309: 307:         self,
310: 308:         _buf: &mut String,
311: 309:         _class: &mut String,
312: 310:         _style: &mut String,
313: 311:         _inner_html: &mut String,
314: 312:     ) {
315: 313:     }
316: 314: 
317: 315:     #[inline(always)]
318: 316:     fn hydrate<const FROM_SERVER: bool>(
319: 317:         self,
320: 318:         el: &crate::renderer::types::Element,
321: 319:     ) -> Self::State {
322: 320:         let cleanup = if E::CAPTURE {
323: 321:             self.attach_capture(el)
324: 322:         } else {
325: 323:             self.attach(el)
326: 324:         };
327: 325:         (el.clone(), Some(cleanup))
328: 326:     }
329: 327: 
330: 328:     #[inline(always)]
331: 329:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
332: 330:         let cleanup = if E::CAPTURE {
333: 331:             self.attach_capture(el)
334: 332:         } else {
335: 333:             self.attach(el)
336: 334:         };
337: 335:         (el.clone(), Some(cleanup))
338: 336:     }
339: 337: 
340: 338:     #[inline(always)]
341: 339:     fn rebuild(self, state: &mut Self::State) {
342: 340:         let (el, prev_cleanup) = state;
343: 341:         if let Some(prev) = prev_cleanup.take() {
344: 342:             if let Some(remove) = prev.into_inner() {
345: 343:                 remove();
346: 344:             }
347: 345:         }
348: 346:         *prev_cleanup = Some(if E::CAPTURE {
349: 347:             self.attach_capture(el)
350: 348:         } else {
351: 349:             self.attach(el)
352: 350:         });
353: 351:     }
354: 352: 
355: 353:     fn into_cloneable(self) -> Self::Cloneable {
356: 354:         On {
357: 355:             cb: self.cb.map(|cb| SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(cb.take().into_shared())),
358: 356:             #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
359: 357:             owner: self.owner,
360: 358:             event: self.event,
361: 359:         }
362: 360:     }
363: 361: 
364: 362:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
365: 363:         On {
366: 364:             cb: self.cb.map(|cb| SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(cb.take().into_shared())),
367: 365:             #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
368: 366:             owner: self.owner,
369: 367:             event: self.event,
370: 368:         }
371: 369:     }
372: 370: 
373: 371:     fn dry_resolve(&mut self) {}
374: 372: 
375: 373:     async fn resolve(self) -> Self::AsyncOutput {
376: 374:         self
377: 375:     }
378: 376: 
379: 377:     fn keys(&self) -> Vec<NamedAttributeKey> {
380: 378:         vec![]
381: 379:     }
382: 380: }
383: 381: 
384: 382: impl<E, F> NextAttribute for On<E, F>
385: 383: where
386: 384:     F: EventCallback<E::EventType>,
387: 385:     E: EventDescriptor + Send + 'static,
388: 386:     E::EventType: 'static,
389: 387: 
390: 388:     E::EventType: From<crate::renderer::types::Event>,
391: 389: {
392: 390:     next_attr_output_type!(Self, NewAttr);
393: 391: 
394: 392:     fn add_any_attr<NewAttr: Attribute>(
395: 393:         self,
396: 394:         new_attr: NewAttr,
397: 395:     ) -> Self::Output<NewAttr> {
398: 396:         next_attr_combine!(self, new_attr)
399: 397:     }
400: 398: }
401: 399: 
402: 400: impl<E, F> ToTemplate for On<E, F> {
403: 401:     #[inline(always)]
404: 402:     fn to_template(
405: 403:         _buf: &mut String,
406: 404:         _class: &mut String,
407: 405:         _style: &mut String,
408: 406:         _inner_html: &mut String,
409: 407:         _position: &mut Position,
410: 408:     ) {
411: 409:     }
412: 410: }
413: 411: 
414: 412: /// A trait for converting types into [web_sys events](web_sys).
415: 413: pub trait EventDescriptor: Clone {
416: 414:     /// The [`web_sys`] event type, such as [`web_sys::MouseEvent`].
417: 415:     type EventType: FromWasmAbi;
418: 416: 
419: 417:     /// Indicates if this event bubbles. For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, `click` bubbles,
420: 418:     /// but `focus` does not.
421: 419:     ///
422: 420:     /// If this is true, then the event will be delegated globally if the `delegation`
423: 421:     /// feature is enabled. Otherwise, event listeners will be directly attached to the element.
424: 422:     const BUBBLES: bool;
425: 423: 
426: 424:     /// Indicates if this event should be handled during the capture phase.
427: 425:     const CAPTURE: bool = false;
428: 426: 
429: 427:     /// The name of the event, such as `click` or `mouseover`.
430: 428:     fn name(&self) -> Cow<'static, str>;
431: 429: 
432: 430:     /// The key used for event delegation.
433: 431:     fn event_delegation_key(&self) -> Cow<'static, str>;
434: 432: 
435: 433:     /// Return the options for this type. This is only used when you create a [`Custom`] event
436: 434:     /// handler.
437: 435:     #[inline(always)]
438: 436:     fn options(&self) -> Option<&web_sys::AddEventListenerOptions> {
439: 437:         None
440: 438:     }
441: 439: }
442: 440: 
443: 441: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper that tells the framework to handle an event during the capture phase.
444: 442: #[derive(Debug, Clone, PartialEq, Eq)]
445: 443: pub struct Capture<E> {
446: 444:     inner: E,
447: 445: }
448: 446: 
449: 447: /// Wraps an event to indicate that it should be handled during the capture phase.
450: 448: pub fn capture<E>(event: E) -> Capture<E> {
451: 449:     Capture { inner: event }
452: 450: }
453: 451: 
454: 452: impl<E: EventDescriptor> EventDescriptor for Capture<E> {
455: 453:     type EventType = E::EventType;
456: 454: 
457: 455:     const CAPTURE: bool = true;
458: 456:     const BUBBLES: bool = E::BUBBLES;
459: 457: 
460: 458:     fn name(&self) -> Cow<'static, str> {
461: 459:         self.inner.name()
462: 460:     }
463: 461: 
464: 462:     fn event_delegation_key(&self) -> Cow<'static, str> {
465: 463:         self.inner.event_delegation_key()
466: 464:     }
467: 465: }
468: 466: 
469: 467: /// A custom event.
470: 468: #[derive(Debug)]
471: 469: pub struct Custom<E: FromWasmAbi = web_sys::Event> {
472: 470:     name: Cow<'static, str>,
473: 471:     options: Option<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<web_sys::AddEventListenerOptions>>,
474: 472:     _event_type: PhantomData<fn() -> E>,
475: 473: }
476: 474: 
477: 475: impl<E: FromWasmAbi> Clone for Custom<E> {
478: 476:     fn clone(&self) -> Self {
479: 477:         Self {
480: 478:             name: self.name.clone(),
481: 479:             options: self.options.clone(),
482: 480:             _event_type: PhantomData,
483: 481:         }
484: 482:     }
485: 483: }
486: 484: 
487: 485: impl<E: FromWasmAbi> EventDescriptor for Custom<E> {
488: 486:     type EventType = E;
489: 487: 
490: 488:     fn name(&self) -> Cow<'static, str> {
491: 489:         self.name.clone()
492: 490:     }
493: 491: 
494: 492:     fn event_delegation_key(&self) -> Cow<'static, str> {
495: 493:         format!("$$${}", self.name).into()
496: 494:     }
497: 495: 
498: 496:     const BUBBLES: bool = false;
499: 497: 
500: 498:     #[inline(always)]
501: 499:     fn options(&self) -> Option<&web_sys::AddEventListenerOptions> {
502: 500:         self.options.as_deref()
503: 501:     }
504: 502: }
505: 503: 
506: 504: impl<E: FromWasmAbi> Custom<E> {
507: 505:     /// Creates a custom event type that can be used within
508: 506:     /// [`OnAttribute::on`](crate::prelude::OnAttribute::on), for events
509: 507:     /// which are not covered in the [`ev`](crate::html::event) module.
510: 508:     pub fn new(name: impl Into<Cow<'static, str>>) -> Self {
511: 509:         Self {
512: 510:             name: name.into(),
513: 511:             options: None,
514: 512:             _event_type: PhantomData,
515: 513:         }
516: 514:     }
517: 515: 
518: 516:     /// Modify the [`AddEventListenerOptions`] used for this event listener.
519: 517:     ///
520: 518:     /// ```rust
521: 519:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_tachys::prelude::*;
522: 520:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html;
523: 521:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::event as ev;
524: 522:     /// # fn custom_event() -> impl Render {
525: 523:     /// let mut non_passive_wheel = ev::Custom::new("wheel");
526: 524:     /// non_passive_wheel.options_mut().set_passive(false);
527: 525:     ///
528: 526:     /// let canvas =
529: 527:     ///     html::element::canvas().on(non_passive_wheel, |e: ev::WheelEvent| {
530: 528:     ///         // handle event
531: 529:     ///     });
532: 530:     /// # canvas
533: 531:     /// # }
534: 532:     /// ```
535: 533:     ///
536: 534:     /// [`AddEventListenerOptions`]: web_sys::AddEventListenerOptions
537: 535:     pub fn options_mut(&mut self) -> &mut web_sys::AddEventListenerOptions {
538: 536:         // It is valid to construct a `SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper` here because
539: 537:         // its inner data will only be accessed in the browser's main thread.
540: 538:         self.options.get_or_insert_with(|| {
541: 539:             SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(web_sys::AddEventListenerOptions::new())
542: 540:         })
543: 541:     }
544: 542: }
545: 543: 
546: 544: macro_rules! generate_event_types {
547: 545:   {$(
548: 546:     $( #[$does_not_bubble:ident] )?
549: 547:     $( $event:ident )+ : $web_event:ident
550: 548:   ),* $(,)?} => {
551: 549:     ::paste::paste! {
552: 550:       $(
553: 551:         #[doc = "The `" [< $($event)+ >] "` event, which receives [" $web_event "](web_sys::" $web_event ") as its argument."]
554: 552:         #[derive(Copy, Clone, Debug)]
555: 553:         #[allow(non_camel_case_types)]
556: 554:         pub struct [<$( $event )+ >];
557: 555: 
558: 556:         impl EventDescriptor for [< $($event)+ >] {
559: 557:           type EventType = web_sys::$web_event;
560: 558: 
561: 559:           #[inline(always)]
562: 560:           fn name(&self) -> Cow<'static, str> {
563: 561:             stringify!([< $($event)+ >]).into()
564: 562:           }
565: 563: 
566: 564:           #[inline(always)]
567: 565:           fn event_delegation_key(&self) -> Cow<'static, str> {
568: 566:             concat!("$$$", stringify!([< $($event)+ >])).into()
569: 567:           }
570: 568: 
571: 569:           const BUBBLES: bool = true $(&& generate_event_types!($does_not_bubble))?;
572: 570:         }
573: 571:       )*
574: 572:     }
575: 573:   };
576: 574: 
577: 575:   (does_not_bubble) => { false }
578: 576: }
579: 577: 
580: 578: generate_event_types! {
581: 579:   // =========================================================
582: 580:   // WindowEventHandlersEventMap
583: 581:   // =========================================================
584: 582:   #[does_not_bubble]
585: 583:   after print: Event,
586: 584:   #[does_not_bubble]
587: 585:   before print: Event,
588: 586:   #[does_not_bubble]
589: 587:   before unload: BeforeUnloadEvent,
590: 588:   #[does_not_bubble]
591: 589:   gamepad connected: GamepadEvent,
592: 590:   #[does_not_bubble]
593: 591:   gamepad disconnected: GamepadEvent,
594: 592:   hash change: HashChangeEvent,
595: 593:   #[does_not_bubble]
596: 594:   language change: Event,
597: 595:   #[does_not_bubble]
598: 596:   message: MessageEvent,
599: 597:   #[does_not_bubble]
600: 598:   message error: MessageEvent,
601: 599:   #[does_not_bubble]
602: 600:   offline: Event,
603: 601:   #[does_not_bubble]
604: 602:   online: Event,
605: 603:   #[does_not_bubble]
606: 604:   page hide: PageTransitionEvent,
607: 605:   #[does_not_bubble]
608: 606:   page show: PageTransitionEvent,
609: 607:   pop state: PopStateEvent,
610: 608:   rejection handled: PromiseRejectionEvent,
611: 609:   #[does_not_bubble]
612: 610:   storage: StorageEvent,
613: 611:   #[does_not_bubble]
614: 612:   unhandled rejection: PromiseRejectionEvent,
615: 613:   #[does_not_bubble]
616: 614:   unload: Event,
617: 615: 
618: 616:   // =========================================================
619: 617:   // GlobalEventHandlersEventMap
620: 618:   // =========================================================
621: 619:   #[does_not_bubble]
622: 620:   abort: UiEvent,
623: 621:   animation cancel: AnimationEvent,
624: 622:   animation end: AnimationEvent,
625: 623:   animation iteration: AnimationEvent,
626: 624:   animation start: AnimationEvent,
627: 625:   aux click: MouseEvent,
628: 626:   before input: InputEvent,
629: 627:   before toggle: Event, // web_sys does not include `ToggleEvent`
630: 628:   #[does_not_bubble]
631: 629:   blur: FocusEvent,
632: 630:   #[does_not_bubble]
633: 631:   can play: Event,
634: 632:   #[does_not_bubble]
635: 633:   can play through: Event,
636: 634:   change: Event,
637: 635:   click: MouseEvent,
638: 636:   #[does_not_bubble]
639: 637:   close: Event,
640: 638:   composition end: CompositionEvent,
641: 639:   composition start: CompositionEvent,
642: 640:   composition update: CompositionEvent,
643: 641:   context menu: MouseEvent,
644: 642:   #[does_not_bubble]
645: 643:   cue change: Event,
646: 644:   dbl click: MouseEvent,
647: 645:   drag: DragEvent,
648: 646:   drag end: DragEvent,
649: 647:   drag enter: DragEvent,
650: 648:   drag leave: DragEvent,
651: 649:   drag over: DragEvent,
652: 650:   drag start: DragEvent,
653: 651:   drop: DragEvent,
654: 652:   #[does_not_bubble]
655: 653:   duration change: Event,
656: 654:   #[does_not_bubble]
657: 655:   emptied: Event,
658: 656:   #[does_not_bubble]
659: 657:   ended: Event,
660: 658:   #[does_not_bubble]
661: 659:   error: ErrorEvent,
662: 660:   #[does_not_bubble]
663: 661:   focus: FocusEvent,
664: 662:   #[does_not_bubble]
665: 663:   focus in: FocusEvent,
666: 664:   #[does_not_bubble]
667: 665:   focus out: FocusEvent,
668: 666:   form data: Event, // web_sys does not include `FormDataEvent`
669: 667:   #[does_not_bubble]
670: 668:   got pointer capture: PointerEvent,
671: 669:   input: Event,
672: 670:   #[does_not_bubble]
673: 671:   invalid: Event,
674: 672:   key down: KeyboardEvent,
675: 673:   key press: KeyboardEvent,
676: 674:   key up: KeyboardEvent,
677: 675:   #[does_not_bubble]
678: 676:   load: Event,
679: 677:   #[does_not_bubble]
680: 678:   loaded data: Event,
681: 679:   #[does_not_bubble]
682: 680:   loaded metadata: Event,
683: 681:   #[does_not_bubble]
684: 682:   load start: Event,
685: 683:   lost pointer capture: PointerEvent,
686: 684:   mouse down: MouseEvent,
687: 685:   #[does_not_bubble]
688: 686:   mouse enter: MouseEvent,
689: 687:   #[does_not_bubble]
690: 688:   mouse leave: MouseEvent,
691: 689:   mouse move: MouseEvent,
692: 690:   mouse out: MouseEvent,
693: 691:   mouse over: MouseEvent,
694: 692:   mouse up: MouseEvent,
695: 693:   #[does_not_bubble]
696: 694:   pause: Event,
697: 695:   #[does_not_bubble]
698: 696:   play: Event,
699: 697:   #[does_not_bubble]
700: 698:   playing: Event,
701: 699:   pointer cancel: PointerEvent,
702: 700:   pointer down: PointerEvent,
703: 701:   #[does_not_bubble]
704: 702:   pointer enter: PointerEvent,
705: 703:   #[does_not_bubble]
706: 704:   pointer leave: PointerEvent,
707: 705:   pointer move: PointerEvent,
708: 706:   pointer out: PointerEvent,
709: 707:   pointer over: PointerEvent,
710: 708:   pointer up: PointerEvent,
711: 709:   #[does_not_bubble]
712: 710:   progress: ProgressEvent,
713: 711:   #[does_not_bubble]
714: 712:   rate change: Event,
715: 713:   reset: Event,
716: 714:   #[does_not_bubble]
717: 715:   resize: UiEvent,
718: 716:   #[does_not_bubble]
719: 717:   scroll: Event,
720: 718:   #[does_not_bubble]
721: 719:   scroll end: Event,
722: 720:   security policy violation: SecurityPolicyViolationEvent,
723: 721:   #[does_not_bubble]
724: 722:   seeked: Event,
725: 723:   #[does_not_bubble]
726: 724:   seeking: Event,
727: 725:   select: Event,
728: 726:   #[does_not_bubble]
729: 727:   selection change: Event,
730: 728:   select start: Event,
731: 729:   slot change: Event,
732: 730:   #[does_not_bubble]
733: 731:   stalled: Event,
734: 732:   submit: SubmitEvent,
735: 733:   #[does_not_bubble]
736: 734:   suspend: Event,
737: 735:   #[does_not_bubble]
738: 736:   time update: Event,
739: 737:   #[does_not_bubble]
740: 738:   toggle: Event,
741: 739:   touch cancel: TouchEvent,
742: 740:   touch end: TouchEvent,
743: 741:   touch move: TouchEvent,
744: 742:   touch start: TouchEvent,
745: 743:   transition cancel: TransitionEvent,
746: 744:   transition end: TransitionEvent,
747: 745:   transition run: TransitionEvent,
748: 746:   transition start: TransitionEvent,
749: 747:   #[does_not_bubble]
750: 748:   volume change: Event,
751: 749:   #[does_not_bubble]
752: 750:   waiting: Event,
753: 751:   webkit animation end: Event,
754: 752:   webkit animation iteration: Event,
755: 753:   webkit animation start: Event,
756: 754:   webkit transition end: Event,
757: 755:   wheel: WheelEvent,
758: 756: 
759: 757:   // =========================================================
760: 758:   // WindowEventMap
761: 759:   // =========================================================
762: 760:   D O M Content Loaded: Event, // Hack for correct casing
763: 761:   #[does_not_bubble]
764: 762:   device motion: DeviceMotionEvent,
765: 763:   #[does_not_bubble]
766: 764:   device orientation: DeviceOrientationEvent,
767: 765:   #[does_not_bubble]
768: 766:   orientation change: Event,
769: 767: 
770: 768:   // =========================================================
771: 769:   // DocumentAndElementEventHandlersEventMap
772: 770:   // =========================================================
773: 771:   copy: ClipboardEvent,
774: 772:   cut: ClipboardEvent,
775: 773:   paste: ClipboardEvent,
776: 774: 
777: 775:   // =========================================================
778: 776:   // DocumentEventMap
779: 777:   // =========================================================
780: 778:   fullscreen change: Event,
781: 779:   fullscreen error: Event,
782: 780:   pointer lock change: Event,
783: 781:   pointer lock error: Event,
784: 782:   #[does_not_bubble]
785: 783:   ready state change: Event,
786: 784:   visibility change: Event,
787: 785: }
788: 786: 
789: 787: // Export `web_sys` event types
790: 788: use super::{
791: 789:     attribute::{
792: 790:         maybe_next_attr_erasure_macros::next_attr_output_type, NextAttribute,
793: 791:     },
794: 792:     element::HasElementType,
795: 793: };
796: 794: #[doc(no_inline)]
797: 795: pub use web_sys::{
798: 796:     AnimationEvent, BeforeUnloadEvent, ClipboardEvent, CompositionEvent,
799: 797:     CustomEvent, DeviceMotionEvent, DeviceOrientationEvent, DragEvent,
800: 798:     ErrorEvent, Event, FocusEvent, GamepadEvent, HashChangeEvent, InputEvent,
801: 799:     KeyboardEvent, MessageEvent, MouseEvent, PageTransitionEvent, PointerEvent,
802: 800:     PopStateEvent, ProgressEvent, PromiseRejectionEvent,
803: 801:     SecurityPolicyViolationEvent, StorageEvent, SubmitEvent, TouchEvent,
804: 802:     TransitionEvent, UiEvent, WheelEvent,
805: 803: };
806: 804: ```
807: 805: ```
808: 806: ```
809: 807: ```
810: 808: ```
811: 809: ```
812: 810: ```
813: 811: ```
814: ```
```
