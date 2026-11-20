//! Journal de l'hôte (`tracing`), texte ou JSON, filtré par `observability.log_filter`.

use crate::{config::ObservabilityConfig, HostError};
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt, EnvFilter};

pub fn init(config: &ObservabilityConfig) -> Result<(), HostError> {
    let filter =
        EnvFilter::try_new(&config.log_filter).map_err(|error| HostError::Configuration {
            message: error.to_string(),
        })?;

    let registry = tracing_subscriber::registry().with(filter);

    if config.json_logs {
        registry
            .with(
                tracing_subscriber::fmt::layer()
                    .json()
                    .with_target(config.include_target)
                    .with_thread_ids(config.include_thread_ids),
            )
            .try_init()
            .map_err(|error| HostError::Telemetry {
                message: error.to_string(),
            })?;
    } else {
        registry
            .with(
                tracing_subscriber::fmt::layer()
                    .with_target(config.include_target)
                    .with_thread_ids(config.include_thread_ids),
            )
            .try_init()
            .map_err(|error| HostError::Telemetry {
                message: error.to_string(),
            })?;
    }
    Ok(())
}
