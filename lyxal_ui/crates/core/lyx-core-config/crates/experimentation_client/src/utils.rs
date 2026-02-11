### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_client\src\utils.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_experimentation_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
10: 8: ```rust
11: 9: use std::fmt;
12: 10: 
13: 11: pub trait MapError<T> {
14: 12:     fn map_err_to_string(self) -> Result<T, String>;
15: 13: }
16: 14: 
17: 15: impl<T, E> MapError<T> for Result<T, E>
18: 16: where
19: 17:     E: fmt::Display,
20: 18: {
21: 19:     fn map_err_to_string(self) -> Result<T, String> {
22: 20:         self.map_err(|e| e.to_string())
23: 21:     }
24: 22: }
25: 23: ```
26: 24: ```
27: 25: ```
28: 26: ```
29: ```
```
