### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform\get_scale.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform\get_scale.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_scale.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_utils::Coords;
44: 42: 
45: 43: use crate::{
46: 44:     types::ElementOrVirtual,
47: 45:     utils::get_css_dimensions::{CssDimensions, get_css_dimensions},
48: 46: };
49: 47: 
50: 48: pub fn get_scale(element_or_virtual: ElementOrVirtual) -> Coords {
51: 49:     let dom_element = element_or_virtual.resolve();
52: 50: 
53: 51:     if let Some(dom_element) = dom_element {
54: 52:         let rect = dom_element.get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect();
55: 53:         let CssDimensions {
56: 54:             dimensions,
57: 55:             should_fallback,
58: 56:         } = get_css_dimensions(&dom_element);
59: 57:         let mut x = if should_fallback {
60: 58:             rect.width().round()
61: 59:         } else {
62: 60:             rect.width()
63: 61:         } / dimensions.width;
64: 62:         let mut y = if should_fallback {
65: 63:             rect.height().round()
66: 64:         } else {
67: 65:             rect.height()
68: 66:         } / dimensions.height;
69: 67: 
70: 68:         if x == 0.0 || x.is_nan() || x.is_infinite() {
71: 69:             x = 1.0;
72: 70:         }
73: 71: 
74: 72:         if y == 0.0 || y.is_nan() || y.is_infinite() {
75: 73:             y = 1.0;
76: 74:         }
77: 75: 
78: 76:         Coords { x, y }
79: 77:     } else {
80: 78:         Coords::new(1.0)
81: 79:     }
82: 80: }
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
93: 91: ```
94: 92: ```
95: 93: ```
96: 94: ```
97: 95: ```
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: ```
```
