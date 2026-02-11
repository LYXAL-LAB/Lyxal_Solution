### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\class.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\class.rs
18: 16: ```rust
19: 17: use super::{ReactiveFunction, SharedReactiveFunction};
20: 18: use crate::{html::class::IntoClass, renderer::Rndr};
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::RenderEffect;
22: 20: use std::borrow::Borrow;
23: 21: 
24: 22: pub struct RenderEffectWithClassName<T>
25: 23: where
26: 24:     T: 'static,
27: 25: {
28: 26:     name: &'static str,
29: 27:     effect: RenderEffect<T>,
30: 28: }
31: 29: 
32: 30: impl<T> RenderEffectWithClassName<T>
33: 31: where
34: 32:     T: 'static,
35: 33: {
36: 34:     fn new(name: &'static str, effect: RenderEffect<T>) -> Self {
37: 35:         Self { effect, name }
38: 36:     }
39: 37: }
40: 38: 
41: 39: impl<F, C> IntoClass for F
42: 40: where
43: 41:     F: ReactiveFunction<Output = C>,
44: 42:     C: IntoClass + 'static,
45: 43:     C::State: 'static,
46: 44: {
47: 45:     type AsyncOutput = C::AsyncOutput;
48: 46:     type State = RenderEffect<C::State>;
49: 47:     type Cloneable = SharedReactiveFunction<C>;
50: 48:     type CloneableOwned = SharedReactiveFunction<C>;
51: 49: 
52: 50:     fn html_len(&self) -> usize {
53: 51:         0
54: 52:     }
55: 53: 
56: 54:     fn to_html(mut self, class: &mut String) {
57: 55:         let value = self.invoke();
58: 56:         value.to_html(class);
59: 57:     }
60: 58: 
61: 59:     fn hydrate<const FROM_SERVER: bool>(
62: 60:         mut self,
63: 61:         el: &crate::renderer::types::Element,
64: 62:     ) -> Self::State {
65: 63:         // TODO FROM_SERVER vs template
66: 64:         let el = el.clone();
67: 65:         RenderEffect::new(move |prev| {
68: 66:             let value = self.invoke();
69: 67:             if let Some(mut state) = prev {
70: 68:                 value.rebuild(&mut state);
71: 69:                 state
72: 70:             } else {
73: 71:                 value.hydrate::<FROM_SERVER>(&el)
74: 72:             }
75: 73:         })
76: 74:     }
77: 75: 
78: 76:     fn build(mut self, el: &crate::renderer::types::Element) -> Self::State {
79: 77:         let el = el.to_owned();
80: 78:         RenderEffect::new(move |prev| {
81: 79:             let value = self.invoke();
82: 80:             if let Some(mut state) = prev {
83: 81:                 value.rebuild(&mut state);
84: 82:                 state
85: 83:             } else {
86: 84:                 value.build(&el)
87: 85:             }
88: 86:         })
89: 87:     }
90: 88: 
91: 89:     fn rebuild(mut self, state: &mut Self::State) {
92: 90:         let prev_value = state.take_value();
93: 91:         *state = RenderEffect::new_with_value(
94: 92:             move |prev| {
95: 93:                 let value = self.invoke();
96: 94:                 if let Some(mut state) = prev {
97: 95:                     value.rebuild(&mut state);
98: 96:                     state
99: 97:                 } else {
100: 98:                     unreachable!()
101: 99:                 }
102: 100:             },
103: 101:             prev_value,
104: 102:         );
105: 103:     }
106: 104: 
107: 105:     fn into_cloneable(self) -> Self::Cloneable {
108: 106:         self.into_shared()
109: 107:     }
110: 108: 
111: 109:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
112: 110:         self.into_shared()
113: 111:     }
114: 112: 
115: 113:     fn dry_resolve(&mut self) {
116: 114:         self.invoke().dry_resolve();
117: 115:     }
118: 116: 
119: 117:     async fn resolve(mut self) -> Self::AsyncOutput {
120: 118:         self.invoke().resolve().await
121: 119:     }
122: 120: 
123: 121:     fn reset(state: &mut Self::State) {
124: 122:         *state = RenderEffect::new_with_value(
125: 123:             move |prev| {
126: 124:                 if let Some(mut state) = prev {
127: 125:                     C::reset(&mut state);
128: 126:                     state
129: 127:                 } else {
130: 128:                     unreachable!()
131: 129:                 }
132: 130:             },
133: 131:             state.take_value(),
134: 132:         );
135: 133:     }
136: 134: }
137: 135: 
138: 136: impl<F, T> IntoClass for (&'static str, F)
139: 137: where
140: 138:     F: ReactiveFunction<Output = T>,
141: 139:     T: Borrow<bool> + Send + 'static,
142: 140: {
143: 141:     type AsyncOutput = (&'static str, bool);
144: 142:     type State =
145: 143:         RenderEffectWithClassName<(crate::renderer::types::ClassList, bool)>;
146: 144:     type Cloneable = (&'static str, SharedReactiveFunction<T>);
147: 145:     type CloneableOwned = (&'static str, SharedReactiveFunction<T>);
148: 146: 
149: 147:     fn html_len(&self) -> usize {
150: 148:         self.0.len()
151: 149:     }
152: 150: 
153: 151:     fn to_html(self, class: &mut String) {
154: 152:         let (name, mut f) = self;
155: 153:         let include = *f.invoke().borrow();
156: 154:         if include {
157: 155:             <&str as IntoClass>::to_html(name, class);
158: 156:         }
159: 157:     }
160: 158: 
161: 159:     fn hydrate<const FROM_SERVER: bool>(
162: 160:         self,
163: 161:         el: &crate::renderer::types::Element,
164: 162:     ) -> Self::State {
165: 163:         // TODO FROM_SERVER vs template
166: 164:         let (name, mut f) = self;
167: 165:         let class_list = Rndr::class_list(el);
168: 166:         let name = Rndr::intern(name);
169: 167: 
170: 168:         RenderEffectWithClassName::new(
171: 169:             name,
172: 170:             RenderEffect::new(
173: 171:                 move |prev: Option<(
174: 172:                     crate::renderer::types::ClassList,
175: 173:                     bool,
176: 174:                 )>| {
177: 175:                     let include = *f.invoke().borrow();
178: 176:                     if let Some((class_list, prev)) = prev {
179: 177:                         if include {
180: 178:                             if !prev {
181: 179:                                 Rndr::add_class(&class_list, name);
182: 180:                             }
183: 181:                         } else if prev {
184: 182:                             Rndr::remove_class(&class_list, name);
185: 183:                         }
186: 184:                     }
187: 185:                     (class_list.clone(), include)
188: 186:                 },
189: 187:             ),
190: 188:         )
191: 189:     }
192: 190: 
193: 191:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
194: 192:         let (name, mut f) = self;
195: 193:         let class_list = Rndr::class_list(el);
196: 194:         let name = Rndr::intern(name);
197: 195: 
198: 196:         RenderEffectWithClassName::new(
199: 197:             name,
200: 198:             RenderEffect::new(
201: 199:                 move |prev: Option<(
202: 200:                     crate::renderer::types::ClassList,
203: 201:                     bool,
204: 202:                 )>| {
205: 203:                     let include = *f.invoke().borrow();
206: 204:                     match prev {
207: 205:                         Some((class_list, prev)) => {
208: 206:                             if include {
209: 207:                                 if !prev {
210: 208:                                     Rndr::add_class(&class_list, name);
211: 209:                                 }
212: 210:                             } else if prev {
213: 211:                                 Rndr::remove_class(&class_list, name);
214: 212:                             }
215: 213:                         }
216: 214:                         None => {
217: 215:                             if include {
218: 216:                                 Rndr::add_class(&class_list, name);
219: 217:                             }
220: 218:                         }
221: 219:                     }
222: 220:                     (class_list.clone(), include)
223: 221:                 },
224: 222:             ),
225: 223:         )
226: 224:     }
227: 225: 
228: 226:     fn rebuild(self, state: &mut Self::State) {
229: 227:         let (name, mut f) = self;
230: 228: 
231: 229:         let prev_name = state.name;
232: 230:         let prev_state = state.effect.take_value();
233: 231:         if let Some((list, prev_include)) = &prev_state {
234: 232:             if prev_name != name && *prev_include {
235: 233:                 Rndr::remove_class(list, prev_name);
236: 234:             }
237: 235:         }
238: 236: 
239: 237:         // Name might've updated:
240: 238:         state.name = name;
241: 239:         let mut first_run = true;
242: 240:         state.effect = RenderEffect::new_with_value(
243: 241:             move |prev| {
244: 242:                 let include = *f.invoke().borrow();
245: 243:                 match prev {
246: 244:                     Some((class_list, prev)) => {
247: 245:                         if include {
248: 246:                             if !prev || first_run {
249: 247:                                 Rndr::add_class(&class_list, name);
250: 248:                             }
251: 249:                         } else if prev {
252: 250:                             Rndr::remove_class(&class_list, name);
253: 251:                         }
254: 252:                         first_run = false;
255: 253:                         (class_list.clone(), include)
256: 254:                     }
257: 255:                     None => {
258: 256:                         unreachable!()
259: 257:                     }
260: 258:                 }
261: 259:             },
262: 260:             prev_state,
263: 261:         );
264: 262:     }
265: 263: 
266: 264:     fn into_cloneable(self) -> Self::Cloneable {
267: 265:         (self.0, self.1.into_shared())
268: 266:     }
269: 267: 
270: 268:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
271: 269:         (self.0, self.1.into_shared())
272: 270:     }
273: 271: 
274: 272:     fn dry_resolve(&mut self) {
275: 273:         self.1.invoke();
276: 274:     }
277: 275: 
278: 276:     async fn resolve(mut self) -> Self::AsyncOutput {
279: 277:         (self.0, *self.1.invoke().borrow())
280: 278:     }
281: 279: 
282: 280:     fn reset(state: &mut Self::State) {
283: 281:         let name = state.name;
284: 282:         state.effect = RenderEffect::new_with_value(
285: 283:             move |prev| {
286: 284:                 if let Some(mut state) = prev {
287: 285:                     let (class_list, prev) = &mut state;
288: 286:                     Rndr::remove_class(class_list, name);
289: 287:                     *prev = false;
290: 288:                     state
291: 289:                 } else {
292: 290:                     unreachable!()
293: 291:                 }
294: 292:             },
295: 293:             state.effect.take_value(),
296: 294:         );
297: 295:     }
298: 296: }
299: 297: 
300: 298: // TODO this needs a non-reactive form too to be restored
301: 299: /*
302: 300: impl<F, T> IntoClass for (Vec<Cow<'static, str>>, F)
303: 301: where
304: 302:     F: ReactiveFunction<Output = T>,
305: 303:     T: Borrow<bool> + Send + 'static,
306: 304: 
307: 305: {
308: 306:     type AsyncOutput = (Vec<Cow<'static, str>>, bool);
309: 307:     type State = RenderEffect<(crate::renderer::types::ClassList, bool)>;
310: 308:     type Cloneable = (Vec<Cow<'static, str>>, SharedReactiveFunction<T>);
311: 309:     type CloneableOwned = (Vec<Cow<'static, str>>, SharedReactiveFunction<T>);
312: 310: 
313: 311:     fn html_len(&self) -> usize {
314: 312:         self.0.iter().map(|n| n.len()).sum()
315: 313:     }
316: 314: 
317: 315:     fn to_html(self, class: &mut String) {
318: 316:         let (names, mut f) = self;
319: 317:         let include = *f.invoke().borrow();
320: 318:         if include {
321: 319:             for name in names {
322: 320:                 <&str as IntoClass>::to_html(&name, class);
323: 321:             }
324: 322:         }
325: 323:     }
326: 324: 
327: 325:     fn hydrate<const FROM_SERVER: bool>(self, el: &crate::renderer::types::Element) -> Self::State {
328: 326:         // TODO FROM_SERVER vs template
329: 327:         let (names, mut f) = self;
330: 328:         let class_list = Rndr::class_list(el);
331: 329: 
332: 330:         RenderEffect::new(move |prev: Option<(crate::renderer::types::ClassList, bool)>| {
333: 331:             let include = *f.invoke().borrow();
334: 332:             if let Some((class_list, prev)) = prev {
335: 333:                 if include {
336: 334:                     if !prev {
337: 335:                         for name in &names {
338: 336:                             // TODO multi-class optimizations here
339: 337:                             Rndr::add_class(&class_list, name);
340: 338:                         }
341: 339:                     }
342: 340:                 } else if prev {
343: 341:                     for name in &names {
344: 342:                         Rndr::remove_class(&class_list, name);
345: 343:                     }
346: 344:                 }
347: 345:             }
348: 346:             (class_list.clone(), include)
349: 347:         })
350: 348:     }
351: 349: 
352: 350:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
353: 351:         let (names, mut f) = self;
354: 352:         let class_list = Rndr::class_list(el);
355: 353: 
356: 354:         RenderEffect::new(move |prev: Option<(crate::renderer::types::ClassList, bool)>| {
357: 355:             let include = *f.invoke().borrow();
358: 356:             match prev {
359: 357:                 Some((class_list, prev)) => {
360: 358:                     if include {
361: 359:                         for name in &names {
362: 360:                             if !prev {
363: 361:                                 Rndr::add_class(&class_list, name);
364: 362:                             }
365: 363:                         }
366: 364:                     } else if prev {
367: 365:                         for name in &names {
368: 366:                             Rndr::remove_class(&class_list, name);
369: 367:                         }
370: 368:                     }
371: 369:                 }
372: 370:                 None => {
373: 371:                     if include {
374: 372:                         for name in &names {
375: 373:                             Rndr::add_class(&class_list, name);
376: 374:                         }
377: 375:                     }
378: 376:                 }
379: 377:             }
380: 378:             (class_list.clone(), include)
381: 379:         })
382: 380:     }
383: 381: 
384: 382:     fn rebuild(self, state: &mut Self::State) {
385: 383:         let (names, mut f) = self;
386: 384:         let prev_value = state.take_value();
387: 385: 
388: 386:         *state = RenderEffect::new_with_value(
389: 387:             move |prev: Option<(crate::renderer::types::ClassList, bool)>| {
390: 388:                 let include = *f.invoke().borrow();
391: 389:                 match prev {
392: 390:                     Some((class_list, prev)) => {
393: 391:                         if include {
394: 392:                             for name in &names {
395: 393:                                 if !prev {
396: 394:                                     Rndr::add_class(&class_list, name);
397: 395:                                 }
398: 396:                             }
399: 397:                         } else if prev {
400: 398:                             for name in &names {
401: 399:                                 Rndr::remove_class(&class_list, name);
402: 400:                             }
403: 401:                         }
404: 402:                         (class_list.clone(), include)
405: 403:                     }
406: 404:                     None => {
407: 405:                         unreachable!()
408: 406:                     }
409: 407:                 }
410: 408:             },
411: 409:             prev_value,
412: 410:         );
413: 411:     }
414: 412: 
415: 413:     fn into_cloneable(self) -> Self::Cloneable {
416: 414:         (self.0.clone(), self.1.into_shared())
417: 415:     }
418: 416: 
419: 417:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
420: 418:         (self.0.clone(), self.1.into_shared())
421: 419:     }
422: 420: 
423: 421:     fn dry_resolve(&mut self) {
424: 422:         self.1.invoke();
425: 423:     }
426: 424: 
427: 425:     async fn resolve(mut self) -> Self::AsyncOutput {
428: 426:         (self.0, *self.1.invoke().borrow())
429: 427:     }
430: 428: }
431: 429: */
432: 430: 
433: 431: /*
434: 432: impl<G> IntoClass for ReadGuard<String, G>
435: 433: where
436: 434:     G: Deref<Target = String> + Send,
437: 435: {
438: 436:     type AsyncOutput = Self;
439: 437:     type State = <String as IntoClass>::State;
440: 438:     type Cloneable = Arc<str>;
441: 439:     type CloneableOwned = Arc<str>;
442: 440: 
443: 441:     fn html_len(&self) -> usize {
444: 442:         self.len()
445: 443:     }
446: 444: 
447: 445:     fn to_html(self, class: &mut String) {
448: 446:         <&str as IntoClass>::to_html(self.deref().as_str(), class);
449: 447:     }
450: 448: 
451: 449:     fn hydrate<const FROM_SERVER: bool>(
452: 450:         self,
453: 451:         el: &crate::renderer::types::Element,
454: 452:     ) -> Self::State {
455: 453:         <String as IntoClass>::hydrate::<FROM_SERVER>(
456: 454:             self.deref().to_owned(),
457: 455:             el,
458: 456:         )
459: 457:     }
460: 458: 
461: 459:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
462: 460:         <String as IntoClass>::build(self.deref().to_owned(), el)
463: 461:     }
464: 462: 
465: 463:     fn rebuild(self, state: &mut Self::State) {
466: 464:         <String as IntoClass>::rebuild(self.deref().to_owned(), state)
467: 465:     }
468: 466: 
469: 467:     fn into_cloneable(self) -> Self::Cloneable {
470: 468:         self.as_str().into()
471: 469:     }
472: 470: 
473: 471:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
474: 472:         self.as_str().into()
475: 473:     }
476: 474: 
477: 475:     fn dry_resolve(&mut self) {}
478: 476: 
479: 477:     async fn resolve(self) -> Self::AsyncOutput {
480: 478:         self
481: 479:     }
482: 480: }
483: 481: 
484: 482: impl<G> IntoClass for (&'static str, ReadGuard<bool, G>)
485: 483: where
486: 484:     G: Deref<Target = bool> + Send,
487: 485: {
488: 486:     type AsyncOutput = Self;
489: 487:     type State = <(&'static str, bool) as IntoClass>::State;
490: 488:     type Cloneable = (&'static str, bool);
491: 489:     type CloneableOwned = (&'static str, bool);
492: 490: 
493: 491:     fn html_len(&self) -> usize {
494: 492:         self.0.len()
495: 493:     }
496: 494: 
497: 495:     fn to_html(self, class: &mut String) {
498: 496:         <(&'static str, bool) as IntoClass>::to_html(
499: 497:             (self.0, *self.1.deref()),
500: 498:             class,
501: 499:         );
502: 500:     }
503: 501: 
504: 502:     fn hydrate<const FROM_SERVER: bool>(
505: 503:         self,
506: 504:         el: &crate::renderer::types::Element,
507: 505:     ) -> Self::State {
508: 506:         <(&'static str, bool) as IntoClass>::hydrate::<FROM_SERVER>(
509: 507:             (self.0, *self.1.deref()),
510: 508:             el,
511: 509:         )
512: 510:     }
513: 511: 
514: 512:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
515: 513:         <(&'static str, bool) as IntoClass>::build(
516: 514:             (self.0, *self.1.deref()),
517: 515:             el,
518: 516:         )
519: 517:     }
520: 518: 
521: 519:     fn rebuild(self, state: &mut Self::State) {
522: 520:         <(&'static str, bool) as IntoClass>::rebuild(
523: 521:             (self.0, *self.1.deref()),
524: 522:             state,
525: 523:         )
526: 524:     }
527: 525: 
528: 526:     fn into_cloneable(self) -> Self::Cloneable {
529: 527:         (self.0, *self.1)
530: 528:     }
531: 529: 
532: 530:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
533: 531:         (self.0, *self.1)
534: 532:     }
535: 533: 
536: 534:     fn dry_resolve(&mut self) {}
537: 535: 
538: 536:     async fn resolve(self) -> Self::AsyncOutput {
539: 537:         self
540: 538:     }
541: 539: }
542: 540: */
543: 541: 
544: 542: macro_rules!  tuple_class_reactive {
545: 543:     ($name:ident, <$($impl_gen:ident),*>, <$($gen:ident),*> , $( $where_clause:tt )*) =>
546: 544:     {
547: 545:         #[allow(deprecated)]
548: 546:         impl<$($impl_gen),*>  IntoClass for (&'static str, $name<$($gen),*>)
549: 547:         where
550: 548:             $($where_clause)*
551: 549:         {
552: 550:             type AsyncOutput = Self;
553: 551:             type State = RenderEffectWithClassName<(
554: 552:                 crate::renderer::types::ClassList,
555: 553:                 bool,
556: 554:             )>;
557: 555:             type Cloneable = Self;
558: 556:             type CloneableOwned = Self;
559: 557: 
560: 558:             fn html_len(&self) -> usize {
561: 559:                 self.0.len()
562: 560:             }
563: 561: 
564: 562:             fn to_html(self, class: &mut String) {
565: 563:                 let (name, f) = self;
566: 564:                 let include = f.get();
567: 565:                 if include {
568: 566:                     <&str as IntoClass>::to_html(name, class);
569: 567:                 }
570: 568:             }
571: 569: 
572: 570:             fn hydrate<const FROM_SERVER: bool>(
573: 571:                 self,
574: 572:                 el: &crate::renderer::types::Element,
575: 573:             ) -> Self::State {
576: 574:                 IntoClass::hydrate::<FROM_SERVER>(
577: 575:                     (self.0, move || self.1.get()),
578: 576:                     el,
579: 577:                 )
580: 578:             }
581: 579: 
582: 580:             fn build(
583: 581:                 self,
584: 582:                 el: &crate::renderer::types::Element,
585: 583:             ) -> Self::State {
586: 584:                 IntoClass::build((self.0, move || self.1.get()), el)
587: 585:             }
588: 586: 
589: 587:             fn rebuild(self, state: &mut Self::State) {
590: 588:                 IntoClass::rebuild((self.0, move || self.1.get()), state)
591: 589:             }
592: 590: 
593: 591:             fn into_cloneable(self) -> Self::Cloneable {
594: 592:                 self
595: 593:             }
596: 594: 
597: 595:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
598: 596:                 self
599: 597:             }
600: 598: 
601: 599:             fn dry_resolve(&mut self) {}
602: 600: 
603: 601:             async fn resolve(self) -> Self::AsyncOutput {
604: 602:                 self
605: 603:             }
606: 604: 
607: 605:             fn reset(state: &mut Self::State) {
608: 606:                 let name = state.name;
609: 607:                 *state = RenderEffectWithClassName::new(
610: 608:                     state.name,
611: 609:                     RenderEffect::new_with_value(
612: 610:                         move |prev| {
613: 611:                             if let Some(mut state) = prev {
614: 612:                                 let (class_list, prev) = &mut state;
615: 613:                                 Rndr::remove_class(class_list, name);
616: 614:                                 *prev = false;
617: 615:                                 state
618: 616:                             } else {
619: 617:                                 unreachable!()
620: 618:                             }
621: 619:                         },
622: 620:                         state.effect.take_value(),
623: 621:                     ),
624: 622:                 );
625: 623:             }
626: 624:         }
627: 625:     };
628: 626: }
629: 627: 
630: 628: macro_rules!  class_reactive {
631: 629:     ($name:ident, <$($gen:ident),*>, $v:ty, $( $where_clause:tt )*) =>
632: 630:     {
633: 631:         #[allow(deprecated)]
634: 632:         impl<$($gen),*> IntoClass for $name<$($gen),*>
635: 633:         where
636: 634:             $v: IntoClass + Clone + Send + Sync + 'static,
637: 635:             <$v as IntoClass>::State: 'static,
638: 636:             $($where_clause)*
639: 637:         {
640: 638:             type AsyncOutput = Self;
641: 639:             type State = RenderEffect<<$v as IntoClass>::State>;
642: 640:             type Cloneable = Self;
643: 641:             type CloneableOwned = Self;
644: 642: 
645: 643:             fn html_len(&self) -> usize {
646: 644:                 0
647: 645:             }
648: 646: 
649: 647:             fn to_html(self, class: &mut String) {
650: 648:                 let value = self.get();
651: 649:                 value.to_html(class);
652: 650:             }
653: 651: 
654: 652:             fn hydrate<const FROM_SERVER: bool>(
655: 653:                 self,
656: 654:                 el: &crate::renderer::types::Element,
657: 655:             ) -> Self::State {
658: 656:                 (move || self.get()).hydrate::<FROM_SERVER>(el)
659: 657:             }
660: 658: 
661: 659:             fn build(
662: 660:                 self,
663: 661:                 el: &crate::renderer::types::Element,
664: 662:             ) -> Self::State {
665: 663:                 (move || self.get()).build(el)
666: 664:             }
667: 665: 
668: 666:             fn rebuild(self, state: &mut Self::State) {
669: 667:                 (move || self.get()).rebuild(state)
670: 668:             }
671: 669: 
672: 670:             fn into_cloneable(self) -> Self::Cloneable {
673: 671:                 self
674: 672:             }
675: 673: 
676: 674:             fn into_cloneable_owned(self) -> Self::CloneableOwned {
677: 675:                 self
678: 676:             }
679: 677: 
680: 678:             fn dry_resolve(&mut self) {}
681: 679: 
682: 680:             async fn resolve(self) -> Self::AsyncOutput {
683: 681:                 self
684: 682:             }
685: 683: 
686: 684:             fn reset(state: &mut Self::State) {
687: 685:                 *state = RenderEffect::new_with_value(
688: 686:                     move |prev| {
689: 687:                         if let Some(mut state) = prev {
690: 688:                             <$v>::reset(&mut state);
691: 689:                             state
692: 690:                         } else {
693: 691:                             unreachable!()
694: 692:                         }
695: 693:                     },
696: 694:                     state.take_value(),
697: 695:                 );
698: 696:             }
699: 697:         }
700: 698:     };
701: 699: }
702: 700: 
703: 701: #[cfg(not(feature = "nightly"))]
704: 702: mod stable {
705: 703:     use super::{RenderEffect, RenderEffectWithClassName};
706: 704:     use crate::{html::class::IntoClass, renderer::Rndr};
707: 705:     #[allow(deprecated)]
708: 706:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::MaybeSignal;
709: 707:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
710: 708:         computed::{ArcMemo, Memo},
711: 709:         owner::Storage,
712: 710:         signal::{ArcReadSignal, ArcRwSignal, ReadSignal, RwSignal},
713: 711:         traits::Get,
714: 712:         wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::{ArcSignal, Signal},
715: 713:     };
716: 714:     class_reactive!(
717: 715:         RwSignal,
718: 716:         <V, S>,
719: 717:         V,
720: 718:         RwSignal<V, S>: Get<Value = V>,
721: 719:         S: Storage<V> + Storage<Option<V>>,
722: 720:         S: Send + Sync + 'static,
723: 721:     );
724: 722:     class_reactive!(
725: 723:         ReadSignal,
726: 724:         <V, S>,
727: 725:         V,
728: 726:         ReadSignal<V, S>: Get<Value = V>,
729: 727:         S: Storage<V> + Storage<Option<V>>,
730: 728:         S: Send + Sync + 'static,
731: 729:     );
732: 730:     class_reactive!(
733: 731:         Memo,
734: 732:         <V, S>,
735: 733:         V,
736: 734:         Memo<V, S>: Get<Value = V>,
737: 735:         S: Storage<V> + Storage<Option<V>>,
738: 736:         S: Send + Sync + 'static,
739: 737:     );
740: 738:     class_reactive!(
741: 739:         Signal,
742: 740:         <V, S>,
743: 741:         V,
744: 742:         Signal<V, S>: Get<Value = V>,
745: 743:         S: Storage<V> + Storage<Option<V>>,
746: 744:         S: Send + Sync + 'static,
747: 745:     );
748: 746:     class_reactive!(
749: 747:         MaybeSignal,
750: 748:         <V, S>,
751: 749:         V,
752: 750:         MaybeSignal<V, S>: Get<Value = V>,
753: 751:         S: Storage<V> + Storage<Option<V>>,
754: 752:         S: Send + Sync + 'static,
755: 753:     );
756: 754:     class_reactive!(ArcRwSignal, <V>, V, ArcRwSignal<V>: Get<Value = V>);
757: 755:     class_reactive!(ArcReadSignal, <V>, V, ArcReadSignal<V>: Get<Value = V>);
758: 756:     class_reactive!(ArcMemo, <V>, V, ArcMemo<V>: Get<Value = V>);
759: 757:     class_reactive!(ArcSignal, <V>, V, ArcSignal<V>: Get<Value = V>);
760: 758: 
761: 759:     tuple_class_reactive!(
762: 760:         RwSignal,
763: 761:         <S>,
764: 762:         <bool, S>,
765: 763:         RwSignal<bool, S>: Get<Value = bool>,
766: 764:         S: Storage<bool>,
767: 765:         S: Send  + 'static,
768: 766:     );
769: 767:     tuple_class_reactive!(
770: 768:         ReadSignal,
771: 769:         <S>,
772: 770:         <bool, S>,
773: 771:         ReadSignal<bool, S>: Get<Value = bool>,
774: 772:         S: Storage<bool>,
775: 773:         S: Send + 'static,
776: 774:     );
777: 775:     tuple_class_reactive!(
778: 776:         Memo,
779: 777:         <S>,
780: 778:         <bool, S>,
781: 779:         Memo<bool, S>: Get<Value = bool>,
782: 780:         S: Storage<bool>,
783: 781:         S: Send + 'static,
784: 782:     );
785: 783:     tuple_class_reactive!(
786: 784:         Signal,
787: 785:         <S>,
788: 786:         <bool, S>,
789: 787:         Signal<bool, S>: Get<Value = bool>,
790: 788:         S: Storage<bool>,
791: 789:         S: Send + 'static,
792: 790:     );
793: 791:     tuple_class_reactive!(
794: 792:         MaybeSignal,
795: 793:         <S>,
796: 794:         <bool, S>,
797: 795:         MaybeSignal<bool, S>: Get<Value = bool>,
798: 796:         S: Storage<bool>,
799: 797:         S: Send + 'static,
800: 798:     );
801: 799:     tuple_class_reactive!(ArcRwSignal,<>, <bool>, ArcRwSignal<bool>: Get<Value = bool>);
802: 800:     tuple_class_reactive!(ArcReadSignal,<>, <bool>, ArcReadSignal<bool>: Get<Value = bool>);
803: 801:     tuple_class_reactive!(ArcMemo,<>, <bool>, ArcMemo<bool>: Get<Value = bool>);
804: 802:     tuple_class_reactive!(ArcSignal,<>, <bool>, ArcSignal<bool>: Get<Value = bool>);
805: 803: }
806: 804: 
807: 805: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
808: 806: mod lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores {
809: 807:     use super::{RenderEffect, RenderEffectWithClassName};
810: 808:     use crate::{html::class::IntoClass, renderer::Rndr};
811: 809:     #[allow(deprecated)]
812: 810:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{owner::Storage, traits::Get};
813: 811:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores::{
814: 812:         ArcField, ArcStore, AtIndex, AtKeyed, DerefedField, Field,
815: 813:         KeyedSubfield, Store, StoreField, Subfield,
816: 814:     };
817: 815:     use std::ops::{Deref, DerefMut, Index, IndexMut};
818: 816: 
819: 817:     class_reactive!(
820: 818:         Subfield,
821: 819:         <Inner, Prev, V>,
822: 820:         V,
823: 821:         Subfield<Inner, Prev, V>: Get<Value = V>,
824: 822:         Prev: Send + Sync + 'static,
825: 823:         Inner: Send + Sync + Clone + 'static,
826: 824:     );
827: 825: 
828: 826:     class_reactive!(
829: 827:         AtKeyed,
830: 828:         <Inner, Prev, K, V>,
831: 829:         V,
832: 830:         AtKeyed<Inner, Prev, K, V>: Get<Value = V>,
833: 831:         Prev: Send + Sync + 'static,
834: 832:         Inner: Send + Sync + Clone + 'static,
835: 833:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
836: 834:         for<'a> &'a V: IntoIterator,
837: 835:     );
838: 836: 
839: 837:     class_reactive!(
840: 838:         KeyedSubfield,
841: 839:         <Inner, Prev, K, V>,
842: 840:         V,
843: 841:         KeyedSubfield<Inner, Prev, K, V>: Get<Value = V>,
844: 842:         Prev: Send + Sync + 'static,
845: 843:         Inner: Send + Sync + Clone + 'static,
846: 844:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
847: 845:         for<'a> &'a V: IntoIterator,
848: 846:     );
849: 847: 
850: 848:     class_reactive!(
851: 849:         DerefedField,
852: 850:         <S>,
853: 851:         <S::Value as Deref>::Target,
854: 852:         S: Clone + StoreField + Send + Sync + 'static,
855: 853:         <S as StoreField>::Value: Deref + DerefMut
856: 854:     );
857: 855: 
858: 856:     class_reactive!(
859: 857:         AtIndex,
860: 858:         <Inner, Prev>,
861: 859:         <Prev as Index<usize>>::Output,
862: 860:         AtIndex<Inner, Prev>: Get<Value = Prev::Output>,
863: 861:         Prev: Send + Sync + IndexMut<usize> + 'static,
864: 862:         Inner: Send + Sync + Clone + 'static,
865: 863:     );
866: 864:     class_reactive!(
867: 865:         Store,
868: 866:         <V, S>,
869: 867:         V,
870: 868:         Store<V, S>: Get<Value = V>,
871: 869:         S: Storage<V> + Storage<Option<V>>,
872: 870:         S: Send + Sync + 'static,
873: 871:     );
874: 872:     class_reactive!(
875: 873:         Field,
876: 874:         <V, S>,
877: 875:         V,
878: 876:         Field<V, S>: Get<Value = V>,
879: 877:         S: Storage<V> + Storage<Option<V>>,
880: 878:         S: Send + Sync + 'static,
881: 879:     );
882: 880:     class_reactive!(ArcStore, <V>, V, ArcStore<V>: Get<Value = V>);
883: 881:     class_reactive!(ArcField, <V>, V, ArcField<V>: Get<Value = V>);
884: 882: 
885: 883:     tuple_class_reactive!(
886: 884:         Subfield,
887: 885:         <Inner, Prev>,
888: 886:         <Inner, Prev, bool>,
889: 887:         Subfield<Inner, Prev, bool>: Get<Value = bool>,
890: 888:         Prev: Send + Sync + 'static,
891: 889:         Inner: Send + Sync + Clone + 'static,
892: 890:     );
893: 891: 
894: 892:     tuple_class_reactive!(
895: 893:         AtKeyed,
896: 894:         <Inner, Prev, K>,
897: 895:         <Inner, Prev, K, bool>,
898: 896:         AtKeyed<Inner, Prev, K, bool>: Get<Value = bool>,
899: 897:         Prev: Send + Sync + 'static,
900: 898:         Inner: Send + Sync + Clone + 'static,
901: 899:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
902: 900:         for<'a> &'a bool: IntoIterator,
903: 901:     );
904: 902: 
905: 903:     tuple_class_reactive!(
906: 904:         KeyedSubfield,
907: 905:         <Inner, Prev, K>,
908: 906:         <Inner, Prev, K, bool>,
909: 907:         KeyedSubfield<Inner, Prev, K, bool>: Get<Value = bool>,
910: 908:         Prev: Send + Sync + 'static,
911: 909:         Inner: Send + Sync + Clone + 'static,
912: 910:         K: Send + Sync + std::fmt::Debug + Clone + 'static,
913: 911:         for<'a> &'a bool: IntoIterator,
914: 912:     );
915: 913: 
916: 914:     tuple_class_reactive!(
917: 915:         DerefedField,
918: 916:         <S>,
919: 917:         <S>,
920: 918:         S: Clone + StoreField + Send + Sync + 'static,
921: 919:         <S as StoreField>::Value: Deref<Target = bool> + DerefMut
922: 920:     );
923: 921: 
924: 922:     tuple_class_reactive!(
925: 923:         AtIndex,
926: 924:         <Inner, Prev>,
927: 925:         <Inner, Prev>,
928: 926:         AtIndex<Inner, Prev>: Get<Value = Prev::Output>,
929: 927:         Prev: Send + Sync + IndexMut<usize,Output = bool> + 'static,
930: 928:         Inner: Send + Sync + Clone + 'static,
931: 929:     );
932: 930:     tuple_class_reactive!(
933: 931:         Store,
934: 932:         <S>,
935: 933:         <bool, S>,
936: 934:         Store<bool, S>: Get<Value = bool>,
937: 935:         S: Storage<bool>,
938: 936:         S: Send  + 'static,
939: 937:     );
940: 938:     tuple_class_reactive!(
941: 939:         Field,
942: 940:         <S>,
943: 941:         <bool, S>,
944: 942:         Field<bool, S>: Get<Value = bool>,
945: 943:         S: Storage<bool>,
946: 944:         S: Send  + 'static,
947: 945:     );
948: 946:     tuple_class_reactive!(ArcStore,<>, <bool>, ArcStore<bool>: Get<Value = bool>);
949: 947:     tuple_class_reactive!(ArcField,<>, <bool>, ArcField<bool>: Get<Value = bool>);
950: 948: }
951: 949: 
952: 950: /*
953: 951: impl<Fut> IntoClass for Suspend<Fut>
954: 952: where
955: 953:     Fut: Clone + Future + Send + 'static,
956: 954:     Fut::Output: IntoClass,
957: 955: {
958: 956:     type AsyncOutput = Fut::Output;
959: 957:     type State = Rc<RefCell<Option<<Fut::Output as IntoClass>::State>>>;
960: 958:     type Cloneable = Self;
961: 959:     type CloneableOwned = Self;
962: 960: 
963: 961:     fn html_len(&self) -> usize {
964: 962:         0
965: 963:     }
966: 964: 
967: 965:     fn to_html(self, style: &mut String) {
968: 966:         if let Some(inner) = self.inner.now_or_never() {
969: 967:             inner.to_html(style);
970: 968:         } else {
971: 969:             panic!("You cannot use Suspend on an attribute outside Suspense");
972: 970:         }
973: 971:     }
974: 972: 
975: 973:     fn hydrate<const FROM_SERVER: bool>(
976: 974:         self,
977: 975:         el: &crate::renderer::types::Element,
978: 976:     ) -> Self::State {
979: 977:         let el = el.to_owned();
980: 978:         let state = Rc::new(RefCell::new(None));
981: 979:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
982: 980:             let state = Rc::clone(&state);
983: 981:             async move {
984: 982:                 *state.borrow_mut() =
985: 983:                     Some(self.inner.await.hydrate::<FROM_SERVER>(&el));
986: 984:                 self.subscriber.forward();
987: 985:             }
988: 986:         });
989: 987:         state
990: 988:     }
991: 989: 
992: 990:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
993: 991:         let el = el.to_owned();
994: 992:         let state = Rc::new(RefCell::new(None));
995: 993:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
996: 994:             let state = Rc::clone(&state);
997: 995:             async move {
998: 996:                 *state.borrow_mut() = Some(self.inner.await.build(&el));
999: 997:                 self.subscriber.forward();
1000: 998:             }
1001: 999:         });
1002: 1000:         state
1003: 1001:     }
1004: 1002: 
1005: 1003:     fn rebuild(self, state: &mut Self::State) {
1006: 1004:         lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::spawn_local_scoped({
1007: 1005:             let state = Rc::clone(state);
1008: 1006:             async move {
1009: 1007:                 let value = self.inner.await;
1010: 1008:                 let mut state = state.borrow_mut();
1011: 1009:                 if let Some(state) = state.as_mut() {
1012: 1010:                     value.rebuild(state);
1013: 1011:                 }
1014: 1012:                 self.subscriber.forward();
1015: 1013:             }
1016: 1014:         });
1017: 1015:     }
1018: 1016: 
1019: 1017:     fn into_cloneable(self) -> Self::Cloneable {
1020: 1018:         self
1021: 1019:     }
1022: 1020: 
1023: 1021:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
1024: 1022:         self
1025: 1023:     }
1026: 1024: 
1027: 1025:     fn dry_resolve(&mut self) {}
1028: 1026: 
1029: 1027:     async fn resolve(self) -> Self::AsyncOutput {
1030: 1028:         self.inner.await
1031: 1029:     }
1032: 1030: }
1033: 1031: */
1034: 1032: ```
1035: 1033: ```
1036: 1034: ```
1037: 1035: ```
1038: 1036: ```
1039: 1037: ```
1040: 1038: ```
1041: 1039: ```
1042: ```
```
