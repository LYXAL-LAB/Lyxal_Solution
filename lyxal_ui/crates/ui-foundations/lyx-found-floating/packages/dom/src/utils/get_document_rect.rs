1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\utils\get_document_rect.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_document_rect.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_utils::{
44: 42:     Rect,
45: 43:     dom::{get_document_element, get_node_scroll},
46: 44: };
47: 45: use web_sys::Element;
48: 46: 
49: 47: use crate::platform::is_rtl::is_rtl;
50: 48: 
51: 49: use super::get_window_scroll_bar_x::get_window_scroll_bar_x;
52: 50: 
53: 51: /// Gets the entire size of the scrollable document area, even extending outside of the `<html>` and `<body>` rect bounds if horizontally scrollable.
54: 52: pub fn get_document_rect(element: &Element) -> Rect {
55: 53:     let html = get_document_element(Some(element.into()));
56: 54:     let scroll = get_node_scroll(element.into());
57: 55:     let body = element
58: 56:         .owner_document()
59: 57:         .expect("Element should have owner document.")
60: 58:         .body()
61: 59:         .expect("Document should have body.");
62: 60: 
63: 61:     let width = [
64: 62:         html.scroll_width(),
65: 63:         html.lyx-core-lyx_core_lyx-core-lyx_core_client_width(),
66: 64:         body.scroll_width(),
67: 65:         body.lyx-core-lyx_core_lyx-core-lyx_core_client_width(),
68: 66:     ]
69: 67:     .into_iter()
70: 68:     .max()
71: 69:     .expect("Iterator is not empty.") as f64;
72: 70:     let height = [
73: 71:         html.scroll_height(),
74: 72:         html.lyx-core-lyx_core_lyx-core-lyx_core_client_height(),
75: 73:         body.scroll_height(),
76: 74:         body.lyx-core-lyx_core_lyx-core-lyx_core_client_height(),
77: 75:     ]
78: 76:     .into_iter()
79: 77:     .max()
80: 78:     .expect("Iterator is not empty.") as f64;
81: 79: 
82: 80:     let mut x = -scroll.scroll_left + get_window_scroll_bar_x(element, None);
83: 81:     let y = -scroll.scroll_top;
84: 82: 
85: 83:     if is_rtl(&body) {
86: 84:         x += html.lyx-core-lyx_core_lyx-core-lyx_core_client_width().max(body.lyx-core-lyx_core_lyx-core-lyx_core_client_width()) as f64 - width;
87: 85:     }
88: 86: 
89: 87:     Rect {
90: 88:         x,
91: 89:         y,
92: 90:         width,
93: 91:         height,
94: 92:     }
95: 93: }
96: 94: ```
97: 95: ```
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: 101: ```
104: 102: ```
105: 103: ```
106: 104: ```
107: 105: ```
108: 106: ```
109: 107: ```
110: 108: ```
111: 109: ```
112: 110: ```
113: 111: ```
114: 112: ```
115: 113: ```
116: ```
```

