### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\global.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\global.rs
18: 16: ```rust
19: 17: use super::Lang;
20: 18: use crate::{
21: 19:     html::{
22: 20:         attribute::*,
23: 21:         class::{class, Class, IntoClass},
24: 22:         element::{ElementType, HasElementType, HtmlElement},
25: 23:         event::{on, on_target, EventDescriptor, On, Targeted},
26: 24:         property::{prop, IntoProperty, Property},
27: 25:         style::{style, IntoStyle, Style},
28: 26:     },
29: 27:     prelude::RenderHtml,
30: 28:     view::add_attr::AddAnyAttr,
31: 29: };
32: 30: use core::convert::From;
33: 31: 
34: 32: /// Adds an attribute that modifies the `class`.
35: 33: pub trait ClassAttribute<C>
36: 34: where
37: 35:     C: IntoClass,
38: 36: {
39: 37:     /// The type of the element with the new attribute added.
40: 38:     type Output;
41: 39: 
42: 40:     /// Adds a CSS class to an element.
43: 41:     fn class(self, value: C) -> Self::Output;
44: 42: }
45: 43: 
46: 44: impl<E, At, Ch, C> ClassAttribute<C> for HtmlElement<E, At, Ch>
47: 45: where
48: 46:     E: ElementType + Send,
49: 47:     At: Attribute + Send,
50: 48:     Ch: RenderHtml + Send,
51: 49:     C: IntoClass,
52: 50: {
53: 51:     type Output = <Self as AddAnyAttr>::Output<Class<C>>;
54: 52: 
55: 53:     fn class(self, value: C) -> Self::Output {
56: 54:         self.add_any_attr(class(value))
57: 55:     }
58: 56: }
59: 57: 
60: 58: /// Adds an attribute that modifies the DOM properties.
61: 59: pub trait PropAttribute<K, P>
62: 60: where
63: 61:     P: IntoProperty,
64: 62: {
65: 63:     /// The type of the element with the new attribute added.
66: 64:     type Output;
67: 65: 
68: 66:     /// Adds a DOM property to an element.
69: 67:     fn prop(self, key: K, value: P) -> Self::Output;
70: 68: }
71: 69: 
72: 70: impl<E, At, Ch, K, P> PropAttribute<K, P> for HtmlElement<E, At, Ch>
73: 71: where
74: 72:     E: ElementType + Send,
75: 73:     At: Attribute + Send,
76: 74:     Ch: RenderHtml + Send,
77: 75:     K: AsRef<str> + Send,
78: 76:     P: IntoProperty,
79: 77: {
80: 78:     type Output = <Self as AddAnyAttr>::Output<Property<K, P>>;
81: 79: 
82: 80:     fn prop(self, key: K, value: P) -> Self::Output {
83: 81:         self.add_any_attr(prop(key, value))
84: 82:     }
85: 83: }
86: 84: 
87: 85: /// Adds an attribute that modifies the CSS styles.
88: 86: pub trait StyleAttribute<S>
89: 87: where
90: 88:     S: IntoStyle,
91: 89: {
92: 90:     /// The type of the element with the new attribute added.
93: 91:     type Output;
94: 92: 
95: 93:     /// Adds a CSS style to an element.
96: 94:     fn style(self, value: S) -> Self::Output;
97: 95: }
98: 96: 
99: 97: impl<E, At, Ch, S> StyleAttribute<S> for HtmlElement<E, At, Ch>
100: 98: where
101: 99:     E: ElementType + Send,
102: 100:     At: Attribute + Send,
103: 101:     Ch: RenderHtml + Send,
104: 102:     S: IntoStyle,
105: 103: {
106: 104:     type Output = <Self as AddAnyAttr>::Output<Style<S>>;
107: 105: 
108: 106:     fn style(self, value: S) -> Self::Output {
109: 107:         self.add_any_attr(style(value))
110: 108:     }
111: 109: }
112: 110: 
113: 111: /// Adds an event listener to an element definition.
114: 112: pub trait OnAttribute<E, F> {
115: 113:     /// The type of the element with the event listener added.
116: 114:     type Output;
117: 115: 
118: 116:     /// Adds an event listener to an element.
119: 117:     fn on(self, event: E, cb: F) -> Self::Output;
120: 118: }
121: 119: 
122: 120: impl<El, At, Ch, E, F> OnAttribute<E, F> for HtmlElement<El, At, Ch>
123: 121: where
124: 122:     El: ElementType + Send,
125: 123:     At: Attribute + Send,
126: 124:     Ch: RenderHtml + Send,
127: 125:     E: EventDescriptor + Send + 'static,
128: 126:     E::EventType: 'static,
129: 127:     E::EventType: From<crate::renderer::types::Event>,
130: 128:     F: FnMut(E::EventType) + 'static,
131: 129: {
132: 130:     type Output = <Self as AddAnyAttr>::Output<On<E, F>>;
133: 131: 
134: 132:     fn on(self, event: E, cb: F) -> Self::Output {
135: 133:         self.add_any_attr(on(event, cb))
136: 134:     }
137: 135: }
138: 136: 
139: 137: /// Adds an event listener with a typed target to an element definition.
140: 138: pub trait OnTargetAttribute<E, F, T> {
141: 139:     /// The type of the element with the new attribute added.
142: 140:     type Output;
143: 141: 
144: 142:     /// Adds an event listener with a typed target to an element definition.
145: 143:     fn on_target(self, event: E, cb: F) -> Self::Output;
146: 144: }
147: 145: 
148: 146: impl<El, At, Ch, E, F> OnTargetAttribute<E, F, Self> for HtmlElement<El, At, Ch>
149: 147: where
150: 148:     El: ElementType + Send,
151: 149:     At: Attribute + Send,
152: 150:     Ch: RenderHtml + Send,
153: 151:     E: EventDescriptor + Send + 'static,
154: 152:     E::EventType: 'static,
155: 153:     E::EventType: From<crate::renderer::types::Event>,
156: 154:     F: FnMut(Targeted<E::EventType, <Self as HasElementType>::ElementType>)
157: 155:         + 'static,
158: 156: {
159: 157:     type Output =
160: 158:         <Self as AddAnyAttr>::Output<On<E, Box<dyn FnMut(E::EventType)>>>;
161: 159: 
162: 160:     fn on_target(self, event: E, cb: F) -> Self::Output {
163: 161:         self.add_any_attr(on_target::<E, HtmlElement<El, At, Ch>, F>(event, cb))
164: 162:     }
165: 163: }
166: 164: 
167: 165: /// Global attributes can be added to any HTML element.
168: 166: pub trait GlobalAttributes<V>
169: 167: where
170: 168:     Self: Sized + AddAnyAttr,
171: 169:     V: AttributeValue,
172: 170: {
173: 171:     /// The `accesskey` global attribute provides a hint for generating a keyboard shortcut for the current element.
174: 172:     fn accesskey(
175: 173:         self,
176: 174:         value: V,
177: 175:     ) -> <Self as AddAnyAttr>::Output<Attr<Accesskey, V>> {
178: 176:         self.add_any_attr(accesskey(value))
179: 177:     }
180: 178: 
181: 179:     /// The `autocapitalize` global attribute controls whether and how text input is automatically capitalized as it is entered/edited by the user.
182: 180:     fn autocapitalize(
183: 181:         self,
184: 182:         value: V,
185: 183:     ) -> <Self as AddAnyAttr>::Output<Attr<Autocapitalize, V>> {
186: 184:         self.add_any_attr(autocapitalize(value))
187: 185:     }
188: 186: 
189: 187:     /// The `autofocus` global attribute is a Boolean attribute indicating that an element should receive focus as soon as the page is loaded.
190: 188:     fn autofocus(
191: 189:         self,
192: 190:         value: V,
193: 191:     ) -> <Self as AddAnyAttr>::Output<Attr<Autofocus, V>> {
194: 192:         self.add_any_attr(autofocus(value))
195: 193:     }
196: 194: 
197: 195:     /// The `contenteditable` global attribute is an enumerated attribute indicating if the element should be editable by the user.
198: 196:     fn contenteditable(
199: 197:         self,
200: 198:         value: V,
201: 199:     ) -> <Self as AddAnyAttr>::Output<Attr<Contenteditable, V>> {
202: 200:         self.add_any_attr(contenteditable(value))
203: 201:     }
204: 202: 
205: 203:     /// The `dir` global attribute is an enumerated attribute indicating the directionality of the element's text.
206: 204:     fn dir(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Dir, V>> {
207: 205:         self.add_any_attr(dir(value))
208: 206:     }
209: 207: 
210: 208:     /// The `draggable` global attribute is an enumerated attribute indicating whether the element can be dragged.
211: 209:     fn draggable(
212: 210:         self,
213: 211:         value: V,
214: 212:     ) -> <Self as AddAnyAttr>::Output<Attr<Draggable, V>> {
215: 213:         self.add_any_attr(draggable(value))
216: 214:     }
217: 215: 
218: 216:     /// The `enterkeyhint` global attribute is used to customize the enter key on virtual keyboards.
219: 217:     fn enterkeyhint(
220: 218:         self,
221: 219:         value: V,
222: 220:     ) -> <Self as AddAnyAttr>::Output<Attr<Enterkeyhint, V>> {
223: 221:         self.add_any_attr(enterkeyhint(value))
224: 222:     }
225: 223: 
226: 224:     /// The `exportparts` attribute enables the sharing of parts of an element's shadow DOM with a containing document.
227: 225:     fn exportparts(
228: 226:         self,
229: 227:         value: V,
230: 228:     ) -> <Self as AddAnyAttr>::Output<Attr<Exportparts, V>> {
231: 229:         self.add_any_attr(exportparts(value))
232: 230:     }
233: 231: 
234: 232:     /// The `hidden` global attribute is a Boolean attribute indicating that the element is not yet, or is no longer, relevant.
235: 233:     fn hidden(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Hidden, V>> {
236: 234:         self.add_any_attr(hidden(value))
237: 235:     }
238: 236: 
239: 237:     /// The `id` global attribute defines a unique identifier (ID) which must be unique in the whole document.
240: 238:     fn id(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Id, V>> {
241: 239:         self.add_any_attr(id(value))
242: 240:     }
243: 241: 
244: 242:     /// The `inert` global attribute is a Boolean attribute that makes an element behave inertly.
245: 243:     fn inert(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Inert, V>> {
246: 244:         self.add_any_attr(inert(value))
247: 245:     }
248: 246: 
249: 247:     /// The `inputmode` global attribute provides a hint to browsers for which virtual keyboard to display.
250: 248:     fn inputmode(
251: 249:         self,
252: 250:         value: V,
253: 251:     ) -> <Self as AddAnyAttr>::Output<Attr<Inputmode, V>> {
254: 252:         self.add_any_attr(inputmode(value))
255: 253:     }
256: 254: 
257: 255:     /// The `is` global attribute allows you to specify that a standard HTML element should behave like a custom built-in element.
258: 256:     fn is(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Is, V>> {
259: 257:         self.add_any_attr(is(value))
260: 258:     }
261: 259: 
262: 260:     /// The `itemid` global attribute is used to specify the unique, global identifier of an item.
263: 261:     fn itemid(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Itemid, V>> {
264: 262:         self.add_any_attr(itemid(value))
265: 263:     }
266: 264: 
267: 265:     /// The `itemprop` global attribute is used to add properties to an item.
268: 266:     fn itemprop(
269: 267:         self,
270: 268:         value: V,
271: 269:     ) -> <Self as AddAnyAttr>::Output<Attr<Itemprop, V>> {
272: 270:         self.add_any_attr(itemprop(value))
273: 271:     }
274: 272: 
275: 273:     /// The `itemref` global attribute is used to refer to other elements.
276: 274:     fn itemref(
277: 275:         self,
278: 276:         value: V,
279: 277:     ) -> <Self as AddAnyAttr>::Output<Attr<Itemref, V>> {
280: 278:         self.add_any_attr(itemref(value))
281: 279:     }
282: 280: 
283: 281:     /// The `itemscope` global attribute is used to create a new item.
284: 282:     fn itemscope(
285: 283:         self,
286: 284:         value: V,
287: 285:     ) -> <Self as AddAnyAttr>::Output<Attr<Itemscope, V>> {
288: 286:         self.add_any_attr(itemscope(value))
289: 287:     }
290: 288: 
291: 289:     /// The `itemtype` global attribute is used to specify the types of items.
292: 290:     fn itemtype(
293: 291:         self,
294: 292:         value: V,
295: 293:     ) -> <Self as AddAnyAttr>::Output<Attr<Itemtype, V>> {
296: 294:         self.add_any_attr(itemtype(value))
297: 295:     }
298: 296: 
299: 297:     /// The `lang` global attribute helps define the language of an element.
300: 298:     fn lang(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Lang, V>> {
301: 299:         self.add_any_attr(lang(value))
302: 300:     }
303: 301: 
304: 302:     /// The `nonce` global attribute is used to specify a cryptographic nonce.
305: 303:     fn nonce(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Nonce, V>> {
306: 304:         self.add_any_attr(nonce(value))
307: 305:     }
308: 306: 
309: 307:     /// The `part` global attribute identifies the element as a part of a component.
310: 308:     fn part(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Part, V>> {
311: 309:         self.add_any_attr(part(value))
312: 310:     }
313: 311: 
314: 312:     /// The `popover` global attribute defines the popover's behavior.
315: 313:     fn popover(
316: 314:         self,
317: 315:         value: V,
318: 316:     ) -> <Self as AddAnyAttr>::Output<Attr<Popover, V>> {
319: 317:         self.add_any_attr(popover(value))
320: 318:     }
321: 319: 
322: 320:     /// The `role` global attribute defines the role of an element in ARIA.
323: 321:     fn role(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Role, V>> {
324: 322:         self.add_any_attr(role(value))
325: 323:     }
326: 324: 
327: 325:     /// The `slot` global attribute assigns a slot in a shadow DOM.
328: 326:     fn slot(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Slot, V>> {
329: 327:         self.add_any_attr(slot(value))
330: 328:     }
331: 329: 
332: 330:     /// The `spellcheck` global attribute is an enumerated attribute that defines whether the element may be checked for spelling errors.
333: 331:     fn spellcheck(
334: 332:         self,
335: 333:         value: V,
336: 334:     ) -> <Self as AddAnyAttr>::Output<Attr<Spellcheck, V>> {
337: 335:         self.add_any_attr(spellcheck(value))
338: 336:     }
339: 337: 
340: 338:     /// The `tabindex` global attribute indicates if the element can take input focus.
341: 339:     fn tabindex(
342: 340:         self,
343: 341:         value: V,
344: 342:     ) -> <Self as AddAnyAttr>::Output<Attr<Tabindex, V>> {
345: 343:         self.add_any_attr(tabindex(value))
346: 344:     }
347: 345: 
348: 346:     /// The `title` global attribute contains text representing advisory information.
349: 347:     fn title(self, value: V) -> <Self as AddAnyAttr>::Output<Attr<Title, V>> {
350: 348:         self.add_any_attr(title(value))
351: 349:     }
352: 350: 
353: 351:     /// The `translate` global attribute is an enumerated attribute that specifies whether an element's attribute values and text content should be translated when the page is localized.
354: 352:     fn translate(
355: 353:         self,
356: 354:         value: V,
357: 355:     ) -> <Self as AddAnyAttr>::Output<Attr<Translate, V>> {
358: 356:         self.add_any_attr(translate(value))
359: 357:     }
360: 358: 
361: 359:     /// The `virtualkeyboardpolicy` global attribute specifies the behavior of the virtual keyboard.
362: 360:     fn virtualkeyboardpolicy(
363: 361:         self,
364: 362:         value: V,
365: 363:     ) -> <Self as AddAnyAttr>::Output<Attr<Virtualkeyboardpolicy, V>> {
366: 364:         self.add_any_attr(virtualkeyboardpolicy(value))
367: 365:     }
368: 366: }
369: 367: 
370: 368: impl<El, At, Ch, V> GlobalAttributes<V> for HtmlElement<El, At, Ch>
371: 369: where
372: 370:     El: ElementType + Send,
373: 371:     At: Attribute + Send,
374: 372:     Ch: RenderHtml + Send,
375: 373:     V: AttributeValue,
376: 374: {
377: 375: }
378: 376: 
379: 377: macro_rules! on_definitions {
380: 378: 	($(#[$meta:meta] $key:ident $html:literal),* $(,)?) => {
381: 379:         paste::paste! {
382: 380:             $(
383: 381:                 #[doc = concat!("Adds the HTML `", $html, "` attribute to the element.\n\n**Note**: This is the HTML attribute, which takes a JavaScript string, not an `on:` listener that takes lyx-platform-lyx_platform_lyx-platform-lyx_platform_application logic written in Rust.")]
384: 382:                 #[track_caller]
385: 383:                 fn $key(
386: 384:                     self,
387: 385:                     value: V,
388: 386:                 ) -> <Self as AddAnyAttr>::Output<Attr<[<$key:camel>], V>>
389: 387:                 {
390: 388:                     self.add_any_attr($key(value))
391: 389:                 }
392: 390:             )*
393: 391: 		}
394: 392:     }
395: 393: }
396: 394: 
397: 395: /// Provides methods for HTML event listener attributes.
398: 396: pub trait GlobalOnAttributes<V>
399: 397: where
400: 398:     Self: Sized + AddAnyAttr,
401: 399:     V: AttributeValue,
402: 400: {
403: 401:     on_definitions! {
404: 402:         /// The `onabort` attribute specifies the event handler for the abort event.
405: 403:         onabort "onabort",
406: 404:         /// The `onautocomplete` attribute specifies the event handler for the autocomplete event.
407: 405:         onautocomplete "onautocomplete",
408: 406:         /// The `onautocompleteerror` attribute specifies the event handler for the autocompleteerror event.
409: 407:         onautocompleteerror "onautocompleteerror",
410: 408:         /// The `onblur` attribute specifies the event handler for the blur event.
411: 409:         onblur "onblur",
412: 410:         /// The `oncancel` attribute specifies the event handler for the cancel event.
413: 411:         oncancel "oncancel",
414: 412:         /// The `oncanplay` attribute specifies the event handler for the canplay event.
415: 413:         oncanplay "oncanplay",
416: 414:         /// The `oncanplaythrough` attribute specifies the event handler for the canplaythrough event.
417: 415:         oncanplaythrough "oncanplaythrough",
418: 416:         /// The `onchange` attribute specifies the event handler for the change event.
419: 417:         onchange "onchange",
420: 418:         /// The `onclick` attribute specifies the event handler for the click event.
421: 419:         onclick "onclick",
422: 420:         /// The `onclose` attribute specifies the event handler for the close event.
423: 421:         onclose "onclose",
424: 422:         /// The `oncontextmenu` attribute specifies the event handler for the contextmenu event.
425: 423:         oncontextmenu "oncontextmenu",
426: 424:         /// The `oncuechange` attribute specifies the event handler for the cuechange event.
427: 425:         oncuechange "oncuechange",
428: 426:         /// The `ondblclick` attribute specifies the event handler for the double click event.
429: 427:         ondblclick "ondblclick",
430: 428:         /// The `ondrag` attribute specifies the event handler for the drag event.
431: 429:         ondrag "ondrag",
432: 430:         /// The `ondragend` attribute specifies the event handler for the dragend event.
433: 431:         ondragend "ondragend",
434: 432:         /// The `ondragenter` attribute specifies the event handler for the dragenter event.
435: 433:         ondragenter "ondragenter",
436: 434:         /// The `ondragleave` attribute specifies the event handler for the dragleave event.
437: 435:         ondragleave "ondragleave",
438: 436:         /// The `ondragover` attribute specifies the event handler for the dragover event.
439: 437:         ondragover "ondragover",
440: 438:         /// The `ondragstart` attribute specifies the event handler for the dragstart event.
441: 439:         ondragstart "ondragstart",
442: 440:         /// The `ondrop` attribute specifies the event handler for the drop event.
443: 441:         ondrop "ondrop",
444: 442:         /// The `ondurationchange` attribute specifies the event handler for the durationchange event.
445: 443:         ondurationchange "ondurationchange",
446: 444:         /// The `onemptied` attribute specifies the event handler for the emptied event.
447: 445:         onemptied "onemptied",
448: 446:         /// The `onended` attribute specifies the event handler for the ended event.
449: 447:         onended "onended",
450: 448:         /// The `onerror` attribute specifies the event handler for the error event.
451: 449:         onerror "onerror",
452: 450:         /// The `onfocus` attribute specifies the event handler for the focus event.
453: 451:         onfocus "onfocus",
454: 452:         /// The `onformdata` attribute specifies the event handler for the formdata event.
455: 453:         onformdata "onformdata",
456: 454:         /// The `oninput` attribute specifies the event handler for the input event.
457: 455:         oninput "oninput",
458: 456:         /// The `oninvalid` attribute specifies the event handler for the invalid event.
459: 457:         oninvalid "oninvalid",
460: 458:         /// The `onkeydown` attribute specifies the event handler for the keydown event.
461: 459:         onkeydown "onkeydown",
462: 460:         /// The `onkeypress` attribute specifies the event handler for the keypress event.
463: 461:         onkeypress "onkeypress",
464: 462:         /// The `onkeyup` attribute specifies the event handler for the keyup event.
465: 463:         onkeyup "onkeyup",
466: 464:         /// The `onlanguagechange` attribute specifies the event handler for the languagechange event.
467: 465:         onlanguagechange "onlanguagechange",
468: 466:         /// The `onload` attribute specifies the event handler for the load event.
469: 467:         onload "onload",
470: 468:         /// The `onloadeddata` attribute specifies the event handler for the loadeddata event.
471: 469:         onloadeddata "onloadeddata",
472: 470:         /// The `onloadedmetadata` attribute specifies the event handler for the loadedmetadata event.
473: 471:         onloadedmetadata "onloadedmetadata",
474: 472:         /// The `onloadstart` attribute specifies the event handler for the loadstart event.
475: 473:         onloadstart "onloadstart",
476: 474:         /// The `onmousedown` attribute specifies the event handler for the mousedown event.
477: 475:         onmousedown "onmousedown",
478: 476:         /// The `onmouseenter` attribute specifies the event handler for the mouseenter event.
479: 477:         onmouseenter "onmouseenter",
480: 478:         /// The `onmouseleave` attribute specifies the event handler for the mouseleave event.
481: 479:         onmouseleave "onmouseleave",
482: 480:         /// The `onmousemove` attribute specifies the event handler for the mousemove event.
483: 481:         onmousemove "onmousemove",
484: 482:         /// The `onmouseout` attribute specifies the event handler for the mouseout event.
485: 483:         onmouseout "onmouseout",
486: 484:         /// The `onmouseover` attribute specifies the event handler for the mouseover event.
487: 485:         onmouseover "onmouseover",
488: 486:         /// The `onmouseup` attribute specifies the event handler for the mouseup event.
489: 487:         onmouseup "onmouseup",
490: 488:         /// The `onpause` attribute specifies the event handler for the pause event.
491: 489:         onpause "onpause",
492: 490:         /// The `onplay` attribute specifies the event handler for the play event.
493: 491:         onplay "onplay",
494: 492:         /// The `onplaying` attribute specifies the event handler for the playing event.
495: 493:         onplaying "onplaying",
496: 494:         /// The `onprogress` attribute specifies the event handler for the progress event.
497: 495:         onprogress "onprogress",
498: 496:         /// The `onratechange` attribute specifies the event handler for the ratechange event.
499: 497:         onratechange "onratechange",
500: 498:         /// The `onreset` attribute specifies the event handler for the reset event.
501: 499:         onreset "onreset",
502: 500:         /// The `onresize` attribute specifies the event handler for the resize event.
503: 501:         onresize "onresize",
504: 502:         /// The `onscroll` attribute specifies the event handler for the scroll event.
505: 503:         onscroll "onscroll",
506: 504:         /// The `onsecuritypolicyviolation` attribute specifies the event handler for the securitypolicyviolation event.
507: 505:         onsecuritypolicyviolation "onsecuritypolicyviolation",
508: 506:         /// The `onseeked` attribute specifies the event handler for the seeked event.
509: 507:         onseeked "onseeked",
510: 508:         /// The `onseeking` attribute specifies the event handler for the seeking event.
511: 509:         onseeking "onseeking",
512: 510:         /// The `onselect` attribute specifies the event handler for the select event.
513: 511:         onselect "onselect",
514: 512:         /// The `onslotchange` attribute specifies the event handler for the slotchange event.
515: 513:         onslotchange "onslotchange",
516: 514:         /// The `onstalled` attribute specifies the event handler for the stalled event.
517: 515:         onstalled "onstalled",
518: 516:         /// The `onsubmit` attribute specifies the event handler for the submit event.
519: 517:         onsubmit "onsubmit",
520: 518:         /// The `onsuspend` attribute specifies the event handler for the suspend event.
521: 519:         onsuspend "onsuspend",
522: 520:         /// The `ontimeupdate` attribute specifies the event handler for the timeupdate event.
523: 521:         ontimeupdate "ontimeupdate",
524: 522:         /// The `ontoggle` attribute specifies the event handler for the toggle event.
525: 523:         ontoggle "ontoggle",
526: 524:         /// The `onvolumechange` attribute specifies the event handler for the volumechange event.
527: 525:         onvolumechange "onvolumechange",
528: 526:         /// The `onwaiting` attribute specifies the event handler for the waiting event.
529: 527:         onwaiting "onwaiting",
530: 528:         /// The `onwebkitanimationend` attribute specifies the event handler for the webkitanimationend event.
531: 529:         onwebkitanimationend "onwebkitanimationend",
532: 530:         /// The `onwebkitanimationiteration` attribute specifies the event handler for the webkitanimationiteration event.
533: 531:         onwebkitanimationiteration "onwebkitanimationiteration",
534: 532:         /// The `onwebkitanimationstart` attribute specifies the event handler for the webkitanimationstart event.
535: 533:         onwebkitanimationstart "onwebkitanimationstart",
536: 534:         /// The `onwebkittransitionend` attribute specifies the event handler for the webkittransitionend event.
537: 535:         onwebkittransitionend "onwebkittransitionend",
538: 536:         /// The `onwheel` attribute specifies the event handler for the wheel event.
539: 537:         onwheel "onwheel",
540: 538: 
541: 539:     }
542: 540: }
543: 541: 
544: 542: impl<El, At, Ch, V> GlobalOnAttributes<V> for HtmlElement<El, At, Ch>
545: 543: where
546: 544:     El: ElementType + Send,
547: 545:     At: Attribute + Send,
548: 546:     Ch: RenderHtml + Send,
549: 547:     V: AttributeValue,
550: 548: {
551: 549: }
552: 550: ```
553: 551: ```
554: 552: ```
555: 553: ```
556: 554: ```
557: 555: ```
558: 556: ```
559: 557: ```
560: ```
```
