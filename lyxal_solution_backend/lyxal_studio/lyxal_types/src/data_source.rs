use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum DataSourceValue {
    Number { value: f64 },
    String { value: String },
    Boolean { value: bool },
    StringArray { value: Vec<String> },
    Json { value: serde_json::Value },
}

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "camelCase")]
pub enum DataSource {
    Variable {
        id: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        scope_instance_id: Option<String>,
        name: String,
        value: DataSourceValue,
    },
    Parameter {
        id: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        scope_instance_id: Option<String>,
        name: String,
    },
    Resource {
        id: String,
        #[serde(skip_serializing_if = "Option::is_none")]
        scope_instance_id: Option<String>,
        name: String,
        resource_id: String,
    },
}

