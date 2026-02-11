### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\keyed.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\keyed.rs
2: ```rust
3: 1: use crate::{
4: 2:     path::{StorePath, StorePathSegment},
5: 3:     store_field::StoreField,
6: 4:     KeyMap, StoreFieldTrigger,
7: 5: };
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
9: 7:     signal::{
10: 8:         guards::{Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut, Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc, WriteGuard},
11: 9:         ArcTrigger,
12: 10:     },
13: 11:     traits::{
14: 12:         DefinedAt, IsDisposed, Notify, ReadUntracked, Track, UntrackableGuard,
15: 13:         Write,
16: 14:     },
17: 15: };
18: 16: use std::{
19: 17:     collections::VecDeque,
20: 18:     fmt::Debug,
21: 19:     hash::Hash,
22: 20:     iter,
23: 21:     ops::{Deref, DerefMut, IndexMut},
24: 22:     panic::Location,
25: 23: };
26: 24: 
27: 25: /// Provides access to a subfield that contains some kind of keyed collection.
28: 26: #[derive(Debug)]
29: 27: pub struct KeyedSubfield<Inner, Prev, K, T>
30: 28: where
31: 29:     for<'a> &'a T: IntoIterator,
32: 30: {
33: 31:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
34: 32:     defined_at: &'static Location<'static>,
35: 33:     path_segment: StorePathSegment,
36: 34:     inner: Inner,
37: 35:     read: fn(&Prev) -> &T,
38: 36:     write: fn(&mut Prev) -> &mut T,
39: 37:     key_fn: fn(<&T as IntoIterator>::Item) -> K,
40: 38: }
41: 39: 
42: 40: impl<Inner, Prev, K, T> Clone for KeyedSubfield<Inner, Prev, K, T>
43: 41: where
44: 42:     for<'a> &'a T: IntoIterator,
45: 43:     Inner: Clone,
46: 44: {
47: 45:     fn clone(&self) -> Self {
48: 46:         Self {
49: 47:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
50: 48:             defined_at: self.defined_at,
51: 49:             path_segment: self.path_segment,
52: 50:             inner: self.inner.clone(),
53: 51:             read: self.read,
54: 52:             write: self.write,
55: 53:             key_fn: self.key_fn,
56: 54:         }
57: 55:     }
58: 56: }
59: 57: 
60: 58: impl<Inner, Prev, K, T> Copy for KeyedSubfield<Inner, Prev, K, T>
61: 59: where
62: 60:     for<'a> &'a T: IntoIterator,
63: 61:     Inner: Copy,
64: 62: {
65: 63: }
66: 64: 
67: 65: impl<Inner, Prev, K, T> KeyedSubfield<Inner, Prev, K, T>
68: 66: where
69: 67:     for<'a> &'a T: IntoIterator,
70: 68: {
71: 69:     /// Creates a keyed subfield of the inner data type with the given key function.
72: 70:     #[track_caller]
73: 71:     pub fn new(
74: 72:         inner: Inner,
75: 73:         path_segment: StorePathSegment,
76: 74:         key_fn: fn(<&T as IntoIterator>::Item) -> K,
77: 75:         read: fn(&Prev) -> &T,
78: 76:         write: fn(&mut Prev) -> &mut T,
79: 77:     ) -> Self {
80: 78:         Self {
81: 79:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
82: 80:             defined_at: Location::caller(),
83: 81:             inner,
84: 82:             path_segment,
85: 83:             read,
86: 84:             write,
87: 85:             key_fn,
88: 86:         }
89: 87:     }
90: 88: }
91: 89: 
92: 90: impl<Inner, Prev, K, T> StoreField for KeyedSubfield<Inner, Prev, K, T>
93: 91: where
94: 92:     Self: Clone,
95: 93:     for<'a> &'a T: IntoIterator,
96: 94:     Inner: StoreField<Value = Prev>,
97: 95:     Prev: 'static,
98: 96:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
99: 97: {
100: 98:     type Value = T;
101: 99:     type Reader = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped<Inner::Reader, T>;
102: 100:     type Writer = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut<WriteGuard<Vec<ArcTrigger>, Inner::Writer>, T>;
103: 101: 
104: 102:     fn path(&self) -> impl IntoIterator<Item = StorePathSegment> {
105: 103:         self.inner
106: 104:             .path()
107: 105:             .into_iter()
108: 106:             .chain(iter::once(self.path_segment))
109: 107:     }
110: 108: 
111: 109:     fn path_unkeyed(&self) -> impl IntoIterator<Item = StorePathSegment> {
112: 110:         self.inner
113: 111:             .path_unkeyed()
114: 112:             .into_iter()
115: 113:             .chain(iter::once(self.path_segment))
116: 114:     }
117: 115: 
118: 116:     fn get_trigger(&self, path: StorePath) -> StoreFieldTrigger {
119: 117:         self.inner.get_trigger(path)
120: 118:     }
121: 119: 
122: 120:     fn get_trigger_unkeyed(&self, path: StorePath) -> StoreFieldTrigger {
123: 121:         self.inner.get_trigger_unkeyed(path)
124: 122:     }
125: 123: 
126: 124:     fn reader(&self) -> Option<Self::Reader> {
127: 125:         let inner = self.inner.reader()?;
128: 126:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::new_with_guard(inner, self.read))
129: 127:     }
130: 128: 
131: 129:     fn writer(&self) -> Option<Self::Writer> {
132: 130:         let mut parent = self.inner.writer()?;
133: 131:         parent.untrack();
134: 132:         let triggers = self.triggers_for_current_path();
135: 133:         let guard = WriteGuard::new(triggers, parent);
136: 134:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMut::new(guard, self.read, self.write))
137: 135:     }
138: 136: 
139: 137:     #[inline(always)]
140: 138:     fn keys(&self) -> Option<KeyMap> {
141: 139:         self.inner.keys()
142: 140:     }
143: 141: 
144: 142:     fn track_field(&self) {
145: 143:         let mut full_path = self.path().into_iter().collect::<StorePath>();
146: 144:         let trigger = self.get_trigger(self.path().into_iter().collect());
147: 145:         trigger.this.track();
148: 146:         trigger.children.track();
149: 147: 
150: 148:         // tracks `this` for all ancestors: i.e., it will track any change that is made
151: 149:         // directly to one of its ancestors, but not a change made to a *child* of an ancestor
152: 150:         // (which would end up with every subfield tracking its own siblings, because they are
153: 151:         // children of its parent)
154: 152:         while !full_path.is_empty() {
155: 153:             full_path.pop();
156: 154:             let inner = self.get_trigger(full_path.clone());
157: 155:             inner.this.track();
158: 156:         }
159: 157:     }
160: 158: }
161: 159: 
162: 160: impl<Inner, Prev, K, T> KeyedSubfield<Inner, Prev, K, T>
163: 161: where
164: 162:     Self: Clone,
165: 163:     for<'a> &'a T: IntoIterator,
166: 164:     Inner: StoreField<Value = Prev>,
167: 165:     Prev: 'static,
168: 166:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
169: 167: {
170: 168:     fn latest_keys(&self) -> Vec<K> {
171: 169:         self.reader()
172: 170:             .map(|r| r.deref().into_iter().map(|n| (self.key_fn)(n)).collect())
173: 171:             .unwrap_or_default()
174: 172:     }
175: 173: }
176: 174: 
177: 175: /// Gives keyed write access to a value in some collection.
178: 176: pub struct KeyedSubfieldWriteGuard<Inner, Prev, K, T, Guard>
179: 177: where
180: 178:     KeyedSubfield<Inner, Prev, K, T>: Clone,
181: 179:     for<'a> &'a T: IntoIterator,
182: 180:     Inner: StoreField<Value = Prev>,
183: 181:     Prev: 'static,
184: 182:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
185: 183: {
186: 184:     inner: KeyedSubfield<Inner, Prev, K, T>,
187: 185:     guard: Option<Guard>,
188: 186:     untracked: bool,
189: 187: }
190: 188: 
191: 189: impl<Inner, Prev, K, T, Guard> Deref
192: 190:     for KeyedSubfieldWriteGuard<Inner, Prev, K, T, Guard>
193: 191: where
194: 192:     Guard: Deref,
195: 193:     KeyedSubfield<Inner, Prev, K, T>: Clone,
196: 194:     for<'a> &'a T: IntoIterator,
197: 195:     Inner: StoreField<Value = Prev>,
198: 196:     Prev: 'static,
199: 197:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
200: 198: {
201: 199:     type Target = Guard::Target;
202: 200: 
203: 201:     fn deref(&self) -> &Self::Target {
204: 202:         self.guard
205: 203:             .as_ref()
206: 204:             .expect("should be Some(_) until dropped")
207: 205:             .deref()
208: 206:     }
209: 207: }
210: 208: 
211: 209: impl<Inner, Prev, K, T, Guard> DerefMut
212: 210:     for KeyedSubfieldWriteGuard<Inner, Prev, K, T, Guard>
213: 211: where
214: 212:     Guard: DerefMut,
215: 213:     KeyedSubfield<Inner, Prev, K, T>: Clone,
216: 214:     for<'a> &'a T: IntoIterator,
217: 215:     Inner: StoreField<Value = Prev>,
218: 216:     Prev: 'static,
219: 217:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
220: 218: {
221: 219:     fn deref_mut(&mut self) -> &mut Self::Target {
222: 220:         self.guard
223: 221:             .as_mut()
224: 222:             .expect("should be Some(_) until dropped")
225: 223:             .deref_mut()
226: 224:     }
227: 225: }
228: 226: 
229: 227: impl<Inner, Prev, K, T, Guard> UntrackableGuard
230: 228:     for KeyedSubfieldWriteGuard<Inner, Prev, K, T, Guard>
231: 229: where
232: 230:     Guard: UntrackableGuard,
233: 231:     KeyedSubfield<Inner, Prev, K, T>: Clone,
234: 232:     for<'a> &'a T: IntoIterator,
235: 233:     Inner: StoreField<Value = Prev>,
236: 234:     Prev: 'static,
237: 235:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
238: 236: {
239: 237:     fn untrack(&mut self) {
240: 238:         self.untracked = true;
241: 239:         if let Some(inner) = self.guard.as_mut() {
242: 240:             inner.untrack();
243: 241:         }
244: 242:     }
245: 243: }
246: 244: 
247: 245: impl<Inner, Prev, K, T, Guard> Drop
248: 246:     for KeyedSubfieldWriteGuard<Inner, Prev, K, T, Guard>
249: 247: where
250: 248:     KeyedSubfield<Inner, Prev, K, T>: Clone,
251: 249:     for<'a> &'a T: IntoIterator,
252: 250:     Inner: StoreField<Value = Prev>,
253: 251:     Prev: 'static,
254: 252:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
255: 253: {
256: 254:     fn drop(&mut self) {
257: 255:         // dropping the inner guard will
258: 256:         // 1) synchronously release its write lock on the store's value
259: 257:         // 2) trigger an (asynchronous) reactive update
260: 258:         drop(self.guard.take());
261: 259: 
262: 260:         // now that the write lock is release, we can get a read lock to refresh this keyed field
263: 261:         // based on the new value
264: 262:         self.inner.update_keys();
265: 263: 
266: 264:         if !self.untracked {
267: 265:             self.inner.notify();
268: 266:         }
269: 267: 
270: 268:         // reactive updates hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen on the next tick
271: 269:     }
272: 270: }
273: 271: 
274: 272: impl<Inner, Prev, K, T> DefinedAt for KeyedSubfield<Inner, Prev, K, T>
275: 273: where
276: 274:     for<'a> &'a T: IntoIterator,
277: 275:     Inner: StoreField<Value = Prev>,
278: 276: {
279: 277:     fn defined_at(&self) -> Option<&'static Location<'static>> {
280: 278:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
281: 279:         {
282: 280:             Some(self.defined_at)
283: 281:         }
284: 282:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
285: 283:         {
286: 284:             None
287: 285:         }
288: 286:     }
289: 287: }
290: 288: 
291: 289: impl<Inner, Prev, K, T> IsDisposed for KeyedSubfield<Inner, Prev, K, T>
292: 290: where
293: 291:     for<'a> &'a T: IntoIterator,
294: 292:     Inner: IsDisposed,
295: 293: {
296: 294:     fn is_disposed(&self) -> bool {
297: 295:         self.inner.is_disposed()
298: 296:     }
299: 297: }
300: 298: 
301: 299: impl<Inner, Prev, K, T> Notify for KeyedSubfield<Inner, Prev, K, T>
302: 300: where
303: 301:     Self: Clone,
304: 302:     for<'a> &'a T: IntoIterator,
305: 303:     Inner: StoreField<Value = Prev>,
306: 304:     Prev: 'static,
307: 305:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
308: 306: {
309: 307:     fn notify(&self) {
310: 308:         let trigger = self.get_trigger(self.path().into_iter().collect());
311: 309:         trigger.this.notify();
312: 310:         trigger.children.notify();
313: 311:     }
314: 312: }
315: 313: 
316: 314: impl<Inner, Prev, K, T> Track for KeyedSubfield<Inner, Prev, K, T>
317: 315: where
318: 316:     Self: Clone,
319: 317:     for<'a> &'a T: IntoIterator,
320: 318:     Inner: StoreField<Value = Prev> + Track + 'static,
321: 319:     Prev: 'static,
322: 320:     T: 'static,
323: 321:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
324: 322: {
325: 323:     fn track(&self) {
326: 324:         self.track_field();
327: 325:     }
328: 326: }
329: 327: 
330: 328: impl<Inner, Prev, K, T> ReadUntracked for KeyedSubfield<Inner, Prev, K, T>
331: 329: where
332: 330:     Self: Clone,
333: 331:     for<'a> &'a T: IntoIterator,
334: 332:     Inner: StoreField<Value = Prev>,
335: 333:     Prev: 'static,
336: 334:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
337: 335: {
338: 336:     type Value = <Self as StoreField>::Reader;
339: 337: 
340: 338:     fn try_read_untracked(&self) -> Option<Self::Value> {
341: 339:         self.reader()
342: 340:     }
343: 341: }
344: 342: 
345: 343: impl<Inner, Prev, K, T> Write for KeyedSubfield<Inner, Prev, K, T>
346: 344: where
347: 345:     Self: Clone,
348: 346:     for<'a> &'a T: IntoIterator,
349: 347:     T: 'static,
350: 348:     Inner: StoreField<Value = Prev>,
351: 349:     Prev: 'static,
352: 350:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
353: 351: {
354: 352:     type Value = T;
355: 353: 
356: 354:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
357: 355:         let guard = self.writer()?;
358: 356:         Some(KeyedSubfieldWriteGuard {
359: 357:             inner: self.clone(),
360: 358:             guard: Some(guard),
361: 359:             untracked: false,
362: 360:         })
363: 361:     }
364: 362: 
365: 363:     fn try_write_untracked(
366: 364:         &self,
367: 365:     ) -> Option<impl DerefMut<Target = Self::Value>> {
368: 366:         let mut guard = self.writer()?;
369: 367:         guard.untrack();
370: 368:         Some(KeyedSubfieldWriteGuard {
371: 369:             inner: self.clone(),
372: 370:             guard: Some(guard),
373: 371:             untracked: true,
374: 372:         })
375: 373:     }
376: 374: }
377: 375: 
378: 376: /// Gives access to the value in a collection based on some key.
379: 377: #[derive(Debug)]
380: 378: pub struct AtKeyed<Inner, Prev, K, T>
381: 379: where
382: 380:     for<'a> &'a T: IntoIterator,
383: 381: {
384: 382:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
385: 383:     defined_at: &'static Location<'static>,
386: 384:     inner: KeyedSubfield<Inner, Prev, K, T>,
387: 385:     key: K,
388: 386: }
389: 387: 
390: 388: impl<Inner, Prev, K, T> Clone for AtKeyed<Inner, Prev, K, T>
391: 389: where
392: 390:     for<'a> &'a T: IntoIterator,
393: 391:     KeyedSubfield<Inner, Prev, K, T>: Clone,
394: 392:     K: Debug + Clone,
395: 393: {
396: 394:     fn clone(&self) -> Self {
397: 395:         Self {
398: 396:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
399: 397:             defined_at: self.defined_at,
400: 398:             inner: self.inner.clone(),
401: 399:             key: self.key.clone(),
402: 400:         }
403: 401:     }
404: 402: }
405: 403: 
406: 404: impl<Inner, Prev, K, T> Copy for AtKeyed<Inner, Prev, K, T>
407: 405: where
408: 406:     for<'a> &'a T: IntoIterator,
409: 407:     KeyedSubfield<Inner, Prev, K, T>: Copy,
410: 408:     K: Debug + Copy,
411: 409: {
412: 410: }
413: 411: 
414: 412: impl<Inner, Prev, K, T> AtKeyed<Inner, Prev, K, T>
415: 413: where
416: 414:     for<'a> &'a T: IntoIterator,
417: 415: {
418: 416:     /// Provides access to the item in the inner collection at this key.
419: 417:     #[track_caller]
420: 418:     pub fn new(inner: KeyedSubfield<Inner, Prev, K, T>, key: K) -> Self {
421: 419:         Self {
422: 420:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
423: 421:             defined_at: Location::caller(),
424: 422:             inner,
425: 423:             key,
426: 424:         }
427: 425:     }
428: 426: }
429: 427: 
430: 428: impl<Inner, Prev, K, T> StoreField for AtKeyed<Inner, Prev, K, T>
431: 429: where
432: 430:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
433: 431:     KeyedSubfield<Inner, Prev, K, T>: Clone,
434: 432:     for<'a> &'a T: IntoIterator,
435: 433:     Inner: StoreField<Value = Prev>,
436: 434:     Prev: 'static,
437: 435:     T: IndexMut<usize>,
438: 436:     T::Output: Sized,
439: 437: {
440: 438:     type Value = T::Output;
441: 439:     type Reader = Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<
442: 440:         <KeyedSubfield<Inner, Prev, K, T> as StoreField>::Reader,
443: 441:         T::Output,
444: 442:     >;
445: 443:     type Writer = WriteGuard<
446: 444:         Vec<ArcTrigger>,
447: 445:         Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc<
448: 446:             <KeyedSubfield<Inner, Prev, K, T> as StoreField>::Writer,
449: 447:             T::Output,
450: 448:         >,
451: 449:     >;
452: 450: 
453: 451:     fn path(&self) -> impl IntoIterator<Item = StorePathSegment> {
454: 452:         let inner = self.inner.path().into_iter().collect::<StorePath>();
455: 453:         let keys = self
456: 454:             .inner
457: 455:             .keys()
458: 456:             .expect("using keys on a store with no keys");
459: 457:         let this = keys
460: 458:             .with_field_keys(
461: 459:                 inner.clone(),
462: 460:                 |keys| (keys.get(&self.key), vec![]),
463: 461:                 || self.inner.latest_keys(),
464: 462:             )
465: 463:             .flatten()
466: 464:             .map(|(path, _)| path);
467: 465:         inner.into_iter().chain(this)
468: 466:     }
469: 467: 
470: 468:     fn path_unkeyed(&self) -> impl IntoIterator<Item = StorePathSegment> {
471: 469:         let inner =
472: 470:             self.inner.path_unkeyed().into_iter().collect::<StorePath>();
473: 471:         let keys = self
474: 472:             .inner
475: 473:             .keys()
476: 474:             .expect("using keys on a store with no keys");
477: 475:         let this = keys
478: 476:             .with_field_keys(
479: 477:                 inner.clone(),
480: 478:                 |keys| (keys.get(&self.key), vec![]),
481: 479:                 || self.inner.latest_keys(),
482: 480:             )
483: 481:             .flatten()
484: 482:             .map(|(_, idx)| StorePathSegment(idx));
485: 483:         inner.into_iter().chain(this)
486: 484:     }
487: 485: 
488: 486:     fn get_trigger(&self, path: StorePath) -> StoreFieldTrigger {
489: 487:         self.inner.get_trigger(path)
490: 488:     }
491: 489: 
492: 490:     fn get_trigger_unkeyed(&self, path: StorePath) -> StoreFieldTrigger {
493: 491:         self.inner.get_trigger_unkeyed(path)
494: 492:     }
495: 493: 
496: 494:     fn reader(&self) -> Option<Self::Reader> {
497: 495:         let inner = self.inner.reader()?;
498: 496: 
499: 497:         let inner_path = self.inner.path().into_iter().collect();
500: 498:         let keys = self.inner.keys()?;
501: 499:         let index = keys
502: 500:             .with_field_keys(
503: 501:                 inner_path,
504: 502:                 |keys| (keys.get(&self.key), vec![]),
505: 503:                 || self.inner.latest_keys(),
506: 504:             )
507: 505:             .flatten()
508: 506:             .map(|(_, idx)| idx)?;
509: 507: 
510: 508:         Some(Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc::new(
511: 509:             inner,
512: 510:             move |n| &n[index],
513: 511:             move |n| &mut n[index],
514: 512:         ))
515: 513:     }
516: 514: 
517: 515:     fn writer(&self) -> Option<Self::Writer> {
518: 516:         let mut inner = self.inner.writer()?;
519: 517:         inner.untrack();
520: 518:         let inner_path = self.inner.path().into_iter().collect::<StorePath>();
521: 519:         let keys = self
522: 520:             .inner
523: 521:             .keys()
524: 522:             .expect("using keys on a store with no keys");
525: 523:         let index = keys
526: 524:             .with_field_keys(
527: 525:                 inner_path.clone(),
528: 526:                 |keys| (keys.get(&self.key), vec![]),
529: 527:                 || self.inner.latest_keys(),
530: 528:             )
531: 529:             .flatten()
532: 530:             .map(|(_, idx)| idx)?;
533: 531: 
534: 532:         let triggers = self.triggers_for_current_path();
535: 533: 
536: 534:         Some(WriteGuard::new(
537: 535:             triggers,
538: 536:             Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_appedMutArc::new(
539: 537:                 inner,
540: 538:                 move |n| &n[index],
541: 539:                 move |n| &mut n[index],
542: 540:             ),
543: 541:         ))
544: 542:     }
545: 543: 
546: 544:     #[inline(always)]
547: 545:     fn keys(&self) -> Option<KeyMap> {
548: 546:         self.inner.keys()
549: 547:     }
550: 548: }
551: 549: 
552: 550: impl<Inner, Prev, K, T> DefinedAt for AtKeyed<Inner, Prev, K, T>
553: 551: where
554: 552:     for<'a> &'a T: IntoIterator,
555: 553: {
556: 554:     fn defined_at(&self) -> Option<&'static Location<'static>> {
557: 555:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
558: 556:         {
559: 557:             Some(self.defined_at)
560: 558:         }
561: 559:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
562: 560:         {
563: 561:             None
564: 562:         }
565: 563:     }
566: 564: }
567: 565: 
568: 566: impl<Inner, Prev, K, T> IsDisposed for AtKeyed<Inner, Prev, K, T>
569: 567: where
570: 568:     for<'a> &'a T: IntoIterator,
571: 569:     Inner: IsDisposed,
572: 570: {
573: 571:     fn is_disposed(&self) -> bool {
574: 572:         self.inner.is_disposed()
575: 573:     }
576: 574: }
577: 575: 
578: 576: impl<Inner, Prev, K, T> Notify for AtKeyed<Inner, Prev, K, T>
579: 577: where
580: 578:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
581: 579:     KeyedSubfield<Inner, Prev, K, T>: Clone,
582: 580:     for<'a> &'a T: IntoIterator,
583: 581:     Inner: StoreField<Value = Prev>,
584: 582:     Prev: 'static,
585: 583:     T: IndexMut<usize>,
586: 584:     T::Output: Sized,
587: 585: {
588: 586:     fn notify(&self) {
589: 587:         let trigger = self.get_trigger(self.path().into_iter().collect());
590: 588:         trigger.this.notify();
591: 589:         trigger.children.notify();
592: 590:     }
593: 591: }
594: 592: 
595: 593: impl<Inner, Prev, K, T> Track for AtKeyed<Inner, Prev, K, T>
596: 594: where
597: 595:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
598: 596:     KeyedSubfield<Inner, Prev, K, T>: Clone,
599: 597:     for<'a> &'a T: IntoIterator,
600: 598:     Inner: StoreField<Value = Prev>,
601: 599:     Prev: 'static,
602: 600:     T: IndexMut<usize>,
603: 601:     T::Output: Sized,
604: 602: {
605: 603:     fn track(&self) {
606: 604:         self.track_field();
607: 605:     }
608: 606: }
609: 607: 
610: 608: impl<Inner, Prev, K, T> ReadUntracked for AtKeyed<Inner, Prev, K, T>
611: 609: where
612: 610:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
613: 611:     KeyedSubfield<Inner, Prev, K, T>: Clone,
614: 612:     for<'a> &'a T: IntoIterator,
615: 613:     Inner: StoreField<Value = Prev>,
616: 614:     Prev: 'static,
617: 615:     T: IndexMut<usize>,
618: 616:     T::Output: Sized,
619: 617: {
620: 618:     type Value = <Self as StoreField>::Reader;
621: 619: 
622: 620:     fn try_read_untracked(&self) -> Option<Self::Value> {
623: 621:         self.reader()
624: 622:     }
625: 623: }
626: 624: 
627: 625: impl<Inner, Prev, K, T> Write for AtKeyed<Inner, Prev, K, T>
628: 626: where
629: 627:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
630: 628:     KeyedSubfield<Inner, Prev, K, T>: Clone,
631: 629:     for<'a> &'a T: IntoIterator,
632: 630:     Inner: StoreField<Value = Prev>,
633: 631:     Prev: 'static,
634: 632:     T: IndexMut<usize>,
635: 633:     T::Output: Sized + 'static,
636: 634: {
637: 635:     type Value = T::Output;
638: 636: 
639: 637:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
640: 638:         self.writer()
641: 639:     }
642: 640: 
643: 641:     fn try_write_untracked(
644: 642:         &self,
645: 643:     ) -> Option<impl DerefMut<Target = Self::Value>> {
646: 644:         self.writer().map(|mut writer| {
647: 645:             writer.untrack();
648: 646:             writer
649: 647:         })
650: 648:     }
651: 649: }
652: 650: 
653: 651: impl<Inner, Prev, K, T> KeyedSubfield<Inner, Prev, K, T>
654: 652: where
655: 653:     Self: Clone,
656: 654:     for<'a> &'a T: IntoIterator,
657: 655:     Inner: StoreField<Value = Prev>,
658: 656:     Prev: 'static,
659: 657:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
660: 658: {
661: 659:     /// Generates a new set of keys and registers those keys with the parent store.
662: 660:     pub fn update_keys(&self) {
663: 661:         let inner_path = self.path().into_iter().collect();
664: 662:         let keys = self
665: 663:             .inner
666: 664:             .keys()
667: 665:             .expect("updating keys on a store with no keys");
668: 666: 
669: 667:         // generating the latest keys out here means that if we have
670: 668:         // nested keyed fields, the second field will not try to take a
671: 669:         // read-lock on the key map to get the field while the first field
672: 670:         // is still holding the write-lock in the closure below
673: 671:         let latest = self.latest_keys();
674: 672:         keys.with_field_keys(
675: 673:             inner_path,
676: 674:             |keys| ((), keys.update(latest)),
677: 675:             || self.latest_keys(),
678: 676:         );
679: 677:     }
680: 678: }
681: 679: 
682: 680: impl<Inner, Prev, K, T> IntoIterator for KeyedSubfield<Inner, Prev, K, T>
683: 681: where
684: 682:     Self: Clone,
685: 683:     for<'a> &'a T: IntoIterator,
686: 684:     Inner: Clone + StoreField<Value = Prev> + 'static,
687: 685:     Prev: 'static,
688: 686:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
689: 687:     T: IndexMut<usize> + 'static,
690: 688:     T::Output: Sized,
691: 689: {
692: 690:     type Item = AtKeyed<Inner, Prev, K, T>;
693: 691:     type IntoIter = StoreFieldKeyedIter<Inner, Prev, K, T>;
694: 692: 
695: 693:     #[track_caller]
696: 694:     fn into_iter(self) -> StoreFieldKeyedIter<Inner, Prev, K, T> {
697: 695:         // reactively track changes to this field
698: 696:         self.update_keys();
699: 697:         self.track_field();
700: 698: 
701: 699:         // get the current length of the field by accessing slice
702: 700:         let reader = self.reader();
703: 701: 
704: 702:         let keys = reader
705: 703:             .map(|r| {
706: 704:                 r.into_iter()
707: 705:                     .map(|item| (self.key_fn)(item))
708: 706:                     .collect::<VecDeque<_>>()
709: 707:             })
710: 708:             .unwrap_or_default();
711: 709: 
712: 710:         // return the iterator
713: 711:         StoreFieldKeyedIter { inner: self, keys }
714: 712:     }
715: 713: }
716: 714: 
717: 715: /// An iterator over a [`KeyedSubfield`].
718: 716: pub struct StoreFieldKeyedIter<Inner, Prev, K, T>
719: 717: where
720: 718:     for<'a> &'a T: IntoIterator,
721: 719:     T: IndexMut<usize>,
722: 720: {
723: 721:     inner: KeyedSubfield<Inner, Prev, K, T>,
724: 722:     keys: VecDeque<K>,
725: 723: }
726: 724: 
727: 725: impl<Inner, Prev, K, T> Iterator for StoreFieldKeyedIter<Inner, Prev, K, T>
728: 726: where
729: 727:     Inner: StoreField<Value = Prev> + Clone + 'static,
730: 728:     T: IndexMut<usize> + 'static,
731: 729:     T::Output: Sized + 'static,
732: 730:     for<'a> &'a T: IntoIterator,
733: 731: {
734: 732:     type Item = AtKeyed<Inner, Prev, K, T>;
735: 733: 
736: 734:     fn next(&mut self) -> Option<Self::Item> {
737: 735:         self.keys
738: 736:             .pop_front()
739: 737:             .map(|key| AtKeyed::new(self.inner.clone(), key))
740: 738:     }
741: 739: }
742: 740: 
743: 741: impl<Inner, Prev, K, T> DoubleEndedIterator
744: 742:     for StoreFieldKeyedIter<Inner, Prev, K, T>
745: 743: where
746: 744:     Inner: StoreField<Value = Prev> + Clone + 'static,
747: 745:     T: IndexMut<usize> + 'static,
748: 746:     T::Output: Sized + 'static,
749: 747:     for<'a> &'a T: IntoIterator,
750: 748: {
751: 749:     fn next_back(&mut self) -> Option<Self::Item> {
752: 750:         self.keys
753: 751:             .pop_back()
754: 752:             .map(|key| AtKeyed::new(self.inner.clone(), key))
755: 753:     }
756: 754: }
757: 755: 
758: 756: #[cfg(test)]
759: 757: mod tests {
760: 758:     use crate::{self as lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores, tests::tick, AtKeyed, Store};
761: 759:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
762: 760:         effect::Effect,
763: 761:         traits::{GetUntracked, ReadUntracked, Set, Track, Write},
764: 762:     };
765: 763:     use lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores::Patch;
766: 764:     use std::sync::{
767: 765:         atomic::{AtomicUsize, Ordering},
768: 766:         Arc,
769: 767:     };
770: 768: 
771: 769:     #[derive(Debug, Store, Default, Patch)]
772: 770:     struct Todos {
773: 771:         #[store(key: usize = |todo| todo.id)]
774: 772:         todos: Vec<Todo>,
775: 773:     }
776: 774: 
777: 775:     #[derive(Debug, Store, Default, Clone, PartialEq, Eq, Patch)]
778: 776:     struct Todo {
779: 777:         id: usize,
780: 778:         label: String,
781: 779:     }
782: 780: 
783: 781:     impl Todo {
784: 782:         pub fn new(id: usize, label: impl ToString) -> Self {
785: 783:             Self {
786: 784:                 id,
787: 785:                 label: label.to_string(),
788: 786:             }
789: 787:         }
790: 788:     }
791: 789: 
792: 790:     fn data() -> Todos {
793: 791:         Todos {
794: 792:             todos: vec![
795: 793:                 Todo {
796: 794:                     id: 10,
797: 795:                     label: "A".to_string(),
798: 796:                 },
799: 797:                 Todo {
800: 798:                     id: 11,
801: 799:                     label: "B".to_string(),
802: 800:                 },
803: 801:                 Todo {
804: 802:                     id: 12,
805: 803:                     label: "C".to_string(),
806: 804:                 },
807: 805:             ],
808: 806:         }
809: 807:     }
810: 808:     #[tokio::test]
811: 809:     async fn keyed_fields_can_be_moved() {
812: 810:         _ = lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio();
813: 811: 
814: 812:         let store = Store::new(data());
815: 813:         assert_eq!(store.read_untracked().todos.len(), 3);
816: 814: 
817: 815:         // create an effect to read from each keyed field
818: 816:         let a_count = Arc::new(AtomicUsize::new(0));
819: 817:         let b_count = Arc::new(AtomicUsize::new(0));
820: 818:         let c_count = Arc::new(AtomicUsize::new(0));
821: 819: 
822: 820:         let a = AtKeyed::new(store.todos(), 10);
823: 821:         let b = AtKeyed::new(store.todos(), 11);
824: 822:         let c = AtKeyed::new(store.todos(), 12);
825: 823: 
826: 824:         Effect::new_sync({
827: 825:             let a_count = Arc::clone(&a_count);
828: 826:             move || {
829: 827:                 a.track();
830: 828:                 a_count.fetch_add(1, Ordering::Relaxed);
831: 829:             }
832: 830:         });
833: 831:         Effect::new_sync({
834: 832:             let b_count = Arc::clone(&b_count);
835: 833:             move || {
836: 834:                 b.track();
837: 835:                 b_count.fetch_add(1, Ordering::Relaxed);
838: 836:             }
839: 837:         });
840: 838:         Effect::new_sync({
841: 839:             let c_count = Arc::clone(&c_count);
842: 840:             move || {
843: 841:                 c.track();
844: 842:                 c_count.fetch_add(1, Ordering::Relaxed);
845: 843:             }
846: 844:         });
847: 845: 
848: 846:         tick().await;
849: 847:         assert_eq!(a_count.load(Ordering::Relaxed), 1);
850: 848:         assert_eq!(b_count.load(Ordering::Relaxed), 1);
851: 849:         assert_eq!(c_count.load(Ordering::Relaxed), 1);
852: 850: 
853: 851:         // writing at a key doesn't notify siblings
854: 852:         *a.label().write() = "Foo".into();
855: 853:         tick().await;
856: 854:         assert_eq!(a_count.load(Ordering::Relaxed), 2);
857: 855:         assert_eq!(b_count.load(Ordering::Relaxed), 1);
858: 856:         assert_eq!(c_count.load(Ordering::Relaxed), 1);
859: 857: 
860: 858:         // the keys can be reorganized
861: 859:         store.todos().write().swap(0, 2);
862: 860:         let after = store.todos().get_untracked();
863: 861:         assert_eq!(
864: 862:             after,
865: 863:             vec![Todo::new(12, "C"), Todo::new(11, "B"), Todo::new(10, "Foo")]
866: 864:         );
867: 865: 
868: 866:         tick().await;
869: 867:         assert_eq!(a_count.load(Ordering::Relaxed), 2);
870: 868:         assert_eq!(b_count.load(Ordering::Relaxed), 1);
871: 869:         assert_eq!(c_count.load(Ordering::Relaxed), 1);
872: 870: 
873: 871:         // and after we move the keys around, they still update the moved items
874: 872:         a.label().set("Bar".into());
875: 873:         let after = store.todos().get_untracked();
876: 874:         assert_eq!(
877: 875:             after,
878: 876:             vec![Todo::new(12, "C"), Todo::new(11, "B"), Todo::new(10, "Bar")]
879: 877:         );
880: 878:         tick().await;
881: 879:         assert_eq!(a_count.load(Ordering::Relaxed), 3);
882: 880:         assert_eq!(b_count.load(Ordering::Relaxed), 1);
883: 881:         assert_eq!(c_count.load(Ordering::Relaxed), 1);
884: 882: 
885: 883:         // we can remove a key and add a new one
886: 884:         store.todos().write().pop();
887: 885:         store.todos().write().push(Todo::new(13, "New"));
888: 886:         let after = store.todos().get_untracked();
889: 887:         assert_eq!(
890: 888:             after,
891: 889:             vec![Todo::new(12, "C"), Todo::new(11, "B"), Todo::new(13, "New")]
892: 890:         );
893: 891:         tick().await;
894: 892:         assert_eq!(a_count.load(Ordering::Relaxed), 3);
895: 893:         assert_eq!(b_count.load(Ordering::Relaxed), 1);
896: 894:         assert_eq!(c_count.load(Ordering::Relaxed), 1);
897: 895:     }
898: 896: 
899: 897:     #[tokio::test]
900: 898:     async fn untracked_write_on_keyed_subfield_shouldnt_notify() {
901: 899:         _ = lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio();
902: 900: 
903: 901:         let store = Store::new(data());
904: 902:         assert_eq!(store.read_untracked().todos.len(), 3);
905: 903: 
906: 904:         // create an effect to read from the keyed subfield
907: 905:         let todos_count = Arc::new(AtomicUsize::new(0));
908: 906:         Effect::new_sync({
909: 907:             let todos_count = Arc::clone(&todos_count);
910: 908:             move || {
911: 909:                 store.todos().track();
912: 910:                 todos_count.fetch_add(1, Ordering::Relaxed);
913: 911:             }
914: 912:         });
915: 913: 
916: 914:         tick().await;
917: 915:         assert_eq!(todos_count.load(Ordering::Relaxed), 1);
918: 916: 
919: 917:         // writing to keyed subfield notifies the iterator
920: 918:         store.todos().write().push(Todo {
921: 919:             id: 13,
922: 920:             label: "D".into(),
923: 921:         });
924: 922:         tick().await;
925: 923:         assert_eq!(todos_count.load(Ordering::Relaxed), 2);
926: 924: 
927: 925:         // but an untracked write doesn't
928: 926:         store.todos().write_untracked().push(Todo {
929: 927:             id: 14,
930: 928:             label: "E".into(),
931: 929:         });
932: 930:         tick().await;
933: 931:         assert_eq!(todos_count.load(Ordering::Relaxed), 2);
934: 932:     }
935: 933: }
936: ```
```
