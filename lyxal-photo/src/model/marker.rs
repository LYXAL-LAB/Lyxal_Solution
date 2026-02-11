use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MarkerType {
    Face,
    Label,
    Manual,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum MarkerSource {
    Ai,
    Manual,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Marker {
    pub uid: String,
    pub file_uid: String, // Appartient strictement à un File
    pub marker_type: MarkerType,
    pub source: MarkerSource,
    pub x: f32, // 0.0 - 1.0
    pub y: f32,
    pub w: f32,
    pub h: f32,
    pub uncertainty: f32, // 0.0 - 100.0
}

impl Marker {
    pub fn new(uid: String, file_uid: String, x: f32, y: f32, w: f32, h: f32) -> Self {
        Self {
            uid,
            file_uid,
            marker_type: MarkerType::Face,
            source: MarkerSource::Ai,
            x,
            y,
            w,
            h,
            uncertainty: 0.0,
        }
    }
}
