### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\already_set_error.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\already_set_error.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::{Executor, ExecutorError};
4: 2: 
5: 3: #[test]
6: 4: fn test_already_set_error() {
7: 5:     struct SimpleExecutor;
8: 6: 
9: 7:     impl lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::CustomExecutor for SimpleExecutor {
10: 8:         fn spawn(&self, _fut: lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::PinnedFuture<()>) {}
11: 9:         fn spawn_local(&self, _fut: lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::PinnedLocalFuture<()>) {}
12: 10:         fn poll_local(&self) {}
13: 11:     }
14: 12: 
15: 13:     // First initialization should succeed
16: 14:     Executor::init_custom_executor(SimpleExecutor)
17: 15:         .expect("First initialization failed");
18: 16: 
19: 17:     // Second initialization should fail with AlreadySet error
20: 18:     let result = Executor::init_custom_executor(SimpleExecutor);
21: 19:     assert!(matches!(result, Err(ExecutorError::AlreadySet)));
22: 20: 
23: 21:     // First local initialization should fail
24: 22:     let result = Executor::init_local_custom_executor(SimpleExecutor);
25: 23:     assert!(matches!(result, Err(ExecutorError::AlreadySet)));
26: 24: }
27: ```
```
