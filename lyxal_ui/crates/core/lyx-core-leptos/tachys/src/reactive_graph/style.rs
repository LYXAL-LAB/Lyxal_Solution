### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\style.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\style.rs
18: 16: ```rust
19: 17: use super::{ReactiveFunction, SharedReactiveFunction};
20: 18: use crate::{
21: 19:     html::style::{IntoStyle, IntoStyleValue},
22: 20:     renderer::Rndr,
23: 21: };
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::RenderEffect;
25: 23: use std::sync::Arc;
26: 24: 
27: 25: impl<F, S> IntoStyleValue for F
28: 26: where
29: 27:     F: ReactiveFunction<Output = S>,
30: 28:     S: IntoStyleValue + 'static,
31: 29: {
32: 30:     type AsyncOutput = Self;
33: 31:     type State = (Arc<str>, RenderEffect<S::State>);
34: 32:     type Cloneable = SharedReactiveFunction<S>;
35: 33:     type CloneableOwned = SharedReactiveFunction<S>;
36: 34: 
37: 35:     fn to_html(self, name: &str, style: &mut String) {
38: 36:         let mut f = self;
39: 37:         let value = f.invoke();
40: 38:         value.to_html(name, style);
41: 39:     }
42: 40: 
43: 41:     fn build(
44: 42:         mut self,
45: 43:         style: &crate::renderer::dom::CssStyleDeclaration,
46: 44:         name: &str,
47: 45:     ) -> Self::State {
48: 46:         let name: Arc<str> = Rndr::intern(name).into();
49: 47:         let style = style.to_owned();
50: 48:         (
51: 49:             Arc::clone(&name),
52: 50:             RenderEffect::new(move |prev| {
53: 51:                 let value = self.invoke();
54: 52:                 if let Some(mut state) = prev {
55: 53:                     value.rebuild(&style, &name, &mut state);
56: 54:                     state
57: 55:                 } else {
58: 56:                     value.build(&style, &name)
59: 57:                 }
60: 58:             }),
61: 59:         )
62: 60:     }
63: 61: 
64: 62:     fn rebuild(
65: 63:         mut self,
66: 64:         style: &crate::renderer::dom::CssStyleDeclaration,
67: 65:         name: &str,
68: 66:         state: &mut Self::State,
69: 67:     ) {
70: 68:         let (prev_name, prev_effect) = state;
71: 69:         let mut prev_value = prev_effect.take_value();
72: 70:         if name != prev_name.as_ref() {
73: 71:             Rndr::remove_css_property(style, prev_name.as_ref());
74: 72:             prev_value = None;
75: 73:         }
76: 74:         let name: Arc<str> = name.into();
77: 75:         let style = style.to_owned();
78: 76: 
79: 77:         *state = (
80: 78:             Arc::clone(&name),
81: 79:             RenderEffect::new_with_value(
82: 80:                 move |prev| {
83: 81:                     let value = self.invoke();
84: 82:                     if let Some(mut state) = prev {
85: 83:                         value.rebuild(&style, &name, &mut state);
86: 84:                         state
87: 85:                     } else {
88: 86:                         value.build(&style, &name)
89: 87:                     }
90: 88:                 },
91: 89:                 prev_value,
92: 90:             ),
93: 91:         );
94: 92:     }
95: 93: 
96: 94:     fn hydrate(
97: 95:         mut self,
98: 96:         style: &crate::renderer::dom::CssStyleDeclaration,
99: 97:         name: &str,
100: 98:     ) -> Self::State {
101: 99:         let name: Arc<str> = Rndr::intern(name).into();
102: 100:         let style = style.to_owned();
103: 101:         (
104: 102:             Arc::clone(&name),
105: 103:             RenderEffect::new(move |prev| {
106: 104:                 let value = self.invoke();
107: 105:                 if let Some(mut state) = prev {
108: 106:                     value.rebuild(&style, &name, &mut state);
109: 107:                     state
110: 108:                 } else {
111: 109:                     value.hydrate(&style, &name)
112: 110:                 }
113: 111:             }),
114: 112:         )
115: 113:     }
116: 114: 
117: 115:     fn into_cloneable(self) -> Self::Cloneable {
118: 116:         self.into_shared()
119: 117:     }
120: 118: 
121: 119:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
122: 120:         self.into_shared()
123: 121:     }
124: 122: 
125: 123:     fn dry_resolve(&mut self) {
126: 124:         self.invoke();
127: 125:     }
128: 126: 
129: 127:     async fn resolve(self) -> Self::AsyncOutput {
130: 128:         self
131: 129:     }
132: 130: }
133: 131: 
134: 132: impl<F, C> IntoStyle for F
135: 133: where
136: 134:     F: ReactiveFunction<Output = C>,
137: 135:     C: IntoStyle + 'static,
138: 136:     C::State: 'static,
139: 137: {
140: 138:     type AsyncOutput = C::AsyncOutput;
141: 139:     type State = RenderEffect<C::State>;
142: 140:     type Cloneable = SharedReactiveFunction<C>;
143: 141:     type CloneableOwned = SharedReactiveFunction<C>;
144: 142: 
145: 143:     fn to_html(mut self, style: &mut String) {
146: 144:         let value = self.invoke();
147: 145:         value.to_html(style);
148: 146:     }
149: 147: 
150: 148:     fn hydrate<const FROM_SERVER: bool>(
151: 149:         mut self,
152: 150:         el: &crate::renderer::types::Element,
153: 151:     ) -> Self::State {
154: 152:         // TODO FROM_SERVER vs template
155: 153:         let el = el.clone();
156: 154:         RenderEffect::new(move |prev| {
157: 155:             let value = self.invoke();
158: 156:             if let Some(mut state) = prev {
159: 157:                 value.rebuild(&mut state);
160: 158:                 state
161: 159:             } else {
162: 160:                 value.hydrate::<FROM_SERVER>(&el)
163: 161:             }
164: 162:         })
165: 163:     }
166: 164: 
167: 165:     fn build(mut self, el: &crate::renderer::types::Element) -> Self::State {
168: 166:         let el = el.clone();
169: 167:         RenderEffect::new(move |prev| {
170: 168:             let value = self.invoke();
171: 169:             if let Some(mut state) = prev {
172: 170:                 value.rebuild(&mut state);
173: 171:                 state
174: 172:             } else {
175: 173:                 value.build(&el)
176: 174:             }
177: 175:         })
178: 176:     }
179: 177: 
180: 178:     fn rebuild(mut self, state: &mut Self::State) {
181: 179:         let prev_value = state.take_value();
182: 180:         *state = RenderEffect::new_with_value(
183: 181:             move |prev| {
184: 182:                 let value = self.invoke();
185: 183:                 if let Some(mut state) = prev {
186: 184:                     value.rebuild(&mut state);
187: 185:                     state
188: 186:                 } else {
189: 187:                     unreachable!()
190: 188:                 }
191: 189:             },
192: 190:             prev_value,
193: 191:         );
194: 192:     }
195: 193: 
196: 194:     fn into_cloneable(self) -> Self::Cloneable {
197: 195:         self.into_shared()
198: 196:     }
199: 197: 
200: 198:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
201: 199:         self.into_shared()
202: 200:     }
203: 201: 
204: 202:     fn dry_resolve(&mut self) {
205: 203:         self.invoke();
206: 204:     }
207: 205: 
208: 206:     async fn resolve(mut self) -> Self::AsyncOutput {
209: 207:         self.invoke().resolve().await
210: 208:     }
211: 209: 
212: 210:     fn reset(state: &mut Self::State) {
213: 211:         *state = RenderEffect::new_with_value(
214: 212:             move |prev| {
215: 213:                 if let Some(mut state) = prev {
216: 214:                     C::reset(&mut state);
217: 215:                     state
218: 216:                 } else {
219: 217:                     unreachable!()
220: 218:                 }
221: 219:             },
222: 220:             state.take_value(),
223: 221:         );
224: 222:     }
225: 223: }
226: 224: 
227: 225: macro_rules! style_reactive {
228: 226:     ($name:ident, <$($gen:ident),*>, $v:ty, $( $where_clause:tt )*) =>
229: 227:     {
230: 228:         #[allow(deprecated)]
231: 229:         impl<$($gen),*> IntoStyle for $name<$($gen),*>
232: 230:         where
233: 231:             $v: IntoStyle + Clone + Send + Sync + 'static,
234: 232:             <$v as IntoStyle>::State: 'static,
235: 233:             $($where_clause)*
236: 234:         {
237: 235:             type AsyncOutput = Self;
238: 236:             type State = RenderEffect<<$v as IntoStyle>::State>;
239: 237:             type Cloneable = Self;
240: 238:             type CloneableOwned = Self;
241: 239: 
242: 240:             fn to_html(self, style: &mut String) {
243: 241:                 let value = self.get();
244: 242:                 value.to_html(style);
245: 243:             }
246: 244: 
247: 245:             fn hydrate<const FROM_SERVER: bool>(
248: 246:                 self,
249: 247:                 el: &crate::renderer::types::Element,
250: 248:             ) -> Self::State {
251: 249:                 (move || self.get()).hydrate::<FROM_SERVER>(el)
252: 250:             }
253: 251: 
254: 252:             fn build(
255: 253:                 self,
256: 254:                 el: &crate::renderer::types::Element,
257: 255:             ) -> Self::State {
258: 256:                 (move || self.get()).build(el)
259: 257:             }
260: 258: 
261: 259:             fn rebuild(self, state: &mut Self::State) {
262: 260:                 (move || self.get()).rebuild(state)
263: 261:             }
264: 262: 
265: 263:             fn into_cloneable(self) -> Self::Cloneable {
266: 264:                 self
267: 265:             }
268: 266: 
269: 267:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
270: 268:                 self
271: 269:             }
272: 270: 
273: 271:             fn dry_resolve(&mut self) {}
274: 272: 
275: 273:             async fn resolve(self) -> Self::AsyncOutput {
276: 274:                 self
277: 275:             }
278: 276: 
279: 277:             fn reset(state: &mut Self::State) {
280: 278:                 *state = RenderEffect::new_with_value(
281: 279:                     move |prev| {
282: 280:                         if let Some(mut state) = prev {
283: 281:                             <$v>::reset(&mut state);
284: 282:                             state
285: 283:                         } else {
286: 284:                             unreachable!()
287: 285:                         }
288: 286:                     },
289: 287:                     state.take_value(),
290: 288:                 );
291: 289:             }
292: 290:         }
293: 291: 
294: 292:         #[allow(deprecated)]
295: 293:         impl<$($gen),*> IntoStyleValue for $name<$($gen),*>
296: 294:         where
297: 295:             $v: IntoStyleValue + Send + Sync + Clone + 'static,
298: 296:             $($where_clause)*
299: 297:         {
300: 298:             type AsyncOutput = Self;
301: 299:             type State = (Arc<str>, RenderEffect<<$v as IntoStyleValue>::State>);
302: 300:             type Cloneable = $name<$($gen),*>;
303: 301:             type CloneableOwned = $name<$($gen),*>;
304: 302: 
305: 303:             fn to_html(self, name: &str, style: &mut String) {
306: 304:                 IntoStyleValue::to_html(move || self.get(), name, style)
307: 305:             }
308: 306: 
309: 307:             fn build(
310: 308:                 self,
311: 309:                 style: &crate::renderer::dom::CssStyleDeclaration,
312: 310:                 name: &str,
313: 311:             ) -> Self::State {
314: 312:                 IntoStyleValue::build(move || self.get(), style, name)
315: 313:             }
316: 314: 
317: 315:             fn rebuild(
318: 316:                 self,
319: 317:                 style: &crate::renderer::dom::CssStyleDeclaration,
320: 318:                 name: &str,
321: 319:                 state: &mut Self::State,
322: 320:             ) {
323: 321:                 IntoStyleValue::rebuild(
324: 322:                     move || self.get(),
325: 323:                     style,
326: 324:                     name,
327: 325:                     state,
328: 326:                 )
329: 327:             }
330: 328: 
331: 329:             fn hydrate(
332: 330:                 self,
333: 331:                 style: &crate::renderer::dom::CssStyleDeclaration,
334: 332:                 name: &str,
335: 333:             ) -> Self::State {
336: 334:                 IntoStyleValue::hydrate(move || self.get(), style, name)
337: 335:             }
338: 336: 
339: 337:             fn into_cloneable(self) -> Self::Cloneable {
340: 338:                 self
341: 339:             }
342: 340: 
343: 341:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
344: 342:                 self
345: 343:             }
346: 344: 
347: 345:             fn dry_resolve(&mut self) {}
348: 346: 
349: 347:             async fn resolve(self) -> Self::AsyncOutput {
350: 348:                 self
351: 349:             }
352: 350:         }
353: 351:     };
354: 352: }
355: 353: 
356: 354: #[cfg(not(feature = "nightly"))]
357: 355: mod stable {
358: 356:     use super::RenderEffect;
359: 357:     use crate::html::style::{IntoStyle, IntoStyleValue};
360: 358:     #[allow(deprecated)]
361: 359:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::MaybeSignal;
362: 360:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
363: 361:         computed::{ArcMemo, Memo},
364: 362:         owner::Storage,
365: 363:         signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
366: 364:         traits::Get,
367: 365:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{ArcSignal, Signal},
368: 366:     };
369: 367:     use std::sync::Arc;
370: 368: 
371: 369:     style_reactive!(
372: 370:         RwSignal,
373: 371:         <V, S>,
374: 372:         V,
375: 373:         RwSignal<V, S>: Get<Value = V>,
376: 374:         S: Storage<V> + Storage<Option<V>>,
377: 375:         S: Send + Sync + 'static,
378: 376:     );
379: 377:     style_reactive!(
380: 378:         ReadSignal,
381: 379:         <V, S>,
382: 380:         V,
383: 381:         ReadSignal<V, S>: Get<Value = V>,
384: 382:         S: Storage<V> + Storage<Option<V>>,
385: 383:         S: Send + Sync + 'static,
386: 384:     );
387: 385:     style_reactive!(
388: 386:         Memo,
389: 387:         <V, S>,
390: 388:         V,
391: 389:         Memo<V, S>: Get<Value = V>,
392: 390:         S: Storage<V> + Storage<Option<V>>,
393: 391:         S: Send + Sync + 'static,
394: 392:     );
395: 393:     style_reactive!(
396: 394:         Signal,
397: 395:         <V, S>,
398: 396:         V,
399: 397:         Signal<V, S>: Get<Value = V>,
400: 398:         S: Storage<V> + Storage<Option<V>>,
401: 399:         S: Send + Sync + 'static,
402: 400:     );
403: 401:     style_reactive!(
404: 402:         MaybeSignal,
405: 403:         <V, S>,
406: 404:         V,
407: 405:         MaybeSignal<V, S>: Get<Value = V>,
408: 406:         S: Storage<V> + Storage<Option<V>>,
409: 407:         S: Send + Sync + 'static,
410: 408:     );
411: 409:     style_reactive!(ArcRwSignal, <V>, V, ArcRwSignal<V>: Get<Value = V>);
412: 410:     style_reactive!(ArcReadSignal, <V>, V, ArcReadSignal<V>: Get<Value = V>);
413: 411:     style_reactive!(ArcMemo, <V>, V, ArcMemo<V>: Get<Value = V>);
414: 412:     style_reactive!(ArcSignal, <V>, V, ArcSignal<V>: Get<Value = V>);
415: 413: }
416: 414: 
417: 415: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
418: 416: mod lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores {
419: 417:     use super::RenderEffect;
420: 418:     use crate::html::style::{IntoStyle, IntoStyleValue};
421: 419:     #[allow(deprecated)]
422: 420:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{owner::Storage, traits::Get};
423: 421:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores::{
424: 422:         ArcField, ArcStore, AtIndex, AtKeyed, DerefedField, Field,
425: 423:         KeyedSubfield, Store, StoreField, Subfield,
426: 424:     };
427: 425:     use std::{
428: 426:         ops::{Deref, DerefMut, Index, IndexMut},
429: 427:         sync::Arc,
430: 428:     };
431: 429: 
432: 430:     style_reactive!(
433: 431:         Subfield,
434: 432:         <Inner, Prev, V>,
435: 433:         V,
436: 434:         Subfield<Inner, Prev, V>: Get<Value = V>,
437: 435:         Prev: Send + Sync + 'static,
438: 436:         Inner: Send + Sync + Clone + 'static,
439: 437:     );
440: 438: 
441: 439:     style_reactive!(
442: 440:         AtKeyed,
443: 441:         <Inner, Prev, K, V>,
444: 442:         V,
445: 443:         AtKeyed<Inner, Prev, K, V>: Get<Value = V>,
446: 444:         Prev: Send + Sync + 'static,
447: 445:         Inner: Send + Sync + Clone + 'static,
448: 446:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
449: 447:         for<'a> &'a V: IntoIterator,
450: 448:     );
451: 449: 
452: 450:     style_reactive!(
453: 451:         KeyedSubfield,
454: 452:         <Inner, Prev, K, V>,
455: 453:         V,
456: 454:         KeyedSubfield<Inner, Prev, K, V>: Get<Value = V>,
457: 455:         Prev: Send + Sync + 'static,
458: 456:         Inner: Send + Sync + Clone + 'static,
459: 457:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
460: 458:         for<'a> &'a V: IntoIterator,
461: 459:     );
462: 460: 
463: 461:     style_reactive!(
464: 462:         DerefedField,
465: 463:         <S>,
466: 464:         <S::Value as Deref>::Target,
467: 465:         S: Clone + StoreField + Send + Sync + 'static,
468: 466:         <S as StoreField>::Value: Deref + DerefMut
469: 467:     );
470: 468: 
471: 469:     style_reactive!(
472: 470:         AtIndex,
473: 471:         <Inner, Prev>,
474: 472:         <Prev as Index<usize>>::Output,
475: 473:         AtIndex<Inner, Prev>: Get<Value = Prev::Output>,
476: 474:         Prev: Send + Sync + IndexMut<usize> + 'static,
477: 475:         Inner: Send + Sync + Clone + 'static,
478: 476:     );
479: 477:     style_reactive!(
480: 478:         Store,
481: 479:         <V, S>,
482: 480:         V,
483: 481:         Store<V, S>: Get<Value = V>,
484: 482:         S: Storage<V> + Storage<Option<V>>,
485: 483:         S: Send + Sync + 'static,
486: 484:     );
487: 485:     style_reactive!(
488: 486:         Field,
489: 487:         <V, S>,
490: 488:         V,
491: 489:         Field<V, S>: Get<Value = V>,
492: 490:         S: Storage<V> + Storage<Option<V>>,
493: 491:         S: Send + Sync + 'static,
494: 492:     );
495: 493:     style_reactive!(ArcStore, <V>, V, ArcStore<V>: Get<Value = V>);
496: 494:     style_reactive!(ArcField, <V>, V, ArcField<V>: Get<Value = V>);
497: 495: }
498: 496: /*
499: 497: impl<Fut> IntoStyle for Suspend<Fut>
500: 498: where
501: 499:     Fut: Clone + Future + Send + 'static,
502: 500:     Fut::Output: IntoStyle,
503: 501: {
504: 502:     type AsyncOutput = Fut::Output;
505: 503:     type State = Rc<RefCell<Option<<Fut::Output as IntoStyle>::State>>>;
506: 504:     type Cloneable = Self;
507: 505:     type CloneableOwned = Self;
508: 506: 
509: 507:     fn to_html(self, style: &mut String) {
510: 508:         if let Some(inner) = self.inner.now_or_never() {
511: 509:             inner.to_html(style);
512: 510:         } else {
513: 511:             panic!("You cannot use Suspend on an attribute outside Suspense");
514: 512:         }
515: 513:     }
516: 514: 
517: 515:     fn hydrate<const FROM_SERVER: bool>(
518: 516:         self,
519: 517:         el: &crate::renderer::types::Element,
520: 518:     ) -> Self::State {
521: 519:         let el = el.to_owned();
522: 520:         let state = Rc::new(RefCell::new(None));
523: 521:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
524: 522:             let state = Rc::clone(&state);
525: 523:             async move {
526: 524:                 *state.borrow_mut() =
527: 525:                     Some(self.inner.await.hydrate::<FROM_SERVER>(&el));
528: 526:                 self.subscriber.forward();
529: 527:             }
530: 528:         });
531: 529:         state
532: 530:     }
533: 531: 
534: 532:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
535: 533:         let el = el.to_owned();
536: 534:         let state = Rc::new(RefCell::new(None));
537: 535:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
538: 536:             let state = Rc::clone(&state);
539: 537:             async move {
540: 538:                 *state.borrow_mut() = Some(self.inner.await.build(&el));
541: 539:                 self.subscriber.forward();
542: 540:             }
543: 541:         });
544: 542:         state
545: 543:     }
546: 544: 
547: 545:     fn rebuild(self, state: &mut Self::State) {
548: 546:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
549: 547:             let state = Rc::clone(state);
550: 548:             async move {
551: 549:                 let value = self.inner.await;
552: 550:                 let mut state = state.borrow_mut();
553: 551:                 if let Some(state) = state.as_mut() {
554: 552:                     value.rebuild(state);
555: 553:                 }
556: 554:                 self.subscriber.forward();
557: 555:             }
558: 556:         });
559: 557:     }
560: 558: 
561: 559:     fn into_cloneable(self) -> Self::Cloneable {
562: 560:         self
563: 561:     }
564: 562: 
565: 563:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
566: 564:         self
567: 565:     }
568: 566: 
569: 567:     fn dry_resolve(&mut self) {}
570: 568: 
571: 569:     async fn resolve(self) -> Self::AsyncOutput {
572: 570:         self.inner.await
573: 571:     }
574: 572: }
575: 573: */
576: 574: ```
577: 575: ```
578: 576: ```
579: 577: ```
580: 578: ```
581: 579: ```
582: 580: ```
583: 581: ```
584: ```
```
