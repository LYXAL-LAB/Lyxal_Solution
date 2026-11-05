use crate::error::ServerError;
use lyxal_surreal::SecretString;
use serde::{Deserialize, Deserializer};
use std::{fmt, net::IpAddr, path::Path, sync::Arc};

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AppConfig {
    pub application: ApplicationConfig,
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub runtime: RuntimeConfig,
    pub observability: ObservabilityConfig,
    pub cors: CorsConfig,
    #[serde(default)]
    pub catalogue_sync: CatalogueSyncConfig,
}

/// Publication du pipeline d'ingestion vers le catalogue : clé de signature du jeton de service
/// `catalogue_sync_agent`, jamais dans les fichiers de configuration, uniquement par
/// `LYXAL__CATALOGUE_SYNC__SIGNING_KEY` (32 caractères `A-Z a-z 0-9 _ -`). Sans clé, la
/// publication est désactivée et la sonde de santé du module le signale.
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct CatalogueSyncConfig {
    #[serde(default)]
    pub signing_key: Option<SecretPassword>,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ApplicationConfig {
    pub name: String,
    pub environment: String,
    pub instance_id: String,
    pub version: String,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ServerConfig {
    pub host: IpAddr,
    pub port: u16,
    pub request_timeout_seconds: u64,
    pub graceful_shutdown_seconds: u64,
    pub max_concurrency: usize,
    pub body_limit_bytes: usize,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
/// Identifiants Root : jamais dans les fichiers de configuration, uniquement par
/// `LYXAL__DATABASE__USERNAME` et `LYXAL__DATABASE__PASSWORD`.
pub struct DatabaseConfig {
    pub endpoint: String,
    pub namespace: String,
    pub database: String,
    pub username: Option<String>,
    pub password: Option<SecretPassword>,
    pub connect_timeout_seconds: u64,
}

/// Secret lu dans la configuration (mot de passe de la base, clé de signature) : masqué dans
/// `Debug`, effacé de la mémoire à la libération (`lyxal_crypto::SecretString`).
#[derive(Clone)]
pub struct SecretPassword(Arc<SecretString>);

impl SecretPassword {
    pub fn new(text: String) -> Result<Self, ServerError> {
        SecretString::new(text)
            .map(|secret| Self(Arc::new(secret)))
            .map_err(|error| ServerError::Configuration {
                message: format!("database.password : {error}"),
            })
    }

    /// Copie protégée du secret, pour une utilisation unique.
    pub fn to_secret(&self) -> Result<SecretString, ServerError> {
        SecretString::new(self.0.expose_secret().to_owned()).map_err(|error| {
            ServerError::Configuration {
                message: format!("database.password : {error}"),
            }
        })
    }
}

impl fmt::Debug for SecretPassword {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("[REDACTED]")
    }
}

impl<'de> Deserialize<'de> for SecretPassword {
    fn deserialize<D: Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        let text = String::deserialize(deserializer)?;
        SecretString::new(text)
            .map(|secret| Self(Arc::new(secret)))
            .map_err(serde::de::Error::custom)
    }
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct RuntimeConfig {
    pub module_install_timeout_seconds: u64,
    pub module_start_timeout_seconds: u64,
    pub module_stop_timeout_seconds: u64,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ObservabilityConfig {
    pub log_filter: String,
    pub json_logs: bool,
    pub include_target: bool,
    pub include_thread_ids: bool,
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct CorsConfig {
    pub enabled: bool,
    pub allow_credentials: bool,
    pub allowed_origins: Vec<String>,
    pub allowed_methods: Vec<String>,
    pub allowed_headers: Vec<String>,
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
            .map_err(|error| ServerError::Configuration {
                message: error.to_string(),
            })?;

        value.validate()?;
        Ok(value)
    }

    pub fn validate(&self) -> Result<(), ServerError> {
        if self.application.name.trim().is_empty() {
            return Err(ServerError::Configuration {
                message: "application.name ne peut pas être vide".into(),
            });
        }
        if self.database.endpoint.trim().is_empty() {
            return Err(ServerError::Configuration {
                message: "database.endpoint ne peut pas être vide".into(),
            });
        }
        if self.database.namespace.trim().is_empty() || self.database.database.trim().is_empty() {
            return Err(ServerError::Configuration {
                message: "namespace et database sont obligatoires".into(),
            });
        }
        if self.server.max_concurrency == 0 {
            return Err(ServerError::Configuration {
                message: "server.max_concurrency doit être supérieur à zéro".into(),
            });
        }
        Ok(())
    }

    pub fn bind_address(&self) -> String {
        format!("{}:{}", self.server.host, self.server.port)
    }
}
