### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\src\lib.rs
pub async fn fetch_data() -> (String, String) {
tokio::time::sleep(std::time::Duration::from_millis(1)).await;
("Hello world".to_string(), "42".to_string())
}

pub fn init_test() {
// Set async executor
lyx-core-lyx_core_lyx-core-lyx_core_any_spawner::Executor::init_tokio().unwrap();

// This sets sandbox arena for reactive graph
let owner = lyx-core-lyx_core_lyx-core-lyx_core_reactive_graph::owner::Owner::new();
owner.set();
}
