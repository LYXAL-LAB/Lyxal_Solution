1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\book-lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
4: 2: 
5: 3: #[component]
6: 4: pub fn App() -> impl IntoView {
7: 5:     let mut views: Vec<AnyView> = vec![];
8: 6: 
9: 7:     #[cfg(feature = "placement")]
10: 8:     {
11: 9:         use crate::positioning::placement::PlacementDemo;
12: 10:         views.push(
13: 11:             view! {
14: 12:                 <PlacementDemo />
15: 13:             }
16: 14:             .into_any(),
17: 15:         );
18: 16:     }
19: 17:     #[cfg(feature = "shift")]
20: 18:     {
21: 19:         use crate::positioning::shift::ShiftDemo;
22: 20:         views.push(
23: 21:             view! {
24: 22:                 <ShiftDemo />
25: 23:             }
26: 24:             .into_any(),
27: 25:         );
28: 26:     }
29: 27:     #[cfg(feature = "flip")]
30: 28:     {
31: 29:         use crate::positioning::flip::FlipDemo;
32: 30:         views.push(
33: 31:             view! {
34: 32:                 <FlipDemo />
35: 33:             }
36: 34:             .into_any(),
37: 35:         );
38: 36:     }
39: 37:     #[cfg(feature = "size")]
40: 38:     {
41: 39:         use crate::positioning::size::SizeDemo;
42: 40:         views.push(
43: 41:             view! {
44: 42:                 <SizeDemo />
45: 43:             }
46: 44:             .into_any(),
47: 45:         );
48: 46:     }
49: 47: 
50: 48:     views.into_view()
51: 49: }
52: ```
```

