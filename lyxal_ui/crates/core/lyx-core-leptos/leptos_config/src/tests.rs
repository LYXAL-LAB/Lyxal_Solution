### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_config\src\tests.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_config\src\tests.rs
2: ```rust
3: 1: use crate::{
4: 2:     env_from_str, env_w_default, env_wo_default, ws_from_str, Env,
5: 3:     LeptosOptions, ReloadWSProtocol,
6: 4: };
7: 5: use std::{net::SocketAddr, str::FromStr};
8: 6: 
9: 7: #[test]
10: 8: fn env_from_str_test() {
11: 9:     assert!(matches!(env_from_str("dev").unwrap(), Env::DEV));
12: 10:     assert!(matches!(env_from_str("development").unwrap(), Env::DEV));
13: 11:     assert!(matches!(env_from_str("DEV").unwrap(), Env::DEV));
14: 12:     assert!(matches!(env_from_str("DEVELOPMENT").unwrap(), Env::DEV));
15: 13:     assert!(matches!(env_from_str("prod").unwrap(), Env::PROD));
16: 14:     assert!(matches!(env_from_str("production").unwrap(), Env::PROD));
17: 15:     assert!(matches!(env_from_str("PROD").unwrap(), Env::PROD));
18: 16:     assert!(matches!(env_from_str("PRODUCTION").unwrap(), Env::PROD));
19: 17:     assert!(env_from_str("TEST").is_err());
20: 18:     assert!(env_from_str("?").is_err());
21: 19: }
22: 20: 
23: 21: #[test]
24: 22: fn ws_from_str_test() {
25: 23:     assert!(matches!(ws_from_str("ws").unwrap(), ReloadWSProtocol::WS));
26: 24:     assert!(matches!(ws_from_str("WS").unwrap(), ReloadWSProtocol::WS));
27: 25:     assert!(matches!(ws_from_str("wss").unwrap(), ReloadWSProtocol::WSS));
28: 26:     assert!(matches!(ws_from_str("WSS").unwrap(), ReloadWSProtocol::WSS));
29: 27:     assert!(ws_from_str("TEST").is_err());
30: 28:     assert!(ws_from_str("?").is_err());
31: 29: }
32: 30: 
33: 31: #[test]
34: 32: fn env_w_default_test() {
35: 33:     temp_env::with_var("LEPTOS_CONFIG_ENV_TEST", Some("custom"), || {
36: 34:         assert_eq!(
37: 35:             env_w_default("LEPTOS_CONFIG_ENV_TEST", "default").unwrap(),
38: 36:             String::from("custom")
39: 37:         );
40: 38:     });
41: 39: 
42: 40:     temp_env::with_var_unset("LEPTOS_CONFIG_ENV_TEST", || {
43: 41:         assert_eq!(
44: 42:             env_w_default("LEPTOS_CONFIG_ENV_TEST", "default").unwrap(),
45: 43:             String::from("default")
46: 44:         );
47: 45:     });
48: 46: }
49: 47: 
50: 48: #[test]
51: 49: fn env_wo_default_test() {
52: 50:     temp_env::with_var("LEPTOS_CONFIG_ENV_TEST", Some("custom"), || {
53: 51:         assert_eq!(
54: 52:             env_wo_default("LEPTOS_CONFIG_ENV_TEST").unwrap(),
55: 53:             Some(String::from("custom"))
56: 54:         );
57: 55:     });
58: 56: 
59: 57:     temp_env::with_var_unset("LEPTOS_CONFIG_ENV_TEST", || {
60: 58:         assert_eq!(env_wo_default("LEPTOS_CONFIG_ENV_TEST").unwrap(), None);
61: 59:     });
62: 60: }
63: 61: 
64: 62: #[test]
65: 63: fn try_from_env_test() {
66: 64:     // Test config values from environment variables
67: 65:     let config = temp_env::with_vars(
68: 66:         [
69: 67:             ("LEPTOS_OUTPUT_NAME", Some("lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_test")),
70: 68:             ("LEPTOS_SITE_ROOT", Some("my_target/site")),
71: 69:             ("LEPTOS_SITE_PKG_DIR", Some("my_pkg")),
72: 70:             ("LEPTOS_SITE_ADDR", Some("0.0.0.0:80")),
73: 71:             ("LEPTOS_RELOAD_PORT", Some("8080")),
74: 72:             ("LEPTOS_RELOAD_EXTERNAL_PORT", Some("8080")),
75: 73:             ("LEPTOS_ENV", Some("PROD")),
76: 74:             ("LEPTOS_RELOAD_WS_PROTOCOL", Some("WSS")),
77: 75:         ],
78: 76:         || LeptosOptions::try_from_env().unwrap(),
79: 77:     );
80: 78: 
81: 79:     assert_eq!(config.output_name.as_ref(), "lyx-platform-lyx_platform_lyx-platform-lyx_platform_app_test");
82: 80:     assert_eq!(config.site_root.as_ref(), "my_target/site");
83: 81:     assert_eq!(config.site_pkg_dir.as_ref(), "my_pkg");
84: 82:     assert_eq!(
85: 83:         config.site_addr,
86: 84:         SocketAddr::from_str("0.0.0.0:80").unwrap()
87: 85:     );
88: 86:     assert_eq!(config.reload_port, 8080);
89: 87:     assert_eq!(config.reload_external_port, Some(8080));
90: 88:     assert_eq!(config.env, Env::PROD);
91: 89:     assert_eq!(config.reload_ws_protocol, ReloadWSProtocol::WSS)
92: 90: }
93: ```
```
