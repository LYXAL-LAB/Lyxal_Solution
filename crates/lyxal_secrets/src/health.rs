//! Sonde de santé de `lyxal_secrets` : base joignable (réglages lisibles), clé maîtresse du
//! coffre-fort présente (R5), clés d'organisation lisibles par le trousseau maître, rescellements
//! en attente (R1 : la sonde annonce la fin du rescellement après une rotation de la clé
//! maîtresse).

use async_trait::async_trait;
use lyxal_runtime::health::{HealthCheckResult, ModuleHealthCheck};
use lyxal_runtime::types::ModuleId;
use lyxal_runtime::{ModuleContext, RuntimeError};
use std::time::Instant;

use crate::keys::MasterKeys;
use crate::models::{RewrapListParams, SettingsGetParams};
use crate::module::MODULE_ID;
use crate::store::SecretsStore;

/// Éléments en attente comptés par la sonde (au-delà : « au moins »).
const PROBE_LIMIT: i64 = 1000;

/// Sonde de santé du coffre-fort.
pub struct SecretsHealthCheck {
    module_id: ModuleId,
    store: SecretsStore,
    master: Option<MasterKeys>,
}

impl SecretsHealthCheck {
    /// Sonde sur le store de la session système de l'hôte et le trousseau maître (absent : la
    /// sonde est « dégradée »).
    pub fn new(store: SecretsStore, master: Option<MasterKeys>) -> Self {
        Self {
            module_id: ModuleId::new(MODULE_ID),
            store,
            master,
        }
    }
}

#[async_trait]
impl ModuleHealthCheck for SecretsHealthCheck {
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
                Some(format!("réglages illisibles : {error}")),
            ));
        }
        let Some(master) = &self.master else {
            return Ok(HealthCheckResult::degraded(
                self.module_id.clone(),
                elapsed(),
                Some(
                    "SECRETS_CRYPTO_UNAVAILABLE : clé maîtresse du coffre-fort absente (LYXAL__SECRETS__MASTER_KEY), aucune valeur n'est écrite ni lue"
                        .to_string(),
                ),
            ));
        };
        let work = match self
            .store
            .rewrap_list(RewrapListParams {
                master_key_id: master.active_id().as_str().to_string(),
                limit: Some(PROBE_LIMIT),
            })
            .await
        {
            Ok(work) => work,
            Err(error) => {
                return Ok(HealthCheckResult::unhealthy(
                    self.module_id.clone(),
                    Some(elapsed()),
                    Some(format!("rescellements illisibles : {error}")),
                ))
            }
        };
        // Clé d'organisation scellée par une clé maîtresse absente du trousseau : ses valeurs ne
        // s'ouvrent plus tant que cette clé n'est pas fournie (LYXAL__SECRETS__PREVIOUS_MASTER_KEY)
        let unknown = work
            .keys
            .iter()
            .filter(|key| !key.master_key_id.as_deref().is_some_and(|id| master.knows(id)))
            .count();
        if unknown > 0 {
            return Ok(HealthCheckResult::degraded(
                self.module_id.clone(),
                elapsed(),
                Some(format!(
                    "SECRETS_TENANT_KEY_UNAVAILABLE : {unknown} clé(s) d'organisation scellée(s) par une clé maîtresse absente du trousseau"
                )),
            ));
        }
        let message = if work.keys.is_empty() && work.versions.is_empty() && work.unused.is_empty()
        {
            match master.previous_id() {
                Some(previous) => format!(
                    "clé maîtresse {} active ; rescellement terminé : l'ancienne clé maîtresse {previous} peut être retirée",
                    master.active_id()
                ),
                None => format!(
                    "clé maîtresse {} active ; aucun rescellement en attente",
                    master.active_id()
                ),
            }
        } else {
            format!(
                "clé maîtresse {} active ; rescellement en attente : {} clé(s) d'organisation, {} version(s), {} ancienne(s) clé(s) à détruire",
                master.active_id(),
                work.keys.len(),
                work.versions.len(),
                work.unused.len()
            )
        };
        Ok(HealthCheckResult::healthy(
            self.module_id.clone(),
            elapsed(),
            Some(message),
        ))
    }
}
