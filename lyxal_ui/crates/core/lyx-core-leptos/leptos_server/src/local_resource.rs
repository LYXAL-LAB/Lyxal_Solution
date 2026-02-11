### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_server\src\local_resource.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server\src\local_resource.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
4: 2:     computed::{
5: 3:         suspense::LocalResourceNotifier, ArcAsyncDerived, AsyncDerived,
6: 4:         AsyncDerivedFuture,
7: 5:     },
8: 6:     graph::{
9: 7:         AnySource, AnySubscriber, ReactiveNode, Source, Subscriber,
10: 8:         ToAnySource, ToAnySubscriber,
11: 9:     },
12: 10:     owner::use_context,
13: 11:     send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper_ext::SendOption,
14: 12:     signal::{
15: 13:         guards::{AsyncPlain, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, ReadGuard},
16: 14:         ArcRwSignal, RwSignal,
17: 15:     },
18: 16:     traits::{
19: 17:         DefinedAt, IsDisposed, Notify, ReadUntracked, Track, UntrackableGuard,
20: 18:         Update, With, Write,
21: 19:     },
22: 20: };
23: 21: use std::{
24: 22:     future::{pending, Future, IntoFuture},
25: 23:     ops::{Deref, DerefMut},
26: 24:     panic::Location,
27: 25: };
28: 26: 
29: 27: /// A reference-counted resource that only loads its data locally on the lyx-core-lyx_core_lyx-core-lyx_core_client.
30: 28: pub struct ArcLocalResource<T> {
31: 29:     data: ArcAsyncDerived<T>,
32: 30:     refetch: ArcRwSignal<usize>,
33: 31:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
34: 32:     defined_at: &'static Location<'static>,
35: 33: }
36: 34: 
37: 35: impl<T> Clone for ArcLocalResource<T> {
38: 36:     fn clone(&self) -> Self {
39: 37:         Self {
40: 38:             data: self.data.clone(),
41: 39:             refetch: self.refetch.clone(),
42: 40:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
43: 41:             defined_at: self.defined_at,
44: 42:         }
45: 43:     }
46: 44: }
47: 45: 
48: 46: impl<T> Deref for ArcLocalResource<T> {
49: 47:     type Target = ArcAsyncDerived<T>;
50: 48: 
51: 49:     fn deref(&self) -> &Self::Target {
52: 50:         &self.data
53: 51:     }
54: 52: }
55: 53: 
56: 54: impl<T> ArcLocalResource<T> {
57: 55:     /// Creates the resource.
58: 56:     ///
59: 57:     /// This will only begin loading data if you are on the lyx-core-lyx_core_lyx-core-lyx_core_client (i.e., if you do not have the
60: 58:     /// `ssr` feature activated).
61: 59:     #[track_caller]
62: 60:     pub fn new<Fut>(fetcher: impl Fn() -> Fut + 'static) -> Self
63: 61:     where
64: 62:         T: 'static,
65: 63:         Fut: Future<Output = T> + 'static,
66: 64:     {
67: 65:         let fetcher = move || {
68: 66:             let fut = fetcher();
69: 67:             async move {
70: 68:                 // in SSR mode, this will simply always be pending
71: 69:                 // if we try to read from it, we will trigger Suspense automatically to fall back
72: 70:                 // so this will never need to return anything
73: 71:                 if cfg!(feature = "ssr") {
74: 72:                     pending().await
75: 73:                 } else {
76: 74:                     // LocalResources that are immediately available can cause a hydration error,
77: 75:                     // because the future *looks* like it is already ready (and therefore would
78: 76:                     // already have been rendered to html on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server), but in fact was ignored
79: 77:                     // on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server. the simplest way to avoid this is to ensure that we always
80: 78:                     // wait a tick before resolving any value for a localresource.
81: 79:                     lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
82: 80:                     fut.await
83: 81:                 }
84: 82:             }
85: 83:         };
86: 84:         let refetch = ArcRwSignal::new(0);
87: 85: 
88: 86:         Self {
89: 87:             data: if cfg!(feature = "ssr") {
90: 88:                 ArcAsyncDerived::new_mock(fetcher)
91: 89:             } else {
92: 90:                 let refetch = refetch.clone();
93: 91:                 ArcAsyncDerived::new_unsync(move || {
94: 92:                     refetch.track();
95: 93:                     fetcher()
96: 94:                 })
97: 95:             },
98: 96:             refetch,
99: 97:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
100: 98:             defined_at: Location::caller(),
101: 99:         }
102: 100:     }
103: 101: 
104: 102:     /// Re-runs the async function.
105: 103:     pub fn refetch(&self) {
106: 104:         *self.refetch.write() += 1;
107: 105:     }
108: 106: 
109: 107:     /// Synchronously, reactively reads the current value of the resource and lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies the function
110: 108:     /// `f` to its value if it is `Some(_)`.
111: 109:     #[track_caller]
112: 110:     pub fn map<U>(&self, f: impl FnOnce(&T) -> U) -> Option<U>
113: 111:     where
114: 112:         T: 'static,
115: 113:     {
116: 114:         self.data.try_with(|n| n.as_ref().map(f))?
117: 115:     }
118: 116: }
119: 117: 
120: 118: impl<T, E> ArcLocalResource<Result<T, E>>
121: 119: where
122: 120:     T: 'static,
123: 121:     E: Clone + 'static,
124: 122: {
125: 123:     /// Applies the given function when a resource that returns `Result<T, E>`
126: 124:     /// has resolved and loaded an `Ok(_)`, rather than requiring nested `.map()`
127: 125:     /// calls over the `Option<Result<_, _>>` returned by the resource.
128: 126:     ///
129: 127:     /// This is useful when used with features like lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions, in conjunction
130: 128:     /// with `<ErrorBoundary/>` and `<Suspense/>`, when these other components are
131: 129:     /// left to handle the `None` and `Err(_)` states.
132: 130:     #[track_caller]
133: 131:     pub fn and_then<U>(&self, f: impl FnOnce(&T) -> U) -> Option<Result<U, E>> {
134: 132:         self.map(|data| data.as_ref().map(f).map_err(|e| e.clone()))
135: 133:     }
136: 134: }
137: 135: 
138: 136: impl<T> IntoFuture for ArcLocalResource<T>
139: 137: where
140: 138:     T: Clone + 'static,
141: 139: {
142: 140:     type Output = T;
143: 141:     type IntoFuture = AsyncDerivedFuture<T>;
144: 142: 
145: 143:     fn into_future(self) -> Self::IntoFuture {
146: 144:         if let Some(mut notifier) = use_context::<LocalResourceNotifier>() {
147: 145:             notifier.notify();
148: 146:         } else if cfg!(feature = "ssr") {
149: 147:             panic!(
150: 148:                 "Reading from a LocalResource outside Suspense in `ssr` mode \
151: 149:                  will cause the response to hang, because LocalResources are \
152: 150:                  always pending on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server."
153: 151:             );
154: 152:         }
155: 153:         self.data.into_future()
156: 154:     }
157: 155: }
158: 156: 
159: 157: impl<T> DefinedAt for ArcLocalResource<T> {
160: 158:     fn defined_at(&self) -> Option<&'static Location<'static>> {
161: 159:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
162: 160:         {
163: 161:             Some(self.defined_at)
164: 162:         }
165: 163:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
166: 164:         {
167: 165:             None
168: 166:         }
169: 167:     }
170: 168: }
171: 169: 
172: 170: impl<T> Notify for ArcLocalResource<T>
173: 171: where
174: 172:     T: 'static,
175: 173: {
176: 174:     fn notify(&self) {
177: 175:         self.data.notify()
178: 176:     }
179: 177: }
180: 178: 
181: 179: impl<T> Write for ArcLocalResource<T>
182: 180: where
183: 181:     T: 'static,
184: 182: {
185: 183:     type Value = Option<T>;
186: 184: 
187: 185:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
188: 186:         self.data.try_write()
189: 187:     }
190: 188: 
191: 189:     fn try_write_untracked(
192: 190:         &self,
193: 191:     ) -> Option<impl DerefMut<Target = Self::Value>> {
194: 192:         self.data.try_write_untracked()
195: 193:     }
196: 194: }
197: 195: 
198: 196: impl<T> ReadUntracked for ArcLocalResource<T>
199: 197: where
200: 198:     T: 'static,
201: 199: {
202: 200:     type Value =
203: 201:         ReadGuard<Option<T>, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<AsyncPlain<SendOption<T>>, Option<T>>>;
204: 202: 
205: 203:     fn try_read_untracked(&self) -> Option<Self::Value> {
206: 204:         if let Some(mut notifier) = use_context::<LocalResourceNotifier>() {
207: 205:             notifier.notify();
208: 206:         }
209: 207:         self.data.try_read_untracked()
210: 208:     }
211: 209: }
212: 210: 
213: 211: impl<T: 'static> IsDisposed for ArcLocalResource<T> {
214: 212:     #[inline(always)]
215: 213:     fn is_disposed(&self) -> bool {
216: 214:         false
217: 215:     }
218: 216: }
219: 217: 
220: 218: impl<T: 'static> ToAnySource for ArcLocalResource<T> {
221: 219:     fn to_any_source(&self) -> AnySource {
222: 220:         self.data.to_any_source()
223: 221:     }
224: 222: }
225: 223: 
226: 224: impl<T: 'static> ToAnySubscriber for ArcLocalResource<T> {
227: 225:     fn to_any_subscriber(&self) -> AnySubscriber {
228: 226:         self.data.to_any_subscriber()
229: 227:     }
230: 228: }
231: 229: 
232: 230: impl<T> Source for ArcLocalResource<T> {
233: 231:     fn add_subscriber(&self, subscriber: AnySubscriber) {
234: 232:         self.data.add_subscriber(subscriber)
235: 233:     }
236: 234: 
237: 235:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
238: 236:         self.data.remove_subscriber(subscriber);
239: 237:     }
240: 238: 
241: 239:     fn clear_subscribers(&self) {
242: 240:         self.data.clear_subscribers();
243: 241:     }
244: 242: }
245: 243: 
246: 244: impl<T> ReactiveNode for ArcLocalResource<T> {
247: 245:     fn mark_dirty(&self) {
248: 246:         self.data.mark_dirty();
249: 247:     }
250: 248: 
251: 249:     fn mark_check(&self) {
252: 250:         self.data.mark_check();
253: 251:     }
254: 252: 
255: 253:     fn mark_subscribers_check(&self) {
256: 254:         self.data.mark_subscribers_check();
257: 255:     }
258: 256: 
259: 257:     fn update_if_necessary(&self) -> bool {
260: 258:         self.data.update_if_necessary()
261: 259:     }
262: 260: }
263: 261: 
264: 262: impl<T> Subscriber for ArcLocalResource<T> {
265: 263:     fn add_source(&self, source: AnySource) {
266: 264:         self.data.add_source(source);
267: 265:     }
268: 266: 
269: 267:     fn clear_sources(&self, subscriber: &AnySubscriber) {
270: 268:         self.data.clear_sources(subscriber);
271: 269:     }
272: 270: }
273: 271: 
274: 272: /// A resource that only loads its data locally on the lyx-core-lyx_core_lyx-core-lyx_core_client.
275: 273: pub struct LocalResource<T> {
276: 274:     data: AsyncDerived<T>,
277: 275:     refetch: RwSignal<usize>,
278: 276:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
279: 277:     defined_at: &'static Location<'static>,
280: 278: }
281: 279: 
282: 280: impl<T> Deref for LocalResource<T> {
283: 281:     type Target = AsyncDerived<T>;
284: 282: 
285: 283:     fn deref(&self) -> &Self::Target {
286: 284:         &self.data
287: 285:     }
288: 286: }
289: 287: 
290: 288: impl<T> Clone for LocalResource<T> {
291: 289:     fn clone(&self) -> Self {
292: 290:         *self
293: 291:     }
294: 292: }
295: 293: 
296: 294: impl<T> Copy for LocalResource<T> {}
297: 295: 
298: 296: impl<T> LocalResource<T> {
299: 297:     /// Creates the resource.
300: 298:     ///
301: 299:     /// This will only begin loading data if you are on the lyx-core-lyx_core_lyx-core-lyx_core_client (i.e., if you do not have the
302: 300:     /// `ssr` feature activated).
303: 301:     #[track_caller]
304: 302:     pub fn new<Fut>(fetcher: impl Fn() -> Fut + 'static) -> Self
305: 303:     where
306: 304:         T: 'static,
307: 305:         Fut: Future<Output = T> + 'static,
308: 306:     {
309: 307:         let fetcher = move || {
310: 308:             let fut = fetcher();
311: 309:             async move {
312: 310:                 // in SSR mode, this will simply always be pending
313: 311:                 // if we try to read from it, we will trigger Suspense automatically to fall back
314: 312:                 // so this will never need to return anything
315: 313:                 if cfg!(feature = "ssr") {
316: 314:                     pending().await
317: 315:                 } else {
318: 316:                     // LocalResources that are immediately available can cause a hydration error,
319: 317:                     // because the future *looks* like it is already ready (and therefore would
320: 318:                     // already have been rendered to html on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server), but in fact was ignored
321: 319:                     // on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server. the simplest way to avoid this is to ensure that we always
322: 320:                     // wait a tick before resolving any value for a localresource.
323: 321:                     lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::tick().await;
324: 322:                     fut.await
325: 323:                 }
326: 324:             }
327: 325:         };
328: 326:         let refetch = RwSignal::new(0);
329: 327: 
330: 328:         Self {
331: 329:             data: if cfg!(feature = "ssr") {
332: 330:                 AsyncDerived::new_mock(fetcher)
333: 331:             } else {
334: 332:                 AsyncDerived::new_unsync_threadsafe_storage(move || {
335: 333:                     refetch.track();
336: 334:                     fetcher()
337: 335:                 })
338: 336:             },
339: 337:             refetch,
340: 338:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
341: 339:             defined_at: Location::caller(),
342: 340:         }
343: 341:     }
344: 342: 
345: 343:     /// Re-runs the async function.
346: 344:     pub fn refetch(&self) {
347: 345:         self.refetch.try_update(|n| *n += 1);
348: 346:     }
349: 347: 
350: 348:     /// Synchronously, reactively reads the current value of the resource and lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies the function
351: 349:     /// `f` to its value if it is `Some(_)`.
352: 350:     #[track_caller]
353: 351:     pub fn map<U>(&self, f: impl FnOnce(&T) -> U) -> Option<U>
354: 352:     where
355: 353:         T: 'static,
356: 354:     {
357: 355:         self.data.try_with(|n| n.as_ref().map(f))?
358: 356:     }
359: 357: }
360: 358: 
361: 359: impl<T, E> LocalResource<Result<T, E>>
362: 360: where
363: 361:     T: 'static,
364: 362:     E: Clone + 'static,
365: 363: {
366: 364:     /// Applies the given function when a resource that returns `Result<T, E>`
367: 365:     /// has resolved and loaded an `Ok(_)`, rather than requiring nested `.map()`
368: 366:     /// calls over the `Option<Result<_, _>>` returned by the resource.
369: 367:     ///
370: 368:     /// This is useful when used with features like lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions, in conjunction
371: 369:     /// with `<ErrorBoundary/>` and `<Suspense/>`, when these other components are
372: 370:     /// left to handle the `None` and `Err(_)` states.
373: 371:     #[track_caller]
374: 372:     pub fn and_then<U>(&self, f: impl FnOnce(&T) -> U) -> Option<Result<U, E>> {
375: 373:         self.map(|data| data.as_ref().map(f).map_err(|e| e.clone()))
376: 374:     }
377: 375: }
378: 376: 
379: 377: impl<T> IntoFuture for LocalResource<T>
380: 378: where
381: 379:     T: Clone + 'static,
382: 380: {
383: 381:     type Output = T;
384: 382:     type IntoFuture = AsyncDerivedFuture<T>;
385: 383: 
386: 384:     fn into_future(self) -> Self::IntoFuture {
387: 385:         if let Some(mut notifier) = use_context::<LocalResourceNotifier>() {
388: 386:             notifier.notify();
389: 387:         } else if cfg!(feature = "ssr") {
390: 388:             panic!(
391: 389:                 "Reading from a LocalResource outside Suspense in `ssr` mode \
392: 390:                  will cause the response to hang, because LocalResources are \
393: 391:                  always pending on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server."
394: 392:             );
395: 393:         }
396: 394:         self.data.into_future()
397: 395:     }
398: 396: }
399: 397: 
400: 398: impl<T> DefinedAt for LocalResource<T> {
401: 399:     fn defined_at(&self) -> Option<&'static Location<'static>> {
402: 400:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
403: 401:         {
404: 402:             Some(self.defined_at)
405: 403:         }
406: 404:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
407: 405:         {
408: 406:             None
409: 407:         }
410: 408:     }
411: 409: }
412: 410: 
413: 411: impl<T> Notify for LocalResource<T>
414: 412: where
415: 413:     T: 'static,
416: 414: {
417: 415:     fn notify(&self) {
418: 416:         self.data.notify()
419: 417:     }
420: 418: }
421: 419: 
422: 420: impl<T> Write for LocalResource<T>
423: 421: where
424: 422:     T: 'static,
425: 423: {
426: 424:     type Value = Option<T>;
427: 425: 
428: 426:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
429: 427:         self.data.try_write()
430: 428:     }
431: 429: 
432: 430:     fn try_write_untracked(
433: 431:         &self,
434: 432:     ) -> Option<impl DerefMut<Target = Self::Value>> {
435: 433:         self.data.try_write_untracked()
436: 434:     }
437: 435: }
438: 436: 
439: 437: impl<T> ReadUntracked for LocalResource<T>
440: 438: where
441: 439:     T: 'static,
442: 440: {
443: 441:     type Value =
444: 442:         ReadGuard<Option<T>, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<AsyncPlain<SendOption<T>>, Option<T>>>;
445: 443: 
446: 444:     fn try_read_untracked(&self) -> Option<Self::Value> {
447: 445:         if let Some(mut notifier) = use_context::<LocalResourceNotifier>() {
448: 446:             notifier.notify();
449: 447:         }
450: 448:         self.data.try_read_untracked()
451: 449:     }
452: 450: }
453: 451: 
454: 452: impl<T: 'static> IsDisposed for LocalResource<T> {
455: 453:     fn is_disposed(&self) -> bool {
456: 454:         self.data.is_disposed()
457: 455:     }
458: 456: }
459: 457: 
460: 458: impl<T: 'static> ToAnySource for LocalResource<T>
461: 459: where
462: 460:     T: 'static,
463: 461: {
464: 462:     fn to_any_source(&self) -> AnySource {
465: 463:         self.data.to_any_source()
466: 464:     }
467: 465: }
468: 466: 
469: 467: impl<T: 'static> ToAnySubscriber for LocalResource<T>
470: 468: where
471: 469:     T: 'static,
472: 470: {
473: 471:     fn to_any_subscriber(&self) -> AnySubscriber {
474: 472:         self.data.to_any_subscriber()
475: 473:     }
476: 474: }
477: 475: 
478: 476: impl<T> Source for LocalResource<T>
479: 477: where
480: 478:     T: 'static,
481: 479: {
482: 480:     fn add_subscriber(&self, subscriber: AnySubscriber) {
483: 481:         self.data.add_subscriber(subscriber)
484: 482:     }
485: 483: 
486: 484:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
487: 485:         self.data.remove_subscriber(subscriber);
488: 486:     }
489: 487: 
490: 488:     fn clear_subscribers(&self) {
491: 489:         self.data.clear_subscribers();
492: 490:     }
493: 491: }
494: 492: 
495: 493: impl<T> ReactiveNode for LocalResource<T>
496: 494: where
497: 495:     T: 'static,
498: 496: {
499: 497:     fn mark_dirty(&self) {
500: 498:         self.data.mark_dirty();
501: 499:     }
502: 500: 
503: 501:     fn mark_check(&self) {
504: 502:         self.data.mark_check();
505: 503:     }
506: 504: 
507: 505:     fn mark_subscribers_check(&self) {
508: 506:         self.data.mark_subscribers_check();
509: 507:     }
510: 508: 
511: 509:     fn update_if_necessary(&self) -> bool {
512: 510:         self.data.update_if_necessary()
513: 511:     }
514: 512: }
515: 513: 
516: 514: impl<T> Subscriber for LocalResource<T>
517: 515: where
518: 516:     T: 'static,
519: 517: {
520: 518:     fn add_source(&self, source: AnySource) {
521: 519:         self.data.add_source(source);
522: 520:     }
523: 521: 
524: 522:     fn clear_sources(&self, subscriber: &AnySubscriber) {
525: 523:         self.data.clear_sources(subscriber);
526: 524:     }
527: 525: }
528: 526: 
529: 527: impl<T: 'static> From<ArcLocalResource<T>> for LocalResource<T> {
530: 528:     fn from(arc: ArcLocalResource<T>) -> Self {
531: 529:         Self {
532: 530:             data: arc.data.into(),
533: 531:             refetch: arc.refetch.into(),
534: 532:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
535: 533:             defined_at: arc.defined_at,
536: 534:         }
537: 535:     }
538: 536: }
539: 537: 
540: 538: impl<T: 'static> From<LocalResource<T>> for ArcLocalResource<T> {
541: 539:     fn from(local: LocalResource<T>) -> Self {
542: 540:         Self {
543: 541:             data: local.data.into(),
544: 542:             refetch: local.refetch.into(),
545: 543:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
546: 544:             defined_at: local.defined_at,
547: 545:         }
548: 546:     }
549: 547: }
550: ```
```
