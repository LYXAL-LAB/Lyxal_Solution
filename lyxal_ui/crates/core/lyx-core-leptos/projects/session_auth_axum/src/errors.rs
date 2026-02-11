### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_session_auth_axum\src\errors.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_session_auth_axum\src\errors.rs
2: ```rust
3: 1: use http::status::StatusCode;
4: 2: use thiserror::Error;
5: 3: 
6: 4: #[derive(Debug, Clone, Error)]
7: 5: pub enum TodoAppError {
8: 6:     #[error("Not Found")]
9: 7:     NotFound,
10: 8:     #[error("Internal Server Error")]
11: 9:     InternalServerError,
12: 10: }
13: 11: 
14: 12: impl TodoAppError {
15: 13:     pub fn status_code(&self) -> StatusCode {
16: 14:         match self {
17: 15:             TodoAppError::NotFound => StatusCode::NOT_FOUND,
18: 16:             TodoAppError::InternalServerError => {
19: 17:                 StatusCode::INTERNAL_SERVER_ERROR
20: 18:             }
21: 19:         }
22: 20:     }
23: 21: }
24: ```
```
