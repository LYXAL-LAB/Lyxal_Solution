### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\custom_executor.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\custom_executor.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
4: 2: use std::sync::{
5: 3:     atomic::{AtomicBool, Ordering},
6: 4:     Arc,
7: 5: };
8: 6: 
9: 7: #[test]
10: 8: fn test_custom_executor() {
11: 9:     // Define a simple custom executor
12: 10:     struct TestExecutor {
13: 11:         spawn_called: Arc<AtomicBool>,
14: 12:         spawn_local_called: Arc<AtomicBool>,
15: 13:         poll_local_called: Arc<AtomicBool>,
16: 14:     }
17: 15: 
18: 16:     impl lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::CustomExecutor for TestExecutor {
19: 17:         fn spawn(&self, fut: lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::PinnedFuture<()>) {
20: 18:             self.spawn_called.store(true, Ordering::SeqCst);
21: 19:             // Execute the future immediately (this works for simple test futures)
22: 20:             futures::executor::block_on(fut);
23: 21:         }
24: 22: 
25: 23:         fn spawn_local(&self, fut: lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::PinnedLocalFuture<()>) {
26: 24:             self.spawn_local_called.store(true, Ordering::SeqCst);
27: 25:             // Execute the future immediately
28: 26:             futures::executor::block_on(fut);
29: 27:         }
30: 28: 
31: 29:         fn poll_local(&self) {
32: 30:             self.poll_local_called.store(true, Ordering::SeqCst);
33: 31:         }
34: 32:     }
35: 33: 
36: 34:     let spawn_called = Arc::new(AtomicBool::new(false));
37: 35:     let spawn_local_called = Arc::new(AtomicBool::new(false));
38: 36:     let poll_local_called = Arc::new(AtomicBool::new(false));
39: 37: 
40: 38:     let executor = TestExecutor {
41: 39:         spawn_called: spawn_called.clone(),
42: 40:         spawn_local_called: spawn_local_called.clone(),
43: 41:         poll_local_called: poll_local_called.clone(),
44: 42:     };
45: 43: 
46: 44:     // Initialize with our custom executor
47: 45:     Executor::init_custom_executor(executor)
48: 46:         .expect("Failed to initialize custom executor");
49: 47: 
50: 48:     // Test spawn
51: 49:     Executor::spawn(async {
52: 50:         // Simple task
53: 51:     });
54: 52:     assert!(spawn_called.load(Ordering::SeqCst));
55: 53: 
56: 54:     // Test spawn_local
57: 55:     Executor::spawn_local(async {
58: 56:         // Simple local task
59: 57:     });
60: 58:     assert!(spawn_local_called.load(Ordering::SeqCst));
61: 59: 
62: 60:     // Test poll_local
63: 61:     Executor::poll_local();
64: 62:     assert!(poll_local_called.load(Ordering::SeqCst));
65: 63: }
66: ```
```
