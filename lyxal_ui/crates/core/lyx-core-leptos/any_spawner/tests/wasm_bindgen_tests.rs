### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\wasm_bindgen_tests.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\wasm_bindgen_tests.rs
2: ```rust
3: 1: #![cfg(all(feature = "wasm-bindgen", target_family = "wasm"))]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4: use futures::channel::oneshot;
7: 5: use std::sync::{
8: 6:     atomic::{AtomicBool, Ordering},
9: 7:     Arc,
10: 8: };
11: 9: use wasm_bindgen_test::*;
12: 10: 
13: 11: wasm_bindgen_test_configure!(run_in_browser);
14: 12: 
15: 13: #[wasm_bindgen_test]
16: 14: async fn test_wasm_bindgen_spawn_local() {
17: 15:     // Initialize the wasm-bindgen executor
18: 16:     let _ = Executor::init_wasm_bindgen();
19: 17: 
20: 18:     // Create a channel to verify the task completes
21: 19:     let (tx, rx) = oneshot::channel();
22: 20: 
23: 21:     // Spawn a local task (wasm doesn't support sending futures between threads)
24: 22:     Executor::spawn_local(async move {
25: 23:         // Simulate some async work
26: 24:         Executor::tick().await;
27: 25:         tx.send(42).expect("Failed to send result");
28: 26:     });
29: 27: 
30: 28:     // Wait for the task to complete
31: 29:     let result = rx.await.expect("Failed to receive result");
32: 30:     assert_eq!(result, 42);
33: 31: }
34: 32: 
35: 33: #[wasm_bindgen_test]
36: 34: async fn test_wasm_bindgen_tick() {
37: 35:     // Initialize the wasm-bindgen executor if not already initialized
38: 36:     let _ = Executor::init_wasm_bindgen();
39: 37: 
40: 38:     let flag = Arc::new(AtomicBool::new(false));
41: 39:     let flag_clone = flag.clone();
42: 40: 
43: 41:     // Spawn a task that will set the flag
44: 42:     Executor::spawn_local(async move {
45: 43:         flag_clone.store(true, Ordering::SeqCst);
46: 44:     });
47: 45: 
48: 46:     // Wait for a tick, which should allow the spawned task to run
49: 47:     Executor::tick().await;
50: 48: 
51: 49:     // Verify the flag was set
52: 50:     assert!(flag.load(Ordering::SeqCst));
53: 51: }
54: 52: 
55: 53: #[wasm_bindgen_test]
56: 54: async fn test_multiple_wasm_bindgen_tasks() {
57: 55:     // Initialize once for all tests
58: 56:     let _ = Executor::init_wasm_bindgen();
59: 57: 
60: 58:     // Create channels for multiple tasks
61: 59:     let (tx1, rx1) = oneshot::channel();
62: 60:     let (tx2, rx2) = oneshot::channel();
63: 61: 
64: 62:     // Spawn multiple tasks
65: 63:     Executor::spawn_local(async move {
66: 64:         tx1.send("task1").expect("Failed to send from task1");
67: 65:     });
68: 66: 
69: 67:     Executor::spawn_local(async move {
70: 68:         tx2.send("task2").expect("Failed to send from task2");
71: 69:     });
72: 70: 
73: 71:     // Wait for both tasks to complete
74: 72:     let (result1, result2) = futures::join!(rx1, rx2);
75: 73: 
76: 74:     assert_eq!(result1.unwrap(), "task1");
77: 75:     assert_eq!(result2.unwrap(), "task2");
78: 76: }
79: 77: 
80: 78: // This test verifies that spawn (not local) fails on wasm as expected
81: 79: #[wasm_bindgen_test]
82: 80: #[should_panic]
83: 81: fn test_wasm_bindgen_spawn_errors() {
84: 82:     let _ = Executor::init_wasm_bindgen();
85: 83: 
86: 84:     // Using should_panic to test that Executor::spawn panics in wasm
87: 85:     Executor::spawn(async {
88: 86:         // This should panic since wasm-bindgen doesn't support Send futures
89: 87:     });
90: 88: }
91: ```
```
