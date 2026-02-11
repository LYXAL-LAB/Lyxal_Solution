### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\lyx-platform-lyx_platform_app.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\tauri-from-scratch\src-orig\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
4: 2: 
5: 3: #[cfg(feature = "ssr")]
6: 4: pub fn shell(options: LeptosOptions) -> impl IntoView {
7: 5:     use lyx-core-lyx_core_lyx-core-meta::MetaTags;
8: 6:     view! {
9: 7:         <!DOCTYPE html>
10: 8:         <html lang="en">
11: 9:             <head>
12: 10:                 <meta charset="utf-8"/>
13: 11:                 <meta name="viewport" content="width=device-width, initial-scale=1"/>
14: 12:                 <AutoReload options=options.clone() />
15: 13:                 <HydrationScripts options/>
16: 14:                 <MetaTags/>
17: 15:             </head>
18: 16:             <body>
19: 17:                 <App/>
20: 18:             </body>
21: 19:         </html>
22: 20:     }
23: 21: }
24: 22: 
25: 23: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "hello_world")]
26: 24: pub async fn hello_world_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server() -> Result<String, ServerFnError> {
27: 25:     Ok("Hey.".to_string())
28: 26: }
29: 27: 
30: 28: #[component]
31: 29: pub fn App() -> impl IntoView {
32: 30:     let action = ServerAction::<HelloWorldServer>::new();
33: 31:     let vals = RwSignal::new(String::new());
34: 32:     Effect::new(move |_| {
35: 33:         if let Some(resp) = action.value().get() {
36: 34:             match resp {
37: 35:                 Ok(val) => vals.set(val),
38: 36:                 Err(err) => vals.set(format!("{err:?}")),
39: 37:             }
40: 38:         }
41: 39:     });
42: 40: 
43: 41:     view! {
44: 42:         <button
45: 43:             on:click=move |_| {
46: 44:                 action.dispatch(HelloWorldServer{});
47: 45:             }
48: 46:         >"Hello world."</button>
49: 47:         <br/><br/>
50: 48:         <span>"Server says: "</span>
51: 49:         {move || vals.get()}
52: 50:     }
53: 51: }
54: ```
```
