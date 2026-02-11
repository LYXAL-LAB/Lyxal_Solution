### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\utils\text_selection.rs
```rust
pub(crate) fn disable_text_selection(element: &web_sys::Element) {
    match element.set_attribute("data-disable-user-select", "true") {
        Ok(_ok) => {}
        Err(err) => {
            tracing::warn!(?err, "Could not set 'data-disable-user-select' attribute.");
        }
    }
}

pub(crate) fn restore_text_selection(element: &web_sys::Element) {
    match element.remove_attribute("data-disable-user-select") {
        Ok(_ok) => {}
        Err(err) => {
            tracing::warn!(
                ?err,
                "Could not remove 'data-disable-user-select' attribute."
            );
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
