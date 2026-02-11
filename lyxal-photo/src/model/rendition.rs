use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum RenditionPurpose {
    Thumb,
    Preview,
    Web,
    Transcode,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum RenditionStatus {
    Pending,
    Completed,
    Failed,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Rendition {
    pub file_uid: String,
    pub purpose: RenditionPurpose,
    pub format: String,
    pub width: u32,
    pub height: u32,
    pub storage_pointer: String,
    pub status: RenditionStatus,
}

impl Rendition {
    pub fn new(file_uid: String, purpose: RenditionPurpose, format: String) -> Self {
        Self {
            file_uid,
            purpose,
            format,
            width: 0,
            height: 0,
            storage_pointer: String::new(),
            status: RenditionStatus::Pending,
        }
    }
}
