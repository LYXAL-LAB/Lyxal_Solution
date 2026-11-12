use crate::error::ServerError;
use lyxal_surreal::SecretString;
use serde::{Deserialize, Deserializer};
use std::{
    collections::BTreeMap,
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
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct StorageConfig {
    #[serde(default)]
    pub disk: Option<DiskStorageConfig>,
    /// Supports S3 ou compatibles, par nom de support (`LYXAL__STORAGE__S3__<NOM>__*`).
    #[serde(default)]
    pub s3: BTreeMap<String, S3StorageConfig>,
    /// Antivirus qui analyse tout fichier envoyé (facultatif).
    #[serde(default)]
    pub antivirus: Option<AntivirusConfig>,
    /// Délai d'inactivité d'un envoi ou d'un téléchargement, en secondes (5 à 600).
    #[serde(default = "default_storage_idle_timeout")]
    pub idle_timeout_seconds: u64,
}

impl Default for StorageConfig {
    fn default() -> Self {
        Self {
            disk: None,
            s3: BTreeMap::new(),
            antivirus: None,
            idle_timeout_seconds: default_storage_idle_timeout(),
        }
    }
}

fn default_storage_idle_timeout() -> u64 {
    60
}

/// Antivirus ClamAV (service `clamd` séparé) : `LYXAL__STORAGE__ANTIVIRUS__ADDRESS`
/// (`hôte:port`) ou `__SOCKET` (chemin d'une socket Unix), l'un des deux ; `__TIMEOUT_SECONDS`
/// (attente maximale du service, 1 à 300, 30 par défaut). Configuré mais injoignable : les envois
/// sont refusés.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct AntivirusConfig {
    #[serde(default)]
    pub address: Option<String>,
    #[serde(default)]
    pub socket: Option<PathBuf>,
    #[serde(default = "default_antivirus_timeout")]
    pub timeout_seconds: u64,
}

fn default_antivirus_timeout() -> u64 {
    30
}

/// Support S3 ou compatible (Bunny Storage, par exemple) : `LYXAL__STORAGE__S3__<NOM>__ENDPOINT`,
/// `__REGION`, `__BUCKET`, `__ACCESS_KEY_ID`, `__SECRET_ACCESS_KEY` (variable d'environnement
/// seulement), `__PATH_STYLE` (vrai par défaut : adresses `/<bucket>/<clé>`), `__ALLOW_HTTP`
/// (faux par défaut). `<NOM>` est le nom du support, celui du champ `backend` d'un bucket.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct S3StorageConfig {
    pub endpoint: String,
    pub region: String,
    pub bucket: String,
    pub access_key_id: String,
    pub secret_access_key: SecretPassword,
    #[serde(default = "default_true")]
    pub path_style: bool,
    #[serde(default)]
    pub allow_http: bool,
}

fn default_true() -> bool {
    true
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

/// La clé secrète d'un support S3 ne se lit que dans l'environnement : présente dans un fichier
/// de configuration, elle arrête le démarrage.
fn refuse_storage_secret_in_files(
    files: config::ConfigBuilder<config::builder::DefaultState>,
) -> Result<(), ServerError> {
    let files = files.build().map_err(|error| ServerError::Configuration {
        message: error.to_string(),
    })?;
    let Ok(backends) = files.get_table("storage.s3") else {
        return Ok(());
    };
    for (name, backend) in backends {
        let in_file = backend
            .into_table()
            .is_ok_and(|fields| fields.contains_key("secret_access_key"));
        if in_file {
            return Err(ServerError::Configuration {
                message: format!(
                    "storage.s3.{name}.secret_access_key ne doit pas figurer dans un fichier : \
                     LYXAL__STORAGE__S3__{}__SECRET_ACCESS_KEY seulement",
                    name.to_uppercase()
                ),
            });
        }
    }
    Ok(())
}

impl AppConfig {
    pub fn load() -> Result<Self, ServerError> {
        Self::load_from("config")
    }

    pub fn load_from(directory: impl AsRef<Path>) -> Result<Self, ServerError> {
        Self::load_with_environment(directory, None)
    }

    /// Charge la configuration ; `variables` remplace les variables d'environnement du
    /// processus (tests).
    pub fn load_with_environment(
        directory: impl AsRef<Path>,
        variables: Option<config::Map<String, String>>,
    ) -> Result<Self, ServerError> {
        let directory = directory.as_ref();
        let environment = std::env::var("LYXAL_ENV").unwrap_or_else(|_| "development".into());

        let files = config::Config::builder()
            .add_source(config::File::from(directory.join("default.toml")).required(true))
            .add_source(
                config::File::from(directory.join(format!("{environment}.toml"))).required(false),
            );
        refuse_storage_secret_in_files(files.clone())?;

        let builder = files.add_source(
            config::Environment::with_prefix("LYXAL")
                .source(variables)
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
        // Nom d'un support : celui que porte le champ `backend` d'un bucket (snake_case)
        for name in self.storage.s3.keys() {
            let valid = name.len() <= 64
                && name.starts_with(|c: char| c.is_ascii_lowercase())
                && name
                    .chars()
                    .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '_');
            if !valid {
                return Err(ServerError::Configuration {
                    message: format!(
                        "storage.s3.{name} : nom de support invalide (minuscules, chiffres et _, 64 caractères au plus)"
                    ),
                });
            }
        }
        if let Some(antivirus) = &self.storage.antivirus {
            if antivirus.address.is_some() == antivirus.socket.is_some() {
                return Err(ServerError::Configuration {
                    message: "storage.antivirus : address ou socket, l'un des deux".into(),
                });
            }
            if !(1..=300).contains(&antivirus.timeout_seconds) {
                return Err(ServerError::Configuration {
                    message: "storage.antivirus.timeout_seconds doit être compris entre 1 et 300"
                        .into(),
                });
            }
        }
        if !(5..=600).contains(&self.storage.idle_timeout_seconds) {
            return Err(ServerError::Configuration {
                message: "storage.idle_timeout_seconds doit être compris entre 5 et 600".into(),
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
