use crate::error::ServerError;
use serde::Deserialize;
use std::{collections::BTreeSet, net::IpAddr, path::Path};

#[derive(Clone, Debug, Deserialize)]
pub struct AppConfig {
    pub application: ApplicationConfig,
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub runtime: RuntimeConfig,
    pub observability: ObservabilityConfig,
    pub cors: CorsConfig,
    pub modules: ModulesConfig,
}

#[derive(Clone, Debug, Deserialize)]
pub struct ApplicationConfig {
    pub name: String,
    pub environment: String,
    pub instance_id: String,
    pub version: String,
}

#[derive(Clone, Debug, Deserialize)]
pub struct ServerConfig {
    pub host: IpAddr,
    pub port: u16,
    pub request_timeout_seconds: u64,
    pub graceful_shutdown_seconds: u64,
    pub max_concurrency: usize,
    pub body_limit_bytes: usize,
    pub trust_proxy_headers: bool,
}

#[derive(Clone, Debug, Deserialize)]
pub struct DatabaseConfig {
    pub endpoint: String,
    pub namespace: String,
    pub database: String,
    pub username: Option<String>,
    pub password: Option<String>,
    pub connect_timeout_seconds: u64,
    pub required: bool,
}

#[derive(Clone, Debug, Deserialize)]
pub struct RuntimeConfig {
    pub run_migrations: bool,
    pub fail_fast: bool,
    pub parallel_start: bool,
    pub module_start_timeout_seconds: u64,
    pub module_stop_timeout_seconds: u64,
}

#[derive(Clone, Debug, Deserialize)]
pub struct ObservabilityConfig {
    pub log_filter: String,
    pub json_logs: bool,
    pub include_target: bool,
    pub include_thread_ids: bool,
}

#[derive(Clone, Debug, Deserialize)]
pub struct CorsConfig {
    pub enabled: bool,
    pub allow_credentials: bool,
    pub allowed_origins: Vec<String>,
    pub allowed_methods: Vec<String>,
    pub allowed_headers: Vec<String>,
}

#[derive(Clone, Debug, Default, Deserialize)]
pub struct ModulesConfig {
    #[serde(default)]
    pub enabled: BTreeSet<String>,
    #[serde(default)]
    pub disabled: BTreeSet<String>,
}

impl AppConfig {
    pub fn load() -> Result<Self, ServerError> {
        Self::load_from("config")
    }

    pub fn load_from(directory: impl AsRef<Path>) -> Result<Self, ServerError> {
        let directory = directory.as_ref();
        let environment = std::env::var("LYXAL_ENV").unwrap_or_else(|_| "development".into());

        let builder = config::Config::builder()
            .add_source(config::File::from(directory.join("default.toml")).required(true))
            .add_source(
                config::File::from(directory.join(format!("{environment}.toml"))).required(false),
            )
            .add_source(
                config::Environment::with_prefix("LYXAL")
                    .prefix_separator("__")
                    .separator("__")
                    .try_parsing(true)
                    .list_separator(","),
            );

        let value: Self = builder
            .build()
            .and_then(config::Config::try_deserialize)
            .map_err(|error| ServerError::Configuration(error.to_string()))?;

        value.validate()?;
        Ok(value)
    }

    pub fn validate(&self) -> Result<(), ServerError> {
        if self.application.name.trim().is_empty() {
            return Err(ServerError::Configuration(
                "application.name ne peut pas être vide".into(),
            ));
        }
        if self.database.endpoint.trim().is_empty() {
            return Err(ServerError::Configuration(
                "database.endpoint ne peut pas être vide".into(),
            ));
        }
        if self.database.namespace.trim().is_empty() || self.database.database.trim().is_empty() {
            return Err(ServerError::Configuration(
                "namespace et database sont obligatoires".into(),
            ));
        }
        if self.server.max_concurrency == 0 {
            return Err(ServerError::Configuration(
                "server.max_concurrency doit être supérieur à zéro".into(),
            ));
        }
        let overlap: Vec<_> = self
            .modules
            .enabled
            .intersection(&self.modules.disabled)
            .cloned()
            .collect();
        if !overlap.is_empty() {
            return Err(ServerError::Configuration(format!(
                "modules présents à la fois dans enabled et disabled : {}",
                overlap.join(", ")
            )));
        }
        Ok(())
    }

    pub fn bind_address(&self) -> String {
        format!("{}:{}", self.server.host, self.server.port)
    }
}
