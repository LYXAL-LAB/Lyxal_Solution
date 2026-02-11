use crate::core::node::NodeId;
use crate::styles::model::StyleValue;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExcelPhysicalLayout {
    pub sheets: Vec<PhysicalExcelSheet>,
    pub settings: GridSettings,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalExcelSheet {
    pub name: String,
    pub grid: BTreeMap<String, PhysicalExcelCell>,
    pub column_widths: BTreeMap<usize, f64>,
    pub row_heights: BTreeMap<usize, f64>,
    pub viewport: ViewportArea,
    pub freeze_panes: FreezeSettings,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PhysicalExcelCell {
    pub id: NodeId,
    pub address: String,
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
    pub value: String, // Valeur formatée pour affichage
    pub styles: BTreeMap<String, StyleValue>,
    pub is_locked: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ViewportArea {
    pub start_address: String, // ex: "A1"
    pub end_address: String,   // ex: "M50"
    pub width: f64,
    pub height: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct FreezeSettings {
    pub frozen_rows: usize,
    pub frozen_columns: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GridSettings {
    pub default_column_width: f64,
    pub default_row_height: f64,
    pub viewport_width: f64,
    pub viewport_height: f64,
}

impl Default for GridSettings {
    fn default() -> Self {
        Self {
            default_column_width: 80.0,
            default_row_height: 20.0,
            viewport_width: 800.0,
            viewport_height: 600.0,
        }
    }
}

