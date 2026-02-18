### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\components\show_data_from_api.rs
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;

use crate::api::say_hello::say_hello;

#[component]
pub fn ShowDataFromApi() -> impl IntoView {
let value = create_rw_signal("".to_string());
let counter = create_rw_signal(0);

let on_click = move |_| {
spawn_local(async move {
let api_said = say_hello(counter.get()).await.unwrap();
value.set(api_said);
counter.update(|v| *v += 1);
});
};

view! {
<div>
<button on:click=on_click>"What does the API say?"</button>
<p>{value}</p>
</div>
}
}
