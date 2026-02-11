### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_leptos\src\arrow.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\arrow.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_dom::{
44: 42:     ARROW_NAME, Arrow as CoreArrow, ArrowOptions as CoreArrowOptions, Middleware, MiddlewareReturn,
45: 43:     MiddlewareState, Padding,
46: 44: };
47: 45: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
48: 46: use lyx-core-lyx_core_lyx-core-lyx_core_leptos_node_ref::AnyNodeRef;
49: 47: use web_sys::wasm_bindgen::JsCast;
50: 48: 
51: 49: /// Options for [`Arrow`].
52: 50: #[derive(Clone)]
53: 51: pub struct ArrowOptions {
54: 52:     /// The arrow element to be positioned.
55: 53:     pub element: AnyNodeRef,
56: 54: 
57: 55:     /// The padding between the arrow element and the floating element edges.
58: 56:     /// Useful when the floating element has rounded corners.
59: 57:     ///
60: 58:     /// Defaults to `0` on all sides.
61: 59:     pub padding: Option<Padding>,
62: 60: }
63: 61: 
64: 62: impl ArrowOptions {
65: 63:     pub fn new(element: AnyNodeRef) -> Self {
66: 64:         ArrowOptions {
67: 65:             element,
68: 66:             padding: None,
69: 67:         }
70: 68:     }
71: 69: 
72: 70:     /// Set `element` option.
73: 71:     pub fn element(mut self, value: AnyNodeRef) -> Self {
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
85: 83: impl PartialEq for ArrowOptions {
86: 84:     fn eq(&self, other: &Self) -> bool {
87: 85:         self.element.get_untracked() == other.element.get_untracked()
88: 86:             && self.padding == other.padding
89: 87:     }
90: 88: }
91: 89: 
92: 90: /// Arrow middleware.
93: 91: ///
94: 92: /// Provides data to position an inner element of the floating element so that it lyx-platform-lyx_platform_lyx-platform-lyx_platform_appears centered to the reference element.
95: 93: ///
96: 94: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/arrow.html) for more documentation.
97: 95: #[derive(Clone, PartialEq)]
98: 96: pub struct Arrow {
99: 97:     options: ArrowOptions,
100: 98: }
101: 99: 
102: 100: impl Arrow {
103: 101:     pub fn new(options: ArrowOptions) -> Self {
104: 102:         Arrow { options }
105: 103:     }
106: 104: }
107: 105: 
108: 106: impl Middleware<web_sys::Element, web_sys::Window> for Arrow {
109: 107:     fn name(&self) -> &'static str {
110: 108:         ARROW_NAME
111: 109:     }
112: 110: 
113: 111:     fn compute(
114: 112:         &self,
115: 113:         state: MiddlewareState<web_sys::Element, web_sys::Window>,
116: 114:     ) -> MiddlewareReturn {
117: 115:         let element = self
118: 116:             .options
119: 117:             .element
120: 118:             .get_untracked()
121: 119:             .and_then(|element| element.dyn_into::<web_sys::Element>().ok());
122: 120: 
123: 121:         if let Some(element) = element {
124: 122:             CoreArrow::new(CoreArrowOptions {
125: 123:                 element,
126: 124:                 padding: self.options.padding.clone(),
127: 125:             })
128: 126:             .compute(state)
129: 127:         } else {
130: 128:             MiddlewareReturn {
131: 129:                 x: None,
132: 130:                 y: None,
133: 131:                 data: None,
134: 132:                 reset: None,
135: 133:             }
136: 134:         }
137: 135:     }
138: 136: }
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: 143: ```
146: 144: ```
147: 145: ```
148: 146: ```
149: 147: ```
150: 148: ```
151: 149: ```
152: 150: ```
153: 151: ```
154: 152: ```
155: 153: ```
156: 154: ```
157: 155: ```
158: 156: ```
159: ```
```
