use std::collections::HashMap;
use lazy_static::lazy_static;

lazy_static! {
    pub static ref UNITS: HashMap<String, Vec<String>> = {
        let json = include_str!("units.json");
        serde_json::from_str(json).expect("Failed to parse units.json")
    };
}
