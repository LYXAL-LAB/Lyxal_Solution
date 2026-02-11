use serde_json;
use crate::core::document::Document;
use crate::validate::{Validator, ValidationError};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum SerializationError {
    #[error("Validation failed: {0}")]
    Validation(#[from] ValidationError),
    
    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),
}

pub fn to_canonical_json(doc: &Document) -> Result<String, SerializationError> {
    // 1. Valider avant de sérialiser
    Validator::validate_document(doc)?;
    
    // 2. Sérialiser en JSON. 
    // Puisque nous utilisons BTreeMap pour les Maps, l'ordre des clés est déterministe.
    let json = serde_json::to_string(doc)?;
    Ok(json)
}

pub fn from_json(json: &str) -> Result<Document, SerializationError> {
    let doc: Document = serde_json::from_str(json)?;
    // Valider après désérialisation pour garantir l'intégrité
    Validator::validate_document(&doc)?;
    Ok(doc)
}

