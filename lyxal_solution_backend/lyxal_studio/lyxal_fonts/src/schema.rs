use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum FontFormat { Ttf, Woff, Woff2 }

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct VariationAxis {
    pub name: String,
    pub min: f64,
    pub default: f64,
    pub max: f64,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(untagged)]
pub enum FontMeta {
    Static {
        family: String,
        style: String,
        weight: u32,
    },
    Variable {
        family: String,
        variation_axes: HashMap<String, VariationAxis>,
    },
}

