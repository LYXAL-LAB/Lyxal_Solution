use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Breakpoint {
    pub id: String,
    pub label: String,
    pub min_width: Option<i32>,
    pub max_width: Option<i32>,
    pub condition: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StyleDecl {
    pub style_source_id: String,
    pub breakpoint_id: String,
    pub state: Option<String>,
    pub property: String,
    pub value: serde_json::Value,
    pub listed: Option<bool>,
}

