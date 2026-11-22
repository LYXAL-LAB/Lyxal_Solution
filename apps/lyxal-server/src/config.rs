use crate::error::ServerError;
use lyxal_host::config::{
    load_layered, DatabaseConfig, ObservabilityConfig, RuntimeTimeouts, SecretPassword,
};
use lyxal_host::net::IpNetwork;
use lyxal_host::services::{validate_storage, SecretsConfig, StorageConfig, SECRET_KEYS};
use serde::Deserialize;
use std::{net::IpAddr, path::Path};

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AppConfig {
    pub application: ApplicationConfig,
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub runtime: RuntimeTimeouts,
    pub observability: ObservabilityConfig,
    pub cors: CorsConfig,
    #[serde(default)]
    pub crypto: CryptoConfig,
    #[serde(default)]
    pub notification: NotificationConfig,
    #[serde(default)]
    pub auth: AuthConfig,
    #[serde(default)]
    pub http: HttpConfig,
    /// Supports des fichiers et antivirus, section commune aux hôtes (`lyxal_host::services`).
    #[serde(default)]
    pub storage: StorageConfig,
    /// Clé maîtresse du coffre-fort, distincte de la clé applicative partagée (section commune
    /// aux hôtes, `lyxal_host::services`).
    #[serde(default)]
    pub secrets: SecretsConfig,
    #[serde(default)]
    pub scheduler: SchedulerConfig,
}

/// Délai des transferts HTTP (section `[http]`) : délai d'inactivité d'un envoi ou d'un
/// téléchargement de fichier, et délai d'écriture de toute connexion HTTP (client qui ne lit
/// plus sa réponse), en secondes (5 à 600, 60 par défaut ;
/// `LYXAL__HTTP__TRANSFER_IDLE_TIMEOUT_SECONDS`).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct HttpConfig {
    #[serde(default = "default_transfer_idle_timeout")]
    pub transfer_idle_timeout_seconds: u64,
}

impl Default for HttpConfig {
    fn default() -> Self {
        Self {
            transfer_idle_timeout_seconds: default_transfer_idle_timeout(),
        }
    }
}

fn default_transfer_idle_timeout() -> u64 {
    60
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

/// Planificateur (`lyxal_scheduler`) : places de chaque exécuteur de file sur ce nœud (W3),
/// `LYXAL__SCHEDULER__WORKERS`, 4 par défaut, de 1 à 64. La concurrence globale de la file et
/// celle de chaque organisation restent tenues par la base.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SchedulerConfig {
    #[serde(default = "default_scheduler_workers")]
    pub workers: u32,
}

fn default_scheduler_workers() -> u32 {
    lyxal_scheduler::DEFAULT_WORKERS
}

impl Default for SchedulerConfig {
    fn default() -> Self {
        Self {
            workers: default_scheduler_workers(),
        }
    }
}

/// Notifications sortantes. Les fournisseurs d'envoi sont des intégrations de `lyxal_notification`
/// (identifiants dans `lyxal_secrets`), plus un réglage de l'hôte. `public_url`
/// (`LYXAL__NOTIFICATION__PUBLIC_URL`) : adresse publique de l'hôte, qui active les liens de
/// désabonnement en un clic (avec la clé applicative) ; sans elle, aucun e-mail ne porte de lien
/// ni d'en-tête `List-Unsubscribe`.
#[derive(Clone, Debug, Default, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct NotificationConfig {
    #[serde(default)]
    pub public_url: Option<String>,
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
    pub trusted_proxies: Vec<IpNetwork>,
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
        Self::load_with_environment(directory, None)
    }

    /// Charge la configuration (`<directory>/default.toml`, `<directory>/<LYXAL_ENV>.toml`, puis
    /// variables `LYXAL__*`) ; `variables` remplace les variables d'environnement du processus
    /// (tests). La clé secrète d'un support S3 et les clés maîtresses du coffre-fort ne se lisent
    /// que dans l'environnement : présentes dans un fichier, elles arrêtent le démarrage.
    pub fn load_with_environment(
        directory: impl AsRef<Path>,
        variables: Option<config::Map<String, String>>,
    ) -> Result<Self, ServerError> {
        let value: Self = load_layered(
            directory.as_ref(),
            "LYXAL",
            SECRET_KEYS,
            // Seules ces clés sont des listes ; les autres restent des chaînes
            &[
                "server.trusted_proxies",
                "cors.allowed_origins",
                "cors.allowed_methods",
                "cors.allowed_headers",
            ],
            variables,
        )?;
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
        validate_storage(&self.storage)?;
        if !(5..=600).contains(&self.http.transfer_idle_timeout_seconds) {
            return Err(ServerError::Configuration {
                message: "http.transfer_idle_timeout_seconds doit être compris entre 5 et 600"
                    .into(),
            });
        }
        if !(1..=lyxal_scheduler::MAX_WORKERS).contains(&self.scheduler.workers) {
            return Err(ServerError::Configuration {
                message: format!(
                    "scheduler.workers doit être compris entre 1 et {}",
                    lyxal_scheduler::MAX_WORKERS
                ),
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
