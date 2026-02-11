### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\guards.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\guards.rs
2: ```rust
3: 1: //! Guards that integrate with the reactive system, wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping references to the values of signals.
4: 2: 
5: 3: use crate::{
6: 4:     computed::BlockingLock,
7: 5:     traits::{Notify, UntrackableGuard},
8: 6: };
9: 7: use core::fmt::Debug;
10: 8: use guardian::{ArcRwLockReadGuardian, ArcRwLockWriteGuardian};
11: 9: use std::{
12: 10:     borrow::Borrow,
13: 11:     fmt::Display,
14: 12:     marker::PhantomData,
15: 13:     ops::{Deref, DerefMut},
16: 14:     sync::{Arc, RwLock},
17: 15: };
18: 16: 
19: 17: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper type for any kind of guard returned by [`Read`](crate::traits::Read).
20: 18: ///
21: 19: /// If `Inner` implements `Deref`, so does `ReadGuard<_, Inner>`.
22: 20: #[derive(Debug)]
23: 21: pub struct ReadGuard<T, Inner> {
24: 22:     ty: PhantomData<T>,
25: 23:     inner: Inner,
26: 24: }
27: 25: 
28: 26: impl<T, Inner> ReadGuard<T, Inner> {
29: 27:     /// Creates a new wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper around another guard type.
30: 28:     pub fn new(inner: Inner) -> Self {
31: 29:         Self {
32: 30:             inner,
33: 31:             ty: PhantomData,
34: 32:         }
35: 33:     }
36: 34: 
37: 35:     /// Returns the inner guard type.
38: 36:     pub fn into_inner(self) -> Inner {
39: 37:         self.inner
40: 38:     }
41: 39: }
42: 40: 
43: 41: impl<T, Inner> Clone for ReadGuard<T, Inner>
44: 42: where
45: 43:     Inner: Clone,
46: 44: {
47: 45:     fn clone(&self) -> Self {
48: 46:         Self {
49: 47:             ty: self.ty,
50: 48:             inner: self.inner.clone(),
51: 49:         }
52: 50:     }
53: 51: }
54: 52: 
55: 53: impl<T, Inner> Deref for ReadGuard<T, Inner>
56: 54: where
57: 55:     Inner: Deref<Target = T>,
58: 56: {
59: 57:     type Target = T;
60: 58: 
61: 59:     fn deref(&self) -> &Self::Target {
62: 60:         self.inner.deref()
63: 61:     }
64: 62: }
65: 63: 
66: 64: impl<T, Inner> Borrow<T> for ReadGuard<T, Inner>
67: 65: where
68: 66:     Inner: Deref<Target = T>,
69: 67: {
70: 68:     fn borrow(&self) -> &T {
71: 69:         self.deref()
72: 70:     }
73: 71: }
74: 72: 
75: 73: impl<T, Inner> PartialEq<T> for ReadGuard<T, Inner>
76: 74: where
77: 75:     Inner: Deref<Target = T>,
78: 76:     T: PartialEq,
79: 77: {
80: 78:     fn eq(&self, other: &Inner::Target) -> bool {
81: 79:         self.deref() == other
82: 80:     }
83: 81: }
84: 82: 
85: 83: impl<T, Inner> Display for ReadGuard<T, Inner>
86: 84: where
87: 85:     Inner: Deref<Target = T>,
88: 86:     T: Display,
89: 87: {
90: 88:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
91: 89:         Display::fmt(&**self, f)
92: 90:     }
93: 91: }
94: 92: 
95: 93: /// A guard that provides access to a signal's inner value.
96: 94: pub struct Plain<T: 'static> {
97: 95:     guard: ArcRwLockReadGuardian<T>,
98: 96: }
99: 97: 
100: 98: impl<T: 'static> Debug for Plain<T> {
101: 99:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
102: 100:         f.debug_struct("Plain").finish()
103: 101:     }
104: 102: }
105: 103: 
106: 104: impl<T: 'static> Plain<T> {
107: 105:     /// Takes a reference-counted read guard on the given lock.
108: 106:     pub fn try_new(inner: Arc<RwLock<T>>) -> Option<Self> {
109: 107:         ArcRwLockReadGuardian::try_take(inner)?
110: 108:             .ok()
111: 109:             .map(|guard| Plain { guard })
112: 110:     }
113: 111: }
114: 112: 
115: 113: impl<T> Deref for Plain<T> {
116: 114:     type Target = T;
117: 115: 
118: 116:     fn deref(&self) -> &Self::Target {
119: 117:         self.guard.deref()
120: 118:     }
121: 119: }
122: 120: 
123: 121: impl<T: PartialEq> PartialEq for Plain<T> {
124: 122:     fn eq(&self, other: &Self) -> bool {
125: 123:         **self == **other
126: 124:     }
127: 125: }
128: 126: 
129: 127: impl<T: PartialEq> PartialEq<T> for Plain<T> {
130: 128:     fn eq(&self, other: &T) -> bool {
131: 129:         **self == *other
132: 130:     }
133: 131: }
134: 132: 
135: 133: impl<T: Display> Display for Plain<T> {
136: 134:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
137: 135:         Display::fmt(&**self, f)
138: 136:     }
139: 137: }
140: 138: 
141: 139: /// A guard that provides access to an async signal's value.
142: 140: pub struct AsyncPlain<T: 'static> {
143: 141:     pub(crate) guard: async_lock::RwLockReadGuardArc<T>,
144: 142: }
145: 143: 
146: 144: impl<T: 'static> Debug for AsyncPlain<T> {
147: 145:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
148: 146:         f.debug_struct("AsyncPlain").finish()
149: 147:     }
150: 148: }
151: 149: 
152: 150: impl<T: 'static> AsyncPlain<T> {
153: 151:     /// Takes a reference-counted async read guard on the given lock.
154: 152:     pub fn try_new(inner: &Arc<async_lock::RwLock<T>>) -> Option<Self> {
155: 153:         Some(Self {
156: 154:             guard: inner.blocking_read_arc(),
157: 155:         })
158: 156:     }
159: 157: }
160: 158: 
161: 159: impl<T> Deref for AsyncPlain<T> {
162: 160:     type Target = T;
163: 161: 
164: 162:     fn deref(&self) -> &Self::Target {
165: 163:         self.guard.deref()
166: 164:     }
167: 165: }
168: 166: 
169: 167: impl<T: PartialEq> PartialEq for AsyncPlain<T> {
170: 168:     fn eq(&self, other: &Self) -> bool {
171: 169:         **self == **other
172: 170:     }
173: 171: }
174: 172: 
175: 173: impl<T: PartialEq> PartialEq<T> for AsyncPlain<T> {
176: 174:     fn eq(&self, other: &T) -> bool {
177: 175:         **self == *other
178: 176:     }
179: 177: }
180: 178: 
181: 179: impl<T: Display> Display for AsyncPlain<T> {
182: 180:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
183: 181:         Display::fmt(&**self, f)
184: 182:     }
185: 183: }
186: 184: 
187: 185: /// A guard that maps over another guard.
188: 186: #[derive(Debug)]
189: 187: pub struct Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner, U>
190: 188: where
191: 189:     Inner: Deref,
192: 190: {
193: 191:     inner: Inner,
194: 192:     map_fn: fn(&Inner::Target) -> &U,
195: 193: }
196: 194: 
197: 195: impl<T: 'static, U> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Plain<T>, U> {
198: 196:     /// Creates a mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped read guard from the inner lock.
199: 197:     pub fn try_new(
200: 198:         inner: Arc<RwLock<T>>,
201: 199:         map_fn: fn(&T) -> &U,
202: 200:     ) -> Option<Self> {
203: 201:         let inner = Plain::try_new(inner)?;
204: 202:         Some(Self { inner, map_fn })
205: 203:     }
206: 204: }
207: 205: 
208: 206: impl<Inner, U> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner, U>
209: 207: where
210: 208:     Inner: Deref,
211: 209: {
212: 210:     /// Creates a mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped read guard from the inner guard.
213: 211:     pub fn new_with_guard(
214: 212:         inner: Inner,
215: 213:         map_fn: fn(&Inner::Target) -> &U,
216: 214:     ) -> Self {
217: 215:         Self { inner, map_fn }
218: 216:     }
219: 217: }
220: 218: 
221: 219: impl<Inner, U> Deref for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner, U>
222: 220: where
223: 221:     Inner: Deref,
224: 222: {
225: 223:     type Target = U;
226: 224: 
227: 225:     fn deref(&self) -> &Self::Target {
228: 226:         (self.map_fn)(self.inner.deref())
229: 227:     }
230: 228: }
231: 229: 
232: 230: impl<Inner, U: PartialEq> PartialEq for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner, U>
233: 231: where
234: 232:     Inner: Deref,
235: 233: {
236: 234:     fn eq(&self, other: &Self) -> bool {
237: 235:         **self == **other
238: 236:     }
239: 237: }
240: 238: 
241: 239: impl<Inner, U: PartialEq> PartialEq<U> for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner, U>
242: 240: where
243: 241:     Inner: Deref,
244: 242: {
245: 243:     fn eq(&self, other: &U) -> bool {
246: 244:         **self == *other
247: 245:     }
248: 246: }
249: 247: 
250: 248: impl<Inner, U: Display> Display for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner, U>
251: 249: where
252: 250:     Inner: Deref,
253: 251: {
254: 252:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
255: 253:         Display::fmt(&**self, f)
256: 254:     }
257: 255: }
258: 256: 
259: 257: /// A guard that provides mutable access to a signal's value, triggering some reactive change
260: 258: /// when it is dropped.
261: 259: #[derive(Debug)]
262: 260: pub struct WriteGuard<S, G>
263: 261: where
264: 262:     S: Notify,
265: 263: {
266: 264:     pub(crate) triggerable: Option<S>,
267: 265:     pub(crate) guard: Option<G>,
268: 266: }
269: 267: 
270: 268: impl<S, G> WriteGuard<S, G>
271: 269: where
272: 270:     S: Notify,
273: 271: {
274: 272:     /// Creates a new guard from the inner mutable guard type, and the signal that should be
275: 273:     /// triggered on drop.
276: 274:     pub fn new(triggerable: S, guard: G) -> Self {
277: 275:         Self {
278: 276:             triggerable: Some(triggerable),
279: 277:             guard: Some(guard),
280: 278:         }
281: 279:     }
282: 280: }
283: 281: 
284: 282: impl<S, G> UntrackableGuard for WriteGuard<S, G>
285: 283: where
286: 284:     S: Notify,
287: 285:     G: DerefMut,
288: 286: {
289: 287:     /// Removes the triggerable type, so that it is no longer notifies when dropped.
290: 288:     fn untrack(&mut self) {
291: 289:         self.triggerable.take();
292: 290:     }
293: 291: }
294: 292: 
295: 293: impl<S, G> Deref for WriteGuard<S, G>
296: 294: where
297: 295:     S: Notify,
298: 296:     G: Deref,
299: 297: {
300: 298:     type Target = G::Target;
301: 299: 
302: 300:     fn deref(&self) -> &Self::Target {
303: 301:         self.guard
304: 302:             .as_ref()
305: 303:             .expect(
306: 304:                 "the guard should always be in place until the Drop \
307: 305:                  implementation",
308: 306:             )
309: 307:             .deref()
310: 308:     }
311: 309: }
312: 310: 
313: 311: impl<S, G> DerefMut for WriteGuard<S, G>
314: 312: where
315: 313:     S: Notify,
316: 314:     G: DerefMut,
317: 315: {
318: 316:     fn deref_mut(&mut self) -> &mut Self::Target {
319: 317:         self.guard
320: 318:             .as_mut()
321: 319:             .expect(
322: 320:                 "the guard should always be in place until the Drop \
323: 321:                  implementation",
324: 322:             )
325: 323:             .deref_mut()
326: 324:     }
327: 325: }
328: 326: 
329: 327: /// A guard that provides mutable access to a signal's inner value, but does not notify of any
330: 328: /// changes.
331: 329: pub struct UntrackedWriteGuard<T: 'static>(ArcRwLockWriteGuardian<T>);
332: 330: 
333: 331: impl<T: 'static> UntrackedWriteGuard<T> {
334: 332:     /// Creates a write guard from the given lock.
335: 333:     pub fn try_new(inner: Arc<RwLock<T>>) -> Option<Self> {
336: 334:         ArcRwLockWriteGuardian::try_take(inner)?
337: 335:             .ok()
338: 336:             .map(UntrackedWriteGuard)
339: 337:     }
340: 338: }
341: 339: 
342: 340: impl<T> Deref for UntrackedWriteGuard<T> {
343: 341:     type Target = T;
344: 342: 
345: 343:     fn deref(&self) -> &Self::Target {
346: 344:         self.0.deref()
347: 345:     }
348: 346: }
349: 347: 
350: 348: impl<T> DerefMut for UntrackedWriteGuard<T> {
351: 349:     fn deref_mut(&mut self) -> &mut Self::Target {
352: 350:         self.0.deref_mut()
353: 351:     }
354: 352: }
355: 353: 
356: 354: // Dropping the write guard will notify dependencies.
357: 355: impl<S, T> Drop for WriteGuard<S, T>
358: 356: where
359: 357:     S: Notify,
360: 358: {
361: 359:     fn drop(&mut self) {
362: 360:         // first, drop the inner guard
363: 361:         drop(self.guard.take());
364: 362: 
365: 363:         // then, notify about a change
366: 364:         if let Some(triggerable) = self.triggerable.as_ref() {
367: 365:             triggerable.notify();
368: 366:         }
369: 367:     }
370: 368: }
371: 369: 
372: 370: /// A mutable guard that maps over an inner mutable guard.
373: 371: #[derive(Debug)]
374: 372: pub struct Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<Inner, U>
375: 373: where
376: 374:     Inner: Deref,
377: 375: {
378: 376:     inner: Inner,
379: 377:     map_fn: fn(&Inner::Target) -> &U,
380: 378:     map_fn_mut: fn(&mut Inner::Target) -> &mut U,
381: 379: }
382: 380: 
383: 381: impl<Inner, U> UntrackableGuard for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<Inner, U>
384: 382: where
385: 383:     Inner: UntrackableGuard,
386: 384: {
387: 385:     fn untrack(&mut self) {
388: 386:         self.inner.untrack();
389: 387:     }
390: 388: }
391: 389: 
392: 390: impl<Inner, U> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<Inner, U>
393: 391: where
394: 392:     Inner: DerefMut,
395: 393: {
396: 394:     /// Creates a new writable guard from the inner guard.
397: 395:     pub fn new(
398: 396:         inner: Inner,
399: 397:         map_fn: fn(&Inner::Target) -> &U,
400: 398:         map_fn_mut: fn(&mut Inner::Target) -> &mut U,
401: 399:     ) -> Self {
402: 400:         Self {
403: 401:             inner,
404: 402:             map_fn,
405: 403:             map_fn_mut,
406: 404:         }
407: 405:     }
408: 406: }
409: 407: 
410: 408: impl<Inner, U> Deref for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<Inner, U>
411: 409: where
412: 410:     Inner: Deref,
413: 411: {
414: 412:     type Target = U;
415: 413: 
416: 414:     fn deref(&self) -> &Self::Target {
417: 415:         (self.map_fn)(self.inner.deref())
418: 416:     }
419: 417: }
420: 418: 
421: 419: impl<Inner, U> DerefMut for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<Inner, U>
422: 420: where
423: 421:     Inner: DerefMut,
424: 422: {
425: 423:     fn deref_mut(&mut self) -> &mut Self::Target {
426: 424:         (self.map_fn_mut)(self.inner.deref_mut())
427: 425:     }
428: 426: }
429: 427: 
430: 428: impl<Inner, U: PartialEq> PartialEq for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<Inner, U>
431: 429: where
432: 430:     Inner: Deref,
433: 431: {
434: 432:     fn eq(&self, other: &Self) -> bool {
435: 433:         **self == **other
436: 434:     }
437: 435: }
438: 436: 
439: 437: impl<Inner, U: Display> Display for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<Inner, U>
440: 438: where
441: 439:     Inner: Deref,
442: 440: {
443: 441:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
444: 442:         Display::fmt(&**self, f)
445: 443:     }
446: 444: }
447: 445: 
448: 446: /// A mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped read guard in which the mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping function is a closure. If the mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping function is a
449: 447: /// function pointer, use [`Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped`].
450: 448: pub struct Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc<Inner, U>
451: 449: where
452: 450:     Inner: Deref,
453: 451: {
454: 452:     inner: Inner,
455: 453:     #[allow(clippy::type_complexity)]
456: 454:     map_fn: Arc<dyn Fn(&Inner::Target) -> &U>,
457: 455: }
458: 456: 
459: 457: impl<Inner, U> Clone for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc<Inner, U>
460: 458: where
461: 459:     Inner: Clone + Deref,
462: 460: {
463: 461:     fn clone(&self) -> Self {
464: 462:         Self {
465: 463:             inner: self.inner.clone(),
466: 464:             map_fn: self.map_fn.clone(),
467: 465:         }
468: 466:     }
469: 467: }
470: 468: 
471: 469: impl<Inner, U> Debug for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc<Inner, U>
472: 470: where
473: 471:     Inner: Debug + Deref,
474: 472: {
475: 473:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
476: 474:         f.debug_struct("Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc")
477: 475:             .field("inner", &self.inner)
478: 476:             .finish_non_exhaustive()
479: 477:     }
480: 478: }
481: 479: 
482: 480: impl<Inner, U> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc<Inner, U>
483: 481: where
484: 482:     Inner: Deref,
485: 483: {
486: 484:     /// Creates a new mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped guard from the inner guard and the map function.
487: 485:     pub fn new(
488: 486:         inner: Inner,
489: 487:         map_fn: impl Fn(&Inner::Target) -> &U + 'static,
490: 488:     ) -> Self {
491: 489:         Self {
492: 490:             inner,
493: 491:             map_fn: Arc::new(map_fn),
494: 492:         }
495: 493:     }
496: 494: }
497: 495: 
498: 496: impl<Inner, U> Deref for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc<Inner, U>
499: 497: where
500: 498:     Inner: Deref,
501: 499: {
502: 500:     type Target = U;
503: 501: 
504: 502:     fn deref(&self) -> &Self::Target {
505: 503:         (self.map_fn)(self.inner.deref())
506: 504:     }
507: 505: }
508: 506: 
509: 507: impl<Inner, U: PartialEq> PartialEq for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc<Inner, U>
510: 508: where
511: 509:     Inner: Deref,
512: 510: {
513: 511:     fn eq(&self, other: &Self) -> bool {
514: 512:         **self == **other
515: 513:     }
516: 514: }
517: 515: 
518: 516: impl<Inner, U: Display> Display for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedArc<Inner, U>
519: 517: where
520: 518:     Inner: Deref,
521: 519: {
522: 520:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
523: 521:         Display::fmt(&**self, f)
524: 522:     }
525: 523: }
526: 524: 
527: 525: /// A mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped write guard in which the mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping function is a closure. If the mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping function is a
528: 526: /// function pointer, use [`Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut`].
529: 527: pub struct Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
530: 528: where
531: 529:     Inner: Deref,
532: 530: {
533: 531:     inner: Inner,
534: 532:     #[allow(clippy::type_complexity)]
535: 533:     map_fn: Arc<dyn Fn(&Inner::Target) -> &U>,
536: 534:     #[allow(clippy::type_complexity)]
537: 535:     map_fn_mut: Arc<dyn Fn(&mut Inner::Target) -> &mut U>,
538: 536: }
539: 537: 
540: 538: impl<Inner, U> Clone for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
541: 539: where
542: 540:     Inner: Clone + Deref,
543: 541: {
544: 542:     fn clone(&self) -> Self {
545: 543:         Self {
546: 544:             inner: self.inner.clone(),
547: 545:             map_fn: self.map_fn.clone(),
548: 546:             map_fn_mut: self.map_fn_mut.clone(),
549: 547:         }
550: 548:     }
551: 549: }
552: 550: 
553: 551: impl<Inner, U> Debug for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
554: 552: where
555: 553:     Inner: Debug + Deref,
556: 554: {
557: 555:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
558: 556:         f.debug_struct("Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc")
559: 557:             .field("inner", &self.inner)
560: 558:             .finish_non_exhaustive()
561: 559:     }
562: 560: }
563: 561: 
564: 562: impl<Inner, U> UntrackableGuard for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
565: 563: where
566: 564:     Inner: UntrackableGuard,
567: 565: {
568: 566:     fn untrack(&mut self) {
569: 567:         self.inner.untrack();
570: 568:     }
571: 569: }
572: 570: 
573: 571: impl<Inner, U> Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
574: 572: where
575: 573:     Inner: Deref,
576: 574: {
577: 575:     /// Creates the new mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped mutable guard from the inner guard and mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping functions.
578: 576:     pub fn new(
579: 577:         inner: Inner,
580: 578:         map_fn: impl Fn(&Inner::Target) -> &U + 'static,
581: 579:         map_fn_mut: impl Fn(&mut Inner::Target) -> &mut U + 'static,
582: 580:     ) -> Self {
583: 581:         Self {
584: 582:             inner,
585: 583:             map_fn: Arc::new(map_fn),
586: 584:             map_fn_mut: Arc::new(map_fn_mut),
587: 585:         }
588: 586:     }
589: 587: }
590: 588: 
591: 589: impl<Inner, U> Deref for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
592: 590: where
593: 591:     Inner: Deref,
594: 592: {
595: 593:     type Target = U;
596: 594: 
597: 595:     fn deref(&self) -> &Self::Target {
598: 596:         (self.map_fn)(self.inner.deref())
599: 597:     }
600: 598: }
601: 599: 
602: 600: impl<Inner, U> DerefMut for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
603: 601: where
604: 602:     Inner: DerefMut,
605: 603: {
606: 604:     fn deref_mut(&mut self) -> &mut Self::Target {
607: 605:         (self.map_fn_mut)(self.inner.deref_mut())
608: 606:     }
609: 607: }
610: 608: 
611: 609: impl<Inner, U: PartialEq> PartialEq for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
612: 610: where
613: 611:     Inner: Deref,
614: 612: {
615: 613:     fn eq(&self, other: &Self) -> bool {
616: 614:         **self == **other
617: 615:     }
618: 616: }
619: 617: 
620: 618: impl<Inner, U: Display> Display for Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<Inner, U>
621: 619: where
622: 620:     Inner: Deref,
623: 621: {
624: 622:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
625: 623:         Display::fmt(&**self, f)
626: 624:     }
627: 625: }
628: 626: 
629: 627: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper that implements [`Deref`] and [`Borrow`] for itself.
630: 628: pub struct Derefable<T>(pub T);
631: 629: 
632: 630: impl<T> Clone for Derefable<T>
633: 631: where
634: 632:     T: Clone,
635: 633: {
636: 634:     fn clone(&self) -> Self {
637: 635:         Derefable(self.0.clone())
638: 636:     }
639: 637: }
640: 638: 
641: 639: impl<T> std::ops::Deref for Derefable<T> {
642: 640:     type Target = T;
643: 641:     fn deref(&self) -> &Self::Target {
644: 642:         &self.0
645: 643:     }
646: 644: }
647: 645: 
648: 646: impl<T> Borrow<T> for Derefable<T> {
649: 647:     fn borrow(&self) -> &T {
650: 648:         self.deref()
651: 649:     }
652: 650: }
653: 651: 
654: 652: impl<T> PartialEq<T> for Derefable<T>
655: 653: where
656: 654:     T: PartialEq,
657: 655: {
658: 656:     fn eq(&self, other: &T) -> bool {
659: 657:         self.deref() == other
660: 658:     }
661: 659: }
662: 660: 
663: 661: impl<T> Display for Derefable<T>
664: 662: where
665: 663:     T: Display,
666: 664: {
667: 665:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
668: 666:         Display::fmt(&**self, f)
669: 667:     }
670: 668: }
671: ```
```
