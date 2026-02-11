### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\meta\src\script.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\meta\src\script.rs
2: ```rust
3: 1: use crate::{register, OrDefaultNonce};
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
5: 3:     component, oco::Oco, prelude::*, lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element::script, IntoView,
6: 4: };
7: 5: 
8: 6: /// Injects an [`HTMLScriptElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLScriptElement) into the document
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
21: 19: ///         <Script>
22: 20: ///           "console.log('Hello, world!');"
23: 21: ///         </Script>
24: 22: ///       </main>
25: 23: ///     }
26: 24: /// }
27: 25: /// ```
28: 26: #[component]
29: 27: pub fn Script(
30: 28:     /// An ID for the `<script>` tag.
31: 29:     #[prop(optional, into)]
32: 30:     id: Option<Oco<'static, str>>,
33: 31:     /// The [`async`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-async) attribute.
34: 32:     #[prop(optional, into)]
35: 33:     async_: Option<Oco<'static, str>>,
36: 34:     /// The [`crossorigin`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-crossorigin) attribute.
37: 35:     #[prop(optional, into)]
38: 36:     crossorigin: Option<Oco<'static, str>>,
39: 37:     /// The [`defer`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-defer) attribute.
40: 38:     #[prop(optional, into)]
41: 39:     defer: Option<Oco<'static, str>>,
42: 40:     /// The [`fetchpriority `](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-fetchpriority ) attribute.
43: 41:     #[prop(optional, into)]
44: 42:     fetchpriority: Option<Oco<'static, str>>,
45: 43:     /// The [`integrity`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-integrity) attribute.
46: 44:     #[prop(optional, into)]
47: 45:     integrity: Option<Oco<'static, str>>,
48: 46:     /// The [`nomodule`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-nomodule) attribute.
49: 47:     #[prop(optional, into)]
50: 48:     nomodule: Option<Oco<'static, str>>,
51: 49:     /// The [`nonce`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-nonce) attribute.
52: 50:     #[prop(optional, into)]
53: 51:     nonce: Option<Oco<'static, str>>,
54: 52:     /// The [`referrerpolicy`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-referrerpolicy) attribute.
55: 53:     #[prop(optional, into)]
56: 54:     referrerpolicy: Option<Oco<'static, str>>,
57: 55:     /// The [`src`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-src) attribute.
58: 56:     #[prop(optional, into)]
59: 57:     src: Option<Oco<'static, str>>,
60: 58:     /// The [`type`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-type) attribute.
61: 59:     #[prop(optional, into)]
62: 60:     type_: Option<Oco<'static, str>>,
63: 61:     /// The [`blocking`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/script#attr-blocking) attribute.
64: 62:     #[prop(optional, into)]
65: 63:     blocking: Option<Oco<'static, str>>,
66: 64:     /// The content of the `<script>` tag.
67: 65:     #[prop(optional)]
68: 66:     children: Option<Children>,
69: 67: ) -> impl IntoView {
70: 68:     register(
71: 69:         script()
72: 70:             .id(id)
73: 71:             .r#async(async_)
74: 72:             .crossorigin(crossorigin)
75: 73:             .defer(defer)
76: 74:             .fetchpriority(fetchpriority)
77: 75:             .integrity(integrity)
78: 76:             .nomodule(nomodule)
79: 77:             .nonce(nonce.or_default_nonce())
80: 78:             .referrerpolicy(referrerpolicy)
81: 79:             .src(src)
82: 80:             .r#type(type_)
83: 81:             .blocking(blocking)
84: 82:             .child(children.map(|c| c())),
85: 83:     )
86: 84: }
87: ```
```
