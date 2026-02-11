### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\meta\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\meta\src\lib.rs
2: ```rust
3: 1: #![deny(missing_docs)]
4: 2: #![forbid(unsafe_code)]
5: 3: 
6: 4: //! # Leptos Meta
7: 5: //!
8: 6: //! Leptos Meta allows you to modify content in a document’s `<head>` from within components
9: 7: //! using the [`Leptos`](https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos) web framework.
10: 8: //!
11: 9: //! Document metadata is updated automatically when running in the browser. For lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side
12: 10: //! rendering, after the component tree is rendered to HTML, [`ServerMetaContextOutput::inject_meta_context`] will inject meta tags into a stream of HTML inside the `<head>`.
13: 11: //!
14: 12: //! ```
15: 13: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
16: 14: //! use lyx-core-lyx_core_lyx-core-meta::*;
17: 15: //!
18: 16: //! #[component]
19: 17: //! fn MyApp() -> impl IntoView {
20: 18: //!     // Provides a [`MetaContext`], if there is not already one provided.
21: 19: //!     provide_meta_context();
22: 20: //!
23: 21: //!     let (name, set_name) = create_signal("Alice".to_string());
24: 22: //!
25: 23: //!     view! {
26: 24: //!       <Title
27: 25: //!         // reactively sets document.title when `name` changes
28: 26: //!         text=move || name.get()
29: 27: //!         // lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies the `formatter` function to the `text` value
30: 28: //!         formatter=|text| format!("“{text}” is your name")
31: 29: //!       />
32: 30: //!       <main>
33: 31: //!         <input
34: 32: //!           prop:value=move || name.get()
35: 33: //!           on:input=move |ev| set_name.set(event_target_value(&ev))
36: 34: //!         />
37: 35: //!       </main>
38: 36: //!     }
39: 37: //! }
40: 38: //! ```
41: 39: //! # Feature Flags
42: 40: //! - `ssr` Server-side rendering: Generate an HTML string (typically on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server)
43: 41: //! - `tracing` Adds integration with the `tracing` crate.
44: 42: //!
45: 43: //! **Important Note:** If you’re using lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendering, you should enable `ssr`.
46: 44: 
47: 45: use futures::{Stream, StreamExt};
48: 46: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
49: 47:     attr::{any_attribute::AnyAttribute, NextAttribute},
50: 48:     component,
51: 49:     logging::debug_warn,
52: 50:     oco::Oco,
53: 51:     reactive::owner::{provide_context, use_context},
54: 52:     lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
55: 53:         dom::document,
56: 54:         html::{
57: 55:             attribute::Attribute,
58: 56:             element::{ElementType, HtmlElement},
59: 57:         },
60: 58:         hydration::Cursor,
61: 59:         view::{
62: 60:             add_attr::AddAnyAttr, Mountable, Position, PositionState, Render,
63: 61:             RenderHtml,
64: 62:         },
65: 63:     },
66: 64:     IntoView,
67: 65: };
68: 66: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
69: 67: use std::{
70: 68:     fmt::Debug,
71: 69:     sync::{
72: 70:         mpsc::{channel, Receiver, Sender},
73: 71:         Arc, LazyLock,
74: 72:     },
75: 73: };
76: 74: use wasm_bindgen::JsCast;
77: 75: use web_sys::HtmlHeadElement;
78: 76: 
79: 77: mod body;
80: 78: mod html;
81: 79: mod link;
82: 80: mod meta_tags;
83: 81: mod script;
84: 82: mod style;
85: 83: mod stylesheet;
86: 84: mod title;
87: 85: pub use body::*;
88: 86: pub use html::*;
89: 87: pub use link::*;
90: 88: pub use meta_tags::*;
91: 89: pub use script::*;
92: 90: pub use style::*;
93: 91: pub use stylesheet::*;
94: 92: pub use title::*;
95: 93: 
96: 94: /// Contains the current state of meta tags. To access it, you can use [`use_head`].
97: 95: ///
98: 96: /// This should generally by provided somewhere in the root of your lyx-platform-lyx_platform_lyx-platform-lyx_platform_application using
99: 97: /// [`provide_meta_context`].
100: 98: #[derive(Clone, Debug)]
101: 99: pub struct MetaContext {
102: 100:     /// Metadata associated with the `<title>` element.
103: 101:     pub(crate) title: TitleContext,
104: 102:     /// The hydration cursor for the location in the `<head>` for arbitrary tags will be rendered.
105: 103:     pub(crate) cursor: Arc<LazyLock<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Cursor>>>,
106: 104: }
107: 105: 
108: 106: impl MetaContext {
109: 107:     /// Creates an empty [`MetaContext`].
110: 108:     pub fn new() -> Self {
111: 109:         Default::default()
112: 110:     }
113: 111: }
114: 112: 
115: 113: pub(crate) const HEAD_MARKER_COMMENT: &str = "HEAD";
116: 114: /// Return value of [`Node::node_type`] for a comment.
117: 115: /// https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeType#node.comment_node
118: 116: const COMMENT_NODE: u16 = 8;
119: 117: 
120: 118: impl Default for MetaContext {
121: 119:     fn default() -> Self {
122: 120:         let build_cursor: fn() -> SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<Cursor> = || {
123: 121:             let head = document().head().expect("missing <head> element");
124: 122:             let mut cursor = None;
125: 123:             let mut child = head.first_child();
126: 124:             while let Some(this_child) = child {
127: 125:                 if this_child.node_type() == COMMENT_NODE
128: 126:                     && this_child.text_content().as_deref()
129: 127:                         == Some(HEAD_MARKER_COMMENT)
130: 128:                 {
131: 129:                     cursor = Some(this_child);
132: 130:                     break;
133: 131:                 }
134: 132:                 child = this_child.next_sibling();
135: 133:             }
136: 134:             SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(Cursor::new(
137: 135:                 cursor
138: 136:                     .expect(
139: 137:                         "no lyx-core-lyx_core_lyx-core-meta HEAD marker comment found. Did you \
140: 138:                          include the <MetaTags/> component in the <head> of \
141: 139:                          your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-rendered lyx-platform-lyx_platform_lyx-platform-lyx_platform_app?",
142: 140:                     )
143: 141:                     .unchecked_into(),
144: 142:             ))
145: 143:         };
146: 144: 
147: 145:         let cursor = Arc::new(LazyLock::new(build_cursor));
148: 146:         Self {
149: 147:             title: Default::default(),
150: 148:             cursor,
151: 149:         }
152: 150:     }
153: 151: }
154: 152: 
155: 153: /// Allows you to add `<head>` content from components located in the `<body>` of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application,
156: 154: /// which can be accessed during lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendering via [`ServerMetaContextOutput`].
157: 155: ///
158: 156: /// This should be provided as context during lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendering.
159: 157: ///
160: 158: /// No content added after the first chunk of the stream has been sent will be included in the
161: 159: /// initial `<head>`. Data that needs to be included in the `<head>` during SSR should be
162: 160: /// synchronous or loaded as a blocking resource.
163: 161: #[derive(Clone, Debug)]
164: 162: pub struct ServerMetaContext {
165: 163:     /// Metadata associated with the `<title>` element.
166: 164:     pub(crate) title: TitleContext,
167: 165:     /// Attributes for the `<html>` element.
168: 166:     pub(crate) html: Sender<String>,
169: 167:     /// Attributes for the `<body>` element.
170: 168:     pub(crate) body: Sender<String>,
171: 169:     /// Arbitrary elements to be added to the `<head>` as HTML.
172: 170:     #[allow(unused)] // used in SSR
173: 171:     pub(crate) elements: Sender<String>,
174: 172: }
175: 173: 
176: 174: /// Allows you to access `<head>` content that was inserted via [`ServerMetaContext`].
177: 175: #[must_use = "If you do not use the output, adding meta tags will have no \
178: 176:               effect."]
179: 177: #[derive(Debug)]
180: 178: pub struct ServerMetaContextOutput {
181: 179:     pub(crate) title: TitleContext,
182: 180:     html: Receiver<String>,
183: 181:     body: Receiver<String>,
184: 182:     elements: Receiver<String>,
185: 183: }
186: 184: 
187: 185: impl ServerMetaContext {
188: 186:     /// Creates an empty [`ServerMetaContext`].
189: 187:     pub fn new() -> (ServerMetaContext, ServerMetaContextOutput) {
190: 188:         let title = TitleContext::default();
191: 189:         let (html_tx, html_rx) = channel();
192: 190:         let (body_tx, body_rx) = channel();
193: 191:         let (elements_tx, elements_rx) = channel();
194: 192:         let tx = ServerMetaContext {
195: 193:             title: title.clone(),
196: 194:             html: html_tx,
197: 195:             body: body_tx,
198: 196:             elements: elements_tx,
199: 197:         };
200: 198:         let rx = ServerMetaContextOutput {
201: 199:             title,
202: 200:             html: html_rx,
203: 201:             body: body_rx,
204: 202:             elements: elements_rx,
205: 203:         };
206: 204:         (tx, rx)
207: 205:     }
208: 206: }
209: 207: 
210: 208: impl ServerMetaContextOutput {
211: 209:     /// Consumes the metadata, injecting it into the the first chunk of an HTML stream in the
212: 210:     /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate place.
213: 211:     ///
214: 212:     /// This means that only meta tags rendered during the first chunk of the stream will be
215: 213:     /// included.
216: 214:     pub async fn inject_meta_context(
217: 215:         self,
218: 216:         mut stream: impl Stream<Item = String> + Send + Unpin,
219: 217:     ) -> impl Stream<Item = String> + Send {
220: 218:         // if the first chunk consists of a synchronously-available Suspend,
221: 219:         // inject_meta_context can accidentally run a tick before it, but the Suspend
222: 220:         // when both are available. waiting a tick before awaiting the first chunk
223: 221:         // in the Stream ensures that this always runs after that first chunk
224: 222:         // see https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos/issues/3976 for the original issue
225: 223:         lyx-core-lyx_core_lyx-core-lyx_core_leptos::task::tick().await;
226: 224: 
227: 225:         // wait for the first chunk of the stream, to ensure our components hve run
228: 226:         let mut first_chunk = stream.next().await.unwrap_or_default();
229: 227: 
230: 228:         // create <title> tag
231: 229:         let title = self.title.as_string();
232: 230:         let title_len = title
233: 231:             .as_ref()
234: 232:             .map(|n| "<title>".len() + n.len() + "</title>".len())
235: 233:             .unwrap_or(0);
236: 234: 
237: 235:         // collect all registered meta tags
238: 236:         let meta_buf = self.elements.try_iter().collect::<String>();
239: 237: 
240: 238:         // get HTML strings for `<html>` and `<body>`
241: 239:         let html_attrs = self.html.try_iter().collect::<String>();
242: 240:         let body_attrs = self.body.try_iter().collect::<String>();
243: 241: 
244: 242:         let mut modified_chunk = if title_len == 0 && meta_buf.is_empty() {
245: 243:             first_chunk
246: 244:         } else {
247: 245:             let mut buf = String::with_capacity(
248: 246:                 first_chunk.len() + title_len + meta_buf.len(),
249: 247:             );
250: 248:             let head_loc = first_chunk
251: 249:                 .find("</head>")
252: 250:                 .expect("you are using lyx-core-lyx_core_lyx-core-meta without a </head> tag");
253: 251:             let marker_loc = first_chunk
254: 252:                 .find("<!--HEAD-->")
255: 253:                 .map(|pos| pos + "<!--HEAD-->".len())
256: 254:                 .unwrap_or_else(|| {
257: 255:                     first_chunk.find("</head>").unwrap_or(head_loc)
258: 256:                 });
259: 257:             let (before_marker, after_marker) =
260: 258:                 first_chunk.split_at_mut(marker_loc);
261: 259:             buf.push_str(before_marker);
262: 260:             buf.push_str(&meta_buf);
263: 261:             if let Some(title) = title {
264: 262:                 buf.push_str("<title>");
265: 263:                 buf.push_str(&title);
266: 264:                 buf.push_str("</title>");
267: 265:             }
268: 266:             buf.push_str(after_marker);
269: 267:             buf
270: 268:         };
271: 269: 
272: 270:         if !html_attrs.is_empty() {
273: 271:             if let Some(index) = modified_chunk.find("<html") {
274: 272:                 // Calculate the position where the new string should be inserted
275: 273:                 let insert_pos = index + "<html".len();
276: 274:                 modified_chunk.insert_str(insert_pos, &html_attrs);
277: 275:             }
278: 276:         }
279: 277: 
280: 278:         if !body_attrs.is_empty() {
281: 279:             if let Some(index) = modified_chunk.find("<body") {
282: 280:                 // Calculate the position where the new string should be inserted
283: 281:                 let insert_pos = index + "<body".len();
284: 282:                 modified_chunk.insert_str(insert_pos, &body_attrs);
285: 283:             }
286: 284:         }
287: 285: 
288: 286:         futures::stream::once(async move { modified_chunk }).chain(stream)
289: 287:     }
290: 288: }
291: 289: 
292: 290: /// Provides a [`MetaContext`], if there is not already one provided. This ensures that you can provide it
293: 291: /// at the highest possible level, without overwriting a [`MetaContext`] that has already been provided
294: 292: /// (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, by a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-rendering integration.)
295: 293: pub fn provide_meta_context() {
296: 294:     if use_context::<MetaContext>().is_none() {
297: 295:         provide_context(MetaContext::new());
298: 296:     }
299: 297: }
300: 298: 
301: 299: /// Returns the current [`MetaContext`].
302: 300: ///
303: 301: /// If there is no [`MetaContext`] in this or any parent scope, this will
304: 302: /// create a new [`MetaContext`] and provide it to the current scope.
305: 303: ///
306: 304: /// Note that this may cause confusing behavior, e.g., if multiple nested routes independently
307: 305: /// call `use_head()` but a single [`MetaContext`] has not been provided at the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application root.
308: 306: /// The best practice is always to call [`provide_meta_context`] early in the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
309: 307: pub fn use_head() -> MetaContext {
310: 308:     match use_context::<MetaContext>() {
311: 309:         None => {
312: 310:             debug_warn!(
313: 311:                 "use_head() is being called without a MetaContext being \
314: 312:                  provided. We'll automatically create and provide one, but if \
315: 313:                  this is being called in a child route it may cause bugs. To \
316: 314:                  be safe, you should provide_meta_context() somewhere in the \
317: 315:                  root of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_app."
318: 316:             );
319: 317:             let meta = MetaContext::new();
320: 318:             provide_context(meta.clone());
321: 319:             meta
322: 320:         }
323: 321:         Some(ctx) => ctx,
324: 322:     }
325: 323: }
326: 324: 
327: 325: pub(crate) fn register<E, At, Ch>(
328: 326:     el: HtmlElement<E, At, Ch>,
329: 327: ) -> RegisteredMetaTag<E, At, Ch>
330: 328: where
331: 329:     HtmlElement<E, At, Ch>: RenderHtml,
332: 330: {
333: 331:     RegisteredMetaTag { el }
334: 332: }
335: 333: 
336: 334: struct RegisteredMetaTag<E, At, Ch> {
337: 335:     // this is `None` if we've already taken it out to render to HTML on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
338: 336:     // we don't render it in place in RenderHtml, so it's fine
339: 337:     el: HtmlElement<E, At, Ch>,
340: 338: }
341: 339: 
342: 340: struct RegisteredMetaTagState<E, At, Ch>
343: 341: where
344: 342:     HtmlElement<E, At, Ch>: Render,
345: 343: {
346: 344:     state: <HtmlElement<E, At, Ch> as Render>::State,
347: 345: }
348: 346: 
349: 347: impl<E, At, Ch> Drop for RegisteredMetaTagState<E, At, Ch>
350: 348: where
351: 349:     HtmlElement<E, At, Ch>: Render,
352: 350: {
353: 351:     fn drop(&mut self) {
354: 352:         self.state.unmount();
355: 353:     }
356: 354: }
357: 355: 
358: 356: fn document_head() -> HtmlHeadElement {
359: 357:     let document = document();
360: 358:     document.head().unwrap_or_else(|| {
361: 359:         let el = document.create_element("head").unwrap();
362: 360:         let document = document.document_element().unwrap();
363: 361:         _ = document.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_child(&el);
364: 362:         el.unchecked_into()
365: 363:     })
366: 364: }
367: 365: 
368: 366: impl<E, At, Ch> Render for RegisteredMetaTag<E, At, Ch>
369: 367: where
370: 368:     E: ElementType,
371: 369:     At: Attribute,
372: 370:     Ch: Render,
373: 371: {
374: 372:     type State = RegisteredMetaTagState<E, At, Ch>;
375: 373: 
376: 374:     fn build(self) -> Self::State {
377: 375:         let state = self.el.build();
378: 376:         RegisteredMetaTagState { state }
379: 377:     }
380: 378: 
381: 379:     fn rebuild(self, state: &mut Self::State) {
382: 380:         self.el.rebuild(&mut state.state);
383: 381:     }
384: 382: }
385: 383: 
386: 384: impl<E, At, Ch> AddAnyAttr for RegisteredMetaTag<E, At, Ch>
387: 385: where
388: 386:     E: ElementType + Send,
389: 387:     At: Attribute + Send,
390: 388:     Ch: RenderHtml + Send,
391: 389: {
392: 390:     type Output<SomeNewAttr: Attribute> =
393: 391:         RegisteredMetaTag<E, <At as NextAttribute>::Output<SomeNewAttr>, Ch>;
394: 392: 
395: 393:     fn add_any_attr<NewAttr: Attribute>(
396: 394:         self,
397: 395:         attr: NewAttr,
398: 396:     ) -> Self::Output<NewAttr>
399: 397:     where
400: 398:         Self::Output<NewAttr>: RenderHtml,
401: 399:     {
402: 400:         RegisteredMetaTag {
403: 401:             el: self.el.add_any_attr(attr),
404: 402:         }
405: 403:     }
406: 404: }
407: 405: 
408: 406: impl<E, At, Ch> RenderHtml for RegisteredMetaTag<E, At, Ch>
409: 407: where
410: 408:     E: ElementType,
411: 409:     At: Attribute,
412: 410:     Ch: RenderHtml + Send,
413: 411: {
414: 412:     type AsyncOutput = Self;
415: 413:     type Owned = RegisteredMetaTag<E, At::CloneableOwned, Ch::Owned>;
416: 414: 
417: 415:     const MIN_LENGTH: usize = 0;
418: 416:     const EXISTS: bool = false;
419: 417: 
420: 418:     fn dry_resolve(&mut self) {
421: 419:         self.el.dry_resolve()
422: 420:     }
423: 421: 
424: 422:     async fn resolve(self) -> Self::AsyncOutput {
425: 423:         self // TODO?
426: 424:     }
427: 425: 
428: 426:     fn to_html_with_buf(
429: 427:         self,
430: 428:         _buf: &mut String,
431: 429:         _position: &mut Position,
432: 430:         _escape: bool,
433: 431:         _mark_branches: bool,
434: 432:         _extra_attrs: Vec<AnyAttribute>,
435: 433:     ) {
436: 434:         // meta tags are rendered into the buffer stored into the context
437: 435:         // the value has already been taken out, when we're on the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server
438: 436:         #[cfg(feature = "ssr")]
439: 437:         if let Some(cx) = use_context::<ServerMetaContext>() {
440: 438:             let mut buf = String::new();
441: 439:             self.el.to_html_with_buf(
442: 440:                 &mut buf,
443: 441:                 &mut Position::NextChild,
444: 442:                 false,
445: 443:                 false,
446: 444:                 vec![],
447: 445:             );
448: 446:             _ = cx.elements.send(buf); // fails only if the receiver is already dropped
449: 447:         } else {
450: 448:             let msg = "tried to use a lyx-core-lyx_core_lyx-core-meta component without \
451: 449:                        `ServerMetaContext` provided";
452: 450: 
453: 451:             #[cfg(feature = "tracing")]
454: 452:             tracing::warn!("{}", msg);
455: 453: 
456: 454:             #[cfg(not(feature = "tracing"))]
457: 455:             eprintln!("{msg}");
458: 456:         }
459: 457:     }
460: 458: 
461: 459:     fn hydrate<const FROM_SERVER: bool>(
462: 460:         self,
463: 461:         _cursor: &Cursor,
464: 462:         _position: &PositionState,
465: 463:     ) -> Self::State {
466: 464:         let cursor = use_context::<MetaContext>()
467: 465:             .expect(
468: 466:                 "attempting to hydrate `lyx-core-lyx_core_lyx-core-meta` components without a \
469: 467:                  MetaContext provided",
470: 468:             )
471: 469:             .cursor;
472: 470:         let state = self.el.hydrate::<FROM_SERVER>(
473: 471:             &cursor,
474: 472:             &PositionState::new(Position::NextChild),
475: 473:         );
476: 474:         RegisteredMetaTagState { state }
477: 475:     }
478: 476: 
479: 477:     fn into_owned(self) -> Self::Owned {
480: 478:         RegisteredMetaTag {
481: 479:             el: self.el.into_owned(),
482: 480:         }
483: 481:     }
484: 482: }
485: 483: 
486: 484: impl<E, At, Ch> Mountable for RegisteredMetaTagState<E, At, Ch>
487: 485: where
488: 486:     E: ElementType,
489: 487:     At: Attribute,
490: 488:     Ch: Render,
491: 489: {
492: 490:     fn unmount(&mut self) {
493: 491:         self.state.unmount();
494: 492:     }
495: 493: 
496: 494:     fn mount(
497: 495:         &mut self,
498: 496:         _parent: &lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element,
499: 497:         _marker: Option<&lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Node>,
500: 498:     ) {
501: 499:         // we always mount this to the <head>, which is the whole point
502: 500:         // but this shouldn't warn about the parent being a regular element or being unused
503: 501:         // because it will call "mount" with the parent where it is located in the component tree,
504: 502:         // but actually be mounted to the <head>
505: 503:         self.state.mount(&document_head(), None);
506: 504:     }
507: 505: 
508: 506:     fn insert_before_this(&self, _child: &mut dyn Mountable) -> bool {
509: 507:         // Registered meta tags will be mounted in the <head>, but *seem* to be mounted somewhere
510: 508:         // else in the DOM. We should never tell the renderer that we have successfully mounted
511: 509:         // something before this, because if e.g., a <Meta/> is the first item in an Either, then
512: 510:         // the alternate view will end up being mounted in the <head> -- which is not at all what
513: 511:         // we intended!
514: 512:         false
515: 513:     }
516: 514: 
517: 515:     fn elements(&self) -> Vec<lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_tachys::renderer::types::Element> {
518: 516:         self.state.elements()
519: 517:     }
520: 518: }
521: 519: 
522: 520: /// During lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendering, inserts the meta tags that have been generated by the other components
523: 521: /// in this crate into the DOM. This should be placed somewhere inside the `<head>` element that is
524: 522: /// being used during lyx-platform-lyx_platform_lyx-platform-lyx_platform_server rendering.
525: 523: #[component]
526: 524: pub fn MetaTags() -> impl IntoView {
527: 525:     MetaTagsView
528: 526: }
529: 527: 
530: 528: #[derive(Debug)]
531: 529: struct MetaTagsView;
532: 530: 
533: 531: // this implementation doesn't do anything during lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering, it's just for lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side
534: 532: // rendering HTML for all the tags that will be injected into the `<head>`
535: 533: //
536: 534: // lyx-core-lyx_core_lyx-core-lyx_core_client-side rendering is handled by the individual components
537: 535: impl Render for MetaTagsView {
538: 536:     type State = ();
539: 537: 
540: 538:     fn build(self) -> Self::State {}
541: 539: 
542: 540:     fn rebuild(self, _state: &mut Self::State) {}
543: 541: }
544: 542: 
545: 543: impl AddAnyAttr for MetaTagsView {
546: 544:     type Output<SomeNewAttr: Attribute> = MetaTagsView;
547: 545: 
548: 546:     fn add_any_attr<NewAttr: Attribute>(
549: 547:         self,
550: 548:         _attr: NewAttr,
551: 549:     ) -> Self::Output<NewAttr>
552: 550:     where
553: 551:         Self::Output<NewAttr>: RenderHtml,
554: 552:     {
555: 553:         self
556: 554:     }
557: 555: }
558: 556: 
559: 557: impl RenderHtml for MetaTagsView {
560: 558:     type AsyncOutput = Self;
561: 559:     type Owned = Self;
562: 560: 
563: 561:     const MIN_LENGTH: usize = 0;
564: 562: 
565: 563:     fn dry_resolve(&mut self) {}
566: 564: 
567: 565:     async fn resolve(self) -> Self::AsyncOutput {
568: 566:         self
569: 567:     }
570: 568: 
571: 569:     fn to_html_with_buf(
572: 570:         self,
573: 571:         buf: &mut String,
574: 572:         _position: &mut Position,
575: 573:         _escape: bool,
576: 574:         _mark_branches: bool,
577: 575:         _extra_attrs: Vec<AnyAttribute>,
578: 576:     ) {
579: 577:         buf.push_str("<!--HEAD-->");
580: 578:     }
581: 579: 
582: 580:     fn hydrate<const FROM_SERVER: bool>(
583: 581:         self,
584: 582:         _cursor: &Cursor,
585: 583:         _position: &PositionState,
586: 584:     ) -> Self::State {
587: 585:     }
588: 586: 
589: 587:     fn into_owned(self) -> Self::Owned {
590: 588:         self
591: 589:     }
592: 590: }
593: 591: 
594: 592: pub(crate) trait OrDefaultNonce {
595: 593:     fn or_default_nonce(self) -> Option<Oco<'static, str>>;
596: 594: }
597: 595: 
598: 596: impl OrDefaultNonce for Option<Oco<'static, str>> {
599: 597:     fn or_default_nonce(self) -> Option<Oco<'static, str>> {
600: 598:         #[cfg(feature = "nonce")]
601: 599:         {
602: 600:             use lyx-core-lyx_core_lyx-core-lyx_core_leptos::nonce::use_nonce;
603: 601: 
604: 602:             match self {
605: 603:                 Some(nonce) => Some(nonce),
606: 604:                 None => use_nonce().map(|n| Arc::clone(n.as_inner()).into()),
607: 605:             }
608: 606:         }
609: 607:         #[cfg(not(feature = "nonce"))]
610: 608:         {
611: 609:             self
612: 610:         }
613: 611:     }
614: 612: }
615: ```
```
