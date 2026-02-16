use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum StyleSource {
    Token {
        id: String,
        name: String,
    },
    Local {
        id: String,
    },
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct StyleSourceSelection {
    pub instance_id: String,
    pub values: Vec<String>,
}

