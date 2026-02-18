### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\platform\lyx_plat_workers\src\api\d1.rs
// This file is just an lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example and isn't included by default.
// Use it as a building block for the rest of your worker-specific lyx-platform-lyx_platform_lyx-platform-lyx_platform_server functions.

use lyx-core-lyx_core_lyx-core-lyx_core_leptos::*;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize)]
pub struct PostData {
pub id: i64,
pub user_id: i64,
pub title: String,
}

#[cfg_attr(feature = "ssr", worker::send)] // <- required to await data from env
#[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(GetPost)]
pub async fn get_post(post_id: i64) -> Result<Option<PostData>, ServerFnError> {
use std::time::Duration;

use axum::Extension;
use lyx-core-axum::*;
use std::sync::Arc;
use worker::*;

/// Get our Worker env variable from axum
let Extension(env): Extension<Arc<Env>> = extract().await?;

/// Connect to our database
let d1 = env.d1("DB").unwrap();

/// Load the post data
let stmt = query!(&d1, "SELECT * FROM post where id=?", post_id).unwrap();
let result: Option<PostData> = stmt.first().await.unwrap();

Ok(result)
}
