### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\size.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\size.rs
2: ```rust
3: 1: use floating_ui_lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
4: 2:     DetectOverflowOptions, MiddlewareVec, Offset, OffsetOptions, Padding, RootBoundary, Size,
5: 3:     SizeOptions,
6: 4: };
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
8: 6: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
9: 7: 
10: 8: use crate::components::{Chrome, Floating, GridItem, Reference, Scrollable};
11: 9: 
12: 10: #[component]
13: 11: pub fn SizeDemo() -> impl IntoView {
14: 12:     view! {
15: 13:         <GridItem
16: 14:             title="Size"
17: 15:             description="Changes the size of your floating element to keep it in view."
18: 16:             chrome=move || view! {
19: 17:                 <Chrome
20: 18:                     label="Scroll the container"
21: 19:                     scrollable=Scrollable::Y
22: 20:                     center=true
23: 21:                     shadow=false
24: 22:                 >
25: 23:                     <Floating
26: 24:                         class="h-[300px] overflow-hidden max-h-0"
27: 25:                         middleware={
28: 26:                             let middleware: MiddlewareVec = vec![
29: 27:                                 Box::new(Offset::new(OffsetOptions::Value(5.0))),
30: 28:                                 Box::new(Size::new(SizeOptions::default().detect_overflow(
31: 29:                                     DetectOverflowOptions::default()
32: 30:                                         .root_boundary(RootBoundary::Document)
33: 31:                                         .padding(Padding::All(8.0))
34: 32:                                 ))),
35: 33:                             ];
36: 34: 
37: 35:                             SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(middleware)
38: 36:                         }
39: 37:                         content=move || view! {
40: 38:                             <div class="grid items-center text-sm font-bold">
41: 39:                                 Dropdown
42: 40:                             </div>
43: 41:                         }
44: 42:                         reference=move |node_ref| view! {
45: 43:                             <Reference node_ref=node_ref />
46: 44:                         }
47: 45:                     />
48: 46:                 </Chrome>
49: 47:             }
50: 48:         />
51: 49:     }
52: 50: }
53: ```
```
