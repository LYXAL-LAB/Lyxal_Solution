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
//! l'organisation et reconstruite à chaque appel depuis la base. Le
//! module qui range les fichiers fournit le contexte de scellement (son identité de fiche) ; le
//! coffre-fort ne lit aucune de ses tables : après une rotation, c'est ce module qui rescelle ses
//! clés de fichiers ([`FileKeys::reseal`]) puis dit si une clé retirée sert encore
//! ([`FileKeys::destroy`]).
//!
//! **Cache facultatif** ([`FileKeys::with_cache`], activé par l'hôte) : une clé « fichiers »
//! ouverte est gardée en mémoire [`FILE_KEY_CACHE_SECONDS`] secondes au plus, par organisation et
//! identifiant de clé, [`FILE_KEY_CACHE_ENTRIES`] entrées au plus, dans un `SecretBytes` effacé à
//! l'éviction. Il ne sert qu'à **ouvrir** une clé de fichier ([`FileKeys::open`]) : la lecture
//! d'un fichier n'a plus à relire le trousseau en base. Il ne sert jamais à sceller : seule la
//! clé `active` scelle, et une clé retirée par une rotation faite sur un autre nœud peut être
//! détruite dès que plus aucun fichier ne l'utilise ; [`FileKeys::seal`] et
//! [`FileKeys::reseal`] relisent donc toujours le trousseau en base. Une clé `decrypt_only`
//! s'ouvre depuis le cache jusqu'à l'expiration de son entrée ; une clé détruite en disparaît au
//! plus tard 60 secondes après sa destruction (aussitôt sur le nœud qui la détruit). Usage
//! `files` seulement : la clé « secrets » du coffre-fort n'est jamais gardée. Aucun contenu de
//! clé n'est journalisé ; seuls les compteurs de succès et d'échecs sont exposés.

use lyxal_crypto::{CryptoError, EncryptedEnvelope, KeyId, SecretBytes, SecretContext, StreamKey};
use lyxal_surreal::RecordId;
use std::collections::HashMap;
use std::fmt;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Arc, Mutex, PoisonError};
use std::time::{Duration, Instant};

use crate::error::{SecretsError, SecretsResult};
use crate::keys::{KeyOpener, MasterKeys, OpenedKey, Scope, TenantKeys, TenantRing};
use crate::models::{KeyPurpose, RetiredKey, TenantKeyDestroyParams, TenantKeyRetiredParams};
use crate::store::SecretsStore;

/// Durée de garde d'une clé « fichiers » ouverte dans le cache, en secondes.
pub const FILE_KEY_CACHE_SECONDS: u64 = 60;
/// Nombre maximal de clés « fichiers » gardées dans le cache.
pub const FILE_KEY_CACHE_ENTRIES: usize = 1_024;

/// Relevé du cache des clés « fichiers » (aucun contenu de clé).
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct FileKeyCacheStats {
    /// Ouvertures servies par le cache.
    pub hits: u64,
    /// Ouvertures qui ont relu le trousseau en base.
    pub misses: u64,
    /// Clés gardées à cet instant (entrées échues comprises jusqu'à leur éviction).
    pub entries: usize,
}

/// Clé « fichiers » ouverte gardée en mémoire.
struct CachedKey {
    material: SecretBytes,
    cached_at: Instant,
}

/// Cache des clés « fichiers » ouvertes, par (organisation, identifiant de clé).
#[derive(Default)]
struct KeyCache {
    entries: Mutex<HashMap<(String, String), CachedKey>>,
    hits: AtomicU64,
    misses: AtomicU64,
}

impl KeyCache {
    const TTL: Duration = Duration::from_secs(FILE_KEY_CACHE_SECONDS);

    fn entries(&self) -> std::sync::MutexGuard<'_, HashMap<(String, String), CachedKey>> {
        self.entries.lock().unwrap_or_else(PoisonError::into_inner)
    }

    /// Copie de la clé gardée, si son entrée n'est pas échue à `now` ; une entrée échue est
    /// retirée (sa clé est effacée).
    fn get(&self, scope: &str, key_id: &str, now: Instant) -> SecretsResult<Option<SecretBytes>> {
        let mut entries = self.entries();
        let key = (scope.to_string(), key_id.to_string());
        let fresh = entries
            .get(&key)
            .map(|cached| now.saturating_duration_since(cached.cached_at) < Self::TTL);
        match fresh {
            Some(true) => {
                self.hits.fetch_add(1, Ordering::Relaxed);
                match entries.get(&key) {
                    Some(cached) => Ok(Some(copy(&cached.material)?)),
                    None => Ok(None),
                }
            }
            Some(false) => {
                entries.remove(&key);
                self.misses.fetch_add(1, Ordering::Relaxed);
                Ok(None)
            }
            None => {
                self.misses.fetch_add(1, Ordering::Relaxed);
                Ok(None)
            }
        }
    }

    /// Garde une copie de la clé ouverte à `now`. Cache plein : les entrées échues sont
    /// retirées, puis la plus ancienne.
    fn put(&self, scope: &str, key: &OpenedKey, now: Instant) -> SecretsResult<()> {
        let material = copy(&key.material)?;
        let mut entries = self.entries();
        let slot = (scope.to_string(), key.id.as_str().to_string());
        if !entries.contains_key(&slot) && entries.len() >= FILE_KEY_CACHE_ENTRIES {
            entries.retain(|_, cached| now.saturating_duration_since(cached.cached_at) < Self::TTL);
            if entries.len() >= FILE_KEY_CACHE_ENTRIES {
                let oldest = entries
                    .iter()
                    .min_by_key(|(_, cached)| cached.cached_at)
                    .map(|(slot, _)| slot.clone());
                if let Some(oldest) = oldest {
                    entries.remove(&oldest);
                }
            }
        }
        entries.insert(
            slot,
            CachedKey {
                material,
                cached_at: now,
            },
        );
        Ok(())
    }

    /// Retire une clé (détruite), quelle que soit son organisation.
    fn forget(&self, key_id: &str) {
        self.entries().retain(|(_, id), _| id != key_id);
    }

    fn stats(&self) -> FileKeyCacheStats {
        FileKeyCacheStats {
            hits: self.hits.load(Ordering::Relaxed),
            misses: self.misses.load(Ordering::Relaxed),
            entries: self.entries().len(),
        }
    }
}

/// Copie d'une clé dans un nouveau `SecretBytes` (effacé à sa libération).
fn copy(material: &SecretBytes) -> SecretsResult<SecretBytes> {
    Ok(SecretBytes::new(material.expose_secret().to_vec())?)
}

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
    cache: Option<Arc<KeyCache>>,
}

impl FileKeys {
    /// Clés de fichiers sur la session système (`system`) et le trousseau maître (absent : rien
    /// ne se scelle ni ne s'ouvre, `SECRETS_CRYPTO_UNAVAILABLE`). Sans cache : chaque appel relit
    /// le trousseau de l'organisation en base.
    pub fn new(system: SecretsStore, master: Option<MasterKeys>) -> Self {
        Self {
            keys: TenantKeys::new(system, master, KeyPurpose::Files),
            cache: None,
        }
    }

    /// Garde en mémoire les clés « fichiers » ouvertes, pour les ouvertures seulement
    /// ([`FILE_KEY_CACHE_SECONDS`] secondes, [`FILE_KEY_CACHE_ENTRIES`] entrées au plus). Les
    /// copies de ces clés de fichiers (`clone`) partagent le même cache.
    pub fn with_cache(mut self) -> Self {
        self.cache = Some(Arc::new(KeyCache::default()));
        self
    }

    /// Relevé du cache ; `None` sans cache.
    pub fn cache_stats(&self) -> Option<FileKeyCacheStats> {
        self.cache.as_ref().map(|cache| cache.stats())
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
        let envelope =
            EncryptedEnvelope::parse(&sealed.envelope).map_err(|_| SecretsError::ValueCorrupted)?;
        let scope = Scope::from_record(tenant)?;
        let ring = match &self.cache {
            None => self.keys.ring(&scope).await?,
            Some(cache) => {
                // Sans clé maîtresse, rien ne s'ouvre, cache compris
                self.keys.master()?;
                let organization = scope.context_tenant();
                if let Some(material) = cache.get(organization, &sealed.key_id, Instant::now())? {
                    let id =
                        KeyId::parse(&sealed.key_id).map_err(|_| SecretsError::ValueCorrupted)?;
                    return KeyOpener::new(id, material)?
                        .open_stream_key(&envelope, context)
                        .map_err(|_| SecretsError::ValueCorrupted);
                }
                let opened = self.keys.opened(&scope).await?;
                let now = Instant::now();
                for key in &opened {
                    cache.put(organization, key, now)?;
                }
                TenantRing::from_keys(opened)?
            }
        }
        .ok_or_else(|| {
            SecretsError::TenantKeyUnavailable(
                "aucune clé « fichiers » pour cette portée".to_string(),
            )
        })?;
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
        let destroyed = self
            .keys
            .system()
            .tenant_key_destroy(TenantKeyDestroyParams {
                key_id: key_id.to_string(),
                in_use: Some(in_use),
            })
            .await?
            .destroyed;
        if destroyed {
            if let Some(cache) = &self.cache {
                cache.forget(key_id);
            }
        }
        Ok(destroyed)
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
            .field("cache", &self.cache.is_some())
            .finish()
    }
}

#[cfg(test)]
#[allow(clippy::expect_used)]
mod tests {
    use super::*;
    use crate::models::TenantKeyState;

    fn opened(id: &str, byte: u8) -> OpenedKey {
        OpenedKey {
            id: KeyId::parse(id).expect("identifiant"),
            material: SecretBytes::new(vec![byte; 32]).expect("clé"),
            state: TenantKeyState::DecryptOnly,
        }
    }

    fn read(cache: &KeyCache, scope: &str, id: &str, now: Instant) -> Option<Vec<u8>> {
        cache
            .get(scope, id, now)
            .expect("lecture")
            .map(|material| material.expose_secret().to_vec())
    }

    #[test]
    fn a_cached_key_is_served_for_sixty_seconds_then_removed() {
        let cache = KeyCache::default();
        let start = Instant::now();
        cache.put("alpha", &opened("k1", 7), start).expect("garde");
        assert_eq!(
            read(&cache, "alpha", "k1", start + Duration::from_secs(59)),
            Some(vec![7; 32])
        );
        // Par organisation et identifiant de clé
        assert_eq!(read(&cache, "beta", "k1", start), None);
        assert_eq!(read(&cache, "alpha", "k2", start), None);
        assert_eq!(cache.stats().entries, 1);
        // Échue : plus servie, retirée
        assert_eq!(
            read(&cache, "alpha", "k1", start + Duration::from_secs(60)),
            None
        );
        assert_eq!(
            cache.stats(),
            FileKeyCacheStats {
                hits: 1,
                misses: 3,
                entries: 0
            }
        );
    }

    #[test]
    fn a_full_cache_drops_expired_entries_then_the_oldest() {
        let cache = KeyCache::default();
        let start = Instant::now();
        for index in 0..FILE_KEY_CACHE_ENTRIES {
            let at = start + Duration::from_millis(index as u64);
            cache
                .put("alpha", &opened(&format!("k{index}"), 1), at)
                .expect("garde");
        }
        assert_eq!(cache.stats().entries, FILE_KEY_CACHE_ENTRIES);
        // Aucune entrée échue : la plus ancienne laisse sa place
        let later = start + Duration::from_secs(30);
        cache
            .put("alpha", &opened("nouvelle", 2), later)
            .expect("garde");
        assert_eq!(cache.stats().entries, FILE_KEY_CACHE_ENTRIES);
        assert_eq!(read(&cache, "alpha", "k0", later), None);
        assert_eq!(read(&cache, "alpha", "k1", later), Some(vec![1; 32]));
        assert_eq!(read(&cache, "alpha", "nouvelle", later), Some(vec![2; 32]));
        // Toutes les anciennes échues : retirées d'un coup à l'entrée suivante
        let much_later = start + Duration::from_secs(75);
        cache
            .put("alpha", &opened("autre", 3), much_later)
            .expect("garde");
        assert_eq!(cache.stats().entries, 2);
        // Une clé déjà gardée est remplacée sans éviction
        cache
            .put("alpha", &opened("autre", 4), much_later)
            .expect("garde");
        assert_eq!(
            read(&cache, "alpha", "autre", much_later),
            Some(vec![4; 32])
        );
        assert_eq!(cache.stats().entries, 2);
    }

    #[test]
    fn a_destroyed_key_is_forgotten_at_once() {
        let cache = KeyCache::default();
        let now = Instant::now();
        cache.put("alpha", &opened("k1", 1), now).expect("garde");
        cache.put("alpha", &opened("k2", 2), now).expect("garde");
        cache.forget("k1");
        assert_eq!(read(&cache, "alpha", "k1", now), None);
        assert_eq!(read(&cache, "alpha", "k2", now), Some(vec![2; 32]));
    }

    #[test]
    fn nothing_of_a_key_is_printed() {
        let keys = FileKeys::new(SecretsStore::new(surrealdb::Surreal::init()), None).with_cache();
        assert_eq!(
            format!("{keys:?}"),
            "FileKeys { available: false, cache: true }"
        );
        assert_eq!(keys.cache_stats(), Some(FileKeyCacheStats::default()));
    }
}
