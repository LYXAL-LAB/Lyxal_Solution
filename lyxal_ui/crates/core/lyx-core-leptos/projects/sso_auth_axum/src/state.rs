### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_sso_auth_axum\src\state.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\lyx-core-lyx_core_lyx-core-lyx_core_sso_auth_axum\src\state.rs
2: ```rust
3: 1: use axum::extract::FromRef;
4: 2: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions;
5: 3: use sqlx::SqlitePool;
6: 4: 
7: 5: /// This takes advantage of Axum's SubStates feature by deriving FromRef. This is the only way to have more than one
8: 6: /// item in Axum's State. Leptos requires you to have lyx-core-lyx_core_lyx-core-lyx_core_leptosOptions in your State struct for the lyx-core-lyx_core_lyx-core-lyx_core_leptos route handlers
9: 7: #[derive(FromRef, Debug, Clone)]
10: 8: pub struct AppState {
11: 9:     pub lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: LeptosOptions,
12: 10:     pub pool: SqlitePool,
13: 11:     pub lyx-core-lyx_core_lyx-core-lyx_core_client: oauth2::lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic::BasicClient,
14: 12: }
15: ```
```
