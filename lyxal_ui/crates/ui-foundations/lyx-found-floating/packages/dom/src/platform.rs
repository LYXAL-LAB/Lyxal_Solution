### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform.rs
42: 40: ```rust
43: 41: pub mod convert_offset_parent_relative_rect_to_viewport_relative_rect;
44: 42: pub mod get_lyx-core-lyx_core_lyx-core-lyx_core_client_length;
45: 43: pub mod get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects;
46: 44: pub mod get_clipping_rect;
47: 45: pub mod get_dimensions;
48: 46: pub mod get_element_rects;
49: 47: pub mod get_offset_parent;
50: 48: pub mod get_scale;
51: 49: pub mod is_rtl;
52: 50: 
53: 51: use lyx_ui_foundations_core::{
54: 52:     ConvertOffsetParentRelativeRectToViewportRelativeRectArgs, GetClippingRectArgs,
55: 53:     GetElementRectsArgs, Platform as CorePlatform,
56: 54: };
57: 55: use lyx_ui_foundations_utils::dom::get_document_element;
58: 56: use lyx_ui_foundations_utils::{
59: 57:     ClientRectObject, Coords, Dimensions, ElementRects, Length, OwnedElementOrWindow, Rect,
60: 58: };
61: 59: use web_sys::{Element, Window};
62: 60: 
63: 61: use crate::types::ElementOrVirtual;
64: 62: 
65: 63: use self::convert_offset_parent_relative_rect_to_viewport_relative_rect::convert_offset_parent_relative_rect_to_viewport_relative_rect;
66: 64: use self::get_lyx-core-lyx_core_lyx-core-lyx_core_client_length::get_lyx-core-lyx_core_lyx-core-lyx_core_client_length;
67: 65: use self::get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects::get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects;
68: 66: use self::get_clipping_rect::get_clipping_rect;
69: 67: use self::get_dimensions::get_dimensions;
70: 68: use self::get_element_rects::get_element_rects;
71: 69: use self::get_offset_parent::get_offset_parent;
72: 70: use self::get_scale::get_scale;
73: 71: use self::is_rtl::is_rtl;
74: 72: 
75: 73: #[derive(Debug)]
76: 74: pub struct Platform {}
77: 75: 
78: 76: impl CorePlatform<Element, Window> for Platform {
79: 77:     fn get_element_rects(&self, args: GetElementRectsArgs<Element>) -> ElementRects {
80: 78:         get_element_rects(self, args)
81: 79:     }
82: 80: 
83: 81:     fn get_clipping_rect(&self, args: GetClippingRectArgs<Element>) -> Rect {
84: 82:         get_clipping_rect(self, args)
85: 83:     }
86: 84: 
87: 85:     fn get_dimensions(&self, element: &Element) -> Dimensions {
88: 86:         get_dimensions(element)
89: 87:     }
90: 88: 
91: 89:     fn convert_offset_parent_relative_rect_to_viewport_relative_rect(
92: 90:         &self,
93: 91:         args: ConvertOffsetParentRelativeRectToViewportRelativeRectArgs<Element, Window>,
94: 92:     ) -> Option<Rect> {
95: 93:         Some(convert_offset_parent_relative_rect_to_viewport_relative_rect(args))
96: 94:     }
97: 95: 
98: 96:     fn get_offset_parent(
99: 97:         &self,
100: 98:         element: &Element,
101: 99:     ) -> Option<OwnedElementOrWindow<Element, Window>> {
102: 100:         Some(get_offset_parent(element, None))
103: 101:     }
104: 102: 
105: 103:     fn get_document_element(&self, element: &Element) -> Option<Element> {
106: 104:         Some(get_document_element(Some(element.into())))
107: 105:     }
108: 106: 
109: 107:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(&self, element: ElementOrVirtual) -> Option<Vec<ClientRectObject>> {
110: 108:         Some(get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(element))
111: 109:     }
112: 110: 
113: 111:     fn is_rtl(&self, element: &Element) -> Option<bool> {
114: 112:         Some(is_rtl(element))
115: 113:     }
116: 114: 
117: 115:     fn get_scale(&self, element: &Element) -> Option<Coords> {
118: 116:         Some(get_scale(element.into()))
119: 117:     }
120: 118: 
121: 119:     fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_length(&self, element: &Element, length: Length) -> Option<f64> {
122: 120:         Some(get_lyx-core-lyx_core_lyx-core-lyx_core_client_length(element, length))
123: 121:     }
124: 122: }
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
139: 137: ```
140: 138: ```
141: 139: ```
142: 140: ```
143: 141: ```
144: 142: ```
145: ```
```
