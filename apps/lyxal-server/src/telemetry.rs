use crate::{config::ObservabilityConfig, error::ServerError};
use tracing_subscriber::{EnvFilter, layer::SubscriberExt, util::SubscriberInitExt};

pub fn init(config: &ObservabilityConfig) -> Result<(), ServerError> {
    let filter = EnvFilter::try_new(&config.log_filter)
        .map_err(|error| ServerError::Configuration(error.to_string()))?;

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
            .map_err(|error| ServerError::Internal(error.to_string()))?;
    } else {
        registry
            .with(
                tracing_subscriber::fmt::layer()
                    .with_target(config.include_target)
                    .with_thread_ids(config.include_thread_ids),
            )
            .try_init()
            .map_err(|error| ServerError::Internal(error.to_string()))?;
    }
    Ok(())
}
