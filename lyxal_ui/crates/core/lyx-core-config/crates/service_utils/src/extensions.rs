1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\extensions.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\extensions.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\extensions.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\extensions.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_service_utils\src\extensions.rs
10: 8: ```rust
11: 9: use actix_web::HttpRequest;
12: 10: 
13: 11: use crate::service::types::{OrganisationId, WorkspaceId};
14: 12: 
15: 13: pub trait HttpRequestExt {
16: 14:     fn get_header(&self, header_name: &str) -> Option<&str>;
17: 15:     fn get_path_param(&self, param: &str) -> Option<&str>;
18: 16:     fn get_query_param(&self, query_param: &str) -> Option<&str>;
19: 17: 
20: 18:     fn get_organisation_id(&self) -> Option<OrganisationId>;
21: 19:     fn get_workspace_id(&self) -> Option<WorkspaceId>;
22: 20: }
23: 21: 
24: 22: impl HttpRequestExt for HttpRequest {
25: 23:     fn get_path_param(&self, param: &str) -> Option<&str> {
26: 24:         let p = self
27: 25:             .match_pattern()?
28: 26:             .split('/')
29: 27:             .position(|mp| mp == param)?;
30: 28:         self.path().split('/').nth(p)
31: 29:     }
32: 30: 
33: 31:     fn get_header(&self, header_name: &str) -> Option<&str> {
34: 32:         self.headers()
35: 33:             .get(header_name)
36: 34:             .and_then(|header_value| header_value.to_str().ok())
37: 35:     }
38: 36: 
39: 37:     fn get_query_param(&self, query_param: &str) -> Option<&str> {
40: 38:         let param = format!("{query_param}=");
41: 39:         self.query_string()
42: 40:             .split('&')
43: 41:             .find(|segment| segment.contains(&param))
44: 42:             .and_then(|query_param| query_param.split('=').nth(1))
45: 43:     }
46: 44: 
47: 45:     fn get_organisation_id(&self) -> Option<OrganisationId> {
48: 46:         self.get_header("x-org-id")
49: 47:             .or_else(|| self.get_path_param("{org_id}"))
50: 48:             .or_else(|| self.get_query_param("org"))
51: 49:             .map(String::from)
52: 50:             .map(OrganisationId)
53: 51:     }
54: 52: 
55: 53:     fn get_workspace_id(&self) -> Option<WorkspaceId> {
56: 54:         self.get_header("x-workspace")
57: 55:             .or_else(|| self.get_header("x-tenant"))
58: 56:             .or_else(|| self.get_path_param("{workspace}"))
59: 57:             .or_else(|| self.get_path_param("{tenant}"))
60: 58:             .or_else(|| self.get_query_param("workspace"))
61: 59:             .or_else(|| self.get_query_param("tenant"))
62: 60:             .map(String::from)
63: 61:             .map(WorkspaceId)
64: 62:     }
65: 63: }
66: 64: ```
67: 65: ```
68: 66: ```
69: 67: ```
70: ```
```

