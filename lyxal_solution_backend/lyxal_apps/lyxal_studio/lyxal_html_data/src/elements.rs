use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Element {
    pub tag: String,
    pub label: String,
    pub void: bool,
}

pub fn get_elements() -> HashMap<String, Element> {
    HashMap::new() // Placeholder
}
