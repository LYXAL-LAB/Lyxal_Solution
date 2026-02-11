### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\effect\render_effect.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\effect\render_effect.rs
2: ```rust
3: 1: use crate::{
4: 2:     channel::channel,
5: 3:     effect::inner::EffectInner,
6: 4:     graph::{
7: 5:         AnySubscriber, ReactiveNode, SourceSet, Subscriber, ToAnySubscriber,
8: 6:         WithOblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
9: 7:     },
10: 8:     owner::Owner,
11: 9: };
12: 10: use futures::StreamExt;
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
14: 12: #[cfg(feature = "subsecond")]
15: 13: use std::sync::Mutex;
16: 14: use std::{
17: 15:     fmt::Debug,
18: 16:     future::{Future, IntoFuture},
19: 17:     mem,
20: 18:     pin::Pin,
21: 19:     sync::{Arc, RwLock, Weak},
22: 20: };
23: 21: 
24: 22: /// A render effect is similar to an [`Effect`](super::Effect), but with two key differences:
25: 23: /// 1. Its first run takes place immediately and synchronously: for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, if it is being used to
26: 24: ///    drive a user interface, it will run during rendering, not on the next tick after rendering.
27: 25: ///    (Hence “render effect.”)
28: 26: /// 2. It is canceled when the `RenderEffect` itself is dropped, rather than being stored in the
29: 27: ///    reactive system and canceled when the `Owner` cleans up.
30: 28: ///
31: 29: /// Unless you are implementing a rendering framework, or require one of these two characteristics,
32: 30: /// it is unlikely you will use render effects directly.
33: 31: ///
34: 32: /// Like an [`Effect`](super::Effect), a render effect runs only with the `effects` feature
35: 33: /// enabled.
36: 34: #[must_use = "A RenderEffect will be canceled when it is dropped. Creating a \
37: 35:               RenderEffect that is not stored in some other data structure or \
38: 36:               leaked will drop it immediately, and it will not react to \
39: 37:               changes in signals it reads."]
40: 38: pub struct RenderEffect<T>
41: 39: where
42: 40:     T: 'static,
43: 41: {
44: 42:     value: Arc<RwLock<Option<T>>>,
45: 43:     inner: Arc<RwLock<EffectInner>>,
46: 44: }
47: 45: 
48: 46: impl<T> Debug for RenderEffect<T> {
49: 47:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
50: 48:         f.debug_struct("RenderEffect")
51: 49:             .field("inner", &Arc::as_ptr(&self.inner))
52: 50:             .finish()
53: 51:     }
54: 52: }
55: 53: 
56: 54: #[cfg(feature = "subsecond")]
57: 55: type CurrentHotPtr = Box<dyn Fn() -> Option<subsecond::HotFnPtr> + Send + Sync>;
58: 56: 
59: 57: impl<T> RenderEffect<T>
60: 58: where
61: 59:     T: 'static,
62: 60: {
63: 61:     /// Creates a new render effect, which immediately runs `fun`.
64: 62:     pub fn new(fun: impl FnMut(Option<T>) -> T + 'static) -> Self {
65: 63:         #[cfg(feature = "subsecond")]
66: 64:         let (hot_fn_ptr, fun) = {
67: 65:             let fun = Arc::new(Mutex::new(subsecond::HotFn::current(fun)));
68: 66:             (
69: 67:                 {
70: 68:                     let fun = Arc::downgrade(&fun);
71: 69:                     let wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped = send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(move || {
72: 70:                         fun.upgrade()
73: 71:                             .map(|n| n.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().ptr_address())
74: 72:                     });
75: 73:                     // it's not redundant, it's due to the SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper deref
76: 74:                     #[allow(clippy::redundant_closure)]
77: 75:                     Box::new(move || wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped())
78: 76:                 },
79: 77:                 move |prev| fun.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().call((prev,)),
80: 78:             )
81: 79:         };
82: 80: 
83: 81:         Self::new_with_value_erased(
84: 82:             Box::new(fun),
85: 83:             None,
86: 84:             #[cfg(feature = "subsecond")]
87: 85:             hot_fn_ptr,
88: 86:         )
89: 87:     }
90: 88: 
91: 89:     /// Creates a new render effect with an initial value.
92: 90:     pub fn new_with_value(
93: 91:         fun: impl FnMut(Option<T>) -> T + 'static,
94: 92:         initial_value: Option<T>,
95: 93:     ) -> Self {
96: 94:         #[cfg(feature = "subsecond")]
97: 95:         let (hot_fn_ptr, fun) = {
98: 96:             let fun = Arc::new(Mutex::new(subsecond::HotFn::current(fun)));
99: 97:             (
100: 98:                 {
101: 99:                     let fun = Arc::downgrade(&fun);
102: 100:                     let wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped = send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(move || {
103: 101:                         fun.upgrade()
104: 102:                             .map(|n| n.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().ptr_address())
105: 103:                     });
106: 104:                     // it's not redundant, it's due to the SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper deref
107: 105:                     #[allow(clippy::redundant_closure)]
108: 106:                     Box::new(move || wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped())
109: 107:                 },
110: 108:                 move |prev| fun.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().call((prev,)),
111: 109:             )
112: 110:         };
113: 111: 
114: 112:         Self::new_with_value_erased(
115: 113:             Box::new(fun),
116: 114:             initial_value,
117: 115:             #[cfg(feature = "subsecond")]
118: 116:             hot_fn_ptr,
119: 117:         )
120: 118:     }
121: 119: 
122: 120:     /// Creates a new render effect, which immediately runs `fun`.
123: 121:     pub async fn new_with_async_value(
124: 122:         fun: impl FnMut(Option<T>) -> T + 'static,
125: 123:         value: impl IntoFuture<Output = T> + 'static,
126: 124:     ) -> Self {
127: 125:         #[cfg(feature = "subsecond")]
128: 126:         let mut fun = subsecond::HotFn::current(fun);
129: 127:         #[cfg(feature = "subsecond")]
130: 128:         let fun = move |prev| fun.call((prev,));
131: 129: 
132: 130:         Self::new_with_async_value_erased(
133: 131:             Box::new(fun),
134: 132:             Box::pin(value.into_future()),
135: 133:         )
136: 134:         .await
137: 135:     }
138: 136: 
139: 137:     fn new_with_value_erased(
140: 138:         #[allow(unused_mut)] mut fun: Box<dyn FnMut(Option<T>) -> T + 'static>,
141: 139:         initial_value: Option<T>,
142: 140:         // this argument can be used to invalidate individual effects in the future
143: 141:         // in present experiments, I have found that it is not actually granular enough to make a difference
144: 142:         #[allow(unused)]
145: 143:         #[cfg(feature = "subsecond")]
146: 144:         hot_fn_ptr: CurrentHotPtr,
147: 145:     ) -> Self {
148: 146:         // codegen optimisation:
149: 147:         fn prep() -> (Owner, Arc<RwLock<EffectInner>>, crate::channel::Receiver)
150: 148:         {
151: 149:             let (oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, rx) = channel();
152: 150:             let owner = Owner::new();
153: 151:             let inner = Arc::new(RwLock::new(EffectInner {
154: 152:                 dirty: false,
155: 153:                 oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
156: 154:                 sources: SourceSet::new(),
157: 155:             }));
158: 156:             (owner, inner, rx)
159: 157:         }
160: 158: 
161: 159:         let (owner, inner, mut rx) = prep();
162: 160: 
163: 161:         let value = Arc::new(RwLock::new(None::<T>));
164: 162: 
165: 163:         #[cfg(not(feature = "effects"))]
166: 164:         {
167: 165:             let _ = initial_value;
168: 166:             let _ = owner;
169: 167:             let _ = &mut rx;
170: 168:             let _ = fun;
171: 169:         }
172: 170: 
173: 171:         #[cfg(feature = "effects")]
174: 172:         {
175: 173:             let subscriber = inner.to_any_subscriber();
176: 174: 
177: 175:             #[cfg(all(feature = "subsecond", debug_assertions))]
178: 176:             let mut fun = {
179: 177:                 use crate::graph::ReactiveNode;
180: 178:                 use rustc_hash::FxHashMap;
181: 179:                 use std::sync::{Arc, LazyLock, Mutex};
182: 180:                 use subsecond::HotFnPtr;
183: 181: 
184: 182:                 static HOT_RELOAD_SUBSCRIBERS: LazyLock<
185: 183:                     Mutex<FxHashMap<AnySubscriber, (HotFnPtr, CurrentHotPtr)>>,
186: 184:                 > = LazyLock::new(|| {
187: 185:                     subsecond::register_handler(Arc::new(|| {
188: 186:                         HOT_RELOAD_SUBSCRIBERS.lock().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().retain(
189: 187:                             |subscriber, (prev_ptr, hot_fn_ptr)| {
190: 188:                                 match hot_fn_ptr() {
191: 189:                                     None => false,
192: 190:                                     Some(curr_hot_ptr) => {
193: 191:                                         if curr_hot_ptr != *prev_ptr {
194: 192:                                             crate::log_warning(format_args!(
195: 193:                                                 "{prev_ptr:?} <> \
196: 194:                                                  {curr_hot_ptr:?}",
197: 195:                                             ));
198: 196:                                             *prev_ptr = curr_hot_ptr;
199: 197: 
200: 198:                                             subscriber.mark_dirty();
201: 199:                                         }
202: 200:                                         true
203: 201:                                     }
204: 202:                                 }
205: 203:                             },
206: 204:                         );
207: 205:                     }));
208: 206:                     Default::default()
209: 207:                 });
210: 208: 
211: 209:                 let mut fun = subsecond::HotFn::current(fun);
212: 210:                 let initial_ptr = hot_fn_ptr().unwrap();
213: 211:                 HOT_RELOAD_SUBSCRIBERS
214: 212:                     .lock()
215: 213:                     .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
216: 214:                     .insert(subscriber.clone(), (initial_ptr, hot_fn_ptr));
217: 215:                 move |prev| fun.call((prev,))
218: 216:             };
219: 217: 
220: 218:             *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(
221: 219:                 owner.with(|| subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| fun(initial_value))),
222: 220:             );
223: 221: 
224: 222:             lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local({
225: 223:                 let value = Arc::clone(&value);
226: 224: 
227: 225:                 async move {
228: 226:                     while rx.next().await.is_some() {
229: 227:                         if !owner.paused()
230: 228:                             && subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
231: 229:                                 subscriber.update_if_necessary()
232: 230:                             })
233: 231:                         {
234: 232:                             subscriber.clear_sources(&subscriber);
235: 233: 
236: 234:                             let old_value =
237: 235:                                 mem::take(&mut *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned());
238: 236:                             let new_value = owner.with_cleanup(|| {
239: 237:                                 subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| fun(old_value))
240: 238:                             });
241: 239:                             *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(new_value);
242: 240:                         }
243: 241:                     }
244: 242:                 }
245: 243:             });
246: 244:         }
247: 245: 
248: 246:         RenderEffect { value, inner }
249: 247:     }
250: 248: 
251: 249:     async fn new_with_async_value_erased(
252: 250:         mut fun: Box<dyn FnMut(Option<T>) -> T + 'static>,
253: 251:         initial_value: Pin<Box<dyn Future<Output = T>>>,
254: 252:     ) -> Self {
255: 253:         // codegen optimisation:
256: 254:         fn prep() -> (Owner, Arc<RwLock<EffectInner>>, crate::channel::Receiver)
257: 255:         {
258: 256:             let (oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, rx) = channel();
259: 257:             let owner = Owner::new();
260: 258:             let inner = Arc::new(RwLock::new(EffectInner {
261: 259:                 dirty: false,
262: 260:                 oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
263: 261:                 sources: SourceSet::new(),
264: 262:             }));
265: 263:             (owner, inner, rx)
266: 264:         }
267: 265: 
268: 266:         let (owner, inner, mut rx) = prep();
269: 267: 
270: 268:         let value = Arc::new(RwLock::new(None::<T>));
271: 269: 
272: 270:         #[cfg(not(feature = "effects"))]
273: 271:         {
274: 272:             drop(initial_value);
275: 273:             let _ = owner;
276: 274:             let _ = &mut rx;
277: 275:             let _ = &mut fun;
278: 276:         }
279: 277: 
280: 278:         #[cfg(feature = "effects")]
281: 279:         {
282: 280:             use crate::computed::ScopedFuture;
283: 281: 
284: 282:             let subscriber = inner.to_any_subscriber();
285: 283: 
286: 284:             let initial = subscriber
287: 285:                 .with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| ScopedFuture::new(initial_value))
288: 286:                 .await;
289: 287:             *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(initial);
290: 288: 
291: 289:             lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::spawn_local({
292: 290:                 let value = Arc::clone(&value);
293: 291: 
294: 292:                 async move {
295: 293:                     while rx.next().await.is_some() {
296: 294:                         if !owner.paused()
297: 295:                             && subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
298: 296:                                 subscriber.update_if_necessary()
299: 297:                             })
300: 298:                         {
301: 299:                             subscriber.clear_sources(&subscriber);
302: 300: 
303: 301:                             let old_value =
304: 302:                                 mem::take(&mut *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned());
305: 303:                             let new_value = owner.with_cleanup(|| {
306: 304:                                 subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| fun(old_value))
307: 305:                             });
308: 306:                             *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(new_value);
309: 307:                         }
310: 308:                     }
311: 309:                 }
312: 310:             });
313: 311:         }
314: 312: 
315: 313:         RenderEffect { value, inner }
316: 314:     }
317: 315: 
318: 316:     /// Mutably accesses the current value.
319: 317:     pub fn with_value_mut<U>(
320: 318:         &self,
321: 319:         fun: impl FnOnce(&mut T) -> U,
322: 320:     ) -> Option<U> {
323: 321:         self.value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().as_mut().map(fun)
324: 322:     }
325: 323: 
326: 324:     /// Takes the current value, replacing it with `None`.
327: 325:     pub fn take_value(&self) -> Option<T> {
328: 326:         self.value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().take()
329: 327:     }
330: 328: }
331: 329: 
332: 330: impl<T> RenderEffect<T>
333: 331: where
334: 332:     T: Send + Sync + 'static,
335: 333: {
336: 334:     /// Creates a render effect that will run whether the `effects` feature is enabled or not.
337: 335:     pub fn new_isomorphic(
338: 336:         fun: impl FnMut(Option<T>) -> T + Send + Sync + 'static,
339: 337:     ) -> Self {
340: 338:         #[cfg(feature = "subsecond")]
341: 339:         let mut fun = subsecond::HotFn::current(fun);
342: 340:         #[cfg(feature = "subsecond")]
343: 341:         let fun = move |prev| fun.call((prev,));
344: 342: 
345: 343:         fn erased<T: Send + Sync + 'static>(
346: 344:             mut fun: Box<dyn FnMut(Option<T>) -> T + Send + Sync + 'static>,
347: 345:         ) -> RenderEffect<T> {
348: 346:             let (oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, mut rx) = channel();
349: 347:             let value = Arc::new(RwLock::new(None::<T>));
350: 348:             let owner = Owner::new();
351: 349:             let inner = Arc::new(RwLock::new(EffectInner {
352: 350:                 dirty: false,
353: 351:                 oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
354: 352:                 sources: SourceSet::new(),
355: 353:             }));
356: 354: 
357: 355:             let initial_value = owner
358: 356:                 .with(|| inner.to_any_subscriber().with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| fun(None)));
359: 357:             *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(initial_value);
360: 358: 
361: 359:             crate::spawn({
362: 360:                 let value = Arc::clone(&value);
363: 361:                 let subscriber = inner.to_any_subscriber();
364: 362: 
365: 363:                 async move {
366: 364:                     while rx.next().await.is_some() {
367: 365:                         if !owner.paused()
368: 366:                             && subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| {
369: 367:                                 subscriber.update_if_necessary()
370: 368:                             })
371: 369:                         {
372: 370:                             subscriber.clear_sources(&subscriber);
373: 371: 
374: 372:                             let old_value =
375: 373:                                 mem::take(&mut *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned());
376: 374:                             let new_value = owner.with_cleanup(|| {
377: 375:                                 subscriber.with_oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server(|| fun(old_value))
378: 376:                             });
379: 377:                             *value.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned() = Some(new_value);
380: 378:                         }
381: 379:                     }
382: 380:                 }
383: 381:             });
384: 382: 
385: 383:             RenderEffect { value, inner }
386: 384:         }
387: 385: 
388: 386:         erased(Box::new(fun))
389: 387:     }
390: 388: }
391: 389: 
392: 390: impl<T> ToAnySubscriber for RenderEffect<T> {
393: 391:     fn to_any_subscriber(&self) -> AnySubscriber {
394: 392:         AnySubscriber(
395: 393:             Arc::as_ptr(&self.inner) as usize,
396: 394:             Arc::downgrade(&self.inner) as Weak<dyn Subscriber + Send + Sync>,
397: 395:         )
398: 396:     }
399: 397: }
400: ```
```
