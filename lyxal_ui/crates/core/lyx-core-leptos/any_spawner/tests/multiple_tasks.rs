### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\multiple_tasks.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\multiple_tasks.rs
2: ```rust
3: 1: #![cfg(feature = "tokio")]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4: use futures::channel::oneshot;
7: 5: use std::sync::{Arc, Mutex};
8: 6: 
9: 7: #[tokio::test]
10: 8: async fn test_multiple_tasks() {
11: 9:     Executor::init_tokio().expect("Failed to initialize tokio executor");
12: 10: 
13: 11:     let counter = Arc::new(Mutex::new(0));
14: 12:     let tasks = 10;
15: 13:     let mut handles = Vec::new();
16: 14: 
17: 15:     // Spawn multiple tasks that increment the counter
18: 16:     for _ in 0..tasks {
19: 17:         let counter_clone = counter.clone();
20: 18:         let (tx, rx) = oneshot::channel();
21: 19: 
22: 20:         Executor::spawn(async move {
23: 21:             *counter_clone.lock().unwrap() += 1;
24: 22:             tx.send(()).expect("Failed to send completion signal");
25: 23:         });
26: 24: 
27: 25:         handles.push(rx);
28: 26:     }
29: 27: 
30: 28:     // Wait for all tasks to complete
31: 29:     for handle in handles {
32: 30:         handle.await.expect("Task failed");
33: 31:     }
34: 32: 
35: 33:     // Verify that all tasks incremented the counter
36: 34:     assert_eq!(*counter.lock().unwrap(), tasks);
37: 35: }
38: ```
```
