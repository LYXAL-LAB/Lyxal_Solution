1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-async-signal\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
26: 24: ```rust
27: 25: use futures::StreamExt;
28: 26: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
29: 27: use lyx-core-src::*;
30: 28: use lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr::init_test;
31: 29: 
32: 30: #[component]
33: 31: pub fn App() -> impl IntoView {
34: 32:     view! {
35: 33:         {
36: 34:             let (msg_res, msg_tx) = async_signal("default message".to_string());
37: 35:             view! {
38: 36:                 <Suspense>
39: 37:                     { move || {
40: 38:                         let msg = match msg_res.get() {
41: 39:                             None => "no msg yet".to_owned(),
42: 40:                             Some(msg) => format!("msg is: {msg}")
43: 41:                         };
44: 42:                         view! { <span id="msg">{msg}</span> }
45: 43:                     }
46: 44:                 }
47: 45:                 </Suspense>
48: 46:                 <Component msg_tx=msg_tx />
49: 47:             }
50: 48:         }
51: 49:     }
52: 50: }
53: 51: 
54: 52: #[component]
55: 53: fn Component(msg_tx: AsyncWriteSignal<String>) -> impl IntoView {
56: 54:     let data = Resource::new(
57: 55:         || (),
58: 56:         move |_| {
59: 57:             let msg_tx = msg_tx.clone();
60: 58:             async move {
61: 59:                 let (msg, num) = lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr::fetch_data().await;
62: 60:                 msg_tx.set(msg);
63: 61:                 num
64: 62:             }
65: 63:         },
66: 64:     );
67: 65:     view! {
68: 66:         <Suspense>
69: 67:             { move || {
70: 68:                     match data.get() {
71: 69:                         Some(num) => view! { <span>The number is: {num}</span> }.into_any(),
72: 70:                         None => view! { <span>No number</span> }.into_any(),
73: 71:                     }
74: 72:                 }
75: 73:             }
76: 74:         </Suspense>
77: 75:     }
78: 76: }
79: 77: 
80: 78: #[tokio::test]
81: 79: async fn render_async() {
82: 80:     init_test();
83: 81:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = view! { <App /> };
84: 82:     let html = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order().collect::<String>().await;
85: 83:     assert!(html.contains("msg is: Hello world"));
86: 84: }
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
99: ```
```

