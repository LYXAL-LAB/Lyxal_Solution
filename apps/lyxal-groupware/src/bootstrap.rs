// SPDX-License-Identifier: AGPL-3.0-only

//! Démarrage de l'hôte : configuration et journal, base, liaison de tous les ports (écoutes de
//! courrier et port HTTP) et chargement des certificats avant toute installation, runtime
//! (socle, modules, écoutes), port HTTP de santé, puis attente du signal d'arrêt : santé « stopping »,
//! arrêt du runtime (écoutes drainées), port HTTP drainé.

use crate::config::GroupwareConfig;
use crate::error::GroupwareError;
use crate::net::bind;
use crate::net::certificates::Certificates;
use crate::{http, runtime};
use lyxal_host::health::{HealthRegistry, HealthState};
use lyxal_host::http::HostHealth;
use lyxal_host::{database, shutdown, telemetry};
use std::time::Duration;

/// Délai d'écriture d'une connexion HTTP (client qui ne lit plus).
const HTTP_WRITE_IDLE: Duration = Duration::from_secs(60);

/// Point d'entrée du binaire.
pub async fn run() -> anyhow::Result<()> {
    run_inner().await.map_err(anyhow::Error::new)
}

async fn run_inner() -> Result<(), GroupwareError> {
    let config = GroupwareConfig::load()?;
    telemetry::init(&config.observability.host())?;
    tracing::info!(
        application = %config.application.name,
        environment = %config.application.environment,
        host = crate::modules::HOST_ID,
        "démarrage de Lyxal Groupware"
    );

    let health = HealthRegistry::default();
    for component in ["groupware", "database", "http"] {
        health.set(component, HealthState::Starting, None).await;
    }

    let database = match database::connect_database(&config.database).await {
        Ok(database) => {
            health.set("database", HealthState::Healthy, None).await;
            database
        }
        Err(error) => {
            health
                .set("database", HealthState::Unhealthy, Some(error.to_string()))
                .await;
            return Err(error.into());
        }
    };

    // Tous les ports avant toute installation : un port indisponible arrête le démarrage ; puis
    // les certificats (un certificat invalide l'arrête aussi)
    let listeners = bind::bind_listeners(&config)?;
    let http_listener = lyxal_host::http::bind(&config.http.bind.to_string()).await?;
    let certificates = Certificates::load(&config.tls)?;

    let prepare = http::prepare(&config, certificates.as_ref())?;
    let started = runtime::start(&config, &database, listeners, certificates).await?;
    let runtime = started.runtime.clone();
    let router = http::router(
        HostHealth::new(
            health.clone(),
            runtime.clone(),
            crate::modules::HOST_ID,
            database,
            Duration::from_secs(config.database.connect_timeout_seconds),
        ),
        started.mail.clone(),
    );
    health.set("http", HealthState::Healthy, None).await;
    health.set("groupware", HealthState::Healthy, None).await;
    tracing::info!(address = %config.http.bind, "port HTTP de santé prêt");

    let shutdown_health = health.clone();
    let mail = started.mail.clone();
    let graceful = Duration::from_secs(config.http.graceful_shutdown_seconds);
    lyxal_host::http::serve_prepared(
        http_listener,
        router,
        HTTP_WRITE_IDLE,
        graceful,
        async move {
            if let Err(error) = shutdown::signal().await {
                tracing::error!(%error, "erreur lors de l'attente du signal d'arrêt");
            }
            // `/ready` répond 503 : le répartiteur retire le nœud
            shutdown_health
                .set("groupware", HealthState::Stopping, None)
                .await;
            if let Err(error) = runtime.stop_all().await {
                tracing::error!(%error, "arrêt des modules incomplet");
            }
            // Les écoutes arrêtées gardent leurs ports : l'arrêt définitif les referme
            mail.close();
        },
        prepare,
    )
    .await;

    tracing::info!("Lyxal Groupware arrêté");
    Ok(())
}
