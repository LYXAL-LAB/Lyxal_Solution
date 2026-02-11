### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\animated_show.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\animated_show.rs
2: ```rust
3: 1: use crate::{children::ChildrenFn, component, control_flow::Show, IntoView};
4: 2: use core::time::Duration;
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::TimeoutHandle;
6: 4: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::view;
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
8: 6:     effect::RenderEffect,
9: 7:     owner::{on_cleanup, StoredValue},
10: 8:     signal::RwSignal,
11: 9:     traits::{Get, GetUntracked, GetValue, Set, SetValue},
12: 10:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::read::Signal,
13: 11: };
14: 12: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::prelude::*;
15: 13: 
16: 14: /// A component that will show its children when the `when` condition is `true`.
17: 15: /// Additionally, you need to specify a `hide_delay`. If the `when` condition changes to `false`,
18: 16: /// the unmounting of the children will be delayed by the specified Duration.
19: 17: /// If you provide the optional `show_class` and `hide_class`, you can create very easy mount /
20: 18: /// unmount animations.
21: 19: ///
22: 20: /// ```rust
23: 21: /// # use core::time::Duration;
24: 22: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
25: 23: /// # #[component]
26: 24: /// # pub fn App() -> impl IntoView {
27: 25: /// let show = RwSignal::new(false);
28: 26: ///
29: 27: /// view! {
30: 28: ///     <div
31: 29: ///         class="hover-me"
32: 30: ///         on:mouseenter=move |_| show.set(true)
33: 31: ///         on:mouseleave=move |_| show.set(false)
34: 32: ///     >
35: 33: ///         "Hover Me"
36: 34: ///     </div>
37: 35: ///
38: 36: ///     <AnimatedShow
39: 37: ///        when=show
40: 38: ///        show_class="fade-in-1000"
41: 39: ///        hide_class="fade-out-1000"
42: 40: ///        hide_delay=Duration::from_millis(1000)
43: 41: ///     >
44: 42: ///        <div class="here-i-am">
45: 43: ///            "Here I Am!"
46: 44: ///        </div>
47: 45: ///     </AnimatedShow>
48: 46: /// }
49: 47: /// # }
50: 48: /// ```
51: 49: #[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
52: 50: #[component]
53: 51: pub fn AnimatedShow(
54: 52:     /// The components Show wraps
55: 53:     children: ChildrenFn,
56: 54:     /// If the component should show or not
57: 55:     #[prop(into)]
58: 56:     when: Signal<bool>,
59: 57:     /// Optional CSS class to lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply if `when == true`
60: 58:     #[prop(optional)]
61: 59:     show_class: &'static str,
62: 60:     /// Optional CSS class to lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply if `when == false`
63: 61:     #[prop(optional)]
64: 62:     hide_class: &'static str,
65: 63:     /// The timeout after which the component will be unmounted if `when == false`
66: 64:     hide_delay: Duration,
67: 65: ) -> impl IntoView {
68: 66:     let handle: StoredValue<Option<TimeoutHandle>> = StoredValue::new(None);
69: 67:     let cls = RwSignal::new(if when.get_untracked() {
70: 68:         show_class
71: 69:     } else {
72: 70:         hide_class
73: 71:     });
74: 72:     let show = RwSignal::new(when.get_untracked());
75: 73: 
76: 74:     let eff = RenderEffect::new(move |_| {
77: 75:         if when.get() {
78: 76:             // clear any possibly active timer
79: 77:             if let Some(h) = handle.get_value() {
80: 78:                 h.clear();
81: 79:             }
82: 80: 
83: 81:             cls.set(show_class);
84: 82:             show.set(true);
85: 83:         } else {
86: 84:             cls.set(hide_class);
87: 85: 
88: 86:             let h = lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_dom::helpers::set_timeout_with_handle(
89: 87:                 move || show.set(false),
90: 88:                 hide_delay,
91: 89:             )
92: 90:             .expect("set timeout in AnimatedShow");
93: 91:             handle.set_value(Some(h));
94: 92:         }
95: 93:     });
96: 94: 
97: 95:     on_cleanup(move || {
98: 96:         if let Some(Some(h)) = handle.try_get_value() {
99: 97:             h.clear();
100: 98:         }
101: 99:         drop(eff);
102: 100:     });
103: 101: 
104: 102:     view! {
105: 103:         <Show when=move || show.get() fallback=|| ()>
106: 104:             <div class=move || cls.get()>{children()}</div>
107: 105:         </Show>
108: 106:     }
109: 107: }
110: ```
```
