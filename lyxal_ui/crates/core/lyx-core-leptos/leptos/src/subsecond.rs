### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_leptos\src\subsecond.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos\src\subsecond.rs
2: ```rust
3: 1: use dioxus_devtools::Devlyx-platform-lyx_platform_lyx-platform-lyx_platform_serverMsg;
4: 2: use wasm_bindgen::{prelude::Closure, JsCast};
5: 3: use web_sys::{js_sys::JsString, MessageEvent, WebSocket};
6: 4: 
7: 5: /// Sets up a websocket connect to the `dx` CLI, waiting for incoming hot-patching messages
8: 6: /// and patching the WASM binary lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriately.
9: 7: //
10: 8: //  Note: This is a stripped-down version of Dioxus's `make_ws` from `dioxus_web`
11: 9: //  It's essentially copy-pasted here because it's not pub there.
12: 10: //  Would love to just take a dependency on that to be able to use it and deduplicate.
13: 11: //
14: 12: //  https://github.com/DioxusLabs/dioxus/blob/main/packages/web/src/devtools.rs#L36
15: 13: pub fn connect_to_hot_patch_messages() {
16: 14:     // Get the location of the devlyx-platform-lyx_platform_lyx-platform-lyx_platform_server, using the current location plus the /_dioxus path
17: 15:     // The idea here being that the devlyx-platform-lyx_platform_lyx-platform-lyx_platform_server is always located on the /_dioxus behind a proxy
18: 16:     let location = web_sys::window().unwrap().location();
19: 17:     let url = format!(
20: 18:         "{protocol}//{host}/_dioxus?build_id={build_id}",
21: 19:         protocol = match location.protocol().unwrap() {
22: 20:             prot if prot == "https:" => "wss:",
23: 21:             _ => "ws:",
24: 22:         },
25: 23:         host = location.host().unwrap(),
26: 24:         build_id = dioxus_cli_config::build_id(),
27: 25:     );
28: 26: 
29: 27:     let ws = WebSocket::new(&url).unwrap();
30: 28: 
31: 29:     ws.set_onmessage(Some(
32: 30:         Closure::<dyn FnMut(MessageEvent)>::new(move |e: MessageEvent| {
33: 31:             let Ok(text) = e.data().dyn_into::<JsString>() else {
34: 32:                 return;
35: 33:             };
36: 34: 
37: 35:             // The devlyx-platform-lyx_platform_lyx-platform-lyx_platform_server messages have some &'static strs in them, so we need to leak the source string
38: 36:             let string: String = text.into();
39: 37:             let string = Box::leak(string.into_boxed_str());
40: 38: 
41: 39:             if let Ok(Devlyx-platform-lyx_platform_lyx-platform-lyx_platform_serverMsg::HotReload(msg)) =
42: 40:                 serde_json::from_str::<Devlyx-platform-lyx_platform_lyx-platform-lyx_platform_serverMsg>(string)
43: 41:             {
44: 42:                 if let Some(jump_table) = msg.jump_table.as_ref().cloned() {
45: 43:                     if msg.for_build_id == Some(dioxus_cli_config::build_id()) {
46: 44:                         let our_pid = if cfg!(target_family = "wasm") {
47: 45:                             None
48: 46:                         } else {
49: 47:                             Some(std::process::id())
50: 48:                         };
51: 49: 
52: 50:                         if msg.for_pid == our_pid {
53: 51:                             unsafe { subsecond::lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_patch(jump_table) }
54: 52:                                 .unwrap();
55: 53:                         }
56: 54:                     }
57: 55:                 }
58: 56:             }
59: 57:         })
60: 58:         .into_js_value()
61: 59:         .as_ref()
62: 60:         .unchecked_ref(),
63: 61:     ));
64: 62: }
65: ```
```
