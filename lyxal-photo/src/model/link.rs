use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Permission {
    Viewer,
    Editor,
    Download,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Link {
    pub token: String, // Unique
    pub target_uid: String, // Photo ou Album
    pub permissions: Vec<Permission>,
    pub expires_at: Option<DateTime<Utc>>,
}

impl Link {
    pub fn new(token: String, target_uid: String) -> Self {
        Self {
            token,
            target_uid,
            permissions: vec![Permission::Viewer],
            expires_at: None,
        }
    }
}
