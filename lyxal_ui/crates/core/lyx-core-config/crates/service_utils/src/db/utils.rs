### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
use aws_sdk_kms::Client;
use diesel::{
PgConnection,
r2d2::{ConnectionManager, Pool},
};
use urlencoding::encode;

use crate::aws::kms;
use crate::helpers::{get_from_env_or_default, get_from_env_unsafe};
use crate::service::types::AppEnv;

pub async fn get_lyx-core-lyx_core_lyx-core-lyx_core_superposition_token(
kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
) -> String {
match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
AppEnv::DEV | AppEnv::TEST | AppEnv::SANDBOX => {
get_from_env_or_default("SUPERPOSITION_TOKEN", "123456".into())
}
_ => kms::decrypt(kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone().unwrap(), "SUPERPOSITION_TOKEN").await,
}
}

pub async fn get_oidc_lyx-core-lyx_core_lyx-core-lyx_core_client_secret(
kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
) -> String {
match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
AppEnv::DEV | AppEnv::TEST | AppEnv::SANDBOX => {
get_from_env_or_default("OIDC_CLIENT_SECRET", "123456".into())
}
_ => kms::decrypt(kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone().unwrap(), "OIDC_CLIENT_SECRET").await,
}
}

pub async fn get_database_url(
kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
env_prefix: Option<&str>,
) -> String {
let env_prefix = env_prefix
.filter(|s| !s.is_empty())
.map(|s| format!("{s}_"))
.unwrap_or_default();

let db_user: String = get_from_env_unsafe(&format!("{env_prefix}DB_USER")).unwrap();
let db_password: String = match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
AppEnv::DEV | AppEnv::TEST => {
get_from_env_or_default(&format!("{env_prefix}DB_PASSWORD"), "docker".into())
}
_ => {
let kms_lyx-core-lyx_core_lyx-core-lyx_core_client = kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone().unwrap();
let db_password_raw =
kms::decrypt(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &format!("{env_prefix}DB_PASSWORD")).await;
encode(db_password_raw.as_str()).to_string()
}
};
let db_host: String = get_from_env_unsafe(&format!("{env_prefix}DB_HOST")).unwrap();
let db_name: String = get_from_env_unsafe(&format!("{env_prefix}DB_NAME")).unwrap();
format!("postgres://{db_user}:{db_password}@{db_host}/{db_name}")
}

pub async fn init_pool_manager(
kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
max_pool_size: u32,
) -> Pool<ConnectionManager<PgConnection>> {
let database_url = get_database_url(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env, None).await;
let manager = ConnectionManager::<PgConnection>::new(database_url);
Pool::builder()
.max_size(max_pool_size)
.build(manager)
.unwrap()
}
