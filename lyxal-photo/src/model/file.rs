use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct File {
    pub uid: String,
    pub asset_hash: String, // Référence à l'Asset physique
    pub photo_uid: Option<String>, // Référence à la Photo logique
    pub path: String,
    pub name: String,
    pub origin: String,
    pub is_primary: bool,
    pub is_sidecar: bool,
}

impl File {
    pub fn new(uid: String, asset_hash: String, path: String, name: String) -> Self {
        Self {
            uid,
            asset_hash,
            photo_uid: None,
            path,
            name,
            origin: String::from("unknown"),
            is_primary: false,
            is_sidecar: false,
        }
    }
}
