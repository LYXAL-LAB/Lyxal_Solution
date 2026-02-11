### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dioxus\src\types.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dioxus\src\types.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\types.rs
42: 40: ```rust
43: 41: use std::{fmt::Display, ops::Deref, rc::Rc};
44: 42: 
45: 43: use dioxus::prelude::*;
46: 44: use lyx_ui_foundations_dom::{ElementOrVirtual, Middleware, MiddlewareData, Placement, Strategy};
47: 45: use web_sys::{Element, Window};
48: 46: 
49: 47: pub type WhileElementsMountedFn =
50: 48:     dyn Fn(ElementOrVirtual, &Element, Rc<dyn Fn()>) -> WhileElementsMountedCleanupFn;
51: 49: 
52: 50: pub type WhileElementsMountedCleanupFn = Box<dyn Fn()>;
53: 51: 
54: 52: /// Options for [`use_floating`][`crate::use_floating::use_floating`].
55: 53: #[derive(Clone, Default)]
56: 54: pub struct UseFloatingOptions {
57: 55:     /// Represents the open/close state of the floating element.
58: 56:     ///
59: 57:     /// Defaults to `true`.
60: 58:     pub open: Option<bool>,
61: 59: 
62: 60:     /// Where to place the floating element relative to the reference element.
63: 61:     ///
64: 62:     /// Defaults to [`Placement::Bottom`].
65: 63:     pub placement: Option<Placement>,
66: 64: 
67: 65:     /// The strategy to use when positioning the floating element.
68: 66:     ///
69: 67:     /// Defaults to [`Strategy::Absolute`].
70: 68:     pub strategy: Option<Strategy>,
71: 69: 
72: 70:     /// Array of middleware objects to modify the positioning or provide data for rendering.
73: 71:     ///
74: 72:     /// Defaults to an empty vector.
75: 73:     pub middleware: Option<Vec<Box<dyn Middleware<Element, Window>>>>,
76: 74: 
77: 75:     ///  Whether to use `transform` for positioning instead of `top` and `left` in the `floatingStyles` object.
78: 76:     ///
79: 77:     /// Defaults to `true`.
80: 78:     pub transform: Option<bool>,
81: 79: 
82: 80:     /// Callback to handle mounting/unmounting of the elements.
83: 81:     ///
84: 82:     /// Defaults to [`Option::None`].
85: 83:     pub while_elements_mounted: Option<Rc<WhileElementsMountedFn>>,
86: 84: }
87: 85: 
88: 86: impl UseFloatingOptions {
89: 87:     /// Set `open` option.
90: 88:     pub fn open(mut self, value: bool) -> Self {
91: 89:         self.open = Some(value);
92: 90:         self
93: 91:     }
94: 92: 
95: 93:     /// Set `placement` option.
96: 94:     pub fn placement(mut self, value: Placement) -> Self {
97: 95:         self.placement = Some(value);
98: 96:         self
99: 97:     }
100: 98: 
101: 99:     /// Set `strategy` option.
102: 100:     pub fn strategy(mut self, value: Strategy) -> Self {
103: 101:         self.strategy = Some(value);
104: 102:         self
105: 103:     }
106: 104: 
107: 105:     /// Set `middleware` option.
108: 106:     pub fn middleware(mut self, value: Vec<Box<dyn Middleware<Element, Window>>>) -> Self {
109: 107:         self.middleware = Some(value);
110: 108:         self
111: 109:     }
112: 110: 
113: 111:     /// Set `transform` option.
114: 112:     pub fn transform(mut self, value: bool) -> Self {
115: 113:         self.transform = Some(value);
116: 114:         self
117: 115:     }
118: 116: 
119: 117:     /// Set `while_elements_mounted` option.
120: 118:     pub fn while_elements_mounted(mut self, value: Rc<WhileElementsMountedFn>) -> Self {
121: 119:         self.while_elements_mounted = Some(value);
122: 120:         self
123: 121:     }
124: 122: }
125: 123: 
126: 124: /// CSS styles to lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply to the floating element to position it.
127: 125: #[derive(Clone, Debug, PartialEq)]
128: 126: pub struct FloatingStyles {
129: 127:     pub position: Strategy,
130: 128:     pub top: String,
131: 129:     pub left: String,
132: 130:     pub transform: Option<String>,
133: 131:     pub will_change: Option<String>,
134: 132: }
135: 133: 
136: 134: impl FloatingStyles {
137: 135:     pub fn style_position(&self) -> String {
138: 136:         match self.position {
139: 137:             Strategy::Absolute => "absolute".to_owned(),
140: 138:             Strategy::Fixed => "fixed".to_owned(),
141: 139:         }
142: 140:     }
143: 141: 
144: 142:     pub fn style_top(&self) -> String {
145: 143:         self.top.clone()
146: 144:     }
147: 145: 
148: 146:     pub fn style_left(&self) -> String {
149: 147:         self.left.clone()
150: 148:     }
151: 149: 
152: 150:     pub fn style_transform(&self) -> Option<String> {
153: 151:         self.transform.clone()
154: 152:     }
155: 153: 
156: 154:     pub fn style_will_change(&self) -> Option<String> {
157: 155:         self.will_change.clone()
158: 156:     }
159: 157: }
160: 158: 
161: 159: impl Display for FloatingStyles {
162: 160:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
163: 161:         write!(
164: 162:             f,
165: 163:             "position: {}; top: {}; left: {};{}{}",
166: 164:             match self.position {
167: 165:                 Strategy::Absolute => "absolute",
168: 166:                 Strategy::Fixed => "fixed",
169: 167:             },
170: 168:             self.top,
171: 169:             self.left,
172: 170:             self.transform
173: 171:                 .as_ref()
174: 172:                 .map_or("".to_owned(), |transform| format!(
175: 173:                     " transform: {transform};"
176: 174:                 ),),
177: 175:             self.will_change
178: 176:                 .as_ref()
179: 177:                 .map_or("".to_owned(), |will_change| format!(
180: 178:                     " will-change: {will_change};"
181: 179:                 ))
182: 180:         )
183: 181:     }
184: 182: }
185: 183: 
186: 184: /// Return of [`use_floating`][crate::use_floating::use_floating].
187: 185: pub struct UseFloatingReturn {
188: 186:     /// The x-coord of the floating element.
189: 187:     pub x: Signal<f64>,
190: 188: 
191: 189:     /// The y-coord of the floating element.
192: 190:     pub y: Signal<f64>,
193: 191: 
194: 192:     /// The stateful placement, which can be different from the initial `placement` passed as options.
195: 193:     pub placement: Signal<Placement>,
196: 194: 
197: 195:     /// The strategy to use when positioning the floating element.
198: 196:     pub strategy: Signal<Strategy>,
199: 197: 
200: 198:     /// Additional data from middleware.
201: 199:     pub middleware_data: Signal<MiddlewareData>,
202: 200: 
203: 201:     /// Indicates if the floating element has been positioned.
204: 202:     pub is_positioned: Signal<bool>,
205: 203: 
206: 204:     /// CSS styles to lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply to the floating element to position it.
207: 205:     pub floating_styles: Memo<FloatingStyles>,
208: 206: 
209: 207:     /// The function to update floating position manually.
210: 208:     pub update: Callback<()>,
211: 209: }
212: 210: 
213: 211: pub struct ShallowRc<T: ?Sized>(Rc<T>);
214: 212: 
215: 213: impl<T: ?Sized> Clone for ShallowRc<T> {
216: 214:     fn clone(&self) -> Self {
217: 215:         Self(self.0.clone())
218: 216:     }
219: 217: }
220: 218: 
221: 219: impl<T: ?Sized> Deref for ShallowRc<T> {
222: 220:     type Target = Rc<T>;
223: 221: 
224: 222:     fn deref(&self) -> &Self::Target {
225: 223:         &self.0
226: 224:     }
227: 225: }
228: 226: 
229: 227: impl<T: ?Sized> From<Rc<T>> for ShallowRc<T> {
230: 228:     fn from(value: Rc<T>) -> Self {
231: 229:         Self(value)
232: 230:     }
233: 231: }
234: 232: 
235: 233: impl<T: ?Sized> PartialEq for ShallowRc<T> {
236: 234:     fn eq(&self, other: &Self) -> bool {
237: 235:         Rc::ptr_eq(&self.0, &other.0)
238: 236:     }
239: 237: }
240: 238: ```
241: 239: ```
242: 240: ```
243: 241: ```
244: 242: ```
245: 243: ```
246: 244: ```
247: 245: ```
248: 246: ```
249: 247: ```
250: 248: ```
251: 249: ```
252: 250: ```
253: 251: ```
254: 252: ```
255: 253: ```
256: 254: ```
257: 255: ```
258: 256: ```
259: 257: ```
260: ```
```
