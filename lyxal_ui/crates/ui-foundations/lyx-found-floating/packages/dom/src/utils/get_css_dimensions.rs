### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\utils\get_css_dimensions.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
32: ```rust
33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
34: ```rust
35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
36: ```rust
37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
38: ```rust
39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_css_dimensions.rs
40: ```rust
41: use lyx_ui_foundations_utils::{
42:     Dimensions,
43:     dom::{get_computed_style, is_html_element},
44: };
45: use web_sys::{Element, HtmlElement, wasm_bindgen::JsCast};
46: 
47: #[derive(Clone, Debug)]
48: pub struct CssDimensions {
49:     pub dimensions: Dimensions,
50:     pub should_fallback: bool,
51: }
52: 
53: pub fn get_css_dimensions(element: &Element) -> CssDimensions {
54:     let css = get_computed_style(element);
55: 
56:     let width = css
57:         .get_property_value("width")
58:         .expect("Computed style should have width.")
59:         .replace("px", "")
60:         .parse::<f64>()
61:         .unwrap_or(0.0);
62:     let height = css
63:         .get_property_value("height")
64:         .expect("Computed style should have height.")
65:         .replace("px", "")
66:         .parse::<f64>()
67:         .unwrap_or(0.0);
68: 
69:     let offset_width;
70:     let offset_height;
71:     if is_html_element(element) {
72:         let element = element.unchecked_ref::<HtmlElement>();
73:         offset_width = element.offset_width() as f64;
74:         offset_height = element.offset_height() as f64;
75:     } else {
76:         offset_width = width;
77:         offset_height = height;
78:     }
79:     let should_fallback = width.round() != offset_width || height.round() != offset_height;
80: 
81:     CssDimensions {
82:         dimensions: if should_fallback {
83:             Dimensions {
84:                 width: offset_width,
85:                 height: offset_height,
86:             }
87:         } else {
88:             Dimensions { width, height }
89:         },
90:         should_fallback,
91:     }
92: }
93: ```
94: ```
95: ```
96: ```
97: ```
98: ```
99: ```
100: ```
101: ```
102: ```
103: ```
104: ```
105: ```
106: ```
107: ```
108: ```
109: ```
110: ```
111: ```
112: ```
```
