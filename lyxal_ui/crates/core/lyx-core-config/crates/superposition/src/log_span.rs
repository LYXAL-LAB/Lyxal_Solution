### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_superposition\src\log_span.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\log_span.rs
2: ```rust
3: 1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\log_span.rs
4: 2: ```rust
5: 3: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\log_span.rs
6: 4: ```rust
7: 5: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\log_span.rs
8: 6: ```rust
9: 7: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_lyx-core-lyx_core_superposition\src\log_span.rs
10: 8: ```rust
11: 9: use actix_http::header::{HeaderMap, HeaderValue};
12: 10: use actix_web::{
13: 11:     Error,
14: 12:     body::MessageBody,
15: 13:     dev::{ServiceRequest, ServiceResponse},
16: 14: };
17: 15: use tracing::Span;
18: 16: use tracing_actix_web::{DefaultRootSpanBuilder, RootSpanBuilder};
19: 17: 
20: 18: pub struct CustomRootSpanBuilder;
21: 19: 
22: 20: impl RootSpanBuilder for CustomRootSpanBuilder {
23: 21:     fn on_request_start(request: &ServiceRequest) -> Span {
24: 22:         let headers = request.headers();
25: 23:         let santize_headers = |value: &str| {
26: 24:             value
27: 25:                 .chars()
28: 26:                 .filter(|c| !c.is_control())
29: 27:                 .take(256)
30: 28:                 .collect::<String>()
31: 29:         };
32: 30:         let header_extractor = |headers: &HeaderMap, key: &str| {
33: 31:             headers
34: 32:                 .get(key)
35: 33:                 .and_then(|v| HeaderValue::to_str(v).ok())
36: 34:                 .map(santize_headers)
37: 35:         };
38: 36:         let workspace = header_extractor(headers, "x-workspace")
39: 37:             .unwrap_or_else(|| "no-workspace-header".to_string());
40: 38:         let org = header_extractor(headers, "x-org-id")
41: 39:             .unwrap_or_else(|| "no-org-header".to_string());
42: 40:         let method = request.method().to_string();
43: 41:         let path = request.path();
44: 42:         tracing_actix_web::root_span!(request, workspace, org, method, path,)
45: 43:     }
46: 44: 
47: 45:     fn on_request_end<B: MessageBody>(
48: 46:         span: Span,
49: 47:         outcome: &Result<ServiceResponse<B>, Error>,
50: 48:     ) {
51: 49:         DefaultRootSpanBuilder::on_request_end(span, outcome);
52: 50:     }
53: 51: }
54: 52: ```
55: 53: ```
56: 54: ```
57: 55: ```
58: ```
```
