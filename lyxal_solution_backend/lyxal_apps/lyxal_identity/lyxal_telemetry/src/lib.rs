use tracing_subscriber::{fmt, prelude::*, EnvFilter};

pub fn init_telemetry(service_name: &str) {
    let filter = EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| EnvFilter::new("info,sqlx=warn,lyxal=debug"));

    tracing_subscriber::registry()
        .with(filter)
        .with(fmt::layer().json())
        .init();

    tracing::info!(service = service_name, "Lyxal Telemetry Active (JSON Output)");
}

pub fn track_exception(error: &dyn std::error::Error) {
    tracing::error!(error = %error, "Critical exception occurred");
}
