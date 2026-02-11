### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\show.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\show.rs
2: ```rust
3: 1: use crate::{
4: 2:     children::{TypedChildrenFn, ViewFn},
5: 3:     IntoView,
6: 4: };
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::component;
8: 6: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{computed::ArcMemo, traits::Get};
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::either::Either;
10: 8: 
11: 9: #[component(transparent)]
12: 10: pub fn Show<W, C>(
13: 11:     /// The children will be shown whenever the condition in the `when` closure returns `true`.
14: 12:     children: TypedChildrenFn<C>,
15: 13:     /// A closure that returns a bool that determines whether this thing runs
16: 14:     when: W,
17: 15:     /// A closure that returns what gets rendered if the when statement is false. By default this is the empty view.
18: 16:     #[prop(optional, into)]
19: 17:     fallback: ViewFn,
20: 18: ) -> impl IntoView
21: 19: where
22: 20:     W: Fn() -> bool + Send + Sync + 'static,
23: 21:     C: IntoView + 'static,
24: 22: {
25: 23:     let memoized_when = ArcMemo::new(move |_| when());
26: 24:     let children = children.into_inner();
27: 25: 
28: 26:     move || match memoized_when.get() {
29: 27:         true => Either::Left(children()),
30: 28:         false => Either::Right(fallback.run()),
31: 29:     }
32: 30: }
33: ```
```
