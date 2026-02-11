use crate::core::node::{NodeId, ValueType};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExcelLayout {
    pub sheets: Vec<ExcelSheet>,
    pub metadata: ExcelDocumentMetadata,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExcelSheet {
    pub name: String,
    pub grid: BTreeMap<String, ExcelCell>, // Key is "A1", "B2", etc.
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExcelCell {
    pub id: NodeId,
    pub address: String,
    pub value: CalculatedValue,
    pub formula: Option<String>,
    pub is_locked: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(tag = "type", content = "value", rename_all = "snake_case")]
pub enum CalculatedValue {
    Number(f64),
    String(String),
    Boolean(bool),
    Date(u64),
    Currency { amount: f64, code: String },
    Error(String), // ex: "#REF!", "#CYCLE!"
    Empty,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ExcelDocumentMetadata {
    pub title: String,
    pub author: String,
}

