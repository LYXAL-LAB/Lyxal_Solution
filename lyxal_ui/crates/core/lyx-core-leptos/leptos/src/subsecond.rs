use dioxus_devtools::Devlyx-platform-lyx_platform_lyx-platform-lyx_platform_serverMsg;
use wasm_bindgen::{prelude::Closure, JsCast};
use web_sys::{js_sys::JsString, MessageEvent, WebSocket};

/// Sets up a websocket connect to the `dx` CLI, waiting for incoming hot-patching messages
/// and patching the WASM binary lyx-platform-lyx_platform_lyx-platform-lyx_platform_appropriately.
//
//  Note: This is a stripped-down version of Dioxus's `make_ws` from `dioxus_web`
//  It's essentially copy-pasted here because it's not pub there.
//  Would love to just take a dependency on that to be able to use it and deduplicate.
//
//  https://github.com/DioxusLabs/dioxus/blob/main/packages/web/src/devtools.rs#L36
pub fn connect_to_hot_patch_messages() {
// Get the location of the devlyx-platform-lyx_platform_lyx-platform-lyx_platform_server, using the current location plus the /_dioxus path
// The idea here being that the devlyx-platform-lyx_platform_lyx-platform-lyx_platform_server is always located on the /_dioxus behind a proxy
let location = web_sys::window().unwrap().location();
let url = format!(
"{protocol}//{host}/_dioxus?build_id={build_id}",
protocol = match location.protocol().unwrap() {
prot if prot == "https:" => "wss:",
_ => "ws:",
},
host = location.host().unwrap(),
build_id = dioxus_cli_config::build_id(),
);

let ws = WebSocket::new(&url).unwrap();

ws.set_onmessage(Some(
Closure::<dyn FnMut(MessageEvent)>::new(move |e: MessageEvent| {
let Ok(text) = e.data().dyn_into::<JsString>() else {
return;
};

// The devlyx-platform-lyx_platform_lyx-platform-lyx_platform_server messages have some &'static strs in them, so we need to leak the source string
let string: String = text.into();
let string = Box::leak(string.into_boxed_str());

if let Ok(Devlyx-platform-lyx_platform_lyx-platform-lyx_platform_serverMsg::HotReload(msg)) =
serde_json::from_str::<Devlyx-platform-lyx_platform_lyx-platform-lyx_platform_serverMsg>(string)
{
if let Some(jump_table) = msg.jump_table.as_ref().cloned() {
if msg.for_build_id == Some(dioxus_cli_config::build_id()) {
let our_pid = if cfg!(target_family = "wasm") {
None
} else {
Some(std::process::id())
};

if msg.for_pid == our_pid {
unsafe { subsecond::lyx-platform-lyx_platform_lyx-platform-lyx_platform_apply_patch(jump_table) }
.unwrap();
}
}
}
}
})
.into_js_value()
.as_ref()
.unchecked_ref(),
));
}
