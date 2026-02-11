### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_daisyui\src\components\radial_progress\style.rs
```rust
/// # Radial Progress Color Variants
///
/// Style enum for daisyUI radial progress color classes that control the semantic color scheme
/// of radial progress indicators. Colors follow daisyUI's semantic system for context and meaning.
#[derive(Clone, Debug, Default)]
pub enum RadialProgressColor {
    /// Default radial progress color (no color class applied)
    #[default]
    Default,

    /// Primary brand color for main progress indicators
    Primary,

    /// Secondary brand color for secondary progress indicators
    Secondary,

    /// Accent brand color for highlighted progress indicators
    Accent,

    /// Success color for positive progress indicators
    Success,

    /// Info color for informational progress indicators
    Info,

    /// Warning color for cautionary progress indicators
    Warning,

    /// Error color for error state progress indicators
    Error,
}

impl RadialProgressColor {
    /// CSS class string
    pub fn as_str(&self) -> &'static str {
        match self {
            RadialProgressColor::Default => "",
            RadialProgressColor::Primary => "text-primary",
            RadialProgressColor::Secondary => "text-secondary",
            RadialProgressColor::Accent => "text-accent",
            RadialProgressColor::Success => "text-success",
            RadialProgressColor::Info => "text-info",
            RadialProgressColor::Warning => "text-warning",
            RadialProgressColor::Error => "text-error",
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
```
```
```
```
