use crate::identity::hash::{Hash, compute_hash};
use crate::history::HistoryLog;
use crate::serialize::json::to_canonical_json;
use crate::core::Document;
use serde_json;

pub fn compute_history_hash(base: &Document, log: &HistoryLog) -> Hash {
    // H0 = hash(base_document)
    let base_json = to_canonical_json(base).unwrap_or_default();
    let mut current_hash = compute_hash(base_json.as_bytes());

    // On parcourt les entrées jusqu'au curseur
    for i in 0..log.cursor() {
        let entry = &log.entries()[i];
        let op_json = serde_json::to_string(&entry.operation).unwrap_or_default();
        
        // H_n = hash(H_{n-1} + op_n_json)
        let mut combined = current_hash.0.as_bytes().to_vec();
        combined.extend_from_slice(op_json.as_bytes());
        current_hash = compute_hash(&combined);
    }
    
    current_hash
}
