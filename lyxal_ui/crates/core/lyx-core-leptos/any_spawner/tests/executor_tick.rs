### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\executor_tick.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\executor_tick.rs
2: ```rust
3: 1: #![cfg(feature = "tokio")]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4: use std::{
7: 5:     sync::{Arc, Mutex},
8: 6:     time::Duration,
9: 7: };
10: 8: 
11: 9: #[tokio::test]
12: 10: async fn test_executor_tick() {
13: 11:     // Initialize the tokio executor
14: 12:     Executor::init_tokio().expect("Failed to initialize tokio executor");
15: 13: 
16: 14:     let value = Arc::new(Mutex::new(false));
17: 15:     let value_clone = value.clone();
18: 16: 
19: 17:     // Spawn a task that sets the value after a tick
20: 18:     Executor::spawn(async move {
21: 19:         Executor::tick().await;
22: 20:         *value_clone.lock().unwrap() = true;
23: 21:     });
24: 22: 
25: 23:     // Allow some time for the task to complete
26: 24:     tokio::time::sleep(Duration::from_millis(50)).await;
27: 25: 
28: 26:     // Check that the value was set
29: 27:     assert!(*value.lock().unwrap());
30: 28: }
31: ```
```
