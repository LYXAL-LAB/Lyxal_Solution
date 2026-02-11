### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_leptonic\leptonic\src\hooks\interactions\use_long_press.rs
```rust
use leptos::Oco;
use leptos_reactive::{Callback, MaybeSignal};

pub struct LongPressEvent {}

pub struct UseLongPressInput {
    /// Whether long press events should be disabled.
    disabled: MaybeSignal<bool>,

    /// Handler that is called when a long press interaction starts.
    on_long_press_start: Callback<LongPressEvent>,

    /// Handler that is called when a long press interaction ends, either
    /// over the target or when the pointer leaves the target.
    on_long_press_end: Callback<LongPressEvent>,

    /// Handler that is called when the threshold time is met while
    /// the press is over the target.
    on_long_press: Callback<LongPressEvent>,

    /// The amount of time in milliseconds to wait before triggering a long press.
    /// Default is 500ms.
    threshold: u64,

    /// A description for assistive technology users indicating that a long press
    /// action is available, e.g. "Long press to open menu".
    accessibility_description: Oco<'static, str>,
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
