### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\logic\lyx_logic_use\src\core\ssr_safe_method.rs
```rust
#![allow(unused_macros, unused_imports)]

macro_rules! impl_ssr_safe_method {
    (
        $(#[$attr:meta])*
        $method:ident(&self$(, $p_name:ident: $p_ty:ty)*) -> $return_ty:ty
        $(; $($post_fix:tt)+)?
    ) => {
        $(#[$attr])*
        #[inline(always)]
        pub fn $method(&self, $($p_name: $p_ty),*) -> $return_ty {
            self.0.as_ref()
                .map(
                    |w| w.$method($($p_name),*)
                )
                $($($post_fix)+)?
        }
    };
}

pub(crate) use impl_ssr_safe_method;
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
