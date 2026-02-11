### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-workers\src\components\show_data_from_api.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-workers\src\components\show_data_from_api.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
46: 44: ```rust
47: 45: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
48: 46: 
49: 47: use crate::api::say_hello::say_hello;
50: 48: 
51: 49: #[component]
52: 50: pub fn ShowDataFromApi() -> impl IntoView {
53: 51:     let value = create_rw_signal("".to_string());
54: 52:     let counter = create_rw_signal(0);
55: 53: 
56: 54:     let on_click = move |_| {
57: 55:         spawn_local(async move {
58: 56:             let api_said = say_hello(counter.get()).await.unwrap();
59: 57:             value.set(api_said);
60: 58:             counter.update(|v| *v += 1);
61: 59:         });
62: 60:     };
63: 61: 
64: 62:     view! {
65: 63:         <div>
66: 64:             <button on:click=on_click>"What does the API say?"</button>
67: 65:             <p>{value}</p>
68: 66:         </div>
69: 67:     }
70: 68: }
71: 69: ```
72: 70: ```
73: 71: ```
74: 72: ```
75: 73: ```
76: 74: ```
77: 75: ```
78: 76: ```
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
93: ```
```
