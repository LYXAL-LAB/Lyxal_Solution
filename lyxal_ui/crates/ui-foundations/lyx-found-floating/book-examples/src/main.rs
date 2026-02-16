1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\main.rs
2: ```rust
3: 1: mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;
4: 2: mod components;
5: 3: mod positioning;
6: 4: mod utils;
7: 5: 
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
9: 7: 
10: 8: use crate::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::App;
11: 9: 
12: 10: pub fn main() {
13: 11:     _ = console_log::init_with_level(log::Level::Debug);
14: 12:     console_error_panic_hook::set_once();
15: 13: 
16: 14:     mount_to_body(App);
17: 15: }
18: ```
```

