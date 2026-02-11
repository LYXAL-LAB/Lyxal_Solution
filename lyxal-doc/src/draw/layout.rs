use crate::core::node::NodeId;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DrawLayout {
    pub canvas: DrawCanvas,
    pub metadata: DrawDocumentMetadata,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DrawCanvas {
    pub layers: Vec<DrawLayer>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DrawLayer {
    pub id: NodeId,
    pub name: String,
    pub elements: Vec<DrawElement>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DrawElement {
    pub id: NodeId,
    pub content: DrawContent,
    pub transform: DrawTransform,
    pub properties: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum DrawContent {
    Shape {
        shape_type: String,
        points: Vec<Point>,
    },
    Image {
        src: String,
    },
    Text {
        value: String,
    },
    Group(Vec<DrawElement>),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DrawTransform {
    pub translate_x: f64,
    pub translate_y: f64,
    pub rotate: f64,
    pub scale_x: f64,
    pub scale_y: f64,
}

impl Default for DrawTransform {
    fn default() -> Self {
        Self {
            translate_x: 0.0,
            translate_y: 0.0,
            rotate: 0.0,
            scale_x: 1.0,
            scale_y: 1.0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct DrawDocumentMetadata {
    pub title: String,
    pub author: String,
}

