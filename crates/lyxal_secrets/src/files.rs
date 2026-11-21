//! Clés des fichiers chiffrés des modules de l'hôte (`FileKeys`).
//!
//! ```text
//! clé maîtresse du coffre-fort
//!    └── clé « fichiers » de l'organisation (secrets_tenant_key, usage files)
//!           └── clé de chaque fichier (StreamKey, tirée par le module qui range le fichier),
//!               scellée ici (enc:v2) et rangée scellée dans la fiche du fichier
//! ```
//!
//! La clé « fichiers » d'une organisation est distincte de sa clé « secrets » : budget de
//! scellements, rotation et cloisonnement séparés. Elle est créée au premier fichier chiffré de
//! l'organisation, reconstruite à chaque appel depuis la base et jamais gardée en mémoire. Le
//! module qui range les fichiers fournit le contexte de scellement (son identité de fiche) ; le
//! coffre-fort ne lit aucune de ses tables : après une rotation, c'est ce module qui rescelle ses
//! clés de fichiers ([`FileKeys::reseal`]) puis dit si une clé retirée sert encore
//! ([`FileKeys::destroy`]).

use lyxal_crypto::{CryptoError, EncryptedEnvelope, SecretContext, StreamKey};
use lyxal_surreal::RecordId;
use std::fmt;

use crate::error::{SecretsError, SecretsResult};
use crate::keys::{MasterKeys, Scope, TenantKeys, TenantRing};
use crate::models::{KeyPurpose, RetiredKey, TenantKeyDestroyParams, TenantKeyRetiredParams};
use crate::store::SecretsStore;

/// Clé d'un fichier scellée par la clé « fichiers » de son organisation (enveloppe `enc:v2`).
/// Illisible sans le coffre-fort ; `Debug` masqué.
#[derive(Clone, PartialEq, Eq)]
pub struct SealedFileKey {
    envelope: String,
    key_id: String,
}

impl SealedFileKey {
    /// Clé scellée lue dans la fiche d'un fichier ; une enveloppe mal formée est
    /// `SECRETS_VALUE_CORRUPTED`.
    pub fn parse(envelope: &str) -> SecretsResult<Self> {
        let parsed =
            EncryptedEnvelope::parse(envelope).map_err(|_| SecretsError::ValueCorrupted)?;
        Ok(Self::from_envelope(&parsed))
    }

    fn from_envelope(envelope: &EncryptedEnvelope) -> Self {
        Self {
            envelope: envelope.encode(),
            key_id: envelope.key_id().as_str().to_string(),
        }
    }

    /// Enveloppe `enc:v2`, à ranger dans la fiche du fichier.
    pub fn as_str(&self) -> &str {
        &self.envelope
    }

    /// Clé « fichiers » de l'organisation qui la scelle.
    pub fn key_id(&self) -> &str {
        &self.key_id
    }
}

impl fmt::Debug for SealedFileKey {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("SealedFileKey")
            .field("key_id", &self.key_id)
            .field("envelope", &"[REDACTED]")
            .finish()
    }
}

/// Scellement et ouverture des clés de fichiers, sur la session système de l'hôte et le
/// trousseau maître du coffre-fort.
#[derive(Clone)]
pub struct FileKeys {
    keys: TenantKeys,
}

impl FileKeys {
    /// Clés de fichiers sur la session système (`system`) et le trousseau maître (absent : rien
    /// ne se scelle ni ne s'ouvre, `SECRETS_CRYPTO_UNAVAILABLE`).
    pub fn new(system: SecretsStore, master: Option<MasterKeys>) -> Self {
        Self {
            keys: TenantKeys::new(system, master, KeyPurpose::Files),
        }
    }

    /// Vrai si la clé maîtresse du coffre-fort est présente.
    pub fn is_available(&self) -> bool {
        self.keys.master().is_ok()
    }

    /// Organisation du contexte de scellement d'une portée : la clé de l'organisation
    /// (`auth_organization:<clé>`), ou `lyxal_installation` pour l'installation. Le module qui
    /// range les fichiers s'en sert comme organisation de son `SecretContext`.
    pub fn context_tenant(tenant: Option<&RecordId>) -> SecretsResult<String> {
        Ok(Scope::from_record(tenant)?.context_tenant().to_string())
    }

    /// Clé d'un fichier scellée par la clé « fichiers » active de l'organisation (`None` :
    /// l'installation), créée au premier fichier.
    pub async fn seal(
        &self,
        tenant: Option<&RecordId>,
        key: &StreamKey,
        context: &SecretContext,
    ) -> SecretsResult<SealedFileKey> {
        let ring = self.keys.active_ring(&Scope::from_record(tenant)?).await?;
        let sealed = key.seal(ring.engine(), context)?;
        Ok(SealedFileKey::from_envelope(&sealed))
    }

    /// Clé d'un fichier ouverte. Clé « fichiers » détruite ou absente :
    /// `SECRETS_TENANT_KEY_UNAVAILABLE` ; enveloppe altérée, recopiée d'un autre fichier ou d'une
    /// autre organisation : `SECRETS_VALUE_CORRUPTED`.
    pub async fn open(
        &self,
        tenant: Option<&RecordId>,
        sealed: &SealedFileKey,
        context: &SecretContext,
    ) -> SecretsResult<StreamKey> {
        let ring = self.ring(tenant).await?;
        let envelope =
            EncryptedEnvelope::parse(&sealed.envelope).map_err(|_| SecretsError::ValueCorrupted)?;
        StreamKey::open(ring.engine(), &envelope, context).map_err(|error| match error {
            CryptoError::KeyUnavailable | CryptoError::KeyRevoked => {
                SecretsError::TenantKeyUnavailable(format!("clé {} absente", sealed.key_id))
            }
            _ => SecretsError::ValueCorrupted,
        })
    }

    /// Clé d'un fichier rescellée par la clé « fichiers » active de son organisation ; `None` si
    /// elle l'est déjà. L'enveloppe est authentifiée dans tous les cas.
    pub async fn reseal(
        &self,
        tenant: Option<&RecordId>,
        sealed: &SealedFileKey,
        context: &SecretContext,
    ) -> SecretsResult<Option<SealedFileKey>> {
        let ring = self.ring(tenant).await?;
        Ok(ring
            .reencrypt(&sealed.envelope, context)?
            .map(|envelope| SealedFileKey::from_envelope(&envelope)))
    }

    /// Clés « fichiers » retirées par une rotation, de la plus anciennement retirée à la plus
    /// récente (`start` : clés en échec à passer).
    pub async fn retired(&self, limit: u32, start: u32) -> SecretsResult<Vec<RetiredKey>> {
        Ok(self
            .keys
            .system()
            .tenant_key_retired(TenantKeyRetiredParams {
                purpose: KeyPurpose::Files,
                limit: i64::from(limit.clamp(1, 1000)),
                start: i64::from(start),
            })
            .await?
            .items)
    }

    /// Détruit une clé « fichiers » retirée, quand le module qui range les fichiers dit qu'elle
    /// ne sert plus (`in_use` faux). Vrai si elle est détruite ; une clé encore utilisée est
    /// `SECRETS_TENANT_KEY_CONFLICT`.
    pub async fn destroy(&self, key_id: &str, in_use: bool) -> SecretsResult<bool> {
        Ok(self
            .keys
            .system()
            .tenant_key_destroy(TenantKeyDestroyParams {
                key_id: key_id.to_string(),
                in_use: Some(in_use),
            })
            .await?
            .destroyed)
    }

    async fn ring(&self, tenant: Option<&RecordId>) -> SecretsResult<TenantRing> {
        self.keys
            .ring(&Scope::from_record(tenant)?)
            .await?
            .ok_or_else(|| {
                SecretsError::TenantKeyUnavailable(
                    "aucune clé « fichiers » pour cette portée".to_string(),
                )
            })
    }
}

impl fmt::Debug for FileKeys {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("FileKeys")
            .field("available", &self.is_available())
            .finish()
    }
}
