use async_trait::async_trait;
use std::path::PathBuf;

#[async_trait]
pub trait StorageClient: Send + Sync {
    async fn upload(&self, name: &str, data: Vec<u8>, content_type: &str) -> Result<String, String>;
    async fn delete(&self, name: &str) -> Result<(), String>;
}

pub struct FsStorage {
    pub base_path: PathBuf,
}

#[async_trait]
impl StorageClient for FsStorage {
    async fn upload(&self, name: &str, data: Vec<u8>, _content_type: &str) -> Result<String, String> {
        let path = self.base_path.join(name);
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }
        std::fs::write(&path, data).map_err(|e| e.to_string())?;
        Ok(name.to_string())
    }
    async fn delete(&self, name: &str) -> Result<(), String> {
        let path = self.base_path.join(name);
        if path.exists() {
            std::fs::remove_file(path).map_err(|e| e.to_string())?;
        }
        Ok(())
    }
}
