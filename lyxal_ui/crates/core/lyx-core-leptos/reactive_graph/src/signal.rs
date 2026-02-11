### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal.rs
2: ```rust
3: 1: //! Reactive primitives for root values that can be changed, notifying other nodes in the reactive
4: 2: //! graph.
5: 3: 
6: 4: mod arc_read;
7: 5: mod arc_rw;
8: 6: mod arc_trigger;
9: 7: mod arc_write;
10: 8: pub mod guards;
11: 9: mod mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped;
12: 10: mod read;
13: 11: mod rw;
14: 12: mod subscriber_traits;
15: 13: mod trigger;
16: 14: mod write;
17: 15: 
18: 16: use crate::owner::LocalStorage;
19: 17: pub use arc_read::*;
20: 18: pub use arc_rw::*;
21: 19: pub use arc_trigger::*;
22: 20: pub use arc_write::*;
23: 21: pub use mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apped::*;
24: 22: pub use read::*;
25: 23: pub use rw::*;
26: 24: pub use trigger::*;
27: 25: pub use write::*;
28: 26: 
29: 27: /// Creates a reference-counted signal.
30: 28: ///
31: 29: /// A signal is a piece of data that may change over time, and notifies other
32: 30: /// code when it has changed. This is the atomic unit of reactivity, which begins all other
33: 31: /// processes of updating.
34: 32: ///
35: 33: /// Takes the initial value as an argument, and returns a tuple containing an
36: 34: /// [`ArcReadSignal`] and an [`ArcWriteSignal`].
37: 35: ///
38: 36: /// This returns reference-counted signals, which are `Clone` but not `Copy`. For arena-allocated
39: 37: /// `Copy` signals, use [`signal`].
40: 38: ///
41: 39: /// ```
42: 40: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
43: 41: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
44: 42: /// let (count, set_count) = arc_signal(0);
45: 43: ///
46: 44: /// // ✅ calling the getter clones and returns the value
47: 45: /// //    this can be `count()` on nightly
48: 46: /// assert_eq!(count.get(), 0);
49: 47: ///
50: 48: /// // ✅ calling the setter sets the value
51: 49: /// //    this can be `set_count(1)` on nightly
52: 50: /// set_count.set(1);
53: 51: /// assert_eq!(count.get(), 1);
54: 52: ///
55: 53: /// // ❌ you could call the getter within the setter
56: 54: /// // set_count.set(count.get() + 1);
57: 55: ///
58: 56: /// // ✅ however it's more efficient to use .update() and mutate the value in place
59: 57: /// set_count.update(|count: &mut i32| *count += 1);
60: 58: /// assert_eq!(count.get(), 2);
61: 59: ///
62: 60: /// // ✅ you can create "derived signals" with a Fn() -> T interface
63: 61: /// let double_count = move || count.get() * 2;
64: 62: /// set_count.set(0);
65: 63: /// assert_eq!(double_count(), 0);
66: 64: /// set_count.set(1);
67: 65: /// assert_eq!(double_count(), 2);
68: 66: /// ```
69: 67: #[inline(always)]
70: 68: #[track_caller]
71: 69: pub fn arc_signal<T>(value: T) -> (ArcReadSignal<T>, ArcWriteSignal<T>) {
72: 70:     ArcRwSignal::new(value).split()
73: 71: }
74: 72: 
75: 73: /// Creates an arena-allocated signal, the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic reactive primitive.
76: 74: ///
77: 75: /// A signal is a piece of data that may change over time, and notifies other
78: 76: /// code when it has changed. This is the atomic unit of reactivity, which begins all other
79: 77: /// processes of updating.
80: 78: ///
81: 79: /// Takes the initial value as an argument, and returns a tuple containing a
82: 80: /// [`ReadSignal`] and a [`WriteSignal`].
83: 81: ///
84: 82: /// This returns an arena-allocated signal, which is `Copy` and is disposed when its reactive
85: 83: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted signal that lives
86: 84: /// as long as a reference to it is alive, see [`arc_signal`].
87: 85: /// ```
88: 86: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
89: 87: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
90: 88: /// let (count, set_count) = signal(0);
91: 89: ///
92: 90: /// // ✅ calling the getter clones and returns the value
93: 91: /// //    this can be `count()` on nightly
94: 92: /// assert_eq!(count.get(), 0);
95: 93: ///
96: 94: /// // ✅ calling the setter sets the value
97: 95: /// //    this can be `set_count(1)` on nightly
98: 96: /// set_count.set(1);
99: 97: /// assert_eq!(count.get(), 1);
100: 98: ///
101: 99: /// // ❌ you could call the getter within the setter
102: 100: /// // set_count.set(count.get() + 1);
103: 101: ///
104: 102: /// // ✅ however it's more efficient to use .update() and mutate the value in place
105: 103: /// set_count.update(|count: &mut i32| *count += 1);
106: 104: /// assert_eq!(count.get(), 2);
107: 105: ///
108: 106: /// // ✅ you can create "derived signals" with a Fn() -> T interface
109: 107: /// let double_count = move || count.get() * 2; // signals are `Copy` so you can `move` them anywhere
110: 108: /// set_count.set(0);
111: 109: /// assert_eq!(double_count(), 0);
112: 110: /// set_count.set(1);
113: 111: /// assert_eq!(double_count(), 2);
114: 112: /// ```
115: 113: #[inline(always)]
116: 114: #[track_caller]
117: 115: pub fn signal<T: Send + Sync + 'static>(
118: 116:     value: T,
119: 117: ) -> (ReadSignal<T>, WriteSignal<T>) {
120: 118:     let (r, w) = arc_signal(value);
121: 119:     (r.into(), w.into())
122: 120: }
123: 121: 
124: 122: /// Creates an arena-allocated signal.
125: 123: ///
126: 124: /// Unlike [`signal`], this does not require the value to be `Send + Sync`. Instead, it is stored
127: 125: /// on a local arena. Accessing either of the returned signals from another thread will panic.
128: 126: #[inline(always)]
129: 127: #[track_caller]
130: 128: pub fn signal_local<T: 'static>(
131: 129:     value: T,
132: 130: ) -> (ReadSignal<T, LocalStorage>, WriteSignal<T, LocalStorage>) {
133: 131:     RwSignal::new_local(value).split()
134: 132: }
135: 133: 
136: 134: /// Creates an arena-allocated signal, the lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic reactive primitive.
137: 135: ///
138: 136: /// A signal is a piece of data that may change over time, and notifies other
139: 137: /// code when it has changed. This is the atomic unit of reactivity, which begins all other
140: 138: /// processes of updating.
141: 139: ///
142: 140: /// Takes the initial value as an argument, and returns a tuple containing a
143: 141: /// [`ReadSignal`] and a [`WriteSignal`].
144: 142: ///
145: 143: /// This returns an arena-allocated signal, which is `Copy` and is disposed when its reactive
146: 144: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted signal that lives
147: 145: /// as long as a reference to it is alive, see [`arc_signal`].
148: 146: /// ```
149: 147: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::prelude::*;
150: 148: /// # use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::signal::*; let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new(); owner.set();
151: 149: /// let (count, set_count) = create_signal(0);
152: 150: ///
153: 151: /// // ✅ calling the getter clones and returns the value
154: 152: /// //    this can be `count()` on nightly
155: 153: /// assert_eq!(count.get(), 0);
156: 154: ///
157: 155: /// // ✅ calling the setter sets the value
158: 156: /// //    this can be `set_count(1)` on nightly
159: 157: /// set_count.set(1);
160: 158: /// assert_eq!(count.get(), 1);
161: 159: ///
162: 160: /// // ❌ you could call the getter within the setter
163: 161: /// // set_count.set(count.get() + 1);
164: 162: ///
165: 163: /// // ✅ however it's more efficient to use .update() and mutate the value in place
166: 164: /// set_count.update(|count: &mut i32| *count += 1);
167: 165: /// assert_eq!(count.get(), 2);
168: 166: ///
169: 167: /// // ✅ you can create "derived signals" with a Fn() -> T interface
170: 168: /// let double_count = move || count.get() * 2; // signals are `Copy` so you can `move` them anywhere
171: 169: /// set_count.set(0);
172: 170: /// assert_eq!(double_count(), 0);
173: 171: /// set_count.set(1);
174: 172: /// assert_eq!(double_count(), 2);
175: 173: /// ```
176: 174: #[inline(always)]
177: 175: #[track_caller]
178: 176: #[deprecated = "This function is being renamed to `signal()` to conform to \
179: 177:                 Rust idioms."]
180: 178: pub fn create_signal<T: Send + Sync + 'static>(
181: 179:     value: T,
182: 180: ) -> (ReadSignal<T>, WriteSignal<T>) {
183: 181:     signal(value)
184: 182: }
185: 183: 
186: 184: /// Creates a reactive signal with the getter and setter unified in one value.
187: 185: #[inline(always)]
188: 186: #[track_caller]
189: 187: #[deprecated = "This function is being removed to conform to Rust idioms. \
190: 188:                 Please use `RwSignal::new()` instead."]
191: 189: pub fn create_rw_signal<T: Send + Sync + 'static>(value: T) -> RwSignal<T> {
192: 190:     RwSignal::new(value)
193: 191: }
194: 192: 
195: 193: /// A trigger is a data-less signal with the sole purpose of notifying other reactive code of a change.
196: 194: #[inline(always)]
197: 195: #[track_caller]
198: 196: #[deprecated = "This function is being removed to conform to Rust idioms. \
199: 197:                 Please use `ArcTrigger::new()` instead."]
200: 198: pub fn create_trigger() -> ArcTrigger {
201: 199:     ArcTrigger::new()
202: 200: }
203: ```
```
