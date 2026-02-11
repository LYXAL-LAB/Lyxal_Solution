### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\shadcn\src\utils\spinner.rs
```rust
use spinners::{Spinner as InnerSpinner, Spinners};

use crate::utils::highlighter::HIGHLIGHTER;

pub struct Spinner {
    inner: InnerSpinner,
    options: SpinnerOptions,
}

impl Spinner {
    fn new(text: String, options: SpinnerOptions) -> Self {
        Self {
            inner: InnerSpinner::new(Spinners::Dots, text),
            options,
        }
    }

    pub fn fail(&mut self) {
        self.inner.stop_with_symbol(&HIGHLIGHTER.error("✖"));
    }

    pub fn succeed(&mut self, text: Option<String>) {
        // TODO: text
        self.inner.stop_with_symbol(&HIGHLIGHTER.success("✔"));
    }
}

#[derive(Default)]
pub struct SpinnerOptions {
    // TODO
    pub silent: bool,
}

pub fn spinner<T: Into<String>>(text: T, options: SpinnerOptions) -> Spinner {
    Spinner::new(text.into(), options)
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
