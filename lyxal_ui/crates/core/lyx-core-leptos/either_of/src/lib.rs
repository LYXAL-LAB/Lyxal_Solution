### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_either_of\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_either_of\src\lib.rs
2: ```rust
3: 1: #![cfg_attr(feature = "no_std", no_std)]
4: 2: #![forbid(unsafe_code)]
5: 3: 
6: 4: //! Utilities for working with enumerated types that contain one of `2..n` other types.
7: 5: 
8: 6: use core::{
9: 7:     cmp::Ordering,
10: 8:     fmt::Display,
11: 9:     future::Future,
12: 10:     iter::{Product, Sum},
13: 11:     pin::Pin,
14: 12:     task::{Context, Poll},
15: 13: };
16: 14: use paste::paste;
17: 15: use pin_project_lite::pin_project;
18: 16: #[cfg(not(feature = "no_std"))]
19: 17: use std::error::Error; // TODO: replace with core::error::Error once MSRV is >= 1.81.0
20: 18: 
21: 19: macro_rules! tuples {
22: 20:     ($name:ident + $fut_name:ident + $fut_proj:ident {
23: 21:         $($ty:ident => ($($rest_variant:ident),*) + <$($mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped_ty:ident),+>),+$(,)?
24: 22:     }) => {
25: 23:         tuples!($name + $fut_name + $fut_proj {
26: 24:             $($ty($ty) => ($($rest_variant),*) + <$($mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped_ty),+>),+
27: 25:         });
28: 26:     };
29: 27:     ($name:ident + $fut_name:ident + $fut_proj:ident {
30: 28:         $($variant:ident($ty:ident) => ($($rest_variant:ident),*) + <$($mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped_ty:ident),+>),+$(,)?
31: 29:     }) => {
32: 30:         #[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
33: 31:         pub enum $name<$($ty),+> {
34: 32:             $($variant ($ty),)+
35: 33:         }
36: 34: 
37: 35:         impl<$($ty),+> $name<$($ty),+> {
38: 36:             paste! {
39: 37:                 #[allow(clippy::too_many_arguments)]
40: 38:                 pub fn map<$([<F $ty>]),+, $([<$ty 1>]),+>(self, $([<$variant:lower>]: [<F $ty>]),+) -> $name<$([<$ty 1>]),+>
41: 39:                 where
42: 40:                     $([<F $ty>]: FnOnce($ty) -> [<$ty 1>],)+
43: 41:                 {
44: 42:                     match self {
45: 43:                         $($name::$variant(inner) => $name::$variant([<$variant:lower>](inner)),)+
46: 44:                     }
47: 45:                 }
48: 46: 
49: 47:                 $(
50: 48:                     pub fn [<map_ $variant:lower>]<Fun, [<$ty 1>]>(self, f: Fun) -> $name<$($mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped_ty),+>
51: 49:                     where
52: 50:                         Fun: FnOnce($ty) -> [<$ty 1>],
53: 51:                     {
54: 52:                         match self {
55: 53:                             $name::$variant(inner) => $name::$variant(f(inner)),
56: 54:                             $($name::$rest_variant(inner) => $name::$rest_variant(inner),)*
57: 55:                         }
58: 56:                     }
59: 57: 
60: 58:                     pub fn [<inspect_ $variant:lower>]<Fun, [<$ty 1>]>(self, f: Fun) -> Self
61: 59:                     where
62: 60:                         Fun: FnOnce(&$ty),
63: 61:                     {
64: 62:                         if let $name::$variant(inner) = &self {
65: 63:                             f(inner);
66: 64:                         }
67: 65:                         self
68: 66:                     }
69: 67: 
70: 68:                     pub fn [<is_ $variant:lower>](&self) -> bool {
71: 69:                         matches!(self, $name::$variant(_))
72: 70:                     }
73: 71: 
74: 72:                     pub fn [<as_ $variant:lower>](&self) -> Option<&$ty> {
75: 73:                         match self {
76: 74:                             $name::$variant(inner) => Some(inner),
77: 75:                             _ => None,
78: 76:                         }
79: 77:                     }
80: 78: 
81: 79:                     pub fn [<as_ $variant:lower _mut>](&mut self) -> Option<&mut $ty> {
82: 80:                         match self {
83: 81:                             $name::$variant(inner) => Some(inner),
84: 82:                             _ => None,
85: 83:                         }
86: 84:                     }
87: 85: 
88: 86:                     pub fn [<unwrap_ $variant:lower>](self) -> $ty {
89: 87:                         match self {
90: 88:                             $name::$variant(inner) => inner,
91: 89:                             _ => panic!(concat!(
92: 90:                                 "called `unwrap_", stringify!([<$variant:lower>]), "()` on a non-`", stringify!($variant), "` variant of `", stringify!($name), "`"
93: 91:                             )),
94: 92:                         }
95: 93:                     }
96: 94: 
97: 95:                     pub fn [<into_ $variant:lower>](self) -> Result<$ty, Self> {
98: 96:                         match self {
99: 97:                             $name::$variant(inner) => Ok(inner),
100: 98:                             _ => Err(self),
101: 99:                         }
102: 100:                     }
103: 101:                 )+
104: 102:             }
105: 103:         }
106: 104: 
107: 105:         impl<$($ty),+> Display for $name<$($ty),+>
108: 106:         where
109: 107:             $($ty: Display,)+
110: 108:         {
111: 109:             fn fmt(&self, f: &mut core::fmt::Formatter<'_>) -> core::fmt::Result {
112: 110:                 match self {
113: 111:                     $($name::$variant(this) => this.fmt(f),)+
114: 112:                 }
115: 113:             }
116: 114:         }
117: 115: 
118: 116:         #[cfg(not(feature = "no_std"))]
119: 117:         impl<$($ty),+> Error for $name<$($ty),+>
120: 118:         where
121: 119:             $($ty: Error,)+
122: 120:         {
123: 121:             fn source(&self) -> Option<&(dyn Error + 'static)> {
124: 122:                 match self {
125: 123:                     $($name::$variant(this) => this.source(),)+
126: 124:                 }
127: 125:             }
128: 126:         }
129: 127: 
130: 128:         impl<Item, $($ty),+> Iterator for $name<$($ty),+>
131: 129:         where
132: 130:             $($ty: Iterator<Item = Item>,)+
133: 131:         {
134: 132:             type Item = Item;
135: 133: 
136: 134:             fn next(&mut self) -> Option<Self::Item> {
137: 135:                 match self {
138: 136:                     $($name::$variant(i) => i.next(),)+
139: 137:                 }
140: 138:             }
141: 139: 
142: 140:             fn size_hint(&self) -> (usize, Option<usize>) {
143: 141:                 match self {
144: 142:                     $($name::$variant(i) => i.size_hint(),)+
145: 143:                 }
146: 144:             }
147: 145: 
148: 146:             fn count(self) -> usize
149: 147:             where
150: 148:                 Self: Sized,
151: 149:             {
152: 150:                 match self {
153: 151:                     $($name::$variant(i) => i.count(),)+
154: 152:                 }
155: 153:             }
156: 154: 
157: 155:             fn last(self) -> Option<Self::Item>
158: 156:             where
159: 157:                 Self: Sized,
160: 158:             {
161: 159:                 match self {
162: 160:                     $($name::$variant(i) => i.last(),)+
163: 161:                 }
164: 162:             }
165: 163: 
166: 164:             fn nth(&mut self, n: usize) -> Option<Self::Item> {
167: 165:                 match self {
168: 166:                     $($name::$variant(i) => i.nth(n),)+
169: 167:                 }
170: 168:             }
171: 169: 
172: 170:             fn for_each<Fun>(self, f: Fun)
173: 171:             where
174: 172:                 Self: Sized,
175: 173:                 Fun: FnMut(Self::Item),
176: 174:             {
177: 175:                 match self {
178: 176:                     $($name::$variant(i) => i.for_each(f),)+
179: 177:                 }
180: 178:             }
181: 179: 
182: 180:             fn collect<Col: FromIterator<Self::Item>>(self) -> Col
183: 181:             where
184: 182:                 Self: Sized,
185: 183:             {
186: 184:                 match self {
187: 185:                     $($name::$variant(i) => i.collect(),)+
188: 186:                 }
189: 187:             }
190: 188: 
191: 189:             fn partition<Col, Fun>(self, f: Fun) -> (Col, Col)
192: 190:             where
193: 191:                 Self: Sized,
194: 192:                 Col: Default + Extend<Self::Item>,
195: 193:                 Fun: FnMut(&Self::Item) -> bool,
196: 194:             {
197: 195:                 match self {
198: 196:                     $($name::$variant(i) => i.partition(f),)+
199: 197:                 }
200: 198:             }
201: 199: 
202: 200:             fn fold<Acc, Fun>(self, init: Acc, f: Fun) -> Acc
203: 201:             where
204: 202:                 Self: Sized,
205: 203:                 Fun: FnMut(Acc, Self::Item) -> Acc,
206: 204:             {
207: 205:                 match self {
208: 206:                     $($name::$variant(i) => i.fold(init, f),)+
209: 207:                 }
210: 208:             }
211: 209: 
212: 210:             fn reduce<Fun>(self, f: Fun) -> Option<Self::Item>
213: 211:             where
214: 212:                 Self: Sized,
215: 213:                 Fun: FnMut(Self::Item, Self::Item) -> Self::Item,
216: 214:             {
217: 215:                 match self {
218: 216:                     $($name::$variant(i) => i.reduce(f),)+
219: 217:                 }
220: 218:             }
221: 219: 
222: 220:             fn all<Fun>(&mut self, f: Fun) -> bool
223: 221:             where
224: 222:                 Self: Sized,
225: 223:                 Fun: FnMut(Self::Item) -> bool,
226: 224:             {
227: 225:                 match self {
228: 226:                     $($name::$variant(i) => i.all(f),)+
229: 227:                 }
230: 228:             }
231: 229: 
232: 230:             fn any<Fun>(&mut self, f: Fun) -> bool
233: 231:             where
234: 232:                 Self: Sized,
235: 233:                 Fun: FnMut(Self::Item) -> bool,
236: 234:             {
237: 235:                 match self {
238: 236:                     $($name::$variant(i) => i.any(f),)+
239: 237:                 }
240: 238:             }
241: 239: 
242: 240:             fn find<Pre>(&mut self, predicate: Pre) -> Option<Self::Item>
243: 241:             where
244: 242:                 Self: Sized,
245: 243:                 Pre: FnMut(&Self::Item) -> bool,
246: 244:             {
247: 245:                 match self {
248: 246:                     $($name::$variant(i) => i.find(predicate),)+
249: 247:                 }
250: 248:             }
251: 249: 
252: 250:             fn find_map<Out, Fun>(&mut self, f: Fun) -> Option<Out>
253: 251:             where
254: 252:                 Self: Sized,
255: 253:                 Fun: FnMut(Self::Item) -> Option<Out>,
256: 254:             {
257: 255:                 match self {
258: 256:                     $($name::$variant(i) => i.find_map(f),)+
259: 257:                 }
260: 258:             }
261: 259: 
262: 260:             fn position<Pre>(&mut self, predicate: Pre) -> Option<usize>
263: 261:             where
264: 262:                 Self: Sized,
265: 263:                 Pre: FnMut(Self::Item) -> bool,
266: 264:             {
267: 265:                 match self {
268: 266:                     $($name::$variant(i) => i.position(predicate),)+
269: 267:                 }
270: 268:             }
271: 269: 
272: 270:             fn max(self) -> Option<Self::Item>
273: 271:             where
274: 272:                 Self: Sized,
275: 273:                 Self::Item: Ord,
276: 274:             {
277: 275:                 match self {
278: 276:                     $($name::$variant(i) => i.max(),)+
279: 277:                 }
280: 278:             }
281: 279: 
282: 280:             fn min(self) -> Option<Self::Item>
283: 281:             where
284: 282:                 Self: Sized,
285: 283:                 Self::Item: Ord,
286: 284:             {
287: 285:                 match self {
288: 286:                     $($name::$variant(i) => i.min(),)+
289: 287:                 }
290: 288:             }
291: 289: 
292: 290:             fn max_by_key<Key: Ord, Fun>(self, f: Fun) -> Option<Self::Item>
293: 291:             where
294: 292:                 Self: Sized,
295: 293:                 Fun: FnMut(&Self::Item) -> Key,
296: 294:             {
297: 295:                 match self {
298: 296:                     $($name::$variant(i) => i.max_by_key(f),)+
299: 297:                 }
300: 298:             }
301: 299: 
302: 300:             fn max_by<Cmp>(self, compare: Cmp) -> Option<Self::Item>
303: 301:             where
304: 302:                 Self: Sized,
305: 303:                 Cmp: FnMut(&Self::Item, &Self::Item) -> Ordering,
306: 304:             {
307: 305:                 match self {
308: 306:                     $($name::$variant(i) => i.max_by(compare),)+
309: 307:                 }
310: 308:             }
311: 309: 
312: 310:             fn min_by_key<Key: Ord, Fun>(self, f: Fun) -> Option<Self::Item>
313: 311:             where
314: 312:                 Self: Sized,
315: 313:                 Fun: FnMut(&Self::Item) -> Key,
316: 314:             {
317: 315:                 match self {
318: 316:                     $($name::$variant(i) => i.min_by_key(f),)+
319: 317:                 }
320: 318:             }
321: 319: 
322: 320:             fn min_by<Cmp>(self, compare: Cmp) -> Option<Self::Item>
323: 321:             where
324: 322:                 Self: Sized,
325: 323:                 Cmp: FnMut(&Self::Item, &Self::Item) -> Ordering,
326: 324:             {
327: 325:                 match self {
328: 326:                     $($name::$variant(i) => i.min_by(compare),)+
329: 327:                 }
330: 328:             }
331: 329: 
332: 330:             fn sum<Out>(self) -> Out
333: 331:             where
334: 332:                 Self: Sized,
335: 333:                 Out: Sum<Self::Item>,
336: 334:             {
337: 335:                 match self {
338: 336:                     $($name::$variant(i) => i.sum(),)+
339: 337:                 }
340: 338:             }
341: 339: 
342: 340:             fn product<Out>(self) -> Out
343: 341:             where
344: 342:                 Self: Sized,
345: 343:                 Out: Product<Self::Item>,
346: 344:             {
347: 345:                 match self {
348: 346:                     $($name::$variant(i) => i.product(),)+
349: 347:                 }
350: 348:             }
351: 349: 
352: 350:             fn cmp<Other>(self, other: Other) -> Ordering
353: 351:             where
354: 352:                 Other: IntoIterator<Item = Self::Item>,
355: 353:                 Self::Item: Ord,
356: 354:                 Self: Sized,
357: 355:             {
358: 356:                 match self {
359: 357:                     $($name::$variant(i) => i.cmp(other),)+
360: 358:                 }
361: 359:             }
362: 360: 
363: 361:             fn partial_cmp<Other>(self, other: Other) -> Option<Ordering>
364: 362:             where
365: 363:                 Other: IntoIterator,
366: 364:                 Self::Item: PartialOrd<Other::Item>,
367: 365:                 Self: Sized,
368: 366:             {
369: 367:                 match self {
370: 368:                     $($name::$variant(i) => i.partial_cmp(other),)+
371: 369:                 }
372: 370:             }
373: 371: 
374: 372:             // TODO: uncomment once MSRV is >= 1.82.0
375: 373:             // fn is_sorted(self) -> bool
376: 374:             // where
377: 375:             //     Self: Sized,
378: 376:             //     Self::Item: PartialOrd,
379: 377:             // {
380: 378:             //     match self {
381: 379:             //         $($name::$variant(i) => i.is_sorted(),)+
382: 380:             //     }
383: 381:             // }
384: 382:             //
385: 383:             // fn is_sorted_by<Cmp>(self, compare: Cmp) -> bool
386: 384:             // where
387: 385:             //     Self: Sized,
388: 386:             //     Cmp: FnMut(&Self::Item, &Self::Item) -> bool,
389: 387:             // {
390: 388:             //     match self {
391: 389:             //         $($name::$variant(i) => i.is_sorted_by(compare),)+
392: 390:             //     }
393: 391:             // }
394: 392:             //
395: 393:             // fn is_sorted_by_key<Fun, Key>(self, f: Fun) -> bool
396: 394:             // where
397: 395:             //     Self: Sized,
398: 396:             //     Fun: FnMut(Self::Item) -> Key,
399: 397:             //     Key: PartialOrd,
400: 398:             // {
401: 399:             //     match self {
402: 400:             //         $($name::$variant(i) => i.is_sorted_by_key(f),)+
403: 401:             //     }
404: 402:             // }
405: 403:         }
406: 404: 
407: 405:         impl<Item, $($ty),+> ExactSizeIterator for $name<$($ty),+>
408: 406:         where
409: 407:             $($ty: ExactSizeIterator<Item = Item>,)+
410: 408:         {
411: 409:             fn len(&self) -> usize {
412: 410:                 match self {
413: 411:                     $($name::$variant(i) => i.len(),)+
414: 412:                 }
415: 413:             }
416: 414:         }
417: 415: 
418: 416:         impl<Item, $($ty),+> DoubleEndedIterator for $name<$($ty),+>
419: 417:         where
420: 418:             $($ty: DoubleEndedIterator<Item = Item>,)+
421: 419:         {
422: 420:             fn next_back(&mut self) -> Option<Self::Item> {
423: 421:                 match self {
424: 422:                     $($name::$variant(i) => i.next_back(),)+
425: 423:                 }
426: 424:             }
427: 425: 
428: 426:             fn nth_back(&mut self, n: usize) -> Option<Self::Item> {
429: 427:                 match self {
430: 428:                     $($name::$variant(i) => i.nth_back(n),)+
431: 429:                 }
432: 430:             }
433: 431: 
434: 432:             fn rfind<Pre>(&mut self, predicate: Pre) -> Option<Self::Item>
435: 433:             where
436: 434:                 Pre: FnMut(&Self::Item) -> bool,
437: 435:             {
438: 436:                 match self {
439: 437:                     $($name::$variant(i) => i.rfind(predicate),)+
440: 438:                 }
441: 439:             }
442: 440:         }
443: 441: 
444: 442:         pin_project! {
445: 443:             #[project = $fut_proj]
446: 444:             pub enum $fut_name<$($ty),+> {
447: 445:                 $($variant { #[pin] inner: $ty },)+
448: 446:             }
449: 447:         }
450: 448: 
451: 449:         impl<$($ty),+> Future for $fut_name<$($ty),+>
452: 450:         where
453: 451:             $($ty: Future,)+
454: 452:         {
455: 453:             type Output = $name<$($ty::Output),+>;
456: 454: 
457: 455:             fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
458: 456:                 let this = self.project();
459: 457:                 match this {
460: 458:                     $($fut_proj::$variant { inner } => match inner.poll(cx) {
461: 459:                         Poll::Pending => Poll::Pending,
462: 460:                         Poll::Ready(inner) => Poll::Ready($name::$variant(inner)),
463: 461:                     },)+
464: 462:                 }
465: 463:             }
466: 464:         }
467: 465:     }
468: 466: }
469: 467: 
470: 468: tuples!(Either + EitherFuture + EitherFutureProj {
471: 469:     Left(A) => (Right) + <A1, B>,
472: 470:     Right(B) => (Left) + <A, B1>,
473: 471: });
474: 472: 
475: 473: impl<A, B> Either<A, B> {
476: 474:     pub fn swap(self) -> Either<B, A> {
477: 475:         match self {
478: 476:             Either::Left(a) => Either::Right(a),
479: 477:             Either::Right(b) => Either::Left(b),
480: 478:         }
481: 479:     }
482: 480: }
483: 481: 
484: 482: impl<A, B> From<Result<A, B>> for Either<A, B> {
485: 483:     fn from(value: Result<A, B>) -> Self {
486: 484:         match value {
487: 485:             Ok(left) => Either::Left(left),
488: 486:             Err(right) => Either::Right(right),
489: 487:         }
490: 488:     }
491: 489: }
492: 490: 
493: 491: pub trait EitherOr {
494: 492:     type Left;
495: 493:     type Right;
496: 494:     fn either_or<FA, A, FB, B>(self, a: FA, b: FB) -> Either<A, B>
497: 495:     where
498: 496:         FA: FnOnce(Self::Left) -> A,
499: 497:         FB: FnOnce(Self::Right) -> B;
500: 498: }
501: 499: 
502: 500: impl EitherOr for bool {
503: 501:     type Left = ();
504: 502:     type Right = ();
505: 503: 
506: 504:     fn either_or<FA, A, FB, B>(self, a: FA, b: FB) -> Either<A, B>
507: 505:     where
508: 506:         FA: FnOnce(Self::Left) -> A,
509: 507:         FB: FnOnce(Self::Right) -> B,
510: 508:     {
511: 509:         if self {
512: 510:             Either::Left(a(()))
513: 511:         } else {
514: 512:             Either::Right(b(()))
515: 513:         }
516: 514:     }
517: 515: }
518: 516: 
519: 517: impl<T> EitherOr for Option<T> {
520: 518:     type Left = T;
521: 519:     type Right = ();
522: 520: 
523: 521:     fn either_or<FA, A, FB, B>(self, a: FA, b: FB) -> Either<A, B>
524: 522:     where
525: 523:         FA: FnOnce(Self::Left) -> A,
526: 524:         FB: FnOnce(Self::Right) -> B,
527: 525:     {
528: 526:         match self {
529: 527:             Some(t) => Either::Left(a(t)),
530: 528:             None => Either::Right(b(())),
531: 529:         }
532: 530:     }
533: 531: }
534: 532: 
535: 533: impl<T, E> EitherOr for Result<T, E> {
536: 534:     type Left = T;
537: 535:     type Right = E;
538: 536: 
539: 537:     fn either_or<FA, A, FB, B>(self, a: FA, b: FB) -> Either<A, B>
540: 538:     where
541: 539:         FA: FnOnce(Self::Left) -> A,
542: 540:         FB: FnOnce(Self::Right) -> B,
543: 541:     {
544: 542:         match self {
545: 543:             Ok(t) => Either::Left(a(t)),
546: 544:             Err(err) => Either::Right(b(err)),
547: 545:         }
548: 546:     }
549: 547: }
550: 548: 
551: 549: impl<A, B> EitherOr for Either<A, B> {
552: 550:     type Left = A;
553: 551:     type Right = B;
554: 552: 
555: 553:     #[inline]
556: 554:     fn either_or<FA, A1, FB, B1>(self, a: FA, b: FB) -> Either<A1, B1>
557: 555:     where
558: 556:         FA: FnOnce(<Self as EitherOr>::Left) -> A1,
559: 557:         FB: FnOnce(<Self as EitherOr>::Right) -> B1,
560: 558:     {
561: 559:         self.map(a, b)
562: 560:     }
563: 561: }
564: 562: 
565: 563: #[test]
566: 564: fn test_either_or() {
567: 565:     let right = false.either_or(|_| 'a', |_| 12);
568: 566:     assert!(matches!(right, Either::Right(12)));
569: 567: 
570: 568:     let left = true.either_or(|_| 'a', |_| 12);
571: 569:     assert!(matches!(left, Either::Left('a')));
572: 570: 
573: 571:     let left = Some(12).either_or(|a| a, |_| 'a');
574: 572:     assert!(matches!(left, Either::Left(12)));
575: 573:     let right = None.either_or(|a: i32| a, |_| 'a');
576: 574:     assert!(matches!(right, Either::Right('a')));
577: 575: 
578: 576:     let result: Result<_, ()> = Ok(1.2f32);
579: 577:     let left = result.either_or(|a| a * 2f32, |b| b);
580: 578:     assert!(matches!(left, Either::Left(2.4f32)));
581: 579: 
582: 580:     let result: Result<i32, _> = Err("12");
583: 581:     let right = result.either_or(|a| a, |b| b.chars().next());
584: 582:     assert!(matches!(right, Either::Right(Some('1'))));
585: 583: 
586: 584:     let either = Either::<i32, char>::Left(12);
587: 585:     let left = either.either_or(|a| a, |b| b);
588: 586:     assert!(matches!(left, Either::Left(12)));
589: 587: 
590: 588:     let either = Either::<i32, char>::Right('a');
591: 589:     let right = either.either_or(|a| a, |b| b);
592: 590:     assert!(matches!(right, Either::Right('a')));
593: 591: }
594: 592: 
595: 593: tuples!(EitherOf3 + EitherOf3Future + EitherOf3FutureProj {
596: 594:     A => (B, C) + <A1, B, C>,
597: 595:     B => (A, C) + <A, B1, C>,
598: 596:     C => (A, B) + <A, B, C1>,
599: 597: });
600: 598: tuples!(EitherOf4 + EitherOf4Future + EitherOf4FutureProj {
601: 599:     A => (B, C, D) + <A1, B, C, D>,
602: 600:     B => (A, C, D) + <A, B1, C, D>,
603: 601:     C => (A, B, D) + <A, B, C1, D>,
604: 602:     D => (A, B, C) + <A, B, C, D1>,
605: 603: });
606: 604: tuples!(EitherOf5 + EitherOf5Future + EitherOf5FutureProj {
607: 605:     A => (B, C, D, E) + <A1, B, C, D, E>,
608: 606:     B => (A, C, D, E) + <A, B1, C, D, E>,
609: 607:     C => (A, B, D, E) + <A, B, C1, D, E>,
610: 608:     D => (A, B, C, E) + <A, B, C, D1, E>,
611: 609:     E => (A, B, C, D) + <A, B, C, D, E1>,
612: 610: });
613: 611: tuples!(EitherOf6 + EitherOf6Future + EitherOf6FutureProj {
614: 612:     A => (B, C, D, E, F) + <A1, B, C, D, E, F>,
615: 613:     B => (A, C, D, E, F) + <A, B1, C, D, E, F>,
616: 614:     C => (A, B, D, E, F) + <A, B, C1, D, E, F>,
617: 615:     D => (A, B, C, E, F) + <A, B, C, D1, E, F>,
618: 616:     E => (A, B, C, D, F) + <A, B, C, D, E1, F>,
619: 617:     F => (A, B, C, D, E) + <A, B, C, D, E, F1>,
620: 618: });
621: 619: tuples!(EitherOf7 + EitherOf7Future + EitherOf7FutureProj {
622: 620:     A => (B, C, D, E, F, G) + <A1, B, C, D, E, F, G>,
623: 621:     B => (A, C, D, E, F, G) + <A, B1, C, D, E, F, G>,
624: 622:     C => (A, B, D, E, F, G) + <A, B, C1, D, E, F, G>,
625: 623:     D => (A, B, C, E, F, G) + <A, B, C, D1, E, F, G>,
626: 624:     E => (A, B, C, D, F, G) + <A, B, C, D, E1, F, G>,
627: 625:     F => (A, B, C, D, E, G) + <A, B, C, D, E, F1, G>,
628: 626:     G => (A, B, C, D, E, F) + <A, B, C, D, E, F, G1>,
629: 627: });
630: 628: tuples!(EitherOf8 + EitherOf8Future + EitherOf8FutureProj {
631: 629:     A => (B, C, D, E, F, G, H) + <A1, B, C, D, E, F, G, H>,
632: 630:     B => (A, C, D, E, F, G, H) + <A, B1, C, D, E, F, G, H>,
633: 631:     C => (A, B, D, E, F, G, H) + <A, B, C1, D, E, F, G, H>,
634: 632:     D => (A, B, C, E, F, G, H) + <A, B, C, D1, E, F, G, H>,
635: 633:     E => (A, B, C, D, F, G, H) + <A, B, C, D, E1, F, G, H>,
636: 634:     F => (A, B, C, D, E, G, H) + <A, B, C, D, E, F1, G, H>,
637: 635:     G => (A, B, C, D, E, F, H) + <A, B, C, D, E, F, G1, H>,
638: 636:     H => (A, B, C, D, E, F, G) + <A, B, C, D, E, F, G, H1>,
639: 637: });
640: 638: tuples!(EitherOf9 + EitherOf9Future + EitherOf9FutureProj {
641: 639:     A => (B, C, D, E, F, G, H, I) + <A1, B, C, D, E, F, G, H, I>,
642: 640:     B => (A, C, D, E, F, G, H, I) + <A, B1, C, D, E, F, G, H, I>,
643: 641:     C => (A, B, D, E, F, G, H, I) + <A, B, C1, D, E, F, G, H, I>,
644: 642:     D => (A, B, C, E, F, G, H, I) + <A, B, C, D1, E, F, G, H, I>,
645: 643:     E => (A, B, C, D, F, G, H, I) + <A, B, C, D, E1, F, G, H, I>,
646: 644:     F => (A, B, C, D, E, G, H, I) + <A, B, C, D, E, F1, G, H, I>,
647: 645:     G => (A, B, C, D, E, F, H, I) + <A, B, C, D, E, F, G1, H, I>,
648: 646:     H => (A, B, C, D, E, F, G, I) + <A, B, C, D, E, F, G, H1, I>,
649: 647:     I => (A, B, C, D, E, F, G, H) + <A, B, C, D, E, F, G, H, I1>,
650: 648: });
651: 649: tuples!(EitherOf10 + EitherOf10Future + EitherOf10FutureProj {
652: 650:     A => (B, C, D, E, F, G, H, I, J) + <A1, B, C, D, E, F, G, H, I, J>,
653: 651:     B => (A, C, D, E, F, G, H, I, J) + <A, B1, C, D, E, F, G, H, I, J>,
654: 652:     C => (A, B, D, E, F, G, H, I, J) + <A, B, C1, D, E, F, G, H, I, J>,
655: 653:     D => (A, B, C, E, F, G, H, I, J) + <A, B, C, D1, E, F, G, H, I, J>,
656: 654:     E => (A, B, C, D, F, G, H, I, J) + <A, B, C, D, E1, F, G, H, I, J>,
657: 655:     F => (A, B, C, D, E, G, H, I, J) + <A, B, C, D, E, F1, G, H, I, J>,
658: 656:     G => (A, B, C, D, E, F, H, I, J) + <A, B, C, D, E, F, G1, H, I, J>,
659: 657:     H => (A, B, C, D, E, F, G, I, J) + <A, B, C, D, E, F, G, H1, I, J>,
660: 658:     I => (A, B, C, D, E, F, G, H, J) + <A, B, C, D, E, F, G, H, I1, J>,
661: 659:     J => (A, B, C, D, E, F, G, H, I) + <A, B, C, D, E, F, G, H, I, J1>,
662: 660: });
663: 661: tuples!(EitherOf11 + EitherOf11Future + EitherOf11FutureProj {
664: 662:     A => (B, C, D, E, F, G, H, I, J, K) + <A1, B, C, D, E, F, G, H, I, J, K>,
665: 663:     B => (A, C, D, E, F, G, H, I, J, K) + <A, B1, C, D, E, F, G, H, I, J, K>,
666: 664:     C => (A, B, D, E, F, G, H, I, J, K) + <A, B, C1, D, E, F, G, H, I, J, K>,
667: 665:     D => (A, B, C, E, F, G, H, I, J, K) + <A, B, C, D1, E, F, G, H, I, J, K>,
668: 666:     E => (A, B, C, D, F, G, H, I, J, K) + <A, B, C, D, E1, F, G, H, I, J, K>,
669: 667:     F => (A, B, C, D, E, G, H, I, J, K) + <A, B, C, D, E, F1, G, H, I, J, K>,
670: 668:     G => (A, B, C, D, E, F, H, I, J, K) + <A, B, C, D, E, F, G1, H, I, J, K>,
671: 669:     H => (A, B, C, D, E, F, G, I, J, K) + <A, B, C, D, E, F, G, H1, I, J, K>,
672: 670:     I => (A, B, C, D, E, F, G, H, J, K) + <A, B, C, D, E, F, G, H, I1, J, K>,
673: 671:     J => (A, B, C, D, E, F, G, H, I, K) + <A, B, C, D, E, F, G, H, I, J1, K>,
674: 672:     K => (A, B, C, D, E, F, G, H, I, J) + <A, B, C, D, E, F, G, H, I, J, K1>,
675: 673: });
676: 674: tuples!(EitherOf12 + EitherOf12Future + EitherOf12FutureProj {
677: 675:     A => (B, C, D, E, F, G, H, I, J, K, L) + <A1, B, C, D, E, F, G, H, I, J, K, L>,
678: 676:     B => (A, C, D, E, F, G, H, I, J, K, L) + <A, B1, C, D, E, F, G, H, I, J, K, L>,
679: 677:     C => (A, B, D, E, F, G, H, I, J, K, L) + <A, B, C1, D, E, F, G, H, I, J, K, L>,
680: 678:     D => (A, B, C, E, F, G, H, I, J, K, L) + <A, B, C, D1, E, F, G, H, I, J, K, L>,
681: 679:     E => (A, B, C, D, F, G, H, I, J, K, L) + <A, B, C, D, E1, F, G, H, I, J, K, L>,
682: 680:     F => (A, B, C, D, E, G, H, I, J, K, L) + <A, B, C, D, E, F1, G, H, I, J, K, L>,
683: 681:     G => (A, B, C, D, E, F, H, I, J, K, L) + <A, B, C, D, E, F, G1, H, I, J, K, L>,
684: 682:     H => (A, B, C, D, E, F, G, I, J, K, L) + <A, B, C, D, E, F, G, H1, I, J, K, L>,
685: 683:     I => (A, B, C, D, E, F, G, H, J, K, L) + <A, B, C, D, E, F, G, H, I1, J, K, L>,
686: 684:     J => (A, B, C, D, E, F, G, H, I, K, L) + <A, B, C, D, E, F, G, H, I, J1, K, L>,
687: 685:     K => (A, B, C, D, E, F, G, H, I, J, L) + <A, B, C, D, E, F, G, H, I, J, K1, L>,
688: 686:     L => (A, B, C, D, E, F, G, H, I, J, K) + <A, B, C, D, E, F, G, H, I, J, K, L1>,
689: 687: });
690: 688: tuples!(EitherOf13 + EitherOf13Future + EitherOf13FutureProj {
691: 689:     A => (B, C, D, E, F, G, H, I, J, K, L, M) + <A1, B, C, D, E, F, G, H, I, J, K, L, M>,
692: 690:     B => (A, C, D, E, F, G, H, I, J, K, L, M) + <A, B1, C, D, E, F, G, H, I, J, K, L, M>,
693: 691:     C => (A, B, D, E, F, G, H, I, J, K, L, M) + <A, B, C1, D, E, F, G, H, I, J, K, L, M>,
694: 692:     D => (A, B, C, E, F, G, H, I, J, K, L, M) + <A, B, C, D1, E, F, G, H, I, J, K, L, M>,
695: 693:     E => (A, B, C, D, F, G, H, I, J, K, L, M) + <A, B, C, D, E1, F, G, H, I, J, K, L, M>,
696: 694:     F => (A, B, C, D, E, G, H, I, J, K, L, M) + <A, B, C, D, E, F1, G, H, I, J, K, L, M>,
697: 695:     G => (A, B, C, D, E, F, H, I, J, K, L, M) + <A, B, C, D, E, F, G1, H, I, J, K, L, M>,
698: 696:     H => (A, B, C, D, E, F, G, I, J, K, L, M) + <A, B, C, D, E, F, G, H1, I, J, K, L, M>,
699: 697:     I => (A, B, C, D, E, F, G, H, J, K, L, M) + <A, B, C, D, E, F, G, H, I1, J, K, L, M>,
700: 698:     J => (A, B, C, D, E, F, G, H, I, K, L, M) + <A, B, C, D, E, F, G, H, I, J1, K, L, M>,
701: 699:     K => (A, B, C, D, E, F, G, H, I, J, L, M) + <A, B, C, D, E, F, G, H, I, J, K1, L, M>,
702: 700:     L => (A, B, C, D, E, F, G, H, I, J, K, M) + <A, B, C, D, E, F, G, H, I, J, K, L1, M>,
703: 701:     M => (A, B, C, D, E, F, G, H, I, J, K, L) + <A, B, C, D, E, F, G, H, I, J, K, L, M1>,
704: 702: });
705: 703: tuples!(EitherOf14 + EitherOf14Future + EitherOf14FutureProj {
706: 704:     A => (B, C, D, E, F, G, H, I, J, K, L, M, N) + <A1, B, C, D, E, F, G, H, I, J, K, L, M, N>,
707: 705:     B => (A, C, D, E, F, G, H, I, J, K, L, M, N) + <A, B1, C, D, E, F, G, H, I, J, K, L, M, N>,
708: 706:     C => (A, B, D, E, F, G, H, I, J, K, L, M, N) + <A, B, C1, D, E, F, G, H, I, J, K, L, M, N>,
709: 707:     D => (A, B, C, E, F, G, H, I, J, K, L, M, N) + <A, B, C, D1, E, F, G, H, I, J, K, L, M, N>,
710: 708:     E => (A, B, C, D, F, G, H, I, J, K, L, M, N) + <A, B, C, D, E1, F, G, H, I, J, K, L, M, N>,
711: 709:     F => (A, B, C, D, E, G, H, I, J, K, L, M, N) + <A, B, C, D, E, F1, G, H, I, J, K, L, M, N>,
712: 710:     G => (A, B, C, D, E, F, H, I, J, K, L, M, N) + <A, B, C, D, E, F, G1, H, I, J, K, L, M, N>,
713: 711:     H => (A, B, C, D, E, F, G, I, J, K, L, M, N) + <A, B, C, D, E, F, G, H1, I, J, K, L, M, N>,
714: 712:     I => (A, B, C, D, E, F, G, H, J, K, L, M, N) + <A, B, C, D, E, F, G, H, I1, J, K, L, M, N>,
715: 713:     J => (A, B, C, D, E, F, G, H, I, K, L, M, N) + <A, B, C, D, E, F, G, H, I, J1, K, L, M, N>,
716: 714:     K => (A, B, C, D, E, F, G, H, I, J, L, M, N) + <A, B, C, D, E, F, G, H, I, J, K1, L, M, N>,
717: 715:     L => (A, B, C, D, E, F, G, H, I, J, K, M, N) + <A, B, C, D, E, F, G, H, I, J, K, L1, M, N>,
718: 716:     M => (A, B, C, D, E, F, G, H, I, J, K, L, N) + <A, B, C, D, E, F, G, H, I, J, K, L, M1, N>,
719: 717:     N => (A, B, C, D, E, F, G, H, I, J, K, L, M) + <A, B, C, D, E, F, G, H, I, J, K, L, M, N1>,
720: 718: });
721: 719: tuples!(EitherOf15 + EitherOf15Future + EitherOf15FutureProj {
722: 720:     A => (B, C, D, E, F, G, H, I, J, K, L, M, N, O) + <A1, B, C, D, E, F, G, H, I, J, K, L, M, N, O>,
723: 721:     B => (A, C, D, E, F, G, H, I, J, K, L, M, N, O) + <A, B1, C, D, E, F, G, H, I, J, K, L, M, N, O>,
724: 722:     C => (A, B, D, E, F, G, H, I, J, K, L, M, N, O) + <A, B, C1, D, E, F, G, H, I, J, K, L, M, N, O>,
725: 723:     D => (A, B, C, E, F, G, H, I, J, K, L, M, N, O) + <A, B, C, D1, E, F, G, H, I, J, K, L, M, N, O>,
726: 724:     E => (A, B, C, D, F, G, H, I, J, K, L, M, N, O) + <A, B, C, D, E1, F, G, H, I, J, K, L, M, N, O>,
727: 725:     F => (A, B, C, D, E, G, H, I, J, K, L, M, N, O) + <A, B, C, D, E, F1, G, H, I, J, K, L, M, N, O>,
728: 726:     G => (A, B, C, D, E, F, H, I, J, K, L, M, N, O) + <A, B, C, D, E, F, G1, H, I, J, K, L, M, N, O>,
729: 727:     H => (A, B, C, D, E, F, G, I, J, K, L, M, N, O) + <A, B, C, D, E, F, G, H1, I, J, K, L, M, N, O>,
730: 728:     I => (A, B, C, D, E, F, G, H, J, K, L, M, N, O) + <A, B, C, D, E, F, G, H, I1, J, K, L, M, N, O>,
731: 729:     J => (A, B, C, D, E, F, G, H, I, K, L, M, N, O) + <A, B, C, D, E, F, G, H, I, J1, K, L, M, N, O>,
732: 730:     K => (A, B, C, D, E, F, G, H, I, J, L, M, N, O) + <A, B, C, D, E, F, G, H, I, J, K1, L, M, N, O>,
733: 731:     L => (A, B, C, D, E, F, G, H, I, J, K, M, N, O) + <A, B, C, D, E, F, G, H, I, J, K, L1, M, N, O>,
734: 732:     M => (A, B, C, D, E, F, G, H, I, J, K, L, N, O) + <A, B, C, D, E, F, G, H, I, J, K, L, M1, N, O>,
735: 733:     N => (A, B, C, D, E, F, G, H, I, J, K, L, M, O) + <A, B, C, D, E, F, G, H, I, J, K, L, M, N1, O>,
736: 734:     O => (A, B, C, D, E, F, G, H, I, J, K, L, M, N) + <A, B, C, D, E, F, G, H, I, J, K, L, M, N, O1>,
737: 735: });
738: 736: tuples!(EitherOf16 + EitherOf16Future + EitherOf16FutureProj {
739: 737:     A => (B, C, D, E, F, G, H, I, J, K, L, M, N, O, P) + <A1, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>,
740: 738:     B => (A, C, D, E, F, G, H, I, J, K, L, M, N, O, P) + <A, B1, C, D, E, F, G, H, I, J, K, L, M, N, O, P>,
741: 739:     C => (A, B, D, E, F, G, H, I, J, K, L, M, N, O, P) + <A, B, C1, D, E, F, G, H, I, J, K, L, M, N, O, P>,
742: 740:     D => (A, B, C, E, F, G, H, I, J, K, L, M, N, O, P) + <A, B, C, D1, E, F, G, H, I, J, K, L, M, N, O, P>,
743: 741:     E => (A, B, C, D, F, G, H, I, J, K, L, M, N, O, P) + <A, B, C, D, E1, F, G, H, I, J, K, L, M, N, O, P>,
744: 742:     F => (A, B, C, D, E, G, H, I, J, K, L, M, N, O, P) + <A, B, C, D, E, F1, G, H, I, J, K, L, M, N, O, P>,
745: 743:     G => (A, B, C, D, E, F, H, I, J, K, L, M, N, O, P) + <A, B, C, D, E, F, G1, H, I, J, K, L, M, N, O, P>,
746: 744:     H => (A, B, C, D, E, F, G, I, J, K, L, M, N, O, P) + <A, B, C, D, E, F, G, H1, I, J, K, L, M, N, O, P>,
747: 745:     I => (A, B, C, D, E, F, G, H, J, K, L, M, N, O, P) + <A, B, C, D, E, F, G, H, I1, J, K, L, M, N, O, P>,
748: 746:     J => (A, B, C, D, E, F, G, H, I, K, L, M, N, O, P) + <A, B, C, D, E, F, G, H, I, J1, K, L, M, N, O, P>,
749: 747:     K => (A, B, C, D, E, F, G, H, I, J, L, M, N, O, P) + <A, B, C, D, E, F, G, H, I, J, K1, L, M, N, O, P>,
750: 748:     L => (A, B, C, D, E, F, G, H, I, J, K, M, N, O, P) + <A, B, C, D, E, F, G, H, I, J, K, L1, M, N, O, P>,
751: 749:     M => (A, B, C, D, E, F, G, H, I, J, K, L, N, O, P) + <A, B, C, D, E, F, G, H, I, J, K, L, M1, N, O, P>,
752: 750:     N => (A, B, C, D, E, F, G, H, I, J, K, L, M, O, P) + <A, B, C, D, E, F, G, H, I, J, K, L, M, N1, O, P>,
753: 751:     O => (A, B, C, D, E, F, G, H, I, J, K, L, M, N, P) + <A, B, C, D, E, F, G, H, I, J, K, L, M, N, O1, P>,
754: 752:     P => (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) + <A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P1>,
755: 753: });
756: 754: 
757: 755: /// Matches over the first expression and returns an either ([`Either`], [`EitherOf3`], ... [`EitherOf8`])
758: 756: /// composed of the values returned by the match arms.
759: 757: ///
760: 758: /// The pattern syntax is exactly the same as found in a match arm.
761: 759: ///
762: 760: /// # Examples
763: 761: ///
764: 762: /// ```
765: 763: /// # use lyx-core-lyx_core_lyx-core-lyx_core_either_of::*;
766: 764: /// let either2 = either!(Some("hello"),
767: 765: ///     Some(s) => s.len(),
768: 766: ///     None => 0.0,
769: 767: /// );
770: 768: /// assert!(matches!(either2, Either::<usize, f64>::Left(5)));
771: 769: ///
772: 770: /// let either3 = either!(Some("admin"),
773: 771: ///     Some("admin") => "hello admin",
774: 772: ///     Some(_) => 'x',
775: 773: ///     _ => 0,
776: 774: /// );
777: 775: /// assert!(matches!(either3, EitherOf3::<&str, char, i32>::A("hello admin")));
778: 776: /// ```
779: 777: #[macro_export]
780: 778: macro_rules! either {
781: 779:     ($match:expr, $left_pattern:pat => $left_expression:expr, $right_pattern:pat => $right_expression:expr$(,)?) => {
782: 780:         match $match {
783: 781:             $left_pattern => $crate::Either::Left($left_expression),
784: 782:             $right_pattern => $crate::Either::Right($right_expression),
785: 783:         }
786: 784:     };
787: 785:     ($match:expr, $a_pattern:pat => $a_expression:expr, $b_pattern:pat => $b_expression:expr, $c_pattern:pat => $c_expression:expr$(,)?) => {
788: 786:         match $match {
789: 787:             $a_pattern => $crate::EitherOf3::A($a_expression),
790: 788:             $b_pattern => $crate::EitherOf3::B($b_expression),
791: 789:             $c_pattern => $crate::EitherOf3::C($c_expression),
792: 790:         }
793: 791:     };
794: 792:     ($match:expr, $a_pattern:pat => $a_expression:expr, $b_pattern:pat => $b_expression:expr, $c_pattern:pat => $c_expression:expr, $d_pattern:pat => $d_expression:expr$(,)?) => {
795: 793:         match $match {
796: 794:             $a_pattern => $crate::EitherOf4::A($a_expression),
797: 795:             $b_pattern => $crate::EitherOf4::B($b_expression),
798: 796:             $c_pattern => $crate::EitherOf4::C($c_expression),
799: 797:             $d_pattern => $crate::EitherOf4::D($d_expression),
800: 798:         }
801: 799:     };
802: 800:     ($match:expr, $a_pattern:pat => $a_expression:expr, $b_pattern:pat => $b_expression:expr, $c_pattern:pat => $c_expression:expr, $d_pattern:pat => $d_expression:expr, $e_pattern:pat => $e_expression:expr$(,)?) => {
803: 801:         match $match {
804: 802:             $a_pattern => $crate::EitherOf5::A($a_expression),
805: 803:             $b_pattern => $crate::EitherOf5::B($b_expression),
806: 804:             $c_pattern => $crate::EitherOf5::C($c_expression),
807: 805:             $d_pattern => $crate::EitherOf5::D($d_expression),
808: 806:             $e_pattern => $crate::EitherOf5::E($e_expression),
809: 807:         }
810: 808:     };
811: 809:     ($match:expr, $a_pattern:pat => $a_expression:expr, $b_pattern:pat => $b_expression:expr, $c_pattern:pat => $c_expression:expr, $d_pattern:pat => $d_expression:expr, $e_pattern:pat => $e_expression:expr, $f_pattern:pat => $f_expression:expr$(,)?) => {
812: 810:         match $match {
813: 811:             $a_pattern => $crate::EitherOf6::A($a_expression),
814: 812:             $b_pattern => $crate::EitherOf6::B($b_expression),
815: 813:             $c_pattern => $crate::EitherOf6::C($c_expression),
816: 814:             $d_pattern => $crate::EitherOf6::D($d_expression),
817: 815:             $e_pattern => $crate::EitherOf6::E($e_expression),
818: 816:             $f_pattern => $crate::EitherOf6::F($f_expression),
819: 817:         }
820: 818:     };
821: 819:     ($match:expr, $a_pattern:pat => $a_expression:expr, $b_pattern:pat => $b_expression:expr, $c_pattern:pat => $c_expression:expr, $d_pattern:pat => $d_expression:expr, $e_pattern:pat => $e_expression:expr, $f_pattern:pat => $f_expression:expr, $g_pattern:pat => $g_expression:expr$(,)?) => {
822: 820:         match $match {
823: 821:             $a_pattern => $crate::EitherOf7::A($a_expression),
824: 822:             $b_pattern => $crate::EitherOf7::B($b_expression),
825: 823:             $c_pattern => $crate::EitherOf7::C($c_expression),
826: 824:             $d_pattern => $crate::EitherOf7::D($d_expression),
827: 825:             $e_pattern => $crate::EitherOf7::E($e_expression),
828: 826:             $f_pattern => $crate::EitherOf7::F($f_expression),
829: 827:             $g_pattern => $crate::EitherOf7::G($g_expression),
830: 828:         }
831: 829:     };
832: 830:     ($match:expr, $a_pattern:pat => $a_expression:expr, $b_pattern:pat => $b_expression:expr, $c_pattern:pat => $c_expression:expr, $d_pattern:pat => $d_expression:expr, $e_pattern:pat => $e_expression:expr, $f_pattern:pat => $f_expression:expr, $g_pattern:pat => $g_expression:expr, $h_pattern:pat => $h_expression:expr$(,)?) => {
833: 831:         match $match {
834: 832:             $a_pattern => $crate::EitherOf8::A($a_expression),
835: 833:             $b_pattern => $crate::EitherOf8::B($b_expression),
836: 834:             $c_pattern => $crate::EitherOf8::C($c_expression),
837: 835:             $d_pattern => $crate::EitherOf8::D($d_expression),
838: 836:             $e_pattern => $crate::EitherOf8::E($e_expression),
839: 837:             $f_pattern => $crate::EitherOf8::F($f_expression),
840: 838:             $g_pattern => $crate::EitherOf8::G($g_expression),
841: 839:             $h_pattern => $crate::EitherOf8::H($h_expression),
842: 840:         }
843: 841:     }; // if you need more eithers feel free to open a PR ;-)
844: 842: }
845: 843: 
846: 844: #[cfg(test)]
847: 845: mod tests {
848: 846:     use super::*;
849: 847: 
850: 848:     // compile time test
851: 849:     #[test]
852: 850:     fn either_macro() {
853: 851:         let _: Either<&str, f64> = either!(12,
854: 852:             12 => "12",
855: 853:             _ => 0.0,
856: 854:         );
857: 855:         let _: EitherOf3<&str, f64, i32> = either!(12,
858: 856:             12 => "12",
859: 857:             13 => 0.0,
860: 858:             _ => 12,
861: 859:         );
862: 860:         let _: EitherOf4<&str, f64, char, i32> = either!(12,
863: 861:             12 => "12",
864: 862:             13 => 0.0,
865: 863:             14 => ' ',
866: 864:             _ => 12,
867: 865:         );
868: 866:         let _: EitherOf5<&str, f64, char, f32, i32> = either!(12,
869: 867:             12 => "12",
870: 868:             13 => 0.0,
871: 869:             14 => ' ',
872: 870:             15 => 0.0f32,
873: 871:             _ => 12,
874: 872:         );
875: 873:         let _: EitherOf6<&str, f64, char, f32, u8, i32> = either!(12,
876: 874:             12 => "12",
877: 875:             13 => 0.0,
878: 876:             14 => ' ',
879: 877:             15 => 0.0f32,
880: 878:             16 => 24u8,
881: 879:             _ => 12,
882: 880:         );
883: 881:         let _: EitherOf7<&str, f64, char, f32, u8, i8, i32> = either!(12,
884: 882:             12 => "12",
885: 883:             13 => 0.0,
886: 884:             14 => ' ',
887: 885:             15 => 0.0f32,
888: 886:             16 => 24u8,
889: 887:             17 => 2i8,
890: 888:             _ => 12,
891: 889:         );
892: 890:         let _: EitherOf8<&str, f64, char, f32, u8, i8, u32, i32> = either!(12,
893: 891:             12 => "12",
894: 892:             13 => 0.0,
895: 893:             14 => ' ',
896: 894:             15 => 0.0f32,
897: 895:             16 => 24u8,
898: 896:             17 => 2i8,
899: 897:             18 => 42u32,
900: 898:             _ => 12,
901: 899:         );
902: 900:     }
903: 901: 
904: 902:     #[test]
905: 903:     #[should_panic]
906: 904:     fn unwrap_wrong_either() {
907: 905:         Either::<i32, &str>::Left(0).unwrap_right();
908: 906:     }
909: 907: }
910: ```
```
