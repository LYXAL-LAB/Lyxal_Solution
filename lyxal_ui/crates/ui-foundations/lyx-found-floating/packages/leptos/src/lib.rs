1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\lib.rs
42: 40: ```rust
43: 41: //! Rust port of [Floating UI](https://floating-ui.com/).
44: 42: //!
45: 43: //! This is the library to use Floating UI with Leptos.
46: 44: //!
47: 45: //! See [the Rust Floating UI book](https://floating-ui.rustforweb.org/frameworks/lyx-core-lyx_core_lyx-core-lyx_core_leptos.html) for more documenation.
48: 46: 
49: 47: mod arrow;
50: 48: mod types;
51: 49: mod use_floating;
52: 50: mod utils;
53: 51: 
54: 52: pub use arrow::*;
55: 53: pub use types::*;
56: 54: pub use use_floating::*;
57: 55: 
58: 56: #[doc(no_inline)]
59: 57: pub use lyx_ui_foundations_dom::{
60: 58:     ARROW_NAME, AUTO_PLACEMENT_NAME, AlignedPlacement, Alignment, ApplyState, ArrowData,
61: 59:     AutoPlacement, AutoPlacementData, AutoPlacementDataOverflow, AutoPlacementOptions,
62: 60:     AutoUpdateOptions, Axis, Boundary, ClientRectObject, ComputePositionConfig,
63: 61:     ComputePositionReturn, Coords, CrossAxis, DefaultLimiter, DefaultVirtualElement, Derivable,
64: 62:     DerivableFn, DetectOverflowOptions, Dimensions, ElementContext, ElementOrVirtual, ElementRects,
65: 63:     FLIP_NAME, FallbackStrategy, Flip, FlipData, FlipDataOverflow, FlipOptions, HIDE_NAME, Hide,
66: 64:     HideData, HideOptions, HideStrategy, INLINE_NAME, Inline, InlineOptions, Length, LimitShift,
67: 65:     LimitShiftOffset, LimitShiftOffsetValues, LimitShiftOptions, Middleware, MiddlewareData,
68: 66:     MiddlewareReturn, MiddlewareState, MiddlewareVec, MiddlewareWithOptions, OFFSET_NAME, Offset,
69: 67:     OffsetData, OffsetOptions, OffsetOptionsValues, Padding, PartialSideObject, Placement, Rect,
70: 68:     RootBoundary, SHIFT_NAME, SIZE_NAME, Shift, ShiftData, ShiftOptions, Side, Size, SizeOptions,
71: 69:     Strategy, VirtualElement, auto_update, compute_position, dom,
72: 70: };
73: 71: ```
74: 72: ```
75: 73: ```
76: 74: ```
77: 75: ```
78: 76: ```
79: 77: ```
80: 78: ```
81: 79: ```
82: 80: ```
83: 81: ```
84: 82: ```
85: 83: ```
86: 84: ```
87: 85: ```
88: 86: ```
89: 87: ```
90: 88: ```
91: 89: ```
92: 90: ```
93: ```
```

