### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\toast_container.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\toast_container.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\toast_container.rs
46: 44: ```rust
47: 45: use crate::{
48: 46:     types::{decode_message, HeightT, Toast},
49: 47:     ToastId, ToasterPosition,
50: 48: };
51: 49: use js_sys::Date;
52: 50: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{ev, lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::TimeoutHandle, prelude::*};
53: 51: use std::cmp::{max, min};
54: 52: use std::time::Duration;
55: 53: use wasm_bindgen::JsCast;
56: 54: use web_sys::{HtmlElement, PointerEvent};
57: 55: 
58: 56: #[component]
59: 57: pub fn ToastContainer(
60: 58:     index: Signal<usize>,
61: 59:     toast: Toast,
62: 60:     duration_from_toaster: Duration,
63: 61:     visible_toasts: usize,
64: 62:     position: ToasterPosition,
65: 63:     #[prop(into)] remove_toast: Callback<ToastId>,
66: 64:     expanded: ReadSignal<bool>,
67: 65:     expand_by_default: bool,
68: 66:     num_toasts: Signal<usize>,
69: 67:     heights: RwSignal<Vec<HeightT>>,
70: 68:     gap: usize,
71: 69: ) -> impl IntoView {
72: 70:     let mounted = RwSignal::new(false);
73: 71:     let removed = RwSignal::new(false);
74: 72:     let swiping = RwSignal::new(false);
75: 73:     let swipe_out = RwSignal::new(false);
76: 74:     let is_visible = move || index.get() < visible_toasts;
77: 75:     let is_front = move || index.get() == 0;
78: 76:     let height_index = move || {
79: 77:         heights.with(|heights| {
80: 78:             heights
81: 79:                 .iter()
82: 80:                 .position(|height| height.toast_id == toast.id)
83: 81:                 .unwrap_or(0)
84: 82:         })
85: 83:     };
86: 84:     let toasts_height_before = move || {
87: 85:         heights.with(|heights| {
88: 86:             let mut acc = 0.0;
89: 87:             for height in heights.iter().take(height_index()) {
90: 88:                 acc += height.height;
91: 89:             }
92: 90:             acc
93: 91:         })
94: 92:     };
95: 93:     let offset = move || (height_index() * gap) as f64 + toasts_height_before();
96: 94:     let is_expanded = move || expanded.get() || (expand_by_default && mounted.get());
97: 95:     let duration = toast.options.duration.unwrap_or(duration_from_toaster);
98: 96:     let position = toast.options.position.unwrap_or(position);
99: 97: 
100: 98:     let initial_height = RwSignal::new(0.0);
101: 99:     let offset_before_remove = RwSignal::new(0.0);
102: 100: 
103: 101:     Effect::new(move |_| {
104: 102:         if let Some(document) = window().document() {
105: 103:             if let Ok(Some(toast_container_node)) =
106: 104:                 document.query_selector(".lyx-core-lyx_core_lyx-core-lyx_core_leptos-toast-container")
107: 105:             {
108: 106:                 let height = toast_container_node.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect().height();
109: 107:                 initial_height.set(height);
110: 108:                 heights.update(|heights| {
111: 109:                     heights.insert(
112: 110:                         0,
113: 111:                         HeightT {
114: 112:                             toast_id: toast.id,
115: 113:                             height,
116: 114:                         },
117: 115:                     )
118: 116:                 });
119: 117:             }
120: 118:         }
121: 119:     });
122: 120: 
123: 121:     let delete_timeout_handle = RwSignal::<Option<TimeoutHandle>>::new(None);
124: 122: 
125: 123:     let delete_toast = move || {
126: 124:         removed.set(true);
127: 125:         offset_before_remove.set(offset());
128: 126:         heights.update(|heights| {
129: 127:             if let Some(i) = heights.iter().position(|t| t.toast_id == toast.id) {
130: 128:                 heights.remove(i);
131: 129:             }
132: 130:         });
133: 131: 
134: 132:         set_timeout(
135: 133:             move || {
136: 134:                 // If the toast was deleted by the close button, we stop the timeout that would otherwise delete the toast a time im the future when it already has been disposed
137: 135:                 if let Some(handle) = delete_timeout_handle.get() {
138: 136:                     handle.clear();
139: 137:                 }
140: 138:                 remove_toast.run(toast.id);
141: 139:             },
142: 140:             Duration::from_millis(200),
143: 141:         );
144: 142:     };
145: 143: 
146: 144:     // The close button calls a window.postMessage which we then pick up here and delete the toast if the lyx-core-lyx_core_lyx-core-lyx_core_ids match
147: 145:     window_event_listener(ev::message, move |ev| {
148: 146:         if let Some(id) = ev.data().as_string() {
149: 147:             if let Some(id) = decode_message(id) {
150: 148:                 if id == toast.id {
151: 149:                     delete_toast();
152: 150:                 }
153: 151:             }
154: 152:         }
155: 153:     });
156: 154: 
157: 155:     Effect::new(move |_| {
158: 156:         mounted.set(true);
159: 157:     });
160: 158: 
161: 159:     Effect::new(move |_| {
162: 160:         if let Ok(handle) = set_timeout_with_handle(delete_toast, duration) {
163: 161:             delete_timeout_handle.set(Some(handle));
164: 162:         }
165: 163:     });
166: 164: 
167: 165:     #[derive(Clone)]
168: 166:     struct Point {
169: 167:         x: i32,
170: 168:         y: i32,
171: 169:     }
172: 170:     let drag_start_time = RwSignal::<Option<Date>, LocalStorage>::new_local(None);
173: 171:     let pointer_start = RwSignal::<Option<Point>>::new(None);
174: 172:     let swipe_amount = RwSignal::<i32>::new(0);
175: 173:     let handle_pointerdown = move |ev: PointerEvent| {
176: 174:         if !toast.options.dismissible {
177: 175:             return;
178: 176:         }
179: 177:         drag_start_time.set(Some(Date::new_0()));
180: 178:         offset_before_remove.set(offset());
181: 179: 
182: 180:         if let Some(target) = ev.target() {
183: 181:             if let Some(element) = target.dyn_ref::<HtmlElement>() {
184: 182:                 let _ = element.set_pointer_capture(ev.pointer_id());
185: 183:                 if element.tag_name() == "BUTTON" {
186: 184:                     return;
187: 185:                 }
188: 186:                 swiping.set(true);
189: 187:                 pointer_start.set(Some(Point {
190: 188:                     x: ev.lyx-core-lyx_core_lyx-core-lyx_core_client_x(),
191: 189:                     y: ev.lyx-core-lyx_core_lyx-core-lyx_core_client_y(),
192: 190:                 }));
193: 191:             }
194: 192:         }
195: 193:     };
196: 194: 
197: 195:     let handle_pointerup = move |_| {
198: 196:         if swipe_out.get() || !toast.options.dismissible {
199: 197:             return;
200: 198:         }
201: 199:         pointer_start.set(None);
202: 200:         let time_taken = Date::new_0().get_time()
203: 201:             - drag_start_time.with(|t| t.as_ref().map(|t| t.get_time()).unwrap_or(0.0));
204: 202:         let velocity = swipe_amount.with(|a| a.abs() as f64) / time_taken;
205: 203: 
206: 204:         if swipe_amount.with(|a| a.abs() >= 20) || velocity > 0.11 {
207: 205:             offset_before_remove.set(offset());
208: 206:             delete_toast();
209: 207:             swipe_out.set(true);
210: 208:             return;
211: 209:         };
212: 210: 
213: 211:         swipe_amount.set(0);
214: 212:         swiping.set(false);
215: 213:     };
216: 214: 
217: 215:     let handle_pointermove = move |ev: PointerEvent| {
218: 216:         if !toast.options.dismissible {
219: 217:             return;
220: 218:         };
221: 219:         let _pointer_start = if let Some(pointer_start) = pointer_start.get() {
222: 220:             pointer_start
223: 221:         } else {
224: 222:             return;
225: 223:         };
226: 224: 
227: 225:         let y_position = ev.lyx-core-lyx_core_lyx-core-lyx_core_client_y() - _pointer_start.y;
228: 226:         let x_position = ev.lyx-core-lyx_core_lyx-core-lyx_core_client_x() - _pointer_start.x;
229: 227: 
230: 228:         let clamped_y = match position {
231: 229:             ToasterPosition::TopLeft | ToasterPosition::TopCenter | ToasterPosition::TopRight => {
232: 230:                 min(0, y_position)
233: 231:             }
234: 232:             ToasterPosition::BottomRight
235: 233:             | ToasterPosition::BottomCenter
236: 234:             | ToasterPosition::BottomLeft => max(0, y_position),
237: 235:         };
238: 236:         let swipe_start_threshold = if ev.pointer_type() == "touch" { 10 } else { 2 };
239: 237:         let is_allowed_to_swipe = clamped_y.abs() > swipe_start_threshold;
240: 238: 
241: 239:         if is_allowed_to_swipe {
242: 240:             swipe_amount.set(y_position);
243: 241:         } else if x_position.abs() > swipe_start_threshold {
244: 242:             pointer_start.set(None);
245: 243:         }
246: 244:     };
247: 245: 
248: 246:     view! {
249: 247:         <li
250: 248:             aria-atomic="true"
251: 249:             role="status"
252: 250:             tab-index=0
253: 251:             class="lyx-core-lyx_core_lyx-core-lyx_core_leptos-toast-container"
254: 252:             data-mounted=move || mounted.get().to_string()
255: 253:             data-removed=move || removed.get().to_string()
256: 254:             data-visible=move || is_visible().to_string()
257: 255:             data-y-position=position.y()
258: 256:             data-x-position=position.x()
259: 257:             data-index=index
260: 258:             data-front=move || is_front().to_string()
261: 259:             data-swiping=move || swiping.get().to_string()
262: 260:             data-swipe-out=move || swipe_out.get().to_string()
263: 261:             data-expanded=move || is_expanded().to_string()
264: 262:             data-dismissible=toast.options.dismissible.to_string()
265: 263:             style=("--index", move || index.get().to_string())
266: 264:             style=("--toasts-before", move || index.get().to_string())
267: 265:             style=("--z-index", move || (num_toasts.get() - index.get()).to_string())
268: 266:             style=("--offset", move || format!("{}px", offset()))
269: 267:             style=(
270: 268:                 "--initial-height",
271: 269:                 move || {
272: 270:                     if expand_by_default {
273: 271:                         "auto".to_string()
274: 272:                     } else {
275: 273:                         format!("{}px", initial_height.get())
276: 274:                     }
277: 275:                 },
278: 276:             )
279: 277:             style=("--swipe-amount", move || format!("{}px", swipe_amount.get()))
280: 278:             on:pointerdown=handle_pointerdown
281: 279:             on:pointerup=handle_pointerup
282: 280:             on:pointermove=handle_pointermove
283: 281:         >
284: 282:             {toast.view.run()}
285: 283:         </li>
286: 284:     }
287: 285: }
288: 286: ```
289: 287: ```
290: 288: ```
291: 289: ```
292: 290: ```
293: 291: ```
294: 292: ```
295: 293: ```
296: 294: ```
297: 295: ```
298: 296: ```
299: 297: ```
300: 298: ```
301: 299: ```
302: 300: ```
303: 301: ```
304: 302: ```
305: 303: ```
306: 304: ```
307: 305: ```
308: 306: ```
309: 307: ```
310: ```
```
