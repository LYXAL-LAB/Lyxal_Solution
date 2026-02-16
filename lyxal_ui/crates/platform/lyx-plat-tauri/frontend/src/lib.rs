1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_tauri\lyx-platform-lyx_platform_lyx-platform-lyx_platform_frontend\src\lib.rs
46: 44: ```rust
47: 45: cfg_if::cfg_if! {
48: 46: 	if #[cfg(feature = "hydrate")] {
49: 47: 		use lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App;
50: 48: 		use wasm_bindgen::prelude::wasm_bindgen;
51: 49: 
52: 50: 		#[wasm_bindgen]
53: 51: 		pub fn hydrate() {
54: 52: 				_ = console_log::init_with_level(log::Level::Debug);
55: 53: 			#[cfg(debug_assertions)]
56: 54: 			console_error_panic_hook::set_once();
57: 55: 			lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount_to_body(App);
58: 56: 		}
59: 57: 	}
60: 58: }
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
77: 75: ```
78: 76: ```
79: 77: ```
80: 78: ```
81: 79: ```
82: 80: ```
83: ```
```

