1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
32: ```rust
33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
34: ```rust
35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
36: ```rust
37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
38: ```rust
39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_offset_parent.rs
40: ```rust
41: use lyx_ui_foundations_utils::OwnedElementOrWindow;
42: use lyx_ui_foundations_utils::dom::{
43:     DomNodeOrWindow, get_computed_style, get_containing_block, get_document_element,
44:     get_parent_node, get_window, is_containing_block, is_element, is_html_element,
45:     is_last_traversable_node, is_table_element, is_top_layer,
46: };
47: use web_sys::Window;
48: use web_sys::{Element, HtmlElement, wasm_bindgen::JsCast};
49: 
50: use crate::utils::is_static_positioned::is_static_positioned;
51: 
52: pub type Polyfill = Box<dyn Fn(&HtmlElement) -> Option<Element>>;
53: 
54: pub fn get_true_offset_parent(element: &Element, polyfill: &Option<Polyfill>) -> Option<Element> {
55:     if !is_html_element(element)
56:         || get_computed_style(element)
57:             .get_property_value("position")
58:             .expect("Computed style should have position.")
59:             == "fixed"
60:     {
61:         None
62:     } else {
63:         let element = element.unchecked_ref::<HtmlElement>();
64: 
65:         if let Some(polyfill) = polyfill {
66:             polyfill(element)
67:         } else {
68:             let raw_offset_parent = element.offset_parent();
69: 
70:             // Firefox returns the <html> element as the offsetParent if it's non-static, while Chrome and Safari return the <body> element.
71:             // The <body> element must be used to perform the correct calculations even if the <html> element is non-static.
72:             if let Some(raw_offset_parent) = raw_offset_parent.as_ref()
73:                 && get_document_element(Some(DomNodeOrWindow::Node(raw_offset_parent)))
74:                     == *raw_offset_parent
75:             {
76:                 return Some(
77:                     raw_offset_parent
78:                         .owner_document()
79:                         .expect("Element should have owner document.")
80:                         .body()
81:                         .expect("Document should have body.")
82:                         .unchecked_into::<Element>(),
83:                 );
84:             }
85: 
86:             raw_offset_parent
87:         }
88:     }
89: }
90: 
91: /// Gets the closest ancestor positioned element. Handles some edge cases, such as table ancestors and cross browser bugs.
92: pub fn get_offset_parent(
93:     element: &Element,
94:     polyfill: Option<Polyfill>,
95: ) -> OwnedElementOrWindow<Element, Window> {
96:     let window = get_window(Some(element));
97: 
98:     if is_top_layer(element) {
99:         return OwnedElementOrWindow::Window(window);
100:     }
101: 
102:     if !is_html_element(element) {
103:         let mut svg_offset_parent = Some(get_parent_node(element));
104:         while let Some(parent) = svg_offset_parent.as_ref() {
105:             if is_last_traversable_node(parent) {
106:                 break;
107:             }
108: 
109:             if is_element(parent) {
110:                 let element = parent.unchecked_ref::<Element>();
111:                 if !is_static_positioned(element) {
112:                     return OwnedElementOrWindow::Element(element.clone());
113:                 }
114:             }
115:             svg_offset_parent = Some(get_parent_node(parent))
116:         }
117:         return OwnedElementOrWindow::Window(window);
118:     }
119: 
120:     let mut offset_parent = get_true_offset_parent(element, &polyfill);
121: 
122:     while let Some(parent) = offset_parent.as_ref() {
123:         if is_table_element(parent) && is_static_positioned(parent) {
124:             offset_parent = get_true_offset_parent(parent, &polyfill);
125:         } else {
126:             break;
127:         }
128:     }
129: 
130:     if let Some(parent) = offset_parent.as_ref()
131:         && is_last_traversable_node(parent)
132:         && is_static_positioned(parent)
133:         && !is_containing_block(parent.into())
134:     {
135:         return OwnedElementOrWindow::Window(window);
136:     }
137: 
138:     offset_parent
139:         .map(OwnedElementOrWindow::Element)
140:         .or(get_containing_block(element)
141:             .map(|element| OwnedElementOrWindow::Element(element.into())))
142:         .unwrap_or(OwnedElementOrWindow::Window(window))
143: }
144: ```
145: ```
146: ```
147: ```
148: ```
149: ```
150: ```
151: ```
152: ```
153: ```
154: ```
155: ```
156: ```
157: ```
158: ```
159: ```
160: ```
161: ```
162: ```
163: ```
```

