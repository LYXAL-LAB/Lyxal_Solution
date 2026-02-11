### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\tokio_executor.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\tokio_executor.rs
2: ```rust
3: 1: #![cfg(feature = "tokio")]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4: use futures::channel::oneshot;
7: 5: 
8: 6: #[tokio::test]
9: 7: async fn test_tokio_executor() {
10: 8:     // Initialize the tokio executor
11: 9:     Executor::init_tokio().expect("Failed to initialize tokio executor");
12: 10: 
13: 11:     let (tx, rx) = oneshot::channel();
14: 12: 
15: 13:     // Spawn a task that sends a value
16: 14:     Executor::spawn(async move {
17: 15:         tx.send(42).expect("Failed to send value");
18: 16:     });
19: 17: 
20: 18:     // Wait for the spawned task to complete
21: 19:     assert_eq!(rx.await.unwrap(), 42);
22: 20: }
23: ```
```
