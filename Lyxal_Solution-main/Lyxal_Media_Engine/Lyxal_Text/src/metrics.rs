use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TextMetrics {
    pub width: f32,
    pub height: f32,
    pub line_height: f32,
    pub baseline: f32,
    pub ascender: f32,
    pub descender: f32,
}
