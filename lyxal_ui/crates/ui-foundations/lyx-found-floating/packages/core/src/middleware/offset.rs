### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\offset.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\offset.rs
2: ```rust
3: 1: use lyx_ui_foundations_utils::{
4: 2:     Alignment, Axis, Coords, Placement, Side, get_alignment, get_side, get_side_axis,
5: 3: };
6: 4: use serde::{Deserialize, Serialize};
7: 5: 
8: 6: use crate::{
9: 7:     middleware::{ARROW_NAME, ArrowData},
10: 8:     types::{
11: 9:         Derivable, DerivableFn, Middleware, MiddlewareReturn, MiddlewareState,
12: 10:         MiddlewareWithOptions,
13: 11:     },
14: 12: };
15: 13: 
16: 14: fn convert_value_to_coords<Element: Clone, Window: Clone>(
17: 15:     state: MiddlewareState<Element, Window>,
18: 16:     options: &OffsetOptions,
19: 17: ) -> Coords {
20: 18:     let MiddlewareState {
21: 19:         placement,
22: 20:         platform,
23: 21:         elements,
24: 22:         ..
25: 23:     } = state;
26: 24: 
27: 25:     let rtl = platform.is_rtl(elements.floating).unwrap_or(false);
28: 26:     let side = get_side(placement);
29: 27:     let alignment = get_alignment(placement);
30: 28:     let is_vertical = get_side_axis(placement) == Axis::Y;
31: 29:     let main_axis_multi = match side {
32: 30:         Side::Left | Side::Top => -1.0,
33: 31:         Side::Right | Side::Bottom => 1.0,
34: 32:     };
35: 33:     let cross_axis_multi = if rtl && is_vertical { -1.0 } else { 1.0 };
36: 34: 
37: 35:     let (main_axis, mut cross_axis, alignment_axis): (f64, f64, Option<f64>) = match options {
38: 36:         OffsetOptions::Value(value) => (*value, 0.0, None),
39: 37:         OffsetOptions::Values(values) => (
40: 38:             values.main_axis.unwrap_or(0.0),
41: 39:             values.cross_axis.unwrap_or(0.0),
42: 40:             values.alignment_axis,
43: 41:         ),
44: 42:     };
45: 43: 
46: 44:     if let Some(alignment) = alignment
47: 45:         && let Some(alignment_axis) = alignment_axis
48: 46:     {
49: 47:         cross_axis = match alignment {
50: 48:             Alignment::Start => alignment_axis,
51: 49:             Alignment::End => -alignment_axis,
52: 50:         };
53: 51:     }
54: 52: 
55: 53:     if is_vertical {
56: 54:         Coords {
57: 55:             x: cross_axis * cross_axis_multi,
58: 56:             y: main_axis * main_axis_multi,
59: 57:         }
60: 58:     } else {
61: 59:         Coords {
62: 60:             x: main_axis * main_axis_multi,
63: 61:             y: cross_axis * cross_axis_multi,
64: 62:         }
65: 63:     }
66: 64: }
67: 65: 
68: 66: /// Name of the [`Offset`] middleware.
69: 67: pub const OFFSET_NAME: &str = "offset";
70: 68: 
71: 69: /// Axes configuration for [`OffsetOptions`].
72: 70: #[derive(Clone, Default, Debug, PartialEq)]
73: 71: pub struct OffsetOptionsValues {
74: 72:     /// The axis that runs along the side of the floating element. Represents the distance (gutter or margin) between the reference and floating element.
75: 73:     ///
76: 74:     /// Defaults to `0`.
77: 75:     pub main_axis: Option<f64>,
78: 76: 
79: 77:     /// The axis that runs along the alignment of the floating element. Represents the skidding between the reference and floating element.
80: 78:     ///
81: 79:     /// Defaults to `0`.
82: 80:     pub cross_axis: Option<f64>,
83: 81: 
84: 82:     /// The same axis as [`cross_axis`][`Self::cross_axis`] but lyx-platform-lyx_platform_lyx-platform-lyx_platform_applies only to aligned placements and inverts the [`End`][`lyx_ui_foundations_utils::Alignment::End`] alignment.
85: 83:     /// When set to a number, it overrides the [`cross_axis`][`Self::cross_axis`] value.
86: 84:     ///
87: 85:     /// A positive number will move the floating element in the direction of the opposite edge to the one that is aligned, while a negative number the reverse.
88: 86:     ///
89: 87:     /// Defaults to [`Option::None`].
90: 88:     pub alignment_axis: Option<f64>,
91: 89: }
92: 90: 
93: 91: impl OffsetOptionsValues {
94: 92:     /// Set `main_axis` option.
95: 93:     pub fn main_axis(mut self, value: f64) -> Self {
96: 94:         self.main_axis = Some(value);
97: 95:         self
98: 96:     }
99: 97: 
100: 98:     /// Set `cross_axis` option.
101: 99:     pub fn cross_axis(mut self, value: f64) -> Self {
102: 100:         self.cross_axis = Some(value);
103: 101:         self
104: 102:     }
105: 103: 
106: 104:     /// Set `alignment_axis` option.
107: 105:     pub fn alignment_axis(mut self, value: f64) -> Self {
108: 106:         self.alignment_axis = Some(value);
109: 107:         self
110: 108:     }
111: 109: }
112: 110: 
113: 111: /// Options for [`Offset`] middleware.
114: 112: ///
115: 113: /// A number (shorthand for [`main_axis`][`OffsetOptionsValues::main_axis`] or distance) or an axes configuration ([`OffsetOptionsValues`]).
116: 114: #[derive(Clone, Debug, PartialEq)]
117: 115: pub enum OffsetOptions {
118: 116:     Value(f64),
119: 117:     Values(OffsetOptionsValues),
120: 118: }
121: 119: 
122: 120: impl Default for OffsetOptions {
123: 121:     fn default() -> Self {
124: 122:         OffsetOptions::Value(0.0)
125: 123:     }
126: 124: }
127: 125: 
128: 126: /// Data stored by [`Offset`] middleware.
129: 127: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
130: 128: pub struct OffsetData {
131: 129:     pub diff_coords: Coords,
132: 130:     pub placement: Placement,
133: 131: }
134: 132: 
135: 133: /// Offset middleware.
136: 134: ///
137: 135: /// Modifies the placement by translating the floating element along the specified axes.
138: 136: ///
139: 137: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/offset.html) for more documentation.
140: 138: #[derive(PartialEq)]
141: 139: pub struct Offset<'a, Element: Clone + 'static, Window: Clone> {
142: 140:     options: Derivable<'a, Element, Window, OffsetOptions>,
143: 141: }
144: 142: 
145: 143: impl<'a, Element: Clone, Window: Clone> Offset<'a, Element, Window> {
146: 144:     /// Constructs a new instance of this middleware.
147: 145:     pub fn new(options: OffsetOptions) -> Self {
148: 146:         Offset {
149: 147:             options: options.into(),
150: 148:         }
151: 149:     }
152: 150: 
153: 151:     /// Constructs a new instance of this middleware with derivable options.
154: 152:     pub fn new_derivable(options: Derivable<'a, Element, Window, OffsetOptions>) -> Self {
155: 153:         Offset { options }
156: 154:     }
157: 155: 
158: 156:     /// Constructs a new instance of this middleware with derivable options function.
159: 157:     pub fn new_derivable_fn(options: DerivableFn<'a, Element, Window, OffsetOptions>) -> Self {
160: 158:         Offset {
161: 159:             options: options.into(),
162: 160:         }
163: 161:     }
164: 162: }
165: 163: 
166: 164: impl<Element: Clone + 'static, Window: Clone> Clone for Offset<'_, Element, Window> {
167: 165:     fn clone(&self) -> Self {
168: 166:         Self {
169: 167:             options: self.options.clone(),
170: 168:         }
171: 169:     }
172: 170: }
173: 171: 
174: 172: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> Middleware<Element, Window>
175: 173:     for Offset<'static, Element, Window>
176: 174: {
177: 175:     fn name(&self) -> &'static str {
178: 176:         OFFSET_NAME
179: 177:     }
180: 178: 
181: 179:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
182: 180:         let options = self.options.evaluate(state.clone());
183: 181: 
184: 182:         let MiddlewareState {
185: 183:             x,
186: 184:             y,
187: 185:             placement,
188: 186:             middleware_data,
189: 187:             ..
190: 188:         } = state;
191: 189: 
192: 190:         let data: Option<OffsetData> = middleware_data.get_as(self.name());
193: 191: 
194: 192:         let diff_coords = convert_value_to_coords(state, &options);
195: 193: 
196: 194:         // If the placement is the same and the arrow caused an alignment offset then we don't need to change the positioning coordinates.
197: 195:         if let Some(data_placement) = data.map(|data| data.placement)
198: 196:             && placement == data_placement
199: 197:         {
200: 198:             let arrow_data: Option<ArrowData> = middleware_data.get_as(ARROW_NAME);
201: 199:             if arrow_data
202: 200:                 .and_then(|arrow_data| arrow_data.alignment_offset)
203: 201:                 .is_some()
204: 202:             {
205: 203:                 return MiddlewareReturn {
206: 204:                     x: None,
207: 205:                     y: None,
208: 206:                     data: None,
209: 207:                     reset: None,
210: 208:                 };
211: 209:             }
212: 210:         }
213: 211: 
214: 212:         MiddlewareReturn {
215: 213:             x: Some(x + diff_coords.x),
216: 214:             y: Some(y + diff_coords.y),
217: 215:             data: Some(
218: 216:                 serde_json::to_value(OffsetData {
219: 217:                     diff_coords,
220: 218:                     placement,
221: 219:                 })
222: 220:                 .expect("Data should be valid JSON."),
223: 221:             ),
224: 222:             reset: None,
225: 223:         }
226: 224:     }
227: 225: }
228: 226: 
229: 227: impl<Element: Clone, Window: Clone> MiddlewareWithOptions<Element, Window, OffsetOptions>
230: 228:     for Offset<'_, Element, Window>
231: 229: {
232: 230:     fn options(&self) -> &Derivable<'_, Element, Window, OffsetOptions> {
233: 231:         &self.options
234: 232:     }
235: 233: }
236: ```
```
