### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\await_.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\await_.rs
2: ```rust
3: 1: use crate::{prelude::Suspend, suspense_component::Suspense, IntoView};
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::{component, view};
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server::ArcOnceResource;
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::ReadUntracked;
7: 5: use serde::{de::DeserializeOwned, Serialize};
8: 6: 
9: 7: #[component]
10: 8: /// Allows you to inline the data loading for an `async` block or
11: 9: /// lyx-platform-lyx_platform_lyx-platform-lyx_platform_server function directly into your view. This is the equivalent of combining a
12: 10: /// [`create_resource`] that only loads once (i.e., with a source signal `|| ()`) with
13: 11: /// a [`Suspense`] with no `fallback`.
14: 12: ///
15: 13: /// Adding `let:{variable name}` to the props makes the data available in the children
16: 14: /// that variable name, when resolved.
17: 15: /// ```
18: 16: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
19: 17: /// # if false {
20: 18: /// async fn fetch_monkeys(monkey: i32) -> i32 {
21: 19: ///     // do some expensive work
22: 20: ///     3
23: 21: /// }
24: 22: ///
25: 23: /// view! {
26: 24: ///     <Await
27: 25: ///         future=fetch_monkeys(3)
28: 26: ///         let:data
29: 27: ///     >
30: 28: ///         <p>{*data} " little monkeys, jumping on the bed."</p>
31: 29: ///     </Await>
32: 30: /// }
33: 31: /// # ;
34: 32: /// # }
35: 33: /// ```
36: 34: pub fn Await<T, Fut, Chil, V>(
37: 35:     /// A [`Future`](std::future::Future) that will the component will `.await`
38: 36:     /// before rendering.
39: 37:     future: Fut,
40: 38:     /// If `true`, the component will create a blocking resource, preventing
41: 39:     /// the HTML stream from returning anything before `future` has resolved.
42: 40:     #[prop(optional)]
43: 41:     blocking: bool,
44: 42:     /// A function that takes a reference to the resolved data from the `future`
45: 43:     /// renders a view.
46: 44:     ///
47: 45:     /// ## Syntax
48: 46:     /// This can be passed in the `view` children of the `<Await/>` by using the
49: 47:     /// `let:` syntax to specify the name for the data variable.
50: 48:     ///
51: 49:     /// ```rust
52: 50:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
53: 51:     /// # if false {
54: 52:     /// # async fn fetch_monkeys(monkey: i32) -> i32 {
55: 53:     /// #    3
56: 54:     /// # }
57: 55:     /// view! {
58: 56:     ///     <Await
59: 57:     ///         future=fetch_monkeys(3)
60: 58:     ///         let:data
61: 59:     ///     >
62: 60:     ///         <p>{*data} " little monkeys, jumping on the bed."</p>
63: 61:     ///     </Await>
64: 62:     /// }
65: 63:     /// # ;
66: 64:     /// # }
67: 65:     /// ```
68: 66:     /// is the same as
69: 67:     ///  ```rust
70: 68:     /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
71: 69:     /// # if false {
72: 70:     /// # async fn fetch_monkeys(monkey: i32) -> i32 {
73: 71:     /// #    3
74: 72:     /// # }
75: 73:     /// view! {
76: 74:     ///     <Await
77: 75:     ///         future=fetch_monkeys(3)
78: 76:     ///         children=|data| view! {
79: 77:     ///           <p>{*data} " little monkeys, jumping on the bed."</p>
80: 78:     ///         }
81: 79:     ///     />
82: 80:     /// }
83: 81:     /// # ;
84: 82:     /// # }
85: 83:     /// ```
86: 84:     children: Chil,
87: 85: ) -> impl IntoView
88: 86: where
89: 87:     T: Send + Sync + Serialize + DeserializeOwned + 'static,
90: 88:     Fut: std::future::Future<Output = T> + Send + 'static,
91: 89:     Chil: FnOnce(&T) -> V + Send + 'static,
92: 90:     V: IntoView + 'static,
93: 91: {
94: 92:     let res = ArcOnceResource::<T>::new_with_options(future, blocking);
95: 93:     let ready = res.ready();
96: 94: 
97: 95:     view! {
98: 96:         <Suspense fallback=|| ()>
99: 97:             {Suspend::new(async move {
100: 98:                 ready.await;
101: 99:                 children(res.read_untracked().as_ref().unwrap())
102: 100:             })}
103: 101: 
104: 102:         </Suspense>
105: 103:     }
106: 104: }
107: ```
```
