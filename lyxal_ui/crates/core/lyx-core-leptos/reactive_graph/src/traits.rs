### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\traits.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\traits.rs
2: ```rust
3: 1: //! A series of traits to implement the behavior of reactive primitive, especially signals.
4: 2: //!
5: 3: //! ## Principles
6: 4: //! 1. **Composition**: Most of the traits are implemented as combinations of more primitive base traits,
7: 5: //!    and blanket implemented for all types that implement those traits.
8: 6: //! 2. **Fallibility**: Most traits includes a `try_` variant, which returns `None` if the method
9: 7: //!    fails (e.g., if signals are arena allocated and this can't be found, or if an `RwLock` is
10: 8: //!    poisoned).
11: 9: //!
12: 10: //! ## Metadata Traits
13: 11: //! - [`DefinedAt`] is used for debugging in the case of errors and should be implemented for all
14: 12: //!   signal types.
15: 13: //! - [`IsDisposed`] checks whether a signal is currently accessible.
16: 14: //!
17: 15: //! ## Base Traits
18: 16: //! | Trait             | Mode  | Description                                                                           |
19: 17: //! |-------------------|-------|---------------------------------------------------------------------------------------|
20: 18: //! | [`Track`]         | —     | Tracks changes to this value, adding it as a source of the current reactive oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server. |
21: 19: //! | [`Notify`]       | —      | Notifies subscribers that this value has changed.                                     |
22: 20: //! | [`ReadUntracked`] | Guard | Gives immutable access to the value of this signal.                                   |
23: 21: //! | [`Write`]     | Guard | Gives mutable access to the value of this signal.
24: 22: //!
25: 23: //! ## Derived Traits
26: 24: //!
27: 25: //! ### Access
28: 26: //! | Trait             | Mode          | Composition                   | Description
29: 27: //! |-------------------|---------------|-------------------------------|------------
30: 28: //! | [`WithUntracked`] | `fn(&T) -> U` | [`ReadUntracked`]                  | Applies closure to the current value of the signal and returns result.
31: 29: //! | [`With`]          | `fn(&T) -> U` | [`ReadUntracked`] + [`Track`]      | Applies closure to the current value of the signal and returns result, with reactive tracking.
32: 30: //! | [`GetUntracked`]  | `T`           | [`WithUntracked`] + [`Clone`] | Clones the current value of the signal.
33: 31: //! | [`Get`]           | `T`           | [`GetUntracked`] + [`Track`]  | Clones the current value of the signal, with reactive tracking.
34: 32: //!
35: 33: //! ### Update
36: 34: //! | Trait               | Mode          | Composition                       | Description
37: 35: //! |---------------------|---------------|-----------------------------------|------------
38: 36: //! | [`UpdateUntracked`] | `fn(&mut T)`  | [`Write`]                     | Applies closure to the current value to update it, but doesn't notify subscribers.
39: 37: //! | [`Update`]          | `fn(&mut T)`  | [`UpdateUntracked`] + [`Notify`] | Applies closure to the current value to update it, and notifies subscribers.
40: 38: //! | [`Set`]             | `T`           | [`Update`]                        | Sets the value to a new value, and notifies subscribers.
41: 39: //!
42: 40: //! ## Using the Traits
43: 41: //!
44: 42: //! These traits are designed so that you can implement as few as possible, and the rest will be
45: 43: //! implemented automatically.
46: 44: //!
47: 45: //! For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, if you have a struct for which you can implement [`ReadUntracked`] and [`Track`], then
48: 46: //! [`WithUntracked`] and [`With`] will be implemented automatically (as will [`GetUntracked`] and
49: 47: //! [`Get`] for `Clone` types). But if you cannot implement [`ReadUntracked`] (because, for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example,
50: 48: //! there isn't an `RwLock` so you can't wrap in a [`ReadGuard`](crate::signal::guards::ReadGuard),
51: 49: //! but you can still implement [`WithUntracked`] and [`Track`], the same traits will still be implemented.
52: 50: 
53: 51: pub use crate::trait_options::*;
54: 52: use crate::{
55: 53:     effect::Effect,
56: 54:     graph::{Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server, Source, Subscriber, ToAnySource},
57: 55:     owner::Owner,
58: 56:     signal::{arc_signal, guards::UntrackedWriteGuard, ArcReadSignal},
59: 57: };
60: 58: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
61: 59: use futures::{Stream, StreamExt};
62: 60: use std::{
63: 61:     ops::{Deref, DerefMut},
64: 62:     panic::Location,
65: 63: };
66: 64: 
67: 65: #[doc(hidden)]
68: 66: /// Provides a sensible panic message for accessing disposed signals.
69: 67: #[macro_export]
70: 68: macro_rules! unwrap_signal {
71: 69:     ($signal:ident) => {{
72: 70:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
73: 71:         let location = std::panic::Location::caller();
74: 72:         || {
75: 73:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
76: 74:             {
77: 75:                 panic!(
78: 76:                     "{}",
79: 77:                     $crate::traits::panic_getting_disposed_signal(
80: 78:                         $signal.defined_at(),
81: 79:                         location
82: 80:                     )
83: 81:                 );
84: 82:             }
85: 83:             #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
86: 84:             {
87: 85:                 panic!(
88: 86:                     "Tried to access a reactive value that has already been \
89: 87:                      disposed."
90: 88:                 );
91: 89:             }
92: 90:         }
93: 91:     }};
94: 92: }
95: 93: 
96: 94: /// Allows disposing an arena-allocated signal before its owner has been disposed.
97: 95: pub trait Dispose {
98: 96:     /// Disposes of the signal. This:
99: 97:     /// 1. Detaches the signal from the reactive graph, preventing it from triggering
100: 98:     ///    further updates; and
101: 99:     /// 2. Drops the value contained in the signal.
102: 100:     fn dispose(self);
103: 101: }
104: 102: 
105: 103: /// Allows tracking the value of some reactive data.
106: 104: pub trait Track {
107: 105:     /// Subscribes to this signal in the current reactive scope without doing anything with its value.
108: 106:     #[track_caller]
109: 107:     fn track(&self);
110: 108: }
111: 109: 
112: 110: impl<T: Source + ToAnySource + DefinedAt> Track for T {
113: 111:     #[track_caller]
114: 112:     fn track(&self) {
115: 113:         if self.is_disposed() {
116: 114:             return;
117: 115:         }
118: 116: 
119: 117:         if let Some(subscriber) = Oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server::get() {
120: 118:             subscriber.add_source(self.to_any_source());
121: 119:             self.add_subscriber(subscriber);
122: 120:         } else {
123: 121:             #[cfg(all(debug_assertions, feature = "effects"))]
124: 122:             {
125: 123:                 use crate::diagnostics::SpecialNonReactiveZone;
126: 124: 
127: 125:                 if !SpecialNonReactiveZone::is_inside() {
128: 126:                     let called_at = Location::caller();
129: 127:                     let ty = std::any::type_name::<T>();
130: 128:                     let defined_at = self
131: 129:                         .defined_at()
132: 130:                         .map(ToString::to_string)
133: 131:                         .unwrap_or_else(|| String::from("{unknown}"));
134: 132:                     crate::log_warning(format_args!(
135: 133:                         "At {called_at}, you access a {ty} (defined at \
136: 134:                          {defined_at}) outside a reactive tracking context. \
137: 135:                          This might mean your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app is not responding to \
138: 136:                          changes in signal values in the way you \
139: 137:                          expect.\n\nHere’s how to fix it:\n\n1. If this is \
140: 138:                          inside a `view!` macro, make sure you are passing a \
141: 139:                          function, not a value.\n  ❌ NO  <p>{{x.get() * \
142: 140:                          2}}</p>\n  ✅ YES <p>{{move || x.get() * \
143: 141:                          2}}</p>\n\n2. If it’s in the body of a component, \
144: 142:                          try wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping this access in a closure: \n  ❌ NO  \
145: 143:                          let y = x.get() * 2\n  ✅ YES let y = move || \
146: 144:                          x.get() * 2.\n\n3. If you’re *trying* to access the \
147: 145:                          value without tracking, use `.get_untracked()` or \
148: 146:                          `.with_untracked()` instead."
149: 147:                     ));
150: 148:                 }
151: 149:             }
152: 150:         }
153: 151:     }
154: 152: }
155: 153: 
156: 154: /// Give read-only access to a signal's value by reference through a guard type,
157: 155: /// without tracking the value reactively.
158: 156: pub trait ReadUntracked: Sized + DefinedAt {
159: 157:     /// The guard type that will be returned, which can be dereferenced to the value.
160: 158:     type Value: Deref;
161: 159: 
162: 160:     /// Returns the guard, or `None` if the signal has already been disposed.
163: 161:     #[track_caller]
164: 162:     fn try_read_untracked(&self) -> Option<Self::Value>;
165: 163: 
166: 164:     /// Returns the guard.
167: 165:     ///
168: 166:     /// # Panics
169: 167:     /// Panics if you try to access a signal that has been disposed.
170: 168:     #[track_caller]
171: 169:     fn read_untracked(&self) -> Self::Value {
172: 170:         self.try_read_untracked()
173: 171:             .unwrap_or_else(unwrap_signal!(self))
174: 172:     }
175: 173: 
176: 174:     /// This is a backdoor to allow overriding the [`Read::try_read`] implementation despite it being auto implemented.
177: 175:     ///
178: 176:     /// If your type contains a [`Signal`](crate::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal),
179: 177:     /// call it's [`ReadUntracked::custom_try_read`] here, else return `None`.
180: 178:     #[track_caller]
181: 179:     fn custom_try_read(&self) -> Option<Option<Self::Value>> {
182: 180:         None
183: 181:     }
184: 182: }
185: 183: 
186: 184: /// Give read-only access to a signal's value by reference through a guard type,
187: 185: /// and subscribes the active reactive oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server (an effect or computed) to changes in its value.
188: 186: pub trait Read: DefinedAt {
189: 187:     /// The guard type that will be returned, which can be dereferenced to the value.
190: 188:     type Value: Deref;
191: 189: 
192: 190:     /// Subscribes to the signal, and returns the guard, or `None` if the signal has already been disposed.
193: 191:     #[track_caller]
194: 192:     fn try_read(&self) -> Option<Self::Value>;
195: 193: 
196: 194:     /// Subscribes to the signal, and returns the guard.
197: 195:     ///
198: 196:     /// # Panics
199: 197:     /// Panics if you try to access a signal that has been disposed.
200: 198:     #[track_caller]
201: 199:     fn read(&self) -> Self::Value {
202: 200:         self.try_read().unwrap_or_else(unwrap_signal!(self))
203: 201:     }
204: 202: }
205: 203: 
206: 204: impl<T> Read for T
207: 205: where
208: 206:     T: Track + ReadUntracked,
209: 207: {
210: 208:     type Value = T::Value;
211: 209: 
212: 210:     fn try_read(&self) -> Option<Self::Value> {
213: 211:         // The [`Read`] trait is auto implemented for types that implement [`ReadUntracked`] + [`Track`]. The [`Read`] trait then auto implements the [`With`] and [`Get`] traits too.
214: 212:         //
215: 213:         // This is a problem for e.g. the [`Signal`](crate::wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal) type,
216: 214:         // this type must use a custom [`Read::try_read`] implementation to avoid an unnecessary clone.
217: 215:         //
218: 216:         // This is a backdoor to allow overriding the [`Read::try_read`] implementation despite it being auto implemented.
219: 217:         if let Some(custom) = self.custom_try_read() {
220: 218:             custom
221: 219:         } else {
222: 220:             self.track();
223: 221:             self.try_read_untracked()
224: 222:         }
225: 223:     }
226: 224: }
227: 225: 
228: 226: /// A reactive, mutable guard that can be untracked to prevent it from notifying subscribers when
229: 227: /// it is dropped.
230: 228: pub trait UntrackableGuard: DerefMut {
231: 229:     /// Removes the notifier from the guard, such that it will no longer notify subscribers when it is dropped.
232: 230:     fn untrack(&mut self);
233: 231: }
234: 232: 
235: 233: impl<T> UntrackableGuard for Box<dyn UntrackableGuard<Target = T>> {
236: 234:     fn untrack(&mut self) {
237: 235:         (**self).untrack();
238: 236:     }
239: 237: }
240: 238: 
241: 239: /// Gives mutable access to a signal's value through a guard type. When the guard is dropped, the
242: 240: /// signal's subscribers will be notified.
243: 241: pub trait Write: Sized + DefinedAt + Notify {
244: 242:     /// The type of the signal's value.
245: 243:     type Value: Sized + 'static;
246: 244: 
247: 245:     /// Returns the guard, or `None` if the signal has already been disposed.
248: 246:     fn try_write(&self) -> Option<impl UntrackableGuard<Target = Self::Value>>;
249: 247: 
250: 248:     // Returns a guard that will not notify subscribers when dropped,
251: 249:     /// or `None` if the signal has already been disposed.
252: 250:     fn try_write_untracked(
253: 251:         &self,
254: 252:     ) -> Option<impl DerefMut<Target = Self::Value>>;
255: 253: 
256: 254:     /// Returns the guard.
257: 255:     ///
258: 256:     /// # Panics
259: 257:     /// Panics if you try to access a signal that has been disposed.
260: 258:     fn write(&self) -> impl UntrackableGuard<Target = Self::Value> {
261: 259:         self.try_write().unwrap_or_else(unwrap_signal!(self))
262: 260:     }
263: 261: 
264: 262:     /// Returns a guard that will not notify subscribers when dropped.
265: 263:     ///
266: 264:     /// # Panics
267: 265:     /// Panics if you try to access a signal that has been disposed.
268: 266:     fn write_untracked(&self) -> impl DerefMut<Target = Self::Value> {
269: 267:         self.try_write_untracked()
270: 268:             .unwrap_or_else(unwrap_signal!(self))
271: 269:     }
272: 270: }
273: 271: 
274: 272: /// Give read-only access to a signal's value by reference inside a closure,
275: 273: /// without tracking the value reactively.
276: 274: pub trait WithUntracked: DefinedAt {
277: 275:     /// The type of the value contained in the signal.
278: 276:     type Value: ?Sized;
279: 277: 
280: 278:     /// Applies the closure to the value, and returns the result,
281: 279:     /// or `None` if the signal has already been disposed.
282: 280:     #[track_caller]
283: 281:     fn try_with_untracked<U>(
284: 282:         &self,
285: 283:         fun: impl FnOnce(&Self::Value) -> U,
286: 284:     ) -> Option<U>;
287: 285: 
288: 286:     /// Applies the closure to the value, and returns the result.
289: 287:     ///
290: 288:     /// # Panics
291: 289:     /// Panics if you try to access a signal that has been disposed.
292: 290:     #[track_caller]
293: 291:     fn with_untracked<U>(&self, fun: impl FnOnce(&Self::Value) -> U) -> U {
294: 292:         self.try_with_untracked(fun)
295: 293:             .unwrap_or_else(unwrap_signal!(self))
296: 294:     }
297: 295: }
298: 296: 
299: 297: impl<T> WithUntracked for T
300: 298: where
301: 299:     T: DefinedAt + ReadUntracked,
302: 300: {
303: 301:     type Value = <<Self as ReadUntracked>::Value as Deref>::Target;
304: 302: 
305: 303:     fn try_with_untracked<U>(
306: 304:         &self,
307: 305:         fun: impl FnOnce(&Self::Value) -> U,
308: 306:     ) -> Option<U> {
309: 307:         self.try_read_untracked().map(|value| fun(&value))
310: 308:     }
311: 309: }
312: 310: 
313: 311: /// Give read-only access to a signal's value by reference inside a closure,
314: 312: /// and subscribes the active reactive oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server (an effect or computed) to changes in its value.
315: 313: pub trait With: DefinedAt {
316: 314:     /// The type of the value contained in the signal.
317: 315:     type Value: ?Sized;
318: 316: 
319: 317:     /// Subscribes to the signal, lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies the closure to the value, and returns the result,
320: 318:     /// or `None` if the signal has already been disposed.
321: 319:     #[track_caller]
322: 320:     fn try_with<U>(&self, fun: impl FnOnce(&Self::Value) -> U) -> Option<U>;
323: 321: 
324: 322:     /// Subscribes to the signal, lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies the closure to the value, and returns the result.
325: 323:     ///
326: 324:     /// # Panics
327: 325:     /// Panics if you try to access a signal that has been disposed.
328: 326:     #[track_caller]
329: 327:     fn with<U>(&self, fun: impl FnOnce(&Self::Value) -> U) -> U {
330: 328:         self.try_with(fun).unwrap_or_else(unwrap_signal!(self))
331: 329:     }
332: 330: }
333: 331: 
334: 332: impl<T> With for T
335: 333: where
336: 334:     T: Read,
337: 335: {
338: 336:     type Value = <<T as Read>::Value as Deref>::Target;
339: 337: 
340: 338:     #[track_caller]
341: 339:     fn try_with<U>(&self, fun: impl FnOnce(&Self::Value) -> U) -> Option<U> {
342: 340:         self.try_read().map(|val| fun(&val))
343: 341:     }
344: 342: }
345: 343: 
346: 344: /// Clones the value of the signal, without tracking the value reactively.
347: 345: pub trait GetUntracked: DefinedAt {
348: 346:     /// The type of the value contained in the signal.
349: 347:     type Value;
350: 348: 
351: 349:     /// Clones and returns the value of the signal,
352: 350:     /// or `None` if the signal has already been disposed.
353: 351:     #[track_caller]
354: 352:     fn try_get_untracked(&self) -> Option<Self::Value>;
355: 353: 
356: 354:     /// Clones and returns the value of the signal,
357: 355:     ///
358: 356:     /// # Panics
359: 357:     /// Panics if you try to access a signal that has been disposed.
360: 358:     #[track_caller]
361: 359:     fn get_untracked(&self) -> Self::Value {
362: 360:         self.try_get_untracked()
363: 361:             .unwrap_or_else(unwrap_signal!(self))
364: 362:     }
365: 363: }
366: 364: 
367: 365: impl<T> GetUntracked for T
368: 366: where
369: 367:     T: WithUntracked,
370: 368:     T::Value: Clone,
371: 369: {
372: 370:     type Value = <Self as WithUntracked>::Value;
373: 371: 
374: 372:     fn try_get_untracked(&self) -> Option<Self::Value> {
375: 373:         self.try_with_untracked(Self::Value::clone)
376: 374:     }
377: 375: }
378: 376: 
379: 377: /// Clones the value of the signal, without tracking the value reactively.
380: 378: /// and subscribes the active reactive oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server (an effect or computed) to changes in its value.
381: 379: pub trait Get: DefinedAt {
382: 380:     /// The type of the value contained in the signal.
383: 381:     type Value: Clone;
384: 382: 
385: 383:     /// Subscribes to the signal, then clones and returns the value of the signal,
386: 384:     /// or `None` if the signal has already been disposed.
387: 385:     #[track_caller]
388: 386:     fn try_get(&self) -> Option<Self::Value>;
389: 387: 
390: 388:     /// Subscribes to the signal, then clones and returns the value of the signal.
391: 389:     ///
392: 390:     /// # Panics
393: 391:     /// Panics if you try to access a signal that has been disposed.
394: 392:     #[track_caller]
395: 393:     fn get(&self) -> Self::Value {
396: 394:         self.try_get().unwrap_or_else(unwrap_signal!(self))
397: 395:     }
398: 396: }
399: 397: 
400: 398: impl<T> Get for T
401: 399: where
402: 400:     T: With,
403: 401:     T::Value: Clone,
404: 402: {
405: 403:     type Value = <T as With>::Value;
406: 404: 
407: 405:     #[track_caller]
408: 406:     fn try_get(&self) -> Option<Self::Value> {
409: 407:         self.try_with(Self::Value::clone)
410: 408:     }
411: 409: }
412: 410: 
413: 411: /// Notifies subscribers of a change in this signal.
414: 412: pub trait Notify {
415: 413:     /// Notifies subscribers of a change in this signal.
416: 414:     #[track_caller]
417: 415:     fn notify(&self);
418: 416: }
419: 417: 
420: 418: /// Updates the value of a signal by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a function that updates it in place,
421: 419: /// without notifying subscribers.
422: 420: pub trait UpdateUntracked: DefinedAt {
423: 421:     /// The type of the value contained in the signal.
424: 422:     type Value;
425: 423: 
426: 424:     /// Updates the value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a function, returning the value returned by that function.
427: 425:     /// Does not notify subscribers that the signal has changed.
428: 426:     ///
429: 427:     /// # Panics
430: 428:     /// Panics if you try to update a signal that has been disposed.
431: 429:     #[track_caller]
432: 430:     fn update_untracked<U>(
433: 431:         &self,
434: 432:         fun: impl FnOnce(&mut Self::Value) -> U,
435: 433:     ) -> U {
436: 434:         self.try_update_untracked(fun)
437: 435:             .unwrap_or_else(unwrap_signal!(self))
438: 436:     }
439: 437: 
440: 438:     /// Updates the value by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a function, returning the value returned by that function,
441: 439:     /// or `None` if the signal has already been disposed.
442: 440:     /// Does not notify subscribers that the signal has changed.
443: 441:     fn try_update_untracked<U>(
444: 442:         &self,
445: 443:         fun: impl FnOnce(&mut Self::Value) -> U,
446: 444:     ) -> Option<U>;
447: 445: }
448: 446: 
449: 447: impl<T> UpdateUntracked for T
450: 448: where
451: 449:     T: Write,
452: 450: {
453: 451:     type Value = <Self as Write>::Value;
454: 452: 
455: 453:     #[track_caller]
456: 454:     fn try_update_untracked<U>(
457: 455:         &self,
458: 456:         fun: impl FnOnce(&mut Self::Value) -> U,
459: 457:     ) -> Option<U> {
460: 458:         let mut guard = self.try_write_untracked()?;
461: 459:         Some(fun(&mut *guard))
462: 460:     }
463: 461: }
464: 462: 
465: 463: /// Updates the value of a signal by lyx-platform-lyx_platform_lyx-platform-lyx_platform_applying a function that updates it in place,
466: 464: /// notifying its subscribers that the value has changed.
467: 465: pub trait Update {
468: 466:     /// The type of the value contained in the signal.
469: 467:     type Value;
470: 468: 
471: 469:     /// Updates the value of the signal and notifies subscribers.
472: 470:     #[track_caller]
473: 471:     fn update(&self, fun: impl FnOnce(&mut Self::Value)) {
474: 472:         self.try_update(fun);
475: 473:     }
476: 474: 
477: 475:     /// Updates the value of the signal, but only notifies subscribers if the function
478: 476:     /// returns `true`.
479: 477:     #[track_caller]
480: 478:     fn maybe_update(&self, fun: impl FnOnce(&mut Self::Value) -> bool) {
481: 479:         self.try_maybe_update(|val| {
482: 480:             let did_update = fun(val);
483: 481:             (did_update, ())
484: 482:         });
485: 483:     }
486: 484: 
487: 485:     /// Updates the value of the signal and notifies subscribers, returning the value that is
488: 486:     /// returned by the update function, or `None` if the signal has already been disposed.
489: 487:     #[track_caller]
490: 488:     fn try_update<U>(
491: 489:         &self,
492: 490:         fun: impl FnOnce(&mut Self::Value) -> U,
493: 491:     ) -> Option<U> {
494: 492:         self.try_maybe_update(|val| (true, fun(val)))
495: 493:     }
496: 494: 
497: 495:     /// Updates the value of the signal, notifying subscribers if the update function returns
498: 496:     /// `(true, _)`, and returns the value returned by the update function,
499: 497:     /// or `None` if the signal has already been disposed.
500: 498:     fn try_maybe_update<U>(
501: 499:         &self,
502: 500:         fun: impl FnOnce(&mut Self::Value) -> (bool, U),
503: 501:     ) -> Option<U>;
504: 502: }
505: 503: 
506: 504: impl<T> Update for T
507: 505: where
508: 506:     T: Write,
509: 507: {
510: 508:     type Value = <Self as Write>::Value;
511: 509: 
512: 510:     #[track_caller]
513: 511:     fn try_maybe_update<U>(
514: 512:         &self,
515: 513:         fun: impl FnOnce(&mut Self::Value) -> (bool, U),
516: 514:     ) -> Option<U> {
517: 515:         let mut lock = self.try_write()?;
518: 516:         let (did_update, val) = fun(&mut *lock);
519: 517:         if !did_update {
520: 518:             lock.untrack();
521: 519:         }
522: 520:         drop(lock);
523: 521:         Some(val)
524: 522:     }
525: 523: }
526: 524: 
527: 525: /// Updates the value of the signal by replacing it.
528: 526: pub trait Set {
529: 527:     /// The type of the value contained in the signal.
530: 528:     type Value;
531: 529: 
532: 530:     /// Updates the value by replacing it, and notifies subscribers that it has changed.
533: 531:     fn set(&self, value: Self::Value);
534: 532: 
535: 533:     /// Updates the value by replacing it, and notifies subscribers that it has changed.
536: 534:     ///
537: 535:     /// If the signal has already been disposed, returns `Some(value)` with the value that was
538: 536:     /// passed in. Otherwise, returns `None`.
539: 537:     fn try_set(&self, value: Self::Value) -> Option<Self::Value>;
540: 538: }
541: 539: 
542: 540: impl<T> Set for T
543: 541: where
544: 542:     T: Update + IsDisposed,
545: 543: {
546: 544:     type Value = <Self as Update>::Value;
547: 545: 
548: 546:     #[track_caller]
549: 547:     fn set(&self, value: Self::Value) {
550: 548:         self.try_update(|n| *n = value);
551: 549:     }
552: 550: 
553: 551:     #[track_caller]
554: 552:     fn try_set(&self, value: Self::Value) -> Option<Self::Value> {
555: 553:         if self.is_disposed() {
556: 554:             Some(value)
557: 555:         } else {
558: 556:             self.set(value);
559: 557:             None
560: 558:         }
561: 559:     }
562: 560: }
563: 561: 
564: 562: /// Allows converting a signal into an async [`Stream`].
565: 563: pub trait ToStream<T> {
566: 564:     /// Generates a [`Stream`] that emits the new value of the signal
567: 565:     /// whenever it changes.
568: 566:     ///
569: 567:     /// # Panics
570: 568:     /// Panics if you try to access a signal that is owned by a reactive node that has been disposed.
571: 569:     #[track_caller]
572: 570:     fn to_stream(&self) -> impl Stream<Item = T> + Send;
573: 571: }
574: 572: 
575: 573: impl<S> ToStream<S::Value> for S
576: 574: where
577: 575:     S: Clone + Get + Send + Sync + 'static,
578: 576:     S::Value: Send + 'static,
579: 577: {
580: 578:     fn to_stream(&self) -> impl Stream<Item = S::Value> + Send {
581: 579:         let (tx, rx) = futures::channel::mpsc::unbounded();
582: 580: 
583: 581:         let close_channel = tx.clone();
584: 582: 
585: 583:         Owner::on_cleanup(move || close_channel.close_channel());
586: 584: 
587: 585:         Effect::new_isomorphic({
588: 586:             let this = self.clone();
589: 587:             move |_| {
590: 588:                 let _ = tx.unbounded_send(this.get());
591: 589:             }
592: 590:         });
593: 591: 
594: 592:         rx
595: 593:     }
596: 594: }
597: 595: 
598: 596: /// Allows creating a signal from an async [`Stream`].
599: 597: pub trait FromStream<T> {
600: 598:     /// Creates a signal that contains the latest value of the stream.
601: 599:     #[track_caller]
602: 600:     fn from_stream(stream: impl Stream<Item = T> + Send + 'static) -> Self;
603: 601: 
604: 602:     /// Creates a signal that contains the latest value of the stream.
605: 603:     #[track_caller]
606: 604:     fn from_stream_unsync(stream: impl Stream<Item = T> + 'static) -> Self;
607: 605: }
608: 606: 
609: 607: impl<S, T> FromStream<T> for S
610: 608: where
611: 609:     S: From<ArcReadSignal<Option<T>>> + Send + Sync,
612: 610:     T: Send + Sync + 'static,
613: 611: {
614: 612:     fn from_stream(stream: impl Stream<Item = T> + Send + 'static) -> Self {
615: 613:         let (read, write) = arc_signal(None);
616: 614:         let mut stream = Box::pin(stream);
617: 615:         crate::spawn(async move {
618: 616:             while let Some(value) = stream.next().await {
619: 617:                 write.set(Some(value));
620: 618:             }
621: 619:         });
622: 620:         read.into()
623: 621:     }
624: 622: 
625: 623:     fn from_stream_unsync(stream: impl Stream<Item = T> + 'static) -> Self {
626: 624:         let (read, write) = arc_signal(None);
627: 625:         let mut stream = Box::pin(stream);
628: 626:         Executor::spawn_local(async move {
629: 627:             while let Some(value) = stream.next().await {
630: 628:                 write.set(Some(value));
631: 629:             }
632: 630:         });
633: 631:         read.into()
634: 632:     }
635: 633: }
636: 634: 
637: 635: /// Checks whether a signal has already been disposed.
638: 636: pub trait IsDisposed {
639: 637:     /// If `true`, the signal cannot be accessed without a panic.
640: 638:     fn is_disposed(&self) -> bool;
641: 639: }
642: 640: 
643: 641: /// Turns a signal back into a raw value.
644: 642: pub trait IntoInner {
645: 643:     /// The type of the value contained in the signal.
646: 644:     type Value;
647: 645: 
648: 646:     /// Returns the inner value if this is the only reference to the signal.
649: 647:     /// Otherwise, returns `None` and drops this reference.
650: 648:     /// # Panics
651: 649:     /// Panics if the inner lock is poisoned.
652: 650:     fn into_inner(self) -> Option<Self::Value>;
653: 651: }
654: 652: 
655: 653: /// Describes where the signal was defined. This is used for diagnostic warnings and is purely a
656: 654: /// debug-mode tool.
657: 655: pub trait DefinedAt {
658: 656:     /// Returns the location at which the signal was defined. This is usually simply `None` in
659: 657:     /// release mode.
660: 658:     fn defined_at(&self) -> Option<&'static Location<'static>>;
661: 659: }
662: 660: 
663: 661: #[doc(hidden)]
664: 662: pub fn panic_getting_disposed_signal(
665: 663:     defined_at: Option<&'static Location<'static>>,
666: 664:     location: &'static Location<'static>,
667: 665: ) -> String {
668: 666:     if let Some(defined_at) = defined_at {
669: 667:         format!(
670: 668:             "At {location}, you tried to access a reactive value which was \
671: 669:              defined at {defined_at}, but it has already been disposed."
672: 670:         )
673: 671:     } else {
674: 672:         format!(
675: 673:             "At {location}, you tried to access a reactive value, but it has \
676: 674:              already been disposed."
677: 675:         )
678: 676:     }
679: 677: }
680: 678: 
681: 679: /// A variation of the [`Read`] trait that provides a signposted "always-non-reactive" API.
682: 680: /// E.g. for [`StoredValue`](`crate::owner::StoredValue`).
683: 681: pub trait ReadValue: Sized + DefinedAt {
684: 682:     /// The guard type that will be returned, which can be dereferenced to the value.
685: 683:     type Value: Deref;
686: 684: 
687: 685:     /// Returns the non-reactive guard, or `None` if the value has already been disposed.
688: 686:     #[track_caller]
689: 687:     fn try_read_value(&self) -> Option<Self::Value>;
690: 688: 
691: 689:     /// Returns the non-reactive guard.
692: 690:     ///
693: 691:     /// # Panics
694: 692:     /// Panics if you try to access a value that has been disposed.
695: 693:     #[track_caller]
696: 694:     fn read_value(&self) -> Self::Value {
697: 695:         self.try_read_value().unwrap_or_else(unwrap_signal!(self))
698: 696:     }
699: 697: }
700: 698: 
701: 699: /// A variation of the [`With`] trait that provides a signposted "always-non-reactive" API.
702: 700: /// E.g. for [`StoredValue`](`crate::owner::StoredValue`).
703: 701: pub trait WithValue: DefinedAt {
704: 702:     /// The type of the value contained in the value.
705: 703:     type Value: ?Sized;
706: 704: 
707: 705:     /// Applies the closure to the value, non-reactively, and returns the result,
708: 706:     /// or `None` if the value has already been disposed.
709: 707:     #[track_caller]
710: 708:     fn try_with_value<U>(
711: 709:         &self,
712: 710:         fun: impl FnOnce(&Self::Value) -> U,
713: 711:     ) -> Option<U>;
714: 712: 
715: 713:     /// Applies the closure to the value, non-reactively, and returns the result.
716: 714:     ///
717: 715:     /// # Panics
718: 716:     /// Panics if you try to access a value that has been disposed.
719: 717:     #[track_caller]
720: 718:     fn with_value<U>(&self, fun: impl FnOnce(&Self::Value) -> U) -> U {
721: 719:         self.try_with_value(fun)
722: 720:             .unwrap_or_else(unwrap_signal!(self))
723: 721:     }
724: 722: }
725: 723: 
726: 724: impl<T> WithValue for T
727: 725: where
728: 726:     T: DefinedAt + ReadValue,
729: 727: {
730: 728:     type Value = <<Self as ReadValue>::Value as Deref>::Target;
731: 729: 
732: 730:     fn try_with_value<U>(
733: 731:         &self,
734: 732:         fun: impl FnOnce(&Self::Value) -> U,
735: 733:     ) -> Option<U> {
736: 734:         self.try_read_value().map(|value| fun(&value))
737: 735:     }
738: 736: }
739: 737: 
740: 738: /// A variation of the [`Get`] trait that provides a signposted "always-non-reactive" API.
741: 739: /// E.g. for [`StoredValue`](`crate::owner::StoredValue`).
742: 740: pub trait GetValue: DefinedAt {
743: 741:     /// The type of the value contained in the value.
744: 742:     type Value: Clone;
745: 743: 
746: 744:     /// Clones and returns the value of the value, non-reactively,
747: 745:     /// or `None` if the value has already been disposed.
748: 746:     #[track_caller]
749: 747:     fn try_get_value(&self) -> Option<Self::Value>;
750: 748: 
751: 749:     /// Clones and returns the value of the value, non-reactively.
752: 750:     ///
753: 751:     /// # Panics
754: 752:     /// Panics if you try to access a value that has been disposed.
755: 753:     #[track_caller]
756: 754:     fn get_value(&self) -> Self::Value {
757: 755:         self.try_get_value().unwrap_or_else(unwrap_signal!(self))
758: 756:     }
759: 757: }
760: 758: 
761: 759: impl<T> GetValue for T
762: 760: where
763: 761:     T: WithValue,
764: 762:     T::Value: Clone,
765: 763: {
766: 764:     type Value = <Self as WithValue>::Value;
767: 765: 
768: 766:     fn try_get_value(&self) -> Option<Self::Value> {
769: 767:         self.try_with_value(Self::Value::clone)
770: 768:     }
771: 769: }
772: 770: 
773: 771: /// A variation of the [`Write`] trait that provides a signposted "always-non-reactive" API.
774: 772: /// E.g. for [`StoredValue`](`crate::owner::StoredValue`).
775: 773: pub trait WriteValue: Sized + DefinedAt {
776: 774:     /// The type of the value's value.
777: 775:     type Value: Sized + 'static;
778: 776: 
779: 777:     /// Returns a non-reactive write guard, or `None` if the value has already been disposed.
780: 778:     #[track_caller]
781: 779:     fn try_write_value(&self) -> Option<UntrackedWriteGuard<Self::Value>>;
782: 780: 
783: 781:     /// Returns a non-reactive write guard.
784: 782:     ///
785: 783:     /// # Panics
786: 784:     /// Panics if you try to access a value that has been disposed.
787: 785:     #[track_caller]
788: 786:     fn write_value(&self) -> UntrackedWriteGuard<Self::Value> {
789: 787:         self.try_write_value().unwrap_or_else(unwrap_signal!(self))
790: 788:     }
791: 789: }
792: 790: 
793: 791: /// A variation of the [`Update`] trait that provides a signposted "always-non-reactive" API.
794: 792: /// E.g. for [`StoredValue`](`crate::owner::StoredValue`).
795: 793: pub trait UpdateValue: DefinedAt {
796: 794:     /// The type of the value contained in the value.
797: 795:     type Value;
798: 796: 
799: 797:     /// Updates the value, returning the value that is
800: 798:     /// returned by the update function, or `None` if the value has already been disposed.
801: 799:     #[track_caller]
802: 800:     fn try_update_value<U>(
803: 801:         &self,
804: 802:         fun: impl FnOnce(&mut Self::Value) -> U,
805: 803:     ) -> Option<U>;
806: 804: 
807: 805:     /// Updates the value.
808: 806:     #[track_caller]
809: 807:     fn update_value(&self, fun: impl FnOnce(&mut Self::Value)) {
810: 808:         self.try_update_value(fun);
811: 809:     }
812: 810: }
813: 811: 
814: 812: impl<T> UpdateValue for T
815: 813: where
816: 814:     T: WriteValue,
817: 815: {
818: 816:     type Value = <Self as WriteValue>::Value;
819: 817: 
820: 818:     #[track_caller]
821: 819:     fn try_update_value<U>(
822: 820:         &self,
823: 821:         fun: impl FnOnce(&mut Self::Value) -> U,
824: 822:     ) -> Option<U> {
825: 823:         let mut guard = self.try_write_value()?;
826: 824:         Some(fun(&mut *guard))
827: 825:     }
828: 826: }
829: 827: 
830: 828: /// A variation of the [`Set`] trait that provides a signposted "always-non-reactive" API.
831: 829: /// E.g. for [`StoredValue`](`crate::owner::StoredValue`).
832: 830: pub trait SetValue: DefinedAt {
833: 831:     /// The type of the value contained in the value.
834: 832:     type Value;
835: 833: 
836: 834:     /// Updates the value by replacing it, non-reactively.
837: 835:     ///
838: 836:     /// If the value has already been disposed, returns `Some(value)` with the value that was
839: 837:     /// passed in. Otherwise, returns `None`.
840: 838:     #[track_caller]
841: 839:     fn try_set_value(&self, value: Self::Value) -> Option<Self::Value>;
842: 840: 
843: 841:     /// Updates the value by replacing it, non-reactively.
844: 842:     #[track_caller]
845: 843:     fn set_value(&self, value: Self::Value) {
846: 844:         self.try_set_value(value);
847: 845:     }
848: 846: }
849: 847: 
850: 848: impl<T> SetValue for T
851: 849: where
852: 850:     T: WriteValue,
853: 851: {
854: 852:     type Value = <Self as WriteValue>::Value;
855: 853: 
856: 854:     fn try_set_value(&self, value: Self::Value) -> Option<Self::Value> {
857: 855:         // Unlike most other traits, for these None actually means success:
858: 856:         if let Some(mut guard) = self.try_write_value() {
859: 857:             *guard = value;
860: 858:             None
861: 859:         } else {
862: 860:             Some(value)
863: 861:         }
864: 862:     }
865: 863: }
866: ```
```
