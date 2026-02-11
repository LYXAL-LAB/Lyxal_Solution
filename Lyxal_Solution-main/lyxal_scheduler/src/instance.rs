//! Identifiant d'instance (namespace) pour isoler les pools.

use std::hash::{Hash, Hasher};

use serde::{Deserialize, Serialize};

pub const DEFAULT_INSTANCE: &str = "default";

#[derive(Debug, Clone, Eq, Serialize, Deserialize)]
#[serde(transparent)]
pub struct InstanceId(pub String);

impl PartialEq for InstanceId {
    fn eq(&self, other: &Self) -> bool {
        self.0 == other.0
    }
}

impl Hash for InstanceId {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.0.hash(state);
    }
}

impl From<&str> for InstanceId {
    fn from(value: &str) -> Self {
        Self(value.to_string())
    }
}

impl Default for InstanceId {
    fn default() -> Self {
        InstanceId(DEFAULT_INSTANCE.to_string())
    }
}
