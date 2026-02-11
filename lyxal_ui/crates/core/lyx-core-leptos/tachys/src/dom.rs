### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\dom.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\dom.rs
22: 20: ```rust
23: 21: use wasm_bindgen::JsCast;
24: 22: use web_sys::{Document, HtmlElement, Window};
25: 23: 
26: 24: thread_local! {
27: 25:     pub(crate) static WINDOW: web_sys::Window = web_sys::window().unwrap();
28: 26: 
29: 27:     pub(crate) static DOCUMENT: web_sys::Document = web_sys::window().unwrap().document().unwrap();
30: 28: }
31: 29: 
32: 30: /// Returns the [`Window`](https://developer.mozilla.org/en-US/docs/Web/API/Window).
33: 31: ///
34: 32: /// This is cached as a thread-local variable, so calling `window()` multiple times
35: 33: /// requires only one call out to JavaScript.
36: 34: pub fn window() -> Window {
37: 35:     WINDOW.with(Clone::clone)
38: 36: }
39: 37: 
40: 38: /// Returns the [`Document`](https://developer.mozilla.org/en-US/docs/Web/API/Document).
41: 39: ///
42: 40: /// This is cached as a thread-local variable, so calling `document()` multiple times
43: 41: /// requires only one call out to JavaScript.
44: 42: ///
45: 43: /// ## Panics
46: 44: /// Panics if called outside a browser environment.
47: 45: pub fn document() -> Document {
48: 46:     DOCUMENT.with(Clone::clone)
49: 47: }
50: 48: 
51: 49: /// The `<body>` element.
52: 50: ///
53: 51: /// ## Panics
54: 52: /// Panics if there is no `<body>` in the current document, or if it is called outside a browser
55: 53: /// environment.
56: 54: pub fn body() -> HtmlElement {
57: 55:     document().body().unwrap()
58: 56: }
59: 57: 
60: 58: /// Helper function to extract [`Event.target`](https://developer.mozilla.org/en-US/docs/Web/API/Event/target)
61: 59: /// from any event.
62: 60: pub fn event_target<T>(event: &web_sys::Event) -> T
63: 61: where
64: 62:     T: JsCast,
65: 63: {
66: 64:     event.target().unwrap().unchecked_into::<T>()
67: 65: }
68: 66: 
69: 67: /// Helper function to extract `event.target.value` from an event.
70: 68: ///
71: 69: /// This is useful in the `on:input` or `on:change` listeners for an `<input>` element.
72: 70: pub fn event_target_value<T>(event: &T) -> String
73: 71: where
74: 72:     T: JsCast,
75: 73: {
76: 74:     event
77: 75:         .unchecked_ref::<web_sys::Event>()
78: 76:         .target()
79: 77:         .unwrap()
80: 78:         .unchecked_into::<web_sys::HtmlInputElement>()
81: 79:         .value()
82: 80: }
83: 81: 
84: 82: /// Helper function to extract `event.target.checked` from an event.
85: 83: ///
86: 84: /// This is useful in the `on:change` listeners for an `<input type="checkbox">` element.
87: 85: pub fn event_target_checked(ev: &web_sys::Event) -> bool {
88: 86:     ev.target()
89: 87:         .unwrap()
90: 88:         .unchecked_into::<web_sys::HtmlInputElement>()
91: 89:         .checked()
92: 90: }
93: 91: ```
94: 92: ```
95: 93: ```
96: 94: ```
97: 95: ```
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: ```
```
