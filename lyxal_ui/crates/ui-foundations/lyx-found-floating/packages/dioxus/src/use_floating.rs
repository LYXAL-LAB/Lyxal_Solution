### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dioxus\src\use_floating.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
32: ```rust
33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
34: ```rust
35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
36: ```rust
37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
38: ```rust
39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_floating.rs
40: ```rust
41: use std::{cell::RefCell, rc::Rc};
42: 
43: use dioxus::{core::use_drop, prelude::*, web::WebEventExt};
44: use lyx_ui_foundations_dom::{
45:     ComputePositionConfig, MiddlewareData, Placement, Strategy, compute_position,
46: };
47: 
48: use crate::{
49:     FloatingStyles, UseFloatingOptions, UseFloatingReturn, WhileElementsMountedCleanupFn,
50:     utils::{get_dpr::get_dpr, round_by_dpr::round_by_dpr},
51: };
52: 
53: /// Computes the `x` and `y` coordinates that will place the floating element next to a reference element.
54: pub fn use_floating(
55:     reference: Signal<Option<Rc<MountedData>>>,
56:     floating: Signal<Option<Rc<MountedData>>>,
57:     options: UseFloatingOptions,
58: ) -> UseFloatingReturn {
59:     let open_option = use_memo(move || options.open.unwrap_or(true));
60:     let placement_option = use_memo(move || options.placement.unwrap_or(Placement::Bottom));
61:     let strategy_option = use_memo(move || options.strategy.unwrap_or(Strategy::Absolute));
62:     let middleware_option = use_memo(move || options.middleware.clone().unwrap_or_default());
63:     let transform_option = use_memo(move || options.transform.unwrap_or(true));
64:     let while_elements_mounted_option = options.while_elements_mounted;
65: 
66:     let mut x = use_signal(|| 0.0);
67:     let mut y = use_signal(|| 0.0);
68:     #[expect(clippy::redundant_closure)]
69:     let mut strategy = use_signal(|| strategy_option());
70:     #[expect(clippy::redundant_closure)]
71:     let mut placement = use_signal(|| placement_option());
72:     let mut middleware_data = use_signal(MiddlewareData::default);
73:     let mut is_positioned = use_signal(|| false);
74:     let floating_styles = use_memo(move || {
75:         let initial_styles = FloatingStyles {
76:             position: strategy(),
77:             top: "0".to_owned(),
78:             left: "0".to_owned(),
79:             transform: None,
80:             will_change: None,
81:         };
82: 
83:         match floating().map(|floating| floating.as_web_event()) {
84:             Some(floating_element) => {
85:                 let x_val = round_by_dpr(&floating_element, x());
86:                 let y_val = round_by_dpr(&floating_element, y());
87: 
88:                 if transform_option() {
89:                     FloatingStyles {
90:                         transform: Some(format!("translate({x_val}px, {y_val}px)")),
91:                         will_change: (get_dpr(&floating_element) >= 1.5)
92:                             .then_some("transform".to_owned()),
93:                         ..initial_styles
94:                     }
95:                 } else {
96:                     FloatingStyles {
97:                         left: format!("{x_val}px"),
98:                         top: format!("{y_val}px"),
99:                         ..initial_styles
100:                     }
101:                 }
102:             }
103:             _ => initial_styles,
104:         }
105:     });
106: 
107:     let update = use_callback(move |_| {
108:         if let Some(reference_element) = reference().map(|reference| reference.as_web_event())
109:             && let Some(floating_element) = floating().map(|floating| floating.as_web_event())
110:         {
111:             let config = ComputePositionConfig {
112:                 placement: Some(placement_option()),
113:                 strategy: Some(strategy_option()),
114:                 middleware: Some(middleware_option()),
115:             };
116: 
117:             let open = open_option();
118: 
119:             let position = compute_position((&reference_element).into(), &floating_element, config);
120:             x.set(position.x);
121:             y.set(position.y);
122:             strategy.set(position.strategy);
123:             placement.set(position.placement);
124:             middleware_data.set(position.middleware_data);
125:             // The floating element's position may be recomputed while it's closed
126:             // but still mounted (such as when transitioning out). To ensure
127:             // `is_positioned` will be `false` initially on the next open,
128:             // avoid setting it to `true` when `open === false` (must be specified).
129:             is_positioned.set(open);
130:         }
131:     });
132: 
133:     let while_elements_mounted_cleanup = use_hook::<
134:         Rc<RefCell<Option<Rc<WhileElementsMountedCleanupFn>>>>,
135:     >(|| Rc::new(RefCell::new(None)));
136: 
137:     let cleanup = use_callback({
138:         let while_elements_mounted_cleanup = while_elements_mounted_cleanup.clone();
139: 
140:         move |_| {
141:             if let Some(while_elements_mounted_cleanup) = while_elements_mounted_cleanup.take() {
142:                 while_elements_mounted_cleanup();
143:             }
144:         }
145:     });
146: 
147:     let attach = use_callback(move |_| {
148:         cleanup.call(());
149: 
150:         if let Some(while_elements_mounted) = &while_elements_mounted_option {
151:             if let Some(reference_element) = reference().map(|reference| reference.as_web_event())
152:                 && let Some(floating_element) = floating().map(|floating| floating.as_web_event())
153:             {
154:                 while_elements_mounted_cleanup.replace(Some(Rc::new((*while_elements_mounted)(
155:                     (&reference_element).into(),
156:                     &floating_element,
157:                     Rc::new(move || {
158:                         update.call(());
159:                     }),
160:                 ))));
161:             }
162:         } else {
163:             update.call(());
164:         }
165:     });
166: 
167:     let reset = use_callback(move |_| {
168:         if open_option() {
169:             is_positioned.set(false);
170:         }
171:     });
172: 
173:     use_effect(move || {
174:         _ = open_option();
175:         _ = placement_option();
176:         _ = strategy_option();
177:         _ = middleware_option();
178: 
179:         update.call(());
180:     });
181: 
182:     use_effect(move || {
183:         _ = reference();
184:         _ = floating();
185: 
186:         attach(());
187:     });
188: 
189:     use_effect(move || {
190:         _ = open_option();
191: 
192:         reset.call(());
193:     });
194: 
195:     use_drop(move || {
196:         cleanup.call(());
197:     });
198: 
199:     UseFloatingReturn {
200:         x,
201:         y,
202:         placement,
203:         strategy,
204:         middleware_data,
205:         is_positioned,
206:         floating_styles,
207:         update,
208:     }
209: }
210: ```
211: ```
212: ```
213: ```
214: ```
215: ```
216: ```
217: ```
218: ```
219: ```
220: ```
221: ```
222: ```
223: ```
224: ```
225: ```
226: ```
227: ```
228: ```
229: ```
```
