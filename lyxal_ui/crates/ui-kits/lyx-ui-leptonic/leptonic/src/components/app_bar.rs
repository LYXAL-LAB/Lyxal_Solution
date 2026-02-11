### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\components\app_bar.rs
```rust
use leptos::*;

use crate::Height;

#[component]
pub fn AppBar(
    #[prop(into, optional)] id: Option<AttributeValue>,
    #[prop(into, optional)] class: Option<AttributeValue>,
    #[prop(into, optional)] style: Option<AttributeValue>,
    #[prop(into, optional)] height: Option<Height>,
    children: Children,
) -> impl IntoView {
    view! {
        <leptonic-app-bar id=id class=class style=style style=("--app-bar-height", move || height.map(|it| format!("{it}")))>
            { children() }
        </leptonic-app-bar>
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
```
```
```
```
