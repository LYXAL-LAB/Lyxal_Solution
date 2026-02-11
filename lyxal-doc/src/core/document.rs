use serde::{Deserialize, Serialize};
use super::node::Block;
use super::meta::Metadata;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Document {
    pub id: String,
    pub title: String,
    pub meta: Metadata,
    pub content: Vec<Block>,
}

impl Document {
    pub fn new(id: String, title: String) -> Self {
        Self {
            id,
            title,
            meta: Metadata::default(),
            content: Vec::new(),
        }
    }
}

