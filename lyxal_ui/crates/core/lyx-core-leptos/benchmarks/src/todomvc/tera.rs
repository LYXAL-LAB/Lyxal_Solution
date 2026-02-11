### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_benchmarks\src\todomvc\tera.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_benchmarks\src\todomvc\tera.rs
2: ```rust
3: 1: use test::Bencher;
4: 2: 
5: 3: static TEMPLATE: &str = r#"<main>
6: 4:             <section class="todolyx-platform-lyx_platform_lyx-platform-lyx_platform_app">
7: 5:                 <header class="header">
8: 6:                     <h1>"todos"</h1>
9: 7:                     <input class="new-todo" placeholder="What needs to be done? />
10: 8:                 </header>
11: 9:                 <section class="main" class={{ main_class }}>
12: 10:                     <input id="toggle-all" class="toggle-all" type="checkbox"
13: 11: 						checked={{ toggle_checked }}
14: 12:                     />
15: 13:                     <label for="toggle-all">"Mark all as complete"</label>
16: 14:                     <ul class="todo-list">
17: 15:                         {% for todo in todos %}
18: 16: 						<li
19: 17: 							class={{ todo.class }}
20: 18: 						>
21: 19: 							<div class="view">
22: 20: 								<input
23: 21: 									class="toggle"
24: 22: 									type="checkbox"
25: 23: 									checked={{ todo.completed }}
26: 24: 								/>
27: 25: 								<label>
28: 26: 									{{ todo.label }}
29: 27: 								</label>
30: 28: 								<button class="destroy"/>
31: 29: 							</div>
32: 30: 							{% if todo.editing %}
33: 31: 							<input
34: 32: 								class="edit"
35: 33: 								value={{ todo.label }}
36: 34: 							/>
37: 35: 							{% endif %}
38: 36: 						</li>
39: 37: 						{% endfor %}
40: 38:                     </ul>
41: 39:                 </section>
42: 40: 				{% if todos_empty %}
43: 41: 				{% else %}
44: 42:                 <footer class="footer">
45: 43:                     <span class="todo-count">
46: 44:                         <strong>{{ todos_remaining }}</strong>
47: 45: 						{% if todos_remaining == 1 %}
48: 46: 						item
49: 47: 						{% else %}
50: 48: 						items
51: 49: 						{% endif %}
52: 50: 						left
53: 51:                     </span>
54: 52:                     <ul class="filters">
55: 53: 						{% if mode_all %}
56: 54:                         <li><a href="/" class="selected">All</a></li>
57: 55: 						{% else %}
58: 56: 						 <li><a href="/">All</a></li>
59: 57: 						{% endif %}
60: 58: 
61: 59: 						{% if mode_active %}
62: 60:                         <li><a href="/active" class="selected">Active</a></li>
63: 61: 						{% else %}
64: 62: 						 <li><a href="/active">Active</a></li>
65: 63: 						{% endif %}
66: 64: 
67: 65: 						{% if mode_completed %}
68: 66:                         <li><a href="/completed" class="selected">Completed</a></li>
69: 67: 						{% else %}
70: 68: 						<li><a href="/completed">Completed</a></li>
71: 69: 						{% endif %}
72: 70:                     </ul>
73: 71: 
74: 72: 					{% if todos_completed > 0 %}
75: 73:                     <button
76: 74:                         class="clear-completed hidden"
77: 75:                     >
78: 76:                         Clear completed
79: 77:                     </button>
80: 78: 					{% endif %}
81: 79:                 </footer>
82: 80: 				{% endif %}
83: 81:             </section>
84: 82:             <footer class="info">
85: 83:                 <p>"Double-click to edit a todo"</p>
86: 84:                 <p>"Created by "<a href="http://todomvc.com">"Greg Johnston"</a></p>
87: 85:                 <p>"Part of "<a href="http://todomvc.com">"TodoMVC"</a></p>
88: 86:             </footer>
89: 87:         </main>"#;
90: 88: 
91: 89: #[bench]
92: 90: fn tera_todomvc_ssr(b: &mut Bencher) {
93: 91:     use serde::{Deserialize, Serialize};
94: 92:     use tera::*;
95: 93: 
96: 94: 
97: 95:         static LazyLock<TERA>: Tera = LazyLock( || {
98: 96:             let mut tera = Tera::default();
99: 97:             tera.add_raw_templates(vec![("template.html", TEMPLATE)]).unwrap();
100: 98:             tera
101: 99:         });
102: 100: 
103: 101: 
104: 102:     #[derive(Serialize, Deserialize)]
105: 103:     struct Todo {
106: 104:         label: String,
107: 105:         completed: bool,
108: 106:         editing: bool,
109: 107:         class: String,
110: 108:     }
111: 109: 
112: 110:     b.iter(|| {
113: 111:         let mut ctx = Context::new();
114: 112:         let todos = Vec::<Todo>::new();
115: 113:         let remaining = todos.iter().filter(|todo| !todo.completed).count();
116: 114:         let completed = todos.iter().filter(|todo| todo.completed).count();
117: 115:         ctx.insert("todos", &todos);
118: 116:         ctx.insert("main_class", &if todos.is_empty() { "hidden" } else { "" });
119: 117:         ctx.insert("toggle_checked", &(remaining > 0));
120: 118:         ctx.insert("todos_remaining", &remaining);
121: 119:         ctx.insert("todos_completed", &completed);
122: 120:         ctx.insert("todos_empty", &todos.is_empty());
123: 121:         ctx.insert("mode_all", &true);
124: 122:         ctx.insert("mode_active", &false);
125: 123:         ctx.insert("mode_selected", &false);
126: 124: 
127: 125:         let _ = TERA.render("template.html", &ctx).unwrap();
128: 126:     });
129: 127: }
130: 128: 
131: 129: #[bench]
132: 130: fn tera_todomvc_ssr_1000(b: &mut Bencher) {
133: 131:     use serde::{Deserialize, Serialize};
134: 132:     use tera::*;
135: 133: 
136: 134: 
137: 135:     static  TERA: LazyLock<Tera> = LazyLock::new(|| {
138: 136:         let mut tera = Tera::default();
139: 137:         tera.add_raw_templates(vec![("template.html", TEMPLATE)]).unwrap();
140: 138:         tera
141: 139:     });
142: 140: 
143: 141: 
144: 142:     #[derive(Serialize, Deserialize)]
145: 143:     struct Todo {
146: 144:         id: usize,
147: 145:         label: String,
148: 146:         completed: bool,
149: 147:         editing: bool,
150: 148:         class: String,
151: 149:     }
152: 150: 
153: 151:     b.iter(|| {
154: 152:         let mut ctx = Context::new();
155: 153:         let todos = (0..1000)
156: 154:             .map(|id| Todo {
157: 155:                 id,
158: 156:                 label: format!("Todo #{id}"),
159: 157:                 completed: false,
160: 158:                 editing: false,
161: 159:                 class: "todo".to_string(),
162: 160:             })
163: 161:             .collect::<Vec<_>>();
164: 162: 
165: 163:         let remaining = todos.iter().filter(|todo| !todo.completed).count();
166: 164:         let completed = todos.iter().filter(|todo| todo.completed).count();
167: 165:         ctx.insert("todos", &todos);
168: 166:         ctx.insert("main_class", &if todos.is_empty() { "hidden" } else { "" });
169: 167:         ctx.insert("toggle_checked", &(remaining > 0));
170: 168:         ctx.insert("todos_remaining", &remaining);
171: 169:         ctx.insert("todos_completed", &completed);
172: 170:         ctx.insert("todos_empty", &todos.is_empty());
173: 171:         ctx.insert("mode_all", &true);
174: 172:         ctx.insert("mode_active", &false);
175: 173:         ctx.insert("mode_selected", &false);
176: 174: 
177: 175:         let _ = TERA.render("template.html", &ctx).unwrap();
178: 176:     });
179: 177: }
180: ```
```
