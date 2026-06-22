use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct AriaAttribute {
    pub name: String,
    pub r#type: String,
}

pub fn get_aria_attributes() -> Vec<AriaAttribute> {
    vec![] // Placeholder
}
