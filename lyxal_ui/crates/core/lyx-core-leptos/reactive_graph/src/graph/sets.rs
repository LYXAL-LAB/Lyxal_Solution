### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\graph\sets.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\graph\sets.rs
2: ```rust
3: 1: //! Types that hold the set of sources or subscribers affiliated with a reactive node.
4: 2: //!
5: 3: //! At the moment, these are implemented as linear maps built on a `Vec<_>`. This is for the sake
6: 4: //! of minimizing binary size as much as possible, and on the assumption that the M:N relationship
7: 5: //! between sources and subscribers usually consists of fairly small numbers, such that the cost of
8: 6: //! a linear search is not significantly more expensive than a hash and lookup.
9: 7: 
10: 8: use super::{AnySource, AnySubscriber, Source};
11: 9: use indexmap::IndexSet;
12: 10: use rustc_hash::FxHasher;
13: 11: use std::{hash::BuildHasherDefault, mem};
14: 12: 
15: 13: type FxIndexSet<T> = IndexSet<T, BuildHasherDefault<FxHasher>>;
16: 14: 
17: 15: #[derive(Default, Clone, Debug)]
18: 16: pub struct SourceSet(FxIndexSet<AnySource>);
19: 17: 
20: 18: impl SourceSet {
21: 19:     pub fn new() -> Self {
22: 20:         Self(Default::default())
23: 21:     }
24: 22: 
25: 23:     pub fn insert(&mut self, source: AnySource) {
26: 24:         self.0.insert(source);
27: 25:     }
28: 26: 
29: 27:     pub fn remove(&mut self, source: &AnySource) {
30: 28:         self.0.shift_remove(source);
31: 29:     }
32: 30: 
33: 31:     pub fn take(&mut self) -> FxIndexSet<AnySource> {
34: 32:         mem::take(&mut self.0)
35: 33:     }
36: 34: 
37: 35:     pub fn len(&self) -> usize {
38: 36:         self.0.len()
39: 37:     }
40: 38: 
41: 39:     pub fn clear_sources(&mut self, subscriber: &AnySubscriber) {
42: 40:         for source in self.take() {
43: 41:             source.remove_subscriber(subscriber);
44: 42:         }
45: 43:     }
46: 44: }
47: 45: 
48: 46: impl IntoIterator for SourceSet {
49: 47:     type Item = AnySource;
50: 48:     type IntoIter = <FxIndexSet<AnySource> as IntoIterator>::IntoIter;
51: 49: 
52: 50:     fn into_iter(self) -> Self::IntoIter {
53: 51:         self.0.into_iter()
54: 52:     }
55: 53: }
56: 54: 
57: 55: impl<'a> IntoIterator for &'a SourceSet {
58: 56:     type Item = &'a AnySource;
59: 57:     type IntoIter = <&'a FxIndexSet<AnySource> as IntoIterator>::IntoIter;
60: 58: 
61: 59:     fn into_iter(self) -> Self::IntoIter {
62: 60:         self.0.iter()
63: 61:     }
64: 62: }
65: 63: #[derive(Debug, Default, Clone)]
66: 64: pub struct SubscriberSet(FxIndexSet<AnySubscriber>);
67: 65: 
68: 66: impl SubscriberSet {
69: 67:     pub fn new() -> Self {
70: 68:         Self(FxIndexSet::with_capacity_and_hasher(2, Default::default()))
71: 69:     }
72: 70: 
73: 71:     pub fn subscribe(&mut self, subscriber: AnySubscriber) {
74: 72:         self.0.insert(subscriber);
75: 73:     }
76: 74: 
77: 75:     pub fn unsubscribe(&mut self, subscriber: &AnySubscriber) {
78: 76:         // note: do not use `.swap_remove()` here.
79: 77:         // using `.remove()` is slower because it shifts other items
80: 78:         // but it maintains the order of the subscribers, which is important
81: 79:         // to correctness when you're using this to drive something like a UI,
82: 80:         // which can have nested effects, where the inner one assumes the outer
83: 81:         // has already run (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, an outer effect that checks .is_some(),
84: 82:         // and an inner effect that unwraps)
85: 83:         self.0.shift_remove(subscriber);
86: 84:     }
87: 85: 
88: 86:     pub fn take(&mut self) -> FxIndexSet<AnySubscriber> {
89: 87:         mem::take(&mut self.0)
90: 88:     }
91: 89: 
92: 90:     pub fn len(&self) -> usize {
93: 91:         self.0.len()
94: 92:     }
95: 93: }
96: 94: 
97: 95: impl IntoIterator for SubscriberSet {
98: 96:     type Item = AnySubscriber;
99: 97:     type IntoIter = <FxIndexSet<AnySubscriber> as IntoIterator>::IntoIter;
100: 98: 
101: 99:     fn into_iter(self) -> Self::IntoIter {
102: 100:         self.0.into_iter()
103: 101:     }
104: 102: }
105: 103: 
106: 104: impl<'a> IntoIterator for &'a SubscriberSet {
107: 105:     type Item = &'a AnySubscriber;
108: 106:     type IntoIter = <&'a FxIndexSet<AnySubscriber> as IntoIterator>::IntoIter;
109: 107: 
110: 108:     fn into_iter(self) -> Self::IntoIter {
111: 109:         self.0.iter()
112: 110:     }
113: 111: }
114: ```
```
