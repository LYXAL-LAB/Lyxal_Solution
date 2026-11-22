//! Module `lyxal_secrets` : implémentation `LyxalModule`, trousseau maître du coffre-fort,
//! maintenance (exécutée par `lyxal_scheduler`, tâche `secrets.maintenance` de `modules::tasks`),
//! sonde de santé, et service des routes `/secrets/*`.
//!
//! La clé maîtresse du coffre-fort est propre au coffre-fort (R1), distincte de la clé
//! applicative partagée par `lyxal_auth` et `lyxal_notification` : `LYXAL__SECRETS__MASTER_KEY`
//! (identifiant `secrets.master_key_id`), et pendant une rotation l'ancienne clé en lecture seule
//! (`LYXAL__SECRETS__PREVIOUS_MASTER_KEY`, `secrets.previous_master_key_id`), lues par
//! `lyxal_crypto::EnvironmentKeyProvider`. Sans clé, le serveur démarre, aucune valeur n'est
//! écrite ni lue (`SECRETS_CRYPTO_UNAVAILABLE`) et la sonde le signale (R5).

use crate::config::AppConfig;
use crate::error::ServerError;
use lyxal_host::services::SecretsConfig;
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use lyxal_secrets::{
    FileKeys, MasterKeys, RotatorRegistry, SecretsClient, SecretsHealthCheck, SecretsMaintenance,
    SecretsModule, SecretsService, SecretsStore,
};
use std::sync::Arc;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_secrets::MODULE_ID;

/// Préfixe des variables d'environnement de l'hôte.
const ENV_PREFIX: &str = "LYXAL";
/// Éléments traités par paquet.
const MAINTENANCE_BATCH: u32 = 200;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(SecretsModule::new())
}

/// Ce que l'hôte rend aux modules qui liront leurs secrets et aux routes `/secrets/*` : la
/// session système, le trousseau maître du coffre-fort et les rotateurs inscrits.
#[derive(Clone)]
pub struct SecretsHost {
    store: SecretsStore,
    master: Option<MasterKeys>,
    rotators: RotatorRegistry,
}

impl SecretsHost {
    /// Service du coffre-fort au nom d'un appelant (`caller` : sa session SurrealDB, authentifiée
    /// par son jeton), avec la session système, le trousseau maître et les rotateurs de l'hôte.
    pub fn service(&self, caller: SecretsStore) -> SecretsService {
        SecretsService::new(caller, self.store.clone(), self.master.clone())
            .with_rotators(self.rotators.clone())
    }

    /// Service de l'ouverture d'un lien de partage, qui n'a pas d'appelant : tout passe par la
    /// session système (`SecretsService::share_open` ne sert qu'elle).
    pub fn share_opener(&self) -> SecretsService {
        self.service(self.store.clone())
    }

    /// Client du coffre-fort pour un module hébergé, annoncé comme consommateur (`module`).
    pub fn client(&self, module: &str) -> SecretsClient {
        SecretsClient::new(self.store.clone(), self.master.clone(), module)
    }

    /// Maintenance du coffre-fort (purge, alertes, rotations, rescellement) sur la session
    /// système, avec le trousseau maître et les rotateurs de l'hôte ; exécutée par la tâche
    /// `secrets.maintenance`.
    pub fn maintenance(&self) -> SecretsMaintenance {
        SecretsMaintenance::new(
            self.store.clone(),
            self.master.clone(),
            self.rotators.clone(),
            MAINTENANCE_BATCH,
        )
    }

    /// Clés de fichiers des buckets chiffrés de `lyxal_storage` : scellées par la clé « fichiers »
    /// de chaque organisation, sur la session système et le trousseau maître (absent : aucun
    /// fichier chiffré n'est écrit ni lu).
    pub fn file_keys(&self) -> FileKeys {
        FileKeys::new(self.store.clone(), self.master.clone())
    }

    /// Vrai si la clé maîtresse du coffre-fort est configurée.
    pub fn has_master_key(&self) -> bool {
        self.master.is_some()
    }
}

/// Trousseau maître du coffre-fort (`LYXAL__SECRETS__MASTER_KEY` et, pendant une rotation,
/// `LYXAL__SECRETS__PREVIOUS_MASTER_KEY`) ; `None` sans clé.
pub fn master_keys(config: &SecretsConfig) -> Result<Option<MasterKeys>, ServerError> {
    Ok(lyxal_host::services::master_keys(config, ENV_PREFIX)?)
}

/// Sonde de santé ; rend ce qu'il faut aux modules pour lire leurs secrets et à la maintenance.
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
    // Aucun rotateur pour l'instant : les modules qui parlent aux services extérieurs inscriront
    // le leur ; sans rotateur, une rotation due ne donne que le rappel
    let rotators = RotatorRegistry::new();
    runtime
        .health_registry()
        .register_check(Arc::new(SecretsHealthCheck::new(
            store.clone(),
            master.clone(),
        )))?;
    Ok(SecretsHost {
        store,
        master,
        rotators,
    })
}
