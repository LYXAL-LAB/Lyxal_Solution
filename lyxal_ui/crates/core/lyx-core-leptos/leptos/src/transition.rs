### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\transition.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\transition.rs
2: ```rust
3: 1: use crate::{
4: 2:     children::{TypedChildren, ViewFnOnce},
5: 3:     error::ErrorBoundarySuspendedChildren,
6: 4:     suspense_component::SuspenseBoundary,
7: 5:     IntoView,
8: 6: };
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::component;
10: 8: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
11: 9:     computed::{suspense::SuspenseContext, ArcMemo},
12: 10:     effect::Effect,
13: 11:     owner::{provide_context, use_context, Owner},
14: 12:     signal::ArcRwSignal,
15: 13:     traits::{Get, Set, Track, With, WithUntracked},
16: 14:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::write::SignalSetter,
17: 15: };
18: 16: use slotmap::{DefaultKey, SlotMap};
19: 17: use std::sync::Arc;
20: 18: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::OwnedView;
21: 19: 
22: 20: /// If any [`Resource`](crate::prelude::Resource) is read in the `children` of this
23: 21: /// component, it will show the `fallback` while they are loading. Once all are resolved,
24: 22: /// it will render the `children`.
25: 23: ///
26: 24: /// Unlike [`Suspense`](crate::prelude::Suspense), this will not fall
27: 25: /// back to the `fallback` state if there are further changes after the initial load.
28: 26: ///
29: 27: /// Note that the `children` will be rendered initially (in order to capture the fact that
30: 28: /// those resources are read under the suspense), so you cannot assume that resources read
31: 29: /// synchronously have
32: 30: /// `Some` value in `children`. However, you can read resources asynchronously by using
33: 31: /// [Suspend](crate::prelude::Suspend).
34: 32: ///
35: 33: /// ```
36: 34: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
37: 35: /// # if false { // don't run in doctests
38: 36: /// async fn fetch_cats(how_many: u32) -> Vec<String> { vec![] }
39: 37: ///
40: 38: /// let (cat_count, set_cat_count) = signal::<u32>(1);
41: 39: ///
42: 40: /// let cats = Resource::new(move || cat_count.get(), |count| fetch_cats(count));
43: 41: ///
44: 42: /// view! {
45: 43: ///   <div>
46: 44: ///     <Transition fallback=move || view! { <p>"Loading (Suspense Fallback)..."</p> }>
47: 45: ///       // you can access a resource synchronously
48: 46: ///       {move || {
49: 47: ///           cats.get().map(|data| {
50: 48: ///             data
51: 49: ///               .into_iter()
52: 50: ///               .map(|src| {
53: 51: ///                   view! {
54: 52: ///                     <img src={src}/>
55: 53: ///                   }
56: 54: ///               })
57: 55: ///               .collect_view()
58: 56: ///           })
59: 57: ///         }
60: 58: ///       }
61: 59: ///       // or you can use `Suspend` to read resources asynchronously
62: 60: ///       {move || Suspend::new(async move {
63: 61: ///         cats.await
64: 62: ///               .into_iter()
65: 63: ///               .map(|src| {
66: 64: ///                   view! {
67: 65: ///                     <img src={src}/>
68: 66: ///                   }
69: 67: ///               })
70: 68: ///               .collect_view()
71: 69: ///       })}
72: 70: ///     </Transition>
73: 71: ///   </div>
74: 72: /// }
75: 73: /// # ;}
76: 74: /// ```
77: 75: #[component]
78: 76: pub fn Transition<Chil>(
79: 77:     /// Will be displayed while resources are pending. By default this is the empty view.
80: 78:     #[prop(optional, into)]
81: 79:     fallback: ViewFnOnce,
82: 80:     /// A function that will be called when the component transitions into or out of
83: 81:     /// the `pending` state, with its argument indicating whether it is pending (`true`)
84: 82:     /// or not pending (`false`).
85: 83:     #[prop(optional, into)]
86: 84:     set_pending: Option<SignalSetter<bool>>,
87: 85:     children: TypedChildren<Chil>,
88: 86: ) -> impl IntoView
89: 87: where
90: 88:     Chil: IntoView + Send + 'static,
91: 89: {
92: 90:     let error_boundary_parent = use_context::<ErrorBoundarySuspendedChildren>();
93: 91: 
94: 92:     let owner = Owner::new();
95: 93:     owner.with(|| {
96: 94:         let (starts_local, id) = {
97: 95:             Owner::current_shared_context()
98: 96:                 .map(|sc| {
99: 97:                     let id = sc.next_id();
100: 98:                     (sc.get_incomplete_chunk(&id), id)
101: 99:                 })
102: 100:                 .unwrap_or_else(|| (false, Default::default()))
103: 101:         };
104: 102:         let fallback = fallback.run();
105: 103:         let children = children.into_inner()();
106: 104:         let tasks = ArcRwSignal::new(SlotMap::<DefaultKey, ()>::new());
107: 105:         provide_context(SuspenseContext {
108: 106:             tasks: tasks.clone(),
109: 107:         });
110: 108:         let none_pending = ArcMemo::new({
111: 109:             let tasks = tasks.clone();
112: 110:             move |prev: Option<&bool>| {
113: 111:                 tasks.track();
114: 112:                 if prev.is_none() && starts_local {
115: 113:                     false
116: 114:                 } else {
117: 115:                     tasks.with(SlotMap::is_empty)
118: 116:                 }
119: 117:             }
120: 118:         });
121: 119:         let has_tasks =
122: 120:             Arc::new(move || !tasks.with_untracked(SlotMap::is_empty));
123: 121:         if let Some(set_pending) = set_pending {
124: 122:             Effect::new_isomorphic({
125: 123:                 let none_pending = none_pending.clone();
126: 124:                 move |_| {
127: 125:                     set_pending.set(!none_pending.get());
128: 126:                 }
129: 127:             });
130: 128:         }
131: 129: 
132: 130:         OwnedView::new(SuspenseBoundary::<true, _, _> {
133: 131:             id,
134: 132:             none_pending,
135: 133:             fallback,
136: 134:             children,
137: 135:             error_boundary_parent,
138: 136:             has_tasks,
139: 137:         })
140: 138:     })
141: 139: }
142: ```
```
