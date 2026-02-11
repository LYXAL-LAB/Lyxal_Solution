### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_benchmarks\src\todomvc\sycamore.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_benchmarks\src\todomvc\sycamore.rs
2: ```rust
3: 1: use serde::{Deserialize, Serialize};
4: 2: use sycamore::prelude::*;
5: 3: use uuid::Uuid;
6: 4: use wasm_bindgen::JsCast;
7: 5: use web_sys::{Event, HtmlInputElement, KeyboardEvent};
8: 6: 
9: 7: #[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq, Hash)]
10: 8: pub struct Todo {
11: 9:     title: String,
12: 10:     completed: bool,
13: 11:     id: usize,
14: 12: }
15: 13: 
16: 14: #[derive(Debug, Clone, Copy, PartialEq, Eq)]
17: 15: pub enum Filter {
18: 16:     All,
19: 17:     Active,
20: 18:     Completed,
21: 19: }
22: 20: 
23: 21: impl Default for Filter {
24: 22:     fn default() -> Self {
25: 23:         Self::All
26: 24:     }
27: 25: }
28: 26: 
29: 27: impl Filter {
30: 28:     fn url(self) -> &'static str {
31: 29:         match self {
32: 30:             Filter::All => "#",
33: 31:             Filter::Active => "#/active",
34: 32:             Filter::Completed => "#/completed",
35: 33:         }
36: 34:     }
37: 35: 
38: 36:     fn get_filter_from_hash() -> Self {
39: 37:         let hash = web_sys::window().unwrap().location().hash().unwrap();
40: 38: 
41: 39:         match hash.as_str() {
42: 40:             "#/active" => Filter::Active,
43: 41:             "#/completed" => Filter::Completed,
44: 42:             _ => Filter::All,
45: 43:         }
46: 44:     }
47: 45: }
48: 46: 
49: 47: #[derive(Debug, Default, Clone)]
50: 48: pub struct AppState {
51: 49:     pub todos: RcSignal<Vec<RcSignal<Todo>>>,
52: 50:     pub filter: RcSignal<Filter>,
53: 51: }
54: 52: 
55: 53: impl AppState {
56: 54:     fn add_todo(&self, title: String, id: usize) {
57: 55:         self.todos.modify().push(create_rc_signal(Todo {
58: 56:             title,
59: 57:             completed: false,
60: 58:             id,
61: 59:         }))
62: 60:     }
63: 61: 
64: 62:     fn remove_todo(&self, id: usize) {
65: 63:         self.todos.modify().retain(|todo| todo.get().id != id);
66: 64:     }
67: 65: 
68: 66:     fn todos_left(&self) -> usize {
69: 67:         self.todos.get().iter().fold(
70: 68:             0,
71: 69:             |acc, todo| if todo.get().completed { acc } else { acc + 1 },
72: 70:         )
73: 71:     }
74: 72: 
75: 73:     fn toggle_complete_all(&self) {
76: 74:         if self.todos_left() == 0 {
77: 75:             // make all todos active
78: 76:             for todo in self.todos.get().iter() {
79: 77:                 if todo.get().completed {
80: 78:                     todo.set(Todo {
81: 79:                         completed: false,
82: 80:                         ..todo.get().as_ref().clone()
83: 81:                     })
84: 82:                 }
85: 83:             }
86: 84:         } else {
87: 85:             // make all todos completed
88: 86:             for todo in self.todos.get().iter() {
89: 87:                 if !todo.get().completed {
90: 88:                     todo.set(Todo {
91: 89:                         completed: true,
92: 90:                         ..todo.get().as_ref().clone()
93: 91:                     })
94: 92:                 }
95: 93:             }
96: 94:         }
97: 95:     }
98: 96: 
99: 97:     fn clear_completed(&self) {
100: 98:         self.todos.modify().retain(|todo| !todo.get().completed);
101: 99:     }
102: 100: }
103: 101: 
104: 102: const KEY: &str = "todos-sycamore";
105: 103: 
106: 104: #[component]
107: 105: pub fn App<G: Html>(cx: Scope) -> View<G> {
108: 106:     // Initialize lyx-platform-lyx_platform_lyx-platform-lyx_platform_application state
109: 107:     let todos = create_rc_signal(Vec::new());
110: 108:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = AppState {
111: 109:         todos,
112: 110:         filter: create_rc_signal(Filter::All),
113: 111:     };
114: 112:     provide_context(cx, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state);
115: 113: 
116: 114:     view! { cx,
117: 115:         div(class="todomvc-wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper") {
118: 116:             section(class="todolyx-platform-lyx_platform_lyx-platform-lyx_platform_app") {
119: 117:                 Header {}
120: 118:                 List {}
121: 119:                 Footer {}
122: 120:             }
123: 121:             Copyright {}
124: 122:         }
125: 123:     }
126: 124: }
127: 125: 
128: 126: #[component]
129: 127: pub fn AppWith1000<G: Html>(cx: Scope) -> View<G> {
130: 128:     // Initialize lyx-platform-lyx_platform_lyx-platform-lyx_platform_application state
131: 129:     let todos = (0..1000)
132: 130:         .map(|id| {
133: 131:             create_rc_signal(Todo {
134: 132:                 title: format!("Todo #{id}"),
135: 133:                 completed: false,
136: 134:                 id,
137: 135:             })
138: 136:         })
139: 137:         .collect();
140: 138:     let todos = create_rc_signal(todos);
141: 139:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = AppState {
142: 140:         todos,
143: 141:         filter: create_rc_signal(Filter::All),
144: 142:     };
145: 143:     provide_context(cx, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state);
146: 144: 
147: 145:     view! { cx,
148: 146:         div(class="todomvc-wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper") {
149: 147:             section(class="todolyx-platform-lyx_platform_lyx-platform-lyx_platform_app") {
150: 148:                 Header {}
151: 149:                 List {}
152: 150:                 Footer {}
153: 151:             }
154: 152:             Copyright {}
155: 153:         }
156: 154:     }
157: 155: }
158: 156: 
159: 157: #[component]
160: 158: pub fn Copyright<G: Html>(cx: Scope) -> View<G> {
161: 159:     view! { cx,
162: 160:         footer(class="info") {
163: 161:             p { "Double click to edit a todo" }
164: 162:             p {
165: 163:                 "Created by "
166: 164:                 a(href="https://github.com/lukechu10", target="_blank") { "lukechu10" }
167: 165:             }
168: 166:             p {
169: 167:                 "Part of "
170: 168:                 a(href="http://todomvc.com") { "TodoMVC" }
171: 169:             }
172: 170:         }
173: 171:     }
174: 172: }
175: 173: 
176: 174: #[component]
177: 175: pub fn Header<G: Html>(cx: Scope) -> View<G> {
178: 176:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = use_context::<AppState>(cx);
179: 177:     let value = create_signal(cx, String::new());
180: 178:     let input_ref = create_node_ref(cx);
181: 179: 
182: 180:     let handle_submit = |event: Event| {
183: 181:         let event: KeyboardEvent = event.unchecked_into();
184: 182: 
185: 183:         if event.key() == "Enter" {
186: 184:             let mut task = value.get().as_ref().clone();
187: 185:             task = task.trim().to_string();
188: 186: 
189: 187:             if !task.is_empty() {
190: 188:                 lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.add_todo(task, 0);
191: 189:                 value.set("".to_string());
192: 190:                 input_ref
193: 191:                     .get::<DomNode>()
194: 192:                     .unchecked_into::<HtmlInputElement>()
195: 193:                     .set_value("");
196: 194:             }
197: 195:         }
198: 196:     };
199: 197: 
200: 198:     view! { cx,
201: 199:         header(class="header") {
202: 200:             h1 { "todos" }
203: 201:             input(ref=input_ref,
204: 202:                 class="new-todo",
205: 203:                 placeholder="What needs to be done?",
206: 204:                 bind:value=value,
207: 205:                 on:keyup=handle_submit,
208: 206:             )
209: 207:         }
210: 208:     }
211: 209: }
212: 210: 
213: 211: #[component(inline_props)]
214: 212: pub fn Item<G: Html>(cx: Scope, todo: RcSignal<Todo>) -> View<G> {
215: 213:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = use_context::<AppState>(cx);
216: 214:     // Make `todo` live as long as the scope.
217: 215:     let todo = create_ref(cx, todo);
218: 216: 
219: 217:     let title = || todo.get().title.clone();
220: 218:     let completed = create_selector(cx, || todo.get().completed);
221: 219:     let id = todo.get().id;
222: 220: 
223: 221:     let editing = create_signal(cx, false);
224: 222:     let input_ref = create_node_ref(cx);
225: 223:     let value = create_signal(cx, "".to_string());
226: 224: 
227: 225:     let handle_input = |event: Event| {
228: 226:         let target: HtmlInputElement = event.target().unwrap().unchecked_into();
229: 227:         value.set(target.value());
230: 228:     };
231: 229: 
232: 230:     let toggle_completed = |_| {
233: 231:         todo.set(Todo {
234: 232:             completed: !todo.get().completed,
235: 233:             ..todo.get().as_ref().clone()
236: 234:         });
237: 235:     };
238: 236: 
239: 237:     let handle_dblclick = move |_| {
240: 238:         editing.set(true);
241: 239:         input_ref
242: 240:             .get::<DomNode>()
243: 241:             .unchecked_into::<HtmlInputElement>()
244: 242:             .focus()
245: 243:             .unwrap();
246: 244:         value.set(title());
247: 245:     };
248: 246: 
249: 247:     let handle_blur = move || {
250: 248:         editing.set(false);
251: 249: 
252: 250:         let mut value = value.get().as_ref().clone();
253: 251:         value = value.trim().to_string();
254: 252: 
255: 253:         if value.is_empty() {
256: 254:             lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.remove_todo(id);
257: 255:         } else {
258: 256:             todo.set(Todo {
259: 257:                 title: value,
260: 258:                 ..todo.get().as_ref().clone()
261: 259:             })
262: 260:         }
263: 261:     };
264: 262: 
265: 263:     let handle_submit = move |event: Event| {
266: 264:         let event: KeyboardEvent = event.unchecked_into();
267: 265:         match event.key().as_str() {
268: 266:             "Enter" => handle_blur(),
269: 267:             "Escape" => {
270: 268:                 input_ref
271: 269:                     .get::<DomNode>()
272: 270:                     .unchecked_into::<HtmlInputElement>()
273: 271:                     .set_value(&title());
274: 272:                 editing.set(false);
275: 273:             }
276: 274:             _ => {}
277: 275:         }
278: 276:     };
279: 277: 
280: 278:     let handle_destroy = move |_| {
281: 279:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.remove_todo(id);
282: 280:     };
283: 281: 
284: 282:     // We need a separate signal for checked because clicking the checkbox will detach the binding
285: 283:     // between the attribute and the view.
286: 284:     let checked = create_signal(cx, false);
287: 285:     create_effect(cx, || {
288: 286:         // Calling checked.set will also update the `checked` property on the input element.
289: 287:         checked.set(*completed.get())
290: 288:     });
291: 289: 
292: 290:     let class = || {
293: 291:         format!(
294: 292:             "{} {}",
295: 293:             if *completed.get() { "completed" } else { "" },
296: 294:             if *editing.get() { "editing" } else { "" }
297: 295:         )
298: 296:     };
299: 297: 
300: 298:     view! { cx,
301: 299:         li(class=class()) {
302: 300:             div(class="view") {
303: 301:                 input(
304: 302:                     class="toggle",
305: 303:                     type="checkbox",
306: 304:                     on:input=toggle_completed,
307: 305:                     bind:checked=checked
308: 306:                 )
309: 307:                 label(on:dblclick=handle_dblclick) {
310: 308:                     (title())
311: 309:                 }
312: 310:                 button(class="destroy", on:click=handle_destroy)
313: 311:             }
314: 312: 
315: 313:             (if *editing.get() {
316: 314:                 view! { cx,
317: 315:                     input(ref=input_ref,
318: 316:                         class="edit",
319: 317:                         prop:value=&todo.get().title,
320: 318:                         on:blur=move |_| handle_blur(),
321: 319:                         on:keyup=handle_submit,
322: 320:                         on:input=handle_input,
323: 321:                     )
324: 322:                 }
325: 323:             } else {
326: 324:                 View::empty()
327: 325:             })
328: 326:         }
329: 327:     }
330: 328: }
331: 329: 
332: 330: #[component]
333: 331: pub fn List<G: Html>(cx: Scope) -> View<G> {
334: 332:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = use_context::<AppState>(cx);
335: 333:     let todos_left = create_selector(cx, || lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.todos_left());
336: 334: 
337: 335:     let filtered_todos = create_memo(cx, || {
338: 336:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state
339: 337:             .todos
340: 338:             .get()
341: 339:             .iter()
342: 340:             .filter(|todo| match *lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.filter.get() {
343: 341:                 Filter::All => true,
344: 342:                 Filter::Active => !todo.get().completed,
345: 343:                 Filter::Completed => todo.get().completed,
346: 344:             })
347: 345:             .cloned()
348: 346:             .collect::<Vec<_>>()
349: 347:     });
350: 348: 
351: 349:     // We need a separate signal for checked because clicking the checkbox will detach the binding
352: 350:     // between the attribute and the view.
353: 351:     let checked = create_signal(cx, false);
354: 352:     create_effect(cx, || {
355: 353:         // Calling checked.set will also update the `checked` property on the input element.
356: 354:         checked.set(*todos_left.get() == 0)
357: 355:     });
358: 356: 
359: 357:     view! { cx,
360: 358:         section(class="main") {
361: 359:             input(
362: 360:                 id="toggle-all",
363: 361:                 class="toggle-all",
364: 362:                 type="checkbox",
365: 363:                 readonly=true,
366: 364:                 bind:checked=checked,
367: 365:                 on:input=|_| lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.toggle_complete_all()
368: 366:             )
369: 367:             label(for="toggle-all")
370: 368: 
371: 369:             ul(class="todo-list") {
372: 370:                 Keyed(
373: 371:                     iterable=filtered_todos,
374: 372:                     view=|cx, todo| view! { cx,
375: 373:                         Item(todo=todo)
376: 374:                     },
377: 375:                     key=|todo| todo.get().id,
378: 376:                 )
379: 377:             }
380: 378:         }
381: 379:     }
382: 380: }
383: 381: 
384: 382: #[component(inline_props)]
385: 383: pub fn TodoFilter<G: Html>(cx: Scope, filter: Filter) -> View<G> {
386: 384:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = use_context::<AppState>(cx);
387: 385:     let selected = move || filter == *lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.filter.get();
388: 386:     let set_filter = |filter| lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.filter.set(filter);
389: 387: 
390: 388:     view! { cx,
391: 389:         li {
392: 390:             a(
393: 391:                 class=if selected() { "selected" } else { "" },
394: 392:                 href=filter.url(),
395: 393:                 on:click=move |_| set_filter(filter),
396: 394:             ) {
397: 395:                 (format!("{filter:?}"))
398: 396:             }
399: 397:         }
400: 398:     }
401: 399: }
402: 400: 
403: 401: #[component]
404: 402: pub fn Footer<G: Html>(cx: Scope) -> View<G> {
405: 403:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state = use_context::<AppState>(cx);
406: 404: 
407: 405:     let items_text = || match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.todos_left() {
408: 406:         1 => "item",
409: 407:         _ => "items",
410: 408:     };
411: 409: 
412: 410:     let has_completed_todos =
413: 411:         create_selector(cx, || lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.todos_left() < lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.todos.get().len());
414: 412: 
415: 413:     let handle_clear_completed = |_| lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.clear_completed();
416: 414: 
417: 415:     view! { cx,
418: 416:         footer(class="footer") {
419: 417:             span(class="todo-count") {
420: 418:                 strong { (lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.todos_left()) }
421: 419:                 span { " " (items_text()) " left" }
422: 420:             }
423: 421:             ul(class="filters") {
424: 422:                 TodoFilter(filter=Filter::All)
425: 423:                 TodoFilter(filter=Filter::Active)
426: 424:                 TodoFilter(filter=Filter::Completed)
427: 425:             }
428: 426: 
429: 427:             (if *has_completed_todos.get() {
430: 428:                 view! { cx,
431: 429:                     button(class="clear-completed", on:click=handle_clear_completed) {
432: 430:                         "Clear completed"
433: 431:                     }
434: 432:                 }
435: 433:             } else {
436: 434:                 view! { cx, }
437: 435:             })
438: 436:         }
439: 437:     }
440: 438: }
441: ```
```
