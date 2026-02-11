### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\swap\style.rs
```rust
/// # Swap Rotate Variants
///
/// Style enum for daisyUI swap animation classes that control the transition effect
/// when swapping between elements.
#[derive(Clone, Debug, Default)]
pub enum SwapRotate {
    /// No rotation animation (default)
    #[default]
    None,
    /// Rotation animation for swap transition
    Rotate,
    /// Flip animation for swap transition
    Flip,
}

impl SwapRotate {
    /// CSS class string
    pub fn as_str(&self) -> &'static str {
        match self {
            SwapRotate::None => "",
            SwapRotate::Rotate => "swap-rotate",
            SwapRotate::Flip => "swap-flip",
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
