### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_benchmarks\src\todomvc\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_benchmarks\src\todomvc\mod.rs
2: ```rust
3: 1: use test::Bencher;
4: 2: 
5: 3: mod lyx-core-lyx_core_lyx-core-lyx_core_leptos;
6: 4: mod sycamore;
7: 5: mod lyx-core-lyx_core_lyx-core-lyx_core_tachys;
8: 6: mod tera;
9: 7: mod yew;
10: 8: 
11: 9: #[bench]
12: 10: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_todomvc_ssr(b: &mut Bencher) {
13: 11:     use ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
14: 12:     let runtime = create_runtime();
15: 13:     b.iter(|| {
16: 14:         use crate::todomvc::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
17: 15: 
18: 16:         let html = ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::ssr::render_to_string(|| {
19: 17:             view! { <TodoMVC todos=Todos::new()/> }
20: 18:         });
21: 19:         assert!(html.len() > 1);
22: 20:     });
23: 21:     runtime.dispose();
24: 22: }
25: 23: 
26: 24: #[bench]
27: 25: fn lyx-core-lyx_core_lyx-core-lyx_core_tachys_todomvc_ssr(b: &mut Bencher) {
28: 26:     use ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
29: 27:     let runtime = create_runtime();
30: 28:     b.iter(|| {
31: 29:         use crate::todomvc::lyx-core-lyx_core_lyx-core-lyx_core_tachys::*;
32: 30:         use tachydom::view::{Render, RenderHtml};
33: 31: 
34: 32:         let rendered = TodoMVC(Todos::new()).to_html();
35: 33:         assert_eq!(
36: 34:             rendered,
37: 35: "<main><section class=\"todolyx-platform-lyx_platform_lyx-platform-lyx_platform_app\"><header class=\"header\"><h1>todos</h1><input placeholder=\"What needs to be done?\" autofocus class=\"new-todo\"></header><section class=\"main hidden\"><input id=\"toggle-all\" type=\"checkbox\" class=\"toggle-all\"><label for=\"toggle-all\">Mark all as complete</label><ul class=\"todo-list\"></ul></section><footer class=\"footer hidden\"><span class=\"todo-count\"><strong>0</strong><!> items<!> left</span><ul class=\"filters\"><li><a href=\"#/\" class=\"selected selected\">All</a></li><li><a href=\"#/active\" class=\"\">Active</a></li><li><a href=\"#/completed\" class=\"\">Completed</a></li></ul><button class=\"clear-completed hidden hidden\">Clear completed</button></footer></section><footer class=\"info\"><p>Double-click to edit a todo</p><p>Created by <a href=\"http://todomvc.com\">Greg Johnston</a></p><p>Part of <a href=\"http://todomvc.com\">TodoMVC</a></p></footer></main>"        );
38: 36:     });
39: 37:     runtime.dispose();
40: 38: }
41: 39: 
42: 40: #[bench]
43: 41: fn sycamore_todomvc_ssr(b: &mut Bencher) {
44: 42:     use self::sycamore::*;
45: 43:     use ::sycamore::{prelude::*, *};
46: 44: 
47: 45:     b.iter(|| {
48: 46:         _ = create_scope(|cx| {
49: 47:             let rendered = render_to_string(|cx| {
50: 48:                 view! {
51: 49:                     cx,
52: 50:                     App()
53: 51:                 }
54: 52:             });
55: 53: 
56: 54:             assert!(rendered.len() > 1);
57: 55:         });
58: 56:     });
59: 57: }
60: 58: 
61: 59: #[bench]
62: 60: fn yew_todomvc_ssr(b: &mut Bencher) {
63: 61:     use self::yew::*;
64: 62:     use ::yew::{prelude::*, ServerRenderer};
65: 63: 
66: 64:     b.iter(|| {
67: 65:         tokio_test::block_on(async {
68: 66:             let renderer = ServerRenderer::<App>::new();
69: 67:             let rendered = renderer.render().await;
70: 68:             assert!(rendered.len() > 1);
71: 69:         });
72: 70:     });
73: 71: }
74: 72: 
75: 73: #[bench]
76: 74: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_todomvc_ssr_with_1000(b: &mut Bencher) {
77: 75:     b.iter(|| {
78: 76:         use self::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
79: 77:         use ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
80: 78: 
81: 79:         let html = ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::ssr::render_to_string(|| {
82: 80:             view! {
83: 81:                 <TodoMVC todos=Todos::new_with_1000()/>
84: 82:             }
85: 83:         });
86: 84:         assert!(html.len() > 1);
87: 85:     });
88: 86: }
89: 87: 
90: 88: #[bench]
91: 89: fn lyx-core-lyx_core_lyx-core-lyx_core_tachys_todomvc_ssr_with_1000(b: &mut Bencher) {
92: 90:     use ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
93: 91:     let runtime = create_runtime();
94: 92:     b.iter(|| {
95: 93:         use crate::todomvc::lyx-core-lyx_core_lyx-core-lyx_core_tachys::*;
96: 94:         use tachydom::view::{Render, RenderHtml};
97: 95: 
98: 96:         let rendered = TodoMVC(Todos::new_with_1000()).to_html();
99: 97:         assert!(rendered.len() > 20_000)
100: 98:     });
101: 99:     runtime.dispose();
102: 100: }
103: 101: 
104: 102: #[bench]
105: 103: fn sycamore_todomvc_ssr_with_1000(b: &mut Bencher) {
106: 104:     use self::sycamore::*;
107: 105:     use ::sycamore::{prelude::*, *};
108: 106: 
109: 107:     b.iter(|| {
110: 108:         _ = create_scope(|cx| {
111: 109:             let rendered = render_to_string(|cx| {
112: 110:                 view! {
113: 111:                     cx,
114: 112:                     AppWith1000()
115: 113:                 }
116: 114:             });
117: 115: 
118: 116:             assert!(rendered.len() > 1);
119: 117:         });
120: 118:     });
121: 119: }
122: 120: 
123: 121: #[bench]
124: 122: fn yew_todomvc_ssr_with_1000(b: &mut Bencher) {
125: 123:     use self::yew::*;
126: 124:     use ::yew::{prelude::*, ServerRenderer};
127: 125: 
128: 126:     b.iter(|| {
129: 127:         tokio_test::block_on(async {
130: 128:             let renderer = ServerRenderer::<AppWith1000>::new();
131: 129:             let rendered = renderer.render().await;
132: 130:             assert!(rendered.len() > 1);
133: 131:         });
134: 132:     });
135: 133: }
136: 134: 
137: 135: #[bench]
138: 136: fn tera_todomvc_ssr(b: &mut Bencher) {
139: 137:     use ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
140: 138:     let runtime = create_runtime();
141: 139:     b.iter(|| {
142: 140:         use crate::todomvc::lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
143: 141: 
144: 142:         let html = ::lyx-core-lyx_core_lyx-core-lyx_core_leptos::ssr::render_to_string(|| {
145: 143:             view! { <TodoMVC todos=Todos::new()/> }
146: 144:         });
147: 145:         assert!(html.len() > 1);
148: 146:     });
149: 147:     runtime.dispose();
150: 148: }
151: ```
```
