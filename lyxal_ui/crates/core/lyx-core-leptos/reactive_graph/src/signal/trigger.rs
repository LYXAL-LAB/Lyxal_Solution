### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\signal\trigger.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\signal\trigger.rs
2: ```rust
3: 1: use super::{subscriber_traits::AsSubscriberSet, ArcTrigger};
4: 2: use crate::{
5: 3:     graph::{ReactiveNode, SubscriberSet},
6: 4:     owner::ArenaItem,
7: 5:     traits::{DefinedAt, Dispose, IsDisposed, Notify},
8: 6: };
9: 7: use std::{
10: 8:     fmt::{Debug, Formatter, Result},
11: 9:     panic::Location,
12: 10:     sync::{Arc, RwLock},
13: 11: };
14: 12: 
15: 13: /// A trigger is a data-less signal with the sole purpose of notifying other reactive code of a change.
16: 14: ///
17: 15: /// This can be useful for when using external data not stored in signals, for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.
18: 16: ///
19: 17: /// This is an arena-allocated Trigger, which is `Copy` and is disposed when its reactive
20: 18: /// [`Owner`](crate::owner::Owner) cleans up. For a reference-counted trigger that lives
21: 19: /// as long as a reference to it is alive, see [`ArcTrigger`].
22: 20: pub struct Trigger {
23: 21:     #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
24: 22:     pub(crate) defined_at: &'static Location<'static>,
25: 23:     pub(crate) inner: ArenaItem<ArcTrigger>,
26: 24: }
27: 25: 
28: 26: impl Trigger {
29: 27:     /// Creates a new trigger.
30: 28:     #[track_caller]
31: 29:     pub fn new() -> Self {
32: 30:         Self {
33: 31:             #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
34: 32:             defined_at: Location::caller(),
35: 33:             inner: ArenaItem::new(ArcTrigger::new()),
36: 34:         }
37: 35:     }
38: 36: }
39: 37: 
40: 38: impl Default for Trigger {
41: 39:     fn default() -> Self {
42: 40:         Self::new()
43: 41:     }
44: 42: }
45: 43: 
46: 44: impl Clone for Trigger {
47: 45:     #[track_caller]
48: 46:     fn clone(&self) -> Self {
49: 47:         *self
50: 48:     }
51: 49: }
52: 50: 
53: 51: impl Copy for Trigger {}
54: 52: 
55: 53: impl Debug for Trigger {
56: 54:     fn fmt(&self, f: &mut Formatter<'_>) -> Result {
57: 55:         f.debug_struct("Trigger").finish()
58: 56:     }
59: 57: }
60: 58: 
61: 59: impl Dispose for Trigger {
62: 60:     fn dispose(self) {
63: 61:         self.inner.dispose()
64: 62:     }
65: 63: }
66: 64: 
67: 65: impl IsDisposed for Trigger {
68: 66:     #[inline(always)]
69: 67:     fn is_disposed(&self) -> bool {
70: 68:         self.inner.is_disposed()
71: 69:     }
72: 70: }
73: 71: 
74: 72: impl AsSubscriberSet for Trigger {
75: 73:     type Output = Arc<RwLock<SubscriberSet>>;
76: 74: 
77: 75:     #[inline(always)]
78: 76:     fn as_subscriber_set(&self) -> Option<Self::Output> {
79: 77:         self.inner
80: 78:             .try_get_value()
81: 79:             .and_then(|arc_trigger| arc_trigger.as_subscriber_set())
82: 80:     }
83: 81: }
84: 82: 
85: 83: impl DefinedAt for Trigger {
86: 84:     #[inline(always)]
87: 85:     fn defined_at(&self) -> Option<&'static Location<'static>> {
88: 86:         #[cfg(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo))]
89: 87:         {
90: 88:             Some(self.defined_at)
91: 89:         }
92: 90:         #[cfg(not(any(debug_assertions, lyx-core-lyx_core_lyx-core-lyx_core_leptos_debuginfo)))]
93: 91:         {
94: 92:             None
95: 93:         }
96: 94:     }
97: 95: }
98: 96: 
99: 97: impl Notify for Trigger {
100: 98:     fn notify(&self) {
101: 99:         if let Some(inner) = self.inner.try_get_value() {
102: 100:             inner.mark_dirty();
103: 101:         }
104: 102:     }
105: 103: }
106: ```
```
