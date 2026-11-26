//! Module `lyxal_auth` : implémentation `LyxalModule`, sonde de santé, purge (exécutée par
//! `lyxal_scheduler`, tâche `auth.purge` de `modules::tasks`) et service de connexion de l'hôte
//! (routes `/auth/*`).
//!
//! Le service de connexion demande la clé applicative (`LYXAL__CRYPTO__APPLICATION_KEY` :
//! clés de signature, empreintes de mots de passe et secrets des messages scellés) et
//! `auth.public_url` (liens des messages). Au démarrage, après l'installation des modules, les
//! clés absentes sont créées et les accès SurrealDB `lyxal_auth_a|b` définis.

use crate::config::AppConfig;
use crate::error::ServerError;
use lyxal_auth::{
    AccessConfig, AccessService, AuthHealthCheck, AuthModule, AuthPurge, AuthStore,
    SigningKeyService,
};
use lyxal_crypto::{CryptoEngine, StaticKeyResolver};
use lyxal_host::database::Database;
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;

pub const MODULE_ID: &str = lyxal_auth::MODULE_ID;

/// Éléments purgés par paquet.
const PURGE_BATCH: i64 = 500;

pub fn module() -> Arc<dyn LyxalModule> {
    Arc::new(AuthModule::new())
}

/// Service de connexion de l'hôte, sur sa session système.
pub struct AuthHost {
    pub access: AccessService<StaticKeyResolver>,
    pub keys: Arc<SigningKeyService<StaticKeyResolver>>,
}

/// Purge de `lyxal_auth` sur la session système de l'hôte, exécutée par la tâche `auth.purge`.
pub fn purge(database: &Database) -> AuthPurge {
    AuthPurge::new(AuthStore::new(database.clone()), PURGE_BATCH)
}

/// Sonde et, si la clé applicative et `auth.public_url` sont fournies, service de connexion.
pub fn register_services(
    runtime: &LyxalRuntime,
    database: &Database,
    config: &AppConfig,
    crypto: Option<Arc<CryptoEngine<StaticKeyResolver>>>,
) -> Result<Option<Arc<AuthHost>>, ServerError> {
    let store = AuthStore::new(database.clone());
    let host = host(database, config, crypto)?;
    let disabled = host.is_none().then(|| {
        "connexion désactivée : LYXAL__CRYPTO__APPLICATION_KEY et auth.public_url requis"
            .to_string()
    });
    if let Some(reason) = &disabled {
        tracing::warn!("{reason}");
    }
    runtime
        .health_registry()
        .register_check(Arc::new(AuthHealthCheck::new(store, disabled)))?;
    Ok(host)
}

/// Service de connexion sur la session système, si la clé applicative et `auth.public_url` sont
/// fournies (routes `/auth/*` et commandes d'administration).
pub fn host(
    database: &Database,
    config: &AppConfig,
    crypto: Option<Arc<CryptoEngine<StaticKeyResolver>>>,
) -> Result<Option<Arc<AuthHost>>, ServerError> {
    let (Some(crypto), Some(public_url)) = (crypto, config.auth.public_url.clone()) else {
        return Ok(None);
    };
    let store = AuthStore::new(database.clone());
    let keys = Arc::new(SigningKeyService::new(store.clone(), crypto.clone()));
    let access = AccessService::new(
        store,
        crypto,
        keys.clone(),
        AccessConfig {
            namespace: config.database.namespace.clone(),
            database: config.database.database.clone(),
            public_url: public_url.trim_end_matches('/').to_string(),
            issuer: config.application.name.clone(),
            passkey_rp_id: config.auth.passkey_rp_id.clone(),
        },
    )
    .map_err(|error| ServerError::Configuration {
        message: format!("auth.public_url : {error}"),
    })?;
    Ok(Some(Arc::new(AuthHost { access, keys })))
}

/// Après l'installation des modules : clés créées si absentes, accès SurrealDB définis.
pub async fn complete_services(host: Option<&Arc<AuthHost>>) -> Result<(), ServerError> {
    if let Some(host) = host {
        host.keys
            .ensure()
            .await
            .map_err(|error| ServerError::Database {
                message: format!("clés de lyxal_auth : {} ({error})", error.code()),
            })?;
    }
    Ok(())
}
