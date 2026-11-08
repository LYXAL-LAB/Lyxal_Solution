//! Trousseau applicatif de l'hôte : une clé AES-256 active, lue par
//! `lyxal_crypto::EnvironmentKeyProvider` dans `LYXAL__CRYPTO__APPLICATION_KEY`. Partagé par les
//! modules qui scellent des secrets (`lyxal_auth`, `lyxal_notification`).

use crate::config::CryptoConfig;
use crate::error::ServerError;
use lyxal_crypto::{
    CryptoEngine, EnvironmentKeyProvider, KeyId, KeyRingBuilder, KeyUse, StaticKeyResolver,
};
use std::sync::Arc;

/// Variable d'environnement de la clé applicative.
const APPLICATION_KEY_VAR: &str = "LYXAL__CRYPTO__APPLICATION_KEY";

fn configuration_error(field: &str, error: impl std::fmt::Display) -> ServerError {
    ServerError::Configuration {
        message: format!("{field} : {error}"),
    }
}

/// Trousseau applicatif : une clé active lue par `EnvironmentKeyProvider`. `None` si la clé n'est
/// pas fournie ; une clé fournie mais invalide (ou sans identifiant) arrête le démarrage.
pub fn application_crypto(
    config: &CryptoConfig,
) -> Result<Option<Arc<CryptoEngine<StaticKeyResolver>>>, ServerError> {
    if config.application_key.is_none() {
        return Ok(None);
    }
    let id = config
        .application_key_id
        .as_deref()
        .ok_or_else(|| configuration_error("crypto.application_key_id", "obligatoire avec la clé"))
        .and_then(|id| {
            KeyId::parse(id).map_err(|e| configuration_error("crypto.application_key_id", e))
        })?;
    let key = EnvironmentKeyProvider::load(APPLICATION_KEY_VAR, id)
        .map_err(|e| configuration_error("crypto.application_key", e))?;
    let mut builder = KeyRingBuilder::new();
    builder
        .insert_resolved(key, KeyUse::Active)
        .map_err(|e| configuration_error("crypto.application_key", e))?;
    let ring = builder
        .build()
        .map_err(|e| configuration_error("crypto.application_key", e))?;
    Ok(Some(Arc::new(CryptoEngine::new(StaticKeyResolver::new(
        Arc::new(ring),
    )))))
}
