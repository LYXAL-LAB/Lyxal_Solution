### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\dioxus\src\use_auto_update.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
32: ```rust
33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
34: ```rust
35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
36: ```rust
37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
38: ```rust
39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\dioxus\src\use_auto_update.rs
40: ```rust
41: use std::rc::Rc;
42: 
43: use dioxus::prelude::*;
44: use lyx_ui_foundations_dom::{AutoUpdateOptions, auto_update};
45: 
46: use crate::{ShallowRc, types::WhileElementsMountedFn};
47: 
48: /// Use [`auto_update`] with [`AutoUpdateOptions::default`].
49: ///
50: /// Can be passed to [`UseFloatingOptions::while_elements_mounted`][crate::types::UseFloatingOptions::while_elements_mounted].
51: pub fn use_auto_update() -> Memo<ShallowRc<WhileElementsMountedFn>> {
52:     use_memo(|| {
53:         let rc: Rc<WhileElementsMountedFn> = Rc::new(|reference, floating, update| {
54:             auto_update(reference, floating, update, AutoUpdateOptions::default())
55:         });
56: 
57:         rc.into()
58:     })
59: }
60: 
61: /// Use [`auto_update`] with `options`.
62: ///
63: /// Can be passed to [`UseFloatingOptions::while_elements_mounted`][crate::types::UseFloatingOptions::while_elements_mounted].
64: pub fn use_auto_update_with_options(
65:     options: ReadSignal<AutoUpdateOptions>,
66: ) -> Memo<ShallowRc<WhileElementsMountedFn>> {
67:     use_memo(move || {
68:         let options = options();
69: 
70:         let rc: Rc<WhileElementsMountedFn> = Rc::new(move |reference, floating, update| {
71:             auto_update(reference, floating, update, options.clone())
72:         });
73: 
74:         rc.into()
75:     })
76: }
77: ```
78: ```
79: ```
80: ```
81: ```
82: ```
83: ```
84: ```
85: ```
86: ```
87: ```
88: ```
89: ```
90: ```
91: ```
92: ```
93: ```
94: ```
95: ```
96: ```
```
