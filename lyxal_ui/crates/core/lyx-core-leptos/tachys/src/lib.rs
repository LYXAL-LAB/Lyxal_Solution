### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\lib.rs
22: 20: ```rust
23: 21: //! Allows rendering user interfaces based on a statically-typed view tree.
24: 22: //!
25: 23: //! This view tree is generic over rendering lyx-platform-lyx_platform_lyx-platform-lyx_platform_backends, and agnostic about reactivity/change
26: 24: //! detection.
27: 25: 
28: 26: // this is specifically used for `unsized_const_params` below
29: 27: // this allows us to use const generic &'static str for static text nodes and attributes
30: 28: #![allow(incomplete_features)]
31: 29: #![cfg_attr(
32: 30:     all(feature = "nightly", rustc_nightly),
33: 31:     feature(unsized_const_params)
34: 32: )]
35: 33: // support for const generic &'static str has now moved back and forth between
36: 34: // these two features a couple times; we'll just enable both
37: 35: #![cfg_attr(all(feature = "nightly", rustc_nightly), feature(adt_const_params))]
38: 36: #![deny(missing_docs)]
39: 37: 
40: 38: /// Commonly-used traits.
41: 39: pub mod prelude {
42: 40:     pub use crate::{
43: 41:         html::{
44: 42:             attribute::{
45: 43:                 any_attribute::IntoAnyAttribute,
46: 44:                 aria::AriaAttributes,
47: 45:                 custom::CustomAttribute,
48: 46:                 global::{
49: 47:                     ClassAttribute, GlobalAttributes, GlobalOnAttributes,
50: 48:                     OnAttribute, OnTargetAttribute, PropAttribute,
51: 49:                     StyleAttribute,
52: 50:                 },
53: 51:                 IntoAttributeValue,
54: 52:             },
55: 53:             directive::DirectiveAttribute,
56: 54:             element::{ElementChild, ElementExt, InnerHtmlAttribute},
57: 55:             node_ref::NodeRefAttribute,
58: 56:         },
59: 57:         renderer::{dom::Dom, Renderer},
60: 58:         view::{
61: 59:             add_attr::AddAnyAttr,
62: 60:             any_view::{AnyView, IntoAny, IntoMaybeErased},
63: 61:             IntoRender, Mountable, Render, RenderHtml,
64: 62:         },
65: 63:     };
66: 64: }
67: 65: 
68: 66: use wasm_bindgen::JsValue;
69: 67: use web_sys::Node;
70: 68: 
71: 69: /// Helpers for interacting with the DOM.
72: 70: pub mod dom;
73: 71: /// Types for building a statically-typed HTML view tree.
74: 72: pub mod html;
75: 73: /// Supports adding interactivity to HTML.
76: 74: pub mod hydration;
77: 75: /// Types for MathML.
78: 76: pub mod mathml;
79: 77: /// Defines various lyx-platform-lyx_platform_lyx-platform-lyx_platform_backends that can render views.
80: 78: pub mod renderer;
81: 79: /// Rendering views to HTML.
82: 80: pub mod ssr;
83: 81: /// Types for SVG.
84: 82: pub mod svg;
85: 83: /// Core logic for manipulating views.
86: 84: pub mod view;
87: 85: 
88: 86: pub use lyx-core-lyx_core_lyx-core-lyx_core_either_of as either;
89: 87: #[cfg(feature = "islands")]
90: 88: #[doc(hidden)]
91: 89: pub use wasm_bindgen;
92: 90: #[cfg(feature = "islands")]
93: 91: #[doc(hidden)]
94: 92: pub use web_sys;
95: 93: 
96: 94: /// View implementations for the `lyx-core-oco` crate (cheaply-cloned string types).
97: 95: #[cfg(feature = "oco")]
98: 96: pub mod oco;
99: 97: /// View implementations for the `lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph` crate.
100: 98: #[cfg(feature = "lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph")]
101: 99: pub mod lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph;
102: 100: 
103: 101: /// A type-erased container.
104: 102: pub mod erased;
105: 103: 
106: 104: pub(crate) trait UnwrapOrDebug {
107: 105:     type Output;
108: 106: 
109: 107:     fn or_debug(self, el: &Node, label: &'static str);
110: 108: 
111: 109:     fn ok_or_debug(
112: 110:         self,
113: 111:         el: &Node,
114: 112:         label: &'static str,
115: 113:     ) -> Option<Self::Output>;
116: 114: }
117: 115: 
118: 116: impl<T> UnwrapOrDebug for Result<T, JsValue> {
119: 117:     type Output = T;
120: 118: 
121: 119:     #[track_caller]
122: 120:     fn or_debug(self, el: &Node, name: &'static str) {
123: 121:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
124: 122:         {
125: 123:             if let Err(err) = self {
126: 124:                 let location = std::panic::Location::caller();
127: 125:                 web_sys::console::warn_3(
128: 126:                     &JsValue::from_str(&format!(
129: 127:                         "[WARNING] Non-fatal error at {location}, while \
130: 128:                          calling {name} on "
131: 129:                     )),
132: 130:                     el,
133: 131:                     &err,
134: 132:                 );
135: 133:             }
136: 134:         }
137: 135:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
138: 136:         {
139: 137:             _ = self;
140: 138:         }
141: 139:     }
142: 140: 
143: 141:     #[track_caller]
144: 142:     fn ok_or_debug(
145: 143:         self,
146: 144:         el: &Node,
147: 145:         name: &'static str,
148: 146:     ) -> Option<Self::Output> {
149: 147:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
150: 148:         {
151: 149:             if let Err(err) = &self {
152: 150:                 let location = std::panic::Location::caller();
153: 151:                 web_sys::console::warn_3(
154: 152:                     &JsValue::from_str(&format!(
155: 153:                         "[WARNING] Non-fatal error at {location}, while \
156: 154:                          calling {name} on "
157: 155:                     )),
158: 156:                     el,
159: 157:                     err,
160: 158:                 );
161: 159:             }
162: 160:             self.ok()
163: 161:         }
164: 162:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
165: 163:         {
166: 164:             self.ok()
167: 165:         }
168: 166:     }
169: 167: }
170: 168: 
171: 169: #[doc(hidden)]
172: 170: #[macro_export]
173: 171: macro_rules! or_debug {
174: 172:     ($action:expr, $el:expr, $label:literal) => {
175: 173:         if cfg!(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)) {
176: 174:             $crate::UnwrapOrDebug::or_debug($action, $el, $label);
177: 175:         } else {
178: 176:             _ = $action;
179: 177:         }
180: 178:     };
181: 179: }
182: 180: 
183: 181: #[doc(hidden)]
184: 182: #[macro_export]
185: 183: macro_rules! ok_or_debug {
186: 184:     ($action:expr, $el:expr, $label:literal) => {
187: 185:         if cfg!(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)) {
188: 186:             $crate::UnwrapOrDebug::ok_or_debug($action, $el, $label)
189: 187:         } else {
190: 188:             $action.ok()
191: 189:         }
192: 190:     };
193: 191: }
194: 192: ```
195: 193: ```
196: 194: ```
197: 195: ```
198: 196: ```
199: 197: ```
200: 198: ```
201: 199: ```
202: 200: ```
203: 201: ```
204: ```
```
