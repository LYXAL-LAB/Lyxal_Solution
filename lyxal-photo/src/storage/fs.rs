use async_trait::async_trait;
use anyhow::{Result, anyhow};
use std::path::{Path, PathBuf};
use tokio::fs;
use super::StorageEngine;

pub struct LocalFsStorage {
    root: PathBuf,
}

impl LocalFsStorage {
    pub fn new(root: String) -> Self {
        Self { root: PathBuf::from(root) }
    }

    fn resolve_path(&self, storage_key: &str) -> Result<PathBuf> {
        let relative = storage_key.strip_prefix("fs://")
            .ok_or_else(|| anyhow!("Invalid FS storage key"))?;
        Ok(self.root.join(relative))
    }
}

#[async_trait]
impl StorageEngine for LocalFsStorage {
    async fn get_bytes(&self, storage_key: &str) -> Result<Vec<u8>> {
        let full_path = self.resolve_path(storage_key)?;
        Ok(fs::read(full_path).await?)
    }

    async fn put_bytes(&self, path: &str, bytes: Vec<u8>, _mime: &str) -> Result<String> {
        let full_path = self.root.join(path);
        if let Some(parent) = full_path.parent() {
            fs::create_dir_all(parent).await?;
        }
        fs::write(&full_path, bytes).await?;
        Ok(format!("fs://{}", path))
    }

    async fn put_file(&self, path: &str, local_path: &Path, _mime: &str) -> Result<String> {
        let full_path = self.root.join(path);
        if let Some(parent) = full_path.parent() {
            fs::create_dir_all(parent).await?;
        }
        fs::copy(local_path, &full_path).await?;
        Ok(format!("fs://{}", path))
    }
}
