### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\mod.rs
18: 16: ```rust
19: 17: use self::attribute::Attribute;
20: 18: use crate::{
21: 19:     hydration::Cursor,
22: 20:     no_attrs,
23: 21:     prelude::{AddAnyAttr, Mountable},
24: 22:     renderer::{
25: 23:         dom::{Element, Node},
26: 24:         CastFrom, Rndr,
27: 25:     },
28: 26:     view::{Position, PositionState, Render, RenderHtml},
29: 27: };
30: 28: use attribute::any_attribute::AnyAttribute;
31: 29: use std::borrow::Cow;
32: 30: 
33: 31: /// Types for HTML attributes.
34: 32: pub mod attribute;
35: 33: /// Types for manipulating the `class` attribute and `classList`.
36: 34: pub mod class;
37: 35: /// Types for creating user-defined attributes with custom behavior (directives).
38: 36: pub mod directive;
39: 37: /// Types for HTML elements.
40: 38: pub mod element;
41: 39: /// Types for DOM events.
42: 40: pub mod event;
43: 41: /// Types for adding interactive islands to inert HTML pages.
44: 42: pub mod islands;
45: 43: /// Types for accessing a reference to an HTML element.
46: 44: pub mod node_ref;
47: 45: /// Types for DOM properties.
48: 46: pub mod property;
49: 47: /// Types for the `style` attribute and individual style manipulation.
50: 48: pub mod style;
51: 49: 
52: 50: /// A `<!DOCTYPE>` declaration.
53: 51: pub struct Doctype {
54: 52:     value: &'static str,
55: 53: }
56: 54: 
57: 55: /// Creates a `<!DOCTYPE>`.
58: 56: pub fn doctype(value: &'static str) -> Doctype {
59: 57:     Doctype { value }
60: 58: }
61: 59: 
62: 60: impl Render for Doctype {
63: 61:     type State = ();
64: 62: 
65: 63:     fn build(self) -> Self::State {}
66: 64: 
67: 65:     fn rebuild(self, _state: &mut Self::State) {}
68: 66: }
69: 67: 
70: 68: no_attrs!(Doctype);
71: 69: 
72: 70: impl RenderHtml for Doctype {
73: 71:     type AsyncOutput = Self;
74: 72:     type Owned = Self;
75: 73: 
76: 74:     const MIN_LENGTH: usize = "<!DOCTYPE html>".len();
77: 75: 
78: 76:     fn dry_resolve(&mut self) {}
79: 77: 
80: 78:     async fn resolve(self) -> Self::AsyncOutput {
81: 79:         self
82: 80:     }
83: 81: 
84: 82:     fn to_html_with_buf(
85: 83:         self,
86: 84:         buf: &mut String,
87: 85:         _position: &mut Position,
88: 86:         _escape: bool,
89: 87:         _mark_branches: bool,
90: 88:         _extra_attrs: Vec<AnyAttribute>,
91: 89:     ) {
92: 90:         buf.push_str("<!DOCTYPE ");
93: 91:         buf.push_str(self.value);
94: 92:         buf.push('>');
95: 93:     }
96: 94: 
97: 95:     fn hydrate<const FROM_SERVER: bool>(
98: 96:         self,
99: 97:         _cursor: &Cursor,
100: 98:         _position: &PositionState,
101: 99:     ) -> Self::State {
102: 100:     }
103: 101: 
104: 102:     fn into_owned(self) -> Self::Owned {
105: 103:         self
106: 104:     }
107: 105: }
108: 106: 
109: 107: /// An element that contains no interactivity, and whose contents can be known at compile time.
110: 108: pub struct InertElement {
111: 109:     html: Cow<'static, str>,
112: 110: }
113: 111: 
114: 112: impl InertElement {
115: 113:     /// Creates a new inert element.
116: 114:     pub fn new(html: impl Into<Cow<'static, str>>) -> Self {
117: 115:         Self { html: html.into() }
118: 116:     }
119: 117: }
120: 118: 
121: 119: /// Retained view state for [`InertElement`].
122: 120: pub struct InertElementState(Cow<'static, str>, Element);
123: 121: 
124: 122: impl Mountable for InertElementState {
125: 123:     fn unmount(&mut self) {
126: 124:         self.1.unmount();
127: 125:     }
128: 126: 
129: 127:     fn mount(&mut self, parent: &Element, marker: Option<&Node>) {
130: 128:         self.1.mount(parent, marker)
131: 129:     }
132: 130: 
133: 131:     fn insert_before_this(&self, child: &mut dyn Mountable) -> bool {
134: 132:         self.1.insert_before_this(child)
135: 133:     }
136: 134: 
137: 135:     fn elements(&self) -> Vec<crate::renderer::types::Element> {
138: 136:         vec![self.1.clone()]
139: 137:     }
140: 138: }
141: 139: 
142: 140: impl Render for InertElement {
143: 141:     type State = InertElementState;
144: 142: 
145: 143:     fn build(self) -> Self::State {
146: 144:         let el = Rndr::create_element_from_html(self.html.clone());
147: 145:         InertElementState(self.html, el)
148: 146:     }
149: 147: 
150: 148:     fn rebuild(self, state: &mut Self::State) {
151: 149:         let InertElementState(prev, el) = state;
152: 150:         if &self.html != prev {
153: 151:             let mut new_el = Rndr::create_element_from_html(self.html.clone());
154: 152:             el.insert_before_this(&mut new_el);
155: 153:             el.unmount();
156: 154:             *el = new_el;
157: 155:             *prev = self.html;
158: 156:         }
159: 157:     }
160: 158: }
161: 159: 
162: 160: impl AddAnyAttr for InertElement {
163: 161:     type Output<SomeNewAttr: Attribute> = Self;
164: 162: 
165: 163:     fn add_any_attr<NewAttr: Attribute>(
166: 164:         self,
167: 165:         _attr: NewAttr,
168: 166:     ) -> Self::Output<NewAttr>
169: 167:     where
170: 168:         Self::Output<NewAttr>: RenderHtml,
171: 169:     {
172: 170:         panic!(
173: 171:             "InertElement does not support adding attributes. It should only \
174: 172:              be used as a child, and not returned at the top level."
175: 173:         )
176: 174:     }
177: 175: }
178: 176: 
179: 177: impl RenderHtml for InertElement {
180: 178:     type AsyncOutput = Self;
181: 179:     type Owned = Self;
182: 180: 
183: 181:     const MIN_LENGTH: usize = 0;
184: 182: 
185: 183:     fn html_len(&self) -> usize {
186: 184:         self.html.len()
187: 185:     }
188: 186: 
189: 187:     fn dry_resolve(&mut self) {}
190: 188: 
191: 189:     async fn resolve(self) -> Self {
192: 190:         self
193: 191:     }
194: 192: 
195: 193:     fn to_html_with_buf(
196: 194:         self,
197: 195:         buf: &mut String,
198: 196:         position: &mut Position,
199: 197:         _escape: bool,
200: 198:         _mark_branches: bool,
201: 199:         _extra_attrs: Vec<AnyAttribute>,
202: 200:     ) {
203: 201:         buf.push_str(&self.html);
204: 202:         *position = Position::NextChild;
205: 203:     }
206: 204: 
207: 205:     fn hydrate<const FROM_SERVER: bool>(
208: 206:         self,
209: 207:         cursor: &Cursor,
210: 208:         position: &PositionState,
211: 209:     ) -> Self::State {
212: 210:         let curr_position = position.get();
213: 211:         if curr_position == Position::FirstChild {
214: 212:             cursor.child();
215: 213:         } else if curr_position != Position::Current {
216: 214:             cursor.sibling();
217: 215:         }
218: 216:         let el = crate::renderer::types::Element::cast_from(cursor.current())
219: 217:             .unwrap();
220: 218:         position.set(Position::NextChild);
221: 219:         InertElementState(self.html, el)
222: 220:     }
223: 221: 
224: 222:     fn into_owned(self) -> Self::Owned {
225: 223:         self
226: 224:     }
227: 225: }
228: 226: ```
229: 227: ```
230: 228: ```
231: 229: ```
232: 230: ```
233: 231: ```
234: 232: ```
235: 233: ```
236: ```
```
