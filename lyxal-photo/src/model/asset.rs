use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Asset {
    pub hash: String, // Identité physique unique (ex: SHA256)
    pub size: u64,
    pub mime: String,
    pub storage_key: String,
}

impl Asset {
    pub fn new(hash: String, size: u64, mime: String, storage_key: String) -> Self {
        Self { hash, size, mime, storage_key }
    }
}
