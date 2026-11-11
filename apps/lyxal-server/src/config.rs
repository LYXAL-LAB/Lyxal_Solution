use crate::error::ServerError;
use lyxal_surreal::SecretString;
use serde::{Deserialize, Deserializer};
use std::{
    fmt,
    net::IpAddr,
    path::{Path, PathBuf},
    sync::Arc,
};

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
    pub crypto: CryptoConfig,
    #[serde(default)]
    pub notification: NotificationConfig,
    #[serde(default)]
    pub auth: AuthConfig,
    #[serde(default)]
    pub storage: StorageConfig,
}

/// Stockage des fichiers (`lyxal_storage`) : support `default` sur un dossier du serveur. Sans
/// dossier, aucun fichier n'est écrit ni lu (sonde « dégradé »).
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct StorageConfig {
    #[serde(default)]
    pub disk: Option<DiskStorageConfig>,
}

/// Support disque : `LYXAL__STORAGE__DISK__ROOT`, dossier créé s'il n'existe pas ; tous les
/// fichiers sont écrits dessous.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct DiskStorageConfig {
    pub root: PathBuf,
}

/// Authentification (`lyxal_auth`) : adresse publique de l'interface, pour les liens des messages
/// (récupération, vérification, installation). Les routes `/auth/*` demandent aussi la clé
/// applicative ; sans l'une ou l'autre, elles répondent `SERVER_AUTH_DISABLED`.
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AuthConfig {
    #[serde(default)]
    pub public_url: Option<String>,
    /// Identifiant de partie de confiance des passkeys (domaine) ; défaut : hôte de `public_url`.
    #[serde(default)]
    pub passkey_rp_id: Option<String>,
}

/// Trousseau applicatif de l'hôte (secrets des notifications, liens d'invitation) : clé AES-256
/// de 32 octets en Base64 canonique (44 caractères), jamais dans les fichiers de configuration,
/// uniquement par `LYXAL__CRYPTO__APPLICATION_KEY` (lue par `lyxal_crypto::EnvironmentKeyProvider`),
/// et son identifiant `application_key_id` (ex. `app-2026`), qui figure dans chaque enveloppe.
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct CryptoConfig {
    #[serde(default)]
    pub application_key: Option<SecretPassword>,
    #[serde(default)]
    pub application_key_id: Option<String>,
}

/// Notifications sortantes : relais SMTP unique de l'installation (avant `lyxal_secrets`). Sans
/// relais ou sans clé applicative, aucun e-mail n'est envoyé (abonnements suspendus, sonde
/// « dégradé »).
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct NotificationConfig {
    #[serde(default)]
    pub smtp: Option<SmtpConfig>,
}

/// Relais SMTP : `LYXAL__NOTIFICATION__SMTP__HOST`, `__PORT`, `__SECURITY` (`tls`, `starttls`,
/// ou `local_plain` pour un relais de la boucle locale), `__USERNAME`, `__PASSWORD` (variable
/// d'environnement seulement), `__FROM_ADDRESS`, `__FROM_NAME`, `__TIMEOUT_SECONDS` (délai par
/// commande, 1 à 30 s).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SmtpConfig {
    pub host: String,
    pub port: u16,
    pub security: String,
    #[serde(default)]
    pub username: Option<String>,
    #[serde(default)]
    pub password: Option<SecretPassword>,
    pub from_address: String,
    #[serde(default)]
    pub from_name: Option<String>,
    #[serde(default = "default_smtp_timeout")]
    pub timeout_seconds: u64,
}

fn default_smtp_timeout() -> u64 {
    30
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
    /// Proxys inverses de confiance (adresses ou réseaux `adresse/préfixe`) : l'adresse du
    /// client n'est lue dans `X-Forwarded-For` que pour une connexion venant de l'un d'eux. Vide
    /// par défaut : adresse de la connexion.
    #[serde(default)]
    pub trusted_proxies: Vec<crate::net::IpNetwork>,
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
                    .list_separator(",")
                    // Seules ces clés sont des listes ; les autres restent des chaînes
                    .with_list_parse_key("server.trusted_proxies")
                    .with_list_parse_key("cors.allowed_origins")
                    .with_list_parse_key("cors.allowed_methods")
                    .with_list_parse_key("cors.allowed_headers"),
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
