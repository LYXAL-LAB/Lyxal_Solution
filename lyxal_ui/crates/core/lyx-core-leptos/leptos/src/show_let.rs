### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\show_let.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\show_let.rs
2: ```rust
3: 1: use crate::{children::ViewFn, IntoView};
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro::component;
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::traits::Get;
6: 4: use std::{marker::PhantomData, sync::Arc};
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_tachys::either::Either;
8: 6: 
9: 7: /// Like `<Show>` but for `Option`. This is a shortcut for
10: 8: ///
11: 9: /// ```ignore
12: 10: /// value.map(|value| {
13: 11: ///     view! { ... }
14: 12: /// })
15: 13: /// ```
16: 14: ///
17: 15: /// If you specify a `fallback` it is equvalent to
18: 16: ///
19: 17: /// ```ignore
20: 18: /// value
21: 19: ///     .map(
22: 20: ///         |value| children(value),
23: 21: ///     )
24: 22: ///     .unwrap_or_else(fallback)
25: 23: /// ```
26: 24: ///
27: 25: /// ## Example
28: 26: ///
29: 27: /// ```
30: 28: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
31: 29: /// #
32: 30: /// # #[component]
33: 31: /// # pub fn Example() -> impl IntoView {
34: 32: /// let (opt_value, set_opt_value) = signal(None::<i32>);
35: 33: ///
36: 34: /// view! {
37: 35: ///     <ShowLet some=opt_value let:value>
38: 36: ///         "We have a value: " {value}
39: 37: ///     </ShowLet>
40: 38: /// }
41: 39: /// # }
42: 40: /// ```
43: 41: ///
44: 42: /// You can also specify a fallback:
45: 43: /// ```
46: 44: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
47: 45: /// #
48: 46: /// # #[component]
49: 47: /// # pub fn Example() -> impl IntoView {
50: 48: /// let (opt_value, set_opt_value) = signal(None::<i32>);
51: 49: ///
52: 50: /// view! {
53: 51: ///     <ShowLet some=opt_value let:value fallback=|| "Got nothing">
54: 52: ///         "We have a value: " {value}
55: 53: ///     </ShowLet>
56: 54: /// }
57: 55: /// # }
58: 56: /// ```
59: 57: ///
60: 58: /// In addition to signals you can also use a closure that returns an `Option`:
61: 59: ///
62: 60: /// ```
63: 61: /// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
64: 62: /// #
65: 63: /// # #[component]
66: 64: /// # pub fn Example() -> impl IntoView {
67: 65: /// let (opt_value, set_opt_value) = signal(None::<i32>);
68: 66: ///
69: 67: /// view! {
70: 68: ///     <ShowLet some=move || opt_value.get().map(|v| v * 2) let:value>
71: 69: ///         "We have a value: " {value}
72: 70: ///     </ShowLet>
73: 71: /// }
74: 72: /// # }
75: 73: /// ```
76: 74: #[component(transparent)]
77: 75: pub fn ShowLet<T, ChFn, V, M>(
78: 76:     /// The children will be shown whenever `value` is `Some`.
79: 77:     ///
80: 78:     /// They take the inner value as an argument. Use `let:` to bind the value to a variable.
81: 79:     children: ChFn,
82: 80: 
83: 81:     /// A signal of type `Option` or a closure that returns an `Option`.
84: 82:     /// If the value is `Some`, the children will be shown.
85: 83:     /// Otherwise the fallback will be shown, if present.
86: 84:     some: impl IntoOptionGetter<T, M>,
87: 85: 
88: 86:     /// A closure that returns what gets rendered when the value is `None`.
89: 87:     /// By default this is the empty view.
90: 88:     ///
91: 89:     /// You can think of it as the closure inside `.unwrap_or_else(|| fallback())`.
92: 90:     #[prop(optional, into)]
93: 91:     fallback: ViewFn,
94: 92: 
95: 93:     /// Marker for generic parameters. Ignore this.
96: 94:     #[prop(optional)]
97: 95:     _marker: PhantomData<(T, M)>,
98: 96: ) -> impl IntoView
99: 97: where
100: 98:     ChFn: Fn(T) -> V + Send + Clone + 'static,
101: 99:     V: IntoView + 'static,
102: 100:     T: 'static,
103: 101: {
104: 102:     let getter = some.into_option_getter();
105: 103: 
106: 104:     move || {
107: 105:         let children = children.clone();
108: 106:         let fallback = fallback.clone();
109: 107: 
110: 108:         getter
111: 109:             .run()
112: 110:             .map(move |t| Either::Left(children(t)))
113: 111:             .unwrap_or_else(move || Either::Right(fallback.run()))
114: 112:     }
115: 113: }
116: 114: 
117: 115: /// Servers as a wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_apper for both, an `Option` signal or a closure that returns an `Option`.
118: 116: pub struct OptionGetter<T>(Arc<dyn Fn() -> Option<T> + Send + Sync + 'static>);
119: 117: 
120: 118: impl<T> Clone for OptionGetter<T> {
121: 119:     fn clone(&self) -> Self {
122: 120:         Self(Arc::clone(&self.0))
123: 121:     }
124: 122: }
125: 123: 
126: 124: impl<T> OptionGetter<T> {
127: 125:     /// Runs the getter and returns the result.
128: 126:     pub fn run(&self) -> Option<T> {
129: 127:         (self.0)()
130: 128:     }
131: 129: }
132: 130: 
133: 131: /// Conversion trait for creating an `OptionGetter` from a closure or a signal.
134: 132: pub trait IntoOptionGetter<T, M> {
135: 133:     /// Converts the given value into an `OptionGetter`.
136: 134:     fn into_option_getter(self) -> OptionGetter<T>;
137: 135: }
138: 136: 
139: 137: /// Marker type for creating an `OptionGetter` from a closure.
140: 138: /// Used so that the compiler doesn't complain about double implementations of the trait `IntoOptionGetter`.
141: 139: pub struct FunctionMarker;
142: 140: 
143: 141: impl<T, F> IntoOptionGetter<T, FunctionMarker> for F
144: 142: where
145: 143:     F: Fn() -> Option<T> + Send + Sync + 'static,
146: 144: {
147: 145:     fn into_option_getter(self) -> OptionGetter<T> {
148: 146:         OptionGetter(Arc::new(self))
149: 147:     }
150: 148: }
151: 149: 
152: 150: /// Marker type for creating an `OptionGetter` from a signal.
153: 151: /// Used so that the compiler doesn't complain about double implementations of the trait `IntoOptionGetter`.
154: 152: pub struct SignalMarker;
155: 153: 
156: 154: impl<T, S> IntoOptionGetter<T, SignalMarker> for S
157: 155: where
158: 156:     S: Get<Value = Option<T>> + Clone + Send + Sync + 'static,
159: 157: {
160: 158:     fn into_option_getter(self) -> OptionGetter<T> {
161: 159:         let cloned = self.clone();
162: 160:         OptionGetter(Arc::new(move || cloned.get()))
163: 161:     }
164: 162: }
165: 163: 
166: 164: /// Marker type for creating an `OptionGetter` from a static value.
167: 165: /// Used so that the compiler doesn't complain about double implementations of the trait `IntoOptionGetter`.
168: 166: pub struct StaticMarker;
169: 167: 
170: 168: impl<T> IntoOptionGetter<T, StaticMarker> for Option<T>
171: 169: where
172: 170:     T: Clone + Send + Sync + 'static,
173: 171: {
174: 172:     fn into_option_getter(self) -> OptionGetter<T> {
175: 173:         OptionGetter(Arc::new(move || self.clone()))
176: 174:     }
177: 175: }
178: ```
```
