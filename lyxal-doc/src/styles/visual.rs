use crate::core::node::NodeId;
use crate::styles::model::StyleValue;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VisualLayout {
    pub root_elements: Vec<VisualElement>,
    pub metadata: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VisualElement {
    pub id: NodeId,
    pub element_type: String,
    pub resolved_styles: BTreeMap<String, StyleValue>,
    pub children: Vec<VisualElement>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum RenderContext {
    Print,
    Screen,
    Dark,
}

