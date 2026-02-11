### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\params.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\params.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
4: 2: use lyx-core-lyx_core_lyx-core-router::params::Params;
5: 3: 
6: 4: #[derive(PartialEq, Debug, Params)]
7: 5: struct UserInfo {
8: 6:     user_id: Option<String>,
9: 7:     email: Option<String>,
10: 8:     r#type: Option<i32>,
11: 9:     not_found: Option<i32>,
12: 10: }
13: 11: 
14: 12: #[test]
15: 13: fn params_test() {
16: 14:     let mut map = lyx-core-lyx_core_lyx-core-router::params::ParamsMap::new();
17: 15:     map.insert("user_id", "12".to_owned());
18: 16:     map.insert("email", "em@il".to_owned());
19: 17:     map.insert("type", "12".to_owned());
20: 18:     let user_info = UserInfo::from_map(&map).unwrap();
21: 19:     assert_eq!(
22: 20:         UserInfo {
23: 21:             email: Some("em@il".to_owned()),
24: 22:             user_id: Some("12".to_owned()),
25: 23:             r#type: Some(12),
26: 24:             not_found: None,
27: 25:         },
28: 26:         user_info
29: 27:     );
30: 28: }
31: ```
```
