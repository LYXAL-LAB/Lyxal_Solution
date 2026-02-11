### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_any_spawner\tests\glib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_any_spawner\tests\glib.rs
2: ```rust
3: 1: #![cfg(feature = "glib")]
4: 2: 
5: 3: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4: use glib::{MainContext, MainLoop};
7: 5: use serial_test::serial;
8: 6: use std::{
9: 7:     cell::Cell,
10: 8:     future::Future,
11: 9:     rc::Rc,
12: 10:     sync::{
13: 11:         atomic::{AtomicBool, Ordering},
14: 12:         Arc, Mutex,
15: 13:     },
16: 14:     time::Duration,
17: 15: };
18: 16: 
19: 17: // Helper to run a future to completion on a dedicated glib MainContext.
20: 18: // Returns true if the future completed within the timeout, false otherwise.
21: 19: fn run_on_glib_context<F>(fut: F)
22: 20: where
23: 21:     F: Future<Output = ()> + Send + 'static,
24: 22: {
25: 23:     let _ = Executor::init_glib();
26: 24: 
27: 25:     let context = MainContext::default();
28: 26:     let main_loop = MainLoop::new(Some(&context), false);
29: 27:     let main_loop_clone = main_loop.clone();
30: 28: 
31: 29:     Executor::spawn(async move {
32: 30:         fut.await;
33: 31:         main_loop_clone.quit();
34: 32:     });
35: 33: 
36: 34:     main_loop.run();
37: 35: }
38: 36: 
39: 37: // Helper to run a local (!Send) future on the glib context.
40: 38: fn run_local_on_glib_context<F>(fut: F)
41: 39: where
42: 40:     F: Future<Output = ()> + 'static,
43: 41: {
44: 42:     let _ = Executor::init_glib();
45: 43: 
46: 44:     let context = MainContext::default();
47: 45:     let main_loop = MainLoop::new(Some(&context), false);
48: 46:     let main_loop_clone = main_loop.clone();
49: 47: 
50: 48:     Executor::spawn_local(async move {
51: 49:         fut.await;
52: 50:         main_loop_clone.quit();
53: 51:     });
54: 52: 
55: 53:     main_loop.run();
56: 54: }
57: 55: 
58: 56: // This test must run after a test that successfully initializes glib,
59: 57: // or within its own process.
60: 58: #[test]
61: 59: #[serial]
62: 60: fn test_glib_spawn() {
63: 61:     let success_flag = Arc::new(AtomicBool::new(false));
64: 62:     let flag_clone = success_flag.clone();
65: 63: 
66: 64:     run_on_glib_context(async move {
67: 65:         // Simulate async work
68: 66:         futures_lite::future::yield_now().await;
69: 67:         flag_clone.store(true, Ordering::SeqCst);
70: 68: 
71: 69:         // We need to give the spawned task time to run.
72: 70:         // The run_on_glib_context handles the main loop.
73: 71:         // We just need to ensure spawn hlyx-platform-lyx_platform_lyx-platform-lyx_platform_appened correctly.
74: 72:         // Let's wait a tiny bit within the driving future to ensure spawn gets processed.
75: 73:         glib::timeout_future(Duration::from_millis(10)).await;
76: 74:     });
77: 75: 
78: 76:     assert!(
79: 77:         success_flag.load(Ordering::SeqCst),
80: 78:         "Spawned future did not complete successfully"
81: 79:     );
82: 80: }
83: 81: 
84: 82: // Similar conditions as test_glib_spawn regarding initialization state.
85: 83: #[test]
86: 84: #[serial]
87: 85: fn test_glib_spawn_local() {
88: 86:     let success_flag = Rc::new(Cell::new(false));
89: 87:     let flag_clone = success_flag.clone();
90: 88: 
91: 89:     run_local_on_glib_context(async move {
92: 90:         // Use Rc to make the future !Send
93: 91:         let non_send_data = Rc::new(Cell::new(10));
94: 92: 
95: 93:         let data = non_send_data.get();
96: 94:         assert_eq!(data, 10, "Rc data should be accessible");
97: 95:         non_send_data.set(20); // Modify non-Send data
98: 96: 
99: 97:         // Simulate async work
100: 98:         futures_lite::future::yield_now().await;
101: 99: 
102: 100:         assert_eq!(
103: 101:             non_send_data.get(),
104: 102:             20,
105: 103:             "Rc data should persist modification"
106: 104:         );
107: 105:         flag_clone.set(true);
108: 106: 
109: 107:         // Wait a tiny bit
110: 108:         glib::timeout_future(Duration::from_millis(10)).await;
111: 109:     });
112: 110: 
113: 111:     assert!(
114: 112:         success_flag.get(),
115: 113:         "Spawned local future did not complete successfully"
116: 114:     );
117: 115: }
118: 116: 
119: 117: // Test Executor::tick with glib lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend
120: 118: #[test]
121: 119: #[serial]
122: 120: fn test_glib_tick() {
123: 121:     run_on_glib_context(async {
124: 122:         let value = Arc::new(Mutex::new(false));
125: 123:         let value_clone = value.clone();
126: 124: 
127: 125:         // Spawn a task that sets the value after a tick
128: 126:         Executor::spawn(async move {
129: 127:             Executor::tick().await;
130: 128:             *value_clone.lock().unwrap() = true;
131: 129:         });
132: 130: 
133: 131:         // Allow some time for the task to complete
134: 132:         glib::timeout_future(Duration::from_millis(10)).await;
135: 133: 
136: 134:         // Check that the value was set
137: 135:         assert!(*value.lock().unwrap());
138: 136:     });
139: 137: }
140: 138: 
141: 139: // Test Executor::poll_local with glib lyx-platform-lyx_platform_lyx-platform-lyx_platform_backend (should be a no-op)
142: 140: #[test]
143: 141: #[serial]
144: 142: fn test_glib_poll_local_is_no_op() {
145: 143:     // Ensure glib executor is initialized
146: 144:     let _ = Executor::init_glib();
147: 145:     // poll_local for glib is configured as a no-op
148: 146:     // Calling it should not panic or cause issues.
149: 147:     Executor::poll_local();
150: 148:     Executor::poll_local();
151: 149: 
152: 150:     println!("Executor::poll_local called successfully (expected no-op).");
153: 151: }
154: ```
```
