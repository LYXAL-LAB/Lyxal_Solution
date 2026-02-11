### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\view\primitives.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\view\primitives.rs
18: 16: ```rust
19: 17: use super::{Mountable, Position, PositionState, Render, RenderHtml};
20: 18: use crate::{
21: 19:     html::attribute::any_attribute::AnyAttribute,
22: 20:     hydration::Cursor,
23: 21:     no_attrs,
24: 22:     renderer::{CastFrom, Rndr},
25: 23:     view::ToTemplate,
26: 24: };
27: 25: use std::{
28: 26:     fmt::Write,
29: 27:     net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr, SocketAddrV4, SocketAddrV6},
30: 28:     num::{
31: 29:         NonZeroI128, NonZeroI16, NonZeroI32, NonZeroI64, NonZeroI8,
32: 30:         NonZeroIsize, NonZeroU128, NonZeroU16, NonZeroU32, NonZeroU64,
33: 31:         NonZeroU8, NonZeroUsize,
34: 32:     },
35: 33: };
36: 34: 
37: 35: // any changes here should also be made in src/lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph/guards.rs
38: 36: macro_rules! render_primitive {
39: 37:   ($($child_type:ty),* $(,)?) => {
40: 38:     $(
41: 39: 		paste::paste! {
42: 40: 			pub struct [<$child_type:camel State>](crate::renderer::types::Text, $child_type);
43: 41: 
44: 42: 			impl Mountable for [<$child_type:camel State>] {
45: 43: 					fn unmount(&mut self) {
46: 44: 						self.0.unmount()
47: 45: 					}
48: 46: 
49: 47: 					fn mount(
50: 48: 						&mut self,
51: 49: 						parent: &crate::renderer::types::Element,
52: 50: 						marker: Option<&crate::renderer::types::Node>,
53: 51: 					) {
54: 52: 						Rndr::insert_node(parent, self.0.as_ref(), marker);
55: 53: 					}
56: 54: 
57: 55: 					fn insert_before_this(&self,
58: 56: 						child: &mut dyn Mountable,
59: 57: 					) -> bool {
60: 58:                         self.0.insert_before_this(child)
61: 59: 					}
62: 60: 
63: 61: 					fn elements(&self) -> Vec<crate::renderer::types::Element> {
64: 62: 						vec![]
65: 63: 					}
66: 64: 			}
67: 65: 
68: 66: 			impl Render for $child_type {
69: 67: 				type State = [<$child_type:camel State>];
70: 68: 
71: 69: 
72: 70: 				fn build(self) -> Self::State {
73: 71: 					let node = Rndr::create_text_node(&self.to_string());
74: 72: 					[<$child_type:camel State>](node, self)
75: 73: 				}
76: 74: 
77: 75: 				fn rebuild(self, state: &mut Self::State) {
78: 76: 					let [<$child_type:camel State>](node, this) = state;
79: 77: 					if &self != this {
80: 78: 						Rndr::set_text(node, &self.to_string());
81: 79: 						*this = self;
82: 80: 					}
83: 81: 				}
84: 82: 			}
85: 83: 
86: 84:             no_attrs!($child_type);
87: 85: 
88: 86: 			impl RenderHtml for $child_type
89: 87: 			{
90: 88: 				type AsyncOutput = Self;
91: 89: 				type Owned = Self;
92: 90: 
93: 91: 				const MIN_LENGTH: usize = 0;
94: 92: 
95: 93:                 fn dry_resolve(&mut self) {}
96: 94: 
97: 95:                 async fn resolve(self) -> Self::AsyncOutput {
98: 96:                     self
99: 97:                 }
100: 98: 
101: 99: 				fn to_html_with_buf(self, buf: &mut String, position: &mut Position, _escape: bool, _mark_branches: bool, _extra_attrs: Vec<AnyAttribute>) {
102: 100: 					// add a comment node to separate from previous sibling, if any
103: 101: 					if matches!(position, Position::NextChildAfterText) {
104: 102: 						buf.push_str("<!>")
105: 103: 					}
106: 104: 					_ = write!(buf, "{}", self);
107: 105: 					*position = Position::NextChildAfterText;
108: 106: 				}
109: 107: 
110: 108: 				fn hydrate<const FROM_SERVER: bool>(
111: 109: 					self,
112: 110: 					cursor: &Cursor,
113: 111: 					position: &PositionState,
114: 112: 				) -> Self::State {
115: 113: 					if position.get() == Position::FirstChild {
116: 114: 						cursor.child();
117: 115: 					} else {
118: 116: 						cursor.sibling();
119: 117: 					}
120: 118: 
121: 119: 					// separating placeholder marker comes before text node
122: 120: 					if matches!(position.get(), Position::NextChildAfterText) {
123: 121: 						cursor.sibling();
124: 122: 					}
125: 123: 
126: 124: 					let node = cursor.current();
127: 125: 					let node = crate::renderer::types::Text::cast_from(node.clone())
128: 126: 						.unwrap_or_else(|| crate::hydration::failed_to_cast_text_node(node));
129: 127: 
130: 128: 					if !FROM_SERVER {
131: 129: 						Rndr::set_text(&node, &self.to_string());
132: 130: 					}
133: 131: 					position.set(Position::NextChildAfterText);
134: 132: 
135: 133: 					[<$child_type:camel State>](node, self)
136: 134: 				}
137: 135: 
138: 136: 				fn into_owned(self) -> Self::Owned {
139: 137: 					self
140: 138: 				}
141: 139: 			}
142: 140: 
143: 141: 			impl<'a> ToTemplate for $child_type {
144: 142: 				const TEMPLATE: &'static str = " <!>";
145: 143: 
146: 144: 				fn to_template(
147: 145: 					buf: &mut String,
148: 146: 					_class: &mut String,
149: 147: 					_style: &mut String,
150: 148: 					_inner_html: &mut String,
151: 149: 					position: &mut Position,
152: 150: 				) {
153: 151: 					if matches!(*position, Position::NextChildAfterText) {
154: 152: 						buf.push_str("<!>")
155: 153: 					}
156: 154: 					buf.push(' ');
157: 155: 					*position = Position::NextChildAfterText;
158: 156: 				}
159: 157: 			}
160: 158: 		}
161: 159:     )*
162: 160:   };
163: 161: }
164: 162: 
165: 163: render_primitive![
166: 164:     usize,
167: 165:     u8,
168: 166:     u16,
169: 167:     u32,
170: 168:     u64,
171: 169:     u128,
172: 170:     isize,
173: 171:     i8,
174: 172:     i16,
175: 173:     i32,
176: 174:     i64,
177: 175:     i128,
178: 176:     f32,
179: 177:     f64,
180: 178:     char,
181: 179:     bool,
182: 180:     IpAddr,
183: 181:     SocketAddr,
184: 182:     SocketAddrV4,
185: 183:     SocketAddrV6,
186: 184:     Ipv4Addr,
187: 185:     Ipv6Addr,
188: 186:     NonZeroI8,
189: 187:     NonZeroU8,
190: 188:     NonZeroI16,
191: 189:     NonZeroU16,
192: 190:     NonZeroI32,
193: 191:     NonZeroU32,
194: 192:     NonZeroI64,
195: 193:     NonZeroU64,
196: 194:     NonZeroI128,
197: 195:     NonZeroU128,
198: 196:     NonZeroIsize,
199: 197:     NonZeroUsize,
200: 198: ];
201: 199: ```
202: 200: ```
203: 201: ```
204: 202: ```
205: 203: ```
206: 204: ```
207: 205: ```
208: 206: ```
209: ```
```
