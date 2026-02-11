### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\components\reference.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\components\reference.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos_node_ref::AnyNodeRef;
5: 3: use tailwind_fuse::tw_merge;
6: 4: 
7: 5: #[component]
8: 6: pub fn Reference(
9: 7:     #[prop(into, optional)] class: MaybeProp<String>,
10: 8:     #[prop(into, optional)] node_ref: AnyNodeRef,
11: 9: ) -> impl IntoView {
12: 10:     view! {
13: 11:         <button
14: 12:             node_ref=node_ref
15: 13:             class={move || {
16: 14:                 let class = class.get();
17: 15:                 tw_merge!(
18: 16:                     "z-50 h-24 w-24 cursor-default border-2 border-dashed border-gray-900 bg-gray-50 p-2 text-sm font-bold text-gray-900",
19: 17:                     class
20: 18:                 )
21: 19:             }}
22: 20:             aria-label="Reference element"
23: 21:         >
24: 22:             Reference
25: 23:         </button>
26: 24:     }
27: 25: }
28: ```
```
