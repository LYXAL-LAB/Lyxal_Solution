//! Octets de la clé applicative de l'hôte (`LYXAL__CRYPTO__APPLICATION_KEY`). Le trousseau
//! applicatif (`lyxal_host::services::application_crypto`, partagé avec `lyxal-groupware`) sert
//! les modules qui scellent des secrets (`lyxal_auth`, `lyxal_notification`).

use crate::error::ServerError;
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use lyxal_crypto::SecretBytes;
use lyxal_host::services::CryptoConfig;

fn configuration_error(field: &str, error: impl std::fmt::Display) -> ServerError {
    ServerError::Configuration {
        message: format!("{field} : {error}"),
    }
}

/// Octets de la clé applicative (32 octets, Base64 canonique), d'où les modules dérivent par HKDF
/// (`lyxal_crypto::hkdf_sha256`) une clé propre à un usage : signature des liens de
/// désabonnement de `lyxal_notification`. `None` si la clé n'est pas fournie.
pub fn application_key_material(config: &CryptoConfig) -> Result<Option<SecretBytes>, ServerError> {
    let Some(key) = &config.application_key else {
        return Ok(None);
    };
    let text = key.to_secret()?;
    let bytes = STANDARD
        .decode(text.expose_secret().trim())
        .map_err(|_| configuration_error("crypto.application_key", "Base64 attendu"))?;
    if bytes.len() != 32 {
        return Err(configuration_error(
            "crypto.application_key",
            "32 octets attendus",
        ));
    }
    SecretBytes::new(bytes)
        .map(Some)
        .map_err(|e| configuration_error("crypto.application_key", e))
}
