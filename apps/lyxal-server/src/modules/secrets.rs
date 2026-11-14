//! Module `lyxal_secrets` : implémentation `LyxalModule`, trousseau maître du coffre-fort,
//! worker de maintenance et sonde de santé.
//!
//! La clé maîtresse du coffre-fort est propre au coffre-fort (R1), distincte de la clé
//! applicative partagée par `lyxal_auth` et `lyxal_notification` : `LYXAL__SECRETS__MASTER_KEY`
//! (identifiant `secrets.master_key_id`), et pendant une rotation l'ancienne clé en lecture seule
//! (`LYXAL__SECRETS__PREVIOUS_MASTER_KEY`, `secrets.previous_master_key_id`), lues par
//! `lyxal_crypto::EnvironmentKeyProvider`. Sans clé, le serveur démarre, aucune valeur n'est
//! écrite ni lue (`SECRETS_CRYPTO_UNAVAILABLE`) et la sonde le signale (R5).

use crate::config::{AppConfig, SecretsConfig};
use crate::error::ServerError;
use lyxal_crypto::{EnvironmentKeyProvider, KeyId, ResolvedKey};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use lyxal_secrets::{
    MasterKeys, RotatorRegistry, SecretsClient, SecretsHealthCheck, SecretsMaintenanceWorker,
    SecretsModule, SecretsStore,
};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_secrets::MODULE_ID;

/// Variable d'environnement de la clé maîtresse du coffre-fort.
const MASTER_KEY_VAR: &str = "LYXAL__SECRETS__MASTER_KEY";
/// Variable d'environnement de l'ancienne clé maîtresse, pendant une rotation.
const PREVIOUS_MASTER_KEY_VAR: &str = "LYXAL__SECRETS__PREVIOUS_MASTER_KEY";
/// Intervalle de la maintenance (purge, rescellement).
const MAINTENANCE_INTERVAL: Duration = Duration::from_secs(600);
/// Éléments traités par paquet.
const MAINTENANCE_BATCH: u32 = 200;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(SecretsModule::new())
}

/// Ce que l'hôte rend aux modules qui liront leurs secrets : la session système et le trousseau
/// maître du coffre-fort.
#[derive(Clone)]
pub struct SecretsHost {
    store: SecretsStore,
    master: Option<MasterKeys>,
}

impl SecretsHost {
    /// Client du coffre-fort pour un module hébergé, annoncé comme consommateur (`module`).
    pub fn client(&self, module: &str) -> SecretsClient {
        SecretsClient::new(self.store.clone(), self.master.clone(), module)
    }

    /// Vrai si la clé maîtresse du coffre-fort est configurée.
    pub fn has_master_key(&self) -> bool {
        self.master.is_some()
    }
}

fn configuration_error(field: &str, error: impl std::fmt::Display) -> ServerError {
    ServerError::Configuration {
        message: format!("{field} : {error}"),
    }
}

/// Une clé lue par `EnvironmentKeyProvider` ; une clé sans identifiant ou invalide arrête le
/// démarrage.
fn load_key(
    var: &str,
    field: &str,
    id_field: &str,
    id: Option<&str>,
) -> Result<ResolvedKey, ServerError> {
    let id = id
        .ok_or_else(|| configuration_error(id_field, "obligatoire avec la clé"))
        .and_then(|id| KeyId::parse(id).map_err(|e| configuration_error(id_field, e)))?;
    EnvironmentKeyProvider::load(var, id).map_err(|e| configuration_error(field, e))
}

/// Trousseau maître du coffre-fort : clé active et, pendant une rotation, l'ancienne en lecture
/// seule. `None` sans clé.
pub fn master_keys(config: &SecretsConfig) -> Result<Option<MasterKeys>, ServerError> {
    if config.master_key.is_none() {
        if config.previous_master_key.is_some() {
            return Err(configuration_error(
                "secrets.previous_master_key",
                "fournie sans clé maîtresse active (secrets.master_key)",
            ));
        }
        return Ok(None);
    }
    let active = load_key(
        MASTER_KEY_VAR,
        "secrets.master_key",
        "secrets.master_key_id",
        config.master_key_id.as_deref(),
    )?;
    let previous = match &config.previous_master_key {
        None => None,
        Some(_) => Some(load_key(
            PREVIOUS_MASTER_KEY_VAR,
            "secrets.previous_master_key",
            "secrets.previous_master_key_id",
            config.previous_master_key_id.as_deref(),
        )?),
    };
    MasterKeys::from_keys(active, previous)
        .map(Some)
        .map_err(|e| configuration_error("secrets.master_key", e))
}

/// Worker de maintenance et sonde ; rend ce qu'il faut aux modules pour lire leurs secrets.
pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
) -> Result<SecretsHost, ServerError> {
    let master = master_keys(&config.secrets)?;
    match &master {
        Some(keys) => tracing::info!(
            master_key_id = %keys.active_id(),
            previous_master_key_id = ?keys.previous_id().map(ToString::to_string),
            "coffre-fort des secrets : clé maîtresse chargée"
        ),
        None => tracing::warn!(
            "coffre-fort des secrets sans clé maîtresse : aucune valeur n'est écrite ni lue (LYXAL__SECRETS__MASTER_KEY et secrets.master_key_id requis)"
        ),
    }
    let store = SecretsStore::new(client.clone());
    runtime.register_worker(Arc::new(SecretsMaintenanceWorker::new(
        store.clone(),
        master.clone(),
        // Aucun rotateur pour l'instant : les modules qui parlent aux services extérieurs
        // inscriront le leur ; sans rotateur, une rotation due ne donne que le rappel
        RotatorRegistry::new(),
        MAINTENANCE_INTERVAL,
        MAINTENANCE_BATCH,
    )?))?;
    runtime
        .health_registry()
        .register_check(Arc::new(SecretsHealthCheck::new(
            store.clone(),
            master.clone(),
        )))?;
    Ok(SecretsHost { store, master })
}
