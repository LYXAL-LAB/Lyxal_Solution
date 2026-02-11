### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\arc_trigger.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\arc_trigger.rs
2: ```rust
3: 1: use super::subscriber_traits::AsSubscriberSet;
4: 2: use crate::{
5: 3:     graph::{ReactiveNode, SubscriberSet},
6: 4:     traits::{DefinedAt, IsDisposed, Notify, Track},
7: 5: };
8: 6: use std::{
9: 7:     fmt::{Debug, Formatter, Result},
10: 8:     panic::Location,
11: 9:     sync::{Arc, RwLock},
12: 10: };
13: 11: 
14: 12: /// A trigger is a data-less signal with the sole purpose of notifying other reactive code of a change.
15: 13: ///
16: 14: /// This can be useful for when using external data not stored in signals, for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.
17: 15: pub struct ArcTrigger {
18: 16:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
19: 17:     pub(crate) defined_at: &'static Location<'static>,
20: 18:     pub(crate) inner: Arc<RwLock<SubscriberSet>>,
21: 19: }
22: 20: 
23: 21: impl ArcTrigger {
24: 22:     /// Creates a new trigger.
25: 23:     #[track_caller]
26: 24:     pub fn new() -> Self {
27: 25:         Self {
28: 26:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
29: 27:             defined_at: Location::caller(),
30: 28:             inner: Default::default(),
31: 29:         }
32: 30:     }
33: 31: }
34: 32: 
35: 33: impl Default for ArcTrigger {
36: 34:     fn default() -> Self {
37: 35:         Self::new()
38: 36:     }
39: 37: }
40: 38: 
41: 39: impl Clone for ArcTrigger {
42: 40:     #[track_caller]
43: 41:     fn clone(&self) -> Self {
44: 42:         Self {
45: 43:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
46: 44:             defined_at: self.defined_at,
47: 45:             inner: Arc::clone(&self.inner),
48: 46:         }
49: 47:     }
50: 48: }
51: 49: 
52: 50: impl Debug for ArcTrigger {
53: 51:     fn fmt(&self, f: &mut Formatter<'_>) -> Result {
54: 52:         f.debug_struct("ArcTrigger").finish()
55: 53:     }
56: 54: }
57: 55: 
58: 56: impl IsDisposed for ArcTrigger {
59: 57:     #[inline(always)]
60: 58:     fn is_disposed(&self) -> bool {
61: 59:         false
62: 60:     }
63: 61: }
64: 62: 
65: 63: impl AsSubscriberSet for ArcTrigger {
66: 64:     type Output = Arc<RwLock<SubscriberSet>>;
67: 65: 
68: 66:     #[inline(always)]
69: 67:     fn as_subscriber_set(&self) -> Option<Self::Output> {
70: 68:         Some(Arc::clone(&self.inner))
71: 69:     }
72: 70: }
73: 71: 
74: 72: impl Notify for Vec<ArcTrigger> {
75: 73:     fn notify(&self) {
76: 74:         for trigger in self {
77: 75:             trigger.notify();
78: 76:         }
79: 77:     }
80: 78: }
81: 79: 
82: 80: impl Track for Vec<ArcTrigger> {
83: 81:     fn track(&self) {
84: 82:         for trigger in self {
85: 83:             trigger.track();
86: 84:         }
87: 85:     }
88: 86: }
89: 87: 
90: 88: impl DefinedAt for ArcTrigger {
91: 89:     #[inline(always)]
92: 90:     fn defined_at(&self) -> Option<&'static Location<'static>> {
93: 91:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
94: 92:         {
95: 93:             Some(self.defined_at)
96: 94:         }
97: 95:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
98: 96:         {
99: 97:             None
100: 98:         }
101: 99:     }
102: 100: }
103: 101: 
104: 102: impl Notify for ArcTrigger {
105: 103:     fn notify(&self) {
106: 104:         self.inner.mark_dirty();
107: 105:     }
108: 106: }
109: ```
```
