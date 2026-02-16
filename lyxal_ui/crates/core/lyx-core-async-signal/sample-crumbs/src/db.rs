1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
2: ```rust
3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
4: ```rust
5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
6: ```rust
7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
8: ```rust
9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
10: ```rust
11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
12: ```rust
13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
14: ```rust
15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
16: ```rust
17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
18: ```rust
19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
20: ```rust
21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
22: ```rust
23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\sample-crumbs\src\db.rs
24: ```rust
25: //! A mock of a database of posts.
26: 
27: use std::time::Duration;
28: 
29: use itertools::Itertools;
30: use phf::{phf_map, Map};
31: 
32: use crate::model::Post;
33: 
34: /// Latency of DB operation.
35: const DB_LATENCY: Duration = Duration::from_millis(250);
36: 
37: /// Representation of post in the database.
38: struct DbPost {
39:     title: &'static str,
40:     body: &'static str,
41: }
42: 
43: impl From<&DbPost> for Post {
44:     fn from(value: &DbPost) -> Self {
45:         Self { title: value.title.to_string(), body: value.body.to_string() }
46:     }
47: }
48: 
49: /// A map of post entries in the database.
50: static ENTRIES: Map<u64, DbPost> = phf_map! {
51:     1u64 => DbPost { title: "First post", body: "This is the very first post." },
52:     2u64 => DbPost { title: "Second post", body: "This is yet another post.\nIt even has another line." },
53:     42u64 => DbPost { title: "Last post", body: "This is yet another post.\nBut also the last one.\nFor sure!\n" },
54: };
55: 
56: /// Fetch all posts from the database.
57: pub async fn all_posts() -> impl Iterator<Item = (u64, Post)> {
58:     tokio::time::sleep(DB_LATENCY).await;
59:     ENTRIES
60:         .into_iter()
61:         .sorted_by_key(|(id, _post)| **id)
62:         .map(|(id, post)| (*id, Post::from(post)))
63: }
64: 
65: /// Fetch a post by ID from the database.
66: #[must_use]
67: pub async fn post_by_id(id: u64) -> Option<Post> {
68:     tokio::time::sleep(DB_LATENCY).await;
69:     ENTRIES.get(&id).map(Post::from)
70: }
71: ```
72: ```
73: ```
74: ```
75: ```
76: ```
77: ```
78: ```
79: ```
80: ```
81: ```
82: ```
```

