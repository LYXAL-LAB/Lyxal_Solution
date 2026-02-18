### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-src\lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr\tests\single.rs
use futures::StreamExt;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use lyx-core-src::*;
use lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr::init_test;

#[component]
pub fn App() -> impl IntoView {
view! {
{
let (msg_res, msg_tx) = async_signal("default message".to_string());
view! {
<Suspense>
{ move || {
let msg = match msg_res.get() {
None => "no msg yet".to_owned(),
Some(msg) => format!("msg is: {msg}")
};
view! { <span id="msg">{msg}</span> }
}
}
</Suspense>
<Component msg_tx=msg_tx />
}
}
}
}

#[component]
fn Component(msg_tx: AsyncWriteSignal<String>) -> impl IntoView {
let data = Resource::new(
|| (),
move |_| {
let msg_tx = msg_tx.clone();
async move {
let (msg, num) = lyx-core-lyx_core_lyx-core-lyx_core_tests_ssr::fetch_data().await;
msg_tx.set(msg);
num
}
},
);
view! {
<Suspense>
{ move || {
match data.get() {
Some(num) => view! { <span>The number is: {num}</span> }.into_any(),
None => view! { <span>No number</span> }.into_any(),
}
}
}
</Suspense>
}
}

#[tokio::test]
async fn render_async() {
init_test();
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = view! { <App /> };
let html = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order().collect::<String>().await;
assert!(html.contains("msg is: Hello world"));
}
