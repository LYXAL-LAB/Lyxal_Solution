// SPDX-License-Identifier: AGPL-3.0-only

//! [`HickoryResolver`] : résolveur de production (décision S3).

use super::{normalize_name, reverse_name, Answer, DnsError, DnsResult, MailResolver, MxRecord};
use super::{MAX_RECORDS_PER_ANSWER, MAX_TXT_BYTES};
use async_trait::async_trait;
use hickory_resolver::config::{NameServerConfig, ResolverConfig};
use hickory_resolver::net::runtime::TokioRuntimeProvider;
use hickory_resolver::net::{DnsError as HickoryDnsError, NetError};
use hickory_resolver::proto::op::ResponseCode;
use hickory_resolver::proto::rr::{RData, RecordType};
use hickory_resolver::TokioResolver;
use std::net::{IpAddr, Ipv4Addr, Ipv6Addr, SocketAddr};
use std::time::Duration;

/// TTL maximal d'une réponse positive gardée en cache (décision S3).
const POSITIVE_MAX_TTL: Duration = Duration::from_secs(3_600);
/// TTL maximal d'une réponse négative gardée en cache (décision S3).
const NEGATIVE_MAX_TTL: Duration = Duration::from_secs(300);

/// Réglages du résolveur (section `[dns]` de l'hôte, plan du lot 5, §11.2). Les bornes sont
/// contrôlées par la configuration de l'hôte ; [`HickoryResolver::new`] les contrôle encore.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct DnsConfig {
    /// Serveurs interrogés (UDP puis TCP) ; vide : configuration du système
    /// (`/etc/resolv.conf`).
    pub servers: Vec<SocketAddr>,
    /// Délai par requête (1 à 30 s ; 5 s par défaut).
    pub timeout: Duration,
    /// Essais par requête (1 à 5 ; 2 par défaut).
    pub attempts: usize,
    /// Réponses gardées en cache (0 à 1 000 000 ; 16 384 par défaut).
    pub cache_size: u64,
}

impl Default for DnsConfig {
    fn default() -> Self {
        Self {
            servers: Vec::new(),
            timeout: Duration::from_secs(5),
            attempts: 2,
            cache_size: 16_384,
        }
    }
}

/// Construction du résolveur impossible.
#[derive(Clone, Debug, PartialEq, Eq, thiserror::Error)]
pub enum DnsSetupError {
    /// Réglage hors de ses bornes.
    #[error("réglage DNS invalide : {0}")]
    InvalidConfig(&'static str),
    /// Configuration DNS du système illisible.
    #[error("configuration DNS du système illisible")]
    SystemConfig,
    /// Aucun serveur DNS configuré.
    #[error("aucun serveur DNS configuré")]
    NoServers,
}

impl DnsConfig {
    /// Contrôle des bornes du plan (§11.2).
    pub fn validate(&self) -> Result<(), DnsSetupError> {
        if !(Duration::from_secs(1)..=Duration::from_secs(30)).contains(&self.timeout) {
            return Err(DnsSetupError::InvalidConfig("timeout_seconds : 1 à 30"));
        }
        if !(1..=5).contains(&self.attempts) {
            return Err(DnsSetupError::InvalidConfig("attempts : 1 à 5"));
        }
        if self.cache_size > 1_000_000 {
            return Err(DnsSetupError::InvalidConfig("cache_size : 0 à 1 000 000"));
        }
        Ok(())
    }
}

/// Résolveur `hickory-resolver` d'un nœud, partagé par toutes les sessions (cloner l'instance
/// partage le cache).
#[derive(Clone)]
pub struct HickoryResolver {
    resolver: TokioResolver,
}

impl std::fmt::Debug for HickoryResolver {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("HickoryResolver").finish_non_exhaustive()
    }
}

impl HickoryResolver {
    /// Résolveur sur les serveurs configurés, ou ceux du système si la liste est vide. Pas de
    /// DNSSEC, pas de DNS chiffré ; le fichier `hosts` n'est pas lu (le courrier suit le DNS).
    pub fn new(config: &DnsConfig) -> Result<Self, DnsSetupError> {
        config.validate()?;
        let provider = TokioRuntimeProvider::default();
        let mut builder = if config.servers.is_empty() {
            TokioResolver::builder(provider).map_err(|_| DnsSetupError::SystemConfig)?
        } else {
            let servers = config
                .servers
                .iter()
                .map(|server| {
                    let mut name_server = NameServerConfig::udp_and_tcp(server.ip());
                    for connection in &mut name_server.connections {
                        connection.port = server.port();
                    }
                    name_server
                })
                .collect();
            TokioResolver::builder_with_config(ResolverConfig::from_name_servers(servers), provider)
        };
        let options = builder.options_mut();
        options.timeout = config.timeout;
        options.attempts = config.attempts;
        options.cache_size = config.cache_size;
        options.positive_max_ttl = Some(POSITIVE_MAX_TTL);
        options.negative_max_ttl = Some(NEGATIVE_MAX_TTL);
        options.use_hosts_file = hickory_resolver::config::ResolveHosts::Never;
        options.preserve_intermediates = false;
        let resolver = builder.build().map_err(|_| DnsSetupError::SystemConfig)?;
        Ok(Self { resolver })
    }

    async fn lookup<T>(
        &self,
        name: &str,
        record_type: RecordType,
        mut convert: impl FnMut(&RData) -> Option<T>,
    ) -> DnsResult<T> {
        let name = normalize_name(name).ok_or(DnsError::InvalidName)?;
        let lookup = self
            .resolver
            .lookup(format!("{name}."), record_type)
            .await
            .map_err(map_error)?;
        let records: Vec<T> = lookup
            .answers()
            .iter()
            .filter_map(|record| convert(&record.data))
            .take(MAX_RECORDS_PER_ANSWER)
            .collect();
        if records.is_empty() {
            return Err(DnsError::NoRecords);
        }
        Ok(Answer { records })
    }
}

fn map_error(error: NetError) -> DnsError {
    if error.is_nx_domain() {
        DnsError::NotFound
    } else if error.is_no_records_found() {
        DnsError::NoRecords
    } else if matches!(
        error,
        NetError::Dns(HickoryDnsError::ResponseCode(ResponseCode::Refused))
    ) {
        DnsError::Refused
    } else {
        DnsError::Temporary
    }
}

/// Nom d'un enregistrement en minuscules, sans point final.
fn name_text(name: &hickory_resolver::proto::rr::Name) -> String {
    let text = name.to_ascii().to_ascii_lowercase();
    match text.strip_suffix('.') {
        Some(stripped) => stripped.to_string(),
        None => text,
    }
}

#[async_trait]
impl MailResolver for HickoryResolver {
    async fn txt(&self, name: &str) -> DnsResult<String> {
        self.lookup(name, RecordType::TXT, |data| match data {
            RData::TXT(txt) => {
                let length: usize = txt.txt_data.iter().map(|part| part.len()).sum();
                if length > MAX_TXT_BYTES {
                    return None;
                }
                let bytes: Vec<u8> = txt
                    .txt_data
                    .iter()
                    .flat_map(|part| part.iter())
                    .copied()
                    .collect();
                Some(String::from_utf8_lossy(&bytes).into_owned())
            }
            _ => None,
        })
        .await
    }

    async fn mx(&self, name: &str) -> DnsResult<MxRecord> {
        self.lookup(name, RecordType::MX, |data| match data {
            RData::MX(mx) => Some(MxRecord {
                preference: mx.preference,
                exchange: name_text(&mx.exchange),
            }),
            _ => None,
        })
        .await
    }

    async fn ipv4(&self, name: &str) -> DnsResult<Ipv4Addr> {
        self.lookup(name, RecordType::A, |data| match data {
            RData::A(a) => Some(a.0),
            _ => None,
        })
        .await
    }

    async fn ipv6(&self, name: &str) -> DnsResult<Ipv6Addr> {
        self.lookup(name, RecordType::AAAA, |data| match data {
            RData::AAAA(aaaa) => Some(aaaa.0),
            _ => None,
        })
        .await
    }

    async fn ptr(&self, ip: IpAddr) -> DnsResult<String> {
        self.lookup(
            &reverse_name(ip.to_canonical()),
            RecordType::PTR,
            |data| match data {
                RData::PTR(ptr) => Some(name_text(&ptr.0)),
                _ => None,
            },
        )
        .await
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;

    #[test]
    fn bornes_des_reglages() {
        assert!(DnsConfig::default().validate().is_ok());
        let mut config = DnsConfig {
            timeout: Duration::from_secs(31),
            ..DnsConfig::default()
        };
        assert!(config.validate().is_err());
        config.timeout = Duration::from_secs(5);
        config.attempts = 0;
        assert!(config.validate().is_err());
        config.attempts = 2;
        config.cache_size = 1_000_001;
        assert!(config.validate().is_err());
    }

    #[tokio::test]
    async fn serveurs_explicites_sans_reseau() {
        // Construction seulement : aucune requête n'est envoyée.
        let config = DnsConfig {
            servers: vec!["127.0.0.1:5353".parse().unwrap()],
            ..DnsConfig::default()
        };
        let resolver = HickoryResolver::new(&config).unwrap();
        assert_eq!(
            resolver.txt("nom invalide").await,
            Err(DnsError::InvalidName)
        );
    }
}
