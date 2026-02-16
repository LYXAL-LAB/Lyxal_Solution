1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\convert_offset_parent_relative_rect_to_viewport_relative_rect.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_core::ConvertOffsetParentRelativeRectToViewportRelativeRectArgs;
44: 42: use lyx_ui_foundations_utils::{
45: 43:     Coords, ElementOrWindow, Rect, Strategy,
46: 44:     dom::{
47: 45:         NodeScroll, get_document_element, get_node_name, get_node_scroll, is_overflow_element,
48: 46:         is_top_layer,
49: 47:     },
50: 48: };
51: 49: use web_sys::{Element, Window};
52: 50: 
53: 51: use crate::{
54: 52:     platform::get_scale::get_scale,
55: 53:     utils::{get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect::get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect, get_html_offset::get_html_offset},
56: 54: };
57: 55: 
58: 56: pub fn convert_offset_parent_relative_rect_to_viewport_relative_rect(
59: 57:     ConvertOffsetParentRelativeRectToViewportRelativeRectArgs {
60: 58:         elements,
61: 59:         rect,
62: 60:         offset_parent,
63: 61:         strategy,
64: 62:     }: ConvertOffsetParentRelativeRectToViewportRelativeRectArgs<Element, Window>,
65: 63: ) -> Rect {
66: 64:     let is_fixed = strategy == Strategy::Fixed;
67: 65:     let document_element = get_document_element(
68: 66:         offset_parent
69: 67:             .as_ref()
70: 68:             .map(|offset_parent| offset_parent.into()),
71: 69:     );
72: 70:     let top_layer = elements.is_some_and(|elements| is_top_layer(elements.floating));
73: 71: 
74: 72:     if offset_parent
75: 73:         .as_ref()
76: 74:         .is_some_and(|offset_parent| match offset_parent {
77: 75:             ElementOrWindow::Element(element) => *element == &document_element,
78: 76:             ElementOrWindow::Window(_) => false,
79: 77:         })
80: 78:         || (top_layer && is_fixed)
81: 79:     {
82: 80:         return rect;
83: 81:     }
84: 82: 
85: 83:     let mut scroll = NodeScroll::new(0.0);
86: 84:     let mut scale = Coords::new(1.0);
87: 85:     let mut offsets = Coords::new(0.0);
88: 86:     let is_offset_parent_an_element =
89: 87:         offset_parent
90: 88:             .as_ref()
91: 89:             .is_some_and(|offset_parent| match offset_parent {
92: 90:                 ElementOrWindow::Element(_) => true,
93: 91:                 ElementOrWindow::Window(_) => false,
94: 92:             });
95: 93: 
96: 94:     #[allow(clippy::nonminimal_bool)]
97: 95:     if is_offset_parent_an_element || (!is_offset_parent_an_element && !is_fixed) {
98: 96:         if let Some(offset_parent) = offset_parent.as_ref()
99: 97:             && (get_node_name(offset_parent.into()) != "body"
100: 98:                 || is_overflow_element(&document_element))
101: 99:         {
102: 100:             scroll = get_node_scroll(offset_parent.into());
103: 101:         }
104: 102: 
105: 103:         if let Some(ElementOrWindow::Element(offset_parent)) = offset_parent {
106: 104:             let offset_rect = get_bounding_lyx-core-lyx_core_lyx-core-lyx_core_client_rect(offset_parent.into(), false, false, None);
107: 105:             scale = get_scale(offset_parent.into());
108: 106:             offsets.x = offset_rect.x + offset_parent.lyx-core-lyx_core_lyx-core-lyx_core_client_left() as f64;
109: 107:             offsets.y = offset_rect.y + offset_parent.lyx-core-lyx_core_lyx-core-lyx_core_client_top() as f64;
110: 108:         }
111: 109:     }
112: 110: 
113: 111:     let html_offset = if !is_offset_parent_an_element && !is_fixed {
114: 112:         get_html_offset(&document_element, &scroll)
115: 113:     } else {
116: 114:         Coords::new(0.0)
117: 115:     };
118: 116: 
119: 117:     Rect {
120: 118:         x: rect.x * scale.x - scroll.scroll_left * scale.x + offsets.x + html_offset.x,
121: 119:         y: rect.y * scale.y - scroll.scroll_top * scale.y + offsets.y + html_offset.y,
122: 120:         width: rect.width * scale.x,
123: 121:         height: rect.height * scale.y,
124: 122:     }
125: 123: }
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
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: 143: ```
146: ```
```

