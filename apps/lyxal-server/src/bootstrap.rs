use crate::{
    config::AppConfig,
    context::AppContext,
    database,
    error::ServerError,
    health::{HealthRegistry, HealthState},
    http,
    metrics::Metrics,
    modules::{ModuleContext, compiled_modules},
    runtime::RuntimeHandle,
    shutdown, telemetry,
};
use std::{sync::Arc, time::Duration};
use tokio::net::TcpListener;

pub async fn run() -> anyhow::Result<()> {
    run_inner().await.map_err(anyhow::Error::new)
}

async fn run_inner() -> Result<(), ServerError> {
    let config = Arc::new(AppConfig::load()?);
    telemetry::init(&config.observability)?;

    tracing::info!(
        application = %config.application.name,
        version = %config.application.version,
        environment = %config.application.environment,
        instance_id = %config.application.instance_id,
        "démarrage de Lyxal OS"
    );

    let health = HealthRegistry::default();
    health
        .set("server", HealthState::Starting, None)
        .await;
    health
        .set("database", HealthState::Starting, None)
        .await;

    let database = match database::connect_database(&config.database).await {
        Ok(database) => {
            health
                .set("database", HealthState::Healthy, None)
                .await;
            database
        }
        Err(error) if !config.database.required => {
            health
                .set(
                    "database",
                    HealthState::Degraded,
                    Some(error.to_string()),
                )
                .await;
            return Err(ServerError::Database(
                "le mode sans base requiert un adaptateur NullDatabase, non activé".into(),
            ));
        }
        Err(error) => {
            health
                .set(
                    "database",
                    HealthState::Unhealthy,
                    Some(error.to_string()),
                )
                .await;
            return Err(error);
        }
    };

    let metrics = Metrics::default();
    let module_context = ModuleContext {
        database: database.clone(),
        health: health.clone(),
        metrics: metrics.clone(),
    };

    let runtime = RuntimeHandle::build(
        compiled_modules(&config),
        &config.modules,
        config.runtime.clone(),
        module_context,
    )?;
    runtime.install_and_start().await?;

    let context = AppContext::new(
        config.clone(),
        database,
        health.clone(),
        metrics,
        runtime.clone(),
    );
    let router = http::build_router(context)?;

    let listener = TcpListener::bind(config.bind_address()).await?;
    health.set("server", HealthState::Healthy, None).await;

    tracing::info!(address = %config.bind_address(), "serveur HTTP prêt");

    let shutdown_runtime = runtime.clone();
    let shutdown_health = health.clone();
    let graceful_seconds = config.server.graceful_shutdown_seconds;

    axum::serve(listener, router)
        .with_graceful_shutdown(async move {
            if let Err(error) = shutdown::signal().await {
                tracing::error!(%error, "erreur lors de l'attente du signal d'arrêt");
            }
            shutdown_health
                .set("server", HealthState::Stopping, None)
                .await;
            shutdown_runtime.stop_all().await;
            tokio::time::sleep(Duration::from_millis(50)).await;
        })
        .await
        .map_err(|error| ServerError::Http(error.to_string()))?;

    tracing::info!(
        graceful_shutdown_seconds = graceful_seconds,
        "Lyxal OS arrêté"
    );
    Ok(())
}
