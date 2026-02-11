### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\hydration.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\hydration.rs
22: 20: ```rust
23: 21: use crate::{
24: 22:     renderer::{CastFrom, Rndr},
25: 23:     view::{Position, PositionState},
26: 24: };
27: 25: #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
28: 26: use std::cell::Cell;
29: 27: use std::{cell::RefCell, panic::Location, rc::Rc};
30: 28: use web_sys::{Comment, Element, Node, Text};
31: 29: 
32: 30: #[cfg(feature = "mark_branches")]
33: 31: const COMMENT_NODE: u16 = 8;
34: 32: 
35: 33: /// Hydration works by walking over the DOM, adding interactivity as needed.
36: 34: ///
37: 35: /// This cursor tracks the location in the DOM that is currently being hydrated. Each that type
38: 36: /// implements [`RenderHtml`](crate::view::RenderHtml) knows how to advance the cursor to access
39: 37: /// the nodes it needs.
40: 38: #[derive(Debug)]
41: 39: pub struct Cursor(Rc<RefCell<crate::renderer::types::Node>>);
42: 40: 
43: 41: impl Clone for Cursor {
44: 42:     fn clone(&self) -> Self {
45: 43:         Self(Rc::clone(&self.0))
46: 44:     }
47: 45: }
48: 46: 
49: 47: impl Cursor
50: 48: where
51: 49:     crate::renderer::types::Element: AsRef<crate::renderer::types::Node>,
52: 50: {
53: 51:     /// Creates a new cursor starting at the root element.
54: 52:     pub fn new(root: crate::renderer::types::Element) -> Self {
55: 53:         let root = <crate::renderer::types::Element as AsRef<
56: 54:             crate::renderer::types::Node,
57: 55:         >>::as_ref(&root)
58: 56:         .clone();
59: 57:         Self(Rc::new(RefCell::new(root)))
60: 58:     }
61: 59: 
62: 60:     /// Returns the node at which the cursor is currently located.
63: 61:     pub fn current(&self) -> crate::renderer::types::Node {
64: 62:         self.0.borrow().clone()
65: 63:     }
66: 64: 
67: 65:     /// Advances to the next child of the node at which the cursor is located.
68: 66:     ///
69: 67:     /// Does nothing if there is no child.
70: 68:     pub fn child(&self) {
71: 69:         let mut inner = self.0.borrow_mut();
72: 70:         if let Some(node) = Rndr::first_child(&inner) {
73: 71:             *inner = node;
74: 72:         }
75: 73: 
76: 74:         #[cfg(feature = "mark_branches")]
77: 75:         {
78: 76:             while inner.node_type() == COMMENT_NODE {
79: 77:                 if let Some(content) = inner.text_content() {
80: 78:                     if content.starts_with("bo") || content.starts_with("bc") {
81: 79:                         if let Some(sibling) = Rndr::next_sibling(&inner) {
82: 80:                             *inner = sibling;
83: 81:                             continue;
84: 82:                         }
85: 83:                     }
86: 84:                 }
87: 85: 
88: 86:                 break;
89: 87:             }
90: 88:         }
91: 89:         // //drop(inner);
92: 90:         //crate::log(">> which is ");
93: 91:         //Rndr::log_node(&self.current());
94: 92:     }
95: 93: 
96: 94:     /// Advances to the next sibling of the node at which the cursor is located.
97: 95:     ///
98: 96:     /// Does nothing if there is no sibling.
99: 97:     pub fn sibling(&self) {
100: 98:         let mut inner = self.0.borrow_mut();
101: 99:         if let Some(node) = Rndr::next_sibling(&inner) {
102: 100:             *inner = node;
103: 101:         }
104: 102: 
105: 103:         #[cfg(feature = "mark_branches")]
106: 104:         {
107: 105:             while inner.node_type() == COMMENT_NODE {
108: 106:                 if let Some(content) = inner.text_content() {
109: 107:                     if content.starts_with("bo") || content.starts_with("bc") {
110: 108:                         if let Some(sibling) = Rndr::next_sibling(&inner) {
111: 109:                             *inner = sibling;
112: 110:                             continue;
113: 111:                         }
114: 112:                     }
115: 113:                 }
116: 114:                 break;
117: 115:             }
118: 116:         }
119: 117:         //drop(inner);
120: 118:         //crate::log(">> which is ");
121: 119:         //Rndr::log_node(&self.current());
122: 120:     }
123: 121: 
124: 122:     /// Moves to the parent of the node at which the cursor is located.
125: 123:     ///
126: 124:     /// Does nothing if there is no parent.
127: 125:     pub fn parent(&self) {
128: 126:         let mut inner = self.0.borrow_mut();
129: 127:         if let Some(node) = Rndr::get_parent(&inner) {
130: 128:             *inner = node;
131: 129:         }
132: 130:     }
133: 131: 
134: 132:     /// Sets the cursor to some node.
135: 133:     pub fn set(&self, node: crate::renderer::types::Node) {
136: 134:         *self.0.borrow_mut() = node;
137: 135:     }
138: 136: 
139: 137:     /// Advances to the next placeholder node and returns it
140: 138:     pub fn next_placeholder(
141: 139:         &self,
142: 140:         position: &PositionState,
143: 141:     ) -> crate::renderer::types::Placeholder {
144: 142:         //crate::dom::log("looking for placeholder after");
145: 143:         //Rndr::log_node(&self.current());
146: 144:         self.advance_to_placeholder(position);
147: 145:         let marker = self.current();
148: 146:         crate::renderer::types::Placeholder::cast_from(marker.clone())
149: 147:             .unwrap_or_else(|| failed_to_cast_marker_node(marker))
150: 148:     }
151: 149: 
152: 150:     /// Advances to the next placeholder node.
153: 151:     pub fn advance_to_placeholder(&self, position: &PositionState) {
154: 152:         if position.get() == Position::FirstChild {
155: 153:             self.child();
156: 154:         } else {
157: 155:             self.sibling();
158: 156:         }
159: 157:         position.set(Position::NextChild);
160: 158:     }
161: 159: }
162: 160: 
163: 161: #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
164: 162: thread_local! {
165: 163:     static CURRENTLY_HYDRATING: Cell<Option<&'static Location<'static>>> = const { Cell::new(None) };
166: 164: }
167: 165: 
168: 166: pub(crate) fn set_currently_hydrating(
169: 167:     location: Option<&'static Location<'static>>,
170: 168: ) {
171: 169:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
172: 170:     {
173: 171:         CURRENTLY_HYDRATING.set(location);
174: 172:     }
175: 173:     #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
176: 174:     {
177: 175:         _ = location;
178: 176:     }
179: 177: }
180: 178: 
181: 179: pub(crate) fn failed_to_cast_element(tag_name: &str, node: Node) -> Element {
182: 180:     #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
183: 181:     {
184: 182:         _ = node;
185: 183:         unreachable!();
186: 184:     }
187: 185:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
188: 186:     {
189: 187:         let hydrating = CURRENTLY_HYDRATING
190: 188:             .take()
191: 189:             .map(|n| n.to_string())
192: 190:             .unwrap_or_else(|| "{unknown}".to_string());
193: 191:         web_sys::console::error_3(
194: 192:             &wasm_bindgen::JsValue::from_str(&format!(
195: 193:                 "A hydration error occurred while trying to hydrate an \
196: 194:                  element defined at {hydrating}.\n\nThe framework expected an \
197: 195:                  HTML <{tag_name}> element, but found this instead: ",
198: 196:             )),
199: 197:             &node,
200: 198:             &wasm_bindgen::JsValue::from_str(
201: 199:                 "\n\nThe hydration mismatch may have occurred slightly \
202: 200:                  earlier, but this is the first time the framework found a \
203: 201:                  node of an unexpected type.",
204: 202:             ),
205: 203:         );
206: 204:         panic!(
207: 205:             "Unrecoverable hydration error. Please read the error message \
208: 206:              directly above this for more details."
209: 207:         );
210: 208:     }
211: 209: }
212: 210: 
213: 211: pub(crate) fn failed_to_cast_marker_node(node: Node) -> Comment {
214: 212:     #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
215: 213:     {
216: 214:         _ = node;
217: 215:         unreachable!();
218: 216:     }
219: 217:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
220: 218:     {
221: 219:         let hydrating = CURRENTLY_HYDRATING
222: 220:             .take()
223: 221:             .map(|n| n.to_string())
224: 222:             .unwrap_or_else(|| "{unknown}".to_string());
225: 223:         web_sys::console::error_3(
226: 224:             &wasm_bindgen::JsValue::from_str(&format!(
227: 225:                 "A hydration error occurred while trying to hydrate an \
228: 226:                  element defined at {hydrating}.\n\nThe framework expected a \
229: 227:                  marker node, but found this instead: ",
230: 228:             )),
231: 229:             &node,
232: 230:             &wasm_bindgen::JsValue::from_str(
233: 231:                 "\n\nThe hydration mismatch may have occurred slightly \
234: 232:                  earlier, but this is the first time the framework found a \
235: 233:                  node of an unexpected type.",
236: 234:             ),
237: 235:         );
238: 236:         panic!(
239: 237:             "Unrecoverable hydration error. Please read the error message \
240: 238:              directly above this for more details."
241: 239:         );
242: 240:     }
243: 241: }
244: 242: 
245: 243: pub(crate) fn failed_to_cast_text_node(node: Node) -> Text {
246: 244:     #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
247: 245:     {
248: 246:         _ = node;
249: 247:         unreachable!();
250: 248:     }
251: 249:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
252: 250:     {
253: 251:         let hydrating = CURRENTLY_HYDRATING
254: 252:             .take()
255: 253:             .map(|n| n.to_string())
256: 254:             .unwrap_or_else(|| "{unknown}".to_string());
257: 255:         web_sys::console::error_3(
258: 256:             &wasm_bindgen::JsValue::from_str(&format!(
259: 257:                 "A hydration error occurred while trying to hydrate an \
260: 258:                  element defined at {hydrating}.\n\nThe framework expected a \
261: 259:                  text node, but found this instead: ",
262: 260:             )),
263: 261:             &node,
264: 262:             &wasm_bindgen::JsValue::from_str(
265: 263:                 "\n\nThe hydration mismatch may have occurred slightly \
266: 264:                  earlier, but this is the first time the framework found a \
267: 265:                  node of an unexpected type.",
268: 266:             ),
269: 267:         );
270: 268:         panic!(
271: 269:             "Unrecoverable hydration error. Please read the error message \
272: 270:              directly above this for more details."
273: 271:         );
274: 272:     }
275: 273: }
276: 274: ```
277: 275: ```
278: 276: ```
279: 277: ```
280: 278: ```
281: 279: ```
282: 280: ```
283: 281: ```
284: 282: ```
285: 283: ```
286: ```
```
