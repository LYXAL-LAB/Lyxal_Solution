### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\custom_runtime.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\custom_runtime.rs
2: ```rust
3: 1: #![cfg(feature = "futures-executor")]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::{CustomExecutor, Executor, PinnedFuture, PinnedLocalFuture};
6: 4: 
7: 5: #[test]
8: 6: fn can_create_custom_executor() {
9: 7:     use futures::{
10: 8:         executor::{LocalPool, LocalSpawner},
11: 9:         task::LocalSpawnExt,
12: 10:     };
13: 11:     use std::{
14: 12:         cell::RefCell,
15: 13:         sync::{
16: 14:             atomic::{AtomicUsize, Ordering},
17: 15:             Arc,
18: 16:         },
19: 17:     };
20: 18: 
21: 19:     thread_local! {
22: 20:         static LOCAL_POOL: RefCell<LocalPool> = RefCell::new(LocalPool::new());
23: 21:         static SPAWNER: LocalSpawner = LOCAL_POOL.with(|pool| pool.borrow().spawner());
24: 22:     }
25: 23: 
26: 24:     struct CustomFutureExecutor;
27: 25:     impl CustomExecutor for CustomFutureExecutor {
28: 26:         fn spawn(&self, _fut: PinnedFuture<()>) {
29: 27:             panic!("not supported in this test");
30: 28:         }
31: 29: 
32: 30:         fn spawn_local(&self, fut: PinnedLocalFuture<()>) {
33: 31:             SPAWNER.with(|spawner| {
34: 32:                 spawner.spawn_local(fut).expect("failed to spawn future");
35: 33:             });
36: 34:         }
37: 35: 
38: 36:         fn poll_local(&self) {
39: 37:             LOCAL_POOL.with(|pool| {
40: 38:                 if let Ok(mut pool) = pool.try_borrow_mut() {
41: 39:                     pool.run_until_stalled();
42: 40:                 }
43: 41:                 // If we couldn't borrow_mut, we're in a nested call to poll, so we don't need to do anything.
44: 42:             });
45: 43:         }
46: 44:     }
47: 45: 
48: 46:     Executor::init_custom_executor(CustomFutureExecutor)
49: 47:         .expect("couldn't set executor");
50: 48: 
51: 49:     let counter = Arc::new(AtomicUsize::new(0));
52: 50:     let counter_clone = Arc::clone(&counter);
53: 51:     Executor::spawn_local(async move {
54: 52:         counter_clone.store(1, Ordering::Release);
55: 53:     });
56: 54:     Executor::poll_local();
57: 55:     assert_eq!(counter.load(Ordering::Acquire), 1);
58: 56: }
59: ```
```
