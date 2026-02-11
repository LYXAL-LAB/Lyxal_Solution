use crate::core::node::NodeId;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SlidesLayout {
    pub slides: Vec<Slide>,
    pub metadata: SlidesDocumentMetadata,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Slide {
    pub id: NodeId,
    pub elements: Vec<SlideElement>,
    pub number: u32,
    pub intent: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SlideElement {
    pub id: NodeId,
    pub content: SlideContent,
    pub spatial: SpatialProperties,
    pub appearance_intent: Option<String>, // ex: "on_click"
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum SlideContent {
    Text(String),
    Image { src: String, caption: Option<String> },
    Shape { shape_type: String },
    Table { rows: usize, cols: usize },
    Group(Vec<SlideElement>),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SpatialProperties {
    pub x: f64,
    pub y: f64,
    pub z: i32,
    pub width: Option<f64>,
    pub height: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct SlidesDocumentMetadata {
    pub title: String,
    pub author: String,
}

