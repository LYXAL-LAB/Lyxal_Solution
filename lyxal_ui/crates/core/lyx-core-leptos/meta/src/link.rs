### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\meta\src\link.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\meta\src\link.rs
2: ```rust
3: 1: use crate::register;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
5: 3:     component, oco::Oco, prelude::GlobalAttributes,
6: 4:     lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element::link, IntoView,
7: 5: };
8: 6: 
9: 7: /// Injects an [`HTMLLinkElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLinkElement) into the document
10: 8: /// head, accepting any of the valid attributes for that tag.
11: 9: ///
12: 10: /// ```
13: 11: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
14: 12: /// use lyx-core-lyx_core_lyx-core-meta::*;
15: 13: ///
16: 14: /// #[component]
17: 15: /// fn MyApp() -> impl IntoView {
18: 16: ///     provide_meta_context();
19: 17: ///
20: 18: ///     view! {
21: 19: ///       <main>
22: 20: ///         <Link rel="preload"
23: 21: ///           href="myFont.woff2"
24: 22: ///           as_="font"
25: 23: ///           type_="font/woff2"
26: 24: ///           crossorigin="anonymous"
27: 25: ///         />
28: 26: ///       </main>
29: 27: ///     }
30: 28: /// }
31: 29: /// ```
32: 30: #[component]
33: 31: pub fn Link(
34: 32:     /// The [`id`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-id) attribute.
35: 33:     #[prop(optional, into)]
36: 34:     id: Option<Oco<'static, str>>,
37: 35:     /// The [`as`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-as) attribute.
38: 36:     #[prop(optional, into)]
39: 37:     as_: Option<Oco<'static, str>>,
40: 38:     /// The [`crossorigin`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-crossorigin) attribute.
41: 39:     #[prop(optional, into)]
42: 40:     crossorigin: Option<Oco<'static, str>>,
43: 41:     /// The [`fetchpriority`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-fetchpriority) attribute.
44: 42:     #[prop(optional, into)]
45: 43:     fetchpriority: Option<Oco<'static, str>>,
46: 44:     /// The [`href`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-href) attribute.
47: 45:     #[prop(optional, into)]
48: 46:     href: Option<Oco<'static, str>>,
49: 47:     /// The [`hreflang`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-hreflang) attribute.
50: 48:     #[prop(optional, into)]
51: 49:     hreflang: Option<Oco<'static, str>>,
52: 50:     /// The [`imagesizes`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-imagesizes) attribute.
53: 51:     #[prop(optional, into)]
54: 52:     imagesizes: Option<Oco<'static, str>>,
55: 53:     /// The [`imagesrcset`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-imagesrcset) attribute.
56: 54:     #[prop(optional, into)]
57: 55:     imagesrcset: Option<Oco<'static, str>>,
58: 56:     /// The [`integrity`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-integrity) attribute.
59: 57:     #[prop(optional, into)]
60: 58:     integrity: Option<Oco<'static, str>>,
61: 59:     /// The [`media`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-media) attribute.
62: 60:     #[prop(optional, into)]
63: 61:     media: Option<Oco<'static, str>>,
64: 62:     /// The [`referrerpolicy`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-referrerpolicy) attribute.
65: 63:     #[prop(optional, into)]
66: 64:     referrerpolicy: Option<Oco<'static, str>>,
67: 65:     /// The [`rel`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-rel) attribute.
68: 66:     #[prop(optional, into)]
69: 67:     rel: Option<Oco<'static, str>>,
70: 68:     /// The [`sizes`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-sizes) attribute.
71: 69:     #[prop(optional, into)]
72: 70:     sizes: Option<Oco<'static, str>>,
73: 71:     /// The [`title`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-title) attribute.
74: 72:     #[prop(optional, into)]
75: 73:     title: Option<Oco<'static, str>>,
76: 74:     /// The [`type`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-type) attribute.
77: 75:     #[prop(optional, into)]
78: 76:     type_: Option<Oco<'static, str>>,
79: 77:     /// The [`blocking`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link#attr-blocking) attribute.
80: 78:     #[prop(optional, into)]
81: 79:     blocking: Option<Oco<'static, str>>,
82: 80: ) -> impl IntoView {
83: 81:     // TODO additional attributes
84: 82:     register(
85: 83:         link()
86: 84:             .id(id)
87: 85:             .r#as(as_)
88: 86:             .crossorigin(crossorigin)
89: 87:             .fetchpriority(fetchpriority)
90: 88:             .href(href)
91: 89:             .hreflang(hreflang)
92: 90:             .imagesizes(imagesizes)
93: 91:             .imagesrcset(imagesrcset)
94: 92:             .integrity(integrity)
95: 93:             .media(media)
96: 94:             .referrerpolicy(referrerpolicy)
97: 95:             .rel(rel)
98: 96:             .sizes(sizes)
99: 97:             .title(title)
100: 98:             .r#type(type_)
101: 99:             .blocking(blocking),
102: 100:     )
103: 101: }
104: ```
```
