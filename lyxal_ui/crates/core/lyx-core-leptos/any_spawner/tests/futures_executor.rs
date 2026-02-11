### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\futures_executor.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\futures_executor.rs
2: ```rust
3: 1: #![cfg(feature = "futures-executor")]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4: use futures::channel::oneshot;
7: 5: use std::{
8: 6:     sync::{Arc, Mutex},
9: 7:     time::Duration,
10: 8: };
11: 9: 
12: 10: #[test]
13: 11: fn test_futures_executor() {
14: 12:     // Initialize the futures executor
15: 13:     Executor::init_futures_executor()
16: 14:         .expect("Failed to initialize futures executor");
17: 15: 
18: 16:     let (tx, rx) = oneshot::channel();
19: 17:     let result = Arc::new(Mutex::new(None));
20: 18:     let result_clone = result.clone();
21: 19: 
22: 20:     // Spawn a task
23: 21:     Executor::spawn(async move {
24: 22:         tx.send(84).expect("Failed to send value");
25: 23:     });
26: 24: 
27: 25:     // Spawn a task that waits for the result
28: 26:     Executor::spawn(async move {
29: 27:         match rx.await {
30: 28:             Ok(val) => *result_clone.lock().unwrap() = Some(val),
31: 29:             Err(_) => panic!("Failed to receive value"),
32: 30:         }
33: 31:     });
34: 32: 
35: 33:     // Poll a few times to ensure the task completes
36: 34:     for _ in 0..10 {
37: 35:         Executor::poll_local();
38: 36:         std::thread::sleep(Duration::from_millis(10));
39: 37: 
40: 38:         if result.lock().unwrap().is_some() {
41: 39:             break;
42: 40:         }
43: 41:     }
44: 42: 
45: 43:     assert_eq!(*result.lock().unwrap(), Some(84));
46: 44: }
47: ```
```
