### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\owner.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\owner.rs
2: ```rust
3: 1: //! The reactive ownership model, which manages effect cancellation, cleanups, and arena allocation.
4: 2: 
5: 3: #[cfg(feature = "hydration")]
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_hydration_context::SharedContext;
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
8: 6: use rustc_hash::FxHashMap;
9: 7: use std::{
10: 8:     any::{Any, TypeId},
11: 9:     cell::RefCell,
12: 10:     fmt::Debug,
13: 11:     mem,
14: 12:     sync::{Arc, RwLock, Weak},
15: 13: };
16: 14: 
17: 15: mod arc_stored_value;
18: 16: mod arena;
19: 17: mod arena_item;
20: 18: mod context;
21: 19: mod storage;
22: 20: mod stored_value;
23: 21: use self::arena::Arena;
24: 22: pub use arc_stored_value::ArcStoredValue;
25: 23: #[cfg(feature = "sandboxed-arenas")]
26: 24: pub use arena::sandboxed::Sandboxed;
27: 25: #[cfg(feature = "sandboxed-arenas")]
28: 26: use arena::ArenaMap;
29: 27: use arena::NodeId;
30: 28: pub use arena_item::*;
31: 29: pub use context::*;
32: 30: pub use storage::*;
33: 31: #[allow(deprecated)] // allow exporting deprecated fn
34: 32: pub use stored_value::{store_value, FromLocal, StoredValue};
35: 33: 
36: 34: /// A reactive owner, which manages
37: 35: /// 1) the cancellation of [`Effect`](crate::effect::Effect)s,
38: 36: /// 2) providing and accessing environment data via [`provide_context`] and [`use_context`],
39: 37: /// 3) running cleanup functions defined via [`Owner::on_cleanup`], and
40: 38: /// 4) an arena storage system to provide `Copy` handles via [`ArenaItem`], which is what allows
41: 39: ///    types like [`RwSignal`](crate::signal::RwSignal), [`Memo`](crate::computed::Memo), and so on to be `Copy`.
42: 40: ///
43: 41: /// Every effect and computed reactive value has an associated `Owner`. While it is running, this
44: 42: /// is marked as the current `Owner`. Whenever it re-runs, this `Owner` is cleared by calling
45: 43: /// [`Owner::with_cleanup`]. This runs cleanup functions, cancels any [`Effect`](crate::effect::Effect)s created during the
46: 44: /// last run, drops signals stored in the arena, and so on, because those effects and signals will
47: 45: /// be re-created as needed during the next run.
48: 46: ///
49: 47: /// When the owner is ultimately dropped, it will clean up its owned resources in the same way.
50: 48: ///
51: 49: /// The "current owner" is set on the thread-local basis: whenever one of these reactive nodes is
52: 50: /// running, it will set the current owner on its thread with [`Owner::with`] or [`Owner::set`],
53: 51: /// allowing other reactive nodes implicitly to access the fact that it is currently the owner.
54: 52: ///
55: 53: /// For a longer discussion of the ownership model, [see
56: 54: /// here](https://book.lyx-core-lyx_core_lyx-core-lyx_core_leptos.dev/lyx-platform-lyx_platform_lyx-platform-lyx_platform_appendix_life_cycle.html).
57: 55: #[derive(Debug, Clone, Default)]
58: 56: #[must_use]
59: 57: pub struct Owner {
60: 58:     pub(crate) inner: Arc<RwLock<OwnerInner>>,
61: 59:     #[cfg(feature = "hydration")]
62: 60:     pub(crate) shared_context: Option<Arc<dyn SharedContext + Send + Sync>>,
63: 61: }
64: 62: 
65: 63: impl Owner {
66: 64:     fn downgrade(&self) -> WeakOwner {
67: 65:         WeakOwner {
68: 66:             inner: Arc::downgrade(&self.inner),
69: 67:             #[cfg(feature = "hydration")]
70: 68:             shared_context: self.shared_context.as_ref().map(Arc::downgrade),
71: 69:         }
72: 70:     }
73: 71: }
74: 72: 
75: 73: #[derive(Clone)]
76: 74: struct WeakOwner {
77: 75:     inner: Weak<RwLock<OwnerInner>>,
78: 76:     #[cfg(feature = "hydration")]
79: 77:     shared_context: Option<Weak<dyn SharedContext + Send + Sync>>,
80: 78: }
81: 79: 
82: 80: impl WeakOwner {
83: 81:     fn upgrade(&self) -> Option<Owner> {
84: 82:         self.inner.upgrade().map(|inner| {
85: 83:             #[cfg(feature = "hydration")]
86: 84:             let shared_context =
87: 85:                 self.shared_context.as_ref().and_then(|sc| sc.upgrade());
88: 86:             Owner {
89: 87:                 inner,
90: 88:                 #[cfg(feature = "hydration")]
91: 89:                 shared_context,
92: 90:             }
93: 91:         })
94: 92:     }
95: 93: }
96: 94: 
97: 95: impl PartialEq for Owner {
98: 96:     fn eq(&self, other: &Self) -> bool {
99: 97:         Arc::ptr_eq(&self.inner, &other.inner)
100: 98:     }
101: 99: }
102: 100: 
103: 101: thread_local! {
104: 102:     static OWNER: RefCell<Option<WeakOwner>> = Default::default();
105: 103: }
106: 104: 
107: 105: impl Owner {
108: 106:     /// Returns a unique identifier for this owner, which can be used to identify it for debugging
109: 107:     /// purposes.
110: 108:     ///
111: 109:     /// Intended for debugging only; this is not guaranteed to be stable between runs.
112: 110:     pub fn debug_id(&self) -> usize {
113: 111:         Arc::as_ptr(&self.inner) as usize
114: 112:     }
115: 113: 
116: 114:     /// Returns the list of parents, grandparents, and ancestors, with values corresponding to
117: 115:     /// [`Owner::debug_id`] for each.
118: 116:     ///
119: 117:     /// Intended for debugging only; this is not guaranteed to be stable between runs.
120: 118:     pub fn ancestry(&self) -> Vec<usize> {
121: 119:         let mut ancestors = Vec::new();
122: 120:         let mut curr_parent = self
123: 121:             .inner
124: 122:             .read()
125: 123:             .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
126: 124:             .parent
127: 125:             .as_ref()
128: 126:             .and_then(|n| n.upgrade());
129: 127:         while let Some(parent) = curr_parent {
130: 128:             ancestors.push(Arc::as_ptr(&parent) as usize);
131: 129:             curr_parent = parent
132: 130:                 .read()
133: 131:                 .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
134: 132:                 .parent
135: 133:                 .as_ref()
136: 134:                 .and_then(|n| n.upgrade());
137: 135:         }
138: 136:         ancestors
139: 137:     }
140: 138: 
141: 139:     /// Creates a new `Owner` and registers it as a child of the current `Owner`, if there is one.
142: 140:     pub fn new() -> Self {
143: 141:         #[cfg(not(feature = "hydration"))]
144: 142:         let parent = OWNER.with(|o| {
145: 143:             o.borrow()
146: 144:                 .as_ref()
147: 145:                 .and_then(|o| o.upgrade())
148: 146:                 .map(|o| Arc::downgrade(&o.inner))
149: 147:         });
150: 148:         #[cfg(feature = "hydration")]
151: 149:         let (parent, shared_context) = OWNER
152: 150:             .with(|o| {
153: 151:                 o.borrow().as_ref().and_then(|o| o.upgrade()).map(|o| {
154: 152:                     (Some(Arc::downgrade(&o.inner)), o.shared_context.clone())
155: 153:                 })
156: 154:             })
157: 155:             .unwrap_or((None, None));
158: 156:         let this = Self {
159: 157:             inner: Arc::new(RwLock::new(OwnerInner {
160: 158:                 parent: parent.clone(),
161: 159:                 nodes: Default::default(),
162: 160:                 contexts: Default::default(),
163: 161:                 cleanups: Default::default(),
164: 162:                 children: Default::default(),
165: 163:                 #[cfg(feature = "sandboxed-arenas")]
166: 164:                 arena: parent
167: 165:                     .as_ref()
168: 166:                     .and_then(|parent| parent.upgrade())
169: 167:                     .map(|parent| parent.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().arena.clone())
170: 168:                     .unwrap_or_default(),
171: 169:                 paused: false,
172: 170:             })),
173: 171:             #[cfg(feature = "hydration")]
174: 172:             shared_context,
175: 173:         };
176: 174:         if let Some(parent) = parent.and_then(|n| n.upgrade()) {
177: 175:             parent
178: 176:                 .write()
179: 177:                 .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
180: 178:                 .children
181: 179:                 .push(Arc::downgrade(&this.inner));
182: 180:         }
183: 181:         this
184: 182:     }
185: 183: 
186: 184:     /// Creates a new "root" context with the given [`SharedContext`], which allows sharing data
187: 185:     /// between the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server and lyx-core-lyx_core_lyx-core-lyx_core_client.
188: 186:     ///
189: 187:     /// Only one `SharedContext` needs to be created per request, and will be automatically shared
190: 188:     /// by any other `Owner`s created under this one.
191: 189:     #[cfg(feature = "hydration")]
192: 190:     #[track_caller]
193: 191:     pub fn new_root(
194: 192:         shared_context: Option<Arc<dyn SharedContext + Send + Sync>>,
195: 193:     ) -> Self {
196: 194:         let this = Self {
197: 195:             inner: Arc::new(RwLock::new(OwnerInner {
198: 196:                 parent: None,
199: 197:                 nodes: Default::default(),
200: 198:                 contexts: Default::default(),
201: 199:                 cleanups: Default::default(),
202: 200:                 children: Default::default(),
203: 201:                 #[cfg(feature = "sandboxed-arenas")]
204: 202:                 arena: Default::default(),
205: 203:                 paused: false,
206: 204:             })),
207: 205:             #[cfg(feature = "hydration")]
208: 206:             shared_context,
209: 207:         };
210: 208:         this.set();
211: 209:         this
212: 210:     }
213: 211: 
214: 212:     /// Returns the parent of this `Owner`, if any.
215: 213:     ///
216: 214:     /// None when:
217: 215:     /// - This is a root owner
218: 216:     /// - The parent has been dropped
219: 217:     pub fn parent(&self) -> Option<Owner> {
220: 218:         self.inner
221: 219:             .read()
222: 220:             .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
223: 221:             .parent
224: 222:             .as_ref()
225: 223:             .and_then(|p| p.upgrade())
226: 224:             .map(|inner| Owner {
227: 225:                 inner,
228: 226:                 #[cfg(feature = "hydration")]
229: 227:                 shared_context: self.shared_context.clone(),
230: 228:             })
231: 229:     }
232: 230: 
233: 231:     /// Creates a new `Owner` that is the child of the current `Owner`, if any.
234: 232:     pub fn child(&self) -> Self {
235: 233:         let parent = Some(Arc::downgrade(&self.inner));
236: 234:         let mut inner = self.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
237: 235:         #[cfg(feature = "sandboxed-arenas")]
238: 236:         let arena = inner.arena.clone();
239: 237:         let paused = inner.paused;
240: 238:         let child = Self {
241: 239:             inner: Arc::new(RwLock::new(OwnerInner {
242: 240:                 parent,
243: 241:                 nodes: Default::default(),
244: 242:                 contexts: Default::default(),
245: 243:                 cleanups: Default::default(),
246: 244:                 children: Default::default(),
247: 245:                 #[cfg(feature = "sandboxed-arenas")]
248: 246:                 arena,
249: 247:                 paused,
250: 248:             })),
251: 249:             #[cfg(feature = "hydration")]
252: 250:             shared_context: self.shared_context.clone(),
253: 251:         };
254: 252:         inner.children.push(Arc::downgrade(&child.inner));
255: 253:         child
256: 254:     }
257: 255: 
258: 256:     /// Sets this as the current `Owner`.
259: 257:     pub fn set(&self) {
260: 258:         OWNER.with_borrow_mut(|owner| *owner = Some(self.downgrade()));
261: 259:         #[cfg(feature = "sandboxed-arenas")]
262: 260:         Arena::set(&self.inner.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().arena);
263: 261:     }
264: 262: 
265: 263:     /// Runs the given function with this as the current `Owner`.
266: 264:     pub fn with<T>(&self, fun: impl FnOnce() -> T) -> T {
267: 265:         // codegen optimisation:
268: 266:         fn inner_1(self_: &Owner) -> Option<WeakOwner> {
269: 267:             let prev = OWNER.with_borrow_mut(|o| o.replace(self_.downgrade()));
270: 268:             #[cfg(feature = "sandboxed-arenas")]
271: 269:             Arena::set(&self_.inner.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().arena);
272: 270:             prev
273: 271:         }
274: 272:         let prev = inner_1(self);
275: 273: 
276: 274:         let val = fun();
277: 275: 
278: 276:         // monomorphisation optimisation:
279: 277:         fn inner_2(prev: Option<WeakOwner>) {
280: 278:             OWNER.with_borrow_mut(|o| *o = prev);
281: 279:         }
282: 280:         inner_2(prev);
283: 281: 
284: 282:         val
285: 283:     }
286: 284: 
287: 285:     /// Cleans up this owner, the given function with this as the current `Owner`.
288: 286:     pub fn with_cleanup<T>(&self, fun: impl FnOnce() -> T) -> T {
289: 287:         self.cleanup();
290: 288:         self.with(fun)
291: 289:     }
292: 290: 
293: 291:     /// Cleans up this owner in the following order:
294: 292:     /// 1) Runs `cleanup` on all children,
295: 293:     /// 2) Runs all cleanup functions registered with [`Owner::on_cleanup`],
296: 294:     /// 3) Drops the values of any arena-allocated [`ArenaItem`]s.
297: 295:     pub fn cleanup(&self) {
298: 296:         self.inner.cleanup();
299: 297:     }
300: 298: 
301: 299:     /// Registers a function to be run the next time the current owner is cleaned up.
302: 300:     ///
303: 301:     /// Because the ownership model is associated with reactive nodes, each "decision point" in an
304: 302:     /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_application tends to have a separate `Owner`: as a result, these cleanup functions often
305: 303:     /// fill the same need as an "on unmount" function in other UI lyx-platform-lyx_platform_lyx-platform-lyx_platform_approaches, etc.
306: 304:     pub fn on_cleanup(fun: impl FnOnce() + Send + Sync + 'static) {
307: 305:         if let Some(owner) = Owner::current() {
308: 306:             let mut inner = owner.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
309: 307: 
310: 308:             #[cfg(feature = "sandboxed-arenas")]
311: 309:             let fun = {
312: 310:                 let arena = Arc::clone(&inner.arena);
313: 311:                 move || {
314: 312:                     Arena::set(&arena);
315: 313:                     fun()
316: 314:                 }
317: 315:             };
318: 316: 
319: 317:             inner.cleanups.push(Box::new(fun));
320: 318:         }
321: 319:     }
322: 320: 
323: 321:     fn register(&self, node: NodeId) {
324: 322:         self.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().nodes.push(node);
325: 323:     }
326: 324: 
327: 325:     /// Returns the current `Owner`, if any.
328: 326:     pub fn current() -> Option<Owner> {
329: 327:         OWNER.with(|o| o.borrow().as_ref().and_then(|n| n.upgrade()))
330: 328:     }
331: 329: 
332: 330:     /// Returns the [`SharedContext`] associated with this owner, if any.
333: 331:     #[cfg(feature = "hydration")]
334: 332:     pub fn shared_context(
335: 333:         &self,
336: 334:     ) -> Option<Arc<dyn SharedContext + Send + Sync>> {
337: 335:         self.shared_context.clone()
338: 336:     }
339: 337: 
340: 338:     /// Removes this from its state as the thread-local owner and drops it.
341: 339:     /// If there are other holders of this owner, it may not cleanup, if always cleaning up is required,
342: 340:     /// see [`Owner::unset_with_forced_cleanup`].
343: 341:     pub fn unset(self) {
344: 342:         OWNER.with_borrow_mut(|owner| {
345: 343:             if owner.as_ref().and_then(|n| n.upgrade()) == Some(self) {
346: 344:                 mem::take(owner);
347: 345:             }
348: 346:         })
349: 347:     }
350: 348: 
351: 349:     /// Removes this from its state as the thread-local owner and drops it.
352: 350:     /// Unlike [`Owner::unset`], this will always run cleanup on this owner,
353: 351:     /// even if there are other holders of this owner.
354: 352:     pub fn unset_with_forced_cleanup(self) {
355: 353:         OWNER.with_borrow_mut(|owner| {
356: 354:             if owner
357: 355:                 .as_ref()
358: 356:                 .and_then(|n| n.upgrade())
359: 357:                 .map(|o| o == self)
360: 358:                 .unwrap_or(false)
361: 359:             {
362: 360:                 mem::take(owner);
363: 361:             }
364: 362:         });
365: 363:         self.cleanup();
366: 364:     }
367: 365: 
368: 366:     /// Returns the current [`SharedContext`], if any.
369: 367:     #[cfg(feature = "hydration")]
370: 368:     pub fn current_shared_context(
371: 369:     ) -> Option<Arc<dyn SharedContext + Send + Sync>> {
372: 370:         OWNER.with(|o| {
373: 371:             o.borrow()
374: 372:                 .as_ref()
375: 373:                 .and_then(|o| o.upgrade())
376: 374:                 .and_then(|current| current.shared_context.clone())
377: 375:         })
378: 376:     }
379: 377: 
380: 378:     /// Runs the given function, after indicating that the current [`SharedContext`] should be
381: 379:     /// prepared to handle any data created in the function.
382: 380:     #[cfg(feature = "hydration")]
383: 381:     pub fn with_hydration<T>(fun: impl FnOnce() -> T + 'static) -> T {
384: 382:         fn inner<T>(fun: Box<dyn FnOnce() -> T>) -> T {
385: 383:             provide_context(IsHydrating(true));
386: 384: 
387: 385:             let sc = OWNER.with_borrow(|o| {
388: 386:                 o.as_ref()
389: 387:                     .and_then(|o| o.upgrade())
390: 388:                     .and_then(|current| current.shared_context.clone())
391: 389:             });
392: 390:             match sc {
393: 391:                 None => fun(),
394: 392:                 Some(sc) => {
395: 393:                     let prev = sc.get_is_hydrating();
396: 394:                     sc.set_is_hydrating(true);
397: 395:                     let value = fun();
398: 396:                     sc.set_is_hydrating(prev);
399: 397:                     value
400: 398:                 }
401: 399:             }
402: 400:         }
403: 401: 
404: 402:         inner(Box::new(fun))
405: 403:     }
406: 404: 
407: 405:     /// Runs the given function, after indicating that the current [`SharedContext`] should /// not handle data created in this function.
408: 406:     #[cfg(feature = "hydration")]
409: 407:     pub fn with_no_hydration<T>(fun: impl FnOnce() -> T + 'static) -> T {
410: 408:         fn inner<T>(fun: Box<dyn FnOnce() -> T>) -> T {
411: 409:             provide_context(IsHydrating(false));
412: 410: 
413: 411:             let sc = OWNER.with_borrow(|o| {
414: 412:                 o.as_ref()
415: 413:                     .and_then(|o| o.upgrade())
416: 414:                     .and_then(|current| current.shared_context.clone())
417: 415:             });
418: 416:             match sc {
419: 417:                 None => fun(),
420: 418:                 Some(sc) => {
421: 419:                     let prev = sc.get_is_hydrating();
422: 420:                     sc.set_is_hydrating(false);
423: 421:                     let value = fun();
424: 422:                     sc.set_is_hydrating(prev);
425: 423:                     value
426: 424:                 }
427: 425:             }
428: 426:         }
429: 427: 
430: 428:         inner(Box::new(fun))
431: 429:     }
432: 430: 
433: 431:     /// Pauses the execution of side effects for this owner, and any of its descendants.
434: 432:     ///
435: 433:     /// If this owner is the owner for an [`Effect`](crate::effect::Effect) or [`RenderEffect`](crate::effect::RenderEffect), this effect will not run until [`Owner::resume`] is called. All children of this effects are also paused.
436: 434:     ///
437: 435:     /// Any notifications will be ignored; effects that are notified will paused will not run when
438: 436:     /// resumed, until they are notified again by a source after being resumed.
439: 437:     pub fn pause(&self) {
440: 438:         let mut stack = Vec::with_capacity(16);
441: 439:         stack.push(Arc::downgrade(&self.inner));
442: 440:         while let Some(curr) = stack.pop() {
443: 441:             if let Some(curr) = curr.upgrade() {
444: 442:                 let mut curr = curr.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
445: 443:                 curr.paused = true;
446: 444:                 stack.extend(curr.children.iter().map(Weak::clone));
447: 445:             }
448: 446:         }
449: 447:     }
450: 448: 
451: 449:     /// Whether this owner has been paused by [`Owner::pause`].
452: 450:     pub fn paused(&self) -> bool {
453: 451:         self.inner.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().paused
454: 452:     }
455: 453: 
456: 454:     /// Resumes side effects that have been paused by [`Owner::pause`].
457: 455:     ///
458: 456:     /// All children will also be resumed.
459: 457:     ///
460: 458:     /// This will *not* cause side effects that were notified while paused to run, until they are
461: 459:     /// notified again by a source after being resumed.
462: 460:     pub fn resume(&self) {
463: 461:         let mut stack = Vec::with_capacity(16);
464: 462:         stack.push(Arc::downgrade(&self.inner));
465: 463:         while let Some(curr) = stack.pop() {
466: 464:             if let Some(curr) = curr.upgrade() {
467: 465:                 let mut curr = curr.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
468: 466:                 curr.paused = false;
469: 467:                 stack.extend(curr.children.iter().map(Weak::clone));
470: 468:             }
471: 469:         }
472: 470:     }
473: 471: }
474: 472: 
475: 473: #[doc(hidden)]
476: 474: #[derive(Copy, Clone, Debug, PartialEq, Eq, Hash)]
477: 475: pub struct IsHydrating(pub bool);
478: 476: 
479: 477: /// Registers a function to be run the next time the current owner is cleaned up.
480: 478: ///
481: 479: /// Because the ownership model is associated with reactive nodes, each "decision point" in an
482: 480: /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_application tends to have a separate `Owner`: as a result, these cleanup functions often
483: 481: /// fill the same need as an "on unmount" function in other UI lyx-platform-lyx_platform_lyx-platform-lyx_platform_approaches, etc.
484: 482: ///
485: 483: /// This is an alias for [`Owner::on_cleanup`].
486: 484: pub fn on_cleanup(fun: impl FnOnce() + Send + Sync + 'static) {
487: 485:     Owner::on_cleanup(fun)
488: 486: }
489: 487: 
490: 488: #[derive(Default)]
491: 489: pub(crate) struct OwnerInner {
492: 490:     pub parent: Option<Weak<RwLock<OwnerInner>>>,
493: 491:     nodes: Vec<NodeId>,
494: 492:     pub contexts: FxHashMap<TypeId, Box<dyn Any + Send + Sync>>,
495: 493:     pub cleanups: Vec<Box<dyn FnOnce() + Send + Sync>>,
496: 494:     pub children: Vec<Weak<RwLock<OwnerInner>>>,
497: 495:     #[cfg(feature = "sandboxed-arenas")]
498: 496:     arena: Arc<RwLock<ArenaMap>>,
499: 497:     paused: bool,
500: 498: }
501: 499: 
502: 500: impl Debug for OwnerInner {
503: 501:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
504: 502:         f.debug_struct("OwnerInner")
505: 503:             .field("parent", &self.parent)
506: 504:             .field("nodes", &self.nodes)
507: 505:             .field("contexts", &self.contexts)
508: 506:             .field("cleanups", &self.cleanups.len())
509: 507:             .finish()
510: 508:     }
511: 509: }
512: 510: 
513: 511: impl Drop for OwnerInner {
514: 512:     fn drop(&mut self) {
515: 513:         for child in std::mem::take(&mut self.children) {
516: 514:             if let Some(child) = child.upgrade() {
517: 515:                 child.cleanup();
518: 516:             }
519: 517:         }
520: 518: 
521: 519:         for cleanup in mem::take(&mut self.cleanups) {
522: 520:             cleanup();
523: 521:         }
524: 522: 
525: 523:         let nodes = mem::take(&mut self.nodes);
526: 524:         if !nodes.is_empty() {
527: 525:             #[cfg(not(feature = "sandboxed-arenas"))]
528: 526:             Arena::with_mut(|arena| {
529: 527:                 for node in nodes {
530: 528:                     _ = arena.remove(node);
531: 529:                 }
532: 530:             });
533: 531:             #[cfg(feature = "sandboxed-arenas")]
534: 532:             {
535: 533:                 let mut arena = self.arena.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
536: 534:                 for node in nodes {
537: 535:                     _ = arena.remove(node);
538: 536:                 }
539: 537:             }
540: 538:         }
541: 539:     }
542: 540: }
543: 541: 
544: 542: trait Cleanup {
545: 543:     fn cleanup(&self);
546: 544: }
547: 545: 
548: 546: impl Cleanup for RwLock<OwnerInner> {
549: 547:     fn cleanup(&self) {
550: 548:         let (cleanups, nodes, children) = {
551: 549:             let mut lock = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
552: 550:             (
553: 551:                 mem::take(&mut lock.cleanups),
554: 552:                 mem::take(&mut lock.nodes),
555: 553:                 mem::take(&mut lock.children),
556: 554:             )
557: 555:         };
558: 556:         for child in children {
559: 557:             if let Some(child) = child.upgrade() {
560: 558:                 child.cleanup();
561: 559:             }
562: 560:         }
563: 561:         for cleanup in cleanups {
564: 562:             cleanup();
565: 563:         }
566: 564: 
567: 565:         if !nodes.is_empty() {
568: 566:             #[cfg(not(feature = "sandboxed-arenas"))]
569: 567:             Arena::with_mut(|arena| {
570: 568:                 for node in nodes {
571: 569:                     _ = arena.remove(node);
572: 570:                 }
573: 571:             });
574: 572:             #[cfg(feature = "sandboxed-arenas")]
575: 573:             {
576: 574:                 let arena = self.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().arena.clone();
577: 575:                 let mut arena = arena.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
578: 576:                 for node in nodes {
579: 577:                     _ = arena.remove(node);
580: 578:                 }
581: 579:             }
582: 580:         }
583: 581:     }
584: 582: }
585: ```
```
