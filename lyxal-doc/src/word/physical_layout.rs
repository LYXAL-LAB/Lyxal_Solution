use crate::core::node::NodeId;
use crate::styles::model::StyleValue;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WordPageLayout {
    pub pages: Vec<PhysicalPage>,
    pub settings: PageSettings,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalPage {
    pub number: u32,
    pub elements: Vec<PhysicalElement>,
    pub header: Vec<PhysicalElement>,
    pub footer: Vec<PhysicalElement>,
    pub footnotes: Vec<PhysicalElement>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalElement {
    pub id: NodeId,
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
    pub content: PhysicalContent,
    pub styles: BTreeMap<String, StyleValue>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type", rename_all = "snake_case")]
pub enum PhysicalContent {
    Line { text: String, runs: Vec<PhysicalTextRun> },
    Image { src: String },
    Table { rows: Vec<PhysicalTableRow> },
    Shape { shape_type: String },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalTextRun {
    pub text: String,
    pub styles: BTreeMap<String, StyleValue>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalTableRow {
    pub cells: Vec<PhysicalTableCell>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalTableCell {
    pub elements: Vec<PhysicalElement>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PageSettings {
    pub width: f64,  // en points (pt)
    pub height: f64,
    pub margins: [f64; 4], // Top, Right, Bottom, Left
}

impl Default for PageSettings {
    fn default() -> Self {
        Self {
            width: 595.0,  // A4 width
            height: 842.0, // A4 height
            margins: [72.0, 72.0, 72.0, 72.0], // 1 inch margins
        }
    }
}

