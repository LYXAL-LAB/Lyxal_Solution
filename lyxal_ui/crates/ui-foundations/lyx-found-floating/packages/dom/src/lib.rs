### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\lib.rs
42: 40: ```rust
43: 41: //! Rust port of [Floating UI](https://floating-ui.com/).
44: 42: //!
45: 43: //! This is the library to use Floating UI on the web, wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping [`lyx_ui_foundations_core`] with DOM interface logic.
46: 44: //!
47: 45: //! See [the Rust Floating UI book](https://floating-ui.rustforweb.org/) for more documenation.
48: 46: //!
49: 47: //! See [@floating-ui/dom](https://www.npmjs.com/package/@floating-ui/dom) for the original package.
50: 48: 
51: 49: mod auto_update;
52: 50: mod middleware;
53: 51: mod platform;
54: 52: mod types;
55: 53: mod utils;
56: 54: 
57: 55: pub use self::platform::Platform;
58: 56: pub use crate::auto_update::*;
59: 57: pub use crate::middleware::*;
60: 58: pub use crate::types::*;
61: 59: pub use lyx_ui_foundations_core::{
62: 60:     Boundary, ComputePositionReturn, Derivable, DerivableFn, DetectOverflowOptions, ElementContext,
63: 61:     Middleware, MiddlewareData, MiddlewareReturn, MiddlewareState, MiddlewareWithOptions,
64: 62:     RootBoundary,
65: 63: };
66: 64: #[doc(no_inline)]
67: 65: pub use lyx_ui_foundations_utils::{
68: 66:     AlignedPlacement, Alignment, Axis, ClientRectObject, Coords, Dimensions, ElementRects, Length,
69: 67:     Padding, PartialSideObject, Placement, Rect, Side, SideObject, Strategy, VirtualElement, dom,
70: 68: };
71: 69: 
72: 70: use lyx_ui_foundations_core::{
73: 71:     ComputePositionConfig as CoreComputePositionConfig, compute_position as compute_position_core,
74: 72: };
75: 73: use web_sys::Element;
76: 74: 
77: 75: const PLATFORM: Platform = Platform {};
78: 76: 
79: 77: /// Options for [`compute_position`].
80: 78: #[derive(Clone, Default)]
81: 79: pub struct ComputePositionConfig {
82: 80:     /// Where to place the floating element relative to the reference element.
83: 81:     ///
84: 82:     /// Defaults to [`Placement::Bottom`].
85: 83:     pub placement: Option<Placement>,
86: 84: 
87: 85:     /// The strategy to use when positioning the floating element.
88: 86:     ///
89: 87:     /// Defaults to [`Strategy::Absolute`].
90: 88:     pub strategy: Option<Strategy>,
91: 89: 
92: 90:     /// Vector of middleware objects to modify the positioning or provide data for rendering.
93: 91:     ///
94: 92:     /// Defaults to an empty vector.
95: 93:     pub middleware: Option<MiddlewareVec>,
96: 94: }
97: 95: 
98: 96: impl ComputePositionConfig {
99: 97:     /// Set `placement` option.
100: 98:     pub fn placement(mut self, value: Placement) -> Self {
101: 99:         self.placement = Some(value);
102: 100:         self
103: 101:     }
104: 102: 
105: 103:     /// Set `strategy` option.
106: 104:     pub fn strategy(mut self, value: Strategy) -> Self {
107: 105:         self.strategy = Some(value);
108: 106:         self
109: 107:     }
110: 108: 
111: 109:     /// Set `middleware` option.
112: 110:     pub fn middleware(mut self, value: MiddlewareVec) -> Self {
113: 111:         self.middleware = Some(value);
114: 112:         self
115: 113:     }
116: 114: }
117: 115: 
118: 116: /// Computes the `x` and `y` coordinates that will place the floating element next to a given reference element.
119: 117: pub fn compute_position(
120: 118:     reference: ElementOrVirtual,
121: 119:     floating: &Element,
122: 120:     config: ComputePositionConfig,
123: 121: ) -> ComputePositionReturn {
124: 122:     // TODO: cache
125: 123: 
126: 124:     compute_position_core(
127: 125:         reference,
128: 126:         floating,
129: 127:         CoreComputePositionConfig {
130: 128:             platform: &PLATFORM,
131: 129:             placement: config.placement,
132: 130:             strategy: config.strategy,
133: 131:             middleware: config.middleware,
134: 132:         },
135: 133:     )
136: 134: }
137: 135: ```
138: 136: ```
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
157: ```
```
