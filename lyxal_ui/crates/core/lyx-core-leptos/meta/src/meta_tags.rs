### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\meta\src\meta_tags.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\meta\src\meta_tags.rs
2: ```rust
3: 1: use crate::register;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
5: 3:     component,
6: 4:     prelude::{CustomAttribute, GlobalAttributes},
7: 5:     lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element::meta,
8: 6:     text_prop::TextProp,
9: 7:     IntoView,
10: 8: };
11: 9: 
12: 10: /// Injects an [`HTMLMetaElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMetaElement) into the document
13: 11: /// head to set metadata
14: 12: ///
15: 13: /// ```
16: 14: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
17: 15: /// use lyx-core-lyx_core_lyx-core-meta::*;
18: 16: ///
19: 17: /// #[component]
20: 18: /// fn MyApp() -> impl IntoView {
21: 19: ///   provide_meta_context();
22: 20: ///
23: 21: ///   view! {
24: 22: ///     <main>
25: 23: ///       <Meta charset="utf-8"/>
26: 24: ///       <Meta name="description" content="A Leptos fan site."/>
27: 25: ///       <Meta http_equiv="refresh" content="3;url=https://github.com/lyx-core-lyx_core_lyx-core-lyx_core_leptos-rs/lyx-core-lyx_core_lyx-core-lyx_core_leptos"/>
28: 26: ///     </main>
29: 27: ///   }
30: 28: /// }
31: 29: /// ```
32: 30: #[component]
33: 31: pub fn Meta(
34: 32:     /// The [`charset`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta#attr-charset) attribute.
35: 33:     #[prop(optional, into)]
36: 34:     charset: Option<TextProp>,
37: 35:     /// The [`name`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta#attr-name) attribute.
38: 36:     #[prop(optional, into)]
39: 37:     name: Option<TextProp>,
40: 38:     /// The [`property`](https://ogp.me/) attribute.
41: 39:     #[prop(optional, into)]
42: 40:     property: Option<TextProp>,
43: 41:     /// The [`http-equiv`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta#attr-http-equiv) attribute.
44: 42:     #[prop(optional, into)]
45: 43:     http_equiv: Option<TextProp>,
46: 44:     /// The [`itemprop`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta#attr-itemprop) attribute.
47: 45:     #[prop(optional, into)]
48: 46:     itemprop: Option<TextProp>,
49: 47:     /// The [`content`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta#attr-content) attribute.
50: 48:     #[prop(optional, into)]
51: 49:     content: Option<TextProp>,
52: 50: ) -> impl IntoView {
53: 51:     register(
54: 52:         meta()
55: 53:             .charset(charset.map(|v| move || v.get()))
56: 54:             .name(name.map(|v| move || v.get()))
57: 55:             .attr("property", property.map(|v| move || v.get()))
58: 56:             .http_equiv(http_equiv.map(|v| move || v.get()))
59: 57:             .itemprop(itemprop.map(|v| move || v.get()))
60: 58:             .content(content.map(|v| move || v.get())),
61: 59:     )
62: 60: }
63: ```
```
