### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\contexts\global_mouseup_event.rs
```rust
use leptos::*;
use web_sys::MouseEvent;

use super::WasmClosure;

#[derive(Debug, Clone)]
pub struct GlobalMouseupEvent {
    _closure: WasmClosure<MouseEvent>,
    pub read_signal: ReadSignal<Option<MouseEvent>>,
    pub write_signal: WriteSignal<Option<MouseEvent>>,
}

impl GlobalMouseupEvent {
    #[allow(clippy::used_underscore_binding)]
    pub fn new(
        _closure: WasmClosure<MouseEvent>,
        read_signal: ReadSignal<Option<MouseEvent>>,
        write_signal: WriteSignal<Option<MouseEvent>>,
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
