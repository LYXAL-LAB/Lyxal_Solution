### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\components\grid_item.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\components\grid_item.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
4: 2: use tailwind_fuse::tw_merge;
5: 3: 
6: 4: #[component]
7: 5: pub fn GridItem<F, IV>(
8: 6:     #[prop(into)] title: Signal<String>,
9: 7:     #[prop(into)] description: Signal<String>,
10: 8:     chrome: F,
11: 9:     // #[prop(into)] lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo_link: Signal<String>,
12: 10:     #[prop(default = false.into(), into)] hidden: Signal<bool>,
13: 11: ) -> impl IntoView
14: 12: where
15: 13:     F: Fn() -> IV + 'static,
16: 14:     IV: IntoView + 'static,
17: 15: {
18: 16:     view! {
19: 17:         <div
20: 18:             class={move || tw_merge!(
21: 19:                 "relative flex-col justify-between overflow-x-hidden bg-gray-50 px-4 py-8 shadow dark:bg-gray-700 sm:p-8 md:rounded-lg lg:flex",
22: 20:                 hidden.get().then_some("hidden")
23: 21:             )}
24: 22:         >
25: 23:             <div class="overflow-hidden">
26: 24:                 <h3 class="mb-2 text-3xl font-bold">{title}</h3>
27: 25:                 <p class="mb-6 text-xl">{description}</p>
28: 26:             </div>
29: 27:             <div class="relative items-center rounded-lg bg-gray-800 shadow-md lg:h-auto">
30: 28:                 {chrome()}
31: 29:             </div>
32: 30:             // <a
33: 31:             //     class="absolute right-6 top-6 inline-flex items-center gap-1 border-none font-bold text-rose-600 underline decoration-rose-500/80 decoration-2 underline-offset-4 transition-colors hover:text-gray-1000 hover:decoration-gray-1000 dark:text-rose-300 dark:decoration-rose-300/80 dark:hover:text-gray-50 dark:hover:decoration-gray-50"
34: 32:             //     href=lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_demo_link
35: 33:             //     target="_blank"
36: 34:             //     rel="noopener noreferrer"
37: 35:             // >
38: 36:             //     CodeSandbox
39: 37:             // </a>
40: 38:         </div>
41: 39:     }
42: 40: }
43: ```
```
