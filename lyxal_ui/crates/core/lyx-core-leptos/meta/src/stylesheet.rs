### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\meta\src\stylesheet.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\meta\src\stylesheet.rs
2: ```rust
3: 1: use crate::register;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
5: 3:     attr::global::GlobalAttributes, component, prelude::LeptosOptions,
6: 4:     lyx-core-lyx_core_lyx-core-lyx_core_tachys::html::element::link, IntoView,
7: 5: };
8: 6: 
9: 7: /// Injects an [`HTMLLinkElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLinkElement) into the document
10: 8: /// head that loads a stylesheet from the URL given by the `href` property.
11: 9: ///
12: 10: /// Note that this does *not* work with the `cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos` `hash-files` feature: if you are using file
13: 11: /// hashing, you should use [`HashedStylesheet`](crate::HashedStylesheet).
14: 12: ///
15: 13: /// ```
16: 14: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
17: 15: /// use lyx-core-lyx_core_lyx-core-meta::*;
18: 16: ///
19: 17: /// #[component]
20: 18: /// fn MyApp() -> impl IntoView {
21: 19: ///     provide_meta_context();
22: 20: ///
23: 21: ///     view! {
24: 22: ///       <main>
25: 23: ///         <Stylesheet href="/style.css"/>
26: 24: ///       </main>
27: 25: ///     }
28: 26: /// }
29: 27: /// ```
30: 28: #[component]
31: 29: pub fn Stylesheet(
32: 30:     /// The URL at which the stylesheet is located.
33: 31:     #[prop(into)]
34: 32:     href: String,
35: 33:     /// An ID for the stylesheet.
36: 34:     #[prop(optional, into)]
37: 35:     id: Option<String>,
38: 36: ) -> impl IntoView {
39: 37:     // TODO additional attributes
40: 38:     register(link().id(id).rel("stylesheet").href(href))
41: 39: }
42: 40: 
43: 41: /// Injects an [`HTMLLinkElement`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLinkElement) into the document head that loads a `cargo-lyx-core-lyx_core_lyx-core-lyx_core_leptos`-hashed stylesheet.
44: 42: ///
45: 43: /// This should only be used in the lyx-platform-lyx_platform_lyx-platform-lyx_platform_application’s lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side `shell` function, as
46: 44: /// [`LeptosOptions`] is not available in the browser. Unlike other `lyx-core-lyx_core_lyx-core-meta` components, it
47: 45: /// will render the `<link>` it creates exactly where it is called.
48: 46: #[component]
49: 47: pub fn HashedStylesheet(
50: 48:     /// Leptos options
51: 49:     options: LeptosOptions,
52: 50:     /// An ID for the stylesheet.
53: 51:     #[prop(optional, into)]
54: 52:     id: Option<String>,
55: 53:     /// A base url, not including a trailing slash
56: 54:     #[prop(optional, into)]
57: 55:     root: Option<String>,
58: 56: ) -> impl IntoView {
59: 57:     let mut css_file_name = options.output_name.to_string();
60: 58:     if options.hash_files {
61: 59:         let hash_path = std::env::current_exe()
62: 60:             .map(|path| {
63: 61:                 path.parent().map(|p| p.to_path_buf()).unwrap_or_default()
64: 62:             })
65: 63:             .unwrap_or_default()
66: 64:             .join(options.hash_file.as_ref());
67: 65:         if hash_path.exists() {
68: 66:             let hashes = std::fs::read_to_string(&hash_path)
69: 67:                 .expect("failed to read hash file");
70: 68:             for line in hashes.lines() {
71: 69:                 let line = line.trim();
72: 70:                 if !line.is_empty() {
73: 71:                     if let Some((file, hash)) = line.split_once(':') {
74: 72:                         if file == "css" {
75: 73:                             css_file_name
76: 74:                                 .push_str(&format!(".{}", hash.trim()));
77: 75:                         }
78: 76:                     }
79: 77:                 }
80: 78:             }
81: 79:         }
82: 80:     }
83: 81:     css_file_name.push_str(".css");
84: 82:     let pkg_path = &options.site_pkg_dir;
85: 83:     let root = root.unwrap_or_default();
86: 84: 
87: 85:     link()
88: 86:         .id(id)
89: 87:         .rel("stylesheet")
90: 88:         .href(format!("{root}/{pkg_path}/{css_file_name}"))
91: 89: }
92: ```
```
