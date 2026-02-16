1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
32: ```rust
33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
34: ```rust
35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
36: ```rust
37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
38: ```rust
39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\utils\get_visual_offsets.rs
40: ```rust
41: use lyx_ui_foundations_utils::{
42:     Coords,
43:     dom::{DomElementOrWindow, get_window},
44: };
45: use web_sys::Element;
46: 
47: pub fn get_visual_offsets(_element: Option<&Element>) -> Coords {
48:     // TODO: web-sys does not support VisualViewport
49: 
50:     // let window = get_window(element.map(|element| element.as_ref()));
51: 
52:     // if !is_web_kit() || !window.visual_viewport {
53:     //     Coords::new(0.0)
54:     // } else {
55:     //     Coords {
56:     //         x: todo!(),
57:     //         y: todo!(),
58:     //     }
59:     // }
60: 
61:     Coords::new(0.0)
62: }
63: 
64: pub fn should_add_visual_offsets(
65:     element: Option<&Element>,
66:     is_fixed: bool,
67:     floating_offset_parent: Option<DomElementOrWindow>,
68: ) -> bool {
69:     match floating_offset_parent {
70:         Some(DomElementOrWindow::Window(floating_offset_parent)) => {
71:             if is_fixed
72:                 && *floating_offset_parent != get_window(element.map(|element| element.as_ref()))
73:             {
74:                 false
75:             } else {
76:                 is_fixed
77:             }
78:         }
79:         _ => false,
80:     }
81: }
82: ```
83: ```
84: ```
85: ```
86: ```
87: ```
88: ```
89: ```
90: ```
91: ```
92: ```
93: ```
94: ```
95: ```
96: ```
97: ```
98: ```
99: ```
100: ```
101: ```
```

