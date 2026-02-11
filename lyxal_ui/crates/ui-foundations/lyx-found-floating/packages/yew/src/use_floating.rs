### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\yew\src\use_floating.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_floating.rs
32: ```rust
33: use std::{cell::RefCell, rc::Rc};
34: 
35: use lyx_ui_foundations_dom::{
36:     ComputePositionConfig, MiddlewareData, OwnedElementOrVirtual, Placement, Strategy,
37:     VirtualElement, compute_position,
38: };
39: use web_sys::wasm_bindgen::JsCast;
40: use yew::{NodeRef, hook, use_callback, use_effect_with, use_memo, use_mut_ref, use_state_eq};
41: 
42: use crate::{
43:     types::{
44:         FloatingStyles, ShallowRc, UseFloatingOptions, UseFloatingReturn,
45:         WhileElementsMountedCleanupFn,
46:     },
47:     utils::{get_dpr::get_dpr, round_by_dpr::round_by_dpr},
48: };
49: 
50: #[derive(Clone, PartialEq)]
51: pub enum VirtualElementOrNodeRef {
52:     VirtualElement(Box<dyn VirtualElement<web_sys::Element>>),
53:     NodeRef(NodeRef),
54: }
55: 
56: impl VirtualElementOrNodeRef {
57:     pub fn get(&self) -> Option<OwnedElementOrVirtual> {
58:         match self {
59:             VirtualElementOrNodeRef::VirtualElement(virtual_element) => {
60:                 Some(virtual_element.clone().into())
61:             }
62:             VirtualElementOrNodeRef::NodeRef(node_ref) => node_ref.get().map(|node| {
63:                 OwnedElementOrVirtual::Element(
64:                     node.dyn_into::<web_sys::Element>()
65:                         .expect("Reference element should be an Element."),
66:                 )
67:             }),
68:         }
69:     }
70: }
71: 
72: impl From<Box<dyn VirtualElement<web_sys::Element>>> for VirtualElementOrNodeRef {
73:     fn from(value: Box<dyn VirtualElement<web_sys::Element>>) -> Self {
74:         VirtualElementOrNodeRef::VirtualElement(value)
75:     }
76: }
77: 
78: impl From<NodeRef> for VirtualElementOrNodeRef {
79:     fn from(value: NodeRef) -> Self {
80:         VirtualElementOrNodeRef::NodeRef(value)
81:     }
82: }
83: 
84: /// Computes the `x` and `y` coordinates that will place the floating element next to a reference element.
85: #[hook]
86: pub fn use_floating(
87:     reference: VirtualElementOrNodeRef,
88:     floating: NodeRef,
89:     options: UseFloatingOptions,
90: ) -> UseFloatingReturn {
91:     let while_elements_mounted_option = options.while_elements_mounted.map(ShallowRc::from);
92:     let open_option = use_memo(options.open, |open| open.unwrap_or(true));
93:     let middleware_option = use_memo(options.middleware, |middleware| {
94:         middleware.clone().unwrap_or_default()
95:     });
96:     let placement_option = use_memo(options.placement, |placement| {
97:         placement.unwrap_or(Placement::Bottom)
98:     });
99:     let strategy_option = use_memo(options.strategy, |strategy| {
100:         strategy.unwrap_or(Strategy::Absolute)
101:     });
102:     let transform_option = use_memo(options.transform, |transform| transform.unwrap_or(true));
103: 
104:     let x = use_state_eq(|| 0.0);
105:     let y = use_state_eq(|| 0.0);
106:     let strategy = use_state_eq(|| *strategy_option);
107:     let placement = use_state_eq(|| *placement_option);
108:     let middleware_data = use_state_eq(MiddlewareData::default);
109:     let is_positioned = use_state_eq(|| false);
110:     let floating_styles = use_memo(
111:         (
112:             floating.clone(),
113:             transform_option,
114:             x.clone(),
115:             y.clone(),
116:             strategy.clone(),
117:         ),
118:         |(floating, transform_option, x, y, strategy)| {
119:             let initial_styles = FloatingStyles {
120:                 position: **strategy,
121:                 top: "0".to_owned(),
122:                 left: "0".to_owned(),
123:                 transform: None,
124:                 will_change: None,
125:             };
126: 
127:             match floating.get() {
128:                 Some(floating_element) => {
129:                     let x_val = round_by_dpr(&floating_element, **x);
130:                     let y_val = round_by_dpr(&floating_element, **y);
131: 
132:                     if **transform_option {
133:                         FloatingStyles {
134:                             transform: Some(format!("translate({x_val}px, {y_val}px)")),
135:                             will_change: (get_dpr(&floating_element) >= 1.5)
136:                                 .then_some("transform".to_owned()),
137:                             ..initial_styles
138:                         }
139:                     } else {
140:                         FloatingStyles {
141:                             left: format!("{x_val}px"),
142:                             top: format!("{y_val}px"),
143:                             ..initial_styles
144:                         }
145:                     }
146:                 }
147:                 _ => initial_styles,
148:             }
149:         },
150:     );
151: 
152:     let update = use_callback(
153:         (
154:             reference.clone(),
155:             floating.clone(),
156:             placement_option.clone(),
157:             strategy_option.clone(),
158:             middleware_option.clone(),
159:             x.clone(),
160:             y.clone(),
161:             strategy.clone(),
162:             placement.clone(),
163:             middleware_data.clone(),
164:             is_positioned.clone(),
165:         ),
166:         {
167:             let open_option = open_option.clone();
168: 
169:             move |_,
170:                   (
171:                 reference,
172:                 floating,
173:                 placement_option,
174:                 strategy_option,
175:                 middleware_option,
176:                 x,
177:                 y,
178:                 strategy,
179:                 placement,
180:                 middleware_data,
181:                 is_positioned,
182:             )| {
183:                 if let Some(reference_element) = reference.get()
184:                     && let Some(floating_element) = floating.get()
185:                 {
186:                     let config = ComputePositionConfig {
187:                         placement: Some(**placement_option),
188:                         strategy: Some(**strategy_option),
189:                         middleware: Some((**middleware_option).clone()),
190:                     };
191: 
192:                     let open = *open_option;
193: 
194:                     let position = compute_position(
195:                         (&reference_element).into(),
196:                         floating_element
197:                             .dyn_ref()
198:                             .expect("Floating element should be an Element."),
199:                         config,
200:                     );
201:                     x.set(position.x);
202:                     y.set(position.y);
203:                     strategy.set(position.strategy);
204:                     placement.set(position.placement);
205:                     middleware_data.set(position.middleware_data);
206:                     // The floating element's position may be recomputed while it's closed
207:                     // but still mounted (such as when transitioning out). To ensure
208:                     // `is_positioned` will be `false` initially on the next open,
209:                     // avoid setting it to `true` when `open === false` (must be specified).
210:                     is_positioned.set(open);
211:                 }
212:             }
213:         },
214:     );
215: 
216:     let while_elements_mounted_cleanup: Rc<
217:         RefCell<Option<ShallowRc<WhileElementsMountedCleanupFn>>>,
218:     > = use_mut_ref(|| None);
219: 
220:     let cleanup = use_callback(
221:         while_elements_mounted_cleanup.clone(),
222:         |_, while_elements_mounted_cleanup| {
223:             if let Some(while_elements_mounted_cleanup) = while_elements_mounted_cleanup.take() {
224:                 while_elements_mounted_cleanup();
225:             }
226:         },
227:     );
228: 
229:     let attach = use_callback(
230:         (
231:             reference.clone(),
232:             floating.clone(),
233:             while_elements_mounted_option,
234:             while_elements_mounted_cleanup,
235:         ),
236:         {
237:             let update = update.clone();
238:             let cleanup = cleanup.clone();
239: 
240:             move |_: (),
241:                   (
242:                 reference,
243:                 floating,
244:                 while_elements_mounted_option,
245:                 while_elements_mounted_cleanup,
246:             )| {
247:                 cleanup.emit(());
248: 
249:                 if let Some(while_elements_mounted) = while_elements_mounted_option {
250:                     if let Some(reference_element) = reference.get()
251:                         && let Some(floating_element) = floating.get()
252:                     {
253:                         while_elements_mounted_cleanup.replace(Some(ShallowRc::from(
254:                             (**while_elements_mounted)(
255:                                 (&reference_element).into(),
256:                                 floating_element
257:                                     .dyn_ref()
258:                                     .expect("Floating element should be an Element."),
259:                                 Rc::new({
260:                                     let update = update.clone();
261: 
262:                                     move || {
263:                                         update.emit(());
264:                                     }
265:                                 }),
266:                             ),
267:                         )));
268:                     }
269:                 } else {
270:                     update.emit(());
271:                 }
272:             }
273:         },
274:     );
275: 
276:     let reset = use_callback(
277:         (open_option.clone(), is_positioned.clone()),
278:         |_, (open_option, is_positioned)| {
279:             if **open_option {
280:                 is_positioned.set(false);
281:             }
282:         },
283:     );
284: 
285:     use_effect_with(
286:         (
287:             open_option.clone(),
288:             placement_option,
289:             strategy_option,
290:             middleware_option,
291:             update.clone(),
292:         ),
293:         |(_, _, _, _, update)| {
294:             update.emit(());
295:         },
296:     );
297: 
298:     use_effect_with((reference, floating, attach), |(_, _, attach)| {
299:         attach.emit(());
300:     });
301: 
302:     use_effect_with((open_option, reset), |(_, reset)| {
303:         reset.emit(());
304:     });
305: 
306:     use_effect_with((), move |_| {
307:         move || {
308:             cleanup.emit(());
309:         }
310:     });
311: 
312:     UseFloatingReturn {
313:         x,
314:         y,
315:         placement,
316:         strategy,
317:         middleware_data,
318:         is_positioned,
319:         floating_styles,
320:         update,
321:     }
322: }
323: ```
324: ```
325: ```
326: ```
327: ```
328: ```
329: ```
330: ```
331: ```
332: ```
333: ```
334: ```
335: ```
336: ```
337: ```
338: ```
```
