use serde::{Deserialize, Serialize};
use crate::identity::hash::{Hash, document_hash};
use crate::identity::chain::compute_history_hash;
use crate::core::Document;
use crate::history::HistoryLog;

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DocumentDigest {
    pub document_hash: Hash,
    pub history_hash: Hash,
    pub version: usize,
}

impl DocumentDigest {
    pub fn from_state(base: &Document, current: &Document, log: &HistoryLog) -> Self {
        Self {
            document_hash: document_hash(current).unwrap(),
            history_hash: compute_history_hash(base, log),
            version: log.cursor(),
        }
    }
}
