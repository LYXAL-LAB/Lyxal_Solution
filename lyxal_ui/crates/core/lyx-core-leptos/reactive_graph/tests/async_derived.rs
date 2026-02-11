### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_reactive_graph\tests\async_derived.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph\tests\async_derived.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::{
5: 3:     computed::{ArcAsyncDerived, AsyncDerived},
6: 4:     owner::Owner,
7: 5:     signal::RwSignal,
8: 6:     traits::{Get, Read, Set, With, WithUntracked},
9: 7: };
10: 8: use std::future::pending;
11: 9: 
12: 10: #[tokio::test]
13: 11: async fn arc_async_derived_calculates_eagerly() {
14: 12:     _ = Executor::init_tokio();
15: 13:     let owner = Owner::new();
16: 14:     owner.set();
17: 15: 
18: 16:     let value = ArcAsyncDerived::new(|| async {
19: 17:         Executor::tick().await;
20: 18:         42
21: 19:     });
22: 20: 
23: 21:     assert_eq!(value.clone().await, 42);
24: 22: }
25: 23: 
26: 24: #[tokio::test]
27: 25: async fn arc_async_derived_tracks_signal_change() {
28: 26:     _ = Executor::init_tokio();
29: 27:     let owner = Owner::new();
30: 28:     owner.set();
31: 29: 
32: 30:     let signal = RwSignal::new(10);
33: 31:     let value = ArcAsyncDerived::new(move || async move {
34: 32:         Executor::tick().await;
35: 33:         signal.get()
36: 34:     });
37: 35: 
38: 36:     assert_eq!(value.clone().await, 10);
39: 37:     signal.set(30);
40: 38:     Executor::tick().await;
41: 39:     assert_eq!(value.clone().await, 30);
42: 40:     signal.set(50);
43: 41:     Executor::tick().await;
44: 42:     assert_eq!(value.clone().await, 50);
45: 43: }
46: 44: 
47: 45: #[tokio::test]
48: 46: async fn async_derived_calculates_eagerly() {
49: 47:     _ = Executor::init_tokio();
50: 48:     let owner = Owner::new();
51: 49:     owner.set();
52: 50: 
53: 51:     let value = AsyncDerived::new(|| async {
54: 52:         Executor::tick().await;
55: 53:         42
56: 54:     });
57: 55: 
58: 56:     assert_eq!(value.await, 42);
59: 57: }
60: 58: 
61: 59: #[tokio::test]
62: 60: async fn async_derived_tracks_signal_change() {
63: 61:     _ = Executor::init_tokio();
64: 62:     let owner = Owner::new();
65: 63:     owner.set();
66: 64: 
67: 65:     let signal = RwSignal::new(10);
68: 66:     let value = AsyncDerived::new(move || async move {
69: 67:         Executor::tick().await;
70: 68:         signal.get()
71: 69:     });
72: 70: 
73: 71:     assert_eq!(value.await, 10);
74: 72:     signal.set(30);
75: 73:     Executor::tick().await;
76: 74:     assert_eq!(value.await, 30);
77: 75:     signal.set(50);
78: 76:     Executor::tick().await;
79: 77:     assert_eq!(value.await, 50);
80: 78: }
81: 79: 
82: 80: #[tokio::test]
83: 81: async fn read_signal_traits_on_arc() {
84: 82:     _ = Executor::init_tokio();
85: 83:     let owner = Owner::new();
86: 84:     owner.set();
87: 85: 
88: 86:     let value = ArcAsyncDerived::new(pending::<()>);
89: 87:     assert_eq!(value.read(), None);
90: 88:     assert_eq!(value.with_untracked(|n| *n), None);
91: 89:     assert_eq!(value.with(|n| *n), None);
92: 90:     assert_eq!(value.get(), None);
93: 91: }
94: 92: 
95: 93: #[tokio::test]
96: 94: async fn read_signal_traits_on_arena() {
97: 95:     _ = Executor::init_tokio();
98: 96:     let owner = Owner::new();
99: 97:     owner.set();
100: 98: 
101: 99:     let value = AsyncDerived::new(pending::<()>);
102: 100:     println!("{:?}", value.read());
103: 101:     assert_eq!(value.read(), None);
104: 102:     assert_eq!(value.with_untracked(|n| *n), None);
105: 103:     assert_eq!(value.with(|n| *n), None);
106: 104:     assert_eq!(value.get(), None);
107: 105: }
108: 106: 
109: 107: #[tokio::test]
110: 108: async fn async_derived_with_initial() {
111: 109:     _ = Executor::init_tokio();
112: 110:     let owner = Owner::new();
113: 111:     owner.set();
114: 112: 
115: 113:     let signal1 = RwSignal::new(0);
116: 114:     let signal2 = RwSignal::new(0);
117: 115:     let derived =
118: 116:         ArcAsyncDerived::new_with_initial(Some(5), move || async move {
119: 117:             // reactive values can be tracked anywhere in the `async` block
120: 118:             let value1 = signal1.get();
121: 119:             tokio::time::sleep(std::time::Duration::from_millis(25)).await;
122: 120:             let value2 = signal2.get();
123: 121: 
124: 122:             value1 + value2
125: 123:         });
126: 124: 
127: 125:     // the value can be accessed synchronously as `Option<T>`
128: 126:     assert_eq!(derived.get(), Some(5));
129: 127:     // we can also .await the value, i.e., convert it into a Future
130: 128:     assert_eq!(derived.clone().await, 0);
131: 129:     assert_eq!(derived.get(), Some(0));
132: 130: 
133: 131:     signal1.set(1);
134: 132:     // while the new value is still pending, the signal holds the old value
135: 133:     tokio::time::sleep(std::time::Duration::from_millis(5)).await;
136: 134:     assert_eq!(derived.get(), Some(0));
137: 135: 
138: 136:     // setting multiple dependencies will hold until the latest change is ready
139: 137:     signal2.set(1);
140: 138:     assert_eq!(derived.await, 2);
141: 139: }
142: ```
```
