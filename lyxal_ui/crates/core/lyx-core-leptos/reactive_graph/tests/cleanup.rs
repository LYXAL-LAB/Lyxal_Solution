### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\tests\cleanup.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\tests\cleanup.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
4: 2:     computed::Memo,
5: 3:     owner::{on_cleanup, Owner},
6: 4:     signal::{RwSignal, Trigger},
7: 5:     traits::{Dispose, GetUntracked, Track},
8: 6: };
9: 7: use std::sync::Arc;
10: 8: 
11: 9: #[test]
12: 10: fn cleanup_on_dispose() {
13: 11:     let owner = Owner::new();
14: 12:     owner.set();
15: 13: 
16: 14:     struct ExecuteOnDrop(Option<Box<dyn FnOnce() + Send + Sync>>);
17: 15: 
18: 16:     impl ExecuteOnDrop {
19: 17:         fn new(f: impl FnOnce() + Send + Sync + 'static) -> Self {
20: 18:             Self(Some(Box::new(f)))
21: 19:         }
22: 20:     }
23: 21:     impl Drop for ExecuteOnDrop {
24: 22:         fn drop(&mut self) {
25: 23:             self.0.take().unwrap()();
26: 24:         }
27: 25:     }
28: 26: 
29: 27:     let trigger = Trigger::new();
30: 28: 
31: 29:     println!("STARTING");
32: 30: 
33: 31:     let memo = Memo::new(move |_| {
34: 32:         trigger.track();
35: 33: 
36: 34:         // An lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example of why you might want to do this is that
37: 35:         // when something goes out of reactive scope you want it to be cleaned up.
38: 36:         // The cleaning up might have side effects, and those side effects might cause
39: 37:         // re-renders where new `on_cleanup` are registered.
40: 38:         let on_drop = ExecuteOnDrop::new(|| {
41: 39:             on_cleanup(|| println!("Nested cleanup in progress."))
42: 40:         });
43: 41: 
44: 42:         on_cleanup(move || {
45: 43:             println!("Cleanup in progress.");
46: 44:             drop(on_drop)
47: 45:         });
48: 46:     });
49: 47:     println!("Memo 1: {memo:?}");
50: 48:     memo.get_untracked(); // First cleanup registered.
51: 49: 
52: 50:     memo.dispose(); // Cleanup not run here.
53: 51: 
54: 52:     println!("Cleanup should have been executed.");
55: 53: 
56: 54:     let memo = Memo::new(move |_| {
57: 55:         // New cleanup registered. It'll panic here.
58: 56:         on_cleanup(move || println!("Test passed."));
59: 57:     });
60: 58:     println!("Memo 2: {memo:?}");
61: 59:     println!("^ Note how the memos have the same key (different versions).");
62: 60:     memo.get_untracked(); // First cleanup registered.
63: 61: 
64: 62:     println!("Test passed.");
65: 63: 
66: 64:     memo.dispose();
67: 65: }
68: 66: 
69: 67: #[test]
70: 68: fn leak_on_dispose() {
71: 69:     let owner = Owner::new();
72: 70:     owner.set();
73: 71: 
74: 72:     let trigger = Trigger::new();
75: 73: 
76: 74:     let value = Arc::new(());
77: 75:     let weak = Arc::downgrade(&value);
78: 76: 
79: 77:     let memo = Memo::new(move |_| {
80: 78:         trigger.track();
81: 79: 
82: 80:         RwSignal::new(value.clone());
83: 81:     });
84: 82: 
85: 83:     memo.get_untracked();
86: 84: 
87: 85:     memo.dispose();
88: 86: 
89: 87:     assert!(weak.upgrade().is_none()); // Should have been dropped.
90: 88: }
91: ```
```
