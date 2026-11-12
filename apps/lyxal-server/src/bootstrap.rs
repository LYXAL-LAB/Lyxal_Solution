use crate::{
    config::AppConfig,
    context::AppContext,
    database,
    error::ServerError,
    health::{HealthRegistry, HealthState},
    http,
    metrics::Metrics,
    runtime, shutdown, telemetry,
};
use std::{sync::Arc, time::Duration};
use tokio::net::TcpListener;

pub async fn run() -> anyhow::Result<()> {
    let args: Vec<String> = std::env::args().skip(1).collect();
    match crate::cli::parse(&args)? {
        crate::cli::Command::Serve => run_inner().await.map_err(anyhow::Error::new),
        command => crate::cli::execute(command)
            .await
            .map_err(anyhow::Error::new),
    }
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
    health.set("server", HealthState::Starting, None).await;
    health.set("database", HealthState::Starting, None).await;

    let database = match database::connect_database(&config.database).await {
        Ok(database) => {
            health.set("database", HealthState::Healthy, None).await;
            database
        }
        Err(error) => {
            health
                .set("database", HealthState::Unhealthy, Some(error.to_string()))
                .await;
            return Err(error);
        }
    };

    let metrics = Metrics::default();
    let started = runtime::start(&config, &database).await?;
    let runtime = started.runtime.clone();

    let context = AppContext::new(
        config.clone(),
        database,
        health.clone(),
        metrics,
        runtime.clone(),
        started.auth,
        started.storage,
    );
    let router = http::build_router(context)?;

    let address = config.bind_address();
    let listener = TcpListener::bind(&address)
        .await
        .map_err(|error| ServerError::Bind {
            address: address.clone(),
            message: error.to_string(),
        })?;
    health.set("server", HealthState::Healthy, None).await;

    tracing::info!(address = %config.bind_address(), "serveur HTTP prêt");

    let shutdown_runtime = runtime.clone();
    let shutdown_health = health.clone();
    let graceful_seconds = config.server.graceful_shutdown_seconds;

    // Adresse du client transmise aux routes (anti-force-brute par adresse IP de `lyxal_auth`)
    axum::serve(
        listener,
        router.into_make_service_with_connect_info::<std::net::SocketAddr>(),
    )
    .with_graceful_shutdown(async move {
        if let Err(error) = shutdown::signal().await {
            tracing::error!(%error, "erreur lors de l'attente du signal d'arrêt");
        }
        shutdown_health
            .set("server", HealthState::Stopping, None)
            .await;
        if let Err(error) = shutdown_runtime.stop_all().await {
            tracing::error!(%error, "arrêt des modules incomplet");
        }
        tokio::time::sleep(Duration::from_millis(50)).await;
    })
    .await
    .map_err(|error| ServerError::HttpServe {
        message: error.to_string(),
    })?;

    tracing::info!(
        graceful_shutdown_seconds = graceful_seconds,
        "Lyxal OS arrêté"
    );
    Ok(())
}
