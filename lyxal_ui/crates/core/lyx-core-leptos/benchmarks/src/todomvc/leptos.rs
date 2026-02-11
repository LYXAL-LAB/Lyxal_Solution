### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_benchmarks\src\todomvc\lyx-core-lyx_core_leptos.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_benchmarks\src\todomvc\lyx-core-lyx_core_lyx-core-lyx_core_leptos.rs
2: ```rust
3: 1: pub use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
4: 2: use miniserde::*;
5: 3: use wasm_bindgen::JsCast;
6: 4: use web_sys::HtmlInputElement;
7: 5: 
8: 6: #[derive(Debug, Clone, PartialEq, Eq)]
9: 7: pub struct Todos(pub Vec<Todo>);
10: 8: 
11: 9: const STORAGE_KEY: &str = "todos-lyx-core-lyx_core_lyx-core-lyx_core_leptos";
12: 10: 
13: 11: impl Todos {
14: 12:     pub fn new() -> Self {
15: 13:         Self(vec![])
16: 14:     }
17: 15: 
18: 16:     pub fn new_with_1000() -> Self {
19: 17:         let todos = (0..1000)
20: 18:             .map(|id| Todo::new(id, format!("Todo #{id}")))
21: 19:             .collect();
22: 20:         Self(todos)
23: 21:     }
24: 22: 
25: 23:     pub fn is_empty(&self) -> bool {
26: 24:         self.0.is_empty()
27: 25:     }
28: 26: 
29: 27:     pub fn add(&mut self, todo: Todo) {
30: 28:         self.0.push(todo);
31: 29:     }
32: 30: 
33: 31:     pub fn remove(&mut self, id: usize) {
34: 32:         self.0.retain(|todo| todo.id != id);
35: 33:     }
36: 34: 
37: 35:     pub fn remaining(&self) -> usize {
38: 36:         self.0.iter().filter(|todo| !(todo.completed)()).count()
39: 37:     }
40: 38: 
41: 39:     pub fn completed(&self) -> usize {
42: 40:         self.0.iter().filter(|todo| (todo.completed)()).count()
43: 41:     }
44: 42: 
45: 43:     pub fn toggle_all(&self) {
46: 44:         // if all are complete, mark them all active instead
47: 45:         if self.remaining() == 0 {
48: 46:             for todo in &self.0 {
49: 47:                 if todo.completed.get() {
50: 48:                     (todo.set_completed)(false);
51: 49:                 }
52: 50:             }
53: 51:         }
54: 52:         // otherwise, mark them all complete
55: 53:         else {
56: 54:             for todo in &self.0 {
57: 55:                 (todo.set_completed)(true);
58: 56:             }
59: 57:         }
60: 58:     }
61: 59: 
62: 60:     fn clear_completed(&mut self) {
63: 61:         self.0.retain(|todo| !todo.completed.get());
64: 62:     }
65: 63: }
66: 64: 
67: 65: #[derive(Debug, PartialEq, Eq, Clone)]
68: 66: pub struct Todo {
69: 67:     pub id: usize,
70: 68:     pub title: ReadSignal<String>,
71: 69:     pub set_title: WriteSignal<String>,
72: 70:     pub completed: ReadSignal<bool>,
73: 71:     pub set_completed: WriteSignal<bool>,
74: 72: }
75: 73: 
76: 74: impl Todo {
77: 75:     pub fn new(id: usize, title: String) -> Self {
78: 76:         Self::new_with_completed(id, title, false)
79: 77:     }
80: 78: 
81: 79:     pub fn new_with_completed(
82: 80:         id: usize,
83: 81:         title: String,
84: 82:         completed: bool,
85: 83:     ) -> Self {
86: 84:         let (title, set_title) = create_signal(title);
87: 85:         let (completed, set_completed) = create_signal(completed);
88: 86:         Self {
89: 87:             id,
90: 88:             title,
91: 89:             set_title,
92: 90:             completed,
93: 91:             set_completed,
94: 92:         }
95: 93:     }
96: 94: 
97: 95:     pub fn toggle(&self) {
98: 96:         self.set_completed
99: 97:             .update(|completed| *completed = !*completed);
100: 98:     }
101: 99: }
102: 100: 
103: 101: const ESCAPE_KEY: u32 = 27;
104: 102: const ENTER_KEY: u32 = 13;
105: 103: 
106: 104: #[component]
107: 105: pub fn TodoMVC(todos: Todos) -> impl IntoView {
108: 106:     let mut next_id = todos
109: 107:         .0
110: 108:         .iter()
111: 109:         .map(|todo| todo.id)
112: 110:         .max()
113: 111:         .map(|last| last + 1)
114: 112:         .unwrap_or(0);
115: 113: 
116: 114:     let (todos, set_todos) = create_signal(todos);
117: 115:     provide_context(set_todos);
118: 116: 
119: 117:     let (mode, set_mode) = create_signal(Mode::All);
120: 118: 
121: 119:     let add_todo = move |ev: web_sys::KeyboardEvent| {
122: 120:         let target = event_target::<HtmlInputElement>(&ev);
123: 121:         ev.stop_propagation();
124: 122:         let key_code = ev.unchecked_ref::<web_sys::KeyboardEvent>().key_code();
125: 123:         if key_code == ENTER_KEY {
126: 124:             let title = event_target_value(&ev);
127: 125:             let title = title.trim();
128: 126:             if !title.is_empty() {
129: 127:                 let new = Todo::new(next_id, title.to_string());
130: 128:                 set_todos.update(|t| t.add(new));
131: 129:                 next_id += 1;
132: 130:                 target.set_value("");
133: 131:             }
134: 132:         }
135: 133:     };
136: 134: 
137: 135:     let filtered_todos = create_memo::<Vec<Todo>>(move |_| {
138: 136:         todos.with(|todos| match mode.get() {
139: 137:             Mode::All => todos.0.to_vec(),
140: 138:             Mode::Active => todos
141: 139:                 .0
142: 140:                 .iter()
143: 141:                 .filter(|todo| !todo.completed.get())
144: 142:                 .cloned()
145: 143:                 .collect(),
146: 144:             Mode::Completed => todos
147: 145:                 .0
148: 146:                 .iter()
149: 147:                 .filter(|todo| todo.completed.get())
150: 148:                 .cloned()
151: 149:                 .collect(),
152: 150:         })
153: 151:     });
154: 152: 
155: 153:     // effect to serialize to JSON
156: 154:     // this does reactive reads, so it will automatically serialize on any relevant change
157: 155:     create_effect(move |_| {
158: 156:         if let Ok(Some(storage)) = window().local_storage() {
159: 157:             let objs = todos
160: 158:                 .get()
161: 159:                 .0
162: 160:                 .iter()
163: 161:                 .map(TodoSerialized::from)
164: 162:                 .collect::<Vec<_>>();
165: 163:             let json = json::to_string(&objs);
166: 164:             if storage.set_item(STORAGE_KEY, &json).is_err() {
167: 165:                 log::error!("error while trying to set item in localStorage");
168: 166:             }
169: 167:         }
170: 168:     });
171: 169: 
172: 170:     view! { 
173: 171:         <main>
174: 172:             <section class="todolyx-platform-lyx_platform_lyx-platform-lyx_platform_app">
175: 173:                 <header class="header">
176: 174:                     <h1>"todos"</h1>
177: 175:                     <input
178: 176:                         class="new-todo"
179: 177:                         placeholder="What needs to be done?"
180: 178:                         autofocus=""
181: 179:                         on:keydown=add_todo
182: 180:                     />
183: 181:                 </header>
184: 182:                 <section class="main" class:hidden=move || todos.with(|t| t.is_empty())>
185: 183:                     <input
186: 184:                         id="toggle-all"
187: 185:                         class="toggle-all"
188: 186:                         type="checkbox"
189: 187:                         prop:checked=move || todos.with(|t| t.remaining() > 0)
190: 188:                         on:input=move |_| set_todos.update(|t| t.toggle_all())
191: 189:                     />
192: 190:                     <label for="toggle-all">"Mark all as complete"</label>
193: 191:                     <ul class="todo-list">
194: 192:                         <For
195: 193:                             each=filtered_todos
196: 194:                             key=|todo| todo.id
197: 195:                             children=move |todo: Todo| {
198: 196:                                 view! { <Todo todo=todo.clone()/> }
199: 197:                             }
200: 198:                         />
201: 199:                     </ul>
202: 200:                 </section>
203: 201:                 <footer class="footer" class:hidden=move || todos.with(|t| t.is_empty())>
204: 202:                     <span class="todo-count">
205: 203:                         <strong>{move || todos.with(|t| t.remaining().to_string())}</strong>
206: 204:                         {move || if todos.with(|t| t.remaining()) == 1 { " item" } else { " items" }}
207: 205:                         " left"
208: 206:                     </span>
209: 207:                     <ul class="filters">
210: 208:                         <li>
211: 209:                             <a
212: 210:                                 href="#/"
213: 211:                                 class="selected"
214: 212:                                 class:selected=move || mode() == Mode::All
215: 213:                             >
216: 214:                                 "All"
217: 215:                             </a>
218: 216:                         </li>
219: 217:                         <li>
220: 218:                             <a href="#/active" class:selected=move || mode() == Mode::Active>
221: 219:                                 "Active"
222: 220:                             </a>
223: 221:                         </li>
224: 222:                         <li>
225: 223:                             <a href="#/completed" class:selected=move || mode() == Mode::Completed>
226: 224:                                 "Completed"
227: 225:                             </a>
228: 226:                         </li>
229: 227:                     </ul>
230: 228:                     <button
231: 229:                         class="clear-completed hidden"
232: 230:                         class:hidden=move || todos.with(|t| t.completed() == 0)
233: 231:                         on:click=move |_| set_todos.update(|t| t.clear_completed())
234: 232:                     >
235: 233:                         "Clear completed"
236: 234:                     </button>
237: 235:                 </footer>
238: 236:             </section>
239: 237:             <footer class="info">
240: 238:                 <p>"Double-click to edit a todo"</p>
241: 239:                 <p>"Created by " <a href="http://todomvc.com">"Greg Johnston"</a></p>
242: 240:                 <p>"Part of " <a href="http://todomvc.com">"TodoMVC"</a></p>
243: 241:             </footer>
244: 242:         </main>
245: 243:     }.into_view()
246: 244: }
247: 245: 
248: 246: #[component]
249: 247: pub fn Todo(todo: Todo) -> impl IntoView {
250: 248:     let (editing, set_editing) = create_signal(false);
251: 249:     let set_todos = use_context::<WriteSignal<Todos>>().unwrap();
252: 250:     //let input = NodeRef::new();
253: 251: 
254: 252:     let save = move |value: &str| {
255: 253:         let value = value.trim();
256: 254:         if value.is_empty() {
257: 255:             set_todos.update(|t| t.remove(todo.id));
258: 256:         } else {
259: 257:             (todo.set_title)(value.to_string());
260: 258:         }
261: 259:         set_editing(false);
262: 260:     };
263: 261: 
264: 262:     view! { 
265: 263:         <li class="todo" class:editing=editing class:completed=move || (todo.completed)()>
266: 264:             <div class="view">
267: 265:                 <input class="toggle" type="checkbox" prop:checked=move || (todo.completed)()/>
268: 266:                 <label on:dblclick=move |_| set_editing(true)>{move || todo.title.get()}</label>
269: 267:                 <button
270: 268:                     class="destroy"
271: 269:                     on:click=move |_| set_todos.update(|t| t.remove(todo.id))
272: 270:                 ></button>
273: 271:             </div>
274: 272:             {move || {
275: 273:                 editing()
276: 274:                     .then(|| {
277: 275:                         view! { 
278: 276:                             <input
279: 277:                                 class="edit"
280: 278:                                 class:hidden=move || !(editing)()
281: 279:                                 prop:value=move || todo.title.get()
282: 280:                                 on:focusout=move |ev| save(&event_target_value(&ev))
283: 281:                                 on:keyup=move |ev| {
284: 282:                                     let key_code = ev.unchecked_ref::<web_sys::KeyboardEvent>().key_code();
285: 283:                                     if key_code == ENTER_KEY {
286: 284:                                         save(&event_target_value(&ev));
287: 285:                                     } else if key_code == ESCAPE_KEY {
288: 286:                                         set_editing(false);
289: 287:                                     }
290: 288:                                 }
291: 289:                             />
292: 290:                         }
293: 291:                     })
294: 292:             }}
295: 293:         </li>
296: 294:     }
297: 295: }
298: 296: 
299: 297: #[derive(Debug, Clone, Copy, PartialEq, Eq)]
300: 298: pub enum Mode {
301: 299:     Active,
302: 300:     Completed,
303: 301:     All,
304: 302: }
305: 303: 
306: 304: impl Default for Mode {
307: 305:     fn default() -> Self {
308: 306:         Mode::All
309: 307:     }
310: 308: }
311: 309: 
312: 310: pub fn route(hash: &str) -> Mode {
313: 311:     match hash {
314: 312:         "/active" => Mode::Active,
315: 313:         "/completed" => Mode::Completed,
316: 314:         _ => Mode::All,
317: 315:     }
318: 316: }
319: 317: 
320: 318: #[derive(Serialize, Deserialize)]
321: 319: pub struct TodoSerialized {
322: 320:     pub id: usize,
323: 321:     pub title: String,
324: 322:     pub completed: bool,
325: 323: }
326: 324: 
327: 325: impl TodoSerialized {
328: 326:     pub fn into_todo(self, ) -> Todo {
329: 327:         Todo::new_with_completed(self.id, self.title, self.completed)
330: 328:     }
331: 329: }
332: 330: 
333: 331: impl From<&Todo> for TodoSerialized {
334: 332:     fn from(todo: &Todo) -> Self {
335: 333:         Self {
336: 334:             id: todo.id,
337: 335:             title: todo.title.get(),
338: 336:             completed: (todo.completed)(),
339: 337:         }
340: 338:     }
341: 339: }
342: ```
```
