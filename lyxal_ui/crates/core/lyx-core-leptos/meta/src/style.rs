### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\meta\src\style.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\meta\src\style.rs
2: ```rust
3: 1: use crate::{register, OrDefaultNonce};
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
5: 3:     component, oco::Oco, prelude::*, lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element::style, IntoView,
6: 4: };
7: 5: 
8: 6: /// Injects an [`HTMLStyleElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLStyleElement) into the document
9: 7: /// head, accepting any of the valid attributes for that tag.
10: 8: ///
11: 9: /// ```
12: 10: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
13: 11: /// use lyx-core-lyx_core_lyx-core-meta::*;
14: 12: ///
15: 13: /// #[component]
16: 14: /// fn MyApp() -> impl IntoView {
17: 15: ///     provide_meta_context();
18: 16: ///
19: 17: ///     view! {
20: 18: ///       <main>
21: 19: ///         <Style>
22: 20: ///           "body { font-weight: bold; }"
23: 21: ///         </Style>
24: 22: ///       </main>
25: 23: ///     }
26: 24: /// }
27: 25: /// ```
28: 26: #[component]
29: 27: pub fn Style(
30: 28:     /// An ID for the `<script>` tag.
31: 29:     #[prop(optional, into)]
32: 30:     id: Option<Oco<'static, str>>,
33: 31:     /// The [`media`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-media) attribute.
34: 32:     #[prop(optional, into)]
35: 33:     media: Option<Oco<'static, str>>,
36: 34:     /// The [`nonce`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-nonce) attribute.
37: 35:     #[prop(optional, into)]
38: 36:     nonce: Option<Oco<'static, str>>,
39: 37:     /// The [`title`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-title) attribute.
40: 38:     #[prop(optional, into)]
41: 39:     title: Option<Oco<'static, str>>,
42: 40:     /// The [`blocking`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/style#attr-blocking) attribute.
43: 41:     #[prop(optional, into)]
44: 42:     blocking: Option<Oco<'static, str>>,
45: 43:     /// The content of the `<style>` tag.
46: 44:     #[prop(optional)]
47: 45:     children: Option<Children>,
48: 46: ) -> impl IntoView {
49: 47:     register(
50: 48:         style()
51: 49:             .id(id)
52: 50:             .media(media)
53: 51:             .nonce(nonce.or_default_nonce())
54: 52:             .title(title)
55: 53:             .blocking(blocking)
56: 54:             .child(children.map(|c| c())),
57: 55:     )
58: 56: }
59: ```
```
