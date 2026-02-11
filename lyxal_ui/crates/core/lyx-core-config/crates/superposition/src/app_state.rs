### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_superposition\src\lyx-platform-lyx_platform_app_state.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_state.rs
10: 8: ```rust
11: 9: use std::{
12: 10:     collections::HashSet,
13: 11:     sync::{Arc, Mutex},
14: 12: };
15: 13: 
16: 14: #[cfg(feature = "high-performance-mode")]
17: 15: use std::time::Duration;
18: 16: 
19: 17: use lyx-core-lyx_core_lyx-core-lyx_core_context_aware_config::helpers::get_meta_schema;
20: 18: 
21: 19: #[cfg(feature = "high-performance-mode")]
22: 20: use fred::{
23: 21:     lyx-core-lyx_core_lyx-core-lyx_core_clients::RedisPool,
24: 22:     interfaces::ClientLike,
25: 23:     types::{ConnectionConfig, PerformanceConfig, ReconnectPolicy, RedisConfig},
26: 24: };
27: 25: use lyx-core-lyx_core_lyx-core-lyx_core_service_utils::{
28: 26:     db::utils::{get_lyx-core-lyx_core_lyx-core-lyx_core_superposition_token, init_pool_manager},
29: 27:     encryption::get_master_encryption_keys,
30: 28:     helpers::{get_from_env_or_default, get_from_env_unsafe},
31: 29:     service::types::{AppEnv, AppState, ExperimentationFlags},
32: 30: };
33: 31: use snowflake::SnowflakeIdGenerator;
34: 32: 
35: 33: pub async fn get(
36: 34:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env: AppEnv,
37: 35:     port: u16,
38: 36:     kms_lyx-core-lyx_core_lyx-core-lyx_core_client: &Option<aws_sdk_kms::Client>,
39: 37:     service_prefix: String,
40: 38:     base: &str,
41: 39: ) -> AppState {
42: 40:     let master_encryption_key = get_master_encryption_keys(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env)
43: 41:         .await
44: 42:         .unwrap_or_else(|e| {
45: 43:             panic!("Error getting encryption keys: {e}");
46: 44:         });
47: 45:     let cac_host =
48: 46:         get_from_env_or_default::<String>("CAC_HOST", format!("http://localhost:{port}"))
49: 47:             + base;
50: 48:     let max_pool_size = get_from_env_or_default("MAX_DB_CONNECTION_POOL_SIZE", 2);
51: 49: 
52: 50:     let snowflake_generator = Arc::new(Mutex::new(SnowflakeIdGenerator::new(1, 1)));
53: 51: 
54: 52:     #[cfg(feature = "high-performance-mode")]
55: 53:     let redis_pool = {
56: 54:         let redis_url =
57: 55:             get_from_env_or_default("REDIS_URL", String::from("http://localhost:6379"));
58: 56:         let redis_pool_size = get_from_env_or_default("REDIS_POOL_SIZE", 10);
59: 57:         let redis_max_attempts = get_from_env_or_default("REDIS_MAX_ATTEMPTS", 10);
60: 58:         let redis_connection_timeout =
61: 59:             get_from_env_or_default("REDIS_CONN_TIMEOUT", 1000);
62: 60:         let config = RedisConfig::from_url(&redis_url).unwrap_or_else(|_| {
63: 61:             panic!("Failed to create RedisConfig from url {}", redis_url)
64: 62:         });
65: 63:         let reconnect_policy = ReconnectPolicy::new_constant(redis_max_attempts, 100);
66: 64:         let redis_pool = RedisPool::new(
67: 65:             config,
68: 66:             Some(PerformanceConfig {
69: 67:                 auto_pipeline: true,
70: 68:                 ..Default::default()
71: 69:             }),
72: 70:             Some(ConnectionConfig {
73: 71:                 connection_timeout: Duration::from_millis(redis_connection_timeout),
74: 72:                 ..Default::default()
75: 73:             }),
76: 74:             Some(reconnect_policy),
77: 75:             redis_pool_size,
78: 76:         )
79: 77:         .map_err(|e| format!("Could not connect to redis due to {e}"))
80: 78:         .unwrap();
81: 79: 
82: 80:         redis_pool.connect();
83: 81:         redis_pool
84: 82:             .wait_for_connect()
85: 83:             .await
86: 84:             .expect("Failed to connect to Redis");
87: 85: 
88: 86:         redis_pool
89: 87:     };
90: 88: 
91: 89:     AppState {
92: 90:         db_pool: init_pool_manager(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env, max_pool_size).await,
93: 91:         cac_host,
94: 92:         cac_version: get_from_env_unsafe("SUPERPOSITION_VERSION")
95: 93:             .expect("SUPERPOSITION_VERSION is not set"),
96: 94:         experimentation_flags: ExperimentationFlags {
97: 95:             allow_same_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: get_from_env_unsafe(
98: 96:                 "ALLOW_SAME_KEYS_OVERLAPPING_CTX",
99: 97:             )
100: 98:             .expect("ALLOW_SAME_KEYS_OVERLAPPING_CTX not set"),
101: 99:             allow_diff_keys_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: get_from_env_unsafe(
102: 100:                 "ALLOW_DIFF_KEYS_OVERLAPPING_CTX",
103: 101:             )
104: 102:             .expect("ALLOW_DIFF_KEYS_OVERLAPPING_CTX not set"),
105: 103:             allow_same_keys_non_overllyx-platform-lyx_platform_lyx-platform-lyx_platform_apping_ctx: get_from_env_unsafe(
106: 104:                 "ALLOW_SAME_KEYS_NON_OVERLAPPING_CTX",
107: 105:             )
108: 106:             .expect("ALLOW_SAME_KEYS_NON_OVERLAPPING_CTX not set"),
109: 107:         },
110: 108:         snowflake_generator,
111: 109:         meta_schema: get_meta_schema(),
112: 110:         lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env,
113: 111:         tenant_middleware_exclusion_list: get_from_env_unsafe::<String>(
114: 112:             "TENANT_MIDDLEWARE_EXCLUSION_LIST",
115: 113:         )
116: 114:         .expect("TENANT_MIDDLEWARE_EXCLUSION_LIST is not set")
117: 115:         .split(',')
118: 116:         .map(String::from)
119: 117:         .collect::<HashSet<_>>(),
120: 118:         service_prefix,
121: 119:         lyx-core-lyx_core_lyx-core-lyx_core_superposition_token: get_lyx-core-lyx_core_lyx-core-lyx_core_superposition_token(kms_lyx-core-lyx_core_lyx-core-lyx_core_client, &lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_env).await,
122: 120:         #[cfg(feature = "high-performance-mode")]
123: 121:         redis: redis_pool,
124: 122:         http_lyx-core-lyx_core_lyx-core-lyx_core_client: reqwest::Client::new(),
125: 123:         master_encryption_key,
126: 124:     }
127: 125: }
128: 126: ```
129: 127: ```
130: 128: ```
131: 129: ```
132: ```
```
