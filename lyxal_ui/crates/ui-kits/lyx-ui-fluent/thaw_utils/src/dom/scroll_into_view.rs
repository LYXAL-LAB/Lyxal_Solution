### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_utils\src\dom\scroll_into_view.rs
```rust
use cfg_if::cfg_if;
use web_sys::HtmlElement;

pub fn scroll_into_view(el: &HtmlElement) {
    cfg_if! { if #[cfg(all(target_arch = "wasm32", any(feature = "csr", feature = "hydrate")))] {
        use super::get_scroll_parent_element;
        if let Some(parent) = get_scroll_parent_element(el) {
            let parent_rect = parent.get_bounding_client_rect();
            let el_rect = el.get_bounding_client_rect();
            if el_rect.y() < parent_rect.y() {
                el.scroll_into_view_with_bool(true);
            } else if el_rect.y() + el_rect.height() > parent_rect.y() + parent_rect.height() {
                el.scroll_into_view_with_bool(false);
            }
        }
    } else {
        let _ = el;
    }}
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
