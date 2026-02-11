### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\keyed.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\keyed.rs
18: 16: ```rust
19: 17: use super::{
20: 18:     add_attr::AddAnyAttr, MarkBranch, Mountable, Position, PositionState,
21: 19:     Render, RenderHtml,
22: 20: };
23: 21: use crate::{
24: 22:     html::attribute::{any_attribute::AnyAttribute, Attribute},
25: 23:     hydration::Cursor,
26: 24:     renderer::{CastFrom, Rndr},
27: 25:     ssr::StreamBuilder,
28: 26: };
29: 27: use drain_filter_polyfill::VecExt as VecDrainFilterExt;
30: 28: use indexmap::IndexSet;
31: 29: use rustc_hash::FxHasher;
32: 30: use std::hash::{BuildHasherDefault, Hash};
33: 31: 
34: 32: type FxIndexSet<T> = IndexSet<T, BuildHasherDefault<FxHasher>>;
35: 33: 
36: 34: /// Creates a keyed list of views.
37: 35: pub fn keyed<T, I, K, KF, VF, VFS, V>(
38: 36:     items: I,
39: 37:     key_fn: KF,
40: 38:     view_fn: VF,
41: 39: ) -> Keyed<T, I, K, KF, VF, VFS, V>
42: 40: where
43: 41:     I: IntoIterator<Item = T>,
44: 42:     K: Eq + Hash + SerializableKey + 'static,
45: 43:     KF: Fn(&T) -> K,
46: 44:     V: Render,
47: 45:     VF: Fn(usize, T) -> (VFS, V),
48: 46:     VFS: Fn(usize),
49: 47: {
50: 48:     Keyed {
51: 49:         #[cfg(not(feature = "ssr"))]
52: 50:         items: Some(items),
53: 51:         #[cfg(feature = "ssr")]
54: 52:         items: None,
55: 53:         #[cfg(feature = "ssr")]
56: 54:         ssr_items: items
57: 55:             .into_iter()
58: 56:             .enumerate()
59: 57:             .map(|(i, t)| {
60: 58:                 let key = if cfg!(feature = "islands") {
61: 59:                     let key = (key_fn)(&t);
62: 60:                     key.ser_key()
63: 61:                 } else {
64: 62:                     String::new()
65: 63:                 };
66: 64:                 let (_, view) = (view_fn)(i, t);
67: 65:                 (key, view)
68: 66:             })
69: 67:             .collect::<Vec<_>>(),
70: 68:         key_fn,
71: 69:         view_fn,
72: 70:     }
73: 71: }
74: 72: 
75: 73: /// A keyed list of views.
76: 74: pub struct Keyed<T, I, K, KF, VF, VFS, V>
77: 75: where
78: 76:     I: IntoIterator<Item = T>,
79: 77:     K: Eq + Hash + 'static,
80: 78:     KF: Fn(&T) -> K,
81: 79:     VF: Fn(usize, T) -> (VFS, V),
82: 80:     VFS: Fn(usize),
83: 81: {
84: 82:     items: Option<I>,
85: 83:     #[cfg(feature = "ssr")]
86: 84:     ssr_items: Vec<(String, V)>,
87: 85:     key_fn: KF,
88: 86:     view_fn: VF,
89: 87: }
90: 88: 
91: 89: /// By default, keys used in for keyed iteration do not need to be serializable.
92: 90: ///
93: 91: /// However, for some scenarios (like the “islands routing” mode that mixes lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side
94: 92: /// rendering with lyx-core-lyx_core_lyx-core-lyx_core_client-side navigation) it is useful to have serializable keys.
95: 93: ///
96: 94: /// When the `islands` feature is not enabled, this trait is implemented by all types.
97: 95: ///
98: 96: /// When the `islands` features is enabled, this is automatically implemented for all types
99: 97: /// that implement [`Serialize`](serde::Serialize), and can be manually implemented otherwise.
100: 98: pub trait SerializableKey {
101: 99:     /// Serializes the key to a unique string.
102: 100:     ///
103: 101:     /// The string can have any value, as long as it is idempotent (i.e., serializing the same key
104: 102:     /// multiple times will give the same value).
105: 103:     fn ser_key(&self) -> String;
106: 104: }
107: 105: 
108: 106: #[cfg(not(feature = "islands"))]
109: 107: impl<T> SerializableKey for T {
110: 108:     fn ser_key(&self) -> String {
111: 109:         panic!(
112: 110:             "SerializableKey called without the `islands` feature enabled. \
113: 111:              Something has gone wrong."
114: 112:         );
115: 113:     }
116: 114: }
117: 115: #[cfg(feature = "islands")]
118: 116: impl<T: serde::Serialize> SerializableKey for T {
119: 117:     fn ser_key(&self) -> String {
120: 118:         serde_json::to_string(self).expect("failed to serialize key")
121: 119:     }
122: 120: }
123: 121: 
124: 122: /// Retained view state for a keyed list.
125: 123: pub struct KeyedState<K, VFS, V>
126: 124: where
127: 125:     K: Eq + Hash + 'static,
128: 126:     VFS: Fn(usize),
129: 127:     V: Render,
130: 128: {
131: 129:     parent: Option<crate::renderer::types::Element>,
132: 130:     marker: crate::renderer::types::Placeholder,
133: 131:     hashed_items: IndexSet<K, BuildHasherDefault<FxHasher>>,
134: 132:     rendered_items: Vec<Option<(VFS, V::State)>>,
135: 133: }
136: 134: 
137: 135: impl<T, I, K, KF, VF, VFS, V> Render for Keyed<T, I, K, KF, VF, VFS, V>
138: 136: where
139: 137:     I: IntoIterator<Item = T>,
140: 138:     K: Eq + Hash + SerializableKey + 'static,
141: 139:     KF: Fn(&T) -> K,
142: 140:     V: Render,
143: 141:     VF: Fn(usize, T) -> (VFS, V),
144: 142:     VFS: Fn(usize),
145: 143: {
146: 144:     type State = KeyedState<K, VFS, V>;
147: 145: 
148: 146:     fn build(self) -> Self::State {
149: 147:         let items = self.items.into_iter().flatten();
150: 148:         let (capacity, _) = items.size_hint();
151: 149:         let mut hashed_items =
152: 150:             FxIndexSet::with_capacity_and_hasher(capacity, Default::default());
153: 151:         let mut rendered_items = Vec::with_capacity(capacity);
154: 152:         for (index, item) in items.enumerate() {
155: 153:             hashed_items.insert((self.key_fn)(&item));
156: 154:             let (set_index, view) = (self.view_fn)(index, item);
157: 155:             rendered_items.push(Some((set_index, view.build())));
158: 156:         }
159: 157:         KeyedState {
160: 158:             parent: None,
161: 159:             marker: Rndr::create_placeholder(),
162: 160:             hashed_items,
163: 161:             rendered_items,
164: 162:         }
165: 163:     }
166: 164: 
167: 165:     fn rebuild(self, state: &mut Self::State) {
168: 166:         let KeyedState {
169: 167:             parent,
170: 168:             marker,
171: 169:             hashed_items,
172: 170:             ref mut rendered_items,
173: 171:         } = state;
174: 172:         let new_items = self.items.into_iter().flatten();
175: 173:         let (capacity, _) = new_items.size_hint();
176: 174:         let mut new_hashed_items =
177: 175:             FxIndexSet::with_capacity_and_hasher(capacity, Default::default());
178: 176: 
179: 177:         let mut items = Vec::new();
180: 178:         for item in new_items {
181: 179:             new_hashed_items.insert((self.key_fn)(&item));
182: 180:             items.push(Some(item));
183: 181:         }
184: 182: 
185: 183:         let cmds = diff(hashed_items, &new_hashed_items);
186: 184: 
187: 185:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_diff(
188: 186:             parent.as_ref(),
189: 187:             marker,
190: 188:             cmds,
191: 189:             rendered_items,
192: 190:             &self.view_fn,
193: 191:             items,
194: 192:         );
195: 193: 
196: 194:         *hashed_items = new_hashed_items;
197: 195:     }
198: 196: }
199: 197: 
200: 198: impl<T, I, K, KF, VF, VFS, V> AddAnyAttr for Keyed<T, I, K, KF, VF, VFS, V>
201: 199: where
202: 200:     I: IntoIterator<Item = T> + Send + 'static,
203: 201:     K: Eq + Hash + SerializableKey + 'static,
204: 202:     KF: Fn(&T) -> K + Send + 'static,
205: 203:     V: RenderHtml,
206: 204:     V: 'static,
207: 205:     VF: Fn(usize, T) -> (VFS, V) + Send + 'static,
208: 206:     VFS: Fn(usize) + 'static,
209: 207:     T: 'static,
210: 208: {
211: 209:     type Output<SomeNewAttr: Attribute> = Keyed<
212: 210:         T,
213: 211:         I,
214: 212:         K,
215: 213:         KF,
216: 214:         Box<
217: 215:             dyn Fn(
218: 216:                     usize,
219: 217:                     T,
220: 218:                 ) -> (
221: 219:                     VFS,
222: 220:                     <V as AddAnyAttr>::Output<SomeNewAttr::CloneableOwned>,
223: 221:                 ) + Send,
224: 222:         >,
225: 223:         VFS,
226: 224:         V::Output<SomeNewAttr::CloneableOwned>,
227: 225:     >;
228: 226: 
229: 227:     fn add_any_attr<NewAttr: Attribute>(
230: 228:         self,
231: 229:         attr: NewAttr,
232: 230:     ) -> Self::Output<NewAttr>
233: 231:     where
234: 232:         Self::Output<NewAttr>: RenderHtml,
235: 233:     {
236: 234:         let Keyed {
237: 235:             items,
238: 236:             #[cfg(feature = "ssr")]
239: 237:             ssr_items,
240: 238:             key_fn,
241: 239:             view_fn,
242: 240:         } = self;
243: 241:         let attr = attr.into_cloneable_owned();
244: 242:         Keyed {
245: 243:             items,
246: 244:             key_fn,
247: 245:             #[cfg(feature = "ssr")]
248: 246:             ssr_items: ssr_items
249: 247:                 .into_iter()
250: 248:                 .map(|(k, v)| (k, v.add_any_attr(attr.clone())))
251: 249:                 .collect(),
252: 250:             view_fn: Box::new(move |index, item| {
253: 251:                 let (index, view) = view_fn(index, item);
254: 252:                 (index, view.add_any_attr(attr.clone()))
255: 253:             }),
256: 254:         }
257: 255:     }
258: 256: }
259: 257: 
260: 258: impl<T, I, K, KF, VF, VFS, V> RenderHtml for Keyed<T, I, K, KF, VF, VFS, V>
261: 259: where
262: 260:     I: IntoIterator<Item = T> + Send + 'static,
263: 261:     K: Eq + Hash + SerializableKey + 'static,
264: 262:     KF: Fn(&T) -> K + Send + 'static,
265: 263:     V: RenderHtml + 'static,
266: 264:     VF: Fn(usize, T) -> (VFS, V) + Send + 'static,
267: 265:     VFS: Fn(usize) + 'static,
268: 266:     T: 'static,
269: 267: {
270: 268:     type AsyncOutput = Vec<V::AsyncOutput>; // TODO
271: 269:     type Owned = Self;
272: 270: 
273: 271:     const MIN_LENGTH: usize = 0;
274: 272: 
275: 273:     fn dry_resolve(&mut self) {
276: 274:         #[cfg(feature = "ssr")]
277: 275:         for view in &mut self.ssr_items {
278: 276:             view.dry_resolve();
279: 277:         }
280: 278:     }
281: 279: 
282: 280:     async fn resolve(self) -> Self::AsyncOutput {
283: 281:         #[cfg(feature = "ssr")]
284: 282:         {
285: 283:             futures::future::join_all(
286: 284:                 self.ssr_items.into_iter().map(|(_, view)| view.resolve()),
287: 285:             )
288: 286:             .await
289: 287:             .into_iter()
290: 288:             .collect::<Vec<_>>()
291: 289:         }
292: 290:         #[cfg(not(feature = "ssr"))]
293: 291:         {
294: 292:             futures::future::join_all(
295: 293:                 self.items.into_iter().flatten().enumerate().map(
296: 294:                     |(index, item)| {
297: 295:                         let (_, view) = (self.view_fn)(index, item);
298: 296:                         view.resolve()
299: 297:                     },
300: 298:                 ),
301: 299:             )
302: 300:             .await
303: 301:             .into_iter()
304: 302:             .collect::<Vec<_>>()
305: 303:         }
306: 304:     }
307: 305: 
308: 306:     #[allow(unused)]
309: 307:     fn to_html_with_buf(
310: 308:         self,
311: 309:         buf: &mut String,
312: 310:         position: &mut Position,
313: 311:         escape: bool,
314: 312:         mark_branches: bool,
315: 313:         extra_attrs: Vec<AnyAttribute>,
316: 314:     ) {
317: 315:         if mark_branches && escape {
318: 316:             buf.open_branch("for");
319: 317:         }
320: 318: 
321: 319:         #[cfg(feature = "ssr")]
322: 320:         for item in self.ssr_items {
323: 321:             if mark_branches && escape {
324: 322:                 buf.open_branch("item");
325: 323:             }
326: 324:             item.to_html_with_buf(
327: 325:                 buf,
328: 326:                 position,
329: 327:                 escape,
330: 328:                 mark_branches,
331: 329:                 extra_attrs.clone(),
332: 330:             );
333: 331:             if mark_branches && escape {
334: 332:                 buf.close_branch("item");
335: 333:             }
336: 334:             *position = Position::NextChild;
337: 335:         }
338: 336:         if mark_branches && escape {
339: 337:             buf.close_branch("for");
340: 338:         }
341: 339:         buf.push_str("<!>");
342: 340:     }
343: 341: 
344: 342:     #[allow(unused)]
345: 343:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
346: 344:         self,
347: 345:         buf: &mut StreamBuilder,
348: 346:         position: &mut Position,
349: 347:         escape: bool,
350: 348:         mark_branches: bool,
351: 349:         extra_attrs: Vec<AnyAttribute>,
352: 350:     ) {
353: 351:         if mark_branches && escape {
354: 352:             buf.open_branch("for");
355: 353:         }
356: 354: 
357: 355:         #[cfg(feature = "ssr")]
358: 356:         for (key, item) in self.ssr_items {
359: 357:             let branch_name = mark_branches.then(|| format!("item-{key}"));
360: 358:             if mark_branches && escape {
361: 359:                 buf.open_branch(branch_name.as_ref().unwrap());
362: 360:             }
363: 361:             item.to_html_async_with_buf::<OUT_OF_ORDER>(
364: 362:                 buf,
365: 363:                 position,
366: 364:                 escape,
367: 365:                 mark_branches,
368: 366:                 extra_attrs.clone(),
369: 367:             );
370: 368:             if mark_branches && escape {
371: 369:                 buf.close_branch(branch_name.as_ref().unwrap());
372: 370:             }
373: 371:             *position = Position::NextChild;
374: 372:         }
375: 373: 
376: 374:         if mark_branches && escape {
377: 375:             buf.close_branch("for");
378: 376:         }
379: 377:         buf.push_sync("<!>");
380: 378:     }
381: 379: 
382: 380:     fn hydrate<const FROM_SERVER: bool>(
383: 381:         self,
384: 382:         cursor: &Cursor,
385: 383:         position: &PositionState,
386: 384:     ) -> Self::State {
387: 385:         // get parent and position
388: 386:         let current = cursor.current();
389: 387:         let parent = if position.get() == Position::FirstChild {
390: 388:             current
391: 389:         } else {
392: 390:             Rndr::get_parent(&current)
393: 391:                 .expect("first child of keyed list has no parent")
394: 392:         };
395: 393:         let parent = crate::renderer::types::Element::cast_from(parent)
396: 394:             .expect("parent of keyed list should be an element");
397: 395: 
398: 396:         // build list
399: 397:         let items = self.items.into_iter().flatten();
400: 398:         let (capacity, _) = items.size_hint();
401: 399:         let mut hashed_items =
402: 400:             FxIndexSet::with_capacity_and_hasher(capacity, Default::default());
403: 401:         let mut rendered_items = Vec::with_capacity(capacity);
404: 402:         for (index, item) in items.enumerate() {
405: 403:             hashed_items.insert((self.key_fn)(&item));
406: 404:             let (set_index, view) = (self.view_fn)(index, item);
407: 405:             let item = view.hydrate::<FROM_SERVER>(cursor, position);
408: 406:             rendered_items.push(Some((set_index, item)));
409: 407:         }
410: 408:         let marker = cursor.next_placeholder(position);
411: 409:         position.set(Position::NextChild);
412: 410: 
413: 411:         KeyedState {
414: 412:             parent: Some(parent),
415: 413:             marker,
416: 414:             hashed_items,
417: 415:             rendered_items,
418: 416:         }
419: 417:     }
420: 418: 
421: 419:     async fn hydrate_async(
422: 420:         self,
423: 421:         cursor: &Cursor,
424: 422:         position: &PositionState,
425: 423:     ) -> Self::State {
426: 424:         // get parent and position
427: 425:         let current = cursor.current();
428: 426:         let parent = if position.get() == Position::FirstChild {
429: 427:             current
430: 428:         } else {
431: 429:             Rndr::get_parent(&current)
432: 430:                 .expect("first child of keyed list has no parent")
433: 431:         };
434: 432:         let parent = crate::renderer::types::Element::cast_from(parent)
435: 433:             .expect("parent of keyed list should be an element");
436: 434: 
437: 435:         // build list
438: 436:         let items = self.items.into_iter().flatten();
439: 437:         let (capacity, _) = items.size_hint();
440: 438:         let mut hashed_items =
441: 439:             FxIndexSet::with_capacity_and_hasher(capacity, Default::default());
442: 440:         let mut rendered_items = Vec::with_capacity(capacity);
443: 441:         for (index, item) in items.enumerate() {
444: 442:             hashed_items.insert((self.key_fn)(&item));
445: 443:             let (set_index, view) = (self.view_fn)(index, item);
446: 444:             let item = view.hydrate_async(cursor, position).await;
447: 445:             rendered_items.push(Some((set_index, item)));
448: 446:         }
449: 447:         let marker = cursor.next_placeholder(position);
450: 448:         position.set(Position::NextChild);
451: 449: 
452: 450:         KeyedState {
453: 451:             parent: Some(parent),
454: 452:             marker,
455: 453:             hashed_items,
456: 454:             rendered_items,
457: 455:         }
458: 456:     }
459: 457: 
460: 458:     fn into_owned(self) -> Self::Owned {
461: 459:         self
462: 460:     }
463: 461: }
464: 462: 
465: 463: impl<K, VFS, V> Mountable for KeyedState<K, VFS, V>
466: 464: where
467: 465:     K: Eq + Hash + 'static,
468: 466:     VFS: Fn(usize),
469: 467:     V: Render,
470: 468: {
471: 469:     fn mount(
472: 470:         &mut self,
473: 471:         parent: &crate::renderer::types::Element,
474: 472:         marker: Option<&crate::renderer::types::Node>,
475: 473:     ) {
476: 474:         self.parent = Some(parent.clone());
477: 475:         for (_, item) in self.rendered_items.iter_mut().flatten() {
478: 476:             item.mount(parent, marker);
479: 477:         }
480: 478:         self.marker.mount(parent, marker);
481: 479:     }
482: 480: 
483: 481:     fn unmount(&mut self) {
484: 482:         for (_, item) in self.rendered_items.iter_mut().flatten() {
485: 483:             item.unmount();
486: 484:         }
487: 485:         self.marker.unmount();
488: 486:     }
489: 487: 
490: 488:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
491: 489:         self.rendered_items
492: 490:             .first()
493: 491:             .map(|item| {
494: 492:                 if let Some((_, item)) = item {
495: 493:                     item.insert_before_this(child)
496: 494:                 } else {
497: 495:                     false
498: 496:                 }
499: 497:             })
500: 498:             .unwrap_or_else(|| self.marker.insert_before_this(child))
501: 499:     }
502: 500: 
503: 501:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
504: 502:         self.rendered_items
505: 503:             .iter()
506: 504:             .flatten()
507: 505:             .flat_map(|item| item.1.elements())
508: 506:             .collect()
509: 507:     }
510: 508: }
511: 509: 
512: 510: trait VecExt<T> {
513: 511:     fn get_next_closest_mounted_sibling(
514: 512:         &self,
515: 513:         start_at: usize,
516: 514:     ) -> Option<&Option<T>>;
517: 515: }
518: 516: 
519: 517: impl<T> VecExt<T> for Vec<Option<T>> {
520: 518:     fn get_next_closest_mounted_sibling(
521: 519:         &self,
522: 520:         start_at: usize,
523: 521:     ) -> Option<&Option<T>> {
524: 522:         self[start_at..].iter().find(|s| s.is_some())
525: 523:     }
526: 524: }
527: 525: 
528: 526: /// Calculates the operations needed to get from `from` to `to`.
529: 527: fn diff<K: Eq + Hash>(from: &FxIndexSet<K>, to: &FxIndexSet<K>) -> Diff {
530: 528:     if from.is_empty() && to.is_empty() {
531: 529:         return Diff::default();
532: 530:     } else if to.is_empty() {
533: 531:         return Diff {
534: 532:             clear: true,
535: 533:             ..Default::default()
536: 534:         };
537: 535:     } else if from.is_empty() {
538: 536:         return Diff {
539: 537:             added: to
540: 538:                 .iter()
541: 539:                 .enumerate()
542: 540:                 .map(|(at, _)| DiffOpAdd {
543: 541:                     at,
544: 542:                     mode: DiffOpAddMode::Append,
545: 543:                 })
546: 544:                 .collect(),
547: 545:             ..Default::default()
548: 546:         };
549: 547:     }
550: 548: 
551: 549:     let mut removed = vec![];
552: 550:     let mut moved = vec![];
553: 551:     let mut added = vec![];
554: 552:     let max_len = std::cmp::max(from.len(), to.len());
555: 553: 
556: 554:     for index in 0..max_len {
557: 555:         let from_item = from.get_index(index);
558: 556:         let to_item = to.get_index(index);
559: 557: 
560: 558:         // if they're the same, do nothing
561: 559:         if from_item != to_item {
562: 560:             // if it's only in old, not new, remove it
563: 561:             if from_item.is_some() && !to.contains(from_item.unwrap()) {
564: 562:                 let op = DiffOpRemove { at: index };
565: 563:                 removed.push(op);
566: 564:             }
567: 565:             // if it's only in new, not old, add it
568: 566:             if to_item.is_some() && !from.contains(to_item.unwrap()) {
569: 567:                 let op = DiffOpAdd {
570: 568:                     at: index,
571: 569:                     mode: DiffOpAddMode::Normal,
572: 570:                 };
573: 571:                 added.push(op);
574: 572:             }
575: 573:             // if it's in both old and new, it can either
576: 574:             // 1) be moved (and need to move in the DOM)
577: 575:             // 2) be moved (but not need to move in the DOM)
578: 576:             //    * this would hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appen if, for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, 2 items
579: 577:             //      have been added before it, and it has moved by 2
580: 578:             if let Some(from_item) = from_item {
581: 579:                 if let Some(to_item) = to.get_full(from_item) {
582: 580:                     let moves_forward_by = (to_item.0 as i32) - (index as i32);
583: 581:                     let move_in_dom = moves_forward_by
584: 582:                         != (added.len() as i32) - (removed.len() as i32);
585: 583: 
586: 584:                     let op = DiffOpMove {
587: 585:                         from: index,
588: 586:                         len: 1,
589: 587:                         to: to_item.0,
590: 588:                         move_in_dom,
591: 589:                     };
592: 590:                     moved.push(op);
593: 591:                 }
594: 592:             }
595: 593:         }
596: 594:     }
597: 595: 
598: 596:     moved = group_adjacent_moves(moved);
599: 597: 
600: 598:     Diff {
601: 599:         removed,
602: 600:         items_to_move: moved.iter().map(|m| m.len).sum(),
603: 601:         moved,
604: 602:         added,
605: 603:         clear: false,
606: 604:     }
607: 605: }
608: 606: 
609: 607: /// Group adjacent items that are being moved as a group.
610: 608: /// For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example from `[2, 3, 5, 6]` to `[1, 2, 3, 4, 5, 6]` should result
611: 609: /// in a move for `2,3` and `5,6` rather than 4 individual moves.
612: 610: fn group_adjacent_moves(moved: Vec<DiffOpMove>) -> Vec<DiffOpMove> {
613: 611:     let mut prev: Option<DiffOpMove> = None;
614: 612:     let mut new_moved = Vec::with_capacity(moved.len());
615: 613:     for m in moved {
616: 614:         match prev {
617: 615:             Some(mut p) => {
618: 616:                 if (m.from == p.from + p.len) && (m.to == p.to + p.len) {
619: 617:                     p.len += 1;
620: 618:                     prev = Some(p);
621: 619:                 } else {
622: 620:                     new_moved.push(prev.take().unwrap());
623: 621:                     prev = Some(m);
624: 622:                 }
625: 623:             }
626: 624:             None => prev = Some(m),
627: 625:         }
628: 626:     }
629: 627:     if let Some(prev) = prev {
630: 628:         new_moved.push(prev)
631: 629:     }
632: 630:     new_moved
633: 631: }
634: 632: 
635: 633: #[derive(Debug, Default, PartialEq, Eq)]
636: 634: struct Diff {
637: 635:     removed: Vec<DiffOpRemove>,
638: 636:     moved: Vec<DiffOpMove>,
639: 637:     items_to_move: usize,
640: 638:     added: Vec<DiffOpAdd>,
641: 639:     clear: bool,
642: 640: }
643: 641: 
644: 642: #[derive(Clone, Copy, Debug, PartialEq, Eq)]
645: 643: struct DiffOpMove {
646: 644:     /// The index this range is starting relative to `from`.
647: 645:     from: usize,
648: 646:     /// The number of elements included in this range.
649: 647:     len: usize,
650: 648:     /// The starting index this range will be moved to relative to `to`.
651: 649:     to: usize,
652: 650:     /// Marks this move to be lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to the DOM, or just to the underlying
653: 651:     /// storage
654: 652:     move_in_dom: bool,
655: 653: }
656: 654: 
657: 655: impl Default for DiffOpMove {
658: 656:     fn default() -> Self {
659: 657:         Self {
660: 658:             from: 0,
661: 659:             to: 0,
662: 660:             len: 1,
663: 661:             move_in_dom: true,
664: 662:         }
665: 663:     }
666: 664: }
667: 665: 
668: 666: #[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
669: 667: struct DiffOpAdd {
670: 668:     at: usize,
671: 669:     mode: DiffOpAddMode,
672: 670: }
673: 671: 
674: 672: #[derive(Debug, PartialEq, Eq)]
675: 673: struct DiffOpRemove {
676: 674:     at: usize,
677: 675: }
678: 676: 
679: 677: #[derive(Clone, Copy, Debug, PartialEq, Eq, Default)]
680: 678: enum DiffOpAddMode {
681: 679:     #[default]
682: 680:     Normal,
683: 681:     Append,
684: 682: }
685: 683: 
686: 684: fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_diff<T, VFS, V>(
687: 685:     parent: Option<&crate::renderer::types::Element>,
688: 686:     marker: &crate::renderer::types::Placeholder,
689: 687:     diff: Diff,
690: 688:     children: &mut Vec<Option<(VFS, V::State)>>,
691: 689:     view_fn: &dyn Fn(usize, T) -> (VFS, V),
692: 690:     mut items: Vec<Option<T>>,
693: 691: ) where
694: 692:     VFS: Fn(usize),
695: 693:     V: Render,
696: 694: {
697: 695:     // The order of cmds needs to be:
698: 696:     // 1. Clear
699: 697:     // 2. Removals
700: 698:     // 3. Move out
701: 699:     // 4. Resize
702: 700:     // 5. Move in
703: 701:     // 6. Additions
704: 702:     // 7. Removes holes
705: 703:     if diff.clear {
706: 704:         for (_, mut child) in children.drain(0..).flatten() {
707: 705:             child.unmount();
708: 706:         }
709: 707: 
710: 708:         if diff.added.is_empty() {
711: 709:             return;
712: 710:         }
713: 711:     }
714: 712: 
715: 713:     for DiffOpRemove { at } in &diff.removed {
716: 714:         let (_, mut item_to_remove) = children[*at].take().unwrap();
717: 715: 
718: 716:         item_to_remove.unmount();
719: 717:     }
720: 718: 
721: 719:     let (move_cmds, add_cmds) = unpack_moves(&diff);
722: 720: 
723: 721:     let mut moved_children = move_cmds
724: 722:         .iter()
725: 723:         .map(|move_| children[move_.from].take())
726: 724:         .collect::<Vec<_>>();
727: 725: 
728: 726:     children.resize_with(children.len() + diff.added.len(), || None);
729: 727: 
730: 728:     for (i, DiffOpMove { to, .. }) in move_cmds
731: 729:         .iter()
732: 730:         .enumerate()
733: 731:         .filter(|(_, move_)| !move_.move_in_dom)
734: 732:     {
735: 733:         children[*to] = moved_children[i]
736: 734:             .take()
737: 735:             .inspect(|(set_index, _)| set_index(*to));
738: 736:     }
739: 737: 
740: 738:     for (i, DiffOpMove { to, .. }) in move_cmds
741: 739:         .into_iter()
742: 740:         .enumerate()
743: 741:         .filter(|(_, move_)| move_.move_in_dom)
744: 742:     {
745: 743:         let (set_index, mut each_item) = moved_children[i].take().unwrap();
746: 744: 
747: 745:         if let Some(parent) = parent {
748: 746:             if let Some(Some((_, state))) =
749: 747:                 children.get_next_closest_mounted_sibling(to)
750: 748:             {
751: 749:                 state.insert_before_this_or_marker(
752: 750:                     parent,
753: 751:                     &mut each_item,
754: 752:                     Some(marker.as_ref()),
755: 753:                 )
756: 754:             } else {
757: 755:                 each_item.try_mount(parent, Some(marker.as_ref()));
758: 756:             }
759: 757:         }
760: 758: 
761: 759:         set_index(to);
762: 760:         children[to] = Some((set_index, each_item));
763: 761:     }
764: 762: 
765: 763:     for DiffOpAdd { at, mode } in add_cmds {
766: 764:         let item = items[at].take().unwrap();
767: 765:         let (set_index, item) = view_fn(at, item);
768: 766:         let mut item = item.build();
769: 767: 
770: 768:         if let Some(parent) = parent {
771: 769:             match mode {
772: 770:                 DiffOpAddMode::Normal => {
773: 771:                     if let Some(Some((_, state))) =
774: 772:                         children.get_next_closest_mounted_sibling(at)
775: 773:                     {
776: 774:                         state.insert_before_this_or_marker(
777: 775:                             parent,
778: 776:                             &mut item,
779: 777:                             Some(marker.as_ref()),
780: 778:                         )
781: 779:                     } else {
782: 780:                         item.try_mount(parent, Some(marker.as_ref()));
783: 781:                     }
784: 782:                 }
785: 783:                 DiffOpAddMode::Append => {
786: 784:                     item.try_mount(parent, Some(marker.as_ref()));
787: 785:                 }
788: 786:             }
789: 787:         }
790: 788: 
791: 789:         children[at] = Some((set_index, item));
792: 790:     }
793: 791: 
794: 792:     #[allow(unstable_name_collisions)]
795: 793:     children.drain_filter(|c| c.is_none());
796: 794: }
797: 795: 
798: 796: fn unpack_moves(diff: &Diff) -> (Vec<DiffOpMove>, Vec<DiffOpAdd>) {
799: 797:     let mut moves = Vec::with_capacity(diff.items_to_move);
800: 798:     let mut adds = Vec::with_capacity(diff.added.len());
801: 799: 
802: 800:     let mut removes_iter = diff.removed.iter();
803: 801:     let mut adds_iter = diff.added.iter();
804: 802:     let mut moves_iter = diff.moved.iter();
805: 803: 
806: 804:     let mut removes_next = removes_iter.next();
807: 805:     let mut adds_next = adds_iter.next();
808: 806:     let mut moves_next = moves_iter.next().copied();
809: 807: 
810: 808:     for i in 0..diff.items_to_move + diff.added.len() + diff.removed.len() {
811: 809:         if let Some(DiffOpRemove { at, .. }) = removes_next {
812: 810:             if i == *at {
813: 811:                 removes_next = removes_iter.next();
814: 812: 
815: 813:                 continue;
816: 814:             }
817: 815:         }
818: 816: 
819: 817:         match (adds_next, &mut moves_next) {
820: 818:             (Some(add), Some(move_)) => {
821: 819:                 if add.at == i {
822: 820:                     adds.push(*add);
823: 821: 
824: 822:                     adds_next = adds_iter.next();
825: 823:                 } else {
826: 824:                     let mut single_move = *move_;
827: 825:                     single_move.len = 1;
828: 826: 
829: 827:                     moves.push(single_move);
830: 828: 
831: 829:                     move_.len -= 1;
832: 830:                     move_.from += 1;
833: 831:                     move_.to += 1;
834: 832: 
835: 833:                     if move_.len == 0 {
836: 834:                         moves_next = moves_iter.next().copied();
837: 835:                     }
838: 836:                 }
839: 837:             }
840: 838:             (Some(add), None) => {
841: 839:                 adds.push(*add);
842: 840: 
843: 841:                 adds_next = adds_iter.next();
844: 842:             }
845: 843:             (None, Some(move_)) => {
846: 844:                 let mut single_move = *move_;
847: 845:                 single_move.len = 1;
848: 846: 
849: 847:                 moves.push(single_move);
850: 848: 
851: 849:                 move_.len -= 1;
852: 850:                 move_.from += 1;
853: 851:                 move_.to += 1;
854: 852: 
855: 853:                 if move_.len == 0 {
856: 854:                     moves_next = moves_iter.next().copied();
857: 855:                 }
858: 856:             }
859: 857:             (None, None) => break,
860: 858:         }
861: 859:     }
862: 860: 
863: 861:     (moves, adds)
864: 862: }
865: 863: /*
866: 864: #[cfg(test)]
867: 865: mod tests {
868: 866:     use crate::{
869: 867:         html::element::{li, ul, HtmlElement, Li},
870: 868:         renderer::mock_dom::MockDom,
871: 869:         view::{keyed::keyed, Render},
872: 870:     };
873: 871: 
874: 872:     fn item(key: usize) -> HtmlElement<Li, (), String, MockDom> {
875: 873:         li((), key.to_string())
876: 874:     }
877: 875: 
878: 876:     #[test]
879: 877:     fn keyed_creates_list() {
880: 878:         let el = ul((), keyed(1..=3, |k| *k, item));
881: 879:         let el_state = el.build();
882: 880:         assert_eq!(
883: 881:             el_state.el.to_debug_html(),
884: 882:             "<ul><li>1</li><li>2</li><li>3</li></ul>"
885: 883:         );
886: 884:     }
887: 885: 
888: 886:     #[test]
889: 887:     fn adding_items_updates_list() {
890: 888:         let el = ul((), keyed(1..=3, |k| *k, item));
891: 889:         let mut el_state = el.build();
892: 890:         let el = ul((), keyed(1..=5, |k| *k, item));
893: 891:         el.rebuild(&mut el_state);
894: 892:         assert_eq!(
895: 893:             el_state.el.to_debug_html(),
896: 894:             "<ul><li>1</li><li>2</li><li>3</li><li>4</li><li>5</li></ul>"
897: 895:         );
898: 896:     }
899: 897: 
900: 898:     #[test]
901: 899:     fn removing_items_updates_list() {
902: 900:         let el = ul((), keyed(1..=3, |k| *k, item));
903: 901:         let mut el_state = el.build();
904: 902:         let el = ul((), keyed(1..=2, |k| *k, item));
905: 903:         el.rebuild(&mut el_state);
906: 904:         assert_eq!(
907: 905:             el_state.el.to_debug_html(),
908: 906:             "<ul><li>1</li><li>2</li></ul>"
909: 907:         );
910: 908:     }
911: 909: 
912: 910:     #[test]
913: 911:     fn swlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_items_updates_list() {
914: 912:         let el = ul((), keyed([1, 2, 3, 4, 5], |k| *k, item));
915: 913:         let mut el_state = el.build();
916: 914:         let el = ul((), keyed([1, 4, 3, 2, 5], |k| *k, item));
917: 915:         el.rebuild(&mut el_state);
918: 916:         assert_eq!(
919: 917:             el_state.el.to_debug_html(),
920: 918:             "<ul><li>1</li><li>4</li><li>3</li><li>2</li><li>5</li></ul>"
921: 919:         );
922: 920:     }
923: 921: 
924: 922:     #[test]
925: 923:     fn swlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_and_removing_orders_correctly() {
926: 924:         let el = ul((), keyed([1, 2, 3, 4, 5], |k| *k, item));
927: 925:         let mut el_state = el.build();
928: 926:         let el = ul((), keyed([1, 4, 3, 5], |k| *k, item));
929: 927:         el.rebuild(&mut el_state);
930: 928:         assert_eq!(
931: 929:             el_state.el.to_debug_html(),
932: 930:             "<ul><li>1</li><li>4</li><li>3</li><li>5</li></ul>"
933: 931:         );
934: 932:     }
935: 933: 
936: 934:     #[test]
937: 935:     fn arbitrarily_hard_adjustment() {
938: 936:         let el = ul((), keyed([1, 2, 3, 4, 5], |k| *k, item));
939: 937:         let mut el_state = el.build();
940: 938:         let el = ul((), keyed([2, 4, 3], |k| *k, item));
941: 939:         el.rebuild(&mut el_state);
942: 940:         assert_eq!(
943: 941:             el_state.el.to_debug_html(),
944: 942:             "<ul><li>2</li><li>4</li><li>3</li></ul>"
945: 943:         );
946: 944:     }
947: 945: 
948: 946:     #[test]
949: 947:     fn a_series_of_moves() {
950: 948:         let el = ul((), keyed([1, 2, 3, 4, 5], |k| *k, item));
951: 949:         let mut el_state = el.build();
952: 950:         let el = ul((), keyed([2, 4, 3], |k| *k, item));
953: 951:         el.rebuild(&mut el_state);
954: 952:         let el = ul((), keyed([1, 7, 5, 11, 13, 17], |k| *k, item));
955: 953:         el.rebuild(&mut el_state);
956: 954:         let el = ul((), keyed([2, 6, 8, 7, 13], |k| *k, item));
957: 955:         el.rebuild(&mut el_state);
958: 956:         let el = ul((), keyed([13, 4, 5, 3], |k| *k, item));
959: 957:         el.rebuild(&mut el_state);
960: 958:         let el = ul((), keyed([1, 2, 3, 4], |k| *k, item));
961: 959:         el.rebuild(&mut el_state);
962: 960:         assert_eq!(
963: 961:             el_state.el.to_debug_html(),
964: 962:             "<ul><li>1</li><li>2</li><li>3</li><li>4</li></ul>"
965: 963:         );
966: 964:     }
967: 965: 
968: 966:     #[test]
969: 967:     fn clearing_works() {
970: 968:         let el = ul((), keyed([1, 2, 3, 4, 5], |k| *k, item));
971: 969:         let mut el_state = el.build();
972: 970:         let el = ul((), keyed([], |k| *k, item));
973: 971:         el.rebuild(&mut el_state);
974: 972:         assert_eq!(el_state.el.to_debug_html(), "<ul></ul>");
975: 973:     }
976: 974: }
977: 975: */
978: 976: ```
979: 977: ```
980: 978: ```
981: 979: ```
982: 980: ```
983: 981: ```
984: 982: ```
985: 983: ```
986: ```
```
