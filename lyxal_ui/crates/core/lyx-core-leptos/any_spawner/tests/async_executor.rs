### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\async_executor.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\async_executor.rs
2: ```rust
3: 1: #![cfg(feature = "async-executor")]
4: 2: 
5: 3: use std::{
6: 4:     future::Future,
7: 5:     pin::Pin,
8: 6:     sync::{Arc, Mutex},
9: 7: };
10: 8: 
11: 9: // A simple async executor for testing
12: 10: struct TestExecutor {
13: 11:     tasks: Mutex<Vec<Pin<Box<dyn Future<Output = ()> + Send + 'static>>>>,
14: 12: }
15: 13: 
16: 14: impl TestExecutor {
17: 15:     fn new() -> Self {
18: 16:         TestExecutor {
19: 17:             tasks: Mutex::new(Vec::new()),
20: 18:         }
21: 19:     }
22: 20: 
23: 21:     fn spawn<F>(&self, future: F)
24: 22:     where
25: 23:         F: Future<Output = ()> + Send + 'static,
26: 24:     {
27: 25:         self.tasks.lock().unwrap().push(Box::pin(future));
28: 26:     }
29: 27: 
30: 28:     fn run_all(&self) {
31: 29:         // Take all tasks out to process them
32: 30:         let tasks = self.tasks.lock().unwrap().drain(..).collect::<Vec<_>>();
33: 31: 
34: 32:         // Use a lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic future executor to run each task to completion
35: 33:         for mut task in tasks {
36: 34:             // Use futures-lite's block_on to complete the future
37: 35:             futures::executor::block_on(async {
38: 36:                 unsafe {
39: 37:                     let task_mut = Pin::new_unchecked(&mut task);
40: 38:                     let _ = std::future::Future::poll(
41: 39:                         task_mut,
42: 40:                         &mut std::task::Context::from_waker(
43: 41:                             futures::task::noop_waker_ref(),
44: 42:                         ),
45: 43:                     );
46: 44:                 }
47: 45:             });
48: 46:         }
49: 47:     }
50: 48: }
51: 49: 
52: 50: #[test]
53: 51: fn test_async_executor() {
54: 52:     let executor = Arc::new(TestExecutor::new());
55: 53:     let executor_clone = executor.clone();
56: 54: 
57: 55:     // Create a spawner function that will use our test executor
58: 56:     let spawner = move |future| {
59: 57:         executor_clone.spawn(future);
60: 58:     };
61: 59: 
62: 60:     // Prepare test data
63: 61:     let counter = Arc::new(Mutex::new(0));
64: 62:     let counter_clone = counter.clone();
65: 63: 
66: 64:     // Use the spawner to spawn a task
67: 65:     spawner(async move {
68: 66:         *counter_clone.lock().unwrap() += 1;
69: 67:     });
70: 68: 
71: 69:     // Run all tasks
72: 70:     executor.run_all();
73: 71: 
74: 72:     // Check if the task completed correctly
75: 73:     assert_eq!(*counter.lock().unwrap(), 1);
76: 74: }
77: ```
```
