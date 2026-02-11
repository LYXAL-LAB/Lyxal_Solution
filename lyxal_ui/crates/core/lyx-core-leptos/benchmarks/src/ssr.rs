### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_benchmarks\src\ssr.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_benchmarks\src\ssr.rs
2: ```rust
3: 1: use test::Bencher;
4: 2: 
5: 3: #[bench]
6: 4: fn lyx-core-lyx_core_lyx-core-lyx_core_leptos_ssr_bench(b: &mut Bencher) {
7: 5: 	use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
8: 6: 	let r = create_runtime();
9: 7:     b.iter(|| {
10: 8: 			lyx-core-lyx_core_lyx-core-lyx_core_leptos::lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::HydrationCtx::reset_id();
11: 9: 			#[component]
12: 10: 			fn Counter(initial: i32) -> impl IntoView {
13: 11: 				let (value, set_value) = create_signal(initial);
14: 12: 				view! {
15: 13: 					<div>
16: 14: 						<button on:click=move |_| set_value.update(|value| *value -= 1)>"-1"</button>
17: 15: 						<span>"Value: " {move || value().to_string()} "!"</span>
18: 16: 						<button on:click=move |_| set_value.update(|value| *value += 1)>"+1"</button>
19: 17: 					</div>
20: 18: 				}
21: 19: 			}
22: 20: 
23: 21: 			let rendered = view! {
24: 22: 				<main>
25: 23: 					<h1>"Welcome to our benchmark page."</h1>
26: 24: 					<p>"Here's some introductory text."</p>
27: 25: 					<Counter initial=1/>
28: 26: 					<Counter initial=2/>
29: 27: 					<Counter initial=3/>
30: 28: 				</main>
31: 29: 			}.into_view().render_to_string();
32: 30: 
33: 31: 			assert_eq!(
34: 32: 				rendered,
35: 33: "<main data-hk=\"0-0-0-1\"><h1 data-hk=\"0-0-0-2\">Welcome to our benchmark page.</h1><p data-hk=\"0-0-0-3\">Here&#x27;s some introductory text.</p><div data-hk=\"0-0-0-5\"><button data-hk=\"0-0-0-6\">-1</button><span data-hk=\"0-0-0-7\">Value: <!>1<!--hk=0-0-0-8-->!</span><button data-hk=\"0-0-0-9\">+1</button></div><!--hk=0-0-0-4--><div data-hk=\"0-0-0-11\"><button data-hk=\"0-0-0-12\">-1</button><span data-hk=\"0-0-0-13\">Value: <!>2<!--hk=0-0-0-14-->!</span><button data-hk=\"0-0-0-15\">+1</button></div><!--hk=0-0-0-10--><div data-hk=\"0-0-0-17\"><button data-hk=\"0-0-0-18\">-1</button><span data-hk=\"0-0-0-19\">Value: <!>3<!--hk=0-0-0-20-->!</span><button data-hk=\"0-0-0-21\">+1</button></div><!--hk=0-0-0-16--></main>"			);
36: 34: 	});
37: 35: 	r.dispose();
38: 36: }
39: 37: 
40: 38: #[bench]
41: 39: fn lyx-core-lyx_core_lyx-core-lyx_core_tachys_ssr_bench(b: &mut Bencher) {
42: 40: 	use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{create_runtime, create_signal, SignalGet, SignalUpdate};
43: 41: 	use tachy_maccy::view;
44: 42: 	use tachydom::view::{Render, RenderHtml};
45: 43: 	use tachydom::html::element::ElementChild;
46: 44: 	use tachydom::html::attribute::global::ClassAttribute;
47: 45: 	use tachydom::html::attribute::global::GlobalAttributes;
48: 46: 	use tachydom::html::attribute::global::OnAttribute;
49: 47: 	use tachydom::renderer::dom::Dom;
50: 48: 	let rt = create_runtime();
51: 49:     b.iter(|| {
52: 50: 		fn counter(initial: i32) -> impl Render<Dom> + RenderHtml<Dom> {
53: 51: 			let (value, set_value) = create_signal(initial);
54: 52: 			view! {
55: 53: 				<div>
56: 54: 					<button on:click=move |_| set_value.update(|value| *value -= 1)>"-1"</button>
57: 55: 					<span>"Value: " {move || value().to_string()} "!"</span>
58: 56: 					<button on:click=move |_| set_value.update(|value| *value += 1)>"+1"</button>
59: 57: 				</div>
60: 58: 			}
61: 59: 		}
62: 60: 
63: 61: 		let rendered = view! {
64: 62: 			<main>
65: 63: 				<h1>"Welcome to our benchmark page."</h1>
66: 64: 				<p>"Here's some introductory text."</p>
67: 65: 				{counter(1)}
68: 66: 				{counter(2)}
69: 67: 				{counter(3)}
70: 68: 			</main>
71: 69: 		}.to_html();
72: 70: 		assert_eq!(
73: 71: 			rendered,
74: 72: 			"<main><h1>Welcome to our benchmark page.</h1><p>Here's some introductory text.</p><div><button>-1</button><span>Value: <!>1<!>!</span><button>+1</button></div><div><button>-1</button><span>Value: <!>2<!>!</span><button>+1</button></div><div><button>-1</button><span>Value: <!>3<!>!</span><button>+1</button></div></main>"
75: 73: 		);
76: 74: 	});
77: 75: 	rt.dispose();
78: 76: }
79: 77: 
80: 78: #[bench]
81: 79: fn tera_ssr_bench(b: &mut Bencher) {
82: 80:     use serde::{Deserialize, Serialize};
83: 81:     use tera::*;
84: 82: 
85: 83:     static TEMPLATE: &str = r#"<main>
86: 84: 	<h1>Welcome to our benchmark page.</h1>
87: 85: 	<p>Here's some introductory text.</p>
88: 86: 	{% for counter in counters %}
89: 87: 	<div>
90: 88: 		<button>-1</button>
91: 89: 		<span>Value: {{ counter.value }}!</span>
92: 90: 		<button>+1</button>
93: 91: 	</div>
94: 92: 	{% endfor %}
95: 93: 	</main>"#;
96: 94: 
97: 95: 
98: 96:     static  LazyCell<TERA>: Tera = LazyLock::new(|| {
99: 97:         let mut tera = Tera::default();
100: 98:         tera.add_raw_templates(vec![("template.html", TEMPLATE)]).unwrap();
101: 99:         tera
102: 100:     });
103: 101: 
104: 102: 
105: 103:     #[derive(Serialize, Deserialize)]
106: 104:     struct Counter {
107: 105:         value: i32,
108: 106:     }
109: 107: 
110: 108:     b.iter(|| {
111: 109:         let mut ctx = Context::new();
112: 110:         ctx.insert(
113: 111:             "counters",
114: 112:             &vec![
115: 113:                 Counter { value: 0 },
116: 114:                 Counter { value: 1 },
117: 115:                 Counter { value: 2 },
118: 116:             ],
119: 117:         );
120: 118: 
121: 119:         let _ = TERA.render("template.html", &ctx).unwrap();
122: 120:     });
123: 121: }
124: 122: 
125: 123: #[bench]
126: 124: fn sycamore_ssr_bench(b: &mut Bencher) {
127: 125:     use sycamore::prelude::*;
128: 126:     use sycamore::*;
129: 127: 
130: 128:     b.iter(|| {
131: 129: 		_ = create_scope(|cx| {
132: 130: 			#[derive(Prop)]
133: 131: 			struct CounterProps {
134: 132: 				initial: i32
135: 133: 			}
136: 134: 
137: 135: 
138: 136: 			#[component]
139: 137: 			fn Counter<G: Html>(cx: Scope, props: CounterProps) -> View<G> {
140: 138: 				let value = create_signal(cx, props.initial);
141: 139: 				view! {
142: 140: 					cx,
143: 141: 					div {
144: 142: 						button(on:click=|_| value.set(*value.get() - 1)) {
145: 143: 							"-1"
146: 144: 						}
147: 145: 						span {
148: 146: 							"Value: "
149: 147: 							(value.get().to_string())
150: 148: 							"!"
151: 149: 						}
152: 150: 						button(on:click=|_| value.set(*value.get() + 1)) {
153: 151: 							"+1"
154: 152: 						}
155: 153: 					}
156: 154: 				}
157: 155: 			}
158: 156: 
159: 157: 			let rendered = render_to_string(|cx| view! {
160: 158: 				cx,
161: 159: 				main {
162: 160: 					h1 {
163: 161: 						"Welcome to our benchmark page."
164: 162: 					}
165: 163: 					p {
166: 164: 						"Here's some introductory text."
167: 165: 					}
168: 166: 					Counter(initial = 1)
169: 167: 					Counter(initial = 2)
170: 168: 					Counter(initial = 3)
171: 169: 				}
172: 170: 			});
173: 171: 
174: 172: 			assert_eq!(
175: 173: 				rendered,
176: 174: 				"<main data-hk=\"0.0\"><h1 data-hk=\"0.1\">Welcome to our benchmark page.</h1><p data-hk=\"0.2\">Here's some introductory text.</p><!--#--><div data-hk=\"1.0\"><button data-hk=\"1.1\">-1</button><span data-hk=\"1.2\">Value: <!--#-->1<!--/-->!</span><button data-hk=\"1.3\">+1</button></div><!--/--><!----><!--#--><div data-hk=\"2.0\"><button data-hk=\"2.1\">-1</button><span data-hk=\"2.2\">Value: <!--#-->2<!--/-->!</span><button data-hk=\"2.3\">+1</button></div><!--/--><!----><!--#--><div data-hk=\"3.0\"><button data-hk=\"3.1\">-1</button><span data-hk=\"3.2\">Value: <!--#-->3<!--/-->!</span><button data-hk=\"3.3\">+1</button></div><!--/--></main>"
177: 175: 			);
178: 176: 		});
179: 177: 	});
180: 178: }
181: 179: 
182: 180: #[bench]
183: 181: fn yew_ssr_bench(b: &mut Bencher) {
184: 182:     use yew::prelude::*;
185: 183:     use yew::ServerRenderer;
186: 184: 
187: 185:     b.iter(|| {
188: 186: 		#[derive(Properties, PartialEq, Eq, Debug)]
189: 187: 		struct CounterProps {
190: 188: 			initial: i32
191: 189: 		}
192: 190: 
193: 191: 		#[function_component(Counter)]
194: 192: 		fn counter(props: &CounterProps) -> Html {
195: 193: 			let state = use_state(|| props.initial);
196: 194: 
197: 195: 			let incr_counter = {
198: 196: 				let state = state.clone();
199: 197: 				Callback::from(move |_| state.set(&*state + 1))
200: 198: 			};
201: 199: 
202: 200: 			let decr_counter = {
203: 201: 				let state = state.clone();
204: 202: 				Callback::from(move |_| state.set(&*state - 1))
205: 203: 			};
206: 204: 
207: 205: 			html! {
208: 206: 				<div>
209: 207: 					<h1>{"Welcome to our benchmark page."}</h1>
210: 208: 					<p>{"Here's some introductory text."}</p>
211: 209: 					<button onclick={decr_counter}> {"-1"} </button>
212: 210: 					<p> {"Value: "} {*state} {"!"} </p>
213: 211: 					<button onclick={incr_counter}> {"+1"} </button>
214: 212: 				</div>
215: 213: 			}
216: 214: 		}
217: 215: 
218: 216: 		#[function_component]
219: 217: 		fn App() -> Html {
220: 218: 			html! {
221: 219: 				<main>
222: 220: 					<Counter initial=1/>
223: 221: 					<Counter initial=2/>
224: 222: 					<Counter initial=3/>
225: 223: 				</main>
226: 224: 			}
227: 225: 		}
228: 226: 
229: 227: 		tokio_test::block_on(async {
230: 228: 			let renderer = ServerRenderer::<App>::new();
231: 229: 			let rendered = renderer.render().await;
232: 230: 			assert_eq!(
233: 231: 				rendered,
234: 232: 				"<!--<[]>--><main><!--<[]>--><div><h1>Welcome to our benchmark page.</h1><p>Here's some introductory text.</p><button>-1</button><p>Value: 1!</p><button>+1</button></div><!--</[]>--><!--<[]>--><div><h1>Welcome to our benchmark page.</h1><p>Here's some introductory text.</p><button>-1</button><p>Value: 2!</p><button>+1</button></div><!--</[]>--><!--<[]>--><div><h1>Welcome to our benchmark page.</h1><p>Here's some introductory text.</p><button>-1</button><p>Value: 3!</p><button>+1</button></div><!--</[]>--></main><!--</[]>-->"
235: 233: 			);
236: 234: 		});
237: 235: 	});
238: 236: }
239: ```
```
