use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Action {
    pub r#type: String,
    pub args: Vec<String>,
    pub code: String,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", content = "value", rename_all = "camelCase")]
pub enum PropValue {
    Number(f64),
    String(String),
    Boolean(bool),
    Json(serde_json::Value),
    Asset(String),
    Page(serde_json::Value),
    #[serde(rename = "string[]")]
    StringArray(Vec<String>),
    Expression(String),
    Action(Vec<Action>),
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Prop {
    pub id: String,
    pub instance_id: String,
    pub name: String,
    pub value: PropValue,
}
