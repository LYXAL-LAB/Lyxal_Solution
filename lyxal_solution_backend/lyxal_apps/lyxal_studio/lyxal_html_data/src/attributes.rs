use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub enum AttributeType {
    #[serde(rename = "string")] String,
    #[serde(rename = "boolean")] Boolean,
    #[serde(rename = "number")] Number,
    #[serde(rename = "select")] Select,
    #[serde(rename = "url")] Url,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Attribute {
    pub name: String,
    pub r#type: AttributeType,
    pub required: bool,
    pub options: Option<Vec<String>>,
}

pub fn get_attribute_type(_tag: &str, attr: &str) -> AttributeType {
    match attr {
        "required" | "disabled" | "readonly" | "checked" | "multiple" | "autofocus" => AttributeType::Boolean,
        "width" | "height" | "size" | "cols" | "rows" | "tabindex" | "step" => AttributeType::Number,
        "href" | "src" | "poster" | "action" | "formaction" => AttributeType::Url,
        _ => AttributeType::String,
    }
}

pub fn get_attributes_by_tag() -> HashMap<String, Vec<Attribute>> {
    HashMap::new() // Placeholder for actual data loaded from JSON
}
