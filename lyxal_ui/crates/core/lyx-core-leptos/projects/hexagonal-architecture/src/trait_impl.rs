### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\trait_impl.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\trait_impl.rs
2: ```rust
3: 1: use crate::ui_types::*;
4: 2: 
5: 3: use super::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types::*;
6: 4: use super::traits::*;
7: 5: use axum::async_trait;
8: 6: use axum::extract::FromRef;
9: 7: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::config::LeptosOptions;
10: 8: 
11: 9: // So we can pass our lyx-platform-lyx_platform_lyx-platform-lyx_platform_server state as state into our lyx-core-lyx_core_lyx-core-lyx_core_leptos router.
12: 10: impl<Handler: HandlerTrait + Clone> FromRef<ServerState<Handler>> for LeptosOptions {
13: 11:     fn from_ref(input: &ServerState<Handler>) -> Self {
14: 12:         input.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone()
15: 13:     }
16: 14: }
17: 15: 
18: 16: #[async_trait]
19: 17: impl<SubDomain1, SubDomain2> HandlerTrait for HandlerStruct<SubDomain1, SubDomain2>
20: 18: where
21: 19:     SubDomain1: SubDomainTrait1 + Send + Sync,
22: 20:     SubDomain2: SubDomainTrait2 + Send + Sync,
23: 21: {
24: 22:     async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_1(&self) -> Result<DomainData, DomainError> {
25: 23:         Ok(self.sub_domain_1.sub_domain_1_method().await?.into())
26: 24:     }
27: 25: 
28: 26:     async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_2(&self) -> Result<DomainData2, DomainError> {
29: 27:         Ok(self.sub_domain_2.sub_domain_2_method().await?.into())
30: 28:     }
31: 29: 
32: 30:     async fn lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_3(&self) -> Result<DomainData3, DomainError> {
33: 31:         Ok((
34: 32:             self.sub_domain_1.sub_domain_1_method().await?,
35: 33:             self.sub_domain_2.sub_domain_2_method().await?,
36: 34:         )
37: 35:             .into())
38: 36:     }
39: 37: }
40: 38: 
41: 39: #[async_trait]
42: 40: impl<ExternalService1, ExternalService2> SubDomainTrait1
43: 41:     for SubDomainStruct1<ExternalService1, ExternalService2>
44: 42: where
45: 43:     ExternalService1: ExternalServiceTrait1 + Send + Sync,
46: 44:     ExternalService2: ExternalServiceTrait2 + Send + Sync,
47: 45: {
48: 46:     async fn sub_domain_1_method(&self) -> Result<SubDomain1Data, SubDomain1Error> {
49: 47:         Ok((
50: 48:             self.external_service_1.external_service_1_method().await?,
51: 49:             self.external_service_2.external_service_2_method().await?,
52: 50:         )
53: 51:             .into())
54: 52:     }
55: 53: }
56: 54: 
57: 55: #[async_trait]
58: 56: impl<ExternalService1> SubDomainTrait2 for SubDomainStruct2<ExternalService1>
59: 57: where
60: 58:     ExternalService1: ExternalServiceTrait1 + Send + Sync,
61: 59: {
62: 60:     async fn sub_domain_2_method(&self) -> Result<SubDomain2Data, SubDomain2Error> {
63: 61:         Ok(self
64: 62:             .external_service_1
65: 63:             .external_service_1_method()
66: 64:             .await?
67: 65:             .into())
68: 66:     }
69: 67: }
70: 68: 
71: 69: #[async_trait]
72: 70: impl ExternalServiceTrait1 for ExternalService1_1 {
73: 71:     async fn external_service_1_method(
74: 72:         &self,
75: 73:     ) -> Result<ExternalService1Data, ExternalService1Error> {
76: 74:         println!("External Service 1 From External Service 1_1");
77: 75:         Ok(ExternalService1Data)
78: 76:     }
79: 77: }
80: 78: #[async_trait]
81: 79: impl ExternalServiceTrait1 for ExternalService1_2 {
82: 80:     async fn external_service_1_method(
83: 81:         &self,
84: 82:     ) -> Result<ExternalService1Data, ExternalService1Error> {
85: 83:         println!("External Service 1 From External Service 1_2");
86: 84:         Ok(ExternalService1Data)
87: 85:     }
88: 86: }
89: 87: #[async_trait]
90: 88: impl ExternalServiceTrait2 for ExternalService2_1 {
91: 89:     async fn external_service_2_method(
92: 90:         &self,
93: 91:     ) -> Result<ExternalService2Data, ExternalService2Error> {
94: 92:         println!("External Service 2 From External Service 2_1");
95: 93:         Ok(ExternalService2Data)
96: 94:     }
97: 95: }
98: 96: #[async_trait]
99: 97: impl ExternalServiceTrait2 for ExternalService2_2 {
100: 98:     async fn external_service_2_method(
101: 99:         &self,
102: 100:     ) -> Result<ExternalService2Data, ExternalService2Error> {
103: 101:         println!("External Service 2 From External Service 2_2");
104: 102:         Ok(ExternalService2Data)
105: 103:     }
106: 104: }
107: 105: 
108: 106: // Sub Domain mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping
109: 107: impl From<(ExternalService1Data, ExternalService2Data)> for SubDomain1Data {
110: 108:     fn from(_: (ExternalService1Data, ExternalService2Data)) -> Self {
111: 109:         Self
112: 110:     }
113: 111: }
114: 112: impl From<ExternalService1Data> for SubDomain2Data {
115: 113:     fn from(_: ExternalService1Data) -> Self {
116: 114:         Self
117: 115:     }
118: 116: }
119: 117: // Domain Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping
120: 118: impl From<SubDomain1Data> for DomainData {
121: 119:     fn from(_: SubDomain1Data) -> Self {
122: 120:         Self
123: 121:     }
124: 122: }
125: 123: impl From<SubDomain2Data> for DomainData2 {
126: 124:     fn from(_: SubDomain2Data) -> Self {
127: 125:         Self
128: 126:     }
129: 127: }
130: 128: impl From<(SubDomain1Data, SubDomain2Data)> for DomainData3 {
131: 129:     fn from(_: (SubDomain1Data, SubDomain2Data)) -> Self {
132: 130:         Self
133: 131:     }
134: 132: }
135: 133: 
136: 134: // Ui Mlyx-platform-lyx_platform_lyx-platform-lyx_platform_apping
137: 135: impl From<DomainData> for UiMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appingFromDomainData {
138: 136:     fn from(_: DomainData) -> Self {
139: 137:         Self
140: 138:     }
141: 139: }
142: 140: impl From<DomainData2> for UiMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appingFromDomainData2 {
143: 141:     fn from(_: DomainData2) -> Self {
144: 142:         Self
145: 143:     }
146: 144: }
147: 145: impl From<DomainData3> for UiMlyx-platform-lyx_platform_lyx-platform-lyx_platform_appingFromDomainData3 {
148: 146:     fn from(_: DomainData3) -> Self {
149: 147:         Self
150: 148:     }
151: 149: }
152: ```
```
