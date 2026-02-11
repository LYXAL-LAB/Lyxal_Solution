### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\shift.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\positioning\shift.rs
2: ```rust
3: 1: use floating_ui_lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
4: 2:     Boundary, DetectOverflowOptions, MiddlewareVec, Offset, OffsetOptions, Padding,
5: 3:     PartialSideObject, Placement, RootBoundary, Shift, ShiftOptions,
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
17: 15: pub fn ShiftDemo() -> impl IntoView {
18: 16:     let boundary_ref = AnyNodeRef::new();
19: 17: 
20: 18:     Effect::new(move |_| {
21: 19:         if let Some(boundary) = boundary_ref.get() {
22: 20:             boundary
23: 21:                 .first_element_child()
24: 22:                 .expect("First element child should exist.")
25: 23:                 .set_scroll_top(rem_to_px(200.0 / 16.0) as i32);
26: 24:         }
27: 25:     });
28: 26: 
29: 27:     view! {
30: 28:         <GridItem
31: 29:             title="Shift"
32: 30:             description="Shifts your floating element to keep it in view."
33: 31:             chrome=move || view! {
34: 32:                 <div node_ref={boundary_ref} class="relative overflow-hidden">
35: 33:                     <Chrome
36: 34:                         label="Scroll the container"
37: 35:                         scrollable=Scrollable::Y
38: 36:                         relative=false
39: 37:                         shadow=false
40: 38:                     >
41: 39:                         <Floating
42: 40:                             placement=Placement::Right
43: 41:                             middleware=MaybeProp::derive(move || {
44: 42:                                 let mut detect_overflow_options =  DetectOverflowOptions::default()
45: 43:                                     .root_boundary(RootBoundary::Document)
46: 44:                                     .padding(Padding::PerSide(PartialSideObject {
47: 45:                                         top: Some(rem_to_px(54.0 / 16.0)),
48: 46:                                         right: None,
49: 47:                                         bottom: Some(rem_to_px(5.0 / 16.0)),
50: 48:                                         left: None
51: 49:                                     }));
52: 50: 
53: 51:                                 if let Some(boundary) = boundary_ref.get() {
54: 52:                                     detect_overflow_options = detect_overflow_options.boundary(Boundary::Element(boundary.clone()));
55: 53:                                 }
56: 54: 
57: 55:                                 let middleware: MiddlewareVec = vec![
58: 56:                                     Box::new(Offset::new(OffsetOptions::Value(5.0))),
59: 57:                                     Box::new(Shift::new(ShiftOptions::default().detect_overflow(detect_overflow_options))),
60: 58:                                 ];
61: 59: 
62: 60:                                 Some(SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new(middleware))
63: 61:                             })
64: 62:                             content=move || view! {
65: 63:                                 <div class="grid h-48 w-20 place-items-center text-sm font-bold">
66: 64:                                     Popover
67: 65:                                 </div>
68: 66:                             }
69: 67:                             reference=move |node_ref| view! {
70: 68:                                 <Reference node_ref=node_ref class="ml-[5%] sm:ml-[33%]" />
71: 69:                             }
72: 70:                         />
73: 71:                     </Chrome>
74: 72:                 </div>
75: 73:             }
76: 74:         />
77: 75:     }
78: 76: }
79: ```
```
