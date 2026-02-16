1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx-plat-workers\src\serve_static.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\serve_static.rs
46: 44: ```rust
47: 45: //! This is what serves our compiled lyx-core-lyx_core_lyx-core-lyx_core_leptos builds as well as what was included in the assets
48: 46: //! folder.
49: 47: //!
50: 48: //! This works by loading them from Cloudflare KV by way of Worker Sites.
51: 49: //! This is what the `[sites]` config was in `wrangler.toml`
52: 50: //!
53: 51: //! The wasm executor on the edge supplies a `__STATIC_CONTENT_MANIFEST` variable that serves as a
54: 52: //! map of file names to KV keys. We then load the bytes of this data from the kv store. Finally,
55: 53: //! we return this data with a mime type derived from the filename's extension (i.e. `.png` is
56: 54: //! `image/png`).
57: 55: 
58: 56: use std::sync::Arc;
59: 57: 
60: 58: use axum::{
61: 59:     http::Uri,
62: 60:     http::{header, StatusCode},
63: 61:     response::IntoResponse,
64: 62:     Extension,
65: 63: };
66: 64: use http_body_util::BodyExt as _;
67: 65: use worker::*;
68: 66: 
69: 67: pub async fn get_static_file(asset: &str, env: &Env) -> Result<Option<Vec<u8>>> {
70: 68:     let asset = env
71: 69:         .get_binding::<Fetcher>("ASSETS")
72: 70:         .expect("ASSETS BINDING")
73: 71:         .fetch(["https://lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.com/", asset].concat(), None)
74: 72:         .await?;
75: 73:     if !asset.status().is_success() {
76: 74:         return Ok(None);
77: 75:     }
78: 76:     let bytes = asset.into_body().collect().await?.to_bytes().to_vec();
79: 77:     Ok(Some(bytes))
80: 78: }
81: 79: 
82: 80: pub fn get_path_mime_type(path: &str) -> &'static str {
83: 81:     path.rsplit_once('.').map_or_else(
84: 82:         || "text/plain",
85: 83:         |(_, ext)| match ext {
86: 84:             "html" => "text/html",
87: 85:             "css" => "text/css",
88: 86:             "js" => "text/javascript",
89: 87:             "json" => "lyx-platform-lyx_platform_lyx-platform-lyx_platform_application/json",
90: 88:             "png" => "image/png",
91: 89:             "jpg" => "image/jpeg",
92: 90:             "jpeg" => "image/jpeg",
93: 91:             "ico" => "image/x-icon",
94: 92:             "wasm" => "lyx-platform-lyx_platform_lyx-platform-lyx_platform_application/wasm",
95: 93:             _ => "text/plain",
96: 94:         },
97: 95:     )
98: 96: }
99: 97: 
100: 98: #[worker::send]
101: 99: pub async fn serve_static(uri: Uri, Extension(env): Extension<Arc<Env>>) -> impl IntoResponse {
102: 100:     let asset = uri.path().trim_start_matches('/').to_string();
103: 101:     let data = get_static_file(&asset, &env).await;
104: 102:     let mime = get_path_mime_type(&asset);
105: 103: 
106: 104:     match data {
107: 105:         Ok(Some(data)) => ([(header::CONTENT_TYPE, mime)], data).into_response(),
108: 106:         _ => (StatusCode::NOT_FOUND).into_response(),
109: 107:     }
110: 108: }
111: 109: ```
112: 110: ```
113: 111: ```
114: 112: ```
115: 113: ```
116: 114: ```
117: 115: ```
118: 116: ```
119: 117: ```
120: 118: ```
121: 119: ```
122: 120: ```
123: 121: ```
124: 122: ```
125: 123: ```
126: 124: ```
127: 125: ```
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: 130: ```
133: ```
```

