### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_examples\src\components\chrome.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\components\chrome.rs
2: ```rust
3: 1: // TODO: remove
4: 2: #![allow(unused)]
5: 3: 
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{context::Provider, html::Div, prelude::*};
7: 5: use tailwind_fuse::tw_merge;
8: 6: 
9: 7: #[derive(Clone, Copy, Debug, PartialEq)]
10: 8: pub enum Scrollable {
11: 9:     None,
12: 10:     X,
13: 11:     Y,
14: 12:     Both,
15: 13: }
16: 14: 
17: 15: #[derive(Clone)]
18: 16: pub struct ChromeContext(pub NodeRef<Div>);
19: 17: 
20: 18: #[component]
21: 19: pub fn Chrome(
22: 20:     #[prop(default = false.into(), into)] center: Signal<bool>,
23: 21:     #[prop(default = Scrollable::None.into(), into)] scrollable: Signal<Scrollable>,
24: 22:     #[prop(default = true.into(), into)] relative: Signal<bool>,
25: 23:     #[prop(into, optional)] label: MaybeProp<String>,
26: 24:     #[prop(default = 305.into(), into)] scroll_height: Signal<isize>,
27: 25:     #[prop(default = true.into(), into)] shadow: Signal<bool>,
28: 26:     #[prop(default = false.into(), into)] tall: Signal<bool>,
29: 27:     children: Children,
30: 28: ) -> impl IntoView {
31: 29:     let scrollable_ref: NodeRef<Div> = NodeRef::new();
32: 30: 
33: 31:     let scrollable_x =
34: 32:         Signal::derive(move || matches!(scrollable.get(), Scrollable::X | Scrollable::Both));
35: 33:     let scrollable_y =
36: 34:         Signal::derive(move || matches!(scrollable.get(), Scrollable::Y | Scrollable::Both));
37: 35:     let is_scrollable = Signal::derive(move || scrollable_x.get() || scrollable_y.get());
38: 36: 
39: 37:     Effect::new(move |_| {
40: 38:         if let Some(scrollable) = scrollable_ref.get() {
41: 39:             if scrollable_y.get() {
42: 40:                 scrollable.set_scroll_top(
43: 41:                     scrollable.scroll_height() / 2 - scrollable.offset_height() / 2,
44: 42:                 );
45: 43:             }
46: 44: 
47: 45:             if scrollable_x.get() {
48: 46:                 scrollable
49: 47:                     .set_scroll_left(scrollable.scroll_width() / 2 - scrollable.offset_width() / 2);
50: 48:             }
51: 49:         }
52: 50:     });
53: 51: 
54: 52:     view! {
55: 53:         <div
56: 54:             class={move || tw_merge!(
57: 55:                 "overflow-hidden rounded-lg text-gray-900 [color-scheme:light] dark:border-none bg-clip-padding",
58: 56:                 shadow.get().then_some("shadow border border-black/10 dark:border-gray-700")
59: 57:             )}
60: 58:         >
61: 59:             <div class="bg-gray-75 dark:bg-gray-600/60 dark:text-white">
62: 60:             <div class={move || tw_merge!("absolute mx-4 flex h-12 items-center gap-2", label.get().map(|_| "sm:flex"))}>
63: 61:                 <div
64: 62:                     class="h-3 w-3 rounded-full"
65: 63:                     style:background="#ec695e"
66: 64:                 />
67: 65:                 <div
68: 66:                     class="h-3 w-3 rounded-full"
69: 67:                     style:background="#f4bf4f"
70: 68:                 />
71: 69:                 <div
72: 70:                     class="h-3 w-3 rounded-full"
73: 71:                     style:background="#61c653"
74: 72:                 />
75: 73:                 </div>
76: 74:                     <div class="flex h-12 items-center justify-center font-semibold">
77: 75:                     {move || label.get()}
78: 76:                 </div>
79: 77:             </div>
80: 78:             <div class="will-change-transform">
81: 79:                 <div
82: 80:                     node_ref={scrollable_ref}
83: 81:                     class={move || tw_merge!(
84: 82:                         "h-[20rem] overflow-hidden bg-gray-50 p-2",
85: 83:                         center.get().then_some("grid place-items-center"),
86: 84:                         scrollable_y.get().then_some("overflow-y-auto"),
87: 85:                         scrollable_x.get().then_some("overflow-x-auto"),
88: 86:                         tall.get().then_some("h-[50rem] md:h-[30rem]"),
89: 87:                         relative.get().then_some("relative")
90: 88:                     )}
91: 89:                 >
92: 90:                     <Show when=move || is_scrollable.get()>
93: 91:                         <div
94: 92:                             class={scrollable_x.get().then_some("w-[180vw] md:w-[75rem] lg:w-[90rem]")}
95: 93:                             style:height={if scrollable_y.get() {
96: 94:                                 format!("{}px", scroll_height.get())
97: 95:                             } else {
98: 96:                                 "1px".to_owned()
99: 97:                             }}
100: 98:                         />
101: 99:                     </Show>
102: 100:                     <Provider value={ChromeContext(scrollable_ref)}>
103: 101:                         {children()}
104: 102:                     </Provider>
105: 103:                     <Show when=move || is_scrollable.get()>
106: 104:                         <div
107: 105:                             class={scrollable_x.get().then_some("w-[180vw] md:w-[75rem] lg:w-[90rem]")}
108: 106:                             style:height={if scrollable_y.get() {
109: 107:                                 format!("{}px", scroll_height.get())
110: 108:                             } else {
111: 109:                                 "1px".to_owned()
112: 110:                             }}
113: 111:                         />
114: 112:                     </Show>
115: 113:                 </div>
116: 114:             </div>
117: 115:         </div>
118: 116:     }
119: 117: }
120: ```
```
