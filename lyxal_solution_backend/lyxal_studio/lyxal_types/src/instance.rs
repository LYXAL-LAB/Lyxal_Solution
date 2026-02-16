use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum InstanceChild {
    #[serde(rename = "id")]
    Id { value: String },
    #[serde(rename = "text")]
    Text { 
        value: String,
        #[serde(default)]
        placeholder: bool 
    },
    #[serde(rename = "expression")]
    Expression { value: String },
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "camelCase")]
pub struct Instance {
    #[serde(rename = "type")]
    pub instance_type: String, // "instance"
    pub id: String,
    pub component: String,
    pub tag: Option<String>,
    pub label: Option<String>,
    pub children: Vec<InstanceChild>,
    pub props: Vec<String>, // Added missing props field
}

