### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_resize_event.rs
```rust
use leptos::*;
use web_sys::Event;

use super::WasmClosure;

#[derive(Debug, Clone)]
pub struct GlobalResizeEvent {
    _closure: WasmClosure<Event>,
    pub read_signal: ReadSignal<Option<Event>>,
    pub write_signal: WriteSignal<Option<Event>>,
}

impl GlobalResizeEvent {
    #[allow(clippy::used_underscore_binding)]
    pub fn new(
        _closure: WasmClosure<Event>,
        read_signal: ReadSignal<Option<Event>>,
        write_signal: WriteSignal<Option<Event>>,
    ) -> Self {
        Self {
            _closure,
            read_signal,
            write_signal,
        }
    }
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
