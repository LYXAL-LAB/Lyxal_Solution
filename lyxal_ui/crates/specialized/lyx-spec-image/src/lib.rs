### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-image\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx-spec-image\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
10: 8: ```rust
11: 9: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
12: 10: ```rust
13: 11: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
14: 12: ```rust
15: 13: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
16: 14: ```rust
17: 15: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
18: 16: ```rust
19: 17: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
20: 18: ```rust
21: 19: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
22: 20: ```rust
23: 21: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
24: 22: ```rust
25: 23: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
26: 24: ```rust
27: 25: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
28: 26: ```rust
29: 27: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
30: 28: ```rust
31: 29: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
32: 30: ```rust
33: 31: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
34: 32: ```rust
35: 33: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
36: 34: ```rust
37: 35: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
38: 36: ```rust
39: 37: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
40: 38: ```rust
41: 39: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
42: 40: ```rust
43: 41: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
44: 42: ```rust
45: 43: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_image\src\lib.rs
46: 44: ```rust
47: 45: #![forbid(unsafe_code)]
48: 46: #![warn(missing_docs)]
49: 47: 
50: 48: //! # Leptos Image
51: 49: //!
52: 50: //! > Crafted with inspiration from Next.js
53: 51: //!
54: 52: //! Images make a substantial impact on the size and performance of a website, so why not get them right?
55: 53: //!
56: 54: //! Enter Leptos `<Image/>`, a component that enhances the standard HTML `<img>` element with automatic image optimization features.
57: 55: //!
58: 56: //! ## Features
59: 57: //!
60: 58: //! - **Size Optimization**: Automatically resizes images and converts them to the modern `.webp` format for an ideal balance of size and quality.
61: 59: //! - **Low-Quality Image Placeholders (LQIP)**: Embeds SVG placeholders extracted from original images directly into your lyx-platform-lyx_platform_lyx-platform-lyx_platform_server-side rendered HTML, improving perceived performance by displaying content while the full-quality image loads.
62: 60: //! - **Faster Page Load**: Prioritizes key images that impact the Largest Contentful Paint (LCP) with the `priority` prop, injecting a preload `<link>` into the document head to accelerate load times.
63: 61: //!
64: 62: //! ## Getting Started
65: 63: //!
66: 64: //! The crate focuses on creating optimized images for static content in Leptos projects, a full-stack web framework in Rust.
67: 65: //!
68: 66: //! ### Setup Process
69: 67: //!
70: 68: //! 1. **Provide Image Context**: Initialize your Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_application with `lyx-core-lyx_core_lyx-spec-image::provide_image_context` to grant it read access to the image cache.
71: 69: //!    ```
72: 70: //!    use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
73: 71: //!
74: 72: //!    #[component]
75: 73: //!    fn App() -> impl IntoView {
76: 74: //!        lyx-core-lyx_core_lyx-spec-image::provide_image_context();
77: 75: //!        // Your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app content here
78: 76: //!    }
79: 77: //!    ```
80: 78: //! 2. **Integrate with Leptos Routes**: Ensure your router includes the `ImageOptimizer` context when setting up Leptos routes.
81: 79: //! 3. **Axum State Configuration**: Incorporate `ImageOptimizer` into your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app's Axum state for centralized management.
82: 80: //! 4. **Cache Route Configuration**: Add a dedicated route to your router for serving optimized images from the cache.
83: 81: //!
84: 82: //! ### Example Implementation
85: 83: //!
86: 84: //! Here’s how you can integrate the Image Optimizer into your Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_application:
87: 85: //!
88: 86: //! ```
89: 87: //!     
90: 88: //! # use lyx-core-lyx_core_lyx-spec-image::*;
91: 89: //! # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
92: 90: //! # use axum::*;
93: 91: //! # use axum::routing::post;
94: 92: //! # use lyx-core-axum::{generate_route_list, handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns, LeptosRoutes};
95: 93: //!
96: 94: //! #[cfg(feature = "ssr")]
97: 95: //! async fn your_main_function() {
98: 96: //!     let options = get_configuration(None).await.unwrap().lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
99: 97: //!     let optimizer = ImageOptimizer::new("/__cache/image", options.site_root.clone(), 1);
100: 98: //!     let state = AppState { lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: options, optimizer: optimizer.clone() };
101: 99: //!
102: 100: //!     let router: Router<()> = Router::new()
103: 101: //!         .route("/api/*fn_name", post(lyx-core-axum::handle_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fns))
104: 102: //!         // Adding cache route
105: 103: //!         .image_cache_route(&state)
106: 104: //!         // Provide the optimizer to Leptos context
107: 105: //!         .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes_with_context(&state, generate_route_list(App), optimizer.provide_context(), App)
108: 106: //!         .with_state(state);
109: 107: //!
110: 108: //!     // Rest of your function...
111: 109: //! }
112: 110: //!
113: 111: //! // Composite App State with the optimizer and Leptos options.
114: 112: //! #[derive(Clone, axum::extract::FromRef)]
115: 113: //! struct AppState {
116: 114: //!     lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions,
117: 115: //!     optimizer: lyx-core-lyx_core_lyx-spec-image::ImageOptimizer,
118: 116: //! }
119: 117: //!
120: 118: //! #[component]
121: 119: //! fn App() -> impl IntoView {
122: 120: //!     provide_image_context();
123: 121: //!     // Your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app content here
124: 122: //! }
125: 123: //! ```
126: 124: //!
127: 125: //! This setup ensures your Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_application is fully equipped to deliver optimized images, enhancing the performance and user experience of your web projects.
128: 126: //!
129: 127: //! Now you can use the Image Component anywhere in your lyx-platform-lyx_platform_lyx-platform-lyx_platform_app!
130: 128: 
131: 129: //! ```
132: 130: //! use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
133: 131: //! use lyx-core-lyx_core_lyx-spec-image::*;
134: 132: //!
135: 133: //! #[component]
136: 134: //! pub fn MyImage() -> impl IntoView {
137: 135: //!     view! {
138: 136: //!         <Image
139: 137: //!             src="/cute_ferris.png"
140: 138: //!             blur=true
141: 139: //!             width=750
142: 140: //!             height=500
143: 141: //!             quality=85
144: 142: //!         />
145: 143: //!     }
146: 144: //! }
147: 145: //! ```
148: 146: //!
149: 147: 
150: 148: mod image;
151: 149: mod optimizer;
152: 150: mod provider;
153: 151: #[cfg(feature = "ssr")]
154: 152: mod routes;
155: 153: 
156: 154: pub use image::*;
157: 155: #[cfg(feature = "ssr")]
158: 156: pub use optimizer::ImageOptimizer;
159: 157: pub use provider::*;
160: 158: #[cfg(feature = "ssr")]
161: 159: pub use routes::*;
162: 160: ```
163: 161: ```
164: 162: ```
165: 163: ```
166: 164: ```
167: 165: ```
168: 166: ```
169: 167: ```
170: 168: ```
171: 169: ```
172: 170: ```
173: 171: ```
174: 172: ```
175: 173: ```
176: 174: ```
177: 175: ```
178: 176: ```
179: 177: ```
180: 178: ```
181: 179: ```
182: 180: ```
183: 181: ```
184: ```
```
