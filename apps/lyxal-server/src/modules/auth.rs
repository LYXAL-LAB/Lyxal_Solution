//! Module `lyxal_auth` : implémentation `LyxalModule`, sonde de santé, worker de purge et
//! service de connexion de l'hôte (routes `/auth/*`).
//!
//! Le service de connexion demande la clé applicative (`LYXAL__CRYPTO__APPLICATION_KEY` :
//! clés de signature, empreintes de mots de passe et secrets des messages scellés) et
//! `auth.public_url` (liens des messages). Au démarrage, après l'installation des modules, les
//! clés absentes sont créées et les accès SurrealDB `lyxal_auth_a|b` définis.

use crate::config::AppConfig;
use crate::error::ServerError;
use lyxal_auth::{
    AccessConfig, AccessService, AuthHealthCheck, AuthModule, AuthPurgeWorker, AuthStore,
    SigningKeyService,
};
use lyxal_crypto::{CryptoEngine, StaticKeyResolver};
use lyxal_runtime::{LyxalModule, LyxalRuntime};
use std::sync::Arc;
use std::time::Duration;
use surrealdb::engine::any::Any;
use surrealdb::Surreal;

pub const MODULE_ID: &str = lyxal_auth::MODULE_ID;

/// Intervalle de la purge.
const PURGE_INTERVAL: Duration = Duration::from_secs(900);
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

/// Sonde, purge et, si la clé applicative et `auth.public_url` sont fournies, service de connexion.
pub fn register_services(
    runtime: &LyxalRuntime,
    client: &Surreal<Any>,
    config: &AppConfig,
    crypto: Option<Arc<CryptoEngine<StaticKeyResolver>>>,
) -> Result<Option<Arc<AuthHost>>, ServerError> {
    let store = AuthStore::new(client.clone());
    runtime.register_worker(Arc::new(AuthPurgeWorker::new(
        store.clone(),
        PURGE_INTERVAL,
        PURGE_BATCH,
    )?))?;
    let host = host(client, config, crypto)?;
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
    client: &Surreal<Any>,
    config: &AppConfig,
    crypto: Option<Arc<CryptoEngine<StaticKeyResolver>>>,
) -> Result<Option<Arc<AuthHost>>, ServerError> {
    let (Some(crypto), Some(public_url)) = (crypto, config.auth.public_url.clone()) else {
        return Ok(None);
    };
    let store = AuthStore::new(client.clone());
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
