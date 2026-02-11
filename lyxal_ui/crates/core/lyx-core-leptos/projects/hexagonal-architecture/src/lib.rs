### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\lib.rs
2: ```rust
3: 1: pub mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_app;
4: 2: 
5: 3: pub mod ui_types;
6: 4: 
7: 5: #[cfg(feature = "ssr")]
8: 6: pub mod config;
9: 7: #[cfg(feature = "ssr")]
10: 8: pub mod middleware;
11: 9: #[cfg(feature = "ssr")]
12: 10: pub mod lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types;
13: 11: #[cfg(feature = "ssr")]
14: 12: pub mod trait_impl;
15: 13: #[cfg(feature = "ssr")]
16: 14: pub mod traits;
17: 15: 
18: 16: #[cfg(feature = "hydrate")]
19: 17: #[wasm_bindgen::prelude::wasm_bindgen]
20: 18: pub fn hydrate() {
21: 19:     use crate::lyx-platform-lyx_platform_lyx-platform-lyx_platform_app::*;
22: 20:     console_error_panic_hook::set_once();
23: 21:     lyx-core-lyx_core_lyx-core-lyx_core_leptos::mount::hydrate_body(App);
24: 22: }
25: 23: 
26: 24: #[cfg(test)]
27: 25: pub mod tests {
28: 26:     use super::lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types::*;
29: 27:     use super::traits::*;
30: 28:     use std::error::Error;
31: 29: 
32: 30:     #[tokio::test]
33: 31:     pub async fn test_subdomain_1_with_mocks() -> Result<(), Box<dyn Error>> {
34: 32:         let mut mock_external_service_1 = MockExternalServiceTrait1::new();
35: 33:         mock_external_service_1
36: 34:             .expect_external_service_1_method()
37: 35:             .returning(|| {
38: 36:                 println!("Mock external service 1");
39: 37:                 Ok(ExternalService1Data)
40: 38:             });
41: 39:         let mut mock_external_service_2 = MockExternalServiceTrait2::new();
42: 40:         mock_external_service_2
43: 41:             .expect_external_service_2_method()
44: 42:             .returning(|| {
45: 43:                 println!("Mock external service 2");
46: 44:                 Ok(ExternalService2Data)
47: 45:             });
48: 46:         let real_subdomain_1_with_mock_externals = SubDomainStruct1 {
49: 47:             external_service_1: mock_external_service_1,
50: 48:             external_service_2: mock_external_service_2,
51: 49:         };
52: 50:         let data = real_subdomain_1_with_mock_externals
53: 51:             .sub_domain_1_method()
54: 52:             .await?;
55: 53:         assert_eq!(data, SubDomain1Data);
56: 54:         Ok(())
57: 55:     }
58: 56: 
59: 57:     #[tokio::test]
60: 58:     pub async fn test_subdomain_2_with_mocks() -> Result<(), Box<dyn Error>> {
61: 59:         let mut mock_external_service_1 = MockExternalServiceTrait1::new();
62: 60:         mock_external_service_1
63: 61:             .expect_external_service_1_method()
64: 62:             .returning(|| {
65: 63:                 println!("Mock external service 1 AGAIN");
66: 64:                 Ok(ExternalService1Data)
67: 65:             });
68: 66:         let real_subdomain_2_with_mock_externals = SubDomainStruct2 {
69: 67:             external_service_1: mock_external_service_1,
70: 68:         };
71: 69:         let data = real_subdomain_2_with_mock_externals
72: 70:             .sub_domain_2_method()
73: 71:             .await?;
74: 72:         assert_eq!(data, SubDomain2Data);
75: 73:         Ok(())
76: 74:     }
77: 75: 
78: 76:     #[tokio::test]
79: 77:     pub async fn test_handler_with_mocks() -> Result<(), Box<dyn Error>> {
80: 78:         let mut mock_subdomain_1_trait = MockSubDomainTrait1::new();
81: 79:         mock_subdomain_1_trait
82: 80:             .expect_sub_domain_1_method()
83: 81:             .returning(|| {
84: 82:                 println!("Mock Subdomain 1");
85: 83:                 Ok(SubDomain1Data)
86: 84:             });
87: 85:         let mut mock_subdomain_2_trait = MockSubDomainTrait2::new();
88: 86:         mock_subdomain_2_trait
89: 87:             .expect_sub_domain_2_method()
90: 88:             .returning(|| {
91: 89:                 println!("Mock Subdomain 2");
92: 90:                 Ok(SubDomain2Data)
93: 91:             });
94: 92:         let real_handler_with_mock_subdomains = HandlerStruct {
95: 93:             sub_domain_1: mock_subdomain_1_trait,
96: 94:             sub_domain_2: mock_subdomain_2_trait,
97: 95:         };
98: 96:         let data = real_handler_with_mock_subdomains.lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_1().await?;
99: 97:         assert_eq!(data, DomainData);
100: 98:         let data = real_handler_with_mock_subdomains.lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_2().await?;
101: 99:         assert_eq!(data, DomainData2);
102: 100:         let data = real_handler_with_mock_subdomains.lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_3().await?;
103: 101:         assert_eq!(data, DomainData3);
104: 102:         Ok(())
105: 103:     }
106: 104: 
107: 105:     fn mock_subdomain_1() -> SubDomainStruct1<MockExternalServiceTrait1, MockExternalServiceTrait2>
108: 106:     {
109: 107:         let mut mock_external_service_1 = MockExternalServiceTrait1::new();
110: 108:         mock_external_service_1
111: 109:             .expect_external_service_1_method()
112: 110:             .returning(|| {
113: 111:                 println!("Mock external service 1");
114: 112:                 Ok(ExternalService1Data)
115: 113:             });
116: 114:         let mut mock_external_service_2 = MockExternalServiceTrait2::new();
117: 115:         mock_external_service_2
118: 116:             .expect_external_service_2_method()
119: 117:             .returning(|| {
120: 118:                 println!("Mock external service 2");
121: 119:                 Ok(ExternalService2Data)
122: 120:             });
123: 121:         let real_subdomain_1_with_mock_externals = SubDomainStruct1 {
124: 122:             external_service_1: mock_external_service_1,
125: 123:             external_service_2: mock_external_service_2,
126: 124:         };
127: 125:         real_subdomain_1_with_mock_externals
128: 126:     }
129: 127: 
130: 128:     #[tokio::test]
131: 129:     pub async fn test_handler_with_mock_and_real_mix() -> Result<(), Box<dyn Error>> {
132: 130:         let sub_domain_1 = mock_subdomain_1();
133: 131:         let mut mock_subdomain_2_trait = MockSubDomainTrait2::new();
134: 132:         mock_subdomain_2_trait
135: 133:             .expect_sub_domain_2_method()
136: 134:             .returning(|| {
137: 135:                 println!("Mock Subdomain 2");
138: 136:                 Ok(SubDomain2Data)
139: 137:             });
140: 138:         let real_handler = HandlerStruct {
141: 139:             sub_domain_1,
142: 140:             sub_domain_2: mock_subdomain_2_trait,
143: 141:         };
144: 142:         let data = real_handler.lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_1().await?;
145: 143:         assert_eq!(data, DomainData);
146: 144:         let data = real_handler.lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_2().await?;
147: 145:         assert_eq!(data, DomainData2);
148: 146:         let data = real_handler.lyx-platform-lyx_platform_lyx-core-lyx_core_lyx-platform-lyx_platform_lyx-core-lyx_core_server_fn_3().await?;
149: 147:         assert_eq!(data, DomainData3);
150: 148:         Ok(())
151: 149:     }
152: 150: }
153: ```
```
