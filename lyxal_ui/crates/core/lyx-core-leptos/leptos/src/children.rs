### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\children.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\children.rs
2: ```rust
3: 1: use crate::into_view::{IntoView, View};
4: 2: use std::{
5: 3:     fmt::{self, Debug},
6: 4:     sync::Arc,
7: 5: };
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::view::{
9: 7:     any_view::{AnyView, IntoAny},
10: 8:     fragment::{Fragment, IntoFragment},
11: 9:     RenderHtml,
12: 10: };
13: 11: 
14: 12: /// The most common type for the `children` property on components,
15: 13: /// which can only be called once.
16: 14: ///
17: 15: /// This does not support iterating over individual nodes within the children.
18: 16: /// To iterate over children, use [`ChildrenFragment`].
19: 17: pub type Children = Box<dyn FnOnce() -> AnyView + Send>;
20: 18: 
21: 19: /// A type for the `children` property on components that can be called only once,
22: 20: /// and provides a collection of all the children passed to this component.
23: 21: pub type ChildrenFragment = Box<dyn FnOnce() -> Fragment + Send>;
24: 22: 
25: 23: /// A type for the `children` property on components that can be called
26: 24: /// more than once.
27: 25: pub type ChildrenFn = Arc<dyn Fn() -> AnyView + Send + Sync>;
28: 26: 
29: 27: /// A type for the `children` property on components that can be called more than once,
30: 28: /// and provides a collection of all the children passed to this component.
31: 29: pub type ChildrenFragmentFn = Arc<dyn Fn() -> Fragment + Send>;
32: 30: 
33: 31: /// A type for the `children` property on components that can be called
34: 32: /// more than once, but may mutate the children.
35: 33: pub type ChildrenFnMut = Box<dyn FnMut() -> AnyView + Send>;
36: 34: 
37: 35: /// A type for the `children` property on components that can be called more than once,
38: 36: /// but may mutate the children, and provides a collection of all the children
39: 37: /// passed to this component.
40: 38: pub type ChildrenFragmentMut = Box<dyn FnMut() -> Fragment + Send>;
41: 39: 
42: 40: // This is to still support components that accept `Box<dyn Fn() -> AnyView>` as a children.
43: 41: type BoxedChildrenFn = Box<dyn Fn() -> AnyView + Send>;
44: 42: 
45: 43: /// This trait can be used when constructing a component that takes children without needing
46: 44: /// to know exactly what children type the component expects. This is used internally by the
47: 45: /// `view!` macro implementation, and can also be used explicitly when using the builder syntax.
48: 46: ///
49: 47: ///
50: 48: /// Different component types take different types for their `children` prop, some of which cannot
51: 49: /// be directly constructed. Using `ToChildren` allows the component user to pass children without
52: 50: /// explicitly constructing the correct type.
53: 51: ///
54: 52: /// ## Examples
55: 53: ///
56: 54: /// ```
57: 55: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
58: 56: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::html::p;
59: 57: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView;
60: 58: /// # use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::component;
61: 59: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::children::ToChildren;
62: 60: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::context::{Provider, ProviderProps};
63: 61: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::control_flow::{Show, ShowProps};
64: 62: ///
65: 63: /// #[component]
66: 64: /// fn App() -> impl IntoView {
67: 65: ///     (
68: 66: ///       Provider(
69: 67: ///         ProviderProps::builder()
70: 68: ///             .children(ToChildren::to_children(|| {
71: 69: ///                 p().child("Foo")
72: 70: ///             }))
73: 71: ///             // ...
74: 72: ///            .value("Foo")
75: 73: ///            .build(),
76: 74: ///        ),
77: 75: ///        Show(
78: 76: ///          ShowProps::builder()
79: 77: ///             .children(ToChildren::to_children(|| {
80: 78: ///                 p().child("Foo")
81: 79: ///             }))
82: 80: ///             // ...
83: 81: ///             .when(|| true)
84: 82: ///             .fallback(|| p().child("foo"))
85: 83: ///             .build(),
86: 84: ///        )
87: 85: ///     )
88: 86: /// }
89: 87: pub trait ToChildren<F> {
90: 88:     /// Convert the provided type (generally a closure) to Self (generally a "children" type,
91: 89:     /// e.g., [Children]). See the implementations to see exactly which input types are supported
92: 90:     /// and which "children" type they are converted to.
93: 91:     fn to_children(f: F) -> Self;
94: 92: }
95: 93: 
96: 94: /// Compiler optimisation, can be used with certain type to avoid unique closures in the view!{} macro.
97: 95: pub struct ChildrenOptContainer<T>(pub T);
98: 96: 
99: 97: impl<F, C> ToChildren<F> for Children
100: 98: where
101: 99:     F: FnOnce() -> C + Send + 'static,
102: 100:     C: RenderHtml + Send + 'static,
103: 101: {
104: 102:     #[inline]
105: 103:     fn to_children(f: F) -> Self {
106: 104:         Box::new(move || f().into_any())
107: 105:     }
108: 106: }
109: 107: 
110: 108: impl<T> ToChildren<ChildrenOptContainer<T>> for Children
111: 109: where
112: 110:     T: IntoAny + Send + 'static,
113: 111: {
114: 112:     #[inline]
115: 113:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
116: 114:         Box::new(move || t.0.into_any())
117: 115:     }
118: 116: }
119: 117: 
120: 118: impl<F, C> ToChildren<F> for ChildrenFn
121: 119: where
122: 120:     F: Fn() -> C + Send + Sync + 'static,
123: 121:     C: RenderHtml + Send + 'static,
124: 122: {
125: 123:     #[inline]
126: 124:     fn to_children(f: F) -> Self {
127: 125:         Arc::new(move || f().into_any())
128: 126:     }
129: 127: }
130: 128: 
131: 129: impl<T> ToChildren<ChildrenOptContainer<T>> for ChildrenFn
132: 130: where
133: 131:     T: IntoAny + Clone + Send + Sync + 'static,
134: 132: {
135: 133:     #[inline]
136: 134:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
137: 135:         Arc::new(move || t.0.clone().into_any())
138: 136:     }
139: 137: }
140: 138: 
141: 139: impl<F, C> ToChildren<F> for ChildrenFnMut
142: 140: where
143: 141:     F: Fn() -> C + Send + 'static,
144: 142:     C: RenderHtml + Send + 'static,
145: 143: {
146: 144:     #[inline]
147: 145:     fn to_children(f: F) -> Self {
148: 146:         Box::new(move || f().into_any())
149: 147:     }
150: 148: }
151: 149: 
152: 150: impl<T> ToChildren<ChildrenOptContainer<T>> for ChildrenFnMut
153: 151: where
154: 152:     T: IntoAny + Clone + Send + 'static,
155: 153: {
156: 154:     #[inline]
157: 155:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
158: 156:         Box::new(move || t.0.clone().into_any())
159: 157:     }
160: 158: }
161: 159: 
162: 160: impl<F, C> ToChildren<F> for BoxedChildrenFn
163: 161: where
164: 162:     F: Fn() -> C + Send + 'static,
165: 163:     C: RenderHtml + Send + 'static,
166: 164: {
167: 165:     #[inline]
168: 166:     fn to_children(f: F) -> Self {
169: 167:         Box::new(move || f().into_any())
170: 168:     }
171: 169: }
172: 170: 
173: 171: impl<T> ToChildren<ChildrenOptContainer<T>> for BoxedChildrenFn
174: 172: where
175: 173:     T: IntoAny + Clone + Send + 'static,
176: 174: {
177: 175:     #[inline]
178: 176:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
179: 177:         Box::new(move || t.0.clone().into_any())
180: 178:     }
181: 179: }
182: 180: 
183: 181: impl<F, C> ToChildren<F> for ChildrenFragment
184: 182: where
185: 183:     F: FnOnce() -> C + Send + 'static,
186: 184:     C: IntoFragment,
187: 185: {
188: 186:     #[inline]
189: 187:     fn to_children(f: F) -> Self {
190: 188:         Box::new(move || f().into_fragment())
191: 189:     }
192: 190: }
193: 191: 
194: 192: impl<T> ToChildren<ChildrenOptContainer<T>> for ChildrenFragment
195: 193: where
196: 194:     T: IntoAny + Send + 'static,
197: 195: {
198: 196:     #[inline]
199: 197:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
200: 198:         Box::new(move || Fragment::new(vec![t.0.into_any()]))
201: 199:     }
202: 200: }
203: 201: 
204: 202: impl<F, C> ToChildren<F> for ChildrenFragmentFn
205: 203: where
206: 204:     F: Fn() -> C + Send + 'static,
207: 205:     C: IntoFragment,
208: 206: {
209: 207:     #[inline]
210: 208:     fn to_children(f: F) -> Self {
211: 209:         Arc::new(move || f().into_fragment())
212: 210:     }
213: 211: }
214: 212: 
215: 213: impl<T> ToChildren<ChildrenOptContainer<T>> for ChildrenFragmentFn
216: 214: where
217: 215:     T: IntoAny + Clone + Send + 'static,
218: 216: {
219: 217:     #[inline]
220: 218:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
221: 219:         Arc::new(move || Fragment::new(vec![t.0.clone().into_any()]))
222: 220:     }
223: 221: }
224: 222: 
225: 223: impl<F, C> ToChildren<F> for ChildrenFragmentMut
226: 224: where
227: 225:     F: FnMut() -> C + Send + 'static,
228: 226:     C: IntoFragment,
229: 227: {
230: 228:     #[inline]
231: 229:     fn to_children(mut f: F) -> Self {
232: 230:         Box::new(move || f().into_fragment())
233: 231:     }
234: 232: }
235: 233: 
236: 234: impl<T> ToChildren<ChildrenOptContainer<T>> for ChildrenFragmentMut
237: 235: where
238: 236:     T: IntoAny + Clone + Send + 'static,
239: 237: {
240: 238:     #[inline]
241: 239:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
242: 240:         Box::new(move || Fragment::new(vec![t.0.clone().into_any()]))
243: 241:     }
244: 242: }
245: 243: 
246: 244: /// New-type wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for a function that returns a view with `From` and `Default` traits implemented
247: 245: /// to enable optional props in for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example `<Show>` and `<Suspense>`.
248: 246: #[derive(Clone)]
249: 247: pub struct ViewFn(Arc<dyn Fn() -> AnyView + Send + Sync + 'static>);
250: 248: 
251: 249: impl Default for ViewFn {
252: 250:     fn default() -> Self {
253: 251:         Self(Arc::new(|| ().into_any()))
254: 252:     }
255: 253: }
256: 254: 
257: 255: impl<F, C> From<F> for ViewFn
258: 256: where
259: 257:     F: Fn() -> C + Send + Sync + 'static,
260: 258:     C: RenderHtml + Send + 'static,
261: 259: {
262: 260:     fn from(value: F) -> Self {
263: 261:         Self(Arc::new(move || value().into_any()))
264: 262:     }
265: 263: }
266: 264: 
267: 265: impl<C> From<View<C>> for ViewFn
268: 266: where
269: 267:     C: Clone + Send + Sync + 'static,
270: 268:     View<C>: IntoAny,
271: 269: {
272: 270:     fn from(value: View<C>) -> Self {
273: 271:         Self(Arc::new(move || value.clone().into_any()))
274: 272:     }
275: 273: }
276: 274: 
277: 275: impl ViewFn {
278: 276:     /// Execute the wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped function
279: 277:     pub fn run(&self) -> AnyView {
280: 278:         (self.0)()
281: 279:     }
282: 280: }
283: 281: 
284: 282: /// New-type wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for a function, which will only be called once and returns a view with `From` and
285: 283: /// `Default` traits implemented to enable optional props in for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example `<Show>` and `<Suspense>`.
286: 284: pub struct ViewFnOnce(Box<dyn FnOnce() -> AnyView + Send + 'static>);
287: 285: 
288: 286: impl Default for ViewFnOnce {
289: 287:     fn default() -> Self {
290: 288:         Self(Box::new(|| ().into_any()))
291: 289:     }
292: 290: }
293: 291: 
294: 292: impl<F, C> From<F> for ViewFnOnce
295: 293: where
296: 294:     F: FnOnce() -> C + Send + 'static,
297: 295:     C: RenderHtml + Send + 'static,
298: 296: {
299: 297:     fn from(value: F) -> Self {
300: 298:         Self(Box::new(move || value().into_any()))
301: 299:     }
302: 300: }
303: 301: 
304: 302: impl<C> From<View<C>> for ViewFnOnce
305: 303: where
306: 304:     C: Send + Sync + 'static,
307: 305:     View<C>: IntoAny,
308: 306: {
309: 307:     fn from(value: View<C>) -> Self {
310: 308:         Self(Box::new(move || value.into_any()))
311: 309:     }
312: 310: }
313: 311: 
314: 312: impl ViewFnOnce {
315: 313:     /// Execute the wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped function
316: 314:     pub fn run(self) -> AnyView {
317: 315:         (self.0)()
318: 316:     }
319: 317: }
320: 318: 
321: 319: /// A typed equivalent to [`Children`], which takes a generic but preserves type information to
322: 320: /// allow the compiler to optimize the view more effectively.
323: 321: pub struct TypedChildren<T>(Box<dyn FnOnce() -> View<T> + Send>);
324: 322: 
325: 323: impl<T> TypedChildren<T> {
326: 324:     /// Extracts the inner `children` function.
327: 325:     pub fn into_inner(self) -> impl FnOnce() -> View<T> + Send {
328: 326:         self.0
329: 327:     }
330: 328: }
331: 329: 
332: 330: impl<F, C> ToChildren<F> for TypedChildren<C>
333: 331: where
334: 332:     F: FnOnce() -> C + Send + 'static,
335: 333:     C: IntoView,
336: 334:     C::AsyncOutput: Send,
337: 335: {
338: 336:     #[inline]
339: 337:     fn to_children(f: F) -> Self {
340: 338:         TypedChildren(Box::new(move || f().into_view()))
341: 339:     }
342: 340: }
343: 341: 
344: 342: impl<T> ToChildren<ChildrenOptContainer<T>> for TypedChildren<T>
345: 343: where
346: 344:     T: IntoView + 'static,
347: 345: {
348: 346:     #[inline]
349: 347:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
350: 348:         TypedChildren(Box::new(move || t.0.into_view()))
351: 349:     }
352: 350: }
353: 351: 
354: 352: /// A typed equivalent to [`ChildrenFnMut`], which takes a generic but preserves type information to
355: 353: /// allow the compiler to optimize the view more effectively.
356: 354: pub struct TypedChildrenMut<T>(Box<dyn FnMut() -> View<T> + Send>);
357: 355: 
358: 356: impl<T> Debug for TypedChildrenMut<T> {
359: 357:     fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
360: 358:         f.debug_tuple("TypedChildrenMut").finish()
361: 359:     }
362: 360: }
363: 361: 
364: 362: impl<T> TypedChildrenMut<T> {
365: 363:     /// Extracts the inner `children` function.
366: 364:     pub fn into_inner(self) -> impl FnMut() -> View<T> + Send {
367: 365:         self.0
368: 366:     }
369: 367: }
370: 368: 
371: 369: impl<F, C> ToChildren<F> for TypedChildrenMut<C>
372: 370: where
373: 371:     F: FnMut() -> C + Send + 'static,
374: 372:     C: IntoView,
375: 373:     C::AsyncOutput: Send,
376: 374: {
377: 375:     #[inline]
378: 376:     fn to_children(mut f: F) -> Self {
379: 377:         TypedChildrenMut(Box::new(move || f().into_view()))
380: 378:     }
381: 379: }
382: 380: 
383: 381: impl<T> ToChildren<ChildrenOptContainer<T>> for TypedChildrenMut<T>
384: 382: where
385: 383:     T: IntoView + Clone + 'static,
386: 384: {
387: 385:     #[inline]
388: 386:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
389: 387:         TypedChildrenMut(Box::new(move || t.0.clone().into_view()))
390: 388:     }
391: 389: }
392: 390: 
393: 391: /// A typed equivalent to [`ChildrenFn`], which takes a generic but preserves type information to
394: 392: /// allow the compiler to optimize the view more effectively.
395: 393: pub struct TypedChildrenFn<T>(Arc<dyn Fn() -> View<T> + Send + Sync>);
396: 394: 
397: 395: impl<T> Debug for TypedChildrenFn<T> {
398: 396:     fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
399: 397:         f.debug_tuple("TypedChildrenFn").finish()
400: 398:     }
401: 399: }
402: 400: 
403: 401: impl<T> Clone for TypedChildrenFn<T> {
404: 402:     // Manual implementation to avoid the `T: Clone` bound.
405: 403:     fn clone(&self) -> Self {
406: 404:         Self(self.0.clone())
407: 405:     }
408: 406: }
409: 407: 
410: 408: impl<T> TypedChildrenFn<T> {
411: 409:     /// Extracts the inner `children` function.
412: 410:     pub fn into_inner(self) -> Arc<dyn Fn() -> View<T> + Send + Sync> {
413: 411:         self.0
414: 412:     }
415: 413: }
416: 414: 
417: 415: impl<F, C> ToChildren<F> for TypedChildrenFn<C>
418: 416: where
419: 417:     F: Fn() -> C + Send + Sync + 'static,
420: 418:     C: IntoView,
421: 419:     C::AsyncOutput: Send,
422: 420: {
423: 421:     #[inline]
424: 422:     fn to_children(f: F) -> Self {
425: 423:         TypedChildrenFn(Arc::new(move || f().into_view()))
426: 424:     }
427: 425: }
428: 426: 
429: 427: impl<T> ToChildren<ChildrenOptContainer<T>> for TypedChildrenFn<T>
430: 428: where
431: 429:     T: IntoView + Clone + Sync + 'static,
432: 430: {
433: 431:     #[inline]
434: 432:     fn to_children(t: ChildrenOptContainer<T>) -> Self {
435: 433:         TypedChildrenFn(Arc::new(move || t.0.clone().into_view()))
436: 434:     }
437: 435: }
438: ```
```
