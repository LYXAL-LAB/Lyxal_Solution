### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\arrow.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\arrow.rs
2: ```rust
3: 1: use lyx_ui_foundations_utils::{
4: 2:     Axis, Coords, OwnedElementOrWindow, Padding, Side, clamp, get_alignment, get_alignment_axis,
5: 3:     get_axis_length, get_padding_object,
6: 4: };
7: 5: use serde::{Deserialize, Serialize};
8: 6: 
9: 7: use crate::types::{
10: 8:     Derivable, DerivableFn, Middleware, MiddlewareReturn, MiddlewareState, MiddlewareWithOptions,
11: 9: };
12: 10: 
13: 11: /// Name of the [`Arrow`] middleware.
14: 12: pub const ARROW_NAME: &str = "arrow";
15: 13: 
16: 14: /// Options for [`Arrow`].
17: 15: #[derive(Clone, Debug, PartialEq)]
18: 16: pub struct ArrowOptions<Element: Clone> {
19: 17:     /// The arrow element to be positioned.
20: 18:     pub element: Element,
21: 19: 
22: 20:     /// The padding between the arrow element and the floating element edges.
23: 21:     /// Useful when the floating element has rounded corners.
24: 22:     ///
25: 23:     /// Defaults to `0` on all sides.
26: 24:     pub padding: Option<Padding>,
27: 25: }
28: 26: 
29: 27: impl<Element: Clone> ArrowOptions<Element> {
30: 28:     pub fn new(element: Element) -> Self {
31: 29:         ArrowOptions {
32: 30:             element,
33: 31:             padding: None,
34: 32:         }
35: 33:     }
36: 34: 
37: 35:     /// Set `element` option.
38: 36:     pub fn element(mut self, value: Element) -> Self {
39: 37:         self.element = value;
40: 38:         self
41: 39:     }
42: 40: 
43: 41:     /// Set `padding` option.
44: 42:     pub fn padding(mut self, value: Padding) -> Self {
45: 43:         self.padding = Some(value);
46: 44:         self
47: 45:     }
48: 46: }
49: 47: 
50: 48: /// Data stored by [`Arrow`] middleware.
51: 49: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
52: 50: pub struct ArrowData {
53: 51:     pub x: Option<f64>,
54: 52:     pub y: Option<f64>,
55: 53:     pub center_offset: f64,
56: 54:     pub alignment_offset: Option<f64>,
57: 55: }
58: 56: 
59: 57: /// Arrow middleware.
60: 58: ///
61: 59: /// Provides data to position an inner element of the floating element so that it lyx-platform-lyx_platform_lyx-platform-lyx_platform_appears centered to the reference element.
62: 60: ///
63: 61: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/arrow.html) for more documentation.
64: 62: #[derive(PartialEq)]
65: 63: pub struct Arrow<'a, Element: Clone + 'static, Window: Clone> {
66: 64:     options: Derivable<'a, Element, Window, ArrowOptions<Element>>,
67: 65: }
68: 66: 
69: 67: impl<'a, Element: Clone + 'static, Window: Clone> Arrow<'a, Element, Window> {
70: 68:     /// Constructs a new instance of this middleware.
71: 69:     pub fn new(options: ArrowOptions<Element>) -> Self {
72: 70:         Arrow {
73: 71:             options: options.into(),
74: 72:         }
75: 73:     }
76: 74: 
77: 75:     /// Constructs a new instance of this middleware with derivable options.
78: 76:     pub fn new_derivable(options: Derivable<'a, Element, Window, ArrowOptions<Element>>) -> Self {
79: 77:         Arrow { options }
80: 78:     }
81: 79: 
82: 80:     /// Constructs a new instance of this middleware with derivable options function.
83: 81:     pub fn new_derivable_fn(
84: 82:         options: DerivableFn<'a, Element, Window, ArrowOptions<Element>>,
85: 83:     ) -> Self {
86: 84:         Arrow {
87: 85:             options: options.into(),
88: 86:         }
89: 87:     }
90: 88: }
91: 89: 
92: 90: impl<Element: Clone + 'static, Window: Clone> Clone for Arrow<'_, Element, Window> {
93: 91:     fn clone(&self) -> Self {
94: 92:         Self {
95: 93:             options: self.options.clone(),
96: 94:         }
97: 95:     }
98: 96: }
99: 97: 
100: 98: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> Middleware<Element, Window>
101: 99:     for Arrow<'static, Element, Window>
102: 100: {
103: 101:     fn name(&self) -> &'static str {
104: 102:         ARROW_NAME
105: 103:     }
106: 104: 
107: 105:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
108: 106:         let options = self.options.evaluate(state.clone());
109: 107: 
110: 108:         let MiddlewareState {
111: 109:             x,
112: 110:             y,
113: 111:             placement,
114: 112:             middleware_data,
115: 113:             elements,
116: 114:             rects,
117: 115:             platform,
118: 116:             ..
119: 117:         } = state;
120: 118: 
121: 119:         let data: Option<ArrowData> = middleware_data.get_as(self.name());
122: 120: 
123: 121:         let padding_object = get_padding_object(options.padding.unwrap_or(Padding::All(0.0)));
124: 122:         let coords = Coords { x, y };
125: 123:         let axis = get_alignment_axis(placement);
126: 124:         let length = get_axis_length(axis);
127: 125:         let arrow_dimensions = platform.get_dimensions(&options.element);
128: 126:         let min_prop = match axis {
129: 127:             Axis::X => Side::Left,
130: 128:             Axis::Y => Side::Top,
131: 129:         };
132: 130:         let max_prop = match axis {
133: 131:             Axis::X => Side::Right,
134: 132:             Axis::Y => Side::Bottom,
135: 133:         };
136: 134: 
137: 135:         let start_diff = coords.axis(axis) - rects.reference.axis(axis);
138: 136:         let end_diff = rects.reference.length(length) + rects.reference.axis(axis)
139: 137:             - coords.axis(axis)
140: 138:             - rects.floating.length(length);
141: 139: 
142: 140:         let arrow_offset_parent = platform.get_offset_parent(&options.element);
143: 141:         let lyx-core-lyx_core_lyx-core-lyx_core_client_size = arrow_offset_parent
144: 142:             .and_then(|arrow_offset_parent| match arrow_offset_parent {
145: 143:                 OwnedElementOrWindow::Element(element) => {
146: 144:                     platform.get_lyx-core-lyx_core_lyx-core-lyx_core_client_length(&element, length)
147: 145:                 }
148: 146:                 OwnedElementOrWindow::Window(_) => {
149: 147:                     platform.get_lyx-core-lyx_core_lyx-core-lyx_core_client_length(elements.floating, length)
150: 148:                 }
151: 149:             })
152: 150:             .unwrap_or(rects.floating.length(length));
153: 151: 
154: 152:         let center_to_reference = end_diff / 2.0 - start_diff / 2.0;
155: 153: 
156: 154:         // If the padding is large enough that it causes the arrow to no longer be centered, modify the padding so that it is centered.
157: 155:         let largest_possible_padding =
158: 156:             lyx-core-lyx_core_lyx-core-lyx_core_client_size / 2.0 - arrow_dimensions.length(length) / 2.0 - 1.0;
159: 157:         let min_padding = padding_object.side(min_prop).min(largest_possible_padding);
160: 158:         let max_padding = padding_object.side(max_prop).min(largest_possible_padding);
161: 159: 
162: 160:         // Make sure the arrow doesn't overflow the floating element if the center point is outside the floating element's bounds.
163: 161:         let min = min_padding;
164: 162:         let max = lyx-core-lyx_core_lyx-core-lyx_core_client_size - arrow_dimensions.length(length) - max_padding;
165: 163:         let center =
166: 164:             lyx-core-lyx_core_lyx-core-lyx_core_client_size / 2.0 - arrow_dimensions.length(length) / 2.0 + center_to_reference;
167: 165:         let offset = clamp(min, center, max);
168: 166: 
169: 167:         // If the reference is small enough that the arrow's padding causes it to to point to nothing for an aligned placement, adjust the offset of the floating element itself.
170: 168:         // To ensure `shift()` continues to take action, a single reset is performed when this is true.
171: 169:         let should_add_offset = data.is_none()
172: 170:             && get_alignment(placement).is_some()
173: 171:             && center != offset
174: 172:             && rects.reference.length(length) / 2.0
175: 173:                 - (if center < min {
176: 174:                     min_padding
177: 175:                 } else {
178: 176:                     max_padding
179: 177:                 })
180: 178:                 - arrow_dimensions.length(length) / 2.0
181: 179:                 < 0.0;
182: 180:         let alignment_offset = if should_add_offset {
183: 181:             if center < min {
184: 182:                 center - min
185: 183:             } else {
186: 184:                 center - max
187: 185:             }
188: 186:         } else {
189: 187:             0.0
190: 188:         };
191: 189: 
192: 190:         MiddlewareReturn {
193: 191:             x: match axis {
194: 192:                 Axis::X => Some(coords.axis(axis) + alignment_offset),
195: 193:                 Axis::Y => None,
196: 194:             },
197: 195:             y: match axis {
198: 196:                 Axis::X => None,
199: 197:                 Axis::Y => Some(coords.axis(axis) + alignment_offset),
200: 198:             },
201: 199:             data: Some(
202: 200:                 serde_json::to_value(ArrowData {
203: 201:                     x: match axis {
204: 202:                         Axis::X => Some(offset),
205: 203:                         Axis::Y => None,
206: 204:                     },
207: 205:                     y: match axis {
208: 206:                         Axis::X => None,
209: 207:                         Axis::Y => Some(offset),
210: 208:                     },
211: 209:                     center_offset: center - offset - alignment_offset,
212: 210:                     alignment_offset: should_add_offset.then_some(alignment_offset),
213: 211:                 })
214: 212:                 .expect("Data should be valid JSON."),
215: 213:             ),
216: 214:             reset: None,
217: 215:         }
218: 216:     }
219: 217: }
220: 218: 
221: 219: impl<Element: Clone, Window: Clone> MiddlewareWithOptions<Element, Window, ArrowOptions<Element>>
222: 220:     for Arrow<'_, Element, Window>
223: 221: {
224: 222:     fn options(&self) -> &Derivable<'_, Element, Window, ArrowOptions<Element>> {
225: 223:         &self.options
226: 224:     }
227: 225: }
228: ```
```
