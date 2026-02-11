### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\subscriber_traits.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\subscriber_traits.rs
2: ```rust
3: 1: //! Traits to reduce the boilerplate when implementing the [`ReactiveNode`], [`Source`], and
4: 2: //! [`ToAnySource`] traits for signal types.
5: 3: //!
6: 4: //! These traits can be automatically derived for any type that
7: 5: //! 1) is a root node in the reactive graph, with no sources (i.e., a signal, not a memo)
8: 6: //! 2) contains an `Arc<RwLock<SubscriberSet>>`
9: 7: //!
10: 8: //! This makes it easy to implement a variety of different signal primitives, as long as they share
11: 9: //! these characteristics.
12: 10: 
13: 11: use crate::{
14: 12:     graph::{
15: 13:         AnySource, AnySubscriber, ReactiveNode, Source, SubscriberSet,
16: 14:         ToAnySource,
17: 15:     },
18: 16:     traits::{DefinedAt, IsDisposed},
19: 17:     unwrap_signal,
20: 18: };
21: 19: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
22: 20: use std::{
23: 21:     borrow::Borrow,
24: 22:     sync::{Arc, RwLock, Weak},
25: 23: };
26: 24: 
27: 25: pub(crate) trait AsSubscriberSet {
28: 26:     type Output: Borrow<RwLock<SubscriberSet>>;
29: 27: 
30: 28:     fn as_subscriber_set(&self) -> Option<Self::Output>;
31: 29: }
32: 30: 
33: 31: impl<'a> AsSubscriberSet for &'a RwLock<SubscriberSet> {
34: 32:     type Output = &'a RwLock<SubscriberSet>;
35: 33: 
36: 34:     #[inline(always)]
37: 35:     fn as_subscriber_set(&self) -> Option<Self::Output> {
38: 36:         Some(self)
39: 37:     }
40: 38: }
41: 39: 
42: 40: impl DefinedAt for RwLock<SubscriberSet> {
43: 41:     fn defined_at(&self) -> Option<&'static std::panic::Location<'static>> {
44: 42:         None
45: 43:     }
46: 44: }
47: 45: 
48: 46: // Implement reactive types for RwLock<SubscriberSet>
49: 47: // This is used so that Weak<RwLock<SubscriberSet>> is a Weak<dyn ReactiveNode> and Weak<dyn
50: 48: // Source>
51: 49: impl<T: AsSubscriberSet + DefinedAt> ReactiveNode for T {
52: 50:     fn mark_dirty(&self) {
53: 51:         self.mark_subscribers_check();
54: 52:     }
55: 53: 
56: 54:     fn mark_check(&self) {}
57: 55: 
58: 56:     fn mark_subscribers_check(&self) {
59: 57:         if let Some(inner) = self.as_subscriber_set() {
60: 58:             let subs = inner.borrow().read().unwrap().clone();
61: 59:             for sub in subs {
62: 60:                 sub.mark_dirty();
63: 61:             }
64: 62:         }
65: 63:     }
66: 64: 
67: 65:     fn update_if_necessary(&self) -> bool {
68: 66:         // a signal will always mark its dependents Dirty when it runs, so they know
69: 67:         // that they may have changed and need to check themselves at least
70: 68:         //
71: 69:         // however, it's always possible that *another* signal or memo has triggered any
72: 70:         // given effect/memo, and so this signal should *not* say that it is dirty, as it
73: 71:         // may also be checked but has not changed
74: 72:         false
75: 73:     }
76: 74: }
77: 75: 
78: 76: impl<T: AsSubscriberSet + DefinedAt> Source for T {
79: 77:     fn clear_subscribers(&self) {
80: 78:         if let Some(inner) = self.as_subscriber_set() {
81: 79:             inner.borrow().write().unwrap().take();
82: 80:         }
83: 81:     }
84: 82: 
85: 83:     fn add_subscriber(&self, subscriber: AnySubscriber) {
86: 84:         if let Some(inner) = self.as_subscriber_set() {
87: 85:             inner.borrow().write().unwrap().subscribe(subscriber)
88: 86:         }
89: 87:     }
90: 88: 
91: 89:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
92: 90:         if let Some(inner) = self.as_subscriber_set() {
93: 91:             inner.borrow().write().unwrap().unsubscribe(subscriber)
94: 92:         }
95: 93:     }
96: 94: }
97: 95: 
98: 96: impl<T: AsSubscriberSet + DefinedAt + IsDisposed> ToAnySource for T
99: 97: where
100: 98:     T::Output: Borrow<Arc<RwLock<SubscriberSet>>>,
101: 99: {
102: 100:     #[track_caller]
103: 101:     fn to_any_source(&self) -> AnySource {
104: 102:         self.as_subscriber_set()
105: 103:             .map(|subs| {
106: 104:                 let subs = subs.borrow();
107: 105:                 AnySource(
108: 106:                     Arc::as_ptr(subs) as usize,
109: 107:                     Arc::downgrade(subs) as Weak<dyn Source + Send + Sync>,
110: 108:                     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
111: 109:                     self.defined_at().expect("no DefinedAt in debug mode"),
112: 110:                 )
113: 111:             })
114: 112:             .unwrap_or_else(unwrap_signal!(self))
115: 113:     }
116: 114: }
117: 115: 
118: 116: impl ReactiveNode for RwLock<SubscriberSet> {
119: 117:     fn mark_dirty(&self) {
120: 118:         self.mark_subscribers_check();
121: 119:     }
122: 120: 
123: 121:     fn mark_check(&self) {}
124: 122: 
125: 123:     fn mark_subscribers_check(&self) {
126: 124:         let subs = self.write().unwrap().take();
127: 125:         for sub in subs {
128: 126:             sub.mark_dirty();
129: 127:         }
130: 128:     }
131: 129: 
132: 130:     fn update_if_necessary(&self) -> bool {
133: 131:         // a signal will always mark its dependents Dirty when it runs, so they know
134: 132:         // that they may have changed and need to check themselves at least
135: 133:         //
136: 134:         // however, it's always possible that *another* signal or memo has triggered any
137: 135:         // given effect/memo, and so this signal should *not* say that it is dirty, as it
138: 136:         // may also be checked but has not changed
139: 137:         false
140: 138:     }
141: 139: }
142: 140: 
143: 141: impl Source for RwLock<SubscriberSet> {
144: 142:     fn clear_subscribers(&self) {
145: 143:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().take();
146: 144:     }
147: 145: 
148: 146:     fn add_subscriber(&self, subscriber: AnySubscriber) {
149: 147:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().subscribe(subscriber)
150: 148:     }
151: 149: 
152: 150:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
153: 151:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().unsubscribe(subscriber)
154: 152:     }
155: 153: }
156: ```
```
