### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\tests\pr_4061.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\pr_4061.rs
2: ```rust
3: 1: #[cfg(feature = "ssr")]
4: 2: mod imports {
5: 3:     pub use lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor;
6: 4:     pub use futures::StreamExt;
7: 5:     pub use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
8: 6: }
9: 7: 
10: 8: #[cfg(feature = "ssr")]
11: 9: #[tokio::test]
12: 10: async fn chain_await_resource() {
13: 11:     use imports::*;
14: 12: 
15: 13:     _ = Executor::init_tokio();
16: 14:     let owner = Owner::new();
17: 15:     owner.set();
18: 16: 
19: 17:     let (rs, ws) = signal(0);
20: 18:     let source = Resource::new(
21: 19:         || (),
22: 20:         move |_| async move {
23: 21:             #[cfg(feature = "ssr")]
24: 22:             tokio::time::sleep(std::time::Duration::from_millis(1)).await;
25: 23:             1
26: 24:         },
27: 25:     );
28: 26:     let consuming = Resource::new(
29: 27:         || (),
30: 28:         move |_| async move {
31: 29:             let result = source.await;
32: 30:             ws.update(|s| *s += 1);
33: 31:             result
34: 32:         },
35: 33:     );
36: 34:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = view! {
37: 35:         <Suspense>{
38: 36:             move || {
39: 37:                 Suspend::new(async move {
40: 38:                     consuming.await;
41: 39:                     rs.get()
42: 40:                 })
43: 41:             }
44: 42:         }</Suspense>
45: 43:     };
46: 44: 
47: 45:     assert_eq!(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order().collect::<String>().await, "1");
48: 46: }
49: 47: 
50: 48: #[cfg(feature = "ssr")]
51: 49: #[tokio::test]
52: 50: async fn chain_no_await_resource() {
53: 51:     use imports::*;
54: 52: 
55: 53:     _ = Executor::init_tokio();
56: 54:     let owner = Owner::new();
57: 55:     owner.set();
58: 56: 
59: 57:     let (rs, ws) = signal(0);
60: 58:     let source = Resource::new(|| (), move |_| async move { 1 });
61: 59:     let consuming = Resource::new(
62: 60:         || (),
63: 61:         move |_| async move {
64: 62:             let result = source.await;
65: 63:             ws.update(|s| *s += 1);
66: 64:             result
67: 65:         },
68: 66:     );
69: 67:     let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = view! {
70: 68:         <Suspense>{
71: 69:             move || {
72: 70:                 Suspend::new(async move {
73: 71:                     consuming.await;
74: 72:                     rs.get()
75: 73:                 })
76: 74:             }
77: 75:         }</Suspense>
78: 76:     };
79: 77: 
80: 78:     assert_eq!(lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order().collect::<String>().await, "1");
81: 79: }
82: ```
```
