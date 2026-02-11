### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_tachys\src\html\element\custom.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_tachys\src\html\element\custom.rs
18: 16: ```rust
19: 17: use super::ElementWithChildren;
20: 18: use crate::html::element::{ElementType, HtmlElement};
21: 19: use std::fmt::Debug;
22: 20: 
23: 21: /// Creates a custom element.
24: 22: #[track_caller]
25: 23: pub fn custom<E>(tag: E) -> HtmlElement<Custom<E>, (), ()>
26: 24: where
27: 25:     E: AsRef<str>,
28: 26: {
29: 27:     HtmlElement {
30: 28:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
31: 29:         defined_at: std::panic::Location::caller(),
32: 30:         tag: Custom(tag),
33: 31:         attributes: (),
34: 32:         children: (),
35: 33:     }
36: 34: }
37: 35: 
38: 36: /// A custom HTML element.
39: 37: #[derive(Debug, Copy, Clone, PartialEq, Eq)]
40: 38: pub struct Custom<E>(E);
41: 39: 
42: 40: impl<E: 'static> ElementType for Custom<E>
43: 41: where
44: 42:     E: AsRef<str> + Send,
45: 43: {
46: 44:     type Output = web_sys::HtmlElement;
47: 45: 
48: 46:     const SELF_CLOSING: bool = false;
49: 47:     const ESCAPE_CHILDREN: bool = true;
50: 48:     const TAG: &'static str = "";
51: 49:     const NAMESPACE: Option<&'static str> = None;
52: 50: 
53: 51:     fn tag(&self) -> &str {
54: 52:         self.0.as_ref()
55: 53:     }
56: 54: }
57: 55: 
58: 56: impl<E> ElementWithChildren for Custom<E> {}
59: 57: ```
60: 58: ```
61: 59: ```
62: 60: ```
63: 61: ```
64: 62: ```
65: 63: ```
66: 64: ```
67: ```
```
