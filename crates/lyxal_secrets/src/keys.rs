//! Clés du coffre-fort.
//!
//! ```text
//! clé maîtresse du coffre-fort (MasterKeys : active, et l'ancienne en lecture seule pendant une rotation)
//!    └── clés de chaque organisation, une par usage : 32 octets tirés par rand_core::OsRng dans
//!        un SecretBytes, scellés par la clé maîtresse et rangés dans secrets_tenant_key
//!           ├── usage « secrets » : chaque version d'un secret
//!           └── usage « files » : la clé de chaque fichier chiffré d'un module de l'hôte (FileKeys)
//! ```
//!
//! Le trousseau d'une organisation pour un usage est reconstruit à chaque opération
//! (`EncryptionKey::import`, `KeyRingBuilder`, `StaticKeyResolver`, `CryptoEngine`) depuis ses
//! clés `active` et `decrypt_only`, ouvertes par la clé maîtresse : aucune clé d'organisation
//! n'est gardée en mémoire au-delà de l'opération, sauf par le cache facultatif des clés
//! « fichiers » (`FileKeys::with_cache`, 60 s au plus, pour ouvrir seulement).

use lyxal_crypto::{
    CryptoEngine, CryptoError, EncryptedEnvelope, EncryptionKey, KeyId, KeyRing, KeyRingBuilder,
    KeyState, KeyUse, ReencryptResult, ResolvedKey, SecretBytes, SecretContext, StaticKeyResolver,
    StreamKey,
};
use lyxal_surreal::{RecordId, ToSql};
use rand_core::{OsRng, RngCore};
use std::fmt;
use std::sync::Arc;
use surrealdb::types::RecordIdKey;

use crate::error::{SecretsError, SecretsResult};
use crate::models::{
    KeyPurpose, RewrapKey, TenantKeyCreateParams, TenantKeyCreated, TenantKeyRingParams,
    TenantKeyState,
};
use crate::module::MODULE_ID;
use crate::store::SecretsStore;

/// Organisation du contexte de scellement d'une valeur ou d'une clé de l'installation.
const INSTALLATION_CONTEXT: &str = "lyxal_installation";
/// Table des organisations (`lyxal_auth`).
const ORGANIZATION_TABLE: &str = "auth_organization";
/// Ressource du contexte de scellement d'une clé d'organisation.
const TENANT_KEY_RESOURCE: &str = "secrets_tenant_key";
/// Ressource du contexte de scellement d'une copie partagée.
const SHARE_RESOURCE: &str = "secrets_share";
/// Ressource du contexte de scellement d'une version.
const VERSION_RESOURCE: &str = "secrets_version";
/// Longueur d'une clé d'organisation (AES-256).
const KEY_BYTES: usize = 32;

/// Trousseau maître du coffre-fort : une clé active et, pendant une rotation, l'ancienne en
/// lecture seule. Distinct de la clé applicative de l'hôte (R1).
#[derive(Clone)]
pub struct MasterKeys {
    ring: Arc<KeyRing>,
    engine: Arc<CryptoEngine<StaticKeyResolver>>,
    previous: Option<KeyId>,
}

impl MasterKeys {
    /// Trousseau de la clé active et, s'il y en a une, de l'ancienne clé (lecture seule, le
    /// temps que la maintenance rescelle les clés des organisations).
    pub fn from_keys(active: ResolvedKey, previous: Option<ResolvedKey>) -> SecretsResult<Self> {
        let previous_id = previous.as_ref().map(|key| key.id().clone());
        let mut builder = KeyRingBuilder::new();
        builder.insert_resolved(active, KeyUse::Active)?;
        if let Some(previous) = previous {
            builder.insert_resolved(previous, KeyUse::DecryptOnly)?;
        }
        let ring = Arc::new(builder.build()?);
        Ok(Self {
            engine: Arc::new(CryptoEngine::new(StaticKeyResolver::new(ring.clone()))),
            ring,
            previous: previous_id,
        })
    }

    /// Identifiant de la clé maîtresse active.
    pub fn active_id(&self) -> &KeyId {
        self.ring.active_id()
    }

    /// Identifiant de l'ancienne clé maîtresse, fournie pendant une rotation.
    pub fn previous_id(&self) -> Option<&KeyId> {
        self.previous.as_ref()
    }

    /// Vrai si cette clé maîtresse (identifiant) est dans le trousseau.
    pub fn knows(&self, key_id: &str) -> bool {
        KeyId::parse(key_id)
            .ok()
            .and_then(|id| self.ring.state(&id))
            .is_some_and(|state| state != KeyState::Revoked)
    }
}

impl fmt::Debug for MasterKeys {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("MasterKeys")
            .field("active", self.active_id())
            .field("previous", &self.previous)
            .field("keys", &"[REDACTED]")
            .finish()
    }
}

/// Texte de la clé d'un enregistrement (`record::id` côté SurrealQL).
pub(crate) fn record_key(record: &RecordId) -> SecretsResult<String> {
    match &record.key {
        RecordIdKey::String(key) => Ok(key.clone()),
        RecordIdKey::Number(key) => Ok(key.to_string()),
        _ => Err(SecretsError::InvalidRecord(record.to_sql())),
    }
}

/// Portée d'une clé ou d'une valeur : une organisation ou l'installation.
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub(crate) struct Scope {
    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    tenant: Option<String>,
    /// Organisation du contexte de scellement (`<clé>` ou `lyxal_installation`).
    context: String,
}

impl Scope {
    /// Portée d'une organisation (identifiant natif), ou de l'installation.
    pub(crate) fn from_record(tenant: Option<&RecordId>) -> SecretsResult<Self> {
        match tenant {
            None => Ok(Self::installation()),
            Some(record) => Ok(Self {
                tenant: Some(record.to_sql()),
                context: record_key(record)?,
            }),
        }
    }

    /// Portée d'une organisation (`auth_organization:<clé>`), ou de l'installation.
    pub(crate) fn from_text(tenant: Option<&str>) -> SecretsResult<Self> {
        let Some(text) = tenant else {
            return Ok(Self::installation());
        };
        let record = RecordId::parse_simple(text)
            .map_err(|_| SecretsError::InvalidRecord(text.to_string()))?;
        if record.table.as_str() != ORGANIZATION_TABLE {
            return Err(SecretsError::InvalidRecord(text.to_string()));
        }
        Self::from_record(Some(&record))
    }

    /// Portée d'après l'organisation d'un contexte de scellement.
    pub(crate) fn from_context(context: &str) -> SecretsResult<Self> {
        if context == INSTALLATION_CONTEXT {
            return Ok(Self::installation());
        }
        Self::from_record(Some(&RecordId::new(
            ORGANIZATION_TABLE,
            context.to_string(),
        )))
    }

    fn installation() -> Self {
        Self {
            tenant: None,
            context: INSTALLATION_CONTEXT.to_string(),
        }
    }

    /// Organisation (`auth_organization:<clé>`), absente pour l'installation.
    pub(crate) fn tenant(&self) -> Option<&str> {
        self.tenant.as_deref()
    }

    fn ring_params(&self, purpose: KeyPurpose) -> TenantKeyRingParams {
        TenantKeyRingParams {
            tenant: self.tenant.clone(),
            purpose,
        }
    }

    /// Organisation du contexte de scellement (`<clé>` ou `lyxal_installation`).
    pub(crate) fn context_tenant(&self) -> &str {
        &self.context
    }

    /// Contexte de scellement d'une version (`<clé du secret>:<numéro>`).
    pub(crate) fn version_context(
        &self,
        secret: &RecordId,
        number: i64,
    ) -> SecretsResult<SecretContext> {
        let record = format!("{}:{number}", record_key(secret)?);
        Ok(SecretContext::with_tenant(
            &self.context,
            MODULE_ID,
            VERSION_RESOURCE,
            &record,
            "value",
        )?)
    }

    /// Contexte de scellement de la copie d'un partage par la clé de son lien : l'enregistrement
    /// est désigné par l'empreinte de cette clé (voir `SecretsService::share_create`).
    pub(crate) fn share_context(&self, fingerprint: &str) -> SecretsResult<SecretContext> {
        Ok(SecretContext::with_tenant(
            &self.context,
            MODULE_ID,
            SHARE_RESOURCE,
            fingerprint,
            "value",
        )?)
    }

    /// Contexte de scellement d'une clé d'organisation par la clé maîtresse : le champ nomme
    /// l'usage (`key_secrets`, `key_files`), une clé rangée sous un usage ne s'ouvre pas sous un
    /// autre.
    fn key_context(&self, key_id: &str, purpose: KeyPurpose) -> SecretsResult<SecretContext> {
        Ok(SecretContext::with_tenant(
            &self.context,
            MODULE_ID,
            TENANT_KEY_RESOURCE,
            key_id,
            &format!("key_{}", purpose.as_str()),
        )?)
    }

    /// Nouvel identifiant de clé : portée, usage des clés « fichiers » et 64 bits aléatoires
    /// (`[A-Za-z0-9._-]{1,64}`).
    fn new_key_id(&self, purpose: KeyPurpose) -> SecretsResult<KeyId> {
        let mut random = [0u8; 8];
        OsRng
            .try_fill_bytes(&mut random)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        let label: String = self.context.chars().take(40).collect();
        let usage = match purpose {
            KeyPurpose::Secrets => "",
            KeyPurpose::Files => "files-",
        };
        Ok(KeyId::parse(&format!(
            "{label}-{usage}{:016x}",
            u64::from_be_bytes(random)
        ))?)
    }
}

/// Clé d'une organisation ouverte par la clé maîtresse.
pub(crate) struct OpenedKey {
    pub(crate) id: KeyId,
    pub(crate) material: SecretBytes,
    pub(crate) state: TenantKeyState,
}

/// Ouverture seule par une clé d'organisation déjà ouverte (clé gardée en mémoire par
/// `FileKeys`) : n'offre aucun scellement, quel que soit l'état de la clé.
pub(crate) struct KeyOpener {
    engine: CryptoEngine<StaticKeyResolver>,
}

impl KeyOpener {
    /// Ouvreur de la clé `id`. `KeyRing` exige une clé active : la clé y est seule, et ce type
    /// ne scelle jamais.
    pub(crate) fn new(id: KeyId, material: SecretBytes) -> SecretsResult<Self> {
        let label = id.as_str().to_string();
        let imported = EncryptionKey::import(material)
            .map_err(|_| SecretsError::TenantKeyUnavailable(format!("clé {label} illisible")))?;
        let mut builder = KeyRingBuilder::new();
        builder.insert(id, imported, KeyUse::Active)?;
        Ok(Self {
            engine: CryptoEngine::new(StaticKeyResolver::new(Arc::new(builder.build()?))),
        })
    }

    /// Clé d'un fichier ouverte par cette clé.
    pub(crate) fn open_stream_key(
        &self,
        envelope: &EncryptedEnvelope,
        context: &SecretContext,
    ) -> Result<StreamKey, CryptoError> {
        StreamKey::open(&self.engine, envelope, context)
    }
}

/// Trousseau d'une organisation, le temps d'une opération.
pub(crate) struct TenantRing {
    engine: CryptoEngine<StaticKeyResolver>,
    active: KeyId,
}

impl TenantRing {
    /// Trousseau des clés ouvertes d'une portée ; `None` sans clé ; une portée sans clé active
    /// est `TenantKeyUnavailable`.
    pub(crate) fn from_keys(keys: Vec<OpenedKey>) -> SecretsResult<Option<Self>> {
        if keys.is_empty() {
            return Ok(None);
        }
        let mut builder = KeyRingBuilder::new();
        let mut active = None;
        for key in keys {
            let label = key.id.as_str().to_string();
            let imported = EncryptionKey::import(key.material).map_err(|_| {
                SecretsError::TenantKeyUnavailable(format!("clé {label} illisible"))
            })?;
            let use_ = match key.state {
                TenantKeyState::Active => {
                    active = Some(key.id.clone());
                    KeyUse::Active
                }
                TenantKeyState::DecryptOnly => KeyUse::DecryptOnly,
            };
            builder.insert(key.id, imported, use_)?;
        }
        let active = active
            .ok_or_else(|| SecretsError::TenantKeyUnavailable("aucune clé active".to_string()))?;
        Ok(Some(Self {
            engine: CryptoEngine::new(StaticKeyResolver::new(Arc::new(builder.build()?))),
            active,
        }))
    }

    /// Clé active de l'organisation.
    pub(crate) fn active_id(&self) -> &KeyId {
        &self.active
    }

    /// Moteur du trousseau (clés de fichiers : `StreamKey::seal`, `StreamKey::open`).
    pub(crate) fn engine(&self) -> &CryptoEngine<StaticKeyResolver> {
        &self.engine
    }

    /// Valeur scellée par la clé active.
    pub(crate) fn seal(
        &self,
        value: &SecretBytes,
        context: &SecretContext,
    ) -> SecretsResult<EncryptedEnvelope> {
        Ok(self.engine.seal(value, context)?)
    }

    /// Valeur ouverte ; une enveloppe qui ne s'ouvre pas (altérée, recopiée d'un autre secret,
    /// d'une autre version ou d'une autre organisation) est `ValueCorrupted`.
    pub(crate) fn open(
        &self,
        envelope: &str,
        context: &SecretContext,
    ) -> SecretsResult<SecretBytes> {
        let envelope =
            EncryptedEnvelope::parse(envelope).map_err(|_| SecretsError::ValueCorrupted)?;
        self.engine
            .open(&envelope, context)
            .map_err(|_| SecretsError::ValueCorrupted)
    }

    /// Enveloppe rescellée par la clé active si elle ne l'est pas déjà (authentifiée dans tous
    /// les cas).
    pub(crate) fn reencrypt(
        &self,
        envelope: &str,
        context: &SecretContext,
    ) -> SecretsResult<Option<EncryptedEnvelope>> {
        let envelope =
            EncryptedEnvelope::parse(envelope).map_err(|_| SecretsError::ValueCorrupted)?;
        match self
            .engine
            .reencrypt_if_needed(&envelope, context)
            .map_err(|_| SecretsError::ValueCorrupted)?
        {
            ReencryptResult::Current => Ok(None),
            ReencryptResult::Rotated(sealed) => Ok(Some(sealed)),
        }
    }
}

impl fmt::Debug for TenantRing {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("TenantRing")
            .field("active", &self.active)
            .field("keys", &"[REDACTED]")
            .finish()
    }
}

/// Clés des organisations pour un usage, lues et écrites par la session système.
#[derive(Clone)]
pub(crate) struct TenantKeys {
    system: SecretsStore,
    master: Option<MasterKeys>,
    purpose: KeyPurpose,
}

impl TenantKeys {
    pub(crate) fn new(
        system: SecretsStore,
        master: Option<MasterKeys>,
        purpose: KeyPurpose,
    ) -> Self {
        Self {
            system,
            master,
            purpose,
        }
    }

    /// Mêmes session et clé maîtresse, pour un autre usage.
    pub(crate) fn for_purpose(&self, purpose: KeyPurpose) -> Self {
        Self {
            system: self.system.clone(),
            master: self.master.clone(),
            purpose,
        }
    }

    /// Store de la session système.
    pub(crate) fn system(&self) -> &SecretsStore {
        &self.system
    }

    /// Trousseau maître ; sans lui, aucune valeur n'est écrite ni lue (R5).
    pub(crate) fn master(&self) -> SecretsResult<&MasterKeys> {
        self.master.as_ref().ok_or(SecretsError::CryptoUnavailable)
    }

    /// Clés d'une portée pour l'usage de ces clés (`active` et `decrypt_only`), lues en base et
    /// ouvertes par la clé maîtresse ; vide si la portée n'a pas encore de clé.
    pub(crate) async fn opened(&self, scope: &Scope) -> SecretsResult<Vec<OpenedKey>> {
        let master = self.master()?;
        let entries = self
            .system
            .tenant_key_ring(scope.ring_params(self.purpose))
            .await?
            .items;
        let mut keys = Vec::with_capacity(entries.len());
        for entry in entries {
            let unavailable =
                |_| SecretsError::TenantKeyUnavailable(format!("clé {} illisible", entry.key_id));
            let id = KeyId::parse(&entry.key_id).map_err(unavailable)?;
            let wrapped = EncryptedEnvelope::parse(&entry.wrapped).map_err(unavailable)?;
            let material = master
                .engine
                .open(&wrapped, &scope.key_context(&entry.key_id, self.purpose)?)
                .map_err(unavailable)?;
            keys.push(OpenedKey {
                id,
                material,
                state: entry.state,
            });
        }
        Ok(keys)
    }

    /// Trousseau d'une portée pour l'usage de ces clés, s'il existe une clé.
    pub(crate) async fn ring(&self, scope: &Scope) -> SecretsResult<Option<TenantRing>> {
        TenantRing::from_keys(self.opened(scope).await?)
    }

    /// Trousseau d'une portée ; sa première clé est créée à la première valeur écrite (R2) ou au
    /// premier fichier chiffré. Une création concurrente perdue relit le trousseau.
    pub(crate) async fn active_ring(&self, scope: &Scope) -> SecretsResult<TenantRing> {
        if let Some(ring) = self.ring(scope).await? {
            return Ok(ring);
        }
        match self.create_key(scope, None, None).await {
            Ok(_) => {}
            Err(error) if error.is_conflict("SECRETS_TENANT_KEY_CONFLICT") => {}
            Err(error) => return Err(error),
        }
        self.ring(scope).await?.ok_or_else(|| {
            SecretsError::TenantKeyUnavailable("aucune clé après création".to_string())
        })
    }

    /// Nouvelle clé active pour une portée ; l'ancienne ne sert plus qu'à relire (R3).
    pub(crate) async fn rotate(
        &self,
        scope: &Scope,
        requested_by: Option<String>,
    ) -> SecretsResult<TenantKeyCreated> {
        self.master()?;
        let active = self
            .system
            .tenant_key_ring(scope.ring_params(self.purpose))
            .await?
            .items
            .into_iter()
            .find(|entry| entry.state == TenantKeyState::Active)
            .map(|entry| entry.key_id);
        self.create_key(scope, active, requested_by).await
    }

    /// Clé tirée, scellée par la clé maîtresse et rangée.
    async fn create_key(
        &self,
        scope: &Scope,
        replaces: Option<String>,
        requested_by: Option<String>,
    ) -> SecretsResult<TenantKeyCreated> {
        let master = self.master()?;
        let key_id = scope.new_key_id(self.purpose)?;
        let mut material = vec![0u8; KEY_BYTES];
        OsRng
            .try_fill_bytes(&mut material)
            .map_err(|_| CryptoError::RandomUnavailable)?;
        let material = SecretBytes::new(material)?;
        let wrapped = master.engine.seal(
            &material,
            &scope.key_context(key_id.as_str(), self.purpose)?,
        )?;
        drop(material);
        Ok(self
            .system
            .tenant_key_create(TenantKeyCreateParams {
                tenant: scope.tenant.clone(),
                purpose: self.purpose,
                key_id: key_id.as_str().to_string(),
                wrapped: wrapped.encode(),
                replaces,
                requested_by,
            })
            .await?)
    }

    /// Clé d'organisation rescellée par la clé maîtresse active ; faux si elle l'était déjà.
    pub(crate) async fn rewrap(&self, key: &RewrapKey) -> SecretsResult<bool> {
        let master = self.master()?;
        let scope = Scope::from_record(key.tenant.as_ref())?;
        let unavailable =
            |_| SecretsError::TenantKeyUnavailable(format!("clé {} illisible", key.key_id));
        let wrapped = EncryptedEnvelope::parse(&key.wrapped).map_err(unavailable)?;
        let expected = wrapped.key_id().as_str().to_string();
        let sealed = match master
            .engine
            .reencrypt_if_needed(&wrapped, &scope.key_context(&key.key_id, key.purpose)?)
            .map_err(unavailable)?
        {
            ReencryptResult::Current => return Ok(false),
            ReencryptResult::Rotated(sealed) => sealed,
        };
        self.system
            .tenant_key_rewrap(crate::models::TenantKeyRewrapParams {
                key_id: key.key_id.clone(),
                expected_master_key_id: expected,
                wrapped: sealed.encode(),
            })
            .await?;
        Ok(true)
    }
}
