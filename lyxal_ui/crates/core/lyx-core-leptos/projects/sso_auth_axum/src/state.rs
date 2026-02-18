use axum::extract::FromRef;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::LeptosOptions;
use sqlx::SqlitePool;

/// This takes advantage of Axum's SubStates feature by deriving FromRef. This is the only way to have more than one
/// item in Axum's State. Leptos requires you to have lyx-core-lyx_core_lyx-core-lyx_core_leptosOptions in your State struct for the lyx-core-lyx_core_lyx-core-lyx_core_leptos route handlers
#[derive(FromRef, Debug, Clone)]
pub struct AppState {
pub lyx-core-lyx_core_lyx-core-lyx_core_leptos_options: LeptosOptions,
pub pool: SqlitePool,
pub lyx-core-lyx_core_lyx-core-lyx_core_client: oauth2::lyx-logic-lyx_logic_lyx-logic-lyx_logic_basic::BasicClient,
}
