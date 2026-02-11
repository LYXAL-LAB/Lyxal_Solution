use serde::{Deserialize, Serialize};
use crate::ops::Operation;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HistoryEntry {
    pub operation: Operation,
}

impl HistoryEntry {
    pub fn new(operation: Operation) -> Self {
        Self { operation }
    }
}

