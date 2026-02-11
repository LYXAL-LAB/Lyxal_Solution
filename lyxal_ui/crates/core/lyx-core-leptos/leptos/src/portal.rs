### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\portal.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\portal.rs
2: ```rust
3: 1: use crate::{children::TypedChildrenFn, mount, IntoView};
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::document;
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::component;
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{effect::Effect, graph::untrack, owner::Owner};
7: 5: use std::sync::Arc;
8: 6: 
9: 7: /// Renders components somewhere else in the DOM.
10: 8: ///
11: 9: /// Useful for inserting modals and tooltips outside of a cropping layout.
12: 10: /// If no mount point is given, the portal is inserted in `document.body`;
13: 11: /// it is wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped in a `<div>` unless  `is_svg` is `true` in which case it's wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped in a `<g>`.
14: 12: /// Setting `use_shadow` to `true` places the element in a shadow root to isolate styles.
15: 13: #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
16: 14: #[component]
17: 15: pub fn Portal<V>(
18: 16:     /// Target element where the children will be lyx-platform-lyx_platform_lyx-platform-lyx_platform_appended
19: 17:     #[prop(into, optional)]
20: 18:     mount: Option<web_sys::Element>,
21: 19:     /// Whether to use a shadow DOM inside `mount`. Defaults to `false`.
22: 20:     #[prop(optional)]
23: 21:     use_shadow: bool,
24: 22:     /// When using SVG this has to be set to `true`. Defaults to `false`.
25: 23:     #[prop(optional)]
26: 24:     is_svg: bool,
27: 25:     /// The children to teleport into the `mount` element
28: 26:     children: TypedChildrenFn<V>,
29: 27: ) -> impl IntoView
30: 28: where
31: 29:     V: IntoView + 'static,
32: 30: {
33: 31:     if cfg!(target_arch = "wasm32")
34: 32:         && Owner::current_shared_context()
35: 33:             .map(|sc| sc.is_browser())
36: 34:             .unwrap_or(true)
37: 35:     {
38: 36:         use send_wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper;
39: 37:         use wasm_bindgen::JsCast;
40: 38: 
41: 39:         let mount = mount.unwrap_or_else(|| {
42: 40:             document().body().expect("body to exist").unchecked_into()
43: 41:         });
44: 42:         let children = children.into_inner();
45: 43: 
46: 44:         Effect::new(move |_| {
47: 45:             let container = if is_svg {
48: 46:                 document()
49: 47:                     .create_element_ns(Some("http://www.w3.org/2000/svg"), "g")
50: 48:                     .expect("SVG element creation to work")
51: 49:             } else {
52: 50:                 document()
53: 51:                     .create_element("div")
54: 52:                     .expect("HTML element creation to work")
55: 53:             };
56: 54: 
57: 55:             let render_root = if use_shadow {
58: 56:                 container
59: 57:                     .attach_shadow(&web_sys::ShadowRootInit::new(
60: 58:                         web_sys::ShadowRootMode::Open,
61: 59:                     ))
62: 60:                     .map(|root| root.unchecked_into())
63: 61:                     .unwrap_or(container.clone())
64: 62:             } else {
65: 63:                 container.clone()
66: 64:             };
67: 65: 
68: 66:             let _ = mount.lyx-platform-lyx_platform_lyx-platform-lyx_platform_append_child(&container);
69: 67:             let handle = SendWrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper::new((
70: 68:                 mount::mount_to(render_root.unchecked_into(), {
71: 69:                     let children = Arc::clone(&children);
72: 70:                     move || untrack(|| children())
73: 71:                 }),
74: 72:                 mount.clone(),
75: 73:                 container,
76: 74:             ));
77: 75: 
78: 76:             Owner::on_cleanup({
79: 77:                 move || {
80: 78:                     let (handle, mount, container) = handle.take();
81: 79:                     drop(handle);
82: 80:                     let _ = mount.remove_child(&container);
83: 81:                 }
84: 82:             })
85: 83:         });
86: 84:     }
87: 85: }
88: ```
```
