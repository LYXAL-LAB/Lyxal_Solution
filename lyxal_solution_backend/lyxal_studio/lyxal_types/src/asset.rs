use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ImageMeta {
    pub width: f64,
    pub height: f64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum Asset {
    Image {
        id: String,
        project_id: String,
        name: String,
        size: f64,
        format: String,
        meta: ImageMeta,
        filename: Option<String>,
    },
    Font {
        id: String,
        project_id: String,
        name: String,
        size: f64,
        format: String,
        filename: Option<String>,
    },
    File {
        id: String,
        project_id: String,
        name: String,
        size: f64,
        format: String,
        filename: Option<String>,
    },
}

impl Asset {
    pub fn name(&self) -> &str {
        match self {
            Asset::Image { name, .. } => name,
            Asset::Font { name, .. } => name,
            Asset::File { name, .. } => name,
        }
    }
}

