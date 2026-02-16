1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-image\src\provider.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\provider.rs
46: 44: ```rust
47: 45: use crate::optimizer::CachedImage;
48: 46: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
49: 47: 
50: 48: /// Provides Image Cache Context so that Images can use their blur placeholders if they exist.
51: 49: ///
52: 50: /// This should go in the base of your Leptos <App/>.
53: 51: ///
54: 52: /// Example
55: 53: ///
56: 54: /// ```
57: 55: /// use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
58: 56: ///
59: 57: /// #[component]
60: 58: /// pub fn App() -> impl IntoView {
61: 59: ///     lyx-core-lyx_core_lyx-spec-image::provide_image_context();
62: 60: ///
63: 61: ///     view!{
64: 62: ///       <div/>
65: 63: ///     }
66: 64: /// }
67: 65: ///
68: 66: /// ```
69: 67: pub fn provide_image_context() {
70: 68:     let resource: ImageResource = create_blocking_resource(
71: 69:         || (),
72: 70:         |_| async {
73: 71:             get_image_config()
74: 72:                 .await
75: 73:                 .expect("Failed to retrieve image cache")
76: 74:         },
77: 75:     );
78: 76: 
79: 77:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::provide_context(resource);
80: 78: }
81: 79: 
82: 80: type ImageResource = Resource<(), ImageConfig>;
83: 81: 
84: 82: #[doc(hidden)]
85: 83: #[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
86: 84: pub struct ImageConfig {
87: 85:     pub(crate) api_handler_path: String,
88: 86:     pub(crate) cache: Vec<(CachedImage, String)>,
89: 87: }
90: 88: 
91: 89: pub(crate) fn use_image_cache_resource() -> ImageResource {
92: 90:     use_context::<ImageResource>().expect("Missing Image Resource")
93: 91: }
94: 92: 
95: 93: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(GetImageCache)]
96: 94: pub(crate) async fn get_image_config() -> Result<ImageConfig, ServerFnError> {
97: 95:     let optimizer = use_optimizer()?;
98: 96: 
99: 97:     let cache = optimizer
100: 98:         .cache
101: 99:         .iter()
102: 100:         .map(|entry| (entry.key().clone(), entry.value().clone()))
103: 101:         .collect();
104: 102: 
105: 103:     let api_handler_path = optimizer.api_handler_path.clone();
106: 104: 
107: 105:     Ok(ImageConfig {
108: 106:         api_handler_path,
109: 107:         cache,
110: 108:     })
111: 109: }
112: 110: 
113: 111: #[cfg(feature = "ssr")]
114: 112: pub(crate) fn use_optimizer() -> Result<crate::ImageOptimizer, ServerFnError> {
115: 113:     use_context::<crate::ImageOptimizer>()
116: 114:         .ok_or_else(|| ServerFnError::ServerError("Image Optimizer Missing.".into()))
117: 115: }
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
133: 131: ```
134: 132: ```
135: 133: ```
136: 134: ```
137: 135: ```
138: 136: ```
139: 137: ```
140: ```
```

