### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\flip.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\flip.rs
2: ```rust
3: 1: use floating_ui_lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
4: 2:     DetectOverflowOptions, Flip, FlipOptions, MiddlewareVec, Offset, OffsetOptions, Placement,
5: 3:     RootBoundary,
6: 4: };
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_leptos_node_ref::AnyNodeRef;
9: 7: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
10: 8: 
11: 9: use crate::{
12: 10:     components::{Chrome, Floating, GridItem, Reference, Scrollable},
13: 11:     utils::rem_to_px,
14: 12: };
15: 13: 
16: 14: #[component]
17: 15: pub fn FlipDemo() -> impl IntoView {
18: 16:     let boundary_ref = AnyNodeRef::new();
19: 17: 
20: 18:     Effect::new(move |_| {
21: 19:         if let Some(boundary) = boundary_ref.get() {
22: 20:             boundary
23: 21:                 .first_element_child()
24: 22:                 .expect("First element child should exist.")
25: 23:                 .set_scroll_top(rem_to_px(275.0 / 16.0) as i32);
26: 24:         }
27: 25:     });
28: 26: 
29: 27:     view! {
30: 28:         <GridItem
31: 29:             title="Flip"
32: 30:             description="Changes the placement of your floating element to keep it in view."
33: 31:             chrome=move || view! {
34: 32:                 <div node_ref={boundary_ref} class="relative overflow-hidden">
35: 33:                     <Chrome
36: 34:                         label="Scroll down"
37: 35:                         scrollable=Scrollable::Y
38: 36:                         center=true
39: 37:                         shadow=false
40: 38:                     >
41: 39:                         <Floating
42: 40:                             placement=Placement::Top
43: 41:                             middleware={
44: 42:                                 let middleware: MiddlewareVec = vec![
45: 43:                                     Box::new(Offset::new(OffsetOptions::Value(5.0))),
46: 44:                                     Box::new(Flip::new(FlipOptions::default().detect_overflow(
47: 45:                                         DetectOverflowOptions::default().root_boundary(RootBoundary::Document)
48: 46:                                     ))),
49: 47:                                 ];
50: 48: 
51: 49:                                 SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(middleware)
52: 50:                             }
53: 51:                             content=move || view! {
54: 52:                                 <span class="text-sm font-bold">
55: 53:                                     Tooltip
56: 54:                                 </span>
57: 55:                             }
58: 56:                             reference=move |node_ref| view! {
59: 57:                                 <Reference node_ref=node_ref />
60: 58:                             }
61: 59:                         />
62: 60:                     </Chrome>
63: 61:                 </div>
64: 62:             }
65: 63:         />
66: 64:     }
67: 65: }
68: ```
```
