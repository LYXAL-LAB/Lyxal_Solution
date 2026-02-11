### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\futures_runtime.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\futures_runtime.rs
2: ```rust
3: 1: #![cfg(feature = "futures-executor")]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4: // All tests in this file use the same executor.
7: 5: 
8: 6: #[test]
9: 7: fn can_spawn_local_future() {
10: 8:     use std::rc::Rc;
11: 9: 
12: 10:     let _ = Executor::init_futures_executor();
13: 11:     let rc = Rc::new(());
14: 12:     Executor::spawn_local(async {
15: 13:         _ = rc;
16: 14:     });
17: 15:     Executor::spawn(async {});
18: 16: }
19: 17: 
20: 18: #[test]
21: 19: fn can_make_local_progress() {
22: 20:     use std::sync::{
23: 21:         atomic::{AtomicUsize, Ordering},
24: 22:         Arc,
25: 23:     };
26: 24:     let _ = Executor::init_futures_executor();
27: 25:     let counter = Arc::new(AtomicUsize::new(0));
28: 26:     Executor::spawn_local({
29: 27:         let counter = Arc::clone(&counter);
30: 28:         async move {
31: 29:             assert_eq!(counter.fetch_add(1, Ordering::AcqRel), 0);
32: 30:             Executor::spawn_local(async {
33: 31:                 // Should not crash
34: 32:             });
35: 33:         }
36: 34:     });
37: 35:     Executor::poll_local();
38: 36:     assert_eq!(counter.load(Ordering::Acquire), 1);
39: 37: }
40: ```
```
