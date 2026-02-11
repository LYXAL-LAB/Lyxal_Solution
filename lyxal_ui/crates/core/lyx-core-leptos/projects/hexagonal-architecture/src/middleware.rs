### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\middleware.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\hexagonal-architecture\src\middleware.rs
2: ```rust
3: 1: use axum::{
4: 2:     body::Body,
5: 3:     http::{Request, Response},
6: 4: };
7: 5: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::expect_context;
8: 6: use std::{
9: 7:     future::Future,
10: 8:     pin::Pin,
11: 9:     task::{Context, Poll},
12: 10: };
13: 11: use tower::{Layer, Service};
14: 12: 
15: 13: use crate::{
16: 14:     lyx-platform-lyx_platform_lyx-platform-lyx_platform_server_types::{HandlerStructAlias, ServerState},
17: 15:     traits::SubDomainTrait1,
18: 16: };
19: 17: use pin_project_lite::pin_project;
20: 18: 
21: 19: #[derive(Clone)]
22: 20: pub struct SubDomain1Layer;
23: 21: 
24: 22: impl<S> Layer<S> for SubDomain1Layer {
25: 23:     type Service = SubDomain1MiddleWare<S>;
26: 24: 
27: 25:     fn layer(&self, inner: S) -> Self::Service {
28: 26:         SubDomain1MiddleWare { inner }
29: 27:     }
30: 28: }
31: 29: 
32: 30: pub struct SubDomain1MiddleWare<S> {
33: 31:     inner: S,
34: 32: }
35: 33: 
36: 34: impl<S, ReqBody> Service<Request<ReqBody>> for SubDomain1MiddleWare<S>
37: 35: where
38: 36:     S: Service<Request<ReqBody>, Response = Response<Body>>,
39: 37:     S::Error: std::fmt::Debug,
40: 38:     S::Future: Send + 'static,
41: 39: {
42: 40:     type Response = S::Response;
43: 41:     type Error = S::Error;
44: 42:     type Future = SubDomain1Future<S::Future>;
45: 43: 
46: 44:     fn poll_ready(&mut self, cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
47: 45:         self.inner.poll_ready(cx)
48: 46:     }
49: 47: 
50: 48:     fn call(&mut self, req: Request<ReqBody>) -> Self::Future {
51: 49:         let req_fut = self.inner.call(req);
52: 50:         SubDomain1Future { req_fut }
53: 51:     }
54: 52: }
55: 53: pin_project! {
56: 54:     pub struct SubDomain1Future<F> {
57: 55:         #[pin]
58: 56:         req_fut: F,
59: 57:     }
60: 58: }
61: 59: 
62: 60: impl<F, Err> Future for SubDomain1Future<F>
63: 61: where
64: 62:     F: Future<Output = Result<Response<Body>, Err>>,
65: 63: {
66: 64:     type Output = Result<Response<Body>, Err>;
67: 65: 
68: 66:     fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output> {
69: 67:         let this = self.project();
70: 68:         let subdomain_1 = expect_context::<ServerState<HandlerStructAlias>>()
71: 69:             .handler
72: 70:             .sub_domain_1;
73: 71:         let mut subdomain_1_fut = subdomain_1.sub_domain_1_method();
74: 72:         match Pin::as_mut(&mut subdomain_1_fut).poll(cx) {
75: 73:             Poll::Ready(Ok(_)) => {
76: 74:                 println!("Middleware for Subdomain 1 Passed, calling request...");
77: 75:                 this.req_fut.poll(cx)
78: 76:             }
79: 77:             Poll::Ready(Err(_)) => Poll::Ready(Ok(Response::builder()
80: 78:                 .status(http::StatusCode::FORBIDDEN)
81: 79:                 .body(Body::from("Access denied"))
82: 80:                 .unwrap())),
83: 81:             Poll::Pending => Poll::Pending,
84: 82:         }
85: 83:     }
86: 84: }
87: ```
```
