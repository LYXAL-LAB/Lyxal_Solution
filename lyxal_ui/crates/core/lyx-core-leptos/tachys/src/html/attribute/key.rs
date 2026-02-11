### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\key.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\key.rs
18: 16: ```rust
19: 17: use super::{Attr, AttributeValue};
20: 18: use std::fmt::Debug;
21: 19: 
22: 20: /// An HTML attribute key.
23: 21: pub trait AttributeKey: Clone + Send + 'static {
24: 22:     /// The name of the attribute.
25: 23:     const KEY: &'static str;
26: 24: }
27: 25: 
28: 26: macro_rules! attributes {
29: 27: 	($(#[$meta:meta] $key:ident $html:literal),* $(,)?) => {
30: 28:         paste::paste! {
31: 29:             $(
32: 30:                 #[$meta]
33: 31:                 #[track_caller]
34: 32:                 pub fn $key<V>(value: V) -> Attr<[<$key:camel>], V>
35: 33: 				where V: AttributeValue,
36: 34: 
37: 35:                 {
38: 36:                     Attr([<$key:camel>], value)
39: 37:                 }
40: 38: 
41: 39:                 #[$meta]
42: 40: 				#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
43: 41: 				pub struct [<$key:camel>];
44: 42: 
45: 43: 				impl AttributeKey for [<$key:camel>] {
46: 44: 					const KEY: &'static str = $html;
47: 45: 				}
48: 46:             )*
49: 47: 		}
50: 48:     }
51: 49: }
52: 50: 
53: 51: attributes! {
54: 52:     // HTML
55: 53:     /// The `abbr` attribute specifies an abbreviated form of the element's content.
56: 54:     abbr "abbr",
57: 55:     /// The `accept-charset` attribute specifies the character encodings that are to be used for the form submission.
58: 56:     accept_charset "accept-charset",
59: 57:     /// The `accept` attribute specifies a list of types the lyx-platform-lyx_platform_lyx-platform-lyx_platform_server accepts, typically a file type.
60: 58:     accept "accept",
61: 59:     /// The `accesskey` attribute specifies a shortcut key to activate or focus an element.
62: 60:     accesskey "accesskey",
63: 61:     /// The `action` attribute defines the URL to which the form data will be sent.
64: 62:     action "action",
65: 63:     /// The `align` attribute specifies the alignment of an element.
66: 64:     align "align",
67: 65:     /// The `allow` attribute defines a feature policy for the content in an iframe.
68: 66:     allow "allow",
69: 67:     /// The `allowfullscreen` attribute allows the iframe to be displayed in fullscreen mode.
70: 68:     allowfullscreen "allowfullscreen",
71: 69:     /// The `allowpaymentrequest` attribute allows a cross-origin iframe to invoke the Payment Request API.
72: 70:     allowpaymentrequest "allowpaymentrequest",
73: 71:     /// The `alt` attribute provides alternative text for an image, if the image cannot be displayed.
74: 72:     alt "alt",
75: 73:     // ARIA
76: 74:     /// The `aria-activedescendant` attribute identifies the currently active element when DOM focus is on a composite widget, textbox, group, or lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
77: 75:     aria_activedescendant "aria-activedescendant",
78: 76:     /// The `aria-atomic` attribute indicates whether assistive technologies will present all, or only parts of, the changed region based on the change notifications defined by the aria-relevant attribute.
79: 77:     aria_atomic "aria-atomic",
80: 78:     /// The `aria-autocomplete` attribute indicates whether user input completion suggestions are provided.
81: 79:     aria_autocomplete "aria-autocomplete",
82: 80:     /// The `aria-busy` attribute indicates whether an element, and its subtree, are currently being updated.
83: 81:     aria_busy "aria-busy",
84: 82:     /// The `aria-checked` attribute indicates the current "checked" state of checkboxes, radio buttons, and other widgets.
85: 83:     aria_checked "aria-checked",
86: 84:     /// The `aria-colcount` attribute defines the total number of columns in a table, grid, or treegrid.
87: 85:     aria_colcount "aria-colcount",
88: 86:     /// The `aria-colindex` attribute defines an element's column index or position with respect to the total number of columns within a table, grid, or treegrid.
89: 87:     aria_colindex "aria-colindex",
90: 88:     /// The `aria-colspan` attribute defines the number of columns spanned by a cell or gridcell within a table, grid, or treegrid.
91: 89:     aria_colspan "aria-colspan",
92: 90:     /// The `aria-controls` attribute identifies the element (or elements) whose contents or presence are controlled by the current element.
93: 91:     aria_controls "aria-controls",
94: 92:     /// The `aria-current` attribute indicates the element representing the current item within a container or set of related elements.
95: 93:     aria_current "aria-current",
96: 94:     /// The `aria-describedby` attribute identifies the element (or elements) that describes the object.
97: 95:     aria_describedby "aria-describedby",
98: 96:     /// The `aria-description` attribute provides a string value that describes or annotates the current element.
99: 97:     aria_description "aria-description",
100: 98:     /// The `aria-details` attribute identifies the element that provides a detailed, extended description for the object.
101: 99:     aria_details "aria-details",
102: 100:     /// The `aria-disabled` attribute indicates that the element is perceivable but disabled, so it is not editable or otherwise operable.
103: 101:     aria_disabled "aria-disabled",
104: 102:     /// The `aria-dropeffect` attribute indicates what functions can be performed when a dragged object is released on the drop target.
105: 103:     aria_dropeffect "aria-dropeffect",
106: 104:     /// The `aria-errormessage` attribute identifies the element that provides an error message for the object.
107: 105:     aria_errormessage "aria-errormessage",
108: 106:     /// The `aria-expanded` attribute indicates whether an element, or another grouping element it controls, is currently expanded or collapsed.
109: 107:     aria_expanded "aria-expanded",
110: 108:     /// The `aria-flowto` attribute identifies the next element (or elements) in an alternate reading order of content.
111: 109:     aria_flowto "aria-flowto",
112: 110:     /// The `aria-grabbed` attribute indicates an element's "grabbed" state in a drag-and-drop operation.
113: 111:     aria_grabbed "aria-grabbed",
114: 112:     /// The `aria-haspopup` attribute indicates the availability and type of interactive popup element, such as menu or dialog, that can be triggered by an element.
115: 113:     aria_haspopup "aria-haspopup",
116: 114:     /// The `aria-hidden` attribute indicates whether the element is exposed to an accessibility API.
117: 115:     aria_hidden "aria-hidden",
118: 116:     /// The `aria-invalid` attribute indicates the entered value does not conform to the format expected by the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
119: 117:     aria_invalid "aria-invalid",
120: 118:     /// The `aria-keyshortcuts` attribute indicates keyboard shortcuts that an author has implemented to activate or give focus to an element.
121: 119:     aria_keyshortcuts "aria-keyshortcuts",
122: 120:     /// The `aria-label` attribute defines a string value that labels the current element.
123: 121:     aria_label "aria-label",
124: 122:     /// The `aria-labelledby` attribute identifies the element (or elements) that labels the current element.
125: 123:     aria_labelledby "aria-labelledby",
126: 124:     /// The `aria-live` attribute indicates that an element will be updated, and describes the types of updates the user agents, assistive technologies, and user can expect from the live region.
127: 125:     aria_live "aria-live",
128: 126:     /// The `aria-modal` attribute indicates whether an element is modal when displayed.
129: 127:     aria_modal "aria-modal",
130: 128:     /// The `aria-multiline` attribute indicates whether a text box accepts multiple lines of input or only a single line.
131: 129:     aria_multiline "aria-multiline",
132: 130:     /// The `aria-multiselectable` attribute indicates that the user may select more than one item from the current selectable descendants.
133: 131:     aria_multiselectable "aria-multiselectable",
134: 132:     /// The `aria-orientation` attribute indicates whether the element's orientation is horizontal, vertical, or unknown/ambiguous.
135: 133:     aria_orientation "aria-orientation",
136: 134:     /// The `aria-owns` attribute identifies an element (or elements) in order to define a relationship between the element with `aria-owns` and the target element.
137: 135:     aria_owns "aria-owns",
138: 136:     /// The `aria-placeholder` attribute defines a short hint (a word or short phrase) intended to aid the user with data entry when the control has no value.
139: 137:     aria_placeholder "aria-placeholder",
140: 138:     /// The `aria-posinset` attribute defines an element's position within a set or treegrid.
141: 139:     aria_posinset "aria-posinset",
142: 140:     /// The `aria-pressed` attribute indicates the current "pressed" state of toggle buttons.
143: 141:     aria_pressed "aria-pressed",
144: 142:     /// The `aria-readonly` attribute indicates that the element is not editable, but is otherwise operable.
145: 143:     aria_readonly "aria-readonly",
146: 144:     /// The `aria-relevant` attribute indicates what user agent changes to the accessibility tree should be monitored.
147: 145:     aria_relevant "aria-relevant",
148: 146:     /// The `aria-required` attribute indicates that user input is required on the element before a form may be submitted.
149: 147:     aria_required "aria-required",
150: 148:     /// The `aria-roledescription` attribute defines a human-readable, author-localized description for the role of an element.
151: 149:     aria_roledescription "aria-roledescription",
152: 150:     /// The `aria-rowcount` attribute defines the total number of rows in a table, grid, or treegrid.
153: 151:     aria_rowcount "aria-rowcount",
154: 152:     /// The `aria-rowindex` attribute defines an element's row index or position with respect to the total number of rows within a table, grid, or treegrid.
155: 153:     aria_rowindex "aria-rowindex",
156: 154:     /// The `aria-rowspan` attribute defines the number of rows spanned by a cell or gridcell within a table, grid, or treegrid.
157: 155:     aria_rowspan "aria-rowspan",
158: 156:     /// The `aria-selected` attribute indicates the current "selected" state of various widgets.
159: 157:     aria_selected "aria-selected",
160: 158:     /// The `aria-setsize` attribute defines the number of items in the current set of listitems or treeitems.
161: 159:     aria_setsize "aria-setsize",
162: 160:     /// The `aria-sort` attribute indicates if items in a table or grid are sorted in ascending or descending order.
163: 161:     aria_sort "aria-sort",
164: 162:     /// The `aria-valuemax` attribute defines the maximum allowed value for a range widget.
165: 163:     aria_valuemax "aria-valuemax",
166: 164:     /// The `aria-valuemin` attribute defines the minimum allowed value for a range widget.
167: 165:     aria_valuemin "aria-valuemin",
168: 166:     /// The `aria-valuenow` attribute defines the current value for a range widget.
169: 167:     aria_valuenow "aria-valuenow",
170: 168:     /// The `aria-valuetext` attribute defines the human-readable text alternative of aria-valuenow for a range widget.
171: 169:     aria_valuetext "aria-valuetext",
172: 170:     /// The `as` attribute specifies the type of destination for the content of the link.
173: 171:     r#as "as",
174: 172:     /// The `async` attribute indicates that the script should be executed asynchronously.
175: 173:     r#async "async",
176: 174:     /// The `attributionsrc` attribute indicates that you want the browser to send an `Attribution-Reporting-Eligible` header along with a request.
177: 175:     attributionsrc "attributionsrc",
178: 176:     /// The `autocapitalize` attribute controls whether and how text input is automatically capitalized as it is entered/edited by the user.
179: 177:     autocapitalize "autocapitalize",
180: 178:     /// The `autocomplete` attribute indicates whether an input field can have its value automatically completed by the browser.
181: 179:     autocomplete "autocomplete",
182: 180:     /// The `autofocus` attribute indicates that an element should be focused on page load.
183: 181:     autofocus "autofocus",
184: 182:     /// The `autoplay` attribute indicates that the media should start playing as soon as it is loaded.
185: 183:     autoplay "autoplay",
186: 184:     /// The `background` attribute sets the URL of the background image for the document.
187: 185:     background "background",
188: 186:     /// The `bgcolor` attribute sets the background color of an element.
189: 187:     bgcolor "bgcolor",
190: 188:     /// The `blocking` attribute indicates that the script will block the page loading until it is executed.
191: 189:     blocking "blocking",
192: 190:     /// The `border` attribute sets the width of an element's border.
193: 191:     border "border",
194: 192:     /// The `buffered` attribute contains the time ranges that the media has been buffered.
195: 193:     buffered "buffered",
196: 194:     /// The `capture` attribute indicates that the user must capture media using a camera or microphone instead of selecting a file from the file picker.
197: 195:     capture "capture",
198: 196:     /// The `challenge` attribute specifies the challenge string that is paired with the keygen element.
199: 197:     challenge "challenge",
200: 198:     /// The `closedby` attribute specifies the types of user actions that can be used to close the associated `<dialog>` element.
201: 199:     closedby "closedby",
202: 200:     /// The `charset` attribute specifies the character encoding of the HTML document.
203: 201:     charset "charset",
204: 202:     /// The `checked` attribute indicates whether an input element is checked or not.
205: 203:     checked "checked",
206: 204:     /// The `cite` attribute contains a URL that points to the source of the quotation or change.
207: 205:     cite "cite",
208: 206:     // class is handled in ../class.rs instead
209: 207:     //class "class",
210: 208:     /// The `code` attribute specifies the URL of the lyx-platform-lyx_platform_lyx-platform-lyx_platform_applet's class file to be loaded and executed.
211: 209:     code "code",
212: 210:     /// The `color` attribute specifies the color of an element's text.
213: 211:     color "color",
214: 212:     /// The `cols` attribute specifies the visible width of a text area.
215: 213:     cols "cols",
216: 214:     /// The `colspan` attribute defines the number of columns a cell should span.
217: 215:     colspan "colspan",
218: 216:     /// The `command` attribute defines the command to be invoked when user clicks the `<button>` element which has `commandfor` attribute specified.
219: 217:     command "command",
220: 218:     /// The `commandfor` attribute defines the id of the element which button is controlling. It is generic version of `popovertarget`.
221: 219:     commandfor "commandfor",
222: 220:     /// The `content` attribute gives the value associated with the http-equiv or name attribute.
223: 221:     content "content",
224: 222:     /// The `contenteditable` attribute indicates whether the element's content is editable.
225: 223:     contenteditable "contenteditable",
226: 224:     /// The `contextmenu` attribute specifies the ID of a `<menu>` element to open as a context menu.
227: 225:     contextmenu "contextmenu",
228: 226:     /// The `controls` attribute indicates whether the browser should display playback controls for the media.
229: 227:     controls "controls",
230: 228:     /// The `controlslist` attribute allows the control of which controls to show on the media element whenever the browser shows its native controls.
231: 229:     controlslist "controlslist",
232: 230:     /// The `coords` attribute specifies the coordinates of an area in an image map.
233: 231:     coords "coords",
234: 232:     /// The `crossorigin` attribute indicates whether the resource should be fetched with a CORS request.
235: 233:     crossorigin "crossorigin",
236: 234:     /// The `csp` attribute allows the embedding document to define the Content Security Policy that an embedded document must agree to enforce upon itself.
237: 235:     csp "csp",
238: 236:     /// The `data` attribute specifies the URL of the resource that is being embedded.
239: 237:     data "data",
240: 238:     /// The `datetime` attribute specifies the date and time.
241: 239:     datetime "datetime",
242: 240:     /// The `decoding` attribute indicates the preferred method for decoding images.
243: 241:     decoding "decoding",
244: 242:     /// The `default` attribute indicates that the track should be enabled unless the user's preferences indicate that another track is more lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriate.
245: 243:     default "default",
246: 244:     /// The `defer` attribute indicates that the script should be executed after the document has been parsed.
247: 245:     defer "defer",
248: 246:     /// The `dir` attribute specifies the text direction for the content in an element.
249: 247:     dir "dir",
250: 248:     /// The `dirname` attribute identifies the text directionality of an input element.
251: 249:     dirname "dirname",
252: 250:     /// The `disabled` attribute indicates whether the element is disabled.
253: 251:     disabled "disabled",
254: 252:     /// The `disablepictureinpicture` attribute indicates that the element is not allowed to be displayed in Picture-in-Picture mode.
255: 253:     disablepictureinpicture "disablepictureinpicture",
256: 254:     /// The `disableremoteplayback` attribute indicates that the element is not allowed to be displayed using remote playback.
257: 255:     disableremoteplayback "disableremoteplayback",
258: 256:     /// The `download` attribute indicates that the linked resource is intended to be downloaded rather than displayed in the browser.
259: 257:     download "download",
260: 258:     /// The `draggable` attribute indicates whether the element is draggable.
261: 259:     draggable "draggable",
262: 260:     /// The `elementtiming` attributes marks the element for observation by the `PerformanceElementTiming` API.
263: 261:     elementtiming "elementtiming",
264: 262:     /// The `enctype` attribute specifies the MIME type of the form submission.
265: 263:     enctype "enctype",
266: 264:     /// The `enterkeyhint` attribute allows authors to specify what kind of action label or icon will be presented to users in a virtual keyboard's enter key.
267: 265:     enterkeyhint "enterkeyhint",
268: 266:     /// The `exportparts` attribute enables the sharing of parts of an element's shadow DOM with a containing document.
269: 267:     exportparts "exportparts",
270: 268:     /// The `fetchpriority` attribute allows developers to specify the priority of a resource fetch request.
271: 269:     fetchpriority "fetchpriority",
272: 270:     /// The `for` attribute specifies which form element a label is bound to.
273: 271:     r#for "for",
274: 272:     /// The `form` attribute associates the element with a form element.
275: 273:     form "form",
276: 274:     /// The `formaction` attribute specifies the URL that processes the form submission.
277: 275:     formaction "formaction",
278: 276:     /// The `formenctype` attribute specifies how the form data should be encoded when submitted.
279: 277:     formenctype "formenctype",
280: 278:     /// The `formmethod` attribute specifies the HTTP method to use when submitting the form.
281: 279:     formmethod "formmethod",
282: 280:     /// The `formnovalidate` attribute indicates that the form should not be validated when submitted.
283: 281:     formnovalidate "formnovalidate",
284: 282:     /// The `formtarget` attribute specifies where to display the response after submitting the form.
285: 283:     formtarget "formtarget",
286: 284:     /// The `headers` attribute specifies the headers associated with the element.
287: 285:     headers "headers",
288: 286:     /// The `height` attribute specifies the height of an element.
289: 287:     height "height",
290: 288:     /// The `hidden` attribute indicates that the element is not yet, or is no longer, relevant.
291: 289:     hidden "hidden",
292: 290:     /// The `high` attribute specifies the range that is considered to be a high value.
293: 291:     high "high",
294: 292:     /// The `href` attribute specifies the URL of a linked resource.
295: 293:     href "href",
296: 294:     /// The `hreflang` attribute specifies the language of the linked resource.
297: 295:     hreflang "hreflang",
298: 296:     /// The `http-equiv` attribute provides an HTTP header for the information/value of the content attribute.
299: 297:     http_equiv "http-equiv",
300: 298:     /// The `icon` attribute specifies the URL of an image to be used as a graphical icon for the element.
301: 299:     icon "icon",
302: 300:     /// The `id` attribute specifies a unique id for an element.
303: 301:     id "id",
304: 302:     /// The `imagesizes` attribute specifies image sizes for different page layouts.
305: 303:     imagesizes "imagesizes",
306: 304:     /// The `imagesrcset` attribute specifies the URLs of multiple images to be used in different situations.
307: 305:     imagesrcset "imagesrcset",
308: 306:     /// The `importance` attribute specifies the relative importance of the element.
309: 307:     importance "importance",
310: 308:     /// The `inert` attribute indicates that the element is non-interactive and won't be accessible to user interactions or assistive technologies.
311: 309:     inert "inert",
312: 310:     /// The `inputmode` attribute specifies the type of data that the user will enter.
313: 311:     inputmode "inputmode",
314: 312:     /// The `integrity` attribute contains a hash value that the browser can use to verify that the resource hasn't been altered.
315: 313:     integrity "integrity",
316: 314:     /// The `intrinsicsize` attribute specifies the intrinsic size of an image or video.
317: 315:     intrinsicsize "intrinsicsize",
318: 316:     /// The `is` attribute allows you to specify the name of a custom element.
319: 317:     is "is",
320: 318:     /// The `ismap` attribute indicates that the image is part of a lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side image map.
321: 319:     ismap "ismap",
322: 320:     /// The `itemid` attribute assigns a unique identifier to an item.
323: 321:     itemid "itemid",
324: 322:     /// The `itemprop` attribute adds a property to an item.
325: 323:     itemprop "itemprop",
326: 324:     /// The `itemref` attribute provides a list of element IDs that have additional properties for the item.
327: 325:     itemref "itemref",
328: 326:     /// The `itemscope` attribute creates a new item and adds it to the page's items.
329: 327:     itemscope "itemscope",
330: 328:     /// The `itemtype` attribute specifies the type of an item.
331: 329:     itemtype "itemtype",
332: 330:     /// The `keytype` attribute specifies the type of key used by the `<keygen>` element.
333: 331:     keytype "keytype",
334: 332:     /// The `kind` attribute specifies the kind of text track.
335: 333:     kind "kind",
336: 334:     /// The `label` attribute provides a user-readable title for an element.
337: 335:     label "label",
338: 336:     /// The `lang` attribute specifies the language of the element's content.
339: 337:     lang "lang",
340: 338:     /// The `language` attribute specifies the scripting language used for the script.
341: 339:     language "language",
342: 340:     /// The `list` attribute identifies a `<datalist>` element that contains pre-defined options for an `<input>` element.
343: 341:     list "list",
344: 342:     /// The `loading` attribute indicates how the browser should load the image.
345: 343:     loading "loading",
346: 344:     /// The `loop` attribute indicates whether the media should start over again when it reaches the end.
347: 345:     r#loop "loop",
348: 346:     /// The `low` attribute specifies the range that is considered to be a low value.
349: 347:     low "low",
350: 348:     /// The `manifest` attribute specifies the URL of a document's cache manifest.
351: 349:     manifest "manifest",
352: 350:     /// The `max` attribute specifies the maximum value for an input element.
353: 351:     max "max",
354: 352:     /// The `maxlength` attribute specifies the maximum number of characters that an input element can accept.
355: 353:     maxlength "maxlength",
356: 354:     /// The `media` attribute specifies what media/device the linked resource is optimized for.
357: 355:     media "media",
358: 356:     /// The `method` attribute specifies the HTTP method to use when submitting the form.
359: 357:     method "method",
360: 358:     /// The `min` attribute specifies the minimum value for an input element.
361: 359:     min "min",
362: 360:     /// The `minlength` attribute specifies the minimum number of characters that an input element can accept.
363: 361:     minlength "minlength",
364: 362:     /// The `multiple` attribute indicates whether the user can enter more than one value.
365: 363:     multiple "multiple",
366: 364:     /// The `muted` attribute indicates whether the audio will be initially silenced on page load.
367: 365:     muted "muted",
368: 366:     /// The `name` attribute specifies the name of the element.
369: 367:     name "name",
370: 368:     /// The `nomodule` attribute indicates that the script should not be executed in browsers that support ES modules.
371: 369:     nomodule "nomodule",
372: 370:     /// The `nonce` attribute provides a cryptographic nonce to ensure that a script or style is lyx-platform-lyx_platform_lyx-platform-lyx_platform_approved for execution.
373: 371:     nonce "nonce",
374: 372:     /// The `novalidate` attribute indicates that the form should not be validated when submitted.
375: 373:     novalidate "novalidate",
376: 374:     /// The `open` attribute indicates whether the details element is open or closed.
377: 375:     open "open",
378: 376:     /// The `optimum` attribute specifies the range that is considered to be an optimum value.
379: 377:     optimum "optimum",
380: 378:     /// The `part` attribute identifies the element as a shadow DOM part.
381: 379:     part "part",
382: 380:     /// The `pattern` attribute specifies a regular expression that the input element's value is checked against.
383: 381:     pattern "pattern",
384: 382:     /// The `ping` attribute contains a space-separated list of URLs to be notified if the user follows the hyperlink.
385: 383:     ping "ping",
386: 384:     /// The `placeholder` attribute provides a short hint that describes the expected value of the input element.
387: 385:     placeholder "placeholder",
388: 386:     /// The `playsinline` attribute indicates that the video should play inline in the element's playback area.
389: 387:     playsinline "playsinline",
390: 388:     /// The `popover` attribute indicates that an element is a popover and specifies the event that causes the popover to be shown.
391: 389:     popover "popover",
392: 390:     /// The `popovertarget` attribute specifies the ID of an element to toggle a popover.
393: 391:     popovertarget "popovertarget",
394: 392:     /// The `popovertargetaction` attribute specifies the action that shows the popover.
395: 393:     popovertargetaction "popovertargetaction",
396: 394:     /// The `poster` attribute specifies an image to be shown while the video is downloading or until the user hits the play button.
397: 395:     poster "poster",
398: 396:     /// The `preload` attribute specifies if and how the author thinks that the media file should be loaded when the page loads.
399: 397:     preload "preload",
400: 398:     /// The `radiogroup` attribute specifies the name of the group to which the element belongs.
401: 399:     radiogroup "radiogroup",
402: 400:     /// The `readonly` attribute indicates that the user cannot modify the value of the input element.
403: 401:     readonly "readonly",
404: 402:     /// The `referrerpolicy` attribute specifies which referrer information to include with requests.
405: 403:     referrerpolicy "referrerpolicy",
406: 404:     /// The `rel` attribute specifies the relationship between the current document and the linked document.
407: 405:     rel "rel",
408: 406:     /// The `required` attribute indicates that the user must fill in the input element before submitting the form.
409: 407:     required "required",
410: 408:     /// The `reversed` attribute indicates that the list should be displayed in a descending order.
411: 409:     reversed "reversed",
412: 410:     /// The `role` attribute defines the role of an element in the context of a web lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
413: 411:     role "role",
414: 412:     /// The `rows` attribute specifies the number of visible text lines for a text area.
415: 413:     rows "rows",
416: 414:     /// The `rowspan` attribute defines the number of rows a cell should span.
417: 415:     rowspan "rowspan",
418: 416:     /// The `sandbox` attribute lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies extra restrictions to the content in the `<iframe>`.
419: 417:     sandbox "sandbox",
420: 418:     /// The `scope` attribute specifies whether a header cell is a header for a column, row, or group of columns or rows.
421: 419:     scope "scope",
422: 420:     /// The `scoped` attribute indicates that the styles in a `<style>` element are scoped to the parent element.
423: 421:     scoped "scoped",
424: 422:     /// The `selected` attribute indicates that the option is selected.
425: 423:     selected "selected",
426: 424:     /// The `shape` attribute specifies the shape of the area.
427: 425:     shape "shape",
428: 426:     /// The `size` attribute specifies the width of the input element.
429: 427:     size "size",
430: 428:     /// The `sizes` attribute specifies the sizes of icons for visual media.
431: 429:     sizes "sizes",
432: 430:     /// The `slot` attribute assigns a slot to an element.
433: 431:     slot "slot",
434: 432:     /// The `span` attribute defines the number of columns in a `<colgroup>` or the number of rows in a `<rowgroup>`.
435: 433:     span "span",
436: 434:     /// The `spellcheck` attribute indicates whether spell checking is allowed for the element.
437: 435:     spellcheck "spellcheck",
438: 436:     /// The `src` attribute specifies the URL of the media resource.
439: 437:     src "src",
440: 438:     /// The `srcdoc` attribute specifies the HTML content of the page to show in the `<iframe>`.
441: 439:     srcdoc "srcdoc",
442: 440:     /// The `srclang` attribute specifies the language of the text track.
443: 441:     srclang "srclang",
444: 442:     /// The `srcset` attribute specifies the URLs of multiple images to be used in different situations.
445: 443:     srcset "srcset",
446: 444:     /// The `start` attribute specifies the start value of the list.
447: 445:     start "start",
448: 446:     /// The `step` attribute specifies the legal number intervals for an input element.
449: 447:     step "step",
450: 448:     // style is handled in ../style.rs instead
451: 449:     // style "style",
452: 450:     /// The `summary` attribute provides a summary of the content of the table.
453: 451:     summary "summary",
454: 452:     /// The `tabindex` attribute specifies the tab order of an element.
455: 453:     tabindex "tabindex",
456: 454:     /// The `target` attribute specifies where to open the linked document.
457: 455:     target "target",
458: 456:     /// The `title` attribute provides additional information about an element.
459: 457:     title "title",
460: 458:     /// The `translate` attribute specifies whether the content of an element should be translated or not.
461: 459:     translate "translate",
462: 460:     /// The `type` attribute specifies the type of the element.
463: 461:     r#type "type",
464: 462:     /// The `usemap` attribute specifies the image map to be used by an `<img>` element.
465: 463:     usemap "usemap",
466: 464:     /// The `value` attribute specifies the value of the element.
467: 465:     value "value",
468: 466:     /// The `virtualkeyboardpolicy` attribute controls the policy for virtual keyboards.
469: 467:     virtualkeyboardpolicy "virtualkeyboardpolicy",
470: 468:     /// The `width` attribute specifies the width of an element.
471: 469:     width "width",
472: 470:     /// The `wrap` attribute specifies how the text in a text area is to be wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped when submitted in a form.
473: 471:     wrap "wrap",
474: 472:     // Event Handler Attributes
475: 473:     /// The `onabort` attribute specifies the event handler for the abort event.
476: 474:     onabort "onabort",
477: 475:     /// The `onautocomplete` attribute specifies the event handler for the autocomplete event.
478: 476:     onautocomplete "onautocomplete",
479: 477:     /// The `onautocompleteerror` attribute specifies the event handler for the autocompleteerror event.
480: 478:     onautocompleteerror "onautocompleteerror",
481: 479:     /// The `onblur` attribute specifies the event handler for the blur event.
482: 480:     onblur "onblur",
483: 481:     /// The `oncancel` attribute specifies the event handler for the cancel event.
484: 482:     oncancel "oncancel",
485: 483:     /// The `oncanplay` attribute specifies the event handler for the canplay event.
486: 484:     oncanplay "oncanplay",
487: 485:     /// The `oncanplaythrough` attribute specifies the event handler for the canplaythrough event.
488: 486:     oncanplaythrough "oncanplaythrough",
489: 487:     /// The `onchange` attribute specifies the event handler for the change event.
490: 488:     onchange "onchange",
491: 489:     /// The `onclick` attribute specifies the event handler for the click event.
492: 490:     onclick "onclick",
493: 491:     /// The `onclose` attribute specifies the event handler for the close event.
494: 492:     onclose "onclose",
495: 493:     /// The `oncontextmenu` attribute specifies the event handler for the contextmenu event.
496: 494:     oncontextmenu "oncontextmenu",
497: 495:     /// The `oncuechange` attribute specifies the event handler for the cuechange event.
498: 496:     oncuechange "oncuechange",
499: 497:     /// The `ondblclick` attribute specifies the event handler for the double click event.
500: 498:     ondblclick "ondblclick",
501: 499:     /// The `ondrag` attribute specifies the event handler for the drag event.
502: 500:     ondrag "ondrag",
503: 501:     /// The `ondragend` attribute specifies the event handler for the dragend event.
504: 502:     ondragend "ondragend",
505: 503:     /// The `ondragenter` attribute specifies the event handler for the dragenter event.
506: 504:     ondragenter "ondragenter",
507: 505:     /// The `ondragleave` attribute specifies the event handler for the dragleave event.
508: 506:     ondragleave "ondragleave",
509: 507:     /// The `ondragover` attribute specifies the event handler for the dragover event.
510: 508:     ondragover "ondragover",
511: 509:     /// The `ondragstart` attribute specifies the event handler for the dragstart event.
512: 510:     ondragstart "ondragstart",
513: 511:     /// The `ondrop` attribute specifies the event handler for the drop event.
514: 512:     ondrop "ondrop",
515: 513:     /// The `ondurationchange` attribute specifies the event handler for the durationchange event.
516: 514:     ondurationchange "ondurationchange",
517: 515:     /// The `onemptied` attribute specifies the event handler for the emptied event.
518: 516:     onemptied "onemptied",
519: 517:     /// The `onended` attribute specifies the event handler for the ended event.
520: 518:     onended "onended",
521: 519:     /// The `onerror` attribute specifies the event handler for the error event.
522: 520:     onerror "onerror",
523: 521:     /// The `onfocus` attribute specifies the event handler for the focus event.
524: 522:     onfocus "onfocus",
525: 523:     /// The `onformdata` attribute specifies the event handler for the formdata event.
526: 524:     onformdata "onformdata",
527: 525:     /// The `oninput` attribute specifies the event handler for the input event.
528: 526:     oninput "oninput",
529: 527:     /// The `oninvalid` attribute specifies the event handler for the invalid event.
530: 528:     oninvalid "oninvalid",
531: 529:     /// The `onkeydown` attribute specifies the event handler for the keydown event.
532: 530:     onkeydown "onkeydown",
533: 531:     /// The `onkeypress` attribute specifies the event handler for the keypress event.
534: 532:     onkeypress "onkeypress",
535: 533:     /// The `onkeyup` attribute specifies the event handler for the keyup event.
536: 534:     onkeyup "onkeyup",
537: 535:     /// The `onlanguagechange` attribute specifies the event handler for the languagechange event.
538: 536:     onlanguagechange "onlanguagechange",
539: 537:     /// The `onload` attribute specifies the event handler for the load event.
540: 538:     onload "onload",
541: 539:     /// The `onloadeddata` attribute specifies the event handler for the loadeddata event.
542: 540:     onloadeddata "onloadeddata",
543: 541:     /// The `onloadedmetadata` attribute specifies the event handler for the loadedmetadata event.
544: 542:     onloadedmetadata "onloadedmetadata",
545: 543:     /// The `onloadstart` attribute specifies the event handler for the loadstart event.
546: 544:     onloadstart "onloadstart",
547: 545:     /// The `onmousedown` attribute specifies the event handler for the mousedown event.
548: 546:     onmousedown "onmousedown",
549: 547:     /// The `onmouseenter` attribute specifies the event handler for the mouseenter event.
550: 548:     onmouseenter "onmouseenter",
551: 549:     /// The `onmouseleave` attribute specifies the event handler for the mouseleave event.
552: 550:     onmouseleave "onmouseleave",
553: 551:     /// The `onmousemove` attribute specifies the event handler for the mousemove event.
554: 552:     onmousemove "onmousemove",
555: 553:     /// The `onmouseout` attribute specifies the event handler for the mouseout event.
556: 554:     onmouseout "onmouseout",
557: 555:     /// The `onmouseover` attribute specifies the event handler for the mouseover event.
558: 556:     onmouseover "onmouseover",
559: 557:     /// The `onmouseup` attribute specifies the event handler for the mouseup event.
560: 558:     onmouseup "onmouseup",
561: 559:     /// The `onpause` attribute specifies the event handler for the pause event.
562: 560:     onpause "onpause",
563: 561:     /// The `onplay` attribute specifies the event handler for the play event.
564: 562:     onplay "onplay",
565: 563:     /// The `onplaying` attribute specifies the event handler for the playing event.
566: 564:     onplaying "onplaying",
567: 565:     /// The `onprogress` attribute specifies the event handler for the progress event.
568: 566:     onprogress "onprogress",
569: 567:     /// The `onratechange` attribute specifies the event handler for the ratechange event.
570: 568:     onratechange "onratechange",
571: 569:     /// The `onreset` attribute specifies the event handler for the reset event.
572: 570:     onreset "onreset",
573: 571:     /// The `onresize` attribute specifies the event handler for the resize event.
574: 572:     onresize "onresize",
575: 573:     /// The `onscroll` attribute specifies the event handler for the scroll event.
576: 574:     onscroll "onscroll",
577: 575:     /// The `onsecuritypolicyviolation` attribute specifies the event handler for the securitypolicyviolation event.
578: 576:     onsecuritypolicyviolation "onsecuritypolicyviolation",
579: 577:     /// The `onseeked` attribute specifies the event handler for the seeked event.
580: 578:     onseeked "onseeked",
581: 579:     /// The `onseeking` attribute specifies the event handler for the seeking event.
582: 580:     onseeking "onseeking",
583: 581:     /// The `onselect` attribute specifies the event handler for the select event.
584: 582:     onselect "onselect",
585: 583:     /// The `onslotchange` attribute specifies the event handler for the slotchange event.
586: 584:     onslotchange "onslotchange",
587: 585:     /// The `onstalled` attribute specifies the event handler for the stalled event.
588: 586:     onstalled "onstalled",
589: 587:     /// The `onsubmit` attribute specifies the event handler for the submit event.
590: 588:     onsubmit "onsubmit",
591: 589:     /// The `onsuspend` attribute specifies the event handler for the suspend event.
592: 590:     onsuspend "onsuspend",
593: 591:     /// The `ontimeupdate` attribute specifies the event handler for the timeupdate event.
594: 592:     ontimeupdate "ontimeupdate",
595: 593:     /// The `ontoggle` attribute specifies the event handler for the toggle event.
596: 594:     ontoggle "ontoggle",
597: 595:     /// The `onvolumechange` attribute specifies the event handler for the volumechange event.
598: 596:     onvolumechange "onvolumechange",
599: 597:     /// The `onwaiting` attribute specifies the event handler for the waiting event.
600: 598:     onwaiting "onwaiting",
601: 599:     /// The `onwebkitanimationend` attribute specifies the event handler for the webkitanimationend event.
602: 600:     onwebkitanimationend "onwebkitanimationend",
603: 601:     /// The `onwebkitanimationiteration` attribute specifies the event handler for the webkitanimationiteration event.
604: 602:     onwebkitanimationiteration "onwebkitanimationiteration",
605: 603:     /// The `onwebkitanimationstart` attribute specifies the event handler for the webkitanimationstart event.
606: 604:     onwebkitanimationstart "onwebkitanimationstart",
607: 605:     /// The `onwebkittransitionend` attribute specifies the event handler for the webkittransitionend event.
608: 606:     onwebkittransitionend "onwebkittransitionend",
609: 607:     /// The `onwheel` attribute specifies the event handler for the wheel event.
610: 608:     onwheel "onwheel",
611: 609: 
612: 610:     // MathML attributes
613: 611:     /// The `accent` attribute specifies whether the element should be treated as an accent.
614: 612:     accent "accent",
615: 613:     /// The `accentunder` attribute specifies whether the element should be treated as an accent under the base element.
616: 614:     accentunder "accentunder",
617: 615:     /// The `columnalign` attribute specifies the alignment of columns.
618: 616:     columnalign "columnalign",
619: 617:     /// The `columnlines` attribute specifies the presence of lines between columns.
620: 618:     columnlines "columnlines",
621: 619:     /// The `columnspacing` attribute specifies the spacing between columns.
622: 620:     columnspacing "columnspacing",
623: 621:     /// The `columnspan` attribute specifies the number of columns the element should span.
624: 622:     columnspan "columnspan",
625: 623:     /// The `depth` attribute specifies the depth of the element.
626: 624:     depth "depth",
627: 625:     /// The `display` attribute specifies the display style of the element.
628: 626:     display "display",
629: 627:     /// The `displaystyle` attribute specifies whether the element is displayed in display style.
630: 628:     displaystyle "displaystyle",
631: 629:     /// The `fence` attribute specifies whether the element should act as a fence.
632: 630:     fence "fence",
633: 631:     /// The `frame` attribute specifies the type of frame for the element.
634: 632:     frame "frame",
635: 633:     /// The `framespacing` attribute specifies the spacing around frames.
636: 634:     framespacing "framespacing",
637: 635:     /// The `linethickness` attribute specifies the thickness of lines.
638: 636:     linethickness "linethickness",
639: 637:     /// The `lspace` attribute specifies the space on the left side of the element.
640: 638:     lspace "lspace",
641: 639:     /// The `mathbackground` attribute specifies the background color of the element.
642: 640:     mathbackground "mathbackground",
643: 641:     /// The `mathcolor` attribute specifies the color of the element.
644: 642:     mathcolor "mathcolor",
645: 643:     /// The `mathsize` attribute specifies the size of the element.
646: 644:     mathsize "mathsize",
647: 645:     /// The `mathvariant` attribute specifies the mathematical variant of the element.
648: 646:     mathvariant "mathvariant",
649: 647:     /// The `maxsize` attribute specifies the maximum size of the element.
650: 648:     maxsize "maxsize",
651: 649:     /// The `minsize` attribute specifies the minimum size of the element.
652: 650:     minsize "minsize",
653: 651:     /// The `movablelimits` attribute specifies whether the limits of the element are movable.
654: 652:     movablelimits "movablelimits",
655: 653:     /// The `notation` attribute specifies the type of notation for the element.
656: 654:     notation "notation",
657: 655:     /// The `rowalign` attribute specifies the alignment of rows.
658: 656:     rowalign "rowalign",
659: 657:     /// The `rowlines` attribute specifies the presence of lines between rows.
660: 658:     rowlines "rowlines",
661: 659:     /// The `rowspacing` attribute specifies the spacing between rows.
662: 660:     rowspacing "rowspacing",
663: 661:     /// The `rspace` attribute specifies the space on the right side of the element.
664: 662:     rspace "rspace",
665: 663:     /// The `scriptlevel` attribute specifies the script level of the element.
666: 664:     scriptlevel "scriptlevel",
667: 665:     /// The `separator` attribute specifies whether the element is a separator.
668: 666:     separator "separator",
669: 667:     /// The `stretchy` attribute specifies whether the element is stretchy.
670: 668:     stretchy "stretchy",
671: 669:     /// The `symmetric` attribute specifies whether the element is symmetric.
672: 670:     symmetric "symmetric",
673: 671:     /// The `voffset` attribute specifies the vertical offset of the element.
674: 672:     voffset "voffset",
675: 673:     /// The `xmlns` attribute specifies the XML namespace of the element.
676: 674:     xmlns "xmlns",
677: 675: }
678: 676: ```
679: 677: ```
680: 678: ```
681: 679: ```
682: 680: ```
683: 681: ```
684: 682: ```
685: 683: ```
686: ```
```
