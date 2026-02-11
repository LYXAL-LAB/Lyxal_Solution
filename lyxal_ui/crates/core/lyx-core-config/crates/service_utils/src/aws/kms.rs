### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_service_utils\src\aws\kms.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\aws\kms.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\aws\kms.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\aws\kms.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\aws\kms.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\aws\kms.rs
10: 8: ```rust
11: 9: use crate::helpers::get_from_env_unsafe;
12: 10: use aws_sdk_kms::{Client, primitives::Blob};
13: 11: use base64::{Engine, engine::general_purpose};
14: 12: 
15: 13: async fn decrypt_helper(aws_kms_cli: Client, key: &str, key_value_env: String) -> String {
16: 14:     let key_value_enc = general_purpose::STANDARD
17: 15:         .decode(key_value_env)
18: 16:         .expect("Input string does not contain valid base 64 characters.");
19: 17: 
20: 18:     let key_value_bytes_result = aws_kms_cli
21: 19:         .decrypt()
22: 20:         .ciphertext_blob(Blob::new(key_value_enc))
23: 21:         .send()
24: 22:         .await;
25: 23:     let key_value: String = String::from_utf8(
26: 24:         key_value_bytes_result
27: 25:             .unwrap_or_else(|_| panic!("Failed to decrypt {key}"))
28: 26:             .plaintext()
29: 27:             .unwrap_or_else(|| panic!("Failed to get plaintext value for {key}"))
30: 28:             .as_ref()
31: 29:             .to_vec(),
32: 30:     )
33: 31:     .expect("Could not convert to UTF-8");
34: 32:     key_value
35: 33: }
36: 34: 
37: 35: pub async fn decrypt(aws_kms_cli: Client, key: &str) -> String {
38: 36:     let key_value_env: String =
39: 37:         get_from_env_unsafe(key).unwrap_or_else(|_| panic!("{key} not present in env"));
40: 38:     decrypt_helper(aws_kms_cli, key, key_value_env).await
41: 39: }
42: 40: 
43: 41: pub async fn decrypt_opt(aws_kms_cli: Client, key: &str) -> Option<String> {
44: 42:     let key_value_env: String = get_from_env_unsafe(key).ok()?;
45: 43:     Some(decrypt_helper(aws_kms_cli, key, key_value_env).await)
46: 44: }
47: 45: 
48: 46: pub async fn new_lyx-core-lyx_core_lyx-core-lyx_core_client() -> Client {
49: 47:     let config = aws_config::load_from_env().await;
50: 48: 
51: 49:     aws_sdk_kms::Client::new(&config)
52: 50: }
53: 51: ```
54: 52: ```
55: 53: ```
56: 54: ```
57: ```
```
