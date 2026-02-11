### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\utils\get_viewport_rect.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\utils\get_viewport_rect.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_viewport_rect.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_utils::{
44: 42:     Rect, Strategy,
45: 43:     dom::{get_computed_style, get_document_element, get_window, is_web_kit},
46: 44: };
47: 45: use web_sys::Element;
48: 46: 
49: 47: use crate::utils::get_window_scroll_bar_x::get_window_scroll_bar_x;
50: 48: 
51: 49: // Safety check: ensure the scrollbar space is reasonable in case this calculation is affected by unusual styles.
52: 50: // Most scrollbars leave 15-18px of space.
53: 51: const SCROLLBAR_MAX: f64 = 25.0;
54: 52: 
55: 53: pub fn get_viewport_rect(element: &Element, strategy: Strategy) -> Rect {
56: 54:     let window = get_window(Some(element));
57: 55:     let html = get_document_element(Some(element.into()));
58: 56:     let visual_viewport = window.visual_viewport();
59: 57: 
60: 58:     let mut x = 0.0;
61: 59:     let mut y = 0.0;
62: 60:     let mut width = html.lyx-core-lyx_core_lyx-core-lyx_core_client_width() as f64;
63: 61:     let mut height = html.lyx-core-lyx_core_lyx-core-lyx_core_client_height() as f64;
64: 62: 
65: 63:     if let Some(visual_viewport) = visual_viewport {
66: 64:         width = visual_viewport.width();
67: 65:         height = visual_viewport.height();
68: 66: 
69: 67:         let visual_viewport_based = is_web_kit();
70: 68:         if !visual_viewport_based || strategy == Strategy::Fixed {
71: 69:             x = visual_viewport.offset_left();
72: 70:             y = visual_viewport.offset_top();
73: 71:         }
74: 72:     }
75: 73: 
76: 74:     let window_scrollbar_x = get_window_scroll_bar_x(&html, None);
77: 75:     // <html> `overflow: hidden` + `scrollbar-gutter: stable` reduces the visual width of the <html>,
78: 76:     // but this is not considered in the size of `html.lyx-core-lyx_core_lyx-core-lyx_core_client_width`.
79: 77:     if window_scrollbar_x <= 0.0 {
80: 78:         let doc = html
81: 79:             .owner_document()
82: 80:             .expect("Element should have owner document.");
83: 81:         let body = doc.body().expect("Document should have body.");
84: 82:         let body_styles = get_computed_style(&body);
85: 83:         let body_margin_inline = if doc.compat_mode() == "CSS1Compat" {
86: 84:             body_styles
87: 85:                 .get_property_value("margin-left")
88: 86:                 .expect("Computed style should have margin left.")
89: 87:                 .parse::<f64>()
90: 88:                 .unwrap_or(0.0)
91: 89:                 + body_styles
92: 90:                     .get_property_value("margin-right")
93: 91:                     .expect("Computed style should have margin right.")
94: 92:                     .parse::<f64>()
95: 93:                     .unwrap_or(0.0)
96: 94:         } else {
97: 95:             0.0
98: 96:         };
99: 97:         let clipping_stable_scrollbar_width =
100: 98:             ((html.lyx-core-lyx_core_lyx-core-lyx_core_client_width() as f64) - (body.lyx-core-lyx_core_lyx-core-lyx_core_client_width() as f64) - body_margin_inline)
101: 99:                 .abs();
102: 100: 
103: 101:         if clipping_stable_scrollbar_width <= SCROLLBAR_MAX {
104: 102:             width -= clipping_stable_scrollbar_width;
105: 103:         }
106: 104:     } else if window_scrollbar_x <= SCROLLBAR_MAX {
107: 105:         // If the <body> scrollbar is on the left, the width needs to be extended
108: 106:         // by the scrollbar amount so there isn't extra space on the right.
109: 107:         width += window_scrollbar_x;
110: 108:     }
111: 109: 
112: 110:     Rect {
113: 111:         x,
114: 112:         y,
115: 113:         width,
116: 114:         height,
117: 115:     }
118: 116: }
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
