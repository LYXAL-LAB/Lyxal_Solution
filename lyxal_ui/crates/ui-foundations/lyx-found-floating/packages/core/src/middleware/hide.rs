### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\hide.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\core\src\middleware\hide.rs
2: ```rust
3: 1: use lyx_ui_foundations_utils::{ALL_SIDES, Rect, SideObject};
4: 2: use serde::{Deserialize, Serialize};
5: 3: 
6: 4: use crate::{
7: 5:     detect_overflow::{DetectOverflowOptions, detect_overflow},
8: 6:     types::{
9: 7:         Derivable, DerivableFn, ElementContext, Middleware, MiddlewareReturn, MiddlewareState,
10: 8:         MiddlewareWithOptions,
11: 9:     },
12: 10: };
13: 11: 
14: 12: fn get_side_offsets(overflow: SideObject, rect: &Rect) -> SideObject {
15: 13:     SideObject {
16: 14:         top: overflow.top - rect.height,
17: 15:         right: overflow.right - rect.width,
18: 16:         bottom: overflow.bottom - rect.height,
19: 17:         left: overflow.left - rect.width,
20: 18:     }
21: 19: }
22: 20: 
23: 21: fn is_any_side_fully_clipped(overflow: &SideObject) -> bool {
24: 22:     ALL_SIDES.into_iter().any(|side| overflow.side(side) >= 0.0)
25: 23: }
26: 24: 
27: 25: /// Name of the [`Hide`] middleware.
28: 26: pub const HIDE_NAME: &str = "hide";
29: 27: 
30: 28: /// Fallback strategy used by [`Hide`] middleware.
31: 29: #[derive(Copy, Clone, Debug, Default, Eq, PartialEq)]
32: 30: pub enum HideStrategy {
33: 31:     #[default]
34: 32:     ReferenceHidden,
35: 33:     Escaped,
36: 34: }
37: 35: 
38: 36: /// Options for [`Hide`] middleware.
39: 37: #[derive(Clone, Debug, PartialEq)]
40: 38: pub struct HideOptions<Element: Clone> {
41: 39:     /// Options for [`detect_overflow`].
42: 40:     ///
43: 41:     /// Defaults to [`DetectOverflowOptions::default`].
44: 42:     pub detect_overflow: Option<DetectOverflowOptions<Element>>,
45: 43: 
46: 44:     /// The strategy used to determine when to hide the floating element.
47: 45:     ///
48: 46:     /// Defaults to [`HideStrategy::ReferenceHidden`].
49: 47:     pub strategy: Option<HideStrategy>,
50: 48: }
51: 49: 
52: 50: impl<Element: Clone> HideOptions<Element> {
53: 51:     /// Set `detect_overflow` option.
54: 52:     pub fn detect_overflow(mut self, value: DetectOverflowOptions<Element>) -> Self {
55: 53:         self.detect_overflow = Some(value);
56: 54:         self
57: 55:     }
58: 56: 
59: 57:     /// Set `strategy` option.
60: 58:     pub fn strategy(mut self, value: HideStrategy) -> Self {
61: 59:         self.strategy = Some(value);
62: 60:         self
63: 61:     }
64: 62: }
65: 63: 
66: 64: impl<Element: Clone> Default for HideOptions<Element> {
67: 65:     fn default() -> Self {
68: 66:         Self {
69: 67:             detect_overflow: Default::default(),
70: 68:             strategy: Default::default(),
71: 69:         }
72: 70:     }
73: 71: }
74: 72: 
75: 73: /// Data stored by [`Hide`] middleware.
76: 74: #[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
77: 75: pub struct HideData {
78: 76:     pub reference_hidden: Option<bool>,
79: 77:     pub reference_hidden_offsets: Option<SideObject>,
80: 78:     pub escaped: Option<bool>,
81: 79:     pub escaped_offsets: Option<SideObject>,
82: 80: }
83: 81: 
84: 82: /// Hide middleware.
85: 83: ///
86: 84: /// Provides data to hide the floating element in lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable situations,
87: 85: /// such as when it is not in the same clipping context as the reference element.
88: 86: ///
89: 87: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/hide.html) for more documentation.
90: 88: #[derive(PartialEq)]
91: 89: pub struct Hide<'a, Element: Clone + 'static, Window: Clone> {
92: 90:     options: Derivable<'a, Element, Window, HideOptions<Element>>,
93: 91: }
94: 92: 
95: 93: impl<'a, Element: Clone, Window: Clone> Hide<'a, Element, Window> {
96: 94:     /// Constructs a new instance of this middleware.
97: 95:     pub fn new(options: HideOptions<Element>) -> Self {
98: 96:         Hide {
99: 97:             options: options.into(),
100: 98:         }
101: 99:     }
102: 100: 
103: 101:     /// Constructs a new instance of this middleware with derivable options.
104: 102:     pub fn new_derivable(options: Derivable<'a, Element, Window, HideOptions<Element>>) -> Self {
105: 103:         Hide { options }
106: 104:     }
107: 105: 
108: 106:     /// Constructs a new instance of this middleware with derivable options function.
109: 107:     pub fn new_derivable_fn(
110: 108:         options: DerivableFn<'a, Element, Window, HideOptions<Element>>,
111: 109:     ) -> Self {
112: 110:         Hide {
113: 111:             options: options.into(),
114: 112:         }
115: 113:     }
116: 114: }
117: 115: 
118: 116: impl<Element: Clone + 'static, Window: Clone> Clone for Hide<'_, Element, Window> {
119: 117:     fn clone(&self) -> Self {
120: 118:         Self {
121: 119:             options: self.options.clone(),
122: 120:         }
123: 121:     }
124: 122: }
125: 123: 
126: 124: impl<Element: Clone + PartialEq, Window: Clone + PartialEq> Middleware<Element, Window>
127: 125:     for Hide<'static, Element, Window>
128: 126: {
129: 127:     fn name(&self) -> &'static str {
130: 128:         HIDE_NAME
131: 129:     }
132: 130: 
133: 131:     fn compute(&self, state: MiddlewareState<Element, Window>) -> MiddlewareReturn {
134: 132:         let options = self.options.evaluate(state.clone());
135: 133: 
136: 134:         let MiddlewareState {
137: 135:             elements, rects, ..
138: 136:         } = state;
139: 137: 
140: 138:         let strategy = options.strategy.unwrap_or_default();
141: 139: 
142: 140:         match strategy {
143: 141:             HideStrategy::ReferenceHidden => {
144: 142:                 let overflow = detect_overflow(
145: 143:                     MiddlewareState {
146: 144:                         elements: elements.clone(),
147: 145:                         ..state
148: 146:                     },
149: 147:                     options
150: 148:                         .detect_overflow
151: 149:                         .unwrap_or_default()
152: 150:                         .element_context(ElementContext::Reference),
153: 151:                 );
154: 152: 
155: 153:                 let offsets = get_side_offsets(overflow, &rects.reference);
156: 154: 
157: 155:                 MiddlewareReturn {
158: 156:                     x: None,
159: 157:                     y: None,
160: 158:                     data: Some(
161: 159:                         serde_json::to_value(HideData {
162: 160:                             reference_hidden: Some(is_any_side_fully_clipped(&offsets)),
163: 161:                             reference_hidden_offsets: Some(offsets),
164: 162:                             escaped: None,
165: 163:                             escaped_offsets: None,
166: 164:                         })
167: 165:                         .expect("Data should be valid JSON."),
168: 166:                     ),
169: 167:                     reset: None,
170: 168:                 }
171: 169:             }
172: 170:             HideStrategy::Escaped => {
173: 171:                 let overflow = detect_overflow(
174: 172:                     MiddlewareState {
175: 173:                         elements: elements.clone(),
176: 174:                         ..state
177: 175:                     },
178: 176:                     options
179: 177:                         .detect_overflow
180: 178:                         .unwrap_or_default()
181: 179:                         .alt_boundary(true),
182: 180:                 );
183: 181: 
184: 182:                 let offsets = get_side_offsets(overflow, &rects.floating);
185: 183: 
186: 184:                 MiddlewareReturn {
187: 185:                     x: None,
188: 186:                     y: None,
189: 187:                     data: Some(
190: 188:                         serde_json::to_value(HideData {
191: 189:                             reference_hidden: None,
192: 190:                             reference_hidden_offsets: None,
193: 191:                             escaped: Some(is_any_side_fully_clipped(&offsets)),
194: 192:                             escaped_offsets: Some(offsets),
195: 193:                         })
196: 194:                         .expect("Data should be valid JSON."),
197: 195:                     ),
198: 196:                     reset: None,
199: 197:                 }
200: 198:             }
201: 199:         }
202: 200:     }
203: 201: }
204: 202: 
205: 203: impl<Element: Clone, Window: Clone> MiddlewareWithOptions<Element, Window, HideOptions<Element>>
206: 204:     for Hide<'_, Element, Window>
207: 205: {
208: 206:     fn options(&self) -> &Derivable<'_, Element, Window, HideOptions<Element>> {
209: 207:         &self.options
210: 208:     }
211: 209: }
212: ```
```
