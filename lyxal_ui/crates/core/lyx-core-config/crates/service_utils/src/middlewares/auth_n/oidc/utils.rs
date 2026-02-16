1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\middlewares\auth_n\oidc\utils.rs
10: 8: ```rust
11: 9: use openidconnect::{AdditionalClaims, GenderClaim, IdTokenClaims, Nonce};
12: 10: use lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_superposition_types::User;
13: 11: 
14: 12: pub(super) fn verify_presence(n: Option<&Nonce>) -> Result<(), String> {
15: 13:     if n.is_some() {
16: 14:         Ok(())
17: 15:     } else {
18: 16:         Err("missing nonce claim".to_string())
19: 17:     }
20: 18: }
21: 19: 
22: 20: pub(super) fn presence_no_check(_: Option<&Nonce>) -> Result<(), String> {
23: 21:     Ok(())
24: 22: }
25: 23: 
26: 24: pub(super) fn try_user_from<A: AdditionalClaims, B: GenderClaim>(
27: 25:     claims: &IdTokenClaims<A, B>,
28: 26: ) -> Result<User, String> {
29: 27:     let user = User {
30: 28:         email: claims
31: 29:             .email()
32: 30:             .ok_or(String::from("Email not found"))?
33: 31:             .to_string(),
34: 32:         username: claims
35: 33:             .preferred_username()
36: 34:             .ok_or(String::from("Username not found"))?
37: 35:             .to_string(),
38: 36:     };
39: 37:     Ok(user)
40: 38: }
41: 39: ```
42: 40: ```
43: 41: ```
44: 42: ```
45: ```
```

