// SPDX-License-Identifier: AGPL-3.0-only

//! Module `lyxal_mail` pour `lyxal_runtime` et sonde de santé du courrier.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::presence::{PresenceConfig, PresenceStore};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use lyxal_storage::{ContentScanner, StorageService};
use std::sync::{Arc, Mutex, PoisonError};
use std::time::{Duration, Instant};

use crate::dns::MailResolver;
use crate::models::SettingsGetParams;
use crate::store::MailStore;
use crate::MODULE_ID;

/// Module `lyxal_mail` : ses ressources SurrealQL sont installées par le runtime depuis le
/// manifeste ; ses services (dépôt, lecture, maintenance), ses écoutes et sa sonde sont
/// enregistrés par l'hôte `lyxal-groupware`, qui fait exécuter la maintenance par
/// `lyxal_scheduler`.
pub struct MailModule {
    descriptor: ModuleDescriptor,
}

impl Default for MailModule {
    fn default() -> Self {
        Self::new()
    }
}

impl MailModule {
    /// Descripteur conforme au manifeste.
    pub fn new() -> Self {
        let descriptor = ModuleDescriptorBuilder::new(ModuleId::new(MODULE_ID), "0.1.0")
            .name("Lyxal Mail")
            .description(
                "Serveur de courrier de Lyxal OS : domaines, comptes, adresses, dossiers, messages et quotas ; écoutes supervisées par l'hôte lyxal-groupware",
            )
            .capability("database")
            .capability("events")
            .capability("mail")
            .dependency(ModuleId::new("lyxal_core"))
            .dependency(ModuleId::new("lyxal_error"))
            .dependency(ModuleId::new("lyxal_event"))
            .dependency(ModuleId::new("lyxal_auth"))
            .dependency(ModuleId::new("lyxal_storage"))
            .build();
        Self { descriptor }
    }
}

#[async_trait]
impl LyxalModule for MailModule {
    fn descriptor(&self) -> &ModuleDescriptor {
        &self.descriptor
    }

    async fn install(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn start(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }

    async fn stop(&self, _ctx: &ModuleContext) -> Result<(), RuntimeError> {
        Ok(())
    }
}

/// Absence tolérée des nœuds d'un hôte requis avant que la sonde du courrier ne passe à
/// « dégradé » : 10 minutes.
pub const REQUIRED_HOST_ABSENCE_LIMIT: Duration = Duration::from_secs(600);

/// Hôte dont des nœuds doivent tourner sur la même base que le courrier : `lyxal_server`, qui
/// exécute `storage.cleanup` (octets des messages effacés retirés des supports) et
/// `secrets.maintenance` (clés des fichiers rescellées après une rotation). La présence est lue
/// dans `runtime_node` (`fn::runtime_node_list`, nœud vivant : battement de moins de 30 s).
///
/// L'absence est comptée par ce nœud depuis le dernier nœud vivant de l'hôte qu'il a vu, ou
/// depuis la création de la sonde s'il n'en a vu aucun.
pub struct RequiredHost {
    presence: PresenceStore,
    host: String,
    absence_limit: Duration,
    last_alive: Mutex<Instant>,
}

impl RequiredHost {
    /// Hôte `host` (rôle d'un binaire, par exemple `lyxal_server`), lu par `presence` (session
    /// système), toléré absent [`REQUIRED_HOST_ABSENCE_LIMIT`].
    pub fn new(presence: PresenceStore, host: impl Into<String>) -> Self {
        Self {
            presence,
            host: host.into(),
            absence_limit: REQUIRED_HOST_ABSENCE_LIMIT,
            last_alive: Mutex::new(Instant::now()),
        }
    }

    /// Absence tolérée (essais).
    pub fn with_absence_limit(mut self, limit: Duration) -> Self {
        self.absence_limit = limit;
        self
    }

    /// Durée de l'absence si elle dépasse la limite ; `None` si un nœud vivant de l'hôte est
    /// listé, ou si l'absence est encore tolérée.
    async fn absence(&self) -> Result<Option<Duration>, RuntimeError> {
        let nodes = self
            .presence
            .list_nodes(PresenceConfig::default().alive_within)
            .await?;
        let alive = nodes
            .iter()
            .any(|node| node.host == self.host && node.alive == Some(true));
        let mut last_alive = self
            .last_alive
            .lock()
            .unwrap_or_else(PoisonError::into_inner);
        if alive {
            *last_alive = Instant::now();
            return Ok(None);
        }
        let absent = last_alive.elapsed();
        Ok((absent > self.absence_limit).then_some(absent))
    }
}

/// Sonde du courrier : base joignable (réglages lus par la session système), support de
/// stockage configuré et service de clés des fichiers présent (sans eux, aucun message n'est
/// déposé ni lu : « dégradé »), et, si un hôte requis est déclaré ([`RequiredHost`]), un de ses
/// nœuds vivant depuis moins de 10 minutes (sinon « dégradé » : octets des messages effacés et
/// rescellement des clés en attente). L'écriture effective sur chaque support est vérifiée par
/// la sonde de `lyxal_storage`.
pub struct MailHealthCheck {
    module_id: ModuleId,
    store: MailStore,
    storage: StorageService,
    required_host: Option<RequiredHost>,
    scanner: Option<Arc<dyn ContentScanner>>,
    dns: Option<DnsProbe>,
}

/// Intervalle entre deux requêtes DNS de la sonde (nom témoin de l'installation).
pub const DNS_PROBE_INTERVAL: Duration = Duration::from_secs(60);

/// Requête DNS témoin de la sonde : le nom de l'hôte (`smtp.hostname`), interrogé une fois par
/// minute au plus ; une absence (`NXDOMAIN`, aucun enregistrement) est une réponse, seule une
/// panne fait passer la sonde à « dégradé ».
struct DnsProbe {
    resolver: Arc<dyn MailResolver>,
    name: String,
    last: Mutex<Option<(Instant, bool)>>,
}

impl DnsProbe {
    async fn answers(&self) -> bool {
        let cached = *self.last.lock().unwrap_or_else(PoisonError::into_inner);
        if let Some((at, answers)) = cached {
            if at.elapsed() < DNS_PROBE_INTERVAL {
                return answers;
            }
        }
        let answers = match self.resolver.ipv4(&self.name).await {
            Ok(_) => true,
            Err(error) => !error.is_temporary(),
        };
        *self.last.lock().unwrap_or_else(PoisonError::into_inner) = Some((Instant::now(), answers));
        answers
    }
}

impl MailHealthCheck {
    /// Sonde sur la session système de l'hôte (`store`) et le stockage des messages.
    pub fn new(store: MailStore, storage: StorageService) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            store,
            storage,
            required_host: None,
            scanner: None,
            dns: None,
        }
    }

    /// Hôte dont un nœud doit tourner sur la même base (`lyxal_server`).
    pub fn with_required_host(mut self, host: RequiredHost) -> Self {
        self.required_host = Some(host);
        self
    }

    /// Antivirus de la chaîne de remise : injoignable, la sonde passe à « dégradé » (les
    /// messages sont refusés temporairement).
    pub fn with_scanner(mut self, scanner: Arc<dyn ContentScanner>) -> Self {
        self.scanner = Some(scanner);
        self
    }

    /// Résolveur DNS de la réception : une panne sur le nom témoin `name` (nom de l'hôte) fait
    /// passer la sonde à « dégradé ».
    pub fn with_dns_probe(mut self, resolver: Arc<dyn MailResolver>, name: String) -> Self {
        self.dns = Some(DnsProbe {
            resolver,
            name,
            last: Mutex::new(None),
        });
        self
    }
}

#[async_trait]
impl ModuleHealthCheck for MailHealthCheck {
    fn module_id(&self) -> &ModuleId {
        &self.module_id
    }

    async fn check(&self, _ctx: &ModuleContext) -> Result<HealthCheckResult, RuntimeError> {
        let started = Instant::now();
        let elapsed = || u64::try_from(started.elapsed().as_millis()).unwrap_or(u64::MAX);
        if let Err(error) = self.store.settings_get(SettingsGetParams::default()).await {
            return Ok(HealthCheckResult::unhealthy(
                self.module_id.clone(),
                Some(elapsed()),
                Some(format!("réglages du courrier illisibles : {error}")),
            ));
        }
        if !self.storage.is_configured() {
            return Ok(HealthCheckResult::degraded(
                self.module_id.clone(),
                elapsed(),
                Some(
                    "MAIL_CONTENT_UNAVAILABLE : aucun support de stockage, aucun message n'est déposé ni lu"
                        .to_string(),
                ),
            ));
        }
        if !self.storage.encryption_available() {
            return Ok(HealthCheckResult::degraded(
                self.module_id.clone(),
                elapsed(),
                Some(
                    "MAIL_CONTENT_UNAVAILABLE : clé maîtresse du coffre-fort absente, aucun message n'est déposé ni lu"
                        .to_string(),
                ),
            ));
        }
        if let Some(scanner) = &self.scanner {
            if let Err(error) = scanner.ping().await {
                return Ok(HealthCheckResult::degraded(
                    self.module_id.clone(),
                    elapsed(),
                    Some(format!(
                        "MAIL_SCANNER_UNAVAILABLE : antivirus injoignable, messages reçus refusés temporairement ({})",
                        error.code()
                    )),
                ));
            }
        }
        if let Some(dns) = &self.dns {
            if !dns.answers().await {
                return Ok(HealthCheckResult::degraded(
                    self.module_id.clone(),
                    elapsed(),
                    Some(format!(
                        "DNS en panne sur le nom témoin {} : contrôles SPF, DKIM et DMARC en « temperror »",
                        dns.name
                    )),
                ));
            }
        }
        if let Some(required) = &self.required_host {
            match required.absence().await {
                Ok(None) => {}
                Ok(Some(absent)) => {
                    return Ok(HealthCheckResult::degraded(
                        self.module_id.clone(),
                        elapsed(),
                        Some(format!(
                            "aucun nœud {} vivant depuis {} s : octets des messages effacés et rescellement des clés des fichiers en attente (storage.cleanup, secrets.maintenance)",
                            required.host,
                            absent.as_secs()
                        )),
                    ))
                }
                Err(error) => {
                    return Ok(HealthCheckResult::degraded(
                        self.module_id.clone(),
                        elapsed(),
                        Some(format!(
                            "présence des nœuds {} illisible : {error}",
                            required.host
                        )),
                    ))
                }
            }
        }
        Ok(HealthCheckResult::healthy(
            self.module_id.clone(),
            elapsed(),
            Some("dépôt et lecture des messages disponibles".to_string()),
        ))
    }
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::*;
    use lyxal_runtime::manifest::ManifestParser;

    /// Le descripteur Rust est celui que le runtime tire de `manifest.toml`.
    #[test]
    fn descriptor_matches_manifest() {
        let from_manifest = ManifestParser::parse_to_descriptor(include_str!("../manifest.toml"))
            .expect("manifeste");
        assert_eq!(MailModule::new().descriptor(), &from_manifest);
    }
}
