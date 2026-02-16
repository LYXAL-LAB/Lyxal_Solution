1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
24: ```rust
25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
26: ```rust
27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
28: ```rust
29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
30: ```rust
31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\src\use_auto_update.rs
32: ```rust
33: use std::rc::Rc;
34: 
35: use lyx_ui_foundations_dom::{AutoUpdateOptions, auto_update};
36: use yew::prelude::*;
37: 
38: use crate::types::WhileElementsMountedFn;
39: 
40: /// Use [`auto_update`] with [`AutoUpdateOptions::default`].
41: ///
42: /// Can be passed to [`UseFloatingOptions::while_elements_mounted`][crate::types::UseFloatingOptions::while_elements_mounted].
43: #[hook]
44: pub fn use_auto_update() -> Rc<Rc<WhileElementsMountedFn>> {
45:     use_memo((), |_| {
46:         let rc: Rc<WhileElementsMountedFn> = Rc::new(|reference, floating, update| {
47:             auto_update(reference, floating, update, AutoUpdateOptions::default()).into()
48:         });
49: 
50:         rc
51:     })
52: }
53: 
54: /// Use [`auto_update`] with `options`.
55: ///
56: /// Can be passed to [`UseFloatingOptions::while_elements_mounted`][crate::types::UseFloatingOptions::while_elements_mounted].
57: #[hook]
58: pub fn use_auto_update_with_options(options: AutoUpdateOptions) -> Rc<Rc<WhileElementsMountedFn>> {
59:     use_memo(options, |options| {
60:         let options = options.clone();
61: 
62:         let rc: Rc<WhileElementsMountedFn> = Rc::new(move |reference, floating, update| {
63:             auto_update(reference, floating, update, options.clone()).into()
64:         });
65: 
66:         rc
67:     })
68: }
69: ```
70: ```
71: ```
72: ```
73: ```
74: ```
75: ```
76: ```
77: ```
78: ```
79: ```
80: ```
81: ```
82: ```
83: ```
84: ```
```

