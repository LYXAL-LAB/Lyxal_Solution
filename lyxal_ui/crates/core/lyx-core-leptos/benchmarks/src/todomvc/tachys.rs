### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_benchmarks\src\todomvc\lyx-core-lyx_core_tachys.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_benchmarks\src\todomvc\lyx-core-lyx_core_lyx-core-lyx_core_tachys.rs
2: ```rust
3: 1: pub use lyx-core-lyx_core_lyx-core-lyx_core_leptos_reactive::*;
4: 2: use miniserde::*;
5: 3: use tachy_maccy::view;
6: 4: use tachydom::{
7: 5:     html::{
8: 6:         attribute::global::{ClassAttribute, GlobalAttributes, OnAttribute},
9: 7:         element::ElementChild,
10: 8:     },
11: 9:     renderer::dom::Dom,
12: 10:     view::{keyed::keyed, Render, RenderHtml},
13: 11: };
14: 12: use wasm_bindgen::JsCast;
15: 13: use web_sys::HtmlInputElement;
16: 14: 
17: 15: #[derive(Debug, Clone, PartialEq, Eq)]
18: 16: pub struct Todos(pub Vec<Todo>);
19: 17: 
20: 18: const STORAGE_KEY: &str = "todos-lyx-core-lyx_core_lyx-core-lyx_core_leptos";
21: 19: 
22: 20: impl Todos {
23: 21:     pub fn new() -> Self {
24: 22:         Self(vec![])
25: 23:     }
26: 24: 
27: 25:     pub fn new_with_1000() -> Self {
28: 26:         let todos = (0..1000)
29: 27:             .map(|id| Todo::new(id, format!("Todo #{id}")))
30: 28:             .collect();
31: 29:         Self(todos)
32: 30:     }
33: 31: 
34: 32:     pub fn is_empty(&self) -> bool {
35: 33:         self.0.is_empty()
36: 34:     }
37: 35: 
38: 36:     pub fn add(&mut self, todo: Todo) {
39: 37:         self.0.push(todo);
40: 38:     }
41: 39: 
42: 40:     pub fn remove(&mut self, id: usize) {
43: 41:         self.0.retain(|todo| todo.id != id);
44: 42:     }
45: 43: 
46: 44:     pub fn remaining(&self) -> usize {
47: 45:         self.0.iter().filter(|todo| !(todo.completed)()).count()
48: 46:     }
49: 47: 
50: 48:     pub fn completed(&self) -> usize {
51: 49:         self.0.iter().filter(|todo| (todo.completed)()).count()
52: 50:     }
53: 51: 
54: 52:     pub fn toggle_all(&self) {
55: 53:         // if all are complete, mark them all active instead
56: 54:         if self.remaining() == 0 {
57: 55:             for todo in &self.0 {
58: 56:                 if todo.completed.get() {
59: 57:                     (todo.set_completed)(false);
60: 58:                 }
61: 59:             }
62: 60:         }
63: 61:         // otherwise, mark them all complete
64: 62:         else {
65: 63:             for todo in &self.0 {
66: 64:                 (todo.set_completed)(true);
67: 65:             }
68: 66:         }
69: 67:     }
70: 68: 
71: 69:     fn clear_completed(&mut self) {
72: 70:         self.0.retain(|todo| !todo.completed.get());
73: 71:     }
74: 72: }
75: 73: 
76: 74: #[derive(Debug, PartialEq, Eq, Clone)]
77: 75: pub struct Todo {
78: 76:     pub id: usize,
79: 77:     pub title: ReadSignal<String>,
80: 78:     pub set_title: WriteSignal<String>,
81: 79:     pub completed: ReadSignal<bool>,
82: 80:     pub set_completed: WriteSignal<bool>,
83: 81: }
84: 82: 
85: 83: impl Todo {
86: 84:     pub fn new(id: usize, title: String) -> Self {
87: 85:         Self::new_with_completed(id, title, false)
88: 86:     }
89: 87: 
90: 88:     pub fn new_with_completed(
91: 89:         id: usize,
92: 90:         title: String,
93: 91:         completed: bool,
94: 92:     ) -> Self {
95: 93:         let (title, set_title) = create_signal(title);
96: 94:         let (completed, set_completed) = create_signal(completed);
97: 95:         Self {
98: 96:             id,
99: 97:             title,
100: 98:             set_title,
101: 99:             completed,
102: 100:             set_completed,
103: 101:         }
104: 102:     }
105: 103: 
106: 104:     pub fn toggle(&self) {
107: 105:         self.set_completed
108: 106:             .update(|completed| *completed = !*completed);
109: 107:     }
110: 108: }
111: 109: 
112: 110: const ESCAPE_KEY: u32 = 27;
113: 111: const ENTER_KEY: u32 = 13;
114: 112: 
115: 113: pub fn TodoMVC(todos: Todos) -> impl Render<Dom> + RenderHtml<Dom> {
116: 114:     let mut next_id = todos
117: 115:         .0
118: 116:         .iter()
119: 117:         .map(|todo| todo.id)
120: 118:         .max()
121: 119:         .map(|last| last + 1)
122: 120:         .unwrap_or(0);
123: 121: 
124: 122:     let (todos, set_todos) = create_signal(todos);
125: 123:     provide_context(set_todos);
126: 124: 
127: 125:     let (mode, set_mode) = create_signal(Mode::All);
128: 126: 
129: 127:     let add_todo = move |ev: web_sys::KeyboardEvent| {
130: 128:         todo!()
131: 129:         /* let target = event_target::<HtmlInputElement>(&ev);
132: 130:         ev.stop_propagation();
133: 131:         let key_code = ev.unchecked_ref::<web_sys::KeyboardEvent>().key_code();
134: 132:         if key_code == ENTER_KEY {
135: 133:             let title = event_target_value(&ev);
136: 134:             let title = title.trim();
137: 135:             if !title.is_empty() {
138: 136:                 let new = Todo::new(next_id, title.to_string());
139: 137:                 set_todos.update(|t| t.add(new));
140: 138:                 next_id += 1;
141: 139:                 target.set_value("");
142: 140:             }
143: 141:         } */
144: 142:     };
145: 143: 
146: 144:     let filtered_todos = create_memo::<Vec<Todo>>(move |_| {
147: 145:         todos.with(|todos| match mode.get() {
148: 146:             Mode::All => todos.0.to_vec(),
149: 147:             Mode::Active => todos
150: 148:                 .0
151: 149:                 .iter()
152: 150:                 .filter(|todo| !todo.completed.get())
153: 151:                 .cloned()
154: 152:                 .collect(),
155: 153:             Mode::Completed => todos
156: 154:                 .0
157: 155:                 .iter()
158: 156:                 .filter(|todo| todo.completed.get())
159: 157:                 .cloned()
160: 158:                 .collect(),
161: 159:         })
162: 160:     });
163: 161: 
164: 162:     // effect to serialize to JSON
165: 163:     // this does reactive reads, so it will automatically serialize on any relevant change
166: 164:     create_effect(move |_| {
167: 165:         ()
168: 166:         /* if let Ok(Some(storage)) = window().local_storage() {
169: 167:             let objs = todos
170: 168:                 .get()
171: 169:                 .0
172: 170:                 .iter()
173: 171:                 .map(TodoSerialized::from)
174: 172:                 .collect::<Vec<_>>();
175: 173:             let json = json::to_string(&objs);
176: 174:             if storage.set_item(STORAGE_KEY, &json).is_err() {
177: 175:                 log::error!("error while trying to set item in localStorage");
178: 176:             }
179: 177:         } */
180: 178:     });
181: 179: 
182: 180:     view! {
183: 181:         <main>
184: 182:             <section class="todolyx-platform-lyx_platform_lyx-platform-lyx_platform_app">
185: 183:                 <header class="header">
186: 184:                     <h1>"todos"</h1>
187: 185:                     <input
188: 186:                         class="new-todo"
189: 187:                         placeholder="What needs to be done?"
190: 188:                         autofocus
191: 189:                     />
192: 190:                 </header>
193: 191:                 <section class="main" class:hidden=move || todos.with(|t| t.is_empty())>
194: 192:                     <input
195: 193:                         id="toggle-all"
196: 194:                         class="toggle-all"
197: 195:                         r#type="checkbox"
198: 196:                         //prop:checked=move || todos.with(|t| t.remaining() > 0)
199: 197:                         on:input=move |_| set_todos.update(|t| t.toggle_all())
200: 198:                     />
201: 199:                     <label r#for="toggle-all">"Mark all as complete"</label>
202: 200:                     <ul class="todo-list">
203: 201:                         {move || {
204: 202:                             keyed(filtered_todos.get(), |todo| todo.id, Todo)
205: 203:                         }}
206: 204:                     </ul>
207: 205:                 </section>
208: 206:                 <footer class="footer" class:hidden=move || todos.with(|t| t.is_empty())>
209: 207:                     <span class="todo-count">
210: 208:                         <strong>{move || todos.with(|t| t.remaining().to_string())}</strong>
211: 209:                         {move || if todos.with(|t| t.remaining()) == 1 { " item" } else { " items" }}
212: 210:                         " left"
213: 211:                     </span>
214: 212:                     <ul class="filters">
215: 213:                         <li>
216: 214:                             <a
217: 215:                                 href="#/"
218: 216:                                 class="selected"
219: 217:                                 class:selected=move || mode() == Mode::All
220: 218:                             >
221: 219:                                 "All"
222: 220:                             </a>
223: 221:                         </li>
224: 222:                         <li>
225: 223:                             <a href="#/active" class:selected=move || mode() == Mode::Active>
226: 224:                                 "Active"
227: 225:                             </a>
228: 226:                         </li>
229: 227:                         <li>
230: 228:                             <a href="#/completed" class:selected=move || mode() == Mode::Completed>
231: 229:                                 "Completed"
232: 230:                             </a>
233: 231:                         </li>
234: 232:                     </ul>
235: 233:                     <button
236: 234:                         class="clear-completed hidden"
237: 235:                         class:hidden=move || todos.with(|t| t.completed() == 0)
238: 236:                         on:click=move |_| set_todos.update(|t| t.clear_completed())
239: 237:                     >
240: 238:                         "Clear completed"
241: 239:                     </button>
242: 240:                 </footer>
243: 241:             </section>
244: 242:             <footer class="info">
245: 243:                 <p>"Double-click to edit a todo"</p>
246: 244:                 <p>"Created by " <a href="http://todomvc.com">"Greg Johnston"</a></p>
247: 245:                 <p>"Part of " <a href="http://todomvc.com">"TodoMVC"</a></p>
248: 246:             </footer>
249: 247:         </main>
250: 248:     }
251: 249: }
252: 250: 
253: 251: pub fn Todo(todo: Todo) -> impl Render<Dom> + RenderHtml<Dom> {
254: 252:     let (editing, set_editing) = create_signal(false);
255: 253:     let set_todos = use_context::<WriteSignal<Todos>>().unwrap();
256: 254:     //let input = NodeRef::new();
257: 255: 
258: 256:     let save = move |value: &str| {
259: 257:         let value = value.trim();
260: 258:         if value.is_empty() {
261: 259:             set_todos.update(|t| t.remove(todo.id));
262: 260:         } else {
263: 261:             (todo.set_title)(value.to_string());
264: 262:         }
265: 263:         set_editing(false);
266: 264:     };
267: 265: 
268: 266:     view! {
269: 267:         <li class="todo" class:editing=editing class:completed=move || (todo.completed)()>
270: 268:             /* <div class="view">
271: 269:                 <input class="toggle" r#type="checkbox"/>
272: 270:                 <label on:dblclick=move |_| set_editing(true)>{move || todo.title.get()}</label>
273: 271:                 <button
274: 272:                     class="destroy"
275: 273:                     on:click=move |_| set_todos.update(|t| t.remove(todo.id))
276: 274:                 ></button>
277: 275:             </div>
278: 276:             {move || {
279: 277:                 editing()
280: 278:                     .then(|| {
281: 279:                         view! {
282: 280:                             <input
283: 281:                                 class="edit"
284: 282:                                 class:hidden=move || !(editing)()
285: 283:                             />
286: 284:                         }
287: 285:                     })
288: 286:             }} */
289: 287:         </li>
290: 288:     }
291: 289: }
292: 290: 
293: 291: #[derive(Debug, Clone, Copy, PartialEq, Eq)]
294: 292: pub enum Mode {
295: 293:     Active,
296: 294:     Completed,
297: 295:     All,
298: 296: }
299: 297: 
300: 298: impl Default for Mode {
301: 299:     fn default() -> Self {
302: 300:         Mode::All
303: 301:     }
304: 302: }
305: 303: 
306: 304: pub fn route(hash: &str) -> Mode {
307: 305:     match hash {
308: 306:         "/active" => Mode::Active,
309: 307:         "/completed" => Mode::Completed,
310: 308:         _ => Mode::All,
311: 309:     }
312: 310: }
313: 311: 
314: 312: #[derive(Serialize, Deserialize)]
315: 313: pub struct TodoSerialized {
316: 314:     pub id: usize,
317: 315:     pub title: String,
318: 316:     pub completed: bool,
319: 317: }
320: 318: 
321: 319: impl TodoSerialized {
322: 320:     pub fn into_todo(self) -> Todo {
323: 321:         Todo::new_with_completed(self.id, self.title, self.completed)
324: 322:     }
325: 323: }
326: 324: 
327: 325: impl From<&Todo> for TodoSerialized {
328: 326:     fn from(todo: &Todo) -> Self {
329: 327:         Self {
330: 328:             id: todo.id,
331: 329:             title: todo.title.get(),
332: 330:             completed: (todo.completed)(),
333: 331:         }
334: 332:     }
335: 333: }
336: ```
```
