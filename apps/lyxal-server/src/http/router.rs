use super::{handlers, middleware};
use crate::{config::CorsConfig, context::AppContext, error::ServerError};
use axum::{
    Router,
    http::{HeaderName, HeaderValue, Method},
    middleware::from_fn_with_state,
    routing::get,
};
use std::{str::FromStr, time::Duration};
use tower::ServiceBuilder;
use tower_http::{
    catch_panic::CatchPanicLayer,
    cors::{AllowHeaders, AllowMethods, AllowOrigin, CorsLayer},
    limit::RequestBodyLimitLayer,
    timeout::TimeoutLayer,
    trace::TraceLayer,
};

pub fn build_router(context: AppContext) -> Result<Router, ServerError> {
    let module_routes = context.runtime.router();

    let api = Router::new()
        .route("/system/info", get(handlers::root))
        .route("/system/modules", get(handlers::modules));

    let mut router = Router::new()
        .route("/", get(handlers::root))
        .route("/live", get(handlers::live))
        .route("/ready", get(handlers::ready))
        .route("/health", get(handlers::health))
        .route("/metrics", get(handlers::metrics))
        .nest("/api/v1", api)
        .merge(module_routes)
        .with_state(context.clone())
        .layer(from_fn_with_state(
            context.clone(),
            middleware::request_context,
        ))
        .layer(
            ServiceBuilder::new()
                .layer(CatchPanicLayer::new())
                .layer(RequestBodyLimitLayer::new(
                    context.config.server.body_limit_bytes,
                ))
                .layer(TimeoutLayer::new(Duration::from_secs(
                    context.config.server.request_timeout_seconds,
                )))
                .layer(TraceLayer::new_for_http())
                .concurrency_limit(context.config.server.max_concurrency),
        );

    if context.config.cors.enabled {
        router = router.layer(cors_layer(&context.config.cors)?);
    }
    Ok(router)
}

fn cors_layer(config: &CorsConfig) -> Result<CorsLayer, ServerError> {
    let origins = config
        .allowed_origins
        .iter()
        .map(|value| {
            HeaderValue::from_str(value)
                .map_err(|error| ServerError::Configuration(error.to_string()))
        })
        .collect::<Result<Vec<_>, _>>()?;

    let methods = config
        .allowed_methods
        .iter()
        .map(|value| {
            Method::from_str(value)
                .map_err(|error| ServerError::Configuration(error.to_string()))
        })
        .collect::<Result<Vec<_>, _>>()?;

    let headers = config
        .allowed_headers
        .iter()
        .map(|value| {
            HeaderName::from_str(value)
                .map_err(|error| ServerError::Configuration(error.to_string()))
        })
        .collect::<Result<Vec<_>, _>>()?;

    Ok(CorsLayer::new()
        .allow_origin(AllowOrigin::list(origins))
        .allow_methods(AllowMethods::list(methods))
        .allow_headers(AllowHeaders::list(headers))
        .allow_credentials(config.allow_credentials))
}
