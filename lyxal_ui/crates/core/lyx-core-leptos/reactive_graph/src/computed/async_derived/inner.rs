### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\computed\async_derived\inner.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\computed\async_derived\inner.rs
2: ```rust
3: 1: use super::suspense::TaskHandle;
4: 2: use crate::{
5: 3:     channel::Sender,
6: 4:     computed::suspense::SuspenseContext,
7: 5:     graph::{
8: 6:         AnySource, AnySubscriber, ReactiveNode, Source, SourceSet, Subscriber,
9: 7:         SubscriberSet,
10: 8:     },
11: 9:     owner::Owner,
12: 10: };
13: 11: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
14: 12: use std::sync::RwLock;
15: 13: 
16: 14: pub(crate) struct ArcAsyncDerivedInner {
17: 15:     pub owner: Owner,
18: 16:     // holds subscribers so the dependency can be cleared when this needs to rerun
19: 17:     pub sources: SourceSet,
20: 18:     // tracks reactive subscribers so they can be notified
21: 19:     // when the new async value is ready
22: 20:     pub subscribers: SubscriberSet,
23: 21:     // when a source changes, notifying this will cause the async work to rerun
24: 22:     pub notifier: Sender,
25: 23:     pub state: AsyncDerivedState,
26: 24:     pub version: usize,
27: 25:     pub suspenses: Vec<SuspenseContext>,
28: 26:     pub pending_suspenses: Vec<TaskHandle>,
29: 27: }
30: 28: 
31: 29: #[derive(Debug, PartialEq, Eq)]
32: 30: pub(crate) enum AsyncDerivedState {
33: 31:     Clean,
34: 32:     Dirty,
35: 33:     Notifying,
36: 34: }
37: 35: 
38: 36: impl ReactiveNode for RwLock<ArcAsyncDerivedInner> {
39: 37:     fn mark_dirty(&self) {
40: 38:         let mut lock = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
41: 39:         if lock.state != AsyncDerivedState::Notifying {
42: 40:             lock.state = AsyncDerivedState::Dirty;
43: 41:             lock.notifier.notify();
44: 42:         }
45: 43:     }
46: 44: 
47: 45:     fn mark_check(&self) {
48: 46:         let mut lock = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
49: 47:         if lock.state != AsyncDerivedState::Notifying {
50: 48:             lock.notifier.notify();
51: 49:         }
52: 50:     }
53: 51: 
54: 52:     fn mark_subscribers_check(&self) {
55: 53:         let lock = self.read().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
56: 54:         for sub in (&lock.subscribers).into_iter() {
57: 55:             sub.mark_check();
58: 56:         }
59: 57:     }
60: 58: 
61: 59:     fn update_if_necessary(&self) -> bool {
62: 60:         let mut guard = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
63: 61:         let (is_dirty, sources) = (
64: 62:             guard.state == AsyncDerivedState::Dirty,
65: 63:             (guard.state != AsyncDerivedState::Notifying)
66: 64:                 .then(|| guard.sources.clone()),
67: 65:         );
68: 66: 
69: 67:         if is_dirty {
70: 68:             guard.state = AsyncDerivedState::Clean;
71: 69:             return true;
72: 70:         }
73: 71:         drop(guard);
74: 72: 
75: 73:         for source in sources.into_iter().flatten() {
76: 74:             if source.update_if_necessary() {
77: 75:                 return true;
78: 76:             }
79: 77:         }
80: 78:         false
81: 79:     }
82: 80: }
83: 81: 
84: 82: impl Source for RwLock<ArcAsyncDerivedInner> {
85: 83:     fn add_subscriber(&self, subscriber: AnySubscriber) {
86: 84:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().subscribers.subscribe(subscriber);
87: 85:     }
88: 86: 
89: 87:     fn remove_subscriber(&self, subscriber: &AnySubscriber) {
90: 88:         self.write()
91: 89:             .lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned()
92: 90:             .subscribers
93: 91:             .unsubscribe(subscriber);
94: 92:     }
95: 93: 
96: 94:     fn clear_subscribers(&self) {
97: 95:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().subscribers.take();
98: 96:     }
99: 97: }
100: 98: 
101: 99: impl Subscriber for RwLock<ArcAsyncDerivedInner> {
102: 100:     fn add_source(&self, source: AnySource) {
103: 101:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().sources.insert(source);
104: 102:     }
105: 103: 
106: 104:     fn clear_sources(&self, subscriber: &AnySubscriber) {
107: 105:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().sources.clear_sources(subscriber);
108: 106:     }
109: 107: }
110: ```
```
