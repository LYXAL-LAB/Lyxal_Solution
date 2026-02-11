### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-foundations\lyx_found_tailwind\variant-macro\src\lib.rs
```rust
use proc_macro::TokenStream;

mod class_macro;
mod model;
mod variant_macro;

#[proc_macro_derive(TwVariant, attributes(tw))]
pub fn variant(input: TokenStream) -> TokenStream {
    variant_macro::variant_impl(input)
}

#[proc_macro_derive(TwClass, attributes(tw))]
pub fn class(input: TokenStream) -> TokenStream {
    class_macro::class_impl(input)
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
