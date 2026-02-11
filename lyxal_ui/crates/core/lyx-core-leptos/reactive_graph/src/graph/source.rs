### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\graph\source.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\graph\source.rs
2: ```rust
3: 1: use super::{node::ReactiveNode, AnySubscriber};
4: 2: use crate::traits::{DefinedAt, IsDisposed};
5: 3: use core::{fmt::Debug, hash::Hash};
6: 4: use std::{panic::Location, sync::Weak};
7: 5: 
8: 6: /// Abstracts over the type of any reactive source.
9: 7: pub trait ToAnySource: IsDisposed {
10: 8:     /// Converts this type to its type-erased equivalent.
11: 9:     fn to_any_source(&self) -> AnySource;
12: 10: }
13: 11: 
14: 12: /// Describes the behavior of any source of reactivity (like a signal, trigger, or memo.)
15: 13: pub trait Source: ReactiveNode {
16: 14:     /// Adds a subscriber to this source's list of dependencies.
17: 15:     fn add_subscriber(&self, subscriber: AnySubscriber);
18: 16: 
19: 17:     /// Removes a subscriber from this source's list of dependencies.
20: 18:     fn remove_subscriber(&self, subscriber: &AnySubscriber);
21: 19: 
22: 20:     /// Remove all subscribers from this source's list of dependencies.
23: 21:     fn clear_subscribers(&self);
24: 22: }
25: 23: 
26: 24: /// A weak reference to any reactive source node.
27: 25: #[derive(Clone)]
28: 26: pub struct AnySource(
29: 27:     pub(crate) usize,
30: 28:     pub(crate) Weak<dyn Source + Send + Sync>,
31: 29:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
32: 30:     pub(crate)  &'static Location<'static>,
33: 31: );
34: 32: 
35: 33: impl DefinedAt for AnySource {
36: 34:     fn defined_at(&self) -> Option<&'static Location<'static>> {
37: 35:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
38: 36:         {
39: 37:             Some(self.2)
40: 38:         }
41: 39:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
42: 40:         {
43: 41:             None
44: 42:         }
45: 43:     }
46: 44: }
47: 45: 
48: 46: impl Debug for AnySource {
49: 47:     fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
50: 48:         f.debug_tuple("AnySource").field(&self.0).finish()
51: 49:     }
52: 50: }
53: 51: 
54: 52: impl Hash for AnySource {
55: 53:     fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
56: 54:         self.0.hash(state);
57: 55:     }
58: 56: }
59: 57: 
60: 58: impl PartialEq for AnySource {
61: 59:     fn eq(&self, other: &Self) -> bool {
62: 60:         self.0 == other.0
63: 61:     }
64: 62: }
65: 63: 
66: 64: impl Eq for AnySource {}
67: 65: 
68: 66: impl IsDisposed for AnySource {
69: 67:     #[inline(always)]
70: 68:     fn is_disposed(&self) -> bool {
71: 69:         false
72: 70:     }
73: 71: }
74: 72: 
75: 73: impl ToAnySource for AnySource {
76: 74:     fn to_any_source(&self) -> AnySource {
77: 75:         self.clone()
78: 76:     }
79: 77: }
80: 78: 
81: 79: impl Source for AnySource {
82: 80:     fn add_subscriber(&self, subscriber: AnySubscriber) {
83: 81:         if let Some(inner) = self.1.upgrade() {
84: 82:             inner.add_subscriber(subscriber)
85: 83:         }
86: 84:     }
87: 85: 
88: 86:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
89: 87:         if let Some(inner) = self.1.upgrade() {
90: 88:             inner.remove_subscriber(subscriber)
91: 89:         }
92: 90:     }
93: 91: 
94: 92:     fn clear_subscribers(&self) {
95: 93:         if let Some(inner) = self.1.upgrade() {
96: 94:             inner.clear_subscribers();
97: 95:         }
98: 96:     }
99: 97: }
100: 98: 
101: 99: impl ReactiveNode for AnySource {
102: 100:     fn mark_dirty(&self) {
103: 101:         if let Some(inner) = self.1.upgrade() {
104: 102:             inner.mark_dirty()
105: 103:         }
106: 104:     }
107: 105: 
108: 106:     fn mark_subscribers_check(&self) {
109: 107:         if let Some(inner) = self.1.upgrade() {
110: 108:             inner.mark_subscribers_check()
111: 109:         }
112: 110:     }
113: 111: 
114: 112:     fn update_if_necessary(&self) -> bool {
115: 113:         if let Some(inner) = self.1.upgrade() {
116: 114:             inner.update_if_necessary()
117: 115:         } else {
118: 116:             false
119: 117:         }
120: 118:     }
121: 119: 
122: 120:     fn mark_check(&self) {
123: 121:         if let Some(inner) = self.1.upgrade() {
124: 122:             inner.mark_check()
125: 123:         }
126: 124:     }
127: 125: }
128: ```
```
