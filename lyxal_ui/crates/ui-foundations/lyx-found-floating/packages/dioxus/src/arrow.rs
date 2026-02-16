1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dioxus\src\arrow.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\arrow.rs
42: 40: ```rust
43: 41: use std::rc::Rc;
44: 42: 
45: 43: use dioxus::{html::MountedData, signals::Signal, web::WebEventExt};
46: 44: use lyx_ui_foundations_dom::{
47: 45:     ARROW_NAME, Arrow as CoreArrow, ArrowOptions as CoreArrowOptions, Middleware, MiddlewareReturn,
48: 46:     MiddlewareState, Padding,
49: 47: };
50: 48: 
51: 49: /// Options for [`Arrow`].
52: 50: #[derive(Clone, PartialEq)]
53: 51: pub struct ArrowOptions {
54: 52:     /// The arrow element to be positioned.
55: 53:     pub element: Signal<Option<Rc<MountedData>>>,
56: 54: 
57: 55:     /// The padding between the arrow element and the floating element edges.
58: 56:     /// Useful when the floating element has rounded corners.
59: 57:     ///
60: 58:     /// Defaults to `0` on all sides.
61: 59:     pub padding: Option<Padding>,
62: 60: }
63: 61: 
64: 62: impl ArrowOptions {
65: 63:     pub fn new(element: Signal<Option<Rc<MountedData>>>) -> Self {
66: 64:         ArrowOptions {
67: 65:             element,
68: 66:             padding: None,
69: 67:         }
70: 68:     }
71: 69: 
72: 70:     /// Set `element` option.
73: 71:     pub fn element(mut self, value: Signal<Option<Rc<MountedData>>>) -> Self {
74: 72:         self.element = value;
75: 73:         self
76: 74:     }
77: 75: 
78: 76:     /// Set `padding` option.
79: 77:     pub fn padding(mut self, value: Padding) -> Self {
80: 78:         self.padding = Some(value);
81: 79:         self
82: 80:     }
83: 81: }
84: 82: 
85: 83: /// Arrow middleware.
86: 84: ///
87: 85: /// Provides data to position an inner element of the floating element so that it lyx-platform-lyx_platform_lyx-platform-lyx_platform_appears centered to the reference element.
88: 86: ///
89: 87: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/arrow.html) for more documentation.
90: 88: #[derive(Clone, PartialEq)]
91: 89: pub struct Arrow {
92: 90:     options: ArrowOptions,
93: 91: }
94: 92: 
95: 93: impl Arrow {
96: 94:     pub fn new(options: ArrowOptions) -> Self {
97: 95:         Arrow { options }
98: 96:     }
99: 97: }
100: 98: 
101: 99: impl Middleware<web_sys::Element, web_sys::Window> for Arrow {
102: 100:     fn name(&self) -> &'static str {
103: 101:         ARROW_NAME
104: 102:     }
105: 103: 
106: 104:     fn compute(
107: 105:         &self,
108: 106:         state: MiddlewareState<web_sys::Element, web_sys::Window>,
109: 107:     ) -> MiddlewareReturn {
110: 108:         match (self.options.element)().map(|element| element.as_web_event()) {
111: 109:             Some(element) => CoreArrow::new(CoreArrowOptions {
112: 110:                 element,
113: 111:                 padding: self.options.padding.clone(),
114: 112:             })
115: 113:             .compute(state),
116: 114:             _ => MiddlewareReturn {
117: 115:                 x: None,
118: 116:                 y: None,
119: 117:                 data: None,
120: 118:                 reset: None,
121: 119:             },
122: 120:         }
123: 121:     }
124: 122: }
125: 123: ```
126: 124: ```
127: 125: ```
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: 130: ```
133: 131: ```
134: 132: ```
135: 133: ```
136: 134: ```
137: 135: ```
138: 136: ```
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: ```
```

