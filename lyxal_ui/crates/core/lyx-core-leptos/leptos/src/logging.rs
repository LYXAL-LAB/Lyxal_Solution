### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\logging.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\logging.rs
2: ```rust
3: 1: //! Utilities for simple isomorphic logging to the console or terminal.
4: 2: 
5: 3: use wasm_bindgen::JsValue;
6: 4: 
7: 5: /// Uses `println!()`-style formatting to log something to the console (in the browser)
8: 6: /// or via `println!()` (if not in the browser).
9: 7: #[macro_export]
10: 8: macro_rules! log {
11: 9:     ($($t:tt)*) => ($crate::logging::console_log(&format_args!($($t)*).to_string()))
12: 10: }
13: 11: 
14: 12: /// Uses `println!()`-style formatting to log warnings to the console (in the browser)
15: 13: /// or via `eprintln!()` (if not in the browser).
16: 14: #[macro_export]
17: 15: macro_rules! warn {
18: 16:     ($($t:tt)*) => ($crate::logging::console_warn(&format_args!($($t)*).to_string()))
19: 17: }
20: 18: 
21: 19: /// Uses `println!()`-style formatting to log errors to the console (in the browser)
22: 20: /// or via `eprintln!()` (if not in the browser).
23: 21: #[macro_export]
24: 22: macro_rules! error {
25: 23:     ($($t:tt)*) => ($crate::logging::console_error(&format_args!($($t)*).to_string()))
26: 24: }
27: 25: 
28: 26: /// Uses `println!()`-style formatting to log warnings to the console (in the browser)
29: 27: /// or via `eprintln!()` (if not in the browser), but only if it's a debug build.
30: 28: #[macro_export]
31: 29: macro_rules! debug_warn {
32: 30:     ($($x:tt)*) => {
33: 31:         {
34: 32:             #[cfg(debug_assertions)]
35: 33:             {
36: 34:                 $crate::warn!($($x)*)
37: 35:             }
38: 36:             #[cfg(not(debug_assertions))]
39: 37:             {
40: 38:                 ($($x)*)
41: 39:             }
42: 40:         }
43: 41:     }
44: 42: }
45: 43: 
46: 44: const fn log_to_stdout() -> bool {
47: 45:     cfg!(not(all(
48: 46:         target_arch = "wasm32",
49: 47:         not(any(target_os = "emscripten", target_os = "wasi"))
50: 48:     )))
51: 49: }
52: 50: 
53: 51: /// Log a string to the console (in the browser)
54: 52: /// or via `println!()` (if not in the browser).
55: 53: pub fn console_log(s: &str) {
56: 54:     #[allow(clippy::print_stdout)]
57: 55:     if log_to_stdout() {
58: 56:         println!("{s}");
59: 57:     } else {
60: 58:         web_sys::console::log_1(&JsValue::from_str(s));
61: 59:     }
62: 60: }
63: 61: 
64: 62: /// Log a warning to the console (in the browser)
65: 63: /// or via `println!()` (if not in the browser).
66: 64: pub fn console_warn(s: &str) {
67: 65:     if log_to_stdout() {
68: 66:         eprintln!("{s}");
69: 67:     } else {
70: 68:         web_sys::console::warn_1(&JsValue::from_str(s));
71: 69:     }
72: 70: }
73: 71: 
74: 72: /// Log an error to the console (in the browser)
75: 73: /// or via `println!()` (if not in the browser).
76: 74: #[inline(always)]
77: 75: pub fn console_error(s: &str) {
78: 76:     if log_to_stdout() {
79: 77:         eprintln!("{s}");
80: 78:     } else {
81: 79:         web_sys::console::error_1(&JsValue::from_str(s));
82: 80:     }
83: 81: }
84: 82: 
85: 83: /// Log an error to the console (in the browser)
86: 84: /// or via `println!()` (if not in the browser), but only in a debug build.
87: 85: #[inline(always)]
88: 86: pub fn console_debug_warn(s: &str) {
89: 87:     #[cfg(debug_assertions)]
90: 88:     {
91: 89:         if log_to_stdout() {
92: 90:             eprintln!("{s}");
93: 91:         } else {
94: 92:             web_sys::console::warn_1(&JsValue::from_str(s));
95: 93:         }
96: 94:     }
97: 95: 
98: 96:     #[cfg(not(debug_assertions))]
99: 97:     {
100: 98:         let _ = s;
101: 99:     }
102: 100: }
103: 101: 
104: 102: 
105: ```
```
