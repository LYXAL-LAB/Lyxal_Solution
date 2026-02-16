1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-toast\src\mount_style.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_toast\src\mount_style.rs
46: 44: ```rust
47: 45: use cfg_if::cfg_if;
48: 46: pub fn mount_style(id: &str, content: &'static str) {
49: 47:     let id = format!("lyx-core-lyx_core_lyx-core-lyx_core_leptos-color-id-{id}");
50: 48:     cfg_if! {
51: 49:         if #[cfg(feature = "ssr")] {
52: 50:             use lyx-core-lyx_core_lyx-core-lyx_core_leptos::view;
53: 51:             use lyx-core-lyx_core_lyx-core-meta::Style;
54: 52:             let _ = view! {
55: 53:                 <Style id=id>
56: 54:                     {content}
57: 55:                 </Style>
58: 56:             };
59: 57:         } else {
60: 58:             use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::document;
61: 59:             let head = document().head().expect("head no exist");
62: 60:             let style = head
63: 61:                 .query_selector(&format!("style#{id}"))
64: 62:                 .expect("query style element error");
65: 63: 
66: 64:             if style.is_some() {
67: 65:                 return;
68: 66:             }
69: 67: 
70: 68:             let style = document()
71: 69:                 .create_element("style")
72: 70:                 .expect("create style element error");
73: 71:             _ = style.set_attribute("id", &id);
74: 72:             style.set_text_content(Some(content));
75: 73:             _ = head.prepend_with_node_1(&style);
76: 74:         }
77: 75:     }
78: 76: }
79: 77: ```
80: 78: ```
81: 79: ```
82: 80: ```
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
101: ```
```

