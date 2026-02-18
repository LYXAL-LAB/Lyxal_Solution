#[cfg(not(feature = "ssr"))]
pub mod tests {
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{
lyx-platform-lyx_platform_lyx-platform-lyx_platform_server,
lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn::{codec, Http, ServerFn, ServerFnError},
};
use std::any::TypeId;

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_default() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(
<MyServerAction as ServerFn>::PATH
.trim_end_matches(char::is_numeric),
"/api/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
);
assert_eq!(
TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::PostUrl, codec::Json>>()
);
}

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_full_legacy() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(FooBar, "/foo/bar", "Cbor", "my_path")]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(<FooBar as ServerFn>::PATH, "/foo/bar/my_path");
assert_eq!(
TypeId::of::<<FooBar as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::Cbor, codec::Cbor>>()
);
}

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_all_keywords() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "my_path", encoding = "Cbor", prefix = "/foo/bar", name = FooBar)]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(<FooBar as ServerFn>::PATH, "/foo/bar/my_path");
assert_eq!(
TypeId::of::<<FooBar as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::Cbor, codec::Cbor>>()
);
}

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_mix() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(FooBar, endpoint = "my_path")]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(<FooBar as ServerFn>::PATH, "/api/my_path");
assert_eq!(
TypeId::of::<<FooBar as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::PostUrl, codec::Json>>()
);
}

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_name() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(name = FooBar)]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(
<FooBar as ServerFn>::PATH.trim_end_matches(char::is_numeric),
"/api/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
);
assert_eq!(
TypeId::of::<<FooBar as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::PostUrl, codec::Json>>()
);
}

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_prefix() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(prefix = "/foo/bar")]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(
<MyServerAction as ServerFn>::PATH
.trim_end_matches(char::is_numeric),
"/foo/bar/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
);
assert_eq!(
TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::PostUrl, codec::Json>>()
);
}

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_encoding() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(encoding = "GetJson")]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(
<MyServerAction as ServerFn>::PATH
.trim_end_matches(char::is_numeric),
"/api/my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action"
);
assert_eq!(
TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::GetUrl, codec::Json>>()
);
}

#[test]
fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_endpoint() {
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "/path/to/my/endpoint")]
pub async fn my_lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_action() -> Result<(), ServerFnError> {
Ok(())
}
assert_eq!(
<MyServerAction as ServerFn>::PATH,
"/api/path/to/my/endpoint"
);
assert_eq!(
TypeId::of::<<MyServerAction as ServerFn>::Protocol>(),
TypeId::of::<Http<codec::PostUrl, codec::Json>>()
);
}
}
