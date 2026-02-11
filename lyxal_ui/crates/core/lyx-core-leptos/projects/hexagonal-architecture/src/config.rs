### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\config.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\config.rs
2: ```rust
3: 1: use super::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types::*;
4: 2: 
5: 3: pub fn config() -> HandlerStructAlias {
6: 4:     cfg_if::cfg_if! {
7: 5:                 if #[cfg(feature="config_1")] {
8: 6:                     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_handler_config_1() -> HandlerStruct<
9: 7:             SubDomainStruct1<ExternalService1_1, ExternalService2_1>,
10: 8:             SubDomainStruct2<ExternalService1_1>,
11: 9:         > {
12: 10:             HandlerStruct::default()
13: 11:         }
14: 12:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_handler_config_1()
15: 13:                 } else {
16: 14:                     fn lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_handler_config_2() -> HandlerStruct<
17: 15:         SubDomainStruct1<ExternalService1_2, ExternalService2_2>,
18: 16:         SubDomainStruct2<ExternalService1_2>,
19: 17:     > {
20: 18:         HandlerStruct::new()
21: 19:     }
22: 20:                     lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_handler_config_2()
23: 21:                 }
24: 22:             }
25: 23: }
26: ```
```
