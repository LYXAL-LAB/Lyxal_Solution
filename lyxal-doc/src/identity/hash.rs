use sha2::{Sha256, Digest};
use hex;
use serde::{Deserialize, Serialize};
use crate::core::Document;
use crate::serialize::json::to_canonical_json;
use thiserror::Error;

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord, Serialize, Deserialize)]
pub struct Hash(pub String);

#[derive(Error, Debug)]
pub enum HashError {
    #[error("Serialization error: {0}")]
    Serialization(String),
}

pub fn document_hash(doc: &Document) -> Result<Hash, HashError> {
    let json = to_canonical_json(doc).map_err(|e| HashError::Serialization(e.to_string()))?;
    Ok(compute_hash(json.as_bytes()))
}

pub fn compute_hash(data: &[u8]) -> Hash {
    let mut hasher = Sha256::new();
    hasher.update(data);
    let result = hasher.finalize();
    Hash(hex::encode(result))
}

