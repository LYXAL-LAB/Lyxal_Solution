### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn\tests\invalid\aliased_return_full.rs
use lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_server_fn_macro_default::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server;

#[derive(Debug, thiserror::Error, Clone, serde::Serialize, serde::Deserialize)]
pub enum InvalidError {
#[error("error a")]
A,
}

type FullAlias = Result<String, InvalidError>;

#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server]
pub async fn full_alias_result() -> FullAlias {
Ok("hello".to_string())
}

fn main() {}
