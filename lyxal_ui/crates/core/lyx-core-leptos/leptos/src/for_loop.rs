### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\for_loop.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\for_loop.rs
2: ```rust
3: 1: use crate::into_view::IntoView;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::component;
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
6: 4:     owner::Owner,
7: 5:     signal::{ArcRwSignal, ReadSignal},
8: 6:     traits::Set,
9: 7: };
10: 8: use std::hash::Hash;
11: 9: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{
12: 10:     lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::OwnedView,
13: 11:     view::keyed::{keyed, SerializableKey},
14: 12: };
15: 13: 
16: 14: /// Iterates over children and displays them, keyed by the `key` function given.
17: 15: ///
18: 16: /// This is much more efficient than naively iterating over nodes with `.iter().map(|n| view! { ... })...`,
19: 17: /// as it avolyx-core-lyx_core_lyx-core-lyx_core_ids re-creating DOM nodes that are not being changed.
20: 18: ///
21: 19: /// ```
22: 20: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
23: 21: ///
24: 22: /// #[derive(Copy, Clone, Debug, PartialEq, Eq)]
25: 23: /// struct Counter {
26: 24: ///   id: usize,
27: 25: ///   count: RwSignal<i32>
28: 26: /// }
29: 27: ///
30: 28: /// #[component]
31: 29: /// fn Counters() -> impl IntoView {
32: 30: ///   let (counters, set_counters) = create_signal::<Vec<Counter>>(vec![]);
33: 31: ///
34: 32: ///   view! {
35: 33: ///     <div>
36: 34: ///       <For
37: 35: ///         // a function that returns the items we're iterating over; a signal is fine
38: 36: ///         each=move || counters.get()
39: 37: ///         // a unique key for each item
40: 38: ///         key=|counter| counter.id
41: 39: ///         // renders each item to a view
42: 40: ///         children=move |counter: Counter| {
43: 41: ///           view! {
44: 42: ///             <button>"Value: " {move || counter.count.get()}</button>
45: 43: ///           }
46: 44: ///         }
47: 45: ///       />
48: 46: ///     </div>
49: 47: ///   }
50: 48: /// }
51: 49: /// ```
52: 50: ///
53: 51: /// For convenience, you can also choose to write template code directly in the `<For>`
54: 52: /// component, using the `let` syntax:
55: 53: ///
56: 54: /// ```
57: 55: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
58: 56: ///
59: 57: /// # #[derive(Copy, Clone, Debug, PartialEq, Eq)]
60: 58: /// # struct Counter {
61: 59: /// #   id: usize,
62: 60: /// #   count: RwSignal<i32>
63: 61: /// # }
64: 62: /// #
65: 63: /// # #[component]
66: 64: /// # fn Counters() -> impl IntoView {
67: 65: /// #   let (counters, set_counters) = create_signal::<Vec<Counter>>(vec![]);
68: 66: /// #
69: 67: ///   view! {
70: 68: ///     <div>
71: 69: ///         <For
72: 70: ///           each=move || counters.get()
73: 71: ///           key=|counter| counter.id
74: 72: ///           let(counter)
75: 73: ///         >
76: 74: ///             <button>"Value: " {move || counter.count.get()}</button>
77: 75: ///         </For>
78: 76: ///     </div>
79: 77: ///   }
80: 78: /// # }
81: 79: /// ```
82: 80: ///
83: 81: /// The `let` syntax also supports destructuring the pattern of your data.
84: 82: /// `let((one, two))` in the case of tuples, and `let(Struct { field_one, field_two })`
85: 83: /// in the case of structs.
86: 84: ///
87: 85: /// ```
88: 86: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
89: 87: ///
90: 88: /// # #[derive(Copy, Clone, Debug, PartialEq, Eq)]
91: 89: /// # struct Counter {
92: 90: /// #   id: usize,
93: 91: /// #   count: RwSignal<i32>
94: 92: /// # }
95: 93: /// #
96: 94: /// # #[component]
97: 95: /// # fn Counters() -> impl IntoView {
98: 96: /// #   let (counters, set_counters) = create_signal::<Vec<Counter>>(vec![]);
99: 97: /// #
100: 98: ///   view! {
101: 99: ///     <div>
102: 100: ///         <For
103: 101: ///           each=move || counters.get()
104: 102: ///           key=|counter| counter.id
105: 103: ///           let(Counter { id, count })
106: 104: ///         >
107: 105: ///             <button>"Value: " {move || count.get()}</button>
108: 106: ///         </For>
109: 107: ///     </div>
110: 108: ///   }
111: 109: /// # }
112: 110: /// ```
113: 111: #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
114: 112: #[component]
115: 113: pub fn For<IF, I, T, EF, N, KF, K>(
116: 114:     /// Items over which the component should iterate.
117: 115:     each: IF,
118: 116:     /// A key function that will be lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to each item.
119: 117:     key: KF,
120: 118:     /// A function that takes the item, and returns the view that will be displayed for each item.
121: 119:     children: EF,
122: 120: ) -> impl IntoView
123: 121: where
124: 122:     IF: Fn() -> I + Send + 'static,
125: 123:     I: IntoIterator<Item = T> + Send + 'static,
126: 124:     EF: Fn(T) -> N + Send + Clone + 'static,
127: 125:     N: IntoView + 'static,
128: 126:     KF: Fn(&T) -> K + Send + Clone + 'static,
129: 127:     K: Eq + Hash + SerializableKey + 'static,
130: 128:     T: Send + 'static,
131: 129: {
132: 130:     // this takes the owner of the For itself
133: 131:     // this will end up with N + 1 children
134: 132:     // 1) the effect for the `move || keyed(...)` updates
135: 133:     // 2) an owner for each child
136: 134:     //
137: 135:     // this means
138: 136:     // a) the reactive owner for each row will not be cleared when the whole list updates
139: 137:     // b) context provided in each row will not wipe out the others
140: 138:     let parent = Owner::current().expect("no reactive owner");
141: 139:     let children = move |_, child| {
142: 140:         let owner = parent.with(Owner::new);
143: 141:         let view = owner.with(|| children(child));
144: 142:         (drop, OwnedView::new_with_owner(view, owner))
145: 143:     };
146: 144:     move || keyed(each(), key.clone(), children.clone())
147: 145: }
148: 146: 
149: 147: /// Iterates over children and displays them, keyed by the `key` function given.
150: 148: ///
151: 149: /// Compared with For, it has an additional index parameter, which can be used to obtain the current index in real time.
152: 150: ///
153: 151: /// This is much more efficient than naively iterating over nodes with `.iter().map(|n| view! { ... })...`,
154: 152: /// as it avolyx-core-lyx_core_lyx-core-lyx_core_ids re-creating DOM nodes that are not being changed.
155: 153: ///
156: 154: /// ```
157: 155: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
158: 156: ///
159: 157: /// #[derive(Copy, Clone, Debug, PartialEq, Eq)]
160: 158: /// struct Counter {
161: 159: ///   id: usize,
162: 160: ///   count: RwSignal<i32>
163: 161: /// }
164: 162: ///
165: 163: /// #[component]
166: 164: /// fn Counters() -> impl IntoView {
167: 165: ///   let (counters, set_counters) = create_signal::<Vec<Counter>>(vec![]);
168: 166: ///
169: 167: ///   view! {
170: 168: ///     <div>
171: 169: ///       <ForEnumerate
172: 170: ///         // a function that returns the items we're iterating over; a signal is fine
173: 171: ///         each=move || counters.get()
174: 172: ///         // a unique key for each item
175: 173: ///         key=|counter| counter.id
176: 174: ///         // renders each item to a view
177: 175: ///         children={move |index: ReadSignal<usize>, counter: Counter| {
178: 176: ///           view! {
179: 177: ///             <button>{move || index.get()} ". Value: " {move || counter.count.get()}</button>
180: 178: ///           }
181: 179: ///         }}
182: 180: ///       />
183: 181: ///     </div>
184: 182: ///   }
185: 183: /// }
186: 184: /// ```
187: 185: #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
188: 186: #[component]
189: 187: pub fn ForEnumerate<IF, I, T, EF, N, KF, K>(
190: 188:     /// Items over which the component should iterate.
191: 189:     each: IF,
192: 190:     /// A key function that will be lyx-platform-lyx_platform_lyx-platform-lyx_platform_applied to each item.
193: 191:     key: KF,
194: 192:     /// A function that takes the index and the item, and returns the view that will be displayed for each item.
195: 193:     children: EF,
196: 194: ) -> impl IntoView
197: 195: where
198: 196:     IF: Fn() -> I + Send + 'static,
199: 197:     I: IntoIterator<Item = T> + Send + 'static,
200: 198:     EF: Fn(ReadSignal<usize>, T) -> N + Send + Clone + 'static,
201: 199:     N: IntoView + 'static,
202: 200:     KF: Fn(&T) -> K + Send + Clone + 'static,
203: 201:     K: Eq + Hash + SerializableKey + 'static,
204: 202:     T: Send + 'static,
205: 203: {
206: 204:     // this takes the owner of the For itself
207: 205:     // this will end up with N + 1 children
208: 206:     // 1) the effect for the `move || keyed(...)` updates
209: 207:     // 2) an owner for each child
210: 208:     //
211: 209:     // this means
212: 210:     // a) the reactive owner for each row will not be cleared when the whole list updates
213: 211:     // b) context provided in each row will not wipe out the others
214: 212:     let parent = Owner::current().expect("no reactive owner");
215: 213:     let children = move |index, child| {
216: 214:         let owner = parent.with(Owner::new);
217: 215:         let (index, set_index) = ArcRwSignal::new(index).split();
218: 216:         let view = owner.with(|| children(index.into(), child));
219: 217:         (
220: 218:             move |index| set_index.set(index),
221: 219:             OwnedView::new_with_owner(view, owner),
222: 220:         )
223: 221:     };
224: 222:     move || keyed(each(), key.clone(), children.clone())
225: 223: }
226: 224: 
227: 225: /*
228: 226: #[cfg(test)]
229: 227: mod tests {
230: 228:     use crate::prelude::*;
231: 229:     use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::view;
232: 230:     use lyx-core-lyx_core_lyx-core-lyx_core_tachys::{html::element::HtmlElement, prelude::ElementChild};
233: 231: 
234: 232:     #[test]
235: 233:     fn creates_list() {
236: 234:         Owner::new().with(|| {
237: 235:             let values = RwSignal::new(vec![1, 2, 3, 4, 5]);
238: 236:             let list: View<HtmlElement<_, _, _>> = view! {
239: 237:                 <ol>
240: 238:                     <For each=move || values.get() key=|i| *i let:i>
241: 239:                         <li>{i}</li>
242: 240:                     </For>
243: 241:                 </ol>
244: 242:             };
245: 243:             assert_eq!(
246: 244:                 list.to_html(),
247: 245:                 "<ol><li>1</li><li>2</li><li>3</li><li>4</li><li>5</li><!></\
248: 246:                  ol>"
249: 247:             );
250: 248:         });
251: 249:     }
252: 250: 
253: 251:     #[test]
254: 252:     fn creates_list_enumerate() {
255: 253:         Owner::new().with(|| {
256: 254:             let values = RwSignal::new(vec![1, 2, 3, 4, 5]);
257: 255:             let list: View<HtmlElement<_, _, _>> = view! {
258: 256:                 <ol>
259: 257:                     <ForEnumerate each=move || values.get() key=|i| *i let(index, i)>
260: 258:                         <li>{move || index.get()}"-"{i}</li>
261: 259:                     </ForEnumerate>
262: 260:                 </ol>
263: 261:             };
264: 262:             assert_eq!(
265: 263:                 list.to_html(),
266: 264:                 "<ol><li>0<!>-<!>1</li><li>1<!>-<!>2</li><li>2<!>-<!>3</li><li>3\
267: 265:                 <!>-<!>4</li><li>4<!>-<!>5</li><!></ol>"
268: 266:             );
269: 267: 
270: 268:             let list: View<HtmlElement<_, _, _>> = view! {
271: 269:                 <ol>
272: 270:                     <ForEnumerate each=move || values.get() key=|i| *i let(index, i)>
273: 271:                         <li>{move || index.get()}"-"{i}</li>
274: 272:                     </ForEnumerate>
275: 273:                 </ol>
276: 274:             };
277: 275:             values.set(vec![5, 4, 1, 2, 3]);
278: 276:             assert_eq!(
279: 277:                 list.to_html(),
280: 278:                 "<ol><li>0<!>-<!>5</li><li>1<!>-<!>4</li><li>2<!>-<!>1</li><li>3\
281: 279:                 <!>-<!>2</li><li>4<!>-<!>3</li><!></ol>"
282: 280:             );
283: 281:         });
284: 282:     }
285: 283: }
286: 284:  */
287: ```
```
