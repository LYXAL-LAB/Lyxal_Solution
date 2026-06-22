use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use lazy_static::lazy_static;

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct PropertyData {
    pub unit_groups: Vec<String>,
    pub inherited: bool,
    pub initial: serde_json::Value,
    pub mdn_url: Option<String>,
}

lazy_static! {
    pub static ref PROPERTIES: HashMap<String, PropertyData> = {
        let json = include_str!("properties.json");
        serde_json::from_str(json).expect("Failed to parse properties.json")
    };
}
