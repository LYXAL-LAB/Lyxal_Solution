### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_floating\packages\yew\tests\visual\src\utils\use_size.rs
```rust
use wasm_bindgen::{JsCast, closure::Closure};
use web_sys::{Event, js_sys::Reflect, window};
use yew::{UseStateHandle, hook, use_state};

#[hook]
pub fn use_size(initial_size: Option<i32>, key: Option<&'static str>) -> UseStateHandle<i32> {
    let initial_size = initial_size.unwrap_or(80);
    let key = key.unwrap_or("floating");

    let size = use_state(|| initial_size);

    let closure: Closure<dyn Fn(Event)> = Closure::new({
        let size = size.clone();

        move |event: Event| {
            size.set(
                event
                    .target()
                    .unwrap()
                    .unchecked_into::<web_sys::HtmlInputElement>()
                    .value()
                    .parse()
                    .unwrap(),
            );
        }
    });

    Reflect::set(
        &window().expect("Window should exist."),
        &format!("__handleSizeChange_{key}").into(),
        &closure.into_js_value(),
    )
    .expect("Reflect set should be successful.");

    size
}
```
```
```
```
```
```
```
```
```
```
```
```
```
```
