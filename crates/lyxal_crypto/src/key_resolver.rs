use crate::error::CryptoError;
use crate::key::{EncryptionKey, KeyId};
use base64::engine::general_purpose::STANDARD;
use base64::Engine;
use std::collections::HashMap;
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::sync::{Arc, RwLock};
use zeroize::Zeroizing;

/// Politique de génération automatique de clé.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyGenerationPolicy {
    /// Autorise la génération automatique d'une nouvelle clé (environnement Dev)
    AllowGenerate,
    /// Exige une clé existante, échoue sinon (environnement Production Strict)
    RequireExisting,
}

/// Trait d'abstraction pour la résolution des clés (supportant la clé active et la rotation via Arc<EncryptionKey>).
pub trait KeyResolver: Send + Sync {
    /// Retourne l'identifiant de la clé active actuelle pour le chiffrement.
    fn active_key_id(&self) -> Result<KeyId, CryptoError>;

    /// Résout une clé par son identifiant unique sous forme d'Arc partageable sans copie mémoire.
    fn resolve(&self, id: &KeyId) -> Result<Arc<EncryptionKey>, CryptoError>;
}

/// Implémentation du trait `KeyResolver` pour les Pointeurs Intelligents `Arc<T>` (Permet le Dynamic Dispatch `Arc<dyn KeyResolver>`).
impl<T> KeyResolver for Arc<T>
where
    T: KeyResolver + ?Sized,
{
    fn active_key_id(&self) -> Result<KeyId, CryptoError> {
        (**self).active_key_id()
    }

    fn resolve(&self, id: &KeyId) -> Result<Arc<EncryptionKey>, CryptoError> {
        (**self).resolve(id)
    }
}

/// Fournisseur de clé via variable d'environnement (`LYXAL_CRYPTO_MASTER_KEY`).
pub struct EnvironmentKeyProvider {
    key_id: KeyId,
    cached_key: Arc<EncryptionKey>,
}

impl EnvironmentKeyProvider {
    pub fn new(env_var: impl AsRef<str>, key_id: KeyId) -> Result<Self, CryptoError> {
        let val = std::env::var(env_var.as_ref()).map_err(|_| CryptoError::MissingActiveKey)?;
        let trimmed = val.trim();

        // Accepte STRICTEMENT et UNIQUEMENT du Base64 standard de 32 octets avec effacement mémoire (Zeroizing)
        let bytes = Zeroizing::new(STANDARD.decode(trimmed).map_err(|_| CryptoError::InvalidKeyEncoding)?);
        if bytes.len() != 32 {
            return Err(CryptoError::InvalidKeyLength);
        }

        let key = EncryptionKey::try_from_slice(&bytes)?;
        Ok(Self {
            key_id,
            cached_key: Arc::new(key),
        })
    }

    pub fn default_env() -> Result<Self, CryptoError> {
        let key_id = KeyId::parse("main")?;
        Self::new("LYXAL_CRYPTO_MASTER_KEY", key_id)
    }
}

impl KeyResolver for EnvironmentKeyProvider {
    fn active_key_id(&self) -> Result<KeyId, CryptoError> {
        Ok(self.key_id.clone())
    }

    fn resolve(&self, id: &KeyId) -> Result<Arc<EncryptionKey>, CryptoError> {
        if id == &self.key_id {
            Ok(Arc::clone(&self.cached_key))
        } else {
            Err(CryptoError::KeyNotFound { key_id: id.to_string() })
        }
    }
}

/// Fournisseur de clé via fichier local (`lyxal-master.key`).
pub struct FileKeyProvider {
    path: PathBuf,
    key_id: KeyId,
    policy: KeyGenerationPolicy,
    cached_key: RwLock<Option<Arc<EncryptionKey>>>,
}

impl FileKeyProvider {
    pub fn new(path: impl AsRef<Path>, key_id: KeyId, policy: KeyGenerationPolicy) -> Self {
        Self {
            path: path.as_ref().to_path_buf(),
            key_id,
            policy,
            cached_key: RwLock::new(None),
        }
    }

    pub fn default_dev(dir: impl AsRef<Path>) -> Result<Self, CryptoError> {
        let key_id = KeyId::parse("main")?;
        Ok(Self::new(dir.as_ref().join("lyxal-master.key"), key_id, KeyGenerationPolicy::AllowGenerate))
    }

    pub fn default_strict(dir: impl AsRef<Path>) -> Result<Self, CryptoError> {
        let key_id = KeyId::parse("main")?;
        Ok(Self::new(dir.as_ref().join("lyxal-master.key"), key_id, KeyGenerationPolicy::RequireExisting))
    }

    fn read_key_from_path(&self) -> Result<EncryptionKey, CryptoError> {
        let content = fs::read_to_string(&self.path)?;
        let trimmed = content.trim();
        let bytes = Zeroizing::new(STANDARD.decode(trimmed).map_err(|_| CryptoError::InvalidKeyEncoding)?);
        EncryptionKey::try_from_slice(&bytes)
    }
}

impl KeyResolver for FileKeyProvider {
    fn active_key_id(&self) -> Result<KeyId, CryptoError> {
        Ok(self.key_id.clone())
    }

    fn resolve(&self, id: &KeyId) -> Result<Arc<EncryptionKey>, CryptoError> {
        if id != &self.key_id {
            return Err(CryptoError::KeyNotFound { key_id: id.to_string() });
        }

        {
            let lock = self.cached_key.read().map_err(|_| CryptoError::KeyStoreUnavailable)?;
            if let Some(ref k) = *lock {
                return Ok(Arc::clone(k));
            }
        }

        let mut lock = self.cached_key.write().map_err(|_| CryptoError::KeyStoreUnavailable)?;
        if let Some(ref k) = *lock {
            return Ok(Arc::clone(k));
        }

        if self.path.exists() {
            let key = Arc::new(self.read_key_from_path()?);
            *lock = Some(Arc::clone(&key));
            Ok(key)
        } else {
            match self.policy {
                KeyGenerationPolicy::AllowGenerate => {
                    let key = EncryptionKey::generate();
                    let b64 = Zeroizing::new(STANDARD.encode(key.expose()));

                    if let Some(parent) = self.path.parent() {
                        fs::create_dir_all(parent)?;
                    }

                    // Configuration des options de création atomique avec mode 0600 sous Unix
                    let mut options = OpenOptions::new();
                    options.write(true).create_new(true);

                    #[cfg(unix)]
                    {
                        use std::os::unix::fs::OpenOptionsExt;
                        options.mode(0o600);
                    }

                    match options.open(&self.path) {
                        Ok(mut file) => {
                            file.write_all(b64.as_bytes())?;
                            file.flush()?;
                            let arc_key = Arc::new(key);
                            *lock = Some(Arc::clone(&arc_key));
                            Ok(arc_key)
                        }
                        Err(err) if err.kind() == std::io::ErrorKind::AlreadyExists => {
                            // Relit la clé créée simultanément par un autre processus
                            let read_key = Arc::new(self.read_key_from_path()?);
                            *lock = Some(Arc::clone(&read_key));
                            Ok(read_key)
                        }
                        Err(err) => Err(err.into()),
                    }
                }
                KeyGenerationPolicy::RequireExisting => Err(CryptoError::GenerationProhibited),
            }
        }
    }
}

/// Résolveur composite associant une clé active et un trousseau de clés historiques pour la rotation.
pub struct CompositeKeyResolver {
    active_id: KeyId,
    keys: RwLock<HashMap<KeyId, Arc<EncryptionKey>>>,
}

impl CompositeKeyResolver {
    pub fn new(active_id: KeyId, active_key: EncryptionKey) -> Self {
        let mut map = HashMap::new();
        map.insert(active_id.clone(), Arc::new(active_key));
        Self {
            active_id,
            keys: RwLock::new(map),
        }
    }

    pub fn add_historical_key(&self, id: KeyId, key: EncryptionKey) -> Result<(), CryptoError> {
        let mut map = self.keys.write().map_err(|_| CryptoError::KeyStoreUnavailable)?;
        map.insert(id, Arc::new(key));
        Ok(())
    }
}

impl KeyResolver for CompositeKeyResolver {
    fn active_key_id(&self) -> Result<KeyId, CryptoError> {
        Ok(self.active_id.clone())
    }

    fn resolve(&self, id: &KeyId) -> Result<Arc<EncryptionKey>, CryptoError> {
        let map = self.keys.read().map_err(|_| CryptoError::KeyStoreUnavailable)?;
        if let Some(key) = map.get(id) {
            Ok(Arc::clone(key))
        } else {
            Err(CryptoError::KeyNotFound { key_id: id.to_string() })
        }
    }
}
