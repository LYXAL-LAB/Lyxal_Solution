### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\tuples.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\tuples.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\tuples.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\tuples.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\tuples.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\tuples.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\tuples.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\tuples.rs
14: 12: ```rust
15: 13: use super::{
16: 14:     Mountable, Position, PositionState, Render, RenderHtml, ToTemplate,
17: 15: };
18: 16: use crate::{
19: 17:     html::attribute::{any_attribute::AnyAttribute, Attribute},
20: 18:     hydration::Cursor,
21: 19:     renderer::Rndr,
22: 20:     view::{add_attr::AddAnyAttr, StreamBuilder},
23: 21: };
24: 22: use lyx-core-lyx_core_lyx-core-lyx_core_const_str_slice_concat::{
25: 23:     const_concat, const_concat_with_separator, str_from_buffer,
26: 24: };
27: 25: 
28: 26: impl Render for () {
29: 27:     type State = crate::renderer::types::Placeholder;
30: 28: 
31: 29:     fn build(self) -> Self::State {
32: 30:         Rndr::create_placeholder()
33: 31:     }
34: 32: 
35: 33:     fn rebuild(self, _state: &mut Self::State) {}
36: 34: }
37: 35: 
38: 36: impl RenderHtml for () {
39: 37:     type AsyncOutput = ();
40: 38:     type Owned = ();
41: 39: 
42: 40:     const MIN_LENGTH: usize = 3;
43: 41:     const EXISTS: bool = false;
44: 42: 
45: 43:     fn to_html_with_buf(
46: 44:         self,
47: 45:         buf: &mut String,
48: 46:         position: &mut Position,
49: 47:         escape: bool,
50: 48:         _mark_branches: bool,
51: 49:         _extra_attrs: Vec<AnyAttribute>,
52: 50:     ) {
53: 51:         if escape {
54: 52:             buf.push_str("<!>");
55: 53:             *position = Position::NextChild;
56: 54:         }
57: 55:     }
58: 56: 
59: 57:     fn hydrate<const FROM_SERVER: bool>(
60: 58:         self,
61: 59:         cursor: &Cursor,
62: 60:         position: &PositionState,
63: 61:     ) -> Self::State {
64: 62:         let marker = cursor.next_placeholder(position);
65: 63:         position.set(Position::NextChild);
66: 64:         marker
67: 65:     }
68: 66: 
69: 67:     async fn resolve(self) -> Self::AsyncOutput {}
70: 68: 
71: 69:     fn dry_resolve(&mut self) {}
72: 70: 
73: 71:     fn into_owned(self) -> Self::Owned {}
74: 72: }
75: 73: 
76: 74: impl AddAnyAttr for () {
77: 75:     type Output<SomeNewAttr: Attribute> = ();
78: 76: 
79: 77:     fn add_any_attr<NewAttr: Attribute>(
80: 78:         self,
81: 79:         _attr: NewAttr,
82: 80:     ) -> Self::Output<NewAttr>
83: 81:     where
84: 82:         Self::Output<NewAttr>: RenderHtml,
85: 83:     {
86: 84:     }
87: 85: }
88: 86: 
89: 87: impl Mountable for () {
90: 88:     fn unmount(&mut self) {}
91: 89: 
92: 90:     fn mount(
93: 91:         &mut self,
94: 92:         _parent: &crate::renderer::types::Element,
95: 93:         _marker: Option<&crate::renderer::types::Node>,
96: 94:     ) {
97: 95:     }
98: 96: 
99: 97:     fn insert_before_this(&self, _child: &mut dyn Mountable) -> bool {
100: 98:         false
101: 99:     }
102: 100: 
103: 101:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
104: 102:         vec![]
105: 103:     }
106: 104: }
107: 105: 
108: 106: impl ToTemplate for () {
109: 107:     const TEMPLATE: &'static str = "<!>";
110: 108: 
111: 109:     fn to_template(
112: 110:         buf: &mut String,
113: 111:         _class: &mut String,
114: 112:         _style: &mut String,
115: 113:         _inner_html: &mut String,
116: 114:         _position: &mut Position,
117: 115:     ) {
118: 116:         buf.push_str("<!>");
119: 117:     }
120: 118: 
121: 119:     fn to_template_attribute(
122: 120:         _buf: &mut String,
123: 121:         _class: &mut String,
124: 122:         _style: &mut String,
125: 123:         _inner_html: &mut String,
126: 124:         _position: &mut Position,
127: 125:     ) {
128: 126:     }
129: 127: }
130: 128: 
131: 129: impl<A: Render> Render for (A,) {
132: 130:     type State = A::State;
133: 131: 
134: 132:     fn build(self) -> Self::State {
135: 133:         self.0.build()
136: 134:     }
137: 135: 
138: 136:     fn rebuild(self, state: &mut Self::State) {
139: 137:         self.0.rebuild(state)
140: 138:     }
141: 139: }
142: 140: 
143: 141: impl<A> RenderHtml for (A,)
144: 142: where
145: 143:     A: RenderHtml,
146: 144: {
147: 145:     type AsyncOutput = (A::AsyncOutput,);
148: 146:     type Owned = (A::Owned,);
149: 147: 
150: 148:     const MIN_LENGTH: usize = A::MIN_LENGTH;
151: 149:     const EXISTS: bool = A::EXISTS;
152: 150: 
153: 151:     fn html_len(&self) -> usize {
154: 152:         self.0.html_len()
155: 153:     }
156: 154: 
157: 155:     fn to_html_with_buf(
158: 156:         self,
159: 157:         buf: &mut String,
160: 158:         position: &mut Position,
161: 159:         escape: bool,
162: 160:         mark_branches: bool,
163: 161:         extra_attrs: Vec<AnyAttribute>,
164: 162:     ) {
165: 163:         self.0.to_html_with_buf(
166: 164:             buf,
167: 165:             position,
168: 166:             escape,
169: 167:             mark_branches,
170: 168:             extra_attrs,
171: 169:         );
172: 170:     }
173: 171: 
174: 172:     fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
175: 173:         self,
176: 174:         buf: &mut StreamBuilder,
177: 175:         position: &mut Position,
178: 176:         escape: bool,
179: 177:         mark_branches: bool,
180: 178:         extra_attrs: Vec<AnyAttribute>,
181: 179:     ) where
182: 180:         Self: Sized,
183: 181:     {
184: 182:         self.0.to_html_async_with_buf::<OUT_OF_ORDER>(
185: 183:             buf,
186: 184:             position,
187: 185:             escape,
188: 186:             mark_branches,
189: 187:             extra_attrs,
190: 188:         );
191: 189:     }
192: 190: 
193: 191:     fn hydrate<const FROM_SERVER: bool>(
194: 192:         self,
195: 193:         cursor: &Cursor,
196: 194:         position: &PositionState,
197: 195:     ) -> Self::State {
198: 196:         self.0.hydrate::<FROM_SERVER>(cursor, position)
199: 197:     }
200: 198: 
201: 199:     async fn hydrate_async(
202: 200:         self,
203: 201:         cursor: &Cursor,
204: 202:         position: &PositionState,
205: 203:     ) -> Self::State {
206: 204:         self.0.hydrate_async(cursor, position).await
207: 205:     }
208: 206: 
209: 207:     async fn resolve(self) -> Self::AsyncOutput {
210: 208:         (self.0.resolve().await,)
211: 209:     }
212: 210: 
213: 211:     fn dry_resolve(&mut self) {
214: 212:         self.0.dry_resolve();
215: 213:     }
216: 214: 
217: 215:     fn into_owned(self) -> Self::Owned {
218: 216:         (self.0.into_owned(),)
219: 217:     }
220: 218: }
221: 219: 
222: 220: impl<A: ToTemplate> ToTemplate for (A,) {
223: 221:     const TEMPLATE: &'static str = A::TEMPLATE;
224: 222:     const CLASS: &'static str = A::CLASS;
225: 223:     const STYLE: &'static str = A::STYLE;
226: 224: 
227: 225:     fn to_template(
228: 226:         buf: &mut String,
229: 227:         class: &mut String,
230: 228:         style: &mut String,
231: 229:         inner_html: &mut String,
232: 230:         position: &mut Position,
233: 231:     ) {
234: 232:         A::to_template(buf, class, style, inner_html, position)
235: 233:     }
236: 234: }
237: 235: 
238: 236: impl<A> AddAnyAttr for (A,)
239: 237: where
240: 238:     A: AddAnyAttr,
241: 239: {
242: 240:     type Output<SomeNewAttr: Attribute> = (A::Output<SomeNewAttr>,);
243: 241: 
244: 242:     fn add_any_attr<NewAttr: Attribute>(
245: 243:         self,
246: 244:         attr: NewAttr,
247: 245:     ) -> Self::Output<NewAttr>
248: 246:     where
249: 247:         Self::Output<NewAttr>: RenderHtml,
250: 248:     {
251: 249:         (self.0.add_any_attr(attr),)
252: 250:     }
253: 251: }
254: 252: 
255: 253: macro_rules! impl_view_for_tuples {
256: 254: 	($first:ident, $($ty:ident),* $(,)?) => {
257: 255: 		impl<$first, $($ty),*> Render for ($first, $($ty,)*)
258: 256: 		where
259: 257: 			$first: Render,
260: 258: 			$($ty: Render),*,
261: 259: 
262: 260: 		{
263: 261: 			type State = ($first::State, $($ty::State,)*);
264: 262: 
265: 263: 			fn build(self) -> Self::State {
266: 264:                 #[allow(non_snake_case)]
267: 265:                 let ($first, $($ty,)*) = self;
268: 266:                 (
269: 267:                     $first.build(),
270: 268:                     $($ty.build()),*
271: 269:                 )
272: 270: 			}
273: 271: 
274: 272: 			fn rebuild(self, state: &mut Self::State) {
275: 273: 				paste::paste! {
276: 274: 					let ([<$first:lower>], $([<$ty:lower>],)*) = self;
277: 275: 					let ([<view_ $first:lower>], $([<view_ $ty:lower>],)*) = state;
278: 276: 					[<$first:lower>].rebuild([<view_ $first:lower>]);
279: 277: 					$([<$ty:lower>].rebuild([<view_ $ty:lower>]));*
280: 278: 				}
281: 279: 			}
282: 280: 		}
283: 281: 
284: 282: 		impl<$first, $($ty),*> RenderHtml for ($first, $($ty,)*)
285: 283: 		where
286: 284: 			$first: RenderHtml,
287: 285: 			$($ty: RenderHtml),*,
288: 286: 
289: 287: 		{
290: 288:             type AsyncOutput = ($first::AsyncOutput, $($ty::AsyncOutput,)*);
291: 289:             type Owned = ($first::Owned, $($ty::Owned,)*);
292: 290:             const EXISTS: bool = $first::EXISTS || $($ty::EXISTS || )* false;
293: 291:             const MIN_LENGTH: usize = $first::MIN_LENGTH $(+ $ty::MIN_LENGTH)*;
294: 292: 
295: 293:             #[inline(always)]
296: 294:             fn html_len(&self) -> usize {
297: 295:                 #[allow(non_snake_case)]
298: 296: 			    let ($first, $($ty,)* ) = self;
299: 297:                 $($ty.html_len() +)* $first.html_len()
300: 298:             }
301: 299: 
302: 300: 			fn to_html_with_buf(
303: 301:                 self,
304: 302:                 buf: &mut String,
305: 303:                 position: &mut Position,
306: 304:                 escape: bool,
307: 305:                 mark_branches: bool,
308: 306:                 extra_attrs: Vec<AnyAttribute>
309: 307:             ) {
310: 308:                 #[allow(non_snake_case)]
311: 309:                 let ($first, $($ty,)* ) = self;
312: 310:                 $first.to_html_with_buf(buf, position, escape, mark_branches, extra_attrs.clone());
313: 311:                 $($ty.to_html_with_buf(buf, position, escape, mark_branches, extra_attrs.clone()));*
314: 312: 			}
315: 313: 
316: 314: 			fn to_html_async_with_buf<const OUT_OF_ORDER: bool>(
317: 315: 				self,
318: 316: 				buf: &mut StreamBuilder,
319: 317:                 position: &mut Position,
320: 318:                 escape: bool,
321: 319:                 mark_branches: bool,
322: 320:                 extra_attrs: Vec<AnyAttribute>
323: 321:             ) where
324: 322: 				Self: Sized,
325: 323: 			{
326: 324:                 #[allow(non_snake_case)]
327: 325:                 let ($first, $($ty,)* ) = self;
328: 326:                 $first.to_html_async_with_buf::<OUT_OF_ORDER>(buf, position, escape, mark_branches, extra_attrs.clone());
329: 327:                 $($ty.to_html_async_with_buf::<OUT_OF_ORDER>(buf, position, escape, mark_branches, extra_attrs.clone()));*
330: 328: 			}
331: 329: 
332: 330: 			fn hydrate<const FROM_SERVER: bool>(self, cursor: &Cursor, position: &PositionState) -> Self::State {
333: 331:                 #[allow(non_snake_case)]
334: 332: 					let ($first, $($ty,)* ) = self;
335: 333: 					(
336: 334: 						$first.hydrate::<FROM_SERVER>(cursor, position),
337: 335: 						$($ty.hydrate::<FROM_SERVER>(cursor, position)),*
338: 336: 					)
339: 337: 			}
340: 338: 
341: 339:             async fn hydrate_async(self, cursor: &Cursor, position: &PositionState) -> Self::State {
342: 340:                 #[allow(non_snake_case)]
343: 341: 					let ($first, $($ty,)* ) = self;
344: 342: 					(
345: 343: 						$first.hydrate_async(cursor, position).await,
346: 344: 						$($ty.hydrate_async(cursor, position).await),*
347: 345: 					)
348: 346: 			}
349: 347: 
350: 348:             async fn resolve(self) -> Self::AsyncOutput {
351: 349:                 #[allow(non_snake_case)]
352: 350:                 let ($first, $($ty,)*) = self;
353: 351:                 futures::join!(
354: 352:                     $first.resolve(),
355: 353:                     $($ty.resolve()),*
356: 354:                 )
357: 355:             }
358: 356: 
359: 357:             fn dry_resolve(&mut self) {
360: 358:                 #[allow(non_snake_case)]
361: 359:                 let ($first, $($ty,)*) = self;
362: 360:                 $first.dry_resolve();
363: 361:                 $($ty.dry_resolve());*
364: 362:             }
365: 363: 
366: 364:             fn into_owned(self) -> Self::Owned {
367: 365:                 #[allow(non_snake_case)]
368: 366:                 let ($first, $($ty,)*) = self;
369: 367:                 (
370: 368:                     $first.into_owned(),
371: 369:                     $($ty.into_owned()),*
372: 370:                 )
373: 371:             }
374: 372: 		}
375: 373: 
376: 374: 		impl<$first, $($ty),*> ToTemplate for ($first, $($ty,)*)
377: 375: 		where
378: 376: 			$first: ToTemplate,
379: 377: 			$($ty: ToTemplate),*
380: 378: 		{
381: 379: 			const TEMPLATE: &'static str = str_from_buffer(&const_concat(&[
382: 380: 				$first::TEMPLATE, $($ty::TEMPLATE),*
383: 381: 			]));
384: 382: 			const CLASS: &'static str = str_from_buffer(&const_concat_with_separator(&[
385: 383: 				$first::CLASS, $($ty::CLASS),*
386: 384: 			], " "));
387: 385: 			const STYLE: &'static str = str_from_buffer(&const_concat_with_separator(&[
388: 386: 				$first::STYLE, $($ty::STYLE),*
389: 387: 			], ";"));
390: 388: 
391: 389: 			fn to_template(buf: &mut String, class: &mut String, style: &mut String, inner_html: &mut String, position: &mut Position)  {
392: 390:                 $first ::to_template(buf, class, style, inner_html, position);
393: 391:                 $($ty::to_template(buf, class, style, inner_html, position));*;
394: 392: 			}
395: 393: 		}
396: 394: 
397: 395: 		impl<$first, $($ty),*> Mountable for ($first, $($ty,)*) where
398: 396: 			$first: Mountable,
399: 397: 			$($ty: Mountable),*,
400: 398: 
401: 399: 		{
402: 400: 			fn unmount(&mut self) {
403: 401:                 #[allow(non_snake_case)] // better macro performance
404: 402:                 let ($first, $($ty,)*) = self;
405: 403:                 $first.unmount();
406: 404:                 $($ty.unmount());*
407: 405: 			}
408: 406: 
409: 407: 			fn mount(
410: 408: 				&mut self,
411: 409: 				parent: &crate::renderer::types::Element,
412: 410: 				marker: Option<&crate::renderer::types::Node>,
413: 411: 			) {
414: 412:                 #[allow(non_snake_case)] // better macro performance
415: 413:                 let ($first, $($ty,)*) = self;
416: 414:                 $first.mount(parent, marker);
417: 415:                 $($ty.mount(parent, marker));*
418: 416: 			}
419: 417: 
420: 418: 			fn insert_before_this(&self,
421: 419: 				child: &mut dyn Mountable,
422: 420: 			) -> bool {
423: 421:                 #[allow(non_snake_case)] // better macro performance
424: 422:                 let ($first, $($ty,)*) = self;
425: 423:                 $first.insert_before_this(child)
426: 424:                 $(|| $ty.insert_before_this(child))*
427: 425: 			}
428: 426: 
429: 427:             fn elements(&self) -> Vec<crate::renderer::types::Element> {
430: 428:                 #[allow(non_snake_case)] // better macro performance
431: 429:                 let ($first, $($ty,)*) = self;
432: 430:                 $first.elements().into_iter()
433: 431:                 $(.chain($ty.elements()))*
434: 432:                     .collect()
435: 433:             }
436: 434: 		}
437: 435: 
438: 436:         impl<$first, $($ty,)*> AddAnyAttr for ($first, $($ty,)*)
439: 437:         where
440: 438: 			$first: AddAnyAttr,
441: 439: 			$($ty: AddAnyAttr),*,
442: 440: 
443: 441:         {
444: 442:             type Output<SomeNewAttr: Attribute> = ($first::Output<SomeNewAttr::Cloneable>, $($ty::Output<SomeNewAttr::Cloneable>,)*);
445: 443: 
446: 444:             fn add_any_attr<NewAttr: Attribute>(
447: 445:                 self,
448: 446:                 attr: NewAttr,
449: 447:             ) -> Self::Output<NewAttr>
450: 448:             where
451: 449:                 Self::Output<NewAttr>: RenderHtml,
452: 450:             {
453: 451:                 let shared = attr.into_cloneable();
454: 452:                 #[allow(non_snake_case)] // better macro performance
455: 453:                 let ($first, $($ty,)*) = self;
456: 454:                 ($first.add_any_attr(shared.clone()), $($ty.add_any_attr(shared.clone()),)*)
457: 455:             }
458: 456:         }
459: 457:     };
460: 458: }
461: 459: 
462: 460: impl_view_for_tuples!(A, B);
463: 461: impl_view_for_tuples!(A, B, C);
464: 462: impl_view_for_tuples!(A, B, C, D);
465: 463: impl_view_for_tuples!(A, B, C, D, E);
466: 464: impl_view_for_tuples!(A, B, C, D, E, F);
467: 465: impl_view_for_tuples!(A, B, C, D, E, F, G);
468: 466: impl_view_for_tuples!(A, B, C, D, E, F, G, H);
469: 467: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I);
470: 468: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J);
471: 469: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K);
472: 470: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L);
473: 471: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M);
474: 472: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N);
475: 473: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O);
476: 474: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P);
477: 475: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q);
478: 476: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R);
479: 477: impl_view_for_tuples!(A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S);
480: 478: impl_view_for_tuples!(
481: 479:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T
482: 480: );
483: 481: impl_view_for_tuples!(
484: 482:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U
485: 483: );
486: 484: impl_view_for_tuples!(
487: 485:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V
488: 486: );
489: 487: impl_view_for_tuples!(
490: 488:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W
491: 489: );
492: 490: impl_view_for_tuples!(
493: 491:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X
494: 492: );
495: 493: impl_view_for_tuples!(
496: 494:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y
497: 495: );
498: 496: impl_view_for_tuples!(
499: 497:     A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y,
500: 498:     Z
501: 499: );
502: 500: ```
503: 501: ```
504: 502: ```
505: 503: ```
506: 504: ```
507: 505: ```
508: ```
```
