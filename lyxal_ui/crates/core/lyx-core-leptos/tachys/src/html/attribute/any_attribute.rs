### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\any_attribute.rs
18: 16: ```rust
19: 17: use super::{Attribute, NextAttribute};
20: 18: use crate::{
21: 19:     erased::{Erased, ErasedLocal},
22: 20:     html::attribute::NamedAttributeKey,
23: 21:     renderer::{dom::Element, Rndr},
24: 22: };
25: 23: use std::{any::TypeId, fmt::Debug, mem};
26: 24: #[cfg(feature = "ssr")]
27: 25: use std::{future::Future, pin::Pin};
28: 26: 
29: 27: /// A type-erased container for any [`Attribute`].
30: 28: pub struct AnyAttribute {
31: 29:     type_id: TypeId,
32: 30:     html_len: usize,
33: 31:     value: Erased,
34: 32:     clone: fn(&Erased) -> AnyAttribute,
35: 33:     #[cfg(feature = "ssr")]
36: 34:     to_html: fn(Erased, &mut String, &mut String, &mut String, &mut String),
37: 35:     build: fn(Erased, el: crate::renderer::types::Element) -> AnyAttributeState,
38: 36:     rebuild: fn(Erased, &mut AnyAttributeState),
39: 37:     #[cfg(feature = "hydrate")]
40: 38:     hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server:
41: 39:         fn(Erased, crate::renderer::types::Element) -> AnyAttributeState,
42: 40:     #[cfg(feature = "hydrate")]
43: 41:     hydrate_from_template:
44: 42:         fn(Erased, crate::renderer::types::Element) -> AnyAttributeState,
45: 43:     #[cfg(feature = "ssr")]
46: 44:     #[allow(clippy::type_complexity)]
47: 45:     resolve: fn(Erased) -> Pin<Box<dyn Future<Output = AnyAttribute> + Send>>,
48: 46:     #[cfg(feature = "ssr")]
49: 47:     dry_resolve: fn(&mut Erased),
50: 48:     keys: fn(&Erased) -> Vec<NamedAttributeKey>,
51: 49: }
52: 50: 
53: 51: impl Clone for AnyAttribute {
54: 52:     fn clone(&self) -> Self {
55: 53:         (self.clone)(&self.value)
56: 54:     }
57: 55: }
58: 56: 
59: 57: impl Debug for AnyAttribute {
60: 58:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
61: 59:         f.debug_struct("AnyAttribute").finish_non_exhaustive()
62: 60:     }
63: 61: }
64: 62: 
65: 63: /// View state for [`AnyAttribute`].
66: 64: pub struct AnyAttributeState {
67: 65:     type_id: TypeId,
68: 66:     state: ErasedLocal,
69: 67:     el: crate::renderer::types::Element,
70: 68:     keys: Vec<NamedAttributeKey>,
71: 69: }
72: 70: 
73: 71: /// Converts an [`Attribute`] into [`AnyAttribute`].
74: 72: pub trait IntoAnyAttribute {
75: 73:     /// Wraps the given attribute.
76: 74:     fn into_any_attr(self) -> AnyAttribute;
77: 75: }
78: 76: 
79: 77: impl<T> IntoAnyAttribute for T
80: 78: where
81: 79:     Self: Send,
82: 80:     T: Attribute,
83: 81:     crate::renderer::types::Element: Clone,
84: 82: {
85: 83:     fn into_any_attr(self) -> AnyAttribute {
86: 84:         fn clone<T: Attribute + Clone + 'static>(
87: 85:             value: &Erased,
88: 86:         ) -> AnyAttribute {
89: 87:             value.get_ref::<T>().clone().into_any_attr()
90: 88:         }
91: 89: 
92: 90:         #[cfg(feature = "ssr")]
93: 91:         fn to_html<T: Attribute + 'static>(
94: 92:             value: Erased,
95: 93:             buf: &mut String,
96: 94:             class: &mut String,
97: 95:             style: &mut String,
98: 96:             inner_html: &mut String,
99: 97:         ) {
100: 98:             value
101: 99:                 .into_inner::<T>()
102: 100:                 .to_html(buf, class, style, inner_html);
103: 101:         }
104: 102: 
105: 103:         fn build<T: Attribute + 'static>(
106: 104:             value: Erased,
107: 105:             el: crate::renderer::types::Element,
108: 106:         ) -> AnyAttributeState {
109: 107:             AnyAttributeState {
110: 108:                 type_id: TypeId::of::<T>(),
111: 109:                 keys: value.get_ref::<T>().keys(),
112: 110:                 state: ErasedLocal::new(value.into_inner::<T>().build(&el)),
113: 111:                 el,
114: 112:             }
115: 113:         }
116: 114: 
117: 115:         #[cfg(feature = "hydrate")]
118: 116:         fn hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server<T: Attribute + 'static>(
119: 117:             value: Erased,
120: 118:             el: crate::renderer::types::Element,
121: 119:         ) -> AnyAttributeState {
122: 120:             AnyAttributeState {
123: 121:                 type_id: TypeId::of::<T>(),
124: 122:                 keys: value.get_ref::<T>().keys(),
125: 123:                 state: ErasedLocal::new(
126: 124:                     value.into_inner::<T>().hydrate::<true>(&el),
127: 125:                 ),
128: 126:                 el,
129: 127:             }
130: 128:         }
131: 129: 
132: 130:         #[cfg(feature = "hydrate")]
133: 131:         fn hydrate_from_template<T: Attribute + 'static>(
134: 132:             value: Erased,
135: 133:             el: crate::renderer::types::Element,
136: 134:         ) -> AnyAttributeState {
137: 135:             AnyAttributeState {
138: 136:                 type_id: TypeId::of::<T>(),
139: 137:                 keys: value.get_ref::<T>().keys(),
140: 138:                 state: ErasedLocal::new(
141: 139:                     value.into_inner::<T>().hydrate::<true>(&el),
142: 140:                 ),
143: 141:                 el,
144: 142:             }
145: 143:         }
146: 144: 
147: 145:         fn rebuild<T: Attribute + 'static>(
148: 146:             value: Erased,
149: 147:             state: &mut AnyAttributeState,
150: 148:         ) {
151: 149:             let value = value.into_inner::<T>();
152: 150:             let state = state.state.get_mut::<T::State>();
153: 151:             value.rebuild(state);
154: 152:         }
155: 153: 
156: 154:         #[cfg(feature = "ssr")]
157: 155:         fn dry_resolve<T: Attribute + 'static>(value: &mut Erased) {
158: 156:             value.get_mut::<T>().dry_resolve();
159: 157:         }
160: 158: 
161: 159:         #[cfg(feature = "ssr")]
162: 160:         fn resolve<T: Attribute + 'static>(
163: 161:             value: Erased,
164: 162:         ) -> Pin<Box<dyn Future<Output = AnyAttribute> + Send>> {
165: 163:             use futures::FutureExt;
166: 164: 
167: 165:             async move {value.into_inner::<T>().resolve().await.into_any_attr()}.boxed()
168: 166:         }
169: 167: 
170: 168:         fn keys<T: Attribute + 'static>(
171: 169:             value: &Erased,
172: 170:         ) -> Vec<NamedAttributeKey> {
173: 171:             value.get_ref::<T>().keys()
174: 172:         }
175: 173: 
176: 174:         let value = self.into_cloneable_owned();
177: 175:         AnyAttribute {
178: 176:             type_id: TypeId::of::<T::CloneableOwned>(),
179: 177:             html_len: value.html_len(),
180: 178:             value: Erased::new(value),
181: 179:             clone: clone::<T::CloneableOwned>,
182: 180:             #[cfg(feature = "ssr")]
183: 181:             to_html: to_html::<T::CloneableOwned>,
184: 182:             build: build::<T::CloneableOwned>,
185: 183:             rebuild: rebuild::<T::CloneableOwned>,
186: 184:             #[cfg(feature = "hydrate")]
187: 185:             hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server: hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::<T::CloneableOwned>,
188: 186:             #[cfg(feature = "hydrate")]
189: 187:             hydrate_from_template: hydrate_from_template::<T::CloneableOwned>,
190: 188:             #[cfg(feature = "ssr")]
191: 189:             resolve: resolve::<T::CloneableOwned>,
192: 190:             #[cfg(feature = "ssr")]
193: 191:             dry_resolve: dry_resolve::<T::CloneableOwned>,
194: 192:             keys: keys::<T::CloneableOwned>,
195: 193:         }
196: 194:     }
197: 195: }
198: 196: 
199: 197: impl NextAttribute for AnyAttribute {
200: 198:     type Output<NewAttr: Attribute> = Vec<AnyAttribute>;
201: 199: 
202: 200:     fn add_any_attr<NewAttr: Attribute>(
203: 201:         self,
204: 202:         new_attr: NewAttr,
205: 203:     ) -> Self::Output<NewAttr> {
206: 204:         vec![self, new_attr.into_any_attr()]
207: 205:     }
208: 206: }
209: 207: 
210: 208: impl Attribute for AnyAttribute {
211: 209:     const MIN_LENGTH: usize = 0;
212: 210: 
213: 211:     type AsyncOutput = AnyAttribute;
214: 212:     type State = AnyAttributeState;
215: 213:     type Cloneable = AnyAttribute;
216: 214:     type CloneableOwned = AnyAttribute;
217: 215: 
218: 216:     fn html_len(&self) -> usize {
219: 217:         self.html_len
220: 218:     }
221: 219: 
222: 220:     #[allow(unused)] // they are used in SSR
223: 221:     fn to_html(
224: 222:         self,
225: 223:         buf: &mut String,
226: 224:         class: &mut String,
227: 225:         style: &mut String,
228: 226:         inner_html: &mut String,
229: 227:     ) {
230: 228:         #[cfg(feature = "ssr")]
231: 229:         {
232: 230:             (self.to_html)(self.value, buf, class, style, inner_html);
233: 231:         }
234: 232:         #[cfg(not(feature = "ssr"))]
235: 233:         panic!(
236: 234:             "You are rendering AnyAttribute to HTML without the `ssr` feature \
237: 235:              enabled."
238: 236:         );
239: 237:     }
240: 238: 
241: 239:     fn hydrate<const FROM_SERVER: bool>(
242: 240:         self,
243: 241:         el: &crate::renderer::types::Element,
244: 242:     ) -> Self::State {
245: 243:         #[cfg(feature = "hydrate")]
246: 244:         if FROM_SERVER {
247: 245:             (self.hydrate_from_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server)(self.value, el.clone())
248: 246:         } else {
249: 247:             (self.hydrate_from_template)(self.value, el.clone())
250: 248:         }
251: 249:         #[cfg(not(feature = "hydrate"))]
252: 250:         {
253: 251:             _ = el;
254: 252:             panic!(
255: 253:                 "You are trying to hydrate AnyAttribute without the `hydrate` \
256: 254:                  feature enabled."
257: 255:             );
258: 256:         }
259: 257:     }
260: 258: 
261: 259:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
262: 260:         (self.build)(self.value, el.clone())
263: 261:     }
264: 262: 
265: 263:     fn rebuild(self, state: &mut Self::State) {
266: 264:         if self.type_id == state.type_id {
267: 265:             (self.rebuild)(self.value, state)
268: 266:         } else {
269: 267:             let new = self.build(&state.el);
270: 268:             *state = new;
271: 269:         }
272: 270:     }
273: 271: 
274: 272:     fn into_cloneable(self) -> Self::Cloneable {
275: 273:         self
276: 274:     }
277: 275: 
278: 276:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
279: 277:         self
280: 278:     }
281: 279: 
282: 280:     fn dry_resolve(&mut self) {
283: 281:         #[cfg(feature = "ssr")]
284: 282:         {
285: 283:             (self.dry_resolve)(&mut self.value)
286: 284:         }
287: 285:         #[cfg(not(feature = "ssr"))]
288: 286:         panic!(
289: 287:             "You are rendering AnyAttribute to HTML without the `ssr` feature \
290: 288:              enabled."
291: 289:         );
292: 290:     }
293: 291: 
294: 292:     async fn resolve(self) -> Self::AsyncOutput {
295: 293:         #[cfg(feature = "ssr")]
296: 294:         {
297: 295:             (self.resolve)(self.value).await
298: 296:         }
299: 297:         #[cfg(not(feature = "ssr"))]
300: 298:         panic!(
301: 299:             "You are rendering AnyAttribute to HTML without the `ssr` feature \
302: 300:              enabled."
303: 301:         );
304: 302:     }
305: 303: 
306: 304:     fn keys(&self) -> Vec<NamedAttributeKey> {
307: 305:         (self.keys)(&self.value)
308: 306:     }
309: 307: }
310: 308: 
311: 309: impl NextAttribute for Vec<AnyAttribute> {
312: 310:     type Output<NewAttr: Attribute> = Self;
313: 311: 
314: 312:     fn add_any_attr<NewAttr: Attribute>(
315: 313:         mut self,
316: 314:         new_attr: NewAttr,
317: 315:     ) -> Self::Output<NewAttr> {
318: 316:         self.push(new_attr.into_any_attr());
319: 317:         self
320: 318:     }
321: 319: }
322: 320: 
323: 321: impl Attribute for Vec<AnyAttribute> {
324: 322:     const MIN_LENGTH: usize = 0;
325: 323: 
326: 324:     type AsyncOutput = Vec<AnyAttribute>;
327: 325:     type State = (Element, Vec<AnyAttributeState>);
328: 326:     type Cloneable = Vec<AnyAttribute>;
329: 327:     type CloneableOwned = Vec<AnyAttribute>;
330: 328: 
331: 329:     fn html_len(&self) -> usize {
332: 330:         self.iter().map(|attr| attr.html_len()).sum()
333: 331:     }
334: 332: 
335: 333:     #[allow(unused)] // they are used in SSR
336: 334:     fn to_html(
337: 335:         self,
338: 336:         buf: &mut String,
339: 337:         class: &mut String,
340: 338:         style: &mut String,
341: 339:         inner_html: &mut String,
342: 340:     ) {
343: 341:         #[cfg(feature = "ssr")]
344: 342:         {
345: 343:             for mut attr in self {
346: 344:                 attr.to_html(buf, class, style, inner_html)
347: 345:             }
348: 346:         }
349: 347:         #[cfg(not(feature = "ssr"))]
350: 348:         panic!(
351: 349:             "You are rendering AnyAttribute to HTML without the `ssr` feature \
352: 350:              enabled."
353: 351:         );
354: 352:     }
355: 353: 
356: 354:     fn hydrate<const FROM_SERVER: bool>(
357: 355:         self,
358: 356:         el: &crate::renderer::types::Element,
359: 357:     ) -> Self::State {
360: 358:         #[cfg(feature = "hydrate")]
361: 359:         if FROM_SERVER {
362: 360:             (
363: 361:                 el.clone(),
364: 362:                 self.into_iter()
365: 363:                     .map(|attr| attr.hydrate::<true>(el))
366: 364:                     .collect(),
367: 365:             )
368: 366:         } else {
369: 367:             (
370: 368:                 el.clone(),
371: 369:                 self.into_iter()
372: 370:                     .map(|attr| attr.hydrate::<false>(el))
373: 371:                     .collect(),
374: 372:             )
375: 373:         }
376: 374:         #[cfg(not(feature = "hydrate"))]
377: 375:         {
378: 376:             _ = el;
379: 377:             panic!(
380: 378:                 "You are trying to hydrate AnyAttribute without the `hydrate` \
381: 379:                  feature enabled."
382: 380:             );
383: 381:         }
384: 382:     }
385: 383: 
386: 384:     fn build(self, el: &crate::renderer::types::Element) -> Self::State {
387: 385:         (
388: 386:             el.clone(),
389: 387:             self.into_iter().map(|attr| attr.build(el)).collect(),
390: 388:         )
391: 389:     }
392: 390: 
393: 391:     fn rebuild(self, state: &mut Self::State) {
394: 392:         let (el, state) = state;
395: 393:         for old in mem::take(state) {
396: 394:             for key in old.keys {
397: 395:                 match key {
398: 396:                     NamedAttributeKey::InnerHtml => {
399: 397:                         Rndr::set_inner_html(&old.el, "");
400: 398:                     }
401: 399:                     NamedAttributeKey::Property(prop_name) => {
402: 400:                         Rndr::set_property(
403: 401:                             &old.el,
404: 402:                             &prop_name,
405: 403:                             &wasm_bindgen::JsValue::UNDEFINED,
406: 404:                         );
407: 405:                     }
408: 406:                     NamedAttributeKey::Attribute(key) => {
409: 407:                         Rndr::remove_attribute(&old.el, &key);
410: 408:                     }
411: 409:                 }
412: 410:             }
413: 411:         }
414: 412:         *state = self.into_iter().map(|s| s.build(el)).collect();
415: 413:     }
416: 414: 
417: 415:     fn into_cloneable(self) -> Self::Cloneable {
418: 416:         self
419: 417:     }
420: 418: 
421: 419:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
422: 420:         self
423: 421:     }
424: 422: 
425: 423:     fn dry_resolve(&mut self) {
426: 424:         #[cfg(feature = "ssr")]
427: 425:         {
428: 426:             for attr in self.iter_mut() {
429: 427:                 attr.dry_resolve()
430: 428:             }
431: 429:         }
432: 430:         #[cfg(not(feature = "ssr"))]
433: 431:         panic!(
434: 432:             "You are rendering AnyAttribute to HTML without the `ssr` feature \
435: 433:              enabled."
436: 434:         );
437: 435:     }
438: 436: 
439: 437:     async fn resolve(self) -> Self::AsyncOutput {
440: 438:         #[cfg(feature = "ssr")]
441: 439:         {
442: 440:             futures::future::join_all(
443: 441:                 self.into_iter().map(|attr| attr.resolve()),
444: 442:             )
445: 443:             .await
446: 444:         }
447: 445:         #[cfg(not(feature = "ssr"))]
448: 446:         panic!(
449: 447:             "You are rendering AnyAttribute to HTML without the `ssr` feature \
450: 448:              enabled."
451: 449:         );
452: 450:     }
453: 451: 
454: 452:     fn keys(&self) -> Vec<NamedAttributeKey> {
455: 453:         self.iter().flat_map(|s| s.keys()).collect()
456: 454:     }
457: 455: }
458: 456: ```
459: 457: ```
460: 458: ```
461: 459: ```
462: 460: ```
463: 461: ```
464: 462: ```
465: 463: ```
466: ```
```
