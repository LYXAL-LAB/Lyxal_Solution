use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
#[serde(rename_all = "lowercase")]
pub enum HttpMethod {
    Get,
    Post,
    Put,
    Delete,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct KeyValue {
    pub name: String,
    pub value: String, // Expression
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Resource {
    pub id: String,
    pub name: String,
    pub method: HttpMethod,
    pub url: String, // Expression
    pub search_params: Option<Vec<KeyValue>>,
    pub headers: Vec<KeyValue>,
    pub body: Option<String>, // Expression
}

