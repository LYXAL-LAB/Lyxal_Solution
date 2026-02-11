### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\src\diagnostics.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\src\diagnostics.rs
2: ```rust
3: 1: //! By default, attempting to [`Track`](crate::traits::Track) a signal when you are not in a
4: 2: //! reactive tracking context will cause a warning when you are in debug mode.
5: 3: //!
6: 4: //! In some cases, this warning is a false positive. For lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, inside an event listener in a
7: 5: //! user interface, you never want to read from a signal reactively; the event listener should run
8: 6: //! when the event fires, not when a signal read in the event listener changes.
9: 7: //!
10: 8: //! This module provides utilities to suppress those warnings by entering a
11: 9: //! [`SpecialNonReactiveZone`].
12: 10: 
13: 11: /// Marks an execution block that is known not to be reactive, and suppresses warnings.
14: 12: #[derive(Debug)]
15: 13: pub struct SpecialNonReactiveZone;
16: 14: 
17: 15: /// Exits the "special non-reactive zone" when dropped.
18: 16: #[derive(Debug)]
19: 17: pub struct SpecialNonReactiveZoneGuard(bool);
20: 18: 
21: 19: use pin_project_lite::pin_project;
22: 20: use std::{
23: 21:     cell::Cell,
24: 22:     future::Future,
25: 23:     pin::Pin,
26: 24:     task::{Context, Poll},
27: 25: };
28: 26: 
29: 27: thread_local! {
30: 28:     static IS_SPECIAL_ZONE: Cell<bool> = const { Cell::new(false) };
31: 29: }
32: 30: 
33: 31: impl SpecialNonReactiveZone {
34: 32:     /// Suppresses warnings about non-reactive accesses until the guard is dropped.
35: 33:     pub fn enter() -> SpecialNonReactiveZoneGuard {
36: 34:         let prev = IS_SPECIAL_ZONE.replace(true);
37: 35:         SpecialNonReactiveZoneGuard(prev)
38: 36:     }
39: 37: 
40: 38:     #[cfg(all(debug_assertions, feature = "effects"))]
41: 39:     #[inline(always)]
42: 40:     pub(crate) fn is_inside() -> bool {
43: 41:         if cfg!(debug_assertions) {
44: 42:             IS_SPECIAL_ZONE.get()
45: 43:         } else {
46: 44:             false
47: 45:         }
48: 46:     }
49: 47: }
50: 48: 
51: 49: impl Drop for SpecialNonReactiveZoneGuard {
52: 50:     fn drop(&mut self) {
53: 51:         IS_SPECIAL_ZONE.set(self.0);
54: 52:     }
55: 53: }
56: 54: 
57: 55: pin_project! {
58: 56:     #[doc(hidden)]
59: 57:     pub struct SpecialNonReactiveFuture<Fut> {
60: 58:         #[pin]
61: 59:         inner: Fut
62: 60:     }
63: 61: }
64: 62: 
65: 63: impl<Fut> SpecialNonReactiveFuture<Fut> {
66: 64:     pub fn new(inner: Fut) -> Self {
67: 65:         Self { inner }
68: 66:     }
69: 67: }
70: 68: 
71: 69: impl<Fut> Future for SpecialNonReactiveFuture<Fut>
72: 70: where
73: 71:     Fut: Future,
74: 72: {
75: 73:     type Output = Fut::Output;
76: 74: 
77: 75:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
78: 76:         #[cfg(debug_assertions)]
79: 77:         let _rw = SpecialNonReactiveZone::enter();
80: 78:         let this = self.project();
81: 79:         this.inner.poll(cx)
82: 80:     }
83: 81: }
84: 82: 
85: 83: thread_local! {
86: 84:     static SUPPRESS_RESOURCE_LOAD: Cell<bool> = const { Cell::new(false) };
87: 85: }
88: 86: 
89: 87: #[doc(hidden)]
90: 88: pub fn suppress_resource_load(suppress: bool) {
91: 89:     SUPPRESS_RESOURCE_LOAD.with(|w| w.set(suppress));
92: 90: }
93: 91: 
94: 92: #[doc(hidden)]
95: 93: pub fn is_suppressing_resource_load() -> bool {
96: 94:     SUPPRESS_RESOURCE_LOAD.with(|w| w.get())
97: 95: }
98: ```
```
