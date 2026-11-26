// SPDX-License-Identifier: AGPL-3.0-only

//! Configuration de l'hôte : fichiers `config/default.toml`, `config/<LYXAL_ENV>.toml`, puis
//! variables `LYXAL_GROUPWARE__*` (décision G5 : distinctes des `LYXAL__*` de `lyxal-server`).
//! Le mot de passe de la base, la clé secrète d'un support S3 et les clés maîtresses du
//! coffre-fort ne se lisent que dans l'environnement. Tout est validé avant la connexion à la
//! base.
//!
//! Les sections `[secrets]` et `[storage]` sont celles de `lyxal_host::services`, communes aux
//! hôtes, et `[scheduler]` a la forme de celle de `lyxal-server` : elles reçoivent les mêmes
//! valeurs que dans `lyxal-server` (décision M13 du lot 4) : même clé maîtresse du coffre-fort,
//! mêmes supports nommés (disque partagé ou S3), sans quoi un hôte ne lit pas les fichiers écrits
//! par l'autre.

use crate::error::GroupwareError;
use lyxal_host::config::{load_layered, DatabaseConfig, ObservabilityConfig, RuntimeTimeouts};
use lyxal_host::net::IpNetwork;
use lyxal_host::services::{
    is_backend_name, validate_storage, SecretsConfig, StorageConfig, SECRET_KEYS,
};
use lyxal_mail::net::{MailProtocol, TlsMode};
use serde::{Deserialize, Deserializer};
use std::collections::BTreeSet;
use std::net::SocketAddr;
use std::path::{Path, PathBuf};
use std::time::Duration;

/// Préfixe des variables d'environnement de l'hôte.
pub const ENV_PREFIX: &str = "LYXAL_GROUPWARE";

/// Configuration de l'hôte `lyxal-groupware`.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct GroupwareConfig {
    pub application: ApplicationConfig,
    pub http: HttpConfig,
    pub database: DatabaseConfig,
    pub runtime: RuntimeTimeouts,
    #[serde(default)]
    pub limits: LimitsConfig,
    /// Certificats des écoutes chiffrées et délais TLS.
    #[serde(default)]
    pub tls: TlsConfig,
    /// Écoutes de courrier ; aucune par défaut.
    #[serde(default)]
    pub listeners: Vec<ListenerConfig>,
    pub observability: GroupwareObservability,
    /// Clé maîtresse du coffre-fort (clés des fichiers chiffrés du courrier), section commune aux
    /// hôtes (`lyxal_host::services`). Sans clé, aucun message n'est déposé ni lu (chiffrement
    /// obligatoire, décision M1) ; si un bucket chiffré existe déjà dans la base, l'hôte refuse
    /// de démarrer (`GROUPWARE_MASTER_KEY_MISSING`).
    #[serde(default)]
    pub secrets: SecretsConfig,
    /// Supports des fichiers et antivirus, section commune aux hôtes (`lyxal_host::services`).
    #[serde(default)]
    pub storage: StorageConfig,
    /// Exécuteurs du planificateur sur ce nœud.
    #[serde(default)]
    pub scheduler: SchedulerConfig,
    /// Courrier : support de ses fichiers, maintenance.
    #[serde(default)]
    pub mail: MailConfig,
    /// Réception SMTP (écoutes `smtp`) : nom de l'hôte, limites, politique DMARC.
    #[serde(default)]
    pub smtp: SmtpSection,
    /// Résolveur DNS du nœud (contrôles SPF, DKIM, DMARC, nom inverse).
    #[serde(default)]
    pub dns: DnsSection,
}

/// Réception SMTP (plan du lot 5, §7.6 et §11.2) : valeurs par défaut et bornes de
/// `lyxal_mail::smtp::SmtpConfig`. `hostname` est obligatoire dès qu'une écoute `smtp` existe
/// (bannière, `Received`, `authserv-id`).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields, default)]
pub struct SmtpSection {
    pub hostname: Option<String>,
    pub max_message_bytes: u64,
    pub max_recipients: usize,
    pub max_messages_per_session: u32,
    pub max_errors: u32,
    pub max_line_bytes: usize,
    pub command_timeout_seconds: u64,
    pub data_timeout_seconds: u64,
    pub session_max_seconds: u64,
    pub data_min_bytes_per_second: u64,
    /// Messages par minute et par réseau : `/32`, `/26`, `/21` (IPv6 : `/64`, `/48`, `/32`).
    pub messages_per_network_per_minute: [u64; 3],
    /// `true` : applique `reject` et `quarantine` de DMARC ; `false` : résultat seulement.
    pub dmarc_enforce: bool,
}

impl Default for SmtpSection {
    fn default() -> Self {
        use lyxal_mail::smtp as d;
        Self {
            hostname: None,
            max_message_bytes: d::DEFAULT_MAX_MESSAGE_BYTES,
            max_recipients: d::DEFAULT_MAX_RECIPIENTS,
            max_messages_per_session: d::DEFAULT_MAX_MESSAGES_PER_SESSION,
            max_errors: d::DEFAULT_MAX_ERRORS,
            max_line_bytes: d::DEFAULT_MAX_LINE_BYTES,
            command_timeout_seconds: d::DEFAULT_COMMAND_TIMEOUT.as_secs(),
            data_timeout_seconds: d::DEFAULT_DATA_TIMEOUT.as_secs(),
            session_max_seconds: d::DEFAULT_SESSION_MAX.as_secs(),
            data_min_bytes_per_second: d::DEFAULT_DATA_MIN_BYTES_PER_SECOND,
            messages_per_network_per_minute: d::DEFAULT_MESSAGES_PER_NETWORK_PER_MINUTE,
            dmarc_enforce: true,
        }
    }
}

impl SmtpSection {
    /// Réglages de la réception ; `None` sans `hostname`.
    pub fn smtp_config(&self) -> Option<lyxal_mail::smtp::SmtpConfig> {
        let hostname = self.hostname.as_ref()?;
        Some(lyxal_mail::smtp::SmtpConfig {
            max_message_bytes: self.max_message_bytes,
            max_recipients: self.max_recipients,
            max_messages_per_session: self.max_messages_per_session,
            max_errors: self.max_errors,
            max_line_bytes: self.max_line_bytes,
            command_timeout: Duration::from_secs(self.command_timeout_seconds),
            data_timeout: Duration::from_secs(self.data_timeout_seconds),
            session_max: Duration::from_secs(self.session_max_seconds),
            data_min_bytes_per_second: self.data_min_bytes_per_second,
            messages_per_network_per_minute: self.messages_per_network_per_minute,
            dmarc_enforce: self.dmarc_enforce,
            ..lyxal_mail::smtp::SmtpConfig::new(hostname.clone())
        })
    }
}

/// Résolveur DNS (décision S3) : serveurs (`ip:port`, ou `ip` pour le port 53 ; vide : ceux du
/// système), délai par requête (5 s, 1 à 30), essais (2, 1 à 5), réponses en cache (16 384,
/// 0 à 1 000 000).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields, default)]
pub struct DnsSection {
    pub servers: Vec<String>,
    pub timeout_seconds: u64,
    pub attempts: usize,
    pub cache_size: u64,
}

impl Default for DnsSection {
    fn default() -> Self {
        let defaults = lyxal_mail::dns::DnsConfig::default();
        Self {
            servers: Vec::new(),
            timeout_seconds: defaults.timeout.as_secs(),
            attempts: defaults.attempts,
            cache_size: defaults.cache_size,
        }
    }
}

impl DnsSection {
    /// Réglages du résolveur ; le message nomme le réglage ou le serveur à corriger.
    pub fn dns_config(&self) -> Result<lyxal_mail::dns::DnsConfig, GroupwareError> {
        let servers = self
            .servers
            .iter()
            .map(|server| {
                server
                    .parse::<SocketAddr>()
                    .or_else(|_| {
                        server
                            .parse::<std::net::IpAddr>()
                            .map(|ip| SocketAddr::new(ip, 53))
                    })
                    .map_err(|_| GroupwareError::Configuration {
                        message: format!(
                            "dns.servers : « {server} » n'est pas une adresse ip ou ip:port"
                        ),
                    })
            })
            .collect::<Result<Vec<_>, _>>()?;
        let config = lyxal_mail::dns::DnsConfig {
            servers,
            timeout: Duration::from_secs(self.timeout_seconds),
            attempts: self.attempts,
            cache_size: self.cache_size,
        };
        config
            .validate()
            .map_err(|error| GroupwareError::Configuration {
                message: format!("dns : {error}"),
            })?;
        Ok(config)
    }
}

/// Planificateur (`lyxal_scheduler`) : places de chaque exécuteur de file sur ce nœud,
/// 4 par défaut, de 1 à 64.
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

/// Courrier : support des fichiers des messages (`storage_backend`, `default` par défaut, nom
/// d'un support de `[storage]`), fixé à la création du bucket chiffré `lyxal-mail` de chaque
/// organisation.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct MailConfig {
    #[serde(default = "default_mail_backend")]
    pub storage_backend: String,
}

fn default_mail_backend() -> String {
    "default".to_string()
}

impl Default for MailConfig {
    fn default() -> Self {
        Self {
            storage_backend: default_mail_backend(),
        }
    }
}

#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ApplicationConfig {
    pub name: String,
    pub environment: String,
}

/// Port HTTP de l'hôte : santé et mesures (`/live`, `/ready`, `/health`, `/metrics`).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct HttpConfig {
    /// Adresse liée, locale par défaut (`127.0.0.1:8090`) : les routes ne demandent aucun jeton.
    pub bind: SocketAddr,
    /// Délai laissé aux requêtes en cours à l'arrêt.
    pub graceful_shutdown_seconds: u64,
    /// TLS sur le port HTTP (certificats de la section `[tls]`, ALPN `h2` et `http/1.1`).
    #[serde(default)]
    pub tls: bool,
    /// Réseaux des répartiteurs : depuis eux, l'en-tête PROXY est exigé sur le port HTTP.
    #[serde(default)]
    pub proxy_networks: Vec<IpNetwork>,
}

/// Limites des connexions de courrier (décisions G10, G11), partagées par les écoutes du nœud.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields, default)]
pub struct LimitsConfig {
    /// Budget mémoire du processus pour les connexions.
    pub memory_budget_bytes: u64,
    /// Mémoire réservée par chaque connexion à son arrivée.
    pub connection_base_bytes: u64,
    /// Plafond de connexions simultanées de chaque écoute (surchargeable par écoute).
    pub max_connections: u32,
    /// Connexions ouvertes par réseau : adresse, petit réseau, grand réseau (IPv4 `/32`, `/26`,
    /// `/21` ; IPv6 `/64`, `/48`, `/32`).
    pub connections_per_network: [u64; 3],
    /// Connexions nouvelles par minute et par réseau (mêmes niveaux).
    pub connections_per_minute: [u64; 3],
    /// Réseaux suivis par fenêtre au plus.
    pub max_tracked_networks: usize,
    /// Réseaux refusés.
    pub deny_networks: Vec<IpNetwork>,
    /// Réseaux permis ; vide : tous (sauf `deny_networks`).
    pub allow_networks: Vec<IpNetwork>,
    /// Réseaux exemptés des limites par réseau (supervision, relais internes).
    pub exempt_networks: Vec<IpNetwork>,
    /// Délai de drainage des connexions à l'arrêt.
    pub drain_seconds: u64,
    /// Délai de lecture de l'en-tête PROXY d'une connexion venue d'un répartiteur déclaré.
    pub proxy_header_timeout_seconds: u64,
}

impl Default for LimitsConfig {
    fn default() -> Self {
        Self {
            memory_budget_bytes: 512 * MIB,
            connection_base_bytes: 64 * 1024,
            max_connections: 4096,
            connections_per_network: [30, 90, 270],
            connections_per_minute: [300, 900, 2700],
            max_tracked_networks: lyxal_mail::net::DEFAULT_MAX_TRACKED_NETWORKS,
            deny_networks: Vec::new(),
            allow_networks: Vec::new(),
            exempt_networks: Vec::new(),
            drain_seconds: 30,
            proxy_header_timeout_seconds: 5,
        }
    }
}

/// Certificats (décision G8) : fichiers PEM (chaîne, clé) lus par l'hôte, relus quand leur contenu
/// change. Le fichier de clé ne doit être lisible ni par le groupe ni par les autres.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields, default)]
pub struct TlsConfig {
    /// Certificat par défaut : client sans nom (SNI), nom inconnu ou adresse IP.
    pub default: Option<CertificateFiles>,
    /// Certificats par nom.
    pub certificates: Vec<NamedCertificate>,
    /// Intervalle de relecture des fichiers.
    pub reload_interval_seconds: u64,
    /// Délai de la poignée de main (TLS implicite et STARTTLS).
    pub handshake_timeout_seconds: u64,
}

impl Default for TlsConfig {
    fn default() -> Self {
        Self {
            default: None,
            certificates: Vec::new(),
            reload_interval_seconds: 60,
            handshake_timeout_seconds: 30,
        }
    }
}

impl TlsConfig {
    /// Vrai si au moins un certificat est déclaré.
    pub fn has_certificates(&self) -> bool {
        self.default.is_some() || !self.certificates.is_empty()
    }
}

/// Chemins PEM d'un certificat : chaîne (certificat du serveur d'abord) et clé privée.
#[derive(Clone, Debug, PartialEq, Eq, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct CertificateFiles {
    pub certificate: PathBuf,
    pub private_key: PathBuf,
}

/// Certificat servi pour des noms (SNI) : nom exact ou joker d'un niveau (`*.exemple.fr`).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct NamedCertificate {
    pub names: Vec<String>,
    pub certificate: PathBuf,
    pub private_key: PathBuf,
}

impl NamedCertificate {
    /// Chemins du certificat.
    pub fn files(&self) -> CertificateFiles {
        CertificateFiles {
            certificate: self.certificate.clone(),
            private_key: self.private_key.clone(),
        }
    }
}

/// Version TLS minimale d'une écoute.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Deserialize)]
pub enum TlsMinVersion {
    /// TLS 1.2 et 1.3.
    #[default]
    #[serde(rename = "1.2")]
    Tls12,
    /// TLS 1.3 seulement.
    #[serde(rename = "1.3")]
    Tls13,
}

const MIB: u64 = 1024 * 1024;

/// Une écoute de courrier.
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ListenerConfig {
    /// Identifiant (minuscules, chiffres, `_`, 32 caractères au plus).
    pub id: String,
    #[serde(deserialize_with = "protocol")]
    pub protocol: MailProtocol,
    /// Adresses liées (`0.0.0.0:25`, `[::]:25`).
    pub bind: Vec<SocketAddr>,
    #[serde(deserialize_with = "tls_mode")]
    pub tls: TlsMode,
    /// Plafond de connexions simultanées propre à cette écoute.
    #[serde(default)]
    pub max_connections: Option<u32>,
    /// Version TLS minimale (`"1.2"` par défaut, `"1.3"`), écoutes chiffrées seulement.
    #[serde(default)]
    pub tls_min_version: Option<TlsMinVersion>,
    /// Réseaux des répartiteurs de charge : depuis eux, l'en-tête PROXY (v1 ou v2) est exigé ;
    /// ailleurs il n'est jamais lu (décision G9).
    #[serde(default)]
    pub proxy_networks: Vec<IpNetwork>,
}

/// Journal : section `observability` commune aux hôtes, plus l'adresse des clients (G13).
#[derive(Clone, Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct GroupwareObservability {
    pub log_filter: String,
    pub json_logs: bool,
    pub include_target: bool,
    pub include_thread_ids: bool,
    /// `network` (défaut) : réseau masqué (`/24`, `/48`) ; `full` : adresse complète, au niveau
    /// `debug` seulement.
    #[serde(default)]
    pub log_client_ip: LogClientIp,
}

impl GroupwareObservability {
    /// Section commune, pour `lyxal_host::telemetry`.
    pub fn host(&self) -> ObservabilityConfig {
        ObservabilityConfig {
            log_filter: self.log_filter.clone(),
            json_logs: self.json_logs,
            include_target: self.include_target,
            include_thread_ids: self.include_thread_ids,
        }
    }
}

/// Adresse d'un client dans le journal.
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum LogClientIp {
    /// Réseau masqué seulement.
    #[default]
    Network,
    /// Adresse complète en plus, au niveau `debug`.
    Full,
}

fn protocol<'de, D: Deserializer<'de>>(deserializer: D) -> Result<MailProtocol, D::Error> {
    let text = String::deserialize(deserializer)?;
    match text.as_str() {
        "smtp" => Ok(MailProtocol::Smtp),
        "submission" => Ok(MailProtocol::Submission),
        "imap" => Ok(MailProtocol::Imap),
        "pop3" => Ok(MailProtocol::Pop3),
        "managesieve" => Ok(MailProtocol::ManageSieve),
        other => Err(serde::de::Error::custom(format!(
            "protocole inconnu « {other} » (smtp, submission, imap, pop3, managesieve)"
        ))),
    }
}

fn tls_mode<'de, D: Deserializer<'de>>(deserializer: D) -> Result<TlsMode, D::Error> {
    let text = String::deserialize(deserializer)?;
    match text.as_str() {
        "none" => Ok(TlsMode::None),
        "starttls" => Ok(TlsMode::StartTls),
        "implicit" => Ok(TlsMode::Implicit),
        other => Err(serde::de::Error::custom(format!(
            "mode TLS inconnu « {other} » (none, starttls, implicit)"
        ))),
    }
}

/// Bornes des réglages (`README.md` de l'hôte, §5 et §6).
const MAX_CONNECTIONS: std::ops::RangeInclusive<u32> = 1..=65_536;
const PER_NETWORK: std::ops::RangeInclusive<u64> = 1..=100_000;
const PER_MINUTE: std::ops::RangeInclusive<u64> = 1..=1_000_000;
const TRACKED: std::ops::RangeInclusive<usize> = 1_000..=10_000_000;
const MIN_MEMORY_BUDGET: u64 = 64 * MIB;
const CONNECTION_BASE: std::ops::RangeInclusive<u64> = 4 * 1024..=16 * MIB;
const DRAIN: std::ops::RangeInclusive<u64> = 1..=300;
const PROXY_HEADER_TIMEOUT: std::ops::RangeInclusive<u64> = 1..=60;
const HANDSHAKE_TIMEOUT: std::ops::RangeInclusive<u64> = 1..=300;
const RELOAD_INTERVAL: std::ops::RangeInclusive<u64> = 5..=86_400;

impl GroupwareConfig {
    /// Charge la configuration du dossier `config`.
    pub fn load() -> Result<Self, GroupwareError> {
        Self::load_from("config")
    }

    /// Charge la configuration du dossier `directory`.
    pub fn load_from(directory: impl AsRef<Path>) -> Result<Self, GroupwareError> {
        Self::load_with_environment(directory, None)
    }

    /// Charge la configuration (`<directory>/default.toml`, `<directory>/<LYXAL_ENV>.toml`, puis
    /// variables `LYXAL_GROUPWARE__*`) et la valide ; `variables` remplace les variables
    /// d'environnement du processus (tests).
    pub fn load_with_environment(
        directory: impl AsRef<Path>,
        variables: Option<config::Map<String, String>>,
    ) -> Result<Self, GroupwareError> {
        let secret_keys = [&["database.password"], SECRET_KEYS].concat();
        let value: Self = load_layered(
            directory.as_ref(),
            ENV_PREFIX,
            &secret_keys,
            &[
                "limits.connections_per_network",
                "limits.connections_per_minute",
                "limits.deny_networks",
                "limits.allow_networks",
                "limits.exempt_networks",
            ],
            variables,
        )?;
        value.validate()?;
        Ok(value)
    }

    /// Contrôle la cohérence de la configuration ; le message dit quel réglage corriger.
    pub fn validate(&self) -> Result<(), GroupwareError> {
        let invalid = |message: String| Err(GroupwareError::Configuration { message });
        if self.application.name.trim().is_empty() {
            return invalid("application.name ne peut pas être vide".into());
        }
        if self.database.endpoint.trim().is_empty() {
            return invalid("database.endpoint ne peut pas être vide".into());
        }
        if self.database.namespace.trim().is_empty() || self.database.database.trim().is_empty() {
            return invalid("database.namespace et database.database sont obligatoires".into());
        }
        if self.http.graceful_shutdown_seconds == 0 {
            return invalid("http.graceful_shutdown_seconds doit être supérieur à zéro".into());
        }
        if self.http.tls && !self.tls.has_certificates() {
            return invalid("http.tls = true : aucun certificat déclaré (section [tls])".into());
        }
        self.validate_limits()?;
        self.validate_tls()?;
        self.validate_services()?;
        self.validate_smtp()?;

        let mut ids = BTreeSet::new();
        let mut addresses = BTreeSet::from([self.http.bind]);
        for listener in &self.listeners {
            let id = &listener.id;
            let valid_id = !id.is_empty()
                && id.len() <= 32
                && id
                    .chars()
                    .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '_');
            if !valid_id {
                return invalid(format!(
                    "listeners.id « {id} » invalide (minuscules, chiffres et _, 32 caractères au plus)"
                ));
            }
            if !ids.insert(id.as_str()) {
                return invalid(format!("listeners.id « {id} » déclaré deux fois"));
            }
            if listener.bind.is_empty() {
                return invalid(format!("listeners.{id}.bind : au moins une adresse"));
            }
            for address in &listener.bind {
                // Port 0 : port libre choisi par le système, jamais le même deux fois
                if address.port() != 0 && !addresses.insert(*address) {
                    return invalid(format!(
                        "listeners.{id}.bind : adresse {address} liée deux fois"
                    ));
                }
            }
            validate_tls_mode(listener)?;
            if listener.tls != TlsMode::None && !self.tls.has_certificates() {
                return invalid(format!(
                    "listeners.{id}.tls = « {} » : aucun certificat déclaré (section [tls])",
                    listener.tls.as_str()
                ));
            }
            if let Some(max) = listener.max_connections {
                if !MAX_CONNECTIONS.contains(&max) {
                    return invalid(format!(
                        "listeners.{id}.max_connections doit être compris entre 1 et 65536"
                    ));
                }
            }
        }
        Ok(())
    }

    fn validate_limits(&self) -> Result<(), GroupwareError> {
        let limits = &self.limits;
        let invalid = |message: &str| {
            Err(GroupwareError::Configuration {
                message: message.to_string(),
            })
        };
        if limits.memory_budget_bytes < MIN_MEMORY_BUDGET {
            return invalid("limits.memory_budget_bytes doit être d'au moins 64 Mio (67108864)");
        }
        if !CONNECTION_BASE.contains(&limits.connection_base_bytes) {
            return invalid("limits.connection_base_bytes doit être compris entre 4 Kio et 16 Mio");
        }
        if !MAX_CONNECTIONS.contains(&limits.max_connections) {
            return invalid("limits.max_connections doit être compris entre 1 et 65536");
        }
        if !limits
            .connections_per_network
            .iter()
            .all(|n| PER_NETWORK.contains(n))
        {
            return invalid("limits.connections_per_network : valeurs entre 1 et 100000");
        }
        if !limits
            .connections_per_minute
            .iter()
            .all(|n| PER_MINUTE.contains(n))
        {
            return invalid("limits.connections_per_minute : valeurs entre 1 et 1000000");
        }
        if !TRACKED.contains(&limits.max_tracked_networks) {
            return invalid("limits.max_tracked_networks doit être compris entre 1000 et 10000000");
        }
        if !DRAIN.contains(&limits.drain_seconds) {
            return invalid("limits.drain_seconds doit être compris entre 1 et 300");
        }
        if !PROXY_HEADER_TIMEOUT.contains(&limits.proxy_header_timeout_seconds) {
            return invalid("limits.proxy_header_timeout_seconds doit être compris entre 1 et 60");
        }
        if limits.drain_seconds >= self.runtime.module_stop_timeout_seconds {
            return invalid(
                "limits.drain_seconds doit être inférieur à runtime.module_stop_timeout_seconds",
            );
        }
        Ok(())
    }

    /// `[smtp]` et `[dns]` : contrôlés dès qu'ils sont donnés ; `smtp.hostname` est obligatoire
    /// avec une écoute `smtp`.
    fn validate_smtp(&self) -> Result<(), GroupwareError> {
        self.dns.dns_config()?;
        let has_smtp = self
            .listeners
            .iter()
            .any(|listener| listener.protocol == MailProtocol::Smtp);
        match self.smtp.smtp_config() {
            Some(config) => config
                .validate()
                .map_err(|error| GroupwareError::Configuration {
                    message: error.to_string(),
                }),
            None if has_smtp => Err(GroupwareError::Configuration {
                message: "smtp.hostname est obligatoire avec une écoute smtp (bannière, Received, Authentication-Results)".into(),
            }),
            None => Ok(()),
        }
    }

    /// Réception SMTP de ce nœud, s'il a une écoute `smtp`.
    pub fn has_smtp_listener(&self) -> bool {
        self.listeners
            .iter()
            .any(|listener| listener.protocol == MailProtocol::Smtp)
    }

    fn validate_services(&self) -> Result<(), GroupwareError> {
        let invalid = |message: String| Err(GroupwareError::Configuration { message });
        validate_storage(&self.storage)?;
        if !(1..=lyxal_scheduler::MAX_WORKERS).contains(&self.scheduler.workers) {
            return invalid(format!(
                "scheduler.workers doit être compris entre 1 et {}",
                lyxal_scheduler::MAX_WORKERS
            ));
        }
        let backend = &self.mail.storage_backend;
        if !is_backend_name(backend) {
            return invalid(format!(
                "mail.storage_backend « {backend} » : nom de support invalide"
            ));
        }
        if self.storage.has_any_backend() && !self.storage.has_backend(backend) {
            return invalid(format!(
                "mail.storage_backend « {backend} » : aucun support de ce nom dans [storage]"
            ));
        }
        Ok(())
    }

    fn validate_tls(&self) -> Result<(), GroupwareError> {
        let tls = &self.tls;
        let invalid = |message: String| Err(GroupwareError::Configuration { message });
        if !RELOAD_INTERVAL.contains(&tls.reload_interval_seconds) {
            return invalid(
                "tls.reload_interval_seconds doit être compris entre 5 et 86400".into(),
            );
        }
        if !HANDSHAKE_TIMEOUT.contains(&tls.handshake_timeout_seconds) {
            return invalid(
                "tls.handshake_timeout_seconds doit être compris entre 1 et 300".into(),
            );
        }
        let mut names = BTreeSet::new();
        for certificate in &tls.certificates {
            if certificate.names.is_empty() {
                return invalid(format!(
                    "tls.certificates ({}) : au moins un nom",
                    certificate.certificate.display()
                ));
            }
            for name in &certificate.names {
                if !names.insert(name.to_ascii_lowercase()) {
                    return invalid(format!(
                        "tls.certificates : nom « {name} » déclaré deux fois"
                    ));
                }
            }
        }
        let empty_path = tls
            .default
            .iter()
            .map(|files| (&files.certificate, &files.private_key))
            .chain(
                tls.certificates
                    .iter()
                    .map(|named| (&named.certificate, &named.private_key)),
            )
            .any(|(certificate, key)| {
                certificate.as_os_str().is_empty() || key.as_os_str().is_empty()
            });
        if empty_path {
            return invalid("tls : chemin de certificat ou de clé vide".into());
        }
        Ok(())
    }

    /// Délai de lecture de l'en-tête PROXY.
    pub fn proxy_header_timeout(&self) -> Duration {
        Duration::from_secs(self.limits.proxy_header_timeout_seconds)
    }

    /// Délai de la poignée de main TLS.
    pub fn handshake_timeout(&self) -> Duration {
        Duration::from_secs(self.tls.handshake_timeout_seconds)
    }

    /// Délai de drainage des connexions à l'arrêt.
    pub fn drain(&self) -> Duration {
        Duration::from_secs(self.limits.drain_seconds)
    }
}

/// Règles TLS par protocole (décision G7) : `implicit` pour la soumission, IMAP et POP3 (RFC
/// 8314 : ports 465, 993, 995) ; `starttls` pour tous (ports 25, 587, 143, 110, 4190) ; `none`
/// pour la seule réception SMTP (port 25 : STARTTLS reste facultatif pour l'expéditeur). La
/// version minimale ne se règle que sur une écoute chiffrée.
fn validate_tls_mode(listener: &ListenerConfig) -> Result<(), GroupwareError> {
    let id = &listener.id;
    let protocol = listener.protocol;
    let refused = match listener.tls {
        TlsMode::None => (protocol != MailProtocol::Smtp).then(|| {
            format!(
                "listeners.{id} : protocole « {protocol} » sans TLS refusé (seule la réception smtp peut être en clair)"
            )
        }),
        TlsMode::StartTls => None,
        TlsMode::Implicit => {
            matches!(protocol, MailProtocol::Smtp | MailProtocol::ManageSieve).then(|| {
                format!(
                    "listeners.{id} : TLS implicite non défini pour « {protocol} » (submission, imap et pop3 seulement ; utiliser starttls)"
                )
            })
        }
    };
    if let Some(message) = refused {
        return Err(GroupwareError::Configuration { message });
    }
    if listener.tls == TlsMode::None && listener.tls_min_version.is_some() {
        return Err(GroupwareError::Configuration {
            message: format!("listeners.{id}.tls_min_version : sans effet sur une écoute en clair"),
        });
    }
    Ok(())
}
