1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-async-signal\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\missing.rs
26: 24: ```rust
27: 25: use futures::StreamExt;
28: 26: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
29: 27: use lyx-core-src::*;
30: 28: use lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr::init_test;
31: 29: 
32: 30: #[component]
33: 31: fn App() -> impl IntoView {
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
59: 57:             let _msg_tx = msg_tx.clone();
60: 58:             async move {
61: 59:                 let (_msg, num) = lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr::fetch_data().await;
62: 60:                 // NOTE: We forget to set the value:
63: 61:                 //  msg_tx.set(msg);
64: 62:                 num
65: 63:             }
66: 64:         },
67: 65:     );
68: 66:     view! {
69: 67:         <Suspense>
70: 68:             { move || {
71: 69:                     match data.get() {
72: 70:                         Some(num) => view! { <span>The number is: {num}</span> }.into_any(),
73: 71:                         None => view! { <span>No number</span> }.into_any(),
74: 72:                     }
75: 73:                 }
76: 74:             }
77: 75:         </Suspense>
78: 76:     }
79: 77: }
80: 78: 
81: 79: #[tokio::test]
82: 80: async fn render_async() {
83: 81:     init_test();
84: 82: 
85: 83:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = view! { <App /> };
86: 84:     let html = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order().collect::<String>().await;
87: 85:     println!("{html}");
88: 86:     assert!(html.contains("msg is: default message"));
89: 87: }
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
101: 99: ```
102: ```
```

