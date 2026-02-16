use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ComponentMeta {
    pub label: String,
    pub category: String,
    pub icon: String,
    pub description: Option<String>,
}

