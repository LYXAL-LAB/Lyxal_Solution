### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-workers\src\api\d1.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-workers\src\api\d1.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
46: 44: ```rust
47: 45: // This file is just an lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example and isn't included by default.
48: 46: // Use it as a building block for the rest of your worker-specific lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions.
49: 47: 
50: 48: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
51: 49: use serde::{Deserialize, Serialize};
52: 50: 
53: 51: #[derive(Clone, Debug, Deserialize, Serialize)]
54: 52: pub struct PostData {
55: 53:     pub id: i64,
56: 54:     pub user_id: i64,
57: 55:     pub title: String,
58: 56: }
59: 57: 
60: 58: #[cfg_attr(feature = "ssr", worker::send)] // <- required to await data from env
61: 59: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(GetPost)]
62: 60: pub async fn get_post(post_id: i64) -> Result<Option<PostData>, ServerFnError> {
63: 61:     use std::time::Duration;
64: 62: 
65: 63:     use axum::Extension;
66: 64:     use lyx-core-axum::*;
67: 65:     use std::sync::Arc;
68: 66:     use worker::*;
69: 67: 
70: 68:     /// Get our Worker env variable from axum
71: 69:     let Extension(env): Extension<Arc<Env>> = extract().await?;
72: 70: 
73: 71:     /// Connect to our database
74: 72:     let d1 = env.d1("DB").unwrap();
75: 73: 
76: 74:     /// Load the post data
77: 75:     let stmt = query!(&d1, "SELECT * FROM post where id=?", post_id).unwrap();
78: 76:     let result: Option<PostData> = stmt.first().await.unwrap();
79: 77: 
80: 78:     Ok(result)
81: 79: }
82: 80: ```
83: 81: ```
84: 82: ```
85: 83: ```
86: 84: ```
87: 85: ```
88: 86: ```
89: 87: ```
90: 88: ```
91: 89: ```
92: 90: ```
93: 91: ```
94: 92: ```
95: 93: ```
96: 94: ```
97: 95: ```
98: 96: ```
99: 97: ```
100: 98: ```
101: 99: ```
102: 100: ```
103: 101: ```
104: ```
```
