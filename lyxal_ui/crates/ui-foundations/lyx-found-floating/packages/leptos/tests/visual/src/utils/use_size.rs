### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx-found-floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos\tests\visual\src\utils\use_size.rs
use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
use wasm_bindgen::closure::Closure;
use web_sys::{Event, js_sys::Reflect, window};

pub fn use_size(
initial_size: Option<i32>,
key: Option<&'static str>,
) -> (ReadSignal<i32>, WriteSignal<i32>) {
let initial_size = initial_size.unwrap_or(80);
let key = key.unwrap_or("floating");

let (size, set_size) = signal(initial_size);

let closure: Closure<dyn Fn(Event)> = Closure::new(move |event: Event| {
set_size.set(event_target_value(&event).parse().unwrap());
});

Reflect::set(
&window().expect("Window should exist."),
&format!("__handleSizeChange_{key}").into(),
&closure.into_js_value(),
)
.expect("Reflect set should be successful.");

(size, set_size)
}
