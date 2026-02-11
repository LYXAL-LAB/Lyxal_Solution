### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\local_custom_executor.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\local_custom_executor.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
4: 2: use std::sync::{
5: 3:     atomic::{AtomicBool, Ordering},
6: 4:     Arc,
7: 5: };
8: 6: 
9: 7: #[test]
10: 8: fn test_local_custom_executor() {
11: 9:     // Define a thread-local custom executor
12: 10:     struct LocalTestExecutor {
13: 11:         spawn_called: Arc<AtomicBool>,
14: 12:         spawn_local_called: Arc<AtomicBool>,
15: 13:     }
16: 14: 
17: 15:     impl lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::CustomExecutor for LocalTestExecutor {
18: 16:         fn spawn(&self, fut: lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::PinnedFuture<()>) {
19: 17:             self.spawn_called.store(true, Ordering::SeqCst);
20: 18:             futures::executor::block_on(fut);
21: 19:         }
22: 20: 
23: 21:         fn spawn_local(&self, fut: lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::PinnedLocalFuture<()>) {
24: 22:             self.spawn_local_called.store(true, Ordering::SeqCst);
25: 23:             futures::executor::block_on(fut);
26: 24:         }
27: 25: 
28: 26:         fn poll_local(&self) {
29: 27:             // No-op for this test
30: 28:         }
31: 29:     }
32: 30: 
33: 31:     let local_spawn_called = Arc::new(AtomicBool::new(false));
34: 32:     let local_spawn_local_called = Arc::new(AtomicBool::new(false));
35: 33: 
36: 34:     let local_executor = LocalTestExecutor {
37: 35:         spawn_called: local_spawn_called.clone(),
38: 36:         spawn_local_called: local_spawn_local_called.clone(),
39: 37:     };
40: 38: 
41: 39:     // Initialize a thread-local executor
42: 40:     Executor::init_local_custom_executor(local_executor)
43: 41:         .expect("Failed to initialize local custom executor");
44: 42: 
45: 43:     // Test spawn - should use the thread-local executor
46: 44:     Executor::spawn(async {
47: 45:         // Simple task
48: 46:     });
49: 47:     assert!(local_spawn_called.load(Ordering::SeqCst));
50: 48: 
51: 49:     // Test spawn_local - should use the thread-local executor
52: 50:     Executor::spawn_local(async {
53: 51:         // Simple local task
54: 52:     });
55: 53:     assert!(local_spawn_local_called.load(Ordering::SeqCst));
56: 54: }
57: ```
```
