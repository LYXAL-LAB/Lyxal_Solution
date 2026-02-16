1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dom\src\platform\get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects.rs
42: 40: ```rust
43: 41: use lyx_ui_foundations_utils::ClientRectObject;
44: 42: 
45: 43: use crate::types::ElementOrVirtual;
46: 44: 
47: 45: pub fn get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects(element: ElementOrVirtual) -> Vec<ClientRectObject> {
48: 46:     match element {
49: 47:         ElementOrVirtual::Element(element) => {
50: 48:             ClientRectObject::from_dom_rect_list(element.get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects())
51: 49:         }
52: 50:         ElementOrVirtual::VirtualElement(virtual_element) => virtual_element
53: 51:             .get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects()
54: 52:             .expect("Virtual element must implement `get_lyx-core-lyx_core_lyx-core-lyx_core_client_rects`."),
55: 53:     }
56: 54: }
57: 55: ```
58: 56: ```
59: 57: ```
60: 58: ```
61: 59: ```
62: 60: ```
63: 61: ```
64: 62: ```
65: 63: ```
66: 64: ```
67: 65: ```
68: 66: ```
69: 67: ```
70: 68: ```
71: 69: ```
72: 70: ```
73: 71: ```
74: 72: ```
75: 73: ```
76: 74: ```
77: ```
```

