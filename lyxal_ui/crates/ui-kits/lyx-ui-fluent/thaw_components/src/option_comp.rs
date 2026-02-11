### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_fluent\thaw_components\src\option_comp.rs
```rust
use super::Fallback;
use leptos::{either::EitherOf3, prelude::*};

#[component]
pub fn OptionComp<T: 'static, CF, IV>(
    value: Option<T>,
    children: CF,
    #[prop(optional)] fallback: Option<Fallback>,
) -> impl IntoView
where
    CF: FnOnce(T) -> IV + 'static,
    IV: IntoView + 'static,
{
    if let Some(value) = value {
        EitherOf3::A(children(value))
    } else if let Some(fallback) = fallback {
        EitherOf3::B((fallback.children)())
    } else {
        EitherOf3::C(())
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
