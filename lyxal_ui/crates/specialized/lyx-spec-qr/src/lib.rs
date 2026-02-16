1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-qr\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_qr\src\lib.rs
46: 44: ```rust
47: 45: pub use fast_qr::convert::{Color, Shape};
48: 46: pub use fast_qr::ECL;
49: 47: use fast_qr::convert::Builder;
50: 48: use fast_qr::convert::svg::SvgBuilder;
51: 49: use fast_qr::QRBuilder;
52: 50: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::component;
53: 51: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::IntoView;
54: 52: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Get;
55: 53: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::InnerHtmlAttribute;
56: 54: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::Signal;
57: 55: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::view;
58: 56: 
59: 57: #[component]
60: 58: pub fn QrCode(
61: 59:     #[prop(into)] data: Signal<String>,
62: 60:     #[prop(into, optional)] fg_color: Option<String>,
63: 61:     #[prop(into, optional)] bg_color: Option<String>,
64: 62:     #[prop(into, optional)] shape: Option<Shape>,
65: 63:     #[prop(into, optional)] ecl: Option<ECL>,
66: 64: ) -> impl IntoView {
67: 65:     let fg_color_inner = fg_color.clone();
68: 66:     let bg_color_inner = bg_color.clone();
69: 67:     let qr_svg = move || {
70: 68:         let qrcode = QRBuilder::new(data.get())
71: 69:             .ecl(ecl.unwrap_or(ECL::M))
72: 70:             .build()
73: 71:             .unwrap();
74: 72: 
75: 73:         let svg = SvgBuilder::default()
76: 74:             .shape(shape.unwrap_or(Shape::Square))
77: 75:             .background_color(Color(
78: 76:                 bg_color_inner
79: 77:                     .clone()
80: 78:                     .unwrap_or_else(|| "#FFFFFF".to_string()),
81: 79:             ))
82: 80:             .module_color(Color(
83: 81:                 fg_color_inner
84: 82:                     .clone()
85: 83:                     .unwrap_or_else(|| "#000000".to_string()),
86: 84:             ))
87: 85:             .to_str(&qrcode);
88: 86: 
89: 87:         svg
90: 88:     };
91: 89: 
92: 90:     view! {
93: 91:         <div
94: 92:             inner_html=qr_svg
95: 93:         />
96: 94:     }
97: 95: }
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
116: 114: ```
117: 115: ```
118: 116: ```
119: 117: ```
120: ```
```

