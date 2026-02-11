use crate::core::node::NodeId;
use crate::styles::model::StyleValue;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DrawPhysicalLayout {
    pub canvas: PhysicalCanvas,
    pub settings: CanvasSettings,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalCanvas {
    pub layers: Vec<PhysicalDrawLayer>,
    pub bounding_box: BoundingBox,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalDrawLayer {
    pub id: NodeId,
    pub name: String,
    pub elements: Vec<PhysicalDrawElement>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalDrawElement {
    pub id: NodeId,
    pub geometry: PhysicalGeometry,
    pub styles: BTreeMap<String, StyleValue>,
    pub z_order: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum PhysicalGeometry {
    Path {
        points: Vec<PhysicalPoint>,
        is_closed: bool,
    },
    Image {
        src: String,
        x: f64,
        y: f64,
        width: f64,
        height: f64,
    },
    Text {
        value: String,
        x: f64,
        y: f64,
    },
    Group {
        children: Vec<PhysicalDrawElement>,
        bounding_box: BoundingBox,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalPoint {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct BoundingBox {
    pub min_x: f64,
    pub min_y: f64,
    pub max_x: f64,
    pub max_y: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CanvasSettings {
    pub units: String, // ex: "pt", "px"
    pub scale: f64,
}

impl Default for CanvasSettings {
    fn default() -> Self {
        Self {
            units: "pt".to_string(),
            scale: 1.0,
        }
    }
}

