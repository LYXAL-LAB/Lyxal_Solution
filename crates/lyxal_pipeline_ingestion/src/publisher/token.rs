//! Jeton de service de l'agent de synchronisation du catalogue.
//!
//! Le catalogue n'accepte un article maître que d'une identité `catalogue_sync_agent`
//! (claims `iss = lyxal-os`, `aud = lyxal-catalogue`, scope `catalogue:sync:write`). L'hôte
//! définit l'accès JWT correspondant (`DEFINE ACCESS ... TYPE JWT ALGORITHM HS256`) avec la clé
//! lue dans sa configuration, et confie la même clé à [`HmacCatalogueTokenIssuer`] qui signe un
//! jeton court pour chaque publication (HS256 par `lyxal_crypto::hmac`).

use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine;
use lyxal_crypto::{sign_hmac_sha256, HmacKey, SecretBytes, SecretString};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use crate::error::{IngestionError, IngestionResult};

/// Émetteur des claims exigé par le catalogue pour l'agent de synchronisation.
pub const CATALOGUE_SYNC_ISSUER: &str = "lyxal-os";
/// Audience des jetons du catalogue.
pub const CATALOGUE_SYNC_AUDIENCE: &str = "lyxal-catalogue";
/// Rôle de l'agent de synchronisation.
pub const CATALOGUE_SYNC_ROLE: &str = "catalogue_sync_agent";
/// Périmètre d'écriture des articles maîtres.
pub const CATALOGUE_SYNC_SCOPE: &str = "catalogue:sync:write";
/// Sujet du jeton, enregistré comme auteur des transitions de manifeste.
pub const CATALOGUE_SYNC_SUBJECT: &str = "service:catalogue_sync";
/// Longueur exacte de la clé de signature (32 octets, caractères `A-Z a-z 0-9 _ -`).
pub const CATALOGUE_SYNC_KEY_LENGTH: usize = 32;

/// Fournit un jeton de service frais à chaque publication.
pub trait CatalogueTokenIssuer: Send + Sync {
    /// Jeton signé, valable pendant une durée courte.
    fn issue(&self) -> IngestionResult<SecretString>;
}

/// Clé de signature partagée entre l'accès JWT de la base et l'émetteur des jetons.
///
/// Exactement [`CATALOGUE_SYNC_KEY_LENGTH`] caractères `A-Z a-z 0-9 _ -` : ces octets sont la
/// clé HMAC (32 octets) et la valeur `KEY` de l'accès SurrealDB, sans conversion ni caractère à
/// échapper.
pub struct CatalogueSyncKey {
    text: SecretString,
}

impl CatalogueSyncKey {
    /// Contrôle la forme de la clé fournie par la configuration de l'hôte.
    pub fn parse(text: SecretString) -> IngestionResult<Self> {
        let value = text.expose_secret();
        let well_formed = value.len() == CATALOGUE_SYNC_KEY_LENGTH
            && value
                .bytes()
                .all(|b| b.is_ascii_alphanumeric() || b == b'_' || b == b'-');
        if !well_formed {
            return Err(IngestionError::Validation(format!(
                "Clé de signature du jeton de synchronisation : {CATALOGUE_SYNC_KEY_LENGTH} caractères A-Z, a-z, 0-9, « _ » ou « - » attendus"
            )));
        }
        Ok(Self { text })
    }

    /// Valeur de la clé, pour la définition de l'accès JWT par l'hôte.
    pub fn expose_secret(&self) -> &str {
        self.text.expose_secret()
    }

    fn hmac_key(&self) -> IngestionResult<HmacKey> {
        let bytes =
            SecretBytes::new(self.text.expose_secret().as_bytes().to_vec()).map_err(|e| {
                IngestionError::Validation(format!(
                    "Clé de signature du jeton de synchronisation : {e}"
                ))
            })?;
        HmacKey::import(bytes).map_err(|e| {
            IngestionError::Validation(format!(
                "Clé de signature du jeton de synchronisation : {e}"
            ))
        })
    }
}

impl std::fmt::Debug for CatalogueSyncKey {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("CatalogueSyncKey([REDACTED])")
    }
}

/// Signe des jetons HS256 `catalogue_sync_agent` pour l'accès JWT défini par l'hôte.
pub struct HmacCatalogueTokenIssuer {
    key: HmacKey,
    namespace: String,
    database: String,
    access: String,
    ttl: Duration,
}

impl HmacCatalogueTokenIssuer {
    /// Émetteur pour l'accès `access` de `namespace` / `database`, jetons valables `ttl`.
    pub fn new(
        key: &CatalogueSyncKey,
        namespace: impl Into<String>,
        database: impl Into<String>,
        access: impl Into<String>,
        ttl: Duration,
    ) -> IngestionResult<Self> {
        Ok(Self {
            key: key.hmac_key()?,
            namespace: namespace.into(),
            database: database.into(),
            access: access.into(),
            ttl,
        })
    }
}

impl CatalogueTokenIssuer for HmacCatalogueTokenIssuer {
    fn issue(&self) -> IngestionResult<SecretString> {
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|e| IngestionError::Validation(format!("Horloge système invalide : {e}")))?
            .as_secs();
        let header = serde_json::json!({ "alg": "HS256", "typ": "JWT" });
        let claims = serde_json::json!({
            "iss": CATALOGUE_SYNC_ISSUER,
            "aud": CATALOGUE_SYNC_AUDIENCE,
            "sub": CATALOGUE_SYNC_SUBJECT,
            "role": CATALOGUE_SYNC_ROLE,
            "scope": [CATALOGUE_SYNC_SCOPE],
            "ns": self.namespace,
            "db": self.database,
            "ac": self.access,
            "iat": now,
            "nbf": now,
            "exp": now + self.ttl.as_secs(),
            "jti": uuid::Uuid::now_v7().to_string(),
        });
        let signing_input = format!(
            "{}.{}",
            URL_SAFE_NO_PAD.encode(header.to_string()),
            URL_SAFE_NO_PAD.encode(claims.to_string())
        );
        let signature = sign_hmac_sha256(&self.key, signing_input.as_bytes()).map_err(|e| {
            IngestionError::Validation(format!("Signature du jeton de synchronisation : {e}"))
        })?;
        SecretString::new(format!(
            "{signing_input}.{}",
            URL_SAFE_NO_PAD.encode(signature)
        ))
        .map_err(|e| IngestionError::Validation(format!("Jeton de synchronisation : {e}")))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn key(text: &str) -> IngestionResult<CatalogueSyncKey> {
        CatalogueSyncKey::parse(
            SecretString::new(text.to_string())
                .map_err(|e| IngestionError::Validation(e.to_string()))?,
        )
    }

    #[test]
    fn key_shape_is_checked() {
        assert!(key("abcdefghijklmnopqrstuvwxyz012345").is_ok());
        assert!(key("trop-courte").is_err());
        assert!(key("abcdefghijklmnopqrstuvwxyz01234\"").is_err());
    }

    #[test]
    fn token_carries_catalogue_claims() -> IngestionResult<()> {
        let issuer = HmacCatalogueTokenIssuer::new(
            &key("abcdefghijklmnopqrstuvwxyz012345")?,
            "lyxal",
            "main",
            "lyxal_catalogue_sync",
            Duration::from_secs(300),
        )?;
        let token = issuer.issue()?;
        let parts: Vec<&str> = token.expose_secret().split('.').collect();
        assert_eq!(parts.len(), 3);
        let claims: serde_json::Value = serde_json::from_slice(
            &URL_SAFE_NO_PAD
                .decode(parts[1])
                .map_err(|e| IngestionError::Validation(e.to_string()))?,
        )
        .map_err(|e| IngestionError::Validation(e.to_string()))?;
        assert_eq!(claims["iss"], CATALOGUE_SYNC_ISSUER);
        assert_eq!(claims["aud"], CATALOGUE_SYNC_AUDIENCE);
        assert_eq!(claims["role"], CATALOGUE_SYNC_ROLE);
        assert_eq!(claims["scope"][0], CATALOGUE_SYNC_SCOPE);
        assert_eq!(claims["ac"], "lyxal_catalogue_sync");
        assert_eq!(
            claims["exp"].as_u64().unwrap_or_default() - claims["iat"].as_u64().unwrap_or_default(),
            300
        );
        Ok(())
    }
}
