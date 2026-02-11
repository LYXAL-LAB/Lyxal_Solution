### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\element\elements.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\elements.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::{
21: 19:         attribute::{Attr, Attribute, AttributeValue, NextAttribute},
22: 20:         element::{ElementType, ElementWithChildren, HtmlElement},
23: 21:     },
24: 22:     view::Render,
25: 23: };
26: 24: use std::fmt::Debug;
27: 25: 
28: 26: macro_rules! html_element_inner {
29: 27:     (
30: 28:         #[$meta:meta]
31: 29:         $tag:ident
32: 30:         $struct_name:ident
33: 31:         $ty:ident
34: 32:         [$($attr:ty),*]
35: 33:         $escape:literal
36: 34:     ) => {
37: 35:         paste::paste! {
38: 36:             #[$meta]
39: 37:             #[track_caller]
40: 38:             pub fn $tag() -> HtmlElement<$struct_name, (), ()>
41: 39:             where
42: 40: 
43: 41:             {
44: 42:                 HtmlElement {
45: 43:                     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
46: 44:                     defined_at: std::panic::Location::caller(),
47: 45:                     tag: $struct_name,
48: 46:                     attributes: (),
49: 47:                     children: (),
50: 48:                 }
51: 49:             }
52: 50: 
53: 51:             #[$meta]
54: 52:             #[derive(Debug, Copy, Clone, PartialEq, Eq)]
55: 53:             pub struct $struct_name;
56: 54: 
57: 55:             // Typed attribute methods
58: 56:             impl<At, Ch> HtmlElement<$struct_name, At, Ch>
59: 57:             where
60: 58:                 At: Attribute,
61: 59:                 Ch: Render,
62: 60: 
63: 61:             {
64: 62:                 $(
65: 63:                     #[doc = concat!("The [`", stringify!($attr), "`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/", stringify!($tag), "#", stringify!($attr) ,") attribute on `<", stringify!($tag), ">`.")]
66: 64:                     pub fn $attr<V>(self, value: V) -> HtmlElement <
67: 65:                         $struct_name,
68: 66:                         <At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>,
69: 67:                         Ch
70: 68:                     >
71: 69:                     where
72: 70:                         V: AttributeValue,
73: 71:                         At: NextAttribute,
74: 72:                         <At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>: Attribute,
75: 73:                     {
76: 74:                         let HtmlElement {
77: 75:                             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
78: 76:                             defined_at,
79: 77:                             tag,
80: 78:                             children,
81: 79:                             attributes
82: 80:                         } = self;
83: 81:                         HtmlElement {
84: 82:                             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
85: 83:                             defined_at,
86: 84:                             tag,
87: 85:                             children,
88: 86:                             attributes: attributes.add_any_attr($crate::html::attribute::$attr(value)),
89: 87:                         }
90: 88:                     }
91: 89:                 )*
92: 90:             }
93: 91: 
94: 92:             impl ElementType for $struct_name {
95: 93:                 type Output = web_sys::$ty;
96: 94: 
97: 95:                 const TAG: &'static str = stringify!($tag);
98: 96:                 const SELF_CLOSING: bool = false;
99: 97:                 const ESCAPE_CHILDREN: bool = $escape;
100: 98:                 const NAMESPACE: Option<&'static str> = None;
101: 99: 
102: 100:                 #[inline(always)]
103: 101:                 fn tag(&self) -> &str {
104: 102:                     Self::TAG
105: 103:                 }
106: 104:             }
107: 105: 
108: 106:             impl ElementWithChildren for $struct_name {}
109: 107:         }
110: 108:     };
111: 109: }
112: 110: 
113: 111: macro_rules! html_elements {
114: 112: 	($(
115: 113:         #[$meta:meta]
116: 114:         $tag:ident
117: 115:         $ty:ident
118: 116:         [$($attr:ty),*]
119: 117:         $escape:literal
120: 118:       ),*
121: 119:       $(,)?
122: 120:     ) => {
123: 121:         paste::paste! {
124: 122:             $(html_element_inner! {
125: 123:                 #[$meta]
126: 124:                 $tag
127: 125:                 [<$tag:camel>]
128: 126:                 $ty
129: 127:                 [$($attr),*]
130: 128:                 $escape
131: 129:             })*
132: 130:         }
133: 131:     }
134: 132: }
135: 133: 
136: 134: macro_rules! html_self_closing_elements {
137: 135: 	($(
138: 136:         #[$meta:meta]
139: 137:         $tag:ident $ty:ident [$($attr:ty),*] $escape:literal
140: 138:       ),*
141: 139:       $(,)?
142: 140:     ) => {
143: 141:         paste::paste! {
144: 142:             $(
145: 143:                 #[$meta]
146: 144:                 #[track_caller]
147: 145:                 pub fn $tag() -> HtmlElement<[<$tag:camel>], (), ()>
148: 146:                 where
149: 147: 
150: 148:                 {
151: 149:                     HtmlElement {
152: 150:                         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
153: 151:                         defined_at: std::panic::Location::caller(),
154: 152:                         attributes: (),
155: 153:                         children: (),
156: 154:                         tag: [<$tag:camel>],
157: 155:                     }
158: 156:                 }
159: 157: 
160: 158:                 #[$meta]
161: 159:                 #[derive(Debug, Copy, Clone, PartialEq, Eq)]
162: 160:                 pub struct [<$tag:camel>];
163: 161: 
164: 162:                 // Typed attribute methods
165: 163:                 impl<At> HtmlElement<[<$tag:camel>], At, ()>
166: 164:                 where
167: 165:                     At: Attribute,
168: 166:                 {
169: 167:                     $(
170: 168:                         #[doc = concat!("The [`", stringify!($attr), "`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/", stringify!($tag), "#", stringify!($attr) ,") attribute on `<", stringify!($tag), ">`.")]
171: 169:                         pub fn $attr<V>(self, value: V) -> HtmlElement<
172: 170:                             [<$tag:camel>],
173: 171:                             <At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>,
174: 172:                             (),
175: 173:                         >
176: 174:                         where
177: 175:                             V: AttributeValue,
178: 176:                             At: NextAttribute,
179: 177:                             <At as NextAttribute>::Output<Attr<$crate::html::attribute::[<$attr:camel>], V>>: Attribute,
180: 178:                         {
181: 179:                             let HtmlElement {
182: 180:                                  #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
183: 181:                                  defined_at,
184: 182:                                 tag,
185: 183:                                 children,
186: 184:                                 attributes,
187: 185:                             } = self;
188: 186:                             HtmlElement {
189: 187:                                 #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
190: 188:                                 defined_at,
191: 189:                                 tag,
192: 190:                                 children,
193: 191:                                 attributes: attributes.add_any_attr($crate::html::attribute::$attr(value)),
194: 192:                             }
195: 193:                         }
196: 194:                     )*
197: 195:                 }
198: 196: 
199: 197:                 impl ElementType for [<$tag:camel>] {
200: 198:                     type Output = web_sys::$ty;
201: 199: 
202: 200:                     const TAG: &'static str = stringify!($tag);
203: 201:                     const SELF_CLOSING: bool = true;
204: 202:                     const ESCAPE_CHILDREN: bool = $escape;
205: 203:                     const NAMESPACE: Option<&'static str> = None;
206: 204: 
207: 205:                     #[inline(always)]
208: 206:                     fn tag(&self) -> &str {
209: 207:                         Self::TAG
210: 208:                     }
211: 209:                 }
212: 210:             )*
213: 211: 		}
214: 212:     }
215: 213: }
216: 214: 
217: 215: html_self_closing_elements! {
218: 216:     /// The `<area>` HTML element defines an area inside an image map that has predefined clickable areas. An image map allows geometric areas on an image to be associated with Hyperlink.
219: 217:     area HtmlAreaElement [alt, coords, download, href, hreflang, ping, rel, shape, target] true,
220: 218:     /// The `<base>` HTML element specifies the base URL to use for all relative URLs in a document. There can be only one `<base>` element in a document.
221: 219:     base HtmlBaseElement [href, target] true,
222: 220:     /// The `<br>` HTML element produces a line break in text (carriage-return). It is useful for writing a poem or an address, where the division of lines is significant.
223: 221:     br HtmlBrElement [] true,
224: 222:     /// The `<col>` HTML element defines a column within a table and is used for defining common semantics on all common cells. It is generally found within a colgroup element.
225: 223:     col HtmlTableColElement [span] true,
226: 224:     /// The `<embed>` HTML element embeds external content at the specified point in the document. This content is provided by an external lyx-platform-lyx_platform_lyx-platform-lyx_platform_application or other source of interactive content such as a browser plug-in.
227: 225:     embed HtmlEmbedElement [height, src, r#type, width] true,
228: 226:     /// The `<hr>` HTML element represents a thematic break between paragraph-level elements: for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, a change of scene in a story, or a shift of topic within a section.
229: 227:     hr HtmlHrElement [] true,
230: 228:     /// The `<img>` HTML element embeds an image into the document.
231: 229:     img HtmlImageElement [alt, attributionsrc, crossorigin, decoding, elementtiming, fetchpriority, height, ismap, loading, referrerpolicy, sizes, src, srcset, usemap, width] true,
232: 230:     /// The `<input>` HTML element is used to create interactive controls for web-based forms in order to accept data from the user; a wide variety of types of input data and control widgets are available, depending on the device and user agent. The `<input>` element is one of the most powerful and complex in all of HTML due to the sheer number of combinations of input types and attributes.
233: 231:     input HtmlInputElement [accept, alt, autocomplete, capture, checked, dirname, disabled, form, formaction, formenctype, formmethod, formnovalidate, formtarget, height, list, max, maxlength, min, minlength, multiple, name, pattern, placeholder, popovertarget, popovertargetaction, readonly, required, size, src, step, r#type, value, width] true,
234: 232:     ///	The `<link>` HTML element specifies relationships between the current document and an external resource. This element is most commonly used to link to CSS, but is also used to establish site icons (both "favicon" style icons and icons for the home screen and lyx-platform-lyx_platform_lyx-platform-lyx_platform_apps on mobile devices) among other things.
235: 233:     link HtmlLinkElement [r#as, blocking, crossorigin, fetchpriority, href, hreflang, imagesizes, imagesrcset, integrity, media, rel, referrerpolicy, sizes, r#type] true,
236: 234:     ///	The `<meta>` HTML element represents Metadata that cannot be represented by other HTML meta-related elements, like base, link, script, style or title.
237: 235:     meta HtmlMetaElement [charset, content, http_equiv, name] true,
238: 236:     /// The `<source>` HTML element specifies multiple media resources for the picture, the audio element, or the video element. It is an empty element, meaning that it has no content and does not have a closing tag. It is commonly used to offer the same media content in multiple file formats in order to provide compatibility with a broad range of browsers given their differing support for image file formats and media file formats.
239: 237:     source HtmlSourceElement [src, r#type, srcset, sizes, media, height, width] true,
240: 238:     /// The `<track>` HTML element is used as a child of the media elements, audio and video. It lets you specify timed text tracks (or time-based data), for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example to automatically handle subtitles. The tracks are formatted in WebVTT format (.vtt files) — Web Video Text Tracks.
241: 239:     track HtmlTrackElement [default, kind, label, src, srclang] true,
242: 240:     /// The `<wbr>` HTML element represents a word break opportunity—a position within text where the browser may optionally break a line, though its line-breaking rules would not otherwise create a break at that location.
243: 241:     wbr HtmlElement [] true,
244: 242: }
245: 243: 
246: 244: html_elements! {
247: 245:     /// The `<a>` HTML element (or anchor element), with its href attribute, creates a hyperlink to web pages, files, email addresses, locations in the same page, or anything else a URL can address.
248: 246:     a HtmlAnchorElement [download, href, hreflang, ping, referrerpolicy, rel, target, r#type ] true,
249: 247:     /// The `<abbr>` HTML element represents an abbreviation or acronym; the optional title attribute can provide an expansion or description for the abbreviation. If present, title must contain this full description and nothing else.
250: 248:     abbr HtmlElement [] true,
251: 249:     /// The `<address>` HTML element indicates that the enclosed HTML provides contact information for a person or people, or for an organization.
252: 250:     address HtmlElement [] true,
253: 251:     /// The `<article>` HTML element represents a self-contained composition in a document, page, lyx-platform-lyx_platform_lyx-platform-lyx_platform_application, or site, which is intended to be independently distributable or reusable (e.g., in syndication). Examples include: a forum post, a magazine or newspaper article, or a blog entry, a product card, a user-submitted comment, an interactive widget or gadget, or any other independent item of content.
254: 252:     article HtmlElement [] true,
255: 253:     /// The `<aside>` HTML element represents a portion of a document whose content is only indirectly related to the document's main content. Asides are frequently presented as sidebars or call-out boxes.
256: 254:     aside HtmlElement [] true,
257: 255:     /// The `<audio>` HTML element is used to embed sound content in documents. It may contain one or more audio sources, represented using the src attribute or the source element: the browser will choose the most suitable one. It can also be the destination for streamed media, using a MediaStream.
258: 256:     audio HtmlAudioElement [autoplay, controls, crossorigin, r#loop, muted, preload, src] true,
259: 257:     /// The `<b>` HTML element is used to draw the reader's attention to the element's contents, which are not otherwise granted special importance. This was formerly known as the Boldface element, and most browsers still draw the text in boldface. However, you should not use `<b>` for styling text; instead, you should use the CSS font-weight property to create boldface text, or the strong element to indicate that text is of special importance.
260: 258:     b HtmlElement [] true,
261: 259:     /// The `<bdi>` HTML element tells the browser's bidirectional algorithm to treat the text it contains in isolation from its surrounding text. It's particularly useful when a website dynamically inserts some text and doesn't know the directionality of the text being inserted.
262: 260:     bdi HtmlElement [] true,
263: 261:     /// The `<bdo>` HTML element overrides the current directionality of text, so that the text within is rendered in a different direction.
264: 262:     bdo HtmlElement [] true,
265: 263:     /// The `<blockquote>` HTML element indicates that the enclosed text is an extended quotation. Usually, this is rendered visually by indentation (see Notes for how to change it). A URL for the source of the quotation may be given using the cite attribute, while a text representation of the source can be given using the cite element.
266: 264:     blockquote HtmlQuoteElement [cite] true,
267: 265:     /// The `<body>` HTML element represents the content of an HTML document. There can be only one `<body>` element in a document.
268: 266:     body HtmlBodyElement [] true,
269: 267:     /// The `<button>` HTML element represents a clickable button, used to submit forms or anywhere in a document for accessible, standard button functionality.
270: 268:     button HtmlButtonElement [command, commandfor, disabled, form, formaction, formenctype, formmethod, formnovalidate, formtarget, name, r#type, value, popovertarget, popovertargetaction] true,
271: 269:     /// Use the HTML `<canvas>` element with either the canvas scripting API or the WebGL API to draw graphics and animations.
272: 270:     canvas HtmlCanvasElement [height, width] true,
273: 271:     /// The `<caption>` HTML element specifies the caption (or title) of a table.
274: 272:     caption HtmlTableCaptionElement [] true,
275: 273:     /// The `<cite>` HTML element is used to describe a reference to a cited creative work, and must include the title of that work. The reference may be in an abbreviated form according to context-lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate conventions related to citation metadata.
276: 274:     cite HtmlElement [] true,
277: 275:     /// The `<code>` HTML element displays its contents styled in a fashion intended to indicate that the text is a short fragment of computer code. By default, the content text is displayed using the user agent default monospace font.
278: 276:     code HtmlElement [] true,
279: 277:     /// The `<colgroup>` HTML element defines a group of columns within a table.
280: 278:     colgroup HtmlTableColElement [span] true,
281: 279:     /// The `<data>` HTML element links a given piece of content with a machine-readable translation. If the content is time- or date-related, the time element must be used.
282: 280:     data HtmlDataElement [value] true,
283: 281:     /// The `<datalist>` HTML element contains a set of option elements that represent the permissible or recommended options available to choose from within other controls.
284: 282:     datalist HtmlDataListElement [] true,
285: 283:     /// The `<dd>` HTML element provides the description, definition, or value for the preceding term (dt) in a description list (dl).
286: 284:     dd HtmlElement [] true,
287: 285:     /// The `<del>` HTML element represents a range of text that has been deleted from a document. This can be used when rendering "track changes" or source code diff information, for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example. The ins element can be used for the opposite purpose: to indicate text that has been added to the document.
288: 286:     del HtmlModElement [cite, datetime] true,
289: 287:     /// The `<details>` HTML element creates a disclosure widget in which information is visible only when the widget is toggled into an "open" state. A summary or label must be provided using the summary element.
290: 288:     details HtmlDetailsElement [name, open] true,
291: 289:     /// The `<dfn>` HTML element is used to indicate the term being defined within the context of a definition phrase or sentence. The p element, the dt/dd pairing, or the section element which is the nearest ancestor of the `<dfn>` is considered to be the definition of the term.
292: 290:     dfn HtmlElement [] true,
293: 291:     /// The `<dialog>` HTML element represents a dialog box or other interactive component, such as a dismissible alert, inspector, or subwindow.
294: 292:     dialog HtmlDialogElement [closedby, open] true,
295: 293:     /// The `<div>` HTML element is the generic container for flow content. It has no effect on the content or layout until styled in some way using CSS (e.g. styling is directly lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to it, or some kind of layout model like Flexbox is lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to its parent element).
296: 294:     div HtmlDivElement [] true,
297: 295:     /// The `<dl>` HTML element represents a description list. The element encloses a list of groups of terms (specified using the dt element) and descriptions (provided by dd elements). Common uses for this element are to implement a glossary or to display metadata (a list of key-value pairs).
298: 296:     dl HtmlDListElement [] true,
299: 297:     /// The `<dt>` HTML element specifies a term in a description or definition list, and as such must be used inside a dl element. It is usually followed by a dd element; however, multiple `<dt>` elements in a row indicate several terms that are all defined by the immediate next dd element.
300: 298:     dt HtmlElement [] true,
301: 299:     /// The `<em>` HTML element marks text that has stress emphasis. The `<em>` element can be nested, with each level of nesting indicating a greater degree of emphasis.
302: 300:     em HtmlElement [] true,
303: 301:     /// The `<fieldset>` HTML element is used to group several controls as well as labels (label) within a web form.
304: 302:     fieldset HtmlFieldSetElement [disabled, form, name] true,
305: 303:     /// The `<figcaption>` HTML element represents a caption or legend describing the rest of the contents of its parent figure element.
306: 304:     figcaption HtmlElement [] true,
307: 305:     /// The `<figure>` HTML element represents self-contained content, potentially with an optional caption, which is specified using the figcaption element. The figure, its caption, and its contents are referenced as a single unit.
308: 306:     figure HtmlElement [] true,
309: 307:     /// The `<footer>` HTML element represents a footer for its nearest sectioning content or sectioning root element. A `<footer>` typically contains information about the author of the section, copyright data or links to related documents.
310: 308:     footer HtmlElement [] true,
311: 309:     /// The `<form>` HTML element represents a document section containing interactive controls for submitting information.
312: 310:     form HtmlFormElement [accept_charset, action, autocomplete, enctype, method, name, novalidate, target] true,
313: 311:     /// The `<h1>` to `<h6>` HTML elements represent six levels of section headings. `<h1>` is the highest section level and `<h6>` is the lowest.
314: 312:     h1 HtmlHeadingElement [] true,
315: 313:     /// The `<h1>` to `<h6>` HTML elements represent six levels of section headings. `<h1>` is the highest section level and `<h6>` is the lowest.
316: 314:     h2 HtmlHeadingElement [] true,
317: 315:     /// The `<h1>` to `<h6>` HTML elements represent six levels of section headings. `<h1>` is the highest section level and `<h6>` is the lowest.
318: 316:     h3 HtmlHeadingElement [] true,
319: 317:     /// The `<h1>` to `<h6>` HTML elements represent six levels of section headings. `<h1>` is the highest section level and `<h6>` is the lowest.
320: 318:     h4 HtmlHeadingElement [] true,
321: 319:     /// The `<h1>` to `<h6>` HTML elements represent six levels of section headings. `<h1>` is the highest section level and `<h6>` is the lowest.
322: 320:     h5 HtmlHeadingElement [] true,
323: 321:     /// The `<h1>` to `<h6>` HTML elements represent six levels of section headings. `<h1>` is the highest section level and `<h6>` is the lowest.
324: 322:     h6 HtmlHeadingElement [] true,
325: 323:     ///	The `<head>` HTML element contains machine-readable information (metadata) about the document, like its title, scripts, and style sheets.
326: 324:     head HtmlHeadElement [] true,
327: 325:     /// The `<header>` HTML element represents introductory content, typically a group of introductory or navigational alyx-core-lyx_core_lyx-core-lyx_core_ids. It may contain some heading elements but also a logo, a search form, an author name, and other elements.
328: 326:     header HtmlElement [] true,
329: 327:     /// The `<hgroup>` HTML element represents a heading and related content. It groups a single `<h1>–<h6>` element with one or more `<p>`.
330: 328:     hgroup HtmlElement [] true,
331: 329:     /// The `<html>` HTML element represents the root (top-level element) of an HTML document, so it is also referred to as the root element. All other elements must be descendants of this element.
332: 330:     html HtmlHtmlElement [] true,
333: 331:     /// The `<i>` HTML element represents a range of text that is set off from the normal text for some reason, such as idiomatic text, technical terms, taxonomical designations, among others. Historically, these have been presented using italicized type, which is the original source of the `<i>` naming of this element.
334: 332:     i HtmlElement [] true,
335: 333:     /// The `<iframe>` HTML element represents a nested browsing context, embedding another HTML page into the current one.
336: 334:     iframe HtmlIFrameElement [allow, allowfullscreen, allowpaymentrequest, height, name, referrerpolicy, sandbox, src, srcdoc, width] true,
337: 335:     /// The `<ins>` HTML element represents a range of text that has been added to a document. You can use the del element to similarly represent a range of text that has been deleted from the document.
338: 336:     ins HtmlElement [cite, datetime] true,
339: 337:     /// The `<kbd>` HTML element represents a span of inline text denoting textual user input from a keyboard, voice input, or any other text entry device. By convention, the user agent defaults to rendering the contents of a `<kbd>` element using its default monospace font, although this is not mandated by the HTML standard.
340: 338:     kbd HtmlElement [] true,
341: 339:     /// The `<label>` HTML element represents a caption for an item in a user interface.
342: 340:     label HtmlLabelElement [r#for, form] true,
343: 341:     /// The `<legend>` HTML element represents a caption for the content of its parent fieldset.
344: 342:     legend HtmlLegendElement [] true,
345: 343:     /// The `<li>` HTML element is used to represent an item in a list. It must be contained in a parent element: an ordered list (ol), an unordered list (ul), or a menu (menu). In menus and unordered lists, list items are usually displayed using bullet points. In ordered lists, they are usually displayed with an ascending counter on the left, such as a number or letter.
346: 344:     li HtmlLiElement [value] true,
347: 345:     /// The `<main>` HTML element represents the dominant content of the body of a document. The main content area consists of content that is directly related to or expands upon the central topic of a document, or the central functionality of an lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
348: 346:     main HtmlElement [] true,
349: 347:     /// The `<map>` HTML element is used with area elements to define an image map (a clickable link area).
350: 348:     map HtmlMapElement [name] true,
351: 349:     /// The `<mark>` HTML element represents text which is marked or highlighted for reference or notation purposes, due to the marked passage's relevance or importance in the enclosing context.
352: 350:     mark HtmlElement [] true,
353: 351:     /// The `<menu>` HTML element is a semantic alternative to ul. It represents an unordered list of items (represented by li elements), each of these represent a link or other command that the user can activate.
354: 352:     menu HtmlMenuElement [] true,
355: 353:     /// The `<meter>` HTML element represents either a scalar value within a known range or a fractional value.
356: 354:     meter HtmlMeterElement [value, min, max, low, high, optimum, form] true,
357: 355:     /// The `<nav>` HTML element represents a section of a page whose purpose is to provide navigation links, either within the current document or to other documents. Common lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples of navigation sections are menus, tables of contents, and indexes.
358: 356:     nav HtmlElement [] true,
359: 357:     /// The `<noscript>` HTML element defines a section of HTML to be inserted if a script type on the page is unsupported or if scripting is currently turned off in the browser.
360: 358:     noscript HtmlElement [] false,
361: 359:     /// The `<object>` HTML element represents an external resource, which can be treated as an image, a nested browsing context, or a resource to be handled by a plugin.
362: 360:     object HtmlObjectElement [data, form, height, name, r#type, usemap, width] true,
363: 361:     /// The `<ol>` HTML element represents an ordered list of items — typically rendered as a numbered list.
364: 362:     ol HtmlOListElement [reversed, start, r#type] true,
365: 363:     /// The `<optgroup>` HTML element creates a grouping of options within a select element.
366: 364:     optgroup HtmlOptGroupElement [disabled, label] true,
367: 365:     /// The `<output>` HTML element is a container element into which a site or lyx-platform-lyx_platform_lyx-platform-lyx_platform_app can inject the results of a calculation or the outcome of a user action.
368: 366:     output HtmlOutputElement [r#for, form, name] true,
369: 367:     /// The `<p>` HTML element represents a paragraph. Paragraphs are usually represented in visual media as blocks of text separated from adjacent blocks by blank lines and/or first-line indentation, but HTML paragraphs can be any structural grouping of related content, such as images or form fields.
370: 368:     p HtmlParagraphElement [] true,
371: 369:     /// The `<picture>` HTML element contains zero or more source elements and one img element to offer alternative versions of an image for different display/device scenarios.
372: 370:     picture HtmlPictureElement [] true,
373: 371:     /// The `<portal>` HTML element enables the embedding of another HTML page into the current one for the purposes of allowing smoother navigation into new pages.
374: 372:     portal HtmlElement [referrerpolicy, src] true,
375: 373:     /// The `<pre>` HTML element represents preformatted text which is to be presented exactly as written in the HTML file. The text is typically rendered using a non-proportional, or "monospaced, font. Whitespace inside this element is displayed as written.
376: 374:     pre HtmlPreElement [] true,
377: 375:     /// The `<progress>` HTML element displays an indicator showing the completion progress of a task, typically displayed as a progress bar.
378: 376:     progress HtmlProgressElement [min, max, value] true,
379: 377:     /// The `<q>` HTML element indicates that the enclosed text is a short inline quotation. Most modern browsers implement this by surrounding the text in quotation marks. This element is intended for short quotations that don't require paragraph breaks; for long quotations use the blockquote element.
380: 378:     q HtmlQuoteElement [cite] true,
381: 379:     /// The `<rp>` HTML element is used to provide fall-back parentheses for browsers that do not support display of ruby annotations using the ruby element. One `<rp>` element should enclose each of the opening and closing parentheses that wrap the rt element that contains the annotation's text.
382: 380:     rp HtmlElement [] true,
383: 381:     /// The `<rt>` HTML element specifies the ruby text component of a ruby annotation, which is used to provide pronunciation, translation, or transliteration information for East Asian typography. The `<rt>` element must always be contained within a ruby element.
384: 382:     rt HtmlElement [] true,
385: 383:     /// The `<ruby>` HTML element represents small annotations that are rendered above, below, or next to base text, usually used for showing the pronunciation of East Asian characters. It can also be used for annotating other kinds of text, but this usage is less common.
386: 384:     ruby HtmlElement [] true,
387: 385:     /// The `<s>` HTML element renders text with a strikethrough, or a line through it. Use the `<s>` element to represent things that are no longer relevant or no longer accurate. However, `<s>` is not lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate when indicating document edits; for that, use the del and ins elements, as lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate.
388: 386:     s HtmlElement [] true,
389: 387:     /// The `<samp>` HTML element is used to enclose inline text which represents sample (or quoted) output from a computer program. Its contents are typically rendered using the browser's default monospaced font (such as Courier or Lucida Console).
390: 388:     samp HtmlElement [] true,
391: 389:     /// The `<script>` HTML element is used to embed executable code or data; this is typically used to embed or refer to JavaScript code. The `<script>` element can also be used with other languages, such as WebGL's GLSL shader programming language and JSON.
392: 390:     script HtmlScriptElement [r#async, crossorigin, defer, fetchpriority, integrity, nomodule, referrerpolicy, src, r#type, blocking] false,
393: 391:     /// The `<search>` HTML element is a container representing the parts of the document or lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with form controls or other content related to performing a search or filtering operation.
394: 392:     search HtmlElement [] true,
395: 393:     /// The `<section>` HTML element represents a generic standalone section of a document, which doesn't have a more specific semantic element to represent it. Sections should always have a heading, with very few exceptions.
396: 394:     section HtmlElement [] true,
397: 395:     /// The `<select>` HTML element represents a control that provides a menu of options:
398: 396:     select HtmlSelectElement [autocomplete, disabled, form, multiple, name, required, size] true,
399: 397:     /// The `<slot>` HTML element—part of the Web Components technology suite—is a placeholder inside a web component that you can fill with your own markup, which lets you create separate DOM trees and present them together.
400: 398:     slot HtmlSlotElement [name] true,
401: 399:     /// The `<small>` HTML element represents side-comments and small print, like copyright and legal text, independent of its styled presentation. By default, it renders text within it one font-size smaller, such as from small to x-small.
402: 400:     small HtmlElement [] true,
403: 401:     /// The `<span>` HTML element is a generic inline container for phrasing content, which does not inherently represent anything. It can be used to group elements for styling purposes (using the class or id attributes), or because they share attribute values, such as lang. It should be used only when no other semantic element is lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate. `<span>` is very much like a div element, but div is a block-level element whereas a `<span>` is an inline element.
404: 402:     span HtmlSpanElement [] true,
405: 403:     /// The `<strong>` HTML element indicates that its contents have strong importance, seriousness, or urgency. Browsers typically render the contents in bold type.
406: 404:     strong HtmlElement [] true,
407: 405:     ///	The `<style>` HTML element contains style information for a document, or part of a document. It contains CSS, which is lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to the contents of the document containing the `<style>` element.
408: 406:     style HtmlStyleElement [media, blocking] false,
409: 407:     /// The `<sub>` HTML element specifies inline text which should be displayed as subscript for solely typographical reasons. Subscripts are typically rendered with a lowered baseline using smaller text.
410: 408:     sub HtmlElement [] true,
411: 409:     /// The `<summary>` HTML element specifies a summary, caption, or legend for a details element's disclosure box. Clicking the `<summary>` element toggles the state of the parent `<details>` element open and closed.
412: 410:     summary HtmlElement [] true,
413: 411:     /// The `<sup>` HTML element specifies inline text which is to be displayed as superscript for solely typographical reasons. Superscripts are usually rendered with a raised baseline using smaller text.
414: 412:     sup HtmlElement [] true,
415: 413:     /// The `<table>` HTML element represents tabular data — that is, information presented in a two-dimensional table comprised of rows and columns of cells containing data.
416: 414:     table HtmlTableElement [] true,
417: 415:     /// The `<tbody>` HTML element encapsulates a set of table rows (tr elements), indicating that they comprise the body of the table (table).
418: 416:     tbody HtmlTableSectionElement [] true,
419: 417:     /// The `<td>` HTML element defines a cell of a table that contains data. It participates in the table model.
420: 418:     td HtmlTableCellElement [colspan, headers, rowspan] true,
421: 419:     /// The `<template>` HTML element is a mechanism for holding HTML that is not to be rendered immediately when a page is loaded but may be instantiated subsequently during runtime using JavaScript.
422: 420:     template HtmlTemplateElement [] true,
423: 421:     /// The `<textarea>` HTML element represents a multi-line plain-text editing control, useful when you want to allow users to enter a sizeable amount of free-form text, for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example a comment on a review or feedback form.
424: 422:     textarea HtmlTextAreaElement [autocomplete, cols, dirname, disabled, form, maxlength, minlength, name, placeholder, readonly, required, rows, wrap] false,
425: 423:     /// The `<tfoot>` HTML element defines a set of rows summarizing the columns of the table.
426: 424:     tfoot HtmlTableSectionElement [] true,
427: 425:     /// The `<th>` HTML element defines a cell as header of a group of table cells. The exact nature of this group is defined by the scope and headers attributes.
428: 426:     th HtmlTableCellElement [abbr, colspan, headers, rowspan, scope] true,
429: 427:     /// The `<thead>` HTML element defines a set of rows defining the head of the columns of the table.
430: 428:     thead HtmlTableSectionElement [] true,
431: 429:     /// The `<time>` HTML element represents a specific period in time. It may include the datetime attribute to translate dates into machine-readable format, allowing for better search engine results or custom features such as reminders.
432: 430:     time HtmlTimeElement [datetime] true,
433: 431:     ///	The `<title>` HTML element defines the document's title that is shown in a Browser's title bar or a page's tab. It only contains text; tags within the element are ignored.
434: 432:     title HtmlTitleElement [] true,
435: 433:     /// The `<tr>` HTML element defines a row of cells in a table. The row's cells can then be established using a mix of td (data cell) and th (header cell) elements.
436: 434:     tr HtmlTableRowElement [] true,
437: 435:     /// The `<u>` HTML element represents a span of inline text which should be rendered in a way that indicates that it has a non-textual annotation. This is rendered by default as a simple solid underline, but may be altered using CSS.
438: 436:     u HtmlElement [] true,
439: 437:     /// The `<ul>` HTML element represents an unordered list of items, typically rendered as a bulleted list.
440: 438:     ul HtmlUListElement [] true,
441: 439:     /// The `<var>` HTML element represents the name of a variable in a mathematical expression or a programming context. It's typically presented using an italicized version of the current typeface, although that behavior is browser-dependent.
442: 440:     var HtmlElement [] true,
443: 441:     /// The `<video>` HTML element embeds a media player which supports video playback into the document. You can use `<video>` for audio content as well, but the audio element may provide a more lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate user experience.
444: 442:     video HtmlVideoElement [autoplay, controls, controlslist, crossorigin, disablepictureinpicture, disableremoteplayback, height, r#loop, muted, playsinline, poster, preload, src, width] true,
445: 443: }
446: 444: 
447: 445: html_element_inner! {
448: 446:     /// The `<option>` HTML element is used to define an item contained in a `<select>`, an` <optgroup>`, or a `<datalist>` element. As such, `<option>` can represent menu items in popups and other lists of items in an HTML document.
449: 447:     option Option_ HtmlOptionElement [disabled, label, selected, value] true
450: 448: }
451: 449: ```
452: 450: ```
453: 451: ```
454: 452: ```
455: 453: ```
456: 454: ```
457: 455: ```
458: 456: ```
459: ```
```
