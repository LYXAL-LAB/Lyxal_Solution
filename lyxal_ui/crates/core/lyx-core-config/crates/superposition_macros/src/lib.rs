### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros\src\lib.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros\src\lib.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros\src\lib.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros\src\lib.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_macros\src\lib.rs
10: 8: ```rust
11: 9: #![deny(unused_crate_dependencies)]
12: 10: #[macro_export]
13: 11: macro_rules! bad_argument {
14: 12:     ($msg: literal, $($args: tt)*) => {
15: 13:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::BadArgument(format!($msg, $($args)*))
16: 14:     };
17: 15:     ($err: tt) => {
18: 16:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::BadArgument($err.to_string())
19: 17:     };
20: 18: }
21: 19: 
22: 20: #[macro_export]
23: 21: macro_rules! validation_error {
24: 22:     ($msg: literal, $($args: tt)*) => {
25: 23:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::ValidationError(format!($msg, $($args)*))
26: 24:     };
27: 25:     ($err: tt) => {
28: 26:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::ValidationError($err.to_string())
29: 27:     };
30: 28: }
31: 29: 
32: 30: #[macro_export]
33: 31: macro_rules! unexpected_error {
34: 32:     ($msg: literal, $($args: tt)*) => {
35: 33:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::UnexpectedError(anyhow::anyhow!(format!($msg, $($args)*)))
36: 34:     };
37: 35:     ($err: tt) => {
38: 36:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::UnexpectedError(anyhow::anyhow!($err.to_string()))
39: 37:     };
40: 38: }
41: 39: 
42: 40: #[macro_export]
43: 41: macro_rules! not_found {
44: 42:     ($msg: literal, $($args: tt)*) => {
45: 43:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::NotFound(format!($msg, $($args)*))
46: 44:     };
47: 45:     ($err: tt) => {
48: 46:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::NotFound($err.to_string())
49: 47:     };
50: 48: }
51: 49: 
52: 50: #[macro_export]
53: 51: macro_rules! db_error {
54: 52:     ($error: expr) => {
55: 53:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::DbError($error)
56: 54:     };
57: 55: }
58: 56: 
59: 57: #[macro_export]
60: 58: macro_rules! response_error {
61: 59:     ($status: expr, $msg: expr) => {
62: 60:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::ResponseError(
63: 61:             lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::ResponseError {
64: 62:                 status_code: $status,
65: 63:                 message: $msg.to_string(),
66: 64:             },
67: 65:         )
68: 66:     };
69: 67: }
70: 68: 
71: 69: #[macro_export]
72: 70: macro_rules! forbidden {
73: 71:     ($msg: literal, $($args: tt)*) => {
74: 72:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::Forbidden(format!($msg, $($args)*))
75: 73:     };
76: 74:     ($err: tt) => {
77: 75:         lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::result::AppError::Forbidden($err.to_string())
78: 76:     };
79: 77: }
80: 78: 
81: 79: #[macro_export]
82: 80: macro_rules! box_params {
83: 81:     ($($param:expr),* $(,)?) => {
84: 82:         vec![
85: 83:             $(Box::new($param),)*
86: 84:         ]
87: 85:     };
88: 86: }
89: 87: ```
90: 88: ```
91: 89: ```
92: 90: ```
93: ```
```
