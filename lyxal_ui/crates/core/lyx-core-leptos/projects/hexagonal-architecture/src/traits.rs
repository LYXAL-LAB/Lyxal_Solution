### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\traits.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\traits.rs
2: ```rust
3: 1: use super::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types::*;
4: 2: use axum::async_trait;
5: 3: use mockall::automock;
6: 4: pub trait New {
7: 5:     fn new() -> Self;
8: 6: }
9: 7: 
10: 8: #[automock]
11: 9: #[async_trait]
12: 10: pub trait HandlerTrait {
13: 11:     async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_1(&self) -> Result<DomainData, DomainError>;
14: 12:     async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_2(&self) -> Result<DomainData2, DomainError>;
15: 13:     async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_3(&self) -> Result<DomainData3, DomainError>;
16: 14: }
17: 15: 
18: 16: #[automock]
19: 17: #[async_trait]
20: 18: pub trait SubDomainTrait1 {
21: 19:     async fn sub_domain_1_method(&self) -> Result<SubDomain1Data, SubDomain1Error>;
22: 20: }
23: 21: 
24: 22: #[automock]
25: 23: #[async_trait]
26: 24: pub trait SubDomainTrait2 {
27: 25:     async fn sub_domain_2_method(&self) -> Result<SubDomain2Data, SubDomain2Error>;
28: 26: }
29: 27: 
30: 28: #[automock]
31: 29: #[async_trait]
32: 30: pub trait ExternalServiceTrait1 {
33: 31:     async fn external_service_1_method(
34: 32:         &self,
35: 33:     ) -> Result<ExternalService1Data, ExternalService1Error>;
36: 34: }
37: 35: 
38: 36: #[automock]
39: 37: #[async_trait]
40: 38: pub trait ExternalServiceTrait2 {
41: 39:     async fn external_service_2_method(
42: 40:         &self,
43: 41:     ) -> Result<ExternalService2Data, ExternalService2Error>;
44: 42: }
45: ```
```
