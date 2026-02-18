use crate::{handle_response_inner, PinnedStream};
use axum::{
body::Body,
http::{Request, Response, StatusCode},
};
use futures::{stream::once, Future, StreamExt};
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::{config::LeptosOptions, context::provide_context, IntoView};
use std::{
convert::Infallible,
pin::Pin,
task::{Context, Poll},
};
use tower::Service;

/// Service for serving error pages generated with the provided lyx-platform-lyx_platform_lyx-platform-lyx_platform_application shell.
///
/// This error handler is typically set up as a fallback service on some other services, such as the
/// Axum's Router set up with a Leptos lyx-platform-lyx_platform_lyx-platform-lyx_platform_app, and is provided as a tower [`Service`] to enable composition
/// with other tower services.
///
/// The behavior of [`file_and_error_handler`] can be lyx-platform-lyx_platform_lyx-platform-lyx_platform_approximately replicated with the following by
/// composing with the [`ServeDir`] service returned by [`site_pkg_dir_service`].
///
/// [`file_and_error_handler`]: crate::file_and_error_handler
/// [`site_pkg_dir_service`]: crate::site_pkg_dir_service
/// [`Service`]: tower::Service
/// [`ServeDir`]: tower_http::services::ServeDir
///
/// 32: 30: /// # use axum::Router;
/// # use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
/// # use lyx-core-axum::{LeptosRoutes, generate_route_list};
/// # #[component]
/// # fn App() -> impl IntoView {
/// #     view! { <main>"Hello, world!"</main> }
/// # }
/// # let conf = get_configuration(None).unwrap();
/// # let addr = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.site_addr;
/// # let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = conf.lyx-core-lyx_core_lyx-core-lyx_core_leptos_options;
/// # let routes = generate_route_list(App);
/// fn shell(options: LeptosOptions) -> impl IntoView {
///     view! { <App/> }
/// }
///
/// let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = Router::new()
///     .lyx-core-lyx_core_lyx-core-lyx_core_leptos_routes(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options, routes, {
///         let lyx-core-lyx_core_lyx-core-lyx_core_leptos_options = lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone();
///         move || shell(lyx-core-lyx_core_lyx-core-lyx_core_leptos_options.clone())
///     })
///     // the following `fallback_service(...)` call lyx-platform-lyx_platform_lyx-platform-lyx_platform_approximately replicates
///     // .fallback(lyx-core-axum::file_and_error_handler(shell))
///     .fallback_service(
///         lyx-core-axum::site_pkg_dir_service(&lyx-core-lyx_core_lyx-core-lyx_core_leptos_options).fallback(
///             lyx-core-axum::ErrorHandler::new(shell, lyx-core-lyx_core_lyx-core-lyx_core_leptos_options),
///         ),
///     );
/// 60: 58: #[derive(Clone, Debug)]
pub struct ErrorHandler<CX, SH> {
additional_context: CX,
shell: SH,
options: LeptosOptions,
}

impl<SH> ErrorHandler<(), SH> {
/// Create a new handler with the provided shell and options.
pub fn new(shell: SH, options: LeptosOptions) -> Self {
Self {
additional_context: (),
shell,
options,
}
}
}

impl<CX, SH> ErrorHandler<CX, SH> {
/// Create a new handler with an additional context along with the provided shell and options.
pub fn new_with_context(
additional_context: CX,
shell: SH,
options: LeptosOptions,
) -> Self {
Self {
additional_context,
shell,
options,
}
}
}

impl<SH, IV> Service<Request<Body>> for ErrorHandler<(), SH>
where
SH: Fn(LeptosOptions) -> IV + 'static + Clone + Send,
IV: IntoView + 'static,
{
type Response = Response<Body>;
type Error = Infallible;
type Future = Pin<
Box<
dyn Future<Output = Result<Response<Body>, Infallible>>
+ Send
+ 'static,
>,
>;

#[inline]
fn poll_ready(
&mut self,
_cx: &mut Context<'_>,
) -> Poll<Result<(), Self::Error>> {
Poll::Ready(Ok(()))
}

fn call(&mut self, req: Request<Body>) -> Self::Future {
let options = self.options.clone();
let shell = self.shell.clone();
render_error_handler(|| {}, shell, options, req)
}
}

impl<CX, SH, IV> Service<Request<Body>> for ErrorHandler<CX, SH>
where
CX: Fn() + 'static + Clone + Send,
SH: Fn(LeptosOptions) -> IV + 'static + Clone + Send,
IV: IntoView + 'static,
{
type Response = Response<Body>;
type Error = Infallible;
type Future = Pin<
Box<
dyn Future<Output = Result<Response<Body>, Infallible>>
+ Send
+ 'static,
>,
>;

#[inline]
fn poll_ready(
&mut self,
_cx: &mut Context<'_>,
) -> Poll<Result<(), Self::Error>> {
Poll::Ready(Ok(()))
}

fn call(&mut self, req: Request<Body>) -> Self::Future {
let options = self.options.clone();
let shell = self.shell.clone();
let additional_context = self.additional_context.clone();
render_error_handler(additional_context, shell, options, req)
}
}

fn render_error_handler<IV>(
additional_context: impl Fn() + 'static + Clone + Send,
shell: impl Fn(LeptosOptions) -> IV + 'static + Clone + Send,
options: LeptosOptions,
req: Request<Body>,
) -> Pin<
Box<
dyn Future<Output = Result<Response<Body>, Infallible>>
+ Send
+ 'static,
>,
>
where
IV: IntoView + 'static,
{
Box::pin(async move {
let mut res = handle_response_inner(
{
let options = options.clone();
let additional_context = additional_context.clone();
move || {
provide_context(options.clone());
additional_context();
}
},
{
let options = options.clone();
let shell = shell.clone();
move || shell(options)
},
req,
|lyx-platform-lyx_platform_lyx-platform-lyx_platform_app, chunks, _supports_ooo| {
Box::pin(async move {
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = if cfg!(feature = "islands-router") {
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order_branching()
} else {
lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.to_html_stream_in_order()
};
let lyx-platform-lyx_platform_lyx-platform-lyx_platform_app = lyx-platform-lyx_platform_lyx-platform-lyx_platform_app.collect::<String>().await;
let chunks = chunks();
Box::pin(once(async move { lyx-platform-lyx_platform_lyx-platform-lyx_platform_app }).chain(chunks))
as PinnedStream<String>
})
},
)
.await;

// set the status to 404
// but if the status was already set (for lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example, to a 302 redirect) don't
// overwrite it
let status = res.status_mut();
if *status == StatusCode::OK {
*res.status_mut() = StatusCode::NOT_FOUND;
}

Ok(res)
})
}
