use crate::core::node::NodeId;
use crate::styles::model::StyleValue;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SlidesPhysicalLayout {
    pub slides: Vec<PhysicalSlide>,
    pub settings: ViewportSettings,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalSlide {
    pub id: NodeId,
    pub number: u32,
    pub steps: Vec<SlideStep>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SlideStep {
    pub index: u32,
    pub elements: Vec<PhysicalSlideElement>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalSlideElement {
    pub id: NodeId,
    pub x: f64,
    pub y: f64,
    pub z: i32,
    pub width: f64,
    pub height: f64,
    pub content: PhysicalSlideContent,
    pub styles: BTreeMap<String, StyleValue>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum PhysicalSlideContent {
    Text(String),
    Image { src: String },
    Shape { shape_type: String },
    Table { rows: usize, cols: usize },
    Group(Vec<PhysicalSlideElement>),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ViewportSettings {
    pub width: f64,  // en points (pt)
    pub height: f64,
    pub aspect_ratio: String, // ex: "16:9"
}

impl Default for ViewportSettings {
    fn default() -> Self {
        Self {
            width: 720.0,
            height: 405.0,
            aspect_ratio: "16:9".to_string(),
        }
    }
}

