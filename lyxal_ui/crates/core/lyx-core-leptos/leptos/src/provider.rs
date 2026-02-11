### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\provider.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\provider.rs
2: ```rust
3: 1: use crate::{children::TypedChildren, component, IntoView};
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::{provide_context, Owner};
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::OwnedView;
6: 4: 
7: 5: #[component]
8: 6: /// Uses the context API to [`provide_context`] to its children and descendants,
9: 7: /// without overwriting any contexts of the same type in its own reactive scope.
10: 8: ///
11: 9: /// This prevents issues related to “context shadowing.”
12: 10: ///
13: 11: /// ```rust
14: 12: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{context::Provider, prelude::*};
15: 13: ///
16: 14: /// #[component]
17: 15: /// pub fn App() -> impl IntoView {
18: 16: ///     // each Provider will only provide the value to its children
19: 17: ///     view! {
20: 18: ///         <Provider value=1u8>
21: 19: ///             // correctly gets 1 from context
22: 20: ///             {use_context::<u8>().unwrap_or(0)}
23: 21: ///         </Provider>
24: 22: ///         <Provider value=2u8>
25: 23: ///             // correctly gets 2 from context
26: 24: ///             {use_context::<u8>().unwrap_or(0)}
27: 25: ///         </Provider>
28: 26: ///         // does not find any u8 in context
29: 27: ///         {use_context::<u8>().unwrap_or(0)}
30: 28: ///     }
31: 29: /// }
32: 30: /// ```
33: 31: pub fn Provider<T, Chil>(
34: 32:     /// The value to be provided via context.
35: 33:     value: T,
36: 34:     children: TypedChildren<Chil>,
37: 35: ) -> impl IntoView
38: 36: where
39: 37:     T: Send + Sync + 'static,
40: 38:     Chil: IntoView + 'static,
41: 39: {
42: 40:     let owner = Owner::current()
43: 41:         .expect("no current reactive Owner found")
44: 42:         .child();
45: 43:     let children = children.into_inner();
46: 44:     let children = owner.with(|| {
47: 45:         provide_context(value);
48: 46:         children()
49: 47:     });
50: 48:     OwnedView::new_with_owner(children, owner)
51: 49: }
52: ```
```
