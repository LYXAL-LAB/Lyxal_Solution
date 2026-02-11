### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_service_mode\src\lyx-platform-lyx_platform_app.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
4: 2: ```rust
5: 3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\integrations\axum\tests\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_service_mode\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
6: 4: 2: ```rust
7: 5: 3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
8: 6: 4: 2: use lyx-core-lyx_core_lyx-core-meta::{MetaTags, *};
9: 7: 5: 3: use lyx-core-lyx_core_lyx-core-router::{
10: 8: 6: 4:     StaticSegment,
11: 9: 7: 5:     components::{FlatRoutes, Route, Router},
12: 10: 8: 6: };
13: 11: 9: 7: 
14: 12: 10: 8: pub fn shell(options: LeptosOptions) -> impl IntoView {
15: 13: 11: 9:     view! {
16: 14: 12: 10:         <!DOCTYPE html>
17: 15: 13: 11:         <html lang="en">
18: 16: 14: 12:             <head>
19: 17: 15: 13:                 <meta charset="utf-8"/>
20: 18: 16: 14:                 <meta name="viewport" content="width=device-width, initial-scale=1"/>
21: 19: 17: 15:                 <AutoReload options=options.clone()/>
22: 20: 18: 16:                 <HydrationScripts options/>
23: 21: 19: 17:                 <MetaTags/>
24: 22: 20: 18:             </head>
25: 23: 21: 19:             <body>
26: 24: 22: 20:                 <App/>
27: 25: 23: 21:             </body>
28: 26: 24: 22:         </html>
29: 27: 25: 23:     }
30: 28: 26: 24: }
31: 29: 27: 25: 
32: 30: 28: 26: #[component]
33: 31: 29: 27: pub fn App() -> impl IntoView {
34: 32: 30: 28:     // Provides context that manages stylesheets, titles, meta tags, etc.
35: 33: 31: 29:     provide_meta_context();
36: 34: 32: 30:     let fallback = || {
37: 35: 33: 31:         view! {
38: 36: 34: 32:             <Title text="Error from fallback"/>
39: 37: 35: 33:             <h1>"This is fallback rendering."</h1>
40: 38: 36: 34:         }
41: 39: 37: 35:         .into_view()
42: 40: 38: 36:     };
43: 41: 39: 37: 
44: 42: 40: 38:     view! {
45: 43: 41: 39:         <Router>
46: 44: 42: 40:             <nav>
47: 45: 43: 41:                 <a href="/">"Home"</a>
48: 46: 44: 42:             </nav>
49: 47: 45: 43:             <main>
50: 48: 46: 44:                 <FlatRoutes fallback>
51: 49: 47: 45:                     <Route path=StaticSegment("") view=HomePage/>
52: 50: 48: 46:                 </FlatRoutes>
53: 51: 49: 47:             </main>
54: 52: 50: 48:         </Router>
55: 53: 51: 49:     }
56: 54: 52: 50: }
57: 55: 53: 51: 
58: 56: 54: 52: #[component]
59: 57: 55: 53: fn HomePage() -> impl IntoView {
60: 58: 56: 54:     view! {
61: 59: 57: 55:         <h1>"Home Page"</h1>
62: 60: 58: 56:     }
63: 61: 59: 57: }
64: 62: 60: ```
65: 63: ```
66: ```
```
