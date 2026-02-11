### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_config\src\errors.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config\src\errors.rs
2: ```rust
3: 1: use std::{net::AddrParseError, num::ParseIntError, str::ParseBoolError};
4: 2: use thiserror::Error;
5: 3: 
6: 4: #[derive(Debug, Error, Clone)]
7: 5: pub enum LeptosConfigError {
8: 6:     #[error("Cargo.toml not found in package root")]
9: 7:     ConfigNotFound,
10: 8:     #[error("package.metadata.lyx-core-lyx_core_lyx-core-lyx_core_leptos section missing from Cargo.toml")]
11: 9:     ConfigSectionNotFound,
12: 10:     #[error("Failed to get Leptos Environment. Did you set LEPTOS_ENV?")]
13: 11:     EnvError,
14: 12:     #[error("Config Error: {0}")]
15: 13:     ConfigError(String),
16: 14:     #[error("Config Error: {0}")]
17: 15:     EnvVarError(String),
18: 16: }
19: 17: impl From<config::ConfigError> for LeptosConfigError {
20: 18:     fn from(e: config::ConfigError) -> Self {
21: 19:         Self::ConfigError(e.to_string())
22: 20:     }
23: 21: }
24: 22: 
25: 23: impl From<ParseIntError> for LeptosConfigError {
26: 24:     fn from(e: ParseIntError) -> Self {
27: 25:         Self::ConfigError(e.to_string())
28: 26:     }
29: 27: }
30: 28: 
31: 29: impl From<AddrParseError> for LeptosConfigError {
32: 30:     fn from(e: AddrParseError) -> Self {
33: 31:         Self::ConfigError(e.to_string())
34: 32:     }
35: 33: }
36: 34: 
37: 35: impl From<ParseBoolError> for LeptosConfigError {
38: 36:     fn from(e: ParseBoolError) -> Self {
39: 37:         Self::ConfigError(e.to_string())
40: 38:     }
41: 39: }
42: ```
```
