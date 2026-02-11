### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\callback.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\callback.rs
2: ```rust
3: 1: //! Callbacks define a standard way to store functions and closures. They are useful
4: 2: //! for component properties, because they can be used to define optional callback functions,
5: 3: //! which generic props don’t support.
6: 4: //!
7: 5: //! The callback types implement [`Copy`], so they can easily be moved into and out of other closures, just like signals.
8: 6: //!
9: 7: //! # Types
10: 8: //! This modules implements 2 callback types:
11: 9: //! - [`Callback`](lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::callback::Callback)
12: 10: //! - [`UnsyncCallback`](lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::callback::UnsyncCallback)
13: 11: //!
14: 12: //! Use `SyncCallback` if the function is not `Sync` and `Send`.
15: 13: 
16: 14: use crate::{
17: 15:     owner::{LocalStorage, StoredValue},
18: 16:     traits::{Dispose, WithValue},
19: 17:     IntoReactiveValue,
20: 18: };
21: 19: use std::{fmt, rc::Rc, sync::Arc};
22: 20: 
23: 21: /// A wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper trait for calling callbacks.
24: 22: pub trait Callable<In: 'static, Out: 'static = ()> {
25: 23:     /// calls the callback with the specified argument.
26: 24:     ///
27: 25:     /// Returns None if the callback has been disposed
28: 26:     fn try_run(&self, input: In) -> Option<Out>;
29: 27:     /// calls the callback with the specified argument.
30: 28:     ///
31: 29:     /// # Panics
32: 30:     /// Panics if you try to run a callback that has been disposed
33: 31:     fn run(&self, input: In) -> Out;
34: 32: }
35: 33: 
36: 34: /// A callback type that is not required to be [`Send`] or [`Sync`].
37: 35: ///
38: 36: /// # Example
39: 37: /// ```
40: 38: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::callback::*;  let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
41: 39: /// let _: UnsyncCallback<()> = UnsyncCallback::new(|_| {});
42: 40: /// let _: UnsyncCallback<(i32, i32)> = (|_x: i32, _y: i32| {}).into();
43: 41: /// let cb: UnsyncCallback<i32, String> = UnsyncCallback::new(|x: i32| x.to_string());
44: 42: /// assert_eq!(cb.run(42), "42".to_string());
45: 43: /// ```
46: 44: pub struct UnsyncCallback<In: 'static, Out: 'static = ()>(
47: 45:     StoredValue<Rc<dyn Fn(In) -> Out>, LocalStorage>,
48: 46: );
49: 47: 
50: 48: impl<In> fmt::Debug for UnsyncCallback<In> {
51: 49:     fn fmt(&self, fmt: &mut fmt::Formatter<'_>) -> Result<(), fmt::Error> {
52: 50:         fmt.write_str("Callback")
53: 51:     }
54: 52: }
55: 53: 
56: 54: impl<In, Out> Copy for UnsyncCallback<In, Out> {}
57: 55: 
58: 56: impl<In, Out> Clone for UnsyncCallback<In, Out> {
59: 57:     fn clone(&self) -> Self {
60: 58:         *self
61: 59:     }
62: 60: }
63: 61: 
64: 62: impl<In, Out> Dispose for UnsyncCallback<In, Out> {
65: 63:     fn dispose(self) {
66: 64:         self.0.dispose();
67: 65:     }
68: 66: }
69: 67: 
70: 68: impl<In, Out> UnsyncCallback<In, Out> {
71: 69:     /// Creates a new callback from the given function.
72: 70:     pub fn new<F>(f: F) -> UnsyncCallback<In, Out>
73: 71:     where
74: 72:         F: Fn(In) -> Out + 'static,
75: 73:     {
76: 74:         Self(StoredValue::new_local(Rc::new(f)))
77: 75:     }
78: 76: 
79: 77:     /// Returns `true` if both callbacks wrap the same underlying function pointer.
80: 78:     #[inline]
81: 79:     pub fn matches(&self, other: &Self) -> bool {
82: 80:         self.0.with_value(|self_value| {
83: 81:             other
84: 82:                 .0
85: 83:                 .with_value(|other_value| Rc::ptr_eq(self_value, other_value))
86: 84:         })
87: 85:     }
88: 86: }
89: 87: 
90: 88: impl<In: 'static, Out: 'static> Callable<In, Out> for UnsyncCallback<In, Out> {
91: 89:     fn try_run(&self, input: In) -> Option<Out> {
92: 90:         self.0.try_with_value(|fun| fun(input))
93: 91:     }
94: 92: 
95: 93:     fn run(&self, input: In) -> Out {
96: 94:         self.0.with_value(|fun| fun(input))
97: 95:     }
98: 96: }
99: 97: 
100: 98: macro_rules! impl_unsync_callable_from_fn {
101: 99:     ($($arg:ident),*) => {
102: 100:         impl<F, $($arg,)* T, Out> From<F> for UnsyncCallback<($($arg,)*), Out>
103: 101:         where
104: 102:             F: Fn($($arg),*) -> T + 'static,
105: 103:             T: Into<Out> + 'static,
106: 104:             $($arg: 'static,)*
107: 105:         {
108: 106:             fn from(f: F) -> Self {
109: 107:                 paste::paste!(
110: 108:                     Self::new(move |($([<$arg:lower>],)*)| f($([<$arg:lower>]),*).into())
111: 109:                 )
112: 110:             }
113: 111:         }
114: 112:     };
115: 113: }
116: 114: 
117: 115: impl_unsync_callable_from_fn!();
118: 116: impl_unsync_callable_from_fn!(P1);
119: 117: impl_unsync_callable_from_fn!(P1, P2);
120: 118: impl_unsync_callable_from_fn!(P1, P2, P3);
121: 119: impl_unsync_callable_from_fn!(P1, P2, P3, P4);
122: 120: impl_unsync_callable_from_fn!(P1, P2, P3, P4, P5);
123: 121: impl_unsync_callable_from_fn!(P1, P2, P3, P4, P5, P6);
124: 122: impl_unsync_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7);
125: 123: impl_unsync_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8);
126: 124: impl_unsync_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8, P9);
127: 125: impl_unsync_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8, P9, P10);
128: 126: impl_unsync_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11);
129: 127: impl_unsync_callable_from_fn!(
130: 128:     P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12
131: 129: );
132: 130: 
133: 131: /// A callback type that is [`Send`] + [`Sync`].
134: 132: ///
135: 133: /// # Example
136: 134: /// ```
137: 135: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::callback::*;  let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
138: 136: /// let _: Callback<()> = Callback::new(|_| {});
139: 137: /// let _: Callback<(i32, i32)> = (|_x: i32, _y: i32| {}).into();
140: 138: /// let cb: Callback<i32, String> = Callback::new(|x: i32| x.to_string());
141: 139: /// assert_eq!(cb.run(42), "42".to_string());
142: 140: /// ```
143: 141: pub struct Callback<In, Out = ()>(
144: 142:     StoredValue<Arc<dyn Fn(In) -> Out + Send + Sync>>,
145: 143: )
146: 144: where
147: 145:     In: 'static,
148: 146:     Out: 'static;
149: 147: 
150: 148: impl<In, Out> fmt::Debug for Callback<In, Out> {
151: 149:     fn fmt(&self, fmt: &mut fmt::Formatter<'_>) -> Result<(), fmt::Error> {
152: 150:         fmt.write_str("SyncCallback")
153: 151:     }
154: 152: }
155: 153: 
156: 154: impl<In, Out> Callable<In, Out> for Callback<In, Out> {
157: 155:     fn try_run(&self, input: In) -> Option<Out> {
158: 156:         self.0.try_with_value(|fun| fun(input))
159: 157:     }
160: 158: 
161: 159:     fn run(&self, input: In) -> Out {
162: 160:         self.0.with_value(|f| f(input))
163: 161:     }
164: 162: }
165: 163: 
166: 164: impl<In, Out> Clone for Callback<In, Out> {
167: 165:     fn clone(&self) -> Self {
168: 166:         *self
169: 167:     }
170: 168: }
171: 169: 
172: 170: impl<In, Out> Dispose for Callback<In, Out> {
173: 171:     fn dispose(self) {
174: 172:         self.0.dispose();
175: 173:     }
176: 174: }
177: 175: 
178: 176: impl<In, Out> Copy for Callback<In, Out> {}
179: 177: 
180: 178: macro_rules! impl_callable_from_fn {
181: 179:     ($($arg:ident),*) => {
182: 180:         impl<F, $($arg,)* T, Out> From<F> for Callback<($($arg,)*), Out>
183: 181:         where
184: 182:             F: Fn($($arg),*) -> T + Send + Sync + 'static,
185: 183:             T: Into<Out> + 'static,
186: 184:             $($arg: Send + Sync + 'static,)*
187: 185:         {
188: 186:             fn from(f: F) -> Self {
189: 187:                 paste::paste!(
190: 188:                     Self::new(move |($([<$arg:lower>],)*)| f($([<$arg:lower>]),*).into())
191: 189:                 )
192: 190:             }
193: 191:         }
194: 192:     };
195: 193: }
196: 194: 
197: 195: impl_callable_from_fn!();
198: 196: impl_callable_from_fn!(P1);
199: 197: impl_callable_from_fn!(P1, P2);
200: 198: impl_callable_from_fn!(P1, P2, P3);
201: 199: impl_callable_from_fn!(P1, P2, P3, P4);
202: 200: impl_callable_from_fn!(P1, P2, P3, P4, P5);
203: 201: impl_callable_from_fn!(P1, P2, P3, P4, P5, P6);
204: 202: impl_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7);
205: 203: impl_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8);
206: 204: impl_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8, P9);
207: 205: impl_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8, P9, P10);
208: 206: impl_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11);
209: 207: impl_callable_from_fn!(P1, P2, P3, P4, P5, P6, P7, P8, P9, P10, P11, P12);
210: 208: 
211: 209: impl<In: 'static, Out: 'static> Callback<In, Out> {
212: 210:     /// Creates a new callback from the given function.
213: 211:     #[track_caller]
214: 212:     pub fn new<F>(fun: F) -> Self
215: 213:     where
216: 214:         F: Fn(In) -> Out + Send + Sync + 'static,
217: 215:     {
218: 216:         Self(StoredValue::new(Arc::new(fun)))
219: 217:     }
220: 218: 
221: 219:     /// Returns `true` if both callbacks wrap the same underlying function pointer.
222: 220:     #[inline]
223: 221:     pub fn matches(&self, other: &Self) -> bool {
224: 222:         self.0
225: 223:             .try_with_value(|self_value| {
226: 224:                 other.0.try_with_value(|other_value| {
227: 225:                     Arc::ptr_eq(self_value, other_value)
228: 226:                 })
229: 227:             })
230: 228:             .flatten()
231: 229:             .unwrap_or(false)
232: 230:     }
233: 231: }
234: 232: 
235: 233: #[doc(hidden)]
236: 234: pub struct __IntoReactiveValueMarkerCallbackSingleParam;
237: 235: 
238: 236: #[doc(hidden)]
239: 237: pub struct __IntoReactiveValueMarkerCallbackStrOutputToString;
240: 238: 
241: 239: impl<I, O, F>
242: 240:     IntoReactiveValue<
243: 241:         Callback<I, O>,
244: 242:         __IntoReactiveValueMarkerCallbackSingleParam,
245: 243:     > for F
246: 244: where
247: 245:     F: Fn(I) -> O + Send + Sync + 'static,
248: 246: {
249: 247:     #[track_caller]
250: 248:     fn into_reactive_value(self) -> Callback<I, O> {
251: 249:         Callback::new(self)
252: 250:     }
253: 251: }
254: 252: 
255: 253: impl<I, O, F>
256: 254:     IntoReactiveValue<
257: 255:         UnsyncCallback<I, O>,
258: 256:         __IntoReactiveValueMarkerCallbackSingleParam,
259: 257:     > for F
260: 258: where
261: 259:     F: Fn(I) -> O + 'static,
262: 260: {
263: 261:     #[track_caller]
264: 262:     fn into_reactive_value(self) -> UnsyncCallback<I, O> {
265: 263:         UnsyncCallback::new(self)
266: 264:     }
267: 265: }
268: 266: 
269: 267: impl<I, F>
270: 268:     IntoReactiveValue<
271: 269:         Callback<I, String>,
272: 270:         __IntoReactiveValueMarkerCallbackStrOutputToString,
273: 271:     > for F
274: 272: where
275: 273:     F: Fn(I) -> &'static str + Send + Sync + 'static,
276: 274: {
277: 275:     #[track_caller]
278: 276:     fn into_reactive_value(self) -> Callback<I, String> {
279: 277:         Callback::new(move |i| self(i).to_string())
280: 278:     }
281: 279: }
282: 280: 
283: 281: impl<I, F>
284: 282:     IntoReactiveValue<
285: 283:         UnsyncCallback<I, String>,
286: 284:         __IntoReactiveValueMarkerCallbackStrOutputToString,
287: 285:     > for F
288: 286: where
289: 287:     F: Fn(I) -> &'static str + 'static,
290: 288: {
291: 289:     #[track_caller]
292: 290:     fn into_reactive_value(self) -> UnsyncCallback<I, String> {
293: 291:         UnsyncCallback::new(move |i| self(i).to_string())
294: 292:     }
295: 293: }
296: 294: 
297: 295: #[cfg(test)]
298: 296: mod tests {
299: 297:     use super::Callable;
300: 298:     use crate::{
301: 299:         callback::{Callback, UnsyncCallback},
302: 300:         owner::Owner,
303: 301:         traits::Dispose,
304: 302:         IntoReactiveValue,
305: 303:     };
306: 304: 
307: 305:     struct NoClone {}
308: 306: 
309: 307:     #[test]
310: 308:     fn clone_callback() {
311: 309:         let owner = Owner::new();
312: 310:         owner.set();
313: 311: 
314: 312:         let callback = Callback::new(move |_no_clone: NoClone| NoClone {});
315: 313:         let _cloned = callback;
316: 314:     }
317: 315: 
318: 316:     #[test]
319: 317:     fn clone_unsync_callback() {
320: 318:         let owner = Owner::new();
321: 319:         owner.set();
322: 320: 
323: 321:         let callback =
324: 322:             UnsyncCallback::new(move |_no_clone: NoClone| NoClone {});
325: 323:         let _cloned = callback;
326: 324:     }
327: 325: 
328: 326:     #[test]
329: 327:     fn runback_from() {
330: 328:         let owner = Owner::new();
331: 329:         owner.set();
332: 330: 
333: 331:         let _callback: Callback<(), String> = (|| "test").into();
334: 332:         let _callback: Callback<(i32, String), String> =
335: 333:             (|num, s| format!("{num} {s}")).into();
336: 334:         // Single params should work without needing the (foo,) tuple using IntoReactiveValue:
337: 335:         let _callback: Callback<usize, &'static str> =
338: 336:             (|_usize| "test").into_reactive_value();
339: 337:         let _callback: Callback<usize, String> =
340: 338:             (|_usize| "test").into_reactive_value();
341: 339:     }
342: 340: 
343: 341:     #[test]
344: 342:     fn sync_callback_from() {
345: 343:         let owner = Owner::new();
346: 344:         owner.set();
347: 345: 
348: 346:         let _callback: UnsyncCallback<(), String> = (|| "test").into();
349: 347:         let _callback: UnsyncCallback<(i32, String), String> =
350: 348:             (|num, s| format!("{num} {s}")).into();
351: 349:         // Single params should work without needing the (foo,) tuple using IntoReactiveValue:
352: 350:         let _callback: UnsyncCallback<usize, &'static str> =
353: 351:             (|_usize| "test").into_reactive_value();
354: 352:         let _callback: UnsyncCallback<usize, String> =
355: 353:             (|_usize| "test").into_reactive_value();
356: 354:     }
357: 355: 
358: 356:     #[test]
359: 357:     fn sync_callback_try_run() {
360: 358:         let owner = Owner::new();
361: 359:         owner.set();
362: 360: 
363: 361:         let callback = Callback::new(move |arg| arg);
364: 362:         assert_eq!(callback.try_run((0,)), Some((0,)));
365: 363:         callback.dispose();
366: 364:         assert_eq!(callback.try_run((0,)), None);
367: 365:     }
368: 366: 
369: 367:     #[test]
370: 368:     fn unsync_callback_try_run() {
371: 369:         let owner = Owner::new();
372: 370:         owner.set();
373: 371: 
374: 372:         let callback = UnsyncCallback::new(move |arg| arg);
375: 373:         assert_eq!(callback.try_run((0,)), Some((0,)));
376: 374:         callback.dispose();
377: 375:         assert_eq!(callback.try_run((0,)), None);
378: 376:     }
379: 377: 
380: 378:     #[test]
381: 379:     fn callback_matches_same() {
382: 380:         let owner = Owner::new();
383: 381:         owner.set();
384: 382: 
385: 383:         let callback1 = Callback::new(|x: i32| x * 2);
386: 384:         let callback2 = callback1;
387: 385:         assert!(callback1.matches(&callback2));
388: 386:     }
389: 387: 
390: 388:     #[test]
391: 389:     fn callback_matches_different() {
392: 390:         let owner = Owner::new();
393: 391:         owner.set();
394: 392: 
395: 393:         let callback1 = Callback::new(|x: i32| x * 2);
396: 394:         let callback2 = Callback::new(|x: i32| x + 1);
397: 395:         assert!(!callback1.matches(&callback2));
398: 396:     }
399: 397: 
400: 398:     #[test]
401: 399:     fn unsync_callback_matches_same() {
402: 400:         let owner = Owner::new();
403: 401:         owner.set();
404: 402: 
405: 403:         let callback1 = UnsyncCallback::new(|x: i32| x * 2);
406: 404:         let callback2 = callback1;
407: 405:         assert!(callback1.matches(&callback2));
408: 406:     }
409: 407: 
410: 408:     #[test]
411: 409:     fn unsync_callback_matches_different() {
412: 410:         let owner = Owner::new();
413: 411:         owner.set();
414: 412: 
415: 413:         let callback1 = UnsyncCallback::new(|x: i32| x * 2);
416: 414:         let callback2 = UnsyncCallback::new(|x: i32| x + 1);
417: 415:         assert!(!callback1.matches(&callback2));
418: 416:     }
419: 417: }
420: ```
```
