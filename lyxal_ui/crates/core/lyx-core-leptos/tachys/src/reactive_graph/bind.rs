### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_reactive_graph\bind.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\bind.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     dom::{event_target_checked, event_target_value},
21: 19:     html::{
22: 20:         attribute::{
23: 21:             maybe_next_attr_erasure_macros::{
24: 22:                 next_attr_combine, next_attr_output_type,
25: 23:             },
26: 24:             Attribute, AttributeKey, AttributeValue, NamedAttributeKey,
27: 25:             NextAttribute,
28: 26:         },
29: 27:         event::{change, input, on},
30: 28:         property::{prop, IntoProperty},
31: 29:     },
32: 30:     prelude::AddAnyAttr,
33: 31:     renderer::{types::Element, RemoveEventHandler},
34: 32:     view::{Position, ToTemplate},
35: 33: };
36: 34: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
37: 35:     signal::{ReadSignal, RwSignal, WriteSignal},
38: 36:     traits::{Get, Set},
39: 37:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal,
40: 38: };
41: 39: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
42: 40: use wasm_bindgen::JsValue;
43: 41: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
44: 42: use {
45: 43:     lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Storage,
46: 44:     lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores::{
47: 45:         ArcField, AtIndex, AtKeyed, DerefedField, Field, KeyedSubfield,
48: 46:         StoreField, Subfield,
49: 47:     },
50: 48:     std::ops::{Deref, DerefMut, IndexMut},
51: 49: };
52: 50: 
53: 51: /// `group` attribute used for radio inputs with `bind`.
54: 52: #[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
55: 53: pub struct Group;
56: 54: 
57: 55: impl AttributeKey for Group {
58: 56:     const KEY: &'static str = "group";
59: 57: }
60: 58: 
61: 59: /// Adds a two-way binding to the element, which adds an attribute and an event listener to the
62: 60: /// element when the element is created or hydrated.
63: 61: pub trait BindAttribute<Key, Sig, T>
64: 62: where
65: 63:     Key: AttributeKey,
66: 64:     Sig: IntoSplitSignal<Value = T>,
67: 65:     T: FromEventTarget + AttributeValue + 'static,
68: 66: {
69: 67:     /// The type of the element with the two-way binding added.
70: 68:     type Output;
71: 69: 
72: 70:     /// Adds a two-way binding to the element, which adds an attribute and an event listener to the
73: 71:     /// element when the element is created or hydrated.
74: 72:     ///
75: 73:     /// Example:
76: 74:     ///
77: 75:     /// ```ignore
78: 76:     /// // You can use `RwSignal`s
79: 77:     /// let is_awesome = RwSignal::new(true);
80: 78:     ///
81: 79:     /// // And you can use split signals
82: 80:     /// let (text, set_text) = signal("Hello world".to_string());
83: 81:     ///
84: 82:     /// // Use `Checked` and a `bool` signal for a checkbox
85: 83:     /// checkbox_element.bind(Checked, is_awesome);
86: 84:     ///
87: 85:     /// // Use `Group` and `String` for radio inputs
88: 86:     /// radio_element.bind(Group, (text, set_text));
89: 87:     ///
90: 88:     /// // Use `Value` and `String` for everything else
91: 89:     /// input_element.bind(Value, (text, set_text));
92: 90:     /// ```
93: 91:     ///
94: 92:     /// Depending on the input different events are listened to.
95: 93:     /// - `<input type="checkbox">`, `<input type="radio">` and `<select>` use the `change` event;
96: 94:     /// - `<input>` with the rest of the types and `<textarea>` elements use the `input` event;
97: 95:     fn bind(self, key: Key, signal: Sig) -> Self::Output;
98: 96: }
99: 97: 
100: 98: impl<V, Key, Sig, T> BindAttribute<Key, Sig, T> for V
101: 99: where
102: 100:     V: AddAnyAttr,
103: 101:     Key: AttributeKey,
104: 102:     Sig: IntoSplitSignal<Value = T>,
105: 103:     T: FromEventTarget + AttributeValue + PartialEq + Sync + 'static,
106: 104:     Signal<BoolOrT<T>>: IntoProperty,
107: 105:     <Sig as IntoSplitSignal>::Read:
108: 106:         Get<Value = T> + Send + Sync + Clone + 'static,
109: 107:     <Sig as IntoSplitSignal>::Write: Send + Clone + 'static,
110: 108:     Element: GetValue<T>,
111: 109: {
112: 110:     type Output = <Self as AddAnyAttr>::Output<
113: 111:         Bind<
114: 112:             Key,
115: 113:             T,
116: 114:             <Sig as IntoSplitSignal>::Read,
117: 115:             <Sig as IntoSplitSignal>::Write,
118: 116:         >,
119: 117:     >;
120: 118: 
121: 119:     fn bind(self, key: Key, signal: Sig) -> Self::Output {
122: 120:         self.add_any_attr(bind(key, signal))
123: 121:     }
124: 122: }
125: 123: 
126: 124: /// Adds a two-way binding to the element, which adds an attribute and an event listener to the
127: 125: /// element when the element is created or hydrated.
128: 126: #[inline(always)]
129: 127: pub fn bind<Key, Sig, T>(
130: 128:     key: Key,
131: 129:     signal: Sig,
132: 130: ) -> Bind<Key, T, <Sig as IntoSplitSignal>::Read, <Sig as IntoSplitSignal>::Write>
133: 131: where
134: 132:     Key: AttributeKey,
135: 133:     Sig: IntoSplitSignal<Value = T>,
136: 134:     T: FromEventTarget + AttributeValue + 'static,
137: 135:     <Sig as IntoSplitSignal>::Read: Get<Value = T> + Clone + 'static,
138: 136:     <Sig as IntoSplitSignal>::Write: Send + Clone + 'static,
139: 137: {
140: 138:     let (read_signal, write_signal) = signal.into_split_signal();
141: 139: 
142: 140:     Bind {
143: 141:         key,
144: 142:         read_signal,
145: 143:         write_signal,
146: 144:     }
147: 145: }
148: 146: 
149: 147: /// Two-way binding of an attribute and an event listener
150: 148: #[derive(Debug)]
151: 149: pub struct Bind<Key, T, R, W>
152: 150: where
153: 151:     Key: AttributeKey,
154: 152:     T: FromEventTarget + AttributeValue + 'static,
155: 153:     R: Get<Value = T> + Clone + 'static,
156: 154:     W: Set<Value = T>,
157: 155: {
158: 156:     key: Key,
159: 157:     read_signal: R,
160: 158:     write_signal: W,
161: 159: }
162: 160: 
163: 161: impl<Key, T, R, W> Clone for Bind<Key, T, R, W>
164: 162: where
165: 163:     Key: AttributeKey,
166: 164:     T: FromEventTarget + AttributeValue + 'static,
167: 165:     R: Get<Value = T> + Clone + 'static,
168: 166:     W: Set<Value = T> + Clone,
169: 167: {
170: 168:     fn clone(&self) -> Self {
171: 169:         Self {
172: 170:             key: self.key.clone(),
173: 171:             read_signal: self.read_signal.clone(),
174: 172:             write_signal: self.write_signal.clone(),
175: 173:         }
176: 174:     }
177: 175: }
178: 176: 
179: 177: impl<Key, T, R, W> Bind<Key, T, R, W>
180: 178: where
181: 179:     Key: AttributeKey,
182: 180:     T: FromEventTarget + AttributeValue + PartialEq + Sync + 'static,
183: 181:     R: Get<Value = T> + Clone + Send + Sync + 'static,
184: 182:     W: Set<Value = T> + Clone + 'static,
185: 183:     Element: ChangeEvent + GetValue<T>,
186: 184: {
187: 185:     /// Attaches the event listener that updates the signal value to the element.
188: 186:     pub fn attach(self, el: &Element) -> RemoveEventHandler<Element> {
189: 187:         el.attach_change_event::<T, W>(Key::KEY, self.write_signal.clone())
190: 188:     }
191: 189: 
192: 190:     /// Creates the signal to update the value of the attribute. This signal is different
193: 191:     /// when using a `"group"` attribute
194: 192:     pub fn read_signal(&self, el: &Element) -> Signal<BoolOrT<T>> {
195: 193:         let read_signal = self.read_signal.clone();
196: 194: 
197: 195:         if Key::KEY == "group" {
198: 196:             let el = SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(el.clone());
199: 197: 
200: 198:             Signal::derive(move || {
201: 199:                 BoolOrT::Bool(el.get_value() == read_signal.get())
202: 200:             })
203: 201:         } else {
204: 202:             Signal::derive(move || BoolOrT::T(read_signal.get()))
205: 203:         }
206: 204:     }
207: 205: 
208: 206:     /// Returns the key of the attribute. If the key is `"group"` it returns `"checked"`, otherwise
209: 207:     /// the one which was provided originally.
210: 208:     pub fn key(&self) -> &'static str {
211: 209:         if Key::KEY == "group" {
212: 210:             "checked"
213: 211:         } else {
214: 212:             Key::KEY
215: 213:         }
216: 214:     }
217: 215: }
218: 216: 
219: 217: impl<Key, T, R, W> Attribute for Bind<Key, T, R, W>
220: 218: where
221: 219:     Key: AttributeKey,
222: 220:     T: FromEventTarget + AttributeValue + PartialEq + Sync + 'static,
223: 221:     R: Get<Value = T> + Clone + Send + Sync + 'static,
224: 222:     Signal<BoolOrT<T>>: IntoProperty,
225: 223:     W: Set<Value = T> + Clone + Send + 'static,
226: 224:     Element: ChangeEvent + GetValue<T>,
227: 225: {
228: 226:     const MIN_LENGTH: usize = 0;
229: 227: 
230: 228:     type State = (
231: 229:         <Signal<BoolOrT<T>> as IntoProperty>::State,
232: 230:         (Element, Option<RemoveEventHandler<Element>>),
233: 231:     );
234: 232:     type AsyncOutput = Self;
235: 233:     type Cloneable = Bind<Key, T, R, W>;
236: 234:     type CloneableOwned = Bind<Key, T, R, W>;
237: 235: 
238: 236:     fn html_len(&self) -> usize {
239: 237:         0
240: 238:     }
241: 239: 
242: 240:     fn to_html(
243: 241:         self,
244: 242:         _buf: &mut String,
245: 243:         _class: &mut String,
246: 244:         _style: &mut String,
247: 245:         _inner_html: &mut String,
248: 246:     ) {
249: 247:     }
250: 248: 
251: 249:     #[inline(always)]
252: 250:     fn hydrate<const FROM_SERVER: bool>(self, el: &Element) -> Self::State {
253: 251:         let signal = self.read_signal(el);
254: 252:         let attr_state = prop(self.key(), signal).hydrate::<FROM_SERVER>(el);
255: 253: 
256: 254:         let cleanup = self.attach(el);
257: 255: 
258: 256:         (attr_state, (el.clone(), Some(cleanup)))
259: 257:     }
260: 258: 
261: 259:     #[inline(always)]
262: 260:     fn build(self, el: &Element) -> Self::State {
263: 261:         let signal = self.read_signal(el);
264: 262:         let attr_state = prop(self.key(), signal).build(el);
265: 263: 
266: 264:         let cleanup = self.attach(el);
267: 265: 
268: 266:         (attr_state, (el.clone(), Some(cleanup)))
269: 267:     }
270: 268: 
271: 269:     #[inline(always)]
272: 270:     fn rebuild(self, state: &mut Self::State) {
273: 271:         let (attr_state, (el, prev_cleanup)) = state;
274: 272: 
275: 273:         let signal = self.read_signal(el);
276: 274:         prop(self.key(), signal).rebuild(attr_state);
277: 275: 
278: 276:         if let Some(prev) = prev_cleanup.take() {
279: 277:             if let Some(remove) = prev.into_inner() {
280: 278:                 remove();
281: 279:             }
282: 280:         }
283: 281:         *prev_cleanup = Some(self.attach(el));
284: 282:     }
285: 283: 
286: 284:     fn into_cloneable(self) -> Self::Cloneable {
287: 285:         self.into_cloneable_owned()
288: 286:     }
289: 287: 
290: 288:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
291: 289:         self
292: 290:     }
293: 291: 
294: 292:     fn dry_resolve(&mut self) {}
295: 293: 
296: 294:     async fn resolve(self) -> Self::AsyncOutput {
297: 295:         self
298: 296:     }
299: 297: 
300: 298:     fn keys(&self) -> Vec<NamedAttributeKey> {
301: 299:         vec![]
302: 300:     }
303: 301: }
304: 302: 
305: 303: impl<Key, T, R, W> NextAttribute for Bind<Key, T, R, W>
306: 304: where
307: 305:     Key: AttributeKey,
308: 306:     T: FromEventTarget + AttributeValue + PartialEq + Sync + 'static,
309: 307:     R: Get<Value = T> + Clone + Send + Sync + 'static,
310: 308:     Signal<BoolOrT<T>>: IntoProperty,
311: 309:     W: Set<Value = T> + Clone + Send + 'static,
312: 310:     Element: ChangeEvent + GetValue<T>,
313: 311: {
314: 312:     next_attr_output_type!(Self, NewAttr);
315: 313: 
316: 314:     fn add_any_attr<NewAttr: Attribute>(
317: 315:         self,
318: 316:         new_attr: NewAttr,
319: 317:     ) -> Self::Output<NewAttr> {
320: 318:         next_attr_combine!(self, new_attr)
321: 319:     }
322: 320: }
323: 321: 
324: 322: impl<Key, T, R, W> ToTemplate for Bind<Key, T, R, W>
325: 323: where
326: 324:     Key: AttributeKey,
327: 325:     T: FromEventTarget + AttributeValue + 'static,
328: 326:     R: Get<Value = T> + Clone + 'static,
329: 327:     W: Set<Value = T> + Clone,
330: 328: {
331: 329:     #[inline(always)]
332: 330:     fn to_template(
333: 331:         _buf: &mut String,
334: 332:         _class: &mut String,
335: 333:         _style: &mut String,
336: 334:         _inner_html: &mut String,
337: 335:         _position: &mut Position,
338: 336:     ) {
339: 337:     }
340: 338: }
341: 339: 
342: 340: /// Splits a combined signal into its read and write parts.
343: 341: ///
344: 342: /// This allows you to either provide a `RwSignal` or a tuple `(ReadSignal, WriteSignal)`.
345: 343: pub trait IntoSplitSignal {
346: 344:     /// The actual contained value of the signal
347: 345:     type Value;
348: 346:     /// The read part of the signal
349: 347:     type Read: Get<Value = Self::Value>;
350: 348:     /// The write part of the signal
351: 349:     type Write: Set<Value = Self::Value>;
352: 350:     /// Splits a combined signal into its read and write parts.
353: 351:     fn into_split_signal(self) -> (Self::Read, Self::Write);
354: 352: }
355: 353: 
356: 354: impl<T> IntoSplitSignal for RwSignal<T>
357: 355: where
358: 356:     T: Send + Sync + 'static,
359: 357:     ReadSignal<T>: Get<Value = T>,
360: 358: {
361: 359:     type Value = T;
362: 360:     type Read = ReadSignal<T>;
363: 361:     type Write = WriteSignal<T>;
364: 362: 
365: 363:     fn into_split_signal(self) -> (ReadSignal<T>, WriteSignal<T>) {
366: 364:         self.split()
367: 365:     }
368: 366: }
369: 367: 
370: 368: impl<T, R, W> IntoSplitSignal for (R, W)
371: 369: where
372: 370:     R: Get<Value = T>,
373: 371:     W: Set<Value = T>,
374: 372: {
375: 373:     type Value = T;
376: 374:     type Read = R;
377: 375:     type Write = W;
378: 376: 
379: 377:     fn into_split_signal(self) -> (Self::Read, Self::Write) {
380: 378:         self
381: 379:     }
382: 380: }
383: 381: 
384: 382: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
385: 383: impl<Inner, Prev, T> IntoSplitSignal for Subfield<Inner, Prev, T>
386: 384: where
387: 385:     Self: Get<Value = T> + Set<Value = T> + Clone,
388: 386: {
389: 387:     type Value = T;
390: 388:     type Read = Self;
391: 389:     type Write = Self;
392: 390: 
393: 391:     fn into_split_signal(self) -> (Self::Read, Self::Write) {
394: 392:         (self.clone(), self.clone())
395: 393:     }
396: 394: }
397: 395: 
398: 396: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
399: 397: impl<T, S> IntoSplitSignal for Field<T, S>
400: 398: where
401: 399:     Self: Get<Value = T> + Set<Value = T> + Clone,
402: 400:     S: Storage<ArcField<T>>,
403: 401: {
404: 402:     type Value = T;
405: 403:     type Read = Self;
406: 404:     type Write = Self;
407: 405: 
408: 406:     fn into_split_signal(self) -> (Self::Read, Self::Write) {
409: 407:         (self, self)
410: 408:     }
411: 409: }
412: 410: 
413: 411: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
414: 412: impl<Inner, Prev, K, T> IntoSplitSignal for KeyedSubfield<Inner, Prev, K, T>
415: 413: where
416: 414:     Self: Get<Value = T> + Set<Value = T> + Clone,
417: 415:     for<'a> &'a T: IntoIterator,
418: 416: {
419: 417:     type Value = T;
420: 418:     type Read = Self;
421: 419:     type Write = Self;
422: 420: 
423: 421:     fn into_split_signal(self) -> (Self::Read, Self::Write) {
424: 422:         (self.clone(), self.clone())
425: 423:     }
426: 424: }
427: 425: 
428: 426: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
429: 427: impl<Inner, Prev, K, T> IntoSplitSignal for AtKeyed<Inner, Prev, K, T>
430: 428: where
431: 429:     Self: Get<Value = T> + Set<Value = T> + Clone,
432: 430:     for<'a> &'a T: IntoIterator,
433: 431: {
434: 432:     type Value = T;
435: 433:     type Read = Self;
436: 434:     type Write = Self;
437: 435: 
438: 436:     fn into_split_signal(self) -> (Self::Read, Self::Write) {
439: 437:         (self.clone(), self.clone())
440: 438:     }
441: 439: }
442: 440: 
443: 441: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
444: 442: impl<Inner, Prev> IntoSplitSignal for AtIndex<Inner, Prev>
445: 443: where
446: 444:     Prev: Send + Sync + IndexMut<usize> + 'static,
447: 445:     Inner: Send + Sync + Clone + 'static,
448: 446:     Self: Get<Value = Prev::Output> + Set<Value = Prev::Output> + Clone,
449: 447:     Prev::Output: Sized,
450: 448: {
451: 449:     type Value = Prev::Output;
452: 450:     type Read = Self;
453: 451:     type Write = Self;
454: 452: 
455: 453:     fn into_split_signal(self) -> (Self::Read, Self::Write) {
456: 454:         (self.clone(), self.clone())
457: 455:     }
458: 456: }
459: 457: 
460: 458: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_stores")]
461: 459: impl<S> IntoSplitSignal for DerefedField<S>
462: 460: where
463: 461:     Self: Get<Value = <S::Value as Deref>::Target>
464: 462:         + Set<Value = <S::Value as Deref>::Target>
465: 463:         + Clone,
466: 464:     S: Clone + StoreField + Send + Sync + 'static,
467: 465:     <S as StoreField>::Value: Deref + DerefMut,
468: 466:     <S::Value as Deref>::Target: Sized,
469: 467: {
470: 468:     type Value = <S::Value as Deref>::Target;
471: 469:     type Read = Self;
472: 470:     type Write = Self;
473: 471: 
474: 472:     fn into_split_signal(self) -> (Self::Read, Self::Write) {
475: 473:         (self.clone(), self.clone())
476: 474:     }
477: 475: }
478: 476: 
479: 477: /// Returns self from an event target.
480: 478: pub trait FromEventTarget {
481: 479:     /// Returns self from an event target.
482: 480:     fn from_event_target(evt: &web_sys::Event) -> Self;
483: 481: }
484: 482: 
485: 483: impl FromEventTarget for bool {
486: 484:     fn from_event_target(evt: &web_sys::Event) -> Self {
487: 485:         event_target_checked(evt)
488: 486:     }
489: 487: }
490: 488: 
491: 489: impl FromEventTarget for String {
492: 490:     fn from_event_target(evt: &web_sys::Event) -> Self {
493: 491:         event_target_value(evt)
494: 492:     }
495: 493: }
496: 494: 
497: 495: /// Attaches the lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate change event listener to the element.
498: 496: /// - `<input>` with text types and `<textarea>` elements use the `input` event;
499: 497: /// - `<input type="checkbox">`, `<input type="radio">` and `<select>` use the `change` event;
500: 498: pub trait ChangeEvent {
501: 499:     /// Attaches the lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate change event listener to the element.
502: 500:     fn attach_change_event<T, W>(
503: 501:         &self,
504: 502:         key: &str,
505: 503:         write_signal: W,
506: 504:     ) -> RemoveEventHandler<Self>
507: 505:     where
508: 506:         T: FromEventTarget + AttributeValue + 'static,
509: 507:         W: Set<Value = T> + 'static,
510: 508:         Self: Sized;
511: 509: }
512: 510: 
513: 511: impl ChangeEvent for web_sys::Element {
514: 512:     fn attach_change_event<T, W>(
515: 513:         &self,
516: 514:         key: &str,
517: 515:         write_signal: W,
518: 516:     ) -> RemoveEventHandler<Self>
519: 517:     where
520: 518:         T: FromEventTarget + AttributeValue + 'static,
521: 519:         W: Set<Value = T> + 'static,
522: 520:     {
523: 521:         if key == "group" {
524: 522:             let handler = move |evt| {
525: 523:                 let checked = event_target_checked(&evt);
526: 524:                 if checked {
527: 525:                     write_signal.try_set(T::from_event_target(&evt));
528: 526:                 }
529: 527:             };
530: 528: 
531: 529:             on::<_, _>(change, handler).attach(self)
532: 530:         } else {
533: 531:             let handler = move |evt| {
534: 532:                 write_signal.try_set(T::from_event_target(&evt));
535: 533:             };
536: 534: 
537: 535:             if key == "checked" || self.tag_name() == "SELECT" {
538: 536:                 on::<_, _>(change, handler).attach(self)
539: 537:             } else {
540: 538:                 on::<_, _>(input, handler).attach(self)
541: 539:             }
542: 540:         }
543: 541:     }
544: 542: }
545: 543: 
546: 544: /// Get the value attribute of an element (input).
547: 545: /// Reads `value` if `T` is `String` and `checked` if `T` is `bool`.
548: 546: pub trait GetValue<T> {
549: 547:     /// Get the value attribute of an element (input).
550: 548:     fn get_value(&self) -> T;
551: 549: }
552: 550: 
553: 551: impl GetValue<String> for web_sys::Element {
554: 552:     fn get_value(&self) -> String {
555: 553:         self.get_attribute("value").unwrap_or_default()
556: 554:     }
557: 555: }
558: 556: 
559: 557: impl GetValue<bool> for web_sys::Element {
560: 558:     fn get_value(&self) -> bool {
561: 559:         self.get_attribute("checked").unwrap_or_default() == "true"
562: 560:     }
563: 561: }
564: 562: 
565: 563: #[derive(Debug, Clone, PartialEq, Eq, Hash)]
566: 564: /// Bool or a type. Needed to make the `group` attribute work. It is decided at runtime
567: 565: /// if the derived signal value is a bool or a type `T`.
568: 566: pub enum BoolOrT<T> {
569: 567:     /// We have definitely a boolean value for the `group` attribute
570: 568:     Bool(bool),
571: 569:     /// Standard case with some type `T`
572: 570:     T(T),
573: 571: }
574: 572: 
575: 573: impl<T> IntoProperty for BoolOrT<T>
576: 574: where
577: 575:     T: IntoProperty<State = (Element, JsValue)>
578: 576:         + Into<JsValue>
579: 577:         + Clone
580: 578:         + 'static,
581: 579: {
582: 580:     type State = (Element, JsValue);
583: 581:     type Cloneable = Self;
584: 582:     type CloneableOwned = Self;
585: 583: 
586: 584:     fn hydrate<const FROM_SERVER: bool>(
587: 585:         self,
588: 586:         el: &Element,
589: 587:         key: &str,
590: 588:     ) -> Self::State {
591: 589:         match self.clone() {
592: 590:             Self::T(s) => {
593: 591:                 s.hydrate::<FROM_SERVER>(el, key);
594: 592:             }
595: 593:             Self::Bool(b) => {
596: 594:                 <bool as IntoProperty>::hydrate::<FROM_SERVER>(b, el, key);
597: 595:             }
598: 596:         };
599: 597: 
600: 598:         (el.clone(), self.into())
601: 599:     }
602: 600: 
603: 601:     fn build(self, el: &Element, key: &str) -> Self::State {
604: 602:         match self.clone() {
605: 603:             Self::T(s) => {
606: 604:                 s.build(el, key);
607: 605:             }
608: 606:             Self::Bool(b) => {
609: 607:                 <bool as IntoProperty>::build(b, el, key);
610: 608:             }
611: 609:         }
612: 610: 
613: 611:         (el.clone(), self.into())
614: 612:     }
615: 613: 
616: 614:     fn rebuild(self, state: &mut Self::State, key: &str) {
617: 615:         let (el, prev) = state;
618: 616: 
619: 617:         match self {
620: 618:             Self::T(s) => s.rebuild(&mut (el.clone(), prev.clone()), key),
621: 619:             Self::Bool(b) => <bool as IntoProperty>::rebuild(
622: 620:                 b,
623: 621:                 &mut (el.clone(), prev.clone()),
624: 622:                 key,
625: 623:             ),
626: 624:         }
627: 625:     }
628: 626: 
629: 627:     fn into_cloneable(self) -> Self::Cloneable {
630: 628:         self
631: 629:     }
632: 630: 
633: 631:     fn into_cloneable_owned(self) -> Self::CloneableOwned {
634: 632:         self
635: 633:     }
636: 634: }
637: 635: 
638: 636: impl<T> From<BoolOrT<T>> for JsValue
639: 637: where
640: 638:     T: Into<JsValue>,
641: 639: {
642: 640:     fn from(value: BoolOrT<T>) -> Self {
643: 641:         match value {
644: 642:             BoolOrT::Bool(b) => b.into(),
645: 643:             BoolOrT::T(t) => t.into(),
646: 644:         }
647: 645:     }
648: 646: }
649: 647: ```
650: 648: ```
651: 649: ```
652: 650: ```
653: 651: ```
654: 652: ```
655: 653: ```
656: 654: ```
657: ```
```
