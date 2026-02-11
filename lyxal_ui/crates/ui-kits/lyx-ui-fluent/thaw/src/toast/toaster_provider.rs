### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw\src\toast\toaster_provider.rs
```rust
use super::{toaster::Toaster, ToastIntent, ToastPosition, ToasterInjection};
use leptos::{context::Provider, prelude::*};

#[component]
pub fn ToasterProvider(
    /// The position the toast should render.
    #[prop(optional)]
    position: ToastPosition,
    /// The intent of the toasts
    #[prop(optional)]
    intent: ToastIntent,
    children: Children,
) -> impl IntoView {
    let (injection, receiver) = ToasterInjection::channel();
    view! {
        <Toaster receiver position intent />
        <Provider value=injection>{children()}</Provider>
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
