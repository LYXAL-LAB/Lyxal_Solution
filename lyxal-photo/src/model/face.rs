use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Face {
    pub marker_uid: String, // 1:1 avec Marker
    pub embedding: Vec<f32>, // Vecteur 512d
    pub cluster_id: Option<Uuid>, // Groupe de similarité
    pub subject_uid: Option<String>, // Identification (Subject/Person)
}

impl Face {
    pub fn new(marker_uid: String, embedding: Vec<f32>) -> Self {
        Self {
            marker_uid,
            embedding,
            cluster_id: None,
            subject_uid: None,
        }
    }
}
