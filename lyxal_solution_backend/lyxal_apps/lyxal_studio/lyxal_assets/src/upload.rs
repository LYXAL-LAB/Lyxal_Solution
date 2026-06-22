use crate::storage::StorageClient;
use crate::utils::filename::get_unique_filename;
use crate::utils::s3_utils::sanitize_s3_key;
use crate::utils::get_asset_data::extract_metadata;
use serde_json::json;

pub struct Uploader {
    pub storage: Box<dyn StorageClient>,
}

impl Uploader {
    pub fn new(storage: Box<dyn StorageClient>) -> Self {
        Self { storage }
    }

    pub async fn upload(&self, filename: &str, data: Vec<u8>, content_type: &str) -> Result<serde_json::Value, String> {
        let name = get_unique_filename(&sanitize_s3_key(filename));
        self.storage.upload(&name, data.clone(), content_type).await?;
        let meta = extract_metadata(&data, content_type, &name);
        
        Ok(json!({
            "name": name,
            "size": data.len(),
            "format": content_type,
            "meta": meta,
            "status": "UPLOADED"
        }))
    }
}

