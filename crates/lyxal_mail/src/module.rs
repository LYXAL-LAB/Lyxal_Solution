// SPDX-License-Identifier: AGPL-3.0-only

//! Module `lyxal_mail` pour `lyxal_runtime` et sonde de santé du courrier.

use async_trait::async_trait;
use lyxal_runtime::descriptor::{ModuleDescriptor, ModuleDescriptorBuilder};
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{LyxalModule, ModuleContext, RuntimeError};
use lyxal_storage::StorageService;
use std::time::Instant;

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

/// Sonde du courrier : base joignable (réglages lus par la session système), support de
/// stockage configuré et service de clés des fichiers présent (sans eux, aucun message n'est
/// déposé ni lu : « dégradé »). L'écriture effective sur chaque support est vérifiée par la
/// sonde de `lyxal_storage`.
pub struct MailHealthCheck {
    module_id: ModuleId,
    store: MailStore,
    storage: StorageService,
}

impl MailHealthCheck {
    /// Sonde sur la session système de l'hôte (`store`) et le stockage des messages.
    pub fn new(store: MailStore, storage: StorageService) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            store,
            storage,
        }
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
