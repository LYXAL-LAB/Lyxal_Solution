### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\effect\inner.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\effect\inner.rs
2: ```rust
3: 1: use crate::{
4: 2:     channel::Sender,
5: 3:     graph::{
6: 4:         AnySource, AnySubscriber, ReactiveNode, SourceSet, Subscriber,
7: 5:         ToAnySubscriber,
8: 6:     },
9: 7: };
10: 8: use lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned::OrPoisoned;
11: 9: use std::sync::{Arc, RwLock, Weak};
12: 10: 
13: 11: /// Handles internal subscription logic for effects.
14: 12: #[derive(Debug)]
15: 13: pub struct EffectInner {
16: 14:     pub(crate) dirty: bool,
17: 15:     pub(crate) oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server: Sender,
18: 16:     pub(crate) sources: SourceSet,
19: 17: }
20: 18: 
21: 19: impl ToAnySubscriber for Arc<RwLock<EffectInner>> {
22: 20:     fn to_any_subscriber(&self) -> AnySubscriber {
23: 21:         AnySubscriber(
24: 22:             Arc::as_ptr(self) as usize,
25: 23:             Arc::downgrade(self) as Weak<dyn Subscriber + Send + Sync>,
26: 24:         )
27: 25:     }
28: 26: }
29: 27: 
30: 28: impl ReactiveNode for RwLock<EffectInner> {
31: 29:     fn mark_subscribers_check(&self) {}
32: 30: 
33: 31:     fn update_if_necessary(&self) -> bool {
34: 32:         let mut guard = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
35: 33: 
36: 34:         if guard.dirty {
37: 35:             guard.dirty = false;
38: 36:             return true;
39: 37:         }
40: 38: 
41: 39:         let sources = guard.sources.clone();
42: 40: 
43: 41:         drop(guard);
44: 42: 
45: 43:         sources
46: 44:             .into_iter()
47: 45:             .any(|source| source.update_if_necessary())
48: 46:     }
49: 47: 
50: 48:     fn mark_check(&self) {
51: 49:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.notify()
52: 50:     }
53: 51: 
54: 52:     fn mark_dirty(&self) {
55: 53:         let mut lock = self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned();
56: 54:         lock.dirty = true;
57: 55:         lock.oblyx-platform-lyx_platform_lyx-platform-lyx_platform_server.notify()
58: 56:     }
59: 57: }
60: 58: 
61: 59: impl Subscriber for RwLock<EffectInner> {
62: 60:     fn add_source(&self, source: AnySource) {
63: 61:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().sources.insert(source);
64: 62:     }
65: 63: 
66: 64:     fn clear_sources(&self, subscriber: &AnySubscriber) {
67: 65:         self.write().lyx-core-lyx_core_lyx-core-lyx_core_or_poisoned().sources.clear_sources(subscriber);
68: 66:     }
69: 67: }
70: ```
```
