### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_bevy3d_ui\src\routes\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_bevy3d_ui\src\routes\mod.rs
2: ```rust
3: 1: pub mod lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1;
4: 2: use lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo1::Demo1;
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
6: 4: use lyx-core-lyx_core_lyx-core-meta::Meta;
7: 5: use lyx-core-lyx_core_lyx-core-meta::Title;
8: 6: use lyx-core-lyx_core_lyx-core-meta::{provide_meta_context, MetaTags, Stylesheet};
9: 7: use lyx-core-lyx_core_lyx-core-router::components::*;
10: 8: use lyx-core-lyx_core_lyx-core-router::StaticSegment;
11: 9: #[component]
12: 10: pub fn RootPage() -> impl IntoView {
13: 11:     provide_meta_context();
14: 12: 
15: 13:     view! {
16: 14:         <Meta name="charset" content="UTF-8"/>
17: 15:         <Meta name="description" content="Leptonic CSR template"/>
18: 16:         <Meta name="viewport" content="width=device-width, initial-scale=1.0"/>
19: 17:         <Meta name="theme-color" content="#e66956"/>
20: 18:         <Title text="Leptos Bevy3D Example"/>
21: 19:         <Stylesheet href="https://fonts.googleapis.com/css?family=Roboto&display=swap"/>
22: 20:         <MetaTags/>
23: 21:         <Router>
24: 22:             <Routes fallback=move || "Not found.">
25: 23:                 <Route path=StaticSegment("") view=Demo1 />
26: 24:             </Routes>
27: 25:         </Router>
28: 26:     }
29: 27: }
30: ```
```
