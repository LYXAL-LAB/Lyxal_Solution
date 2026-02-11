### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_stores\src\arc_field.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores\src\arc_field.rs
2: ```rust
3: 1: use crate::{
4: 2:     path::{StorePath, StorePathSegment},
5: 3:     ArcStore, AtIndex, AtKeyed, DerefedField, KeyMap, KeyedSubfield, Store,
6: 4:     StoreField, StoreFieldTrigger, Subfield,
7: 5: };
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
9: 7:     owner::Storage,
10: 8:     traits::{
11: 9:         DefinedAt, IsDisposed, Notify, ReadUntracked, Track, UntrackableGuard,
12: 10:         Write,
13: 11:     },
14: 12: };
15: 13: use std::{
16: 14:     fmt::Debug,
17: 15:     hash::Hash,
18: 16:     ops::{Deref, DerefMut, IndexMut},
19: 17:     panic::Location,
20: 18:     sync::Arc,
21: 19: };
22: 20: 
23: 21: /// Reference-counted access to a single field of type `T`.
24: 22: ///
25: 23: /// This can be used to erase the chain of field-accessors, to make it easier to pass this into
26: 24: /// another component or function without needing to specify the full type signature.
27: 25: pub struct ArcField<T>
28: 26: where
29: 27:     T: 'static,
30: 28: {
31: 29:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
32: 30:     defined_at: &'static Location<'static>,
33: 31:     path: Arc<dyn Fn() -> StorePath + Send + Sync>,
34: 32:     path_unkeyed: Arc<dyn Fn() -> StorePath + Send + Sync>,
35: 33:     get_trigger: Arc<dyn Fn(StorePath) -> StoreFieldTrigger + Send + Sync>,
36: 34:     get_trigger_unkeyed:
37: 35:         Arc<dyn Fn(StorePath) -> StoreFieldTrigger + Send + Sync>,
38: 36:     read: Arc<dyn Fn() -> Option<StoreFieldReader<T>> + Send + Sync>,
39: 37:     pub(crate) write:
40: 38:         Arc<dyn Fn() -> Option<StoreFieldWriter<T>> + Send + Sync>,
41: 39:     keys: Arc<dyn Fn() -> Option<KeyMap> + Send + Sync>,
42: 40:     track_field: Arc<dyn Fn() + Send + Sync>,
43: 41:     notify: Arc<dyn Fn() + Send + Sync>,
44: 42: }
45: 43: 
46: 44: impl<T> Debug for ArcField<T>
47: 45: where
48: 46:     T: 'static,
49: 47: {
50: 48:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
51: 49:         let mut f = f.debug_struct("ArcField");
52: 50:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
53: 51:         let f = f.field("defined_at", &self.defined_at);
54: 52:         f.finish_non_exhaustive()
55: 53:     }
56: 54: }
57: 55: 
58: 56: pub struct StoreFieldReader<T>(Box<dyn Deref<Target = T>>);
59: 57: 
60: 58: impl<T> StoreFieldReader<T> {
61: 59:     pub fn new(inner: impl Deref<Target = T> + 'static) -> Self {
62: 60:         Self(Box::new(inner))
63: 61:     }
64: 62: }
65: 63: 
66: 64: impl<T> Deref for StoreFieldReader<T> {
67: 65:     type Target = T;
68: 66: 
69: 67:     fn deref(&self) -> &Self::Target {
70: 68:         self.0.deref()
71: 69:     }
72: 70: }
73: 71: 
74: 72: pub struct StoreFieldWriter<T>(Box<dyn UntrackableGuard<Target = T>>);
75: 73: 
76: 74: impl<T> StoreFieldWriter<T> {
77: 75:     pub fn new(inner: impl UntrackableGuard<Target = T> + 'static) -> Self {
78: 76:         Self(Box::new(inner))
79: 77:     }
80: 78: }
81: 79: 
82: 80: impl<T> Deref for StoreFieldWriter<T> {
83: 81:     type Target = T;
84: 82: 
85: 83:     fn deref(&self) -> &Self::Target {
86: 84:         self.0.deref()
87: 85:     }
88: 86: }
89: 87: 
90: 88: impl<T> DerefMut for StoreFieldWriter<T> {
91: 89:     fn deref_mut(&mut self) -> &mut Self::Target {
92: 90:         self.0.deref_mut()
93: 91:     }
94: 92: }
95: 93: 
96: 94: impl<T> UntrackableGuard for StoreFieldWriter<T> {
97: 95:     fn untrack(&mut self) {
98: 96:         self.0.untrack();
99: 97:     }
100: 98: }
101: 99: 
102: 100: impl<T> StoreField for ArcField<T> {
103: 101:     type Value = T;
104: 102:     type Reader = StoreFieldReader<T>;
105: 103:     type Writer = StoreFieldWriter<T>;
106: 104: 
107: 105:     fn get_trigger(&self, path: StorePath) -> StoreFieldTrigger {
108: 106:         (self.get_trigger)(path)
109: 107:     }
110: 108: 
111: 109:     fn get_trigger_unkeyed(&self, path: StorePath) -> StoreFieldTrigger {
112: 110:         (self.get_trigger_unkeyed)(path)
113: 111:     }
114: 112: 
115: 113:     fn path(&self) -> impl IntoIterator<Item = StorePathSegment> {
116: 114:         (self.path)()
117: 115:     }
118: 116: 
119: 117:     fn path_unkeyed(&self) -> impl IntoIterator<Item = StorePathSegment> {
120: 118:         (self.path_unkeyed)()
121: 119:     }
122: 120: 
123: 121:     fn reader(&self) -> Option<Self::Reader> {
124: 122:         (self.read)().map(StoreFieldReader::new)
125: 123:     }
126: 124: 
127: 125:     fn writer(&self) -> Option<Self::Writer> {
128: 126:         (self.write)().map(StoreFieldWriter::new)
129: 127:     }
130: 128: 
131: 129:     fn keys(&self) -> Option<KeyMap> {
132: 130:         (self.keys)()
133: 131:     }
134: 132: }
135: 133: 
136: 134: impl<T, S> From<Store<T, S>> for ArcField<T>
137: 135: where
138: 136:     T: 'static,
139: 137:     S: Storage<ArcStore<T>>,
140: 138: {
141: 139:     #[track_caller]
142: 140:     fn from(value: Store<T, S>) -> Self {
143: 141:         ArcField {
144: 142:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
145: 143:             defined_at: Location::caller(),
146: 144:             path: Arc::new(move || value.path().into_iter().collect()),
147: 145:             path_unkeyed: Arc::new(move || {
148: 146:                 value.path_unkeyed().into_iter().collect()
149: 147:             }),
150: 148:             get_trigger: Arc::new(move |path| value.get_trigger(path)),
151: 149:             get_trigger_unkeyed: Arc::new(move |path| {
152: 150:                 value.get_trigger_unkeyed(path)
153: 151:             }),
154: 152:             read: Arc::new(move || value.reader().map(StoreFieldReader::new)),
155: 153:             write: Arc::new(move || value.writer().map(StoreFieldWriter::new)),
156: 154:             keys: Arc::new(move || value.keys()),
157: 155:             track_field: Arc::new(move || value.track_field()),
158: 156:             notify: Arc::new(move || value.notify()),
159: 157:         }
160: 158:     }
161: 159: }
162: 160: 
163: 161: impl<T> From<ArcStore<T>> for ArcField<T>
164: 162: where
165: 163:     T: Send + Sync + 'static,
166: 164: {
167: 165:     #[track_caller]
168: 166:     fn from(value: ArcStore<T>) -> Self {
169: 167:         ArcField {
170: 168:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
171: 169:             defined_at: Location::caller(),
172: 170:             path: Arc::new({
173: 171:                 let value = value.clone();
174: 172:                 move || value.path().into_iter().collect()
175: 173:             }),
176: 174:             path_unkeyed: Arc::new({
177: 175:                 let value = value.clone();
178: 176:                 move || value.path_unkeyed().into_iter().collect()
179: 177:             }),
180: 178:             get_trigger: Arc::new({
181: 179:                 let value = value.clone();
182: 180:                 move |path| value.get_trigger(path)
183: 181:             }),
184: 182:             get_trigger_unkeyed: Arc::new({
185: 183:                 let value = value.clone();
186: 184:                 move |path| value.get_trigger_unkeyed(path)
187: 185:             }),
188: 186:             read: Arc::new({
189: 187:                 let value = value.clone();
190: 188:                 move || value.reader().map(StoreFieldReader::new)
191: 189:             }),
192: 190:             write: Arc::new({
193: 191:                 let value = value.clone();
194: 192:                 move || value.writer().map(StoreFieldWriter::new)
195: 193:             }),
196: 194:             keys: Arc::new({
197: 195:                 let value = value.clone();
198: 196:                 move || value.keys()
199: 197:             }),
200: 198:             track_field: Arc::new({
201: 199:                 let value = value.clone();
202: 200:                 move || value.track_field()
203: 201:             }),
204: 202:             notify: Arc::new({
205: 203:                 let value = value.clone();
206: 204:                 move || value.notify()
207: 205:             }),
208: 206:         }
209: 207:     }
210: 208: }
211: 209: 
212: 210: impl<Inner, Prev, T> From<Subfield<Inner, Prev, T>> for ArcField<T>
213: 211: where
214: 212:     T: Send + Sync,
215: 213:     Subfield<Inner, Prev, T>: Clone,
216: 214:     Inner: StoreField<Value = Prev> + Send + Sync + 'static,
217: 215:     Prev: 'static,
218: 216: {
219: 217:     #[track_caller]
220: 218:     fn from(value: Subfield<Inner, Prev, T>) -> Self {
221: 219:         ArcField {
222: 220:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
223: 221:             defined_at: Location::caller(),
224: 222:             path: Arc::new({
225: 223:                 let value = value.clone();
226: 224:                 move || value.path().into_iter().collect()
227: 225:             }),
228: 226:             path_unkeyed: Arc::new({
229: 227:                 let value = value.clone();
230: 228:                 move || value.path_unkeyed().into_iter().collect()
231: 229:             }),
232: 230:             get_trigger: Arc::new({
233: 231:                 let value = value.clone();
234: 232:                 move |path| value.get_trigger(path)
235: 233:             }),
236: 234:             get_trigger_unkeyed: Arc::new({
237: 235:                 let value = value.clone();
238: 236:                 move |path| value.get_trigger_unkeyed(path)
239: 237:             }),
240: 238:             read: Arc::new({
241: 239:                 let value = value.clone();
242: 240:                 move || value.reader().map(StoreFieldReader::new)
243: 241:             }),
244: 242:             write: Arc::new({
245: 243:                 let value = value.clone();
246: 244:                 move || value.writer().map(StoreFieldWriter::new)
247: 245:             }),
248: 246:             keys: Arc::new({
249: 247:                 let value = value.clone();
250: 248:                 move || value.keys()
251: 249:             }),
252: 250:             track_field: Arc::new({
253: 251:                 let value = value.clone();
254: 252:                 move || value.track_field()
255: 253:             }),
256: 254:             notify: Arc::new({
257: 255:                 let value = value.clone();
258: 256:                 move || value.notify()
259: 257:             }),
260: 258:         }
261: 259:     }
262: 260: }
263: 261: 
264: 262: impl<Inner, T> From<DerefedField<Inner>> for ArcField<T>
265: 263: where
266: 264:     Inner: Clone + StoreField + Send + Sync + 'static,
267: 265:     Inner::Value: Deref<Target = T> + DerefMut,
268: 266:     T: Sized + 'static,
269: 267: {
270: 268:     #[track_caller]
271: 269:     fn from(value: DerefedField<Inner>) -> Self {
272: 270:         ArcField {
273: 271:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
274: 272:             defined_at: Location::caller(),
275: 273:             path: Arc::new({
276: 274:                 let value = value.clone();
277: 275:                 move || value.path().into_iter().collect()
278: 276:             }),
279: 277:             path_unkeyed: Arc::new({
280: 278:                 let value = value.clone();
281: 279:                 move || value.path_unkeyed().into_iter().collect()
282: 280:             }),
283: 281:             get_trigger: Arc::new({
284: 282:                 let value = value.clone();
285: 283:                 move |path| value.get_trigger(path)
286: 284:             }),
287: 285:             get_trigger_unkeyed: Arc::new({
288: 286:                 let value = value.clone();
289: 287:                 move |path| value.get_trigger_unkeyed(path)
290: 288:             }),
291: 289:             read: Arc::new({
292: 290:                 let value = value.clone();
293: 291:                 move || value.reader().map(StoreFieldReader::new)
294: 292:             }),
295: 293:             write: Arc::new({
296: 294:                 let value = value.clone();
297: 295:                 move || value.writer().map(StoreFieldWriter::new)
298: 296:             }),
299: 297:             keys: Arc::new({
300: 298:                 let value = value.clone();
301: 299:                 move || value.keys()
302: 300:             }),
303: 301:             track_field: Arc::new({
304: 302:                 let value = value.clone();
305: 303:                 move || value.track_field()
306: 304:             }),
307: 305:             notify: Arc::new({
308: 306:                 let value = value.clone();
309: 307:                 move || value.notify()
310: 308:             }),
311: 309:         }
312: 310:     }
313: 311: }
314: 312: 
315: 313: impl<Inner, Prev> From<AtIndex<Inner, Prev>> for ArcField<Prev::Output>
316: 314: where
317: 315:     AtIndex<Inner, Prev>: Clone,
318: 316:     Inner: StoreField<Value = Prev> + Send + Sync + 'static,
319: 317:     Prev: IndexMut<usize> + Send + Sync + 'static,
320: 318:     Prev::Output: Sized + Send + Sync,
321: 319: {
322: 320:     #[track_caller]
323: 321:     fn from(value: AtIndex<Inner, Prev>) -> Self {
324: 322:         ArcField {
325: 323:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
326: 324:             defined_at: Location::caller(),
327: 325:             path: Arc::new({
328: 326:                 let value = value.clone();
329: 327:                 move || value.path().into_iter().collect()
330: 328:             }),
331: 329:             path_unkeyed: Arc::new({
332: 330:                 let value = value.clone();
333: 331:                 move || value.path_unkeyed().into_iter().collect()
334: 332:             }),
335: 333:             get_trigger: Arc::new({
336: 334:                 let value = value.clone();
337: 335:                 move |path| value.get_trigger(path)
338: 336:             }),
339: 337:             get_trigger_unkeyed: Arc::new({
340: 338:                 let value = value.clone();
341: 339:                 move |path| value.get_trigger_unkeyed(path)
342: 340:             }),
343: 341:             read: Arc::new({
344: 342:                 let value = value.clone();
345: 343:                 move || value.reader().map(StoreFieldReader::new)
346: 344:             }),
347: 345:             write: Arc::new({
348: 346:                 let value = value.clone();
349: 347:                 move || value.writer().map(StoreFieldWriter::new)
350: 348:             }),
351: 349:             keys: Arc::new({
352: 350:                 let value = value.clone();
353: 351:                 move || value.keys()
354: 352:             }),
355: 353:             track_field: Arc::new({
356: 354:                 let value = value.clone();
357: 355:                 move || value.track_field()
358: 356:             }),
359: 357:             notify: Arc::new({
360: 358:                 let value = value.clone();
361: 359:                 move || value.notify()
362: 360:             }),
363: 361:         }
364: 362:     }
365: 363: }
366: 364: 
367: 365: impl<Inner, Prev, K, T> From<AtKeyed<Inner, Prev, K, T>> for ArcField<T::Output>
368: 366: where
369: 367:     AtKeyed<Inner, Prev, K, T>: Clone,
370: 368:     K: Debug + Send + Sync + PartialEq + Eq + Hash + 'static,
371: 369:     KeyedSubfield<Inner, Prev, K, T>: Clone,
372: 370:     for<'a> &'a T: IntoIterator,
373: 371:     Inner: StoreField<Value = Prev> + Send + Sync + 'static,
374: 372:     Prev: 'static,
375: 373:     T: IndexMut<usize> + 'static,
376: 374:     T::Output: Sized,
377: 375: {
378: 376:     #[track_caller]
379: 377:     fn from(value: AtKeyed<Inner, Prev, K, T>) -> Self {
380: 378:         ArcField {
381: 379:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
382: 380:             defined_at: Location::caller(),
383: 381:             path: Arc::new({
384: 382:                 let value = value.clone();
385: 383:                 move || value.path().into_iter().collect()
386: 384:             }),
387: 385:             path_unkeyed: Arc::new({
388: 386:                 let value = value.clone();
389: 387:                 move || value.path_unkeyed().into_iter().collect()
390: 388:             }),
391: 389:             get_trigger: Arc::new({
392: 390:                 let value = value.clone();
393: 391:                 move |path| value.get_trigger(path)
394: 392:             }),
395: 393:             get_trigger_unkeyed: Arc::new({
396: 394:                 let value = value.clone();
397: 395:                 move |path| value.get_trigger_unkeyed(path)
398: 396:             }),
399: 397:             read: Arc::new({
400: 398:                 let value = value.clone();
401: 399:                 move || value.reader().map(StoreFieldReader::new)
402: 400:             }),
403: 401:             write: Arc::new({
404: 402:                 let value = value.clone();
405: 403:                 move || value.writer().map(StoreFieldWriter::new)
406: 404:             }),
407: 405:             keys: Arc::new({
408: 406:                 let value = value.clone();
409: 407:                 move || value.keys()
410: 408:             }),
411: 409:             track_field: Arc::new({
412: 410:                 let value = value.clone();
413: 411:                 move || value.track_field()
414: 412:             }),
415: 413:             notify: Arc::new({
416: 414:                 let value = value.clone();
417: 415:                 move || value.notify()
418: 416:             }),
419: 417:         }
420: 418:     }
421: 419: }
422: 420: 
423: 421: impl<T> Clone for ArcField<T> {
424: 422:     fn clone(&self) -> Self {
425: 423:         Self {
426: 424:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
427: 425:             defined_at: self.defined_at,
428: 426:             path: self.path.clone(),
429: 427:             path_unkeyed: self.path_unkeyed.clone(),
430: 428:             get_trigger: Arc::clone(&self.get_trigger),
431: 429:             get_trigger_unkeyed: Arc::clone(&self.get_trigger_unkeyed),
432: 430:             read: Arc::clone(&self.read),
433: 431:             write: Arc::clone(&self.write),
434: 432:             keys: Arc::clone(&self.keys),
435: 433:             track_field: Arc::clone(&self.track_field),
436: 434:             notify: Arc::clone(&self.notify),
437: 435:         }
438: 436:     }
439: 437: }
440: 438: 
441: 439: impl<T> DefinedAt for ArcField<T> {
442: 440:     fn defined_at(&self) -> Option<&'static Location<'static>> {
443: 441:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
444: 442:         {
445: 443:             Some(self.defined_at)
446: 444:         }
447: 445:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
448: 446:         {
449: 447:             None
450: 448:         }
451: 449:     }
452: 450: }
453: 451: 
454: 452: impl<T> Notify for ArcField<T> {
455: 453:     fn notify(&self) {
456: 454:         (self.notify)()
457: 455:     }
458: 456: }
459: 457: 
460: 458: impl<T> Track for ArcField<T> {
461: 459:     fn track(&self) {
462: 460:         (self.track_field)();
463: 461:     }
464: 462: }
465: 463: 
466: 464: impl<T> ReadUntracked for ArcField<T> {
467: 465:     type Value = StoreFieldReader<T>;
468: 466: 
469: 467:     fn try_read_untracked(&self) -> Option<Self::Value> {
470: 468:         (self.read)()
471: 469:     }
472: 470: }
473: 471: 
474: 472: impl<T> Write for ArcField<T> {
475: 473:     type Value = T;
476: 474: 
477: 475:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>> {
478: 476:         (self.write)()
479: 477:     }
480: 478: 
481: 479:     fn try_write_untracked(
482: 480:         &self,
483: 481:     ) -> Option<impl DerefMut<Target = Self::Value>> {
484: 482:         let mut guard = (self.write)()?;
485: 483:         guard.untrack();
486: 484:         Some(guard)
487: 485:     }
488: 486: }
489: 487: 
490: 488: impl<T> IsDisposed for ArcField<T> {
491: 489:     fn is_disposed(&self) -> bool {
492: 490:         false
493: 491:     }
494: 492: }
495: ```
```
