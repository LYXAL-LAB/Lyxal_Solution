### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\attribute\aria.rs
18: 16: ```rust
19: 17: use crate::{
20: 18:     html::{
21: 19:         attribute::{Attr, *},
22: 20:         element::{ElementType, HtmlElement},
23: 21:     },
24: 22:     renderer::Rndr,
25: 23:     view::{add_attr::AddAnyAttr, RenderHtml},
26: 24: };
27: 25: 
28: 26: /// Applies ARIA attributes to an HTML element.
29: 27: pub trait AriaAttributes<Rndr, V>
30: 28: where
31: 29:     Self: Sized + AddAnyAttr,
32: 30:     V: AttributeValue,
33: 31: {
34: 32:     /// Identifies the currently active descendant of a composite widget.
35: 33:     fn aria_activedescendant(
36: 34:         self,
37: 35:         value: V,
38: 36:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaActivedescendant, V>> {
39: 37:         self.add_any_attr(aria_activedescendant(value))
40: 38:     }
41: 39: 
42: 40:     /// Indicates whether assistive technologies will present all, or only parts of, the changed region based on the change notifications defined by the `aria-relevant` attribute.
43: 41:     fn aria_atomic(
44: 42:         self,
45: 43:         value: V,
46: 44:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaAtomic, V>> {
47: 45:         self.add_any_attr(aria_atomic(value))
48: 46:     }
49: 47: 
50: 48:     /// Indicates whether user input completion suggestions are provided.
51: 49:     fn aria_autocomplete(
52: 50:         self,
53: 51:         value: V,
54: 52:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaAutocomplete, V>> {
55: 53:         self.add_any_attr(aria_autocomplete(value))
56: 54:     }
57: 55: 
58: 56:     /// Indicates whether an element, and its subtree, are currently being updated.
59: 57:     fn aria_busy(
60: 58:         self,
61: 59:         value: V,
62: 60:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaBusy, V>> {
63: 61:         self.add_any_attr(aria_busy(value))
64: 62:     }
65: 63: 
66: 64:     /// Indicates the current "checked" state of checkboxes, radio buttons, and other widgets.
67: 65:     fn aria_checked(
68: 66:         self,
69: 67:         value: V,
70: 68:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaChecked, V>> {
71: 69:         self.add_any_attr(aria_checked(value))
72: 70:     }
73: 71: 
74: 72:     /// Defines the number of columns in a table, grid, or treegrid.
75: 73:     fn aria_colcount(
76: 74:         self,
77: 75:         value: V,
78: 76:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaColcount, V>> {
79: 77:         self.add_any_attr(aria_colcount(value))
80: 78:     }
81: 79: 
82: 80:     /// Defines an element's column index or position with respect to the total number of columns within a table, grid, or treegrid.
83: 81:     fn aria_colindex(
84: 82:         self,
85: 83:         value: V,
86: 84:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaColindex, V>> {
87: 85:         self.add_any_attr(aria_colindex(value))
88: 86:     }
89: 87: 
90: 88:     /// Defines the number of columns spanned by a cell or gridcell within a table, grid, or treegrid.
91: 89:     fn aria_colspan(
92: 90:         self,
93: 91:         value: V,
94: 92:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaColspan, V>> {
95: 93:         self.add_any_attr(aria_colspan(value))
96: 94:     }
97: 95: 
98: 96:     /// Identifies the element (or elements) whose contents or presence are controlled by the current element.
99: 97:     fn aria_controls(
100: 98:         self,
101: 99:         value: V,
102: 100:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaControls, V>> {
103: 101:         self.add_any_attr(aria_controls(value))
104: 102:     }
105: 103: 
106: 104:     /// Indicates the element that represents the current item within a container or set of related elements.
107: 105:     fn aria_current(
108: 106:         self,
109: 107:         value: V,
110: 108:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaCurrent, V>> {
111: 109:         self.add_any_attr(aria_current(value))
112: 110:     }
113: 111: 
114: 112:     /// Identifies the element (or elements) that describes the object.
115: 113:     fn aria_describedby(
116: 114:         self,
117: 115:         value: V,
118: 116:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaDescribedby, V>> {
119: 117:         self.add_any_attr(aria_describedby(value))
120: 118:     }
121: 119: 
122: 120:     /// Defines a string value that describes or annotates the current element.
123: 121:     fn aria_description(
124: 122:         self,
125: 123:         value: V,
126: 124:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaDescription, V>> {
127: 125:         self.add_any_attr(aria_description(value))
128: 126:     }
129: 127: 
130: 128:     /// Identifies the element that provides additional information related to the object.
131: 129:     fn aria_details(
132: 130:         self,
133: 131:         value: V,
134: 132:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaDetails, V>> {
135: 133:         self.add_any_attr(aria_details(value))
136: 134:     }
137: 135: 
138: 136:     /// Indicates that the element is perceivable but disabled, so it is not editable or otherwise operable.
139: 137:     fn aria_disabled(
140: 138:         self,
141: 139:         value: V,
142: 140:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaDisabled, V>> {
143: 141:         self.add_any_attr(aria_disabled(value))
144: 142:     }
145: 143: 
146: 144:     /// Indicates what functions can be performed when a dragged object is released on the drop target.
147: 145:     fn aria_dropeffect(
148: 146:         self,
149: 147:         value: V,
150: 148:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaDropeffect, V>> {
151: 149:         self.add_any_attr(aria_dropeffect(value))
152: 150:     }
153: 151: 
154: 152:     /// Defines the element that provides an error message related to the object.
155: 153:     fn aria_errormessage(
156: 154:         self,
157: 155:         value: V,
158: 156:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaErrormessage, V>> {
159: 157:         self.add_any_attr(aria_errormessage(value))
160: 158:     }
161: 159: 
162: 160:     /// Indicates whether the element, or another grouping element it controls, is currently expanded or collapsed.
163: 161:     fn aria_expanded(
164: 162:         self,
165: 163:         value: V,
166: 164:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaExpanded, V>> {
167: 165:         self.add_any_attr(aria_expanded(value))
168: 166:     }
169: 167: 
170: 168:     /// Identifies the next element (or elements) in an alternate reading order of content.
171: 169:     fn aria_flowto(
172: 170:         self,
173: 171:         value: V,
174: 172:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaFlowto, V>> {
175: 173:         self.add_any_attr(aria_flowto(value))
176: 174:     }
177: 175: 
178: 176:     /// Indicates an element's "grabbed" state in a drag-and-drop operation.
179: 177:     fn aria_grabbed(
180: 178:         self,
181: 179:         value: V,
182: 180:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaGrabbed, V>> {
183: 181:         self.add_any_attr(aria_grabbed(value))
184: 182:     }
185: 183: 
186: 184:     /// Indicates the availability and type of interactive popup element, such as menu or dialog, that can be triggered by an element.
187: 185:     fn aria_haspopup(
188: 186:         self,
189: 187:         value: V,
190: 188:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaHaspopup, V>> {
191: 189:         self.add_any_attr(aria_haspopup(value))
192: 190:     }
193: 191: 
194: 192:     /// Indicates whether the element is exposed to an accessibility API.
195: 193:     fn aria_hidden(
196: 194:         self,
197: 195:         value: V,
198: 196:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaHidden, V>> {
199: 197:         self.add_any_attr(aria_hidden(value))
200: 198:     }
201: 199: 
202: 200:     /// Indicates the entered value does not conform to the format expected by the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application.
203: 201:     fn aria_invalid(
204: 202:         self,
205: 203:         value: V,
206: 204:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaInvalid, V>> {
207: 205:         self.add_any_attr(aria_invalid(value))
208: 206:     }
209: 207: 
210: 208:     /// Indicates keyboard shortcuts that an author has implemented to activate or give focus to an element.
211: 209:     fn aria_keyshortcuts(
212: 210:         self,
213: 211:         value: V,
214: 212:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaKeyshortcuts, V>> {
215: 213:         self.add_any_attr(aria_keyshortcuts(value))
216: 214:     }
217: 215: 
218: 216:     /// Defines a string value that labels the current element.
219: 217:     fn aria_label(
220: 218:         self,
221: 219:         value: V,
222: 220:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaLabel, V>> {
223: 221:         self.add_any_attr(aria_label(value))
224: 222:     }
225: 223: 
226: 224:     /// Identifies the element (or elements) that labels the current element.
227: 225:     fn aria_labelledby(
228: 226:         self,
229: 227:         value: V,
230: 228:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaLabelledby, V>> {
231: 229:         self.add_any_attr(aria_labelledby(value))
232: 230:     }
233: 231: 
234: 232:     /// Indicates that an element will be updated, and describes the types of updates the user agents, assistive technologies, and user can expect from the live region.
235: 233:     fn aria_live(
236: 234:         self,
237: 235:         value: V,
238: 236:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaLive, V>> {
239: 237:         self.add_any_attr(aria_live(value))
240: 238:     }
241: 239: 
242: 240:     /// Indicates whether an element is modal when displayed.
243: 241:     fn aria_modal(
244: 242:         self,
245: 243:         value: V,
246: 244:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaModal, V>> {
247: 245:         self.add_any_attr(aria_modal(value))
248: 246:     }
249: 247: 
250: 248:     /// Indicates whether a text box accepts multiple lines of input or only a single line.
251: 249:     fn aria_multiline(
252: 250:         self,
253: 251:         value: V,
254: 252:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaMultiline, V>> {
255: 253:         self.add_any_attr(aria_multiline(value))
256: 254:     }
257: 255: 
258: 256:     /// Indicates that the user may select more than one item from the current selectable descendants.
259: 257:     fn aria_multiselectable(
260: 258:         self,
261: 259:         value: V,
262: 260:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaMultiselectable, V>> {
263: 261:         self.add_any_attr(aria_multiselectable(value))
264: 262:     }
265: 263: 
266: 264:     /// Indicates whether the element's orientation is horizontal, vertical, or undefined.
267: 265:     fn aria_orientation(
268: 266:         self,
269: 267:         value: V,
270: 268:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaOrientation, V>> {
271: 269:         self.add_any_attr(aria_orientation(value))
272: 270:     }
273: 271: 
274: 272:     /// Identifies an element (or elements) in order to define a visual, functional, or contextual parent/child relationship between DOM elements where the DOM hierarchy cannot be used to represent the relationship.
275: 273:     fn aria_owns(
276: 274:         self,
277: 275:         value: V,
278: 276:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaOwns, V>> {
279: 277:         self.add_any_attr(aria_owns(value))
280: 278:     }
281: 279: 
282: 280:     /// Defines a short hint (a word or short phrase) intended to help the user with data entry when the control has no value.
283: 281:     fn aria_placeholder(
284: 282:         self,
285: 283:         value: V,
286: 284:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaPlaceholder, V>> {
287: 285:         self.add_any_attr(aria_placeholder(value))
288: 286:     }
289: 287: 
290: 288:     /// Defines an element's number or position in the current set of listitems or treeitems.
291: 289:     fn aria_posinset(
292: 290:         self,
293: 291:         value: V,
294: 292:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaPosinset, V>> {
295: 293:         self.add_any_attr(aria_posinset(value))
296: 294:     }
297: 295: 
298: 296:     /// Indicates the current "pressed" state of toggle buttons.
299: 297:     fn aria_pressed(
300: 298:         self,
301: 299:         value: V,
302: 300:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaPressed, V>> {
303: 301:         self.add_any_attr(aria_pressed(value))
304: 302:     }
305: 303: 
306: 304:     /// Indicates that the element is not editable, but is otherwise operable.
307: 305:     fn aria_readonly(
308: 306:         self,
309: 307:         value: V,
310: 308:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaReadonly, V>> {
311: 309:         self.add_any_attr(aria_readonly(value))
312: 310:     }
313: 311: 
314: 312:     /// Indicates what notifications the user agent will trigger when the accessibility tree within a live region is modified.
315: 313:     fn aria_relevant(
316: 314:         self,
317: 315:         value: V,
318: 316:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaRelevant, V>> {
319: 317:         self.add_any_attr(aria_relevant(value))
320: 318:     }
321: 319: 
322: 320:     /// Indicates that user input is required on the element before a form may be submitted.
323: 321:     fn aria_required(
324: 322:         self,
325: 323:         value: V,
326: 324:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaRequired, V>> {
327: 325:         self.add_any_attr(aria_required(value))
328: 326:     }
329: 327: 
330: 328:     /// Defines a human-readable, author-localized description for the role of an element.
331: 329:     fn aria_roledescription(
332: 330:         self,
333: 331:         value: V,
334: 332:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaRoledescription, V>> {
335: 333:         self.add_any_attr(aria_roledescription(value))
336: 334:     }
337: 335: 
338: 336:     /// Defines the total number of rows in a table, grid, or treegrid.
339: 337:     fn aria_rowcount(
340: 338:         self,
341: 339:         value: V,
342: 340:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaRowcount, V>> {
343: 341:         self.add_any_attr(aria_rowcount(value))
344: 342:     }
345: 343: 
346: 344:     /// Defines an element's row index or position with respect to the total number of rows within a table, grid, or treegrid.
347: 345:     fn aria_rowindex(
348: 346:         self,
349: 347:         value: V,
350: 348:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaRowindex, V>> {
351: 349:         self.add_any_attr(aria_rowindex(value))
352: 350:     }
353: 351: 
354: 352:     /// Defines the number of rows spanned by a cell or gridcell within a table, grid, or treegrid.
355: 353:     fn aria_rowspan(
356: 354:         self,
357: 355:         value: V,
358: 356:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaRowspan, V>> {
359: 357:         self.add_any_attr(aria_rowspan(value))
360: 358:     }
361: 359: 
362: 360:     /// Indicates the current "selected" state of various widgets.
363: 361:     fn aria_selected(
364: 362:         self,
365: 363:         value: V,
366: 364:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaSelected, V>> {
367: 365:         self.add_any_attr(aria_selected(value))
368: 366:     }
369: 367: 
370: 368:     /// Defines the number of items in the current set of listitems or treeitems.
371: 369:     fn aria_setsize(
372: 370:         self,
373: 371:         value: V,
374: 372:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaSetsize, V>> {
375: 373:         self.add_any_attr(aria_setsize(value))
376: 374:     }
377: 375: 
378: 376:     /// Indicates if items in a table or grid are sorted in ascending or descending order.
379: 377:     fn aria_sort(
380: 378:         self,
381: 379:         value: V,
382: 380:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaSort, V>> {
383: 381:         self.add_any_attr(aria_sort(value))
384: 382:     }
385: 383: 
386: 384:     /// Defines the maximum allowed value for a range widget.
387: 385:     fn aria_valuemax(
388: 386:         self,
389: 387:         value: V,
390: 388:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaValuemax, V>> {
391: 389:         self.add_any_attr(aria_valuemax(value))
392: 390:     }
393: 391: 
394: 392:     /// Defines the minimum allowed value for a range widget.
395: 393:     fn aria_valuemin(
396: 394:         self,
397: 395:         value: V,
398: 396:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaValuemin, V>> {
399: 397:         self.add_any_attr(aria_valuemin(value))
400: 398:     }
401: 399: 
402: 400:     /// Defines the current value for a range widget.
403: 401:     fn aria_valuenow(
404: 402:         self,
405: 403:         value: V,
406: 404:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaValuenow, V>> {
407: 405:         self.add_any_attr(aria_valuenow(value))
408: 406:     }
409: 407: 
410: 408:     /// Defines the human-readable text alternative of `aria-valuenow` for a range widget.
411: 409:     fn aria_valuetext(
412: 410:         self,
413: 411:         value: V,
414: 412:     ) -> <Self as AddAnyAttr>::Output<Attr<AriaValuetext, V>> {
415: 413:         self.add_any_attr(aria_valuetext(value))
416: 414:     }
417: 415: }
418: 416: 
419: 417: impl<El, At, Ch, V> AriaAttributes<Rndr, V> for HtmlElement<El, At, Ch>
420: 418: where
421: 419:     El: ElementType + Send,
422: 420:     At: Attribute + Send,
423: 421:     Ch: RenderHtml + Send,
424: 422:     V: AttributeValue,
425: 423: {
426: 424: }
427: 425: ```
428: 426: ```
429: 427: ```
430: 428: ```
431: 429: ```
432: 430: ```
433: 431: ```
434: 432: ```
435: ```
```
