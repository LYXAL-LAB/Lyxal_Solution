### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\yew\tests\visual\src\spec\placement.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\spec\placement.rs
32: ```rust
33: use convert_case::{Case, Casing};
34: use lyx_ui_foundations_yew::{
35:     Placement as PlacementEnum, UseFloatingOptions, UseFloatingReturn, use_auto_update,
36:     use_floating,
37: };
38: use wasm_bindgen::JsCast;
39: use yew::prelude::*;
40: 
41: use crate::utils::{all_placements::ALL_PLACEMENTS, use_size::use_size};
42: 
43: #[function_component]
44: pub fn Placement() -> Html {
45:     let reference_ref = use_node_ref();
46:     let floating_ref = use_node_ref();
47: 
48:     let rtl = use_state_eq(|| false);
49:     let placement = use_state_eq(|| PlacementEnum::Bottom);
50: 
51:     let auto_update = use_auto_update();
52: 
53:     let UseFloatingReturn {
54:         floating_styles,
55:         update,
56:         ..
57:     } = use_floating(
58:         reference_ref.clone().into(),
59:         floating_ref.clone(),
60:         UseFloatingOptions::default()
61:             .placement(*placement)
62:             .while_elements_mounted((*auto_update).clone()),
63:     );
64: 
65:     let size = use_size(None, None);
66: 
67:     html! {
68:         <>
69:             <h1>{"Placement"}</h1>
70:             <p>
71:                 {"The floating element should be correctly positioned when given each of the 12 placements."}
72:             </p>
73:             <div class="container" style={format!("direction: {}", if *rtl {
74:                 "rtl"
75:             } else {
76:                 "ltr"
77:             })}>
78:                 <div ref={reference_ref} class="reference">
79:                     {"Reference"}
80:                 </div>
81:                 <div
82:                     ref={floating_ref}
83:                     class="floating"
84:                     style={format!("{} width: {}px; height: {}px;", floating_styles, *size, *size)}
85:                 >
86:                     {"Floating"}
87:                 </div>
88:             </div>
89: 
90:             <div class="controls">
91:                 <label for="size">{"Size"}</label>
92:                 <input
93:                     id="size"
94:                     type="range"
95:                     min="1"
96:                     max="200"
97:                     value={size.to_string()}
98:                     oninput={Callback::from(move |event: InputEvent| {
99:                         size.set(
100:                             event
101:                                 .target()
102:                                 .unwrap()
103:                                 .unchecked_into::<web_sys::HtmlInputElement>()
104:                                 .value()
105:                                 .parse()
106:                                 .unwrap(),
107:                         );
108:                     })}
109:                 />
110:             </div>
111: 
112:             <div class="controls">
113:                 {
114:                     ALL_PLACEMENTS.into_iter().map(|value| {
115:                         html! {
116:                             <button
117:                                 key={format!("{:?}", value)}
118:                                 data-testid={format!("Placement{value:?}").to_case(Case::Kebab)}
119:                                 style={if *placement == value {
120:                                     "background-color: black;"
121:                                 } else {
122:                                     ""
123:                                 }}
124:                                 onclick={Callback::from({
125:                                     let placement = placement.clone();
126: 
127:                                     move |_| placement.set(value)
128:                                 })}
129:                             >
130:                                 {format!("{value:?}").to_case(Case::Kebab)}
131:                             </button>
132:                         }
133:                     }).collect::<Html>()
134:                 }
135:             </div>
136: 
137:             <h2>{"RTL"}</h2>
138:             <div class="controls">
139:                 {
140:                     [true, false].into_iter().map(|value| {
141:                         html! {
142:                             <button
143:                                 key={format!("{}", value)}
144:                                 data-testid={format!("rtl-{value}")}
145:                                 style={if *rtl == value {
146:                                     "background-color: black;"
147:                                 } else {
148:                                     ""
149:                                 }}
150:                                 onclick={Callback::from({
151:                                     let rtl = rtl.clone();
152:                                     let update = update.clone();
153: 
154:                                     move |_| {
155:                                         rtl.set(value);
156:                                         update.emit(());
157:                                     }
158:                                 })}
159:                             >
160:                                 {format!("{}", value)}
161:                             </button>
162:                         }
163:                     }).collect::<Html>()
164:                 }
165:             </div>
166:         </>
167:     }
168: }
169: ```
170: ```
171: ```
172: ```
173: ```
174: ```
175: ```
176: ```
177: ```
178: ```
179: ```
180: ```
181: ```
182: ```
183: ```
184: ```
```
