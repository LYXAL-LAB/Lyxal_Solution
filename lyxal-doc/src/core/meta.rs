use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize, Default)]
pub struct Metadata {
    pub author: Option<String>,
    pub created_at: Option<u64>,
    pub updated_at: Option<u64>,
    pub extra: BTreeMap<String, String>,
    pub tags: Vec<SemanticTag>,
    pub policy: Option<NodePolicy>,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct SemanticTag {
    pub key: String,
    pub value: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct NodePolicy {
    pub read: Scope,
    pub write: Scope,
    pub comment: Scope,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Scope {
    Public,
    Private,
    Inherit,
    Restricted(Vec<String>), // Liste de rôles ou IDs
}

impl Default for Scope {
    fn default() -> Self {
        Scope::Inherit
    }
}
