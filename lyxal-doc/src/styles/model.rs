use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct StyleSheet {
    pub name: String,
    pub version: String,
    pub base_styles: BTreeMap<String, StyleDefinition>,
    pub variants: BTreeMap<String, VariantOverlay>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct StyleDefinition {
    pub parent: Option<String>,
    pub properties: BTreeMap<String, StyleValue>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct VariantOverlay {
    pub context_key: String,
    pub overrides: BTreeMap<String, BTreeMap<String, StyleValue>>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(tag = "type", content = "value", rename_all = "snake_case")]
pub enum StyleValue {
    Number(f64),
    String(String),
    Color(String), // Hex code
    BoxValues([f64; 4]), // Top, Right, Bottom, Left
}

impl StyleSheet {
    pub fn new(name: String, version: String) -> Self {
        Self {
            name,
            version,
            base_styles: BTreeMap::new(),
            variants: BTreeMap::new(),
        }
    }
}

