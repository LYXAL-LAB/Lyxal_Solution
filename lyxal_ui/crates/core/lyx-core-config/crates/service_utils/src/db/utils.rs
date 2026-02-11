### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\db\utils.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\db\utils.rs
10: 8: ```rust
11: 9: use aws_sdk_kms::Client;
12: 10: use diesel::{
13: 11:     PgConnection,
14: 12:     r2d2::{ConnectionManager, Pool},
15: 13: };
16: 14: use urlencoding::encode;
17: 15: 
18: 16: use crate::aws::kms;
19: 17: use crate::helpers::{get_from_env_or_default, get_from_env_unsafe};
20: 18: use crate::service::types::AppEnv;
21: 19: 
22: 20: pub async fn get_lyx-core-lyx_core_lyx-core-lyx_core_superposition_token(
23: 21:     kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
24: 22:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
25: 23: ) -> String {
26: 24:     match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
27: 25:         AppEnv::DEV | AppEnv::TEST | AppEnv::SANDBOX => {
28: 26:             get_from_env_or_default("SUPERPOSITION_TOKEN", "123456".into())
29: 27:         }
30: 28:         _ => kms::decrypt(kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone().unwrap(), "SUPERPOSITION_TOKEN").await,
31: 29:     }
32: 30: }
33: 31: 
34: 32: pub async fn get_oidc_lyx-core-lyx_core_lyx-core-lyx_core_client_secret(
35: 33:     kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
36: 34:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
37: 35: ) -> String {
38: 36:     match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
39: 37:         AppEnv::DEV | AppEnv::TEST | AppEnv::SANDBOX => {
40: 38:             get_from_env_or_default("OIDC_CLIENT_SECRET", "123456".into())
41: 39:         }
42: 40:         _ => kms::decrypt(kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone().unwrap(), "OIDC_CLIENT_SECRET").await,
43: 41:     }
44: 42: }
45: 43: 
46: 44: pub async fn get_database_url(
47: 45:     kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
48: 46:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
49: 47:     env_prefix: Option<&str>,
50: 48: ) -> String {
51: 49:     let env_prefix = env_prefix
52: 50:         .filter(|s| !s.is_empty())
53: 51:         .map(|s| format!("{s}_"))
54: 52:         .unwrap_or_default();
55: 53: 
56: 54:     let db_user: String = get_from_env_unsafe(&format!("{env_prefix}DB_USER")).unwrap();
57: 55:     let db_password: String = match lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env {
58: 56:         AppEnv::DEV | AppEnv::TEST => {
59: 57:             get_from_env_or_default(&format!("{env_prefix}DB_PASSWORD"), "docker".into())
60: 58:         }
61: 59:         _ => {
62: 60:             let kms_lyx-core-lyx_core_lyx-core-lyx_core_client = kms_lyx-core-lyx_core_lyx-core-lyx_core_client.clone().unwrap();
63: 61:             let db_password_raw =
64: 62:                 kms::decrypt(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &format!("{env_prefix}DB_PASSWORD")).await;
65: 63:             encode(db_password_raw.as_str()).to_string()
66: 64:         }
67: 65:     };
68: 66:     let db_host: String = get_from_env_unsafe(&format!("{env_prefix}DB_HOST")).unwrap();
69: 67:     let db_name: String = get_from_env_unsafe(&format!("{env_prefix}DB_NAME")).unwrap();
70: 68:     format!("postgres://{db_user}:{db_password}@{db_host}/{db_name}")
71: 69: }
72: 70: 
73: 71: pub async fn init_pool_manager(
74: 72:     kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<Client>,
75: 73:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: &AppEnv,
76: 74:     max_pool_size: u32,
77: 75: ) -> Pool<ConnectionManager<PgConnection>> {
78: 76:     let database_url = get_database_url(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env, None).await;
79: 77:     let manager = ConnectionManager::<PgConnection>::new(database_url);
80: 78:     Pool::builder()
81: 79:         .max_size(max_pool_size)
82: 80:         .build(manager)
83: 81:         .unwrap()
84: 82: }
85: 83: ```
86: 84: ```
87: 85: ```
88: 86: ```
89: ```
```
