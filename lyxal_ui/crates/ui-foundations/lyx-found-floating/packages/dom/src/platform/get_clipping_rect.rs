### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform\get_clipping_rect.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform\get_clipping_rect.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_clipping_rect.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_core::{GetClippingRectArgs, RootBoundary};
44: 42: use lyx_ui_foundations_utils::{
45: 43:     ClientRectObject, Rect, Strategy,
46: 44:     dom::{
47: 45:         OverflowAncestor, get_computed_style, get_document_element, get_node_name,
48: 46:         get_overflow_ancestors, get_parent_node, is_containing_block, is_last_traversable_node,
49: 47:         is_overflow_element, is_top_layer,
50: 48:     },
51: 49:     rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect,
52: 50: };
53: 51: use web_sys::{CssStyleDeclaration, Element, Node, wasm_bindgen::JsCast};
54: 52: 
55: 53: use crate::{
56: 54:     platform::{Platform, get_scale::get_scale},
57: 55:     types::Boundary,
58: 56:     utils::{
59: 57:         get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect::get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect, get_document_rect::get_document_rect,
60: 58:         get_viewport_rect::get_viewport_rect, get_visual_offsets::get_visual_offsets,
61: 59:     },
62: 60: };
63: 61: 
64: 62: #[derive(Clone, Debug)]
65: 63: enum ElementOrRootBoundary {
66: 64:     Element(Element),
67: 65:     RootBoundary(RootBoundary),
68: 66: }
69: 67: 
70: 68: fn get_inner_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(element: &Element, strategy: Strategy) -> Rect {
71: 69:     let lyx-core-lyx_core_lyx-core-lyx_core_client_rect =
72: 70:         get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(element.into(), true, strategy == Strategy::Fixed, None);
73: 71:     let top = lyx-core-lyx_core_lyx-core-lyx_core_client_rect.top + element.lyx-core-lyx_core_lyx-core-lyx_core_client_top() as f64;
74: 72:     let left = lyx-core-lyx_core_lyx-core-lyx_core_client_rect.left + element.lyx-core-lyx_core_lyx-core-lyx_core_client_left() as f64;
75: 73:     let scale = get_scale(element.into());
76: 74: 
77: 75:     Rect {
78: 76:         x: left * scale.x,
79: 77:         y: top * scale.y,
80: 78:         width: element.lyx-core-lyx_core_lyx-core-lyx_core_client_width() as f64 * scale.x,
81: 79:         height: element.lyx-core-lyx_core_lyx-core-lyx_core_client_height() as f64 * scale.y,
82: 80:     }
83: 81: }
84: 82: 
85: 83: fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rect_from_clipping_ancestor(
86: 84:     element: &Element,
87: 85:     clipping_ancestor: ElementOrRootBoundary,
88: 86:     strategy: Strategy,
89: 87: ) -> ClientRectObject {
90: 88:     let rect = match clipping_ancestor {
91: 89:         ElementOrRootBoundary::Element(element) => {
92: 90:             get_inner_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(&element, strategy)
93: 91:         }
94: 92:         ElementOrRootBoundary::RootBoundary(RootBoundary::Viewport) => {
95: 93:             get_viewport_rect(&get_document_element(Some(element.into())), strategy)
96: 94:         }
97: 95:         ElementOrRootBoundary::RootBoundary(RootBoundary::Document) => {
98: 96:             get_document_rect(&get_document_element(Some(element.into())))
99: 97:         }
100: 98:         ElementOrRootBoundary::RootBoundary(RootBoundary::Rect(rect)) => {
101: 99:             let visual_offsets = get_visual_offsets(Some(element));
102: 100:             Rect {
103: 101:                 x: rect.x - visual_offsets.x,
104: 102:                 y: rect.y - visual_offsets.y,
105: 103:                 width: rect.width,
106: 104:                 height: rect.height,
107: 105:             }
108: 106:         }
109: 107:     };
110: 108: 
111: 109:     rect_to_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(rect)
112: 110: }
113: 111: 
114: 112: fn has_fixed_position_ancestor(element: &Element, stop_node: &Node) -> bool {
115: 113:     let parent_node = get_parent_node(element);
116: 114:     if &parent_node == stop_node
117: 115:         || !parent_node.is_instance_of::<Element>()
118: 116:         || is_last_traversable_node(&parent_node)
119: 117:     {
120: 118:         false
121: 119:     } else {
122: 120:         let element = parent_node.unchecked_into::<Element>();
123: 121:         get_computed_style(&element)
124: 122:             .get_property_value("position")
125: 123:             .expect("Computed style should have position.")
126: 124:             == "fixed"
127: 125:             || has_fixed_position_ancestor(&element, stop_node)
128: 126:     }
129: 127: }
130: 128: 
131: 129: fn get_clipping_element_ancestors(element: &Element) -> Vec<Element> {
132: 130:     // TODO: cache
133: 131: 
134: 132:     let mut result: Vec<Element> = get_overflow_ancestors(element, vec![], false)
135: 133:         .into_iter()
136: 134:         .filter_map(|ancestor| match ancestor {
137: 135:             OverflowAncestor::Element(element) => {
138: 136:                 (get_node_name((&element).into()) != "body").then_some(element)
139: 137:             }
140: 138:             OverflowAncestor::Window(_) => None,
141: 139:         })
142: 140:         .collect();
143: 141:     let mut current_containing_block_computed_style: Option<CssStyleDeclaration> = None;
144: 142:     let element_is_fixed = get_computed_style(element)
145: 143:         .get_property_value("position")
146: 144:         .expect("Computed style should have position.")
147: 145:         == "fixed";
148: 146:     let mut current_node: Node = if element_is_fixed {
149: 147:         get_parent_node(element)
150: 148:     } else {
151: 149:         element.clone().into()
152: 150:     };
153: 151: 
154: 152:     // https://developer.mozilla.org/en-US/docs/Web/CSS/Containing_block#identifying_the_containing_block
155: 153:     while current_node.is_instance_of::<Element>() && !is_last_traversable_node(&current_node) {
156: 154:         let current_element = current_node.unchecked_ref::<Element>();
157: 155:         let computed_style = get_computed_style(current_element);
158: 156:         let current_node_is_containing = is_containing_block(current_element.into());
159: 157: 
160: 158:         let position = computed_style
161: 159:             .get_property_value("position")
162: 160:             .expect("Computed style should have position");
163: 161: 
164: 162:         if !current_node_is_containing && position == "fixed" {
165: 163:             current_containing_block_computed_style = None;
166: 164:         }
167: 165: 
168: 166:         let should_drop_current_node = if element_is_fixed {
169: 167:             !current_node_is_containing && current_containing_block_computed_style.is_none()
170: 168:         } else {
171: 169:             (!current_node_is_containing
172: 170:                 && position == "static"
173: 171:                 && current_containing_block_computed_style
174: 172:                     .as_ref()
175: 173:                     .is_some_and(|style| {
176: 174:                         let positon = style
177: 175:                             .get_property_value("position")
178: 176:                             .expect("Computed style should have position");
179: 177: 
180: 178:                         positon == "absolute" || positon == "fixed"
181: 179:                     }))
182: 180:                 || (is_overflow_element(current_element)
183: 181:                     && !current_node_is_containing
184: 182:                     && has_fixed_position_ancestor(element, current_element))
185: 183:         };
186: 184: 
187: 185:         if should_drop_current_node {
188: 186:             result.retain(|ancestor| ancestor != current_element);
189: 187:         } else {
190: 188:             current_containing_block_computed_style = Some(computed_style);
191: 189:         }
192: 190: 
193: 191:         current_node = get_parent_node(&current_node);
194: 192:     }
195: 193: 
196: 194:     // TODO: cache
197: 195: 
198: 196:     result
199: 197: }
200: 198: 
201: 199: pub fn get_clipping_rect(
202: 200:     _platform: &Platform,
203: 201:     GetClippingRectArgs {
204: 202:         element,
205: 203:         boundary,
206: 204:         root_boundary,
207: 205:         strategy,
208: 206:     }: GetClippingRectArgs<Element>,
209: 207: ) -> Rect {
210: 208:     // TODO: cache
211: 209: 
212: 210:     let clipping_element_ancestors = match boundary {
213: 211:         Boundary::ClippingAncestors => {
214: 212:             if is_top_layer(element) {
215: 213:                 vec![]
216: 214:             } else {
217: 215:                 get_clipping_element_ancestors(element)
218: 216:             }
219: 217:         }
220: 218:         _ => vec![],
221: 219:     };
222: 220: 
223: 221:     let element_clipping_ancestors: Vec<Element> = clipping_element_ancestors
224: 222:         .into_iter()
225: 223:         .chain(match boundary {
226: 224:             Boundary::Element(element) => vec![element],
227: 225:             Boundary::Elements(elements) => elements,
228: 226:             _ => vec![],
229: 227:         })
230: 228:         .collect();
231: 229: 
232: 230:     let clipping_ancestors: Vec<ElementOrRootBoundary> = element_clipping_ancestors
233: 231:         .into_iter()
234: 232:         .map(ElementOrRootBoundary::Element)
235: 233:         .chain(vec![ElementOrRootBoundary::RootBoundary(root_boundary)])
236: 234:         .collect();
237: 235: 
238: 236:     let init =
239: 237:         get_lyx-core-lyx_core_lyx-core-lyx_core_client_rect_from_clipping_ancestor(element, clipping_ancestors[0].clone(), strategy);
240: 238:     let clipping_rect = clipping_ancestors
241: 239:         .into_iter()
242: 240:         .fold(init, |mut acc, clipping_ancestor| {
243: 241:             let rect = get_lyx-core-lyx_core_lyx-core-lyx_core_client_rect_from_clipping_ancestor(element, clipping_ancestor, strategy);
244: 242: 
245: 243:             acc.top = acc.top.max(rect.top);
246: 244:             acc.right = acc.right.min(rect.right);
247: 245:             acc.bottom = acc.bottom.min(rect.bottom);
248: 246:             acc.left = acc.left.max(rect.left);
249: 247: 
250: 248:             acc
251: 249:         });
252: 250: 
253: 251:     Rect {
254: 252:         x: clipping_rect.left,
255: 253:         y: clipping_rect.top,
256: 254:         width: clipping_rect.right - clipping_rect.left,
257: 255:         height: clipping_rect.bottom - clipping_rect.top,
258: 256:     }
259: 257: }
260: 258: ```
261: 259: ```
262: 260: ```
263: 261: ```
264: 262: ```
265: 263: ```
266: 264: ```
267: 265: ```
268: 266: ```
269: 267: ```
270: 268: ```
271: 269: ```
272: 270: ```
273: 271: ```
274: 272: ```
275: 273: ```
276: 274: ```
277: 275: ```
278: 276: ```
279: 277: ```
280: ```
```
