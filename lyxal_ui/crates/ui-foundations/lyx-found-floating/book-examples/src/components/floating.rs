### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\components\floating.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\components\floating.rs
2: ```rust
3: 1: use floating_ui_lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
4: 2:     MiddlewareVec, Placement, Strategy, UseFloatingOptions, UseFloatingReturn, use_floating,
5: 3: };
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_leptos_node_ref::AnyNodeRef;
8: 6: use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
9: 7: use tailwind_fuse::tw_merge;
10: 8: 
11: 9: #[component]
12: 10: pub fn Floating<CF, CIV, RF, RIV>(
13: 11:     #[prop(into, optional)] class: MaybeProp<String>,
14: 12:     #[prop(into, optional)] strategy: MaybeProp<Strategy>,
15: 13:     #[prop(into, optional)] placement: MaybeProp<Placement>,
16: 14:     #[prop(into, optional)] middleware: MaybeProp<SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper<MiddlewareVec>>,
17: 15:     #[prop(default = false.into(), into)] arrow: Signal<bool>,
18: 16:     content: CF,
19: 17:     reference: RF,
20: 18: ) -> impl IntoView
21: 19: where
22: 20:     CF: Fn() -> CIV + 'static,
23: 21:     CIV: IntoView + 'static,
24: 22:     RF: Fn(AnyNodeRef) -> RIV + 'static,
25: 23:     RIV: IntoView + 'static,
26: 24: {
27: 25:     let floating_ref = AnyNodeRef::new();
28: 26:     let reference_ref = AnyNodeRef::new();
29: 27:     let arrow_ref = AnyNodeRef::new();
30: 28: 
31: 29:     let UseFloatingReturn {
32: 30:         floating_styles, ..
33: 31:     } = use_floating(
34: 32:         reference_ref,
35: 33:         floating_ref,
36: 34:         UseFloatingOptions::default()
37: 35:             .while_elements_mounted_auto_update()
38: 36:             .placement(placement)
39: 37:             .strategy(strategy)
40: 38:             .middleware(middleware),
41: 39:     );
42: 40: 
43: 41:     view! {
44: 42:         {reference(reference_ref)}
45: 43: 
46: 44:         <div
47: 45:             node_ref=floating_ref
48: 46:             class=move || {
49: 47:                 let class = class.get();
50: 48: 
51: 49:                 tw_merge!(
52: 50:                     "z-10 grid place-items-center bg-rose-500 text-base font-semibold text-gray-50",
53: 51:                     class
54: 52:                 )
55: 53:             }
56: 54:             // TODO: style
57: 55:             style:position=move || floating_styles.get().style_position()
58: 56:             style:top=move || floating_styles.get().style_top()
59: 57:             style:left=move || floating_styles.get().style_left()
60: 58:             style:transform=move || floating_styles.get().style_transform().unwrap_or_default()
61: 59:             style:will-change=move || floating_styles.get().style_will_change().unwrap_or_default()
62: 60:         >
63: 61:             <div class="px-2 py-2">{content()}</div>
64: 62:             <Show when=move || arrow.get()>
65: 63:                 <div
66: 64:                     node_ref=arrow_ref
67: 65:                     class="h-4 w-4 bg-gray-800 [left:-0.5rem]"
68: 66:                     // TODO: style
69: 67:                 />
70: 68:             </Show>
71: 69:         </div>
72: 70:     }
73: 71: }
74: ```
```
