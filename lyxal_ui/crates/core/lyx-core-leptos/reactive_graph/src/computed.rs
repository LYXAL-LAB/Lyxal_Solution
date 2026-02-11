### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed.rs
2: ```rust
3: 1: //! Computed reactive values that derive from other reactive values.
4: 2: 
5: 3: mod arc_memo;
6: 4: mod async_derived;
7: 5: mod inner;
8: 6: mod memo;
9: 7: mod selector;
10: 8: use crate::{
11: 9:     prelude::*,
12: 10:     signal::RwSignal,
13: 11:     wrlyx-platform-lyx_platform_lyx-platform-lyx_platform_appers::{
14: 12:         read::Signal,
15: 13:         write::{IntoSignalSetter, SignalSetter},
16: 14:     },
17: 15: };
18: 16: pub use arc_memo::*;
19: 17: pub use async_derived::*;
20: 18: pub use memo::*;
21: 19: pub use selector::*;
22: 20: 
23: 21: /// Derives a reactive slice of an [`RwSignal`].
24: 22: ///
25: 23: /// Slices have the same guarantees as [`Memo`s](crate::computed::Memo):
26: 24: /// they only emit their value when it has actually been changed.
27: 25: ///
28: 26: /// Slices need a getter and a setter, and you must make sure that
29: 27: /// the setter and getter only touch their respective field and nothing else.
30: 28: /// They optimally should not have any side effects.
31: 29: ///
32: 30: /// You can use slices whenever you want to react to only parts
33: 31: /// of a bigger signal. The prime lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example would be state management,
34: 32: /// where you want all state variables grouped together, but also need
35: 33: /// fine-grained signals for each or some of these variables.
36: 34: /// In the lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example below, setting an auth token will only trigger
37: 35: /// the token signal, but none of the other derived signals.
38: 36: /// ```
39: 37: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
40: 38: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::effect::Effect;
41: 39: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::RwSignal;
42: 40: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::computed::*;
43: 41: ///
44: 42: /// // some global state with independent fields
45: 43: /// #[derive(Default, Clone, Debug)]
46: 44: /// struct GlobalState {
47: 45: ///     count: u32,
48: 46: ///     name: String,
49: 47: /// }
50: 48: ///
51: 49: /// let state = RwSignal::new(GlobalState::default());
52: 50: ///
53: 51: /// // `create_slice` lets us create a "lens" into the data
54: 52: /// let (count, set_count) = create_slice(
55: 53: ///     // we take a slice *from* `state`
56: 54: ///     state,
57: 55: ///     // our getter returns a "slice" of the data
58: 56: ///     |state| state.count,
59: 57: ///     // our setter describes how to mutate that slice, given a new value
60: 58: ///     |state, n| state.count = n,
61: 59: /// );
62: 60: ///
63: 61: /// // this slice is completely independent of the `count` slice
64: 62: /// // neither of them will cause the other to rerun
65: 63: /// let (name, set_name) = create_slice(
66: 64: ///     // we take a slice *from* `state`
67: 65: ///     state,
68: 66: ///     // our getter returns a "slice" of the data
69: 67: ///     |state| state.name.clone(),
70: 68: ///     // our setter describes how to mutate that slice, given a new value
71: 69: ///     |state, n| state.name = n,
72: 70: /// );
73: 71: ///
74: 72: /// # if false { // don't run effects in doctest
75: 73: /// Effect::new(move |_| {
76: 74: ///     println!("name is {}", name.get());
77: 75: /// });
78: 76: /// Effect::new(move |_| {
79: 77: ///     println!("count is {}", count.get());
80: 78: /// });
81: 79: /// # }
82: 80: ///
83: 81: /// // setting count only causes count to log, not name
84: 82: /// set_count.set(42);
85: 83: ///
86: 84: /// // setting name only causes name to log, not count
87: 85: /// set_name.set("Bob".into());
88: 86: /// ```
89: 87: #[track_caller]
90: 88: pub fn create_slice<T, O, S>(
91: 89:     signal: RwSignal<T>,
92: 90:     getter: impl Fn(&T) -> O + Copy + Send + Sync + 'static,
93: 91:     setter: impl Fn(&mut T, S) + Copy + Send + Sync + 'static,
94: 92: ) -> (Signal<O>, SignalSetter<S>)
95: 93: where
96: 94:     T: Send + Sync + 'static,
97: 95:     O: PartialEq + Send + Sync + 'static,
98: 96: {
99: 97:     (
100: 98:         create_read_slice(signal, getter),
101: 99:         create_write_slice(signal, setter),
102: 100:     )
103: 101: }
104: 102: 
105: 103: /// Takes a memoized, read-only slice of a signal. This is equivalent to the
106: 104: /// read-only half of [`create_slice`].
107: 105: #[track_caller]
108: 106: pub fn create_read_slice<T, O>(
109: 107:     signal: RwSignal<T>,
110: 108:     getter: impl Fn(&T) -> O + Copy + Send + Sync + 'static,
111: 109: ) -> Signal<O>
112: 110: where
113: 111:     T: Send + Sync + 'static,
114: 112:     O: PartialEq + Send + Sync + 'static,
115: 113: {
116: 114:     Memo::new(move |_| signal.with(getter)).into()
117: 115: }
118: 116: 
119: 117: /// Creates a setter to access one slice of a signal. This is equivalent to the
120: 118: /// write-only half of [`create_slice`].
121: 119: #[track_caller]
122: 120: pub fn create_write_slice<T, O>(
123: 121:     signal: RwSignal<T>,
124: 122:     setter: impl Fn(&mut T, O) + Copy + Send + Sync + 'static,
125: 123: ) -> SignalSetter<O>
126: 124: where
127: 125:     T: Send + Sync + 'static,
128: 126: {
129: 127:     let setter = move |value| signal.update(|x| setter(x, value));
130: 128:     setter.into_signal_setter()
131: 129: }
132: 130: 
133: 131: /// Creates a new memoized, computed reactive value.
134: 132: #[inline(always)]
135: 133: #[track_caller]
136: 134: #[deprecated = "This function is being removed to conform to Rust idioms. \
137: 135:                 Please use `Memo::new()` instead."]
138: 136: pub fn create_memo<T>(
139: 137:     fun: impl Fn(Option<&T>) -> T + Send + Sync + 'static,
140: 138: ) -> Memo<T>
141: 139: where
142: 140:     T: PartialEq + Send + Sync + 'static,
143: 141: {
144: 142:     Memo::new(fun)
145: 143: }
146: 144: 
147: 145: /// Creates a new memo by passing a function that computes the value.
148: 146: #[inline(always)]
149: 147: #[track_caller]
150: 148: #[deprecated = "This function is being removed to conform to Rust idioms. \
151: 149:                 Please use `Memo::new_owning()` instead."]
152: 150: pub fn create_owning_memo<T>(
153: 151:     fun: impl Fn(Option<T>) -> (T, bool) + Send + Sync + 'static,
154: 152: ) -> Memo<T>
155: 153: where
156: 154:     T: PartialEq + Send + Sync + 'static,
157: 155: {
158: 156:     Memo::new_owning(fun)
159: 157: }
160: 158: 
161: 159: /// A conditional signal that only notifies subscribers when a change
162: 160: /// in the source signal’s value changes whether the given function is true.
163: 161: #[inline(always)]
164: 162: #[track_caller]
165: 163: #[deprecated = "This function is being removed to conform to Rust idioms. \
166: 164:                 Please use `Selector::new()` instead."]
167: 165: pub fn create_selector<T>(
168: 166:     source: impl Fn() -> T + Clone + Send + Sync + 'static,
169: 167: ) -> Selector<T>
170: 168: where
171: 169:     T: PartialEq + Eq + Send + Sync + Clone + std::hash::Hash + 'static,
172: 170: {
173: 171:     Selector::new(source)
174: 172: }
175: 173: 
176: 174: /// Creates a conditional signal that only notifies subscribers when a change
177: 175: /// in the source signal’s value changes whether the given function is true.
178: 176: #[inline(always)]
179: 177: #[track_caller]
180: 178: #[deprecated = "This function is being removed to conform to Rust idioms. \
181: 179:                 Please use `Selector::new_with_fn()` instead."]
182: 180: pub fn create_selector_with_fn<T>(
183: 181:     source: impl Fn() -> T + Clone + Send + Sync + 'static,
184: 182:     f: impl Fn(&T, &T) -> bool + Send + Sync + Clone + 'static,
185: 183: ) -> Selector<T>
186: 184: where
187: 185:     T: PartialEq + Eq + Send + Sync + Clone + std::hash::Hash + 'static,
188: 186: {
189: 187:     Selector::new_with_fn(source, f)
190: 188: }
191: ```
```
