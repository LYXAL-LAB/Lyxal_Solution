use async_trait::async_trait;
use anyhow::Result;

pub mod fs;
pub mod bunny;

#[async_trait]
pub trait StorageEngine: Send + Sync {
    /// Télécharge les octets d'un objet via sa storage_key (ex: fs://..., bunny://...)
    async fn get_bytes(&self, storage_key: &str) -> Result<Vec<u8>>;

    /// Télécharge un fichier vers le storage et retourne la storage_key finale
    async fn put_bytes(&self, path: &str, bytes: Vec<u8>, mime: &str) -> Result<String>;

    /// Variante pour uploader un fichier local directement
    async fn put_file(&self, path: &str, local_path: &std::path::Path, mime: &str) -> Result<String>;
}

pub struct StorageManager {
    fs: fs::LocalFsStorage,
    bunny: bunny::BunnyStorage,
}

impl StorageManager {
    pub fn new(local_root: String, bunny_config: bunny::BunnyConfig) -> Self {
        Self {
            fs: fs::LocalFsStorage::new(local_root),
            bunny: bunny::BunnyStorage::new(bunny_config),
        }
    }

    pub fn get_engine(&self, storage_key: &str) -> &dyn StorageEngine {
        if storage_key.starts_with("fs://") {
            &self.fs
        } else if storage_key.starts_with("bunny://") {
            &self.bunny
        } else {
            // Par défaut on peut tomber sur le FS ou lever une erreur
            &self.fs
        }
    }
}
