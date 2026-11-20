use super::{
    auth, handlers, middleware, notification, scheduler, secrets, storage, system, uploads,
};
use crate::{config::CorsConfig, context::AppContext, error::ServerError, modules};
use axum::{
    http::{HeaderName, HeaderValue, Method},
    middleware::from_fn_with_state,
    routing::{get, post},
    Router,
};
use lyxal_host::http::{health_routes, HostHealth};
use std::{str::FromStr, time::Duration};
use tower::ServiceBuilder;
use tower_http::{
    catch_panic::CatchPanicLayer,
    cors::{AllowHeaders, AllowMethods, AllowOrigin, CorsLayer, ExposeHeaders},
    limit::RequestBodyLimitLayer,
    timeout::TimeoutLayer,
    trace::TraceLayer,
};

pub fn build_router(context: AppContext) -> Result<Router, ServerError> {
    let api = Router::new()
        .route("/system/info", get(handlers::root))
        .route("/system/modules", get(system::modules))
        .route(
            "/system/migrations/interrupted",
            get(system::migrations_interrupted),
        )
        .route(
            "/system/migrations/resolve",
            post(system::migrations_resolve),
        )
        .nest("/auth", auth::routes())
        .nest("/secrets", secrets::routes())
        .nest("/scheduler", scheduler::routes())
        .nest("/notification", notification::routes());

    // Santé de l'hôte : `/live`, `/ready`, `/health` (composants et sondes du runtime)
    let health = HostHealth::new(
        context.health.clone(),
        context.runtime.clone(),
        modules::HOST_ID,
    );

    // Limite du corps et délai total : toutes les routes, sauf les fichiers
    let general = Router::new()
        .route("/", get(handlers::root))
        .merge(health_routes::<AppContext, ServerError>(health))
        .route("/metrics", get(handlers::metrics))
        .nest("/api/v1", api)
        .layer(
            ServiceBuilder::new()
                .layer(RequestBodyLimitLayer::new(
                    context.config.server.body_limit_bytes,
                ))
                .layer(TimeoutLayer::new(Duration::from_secs(
                    context.config.server.request_timeout_seconds,
                ))),
        );
    // Fichiers : taille bornée par le bucket pendant l'écriture, délai d'inactivité sur les flux
    let files = Router::new().nest("/api/v1/storage", storage::routes());

    let mut router = general
        .merge(files)
        .with_state(context.clone())
        .layer(from_fn_with_state(
            context.clone(),
            middleware::request_context,
        ))
        .layer(
            ServiceBuilder::new()
                .layer(CatchPanicLayer::new())
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
            HeaderValue::from_str(value).map_err(|error| ServerError::Configuration {
                message: error.to_string(),
            })
        })
        .collect::<Result<Vec<_>, _>>()?;

    let methods = config
        .allowed_methods
        .iter()
        .map(|value| {
            Method::from_str(value).map_err(|error| ServerError::Configuration {
                message: error.to_string(),
            })
        })
        .collect::<Result<Vec<_>, _>>()?;

    let headers = config
        .allowed_headers
        .iter()
        .map(|value| {
            HeaderName::from_str(value).map_err(|error| ServerError::Configuration {
                message: error.to_string(),
            })
        })
        .collect::<Result<Vec<_>, _>>()?;

    // En-têtes de l'envoi reprenable (tus) : autorisés et lisibles pour un client navigateur
    let headers = headers.into_iter().chain(uploads::REQUEST_HEADERS);

    Ok(CorsLayer::new()
        .allow_origin(AllowOrigin::list(origins))
        .allow_methods(AllowMethods::list(methods))
        .allow_headers(AllowHeaders::list(headers))
        .expose_headers(ExposeHeaders::list(uploads::RESPONSE_HEADERS))
        .allow_credentials(config.allow_credentials))
}
