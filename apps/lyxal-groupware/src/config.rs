// SPDX-License-Identifier: AGPL-3.0-only

//! Configuration de l'hôte : fichiers `config/default.toml`, `config/<LYXAL_ENV>.toml`, puis
//! variables `LYXAL_GROUPWARE__*` (décision G5 : distinctes des `LYXAL__*` de `lyxal-server`).
//! Le mot de passe de la base ne se lit que dans l'environnement. Tout est validé avant la
//! connexion à la base.

use crate::error::GroupwareError;
use lyxal_host::config::{load_layered, DatabaseConfig, ObservabilityConfig, RuntimeTimeouts};
use lyxal_host::net::IpNetwork;
use lyxal_mail::net::{MailProtocol, TlsMode};
use serde::{Deserialize, Deserializer};
use std::collections::BTreeSet;
use std::net::SocketAddr;
use std::path::Path;
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
    /// Écoutes de courrier ; aucune par défaut.
    #[serde(default)]
    pub listeners: Vec<ListenerConfig>,
    pub observability: GroupwareObservability,
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
        }
    }
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

/// Bornes des réglages (§6.7 à §6.9 du plan du lot 3).
const MAX_CONNECTIONS: std::ops::RangeInclusive<u32> = 1..=65_536;
const PER_NETWORK: std::ops::RangeInclusive<u64> = 1..=100_000;
const PER_MINUTE: std::ops::RangeInclusive<u64> = 1..=1_000_000;
const TRACKED: std::ops::RangeInclusive<usize> = 1_000..=10_000_000;
const MIN_MEMORY_BUDGET: u64 = 64 * MIB;
const CONNECTION_BASE: std::ops::RangeInclusive<u64> = 4 * 1024..=16 * MIB;
const DRAIN: std::ops::RangeInclusive<u64> = 1..=300;

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
        let value: Self = load_layered(
            directory.as_ref(),
            ENV_PREFIX,
            &["database.password"],
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
        self.validate_limits()?;

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
            // TLS implicite et STARTTLS : lot 3c (certificats). D'ici là, écoutes en clair
            // seulement, et seulement pour la réception SMTP (décision G7).
            if listener.tls != TlsMode::None {
                return invalid(format!(
                    "listeners.{id}.tls = « {} » : TLS pas encore disponible dans cette version (écoutes « none » seulement)",
                    listener.tls.as_str()
                ));
            }
            if listener.protocol != MailProtocol::Smtp {
                return invalid(format!(
                    "listeners.{id} : protocole « {} » sans TLS refusé (seule la réception smtp peut être en clair)",
                    listener.protocol
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
        if limits.drain_seconds >= self.runtime.module_stop_timeout_seconds {
            return invalid(
                "limits.drain_seconds doit être inférieur à runtime.module_stop_timeout_seconds",
            );
        }
        Ok(())
    }

    /// Délai de drainage des connexions à l'arrêt.
    pub fn drain(&self) -> Duration {
        Duration::from_secs(self.limits.drain_seconds)
    }
}
