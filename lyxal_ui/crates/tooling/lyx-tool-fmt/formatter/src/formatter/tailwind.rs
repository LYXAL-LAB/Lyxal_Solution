### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\tooling\lyx_tool_fmt\formatter\src\formatter\tailwind.rs
```rust
use rustywind_core::sorter::{self, FinderRegex};

use crate::Formatter;

impl Formatter<'_> {
    pub fn tailwind_expr(&mut self, attr_value: String) {
        static OPTIONS: sorter::Options = sorter::Options {
            regex: FinderRegex::DefaultRegex,
            sorter: sorter::Sorter::DefaultSorter,
            allow_duplicates: true,
        };

        let sorted = sorter::sort_classes(&attr_value, &OPTIONS);
        self.printer.word("\"");
        self.printer.word(sorted);
        self.printer.word("\"");
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
```
```
```
```
