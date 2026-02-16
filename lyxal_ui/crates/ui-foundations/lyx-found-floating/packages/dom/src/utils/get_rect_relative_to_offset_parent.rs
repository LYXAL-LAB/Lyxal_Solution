1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_rect_relative_to_offset_parent.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_utils::{
44: 42:     Coords, Rect, Strategy,
45: 43:     dom::{
46: 44:         DomElementOrWindow, NodeScroll, get_document_element, get_node_name, get_node_scroll,
47: 45:         is_overflow_element,
48: 46:     },
49: 47: };
50: 48: 
51: 49: use crate::{
52: 50:     types::ElementOrVirtual,
53: 51:     utils::{
54: 52:         get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect::get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect, get_html_offset::get_html_offset,
55: 53:         get_window_scroll_bar_x::get_window_scroll_bar_x,
56: 54:     },
57: 55: };
58: 56: 
59: 57: pub fn get_rect_relative_to_offset_parent(
60: 58:     element_or_virtual: ElementOrVirtual,
61: 59:     offset_parent: DomElementOrWindow,
62: 60:     strategy: Strategy,
63: 61: ) -> Rect {
64: 62:     let is_offset_parent_an_element = matches!(offset_parent, DomElementOrWindow::Element(_));
65: 63:     let document_element = get_document_element(Some((&offset_parent).into()));
66: 64:     let is_fixed = strategy == Strategy::Fixed;
67: 65:     let rect = get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(
68: 66:         element_or_virtual,
69: 67:         true,
70: 68:         is_fixed,
71: 69:         Some(offset_parent.clone()),
72: 70:     );
73: 71: 
74: 72:     let mut scroll = NodeScroll::new(0.0);
75: 73:     let mut offsets = Coords::new(0.0);
76: 74: 
77: 75:     // If the <body> scrollbar lyx-platform-lyx_platform_lyx-platform-lyx_platform_appears on the left (e.g. RTL systems).
78: 76:     // Use Firefox with layout.scrollbar.side = 3 in about:config to test this.
79: 77:     let set_left_rtl_scrollbar_offset = |offsets: &mut Coords| {
80: 78:         offsets.x = get_window_scroll_bar_x(&document_element, None);
81: 79:     };
82: 80: 
83: 81:     #[allow(clippy::nonminimal_bool)]
84: 82:     if is_offset_parent_an_element || (!is_offset_parent_an_element && !is_fixed) {
85: 83:         if get_node_name((&offset_parent).into()) != "body"
86: 84:             || is_overflow_element(&document_element)
87: 85:         {
88: 86:             scroll = get_node_scroll(offset_parent.clone());
89: 87:         }
90: 88: 
91: 89:         match offset_parent {
92: 90:             DomElementOrWindow::Element(offset_parent) => {
93: 91:                 let offset_rect = get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(
94: 92:                     offset_parent.into(),
95: 93:                     true,
96: 94:                     is_fixed,
97: 95:                     Some(offset_parent.into()),
98: 96:                 );
99: 97:                 offsets.x = offset_rect.x + offset_parent.lyx-core-lyx_core_lyx-core-lyx_core_client_left() as f64;
100: 98:                 offsets.y = offset_rect.y + offset_parent.lyx-core-lyx_core_lyx-core-lyx_core_client_top() as f64;
101: 99:             }
102: 100:             DomElementOrWindow::Window(_) => {
103: 101:                 set_left_rtl_scrollbar_offset(&mut offsets);
104: 102:             }
105: 103:         }
106: 104:     }
107: 105: 
108: 106:     if is_fixed && !is_offset_parent_an_element {
109: 107:         set_left_rtl_scrollbar_offset(&mut offsets);
110: 108:     }
111: 109: 
112: 110:     let html_offset = if !is_offset_parent_an_element && !is_fixed {
113: 111:         get_html_offset(&document_element, &scroll)
114: 112:     } else {
115: 113:         Coords::new(0.0)
116: 114:     };
117: 115: 
118: 116:     let x = rect.left + scroll.scroll_left - offsets.x - html_offset.x;
119: 117:     let y = rect.top + scroll.scroll_top - offsets.y - html_offset.y;
120: 118: 
121: 119:     Rect {
122: 120:         x,
123: 121:         y,
124: 122:         width: rect.width,
125: 123:         height: rect.height,
126: 124:     }
127: 125: }
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
145: 143: ```
146: 144: ```
147: 145: ```
148: ```
```

