### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\owner\context.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\owner\context.rs
2: ```rust
3: 1: use crate::owner::Owner;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
5: 3: use std::{
6: 4:     any::{Any, TypeId},
7: 5:     collections::VecDeque,
8: 6: };
9: 7: 
10: 8: impl Owner {
11: 9:     fn provide_context<T: Send + Sync + 'static>(&self, value: T) {
12: 10:         self.inner
13: 11:             .write()
14: 12:             .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
15: 13:             .contexts
16: 14:             .insert(value.type_id(), Box::new(value));
17: 15:     }
18: 16: 
19: 17:     fn use_context<T: Clone + 'static>(&self) -> Option<T> {
20: 18:         self.with_context(Clone::clone)
21: 19:     }
22: 20: 
23: 21:     fn take_context<T: 'static>(&self) -> Option<T> {
24: 22:         let ty = TypeId::of::<T>();
25: 23:         let mut inner = self.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
26: 24:         let contexts = &mut inner.contexts;
27: 25:         if let Some(context) = contexts.remove(&ty) {
28: 26:             context.downcast::<T>().ok().map(|n| *n)
29: 27:         } else {
30: 28:             let mut parent = inner.parent.as_ref().and_then(|p| p.upgrade());
31: 29:             while let Some(ref this_parent) = parent.clone() {
32: 30:                 let mut this_parent = this_parent.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
33: 31:                 let contexts = &mut this_parent.contexts;
34: 32:                 let value = contexts.remove(&ty);
35: 33:                 let downcast =
36: 34:                     value.and_then(|context| context.downcast::<T>().ok());
37: 35:                 if let Some(value) = downcast {
38: 36:                     return Some(*value);
39: 37:                 } else {
40: 38:                     parent =
41: 39:                         this_parent.parent.as_ref().and_then(|p| p.upgrade());
42: 40:                 }
43: 41:             }
44: 42:             None
45: 43:         }
46: 44:     }
47: 45: 
48: 46:     fn with_context<T: 'static, R>(
49: 47:         &self,
50: 48:         cb: impl FnOnce(&T) -> R,
51: 49:     ) -> Option<R> {
52: 50:         let ty = TypeId::of::<T>();
53: 51:         let inner = self.inner.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
54: 52:         let contexts = &inner.contexts;
55: 53:         let reference = if let Some(context) = contexts.get(&ty) {
56: 54:             context.downcast_ref::<T>()
57: 55:         } else {
58: 56:             let mut parent = inner.parent.as_ref().and_then(|p| p.upgrade());
59: 57:             while let Some(ref this_parent) = parent.clone() {
60: 58:                 let this_parent = this_parent.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
61: 59:                 let contexts = &this_parent.contexts;
62: 60:                 let value = contexts.get(&ty);
63: 61:                 let downcast =
64: 62:                     value.and_then(|context| context.downcast_ref::<T>());
65: 63:                 if let Some(value) = downcast {
66: 64:                     return Some(cb(value));
67: 65:                 } else {
68: 66:                     parent =
69: 67:                         this_parent.parent.as_ref().and_then(|p| p.upgrade());
70: 68:                 }
71: 69:             }
72: 70: 
73: 71:             None
74: 72:         };
75: 73:         reference.map(cb)
76: 74:     }
77: 75: 
78: 76:     fn update_context<T: 'static, R>(
79: 77:         &self,
80: 78:         cb: impl FnOnce(&mut T) -> R,
81: 79:     ) -> Option<R> {
82: 80:         let ty = TypeId::of::<T>();
83: 81:         let mut inner = self.inner.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
84: 82:         let contexts = &mut inner.contexts;
85: 83:         let reference = if let Some(context) = contexts.get_mut(&ty) {
86: 84:             context.downcast_mut::<T>()
87: 85:         } else {
88: 86:             let mut parent = inner.parent.as_ref().and_then(|p| p.upgrade());
89: 87:             while let Some(ref this_parent) = parent.clone() {
90: 88:                 let mut this_parent = this_parent.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
91: 89:                 let contexts = &mut this_parent.contexts;
92: 90:                 let value = contexts.get_mut(&ty);
93: 91:                 let downcast =
94: 92:                     value.and_then(|context| context.downcast_mut::<T>());
95: 93:                 if let Some(value) = downcast {
96: 94:                     return Some(cb(value));
97: 95:                 } else {
98: 96:                     parent =
99: 97:                         this_parent.parent.as_ref().and_then(|p| p.upgrade());
100: 98:                 }
101: 99:             }
102: 100:             None
103: 101:         };
104: 102:         reference.map(cb)
105: 103:     }
106: 104: 
107: 105:     /// Searches for items stored in context in either direction, either among parents or among
108: 106:     /// descendants.
109: 107:     pub fn use_context_bidirectional<T: Clone + 'static>(&self) -> Option<T> {
110: 108:         self.use_context()
111: 109:             .unwrap_or_else(|| self.find_context_in_children())
112: 110:     }
113: 111: 
114: 112:     fn find_context_in_children<T: Clone + 'static>(&self) -> Option<T> {
115: 113:         let ty = TypeId::of::<T>();
116: 114:         let inner = self.inner.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
117: 115:         let mut to_search = VecDeque::new();
118: 116:         to_search.extend(inner.children.clone());
119: 117:         drop(inner);
120: 118: 
121: 119:         while let Some(next) = to_search.pop_front() {
122: 120:             if let Some(child) = next.upgrade() {
123: 121:                 let child = child.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
124: 122:                 let contexts = &child.contexts;
125: 123:                 if let Some(context) = contexts.get(&ty) {
126: 124:                     return context.downcast_ref::<T>().cloned();
127: 125:                 }
128: 126: 
129: 127:                 to_search.extend(child.children.clone());
130: 128:             }
131: 129:         }
132: 130: 
133: 131:         None
134: 132:     }
135: 133: }
136: 134: 
137: 135: /// Provides a context value of type `T` to the current reactive [`Owner`]
138: 136: /// and all of its descendants. This can be accessed using [`use_context`].
139: 137: ///
140: 138: /// This is useful for passing values down to components or functions lower in a
141: 139: /// hierarchy without needs to “prop drill” by passing them through each layer as
142: 140: /// arguments to a function or properties of a component.
143: 141: ///
144: 142: /// Context works similarly to variable scope: a context that is provided higher in
145: 143: /// the reactive graph can be used lower down, but a context that is provided lower
146: 144: /// down cannot be used higher up.
147: 145: ///
148: 146: /// ```rust
149: 147: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
150: 148: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::*;
151: 149: /// # let owner = Owner::new(); owner.set();
152: 150: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
153: 151: /// # futures::executor::block_on(async move {
154: 152: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
155: 153: /// Effect::new(move |_| {
156: 154: ///     println!("Provider");
157: 155: ///     provide_context(42i32); // provide an i32
158: 156: ///
159: 157: ///     Effect::new(move |_| {
160: 158: ///         println!("intermediate node");
161: 159: ///
162: 160: ///         Effect::new(move |_| {
163: 161: ///             let value = use_context::<i32>()
164: 162: ///                 .expect("could not find i32 in context");
165: 163: ///             assert_eq!(value, 42);
166: 164: ///         });
167: 165: ///     });
168: 166: /// });
169: 167: /// # });
170: 168: /// ```
171: 169: ///
172: 170: /// ## Context Shadowing
173: 171: ///
174: 172: /// Only a single value of any type can be provided via context. If you need to provide multiple
175: 173: /// values of the same type, wrap each one in a "newtype" struct wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper so that each one is a
176: 174: /// distinct type.
177: 175: ///
178: 176: /// Providing a second value of the same type "lower" in the ownership tree will shadow the value,
179: 177: /// just as a second `let` declaration with the same variable name will shadow that variable.
180: 178: ///
181: 179: /// ```rust
182: 180: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
183: 181: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::*;
184: 182: /// # let owner = Owner::new(); owner.set();
185: 183: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
186: 184: /// # futures::executor::block_on(async move {
187: 185: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
188: 186: /// Effect::new(move |_| {
189: 187: ///     println!("Provider");
190: 188: ///     provide_context("foo"); // provide a &'static str
191: 189: ///
192: 190: ///     Effect::new(move |_| {
193: 191: ///         // before we provide another value of the same type, we can access the old one
194: 192: ///         assert_eq!(use_context::<&'static str>(), Some("foo"));
195: 193: ///         // but providing another value of the same type shadows it
196: 194: ///         provide_context("bar");
197: 195: ///
198: 196: ///         Effect::new(move |_| {
199: 197: ///             assert_eq!(use_context::<&'static str>(), Some("bar"));
200: 198: ///         });
201: 199: ///     });
202: 200: /// });
203: 201: /// # });
204: 202: /// ```
205: 203: pub fn provide_context<T: Send + Sync + 'static>(value: T) {
206: 204:     if let Some(owner) = Owner::current() {
207: 205:         owner.provide_context(value);
208: 206:     }
209: 207: }
210: 208: 
211: 209: /// Extracts a context value of type `T` from the reactive system.
212: 210: ///
213: 211: /// This traverses the reactive ownership graph, beginning from the current reactive
214: 212: /// [`Owner`] and iterating through its parents, if any. When the value is found, it is cloned.
215: 213: ///
216: 214: /// The context value should have been provided elsewhere using
217: 215: /// [`provide_context`](provide_context).
218: 216: ///
219: 217: /// This is useful for passing values down to components or functions lower in a
220: 218: /// hierarchy without needs to “prop drill” by passing them through each layer as
221: 219: /// arguments to a function or properties of a component.
222: 220: ///
223: 221: /// Context works similarly to variable scope: a context that is provided higher in
224: 222: /// the reactive graph can be used lower down, but a context that is provided lower
225: 223: /// in the tree cannot be used higher up.
226: 224: ///
227: 225: /// While the term “consume” is sometimes used, note that [`use_context`] clones the value, rather
228: 226: /// than removing it; it is still accessible to other users.
229: 227: ///
230: 228: /// ```rust
231: 229: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
232: 230: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::*;
233: 231: /// # let owner = Owner::new(); owner.set();
234: 232: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
235: 233: /// # futures::executor::block_on(async move {
236: 234: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
237: 235: /// Effect::new(move |_| {
238: 236: ///     provide_context(String::from("foo"));
239: 237: ///
240: 238: ///     Effect::new(move |_| {
241: 239: ///         // each use_context clones the value
242: 240: ///         let value = use_context::<String>()
243: 241: ///             .expect("could not find String in context");
244: 242: ///         assert_eq!(value, "foo");
245: 243: ///         let value2 = use_context::<String>()
246: 244: ///             .expect("could not find String in context");
247: 245: ///         assert_eq!(value2, "foo");
248: 246: ///     });
249: 247: /// });
250: 248: /// # });
251: 249: /// ```
252: 250: pub fn use_context<T: Clone + 'static>() -> Option<T> {
253: 251:     Owner::current().and_then(|owner| owner.use_context())
254: 252: }
255: 253: 
256: 254: /// Extracts a context value of type `T` from the reactive system, and
257: 255: /// panics if it can't be found.
258: 256: ///
259: 257: /// This traverses the reactive ownership graph, beginning from the current reactive
260: 258: /// [`Owner`] and iterating through its parents, if any. When the value is found, it is cloned.
261: 259: ///
262: 260: /// Panics if no value is found.
263: 261: ///
264: 262: /// The context value should have been provided elsewhere using
265: 263: /// [`provide_context`](provide_context).
266: 264: ///
267: 265: /// This is useful for passing values down to components or functions lower in a
268: 266: /// hierarchy without needs to “prop drill” by passing them through each layer as
269: 267: /// arguments to a function or properties of a component.
270: 268: ///
271: 269: /// Context works similarly to variable scope: a context that is provided higher in
272: 270: /// the reactive graph can be used lower down, but a context that is provided lower
273: 271: /// in the tree cannot be used higher up.
274: 272: ///
275: 273: /// While the term “consume” is sometimes used, note that [`use_context`] clones the value, rather
276: 274: /// than removing it; it is still accessible to other users.
277: 275: ///
278: 276: /// ```rust
279: 277: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
280: 278: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::*;
281: 279: /// # let owner = Owner::new(); owner.set();
282: 280: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
283: 281: /// # futures::executor::block_on(async move {
284: 282: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
285: 283: /// Effect::new(move |_| {
286: 284: ///     provide_context(String::from("foo"));
287: 285: ///
288: 286: ///     Effect::new(move |_| {
289: 287: ///         // each use_context clones the value
290: 288: ///         let value = use_context::<String>()
291: 289: ///             .expect("could not find String in context");
292: 290: ///         assert_eq!(value, "foo");
293: 291: ///         let value2 = use_context::<String>()
294: 292: ///             .expect("could not find String in context");
295: 293: ///         assert_eq!(value2, "foo");
296: 294: ///     });
297: 295: /// });
298: 296: /// # });
299: 297: /// ```
300: 298: /// ## Panics
301: 299: /// Panics if a context of this type is not found in the current reactive
302: 300: /// owner or its ancestors.
303: 301: #[track_caller]
304: 302: pub fn expect_context<T: Clone + 'static>() -> T {
305: 303:     let location = std::panic::Location::caller();
306: 304: 
307: 305:     use_context().unwrap_or_else(|| {
308: 306:         panic!(
309: 307:             "{:?} expected context of type {:?} to be present",
310: 308:             location,
311: 309:             std::any::type_name::<T>()
312: 310:         )
313: 311:     })
314: 312: }
315: 313: 
316: 314: /// Extracts a context value of type `T` from the reactive system, and takes ownership,
317: 315: /// removing it from the context system.
318: 316: ///
319: 317: /// This traverses the reactive ownership graph, beginning from the current reactive
320: 318: /// [`Owner`] and iterating through its parents, if any. When the value is found, it is removed,
321: 319: /// and is not available to any other [`use_context`] or [`take_context`] calls.
322: 320: ///
323: 321: /// If the value is `Clone`, use [`use_context`] instead.
324: 322: ///
325: 323: /// The context value should have been provided elsewhere using
326: 324: /// [`provide_context`](provide_context).
327: 325: ///
328: 326: /// This is useful for passing values down to components or functions lower in a
329: 327: /// hierarchy without needs to “prop drill” by passing them through each layer as
330: 328: /// arguments to a function or properties of a component.
331: 329: ///
332: 330: /// Context works similarly to variable scope: a context that is provided higher in
333: 331: /// the reactive graph can be used lower down, but a context that is provided lower
334: 332: /// in the tree cannot be used higher up.
335: 333: /// ```rust
336: 334: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
337: 335: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::*;
338: 336: /// # let owner = Owner::new(); owner.set();
339: 337: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
340: 338: /// # futures::executor::block_on(async move {
341: 339: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
342: 340: ///
343: 341: /// #[derive(Debug, PartialEq)]
344: 342: /// struct NotClone(String);
345: 343: ///
346: 344: /// Effect::new(move |_| {
347: 345: ///     provide_context(NotClone(String::from("foo")));
348: 346: ///
349: 347: ///     Effect::new(move |_| {
350: 348: ///         // take_context removes the value from context without needing to clone
351: 349: ///         let value = take_context::<NotClone>();
352: 350: ///         assert_eq!(value, Some(NotClone(String::from("foo"))));
353: 351: ///         let value2 = take_context::<NotClone>();
354: 352: ///         assert_eq!(value2, None);
355: 353: ///     });
356: 354: /// });
357: 355: /// # });
358: 356: /// ```
359: 357: pub fn take_context<T: 'static>() -> Option<T> {
360: 358:     Owner::current().and_then(|owner| owner.take_context())
361: 359: }
362: 360: 
363: 361: /// Access a reference to a context value of type `T` in the reactive system.
364: 362: ///
365: 363: /// This traverses the reactive ownership graph, beginning from the current reactive
366: 364: /// [`Owner`] and iterating through its parents, if any. When the value is found,
367: 365: /// the function that you pass is lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to an immutable reference to it.
368: 366: ///
369: 367: /// The context value should have been provided elsewhere using
370: 368: /// [`provide_context`](provide_context).
371: 369: ///
372: 370: /// This is useful for passing values down to components or functions lower in a
373: 371: /// hierarchy without needs to “prop drill” by passing them through each layer as
374: 372: /// arguments to a function or properties of a component.
375: 373: ///
376: 374: /// Context works similarly to variable scope: a context that is provided higher in
377: 375: /// the reactive graph can be used lower down, but a context that is provided lower
378: 376: /// in the tree cannot be used higher up.
379: 377: ///
380: 378: /// ```rust
381: 379: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
382: 380: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::*;
383: 381: /// # let owner = Owner::new(); owner.set();
384: 382: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
385: 383: /// # futures::executor::block_on(async move {
386: 384: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
387: 385: /// Effect::new(move |_| {
388: 386: ///     provide_context(String::from("foo"));
389: 387: ///
390: 388: ///     Effect::new(move |_| {
391: 389: ///         let value = with_context::<String, _>(|val| val.to_string())
392: 390: ///             .expect("could not find String in context");
393: 391: ///         assert_eq!(value, "foo");
394: 392: ///     });
395: 393: /// });
396: 394: /// # });
397: 395: /// ```
398: 396: pub fn with_context<T: 'static, R>(cb: impl FnOnce(&T) -> R) -> Option<R> {
399: 397:     Owner::current().and_then(|owner| owner.with_context(cb))
400: 398: }
401: 399: 
402: 400: /// Update a context value of type `T` in the reactive system.
403: 401: ///
404: 402: /// This traverses the reactive ownership graph, beginning from the current reactive
405: 403: /// [`Owner`] and iterating through its parents, if any. When the value is found,
406: 404: /// the function that you pass is lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to a mutable reference to it.
407: 405: ///
408: 406: /// The context value should have been provided elsewhere using
409: 407: /// [`provide_context`](provide_context).
410: 408: ///
411: 409: /// This is useful for passing values down to components or functions lower in a
412: 410: /// hierarchy without needs to “prop drill” by passing them through each layer as
413: 411: /// arguments to a function or properties of a component.
414: 412: ///
415: 413: /// Context works similarly to variable scope: a context that is provided higher in
416: 414: /// the reactive graph can be used lower down, but a context that is provided lower
417: 415: /// in the tree cannot be used higher up.
418: 416: ///
419: 417: /// ```rust
420: 418: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
421: 419: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::*;
422: 420: /// # let owner = Owner::new(); owner.set();
423: 421: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
424: 422: /// # futures::executor::block_on(async move {
425: 423: /// # lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_futures_executor();
426: 424: /// Effect::new(move |_| {
427: 425: ///     provide_context(String::from("foo"));
428: 426: ///
429: 427: ///     Effect::new(move |_| {
430: 428: ///         let value = update_context::<String, _>(|val| {
431: 429: ///             std::mem::replace(val, "bar".to_string())
432: 430: ///         })
433: 431: ///         .expect("could not find String in context");
434: 432: ///         assert_eq!(value, "foo");
435: 433: ///         assert_eq!(expect_context::<String>(), "bar");
436: 434: ///     });
437: 435: /// });
438: 436: /// # });
439: 437: /// ```
440: 438: pub fn update_context<T: 'static, R>(
441: 439:     cb: impl FnOnce(&mut T) -> R,
442: 440: ) -> Option<R> {
443: 441:     Owner::current().and_then(|owner| owner.update_context(cb))
444: 442: }
445: ```
```
