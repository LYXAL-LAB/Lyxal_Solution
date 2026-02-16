1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\middleware.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\middleware.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_core::middleware::{
44: 42:     Arrow as CoreArrow, AutoPlacement as CoreAutoPlacement, Flip as CoreFlip, Hide as CoreHide,
45: 43:     Inline as CoreInline, Offset as CoreOffset, Shift as CoreShift, Size as CoreSize,
46: 44: };
47: 45: use web_sys::{Element, Window};
48: 46: 
49: 47: pub use lyx_ui_foundations_core::middleware::{
50: 48:     ARROW_NAME, AUTO_PLACEMENT_NAME, ApplyState, ArrowData, ArrowOptions, AutoPlacementData,
51: 49:     AutoPlacementDataOverflow, AutoPlacementOptions, CrossAxis, DefaultLimiter, FLIP_NAME,
52: 50:     FallbackStrategy, FlipData, FlipDataOverflow, FlipOptions, HIDE_NAME, HideData, HideOptions,
53: 51:     HideStrategy, INLINE_NAME, InlineOptions, LimitShift, LimitShiftOffset, LimitShiftOffsetValues,
54: 52:     LimitShiftOptions, OFFSET_NAME, OffsetData, OffsetOptions, OffsetOptionsValues, SHIFT_NAME,
55: 53:     SIZE_NAME, ShiftData, ShiftOptions, SizeOptions,
56: 54: };
57: 55: 
58: 56: /// Arrow middleware.
59: 57: ///
60: 58: /// Provides data to position an inner element of the floating element so that it lyx-platform-lyx_platform_lyx-platform-lyx_platform_appears centered to the reference element.
61: 59: ///
62: 60: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/arrow.html) for more documentation.
63: 61: pub type Arrow<'a> = CoreArrow<'a, Element, Window>;
64: 62: 
65: 63: /// Auto placement middleware.
66: 64: ///
67: 65: /// Optimizes the visibility of the floating element by choosing the placement that has the most space available automatically,
68: 66: /// without needing to specify a preferred placement.
69: 67: ///
70: 68: /// Alternative to [`Flip`].
71: 69: ///
72: 70: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/auto-placement.html) for more documentation.
73: 71: pub type AutoPlacement<'a> = CoreAutoPlacement<'a, Element, Window>;
74: 72: 
75: 73: /// Flip middleware.
76: 74: ///
77: 75: /// Optimizes the visibility of the floating element by flipping the `placement` in order to keep it in view when the preferred placement(s) will overflow the clipping boundary.
78: 76: /// Alternative to [`AutoPlacement`].
79: 77: ///
80: 78: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/flip.html) for more documentation.
81: 79: pub type Flip<'a> = CoreFlip<'a, Element, Window>;
82: 80: 
83: 81: /// Hide middleware.
84: 82: ///
85: 83: /// Provides data to hide the floating element in lyx-platform-lyx_platform_lyx-platform-lyx_platform_applicable situations,
86: 84: /// such as when it is not in the same clipping context as the reference element.
87: 85: ///
88: 86: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/hide.html) for more documentation.
89: 87: pub type Hide<'a> = CoreHide<'a, Element, Window>;
90: 88: 
91: 89: /// Inline middleware.
92: 90: ///
93: 91: /// Provides improved positioning for inline reference elements that can span over multiple lines, such as hyperlinks or range selections.
94: 92: ///
95: 93: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/inline.html) for more documentation.
96: 94: pub type Inline<'a> = CoreInline<'a, Element, Window>;
97: 95: 
98: 96: /// Offset middleware.
99: 97: ///
100: 98: /// Modifies the placement by translating the floating element along the specified axes.
101: 99: ///
102: 100: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/offset.html) for more documentation.
103: 101: pub type Offset<'a> = CoreOffset<'a, Element, Window>;
104: 102: 
105: 103: /// Shift middleware.
106: 104: ///
107: 105: /// Optimizes the visibility of the floating element by shifting it in order to keep it in view when it will overflow the clipping boundary.
108: 106: ///
109: 107: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/shift.html) for more documentation.
110: 108: pub type Shift<'a> = CoreShift<'a, Element, Window>;
111: 109: 
112: 110: /// Size middleware.
113: 111: ///
114: 112: /// Provides data that allows you to change the size of the floating element -
115: 113: /// for instance, prevent it from overflowing the clipping boundary or match the width of the reference element.
116: 114: ///
117: 115: /// See [the Rust Floating UI book](https://floating-ui.rustforweb.org/middleware/size.html) for more documentation.
118: 116: pub type Size<'a> = CoreSize<'a, Element, Window>;
119: 117: ```
120: 118: ```
121: 119: ```
122: 120: ```
123: 121: ```
124: 122: ```
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
139: ```
```

