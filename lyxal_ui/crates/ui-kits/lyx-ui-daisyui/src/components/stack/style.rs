### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\stack\style.rs
```rust
/// # Stack Placement Variants
#[derive(Clone, Debug, Default)]
pub enum StackPlacement {
    /// Top vertical placement
    Top,

    /// Bottom vertical placement
    #[default]
    Bottom,

    /// Start horizontal placement
    Start,

    /// End horizaonahorizontall placement
    End,
}

impl StackPlacement {
    /// CSS class string
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Top => "stack-top",
            Self::Bottom => "indicator-bottom",
            Self::Start => "stack-start",
            Self::End => "stack-end",
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
